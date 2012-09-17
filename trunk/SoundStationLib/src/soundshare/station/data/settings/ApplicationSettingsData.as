package soundshare.station.data.settings
{
	import soundshare.station.data.stations.StationData;
	
	import utils.math.ExMath;

	[Bindable]
	[RemoteClass]
	public class ApplicationSettingsData
	{
		public var MANAGER_URL:String = "http://192.168.204.131:6001";
		
		public var MANAGER_SOCKET_ADDRESS:String = "192.168.204.131";
		public var MANAGER_SOCKET_PORT:int = 6001;
		
		public var SERVER_ID:String = "1B2675A6-E5DC-45AF-98D6-83D779A8698B";
		
		public var maxListeners:Number = 10;
		public var groupsSortType:Number = 1;
		
		public var membersPerPage:Number = 10;
		public var groupMembersPerPage:Number = 10;
		
		public var stationId:String;
		public var guestStationId:String = ExMath.uuidCompact();
		
		public var playlistsStationId:String;
		public var playlistsStationIndex:int = 0;
		
		public var channelsStationId:String;
		public var channelsStationIndex:int = 0;
		
		public function ApplicationSettingsData()
		{
		}
	}
}