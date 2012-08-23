package soundshare.station.data.channels.broadcasts
{
	import soundshare.station.data.channels.broadcasts.base.BroadcastContext;

	public class StandardRadioContext extends BroadcastContext
	{
		public var playType:int = 0;
		public var playlists:Array = new Array();
		
		public function StandardRadioContext()
		{
			super();
		}
		
		override public function readObject(obj:Object, excep:Array = null):Boolean
		{
			excep = excep ? excep.concat(["playlists"]) : ["playlists"];
			
			if (!super.readObject(obj, excep))
				return false;
			
			if (obj.playlists)
				playlists = obj.playlists;
			
			return true;
		}
		
		override public function clearObject():void
		{
			playType = 0;
			playlists = new Array();
		}
		
		override public function get data():Object
		{
			var obj:Object = {
				playType: playType,
				playlists: playlists
			};
			
			return obj;
		}
	}
}