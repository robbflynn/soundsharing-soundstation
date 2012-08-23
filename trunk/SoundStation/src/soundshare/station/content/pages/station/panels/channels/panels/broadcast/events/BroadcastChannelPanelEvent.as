package content.pages.station.panels.channels.panels.broadcast.events
{
	import flash.events.Event;
	
	public class BroadcastChannelPanelEvent extends Event
	{
		public static const START_BROADCASTING:String = "startBroadcasting";
		public static const STOP_BROADCASTING:String = "stopBroadcasting";
		
		public static const CREATE_BROADCAST_MANAGER:String = "createBroadcastManager";
		
		public var broadcastManager:Object;
		
		public function BroadcastChannelPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}