package soundshare.station.data.groups
{
	import soundshare.sdk.data.base.DataObject;
	
	[Bindable]
	public class GroupData extends DataObject
	{
		public var _id:String;
		public var name:String;
		public var type:int = 0;
		
		public var info:String;
		
		public var accountId:String;
		public var ownerId:String;
		
		public var deletable:Boolean = true;
		
		public function GroupData()
		{
			super();
		}
	}
}