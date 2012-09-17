package soundshare.station.data
{
	import mx.collections.ArrayCollection;
	
	import soundshare.sdk.data.SoundShareContext;
	import soundshare.sdk.data.platlists.PlaylistContext;
	import soundshare.sdk.data.plugin.PluginData;
	import soundshare.sdk.managers.events.SecureClientEventDispatcher;
	import soundshare.station.broadcasts.base.BaseBroadcast;
	import soundshare.station.broadcasts.rpb.RemotePlaylistBroadcast;
	import soundshare.station.broadcasts.srb.StandardRadioBroadcast;
	import soundshare.station.builders.broadcasts.RemotePlaylistBroadcastBuilder;
	import soundshare.station.builders.broadcasts.RemotePlaylistListenerBuilder;
	import soundshare.station.builders.broadcasts.StandardRadioBroadcastBuilder;
	import soundshare.station.builders.broadcasts.StandardRadioListenerBuilder;
	import soundshare.station.builders.managers.broadcasts.BroadcastsManagersBuilder;
	import soundshare.station.builders.managers.broadcasts.RemoteBroadcastsManagersBuilder;
	import soundshare.station.builders.managers.stations.StationRemoteControlsBuilder;
	import soundshare.station.controllers.station.StationController;
	import soundshare.station.data.account.AccountData;
	import soundshare.station.data.channels.ChannelContext;
	import soundshare.station.data.stations.StationData;
	import soundshare.station.managers.account.AccountManager;
	import soundshare.station.managers.broadcasts.RemoteBroadcastsManager;
	import soundshare.station.managers.stations.StationRemoteControl;
	import soundshare.station.utils.settings.application.ApplicationSettings;
	
	import utils.math.ExMath;

	public class StationContext extends SoundShareContext
	{
		//public static const GUEST_ID:String = "#GUEST#";
		
		[Bindable] public var playOrders:ArrayCollection = new ArrayCollection([
			{title: "Default", value: 0},
			{title: "Repeat playlist", value: 1},
			{title: "Shuffle", value: 2}
		]);
		
		[Bindable] public var groupsSortTypes:ArrayCollection = new ArrayCollection([
			{title: "All groups", value: 0},
			{title: "Users groups", value: 1},
			{title: "Channels groups", value: 2},
			{title: "Playlists groups", value: 3},
			{title: "Channels & Playlists groups", value: 4}
		]);
		
		public var genres:Array = new Array(	
			"Metal",
			"Punk",
			"Ska",
			"Hardcore",
			"Nu-metal",
			"Jazz",
			"Pop"  
		);
		
		public var playlistTypes:Array = new Array(	
			"public",
			"private",
			"invisible" 
		);
		
		public var groupsTypes:Array = new Array(	
			"user",
			"channel",
			"playlist"
		);
		
		public var stationController:StationController;
		
		public var accountData:AccountData = new AccountData();
		
		public var broadcastsManagersBuilder:BroadcastsManagersBuilder;
		public var remoteBroadcastsManagersBuilder:RemoteBroadcastsManagersBuilder;
		
		public var remotePlaylistListenerBuilder:RemotePlaylistListenerBuilder;
		public var remotePlaylistBroadcastBuilder:RemotePlaylistBroadcastBuilder
		
		//public var stationRemoteControlsBuilder:StationRemoteControlsBuilder;
		//public var stationRemoteControl:StationRemoteControl;
		
		public var remoteBroadcastsManager:RemoteBroadcastsManager;
		public var accountManager:AccountManager;
		
		public var standardRadioBroadcastBuilder:StandardRadioBroadcastBuilder;
		public var standardRadioListenerBuilder:StandardRadioListenerBuilder;
		
		[Bindable] public var channels:ArrayCollection = new ArrayCollection();
		[Bindable] public var playlists:ArrayCollection = new ArrayCollection();
		[Bindable] public var groups:ArrayCollection = new ArrayCollection();
		[Bindable] public var notifications:ArrayCollection = new ArrayCollection();
		[Bindable] public var stations:ArrayCollection = new ArrayCollection();
		[Bindable] public var servers:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var broadcasts:ArrayCollection = new ArrayCollection();
		[Bindable] public var broadcastsById:Array = new Array();
		
		[Bindable] public var applicationSettings:ApplicationSettings;
		
		[Bindable] public var selectedPlaylist:PlaylistContext;
		[Bindable] public var selectedChannel:ChannelContext;
		
		public var stationData:StationData;
		//private var guestStationData:StationData;
		
		public function StationContext()
		{
			super();
			
			var pd:PluginData = new PluginData();
			pd._id = "-REMOTE_PLAYLIST-";
			pd.name = "Remote playlist";
			pd.namespace = null;
			pd.version = "0.1";
			pd.type = 0;
			pd.filename = "data/soundshare/plugins/station/remoteplaylist/container/RemotePlaylistPlugin.swf";
			
			pluginsCollection.addPlugin(pd);
			
			pd = new PluginData();
			pd._id = "-STANDARD_RADIO-";
			pd.name = "Standard radio broadcast";
			pd.namespace = "sss_standardradioplugin";
			pd.version = "0.1";
			pd.type = 1;
			pd.filename = "data/soundshare/plugins/station/standardradio/container/StandardRadioPlugin.swf";
			
			pluginsCollection.addPlugin(pd);
			
			applicationSettings = new ApplicationSettings();
			applicationSettings.load();
			
			/*stationData = new StationData();
			stationData._id = applicationSettings.settings.guestStationId;
			stationData.name = "Guest";*/
			
			accountManager = new AccountManager(this);
			accountManager.namespace = "socket.managers.AccountsManager";
			accountManager.receiverNamespace = "socket.managers.AccountsManager";
			
			connection.addUnit(accountManager);
			
			remoteBroadcastsManager = new RemoteBroadcastsManager(this);
			remoteBroadcastsManager.namespace = "socket.managers.RemoteBroadcastsManager";
			
			broadcastsManagersBuilder = new BroadcastsManagersBuilder(this);
			remoteBroadcastsManagersBuilder = new RemoteBroadcastsManagersBuilder(this);
			
			remotePlaylistListenerBuilder = new RemotePlaylistListenerBuilder(this);
			remotePlaylistBroadcastBuilder = new RemotePlaylistBroadcastBuilder(this);
			
			standardRadioBroadcastBuilder = new StandardRadioBroadcastBuilder(this);
			standardRadioListenerBuilder = new StandardRadioListenerBuilder(this);
			
			/*stationRemoteControl = new StationRemoteControl();
			stationRemoteControl.namespace = "socket.managers.StationRemoteControl";
			
			connection.addUnit(stationRemoteControl);
			
			stationRemoteControlsBuilder = new StationRemoteControlsBuilder(this);*/
		}
		
		public function getItemFromCollection(property:String, value:Object, collection:ArrayCollection):Object
		{
			for (var i:int = 0;i < collection.length;i ++)
				if (collection.getItemAt(i)[property] == value)
					return collection.getItemAt(i);
			
			return null;
		}
		
		public function getItemIndexFromCollection(property:String, value:Object, collection:ArrayCollection):int
		{
			for (var i:int = 0;i < collection.length;i ++)
				if (collection.getItemAt(i)[property] == value)
					return i;
			
			return -1;
		}
		
		/*public function get stationData():StationData
		{
			if (tmpStationData && applicationSettings.settings.stationId == tmpStationData._id)
				return tmpStationData;
			
			if (applicationSettings.settings.stationId == applicationSettings.settings.guestStationId)
				tmpStationData = guestStationData;
			else
				tmpStationData = getItemFromCollection("_id", applicationSettings.settings.stationId, stations) as StationData;
			
			return tmpStationData;
		}*/
		
		public function get totalListeners():int
		{
			var total:int = 0;
			
			for (var i:int = 0;i < broadcasts.length;i ++)
				if (broadcasts.getItemAt(i) is RemotePlaylistBroadcast)
					total ++;
			
			return total;
		}
		
		public function registerBroadcast(broadcast:SecureClientEventDispatcher):void
		{
			trace("registerBroadcast:", broadcast.id);
			
			broadcasts.addItem(broadcast);
			broadcastsById[broadcast.id] = broadcast;
		}
		
		public function unregisterBroadcast(broadcast:SecureClientEventDispatcher):void
		{
			var index:int = broadcasts.getItemIndex(broadcast);
			
			trace("unregisterBroadcast:", index, broadcast.id);
			
			if (index != -1)
			{
				var broadcast:SecureClientEventDispatcher = broadcasts.removeItemAt(index) as SecureClientEventDispatcher;
				delete broadcastsById[broadcast.id];
				
				if (broadcast is RemotePlaylistBroadcast)
					remotePlaylistBroadcastBuilder.destroy(broadcast as RemotePlaylistBroadcast);
				else
				if (broadcast is StandardRadioBroadcast)
					standardRadioBroadcastBuilder.destroy(broadcast as StandardRadioBroadcast);
			}
		}
		
		public function getBroadcastById(id:String):BaseBroadcast
		{
			return broadcastsById[id] as BaseBroadcast;
		}
		
		public function unregisterAllBroadcast():void
		{
			var items:Array = [].concat(broadcasts.source);
			
			for (var i:int = 0;i < items.length;i ++)
				unregisterBroadcast(items[i]);
			
			broadcasts.removeAll();
		}
		
		override public function set token(value:String):void
		{
			super.token = value;
			
			remoteBroadcastsManager.token = value;
			accountManager.token = value;
		}
	}
}