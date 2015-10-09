////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
//ashCR: TODO: need summary of file here
/**
 *
 * File			: HelpDownloadWindowHandler.as
 * Module		: Help
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Vinod
 * 
 * PNCR: Description
 */


/**
 * importing the flash library
 */
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;
/**
 * importing the mx library
 */
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

//KKCR: All function comments inside this file does not follow the common rule specified in the sample.as
/**
 * @protected
 * This function is invoked on click of window close and view PDF buttons
 * This closes the download help popup
 *
 * @return void
 */
protected function close():void
{
	PopUpManager.removePopUp(this);
}

/**
 * @protected
 * This function is invoked from the view PDF button click
 * This opens the downloaded help document file from 'My Documents'
 *
 * @param event type of Mouse event
 * @return void
 */

protected function openDocument(event:MouseEvent):void
{
	/**variable to store the downloaded file path**/
	var helpFilePath:String;
	/**Checking the OS for getting the path of downloaded file**/
	if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
	{
//		ashCR: TODO: is this code platform independent? If this code is ported to, for e.g. ios tomorrow, will it work? perhaps, file access should be a separate, common function that deals with the nuances of various platforms
		helpFilePath="file:///" + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.file.nativePath;
	}
	else
	{
		helpFilePath=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.file.nativePath;
	}
	/**
	* The downloaded PDF file will be opened in the default browser using the navigateToURL method
	* First parameter: path of the downloaded help file
	* Second parameter: browser tab in which the file will be opened, _self means on the same tab
	**/
	navigateToURL(new URLRequest(helpFilePath), "_self");
	close();
}
