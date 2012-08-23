package soundshare.station.builders.messages.account
{
	import flashsocket.message.FlashSocketMessage;
	import flashsocket.client.base.ClientSocketUnit;
	
	import soundshare.sdk.data.SoundShareContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;

	public class AccountManagerMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		public function AccountManagerMessageBuilder(target:SecureClientEventDispatcher)
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
		
		public function buildRegisterConnectionMessage(token:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("REGISTER_CONNECTION");
			message.setJSONBody({
				token: token
			});
			
			return message;
		}
		
		public function buildUnregisterConnectionMessage(token:String, sessionId:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("UNREGISTER_CONNECTION");
			message.setJSONBody({
				token: token,
				sessionId: sessionId
			});
			
			return message;
		}
		
		public function buildLogin(username:String, password:String, remoteBroadcastsManagerRoute:Array):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("LOGIN");
			message.setJSONBody({
					username: username, 
					password: password,
					remoteBroadcastsManagerRoute: remoteBroadcastsManagerRoute
			});
			
			return message;
		}
		
		public function buildLogout():FlashSocketMessage
		{
			return build("LOGOUT");
		}
		
		public function buildRegister(username:String, password:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("REGISTER");
			message.setJSONBody({
				username: username, 
				password: password
			});
			
			return message;
		}
		
		public function buildList():FlashSocketMessage
		{
			return build("LIST");
		}
		
		public function buildStartWatchAccouns(accounts:Array, watchLogin:Boolean = true, watchLogout:Boolean = true):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("START_WATCH_ACCOUNTS");
			message.setJSONBody({
				accounts: accounts,
				login: watchLogin,
				logout: watchLogout
			});
			
			return message;
		}
		
		public function buildStopWatchAccouns(accounts:Array, watchLogin:Boolean = true, watchLogout:Boolean = true):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("STOP_WATCH_ACCOUNTS");
			message.setJSONBody({
				accounts: accounts,
				login: watchLogin,
				logout: watchLogout
			});
			
			return message;
		}
	}
}