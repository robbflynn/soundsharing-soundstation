package soundshare.station.builders.messages.stations
{
	import socket.message.FlashSocketMessage;
	
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;

	public class StationRemoteControlMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		public function StationRemoteControlMessageBuilder(target:SecureClientEventDispatcher)
		{
			this.target = target;
		}
		
		protected function build(xtype:String, data:Object):FlashSocketMessage
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
						xtype: xtype,
						data: data
					}
				}
			});
			
			return message;
		}
		
		public function buildExecuteAction(name:String, data:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("EXECUTE_ACTION", {
				name: name,
				data: data
			});
			
			return message;
		}
	}
}