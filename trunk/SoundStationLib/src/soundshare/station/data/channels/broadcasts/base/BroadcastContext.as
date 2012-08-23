package soundshare.station.data.channels.broadcasts.base
{
	import soundshare.sdk.data.base.DataObject;
	import soundshare.station.data.channels.ChannelContext;

	public class BroadcastContext extends DataObject
	{
		public var parent:ChannelContext;
		
		public function BroadcastContext()
		{
			super();
		}
		
		override public function readObject(obj:Object, excep:Array = null):Boolean
		{
			excep = excep ? excep.concat(["parent"]) : ["parent"];
			
			if (!super.readObject(obj, excep))
				return false;
			
			return true;
		}
	}
}