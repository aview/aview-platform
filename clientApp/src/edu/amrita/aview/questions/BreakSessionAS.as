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
 * File			: BreakSessionAS.as
 * Module		: Question
 * Developer(s)	: Ravishankar
 * Reviewer(s)	: Sinu
 *
 * This file contains code for the Break Session functionality.
 * The layout of the function UI is in the BreakSession.mxml file.
 * The function is triggered by a <sendButton> click which results
 * in a PopUp of a UI box as defined in the BreakSession.mxml file.
 * The different steps involved in the processing of the functionality are:
 * 		a)	the setDefaultValuesForBreakSessionItems() sets up the defaults for the UI items
 * 		b)	the cancelSessionBreak() is for cancelling the PopUp
 * 		c)	the sendSessionBreakMessage() is for processing the BreakSession.mxml
 * 			UI items and each of the UI item is validated. breakSessionConfirmed() is called
 * 			for a final confirmation when validation is successful
 * 		d)	breakSessionMessageTextInput_focusOutHandler() and
 * 			breakSessionMessageTextInput_focusInHandler()
 * 				handle the focus on <break message text input>
 * 		e)	breakSessionMinutesTextInput_focusInHandler()
 * 				handles the focus on <break duration input>
 * 		f)	cancelSessionBreakOnPresenterRoleChange() is to handle the change in the Presenter role
 *
 * The trigger button is defined in the ClassRoomActions file
 */


import com.amrita.edu.collaboration.CollaborationFactory;
import com.amrita.edu.collaboration.CollaborationObject;
import com.amrita.edu.collaboration.CollaborationService;
applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.alert.CustomAlert;
	import edu.amrita.aview.preferenceSettings.Desktop;
}
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
import edu.amrita.aview.core.entry.events.SessionStatusEvent;
applicationType::mobile{
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
}
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.core.shared.events.ChatEvent;
import edu.amrita.aview.questions.BreakDetails;
import edu.amrita.aview.questions.events.BreakSessionEvent;
import edu.amrita.aview.questions.events.QuestionInteractionEvent;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.setTimeout;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;


/**
 * Used to keep track of the enable / disable state of Question & Answer feature
 */
[Bindable]
public var questionAnswerEnabledState:Boolean=true;

/**
 * Used to inform that the posting and voting feature in Question & Answer is disabled
 */
applicationType::DesktopWeb{
	public var breakSessionQuestionTabDisableAlert:Alert;
	/**
	 *  This variable used to check whether viewer clicked on the breaksession button while viewer get the presenter control. 
	 */
	public var isBreakSessionClicked:Boolean = false;
}
applicationType::mobile{
	public var breakSessionQuestionTabDisableAlert:MessageBox;
}
/**
 * Used to close the Break Session popup window
 */
private var _closer:mx.controls.Button=new mx.controls.Button();
/**
 * Used to log the Break Session trail
 */
private var log:ILogger=Log.getLogger("aview.BreakSession");

private var classRoomModuleRO:ModuleRO = null;

private var breakSessionCO:CollaborationObject = null;

private static const BREAK_SESSION_CO_NAME:String = "BreakSession";

private var breakDetails:BreakDetails = null;

private var breakSessionTimeoutId:uint;
private var clientNotified:Boolean=false;
private var popMessage:String;
applicationType::DesktopWeb{
	private var breakNote:Alert;
	private var breakConfirm:Alert;
}
applicationType::mobile{
	private var breakNote:MessageBox;
	private var breakConfirm:MessageBox;
}


public function setModuleRO(mro:ModuleRO):void{
	this.classRoomModuleRO = mro;
	setupEvents();
	setupCollaboration();
	setupClientCallbacks();
}

private function setupClientCallbacks():void
{
	classRoomModuleRO.mediaServerConnection.addClientMethod("sendBreakSessionMessage",sendBreakSessionMessage);
	classRoomModuleRO.mediaServerConnection.addClientMethod("compareStartResumeBreakTimes",compareStartResumeBreakTimes);
}

private function setupEvents():void{
	applicationType::DesktopWeb{
		classRoomModuleRO.moduleEventMap.registerMapListener(QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE,onQuestionInteractionStateEvent);
		classRoomModuleRO.moduleEventMap.registerMapListener(QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE,onQuestionInteractionStateEvent);
	}
	classRoomModuleRO.moduleEventMap.registerMapListener(BreakSessionEvent.CANCEL_BREAK_SESSION,cancelSessionBreakOnPresenterRoleChange);
	classRoomModuleRO.moduleEventMap.registerInitiator(this,BreakSessionEvent.BREAK_SESSION_STARTED_TYPE);
	classRoomModuleRO.moduleEventMap.registerInitiator(this,BreakSessionEvent.BREAK_SESSION_ENDED_TYPE);

	classRoomModuleRO.moduleEventMap.registerInitiator(this,ChatEvent.SEND_CHAT_MESSAGE,"Session");
	classRoomModuleRO.moduleEventMap.registerMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
	classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
	classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
}

private function setupCollaboration():void
{
	breakSessionCO = classRoomModuleRO.collaborationService.connectCollaborationObject(BREAK_SESSION_CO_NAME);
	breakSessionCO.setOnChangeProperty("BreakDetails",onBreakDetailsChange);
	breakSessionCO.setOnClear(resumeBreak);
}

private function onBreakDetailsChange(breakObject:Object,oldBreakObject:Object,paramName:String):void
{
	breakDetails =  new BreakDetails(breakObject);

	if (Log.isInfo()) log.info("Break Session started: " + breakDetails.breakMessage + " for: " +breakDetails.minutes+" minutes");
	
	this.classRoomModuleRO.mediaServerConnection.netConnection.call("getServerTime", null, "compareStartResumeBreakTimes");
}

private function resumeBreak():void
{
	if (breakSessionCO.syncEventCount == 1)
	{
		breakDetails = new BreakDetails(breakSessionCO.getData()["BreakDetails"]);
		this.classRoomModuleRO.mediaServerConnection.netConnection.call("getServerTime", null, "compareStartResumeBreakTimes");
	}
}

/**
 * @public
 * Function called from server to pass the current server time.
 * Compare the current time with the set end of break session time 
 * to determine if break session notification is to be pop up'ed. 
 * 
 * @param serverTime of type Date
 * @param isBreakNotePop of type Boolean
 * @return void 
 * 
 */
public function compareStartResumeBreakTimes(serverTime:Date):void
{
	var breakTime:Object = breakDetails.resumeTime;
	
	var diffBreakTimeInMilliseconds:int = (breakTime == null) ? 0 : Math.ceil(breakTime.getTime() - serverTime.getTime());
	
	if (Log.isDebug()) log.debug("compareStartResumeBreakTimes::serverTime=" + serverTime + "  resumeBreakTime=[" + (breakTime == null) ? "empty string" : breakTime.toString() + "]   diff=" + diffBreakTimeInMilliseconds);
	
	if (!clientNotified && diffBreakTimeInMilliseconds > 0)
	{
		breakSessionTimeoutId=setTimeout(resetBreakTimeInterval, diffBreakTimeInMilliseconds);
		breakNotePop();
		this.dispatchEvent(new BreakSessionEvent(BreakSessionEvent.BREAK_SESSION_STARTED_TYPE,breakDetails));

	}
}

/**
 * 
 * START of Break Session code additions
 */
/**
 * @private
 * To remove the break session popup window.
 * 
 * @param clEvt of type CloseEvent
 * @return void 
 * 
 */
applicationType::DesktopWeb{
	private function breakHandler(clEvt:CloseEvent):void
	{
		PopUpManager.removePopUp(breakNote);
		if ((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) || ClassroomContext.isModerator)
		{
			PopUpManager.removePopUp(this);
		}
	}
}
applicationType::mobile{
	private function breakHandler(clEvt:MessageBoxEvent):void
	{
		PopUpManager.removePopUp(breakNote);
	}
}
/**
 * @private
 * Function resets the defined break duration time interval and
 * closes all break session related pop up(s).
 * 
 *
 * @return void 
 * 
 */
private function resetBreakTimeInterval():void
{
	clearTimeout(breakSessionTimeoutId);
	clientNotified=false;
	if (breakNote)
	{
		PopUpManager.removePopUp(breakNote);
	}
	this.dispatchEvent(new BreakSessionEvent(BreakSessionEvent.BREAK_SESSION_ENDED_TYPE,breakDetails));
}
/**
 * @private
 * Defines the break session notifications and triggers the break session pop up window.
 *
 * @return void 
 * 
 */
private function breakNotePop():void
{
	var uName:String=ClassroomContext.userVO.userName;
	applicationType::DesktopWeb{
		if ((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) 
			|| ClassroomContext.isModerator)
		{
			if(isBreakSessionClicked == true){
				breakNote=CustomAlert.info(Constants.BREAK_MESSAGE_SUCCESS, Constants.BREAK_SESSION_COMPONENT_TITLE, breakHandler);
			}
			else{
				breakNote=CustomAlert.info('\n'+breakDetails.popupMessage+'\n', Constants.BREAK_SESSION_COMPONENT_TITLE,breakHandler);
				applicationType::desktop{
					breakNote.x=(FlexGlobals.topLevelApplication.applicationWidth-breakNote.width)/2;
					breakNote.y=(FlexGlobals.topLevelApplication.applicationHeight-breakNote.height)/2;
				}
				applicationType::web{
					breakNote.x=(FlexGlobals.topLevelApplication.width-breakNote.width)/2;
					breakNote.y=(FlexGlobals.topLevelApplication.height-breakNote.height)/2;	
				}
				setTimeout(centerBreakMessage,1000,breakNote.x,breakNote.y);
			}
		}
		else
		{
			breakNote=CustomAlert.info('\n'+breakDetails.popupMessage+'\n', Constants.BREAK_SESSION_COMPONENT_TITLE,breakHandler);
			applicationType::desktop{
				breakNote.x=(FlexGlobals.topLevelApplication.applicationWidth-breakNote.width)/2;
				breakNote.y=(FlexGlobals.topLevelApplication.applicationHeight-breakNote.height)/2;
			}
			//Fix for issue #18747
			applicationType::web{
				breakNote.x=(FlexGlobals.topLevelApplication.width-breakNote.width)/2;
				breakNote.y=(FlexGlobals.topLevelApplication.height-breakNote.height)/2;	
			}
			setTimeout(centerBreakMessage,1000,breakNote.x,breakNote.y);
			//Fix for issue #15363
			if(breakDetails.enableQuestions==false)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.enableQuestionInteraction(false,null,null);
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.enableQuestionInteraction(true,null,null);
			}
		}
	}
	applicationType::mobile{
		if ((FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) || ClassroomContext.isModerator){
			breakNote = MessageBox.show(Constants.BREAK_MESSAGE_SUCCESS, Constants.BREAK_SESSION_COMPONENT_TITLE,MessageBox.MB_OK,null, breakHandler,null,MessageBox.IC_INFO);
		}else{
			breakNote = MessageBox.show(breakDetails.popupMessage, Constants.BREAK_SESSION_COMPONENT_TITLE, MessageBox.MB_OK, null,breakHandler,null,MessageBox.IC_INFO);
		}
		if(breakDetails.enableQuestions==false){
			FlexGlobals.topLevelApplication.mainApp.questionComp.enableQuestionInteraction(false,null,null);
		}else{
			FlexGlobals.topLevelApplication.mainApp.questionComp.enableQuestionInteraction(true,null,null);
		}
	}
	clientNotified=true;
	
	//TODO: May not be necessary
	applicationType::DesktopWeb{
		if (breakConfirm)
		{
			PopUpManager.removePopUp(breakConfirm);
		}
		isBreakSessionClicked = false;
	}
	applicationType::mobile{
		if (breakConfirm)
		{
			PopUpManager.removePopUp(this);
		}
	}
}
private function centerBreakMessage(x:int,y:int):void{
	breakNote.move(x,y);
}
private function cleanup(event:Event = null):void{
	clearEvents();
	classRoomModuleRO.collaborationService.closeCollaborationObject(BREAK_SESSION_CO_NAME);
}

private function clearEvents():void{
	classRoomModuleRO.moduleEventMap.unregisterMapListener(QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE,onQuestionInteractionStateEvent);
	classRoomModuleRO.moduleEventMap.unregisterMapListener(QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE,onQuestionInteractionStateEvent);

	classRoomModuleRO.moduleEventMap.unregisterMapListener(BreakSessionEvent.CANCEL_BREAK_SESSION,cancelSessionBreakOnPresenterRoleChange);
	classRoomModuleRO.moduleEventMap.unregisterInitiator(this,BreakSessionEvent.BREAK_SESSION_STARTED_TYPE);
	classRoomModuleRO.moduleEventMap.unregisterInitiator(this,BreakSessionEvent.BREAK_SESSION_ENDED_TYPE);

	classRoomModuleRO.moduleEventMap.unregisterInitiator(this,ChatEvent.SEND_CHAT_MESSAGE,"Session");

	classRoomModuleRO.moduleEventMap.unregisterMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
	classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
	classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);

}

private function onQuestionInteractionStateEvent(event:QuestionInteractionEvent){
	questionAnswerEnabledState = (event.type == QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE);
}

/**
 *
 * @protected
 * This  function is used when feedback form is closed.
 * It will remove feedback form and
 * dispatch event to cancel break session.
 *
 * @param event of FlexEvent
 * @return void
 *
 */
applicationType::DesktopWeb{
	protected function init(event:FlexEvent):void
	{
		this.addElement(_closer);
		_closer.width=18;
		_closer.height=18;
		//TODO: It says width is undefined
		_closer.x=this.width - _closer.width - 8;
		_closer.y=-25;
		_closer.toolTip="Close";
		_closer.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
		{
			closeFeedback(event)
		});
		_closer.setStyle('icon', breakSession_closePng);
		_closer.useHandCursor=false;
	}
}

/**
 *
 * @private
 * This  function is used when feedback form is closed.
 * It will remove session break pop up.
 *
 * @param event of validation result
 * @return void
 *
 */
private function closeFeedback(e:*):void
{
	cancelSessionBreak();
}

/**
 *
 * @public
 * This  function is used to set default values for the Break Session pop up
 *
 * 
 * @return void
 *
 */
public function setDefaultValuesForBreakSessionItems():void
{
	breakSessionMessageTextInput.text=Constants.BREAK_MESSAGE_INPUT_TEXT;
	breakSessionMessageTextInput.alpha=0.5;
	breakSessionMinutesTextInput.text="01";
	applicationType::DesktopWeb{
		questionAnswerEnabledStateCheckBox.selected=true;
	}
}

/**
 *
 * @private
 * This  function is used to remove the Break Session pop up
 *
 * 
 * @return void
 *
 */
private function cancelSessionBreak():void
{
	setDefaultValuesForBreakSessionItems();
	PopUpManager.removePopUp(this);
	this.dispatchEvent(new BreakSessionEvent(BreakSessionEvent.BREAK_SESSION_ENDED_TYPE,null));
}

/**
 *
 * @public
 * This  function is used to remove Break Session pop up when Presenter role becomes Viewer role
 *
 * 
 * @return void
 *
 */
//Fix for issue #15072: Changed private to public to access this function in coreLib project 
public function cancelSessionBreakOnPresenterRoleChange(event:BreakSessionEvent=null):void
{
	if (breakConfirm)
	{
		applicationType::DesktopWeb{
			PopUpManager.removePopUp(breakConfirm);
		}
		applicationType::mobile{
			PopUpManager.removePopUp(this);
		}
		breakConfirm=null;
	}
	else if (breakSessionQuestionTabDisableAlert)
	{
		PopUpManager.removePopUp(breakSessionQuestionTabDisableAlert);
		breakSessionQuestionTabDisableAlert=null;
	}
	PopUpManager.removePopUp(this);
	this.dispatchEvent(new BreakSessionEvent(BreakSessionEvent.BREAK_SESSION_ENDED_TYPE,breakDetails));
}

/**
 *
 * @private
 * This  function is used to validate the UI entries in the Break Session pop up.
 * Send a confirm pop up if validation is successful
 *
 * 
 * @return void
 *
 */
private function initiateateSessionBreak():void
{
	breakDetails = new BreakDetails();
	applicationType::mobile{
		this.addEventListener(ChatEvent.SEND_CHAT_MESSAGE,FlexGlobals.topLevelApplication.chatComp.sendChatMessage);
	}
	//TODO:Variable description
	var uName:String=ClassroomContext.userVO.userName;
	breakDetails.minutes=parseInt(breakSessionMinutesTextInput.text);
	//TODO:Variable description
	breakDetails.breakMessage=StringUtil.trim(breakSessionMessageTextInput.text);
	
	
	if (breakDetails.breakMessage == "" || breakSessionMessageTextInput.alpha == 0.5)
	{
		if (breakDetails.minutes < 1)
		{
			breakSessionMessageTextInput.setFocus();
			applicationType::DesktopWeb{
				CustomAlert.info("Invalid break session input");
			}
			applicationType::mobile{
				MessageBox.show("Invalid Break Session input(s)");
			}
		}
		else
		{
			breakSessionMessageTextInput.setFocus();
			applicationType::DesktopWeb{
				CustomAlert.info("Please fill session break message");
			}
			applicationType::mobile{
				MessageBox.show("Please fill session break message");
			}
		}
	}
	else
	{
		applicationType::DesktopWeb{
			if (breakDetails.minutes < 1)
			{
				breakSessionMinutesTextInput.setFocus();
				CustomAlert.info("Invalid entry, please enter a valid time duration in minutes", "Information");
			}
			else if (!questionAnswerEnabledStateCheckBox.selected)
			{
				breakSessionQuestionTabDisableAlert=CustomAlert.confirm("Posting Questions and Voting is Disabled." + "\n" + Constants.BREAK_SESSION_MSG, "Confirmation", breakSessionConfirmed);
			}
			else
			{
				breakConfirm=CustomAlert.confirm(Constants.BREAK_SESSION_MSG, "Confirmation", breakSessionConfirmed);
			}
		}
		applicationType::mobile{
			if (breakDetails.minutes < 1)
			{
				breakSessionMinutesTextInput.setFocus();
				
				MessageBox.show("Invalid entry, please enter a valid time duration in minutes", "Information");
			}
			else
			{
				breakConfirm=MessageBox.show(Constants.BREAK_SESSION_MSG, "Confirmation",MessageBox.MB_OKCANCEL,this, breakSessionConfirmed,null,MessageBox.IC_INFO);
			}
		}
	}
}

/**
 *
 * @private
 * This  function is used to initiate the Break Session process, if confirmed OK
 *
 * @param breakEvent of type CloseEvent
 * @return void
 *
 */
applicationType::DesktopWeb{
	private function breakSessionConfirmed(confirmEvent:CloseEvent):void
	{
		if (confirmEvent.detail == Alert.YES)
		{
			if (Log.isInfo()) log.info("Chat: Break session confirmed - ");
			sendBreakSessionChatMessage();
			breakDetails.enableQuestions = questionAnswerEnabledStateCheckBox.selected;
			this.dispatchEvent(new BreakSessionEvent(BreakSessionEvent.BREAK_SESSION_STARTED_TYPE,breakDetails));
			PopUpManager.removePopUp(this);
		}
		else if (!questionAnswerEnabledStateCheckBox.selected)
		{
			questionAnswerEnabledStateCheckBox.selected=true;
		}
	}
}
applicationType::mobile{
	private function breakSessionConfirmed(brkEvent:MessageBoxEvent):void
	{
		if (brkEvent.type == MessageBoxEvent.MESSAGEBOX_OK)
		{
			FlexGlobals.topLevelApplication.chatComp.brkSessionBool = true ;
			if (Log.isInfo()) log.info("Chat: Break session confirmed - "+FlexGlobals.topLevelApplication.chatComp.brkSessionBool);
			sendBreakSessionChatMessage();			
			
			this.dispatchEvent(new BreakSessionEvent(BreakSessionEvent.BREAK_SESSION_STARTED_TYPE,breakDetails));
			PopUpManager.removePopUp(this);
		}
	}
}

private function sendBreakSessionChatMessage():void
{
	if(this.classRoomModuleRO.mediaServerConnection.netConnection != null && this.classRoomModuleRO.mediaServerConnection.netConnection.connected==true)
	{
		this.classRoomModuleRO.mediaServerConnection.netConnection.call("getServerTime", null, "sendBreakSessionMessage");
	}
	else
	{
		Alert.show('Could not send the message, please try again after some time', Constants.BREAK_SESSION_COMPONENT_TITLE);
	}
}

/**
 * @public
 * Function called from the server to pass break session key and the end of break time stamp.
 * @param serverTime of type Date
 * @return void 
 * 
 */
public function sendBreakSessionMessage(serverTime:Date):void
{
	if (Log.isInfo()) log.info("sendBreakResumeTime::" + serverTime.toString());
	var strMsg:String;
	applicationType::DesktopWeb{
		strMsg="<b><font color='"+Constants.CHAT_BREAK_MSG_COLOR+"'>\n-----------------------------------------------------\n@" + Constants.BREAK_SESSION_TITLE.toUpperCase() + "  @\n\n" + breakDetails.breakMessage + "\n" + "Break duration: " + breakDetails.minutes +"minute(s)\n-----------------------------------------------------</font></b>";
	}
	applicationType::mobile{
		strMsg=Constants.BREAK_SESSION_TITLE.toUpperCase() + "  @\n\n" + breakDetails.breakMessage + "\n" + "Break duration: " + breakDetails.minutes +"minute(s)\n-----------------------------------------------------";
	}
	serverTime.setMinutes(serverTime.getMinutes() + breakDetails.minutes);
	breakDetails.resumeTime = serverTime;
	breakDetails.breakChatMessage = strMsg;
	
	if (Log.isInfo()) log.info("addTime::" + serverTime.toString());
	this.dispatchEvent(new ChatEvent(ChatEvent.SEND_CHAT_MESSAGE,breakDetails.breakChatMessage));
	breakSessionCO.setValue("BreakDetails",breakDetails);
	setDefaultValuesForBreakSessionItems();
}


/**
 *
 * @protected
 * This  function is used to handle the text input message UI in Break Session pop up, on FocusOut
 *
 * @param event of type FocusEvent
 * @return void
 *
 */
protected function breakSessionMessageTextInput_focusOutHandler(event:FocusEvent):void
{
	//TODO:Variable description
	var str:String=StringUtil.trim(breakSessionMessageTextInput.text);
	if (str == '' || str == " ")
	{
		breakSessionMessageTextInput.text=Constants.BREAK_MESSAGE_INPUT_TEXT;
		breakSessionMessageTextInput.alpha=0.5;
	}
	else if (breakSessionMessageTextInput.text != '' && breakSessionMessageTextInput.alpha != 0.5)
	{
		breakSessionMessageTextInput.text=breakSessionMessageTextInput.text;
		breakSessionMessageTextInput.alpha=1;
	}
}

/**
 *
 * @protected
 * This  function is used to handle the text input message UI in Break Session pop up, on FocusIn
 *
 * @param event of type FocusEvent
 * @return void
 *
 */
protected function breakSessionMessageTextInput_focusInHandler(event:FocusEvent):void
{
	if (breakSessionMessageTextInput.text != '' && breakSessionMessageTextInput.alpha != 0.5)
	{
		breakSessionMessageTextInput.text=breakSessionMessageTextInput.text;
		breakSessionMessageTextInput.alpha=1;
		return;
	}
	if (breakSessionMessageTextInput.text == '')
	{
		breakSessionMessageTextInput.text=Constants.BREAK_MESSAGE_INPUT_TEXT;
		breakSessionMessageTextInput.alpha=0.5;
		return;
	}
	if (breakSessionMessageTextInput.alpha == 0.5)
	{
		breakSessionMessageTextInput.text="";
		breakSessionMessageTextInput.alpha=1;
		breakSessionMessageTextInput.setStyle("color", 0x060606);
		return;
	}
}

/**
 *
 * @protected
 * This  function is used to handle the text input of break duration UI minutes in Break Session pop up, on FocusIn
 *
 * @param event of type FocusEvent
 * @return void
 *
 */
protected function breakSessionMinutesTextInput_focusInHandler(event:FocusEvent):void
{
	if (breakSessionMinutesTextInput.text == "" || breakSessionMinutesTextInput.text == "0" || breakSessionMinutesTextInput.text == "00")
	{
		breakSessionMinutesTextInput.text="01";
		breakSessionMinutesTextInput.setStyle("color", 0x060606);
	}
}

/**
 *
 * @private
 * This  function is used to handle the trigger UI via keyboard
 *
 * @param event of type KeyboardEvent
 * @return void
 *
 */
private function keyboardKeyDown(event:KeyboardEvent):void
{
	if (event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.SPACE)
	{
		event.preventDefault();
		event.stopImmediatePropagation();
		return
	}
}
