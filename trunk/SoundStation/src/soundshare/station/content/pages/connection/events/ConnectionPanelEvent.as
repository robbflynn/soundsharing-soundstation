package content.pages.connection.events
{
	import flash.events.Event;
	
	public class ConnectionPanelEvent extends Event
	{
		public static const CONNECTED:String = "connected";
		public static const ERROR:String = "error";
		
		public function ConnectionPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}