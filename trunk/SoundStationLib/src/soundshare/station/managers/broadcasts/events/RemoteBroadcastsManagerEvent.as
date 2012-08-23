package soundshare.station.managers.broadcasts.events
{
	import socket.client.managers.events.events.ClientEventDispatcherEvent;
	
	public class RemoteBroadcastsManagerEvent extends ClientEventDispatcherEvent
	{
		public static const CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR";
		public static const CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR:String = "CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR";
		
		public static const DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const DESTROY_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "DESTROY_REMOTE_PLAYLIST_BROADCAST_ERROR";
		
		public function RemoteBroadcastsManagerEvent(type:String, data:Object=null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}