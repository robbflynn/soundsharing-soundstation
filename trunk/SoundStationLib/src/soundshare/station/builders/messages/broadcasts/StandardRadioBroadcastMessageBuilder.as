package soundshare.station.builders.messages.broadcasts
{
	import socket.message.FlashSocketMessage;
	import socket.client.base.ClientSocketUnit;
	
	import soundshare.sdk.data.SoundShareContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class StandardRadioBroadcastMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		private var broadcastHeaderObject:Object;
		private var broadcastSetInfoHeaderObject:Object;
		
		private var broadcastMessage:FlashSocketMessage;
		private var broadcastInfoMessage:FlashSocketMessage;
		
		public function StandardRadioBroadcastMessageBuilder(target:SecureClientEventDispatcher)
		{
			this.target = target;
			
			this.broadcastHeaderObject = {
				route: {
					sender: target.route,
					receiver: target.receiverRoute
				},
				data: {
					token: target.token,
					action: {
						xtype: "BROADCAST_AUDIO_DATA"
					}
				}
			}
				
			this.broadcastSetInfoHeaderObject = {
				route: {
					sender: target.route,
					receiver: target.receiverRoute
				},
				data: {
					token: target.token,
					action: {
						xtype: "SET_AUDIO_INFO_DATA"
					}
				}
			}
				
			this.broadcastMessage = new FlashSocketMessage();
			this.broadcastInfoMessage = new FlashSocketMessage();
		}
		
		public function buildBroadcastMessage():FlashSocketMessage
		{
			broadcastHeaderObject.route.sender = target.route;
			broadcastHeaderObject.route.receiver = target.receiverRoute;
			
			broadcastHeaderObject.data.token = target.token;
			
			broadcastMessage.clear();
			broadcastMessage.setJSONHeader(broadcastHeaderObject);
			
			return broadcastMessage;
		}
		
		public function buildSetAudioInfoDataMessage(audioInfoData:Object):FlashSocketMessage
		{
			broadcastSetInfoHeaderObject.route.sender = target.route;
			broadcastSetInfoHeaderObject.route.receiver = target.receiverRoute;
			
			broadcastSetInfoHeaderObject.data.token = target.token;
			
			broadcastInfoMessage.clear();
			broadcastInfoMessage.setJSONHeader(broadcastSetInfoHeaderObject);
			broadcastInfoMessage.setJSONBody({
				audioInfoData: audioInfoData
			});
			
			return broadcastInfoMessage;
		}
	}
}