package soundshare.station.listeners.remote.rpb.events
{
	import socket.client.managers.events.events.ClientEventDispatcherEvent;

	public class RemotePlaylistListenerEvent extends ClientEventDispatcherEvent
	{
		public static const AUDIO_DATA:String = "AUDIO_DATA";
		public static const AUDIO_INFO_DATA:String = "AUDIO_INFO_DATA";
		
		public static const PREPARE_COMPLETE:String = "PREPARE_COMPLETE";
		public static const PREPARE_ERROR:String = "PREPARE_ERROR";
		
		public static const BROADCAST_CONNECTION_COMPLETE:String = "BROADCAST_CONNECTION_COMPLETE";
		public static const BROADCAST_CONNECTION_ERROR:String = "BROADCAST_CONNECTION_ERROR";
		public static const BROADCAST_CONNECTION_LIMIT_ERROR:String = "BROADCAST_CONNECTION_LIMIT_ERROR";
		
		public static const SONG_CHANGED:String = "SONG_CHANGED";
		public static const STOP_PLAYING:String = "STOP_PLAYING";
		
		public static const CONNECTION_CLOSED:String = "CONNECTION_CLOSED";
		public static const STATION_CONNECTION_LOST:String = "STATION_CONNECTION_LOST";
		public static const BROADCAST_CONNECTION_LOST:String = "BROADCAST_CONNECTION_LOST";
		
		public var index:int;
		
		public function RemotePlaylistListenerEvent(type:String, data:Object = null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}