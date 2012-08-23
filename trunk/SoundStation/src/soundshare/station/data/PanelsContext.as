package soundshare.station.data
{
	import soundshare.station.content.pages.station.panels.accounts.AccountDataPanel;
	import soundshare.station.content.pages.station.panels.channels.panels.player.ChannelPlayerPanel;
	import soundshare.station.content.pages.station.panels.groups.panels.GroupInfoPanel;
	import soundshare.station.content.pages.station.panels.groups.panels.requests.JoinToGroupsRequestPanel;
	import soundshare.station.content.pages.station.panels.groups.panels.selector.SelectGroupPanel;
	import soundshare.station.content.pages.station.panels.playlists.panels.player.PlaylistPlayerPanel;
	
	public class PanelsContext
	{
		[Bindable] private var _context:StationContext;
		
		public var accountDataPanel:AccountDataPanel;
		public var playlistPlayerPanel:PlaylistPlayerPanel;
		public var channelPlayerPanel:ChannelPlayerPanel;
		
		public var groupInfoPanel:GroupInfoPanel;
		public var joinToGroupsRequestPanel:JoinToGroupsRequestPanel;
		
		public var selectGroupPanel:SelectGroupPanel;
		
		public function PanelsContext()
		{
			accountDataPanel = new AccountDataPanel();
			channelPlayerPanel = new ChannelPlayerPanel();
			playlistPlayerPanel = new PlaylistPlayerPanel();
			
			groupInfoPanel = new GroupInfoPanel();
			joinToGroupsRequestPanel = new JoinToGroupsRequestPanel();
			selectGroupPanel = new SelectGroupPanel();
		}
		
		public function set context(value:StationContext):void
		{
			_context = value;
			
			accountDataPanel.init(value, this);
			channelPlayerPanel.init(value, this);
			playlistPlayerPanel.init(value, this);
			
			groupInfoPanel.init(value, this);
			joinToGroupsRequestPanel.init(context);
			selectGroupPanel.init(value);
		}
		
		public function get context():StationContext
		{
			return _context;
		}
	}
}