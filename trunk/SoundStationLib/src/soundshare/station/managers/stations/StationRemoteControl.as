package soundshare.station.managers.stations
{
	import socket.client.builders.message.events.ClientEventMessageBuilder;
	import socket.message.FlashSocketMessage;
	
	import soundshare.station.builders.messages.stations.StationRemoteControlMessageBuilder;
	import soundshare.station.managers.stations.events.StationRemoteControlEvent;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class StationRemoteControl extends SecureClientEventDispatcher
	{
		private var messageBuilder:StationRemoteControlMessageBuilder;
		
		public function StationRemoteControl()
		{
			super();
		
			messageBuilder = new StationRemoteControlMessageBuilder(this);
			
			addAction("EXECUTE_ACTION", processAction);
		}
		
		protected function processAction(message:FlashSocketMessage):void
		{
			var action:Object = getActionData(message);
			
			dispatchEvent(new StationRemoteControlEvent(action.name, action.data));
		}
		
		public function executeAction(name:String, data:Object):void
		{
			var message:FlashSocketMessage = messageBuilder.buildExecuteAction(name, data);
			
			if (message)
				send(message);
		}
	}
}