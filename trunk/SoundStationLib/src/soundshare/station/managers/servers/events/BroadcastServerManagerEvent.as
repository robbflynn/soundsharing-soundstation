package soundshare.station.managers.servers.events
{
	import socket.client.managers.events.events.ClientEventDispatcherEvent;
	
	public class BroadcastServerManagerEvent extends ClientEventDispatcherEvent
	{
		public static const GET_MANAGERS_COMPLETE:String = "GET_MANAGERS_COMPLETE";
		
		public function BroadcastServerManagerEvent(type:String, data:Object = null, body:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, body, bubbles, cancelable);
		}
	}
}