package soundshare.station.data.media
{
	import soundshare.sdk.data.base.DataObject;

	public class MediaInfoData extends DataObject
	{
		public var album:String;
		public var artist:String;
		public var comment:String;
		public var genre:String;
		public var songName:String;
		public var track:String;
		public var year:String;
		
		public function MediaInfoData()
		{
			super();
		}
		
		override public function get data():Object
		{
			var obj:Object = {
				album: album,
				artist: artist,
				comment: comment,
				genre: genre,
				songName: songName,
				track: track,
				year: year
			};
			
			return obj;
		}
	}
}