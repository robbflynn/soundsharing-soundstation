package soundshare.station.content.pages.station.panels.channels.renderers.playlist.events
{
	import flash.events.Event;
	
	import soundshare.station.data.channels.RemoteChannelContext;
	
	public class PlaylistChannelRendererEvent extends Event
	{
		public static const CLOSE:String = "close";
		
		public var remoteChannelContext:RemoteChannelContext;
		
		public function PlaylistChannelRendererEvent(type:String, remoteChannelContext:RemoteChannelContext=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.remoteChannelContext = remoteChannelContext;
		}
	}
}