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
 * File		   : MeetingsListItemRenderer.mxml
 * Module	   : meeting
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) :
 *
 * This file contains the code for display the accept and reject images in the notifications.
 * Click on to this images will lead to accept and reject the invitations.
 *
 */
applicationType::DesktopWeb{
import edu.amrita.aview.common.vo.AViewResponseVO;
import edu.amrita.aview.contacts.ContactsView;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
import edu.amrita.aview.core.gclm.vo.LectureListVO;
import edu.amrita.aview.meeting.events.CommonEvent;

import flash.events.MouseEvent;

import mx.rpc.events.ResultEvent;

import spark.components.Image;

/**
 * Icon for accept the invitations
 */
[Bindable]
[Embed(source='assets/images/Accept.png')]
public var acceptIcon:Class;
/**
 * Accept icon assigning to a class.
 */
[Bindable]
public var acceptIconStatus:Class=acceptIcon;
/**
 * Icon for reject the invitations
 */
[Bindable]
[Embed(source='assets/images/Reject.png')]
public var rejectIcon:Class;
/**
 * Reject icon assigning to a class.
 */
[Bindable]
public var rejectIconStatus:Class=rejectIcon;

/**
 * Image for accept the invitation
 */
private var btnAccept:Image;

/**
 * Image for reject the invitation
 */
private var btnReject:Image;
/**
 * Variable for ClassRegistrationHelper
 */
private var classregHelper:ClassRegistrationHelper;
/**
 * Variable for LectureListVO
 */
private var lectureDetails:LectureListVO=new LectureListVO;
/**
 * Class for setting the status when user logs in but not in a meeting.
 */
private var meetingAcceptanceStatus:String="";
/**
 * Variable for MyContacts
 */
private var mycontacts:ContactsView=new ContactsView;

/**
 * @public
 * Set the status id in the class registration as 1 and update the class
 * registration with new class regisatrion vo.
 *
 * @param classReg of type ClassRegisterVO
 * @return void
 *
 */
public function getClassRegisterByIdResultHandler(classReg:ClassRegisterVO):void
{
	classReg.statusId=1;
	classregHelper=new ClassRegistrationHelper();
	classregHelper.updateClassRegistration(classReg, ClassroomContext.userVO.userId,updateClassRegistrationResultHandler);
}

/**
 * @public
 * Result handelr function of updateClassRegistration
 *
 * Dispatch an event with lecture id for clear the notification and refresh the meetingslist.
 * And then enter the meeting room.
 *
 * @param event of type ResultEvent
 * @return void
 *
 */
public function updateClassRegistrationResultHandler(event:ResultEvent):void
{
	this.owner.dispatchEvent(new CommonEvent("acceptinvitations", this.data.lectureId));
	//mycontacts.gotoMeeting(lectureDetails);
}

/**
 * @public
 * Click on the reject image will dispatch an event with
 * lecture id and thus clear the notification and refresh the meetingslist.
 *
 * @param event of type MouseEvent
 * @return void
 *
 */
public function rejectInvitation(event:MouseEvent):void
{
	this.owner.dispatchEvent(new CommonEvent("rejectinvitations", this.data.lectureId));
}

/**
 * @public
 * From lecture details retrieve the class registartion id and
 * using this class registartion id, retrieve the class registration.
 *
 * @param response of type AViewResponseVO
 * @return void
 *
 */
public function getClassRoomLectureByLectureIdResultHandler(response:AViewResponseVO):void
{
	lectureDetails=response.result as LectureListVO;
	var classregId:Number=lectureDetails.classRegistration.classRegisterId;
	classregHelper=new ClassRegistrationHelper();
	classregHelper.getClassRegistrationById(classregId,getClassRegisterByIdResultHandler);
}

/**
 * @private
 * Create images for accept and reject and assign images
 * and its height,width and tooltip.
 *
 *
 * @return void
 *
 */
private function onInit():void
{
	//add new images for accept and reject the invitations.
	btnAccept=new Image;
	btnAccept.source=acceptIconStatus;
	btnAccept.addEventListener(MouseEvent.CLICK, acceptInvitation);
	btnAccept.width=40;
	btnAccept.height=23;
	btnAccept.toolTip="Accept";
	
	btnReject=new Image;
	btnReject.source=rejectIconStatus;
	btnReject.addEventListener(MouseEvent.CLICK, rejectInvitation);
	btnReject.width=40;
	btnReject.height=23;
	btnReject.toolTip="Reject";
}

/**
 * @private
 * Add the accept and reject image on the container on mouse over of the notification.
 *
 *
 * @return void
 *
 */
private function onMouseOver():void
{
	buttonContainer.addElement(btnAccept);
	buttonContainer.addElement(btnReject);
}

/**
 * @private
 * Remove all elements on the rollout of notifications.
 *
 *
 * @return void
 *
 */
private function onRollOut():void
{
	buttonContainer.removeAllElements();
}

/**
 * @private
 * Click on accept image will retrieve the lecture by using lecture id in the data.
 *
 * @param event of type MouseEvent
 * @return void
 *
 */
private function acceptInvitation(event:MouseEvent):void
{
	//dispatch an event and move the code to its event listener
	var lectureid:Number=this.data.lectureId;
	var lectureHelper:LectureHelper=new LectureHelper;
	lectureHelper.getClassRoomLectureByLectureId(lectureid,getClassRoomLectureByLectureIdResultHandler);
}
}