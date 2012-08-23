package soundshare.station.components.paginators.events
{
	import flash.events.Event;
	
	public class PaginatorEvent extends Event
	{
		public static const FIRST:String = "first";
		public static const PREVIOUS:String = "previous";
		public static const NEXT:String = "next";
		public static const LAST:String = "last";
		public static const GOTO:String = "goto";
		public static const CHANGE:String = "change";
		
		public var page:int = 1; 
		public var items_per_page:int = 10;
		
		public function PaginatorEvent(type:String, page:int = 1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.page = page;
		}
	}
}