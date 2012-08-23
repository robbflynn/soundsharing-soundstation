package soundshare.station.content.pages.login.events
{
	import flash.events.Event;
	
	public class LoginPanelEvent extends Event
	{
		public static const LOGGED:String = "logged";
		public static const ERROR:String = "error";
		
		public static const REGISTER:String = "register";
		
		public function LoginPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}