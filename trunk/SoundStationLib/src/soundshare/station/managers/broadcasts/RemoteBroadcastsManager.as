package soundshare.station.managers.broadcasts
{
	import flashsocket.message.FlashSocketMessage;
	
	import soundshare.station.broadcasts.rpb.RemotePlaylistBroadcast;
	import soundshare.station.broadcasts.rpb.events.RemotePlaylistBroadcastEvent;
	import soundshare.station.builders.messages.broadcasts.RemoteBroadcastsManagerMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.station.managers.broadcasts.events.BroadcastsManagerEvent;
	import soundshare.station.managers.broadcasts.events.RemoteBroadcastsManagerEvent;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	import utils.collection.CollectionUtil;
	
	public class RemoteBroadcastsManager extends SecureClientEventDispatcher
	{
		private var messageBuilder:RemoteBroadcastsManagerMessageBuilder;
		public var context:StationContext;
		
		public function RemoteBroadcastsManager(context:StationContext)
		{
			super();
			
			this.context = context;
			
			messageBuilder = new RemoteBroadcastsManagerMessageBuilder(this);
			
			addAction("CREATE_REMOTE_PLAYLIST_BROADCAST", executeCreateRemotePlaylistBroadcast);
		}
		
		override protected function $dispatchSocketEvent(message:FlashSocketMessage):void
		{
			var event:Object = getActionData(message);
			
			if (event)
				dispatchEvent(new RemoteBroadcastsManagerEvent(event.type, event.data));
		}
		
		public function createRemotePlaylistBroadcast(playlistId:String, listenerName:String, listenerRoute:Array, serverData:Object):void
		{
			var message:FlashSocketMessage = messageBuilder.buildCreateRemotePlaylistBroadcastMessage({
				playlistId: playlistId,
				listenerName: listenerName,
				listenerRoute: listenerRoute,
				serverData: serverData
			});
			send(message);
		}
		
		public function executeCreateRemotePlaylistBroadcast(message:FlashSocketMessage):void
		{
			trace("-RemoteBroadcastsManager[executeCreateRemotePlaylistBroadcast]-", context.totalListeners, context.applicationSettings.settings.maxListeners);
			
			var header:Object = message.getJSONHeader();
			var body:Object = message.getJSONBody();
			
			var sender:Array = header.route.sender;
			
			if (context.totalListeners >= context.applicationSettings.settings.maxListeners)
			{
				trace("2.-RemoteBroadcastsManager[executeCreateRemotePlaylistBroadcast]-");
					
				dispatchSocketEvent({
					event: {
						type: RemoteBroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR,
						data: {
							error: "Can't create remote playlist broadcast because of limit!",
							code: 0
						}
					},
					receiver: sender
				});
			}
			else
			{
				var playlistId:String   = body.playlistId;
				var listenerName:String = body.listenerName;
				var listenerRoute:Array = body.listenerRoute as Array;
				var serverData:Object = body.serverData;
				
				var remotePlaylistBroadcast:RemotePlaylistBroadcast = context.remotePlaylistBroadcastBuilder.build();
				var playlistContext:PlaylistContext = CollectionUtil.getItemFromCollection("_id", playlistId, context.playlists) as PlaylistContext;
				
				trace("RemotePlaylistBroadcastBuilder[build]:", remotePlaylistBroadcast.route, playlistId);
				
				remotePlaylistBroadcast.receiverRoute = listenerRoute;
				remotePlaylistBroadcast.initiatorRoute = sender;
				remotePlaylistBroadcast.addEventListener(RemotePlaylistBroadcastEvent.PREPARE_COMPLETE, onPrepareRemotePlaylistBroadcastComplete);
				remotePlaylistBroadcast.addEventListener(RemotePlaylistBroadcastEvent.PREPARE_ERROR, onPrepareRemotePlaylistBroadcastError);
				remotePlaylistBroadcast.prepare(playlistContext, listenerName, serverData);
			}
		}
		
		private function onPrepareRemotePlaylistBroadcastComplete(e:RemotePlaylistBroadcastEvent):void
		{
			trace("2.-RemoteBroadcastsManager[onPrepareRemotePlaylistBroadcastComplete]-");
			
			var remotePlaylistBroadcast:RemotePlaylistBroadcast = e.currentTarget as RemotePlaylistBroadcast;
			
			dispatchSocketEvent({
				event: {
					type: RemoteBroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE,
					data: {
						broadcastRoute: remotePlaylistBroadcast.route
					}
				},
				receiver: remotePlaylistBroadcast.initiatorRoute
			});
		}
		
		private function onPrepareRemotePlaylistBroadcastError(e:RemotePlaylistBroadcastEvent):void
		{
			trace("2.-RemoteBroadcastsManager[onPrepareRemotePlaylistBroadcastError]-");
			
			dispatchSocketEvent({
				event: {
					type: RemoteBroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR,
					data: {
						error: "Can't create remote playlist broadcast!",
						code: 0
					}
				},
				receiver: (e.currentTarget as RemotePlaylistBroadcast).initiatorRoute
			});
			
			context.remotePlaylistBroadcastBuilder.destroy(e.currentTarget as RemotePlaylistBroadcast);
		}
	}
}