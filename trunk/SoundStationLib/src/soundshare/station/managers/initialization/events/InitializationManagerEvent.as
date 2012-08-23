package soundshare.station.managers.initialization.events
{
	import flash.events.Event;
	
	public class InitializationManagerEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";
		
		public var data:Object;
		
		public function InitializationManagerEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
	}
}