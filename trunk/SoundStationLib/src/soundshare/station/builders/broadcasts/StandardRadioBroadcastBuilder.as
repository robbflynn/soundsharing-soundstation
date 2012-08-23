package soundshare.station.builders.broadcasts
{
	import soundshare.station.broadcasts.srb.StandardRadioBroadcast;
	import soundshare.station.data.StationContext;
	import soundshare.station.data.channels.ChannelContext;
	
	import utils.collection.CollectionUtil;
	
	public class StandardRadioBroadcastBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<StandardRadioBroadcast> = new Vector.<StandardRadioBroadcast>();
		
		public var cacheEnabled:Boolean = true;
		
		public function StandardRadioBroadcastBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build(channelId:String, broadcasterRoute:Array):StandardRadioBroadcast
		{
			var broadcast:StandardRadioBroadcast;
			
			if (cacheEnabled)
				broadcast = cache.shift();
			
			if (!broadcast)
				broadcast = new StandardRadioBroadcast();
			
			broadcast.id = channelId;
			broadcast.context = context;
			broadcast.channelContext = CollectionUtil.getItemFromCollection("_id", channelId, context.channels) as ChannelContext;
			broadcast.token = context.token;
			broadcast.receiverRoute = broadcasterRoute;
			
			context.connection.addUnit(broadcast);
			
			return broadcast;
		}
		
		public function destroy(broadcast:StandardRadioBroadcast):void
		{
			context.connection.removeUnit(broadcast.id);
			
			if (cacheEnabled)
				cache.push(broadcast);
		}
	}
}