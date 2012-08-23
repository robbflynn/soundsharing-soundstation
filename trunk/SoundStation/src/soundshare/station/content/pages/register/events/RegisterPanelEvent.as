package soundshare.station.content.pages.register.events
{
	import flash.events.Event;
	
	public class RegisterPanelEvent extends Event
	{
		public static const REGISTRED:String = "registred";
		public static const ERROR:String = "error";
		public static const LOGIN:String = "login";
		
		public function RegisterPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}