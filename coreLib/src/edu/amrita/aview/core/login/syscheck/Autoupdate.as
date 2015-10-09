package edu.amrita.aview.core.login.syscheck {
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.login.syscheck.worker.Java;
	import edu.amrita.aview.core.login.syscheck.worker.Utils;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class Autoupdate extends EventDispatcher{
		public function Autoupdate() {
			utils = new Utils;
			getUpdateServerIP= new HTTPService();
			log=Log.getLogger("aview.autoupdate");
			java = new Java;
		}

		/**
		 * Platform specific imports
		 */
		applicationType::desktop
		{
			import flash.filesystem.File;
			var updater:NativeApplicationUpdater=null;
		}
		
		use namespace mx_internal;
		public var getUpdateServerIP:HTTPService;
		public var log:ILogger;
		private var utils:Utils; 
		private var java:Java;

		
		/**
		 * ArrayCollection for storing the Updation Server details.
		 */
		[Bindable]
		private var updateSeverIPDetails:ArrayCollection=new ArrayCollection();
		/**
		 * Alert for showing the download progressing message.
		 */
		private var downloadInProgressMessage:Alert;
		
		/**
		 * @public
		 * The function for retrieving updation server IP from UpdationServer.xml.
		 *
		 *
		 * @return void
		 */
		public function getUpdateServerDetails():void
		{ 
			
			// Setting the details of updation server to HTTP service and  event listners are added
			if (Log.isDebug()) log.debug("Starting to read the UpdationServer.xml");
			getUpdateServerIP.url="config/UpdationServer.xml";
			getUpdateServerIP.send();
			getUpdateServerIP.addEventListener(ResultEvent.RESULT, updateSeverDetailsResultHandler);
			getUpdateServerIP.addEventListener(FaultEvent.FAULT, updateSeverDetailsFaultHandler);
		}
		
		/**
		 * @private
		 * This function is the result handler for getUpdateServerIP HTTP service.
		 *
		 * @param event of type ResultEvent.
		 * @return void
		 */
		private function updateSeverDetailsResultHandler(event:ResultEvent):void
		{ 
			
			applicationType::desktop
			{

				//For handling multiple update server IPs from the UpdationServer.xml file
				
				if (event.result.update_servers.server is ArrayCollection)
				{
					updateSeverIPDetails=event.result.update_servers.server;
					/* Setting the path for automatic updation checker.*/
					//PNCR: protocal constant to be moved to some global file  
					updater.updateURL="http://" + updateSeverIPDetails[0].ip.toString() + "/A-VIEW/update.xml";
					ClassroomContext.UPDATE_SERVER=updateSeverIPDetails[0].ip.toString();
				}
					//For handling single update server ips from the UpdationServer.xml file
				else
				{
					/* Setting the path for automatic updation checker.*/
					//PNCR: protocal constant to be moved to some global file  
					updater.updateURL="http://" + event.result.update_servers.server.ip.toString() + "/A-VIEW/update.xml";
					ClassroomContext.UPDATE_SERVER=event.result.update_servers.server.ip.toString();
				}
				if (Log.isInfo()) log.info("Updater server url is :" + updater.updateURL + ": Checking for updates...");
			}
			//Initialize NativeApplicationUpdater
			checkForOnlineUpdate();
		}
		
		/**
		 * @private
		 * This function is the fault event handler for getUpdateServerIP HTTP service.
		 *
		 * @param event of type FaultEvent.
		 * @return void
		 */
		private function updateSeverDetailsFaultHandler(event:FaultEvent):void
		{ 
			
			if(Log.isError()) log.error("entry::AutoUpdate::updateSeverDetailsFaultHandler:"+ AbstractHelper.getStaticFaultMessage(event));
			Alert.show("Sorry data cannot be retreived.\nProblem with Server", "Error");
		}
		
		/**
		 * @public
		 * This function is for comparing currently installed A-VIEW version with A-VIEW version in update server.
		 * If a greater value is found in updation server this function will return 'true' otherwise 'false'.
		 *
		 * @param currentVersion of type String.
		 * @param updateVersion of type String.
		 * @return Boolean
		 */
		public function isLatestVersionInstalled(currentVersion:String, updateVersion:String):Boolean
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
		 * @public
		 * This function is the error handler for NativeApplicationUpdater component.
		 *
		 * @param event of type ErrorEvent.
		 * @return void
		 */
		public function updaterErrorHandler(event:ErrorEvent):void
		{ 
			
			log.error("Error while checking for auto updates. Error details :" + event.text);
			_changeLoginBtnState(true);
			applicationType::desktop
			{
				utils.killAllAviewRelated();
				java.findJavaInstallationPath();
			}
		}
		
		/**
		 * @protected
		 * The function for initializing NativeApplicationUpdater component.
		 *
		 *
		 * @return void
		 */
		protected function checkForOnlineUpdate():void
		{ 
			
			if (Log.isDebug()) log.debug("Initializing the updator");
			applicationType::desktop
			{
				updater.initialize();
			}
		}
		
		applicationType::desktop
		{
			/**
			 * @public
			 * This function is the initialized event handler for NativeApplicationUpdater component.
			 * When NativeApplicationUpdater is initialized then call checkNow function.
			 *
			 * @param event of type UpdateEvent.
			 * @return void
			 */
			public function updaterInitializedHandler(event:UpdateEvent):void
			{
				// When NativeApplicationUpdater is initialized you can call checkNow function
				if (Log.isDebug()) log.debug("Checking for the updates");
				updater.checkNow();
			}
			
			/**
			 * @public
			 * This function is the updateStatus event handler for NativeApplicationUpdater component.
			 *
			 * @param event of type StatusUpdateEvent.
			 * @return void
			 */
			public function updaterUpdateStatusHandler(event:StatusUpdateEvent):void
			{
				if (event.available)
				{
					// In case update is available prevent default behavior of checkNow() function 
					// and switch to the view that gives the user ability to decide if he wants to
					// install new version of the application.
					Alert.show("An updated version of A-VIEW " + FlexGlobals.topLevelApplication.mainApp.updater.updateVersion + " is available.Please update to continue using \nA-VIEW.", "A-VIEW Update", Alert.OK, null, updateOkHandler);
					log.info("An updated version of A-VIEW " + FlexGlobals.topLevelApplication.mainApp.updater.updateVersion + " is available");
					_changeLoginBtnState(false);
					event.preventDefault();
				}
				else
				{
					_changeLoginBtnState(true);
					log.info("Your application is up to date!");
					//Terminating all running external processes associated with A-VIEW (previous session) before login.
					utils.killAllAviewRelated();
					java.findJavaInstallationPath();
				}
			}
		}
		
		/**
		 * @private
		 * This function is for initiating the update process.
		 *
		 * @param event of type Event.
		 * @return void
		 */
		private function updateOkHandler(event:Event):void
		{ 
			
			startUpdate();
		}
		
		/**
		 * @protected
		 * This function is for passing the silent install commands to the NativeApplicationUpdater component & initiate download process.
		 *
		 *
		 * @return void
		 */
		protected function startUpdate():void
		{ 
			
			// In case user wants to download and install update display download progress message
			// and invoke downloadUpdate() function.
			showDownladInProgressMessage("A-VIEW");
			applicationType::desktop
			{
				updater.commandLineArguments=new Vector.<String>();
				updater.commandLineArguments.push("/NOCANCEL", "/SILENT");
				updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updaterDownloadErrorHandler);
				updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updaterDownloadCompleteHandler);
				updater.downloadUpdate();
			}
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
		
		applicationType::desktop
		{
			/**
			 * @private
			 * This function is the DOWNLOAD_COMPLETE handler for NativeApplicationUpdater component.
			 *
			 * @param event of type UpdateEvent.
			 * @return void
			 */
			private function updaterDownloadCompleteHandler(event:UpdateEvent):void
			{
				// When update is downloaded install it.
				FlexGlobals.topLevelApplication.mainApp.updater.installUpdate("/NOCANCEL", "/SILENT", "/DIR=" + File.applicationDirectory.nativePath + "");
			}
			
			/**
			 * @private
			 * This function is the DOWNLOAD_ERROR handler for NativeApplicationUpdater component.
			 *
			 * @param event of type DownloadErrorEvent.
			 * @return void
			 */
			private function updaterDownloadErrorHandler(event:DownloadErrorEvent):void
			{
				Alert.show("Error downloading update file, try again later.", "A-VIEW Update", Alert.OK, null, closeAVIEW);
			}

			/**
			 * @private
			 * The function for closing A-VIEW application if the third party appliactions (JRE,Screencamera) are not installed properly.
			 *
			 * @param event of type Event
			 * @return void
			 */
			private function closeAVIEW(event:Event):void
			{
				// ashwini: todo: close the application
				var a = 1;
//				this.windowApp.nativeApplication.exit();
			}
			
			private function _changeLoginBtnState(state:Boolean):void{
				// ashwini : now this is a hack
				FlexGlobals.topLevelApplication.mainApp.btn_login.enabled = state;
//				btn_login.enabled = state;
			}

		}
		
	}
}
