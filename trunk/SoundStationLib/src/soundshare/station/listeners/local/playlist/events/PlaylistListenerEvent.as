package soundshare.station.listeners.local.playlist.events
{
	import flash.events.Event;
	
	public class PlaylistListenerEvent extends Event
	{
		public function PlaylistListenerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}