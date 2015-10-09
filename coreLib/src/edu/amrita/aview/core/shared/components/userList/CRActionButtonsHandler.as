
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
 * File			: CRActionButtonsHandler.as
 * Module		: Common
 * Developer(s)	: Ravi Sankar
 * Reviewer(s)	: Veena Gopal K.V
 * 
 */
//VGCR:-add description for bindable variable
//VGCR:-Description For variable
//VGCR:-add function description for all functions
import objectResolver.EntryFac;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.entry.ClassroomComponent;
	import edu.amrita.aview.core.shared.components.userList.PTTBox;
	import edu.amrita.aview.core.shared.components.userList.UserList;
}
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
import edu.amrita.aview.core.entry.events.SessionStatusEvent;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.desktopSharing.SharingMode;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import spark.components.Button;
import edu.amrita.aview.core.entry.AVCEnvironment;
import flash.display.DisplayObject;
import mx.modules.Module;
import mx.controls.Button;
import edu.amrita.aview.core.documentSharing.DocComponent;
import flash.utils.setTimeout;

applicationType::mobile{
	import edu.amrita.aview.core.entry.MainMobileApplication;
	import edu.amrita.aview.core.shared.components.userList.MobileUserList;
}

[Bindable]
public var pttCheckBoxState:Boolean=false;
[Bindable]
public var breakSessionButtonEnabledState:Boolean=true;
public var entryFac:EntryFac = new EntryFac;
applicationType::DesktopWeb{
	[Bindable]
	public var breakSessionObj = entryFac.breakSessionMessage();
}
applicationType::mobile{
	[Bindable]
	public var breakSessionObj:*  = null;
	[Bindable]
	public var isBtnHandRaiseReleaseVisible:Boolean = false;
}

applicationType::DesktopWeb{
	private var classRoomComp:ClassroomComponent;
	private var lstUsers:UserList;
	private var adminPTTButtons:PTTBox;
}
applicationType::mobile{
	private var classRoomComp:MainMobileApplication;
	private var lstUsers:MobileUserList;	
}


/**
 * Variables used for setting user action buttons
 */
public var viewcam:Boolean;
public var handraise:Boolean;
public var presenter:Boolean;
public var prsntrReq:Boolean;
[Bindable]
public var isMUISelected:Boolean=false;

private var classRoomModuleRO:ModuleRO = null;

/**
 * @protected 
 * @param event of type FlexEvent
 * 
 */
protected function hbox1_creationCompleteHandler(event:FlexEvent):void
{
	applicationType::DesktopWeb{
		adminPTTButtons = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pttBox;
		this.addChild(adminPTTButtons);
		adminPTTButtons.init(this);
	}
}

/**
 * @public 
 * @param classRoomComp of type ClassroomComponent
 * @param lstUsers of type UserList
 * 
 */
applicationType::DesktopWeb{
	public function init(classRoomComp:ClassroomComponent,lstUsers:UserList,mro:ModuleRO):void
	{
		this.classRoomComp = classRoomComp;
		this.lstUsers = lstUsers;
		this.classRoomModuleRO = mro;
		this.breakSessionObj.setModuleRO(this.classRoomModuleRO);
		setupEvents();
	}
}
applicationType::mobile{
	public function init(classRoomComp:MainMobileApplication,lstUsers:MobileUserList,mro:ModuleRO):void
	{
		breakSessionObj = entryFac.breakSessionMessage();
		this.classRoomComp = classRoomComp;
		this.lstUsers = lstUsers;
		this.classRoomModuleRO = mro;
		this.breakSessionObj.setModuleRO(this.classRoomModuleRO);
		setupEvents();
	}
}
private function setupEvents():void{
	//CRASH: API : done
	classRoomModuleRO.moduleEventMap.registerMapListener(EntryFac.BREAK_SESSION_ENDED_TYPE,onBreakSessionEndedEvent);
	classRoomModuleRO.moduleEventMap.registerMapListener(EntryFac.BREAK_SESSION_STARTED_TYPE,onBreakSessionStartedEvent);

	classRoomModuleRO.moduleEventMap.registerMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
	classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
	classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
}

private function cleanup(event:Event = null):void{
	clearEvents();
}

public function clearEvents():void{
	//CRASH: API done

	classRoomModuleRO.moduleEventMap.unregisterMapListener(EntryFac.BREAK_SESSION_ENDED_TYPE,onBreakSessionEndedEvent);
	classRoomModuleRO.moduleEventMap.unregisterMapListener(EntryFac.BREAK_SESSION_STARTED_TYPE,onBreakSessionStartedEvent);

	classRoomModuleRO.moduleEventMap.unregisterMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
	classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
	classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
}

//CRASH: API : done; since the passed event is not being used, I changed the event type from BreakSessionEvent to Event Type
// package will take care of this change.
//private function onBreakSessionEndedEvent(event:BreakSessionEvent):void{
private function onBreakSessionEndedEvent(event:Event):void{
	breakSessionButtonEnabledState=true;
	breakSessionButton.toolTip=Constants.BREAK_ENABLE_TOOLTIP;
	applicationType::mobile{
		FlexGlobals.topLevelApplication.mainApp.questionComp.enableQuestionInteraction(true,null,null);
	}
}
//CRASH: API : done; since the passed event is not being used, I changed the event type from BreakSessionEvent to Event Type
//private function onBreakSessionStartedEvent(event:BreakSessionEvent):void{
private function onBreakSessionStartedEvent(event:Event):void{
	breakSessionButtonEnabledState=false;
	breakSessionButton.toolTip=Constants.BREAK_DISABLE_TOOLTIP;
}

/**
 *@public 
 *This method is called when the tabs are navigated or role is changed.
 */
public function setupUserActionButtons():void
{
	/**First we have to remove all buttons */
	
	removeAccept();
	removeRelease();
	
	removeViewCam();
	removeCloseViewCam();
	
	removeHandraise();
	removeReleaseHandraise();
	
	removeMakePresenter();
	removeTakeControl();
	
	removeRequestPresenter();
	removeReleaseRequestPresenter();
	
	removePTT();
	removeMUI();
	removeBrkSessBtn();
	removeAddPeopleBtn();
	applicationType::DesktopWeb{
		classRoomComp.classroomComponentSgl.classRmActions.height=35;
		classRoomComp.classroomComponentSgl.leftPanelTabNav.percentHeight=87;
	}
	/**user based buttons (accept,view video,close video & make presenter) are not dealt with here*/
	if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
	{
	if (ClassroomContext.isModerator)
	{
		applicationType::DesktopWeb{
			classRoomComp.classroomComponentSgl.classRmActions.height=70;
		}
		addPTT();
		addMUI();
		addBrkSessBtn();
		applicationType::DesktopWeb{
			if(ClassroomContext.aviewClass.classType=="Meeting")
			{
				addAddPeopleBtn();
			}
			
			
			//addAddPeopleBtn();
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				/**Only if the selected viewer is currently there, then have the release button.*/
				if (lstUsers.userGrid.selectedItem != null && classRoomComp.isAcceptedStudent(lstUsers.userGrid.selectedItem.id))
				{
					setupAcceptRelease(false);
				}
			}
			else /** MODERATOR as VIEWER and NOT the PRESENTER role */
			{
				classRoomComp.classroomComponentSgl.leftPanelTabNav.percentHeight=80;
				setupHandraise();
				presenter=false;
				setupMakeTakeControlPresenter();
			}
		}
		applicationType::mobile{
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				//Only if the selected viewer is currently there, then have the release button.
				if (lstUsers.selectedItem != null && classRoomComp.isAcceptedStudent(lstUsers.selectedItem.id)){
					setupAcceptRelease(false);
				}
			}else{
				setupHandraise();
				presenter = false;
				setupMakeTakeControlPresenter();
			}
		}
	}
	else
	{

		if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) /** non moderator in a PRESENTER role */
		{
			applicationType::DesktopWeb{
				classRoomComp.classroomComponentSgl.classRmActions.height=70;
			}
			
			addPTT();
			addBrkSessBtn();
			addMUI();
			/**When the non moderator gets a presenter control, the takeControl button should appear*/
			setupPresenterRequest();
			
			releasePrsntrRequestButton.toolTip=Constants.PRESENTER_CNCL;
			/**Only if the selected viewer is currently there, then have the release button.*/
			applicationType::DesktopWeb{
				if (lstUsers.userGrid.selectedItem != null && classRoomComp.isAcceptedStudent(lstUsers.userGrid.selectedItem.id))
				{
					setupAcceptRelease(false);
				}
			}
			applicationType::mobile{
				if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE){
					setupPresenterRequest();
				}
			}
		}
		else /** all VIEWER's */
		{
			setupHandraise();
			//Fix for issue #15072
			if(breakSessionObj.isPopUp)
			{
				breakSessionObj.cancelSessionBreakOnPresenterRoleChange();
			}
			applicationType::desktop{
				//Fix for issue #15409
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpSharingMode.infoAlert!=null)
				{
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpSharingMode.infoAlert.isPopUp)
					{
						PopUpManager.removePopUp(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpSharingMode.infoAlert);
					}
				}
			}
			if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
			{
				setupPresenterRequest();
			}
			releasePrsntrRequestButton.toolTip="Release the Presenter Request";
		}
	}
}
	applicationType::DesktopWeb{
		if (lstUsers.userGrid.selectedItem != null){
			setupUserActionButtonsOnSelection();
		}
	}
	applicationType::mobile{
		if(lstUsers.selectedItem!=null){
			setupUserActionButtonsOnSelection();
		}
	}
}



/**
 * @public
 * Function changes the status of Buttons on PRESENTER side userlist based on the clicked user's status.
 *
 */
public function setupUserActionButtonsOnSelection():void
{
	/**The user action button are visible across all the tabs - Users, Chat, Viewer, Question */
	/*	if(tab1.selectedIndex != 0)
	{
	return;
	}*/
	
	removeAccept();
	removeRelease();
	removeViewCam();
	removeCloseViewCam();
	removeMakePresenter();
	applicationType::DesktopWeb{
		if (lstUsers.userGrid.selectedItem != null && lstUsers.userGrid.selectedItem.id != ClassroomContext.userVO.userName)
		{
			/**
			Moderator:
			Remove Make Presenter/Take Control buttons
			Depending on selected viewer is presenter or not, take/give control
			
			Presenter:
			First remove all the user based buttons
			If User is in Accept -> acceptRelease (false)
			Else
			-> acceptRelease(true)
			If user is in VIEW -> setupView(false)
			Else -> setupView(true)
			*/
	
			// AKCR: please combine these 3 IF statements
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
			if (ClassroomContext.isModerator)
			{
				if (classRoomComp.getUserSO(lstUsers.userGrid.selectedItem.id).userStatus != Constants.ACCEPT)
				{
					/**If moderator is a presenter also, then he can pass on the presenter control to any other user who is not currently selected for student interaction.*/
					if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
					{
						presenter=true;
						setupMakeTakeControlPresenter();
					}
				}
			}
			
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				if (classRoomComp.getUserSO(lstUsers.userGrid.selectedItem.id).userStatus == Constants.ACCEPT)
				{
					setupAcceptRelease(false);
				}
				else
				{
					setupAcceptRelease(true);
	
					// AKCR: please use conditional operator for the below; for e.g:
	//AKCR:			viewcam = (classRoomComp.viewVideoStatus(lstUsers.userGrid.selectedItem.id)? true : false;
	//AKCR:			setupViewCam();
					if (classRoomComp.viewVideoStatus(lstUsers.userGrid.selectedItem.id) == true)
					{
						viewcam=false;
						setupViewCam();
					}
					else if (classRoomComp.viewVideoStatus(lstUsers.userGrid.selectedItem.id) == false)
					{
						viewcam=true;
						setupViewCam();
					}
				}
			}
			}
			else if(ClassroomContext.userVO.role==Constants.MONITOR_TYPE)
			{
				if (classRoomComp.viewVideoStatus(lstUsers.userGrid.selectedItem.id) == true)
				{
					viewcam=false;
					setupViewCam();
				}
				else if (classRoomComp.viewVideoStatus(lstUsers.userGrid.selectedItem.id) == false)
				{
					viewcam=true;
					setupViewCam();
				}
			}
		}
	}
	applicationType::mobile{
		trace("ClassroomContext.userVO.userName : " +ClassroomContext.userVO.userName);
		if (lstUsers.selectedItem != null && lstUsers.selectedItem.id != ClassroomContext.userVO.userName)
		{
			/**
			 Moderator:
			 Remove Make Presenter/Take Control buttons
			 Depending on selected viewer is presenter or not, take/give control
			 
			 Presenter:
			 First remove all the user based buttons
			 If User is in Accept -> acceptRelease (false)
			 Else
			 -> acceptRelease(true)
			 If user is in VIEW -> setupView(false)
			 Else -> setupView(true)
			 */
			
			// AKCR: please combine these 3 IF statements
			if (ClassroomContext.isModerator)
			{
				if (classRoomComp.getUserSO(lstUsers.selectedItem.id).userStatus != Constants.ACCEPT)
				{
					/**If moderator is a presenter also, then he can pass on the presenter control to any other user who is not currently selected for student interaction.*/
					if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
					{
						presenter=true;
						setupMakeTakeControlPresenter();
					}
				}
				//To change the visibilty of private change button based on the usertype
				if(classRoomComp.getUserSO(lstUsers.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER){
					if(classRoomComp.getUserSO(lstUsers.selectedItem.id).userRole == Constants.VIEWER_ROLE){
						btnPrivateChat.includeInLayout = true;
						btnPrivateChat.visible = true;
					}else if(classRoomComp.getUserSO(lstUsers.selectedItem.id).userRole == Constants.PRESENTER_ROLE){
						btnPrivateChat.includeInLayout = false;
						btnPrivateChat.visible = false;
					}
				}else{
					btnPrivateChat.includeInLayout = false;
					btnPrivateChat.visible = false;
				}
			}
			
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				if (classRoomComp.getUserSO(lstUsers.selectedItem.id).userStatus == Constants.ACCEPT)
				{
					setupAcceptRelease(false);
				}
				else
				{
					setupAcceptRelease(true);
					
					// AKCR: please use conditional operator for the below; for e.g:
					//AKCR:			viewcam = (classRoomComp.viewVideoStatus(lstUsers.userGrid.selectedItem.id)? true : false;
					//AKCR:			setupViewCam();
					if (classRoomComp.viewVideoStatus(lstUsers.selectedItem.id) == true)
					{
						viewcam=false;
						setupViewCam();
					}
					else if (classRoomComp.viewVideoStatus(lstUsers.selectedItem.id) == false)
					{
						viewcam=true;
						setupViewCam();
					}
				}
				//To change the visibilty of private change button based on the usertype
				if(classRoomComp.getUserSO(lstUsers.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER){
					if(classRoomComp.getUserSO(lstUsers.selectedItem.id).isModerator){
						btnPrivateChat.includeInLayout = true;
						btnPrivateChat.visible = true;
					}else if(classRoomComp.getUserSO(lstUsers.selectedItem.id).userRole == Constants.VIEWER_ROLE){
						btnPrivateChat.includeInLayout = true;
						btnPrivateChat.visible = true;
					}
				}else{
					btnPrivateChat.includeInLayout = false;
					btnPrivateChat.visible = false;
				}
			}
			//To change the visibilty of private change button based on the usertype
			if(classRoomComp.classroomContextObj.userRole == Constants.VIEWER_ROLE){
				if(classRoomComp.getUserSO(lstUsers.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER){
					if(classRoomComp.getUserSO(lstUsers.selectedItem.id).isModerator){
						btnPrivateChat.includeInLayout = true;
						btnPrivateChat.visible = true;
					}else if(classRoomComp.getUserSO(lstUsers.selectedItem.id).userRole == Constants.PRESENTER_ROLE){
						btnPrivateChat.includeInLayout = true;
						btnPrivateChat.visible = true;
					}else if(classRoomComp.getUserSO(lstUsers.selectedItem.id).userRole == Constants.VIEWER_ROLE){
						btnPrivateChat.includeInLayout = false;
						btnPrivateChat.visible = false;
					}
				}else{
					btnPrivateChat.includeInLayout = false;
					btnPrivateChat.visible = false;
				}
			}
		}
		//To change the visibilty of private change button based on the usertype
		else
		{
			btnPrivateChat.includeInLayout = false;
			btnPrivateChat.visible = false;
		}
	}
}


/**
 * @public
 * @param event of type MouseEvent
 * This function is for calling Accept/Reject functions using toggle button 'btn_accept' in main.mxml.
 * <br>This option is available only for PRESENTER</br>
 */ 


public function onClickAccept(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.acceptViewer())
	{
		setupAcceptRelease(false);
	}
}

/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickRelease(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.rejectViewer())
	{
		setupAcceptRelease(true);
	}
}

/**
 * @public 
 * @param accept of type Boolean
 * 
 */
public function setupAcceptRelease(accept:Boolean):void
{
	btn_release.includeInLayout=!accept;
	btn_release.visible=!accept;
	btn_release.enabled=!accept;
	
	btn_accept.includeInLayout=accept;
	btn_accept.visible=accept;
	btn_accept.enabled=accept;
	
	btn_disaccept.includeInLayout=false;
	btn_disaccept.visible=false;
	btn_disaccept.enabled=false;
}

/**
 * @public 
 * @param accept of type Boolean
 * 
 */
public function setupDisAccept(accept:Boolean):void
{
	btn_release.includeInLayout=!accept;
	btn_release.visible=!accept;
	btn_release.enabled=!accept;
	
	btn_accept.includeInLayout=!accept;
	btn_accept.visible=!accept;
	btn_accept.enabled=!accept;
	
	btn_disaccept.includeInLayout=accept;
	btn_disaccept.visible=accept;
	btn_disaccept.enabled=accept;
}


/**
 *@public 
 * 
 */
public function removeAccept():void
{
	btn_accept.includeInLayout=false;
	btn_accept.visible=false;
	btn_accept.enabled=false;
	
	btn_disaccept.includeInLayout=false;
	btn_disaccept.visible=false;
	btn_disaccept.enabled=false;
}

/**
 *@public 
 * 
 */
public function removeRelease():void
{
	btn_release.includeInLayout=false;
	btn_release.visible=false;
	btn_release.enabled=false;
}



/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickViewVideo(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.callViewStudent())
	{
		viewcam=false;
		setupViewCam();
	}
}

/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickCloseViewVideo(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.closeViewStudent())
	{
		viewcam=true;
		setupViewCam();
	}
}

/**
 *@public 
 * 
 */
public function setupViewCam():void
{
	applicationType::DesktopWeb{
		btn_cam_rel.includeInLayout=!viewcam;
		btn_cam_rel.visible=!viewcam;
		btn_cam_rel.enabled=!viewcam;
		
		btn_cam.includeInLayout=viewcam;
		btn_cam.visible=viewcam;
		btn_cam.enabled=viewcam;
	}
}

/**
 *@public 
 * 
 */
public function removeViewCam():void
{
	applicationType::DesktopWeb{
		btn_cam.includeInLayout=false;
		btn_cam.visible=false;
		btn_cam.enabled=false;
	}
}

/**
 *@public 
 * 
 */
public function removeCloseViewCam():void
{
	applicationType::DesktopWeb{
		btn_cam_rel.includeInLayout=false;
		btn_cam_rel.visible=false;
		btn_cam_rel.enabled=false;
	}
}


/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickHandRaise(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.handRaise())
	{
		handraise=false;
		setupHandraise();
	}
}

/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickHandraiseRelease(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.releaseHandRaise())
	{
		handraise=true;
		setupHandraise();
	}
}

/**
 *@public 
 * 
 */
public function setupHandraise():void
{
	btn_handrelease.includeInLayout=!handraise;
	btn_handrelease.visible=!handraise;
	btn_handrelease.enabled=!handraise;
	
	btn_handraise.includeInLayout=handraise;
	btn_handraise.visible=handraise;
	if (ClassroomContext.IS_AUDIO_VIDEO_ENABLED){
		btn_handraise.enabled=handraise;
	}
	applicationType::mobile{
		isBtnHandRaiseReleaseVisible = false;
	}
}

/**
 *@public 
 * 
 */
public function removeHandraise():void
{
	btn_handraise.includeInLayout=false;
	btn_handraise.visible=false;
	btn_handraise.enabled=false;
}

/**
 *@public 
 * 
 */
public function removeReleaseHandraise():void
{
	btn_handrelease.includeInLayout=false;
	btn_handrelease.visible=false;
	btn_handrelease.enabled=false;
	applicationType::mobile{
		isBtnHandRaiseReleaseVisible = false;
	}
}



/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickMakePresenter(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		//trace("Make Presenter Called"+classRoomComp.docComp.isPresnter);
		lstUsers.hideMenu();
		/*if(classRoomComp.docComp.isPresnter){
			setTimeout(classRoomComp.makePresenter,3000);
			//return;
		}*/
		 if (classRoomComp.makePresenter())
		{
			lstUsers.notifyPresenter=true;                              
			presenter=false;
			setupMakeTakeControlPresenter();
		}
	}
	applicationType::mobile{
		if (classRoomComp.makePresenter()){
			lstUsers.notifyPresenter=true;
			presenter=false;
			setupMakeTakeControlPresenter();
		}
	}
}

/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickTakeControl(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.takeControl())
	{
		presenter=true;
		setupMakeTakeControlPresenter();
	}
}

/**
 *@public 
 * 
 */
public function setupMakeTakeControlPresenter():void
{

	takeControlButton.includeInLayout=!presenter;
	takeControlButton.visible=!presenter;
	takeControlButton.enabled=!presenter;
	
	presenterButton.includeInLayout=presenter;
	presenterButton.visible=presenter;
	presenterButton.enabled=presenter;

}

/**
 *@public 
 * 
 */
public function removeMakePresenter():void
{
	presenterButton.includeInLayout=false;
	presenterButton.visible=false;
	presenterButton.enabled=false;
}

/**
 *@public 
 * 
 */
public function removeTakeControl():void
{
	takeControlButton.includeInLayout=false;
	takeControlButton.visible=false;
	takeControlButton.enabled=false;
}

/**
 * @public 
 * @param event of MouseEvent
 * 
 */
public function onClickRequestPresenter(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.presenterRequest())
	{
		prsntrReq=false;
		setupPresenterRequest();
	}
}

/**
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function onClickReleasePresenter(event:MouseEvent):void
{
	lstUsers.hideMenu();
	if (classRoomComp.presenterRelease())
	{
		prsntrReq=true;
		setupPresenterRequest();
	}
}

/**
 *@public
 *  
 * 
 */
public function setupPresenterRequest():void
{
	releasePrsntrRequestButton.includeInLayout=!prsntrReq;
	releasePrsntrRequestButton.visible=!prsntrReq;
	releasePrsntrRequestButton.enabled=!prsntrReq;
	
	prsntrRequestButton.includeInLayout=prsntrReq;
	prsntrRequestButton.visible=prsntrReq;
	if (ClassroomContext.IS_AUDIO_VIDEO_ENABLED)
		prsntrRequestButton.enabled=prsntrReq;
}

/**
 *@public  
 * 
 */
public function removeRequestPresenter():void
{
	prsntrRequestButton.includeInLayout=false;
	prsntrRequestButton.visible=false;
	prsntrRequestButton.enabled=false;
}

/**
 *@public 
 * 
 */
public function removeReleaseRequestPresenter():void
{
	releasePrsntrRequestButton.includeInLayout=false;
	releasePrsntrRequestButton.visible=false;
	releasePrsntrRequestButton.enabled=false;
}
/**
 * @public
 * Break Session click
 * @param event of type MouseEvent
 * 
 */
public function onClickBreakSession(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		breakSessionObj.isBreakSessionClicked = true;
	}
	applicationType::mobile{
		breakSessionObj.width = FlexGlobals.topLevelApplication.width/2;
	}
	PopUpManager.addPopUp(breakSessionObj,this.parentApplication as DisplayObject, true);
	PopUpManager.centerPopUp(breakSessionObj);
	breakSessionObj.setDefaultValuesForBreakSessionItems();
	breakSessionButtonEnabledState=false;
}

/**
 *@private 
 * 
 */
private function removePTT():void
{
	applicationType::DesktopWeb{
		pttButtonVBox.includeInLayout=false;
		pttButtonVBox.visible=false;
		pttButtonVBox.enabled=false;
	}
	applicationType::mobile{
		pttBtnsGroup.includeInLayout = false;
		pttBtnsGroup.visible = false;
		pttBtnsGroup.enabled = false;
	}
}

/**
 *@private 
 * 
 */
private function addPTT():void
{
	applicationType::DesktopWeb{
		pttButtonVBox.includeInLayout=true;
		pttButtonVBox.visible=true;
		pttButtonVBox.enabled=true;
	}
	applicationType::mobile{
		pttBtnsGroup.includeInLayout = true;
		pttBtnsGroup.visible = true;
		pttBtnsGroup.enabled = true;
	}
}
private function addMUI():void
{
	applicationType::DesktopWeb{
		muiContainer.includeInLayout=true;
		muiContainer.visible=true;
	}
}

private function removeMUI():void
{
	applicationType::DesktopWeb{
		muiContainer.includeInLayout=false;
		muiContainer.visible=false;
	}
}

/**
 *@private 
 * 
 */
private function removeBrkSessBtn():void
{
	breakSessionButton.includeInLayout=false;
	breakSessionButton.visible=false;
	breakSessionButton.enabled=breakSessionButtonEnabledState;
}

/**
 *@private 
 * 
 */
private function addBrkSessBtn():void
{
	breakSessionButton.includeInLayout=true;
	breakSessionButton.visible=true;
	breakSessionButton.enabled=breakSessionButtonEnabledState;
}

/**
 *@private 
 * 
 */
private function removeAddPeopleBtn():void
{
	applicationType::DesktopWeb{
		AddPeopleBtn.includeInLayout=false;
		AddPeopleBtn.visible=false;
	}
}

/**
 *@private 
 * 
 */
private function addAddPeopleBtn():void
{
	applicationType::DesktopWeb{
		AddPeopleBtn.includeInLayout=true;
		AddPeopleBtn.visible=true;
	}
}

/**
 * @public
 * This method is called from usersSyncHandler if the current user is a viewer.
 * This sets the Handraise/release and presenter request/canel request button statuses
 */
public function setInteractionRequestButtonStatus():void
{
	// AKCR: please use conditional operator
	if (
		(classRoomComp.getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT) 
		|| (classRoomComp.getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.WAITING))
	{
		handraise=false;
	}
	else
	{
		handraise=true;
	}
	// AKCR: please combine the following 2 if statements;
	// AKCR: you can also use a conditional operator here
	// AKCR: please try to restrict the lenght of the line to the reading pane, about 80 chars
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE && !ClassroomContext.isModerator)
	{
		if (classRoomComp.getUserSO(ClassroomContext.userVO.userName).controlStatus == Constants.PRSNTR_REQUEST)
		{
			prsntrReq=false;
		}
		else
		{
			prsntrReq=true;
		}
	}
}

/**
 * @public 
 * Function is used for changing the status of setAudioMuteSO to 'mute' or 'unmute' (push to talk feature).
 * @param userName type of String
 * 
 */
public function talkMute(userName:String):void
{
	applicationType::DesktopWeb{
		if (pttCheckBoxState || ( adminPTTButtons && adminPTTButtons.pttCheckBoxState))
		{
			classRoomComp.setAudioMuteSOValue(userName);
			callSetupTalkMute((userName == ClassroomContext.currentPresenterName));
			if(userName != ""){
				userPushToTalkEventLog(userName, classRoomComp.getUserSO(userName).userRole);
			}
		}
	}
	applicationType::mobile{
		if(pttCheckBoxState){
			classRoomComp.setAudioMuteSOValue(userName);
			callSetupTalkMute((userName == ClassroomContext.currentPresenterName));
		}
	}
}

/**
 *
 * @private
 * Audits the "PushToTalk" action, when a viewer is selected for talking
 *
 * @param talkingUser - userName of the talking viewer
 * @param currentRole - role of the currently talking viewer
 * @return void
 *
 */
private function userPushToTalkEventLog(talkingUser:String, currentRole:String):void
{
	AuditContext.userAction.createAction(AuditConstants.pushToTalk, talkingUser, currentRole, null);
}

/**
 * @public 
 * @param talk type of Boolean
 * 
 */
public function callSetupTalkMute(talk:Boolean):void
{
	applicationType::DesktopWeb{
		if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
		{
			setupTalkMute(talk, adminPTTButtons.btnFreeTalk, adminPTTButtons.btnMute, adminPTTButtons.btnTalk);
		}
		else
		{
			setupTalkMute(talk, btnFreeTalk, btnMute, btnTalk);
		}
	}
	applicationType::mobile{
		setupTalkMute(talk, btnFreeTalk, btnMute, btnTalk);
	}
}

/**
 * @public 
 * @param talk of type Boolean
 * @param btnFreeTalk of type Button
 * @param btnMute of type Button
 * @param btnTalk of type Button
 * 
 */
public function setupTalkMute(talk:Boolean, btnFreeTalk:*, btnMute:*, btnTalk:*):void
{
	//	if(ClassroomContext.userVO.role != Constants.ADMIN_TYPE &&  ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE)
	btnFreeTalk.includeInLayout=false;
	btnFreeTalk.visible=false;
	
	btnMute.includeInLayout=!talk;
	btnMute.visible=!talk;
	btnMute.enabled=!talk;
	
	
	btnTalk.includeInLayout=talk;
	btnTalk.visible=talk;
	btnTalk.enabled=talk;
	
	/**For all the other users, the PTT buttons should be same as presenter/moderator's view, except in disabled state*/
	if (ClassroomContext.userVO.userName != ClassroomContext.currentPresenterName && !ClassroomContext.isModerator && ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE)
	{
		btnMute.enabled=false;
		btnTalk.enabled=false;
	}
}

/**
 *@public 
 * 
 */
public function callSetupFreeTalk():void
{
	applicationType::DesktopWeb{
		if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
		{
			setupFreeTalk(adminPTTButtons.btnFreeTalk, adminPTTButtons.btnMute, adminPTTButtons.btnTalk);
		}
		else
		{
			setupFreeTalk(btnFreeTalk, btnMute, btnTalk);
		}
	}
	applicationType::mobile{
		setupFreeTalk(btnFreeTalk, btnMute, btnTalk);
	}
}

/**
 * @public 
 * @param btnFreeTalk of type Button
 * @param btnMute of type Button
 * @param btnTalk of type Button
 * 
 */
public function setupFreeTalk(btnFreeTalk:*, btnMute:*, btnTalk:*):void
{
	//	if(ClassroomContext.userVO.role != Constants.ADMIN_TYPE &&  ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE)
	//	{
	btnFreeTalk.includeInLayout=true;
	btnFreeTalk.visible=true;
	btnFreeTalk.enabled=false;
	
	btnMute.includeInLayout=false;
	btnMute.visible=false;
	btnMute.enabled=false;
	
	btnTalk.includeInLayout=false;
	btnTalk.visible=false;
	btnTalk.enabled=false;
	//	}
}
/**
 * @public
 * Function is used for enabling/disabling push to talk feature.
 * @param selected of type Boolean
 * 
 */
applicationType::DesktopWeb{
	public function pushToTalk(selected:Boolean):void
	{
		//	if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Checkbox Current Status:"+ actionBtns.chkboxPushToTalk.selected) ;
		if (selected)
		{
			classRoomComp.setAudioMuteSOValue(ClassroomContext.currentPresenterName);
			userPushToTalkEventLog(ClassroomContext.currentPresenterName, Constants.PRESENTER_ROLE);
		}
		else
		{
			classRoomComp.setAudioMuteSOValue(Constants.FREETALK);
			userFreeTalkEventLog();
		}
	}
}
applicationType::mobile{
	public function pushToTalk(event:Event):void
	{
		var selected:Boolean = event.target.selected; 
		if(selected)
		{
			classRoomComp.setAudioMuteSOValue(ClassroomContext.currentPresenterName);
			//To change the color of Callout button label.
			PTT.setStyle('color',"#0cd023");
		}
		else
		{
			classRoomComp.setAudioMuteSOValue(Constants.FREETALK);
			//To change the color of Callout button label.
			PTT.setStyle('color',"#FFFFFF");
		}
	}
}
/**
 *
 * @private
 * Audits the "FreeTalk" action when the push to talk is truned off/free talk is enabled
 *
 * @return void
 *
 */
private function userFreeTalkEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.freeTalk, null, null, null);
}

private function setMultiUserInteraction():void
{
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.muiInteractionflag=chkMultiUser.selected;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changeMUIMode(chkMultiUser.selected);
	}
}
private function setPeopleCount():void
{
	applicationType::DesktopWeb{
		if(chkPeopleCount.selected==true)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.peopleCountFlag=true;
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatusToolTip.toolTip=Constants.PEOPLE_COUNT;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatus.headerText='PC';
		}
		else
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.peopleCountFlag=false;
			
			if(ClassroomContext.userVO.role!=Constants.MONITOR_TYPE)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatus.headerText ="IC";
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatusToolTip.toolTip=Constants.PRESENTER_INTERACT;
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatus.headerText = "MC";
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatusToolTip.toolTip=Constants.MONITOR_INTERACT;
			}
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.sortUserList();
	}
}
