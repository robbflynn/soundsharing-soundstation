package soundshare.station.builders.managers.broadcasts
{
	import soundshare.station.data.StationContext;
	import soundshare.station.managers.broadcasts.RemoteBroadcastsManager;

	public class RemoteBroadcastsManagersBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<RemoteBroadcastsManager> = new Vector.<RemoteBroadcastsManager>();
		
		public var cacheEnabled:Boolean = true;
		
		public function RemoteBroadcastsManagersBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build(routingMap:Object):RemoteBroadcastsManager
		{
			var manager:RemoteBroadcastsManager;
			
			if (cacheEnabled)
				manager = cache.shift();
			
			if (!manager)
				manager = new RemoteBroadcastsManager(context);
			
			manager.context = context;
			manager.token = context.token;
			manager.receiverNamespace = "socket.managers.RemoteBroadcastsManager";
			
			manager.$identify(routingMap);
			
			context.connection.addUnit(manager);
			
			return manager;
		}
		
		public function destroy(manager:RemoteBroadcastsManager):void
		{
			context.connection.removeUnit(manager.id);
			
			if (cacheEnabled)
				cache.push(manager);
		}
	}
}