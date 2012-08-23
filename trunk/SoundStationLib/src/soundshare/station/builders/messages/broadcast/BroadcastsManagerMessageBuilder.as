package soundshare.station.builders.messages.broadcast
{
	import socket.message.FlashSocketMessage;
	import socket.client.base.ClientSocketUnit;
	
	import soundshare.sdk.data.SoundShareContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;

	public class BroadcastsManagerMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		public function BroadcastsManagerMessageBuilder(target:SecureClientEventDispatcher)
		{
			this.target = target;
		}
		
		protected function build(xtype:String, senderRoute:Object = null, receiverRoute:Object = null):FlashSocketMessage
		{
			if (!xtype)
				throw new Error("Invalid xtype!");
			
			var message:FlashSocketMessage = new FlashSocketMessage();
			message.setJSONHeader({
				route: {
					sender: senderRoute ? senderRoute : target.route,
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
		
		public function buildCreateStandardRadioBroadcastMessage(channelId:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("CREATE_STANDARD_RADIO_BROADCAST");
			
			if (message && channelId)
				message.setJSONBody({
					channelId: channelId
				});
			
			return message;
		}
		
		public function buildDestroyStandardRadioBroadcastMessage(channelId:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("DESTROY_STANDARD_RADIO_BROADCAST");
			
			if (message && channelId)
				message.setJSONBody({
					channelId: channelId
				});
			
			return message;
		}
		
		public function buildPrepareForRemotePlaylistBroadcastMessage(id:String, playlistId:String, accountManagerRoute:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("PREPARE_FOR_REMOTE_PLAYLIST_BROADCAST");
			
			if (message && id && playlistId)
				message.setJSONBody({
					id: id,
					playlistId: playlistId,
					accountManagerRoute: accountManagerRoute
				});
			
			return message;
		}
		
		public function buildUnprepareForRemotePlaylistBroadcastMessage(id:String, accountManagerRoute:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("UNPREPARE_FOR_REMOTE_PLAYLIST_BROADCAST");
			
			if (message && id)
				message.setJSONBody({
					id: id,
					accountManagerRoute: accountManagerRoute
				});
			
			return message;
		}
		
		public function buildCreateRemotePlaylistBroadcastMessage(playlistId:String, playlistName:String, listenerId:String, listenerName:String, targetId:String, stationId:String, listenerRoute:Array):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("CREATE_REMOTE_PLAYLIST_BROADCAST");
			message.setJSONBody({
				playlistId: playlistId,
				playlistName: playlistName,
				listenerId: listenerId,
				listenerName: listenerName,
				targetId: targetId,
				stationId: stationId,
				listenerRoute: listenerRoute
			});
			
			return message;
		}
	}
}