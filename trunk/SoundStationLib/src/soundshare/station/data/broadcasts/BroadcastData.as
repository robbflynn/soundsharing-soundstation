package soundshare.station.data.broadcasts
{
	import soundshare.sdk.data.base.DataObject;
	import soundshare.station.data.channels.ChannelContext;

	public class BroadcastData extends DataObject
	{
		public var _id:String;
		
		public var channel:ChannelContext;
		public var playlists:Array = new Array();
		
		public function BroadcastData()
		{
			super();
		}
	}
}