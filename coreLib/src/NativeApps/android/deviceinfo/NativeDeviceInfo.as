package NativeApps.android.deviceinfo
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	/*
	 * Android-Native-Device-Info:
	 *
	 * This class is used to grab a system file, parse it and store its values.
	 * This information is mainly used for analytics and debugging
	 *
	 *
	 * Usage:
	 *
	 * 		var deviceInfo : NativeDeviceInfo = new NativeDeviceInfo();
	 * 		deviceInfo.addEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
	 * 		deviceInfo.setDebug(false);
	 * 		deviceInfo.parse();
	 *
	 * 		private function handleDevicePropertiesParsed(event : NativeDeviceInfoEvent) : void {
	 * 	   		 NativeDeviceInfo(event.target).removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
	 * 		}
	 *
	 */
	public class NativeDeviceInfo extends EventDispatcher
	{
		
		private static const PROP_FILE_ON_DEVICE:String="/system/build.prop";
		private var _debug:Boolean;
		private var _fileName:String;
		
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("NativeApps.android.deviceinfo.NativeDeviceInfo.as");
		
		public function NativeDeviceInfo(propfilename:String=PROP_FILE_ON_DEVICE, debug:Boolean=false)
		{
			_debug=debug;
			
			if (propfilename == PROP_FILE_ON_DEVICE)
			{
				_fileName=PROP_FILE_ON_DEVICE;
			}
			else
			{
				_fileName=propfilename;
			}
		}
		
		public function parse():void
		{
			var propFile:File=new File();
			propFile.nativePath=_fileName;
			
			var fs:FileStream=new FileStream();
			fs.open(propFile, FileMode.READ);
			
			var fileContents:String=fs.readUTFBytes(fs.bytesAvailable);
			fileContents=fileContents.replace(File.lineEnding, "\n");
			fs.close();
			
			// split on newlines
			var pattern:RegExp=/\r?\n/;
			var lines:Array=fileContents.split(pattern);
			
			for (var i:int=0; i < lines.length; i++)
			{
				var line:String=String(lines[i]);
				if (line != "")
				{
					if (line.search("#") == -1)
					{
						for (var j:int=0; j < NativeDeviceProperties.DEVICE_PROPERTIES.length; j++)
						{
							if (line.search(NativeDevicePropertiesData(NativeDeviceProperties.DEVICE_PROPERTIES[j]).configKey) != -1)
							{
								NativeDevicePropertiesData(NativeDeviceProperties.DEVICE_PROPERTIES[j]).value=line.split("=")[1];
								if (_debug)
								{
									if(Log.isDebug()) log.debug(NativeDevicePropertiesData(NativeDeviceProperties.DEVICE_PROPERTIES[j]).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.DEVICE_PROPERTIES[j]).value);
									if(Log.isDebug()) log.debug(NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).value);
								}
								break;
							}
						}
					}
				}
			}
			dispatchEvent(new NativeDeviceInfoEvent(NativeDeviceInfoEvent.PROPERTIES_PARSED));
		}
		
		public function getDebug():Boolean
		{
			return _debug;
		}
		
		public function setDebug(value:Boolean):void
		{
			_debug=value;
		}
	}
}
