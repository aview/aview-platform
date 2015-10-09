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
 *
 * File		   : InvitationMessage.mxml
 * Module	   : meeting
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) :
 *
 * This file contains the code for display the meeting invitation component.
 * This component contains the meeting name,moderatorname,accept button and reject button.
 * It also contains a ring to alert the online participants.
 *
 */
import edu.amrita.aview.meeting.MeetingInvitation;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

import mx.events.CloseEvent;
import mx.managers.PopUpManager;

/**
 * An event for meeting invitation.
 * That contains title,userId,lectureId,meetingName,moderatorName and userName
 */
[Bindable]
public var invitedMeeting:MeetingInvitation=new MeetingInvitation;

/**
 * Ring to alert the online, invited users.
 */
[Embed(source="assets/sounds/ring.mp3")]
[Bindable]
public var soundClass:Class;
/**
 * Varible for Sound.
 */
public var ringSound:Sound;
/**
 * Varible for SoundChannel.
 */
public var ringSoundChannel:SoundChannel;

/**
 * @public
 * Remove the invitation message component when accept or reject
 * Or after a short time of no action take place.
 *
 *
 * @return void
 *
 */
public function removeMe():void
{
	PopUpManager.removePopUp(this);
}

/**
 * @public
 * Stops the ringtone.
 *
 *
 * @return void
 *
 */
public function stopRing():void
{
	ringSoundChannel.stop();
}

/**
 * @private
 * Play the ring tone on init.
 * set focus on the accept button.
 * Retrieve the moderator name and set the invitation message.
 *
 *
 * @return void
 *
 */
private function initInvitation():void
{
	ringSound=new soundClass() as Sound;
	ringSoundChannel=ringSound.play();
	this.addEventListener(CloseEvent.CLOSE, closeInviteWindow);
	btnAccept.setFocus();
	var moderator:String=this.invitedMeeting.moderatorName;
	txtInvitationMsg.text='Meeting Invitation from ' + moderator + ' to the meeting : ' + this.invitedMeeting.title;
}

/**
 * @private
 * Close the invitation window.
 *
 * @param event of type Event
 * @return void
 *
 */
private function closeInviteWindow(event:Event):void
{
	PopUpManager.removePopUp(this);
}
