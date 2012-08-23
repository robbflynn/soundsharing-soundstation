package soundshare.station.content.pages.station.panels.channels.renderers.channel.events
{
	import flash.events.Event;
	
	import soundshare.station.data.channels.ChannelContext;
	
	public class ChannelRendererEvent extends Event
	{
		public static const EDIT:String = "edit";
		public static const BROADCAST:String = "broadcast";
		public static const INVATE:String = "invate";
		public static const DELETE:String = "delete";
		
		public var channelContext:ChannelContext;
		
		public function ChannelRendererEvent(type:String, channelContext:ChannelContext=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.channelContext = channelContext;
		}
	}
}