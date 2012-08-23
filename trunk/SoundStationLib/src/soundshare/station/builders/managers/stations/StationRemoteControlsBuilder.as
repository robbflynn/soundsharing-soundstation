package soundshare.station.builders.managers.stations
{
	import soundshare.station.data.StationContext;
	import soundshare.station.managers.stations.StationRemoteControl;

	public class StationRemoteControlsBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<StationRemoteControl> = new Vector.<StationRemoteControl>();
		
		public var cacheEnabled:Boolean = true;
		
		public function StationRemoteControlsBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build():StationRemoteControl
		{
			var manager:StationRemoteControl;
			
			if (cacheEnabled)
				manager = cache.shift();
			
			if (!manager)
				manager = new StationRemoteControl();
			
			manager.receiverNamespace = "socket.managers.StationRemoteControl";
			manager.token = context.token;
			
			context.connection.addUnit(manager);
			
			return manager;
		}
		
		public function destroy(manager:StationRemoteControl):void
		{
			context.connection.removeUnit(manager.id);
			
			if (cacheEnabled)
				cache.push(manager);
		}
	}
}