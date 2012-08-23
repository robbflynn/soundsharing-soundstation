package soundshare.station.managers.account.events
{
	import flashsocket.client.managers.events.events.ClientEventDispatcherEvent;
	
	public class AccountManagerEvent extends ClientEventDispatcherEvent
	{
		public static const NEW_NOTIFICATION_MESSAGE:String = "newNotificationMessage";
		
		public static const SHUT_DOWN_STATION:String = "SHUT_DOWN_STATION";
		
		public static const STATION_INSERTED:String = "STATION_INSERTED";
		public static const STATION_UPDATED:String = "STATION_UPDATED";
		public static const STATION_DELETED:String = "STATION_DELETED";
		
		public static const PLAYLIST_INSERTED:String = "PLAYLIST_INSERTED";
		public static const PLAYLIST_UPDATED:String = "PLAYLIST_UPDATED";
		public static const PLAYLIST_DELETED:String = "PLAYLIST_DELETED";
		
		public static const CHANNEL_INSERTED:String = "CHANNEL_INSERTED";
		public static const CHANNEL_UPDATED:String = "CHANNEL_UPDATED";
		public static const CHANNEL_DELETED:String = "CHANNEL_DELETED";
		
		public static const GROUP_INSERTED:String = "GROUP_INSERTED";
		public static const GROUP_UPDATED:String = "GROUP_UPDATED";
		public static const GROUP_DELETED:String = "GROUP_DELETED";
		
		public static const SERVER_INSERTED:String = "SERVER_INSERTED";
		public static const SERVER_UPDATED:String = "SERVER_UPDATED";
		public static const SERVER_DELETED:String = "SERVER_DELETED";
		
		public function AccountManagerEvent(type:String, data:Object=null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}