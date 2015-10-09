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
 * File			: UserSelectedCountHandler.as
 * Module		: Common
 * Developer(s)	: Ashish
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-add description for bindable variable
//VGCR:-add description for function
[Bindable]
private var userIntCount:String;

[Bindable]
private var toolTipData:String;

/**
 *@private 
 * 
 */
private function changeICon():void
{
	userIntCount=this.data.userInteractedCount.toString();
	toolTipData="Interaction Count : " + userIntCount;
}
