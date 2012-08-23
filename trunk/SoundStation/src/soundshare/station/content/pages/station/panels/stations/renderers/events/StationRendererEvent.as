package soundshare.station.content.pages.station.panels.stations.renderers.events
{
	import flash.events.Event;
	
	import soundshare.station.data.channels.ChannelContext;
	import soundshare.station.data.stations.StationData;
	
	public class StationRendererEvent extends Event
	{
		public static const SWITCH:String = "switch";
		public static const SHUT_DOWN:String = "shutDown";
		public static const DELETE:String = "delete";
		
		public var stationData:StationData;
		
		public function StationRendererEvent(type:String, stationData:StationData=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.stationData = stationData;
		}
	}
}