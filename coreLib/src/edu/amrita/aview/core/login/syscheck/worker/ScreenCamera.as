package edu.amrita.aview.core.login.syscheck.worker {
	
	
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	applicationType::desktop{
		import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	}
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	
	public class ScreenCamera {
		
		public function ScreenCamera() {
		}
		applicationType::desktop{
			private var screenCameraUpdater:NativeApplicationUpdater;
		}
		private var downloadInProgressMessage:Alert;
		private var operatingSystemName:String=Capabilities.os.toLowerCase();
		applicationType::desktop{
			var updater:NativeApplicationUpdater=null;
		}

		/**
		 * @private
		 * This function is for initializing automatic updater for ScreenCamera.
		 *
		 * @param event of type CloseEvent.
		 * @return void
		 */
		private function downloadScreenCameraHandler(event:CloseEvent):void {
			if (event.detail == Alert.YES) {
				applicationType::desktop{
					screenCameraUpdater=new NativeApplicationUpdater();
					screenCameraUpdater.isNewerVersionFunction=_deletemeLatestVersionInstalled;
					screenCameraUpdater.addEventListener(UpdateEvent.INITIALIZED, screenCameraUpdaterInitializedHandler);
					screenCameraUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, screenCameraUpdaterUpdateStatusHandler);
					//PNCR: protocol constant to be moved to some global file  
					screenCameraUpdater.updateURL="http://" + ClassroomContext.UPDATE_SERVER + "/SCREENCAMERA/update.xml";
					screenCameraUpdater.initialize();
				}
			}
		}
		
		/**
		 * ashwini: TODO: delete this function once Autoupdate is refactored!!!!
		 * This is a temporary hack
		 */
		
		public function _deletemeLatestVersionInstalled(currentVersion:String, updateVersion:String):Boolean
		{ 
			
			//PNCR: actionscript already has a comparison operator ObjectUtil.compare(a, b, 0) please check that.
			
			//Split CurrentVersion number (eg: 1.5.10) into three parts and store in array for comparison
			var currentVersionDetails:Array=currentVersion.split(".");
			//Split UpdateVersion  number (eg: 1.6.0) into three parts and store in array for comparison
			var updateVersionDetails:Array=updateVersion.split(".");
			//If three parts (eg: 1,5,10) of both CurrentVersion & UpdateVersion are same return 'false'
			if ((parseInt(updateVersionDetails[0]) == parseInt(currentVersionDetails[0])) && (parseInt(updateVersionDetails[1]) == parseInt(currentVersionDetails[1])) && (parseInt(updateVersionDetails[2]) == parseInt(currentVersionDetails[2])))
			{
				return false;
			}
			//eg:  UpdateVersion=2.0.0 & CurrentVersion=1.5.10 
			if (parseInt(updateVersionDetails[0]) > parseInt(currentVersionDetails[0]))
			{
				return true;
			}
			//eg:  UpdateVersion=1.6.10 & CurrentVersion=1.5.11 
			if ((parseInt(updateVersionDetails[1]) > parseInt(currentVersionDetails[1])) && parseInt(updateVersionDetails[0]) == parseInt(currentVersionDetails[0]))
			{
				return true;
			}
			//eg:  UpdateVersion=1.5.12 & CurrentVersion=1.5.11 
			if ((parseInt(updateVersionDetails[2]) > parseInt(currentVersionDetails[2])) && (parseInt(updateVersionDetails[1]) == parseInt(currentVersionDetails[1])) && (parseInt(updateVersionDetails[0]) == parseInt(currentVersionDetails[0])))
			{
				return true;
			}
			
			return false;
		}

		/**
		 * @protected
		 * This function is the INITIALIZED event handler for screenCameraUpdater.
		 *
		 * @param event of type UpdateEvent.
		 * @return void
		 */
		protected function screenCameraUpdaterInitializedHandler(event:UpdateEvent):void {
			// When NativeApplicationUpdater is initialized you can call checkNow function	
			applicationType::desktop{
				screenCameraUpdater.checkNow();
			}
		}

		/**
		 * @protected
		 * This function is the UPDATE_STATUS event handler for screenCameraUpdater.
		 *
		 * @param event of type StatusUpdateEvent.
		 * @return void
		 */
		protected function screenCameraUpdaterUpdateStatusHandler(event:StatusUpdateEvent):void {
			startScreenCameraUpdate();
			event.preventDefault();
		}
		/**
		 * @private
		 * This function is for showing the download progressing message.
		 *
		 * @param appName of type String.
		 * @return void
		 */
		private function showDownladInProgressMessage(appName:String):void
		{ 
			
			applicationType::desktop
			{
				if (appName == "A-VIEW")
				{
					downloadInProgressMessage=Alert.show(appName + " " + updater.updateVersion + " is getting downloaded.", appName + " Update");
				}
				else
				{
					downloadInProgressMessage=Alert.show(appName + " is getting downloaded.", appName + " Update");
				}
			}
			//Remove 'OK' button from the alert.
			downloadInProgressMessage.mx_internal::alertForm.removeChild(downloadInProgressMessage.mx_internal::alertForm.mx_internal::buttons[0]);
		}

		/**
		 * @protected
		 * This function is for passing the silent install commands to the screenCameraUpdater & initiate download process.
		 *
		 *
		 * @return void
		 */
		protected function startScreenCameraUpdate():void {
			applicationType::desktop{
				showDownladInProgressMessage("ScreenCamera");
				screenCameraUpdater.commandLineArguments=new Vector.<String>();
				screenCameraUpdater.commandLineArguments.push("/SILENT");
				screenCameraUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, screenCameraUpdaterDownloadErrorHandler);
				screenCameraUpdater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, screenCameraUpdaterDownloadCompleteHandler);
				screenCameraUpdater.downloadUpdate();
			}
		}

		/**
		 * @private
		 * This function is the DOWNLOAD_COMPLETE event handler for screenCameraUpdater.
		 *
		 * @param event of type UpdateEvent.
		 * @return void
		 */
		private function screenCameraUpdaterDownloadCompleteHandler(event:UpdateEvent):void {
			applicationType::desktop{
				// When update is downloaded install it.
				screenCameraUpdater.installUpdate("/SILENT", "/SLNAME='Amrita E-Learning Initiatives'", "/SLKEY='AMRITA-E-LEARNING-8B1A4759-4158-4998-9B48-0B24068C2981'" + "");
			}	
		}

		/**
		 * @private
		 * This function is the DOWNLOAD_ERROR event handler for screenCameraUpdater.
		 *
		 * @param event of type DownloadErrorEvent.
		 * @return void
		 */
		private function screenCameraUpdaterDownloadErrorHandler(event:DownloadErrorEvent):void {
			Alert.show("Error downloading update file, try again later.", "ScreenCamera Update");
		}

		// ashwini : todo: this is wrong. this array gets populated somewhere
		public var thirdPartySoftwareDetails:Array=new Array();

		/**
		 * @public
		 * The function for finding whether ScreenCamera is installed or not in Windows operating systems.
		 *
		 *
		 * @return void
		 */
		public function findScreenCameraInstallationPath():void {
			var scrCam:File;
			if (operatingSystemName.indexOf('win') > -1 && thirdPartySoftwareDetails.length > 0) {
				if (thirdPartySoftwareDetails[1] != "NF") {
					var replacePattern:RegExp=/\\/g;
					thirdPartySoftwareDetails[1].replace(replacePattern, "/");
					scrCam=new File(thirdPartySoftwareDetails[1] + '/ScrCam.exe');
					if (!scrCam.exists) {
						//Parameters of the alert in order: message text,tile,type of button(eg: 3=YES&NO),parent component,close handler function.
//						Alert.show("Please install ScreenCamera and relogin to the application to start your video." + "Click 'Yes'" +
//							" to download and install Screencamera.", "WARNING", 3, this, downloadScreenCameraHandler);
						// ashwini: todo: do not know how to fix this, or get a parent handler instead of this...setting it to null
						Alert.show("Please install ScreenCamera and relogin to the application to start your video." + "Click 'Yes'" +
							" to download and install Screencamera.", "WARNING", 3, null, downloadScreenCameraHandler);
					} else {
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.writeScreenCamFile(thirdPartySoftwareDetails[1]);
					}
				} else {
//					Alert.show("Please install ScreenCamera and relogin to the application to start your video." + "Click 'Yes' " +
//						"to download and install Screencamera.", "WARNING", 3, this, downloadScreenCameraHandler);
					// ashwini: todo: do not know how to fix this, or get a parent handler instead of this...setting it to null
					Alert.show("Please install ScreenCamera and relogin to the application to start your video." + "Click 'Yes' " +
						"to download and install Screencamera.", "WARNING", 3, null, downloadScreenCameraHandler);
				}
			}
		}

	}
}
