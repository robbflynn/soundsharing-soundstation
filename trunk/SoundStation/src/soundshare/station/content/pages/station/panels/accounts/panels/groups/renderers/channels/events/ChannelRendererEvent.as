package soundshare.station.content.pages.station.panels.accounts.panels.groups.renderers.channels.events
{
	import flash.events.Event;
	
	import soundshare.station.data.channels.ChannelContext;
	
	public class ChannelRendererEvent extends Event
	{
		public static const BROWSE:String = "browse";
		
		public var channelContext:ChannelContext;
		
		public function ChannelRendererEvent(type:String, channelContext:ChannelContext=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.channelContext = channelContext;
		}
	}
}