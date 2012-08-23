package soundshare.station.broadcasts.rpb.events
{
	import flashsocket.client.managers.events.events.ClientEventDispatcherEvent;
	
	public class RemotePlaylistBroadcastEvent extends ClientEventDispatcherEvent
	{
		public static const PREPARE_COMPLETE:String = "prepareComplete";
		public static const PREPARE_ERROR:String = "prepareError";
		
		public static const LOAD_AUDIO_DATA_ERROR:String = "loadAudioDataError";
		
		public static const CONNECTION_LOST:String = "connectionLost";
		
		public static const DESTROY_BROADCAST:String = "destroyBroadcast";
		
		public function RemotePlaylistBroadcastEvent(type:String, data:Object=null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}