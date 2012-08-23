package soundshare.station.broadcasts.srb
{
	import socket.message.FlashSocketMessage;
	
	import soundshare.station.broadcasts.srb.events.StandardRadioBroadcastEvent;
	import soundshare.station.builders.messages.broadcasts.StandardRadioBroadcastMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.station.data.channels.ChannelContext;
	import soundshare.station.data.channels.broadcasts.StandardRadioContext;
	import soundshare.sdk.managers.broadcaster.Broadcaster;
	import soundshare.sdk.sound.channels.microphone.MicrophoneChannel;
	import soundshare.sdk.sound.channels.playlist.PlaylistChannel;
	import soundshare.sdk.sound.channels.playlist.events.PlaylistsChannelEvent;
	
	public class StandardRadioBroadcast extends Broadcaster
	{
		private var playlistChannel:PlaylistChannel;
		private var microphoneChannel:MicrophoneChannel;
		
		private var _context:StationContext;
		private var _channelContext:ChannelContext;
		
		private var standardRadioContext:StandardRadioContext;
		
		private var messageBuilder:StandardRadioBroadcastMessageBuilder;
		
		public function StandardRadioBroadcast()
		{
			super();
			
			playlistChannel = new PlaylistChannel();
			playlistChannel.addEventListener(PlaylistsChannelEvent.AUDIO_INFO_DATA, onAudioInfoData);
			playlistChannel.addEventListener(PlaylistsChannelEvent.LOAD_AUDIO_DATA_ERROR, onLoadAudioDataError);
			playlistChannel.addEventListener(PlaylistsChannelEvent.CHANGE_SONG, onChangeSong);
			playlistChannel.addEventListener(PlaylistsChannelEvent.STOP_PLAYING, onStopPlaying);
			
			microphoneChannel = new MicrophoneChannel();
			
			channelsMixer.addChannel(playlistChannel, "PlaylistChannel");
			//broadcaster.channelsMixer.addChannel(microphoneChannel, "MicrophoneChannel");
			
			messageBuilder = new StandardRadioBroadcastMessageBuilder(this);
		}
		
		public function startBroadcasting():void
		{
			if (!broadcasting)
			{
				trace("-StandardRadioBroadcaster[start]-", receiverRoute, token);
				
				message = messageBuilder.buildBroadcastMessage();
				start();
				
				dispatchEvent(new StandardRadioBroadcastEvent(StandardRadioBroadcastEvent.START_BROADCASTING_COMPLETE));
			}
		}
		
		public function stopBroadcasting():void
		{
			trace("-StandardRadioBroadcaster[stop]-", broadcasting);
			
			if (broadcasting)
			{
				stop();
				playlistChannel.stop();
			}
		}
		
		public function playSong(index:int = 0):void
		{
			trace("-StandardRadioBroadcaster[playSong]-", broadcasting);
			
			if (broadcasting)
				playlistChannel.play(index);
		}
		
		public function stopSong():void
		{
			trace("-StandardRadioBroadcaster[stopSong]-", broadcasting);
			
			if (broadcasting)
				playlistChannel.stop();
		}
		
		public function nextSong():void
		{
			trace("-StandardRadioBroadcaster[nextSong]-");
			
			playlistChannel.next();
		}
		
		public function previousSong():void
		{
			trace("-StandardRadioBroadcaster[previousSong]-");
			
			playlistChannel.previous();
		}
		
		public function changePlayOrder(order:int = 0):void
		{
			trace("-StandardRadioBroadcaster[changePlayOrder]-");
			
			playlistChannel.playOrder = order;
		}
		
		private function onAudioInfoData(e:PlaylistsChannelEvent):void
		{
			trace("-StandardRadioBroadcaster[onAudioInfoData]-");
			
			var message:FlashSocketMessage = messageBuilder.buildSetAudioInfoDataMessage(e.data);
			
			if (message)
				send(message);
		}
		
		private function onLoadAudioDataError(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onPlaylistError]-");
			
			dispatchEvent(new StandardRadioBroadcastEvent(StandardRadioBroadcastEvent.LOAD_AUDIO_DATA_ERROR));
		}
		
		private function onChangeSong(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onChangeSong]-");
			
			var event:StandardRadioBroadcastEvent = new StandardRadioBroadcastEvent(StandardRadioBroadcastEvent.CHANGE_SONG);
			event.songIndex = e.songIndex;
			
			dispatchEvent(event);
		}
		
		private function onStopPlaying(e:PlaylistsChannelEvent):void
		{
			trace("-RemotePlaylistBroadcast[onStopPlaying]-");
			
			dispatchEvent(new StandardRadioBroadcastEvent(StandardRadioBroadcastEvent.STOP_PLAYING));
		}
		
		public function set context(value:StationContext):void
		{
			_context = value;
		}
		
		public function get context():StationContext
		{
			return _context;
		}
		
		public function set channelContext(value:ChannelContext):void
		{
			_channelContext = value;
			standardRadioContext = value.broadcast as StandardRadioContext;
		}
		
		public function get channelContext():ChannelContext
		{
			return _channelContext;
		}
		
		public function set playlist(value:Array):void
		{
			playlistChannel.playlist = value;
		}
		
		public function get playlist():Array
		{
			return playlistChannel.playlist;
		}
	}
}