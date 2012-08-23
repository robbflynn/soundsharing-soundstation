package soundshare.station.builders.broadcasts.events
{
	import flash.events.Event;
	
	import soundshare.station.broadcasts.rpb.RemotePlaylistBroadcast;
	
	public class RemotePlaylistBroadcastBuilderEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";
		
		public var broadcast:RemotePlaylistBroadcast;
		
		public function RemotePlaylistBroadcastBuilderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}