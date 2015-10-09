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
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.components.userList.QuestionInterface;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

[Bindable]
private var status_icon_source:Class;

[Bindable]
private var question_icon_source:Class=null;
[Bindable]
[Embed(source="assets/images/PTT_status_talk.png")]
public var mic_Talk_Icon:Class;

[Bindable]
[Embed(source="assets/images/PTT_status_mute.png")]
public var mic_Mute_Icon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/handRaiseWaitingStatus.png")]
public var ask_Question_Req:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/presenterControlRequestStatus.png")]
public var presenter_Req:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/micActive.png")]
public var audioActive:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/micMute.png")]
public var audioMute:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/videoActive.png")]
public var videoActive:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/videoMute.png")]
public var videoMute:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/noVideoAudio.png")]
public var NoVideoAudio:Class;


public var questInterface:QuestionInterface;

[Bindable]
[Embed(source="/edu/amrita/aview/core/shared/components/userList/assets/images/questionIcon.png")]
public var questionIcon:Class;

[Bindable]
private var handraiseStatus:Boolean=false;

[Bindable]
/**
 * Stores all questions posted by selected user.
 */
private var questions:ArrayCollection = new ArrayCollection();
[Bindable]
private var unAnsweredQuestionExists:Boolean = false;
/**
 * @private
 * 
 */
private function changeICon():void
{
	// AKCR: please use a switch statement here. It would be faster and lot more readable
	if (this.data.userStatus == Constants.WAITING)
	{
		question_icon_source=ask_Question_Req;
		iconQuestion.toolTip="User is requesting interaction";
	}
	else if (this.data.controlStatus == Constants.PRSNTR_REQUEST)
	{
		question_icon_source=presenter_Req;
		iconQuestion.toolTip="User is requesting to be made as a presenter";
	}
	else if (this.data.userStatus == Constants.ACCEPT && this.data.userTalkStatus == Constants.FREETALK)
	{
		question_icon_source=mic_Talk_Icon;
		iconQuestion.toolTip="User is interacting";
	}
	else if (this.data.userStatus == Constants.ACCEPT)
	{
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp==null || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp==null)
			return;
		if (this.data.id == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getAudioMuteSOValue())
		    question_icon_source=mic_Talk_Icon;
		else
		question_icon_source=mic_Mute_Icon;
	}
	else
	{
		question_icon_source=null;
	}
	getQuestions();
	/*if(this.data.isVideoPublishing)
	{
		if(this.data.isAudioOnlyMode)
		{
			status_icon_source=audioActive;
			
			if(this.data.isAudioMute)
				status_icon_source=audioMute;
			
		}
		else
		{
			status_icon_source=videoActive;
			if(this.data.isVideoHide)
			{
			if(this.data.isAudioMute)
			  status_icon_source=audioMute;
			else
				status_icon_source=audioActive;
			}
			else
			{
				if(this.data.isAudioMute)
					status_icon_source=audioMute;
				else
					status_icon_source=videoActive;
			}
			
		}
	}
	else
	{
	status_icon_source=NoVideoAudio;
	}*/

}
protected function showQuestionInterface():void
{
	if(question_icon_source != presenter_Req && question_icon_source!=mic_Talk_Icon && question_icon_source!=mic_Mute_Icon &&
	(ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName || ClassroomContext.isModerator))
	{
		getQuestions();
		questInterface=null;
			questInterface = new QuestionInterface();
			if(unAnsweredQuestionExists)
			{
				questInterface.selectedIndex=0;
				questInterface.userStatus = this.data.userStatus;
			}
			else
			{
				questInterface.selectedIndex=1;
				questInterface.displayName = this.data.userDisplayName;
			}
			//Fix for Bug#17605
			questInterface.userName = this.data.id;
			questInterface.addEventListener("QuestionInterfaceRemoved",removeQuestionIcon);
			questInterface.questions = questions;
			PopUpManager.addPopUp(questInterface,FlexGlobals.topLevelApplication as DisplayObject,true);
			var point:Point=localToGlobal(new Point(mouseX, mouseY));
			questInterface.move(point.x, point.y-30);
	}
}

/**
 * @private
 * Get all questions posted by selected user
 * @return void 
 * 
 */
private function getQuestions():void
{
	try
	{
	var tmpQuestions:ArrayCollection = new ArrayCollection(); 
	var tmpQuestionsMasterArray:ArrayCollection = new ArrayCollection(); 
	var question:Object = null;
	tmpQuestionsMasterArray = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.questionList;
	
	for(var i:int = 0;i < tmpQuestionsMasterArray.length;i++)
	{
		question = tmpQuestionsMasterArray[i];
		//Checking whether question is posted by selected user
		if(question.postedBy == this.data.id)
		{
			tmpQuestions.addItem(question);
		}
	}
	questions = tmpQuestions;
	checkIconQuestionVisibility();
	}
	catch (e:Error)
	{
		
	}
}
private function getIconSeperatorVisibility():Boolean
{
	var returnValue:Boolean = false;
	if(status_icon_source!=null && iconQuestion.visible)
	{
		returnValue = true;
	}
	return returnValue;
}
private function checkIconQuestionVisibility():void
{
	var questionIconVisibilityFlag:Boolean = false;
	/*if (this.data.id == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getAudioMuteSOValue())
	{
		question_icon_source=mic_Talk_Icon;
		questionIconVisibilityFlag=true;
	}
	else
	{
		question_icon_source=mic_Mute_Icon;
		questionIconVisibilityFlag=true;
	}*/
	//Fix for Bug#17965 : Handraise icon and QuestionInterface icon is visible to both moderator and presenter
	if(question_icon_source!=mic_Talk_Icon && question_icon_source!=mic_Mute_Icon)
	{
	if(ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName || ClassroomContext.isModerator)
	{
		var question:Object = null;
		//Fix for Bug#18121
		unAnsweredQuestionExists = false;
		for(var i:int = 0;i < questions.length;i++)
		{
			question = questions[i];
			if(question.questionStatus == "UNANSWERED")
			{
				questionIconVisibilityFlag = true;
				unAnsweredQuestionExists = true;
				question_icon_source = questionIcon;
				iconQuestion.toolTip="User has a question, click to view";
				break;
			}
		}
		//Fix for Bug#17262
		/*if(this.data.userStatus == Constants.WAITING)
		{
			questionIconVisibilityFlag = true;
			question_icon_source = ask_Question_Req;
		}*/
		if(this.data.controlStatus == Constants.PRSNTR_REQUEST)
		{
			questionIconVisibilityFlag = true;
			question_icon_source = presenter_Req;
		    iconQuestion.toolTip="User is requesting to be made as a presenter";
		}
	}
	else
	{
		questionIconVisibilityFlag = false;
	}
	//Fix for Bug#17262
	if(this.data.userStatus == Constants.WAITING)
	{
		questionIconVisibilityFlag = true;
		question_icon_source = ask_Question_Req;
		iconQuestion.toolTip="User is requesting interaction";
	}
	}
	else
	{
		questionIconVisibilityFlag = true;
	}
	setIconQuestionVisibility(questionIconVisibilityFlag);
}
private function removeQuestionIcon(e:Event):void
{
	setIconQuestionVisibility(false);
	unAnsweredQuestionExists =  false;
	questInterface.removeEventListener("QuestionInterfaceRemoved",removeQuestionIcon);
	//Fix for Bug#17245
	getQuestions();
}
private function setIconQuestionVisibility(value:Boolean):void
{
	iconQuestion.visible = iconQuestion.includeInLayout = value;
}