package soundshare.station.listeners.remote.rpb
{
	import flashsocket.client.events.FlashSocketClientEvent;
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.station.builders.messages.listeners.RemotePlaylistListenerMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.station.listeners.remote.rpb.events.RemotePlaylistListenerEvent;
	import soundshare.station.managers.broadcasts.RemoteBroadcastsManager;
	import soundshare.station.managers.broadcasts.events.BroadcastsManagerEvent;
	import soundshare.station.managers.broadcasts.events.RemoteBroadcastsManagerEvent;
	import soundshare.station.utils.debuger.Debuger;
	import soundshare.sdk.controllers.connection.client.ClientConnection;
	import soundshare.sdk.controllers.connection.client.events.ClientConnectionEvent;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.data.servers.ServerData;
	import soundshare.sdk.db.mongo.playlists.loader.PlaylistsLoader;
	import soundshare.sdk.db.mongo.playlists.loader.events.PlaylistsLoaderEvent;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	import soundshare.sdk.managers.servers.ServersManager;
	import soundshare.sdk.managers.servers.events.ServersManagerEvent;
	import soundshare.sdk.managers.stations.StationsManager;
	import soundshare.sdk.managers.stations.events.StationsManagerEvent;
	import soundshare.sdk.sound.player.broadcast.BroadcastPlayer;
	
	public class RemotePlaylistListener extends SecureClientEventDispatcher
	{
		public static const NONE_STATE:String = "";
		
		public static const PREPARE_STATE:String = "PREPARE_STATE";
		public static const PREPARE_COMPLETE_STATE:String = "PREPARE_COMPLETE_STATE";
		
		public static const CREATE_BROADCAST_STATE:String = "CREATE_BROADCAST_STATE";
		public static const CREATE_BROADCAST_COMPLETE_STATE:String = "CREATE_BROADCAST_COMPLETE_STATE";
		
		private var state:String = NONE_STATE;
		
		public var context:StationContext;
		
		private var _playlist:Array;
		private var _playOrder:int = 0;
		private var _playing:Boolean = false;
		
		private var broadcastPlayer:BroadcastPlayer;
		
		private var playlistContext:PlaylistContext;
		private var serverData:ServerData = new ServerData();
		
		private var songIndex:int = 0;
		
		private var stationsManager:StationsManager;
		private var serversManager:ServersManager;
		
		private var connection:ClientConnection;
		
		private var playlistsLoader:PlaylistsLoader;
		
		private var remoteBroadcastsManager:RemoteBroadcastsManager;
		private var targetRoutingMap:Object;
		
		private var messageBuilder:RemotePlaylistListenerMessageBuilder;
		
		public function RemotePlaylistListener()
		{
			super();
			
			broadcastPlayer = new BroadcastPlayer();
			broadcastPlayer.minSamples = 5;
			
			messageBuilder = new RemotePlaylistListenerMessageBuilder(this);
			
			addAction("BROADCAST_AUDIO_DATA", processAudioData);
			addAction("LOAD_AUDIO_DATA_ERROR", loadAudioDataError);
			addAction("CHANGE_SONG", changeSong);
			addAction("STOP_PLAYING", stopPlaying);
			addAction("CLOSE_CONNECTION", closeConnection);
		}
		
		override protected function $dispatchSocketEvent(message:FlashSocketMessage):void
		{
			var event:Object = getActionData(message);
			
			if (event)
				dispatchEvent(new RemotePlaylistListenerEvent(event.type, event.data));
		}
		
		// ************************************************************************************************************
		// 													PREPARE
		// ************************************************************************************************************
		
		public function prepare(playlistContext:PlaylistContext):void
		{
			trace("-prepareForRemotePlaylistBroadcast-", state, playlistContext.stationId);
			
			if (state == NONE_STATE)
			{
				this.state = PREPARE_STATE;
				this.playlistContext = playlistContext;
				
				stationsManager = context.stationsManagersBuilder.build();
				stationsManager.addSocketEventListener(StationsManagerEvent.START_WATCH_COMPLETE, onStartWatchComplete);
				stationsManager.addSocketEventListener(StationsManagerEvent.START_WATCH_ERROR, onStartWatchError);
				stationsManager.startWatchStations([playlistContext.stationId]);
			}
			else
				dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.PREPARE_ERROR));
		}
		
		private function onStartWatchComplete(e:StationsManagerEvent):void
		{
			trace("--RemotePlaylistListener[onStartWatchComplete]-");
			
			stationsManager.removeSocketEventListener(StationsManagerEvent.START_WATCH_COMPLETE, onStartWatchComplete);
			stationsManager.removeSocketEventListener(StationsManagerEvent.START_WATCH_ERROR, onStartWatchError);
			
			var stationsReport:Object = e.data.stationsReport;
			
			if (stationsReport && stationsReport[playlistContext.stationId])
			{
				targetRoutingMap = stationsReport[playlistContext.stationId].routingMap;
				dispatchEvent(new StationsManagerEvent(StationsManagerEvent.STATION_UP_DETECTED, e.data));
			}
			else
			{
				targetRoutingMap = null;
				dispatchEvent(new StationsManagerEvent(StationsManagerEvent.STATION_DOWN_DETECTED, e.data));
			}
			
			stationsManager.addSocketEventListener(StationsManagerEvent.STATION_UP_DETECTED, onStationUpDetected);
			stationsManager.addSocketEventListener(StationsManagerEvent.STATION_DOWN_DETECTED, onStationDownDetected);
			
			loadPlaylists();
		}
		
		private function onStartWatchError(e:StationsManagerEvent):void
		{
			trace("--RemotePlaylistListener[onStartWatchError]-");
			
			context.stationsManagersBuilder.destroy(stationsManager);
			stationsManager = null;
			
			reset();
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.PREPARE_ERROR));
		}
		
		private function onStationUpDetected(e:StationsManagerEvent):void
		{
			trace("--RemotePlaylistListener[onLoginDetected]-");
			
			targetRoutingMap[e.data.stationId] = e.data.routingMap;
			dispatchEvent(new StationsManagerEvent(StationsManagerEvent.STATION_UP_DETECTED, e.data));
		}
		
		private function onStationDownDetected(e:StationsManagerEvent):void
		{
			trace("--RemotePlaylistListener[onLogoutDetected]-");
			
			targetRoutingMap[e.data.stationId] = null;
			
			if (state == PREPARE_STATE)
			{
				reset();
				dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.PREPARE_ERROR));
			}
			else
			{
				dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.STATION_CONNECTION_LOST));
				reset(false);
			}
			
			dispatchEvent(new StationsManagerEvent(StationsManagerEvent.STATION_DOWN_DETECTED, e.data));
		}
		
		private function loadPlaylists():void
		{
			trace("--RemotePlaylistListener[loadPlaylists]-");
			
			playlistsLoader = context.playlistsLoaderBuilder.build();
			playlistsLoader.addEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.addEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			playlistsLoader.load([playlistContext._id]);
		}
		
		private function onPlaylistsComplete(e:PlaylistsLoaderEvent):void
		{
			trace("--RemotePlaylistListener[onPlaylistsComplete]-");
			
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			context.playlistsLoaderBuilder.destroy(playlistsLoader);
			playlistsLoader = null;
			
			_playlist = e.playlists[0];
			
			state = PREPARE_COMPLETE_STATE;
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.PREPARE_COMPLETE));
		}
		
		private function onPlaylistsError(e:PlaylistsLoaderEvent):void
		{
			trace("--RemotePlaylistListener[onPlaylistsError]-");
			
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			context.playlistsLoaderBuilder.destroy(playlistsLoader);
			playlistsLoader = null;
			
			reset();
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.PREPARE_ERROR));
		}
		
		// ************************************************************************************************************
		// 												BROADCAST CONNECTION
		// ************************************************************************************************************
		
		public function createBroadcastConnection():void
		{
			trace("--RemotePlaylistListener[createBroadcastConnection]-", state, targetRoutingMap);
			
			if (!targetRoutingMap)
				dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_ERROR));
			else
			if (state == PREPARE_COMPLETE_STATE)
			{
				state = CREATE_BROADCAST_STATE;
				
				serversManager = context.serversManagersBuilder.build();
				serversManager.addSocketEventListener(ServersManagerEvent.GET_AVAILABLE_SERVER_COMPLETE, onGetAvailableServerComplete);
				serversManager.addSocketEventListener(ServersManagerEvent.GET_AVAILABLE_SERVER_ERROR, onGetAvailableServerError);
				serversManager.getAvailableServer();
			}
		}
		
		private function onGetAvailableServerComplete(e:ServersManagerEvent):void
		{
			trace("--RemotePlaylistListener[onGetAvailableServerComplete]-");
			
			serversManager.removeSocketEventListener(ServersManagerEvent.GET_AVAILABLE_SERVER_COMPLETE, onGetAvailableServerComplete);
			serversManager.removeSocketEventListener(ServersManagerEvent.GET_AVAILABLE_SERVER_ERROR, onGetAvailableServerError);
			
			context.serversManagersBuilder.destroy(serversManager);
			serversManager = null;
			
			serverData.readObject(e.data);
			
			connection = context.connectionsController.createConnection("CONNECTION-" + id);
			connection.addUnit(this);
			
			connection.addEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.addEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.addEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
			connection.address = serverData.address;
			connection.port = serverData.port;
			connection.connect();
		}
		
		private function onGetAvailableServerError(e:ServersManagerEvent):void
		{
			trace("--RemotePlaylistListener[onGetAvailableServerError]-");
			
			serversManager.removeSocketEventListener(ServersManagerEvent.GET_AVAILABLE_SERVER_COMPLETE, onGetAvailableServerComplete);
			serversManager.removeSocketEventListener(ServersManagerEvent.GET_AVAILABLE_SERVER_ERROR, onGetAvailableServerError);
			
			context.serversManagersBuilder.destroy(serversManager);
			serversManager = null;
			
			reset(false);
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_ERROR, e.data));
		}
		
		private function onInitializationDisconnect(e:FlashSocketClientEvent):void
		{
			trace("--RemotePlaylistListener[onInitializationDisconnect]-");
			
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
			
			context.connectionsController.destroyConnection(connection);
			
			connection.removeUnit(id);
			connection = null;
			
			reset(false);
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_ERROR));
		}
		
		private function onInitializationError(e:FlashSocketClientEvent):void
		{
			trace("--RemotePlaylistListener[onInitializationError]-");
			
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
			
			context.connectionsController.destroyConnection(connection);
			
			connection.removeUnit(id);
			connection = null;
			
			reset(false);
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_ERROR));
		}
		
		private function onInitializationComplete(e:ClientConnectionEvent):void
		{
			trace("--RemotePlaylistListener[onInitializationComplete]-", route);
			
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);

			connection.addEventListener(FlashSocketClientEvent.DISCONNECTED, onDisconnect);
			
			remoteBroadcastsManager = context.remoteBroadcastsManagersBuilder.build(targetRoutingMap);
			remoteBroadcastsManager.addSocketEventListener(RemoteBroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE, onCreateRremotePlaylistBroadcastComplete);
			remoteBroadcastsManager.addSocketEventListener(RemoteBroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR, onCreateRremotePlaylistBroadcastError);
			remoteBroadcastsManager.addSocketEventListener(RemoteBroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR, onCreateRremotePlaylistBroadcastLimitError);
			remoteBroadcastsManager.createRemotePlaylistBroadcast(playlistContext._id, context.accountData.username, route, {
				_id: serverData._id,
				address: serverData.address,
				port: serverData.port,
				token: serverData.token
			});
			
			trace("---- YES ---")
		}
		
		private function onCreateRremotePlaylistBroadcastComplete(e:RemoteBroadcastsManagerEvent):void
		{
			context.remoteBroadcastsManagersBuilder.destroy(remoteBroadcastsManager);
			remoteBroadcastsManager = null;
			
			state = CREATE_BROADCAST_COMPLETE_STATE;
			receiverRoute = e.data.broadcastRoute;
			
			trace("--RemotePlaylistListener[onCreateRremotePlaylistBroadcastComplete]-", receiverRoute);
			
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_COMPLETE));
		}
		
		private function onCreateRremotePlaylistBroadcastError(e:RemoteBroadcastsManagerEvent):void
		{
			trace("--RemotePlaylistListener[onCreateRremotePlaylistBroadcastError]-");
			
			context.remoteBroadcastsManagersBuilder.destroy(remoteBroadcastsManager);
			remoteBroadcastsManager = null;
			
			reset(false);
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_ERROR));
		}
		
		private function onCreateRremotePlaylistBroadcastLimitError(e:BroadcastsManagerEvent):void
		{
			trace("--RemotePlaylistListener[onCreateRremotePlaylistBroadcastLimitError]-");
			
			context.remoteBroadcastsManagersBuilder.destroy(remoteBroadcastsManager);
			remoteBroadcastsManager = null;
			
			reset(false);
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_LIMIT_ERROR));
		}
		
		private function onDisconnect(e:FlashSocketClientEvent):void
		{
			trace("--RemotePlaylistListener[onDisconnect]-");
			
			reset(false);
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_LOST));
			
			/*if (state == CREATE_BROADCAST_STATE)
			{
				reset(false);
				dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_LOST));
			}
			else
			{
				reset(false);
				dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.BROADCAST_CONNECTION_ERROR));
			}*/
		}
		
		// ******************************************************************************************************************
		
		public function reset(all:Boolean = true):void
		{
			trace("--RemotePlaylistListener[reset]-", state);
			
			if (state == NONE_STATE || (!all && state == PREPARE_COMPLETE_STATE))
				return ;
			
			if (all)
			{
				if (stationsManager)
				{
					context.stationsManagersBuilder.destroy(stationsManager);
					stationsManager = null;
				}
				
				if (playlistsLoader)
				{
					playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
					playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
					
					context.playlistsLoaderBuilder.destroy(playlistsLoader);
					playlistsLoader = null;
				}
				
				state = NONE_STATE;
				targetRoutingMap = null;
			}
			else
				state = PREPARE_COMPLETE_STATE;
			
			_playing = false;
			
			if (serversManager)
			{
				context.serversManagersBuilder.destroy(serversManager);
				serversManager = null;
			}
			
			if (remoteBroadcastsManager)
			{
				context.remoteBroadcastsManagersBuilder.destroy(remoteBroadcastsManager);
				remoteBroadcastsManager = null;
			}
			
			if (connection)
			{
				connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
				connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
				connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
				connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onDisconnect);
				
				context.connectionsController.destroyConnection(connection);
				
				connection.removeUnit(id);
				connection = null;
			}
		}
		
		// ************************************************************************************************************
		// 												
		// ************************************************************************************************************
		
		private function processAudioData(message:FlashSocketMessage):void
		{
			broadcastPlayer.process(message.$body);
		}
		
		// ************************************************************************************************************
		// 												COMMANDS
		// ************************************************************************************************************
		
		public function playSong(index:int = 0, sendPlayOrder:Boolean = false):void
		{
			trace("RemotePlaylistListener[playSong]", index, sendPlayOrder);
			
			_playing = true;
			songIndex = index;
			
			var message:FlashSocketMessage = messageBuilder.buildPlaySongMessage(index, sendPlayOrder ? playOrder : -1);
			send(message);
		}
		
		public function stopSong():void
		{
			trace("-RemotePlaylistListener[stopSong]-");
			
			var message:FlashSocketMessage = messageBuilder.buildStopSongMessage();
			send(message);
		}
		
		public function previousSong():void
		{
			trace("-RemotePlaylistListener[previousSong]-");
			
			var message:FlashSocketMessage = messageBuilder.buildPreviousSongMessage();
			send(message);
		}
		
		public function nextSong():void
		{
			trace("-RemotePlaylistListener[nextSong]-");
			
			var message:FlashSocketMessage = messageBuilder.buildNextSongMessage();
			send(message);
		}
		
		public function changePlayOrder(order:int = 0):void
		{
			trace("-RemotePlaylistListener[changePlayOrder]-", _playOrder);
			
			_playOrder = order;
			
			var message:FlashSocketMessage = messageBuilder.buildChangePlayOrder(order);
			send(message);
		}
		
		public function destroyBroadcast():void
		{
			trace("-RemotePlaylistListener[destroyBroadcast]-");
			
			var message:FlashSocketMessage = messageBuilder.buildDestroyBroadcastMessage();
			send(message);
		}
		
		// ************************************************************************************************************
		// 												ACTIONS
		// ************************************************************************************************************
		
		private function stopPlaying(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistListener[stopPlaying]-");
			
			_playing = false;
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.STOP_PLAYING));
		}
		
		private function closeConnection(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistListener[closeConnection]-");
			
			reset();
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.CONNECTION_CLOSED));
		}
		
		private function changeSong(message:FlashSocketMessage):void
		{
			var body:Object = message.getJSONBody();
			
			trace("-RemotePlaylistListener[changeSong]-", body.index);
			
			if (body.hasOwnProperty("index"))
			{
				var e:RemotePlaylistListenerEvent = new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.SONG_CHANGED);
				e.index = int(body.index);
				
				songIndex = int(body.index);
				dispatchEvent(e);
			}
		}
		
		private function loadAudioDataError(message:FlashSocketMessage):void
		{
			_playing = false;
			
			Debuger.error("Error loading adudio file!");
			Debuger.error(playlist[songIndex].path);
			
			Debuger.show();
		}
		
		// ************************************************************************************************************
		// ************************************************************************************************************
		
		public function get playOrder():int
		{
			return _playOrder;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function get listening():Boolean
		{
			return state == CREATE_BROADCAST_COMPLETE_STATE;
		}
		
		public function set volume(value:Number):void
		{
			broadcastPlayer.volume = value;
		}
		
		public function get volume():Number
		{
			return broadcastPlayer.volume;
		}
		
		public function get playlist():Array
		{
			return _playlist;
		}
	}
}