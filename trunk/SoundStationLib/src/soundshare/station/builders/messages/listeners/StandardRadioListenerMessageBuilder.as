package soundshare.station.builders.messages.listeners
{
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;

	public class StandardRadioListenerMessageBuilder
	{
		protected var target:SecureClientEventDispatcher;
		
		public function StandardRadioListenerMessageBuilder(target:SecureClientEventDispatcher)
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
		
		public function buildGetAudioInfoData():FlashSocketMessage
		{
			return build("GET_AUDIO_INFO_DATA");
		}
	}
}