package soundshare.station.controllers.station
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flashsocket.client.events.FlashSocketClientEvent;
	
	import soundshare.sdk.controllers.connection.client.ClientConnection;
	import soundshare.sdk.controllers.connection.client.events.ClientConnectionEvent;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.data.servers.ServerData;
	import soundshare.sdk.db.mongo.accounts.AccountsDataManager;
	import soundshare.sdk.db.mongo.base.MongoDBRest;
	import soundshare.sdk.db.mongo.base.events.MongoDBRestEvent;
	import soundshare.sdk.db.mongo.members.MembersDataManager;
	import soundshare.sdk.db.mongo.notifications.NotificationsDataManager;
	import soundshare.sdk.managers.servers.ServersManager;
	import soundshare.sdk.managers.servers.events.ServersManagerEvent;
	import soundshare.sdk.managers.stations.StationsManager;
	import soundshare.sdk.managers.stations.events.StationsManagerEvent;
	import soundshare.sdk.plugins.loaders.list.PluginsListLoader;
	import soundshare.sdk.plugins.loaders.list.events.PluginsListLoaderEvent;
	import soundshare.station.controllers.station.events.StationControllerEvent;
	import soundshare.station.data.StationContext;
	import soundshare.station.data.channels.ChannelContext;
	import soundshare.station.data.groups.GroupData;
	import soundshare.station.data.notifications.NotificationData;
	import soundshare.station.data.stations.StationData;
	import soundshare.station.managers.account.events.AccountManagerEvent;
	import soundshare.station.managers.stations.events.StationRemoteControlEvent;
	
	import utils.collection.CollectionUtil;
	
	public class StationController extends EventDispatcher
	{
		private var context:StationContext;
		private var connection:ClientConnection;
		
		private var stationsWatcherManager:StationsManager;
		private var serversWatcherManager:ServersManager;
		
		private var tmpAccountDataManager:AccountsDataManager;
		
		private var tmpUpStationsManager:StationsManager;
		private var tmpDownStationsManager:StationsManager;
		
		private var tmpPluginsListLoader:PluginsListLoader;
		
		public function StationController(context:StationContext)
		{
			this.context = context;
			
			connection = context.connection;
			connection.addEventListener(FlashSocketClientEvent.CONNECTED, onSocketConnected);
			connection.addEventListener(FlashSocketClientEvent.DISCONNECTED, onSocketDisconnected);
			connection.addEventListener(ClientConnectionEvent.INITIALIZATION_COMPLETE, onSocketInitializationComplete);
			
			context.accountManager.addEventListener(AccountManagerEvent.STATION_INSERTED, onStationInserted);
			context.accountManager.addEventListener(AccountManagerEvent.STATION_UPDATED, onStationUpdated);
			context.accountManager.addEventListener(AccountManagerEvent.STATION_DELETED, onStationDeleted);
			
			context.accountManager.addEventListener(AccountManagerEvent.CHANNEL_INSERTED, onChannelInserted);
			context.accountManager.addEventListener(AccountManagerEvent.CHANNEL_UPDATED, onChannelUpdated);
			context.accountManager.addEventListener(AccountManagerEvent.PLAYLIST_DELETED, onChannelDeleted);
			
			context.accountManager.addEventListener(AccountManagerEvent.PLAYLIST_INSERTED, onPlaylistInserted);
			context.accountManager.addEventListener(AccountManagerEvent.PLAYLIST_UPDATED, onPlaylistUpdated);
			context.accountManager.addEventListener(AccountManagerEvent.PLAYLIST_DELETED, onPlaylistDeleted);
			
			context.accountManager.addEventListener(AccountManagerEvent.GROUP_INSERTED, onGroupInserted);
			context.accountManager.addEventListener(AccountManagerEvent.GROUP_UPDATED, onGroupUpdated);
			context.accountManager.addEventListener(AccountManagerEvent.GROUP_DELETED, onGroupDeleted);
			
			context.accountManager.addEventListener(AccountManagerEvent.SERVER_INSERTED, onServerInserted);
			context.accountManager.addEventListener(AccountManagerEvent.SERVER_UPDATED, onServerUpdated);
			context.accountManager.addEventListener(AccountManagerEvent.SERVER_DELETED, onServerDeleted);
			
			//context.stationRemoteControl.addEventListener(StationRemoteControlEvent.SELECT_CHANNEL, onSelectChannel);
		}
		
		public function login(username:String, password:String):void
		{
			trace("StationController[login]:", username, password);
			
			MongoDBRest.GLOBAL_URL = context.applicationSettings.settings.MANAGER_URL;
			
			NotificationsDataManager.GLOBAL_URL = context.applicationSettings.settings.MANAGER_URL;
			AccountsDataManager.GLOBAL_URL = context.applicationSettings.settings.MANAGER_URL;
			MembersDataManager.GLOBAL_URL = context.applicationSettings.settings.MANAGER_URL;
			
			tmpAccountDataManager = context.accountsDataManagersBuilder.build();
			tmpAccountDataManager.addEventListener(MongoDBRestEvent.COMPLETE, onLoginComplete);
			tmpAccountDataManager.addEventListener(MongoDBRestEvent.ERROR, onLoginError);
			tmpAccountDataManager.login(username, password);
		}
		
		private function onLoginComplete(e:MongoDBRestEvent):void
		{
			tmpAccountDataManager.removeEventListener(MongoDBRestEvent.COMPLETE, onLoginComplete);
			tmpAccountDataManager.removeEventListener(MongoDBRestEvent.ERROR, onLoginError);
			
			context.accountsDataManagersBuilder.destroy(tmpAccountDataManager);
			tmpAccountDataManager = null;
			
			context.accountData._id = e.data.id;
			context.accountData.username = e.data.username;
			context.token = e.data.token;
			
			var i:int;
			var stations:Array = e.data.accountData.stations as Array;
			var servers:Array = e.data.accountData.servers as Array;
			var channels:Array = e.data.accountData.channels as Array;
			var playlists:Array = e.data.accountData.playlists as Array;
			var groups:Array = e.data.accountData.groups as Array;
			var notifications:Array = e.data.accountData.notifications as Array;
			
			var channelContext:ChannelContext;
			var playlistContext:PlaylistContext;
			var groupData:GroupData;
			var notificationData:NotificationData;
			var stationData:StationData;
			var serverData:ServerData;
			
			trace("StationController[onLoginComplete]:", stations.length, channels.length, playlists.length, groups.length, notifications.length);
			
			for (i = 0;i < channels.length;i ++)
			{
				channelContext = new ChannelContext();
				channelContext.readObject(channels[i]);
				
				context.channels.addItem(channelContext);
			}
			
			for (i = 0;i < playlists.length;i ++)
			{
				playlistContext = new PlaylistContext();
				playlistContext.readObject(playlists[i]);
				
				context.playlists.addItem(playlistContext);
			}
			
			for (i = 0;i < groups.length;i ++)
			{
				groupData = new GroupData();
				groupData.readObject(groups[i]);
				
				context.groups.addItem(groupData);
			}
			
			for (i = 0;i < notifications.length;i ++)
			{
				notificationData = new NotificationData();
				notificationData.readObject(notifications[i]);
				
				context.notifications.addItem(notificationData);
			}
			
			for (i = 0;i < stations.length;i ++)
			{
				stationData = new StationData();
				stationData.readObject(stations[i]);
				
				context.stations.addItem(stationData);
			}
			
			for (i = 0;i < servers.length;i ++)
			{
				serverData = new ServerData();
				serverData.readObject(servers[i]);
				
				context.servers.addItem(serverData);
			}
			
			/*if (tmpStationData && applicationSettings.settings.stationId == tmpStationData._id)
				return tmpStationData;
			
			if (applicationSettings.settings.stationId == applicationSettings.settings.guestStationId)
				tmpStationData = guestStationData;
			else*/
			
			
			
			
			
			/*if (!context.stationData)
			{
				context.applicationSettings.settings.stationId = null;
				context.applicationSettings.save();
			}*/
			
			
			trace("_id:", e.data.id);
			trace("token:", e.data.token);
			trace("socket.address:", e.data.socket.address);
			trace("socket.port:", e.data.socket.port);
			
			context.applicationSettings.settings.MANAGER_SOCKET_ADDRESS = e.data.socket.address;
			context.applicationSettings.settings.MANAGER_SOCKET_PORT = e.data.socket.port;
			
			
			connection.address = e.data.socket.address;
			connection.port = e.data.socket.port;
			
			tmpPluginsListLoader = new PluginsListLoader();
			tmpPluginsListLoader.addEventListener(PluginsListLoaderEvent.PLUGIN_COMPLETE, onPluginComplete);
			tmpPluginsListLoader.addEventListener(PluginsListLoaderEvent.PLUGINS_COMPLETE, onPluginsComplete);
			tmpPluginsListLoader.addEventListener(PluginsListLoaderEvent.PLUGINS_ERROR, onPluginsError);
			
			for (i = 0;i < context.pluginsCollection.length;i ++)
				tmpPluginsListLoader.addPlugin(context.pluginsCollection.getPluginAt(i).filename);
			
			tmpPluginsListLoader.load();
		}
		
		protected function onPluginComplete(e:PluginsListLoaderEvent):void
		{
			trace("-onPluginComplete-");
			
			context.pluginsCollection.getPluginByFilename(e.filename).plugin = e.plugin;
		}
		
		protected function onPluginsComplete(e:PluginsListLoaderEvent):void
		{
			trace("-onPluginsComplete-");
			
			e.currentTarget.removeEventListener(PluginsListLoaderEvent.PLUGIN_COMPLETE, onPluginComplete);
			e.currentTarget.removeEventListener(PluginsListLoaderEvent.PLUGINS_COMPLETE, onPluginsComplete);
			e.currentTarget.removeEventListener(PluginsListLoaderEvent.PLUGINS_ERROR, onPluginsError);
			
			connection.addEventListener(FlashSocketClientEvent.CONNECTED, onSocketInitializationConnected);
			connection.addEventListener(FlashSocketClientEvent.ERROR, onSocketInitializationError);
			connection.connect();
		}
		
		protected function onPluginsError(e:PluginsListLoaderEvent):void
		{
			trace("-onPluginsError-");
			
			e.currentTarget.removeEventListener(PluginsListLoaderEvent.PLUGIN_COMPLETE, onPluginComplete);
			e.currentTarget.removeEventListener(PluginsListLoaderEvent.PLUGINS_COMPLETE, onPluginsComplete);
			e.currentTarget.removeEventListener(PluginsListLoaderEvent.PLUGINS_ERROR, onPluginsError);
			
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 107));
		}
		
		private function onLoginError(e:MongoDBRestEvent):void
		{
			reset();
			
			if (!e.data || e.data.code == 0)
				dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 100));
			else
				dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 101));
		}
		
		private function onSocketInitializationConnected(e:FlashSocketClientEvent):void
		{
			connection.removeEventListener(FlashSocketClientEvent.CONNECTED, onSocketInitializationConnected);
			connection.removeEventListener(FlashSocketClientEvent.ERROR, onSocketInitializationError);
			
			connection.addEventListener(FlashSocketClientEvent.DISCONNECTED, onSocketInitializationDisconnected);
		}
		
		private function onSocketInitializationDisconnected(e:FlashSocketClientEvent):void
		{
			connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onSocketInitializationDisconnected);
			
			reset();
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 102));
		}
		
		protected function onSocketInitializationError(e:FlashSocketClientEvent):void 
		{
			reset();
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 103));
		}
		
		protected function onSocketInitializationComplete(e:ClientConnectionEvent):void 
		{
			trace("onSocketInitializationComplete:", e.data);
			
			//connection.removeEventListener(FlashSocketClientEvent.DISCONNECTED, onSocketInitializationDisconnected);
			
			context.sessionId = e.data.sessionId;
			
			trace("CLIENT_ID:", e.data.serverId);
			
			// ******************************************************
			
			context.accountManager.registerConnection(context.token);
			
			// ******************************************************
			
			stationsWatcherManager = context.stationsManagersBuilder.build();
			
			var stations:Array = new Array();
			
			for (var i:int = 0;i < context.stations.length;i ++)
				stations.push((context.stations.getItemAt(i) as StationData)._id);
			
			trace("2.StationController[onSocketInitializationComplete]:", stations);
			
			if (stations.length > 0)
			{
				stationsWatcherManager.addSocketEventListener(StationsManagerEvent.START_WATCH_COMPLETE, onStartWatchStationsComplete);
				stationsWatcherManager.addSocketEventListener(StationsManagerEvent.START_WATCH_ERROR, onStartWatchStationsError);
				stationsWatcherManager.startWatchStations(stations);
			}
			else
			{
				if (context.stationData)
					stationUp();
				else
					dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_INVALID_STATION));
			}
		}
		
		protected function onStartWatchStationsComplete(e:StationsManagerEvent):void 
		{
			trace("-onStartWatchStationsComplete-");
			
			stationsWatcherManager.removeSocketEventListener(StationsManagerEvent.START_WATCH_COMPLETE, onStartWatchStationsComplete);
			stationsWatcherManager.removeSocketEventListener(StationsManagerEvent.START_WATCH_ERROR, onStartWatchStationsError);
			
			var stationsReport:Object = e.data.stationsReport;
			var i:int;
				
			if (stationsReport)
				for (i = 0;i < context.stations.length;i ++)
					if (stationsReport[(context.stations.getItemAt(i) as StationData)._id])
						(context.stations.getItemAt(i) as StationData).online = stationsReport[(context.stations.getItemAt(i) as StationData)._id] == true;
			
			stationsWatcherManager.addSocketEventListener(StationsManagerEvent.STATION_UP_DETECTED, onStationUpDetected);
			stationsWatcherManager.addSocketEventListener(StationsManagerEvent.STATION_DOWN_DETECTED, onStationDownDetected);
			
			// ******************************************************
			
			var servers:Array = new Array();
			
			for (i = 0;i < context.servers.length;i ++)
				servers.push((context.servers.getItemAt(i) as ServerData)._id);
			
			trace("2.StationController[onStationUpComplete]:", servers);
			
			if (servers.length > 0)
			{
				serversWatcherManager = context.serversManagersBuilder.build();
				serversWatcherManager.addSocketEventListener(ServersManagerEvent.START_WATCH_COMPLETE, onStartWatchServersComplete);
				serversWatcherManager.addSocketEventListener(ServersManagerEvent.START_WATCH_ERROR, onStartWatchServersError);
				serversWatcherManager.startWatchServers(servers);
			}
			else
			{
				if (context.stationData)
					stationUp();
				else
					dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_INVALID_STATION));
			}
		}
		
		protected function onStartWatchStationsError(e:StationsManagerEvent):void 
		{
			trace("-onStartWatchStationsComplete-");
			
			stationsWatcherManager.removeSocketEventListener(StationsManagerEvent.START_WATCH_COMPLETE, onStartWatchStationsComplete);
			stationsWatcherManager.removeSocketEventListener(StationsManagerEvent.START_WATCH_ERROR, onStartWatchStationsError);
			
			reset();
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 104));
		}
		
		// *************************************************************************************************************************
		
		protected function onStartWatchServersComplete(e:ServersManagerEvent):void 
		{
			trace("-onStartWatchServersComplete-");
			
			serversWatcherManager.removeSocketEventListener(ServersManagerEvent.START_WATCH_COMPLETE, onStartWatchServersComplete);
			serversWatcherManager.removeSocketEventListener(ServersManagerEvent.START_WATCH_ERROR, onStartWatchServersError);
			
			var serversReport:Object = e.data.serversReport;
			
			if (serversReport)
				for (var i:int = 0;i < context.servers.length;i ++)
					if (serversReport[(context.servers.getItemAt(i) as ServerData)._id])
						(context.servers.getItemAt(i) as ServerData).online = serversReport[(context.servers.getItemAt(i) as ServerData)._id] == true;
			
			serversWatcherManager.addSocketEventListener(ServersManagerEvent.SERVER_UP_DETECTED, onServerUpDetected);
			serversWatcherManager.addSocketEventListener(ServersManagerEvent.SERVER_DOWN_DETECTED, onServerDownDetected);
			
			/*if (context.stationData)
				stationUp();
			else
				dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_INVALID_STATION));*/
			
			stationUp();
		}
		
		protected function onStartWatchServersError(e:ServersManagerEvent):void 
		{
			trace("-onStartWatchServersComplete-");
			
			serversWatcherManager.removeSocketEventListener(ServersManagerEvent.START_WATCH_COMPLETE, onStartWatchServersComplete);
			serversWatcherManager.removeSocketEventListener(ServersManagerEvent.START_WATCH_ERROR, onStartWatchServersError);
			
			reset();
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 104));
		}
		
		
		// ****************************************************************************************************************
		// 														STATIONS
		// ****************************************************************************************************************
		
		public function stationUp():void
		{
			/*if (tmpStationData && applicationSettings.settings.stationId == tmpStationData._id)
				return tmpStationData;
			
			if (applicationSettings.settings.stationId == applicationSettings.settings.guestStationId)
				tmpStationData = guestStationData;
			else
				tmpStationData = getItemFromCollection("_id", applicationSettings.settings.stationId, stations) as StationData;*/
			
			
			trace("StationController[stationUp]:");
			
			/*if (context.applicationSettings.settings.stationId != StationContext.GUEST_ID)
			{
				tmpUpStationsManager = context.stationsManagersBuilder.build();
				tmpUpStationsManager.addSocketEventListener(StationsManagerEvent.STATION_UP_COMPLETE, onStationUpComplete);
				tmpUpStationsManager.addSocketEventListener(StationsManagerEvent.STATION_UP_ERROR, onStationUpError);
				tmpUpStationsManager.stationUp(context.stationData._id);
			}
			else
				onGuestStationUpComplete();*/
			
			context.stationData = CollectionUtil.getItemFromCollection("_id", context.applicationSettings.settings.stationId, context.stations) as StationData;
			
			if (!context.stationData)
			{
				if (context.applicationSettings.settings.stationId == context.applicationSettings.settings.guestStationId)
				{
					context.stationData = new StationData();
					context.stationData._id = context.applicationSettings.settings.guestStationId;
					context.stationData.name = "Guest";
				}
				else
				{
					context.applicationSettings.settings.stationId = null;
					context.applicationSettings.save();
				}
			}
			
			if (context.stationData)
			{
				tmpUpStationsManager = context.stationsManagersBuilder.build();
				tmpUpStationsManager.addSocketEventListener(StationsManagerEvent.STATION_UP_COMPLETE, onStationUpComplete);
				tmpUpStationsManager.addSocketEventListener(StationsManagerEvent.STATION_UP_ERROR, onStationUpError);
				tmpUpStationsManager.stationUp(context.stationData._id);
			}
			else
				dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_INVALID_STATION));
		}
		
		protected function onStationUpComplete(e:StationsManagerEvent):void 
		{
			tmpUpStationsManager.removeSocketEventListener(StationsManagerEvent.STATION_UP_COMPLETE, onStationUpComplete);
			tmpUpStationsManager.removeSocketEventListener(StationsManagerEvent.STATION_UP_ERROR, onStationUpError);
			
			context.stationsManagersBuilder.destroy(tmpUpStationsManager);
			tmpUpStationsManager = null;
			
			var index:int = context.applicationSettings.settings.playlistsStationIndex;
			var stationId:String = context.applicationSettings.settings.playlistsStationId;
			
			if (index < 0 || 
				index > context.stations.length - 1 || 
				(context.stations.getItemAt(index) as StationData)._id != stationId)
			{
				context.applicationSettings.settings.playlistsStationIndex = context.getItemIndexFromCollection("_id", context.stationData._id, context.stations);
				context.applicationSettings.settings.playlistsStationId = context.stationData._id;
			}
			
			index = context.applicationSettings.settings.channelsStationIndex;
			stationId = context.applicationSettings.settings.channelsStationId;
			
			if (index < 0 || 
				index > context.stations.length - 1 || 
				(context.stations.getItemAt(index) as StationData)._id != stationId)
			{
				context.applicationSettings.settings.channelsStationIndex = context.getItemIndexFromCollection("_id", context.stationData._id, context.stations);
				context.applicationSettings.settings.channelsStationId = context.stationData._id;
			}
			
			context.applicationSettings.save();
			
			context.channels.refresh();
			context.playlists.refresh();
			
			trace("StationController[onStationUpComplete]:");
			
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_READY));
		}
		
		protected function onGuestStationUpComplete():void
		{
			trace("-managerGuestStationLogin-", context.stations.length);
			
			if (context.stations.length > 0)
			{
				var index:int = context.applicationSettings.settings.playlistsStationIndex;
				var stationId:String = context.applicationSettings.settings.playlistsStationId;
				
				if (index < 0 || 
					index > context.stations.length - 1 || 
					(context.stations.getItemAt(index) as StationData)._id != stationId)
				{
					context.applicationSettings.settings.playlistsStationIndex = 0;
					context.applicationSettings.settings.playlistsStationId = (context.stations.getItemAt(0) as StationData)._id;
				}
				
				index = context.applicationSettings.settings.channelsStationIndex;
				stationId = context.applicationSettings.settings.channelsStationId;
				
				if (index < 0 || 
					index > context.stations.length - 1 || 
					(context.stations.getItemAt(index) as StationData)._id != stationId)
				{
					context.applicationSettings.settings.channelsStationIndex = 0;
					context.applicationSettings.settings.channelsStationId = (context.stations.getItemAt(0) as StationData)._id;
				}
				
				context.applicationSettings.save();
			}
			else
			{
				context.applicationSettings.settings.channelsStationIndex = -1;
				context.applicationSettings.settings.channelsStationId = null;
				
				context.applicationSettings.settings.playlistsStationIndex = -1;
				context.applicationSettings.settings.playlistsStationId = null;
			}
			
			context.applicationSettings.save();
			
			context.channels.refresh();
			context.playlists.refresh();
			
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_READY));
		}
		
		protected function onStationUpError(e:StationsManagerEvent):void 
		{
			tmpUpStationsManager.removeSocketEventListener(StationsManagerEvent.STATION_UP_COMPLETE, onStationUpComplete);
			tmpUpStationsManager.removeSocketEventListener(StationsManagerEvent.STATION_UP_ERROR, onStationUpError);
			
			context.stationsManagersBuilder.destroy(tmpUpStationsManager);
			tmpUpStationsManager = null;
			
			trace("StationController[onStationUpError]:");
			
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 105));
		}
		
		// ****************************************************************************************************************
		
		public function stationDown():void
		{
			trace("StationController[stationDown]:");
			
			/*if (context.applicationSettings.settings.stationId != StationContext.GUEST_ID)
			{
				tmpDownStationsManager = context.stationsManagersBuilder.build();
				tmpDownStationsManager.addSocketEventListener(StationsManagerEvent.STATION_DOWN_COMPLETE, onStationDownComplete);
				tmpDownStationsManager.addSocketEventListener(StationsManagerEvent.STATION_DOWN_ERROR, onStationDownError);
				tmpDownStationsManager.stationDown(context.stationData._id);
			}
			else
				onStationDownComplete(null);*/
			
			tmpDownStationsManager = context.stationsManagersBuilder.build();
			tmpDownStationsManager.addSocketEventListener(StationsManagerEvent.STATION_DOWN_COMPLETE, onStationDownComplete);
			tmpDownStationsManager.addSocketEventListener(StationsManagerEvent.STATION_DOWN_ERROR, onStationDownError);
			tmpDownStationsManager.stationDown(context.stationData._id);
		}
		
		protected function onStationDownComplete(e:StationsManagerEvent):void 
		{
			if (tmpDownStationsManager)
			{
				tmpDownStationsManager.removeSocketEventListener(StationsManagerEvent.STATION_DOWN_COMPLETE, onStationDownComplete);
				tmpDownStationsManager.removeSocketEventListener(StationsManagerEvent.STATION_DOWN_ERROR, onStationDownError);
				
				context.stationsManagersBuilder.destroy(tmpDownStationsManager);
				tmpDownStationsManager = null;
			}
			
			context.applicationSettings.settings.playlistsStationIndex = -1;
			context.applicationSettings.settings.playlistsStationId = null;
			
			context.applicationSettings.settings.channelsStationIndex = -1;
			context.applicationSettings.settings.channelsStationId = null;
			
			context.applicationSettings.settings.stationId = null;
			context.applicationSettings.save();
			
			trace("StationController[onStationDownComplete]:");
			
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_STATION_DOWN_COMPLETE));
		}
		
		protected function onStationDownError(e:StationsManagerEvent):void 
		{
			trace("StationController[onStationDownError]:");
			
			reset();
			
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_STATION_DOWN_ERROR));
			dispatchEvent(new StationControllerEvent(StationControllerEvent.EMITTER_ERROR, 106));
		}
		
		// ****************************************************************************************************************
		
		protected function onStationUpDetected(e:StationsManagerEvent):void 
		{
			trace("-onStationUpDetected-");
			
			var stationData:StationData = CollectionUtil.getItemFromCollection("_id", e.data.stationId, context.stations) as StationData;
			
			if (stationData)
				stationData.online = true;
		}
		
		protected function onStationDownDetected(e:StationsManagerEvent):void 
		{
			trace("-onStationDownDetected-");
			
			var stationData:StationData = CollectionUtil.getItemFromCollection("_id", e.data.stationId, context.stations) as StationData;
			
			if (stationData)
				stationData.online = false;
		}
		
		private function onStationInserted(e:AccountManagerEvent):void
		{
			var stationData:StationData = new StationData();
			stationData.readObject(e.data);
			
			context.stations.addItem(stationData);
			stationsWatcherManager.startWatchStations([stationData._id]);
		}
		
		private function onStationUpdated(e:AccountManagerEvent):void
		{
			var stationData:StationData = CollectionUtil.getItemFromCollection("_id", e.data._id, context.stations) as StationData;
			
			if (stationData)
				stationData.readObject(e.data);
		}
		
		private function onStationDeleted(e:AccountManagerEvent):void
		{
			var stationData:StationData = CollectionUtil.getItemFromCollection("_id", e.data._id, context.stations) as StationData;
			
			if (stationData)
			{
				stationsWatcherManager.stopWatchStations([stationData._id]);
				context.stations.removeItemAt(context.stations.getItemIndex(stationData));
			}
		}
		
		// ****************************************************************************************************************
		// 														SERVERS
		// ****************************************************************************************************************
		
		protected function onServerUpDetected(e:ServersManagerEvent):void 
		{
			trace("-onServerUpDetected-", e.data.serverId);
			
			var serverData:ServerData = CollectionUtil.getItemFromCollection("_id", e.data.serverId, context.servers) as ServerData;
			
			if (serverData)
				serverData.online = true;
		}
		
		protected function onServerDownDetected(e:ServersManagerEvent):void 
		{
			trace("-onServerDownDetected-", e.data.serverId);
			
			var serverData:ServerData = CollectionUtil.getItemFromCollection("_id", e.data.serverId, context.servers) as ServerData;
			
			if (serverData)
				serverData.online = false;
		}
		
		private function onServerInserted(e:AccountManagerEvent):void
		{
			var serverData:ServerData = new ServerData();
			serverData.readObject(e.data);
			
			context.servers.addItem(serverData);
			serversWatcherManager.startWatchServers([serverData._id]);
		}
		
		private function onServerUpdated(e:AccountManagerEvent):void
		{
			var serverData:ServerData = CollectionUtil.getItemFromCollection("_id", e.data._id, context.servers) as ServerData;
			
			if (serverData)
				serverData.readObject(e.data);
		}
		
		private function onServerDeleted(e:AccountManagerEvent):void
		{
			var serverData:ServerData = CollectionUtil.getItemFromCollection("_id", e.data._id, context.servers) as ServerData;
			
			if (serverData)
			{
				serversWatcherManager.stopWatchServers([serverData._id]);
				context.servers.removeItemAt(context.servers.getItemIndex(serverData));
			}
		}
		
		/*protected function onSelectChannel(e:StationRemoteControlEvent):void
		{
			var channelContext:ChannelContext = CollectionUtil.getItemFromCollection("_id", e.data._id, context.channels) as ChannelContext;
			
			trace("onSelectChannel:", channelContext);
			
			if (channelContext)
				context.selectedChannel = channelContext;
		}*/
		
		// ****************************************************************************************************************
		// 														PLAYLISTS
		// ****************************************************************************************************************
		
		private function onPlaylistInserted(e:AccountManagerEvent):void
		{
			var playlistContext:PlaylistContext = new PlaylistContext();
			playlistContext.readObject(e.data);
			
			context.playlists.addItem(playlistContext);
		}
		
		private function onPlaylistUpdated(e:AccountManagerEvent):void
		{
			var playlistContext:PlaylistContext = CollectionUtil.getItemFromCollection("_id", e.data._id, context.playlists) as PlaylistContext;
			
			if (playlistContext)
				playlistContext.readObject(e.data);
		}
		
		private function onPlaylistDeleted(e:AccountManagerEvent):void
		{
			var playlistContext:PlaylistContext = CollectionUtil.getItemFromCollection("_id", e.data._id, context.playlists) as PlaylistContext;
			
			if (playlistContext)
				context.playlists.removeItemAt(context.playlists.getItemIndex(playlistContext));
		}
		
		// ****************************************************************************************************************
		// 														CHANNELS
		// ****************************************************************************************************************
		
		private function onChannelInserted(e:AccountManagerEvent):void
		{
			var channelContext:ChannelContext = new ChannelContext();
			channelContext.readObject(e.data);
			
			context.channels.addItem(channelContext);
		}
		
		private function onChannelUpdated(e:AccountManagerEvent):void
		{
			var channelContext:ChannelContext = CollectionUtil.getItemFromCollection("_id", e.data._id, context.channels) as ChannelContext;
			
			if (channelContext)
				channelContext.readObject(e.data);
		}
		
		private function onChannelDeleted(e:AccountManagerEvent):void
		{
			var channelContext:ChannelContext = CollectionUtil.getItemFromCollection("_id", e.data._id, context.channels) as ChannelContext;
			
			if (channelContext)
				context.channels.removeItemAt(context.channels.getItemIndex(channelContext));
		}
		
		// ****************************************************************************************************************
		// 														GROUPS
		// ****************************************************************************************************************
		
		private function onGroupInserted(e:AccountManagerEvent):void
		{
			var groupData:GroupData = new GroupData();
			groupData.readObject(e.data);
			
			context.groups.addItem(groupData);
		}
		
		private function onGroupUpdated(e:AccountManagerEvent):void
		{
			var groupData:GroupData = CollectionUtil.getItemFromCollection("_id", e.data._id, context.groups) as GroupData;
			
			if (groupData)
				groupData.readObject(e.data);
		}
		
		private function onGroupDeleted(e:AccountManagerEvent):void
		{
			var groupData:GroupData = CollectionUtil.getItemFromCollection("_id", e.data._id, context.groups) as GroupData;
			
			if (groupData)
				context.groups.removeItemAt(context.groups.getItemIndex(groupData));
		}
		
		// ****************************************************************************************************************
		// 														SOCKET
		// ****************************************************************************************************************
		
		protected function onSocketConnected(e:FlashSocketClientEvent):void 
		{
			dispatchEvent(new FlashSocketClientEvent(FlashSocketClientEvent.CONNECTED));
		}
		
		protected function onSocketDisconnected(e:FlashSocketClientEvent):void 
		{
			dispatchEvent(new FlashSocketClientEvent(FlashSocketClientEvent.DISCONNECTED));
		}
		
		// ****************************************************************************************************************
		// 														
		// ****************************************************************************************************************
		
		public function reset():void
		{
			if (tmpAccountDataManager)
			{
				tmpAccountDataManager.removeEventListener(MongoDBRestEvent.COMPLETE, onLoginComplete);
				tmpAccountDataManager.removeEventListener(MongoDBRestEvent.ERROR, onLoginError);
				
				context.accountsDataManagersBuilder.destroy(tmpAccountDataManager);
				tmpAccountDataManager = null;
			}
			
			if (connection.online)
				connection.disconnect();
			
			if (serversWatcherManager)
			{
				context.serversManagersBuilder.destroy(serversWatcherManager);
				serversWatcherManager = null;
			}
			
			if (stationsWatcherManager)
			{
				context.stationsManagersBuilder.destroy(stationsWatcherManager);
				stationsWatcherManager = null;
			}
			
			if (tmpUpStationsManager)
			{
				context.stationsManagersBuilder.destroy(tmpUpStationsManager);
				tmpUpStationsManager = null;
			}
			
			if (tmpDownStationsManager)
			{
				context.stationsManagersBuilder.destroy(tmpDownStationsManager);
				tmpDownStationsManager = null;
			}
			
			context.channels.removeAll();
			context.playlists.removeAll();
			context.groups.removeAll();
			context.notifications.removeAll();
			context.stations.removeAll();
			context.servers.removeAll();
			
			context.unregisterAllBroadcast();
		}
	}
}