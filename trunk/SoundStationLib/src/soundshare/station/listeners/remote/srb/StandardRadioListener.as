package soundshare.station.listeners.remote.srb
{
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.station.builders.messages.listeners.StandardRadioListenerMessageBuilder;
	import soundshare.station.listeners.remote.srb.events.StandardRadioListenerEvent;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	import soundshare.sdk.sound.player.broadcast.BroadcastPlayer;
	
	public class StandardRadioListener extends SecureClientEventDispatcher
	{
		private var messageBuilder:StandardRadioListenerMessageBuilder;
		private var broadcastPlayer:BroadcastPlayer;
		
		private var listening:Boolean = false;
		
		public function StandardRadioListener()
		{
			super();
			
			messageBuilder = new StandardRadioListenerMessageBuilder(this);
			broadcastPlayer = new BroadcastPlayer();
		}
		
		override protected function $dispatchSocketEvent(message:FlashSocketMessage):void
		{
			var event:Object = getActionData(message);
			
			if (event)
			{
				if (event.type == StandardRadioListenerEvent.AUDIO_DATA)
					broadcastPlayer.process(message.$body);
				else
					dispatchEvent(new StandardRadioListenerEvent(event.type, event.data));
			}
		}
		
		public function start():void
		{
			if (!listening)
			{
				//active = true;
				listening = true;
				
				registerSocketEventListener(StandardRadioListenerEvent.CONNECTION_LOST);
				
				registerSocketEventListener(StandardRadioListenerEvent.AUDIO_DATA);
				registerSocketEventListener(StandardRadioListenerEvent.AUDIO_INFO_DATA);
				
				refreshInfoData();
			}
		}
		
		public function stop():void
		{
			if (listening)
			{
				listening = false;
				
				unregisterSocketEventListener(StandardRadioListenerEvent.CONNECTION_LOST);
				
				unregisterSocketEventListener(StandardRadioListenerEvent.AUDIO_DATA);
				unregisterSocketEventListener(StandardRadioListenerEvent.AUDIO_INFO_DATA);
			}
		}
		
		public function refreshInfoData():void
		{
			var message:FlashSocketMessage = messageBuilder.buildGetAudioInfoData();
			send(message);
		}
		
		/*public function set context(value:StationContext):void
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
		}*/
		
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