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
 * File			: QuickNotePopOutComponentHandler.as
 * Module		: QuickNote
 * Developer(s)	: Ajith Kumar R,Sivaram
 * Reviewer(s)	: Remya T
 *
 * QuickNotePopOutComponentHandler.as is used to handle resizing & closing of quicknote popout component.
 */

import flash.events.Event;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.quickNotes.QuickNotePopOutComponentHandler.as");

/**
 * @private
 * CreationComplete handler function for QuickNotePopOutComponent
 *
 *
 * @return void
 */
private function init():void
{
	applicationType::desktop
	{
		//CLOSING event is not available for web
		this.addEventListener(Event.CLOSING, closeHandler);
	}
}

/**
 * @private
 * Resize handler function for QuickNotePopOutComponent
 *
 *
 * @return void
 */
private function resizeHandler():void
{
	try
	{
		this.getChildByName("quickNoteVBox").width=this.width;
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in resizeHandler method"+ e.getStackTrace());
	}
}

/**
 * @private
 * Close handler function for QuickNotePopOutComponent
 *
 * @param event of type Event
 * @return void
 */
private function closeHandler(event:Event):void
{
	event.preventDefault();
	try
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.popOutWindow();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.quickNoteVBox.width=600;
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in closeHandler method"+ e.getStackTrace());
	}
}
