package soundshare.station.builders.broadcasts
{
	import soundshare.station.data.StationContext;
	import soundshare.station.listeners.remote.srb.StandardRadioListener;
	
	public class StandardRadioListenerBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<StandardRadioListener> = new Vector.<StandardRadioListener>();
		
		public var cacheEnabled:Boolean = true;
		
		public function StandardRadioListenerBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build(/*channelId:String, */broadcasterRoute:Array):StandardRadioListener
		{
			var broadcast:StandardRadioListener;
			
			if (cacheEnabled)
				broadcast = cache.shift();
			
			if (!broadcast)
				broadcast = new StandardRadioListener();
			
			//broadcast.context = context;
			//broadcast.channelContext = CollectionUtil.getItemFromCollection("_id", channelId, context.channels) as ChannelContext;
			broadcast.token = context.token;
			broadcast.receiverRoute = broadcasterRoute;
			
			trace("StandardRadioListenerBuilder[build]:", context.token, broadcasterRoute);
			
			context.connection.addUnit(broadcast);
			
			return broadcast;
		}
		
		public function destroy(broadcast:StandardRadioListener):void
		{
			context.connection.removeUnit(broadcast.id);
			
			if (cacheEnabled)
				cache.push(broadcast);
		}
	}
}