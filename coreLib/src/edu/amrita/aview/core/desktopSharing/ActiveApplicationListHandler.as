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
 * File			: ActiveApplicationListHandler.as
 * Module		: DesktopSharing
 * Developer(s)	: Ajith Kumar R
 * Reviewer(s)	: Meena S
 *
 * ActiveApplicationListHandler.as is used to handle functionalities related to ActiveApplicationList custom component.
 *
 */

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

/**
 * @private
 * The function for creating the ActiveApplicationList popup.
 *
 * @return void
 */
private function init():void{
	
}

/**
 * @private
 * The function for initiating application sharing.
 *
 * @return void
 */
public function selectApp(event:*= null):void{
	//If application is selected for sharing,then start sharing.
	//Fix for issue #15405
	if (appList.selectedIndex != -1) 
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callDesktopSharing();
	}
}

/**
 * @private
 * CloseEvent handler function for ActiveApplicationList popup.
 *
 * @param event of type CloseEvent
 * @return void
 */
private function titleWindowCloseHandler(event:CloseEvent):void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopApplicationSharing();
}