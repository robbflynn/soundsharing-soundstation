package soundshare.station.builders.messages.servers
{
	import flashsocket.message.FlashSocketMessage;
	import flashsocket.client.base.ClientSocketUnit;
	
	import soundshare.sdk.data.SoundShareContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;

	public class BroadcastServerManagerMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		public function BroadcastServerManagerMessageBuilder(target:SecureClientEventDispatcher)
		{
			this.target = target;
		}
		
		protected function build(xtype:String):FlashSocketMessage
		{
			if (!xtype)
				throw new Error("Invalid xtype!");
			
			var message:FlashSocketMessage = new FlashSocketMessage();
			message.setJSONHeader({
				route: {
					sender: target.route,
					receiver: target.receiverRoute
				},
				data: {
					token: target.token,
					action: {
						xtype: xtype
					}
				}
			});
			
			return message;
		}
		
		public function buildGetManagersMessage():FlashSocketMessage
		{
			return build("GET_MANAGERS");
		}
	}
}