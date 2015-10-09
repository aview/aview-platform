////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: AutoUpdate.as
 * Module		: AutoUpdate
 * Developer(s)	: Ajith Kumar R,Luis
 * Reviewer(s)	: Monisha,Remya T
 *
 *AutoUpdate.as is used to handle all auto updation related functionalities of A-VIEW.
 *This file has methods for comparing A-VIEW's version with the autoupdation server &
 *status,error handlers of NativeApplicationUpdater component.
 *
 */

import air.update.events.DownloadErrorEvent;
import air.update.events.StatusUpdateEvent;
import air.update.events.UpdateEvent;

import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;

import flash.events.ErrorEvent;
import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 * Platform specific imports
 */
applicationType::desktop
{
	import flash.filesystem.File;
}

use namespace mx_internal;

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
	//PNCR: lowerCamelCase
	btn_login.enabled=true;
	applicationType::desktop
	{
		killAkr();
		findJavaInstallationPath();
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
	//PNCR: function name is confusing.
	public function updaterUpdateStatusHandler(event:StatusUpdateEvent):void
	{
		if (event.available)
		{
			// In case update is available prevent default behavior of checkNow() function 
			// and switch to the view that gives the user ability to decide if he wants to
			// install new version of the application.
			Alert.show("An updated version of A-VIEW " + FlexGlobals.topLevelApplication.mainApp.updater.updateVersion + " is available.Please update to continue using \nA-VIEW.", "A-VIEW Update", Alert.OK, null, updateOkHandler);
			log.info("An updated version of A-VIEW " + FlexGlobals.topLevelApplication.mainApp.updater.updateVersion + " is available");
			btn_login.enabled=false;
			event.preventDefault();
		}
		else
		{
			btn_login.enabled=true;
			log.info("Your application is up to date!");
			//Terminating all running external processes associated with A-VIEW (previous session) before login.
			killAkr();
			findJavaInstallationPath();
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
}
