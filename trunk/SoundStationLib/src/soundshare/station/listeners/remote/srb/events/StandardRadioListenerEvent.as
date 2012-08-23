package soundshare.station.listeners.remote.srb.events
{
	import flashsocket.client.managers.events.events.ClientEventDispatcherEvent;
	
	public class StandardRadioListenerEvent extends ClientEventDispatcherEvent
	{
		public static const CONNECTION_LOST:String = "CONNECTION_LOST";
		
		public static const AUDIO_DATA:String = "AUDIO_DATA";
		public static const AUDIO_INFO_DATA:String = "AUDIO_INFO_DATA";
		
		public function StandardRadioListenerEvent(type:String, data:Object = null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}