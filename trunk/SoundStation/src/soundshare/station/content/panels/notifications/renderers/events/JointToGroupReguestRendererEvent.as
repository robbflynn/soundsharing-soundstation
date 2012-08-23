package soundshare.station.content.panels.notifications.renderers.events
{
	import flash.events.Event;
	
	import soundshare.station.data.notifications.NotificationData;
	
	public class JointToGroupReguestRendererEvent extends Event
	{
		public static const ALLOW:String = "allow";
		public static const DENY:String = "deny";
		public static const BROWSE:String = "browse";
		
		public var notificationData:NotificationData;
		
		public function JointToGroupReguestRendererEvent(type:String, notificationData:NotificationData=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.notificationData = notificationData;
		}
	}
}