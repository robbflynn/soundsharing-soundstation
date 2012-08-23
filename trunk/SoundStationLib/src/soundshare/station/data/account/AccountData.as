package soundshare.station.data.account
{
	import soundshare.sdk.data.base.DataObject;

	[Bindable]
	public class AccountData extends DataObject
	{
		public var _id:String;
		
		public var username:String;
		public var password:String;
		
		public function AccountData()
		{
		}
		
		public function toString():String
		{
			return '[AccountData(id="' + _id + '", username="' + username + '", password="' + password + '")]';
		}
	}
}