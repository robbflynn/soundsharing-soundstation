package soundshare.station.data.channels
{
	import soundshare.sdk.data.base.DataObject;
	import soundshare.sdk.plugins.manager.IPluginManager;
	
	[Bindable]
	public class RemoteChannelContext extends DataObject
	{
		public var _id:String;
		
		public var stationId:String;
		public var pluginManager:IPluginManager;
		
		public function RemoteChannelContext()
		{
		}
		
		override public function clearObject():void
		{
			_id = null;
			
			stationId = null;
			pluginManager = null;
		}
	}
}