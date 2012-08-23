package soundshare.station.builders.broadcasts
{
	import soundshare.station.data.StationContext;
	import soundshare.station.listeners.remote.rpb.RemotePlaylistListener;

	public class RemotePlaylistListenerBuilder
	{
		protected var context:StationContext;
		protected var cache:Vector.<RemotePlaylistListener> = new Vector.<RemotePlaylistListener>();
		
		public var cacheEnabled:Boolean = true;
		
		public function RemotePlaylistListenerBuilder(context:StationContext)
		{
			this.context = context;
		}
		
		public function build():RemotePlaylistListener
		{
			var listener:RemotePlaylistListener;
			
			if (cacheEnabled)
				listener = cache.shift();
			
			if (!listener)
				listener = new RemotePlaylistListener();
			
			listener.context = context;
			
			return listener;
		}
		
		public function destroy(listener:RemotePlaylistListener):void
		{
			listener.reset();
			
			if (cacheEnabled)
				cache.push(listener);
		}
	}
}