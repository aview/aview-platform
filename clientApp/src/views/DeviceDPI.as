package views
{
	import NativeApps.android.deviceinfo.NativeDeviceInfo;
	import NativeApps.android.deviceinfo.NativeDeviceInfoEvent;
	import NativeApps.android.deviceinfo.NativeDeviceProperties;
	import NativeApps.android.deviceinfo.NativeDevicePropertiesData;
	
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.FlexGlobals;
	import mx.core.RuntimeDPIProvider;
	
	public class DeviceDPI extends RuntimeDPIProvider
	{
		public var screenDPI:int = 0 ;
		public var deviceRuntimeDPI:int = 0;
		public var deviceModel:String;

		public function DeviceDPI()
		{
			deviceDPI();
		}
		
		public function deviceDPI():void
		{
			screenDPI = Capabilities.screenDPI;
			trace("Screen DPI :"+Capabilities.screenDPI.toString());
			if (screenDPI < 200){
				deviceRuntimeDPI = DPIClassification.DPI_240;
			}
			if (screenDPI >=200 && screenDPI<280){
				deviceRuntimeDPI = DPIClassification.DPI_240
			}
			if (screenDPI >=280){
				deviceRuntimeDPI = DPIClassification.DPI_320;
			}
			FlexGlobals.topLevelApplication.applicationDPI = deviceRuntimeDPI;
			//if ((Capabilities.os.toLowerCase().indexOf("android") > -1))
			//{
				var deviceInfo : NativeDeviceInfo = new NativeDeviceInfo();
				deviceInfo.addEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
				deviceInfo.setDebug(true);
				deviceInfo.parse();
			//}
		}
		private function handleDevicePropertiesParsed(event : NativeDeviceInfoEvent) : void 
		{
			NativeDeviceInfo(event.target).removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
			if((NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).value.toLowerCase().indexOf("android")) > -1)
			{
				//os = ANDROID;
				var device:String = NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).value+""
					+NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).value;
				deviceModel = NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MODEL).value
				trace("Android : "+device+"Device Model : "+deviceModel);
			}
		}
	}
}