package soundshare.station.broadcasts.rpb
{
	import flashsocket.client.events.FlashSocketClientEvent;
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.station.broadcasts.rpb.events.RemotePlaylistBroadcastEvent;
	import soundshare.station.builders.messages.broadcasts.RemotePlaylistBroadcastMessageBuilder2;
	import soundshare.station.data.EmitterBroadcastContext;
	import soundshare.station.data.StationContext;
	import soundshare.station.data.channels.RemoteChannelContext;
	import soundshare.sdk.controllers.connection.client.ClientConnection;
	import soundshare.sdk.controllers.connection.client.events.ClientConnectionEvent;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.data.servers.ServerData;
	import soundshare.sdk.db.mongo.playlists.loader.PlaylistsLoader;
	import soundshare.sdk.db.mongo.playlists.loader.events.PlaylistsLoaderEvent;
	import soundshare.sdk.managers.broadcaster.Broadcaster;
	import soundshare.sdk.managers.connections.server.ConnectionsManager;
	import soundshare.sdk.managers.connections.server.events.ConnectionsManagerEvent;
	import soundshare.sdk.sound.channels.playlist.PlaylistChannel;
	import soundshare.sdk.sound.channels.playlist.events.PlaylistsChannelEvent;
	
	public class RemotePlaylistBroadcast extends Broadcaster
	{
		public var context:StationContext;
		
		private var playlistsLoader:PlaylistsLoader;
		private var remoteChannelContext:RemoteChannelContext = new RemoteChannelContext();
		
		private var playlistContext:PlaylistContext;
		private var playlistChannel:PlaylistChannel;
		
		private var connectionsManager:ConnectionsManager;
		
		private var broadcastContext:EmitterBroadcastContext = new EmitterBroadcastContext();
		
		private var connection:ClientConnection;
		private var messageBuilder:RemotePlaylistBroadcastMessageBuilder2;
		
		private var serverData:ServerData = new ServerData();
		private var listenerName:String;
		
		public var initiatorRoute:Array;
		
		public static const NONE_STATE:String = "";
		public static const PREPARE_STATE:String = "PREPARE_STATE";
		public static const PREPARE_COMPLETE_STATE:String = "PREPARE_COMPLETE_STATE";
		
		private var state:String = NONE_STATE;
		
		public function RemotePlaylistBroadcast()
		{
			super();
			
			playlistChannel = new PlaylistChannel();
			playlistChannel.addEventListener(PlaylistsChannelEvent.CHANGE_SONG, onChangeSong);
			playlistChannel.addEventListener(PlaylistsChannelEvent.LOAD_AUDIO_DATA_ERROR, onLoadAudioDataError);
			playlistChannel.addEventListener(PlaylistsChannelEvent.STOP_PLAYING, onStopPlaying);
			
			channelsMixer.addChannel(playlistChannel, "PlaylistChannel");
			
			messageBuilder = new RemotePlaylistBroadcastMessageBuilder2(this);
			
			addAction("PLAY", executePlaySong);
			addAction("STOP", executeStopSong);
			addAction("NEXT", executeNextSong);
			addAction("PREVIOUS", executePreviousSong);
			addAction("CHANGE_PLAY_ORDER", executeChangePlayOrder);
			addAction("DESTROY", executeDestroyBroadcast);
		}
		
		// ************************************************************************************************************
		// 													PREPARE
		// ************************************************************************************************************
		
		public function prepare(playlistContext:PlaylistContext, listenerName:String, serverData:Object):void
		{
			if (state == NONE_STATE)
			{
				this.state == PREPARE_STATE
				
				this.playlistContext = playlistContext;
				this.listenerName = listenerName;
				this.serverData.readObject(serverData);
				
				broadcastContext.token = this.serverData.token;
				
				trace("-RemotePlaylistBroadcast[prepare]-", serverData.address, serverData.port);
				
				connection = context.connectionsController.createConnection("CONNECTION-" + id);
				connection.addUnit(this);
				
				connection.addEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
				connection.addEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
				connection.addEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
				connection.address = serverData.address;
				connection.port = serverData.port;
				connection.connect();
			}
			else
				dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR));
		}
		
		private function onInitializationDisconnect(e:FlashSocketClientEvent):void
		{
			trace("--RemotePlaylistBroadcast[onInitializationDisconnect]-");
			
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
			
			context.connectionsController.destroyConnection(connection);
			
			connection.removeUnit(id);
			connection = null;
			
			reset();
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR, {
				code: 100,
				error: "Unable to connect to broadcast server!"
			}));
		}
		
		private function onInitializationError(e:FlashSocketClientEvent):void
		{
			trace("--RemotePlaylistBroadcast[onInitializationError]-")
			
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
			
			context.connectionsController.destroyConnection(connection);
			
			connection.removeUnit(id);
			connection = null;
			
			reset();
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR, {
				code: 100,
				error: "Unable to connect to broadcast server!"
			}));
		}
		
		private function onInitializationComplete(e:ClientConnectionEvent):void
		{
			trace("--RemotePlaylistBroadcast[onInitializationComplete]-", route, e.data);
			
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onInitializationDisconnect);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onInitializationError);
			connection.removeEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onInitializationComplete);
			
			connection.addEventListener(FlashSocketClientEvent.DISCONNECTED, onDisconnect);
			
			broadcastContext.connection = connection;
			
			connectionsManager = broadcastContext.connectionsManagerBuilder.build();
			connectionsManager.addSocketEventListener(ConnectionsManagerEvent.WATCH_FOR_DISCONNECT_COMPLETE, onWatchForDisconnectComplete);
			connectionsManager.addSocketEventListener(ConnectionsManagerEvent.WATCH_FOR_DISCONNECT_ERROR, onWatchForDisconnectError);
			connectionsManager.watchForDisconnect([route[1]]);
			
			
			
			/*broadcastContext.BROADCAST_SERVER_ROUTE = e.data.server.broadcastServerRoute;
			
			broadcastServerManager = broadcastContext.broadcastServerManagerBuilder.build();
			broadcastServerManager.receiverRoute = e.data.server.broadcastServerRoute;
			broadcastServerManager.addSocketEventListener(BroadcastServerManagerEvent.GET_MANAGERS_COMPLETE, onGetManagersCompelte);
			broadcastServerManager.getManagers();*/
		}
		
		/*private function onGetManagersCompelte(e:BroadcastServerManagerEvent):void
		{
			trace("--RemotePlaylistBroadcast[onGetManagersCompelte]-");

			broadcastServerManager.removeSocketEventListener(BroadcastServerManagerEvent.GET_MANAGERS_COMPLETE, onGetManagersCompelte);
			
			broadcastContext.broadcastServerManagerBuilder.destroy(broadcastServerManager);
			broadcastServerManager = null;
			
			broadcastContext.CONNECTIONS_MANAGER_ROUTE = e.data.managers.CONNECTIONS_MANAGER_ROUTE;
			
			connectionsManager = broadcastContext.ConnectionsManagerBuilder.build();
			connectionsManager.addSocketEventListener(ConnectionsManagerEvent.WATCH_FOR_DISCONNECT_COMPLETE, onWatchForDisconnectComplete);
			connectionsManager.addSocketEventListener(ConnectionsManagerEvent.WATCH_FOR_DISCONNECT_ERROR, onWatchForDisconnectError);
			connectionsManager.watchForDisconnect([route[1]]);
		}*/
		
		private function onWatchForDisconnectComplete(e:ConnectionsManagerEvent):void
		{
			connectionsManager.removeSocketEventListener(ConnectionsManagerEvent.WATCH_FOR_DISCONNECT_COMPLETE, onWatchForDisconnectComplete);
			connectionsManager.removeSocketEventListener(ConnectionsManagerEvent.WATCH_FOR_DISCONNECT_ERROR, onWatchForDisconnectError);
			
			var onlineReport:Object = e.data.report;
			
			trace("--RemotePlaylistBroadcast[onWatchForDisconnectComplete]-");
			
			if (onlineReport && onlineReport[route[1]])
			{
				connectionsManager.addSocketEventListener(ConnectionsManagerEvent.DISCONNECT_DETECTED, onListenerDisconnect);
				loadPlaylists();
			}
			else
			{
				broadcastContext.connectionsManagerBuilder.destroy(connectionsManager);
				connectionsManager = null;
				
				reset();
				dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR, {
					code: 100,
					error: "Broadcaster is offline!"
				}));
			}
		}
		
		private function onWatchForDisconnectError(e:ConnectionsManagerEvent):void
		{
			trace("--RemotePlaylistBroadcast[onWatchForDisconnectError]-");
			
			broadcastContext.connectionsManagerBuilder.destroy(connectionsManager);
			connectionsManager = null;
			
			reset();
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR, {
				code: 100,
				error: "Unable to connect to broadcast server!"
			}));
		}
		
		// ******************************************************************************************************************
		
		private function loadPlaylists():void
		{
			playlistsLoader = context.playlistsLoaderBuilder.build();
			playlistsLoader.addEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.addEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			playlistsLoader.load([playlistContext._id]);
		}
		
		private function onPlaylistsComplete(e:PlaylistsLoaderEvent):void
		{
			trace("PlaylistsChannel[onPlaylistsComplete]:", e.playlists.length);
			
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			context.playlistsLoaderBuilder.destroy(playlistsLoader);
			playlistsLoader = null;
			
			var playlist:Array = new Array();
			
			while (e.playlists.length > 0)
				playlist = playlist.concat(e.playlists.shift() as Array);
			
			trace("PlaylistsChannel[onPlaylistsComplete]:", playlist);
			
			playlistChannel.playlist = playlist
			message = messageBuilder.buildBroadcastMessage();
			
			state = PREPARE_COMPLETE_STATE;
			
			addChannelContext();
			context.registerBroadcast(this);
			
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_COMPLETE));
		}
		
		private function onPlaylistsError(e:PlaylistsLoaderEvent):void
		{
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			context.playlistsLoaderBuilder.destroy(playlistsLoader);
			playlistsLoader = null;
			
			trace("-RemotePlaylistBroadcast[onPlaylistsError]- Error loading playlists!");
			
			reset();
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR, {
				code: 100,
				error: "Unable to load playlsit!"
			}));
		}
		
		private function onDisconnect(e:FlashSocketClientEvent):void
		{
			trace("--RemotePlaylistBroadcast[onDisconnect]-");
			
			if (state == PREPARE_COMPLETE_STATE)
				destroyBroadcast();
			else
			{
				reset();
				dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR, {
					code: 100,
					error: "Disconnected while preparing!"
				}));
			}
		}
		
		private function onListenerDisconnect(e:ConnectionsManagerEvent):void
		{
			trace("--RemotePlaylistBroadcast[onListenerDisconnect]-");
			
			if (state == PREPARE_COMPLETE_STATE)
				destroyBroadcast();
			else
				reset();
		}
		
		// ******************************************************************************************************************
		
		public function reset():void
		{
			trace("-RemotePlaylistBroadcast[reset]", state);
			
			if (state == NONE_STATE)
				return ;
			
			stop();
			
			playlistChannel.reset();
			remoteChannelContext.clearObject();
			
			state = NONE_STATE;
			
			if (playlistsLoader)
			{
				context.playlistsLoaderBuilder.destroy(playlistsLoader);
				playlistsLoader = null;
			}
			
			if (connectionsManager)
			{
				broadcastContext.connectionsManagerBuilder.destroy(connectionsManager);
				connectionsManager = null;
			}
			
			if (connection)
			{
				context.connectionsController.destroyConnection(connection);
				
				connection.removeUnit(id);
				connection = null;
			}
			
			broadcastContext.connection = null;
		}
		
		public function close():void
		{
			trace("--RemotePlaylistBroadcast[close]-");
			
			var message:FlashSocketMessage = messageBuilder.buildCloseConnectionMessage();
			
			if (message)
				send(message);
			
			destroyBroadcast();
		}
		
		public function destroyBroadcast():void
		{
			trace("--RemotePlaylistBroadcast[destroyBroadcast]-");
			
			reset();
			removeChannelContext();
			
			context.unregisterBroadcast(this);
		}
		
		// ******************************************************************************************************************
		// 													COMMANDS
		// ******************************************************************************************************************
		
		private function onChangeSong(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onChangeSong]-");
			
			var message:FlashSocketMessage = messageBuilder.buildChangeSongMessage(e.songIndex);
			
			if (message)
				send(message);
		}
		
		private function onStopPlaying(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onStopPlaying]-");
			
			stop();
			sendStopPlaying();
		}
		
		private function sendStopPlaying():void
		{
			trace("-RemotePlaylistBroadcast[sendStopPlaying]-");
			
			var message:FlashSocketMessage = messageBuilder.buildStopPlayingMessage();
			
			if (message)
				send(message);
		}
		
		private function onLoadAudioDataError(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onPlaylistError]-");
			
			var message:FlashSocketMessage = messageBuilder.buildLoadAudioDataErrorMessage();
			
			if (message)
				send(message);
			
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.LOAD_AUDIO_DATA_ERROR));
		}
		
		// ******************************************************************************************************************
		// 													ACTIONS
		// ******************************************************************************************************************
		
		private function executePlaySong(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistBroadcast[executePlaySong]-");
			
			var body:Object = message.getJSONBody();
			var index:int = body.index ? body.index : 0;
			var order:int = body.order ? body.order : -1;
				
			start();
			playlistChannel.play(index);
			
			if (order != -1)
				playlistChannel.playOrder = order;
		}
		
		private function executeStopSong(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistBroadcast[executePlaySong]-");
			
			playlistChannel.stop();
			sendStopPlaying();
		}
		
		private function executeNextSong(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistBroadcast[executeNextSong]-");
			
			playlistChannel.next();
		}
		
		private function executePreviousSong(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistBroadcast[executePreviousSong]-");
			
			playlistChannel.previous();
		}
		
		private function executeChangePlayOrder(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistBroadcast[executePlaySong]-");
			
			var body:Object = message.getJSONBody();
			var order:int = body.order ? body.order : 0;
			
			playlistChannel.playOrder = order;
		}
		
		private function executeDestroyBroadcast(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistBroadcast[executeDestroyBroadcast]-");
			
			destroyBroadcast();
		}
		
		private function addChannelContext():void
		{
			var index:int = context.channels.getItemIndex(remoteChannelContext);
			
			if (index == -1)
				context.channels.addItem(remoteChannelContext);
		}
		
		private function removeChannelContext():void
		{
			var index:int = context.channels.getItemIndex(remoteChannelContext);
			
			if (index != -1)
				context.channels.removeItemAt(index);
		}
		
		public function get playlist():Array
		{
			return playlistChannel.playlist;
		}
	}
}