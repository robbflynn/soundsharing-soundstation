package soundshare.station.builders.managers.broadcasts
{
	import soundshare.station.data.StationContext;
	import soundshare.station.managers.broadcasts.BroadcastsManager;

	public class BroadcastsManagersBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<BroadcastsManager> = new Vector.<BroadcastsManager>();
		
		public var cacheEnabled:Boolean = true;
		
		public function BroadcastsManagersBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build():BroadcastsManager
		{
			var manager:BroadcastsManager;
			
			if (cacheEnabled)
				manager = cache.shift();
			
			if (!manager)
				manager = new BroadcastsManager(context);
			
			manager.context = context;
			manager.receiverNamespace = "socket.managers.BroadcastsManager";
			manager.token = context.token;
			
			context.connection.addUnit(manager);
			
			return manager;
		}
		
		public function destroy(manager:BroadcastsManager):void
		{
			context.connection.removeUnit(manager.id);
			
			if (cacheEnabled)
				cache.push(manager);
		}
	}
}