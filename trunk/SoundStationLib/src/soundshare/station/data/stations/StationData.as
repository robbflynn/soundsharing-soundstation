package soundshare.station.data.stations
{
	import soundshare.sdk.data.base.DataObject;
	
	[Bindable]
	[RemoteClass]
	public class StationData extends DataObject
	{
		public var _id:String;
		public var name:String;
		public var accountId:String;
		
		public var online:Boolean = false;
		
		public function StationData()
		{
		}
	}
}