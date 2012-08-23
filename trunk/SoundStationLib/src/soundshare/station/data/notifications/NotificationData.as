package soundshare.station.data.notifications
{
	import soundshare.sdk.data.base.DataObject;
	
	[Bindable]
	public class NotificationData extends DataObject
	{
		public var _id:String;
		public var senderId:String;
		public var receiverId:String;
		
		public var groupId:String;
		
		public var message:String;
		
		public function NotificationData()
		{
			super();
		}
	}
}