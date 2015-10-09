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
 * File			: PollingWindowUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * PollingWindowUIHandler.as file is the script handler for PollingWindow.mxml
 * This file contains all the popout functionalities.
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.polling.PollingWindowUIHandler.as");

/**
 * @public
 * Function : closePollingWindow
 * Handler for close event in this component.
 *
 *
 * @return void
 *
 */
public function closePollingWindow():void {
	try {
		applicationType::desktop {
			//close() method not available for web
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pollingMultipleWindow.close();
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pollingObj.stop();
	} 
	catch (e:Error) {
		if(Log.isError()) log.error("Error in closePollingWindow method:"+ e.getStackTrace());
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.polling_count=0;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pollingIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.poll_unclicked;
}


/**
 * @private
 * Function : creationCompleteHandler
 * Handler for creationComplete event in this component.
 *
 *
 * @return void
 *
 ***/
private function creationCompleteHandler():void {
	applicationType::desktop {
		//title property not available for web
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pollingMultipleWindow.title=" Polling (A-VIEW Classroom - " + ClassroomContext.aviewClass.className + " )";
	}
}

/**
 *
 * @private
 * Function : resizewindow
 * Handler for resize event in this component.
 *
 *
 * @return void
 *
 ***/
private function resizeWindow():void {
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.onResizePollingWindow();
}

