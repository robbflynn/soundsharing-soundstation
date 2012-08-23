package soundshare.station.broadcasts.rpb
{
	import soundshare.sdk.managers.broadcaster.Broadcaster;
	
	public class RemotePlaylistBroadcast2 extends Broadcaster
	{
		/*private var playlistChannel:PlaylistChannel;
		
		private var _context:StationContext;
		
		private var ready:Boolean = false;
		
		private var accountManager:AccountManager;
		private var messageBuilder:RemotePlaylistBroadcastMessageBuilder;
		
		private var playlistsLoader:PlaylistsLoader;
		
		private var remoteChannelContext:RemoteChannelContext = new RemoteChannelContext();*/
		
		public function RemotePlaylistBroadcast2()
		{
			super();
			
			/*playlistsLoader = new PlaylistsLoader();
			
			playlistChannel = new PlaylistChannel();
			playlistChannel.addEventListener(PlaylistsChannelEvent.CHANGE_SONG, onChangeSong);
			playlistChannel.addEventListener(PlaylistsChannelEvent.LOAD_AUDIO_DATA_ERROR, onLoadAudioDataError);
			playlistChannel.addEventListener(PlaylistsChannelEvent.STOP_PLAYING, onStopPlaying);
			
			channelsMixer.addChannel(playlistChannel, "PlaylistChannel");
			
			messageBuilder = new RemotePlaylistBroadcastMessageBuilder(this);
			
			addAction("PLAY", executePlaySong);
			addAction("STOP", executeStopSong);
			addAction("NEXT", executeNextSong);
			addAction("PREVIOUS", executePreviousSong);
			addAction("CHANGE_PLAY_ORDER", executeChangePlayOrder);
			addAction("DESTROY", executeDestroyBroadcast);*/
		}
		
		/*public function prepare(playlistId:String, playlistName:String, listenerId:String, listenerName:String):void
		{
			trace("-RemotePlaylistBroadcast[prepare]-");
			
			remoteChannelContext._id = id;
			remoteChannelContext.playlistId = playlistId;
			remoteChannelContext.playlistName = playlistName;
			remoteChannelContext.listenerId = listenerId;
			remoteChannelContext.listenerName = listenerName;
			
			accountManager = context.accountManagersBuilder.build();
			accountManager.addSocketEventListener(AccountManagerEvent.START_WATCH_COMPLETE, onStartWatchComplete);
			accountManager.addSocketEventListener(AccountManagerEvent.START_WATCH_ERROR, onStartWatchError);
			accountManager.startWatchAccouns([listenerId]);
		}
		
		private function onStartWatchComplete(e:AccountManagerEvent):void
		{
			trace("--RemotePlaylistBroadcast[onStartWatchComplete]-");
			
			accountManager.removeSocketEventListener(AccountManagerEvent.START_WATCH_COMPLETE, onStartWatchComplete);
			accountManager.removeSocketEventListener(AccountManagerEvent.START_WATCH_ERROR, onStartWatchError);
			
			accountManager.addSocketEventListener(AccountManagerEvent.LOGOUT_DETECTED, onLogoutDetected);
			
			loadPlaylists();
		}
		
		private function onStartWatchError(e:AccountManagerEvent):void
		{
			trace("--RemotePlaylistBroadcast[onStartWatchError]-");
			
			accountManager.removeSocketEventListener(AccountManagerEvent.START_WATCH_COMPLETE, onStartWatchComplete);
			accountManager.removeSocketEventListener(AccountManagerEvent.START_WATCH_ERROR, onStartWatchError);
			
			Debuger.log("Error shit!!!");
		}
		
		private function onLogoutDetected(e:AccountManagerEvent):void
		{
			trace("-RemotePlaylistBroadcast[onLogoutDetected]-");
			
			executeDestroyBroadcast(null);
		}
		
		public function loadPlaylists():void
		{
			playlistsLoader.load([remoteChannelContext.playlistId]);
			playlistsLoader.addEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.addEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
		}
		
		private function onPlaylistsComplete(e:PlaylistsLoaderEvent):void
		{
			trace("PlaylistsChannel[onPlaylistsComplete]:", e.playlists.length);
			
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			var playlist:Array = new Array();
			
			while (e.playlists.length > 0)
				playlist = playlist.concat(e.playlists.shift() as Array);
			
			trace("PlaylistsChannel[onPlaylistsComplete]:", playlist);
			
			playlistChannel.playlist = playlist
			message = messageBuilder.buildBroadcastMessage();
			
			addChannelContext();
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_COMPLETE));
		}
		
		private function onPlaylistsError(e:PlaylistsLoaderEvent):void
		{
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			Alert.show("Error loading playlists!");
			
			dispatchEvent(new RemotePlaylistBroadcastEvent(RemotePlaylistBroadcastEvent.PREPARE_ERROR));
		}
		
		private function onChangeSong(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onChangeSong]-");
			
			var message:FlashSocketMessage = messageBuilder.buildChangeSongMessage(e.singIndex);
			
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
			
			var message:FlashSocketMessage = messageBuilder.buildStopPlaying();
			
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
		
		override public function reset():void
		{
			trace("-reset-");
			
			if (playlistsLoader.hasEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE))
				playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_COMPLETE, onPlaylistsComplete);
			
			if (playlistsLoader.hasEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR))
				playlistsLoader.removeEventListener(PlaylistsLoaderEvent.PLAYLISTS_ERROR, onPlaylistsError);
			
			stop();
			playlistChannel.reset();
			remoteChannelContext.clearObject();
			
			if (accountManager)
			{
				context.accountManagersBuilder.destroy(accountManager);
				accountManager = null;
			}
		}
		
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
			
			accountManager.removeSocketEventListener(AccountManagerEvent.LOGOUT_DETECTED, onLogoutDetected);
			accountManager.stopWatchAccouns([remoteChannelContext.listenerId]);
			
			dispatchSocketEvent({
				event: {
					type: "DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE"
				},
				receiver: receiverRoute
			});
			
			reset();
			removeChannelContext();
			
			context.unregisterBroadcast(this);
		}
		
		public function close():void
		{
			accountManager.removeSocketEventListener(AccountManagerEvent.LOGOUT_DETECTED, onLogoutDetected);
			accountManager.stopWatchAccouns([remoteChannelContext.listenerId]);
			
			dispatchSocketEvent({
				event: {
					type: RemotePlaylistListenerEvent.CONNECTION_CLOSED
				},
				receiver: receiverRoute
			});
			
			reset();
			removeChannelContext();
			
			context.unregisterBroadcast(this);
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
		
		public function set context(value:StationContext):void
		{
			_context = value;
			playlistsLoader.context = value;
		}
		
		public function get context():StationContext
		{
			return _context;
		}
		
		public function get playlist():Array
		{
			return playlistChannel.playlist;
		}*/
	}
}