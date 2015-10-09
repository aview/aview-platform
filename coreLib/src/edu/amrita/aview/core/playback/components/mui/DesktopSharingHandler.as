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
 * File			: DesktopSharingHandler.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)	: Remya T
 *
 * DesktopSharingHandler.as Class is used for desktopsharing playback functionality
 *
 */
import mx.events.CloseEvent;
/**
 * To check wheather the desktop sharing play back window is minimized or not
 * @default false means not minimized
 */
public var isMinimize:Boolean=false;
/**
 * Icon class for maximize button
 */
private var maximizeIcon:Class;
[Bindable]
/**
 *The default postion of Desktop sharing window
 */
public var defaultPosition:Number;

/**
 * @protected
 * This function will invoked while the user try to close
 * desktopsharing playback window.
 *
 * @param event of CloseEvent
 * @return void
 *
 */
protected function closeHandler(event:CloseEvent):void
{
	// TODO Auto-generated method stub
	if (!isMinimize)
	{
		
		dektopMinmize.play([this, desktopPlayerContainer], false);
		isMinimize=true;
		retainPos.play([this], false);
		this.isPopUp=false;
	}
	else
	{
		
		dektopMaxmize.play([this, desktopPlayerContainer], false)
		isMinimize=false;
		this.isPopUp=true;
	}
}
