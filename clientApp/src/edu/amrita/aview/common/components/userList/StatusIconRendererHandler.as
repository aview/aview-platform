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
 * File			: StatusIconRendererHandler.as
 * Module		: Common
 * Developer(s)	: Ravi Sankar
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 */
//VGCR:-description for bindable variable
//VGCR:-Description for function
import edu.amrita.aview.core.entry.Constants;

import mx.core.FlexGlobals;

[Bindable]
private var status_icon_source:Class;

[Bindable]
[Embed(source="assets/images/PTT_status_talk.png")]
public var mic_Talk_Icon:Class;

[Bindable]
[Embed(source="assets/images/PTT_status_mute.png")]
public var mic_Mute_Icon:Class;

[Bindable]
[Embed(source="assets/images/handRaiseWaitingStatus.png")]
public var ask_Question_Req:Class;

[Bindable]
[Embed(source="assets/images/presenterControlRequestStatus.png")]
public var presenter_Req:Class;

/**
 * @private
 * 
 */
private function changeICon():void
{
	// AKCR: please use a switch statement here. It would be faster and lot more readable
	if (this.data.userStatus == Constants.ACCEPT && this.data.userTalkStatus == Constants.FREETALK)
	{
		status_icon_source=mic_Talk_Icon;
	}
	else if (this.data.userStatus == Constants.ACCEPT)
	{
		if (this.data.id == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getAudioMuteSOValue())
			status_icon_source=mic_Talk_Icon;
		else
			status_icon_source=mic_Mute_Icon;
	}
	else if (this.data.userStatus == Constants.WAITING)
	{
		status_icon_source=ask_Question_Req;
	}
	else if (this.data.controlStatus == Constants.PRSNTR_REQUEST)
	{
		status_icon_source=presenter_Req;
	}
	else
	{
		status_icon_source=null;
	}
}
