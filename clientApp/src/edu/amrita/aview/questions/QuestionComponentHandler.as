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
 * File			: QuestionSession.as
 * Module		: Question
 * Developer(s)	: Ravishankar
 * Reviewer(s)	: Meena S
 *
 * For a Viewer (role):
 * 		Provides a forum to raise questions in a live classroom session without interupting the class.
 * 		Can vote in favour of an already posted question.
 * For a Presenter (role):
 * 		Provides means to mark a question as Answered.
 * 		Using the vote count for a question identify how many viewers share a question.
 * 		Prioritise addressing the posted questions.
 * 		Delete a question.
 * For a Moderator (role):
 * 		Besides all the above listed features available to the Presenter, a Moderator can also vote for a posted question.
 *
 */

import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.entry.ClassroomComponent;
}
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
applicationType::mobile{
	import edu.amrita.aview.core.entry.MainMobileApplication;
	import edu.amrita.aview.core.shared.components.mobileComponents.toolTip.MobileToolTip;
}
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.entry.events.RoleChangeEvent;
import edu.amrita.aview.core.entry.events.SessionStatusEvent;
import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.questions.QuestionSOValues;
import edu.amrita.aview.questions.events.BreakSessionEvent;
import edu.amrita.aview.questions.events.QuestionInteractionEvent;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.utils.StringUtil;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.shared.components.DateFormatter;
	import edu.amrita.aview.common.components.alert.CustomAlert;
}
import spark.formatters.DateTimeFormatter;
import edu.amrita.aview.common.helper.TimeStampHelper;
import flash.display.DisplayObject;


/**
 * Used to hold the last selected question's id
 */
private var lastSelectedQuestionId:String="";

/**
 * Used to access the Question Shared Object
 */
private var questionCO:CollaborationObject;
/**
 * Used to collaborate on the Queston Interaction status
 */
private var questionStatusCO:CollaborationObject;

private static const QUESTION_CO_NAME:String = "questionSharedObj";

private static const QUESTION_STATUS_CO_NAME:String = "questionStatus";

/**
 * Used to maintain the posted Questions
 */
[Bindable]
private var questionArray:ArrayCollection;

/**
 * Used to define the datagrid column width
 */
private var questionDataGridQuestionColumnWidth:int;
private var questionDataGridVoteColumnWidth:int;

/**
 * Used to define the questions' status
 */
private static const QUESTION_ANSWERED:String="ANSWERED";
private static const QUESTION_UNANSWERED:String="UNANSWERED";
private static const QUESTION_SKIPPED:String="SKIPPED";

//TODO:Variable description
applicationType::DesktopWeb{
	private var classroomComp:ClassroomComponent;
}
applicationType::mobile{
	private var classroomComp:MainMobileApplication;
}
private var classRoomModuleRO:ModuleRO = null;
private var parentComp:Canvas;

/**
 * 
 * @public
 * The function is used to initiliaze the chat component.This sets the height,width and x value
 * of the chat component.This function sets connection with the FMS server.		
 *
 * @param classroomComp
 * @return void
 */
applicationType::DesktopWeb{
	public function init(classroomComp:ClassroomComponent,mro:ModuleRO):void
	{
		this.classroomComp = classroomComp;
		this.classRoomModuleRO = mro;
		this.parentComp = classroomComp.classroomComponentSgl.questionInterface;
		this.parentComp.addChild(this);
	
		setupEvents();
		setupCollaboration();
		enableQuestionInteraction(true,null,null);//Default behavior	
	}
}
applicationType::mobile{
	public function init(classroomComp:MainMobileApplication,mro:ModuleRO):void
	{
		this.classroomComp = classroomComp;
		this.classRoomModuleRO = mro;
		setupEvents();
		
		setupCollaboration();
		enableQuestionInteraction(true,null,null);//Default behavior
	}
}
private function setupEvents():void{
	classRoomModuleRO.moduleEventMap.registerMapListener(RoleChangeEvent.TYPE_ROLE_CHANGE,setButtonVisibilityOnRoleChange);
	classRoomModuleRO.moduleEventMap.registerMapListener(QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE,onQuestionInteractionStateEvent);
	classRoomModuleRO.moduleEventMap.registerMapListener(QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE,onQuestionInteractionStateEvent);
	
	classRoomModuleRO.moduleEventMap.registerMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
	classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
	classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
}

private function cleanup(event:Event = null):void{
	clearEvents();
	classRoomModuleRO.collaborationService.closeCollaborationObject(QUESTION_CO_NAME);
	classRoomModuleRO.collaborationService.closeCollaborationObject(QUESTION_STATUS_CO_NAME);
}

private function clearEvents():void{
	classRoomModuleRO.moduleEventMap.unregisterMapListener(RoleChangeEvent.TYPE_ROLE_CHANGE,setButtonVisibilityOnRoleChange);
	classRoomModuleRO.moduleEventMap.unregisterMapListener(QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE,onQuestionInteractionStateEvent);
	classRoomModuleRO.moduleEventMap.unregisterMapListener(QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE,onQuestionInteractionStateEvent);
	
	classRoomModuleRO.moduleEventMap.unregisterMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
	classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
	classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
	
}
/**
 *
 * @public
 * This function establishes connection with a collaborative Question Shared Object
 *
 * @return void
 *
 */
private function setupCollaboration():void
{
	questionCO=this.classRoomModuleRO.collaborationService.connectCollaborationObject(QUESTION_CO_NAME);
	questionCO.setOnSync(questionSyncHandler);

	questionStatusCO=this.classRoomModuleRO.collaborationService.connectCollaborationObject(QUESTION_STATUS_CO_NAME);
	questionStatusCO.setOnChangeProperty("EnableQA",enableQuestionInteraction);
}

/**
 *
 * @public
 * This function checks the typed question string for leading spaces and posts the entered question in the
 * Question Shared Object alongwith the display name and date-time stamp. It also sets the vote count to 0
 * and the question's status to unanswered.
 * It also, clears and sets focus at the question text input field, ready for next entry.
 *
 * @return void
 *
 */
public function postQuestion():void
{
	var question:String=StringUtil.trim(questionInput.text);
	if(question == null || question == "")
	{
		applicationType::DesktopWeb{
			questionInput.setFocus();
		}
	}
	else
	{
		//Fix for Bug#17302:Start
		var timeStampHelper:TimeStampHelper = new TimeStampHelper();
		timeStampHelper.getServerDateAndTime(getServerDateAndTimeResultHandler,getServerDateAndTimeFaultHandler);
		//Fix for Bug#17302:End
	}
}

/**
 *
 * @private
 * Audits the "QuestionAsk" action, when the current viewer is aksing a question
 *
 * @param question - Question text
 * @return void
 *
 */
private function questionAskEventLog(question:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.questionAsk, question, null, null);
	}
}

/**
 *
 * @public
 * This function verifies:-
 * 		a)	if the posted question and the viewer is not the same (self voting).
 * 		b)	if the viewer has already voted for the question earlier (duplicate voting).
 * if the above verifications are cleared the vote count is bumped up by 1 and the viewer
 * name is recorded as having voted for that question id.
 *
 * @return void
 *
 */
private function voteForQuestion():void
{
	if (questionDataGrid.selectedItem == null)
	{
		return;
	}
	var questionSOValue:QuestionSOValues= new QuestionSOValues(questionDataGrid.selectedItem);
	
	if (questionSOValue.postedBy != ClassroomContext.userVO.userName)
	{
		
		if(questionSOValue.votedBy.indexOf(ClassroomContext.userVO.userName) == -1){
			questionSOValue.vote=questionSOValue.vote + 1;
			questionSOValue.votedBy.push(ClassroomContext.userVO.userName);
			
			questionCO.setValue(questionSOValue.questionId, questionSOValue);
			
			questionVoteEventLog(questionSOValue.question, questionSOValue.vote);
		}
		else{
			Alert.show("Voted Already", "Question Session");
		}
			
	}
	else
	{
		Alert.show("Cannot Vote for a self-posted Question", "Question Session");
	}
}

/**
 *
 * @private
 * Audits the "QuestionVote" action, when the current viewer votes for a question
 *
 * @param question - Question text
 * @param votes - New votes
 * @return void
 *
 */
private function questionVoteEventLog(question:String, votes:int):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.questionVote, question, votes + "", null);
	}
}

/**
 *
 * @public
 * This function verifies if the selected question's status is unanswered,
 * if so it marks the same as answered.
 *
 * @return void
 *
 */
public function setQuestionToAnswered():void
{
	if (questionDataGrid.selectedItem == null)
	{
		return;
	}
	var questionObject:QuestionSOValues=new QuestionSOValues(questionDataGrid.selectedItem);
	if (questionObject.questionStatus == QUESTION_UNANSWERED)
	{
		questionObject.questionStatus=QUESTION_ANSWERED;
		
		questionCO.setValue(questionObject.questionId, questionObject);
		
		questionAnswerEventLog(questionObject.question);
	}
}

/**
 *
 * @public
 * This function verifies if the selected question's status is unanswered,
 * if so it marks the same as answered.
 *
 * @return void
 *
 */
public function setQuestionToSkipped():void
{
	if (questionDataGrid.selectedItem == null)
	{
		return;
	}
	var questionObject:QuestionSOValues=new QuestionSOValues(questionDataGrid.selectedItem);
	if (questionObject.questionStatus == QUESTION_UNANSWERED)
	{
		questionObject.questionStatus=QUESTION_SKIPPED;
		
		questionCO.setValue(questionObject.questionId, questionObject);
		
		questionAnswerEventLog(questionObject.question);
	}
}

/**
 *
 * @private
 * Audits the "QuestionAnswer" action, when the presenter marks a question as answered
 *
 * @param question - Question text
 * @return void
 *
 */
private function questionAnswerEventLog(question:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.questionAnswer, question, null, null);
	}
}

/**
 *
 * @private
 * This function verifies the presence of the new question in the question array.
 * If not already present prior to this the Question blink is triggered.
 *
 * @return void
 *
 */
private function checkAndBlinkQuestionTab():void
{
	applicationType::DesktopWeb{
		//If any of the questions in the new shared object are not present in the Array, then we conclude it's a new question and tab should blink
		for (var questionId:String in questionCO.getData())
		{
			if (getQuestionArrayIndex(questionId) == -1 && questionCO.getData()[questionId].postedBy != ClassroomContext.userVO.userName)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.glowQuestionTab();
				break;
			}
		}
	}
}

/**
 *
 * @private
 * The function
 * 		a) seperates the unanswered questions from the answered questions.
 * 		b) next within the unanswered set of questions and answered set of
 * 			questions it sorts the questions in descending order of votes.
 * 		c) lists the unanswered questions in descending order of votes
 * 			followed by answered questions in descending order of votes.
 *
 * @return void
 *
 */
private function setQuestionDataGrid():void
{
	var questionUnansweredArray:ArrayCollection=new ArrayCollection();
	var questionAnsweredArray:ArrayCollection=new ArrayCollection();
	
	for (var questionId:String in questionCO.getData())
	{
		if (questionCO.getData()[questionId].questionStatus == QUESTION_UNANSWERED)
		{
			questionUnansweredArray.addItem(questionCO.getData()[questionId]);
		}
		else
		{
			questionAnsweredArray.addItem(questionCO.getData()[questionId]);
		}
	}
	questionUnansweredArray.source.sortOn("vote", Array.DESCENDING | Array.NUMERIC);
	questionAnsweredArray.source.sortOn("vote", Array.DESCENDING | Array.NUMERIC);
	if (questionUnansweredArray.length != 0)
	{
		questionArray.addAll(questionUnansweredArray);
	}
	if (questionAnsweredArray.length != 0)
	{
		questionArray.addAll(questionAnsweredArray);
	}
	
	questionDataGrid.dataProvider=questionArray;
	applicationType::DesktopWeb{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.questionList = questionArray;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.questionCount = questionArray.length;
	}
	
	questionDataGrid.selectedIndex=getQuestionArrayIndex(lastSelectedQuestionId);	
}

/**
 *
 * @private
 * The function returns the integer value of the sought question id in the question array.
 *
 * @param questionId of type string
 * @return int of type integer
 *
 */
private function getQuestionArrayIndex(questionId:String):int
{
	if (questionArray != null)
	{
		for (var i:int=0; i < questionArray.length; i++)
		{
			if (questionArray.getItemAt(i).questionId == questionId)
			{
				return i;
			}
		}
	}
	return -1;
}

/**
 *
 * @public
 * The function requests confirmation on the delete question command via message box popup.
 *
 * @return void
 *
 */
public function deleteQuestion():void
{
	if (questionDataGrid.selectedItem != null)
	{
		MessageBox.show("Do you want to delete this Question ?", "INFO", MessageBox.MB_OKCANCEL, null, deleteQuestionConfirmed);
	}
}

/**
 *
 * @private
 * The function processes the confirmed delete question command.
 *
 * @param event of type messageboxevent
 * @return void
 *
 */
public function deleteQuestionConfirmed(event:MessageBoxEvent=null):void
{
	if (questionDataGrid.selectedItem != null)
	{
		questionDeleteEventLog(questionDataGrid.selectedItem.question);
		questionCO.setValue(questionDataGrid.selectedItem.questionId, null);
	}
}

/**
 *
 * @private
 * Audits the "QuestionDelete" action, when the presenter deletes a question
 *
 * @param question - Question text
 * @return void
 *
 */
private function questionDeleteEventLog(question:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.questionDelete, question, null, null);
	}
}

/**
 *
 * @public
 * The function is the sync handler for the Question data items.
 * Is performed on establishing new Question Shared objects.
 *
 * @param questionSharedData of type Object
 * @return void
 *
 */
public function questionSyncHandler(questionSharedData:Object):void
{
	if (questionSharedData != null)
	{
		checkAndBlinkQuestionTab();
	}
	questionArray=new ArrayCollection();
	setQuestionDataGrid();
	onClickQuestionGrid();
	//To sync question added in the QuestionComponent with the UserList.Use:To show data in QuestionInterface.
	this.dispatchEvent(new Event("QuestionSync"));
}

/**
 *
 * @private
 * The function is for setting the Answer button's:-
 * 		enable / disable state
 * 		style
 * 		tooltip
 *
 * @param enabled of type boolean
 * @return void
 *
 */
private function enableAnswerButton(enabled:Boolean):void
{
	answerQuestionButton.enabled=enabled;
	answerQuestionButton.setStyle("icon", (enabled)?answer_icon:answerDisabled_icon);
	answerQuestionButton.toolTip=(enabled)?"Answer Question":"Marked as answered";
}

/**
 *
 * @private
 * The function is for setting the Delete button's:-
 * 		enable / disable state
 * 		style
 *
 * @param enabled of type boolean
 * @return void
 *
 */
private function enableDeleteButton(enabled:Boolean):void
{
	deleteQuestionButton.enabled=enabled;
	deleteQuestionButton.setStyle("icon", (enabled)?delete_icon:deleteDisabled_icon);
}

/**
 *
 * @private
 * The function is for setting the Vote button's:-
 * 		enable / disable state
 * 		style
 *
 * @param enabled of type boolean
 * @return void
 *
 */
private function enableVoteButton(enabled:Boolean):void
{
	voteQuestionButton.enabled=enabled;
	voteQuestionButton.setStyle("icon", (enabled)?vote_icon:voteDsiabled_icon);
}

/**
 *
 * @private
 * The function is for setting the Vote button's:-
 * 		enable / disable state
 * 		style
 *
 * @param enabled of type boolean
 * @return void
 *
 */
private function enableQuestionPosting(enabled:Boolean):void
{
	questionInput.enabled=enabled;
	postQuestionButton.enabled=enabled;
}

/**
 *
 * @private
 * The function is for setting the Question interaction based on enabling/disabling question time by moderator/presenter
 *
 * @param enabled of type boolean
 * @return void
 *
 */
//Fix for issue #15363: Changed private to public to access this function in BreakSessionAs.as
public function enableQuestionInteraction(enabled:Boolean,oldValue:Boolean,propertyName:String):void
{
	enableQuestionPosting(enabled)
	enableVoteButton(enabled);
	applicationType::mobile{
		FlexGlobals.topLevelApplication.isQuestionEnable = enabled;
	}
}

/**
 *
 * @private
 * The function is for setting the Answer button's visibility:-
 *
 * @param visible of type boolean
 * @return void
 *
 */
private function visibleAnswerButton(visible:Boolean):void
{
	answerQuestionButton.visible=visible;
	answerQuestionButton.includeInLayout=visible;
}

/**
 *
 * @private
 * The function is for setting the Delete button's visibility:-
 *
 * @param visible of type boolean
 * @return void
 *
 */
private function visibleDeleteButton(visible:Boolean):void
{
	deleteQuestionButton.visible=visible;
	deleteQuestionButton.includeInLayout=visible;
}

/**
 *
 * @private
 * The function is for setting the Vote button's visibility:-
 *
 * @param visible of type boolean
 * @return void
 *
 */
private function visibleVoteButton(visible:Boolean):void
{
	voteQuestionButton.visible=visible;
	voteQuestionButton.includeInLayout=visible;
}

/**
 *
 * @private
 * The function is for setting the Post controles' visibility:-
 *
 * @param visible of type boolean
 * @return void
 *
 */
private function visibleQuestionPosting(visible:Boolean):void
{
	questionInput.visible=visible;
	questionInput.includeInLayout=visible;
	
	postQuestionButton.visible=visible;
	postQuestionButton.includeInLayout=visible;
	
}

/**
 *
 * @public
 * The function is for locating and identifying the selected question on the datagrid.
 * Accordingly on selection set the UI buttons' enable state, style and tooltip
 *
 * @return void
 *
 */
private function onClickQuestionGrid():void
{
	if (questionDataGrid.selectedItem != null)
	{
		var qustion:QuestionSOValues = new QuestionSOValues(questionDataGrid.selectedItem);
		lastSelectedQuestionId=qustion.questionId;
		
		enableDeleteButton(true)
		//Allow voting only on the unanswered questions and on questions posted by others
		enableVoteButton(
			(qustion.questionStatus == QUESTION_UNANSWERED) && 
			(qustion.postedBy !=ClassroomContext.userVO.userName)
		); 
		enableAnswerButton((qustion.questionStatus == QUESTION_UNANSWERED));
	}
	else
	{
		enableDeleteButton(false)
		enableVoteButton(false); 
		enableAnswerButton(false);
	}
}

private function setButtonVisibilityOnRoleChange(roleEvent:RoleChangeEvent):void
{
	setButtonVisibility(roleEvent.newRole);
}


private function setButtonVisibility(role:String):void
{
	visibleAnswerButton(role == Constants.PRESENTER_ROLE);
	visibleDeleteButton(role == Constants.PRESENTER_ROLE);
	visibleQuestionPosting((role == Constants.VIEWER_ROLE) || (ClassroomContext.isModerator && role == Constants.VIEWER_ROLE));
	visibleVoteButton((role == Constants.VIEWER_ROLE) || (ClassroomContext.isModerator && role == Constants.VIEWER_ROLE) );	
	// To make the question buttons enable when presenter enters the class room bug fix for 14504 
	if(role == Constants.PRESENTER_ROLE)
	{		
		setQuestionInteraction(true);		
	}
}

/**
 *
 * @private
 * This function processes the <enter> and <spacebar> keyboard entry's
 *
 * @param event of type KeyboardEvent
 * @return void
 *
 */
private function enterQuestion(event:KeyboardEvent):void
{
	if ((event.keyCode=Keyboard.ENTER) || (event.keyCode=Keyboard.SPACE))
	{
		postQuestion();
		event.stopImmediatePropagation();
	}
}

/**
 *
 * @public
 * This function sets the posting and voting features of questions to enable or disabled state
 * at the MUI shared object
 *
 * @return void
 *
 */
public function setQuestionInteraction(enabled:Boolean):void
{
	questionStatusCO.setValue("EnableQA",enabled);
}


private function onQuestionInteractionStateEvent(event:QuestionInteractionEvent){
	setQuestionInteraction(event.type == QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE);
}
//Fix for Bug#17302:Start
/**
 * @public
 * Get the server's current date and time(taken from wamp server)
 * @param serverDate type of String
 * @return void
 */
public function getServerDateAndTimeResultHandler(serverDate:String):void
{
	var questionSOValue:QuestionSOValues = new QuestionSOValues();
	questionSOValue.questionId = ClassroomContext.userVO.userName + ":" + new Date().time;
	questionSOValue.question = ClassroomContext.userVO.userDisplayName + ": " + StringUtil.trim(questionInput.text);;
	questionSOValue.postedBy = ClassroomContext.userVO.userName;
	var currentDate:Date =  new Date(serverDate);
	serverDate = serverDate.slice(serverDate.indexOf("-")+1 , serverDate.length);
	serverDate = serverDate.slice(0 , serverDate.lastIndexOf(":")) + " " + serverDate.slice(serverDate.lastIndexOf(" ") , serverDate.length);
	questionSOValue.postedTime = serverDate;
	questionSOValue.vote = 0;
	questionSOValue.questionStatus = QUESTION_UNANSWERED;
	
	questionCO.setValue(questionSOValue.questionId, questionSOValue);
	questionAskEventLog(questionSOValue.question);
	
	questionInput.text = "";
	applicationType::DesktopWeb
	{
		questionInput.setFocus();
	}
}

/**
 * @public
 * Handles exception thrown while getting server's date and time
 * @return void
 */
public function getServerDateAndTimeFaultHandler():void
{
	applicationType::DesktopWeb{
		CustomAlert.error("Server not available");
	}
}
//Fix for Bug#17302:End
applicationType::mobile{
	/**
	 * @private
	 *
	 * To show tooltip
	 *
	 * @param event of MouseEvent
	 * @return void
	 */
	private function showTooltip(event:MouseEvent):void
	{
		var tooltip:MobileToolTip = MobileToolTip.open(event.target.toolTip.toString(),event.currentTarget as DisplayObject);
		tooltip.handleToolTipPosition(event.currentTarget as DisplayObject);
	}
}