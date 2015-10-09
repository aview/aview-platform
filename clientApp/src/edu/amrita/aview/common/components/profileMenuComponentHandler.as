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
 * File			: profileMenuComponentHandler.as
 * Module		: Common
 * Developer(s)	: Sivaram.S.K
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 *
 */
//MMCR:-Function description 
//VGCR:-File name UpperCamelCase

import edu.amrita.aview.core.entry.ClassroomContext;

import flash.utils.setTimeout;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

//VGCR:-variable Description
public var menuOpened:Boolean;
private var menuOpenTimout:uint;

/**
 * @public
 * for setting the flag value 
 *
 * @return void
 *
 */
public function init():void
{
	menuOpened=true;
}
/**
 * @protected
 *
 * @param event type FlexEvent
 * @return void
 *
 */
protected function component_creationCompleteHandler(event:FlexEvent):void
{
	menuOpenTimout=setTimeout(init, 100);
	/*if (ClassroomContext.aviewClass && ClassroomContext.aviewClass.classType == "Meeting")
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.profileMenu.menuExitClassroom.text="Exit Meeting";
	}*/
}
