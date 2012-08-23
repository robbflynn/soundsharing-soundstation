package soundshare.station.managers.broadcasts.events
{
	import socket.client.managers.events.events.ClientEventDispatcherEvent;
	
	import soundshare.station.broadcasts.base.BaseBroadcast;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class BroadcastsManagerEvent extends ClientEventDispatcherEvent
	{
		public static const CREATE_STANDARD_RADIO_BROADCAST_COMPLETE:String = "CREATE_STANDARD_RADIO_BROADCAST_COMPLETE";
		public static const CREATE_STANDARD_RADIO_BROADCAST_ERROR:String = "CREATE_STANDARD_RADIO_BROADCAST_ERROR";
		
		public static const CREATE_SRB_COMPLETE:String = "createSRBComplete";
		public static const CREATE_SRB_ERROR:String = "createSRBError";
		
		public static const DESTROY_STANDARD_RADIO_BROADCAST_COMPLETE:String = "DESTROY_STANDARD_RADIO_BROADCAST_COMPLETE";
		public static const DESTROY_STANDARD_RADIO_BROADCAST_ERROR:String = "DESTROY_STANDARD_RADIO_BROADCAST_ERROR";
		
		public static const DESTROY_SRB_COMPLETE:String = "destroySRBComplete";
		public static const DESTROY_SRB_ERROR:String = "destroySRBError";
		
		
		
		public static const SERVER_CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "SERVER_CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const SERVER_DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "SERVER_DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		
		
		
		public static const PREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "PREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const PREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "PREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_ERROR";
		
		public static const UNPREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "UNPREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const UNPREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "UNPREPARE_FOR_REMOTE_PLAYLIST_BROADCAST_ERROR";
		
		
		
		public static const BUILD_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "BUILD_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const BUILD_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "BUILD_REMOTE_PLAYLIST_BROADCAST_ERROR";
		
		public static const CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR";
		public static const CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR:String = "CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR";
		
		
		public static const CREATE_RPB_COMPLETE:String = "createRPBComplete";
		public static const CREATE_RPB_ERROR:String = "createRPBError";
		public static const CREATE_RPB_LIMIT_ERROR:String = "createRPBLimitError";
		
		
		public static const DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE:String = "DESTROY_REMOTE_PLAYLIST_BROADCAST_COMPLETE";
		public static const DESTROY_REMOTE_PLAYLIST_BROADCAST_ERROR:String = "DESTROY_REMOTE_PLAYLIST_BROADCAST_ERROR";
		
		public var listener:SecureClientEventDispatcher;
		public var initiatorRoute:Array;
		
		public var broadcast:SecureClientEventDispatcher;
		
		public function BroadcastsManagerEvent(type:String, data:Object = null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}