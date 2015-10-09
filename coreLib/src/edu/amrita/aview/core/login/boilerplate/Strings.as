package edu.amrita.aview.core.login.boilerplate {
	import edu.amrita.aview.core.login.MainApp;
	
	applicationType::DesktopMobile {
		import flash.desktop.NativeApplication;
	}

	public class Strings {
		public function Strings() {
		}
		public static const NATIONAL_SERVER:String="National Server";
		public static const NORMAL_LOGIN:String="Password";
		public static const BIOMETRIC_LOGIN:String="Face Recognition";
		public static const SERVER_DETAIL_FILENAME:String="config//ServerDetails.xml";
		public static const PROMPT_SERVER_DROPDOWN:String="--Select server--";
		public static const COPY_RIGHT_FOOTER:String=getCopyrightFooter();
		public static const PROTOCOL_HTTPS:String = "https";
		public static const PROTOCOL_HTTP:String="http";
		
		//For Guest Login
		public static const GUEST_TYPE:String = "GUEST";

		applicationType::web {
			public static const guestLogin:String="guestLogin";
			public static const userLogin:String="userLogin";
			public static const classEntry:String="classEntry";
		}
		applicationType::DesktopMobile {
			public static function getAppVersion():String {
				var appXml:XML=NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace=appXml.namespace();
				var appVersion:String=appXml.ns::versionLabel[0];
				return appVersion;
			}
		}

		// ashwini: todo: find a suitable place for this function...this is not the correct place
		private static function getCopyrightFooter():String {
			applicationType::DesktopMobile {
				var version:String = getAppVersion();
			}
			applicationType::web{
				var version:String = MainApp.AVIEW_VERSION;
			}
			return "A-VIEW (Amrita Virtual Interactive E-Learning World) Version " + version + "; © 2007-2015";
		}
	}
}
