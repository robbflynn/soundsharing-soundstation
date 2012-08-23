package soundshare.station.listeners.local.playlist
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.managers.CursorManager;
	
	import soundshare.sdk.db.mongo.base.events.MongoDBRestEvent;
	import soundshare.sdk.db.mongo.playlists.PlaylistsDataManager;
	import soundshare.station.data.StationContext;
	import soundshare.sdk.data.platlists.PlaylistContext;
	
	public class PlaylistListener extends EventDispatcher
	{
		[Bindable] private var _playlistCollection:ArrayCollection = new ArrayCollection();
		
		public var context:StationContext;
		
		private var playlistContext:PlaylistContext;
		
		public function PlaylistListener()
		{
			super();
		}
		
		public function prepare(playlistContext:PlaylistContext):void
		{
			this.playlistContext = playlistContext;
		}
		
		protected function loadPlaylist():void
		{
			var playlistsDataManager:PlaylistsDataManager = context.playlistsDataManagersBuilder.build();
			
			playlistsDataManager.addEventListener(MongoDBRestEvent.COMPLETE, onLoadPlaylistFileComplete);
			playlistsDataManager.addEventListener(MongoDBRestEvent.ERROR, onLoadPlaylistFileError);
			playlistsDataManager.loadPlaylistFile(playlistContext._id);
		}
		
		private function onLoadPlaylistFileComplete(e:MongoDBRestEvent):void
		{
			e.currentTarget.removeEventListener(MongoDBRestEvent.COMPLETE, onLoadPlaylistFileComplete);
			e.currentTarget.removeEventListener(MongoDBRestEvent.ERROR, onLoadPlaylistFileError);
			
			context.playlistsDataManagersBuilder.destroy(e.currentTarget as PlaylistsDataManager);
			
			playlistCollection.addAll(new ArrayCollection(e.data as Array));
		}
		
		private function onLoadPlaylistFileError(e:MongoDBRestEvent):void
		{
			e.currentTarget.removeEventListener(MongoDBRestEvent.COMPLETE, onLoadPlaylistFileComplete);
			e.currentTarget.removeEventListener(MongoDBRestEvent.ERROR, onLoadPlaylistFileError);
			
			context.playlistsDataManagersBuilder.destroy(e.currentTarget as PlaylistsDataManager);
			
		}
		
		public function get playlistCollection():ArrayCollection
		{
			return _playlistCollection;
		}
	}
}