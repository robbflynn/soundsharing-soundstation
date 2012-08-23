package soundshare.station.data.channels
{
	import soundshare.station.data.StationContext;
	import soundshare.station.data.channels.broadcasts.StandardRadioContext;
	import soundshare.station.data.channels.broadcasts.base.BroadcastContext;
	import soundshare.sdk.data.base.DataObject;
	import soundshare.sdk.data.plugin.PluginConfigurationData;
	
	[Bindable]
	public class ChannelContext extends DataObject
	{
		public var _id:String;
		public var accountId:String;
		public var stationId:String;
		
		public var name:String;
		public var info:String;
		public var genre:String;
		public var type:int;
		public var status:int = 0;
		public var groups:Array = new Array();
		public var route:Array;
		
		public var active:Boolean = false;;
		
		public var plugin:PluginConfigurationData;
		
		public var broadcastType:int = -1;
		public var broadcast:BroadcastContext;
		
		public function ChannelContext()
		{
			
		}
		
		override public function readObject(obj:Object, excep:Array = null):Boolean
		{
			excep = excep ? excep.concat(["broadcast", "route", "groups"]) : ["broadcast", "route", "groups"];
			
			if (!super.readObject(obj, excep))
				return false;
			
			if (obj.route)
				route = obj.route;
			
			if (obj.groups)
				groups = obj.groups;
			
			if (obj.plugin)
			{
				if (!plugin)
					plugin = new PluginConfigurationData();
				else
					plugin.clearObject();
				
				plugin.readObject(obj.plugin);
			}
			
			return true;
		}
		
		override public function clearObject():void
		{
			_id = null;
			accountId = null;
			stationId = null;
			
			name = null;
			info = null;
			genre = null;
			type = NaN;
			status = 0;
			route = null;
			groups = new Array();
			
			active = false;
			plugin = null;
		}
		
		override public function get data():Object
		{
			var obj:Object = {
				accountId: accountId,
				stationId: stationId,
				
				name: name,
				info: info,
				genre: genre,
				type: type,
				status: status,
				groups:groups,
				active: active,
				
				plugin: plugin ? plugin.data : null
			};
			
			return obj;
		}
		
		public function toString():String
		{
			return "ChannelContext[" + _id + "]";
		}
	}
}