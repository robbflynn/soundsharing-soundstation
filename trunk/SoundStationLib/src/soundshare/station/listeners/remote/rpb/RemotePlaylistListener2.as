package soundshare.station.listeners.remote.rpb
{
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.station.builders.messages.listeners.RemotePlaylistListenerMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.station.listeners.remote.rpb.events.RemotePlaylistListenerEvent;
	import soundshare.station.utils.debuger.Debuger;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	import soundshare.sdk.sound.player.broadcast.BroadcastPlayer;
	
	public class RemotePlaylistListener2 extends SecureClientEventDispatcher
	{
		private var broadcastPlayer:BroadcastPlayer;
		
		// [Bindable] public var hostIsOnline:Boolean = false;
		
		public var playlist:Array;
		public var playlistContext:PlaylistContext;
		
		private var songIndex:int = 0;
		private var _playOrder:int = 0;
		
		public var _playing:Boolean = false;
		
		private var messageBuilder:RemotePlaylistListenerMessageBuilder;
		
		private var _context:StationContext;
		
		public function RemotePlaylistListener2()
		{
			super();
			
			broadcastPlayer = new BroadcastPlayer();
			broadcastPlayer.minSamples = 5;
			
			messageBuilder = new RemotePlaylistListenerMessageBuilder(this);
			
			addAction("BROADCAST_AUDIO_DATA", processAudioData);
			addAction("LOAD_AUDIO_DATA_ERROR", loadAudioDataError);
			addAction("CHANGE_SONG", changeSong);
			addAction("STOP_PLAYING", stopPlaying);
		}
		
		private function processAudioData(message:FlashSocketMessage):void
		{
			broadcastPlayer.process(message.$body);
		}
		
		private function stopPlaying(message:FlashSocketMessage):void
		{
			trace("-RemotePlaylistListener[stopPlaying]-");
			
			_playing = false;
			dispatchEvent(new RemotePlaylistListenerEvent(RemotePlaylistListenerEvent.STOP_PLAYING));
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
		
		private function loadAudioDataError():void
		{
			_playing = false;
			
			Debuger.error("Error loading adudio file!");
			Debuger.error(playlist[songIndex].path);
			
			Debuger.show();
		}
		
		public function set context(value:StationContext):void
		{
			_context = value;
		}
		
		public function get context():StationContext
		{
			return _context;
		}
		
		override protected function $dispatchSocketEvent(message:FlashSocketMessage):void
		{
			var event:Object = getActionData(message);
			
			if (event)
				dispatchEvent(new RemotePlaylistListenerEvent(event.type, event.data));
		}
		
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
		
		public function get playOrder():int
		{
			return _playOrder;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set volume(value:Number):void
		{
			broadcastPlayer.volume = value;
		}
		
		public function get volume():Number
		{
			return broadcastPlayer.volume;
		}
	}
}