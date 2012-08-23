package soundshare.station.data
{
	import soundshare.sdk.builders.managers.connections.server.ConnectionsManagerBuilder;
	import soundshare.sdk.controllers.connection.client.ClientConnection;
	import soundshare.sdk.data.SoundShareContext;

	public class EmitterBroadcastContext
	{
		private var _token:String;
		
		public var BROADCAST_SERVER_ROUTE:Array;
		public var CONNECTIONS_MANAGER_ROUTE:Array;
		
		public var connection:ClientConnection;
		public var connectionsManagerBuilder:ConnectionsManagerBuilder;
		
		public function EmitterBroadcastContext()
		{
			super();
			
			connectionsManagerBuilder = new ConnectionsManagerBuilder();
		}
		
		public function set token(value:String):void
		{
			_token = value;
		}
		
		public function get token():String
		{
			return _token;
		}
	}
}