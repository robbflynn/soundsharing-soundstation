package soundshare.station.data.groups
{
	import soundshare.sdk.data.base.DataObject;
	
	[Bindable]
	public class GroupMemberData extends DataObject
	{
		public var _id:String;
		public var groupId:String;
		public var memberId:String;
		
		public function GroupMemberData()
		{
			super();
		}
	}
}