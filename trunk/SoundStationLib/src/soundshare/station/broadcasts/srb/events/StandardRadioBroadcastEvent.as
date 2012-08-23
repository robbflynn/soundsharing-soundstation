package soundshare.station.broadcasts.srb.events
{
	import flash.events.Event;
	
	public class StandardRadioBroadcastEvent extends Event
	{
		public static const CREATE_BROADCAST_COMPLETE:String = "createBroadcastComplete";
		public static const CREATE_BROADCAST_ERROR:String = "createBroadcastError";
		
		public static const START_BROADCASTING_COMPLETE:String = "startBroadcastingComplete";
		public static const START_BROADCASTING_ERROR:String = "startBroadcastingError";
		
		public static const STOP_BROADCASTING_COMPLETE:String = "stopBroadcastingComplete";
		public static const STOP_BROADCASTING_ERROR:String = "stopBroadcastingError";
		
		public static const PREPARE_COMPLETE:String = "prepareComplete";
		public static const PREPARE_ERROR:String = "prepareError";
		
		public static const LOAD_AUDIO_DATA_ERROR:String = "loadAudioDataError";
		public static const STOP_PLAYING:String = "stopPlaying";
		public static const CHANGE_SONG:String = "changeSong";
		
		public var songIndex:int = 0;
		
		public function StandardRadioBroadcastEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}