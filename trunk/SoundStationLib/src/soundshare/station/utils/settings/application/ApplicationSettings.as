package soundshare.station.utils.settings.application
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import soundshare.station.data.settings.ApplicationSettingsData;
	import utils.files.FileUtil;
	
	public class ApplicationSettings extends EventDispatcher
	{
		public static const filepath:String = "data/settings/settings.dat";
		
		private var _settings:ApplicationSettingsData = new ApplicationSettingsData();
		
		public function ApplicationSettings()
		{
			super();
		}
		
		public function save():void
		{
			FileUtil.saveObjectToStorageDirectory(filepath, _settings);
		}
		
		public function load():void
		{
			var obj:Object = FileUtil.loadObjectFromStorageDirectory(filepath);
			
			if ((obj as ApplicationSettingsData) != null)
				_settings = obj as ApplicationSettingsData;
		}
		
		[Bindable]
		public function set settings(value:ApplicationSettingsData):void
		{
			_settings = value;
		}
		
		public function get settings():ApplicationSettingsData
		{
			return _settings;
		}
		
		public function get exist():Boolean
		{
			var file:File = File.applicationStorageDirectory.resolvePath(filepath);
			
			return file ? file.exists : false; 
		}
	}
}