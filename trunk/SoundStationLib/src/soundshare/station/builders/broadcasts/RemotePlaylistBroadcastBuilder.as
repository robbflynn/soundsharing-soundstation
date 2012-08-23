package soundshare.station.builders.broadcasts
{
	import soundshare.station.broadcasts.rpb.RemotePlaylistBroadcast;
	import soundshare.station.data.StationContext;
	
	public class RemotePlaylistBroadcastBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<RemotePlaylistBroadcast> = new Vector.<RemotePlaylistBroadcast>();
		
		public var cacheEnabled:Boolean = true;
		
		public function RemotePlaylistBroadcastBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build():RemotePlaylistBroadcast
		{
			var broadcast:RemotePlaylistBroadcast;
			
			if (cacheEnabled)
				broadcast = cache.shift();
			
			if (!broadcast)
				broadcast = new RemotePlaylistBroadcast();
			
			broadcast.context = context;
			
			return broadcast;
		}
		
		public function destroy(broadcast:RemotePlaylistBroadcast):void
		{
			if (cacheEnabled)
				cache.push(broadcast);
		}
	}
}