package edu.amrita.aview.core.entry
{
		
	import flash.system.Capabilities;
	applicationType::DesktopMobile{
		import NativeApps.android.deviceinfo.NativeDeviceInfo;
		import NativeApps.android.deviceinfo.NativeDeviceInfoEvent;
		import NativeApps.android.deviceinfo.NativeDeviceProperties;
		import NativeApps.android.deviceinfo.NativeDevicePropertiesData;
	}
	
	public class AVCEnvironment
	{
		/**Platform specific imports*/
		public static const WINDOWS:String="WINDOWS";
		public static const MACINTOSH:String="MACINTOSH";
		public static const LINUX:String="LINUX";
		public static const ANDROID:String="ANDROID";
		public static const IOS:String="IOS";
		
		public static const BROWSER:String="BROWSER";
		public static const STAND_ALONE:String="STAND_ALONE";
		
		public static const DESKTOP:String="DESKTOP";
		public static const HAND_HELD_DEVICES:String="HAND_HELD_DEVICES";
		
		
		public static var deviceType:String="";
		public static var device:String="";
		public static var runTime:String="";
		public static var os:String="";
		
		public function AVCEnvironment()
		{
			getAVCEnvironment();
		}
		
		private function getAVCEnvironment():void
		{
			
			if (Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn")
				runTime=BROWSER;
			if (Capabilities.playerType == "Desktop")
				runTime=STAND_ALONE;
			if (Capabilities.cpuArchitecture == "ARM")
			{
				deviceType=HAND_HELD_DEVICES;
			}
			else
			{
				deviceType=DESKTOP;
			}
			if ((Capabilities.os.toLowerCase().indexOf("win") > -1))
				os=WINDOWS;
			if ((Capabilities.os.toLowerCase().indexOf("mac") > -1))
				os=MACINTOSH;
			if ((Capabilities.os.toLowerCase().indexOf("linux") > -1))
				os=LINUX;
			if ((Capabilities.os.toLowerCase().indexOf("iphone") > -1))
				os=IOS;
			if ((Capabilities.os.toLowerCase().indexOf("android") > -1) || (deviceType == HAND_HELD_DEVICES && os != IOS && os == LINUX))
			{
				applicationType::DesktopMobile{
					var deviceInfo:NativeDeviceInfo=new NativeDeviceInfo();
					deviceInfo.addEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
					deviceInfo.setDebug(true);
					deviceInfo.parse();
				}
			}
		}
		
		/**Platform specific function*/
		
		applicationType::DesktopMobile{
			private function handleDevicePropertiesParsed(event:NativeDeviceInfoEvent):void
			{
				NativeDeviceInfo(event.target).removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
				if ((NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).value.toLowerCase().indexOf("android")) > -1)
				{
					os=ANDROID;
					device=NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).value + "" + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).value;
				}
			}
		}
	}
}
