package soundshare.station.controllers.station.events
{
	import flash.events.Event;
	
	public class StationControllerEvent extends Event
	{
		public static const EMITTER_READY:String = "emitterReady";
		public static const EMITTER_ERROR:String = "emitterError";
		
		public static const EMITTER_INVALID_STATION:String = "emitterInvalidStation";
		
		public static const EMITTER_STATION_DOWN_COMPLETE:String = "emitterStationDownComplete";
		public static const EMITTER_STATION_DOWN_ERROR:String = "emitterStationDownError";
		
		public var errorCode:int;
		
		public function StationControllerEvent(type:String, errorCode:int=-1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.errorCode = errorCode;
		}
	}
}