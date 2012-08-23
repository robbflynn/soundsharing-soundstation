package soundshare.station.builders.messages.broadcasts
{
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class RemoteBroadcastsManagerMessageBuilder
	{
		protected var target:SecureClientEventDispatcher;
		
		public function RemoteBroadcastsManagerMessageBuilder(target:SecureClientEventDispatcher)
		{
			this.target = target;
		}
		
		protected function build(xtype:String, receiverRoute:Array = null):FlashSocketMessage
		{
			if (!xtype)
				return null;
			
			var message:FlashSocketMessage = new FlashSocketMessage();
			message.setJSONHeader({
				route: {
					sender: target.route,
					receiver: receiverRoute ? receiverRoute : target.receiverRoute
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
		
		public function buildCreateRemotePlaylistBroadcastMessage(params:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("CREATE_REMOTE_PLAYLIST_BROADCAST");
			
			if (params)
				message.setJSONBody(params);
			
			return message;
		}
		
		public function buildDestroyRemotePlaylistBroadcastMessage(creatorRoute:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("DESTROY_REMOTE_PLAYLIST_BROADCAST");
			
			if (creatorRoute)
				message.setJSONBody({
					creatorRoute: creatorRoute
				});
			
			return message;
		}
	}
}