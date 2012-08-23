package soundshare.station.builders.messages.playlists
{
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.sdk.data.SoundShareContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	public class PlaylistsManagerMessageBuilder
	{
		public var target:SecureClientEventDispatcher;
		
		public function PlaylistsManagerMessageBuilder(target:SecureClientEventDispatcher)
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
		
		protected function buildFileEventMessage(xtype:String, metadata:Object = null):FlashSocketMessage
		{
			if (!xtype)
				throw new Error("Invalid xtype!");
			
			var message:FlashSocketMessage = new FlashSocketMessage();
			var headerObject:Object = {
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
			}
			
			if (metadata)
				headerObject.data.action.metadata = metadata;
			
			message.clear();
			message.setJSONHeader(headerObject);
			
			return message;
		}
		
		public function buildAdd(obj:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("ADD");
			message.setJSONBody(obj);
			
			return message;
		}
		
		public function buildUpdate(id:String, fields:Object):FlashSocketMessage
		{
			var message:FlashSocketMessage = build("UPDATE");
			message.setJSONBody({
				_id: id, 
				fields: fields
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
			message.setJSONBody(expression);
			
			return message;
		}
		
		public function buildSaveFile(id:String, playlist:Array):FlashSocketMessage
		{
			var message:FlashSocketMessage = buildFileEventMessage("SAVE_PLAYLIST_FILE", {
				_id: id, 
				total: playlist.length
			});
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(playlist);
			ba.compress(CompressionAlgorithm.DEFLATE);
			
			message.writeBodyBytes(ba);
			
			return message;
		}
		
		public function buildLoadFile(id:String):FlashSocketMessage
		{
			var message:FlashSocketMessage = buildFileEventMessage("LOAD_PLAYLIST_FILE", {
				_id: id
			});
			
			return message;
		}
	}
}