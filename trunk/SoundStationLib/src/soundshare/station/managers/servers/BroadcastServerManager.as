package soundshare.station.managers.servers
{
	import socket.message.FlashSocketMessage;
	
	import soundshare.station.builders.messages.servers.BroadcastServerManagerMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	import soundshare.station.managers.servers.events.BroadcastServerManagerEvent;

	public class BroadcastServerManager extends SecureClientEventDispatcher
	{
		private var _context:StationContext;
		
		private var messageBuilder:BroadcastServerManagerMessageBuilder;
		
		public function BroadcastServerManager()
		{
			super();
			
			messageBuilder = new BroadcastServerManagerMessageBuilder(this);
		}
		
		override protected function $dispatchSocketEvent(message:FlashSocketMessage):void
		{
			var event:Object = getActionData(message);
			
			if (event)
				dispatchEvent(new BroadcastServerManagerEvent(event.type, event.data));
		}
		
		public function set context(value:StationContext ):void
		{
			_context = value;
		}
		
		public function get context():StationContext
		{
			return _context;
		}
		
		public function getManagers():void
		{
			var message:FlashSocketMessage = messageBuilder.buildGetManagersMessage();
			send(message);
		}
	}
}