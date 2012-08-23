package soundshare.station.broadcasts.base
{
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class BaseBroadcast extends SecureClientEventDispatcher
	{
		public function BaseBroadcast()
		{
			super();
		}
		
		public function reset():void
		{
			
		}
	}
}