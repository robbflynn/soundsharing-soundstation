package soundshare.station.data.members
{
	import soundshare.sdk.data.base.DataObject;
	
	[Bindable]
	public class MemberData extends DataObject
	{
		public var _id:String;
		public var accountId:String;
		
		public var memberId:String;
		public var memberName:String;
					
		public function MemberData()
		{
			super();
		}
	}
}