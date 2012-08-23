package soundshare.station.managers.account
{
	import socket.message.FlashSocketMessage;
	
	import soundshare.station.builders.messages.account.AccountManagerMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.station.managers.account.events.AccountManagerEvent;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class AccountManager extends SecureClientEventDispatcher
	{
		private var context:StationContext;
		
		private var messageBuilder:AccountManagerMessageBuilder;
		
		public function AccountManager(context:StationContext)
		{
			super();
			
			this.context = context;
			
			addAction("PROCESS_ACTION", processRemoteAction);
			
			messageBuilder = new AccountManagerMessageBuilder(this);
		}
		
		private function processRemoteAction(message:FlashSocketMessage):void
		{
			var actionData:Object = getActionData(message);
			
			dispatchEvent(new AccountManagerEvent(actionData.name, actionData.data));
		}
		
		public function registerConnection(token:String):void
		{
			trace("-AccountManager[registerConnection]-", token);
			
			var message:FlashSocketMessage = messageBuilder.buildRegisterConnectionMessage(token);
			send(message);
		}
	}
}