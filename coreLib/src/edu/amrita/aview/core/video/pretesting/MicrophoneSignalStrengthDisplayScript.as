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
 * File			: MicrophoneSignalStrengthDisplayScript.as
 * Module		: Video
 * Developer(s)	: Ashish
 * Reviewer(s)	: Narayanasamy S
 *
 * File contains all the functionalities related with displaying the stream signal strength.
 *
 */


import flash.events.Event;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import mx.binding.utils.ChangeWatcher;
import mx.core.FlexGlobals;

/**
 * Holding the current value of microphone activity level.
 * DEFAULT value is 0, while starting the display level all the display indicator should be white.
 */
[Bindable]
public var micSignalLevel:int=0;

/**
 * Timeout for resetting the signal indicators level.
 */
private var uintResetSignalDisplay:uint;

/**
 * Change watcher for monitoring any changes occuring for 'micSignalLevel' variable.
 */
private var signalLevelChangeWatcher:ChangeWatcher;

/**
 *
 * @public
 * Function for initializing the timeout for resetting the signal display and registering the change
 * watcher for 'micSignalLevel' variable.
 *
 * @param void
 * @return void
 *
***/
public function initMicDisplayLevel():void
{
	uintResetSignalDisplay=setInterval(canvasBackground, 800);
	signalLevelChangeWatcher=ChangeWatcher.watch(this, "micSignalLevel", watchMicLevel);
}

/**
 *
 * @public
 * Function for removing the timeout for resetting the signal display and unregistering the change
 * watcher for 'micSignalLevel' variable.
 *
 * @param void
 * @return void
 *
 ***/
public function removeMicDisplaylevel():void
{
	clearInterval(uintResetSignalDisplay);
	if (signalLevelChangeWatcher)
		signalLevelChangeWatcher.unwatch();
}

/**
 *
 * @public
 * Function for setting white backgorund for display level indicators.
 *
 * @param void
 * @return void
 *
 ***/
public function canvasBackground():void
{
	cnvs10.setStyle("backgroundColor", "#FFFFFF");
	cnvs20.setStyle("backgroundColor", "#FFFFFF");
	cnvs30.setStyle("backgroundColor", "#FFFFFF");
	cnvs40.setStyle("backgroundColor", "#FFFFFF");
	cnvs50.setStyle("backgroundColor", "#FFFFFF");
	cnvs60.setStyle("backgroundColor", "#FFFFFF");
	cnvs70.setStyle("backgroundColor", "#FFFFFF");
	cnvs80.setStyle("backgroundColor", "#FFFFFF");
	cnvs90.setStyle("backgroundColor", "#FFFFFF");
	cnvs100.setStyle("backgroundColor", "#FFFFFF");
}

/**
 *
 * @private
 * Function for setting backgorund colour for canvas for indicating the microphone activity level
 * based on 'micSignalLevel' variable.
 *
 * @param ev of type event
 * @return void
 *
 ***/
private function watchMicLevel(ev:Event):void
{
	// No need of showing the signal strength if microphone level is less than 20
	if (micSignalLevel > 0 && micSignalLevel < 20)
	{
	}
	// Need to change first 3 canvas background 
	else if (micSignalLevel >= 20 && micSignalLevel < 30)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 4 canvas background 
	else if (micSignalLevel >= 30 && micSignalLevel < 40)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 5 canvas background 
	else if (micSignalLevel >= 40 && micSignalLevel < 50)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
		cnvs50.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 6 canvas background 
	else if (micSignalLevel >= 50 && micSignalLevel < 60)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
		cnvs50.setStyle("backgroundColor", "#E6C3C3");
		cnvs60.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 7 canvas background 
	else if (micSignalLevel >= 60 && micSignalLevel < 70)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
		cnvs50.setStyle("backgroundColor", "#E6C3C3");
		cnvs60.setStyle("backgroundColor", "#E6C3C3");
		cnvs70.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 8 canvas background 
	else if (micSignalLevel >= 70 && micSignalLevel < 80)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
		cnvs50.setStyle("backgroundColor", "#E6C3C3");
		cnvs60.setStyle("backgroundColor", "#E6C3C3");
		cnvs70.setStyle("backgroundColor", "#E6C3C3");
		cnvs80.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 9 canvas background 
	else if (micSignalLevel >= 80 && micSignalLevel < 90)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
		cnvs50.setStyle("backgroundColor", "#E6C3C3");
		cnvs60.setStyle("backgroundColor", "#E6C3C3");
		cnvs70.setStyle("backgroundColor", "#E6C3C3");
		cnvs80.setStyle("backgroundColor", "#E6C3C3");
		cnvs90.setStyle("backgroundColor", "#E6C3C3");
	}
	// Need to change first 10 canvas background 
	else if (micSignalLevel >= 90 && micSignalLevel <= 100)
	{
		cnvs10.setStyle("backgroundColor", "#E6C3C3");
		cnvs20.setStyle("backgroundColor", "#E6C3C3");
		cnvs30.setStyle("backgroundColor", "#E6C3C3");
		cnvs40.setStyle("backgroundColor", "#E6C3C3");
		cnvs50.setStyle("backgroundColor", "#E6C3C3");
		cnvs60.setStyle("backgroundColor", "#E6C3C3");
		cnvs70.setStyle("backgroundColor", "#E6C3C3");
		cnvs80.setStyle("backgroundColor", "#E6C3C3");
		cnvs90.setStyle("backgroundColor", "#E6C3C3");
		cnvs100.setStyle("backgroundColor", "#E6C3C3");
	}

}
