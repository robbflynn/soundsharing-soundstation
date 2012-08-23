package soundshare.station.managers.stations.events
{
	import flash.events.Event;
	
	public class StationRemoteControlEvent extends Event
	{
		public static const SELECT_CHANNEL:String = "SELECT_CHANNEL";
		
		public var data:Object;
		
		public function StationRemoteControlEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
	}
}