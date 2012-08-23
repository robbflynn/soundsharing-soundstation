package soundshare.station.managers.broadcasts
{
	import socket.message.FlashSocketMessage;
	
	import soundshare.station.broadcasts.base.BaseBroadcast;
	import soundshare.station.broadcasts.rpb.RemotePlaylistBroadcast;
	import soundshare.station.broadcasts.rpb.events.RemotePlaylistBroadcastEvent;
	import soundshare.station.broadcasts.srb.StandardRadioBroadcast;
	import soundshare.station.builders.messages.broadcast.BroadcastsManagerMessageBuilder;
	import soundshare.station.data.StationContext;
	import soundshare.station.listeners.remote.rpb.RemotePlaylistListener;
	import soundshare.station.managers.broadcasts.events.BroadcastsManagerEvent;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	
	import utils.collection.CollectionUtil;
	
	public class BroadcastsManager extends SecureClientEventDispatcher
	{
		private var messageBuilder:BroadcastsManagerMessageBuilder;
		private var broadcastsByChannelId:Array = new Array();
		
		public var context:StationContext;
		
		public function BroadcastsManager(context:StationContext)
		{
			super();
			
			this.context = context;
			this.messageBuilder = new BroadcastsManagerMessageBuilder(this);
		}
		
		override protected function $dispatchSocketEvent(message:FlashSocketMessage):void
		{
			var event:Object = getActionData(message);
			
			if (event)
			{
				if (event.type != BroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE)
					dispatchEvent(new BroadcastsManagerEvent(event.type, event.data));
				else
				{
					var playlist:Array;
					
					if (message.bodyLength > 0)
					{
						//message.uncompressBody("deflate"); // TODO
						playlist = message.readBodyObject() as Array;
					}
					else
						playlist = new Array();
					
					var data:Object = event.data;
					data['playlist'] = playlist;
					
					dispatchEvent(new BroadcastsManagerEvent(event.type, data));
				}
			}
		}
		
		public function getBroadcastByChannelId(channelId:String):BaseBroadcast
		{
			return broadcastsByChannelId[channelId];
		}
		
		// *********************************************************************************************************
		// 										CREATE REMOTE PLAYLIST BROADCAST
		// *********************************************************************************************************
		
		public function prepareForRemotePlaylistBroadcast(id:String, playlistId:String, accountManagerRoute:Object):void
		{
			var message:FlashSocketMessage = messageBuilder.buildPrepareForRemotePlaylistBroadcastMessage(id, playlistId, accountManagerRoute);
			
			if (message)
				send(message);
		}
		
		public function unprepareForRemotePlaylistBroadcast(id:String, accountManagerRoute:Object):void
		{
			var message:FlashSocketMessage = messageBuilder.buildUnprepareForRemotePlaylistBroadcastMessage(id, accountManagerRoute);
			
			if (message)
				send(message);
		}
		
		// *********************************************************************************************************
		// 										CREATE STANDARD RADIO BROADCAST
		// *********************************************************************************************************
		
		public function createStandardRadioBroadcast(channelId:String):void
		{
			trace("BroadcastsManager[createStandardRadioBroadcast]", channelId);
			
			addSocketEventListener(BroadcastsManagerEvent.CREATE_STANDARD_RADIO_BROADCAST_COMPLETE, onCreateStandardRadioBroadcastComplete);
			addSocketEventListener(BroadcastsManagerEvent.CREATE_STANDARD_RADIO_BROADCAST_ERROR, onCreateStandardRadioBroadcastError);
			
			var message:FlashSocketMessage = messageBuilder.buildCreateStandardRadioBroadcastMessage(channelId);
			send(message);
		}
		
		private function onCreateStandardRadioBroadcastComplete(e:BroadcastsManagerEvent):void
		{
			trace("BroadcastsManager[onCreateStandardRadioBroadcastComplete]", e.data.channelId, e.data.broadcasterRoute);
			
			removeSocketEventListener(BroadcastsManagerEvent.CREATE_STANDARD_RADIO_BROADCAST_COMPLETE, onCreateStandardRadioBroadcastComplete);
			removeSocketEventListener(BroadcastsManagerEvent.CREATE_STANDARD_RADIO_BROADCAST_ERROR, onCreateStandardRadioBroadcastError);
			
			var channelId:String = e.data.channelId;
			var broadcasterRoute:Array = e.data.broadcasterRoute;
				
			var broadcast:StandardRadioBroadcast = context.standardRadioBroadcastBuilder.build(channelId, broadcasterRoute);
			context.registerBroadcast(broadcast);
			
			var event:BroadcastsManagerEvent = new BroadcastsManagerEvent(BroadcastsManagerEvent.CREATE_SRB_COMPLETE)
			event.broadcast = broadcast;
			
			dispatchEvent(event);
		}
		
		private function onCreateStandardRadioBroadcastError(e:BroadcastsManagerEvent):void
		{
			trace("BroadcastsManager[onCreateStandardRadioBroadcastError]");
			
			removeSocketEventListener(BroadcastsManagerEvent.CREATE_STANDARD_RADIO_BROADCAST_COMPLETE, onCreateStandardRadioBroadcastComplete);
			removeSocketEventListener(BroadcastsManagerEvent.CREATE_STANDARD_RADIO_BROADCAST_ERROR, onCreateStandardRadioBroadcastError);
			
			dispatchEvent(new BroadcastsManagerEvent(BroadcastsManagerEvent.CREATE_SRB_ERROR));
		}
		
		// *********************************************************************************************************
		// 										DESTROY STANDARD RADIO BROADCvAST
		// *********************************************************************************************************
		
		public function destroyStandardRadioBroadcast(channelId:String):void
		{
			trace("BroadcastsManager[destroyStandardRadioBroadcast]", channelId);
			
			addSocketEventListener(BroadcastsManagerEvent.DESTROY_STANDARD_RADIO_BROADCAST_COMPLETE, onDestroyStandardRadioBroadcastComplete);
			addSocketEventListener(BroadcastsManagerEvent.DESTROY_STANDARD_RADIO_BROADCAST_ERROR, onDestroyStandardRadioBroadcastError);
			
			var message:FlashSocketMessage = messageBuilder.buildDestroyStandardRadioBroadcastMessage(channelId);
			send(message);
		}
		
		private function onDestroyStandardRadioBroadcastComplete(e:BroadcastsManagerEvent):void
		{
			trace("BroadcastsManager[onDestroyStandardRadioBroadcastComplete]");
			
			removeSocketEventListener(BroadcastsManagerEvent.DESTROY_STANDARD_RADIO_BROADCAST_COMPLETE, onDestroyStandardRadioBroadcastComplete);
			removeSocketEventListener(BroadcastsManagerEvent.DESTROY_STANDARD_RADIO_BROADCAST_ERROR, onDestroyStandardRadioBroadcastError);
			
			var channelId:String = e.data.channelId;
			var broadcast:StandardRadioBroadcast = context.getBroadcastById(channelId) as StandardRadioBroadcast;
			
			context.unregisterBroadcast(broadcast);
			context.standardRadioBroadcastBuilder.destroy(broadcast);
			
			dispatchEvent(new BroadcastsManagerEvent(BroadcastsManagerEvent.DESTROY_SRB_COMPLETE));
		}
		
		private function onDestroyStandardRadioBroadcastError(e:BroadcastsManagerEvent):void
		{
			trace("BroadcastsManager[onDestroyStandardRadioBroadcastError]");
			
			removeSocketEventListener(BroadcastsManagerEvent.DESTROY_STANDARD_RADIO_BROADCAST_COMPLETE, onDestroyStandardRadioBroadcastComplete);
			removeSocketEventListener(BroadcastsManagerEvent.DESTROY_STANDARD_RADIO_BROADCAST_ERROR, onDestroyStandardRadioBroadcastError);
			
			dispatchEvent(new BroadcastsManagerEvent(BroadcastsManagerEvent.DESTROY_SRB_ERROR));
		}
		
		// *********************************************************************************************************
		// 										CREATE REMOTEP LAYLIST LISTENER
		// *********************************************************************************************************
		
		private var tmpRemotePlaylistListener:RemotePlaylistListener;
		
		public function createRemotePlaylistBroadcast(playlistId:String, playlistName:String, listenerId:String, listenerName:String, targetId:String, stationId:String):void
		{
			//tmpRemotePlaylistListener = context.remotePlaylistListenerBuilder.build(playlistId);
			
			addSocketEventListener(BroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_COMPLETE, onCreateRremotePlaylistBroadcastComplete);
			addSocketEventListener(BroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_ERROR, onCreateRremotePlaylistBroadcastError);
			addSocketEventListener(BroadcastsManagerEvent.CREATE_REMOTE_PLAYLIST_BROADCAST_LIMIT_ERROR, onCreateRremotePlaylistBroadcastLimitError);
			
			trace("BroadcastsManager[createRemotePlaylistBroadcast]");
			
			var message:FlashSocketMessage = messageBuilder.buildCreateRemotePlaylistBroadcastMessage(
				playlistId, 
				playlistName,
				listenerId,
				listenerName,
				targetId,
				stationId,
				tmpRemotePlaylistListener.route
			);
			
			send(message);
		}
		
		private function onCreateRremotePlaylistBroadcastComplete(e:BroadcastsManagerEvent):void
		{
			trace("-#onCreateRremotePlaylistBroadcastComplete#-");
			
			tmpRemotePlaylistListener.token = e.data.token;
			tmpRemotePlaylistListener.receiverRoute = e.data.broadcasterRoute;
			//tmpRemotePlaylistListener.playlist = e.data.playlist;
			
			var event:BroadcastsManagerEvent = new BroadcastsManagerEvent(BroadcastsManagerEvent.CREATE_RPB_COMPLETE);
			event.listener = tmpRemotePlaylistListener;
			
			tmpRemotePlaylistListener = null;
			
			dispatchEvent(event);
		}
		
		private function onCreateRremotePlaylistBroadcastError(e:BroadcastsManagerEvent):void
		{
			trace("-#onCreateRremotePlaylistBroadcastError#-");
			
			context.remotePlaylistListenerBuilder.destroy(tmpRemotePlaylistListener);
			tmpRemotePlaylistListener = null;
			
			dispatchEvent(new BroadcastsManagerEvent(BroadcastsManagerEvent.CREATE_RPB_ERROR));
		}
		
		private function onCreateRremotePlaylistBroadcastLimitError(e:BroadcastsManagerEvent):void
		{
			trace("-#onCreateRremotePlaylistBroadcastError#-");
			
			context.remotePlaylistListenerBuilder.destroy(tmpRemotePlaylistListener);
			tmpRemotePlaylistListener = null;
			
			dispatchEvent(new BroadcastsManagerEvent(BroadcastsManagerEvent.CREATE_RPB_LIMIT_ERROR));
		}
		
		// *********************************************************************************************************
		// 										CREATE REMOTEP LAYLIST BROADCAST
		// *********************************************************************************************************
		
		private var tmpInitiatorRoute:Array;
		
		public function executeCreateRemotePlaylistBroadcast(playlistId:String, listenerId:String, listenerName:String, listenerRoute:Array, initiatorRoute:Array):void
		{
			trace("-RemoteBroadcastsManager[executeCreateRemotePlaylistBroadcast]-", playlistId, listenerRoute);
			
			var playlistContext:PlaylistContext = CollectionUtil.getItemFromCollection("_id", playlistId, context.playlists) as PlaylistContext;
			var broadcast:RemotePlaylistBroadcast = context.remotePlaylistBroadcastBuilder.build();
			this.tmpInitiatorRoute = initiatorRoute;
			
			trace("RemotePlaylistBroadcastBuilder[build]:", broadcast.route, playlistId);
			
			broadcast.receiverRoute = listenerRoute;
			broadcast.addEventListener(RemotePlaylistBroadcastEvent.PREPARE_COMPLETE, onCreateRemotePlaylistBroadcastComplete);
			broadcast.addEventListener(RemotePlaylistBroadcastEvent.PREPARE_ERROR, onCreateRemotePlaylistBroadcastError);
			//broadcast.prepare(playlistContext, listenerId, listenerName);
			
			context.registerBroadcast(broadcast);
		}
		
		private function onCreateRemotePlaylistBroadcastComplete(e:RemotePlaylistBroadcastEvent):void
		{
			trace("-RemoteBroadcastsManager[onCreateRemotePlaylistBroadcastComplete]-");
			
			var broadcast:RemotePlaylistBroadcast = e.currentTarget as RemotePlaylistBroadcast;
			
			broadcast.removeEventListener(RemotePlaylistBroadcastEvent.PREPARE_COMPLETE, onCreateRemotePlaylistBroadcastComplete);
			broadcast.removeEventListener(RemotePlaylistBroadcastEvent.PREPARE_ERROR, onCreateRemotePlaylistBroadcastError);
			
			var event:BroadcastsManagerEvent = new BroadcastsManagerEvent(BroadcastsManagerEvent.BUILD_REMOTE_PLAYLIST_BROADCAST_COMPLETE);
			event.initiatorRoute = tmpInitiatorRoute;
			event.broadcast = broadcast;
			
			tmpInitiatorRoute = null;
			dispatchEvent(event);
		}
		
		private function onCreateRemotePlaylistBroadcastError(e:RemotePlaylistBroadcastEvent):void
		{
			trace("-RemoteBroadcastsManager[onCreateRemotePlaylistBroadcastError]-");
			
			var broadcast:RemotePlaylistBroadcast = e.currentTarget as RemotePlaylistBroadcast;
			
			broadcast.removeEventListener(RemotePlaylistBroadcastEvent.PREPARE_COMPLETE, onCreateRemotePlaylistBroadcastComplete);
			broadcast.removeEventListener(RemotePlaylistBroadcastEvent.PREPARE_ERROR, onCreateRemotePlaylistBroadcastError);
			
			context.remotePlaylistBroadcastBuilder.destroy(broadcast);
			
			var event:BroadcastsManagerEvent = new BroadcastsManagerEvent(BroadcastsManagerEvent.BUILD_REMOTE_PLAYLIST_BROADCAST_ERROR);
			event.initiatorRoute = tmpInitiatorRoute;
			
			tmpInitiatorRoute = null;
			dispatchEvent(event);
		}
	}
}