package soundshare.station.content.pages.station.panels.accounts.panels.groups.renderers.playlists.events
{
	import flash.events.Event;
	
	import soundshare.sdk.data.platlists.PlaylistContext;
	
	public class PlaylistRendererEvent extends Event
	{
		public static const BROWSE:String = "browse";
		
		public var playlistContext:PlaylistContext;
		
		public function PlaylistRendererEvent(type:String, playlistContext:PlaylistContext=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.playlistContext = playlistContext;
		}
	}
}