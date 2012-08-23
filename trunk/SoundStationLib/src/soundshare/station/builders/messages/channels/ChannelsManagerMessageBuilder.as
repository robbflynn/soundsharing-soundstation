package soundshare.station.builders.messages.channels
{
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;

	public class ChannelsManagerMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		public function ChannelsManagerMessageBuilder(target:SecureClientEventDispatcher)
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
		
		public function buildAdd(obj:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("ADD");
			message.setJSONBody(obj);
			
			return message;
		}
		
		public function buildUpdate(id:String, updateFields:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("UPDATE");
			message.setJSONBody({
				_id: id, 
				updateFields: updateFields
			});
			
			return message;
		}
		
		public function buildRemove(id:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("REMOVE");
			message.setJSONBody({
				_id: id
			});
			
			return message;
		}
		
		public function buildList(expression:Object = null):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("LIST");
			
			if (expression)
				message.setJSONBody(expression);
			
			return message;
		}
	}
}