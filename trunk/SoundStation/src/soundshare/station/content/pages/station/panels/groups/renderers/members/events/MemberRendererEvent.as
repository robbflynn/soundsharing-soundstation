package soundshare.station.content.pages.station.panels.groups.renderers.members.events
{
	import flash.events.Event;
	
	import soundshare.station.data.members.MemberData;
	
	public class MemberRendererEvent extends Event
	{
		public static const VIEW:String = "view";
		
		public var memberData:MemberData;
		
		public function MemberRendererEvent(type:String, memberData:MemberData=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.memberData = memberData;
		}
	}
}