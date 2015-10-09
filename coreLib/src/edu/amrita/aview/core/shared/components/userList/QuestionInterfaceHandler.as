import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.components.userList.QuestionInterface;
import edu.amrita.aview.core.shared.components.userList.StatusIconRenderer;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

[Bindable]
public var selectedIndex:int=0;

[Bindable]
public var i:int=0;

[Bindable]
public var deleteq:int=0;
[Bindable]
public var displayName:String='';
[Bindable]
public var flag:Boolean=false;

[Bindable]
public var remainingQuestions:int=0;

[Bindable]
public var userName:String='';
[Bindable]
private var questionIndex:int=0;
[Bindable]
public var userStatus:String='';

[Bindable]
public var questionDeleteIndex:int=0;

[Bindable]
public var questInter:StatusIconRenderer;


[Bindable]
[Embed(source='edu/amrita/aview/core/shared/components/userList/assets/images/questionInteract.png')]
public var interactionActionIconStart:Class;

[Bindable]
[Embed(source='edu/amrita/aview/core/shared/components/userList/assets/images/questionInteractstop.png')]
public var interactionActionIconStop:Class;

/**
 * Stores all questions posted by selected user.
 */
[Bindable]
public var questions:ArrayCollection = new ArrayCollection();

private function escapeQuesionInterface(e:KeyboardEvent):void
{
	if(e.keyCode==27)
		questionInterfaceCloseHandler()
}

private function nextQuestion():void
{
	trace(questions.length.toString());
	if(questionIndex < (questions.length - 1))
	{
		questionDeleteIndex = questionIndex+1;
		questionIndex=questionIndex+1;
		btnPrevious.visible=true;
		if(questionIndex==(questions.length - 1))
			btnNext.visible=false;
		else
			btnNext.visible=true;
	}
	else
	{
		questionIndex=questions.length - 1;
		btnPrevious.visible=true;
		btnNext.visible=false;
	}
	if(questions[questionIndex].questionStatus=='ANSWERED')
	{
		vskQuestionStatus.selectedIndex=1;
	}
	else if(questions[questionIndex].questionStatus=='UNANSWERED')
	{
		vskQuestionStatus.selectedIndex=0;
	}
	else
	{
		vskQuestionStatus.selectedIndex=2;
	}
	
}

private function previousQuestion():void
{
	if(questionIndex > 0)
	{
		questionIndex=questionIndex-1;
		//btnPrevious.visible=true;
		btnNext.visible=true;
		if(questionIndex==0)
			btnPrevious.visible=false;
		else
			btnPrevious.visible=true;
	}
	else
	{
		questionIndex=0;
		btnPrevious.visible=false;
		btnNext.visible=true;
	}
	if(questions[questionIndex].questionStatus=='ANSWERED')
	{
		vskQuestionStatus.selectedIndex=1;
	}
	else if(questions[questionIndex].questionStatus=='UNANSWERED')
	{
		vskQuestionStatus.selectedIndex=0;
	}
	else
	{
		vskQuestionStatus.selectedIndex=2;
	}
}

private function remainingQuestionCount():void
{
	remainingQuestions=0;
	for(i=0;i<questions.length;i++)
	{
		if(questions[i].questionStatus!='ANSWERED' && questions[i].questionStatus!='SKIPPED')
			remainingQuestions+=1;
		
		
		
	}
}

private function setQuestionToAnswered():void
{
	//Fix for Bug#17350
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.questionDataGrid.selectedItem=questions[questionIndex];
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.setQuestionToAnswered();
	questions[questionIndex].questionStatus='ANSWERED';
	remainingQuestionCount();
	if( remainingQuestions>0)
	{
	if(questions.length>1)
	{
		if(questions.length!=(questionIndex+1))
		{
			nextQuestion();
		}
		else
		{
			//PopUpManager.removePopUp(this);
			//Fix for Bug#17245
			previousQuestion();
			//
		}
	}
	else if(questions.length==1)
	{
		
		PopUpManager.removePopUp(this);
		this.dispatchEvent(new Event("QuestionInterfaceRemoved"));
		
	}
	}else
	{
		PopUpManager.removePopUp(this);
		this.dispatchEvent(new Event("QuestionInterfaceRemoved"));
	}
	
}



private function startInteraction():void
{
	if(userStatus==Constants.ACCEPT)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.rejectViewer();
		btnInteraction.source = interactionActionIconStop;
		btnInteraction.toolTip="Start Interaction with the user";
		
	}
	else
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.acceptViewer();
		btnInteraction.source = interactionActionIconStart;
		btnInteraction.toolTip="Stop Interaction with the user";
	}
	PopUpManager.removePopUp(this);
}
private function deleteQuestion():void
{
	//Fix for Bug#17429
	flag=false;
	if(questionDeleteIndex==0)
		questionDeleteIndex = questionIndex+1;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.questionDataGrid.selectedItem=questions[questionIndex];
	MessageBox.show("Do you want to delete this Question ?", "INFO", MessageBox.MB_OKCANCEL, null, deleteConfirm)
	/*if(flag){	
	questions.removeItemAt(questionIndex);	}*/
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.deleteQuestion();
	//Fix for Bug#17429
	
	//PopUpManager.removePopUp(this);
	
		
	
}

private function deletion():void
{
	
	
	
	if(questions.length>0)
	{
		if(deleteq>=questions.length)
			questionIndex=deleteq-1;
		else
			questionIndex=deleteq;
		
		if(questions.length==1)
		{
			btnPrevious.visible=false;
			btnNext.visible=false;
			
		}
		else
		{
			if(questionIndex>0)
			{
				if(questionIndex<questions.length-1)
				{
				btnPrevious.visible=true;
				btnNext.visible=true;
				}
				else
				{
					btnPrevious.visible=true;
					btnNext.visible=false;
				}
			}
			
			else if(questionIndex==0)
			{
				btnNext.visible=true;
				btnPrevious.visible=false;
			}
		}
		
		if(questions[questionIndex].questionStatus=='ANSWERED')
		{
			vskQuestionStatus.selectedIndex=1;
		}
		else if(questions[questionIndex].questionStatus=='UNANSWERED')
		{
			vskQuestionStatus.selectedIndex=0;
		}
		else
		{
			vskQuestionStatus.selectedIndex=2;
		}
	}
	
}

private function deleteConfirm(event:MessageBoxEvent):void
{
	setTimeout(deletion,33);
	flag=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.deleteQuestionConfirmed();

	deleteq=questionIndex;
	
	
	
	if(questions.length>1)
	{
		if(questionIndex>0)
			previousQuestion();
		else
		{  
			nextQuestion();
		}
		
	}
	else if(questions.length==1)
	{
		questionInterfaceCloseHandler();	
	}
	
		if(questions[questionIndex].questionStatus=='ANSWERED')
		{
			vskQuestionStatus.selectedIndex=1;
		}
		else if(questions[questionIndex].questionStatus=='UNANSWERED')
		{
			vskQuestionStatus.selectedIndex=0;
		}
		else
		{
			vskQuestionStatus.selectedIndex=2;
		}
	
		questions.removeItemAt(deleteq);
		//nextQuestion();
/*	if(questions.length>1) //commented these codes to fix bug #17252
	{	
		
	//	questionIndex=(questionIndex%questions.length)+1;
		questionDeleteIndex = (questionIndex%questions.length)+1;
			
			if(questionIndex>=questions.length-1)
				questionIndex=0;
			else
				questionIndex=(questionIndex+1)%questions.length;
			
			
		if(!questionIndex)
		{
			btnPrevious.visible=false;
			btnNext.visible=true;
		}			
		else{
			btnPrevious.visible=true;
		if(questionIndex<questions.length)
			btnNext.visible=true;
		}
		
		if(questionIndex>=questions.length-1){
			btnNext.visible=false;
			btnPrevious.visible=true;	
			
		}
		else{
			btnNext.visible=true;
		
		
		}
		
		
		if(questions[questionIndex].questionStatus=='ANSWERED')
		{
			vskQuestionStatus.selectedIndex=1;
		}
		else if(questions[questionIndex].questionStatus=='UNANSWERED')
		{
			vskQuestionStatus.selectedIndex=0;
		}
		else
		{
			vskQuestionStatus.selectedIndex=2;
		}
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.questionDataGrid.selectedItem=questions[questionIndex];
	}
	else if(questions.length==0)
	{
		questionInterfaceCloseHandler();	
	}
	else 
	{
		
		if(questionIndex>=questions.length){
			questionIndex=(questionIndex%questions.length);}
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.questionDataGrid.selectedItem=questions[questionIndex];
		
		btnPrevious.visible=false;
		btnNext.visible=false;
		
		if(questions[questionIndex].questionStatus=='ANSWERED')
		{
			vskQuestionStatus.selectedIndex=1;
		}
		else if(questions[questionIndex].questionStatus=='UNANSWERED')
		{
			vskQuestionStatus.selectedIndex=0;
		}
		else
		{
			vskQuestionStatus.selectedIndex=2;
		}
	}
	
/*	else if(questions.length>questionIndex)
	{
		
		if(questionIndex < questions.length)
		{
			//questionIndex=questionIndex+1;
			btnPrevious.visible=false;
			
				btnNext.visible=false;
			
		}
		else
		{
			questionIndex=questions.length;
			btnPrevious.visible=true;
			btnNext.visible=false;
		}
		if(questions[questionIndex].questionStatus=='ANSWERED')
		{
			vskQuestionStatus.selectedIndex=1;
		}
		else if(questions[questionIndex].questionStatus=='UNANSWERED')
		{
			vskQuestionStatus.selectedIndex=0;
		}
		else
		{
			vskQuestionStatus.selectedIndex=2;
		}
		
	}
	else
	{
		if(questions.length==0)
		{
			PopUpManager.removePopUp(this);
			this.dispatchEvent(new Event("QuestionInterfaceRemoved"));
		}
		else if(questionIndex==questions.length)
		{
			questionIndex=0;
			btnPrevious.visible=false;
			if(questions[questionIndex].questionStatus=='ANSWERED')
			{
				vskQuestionStatus.selectedIndex=1;
			}
			else if(questions[questionIndex].questionStatus=='UNANSWERED')
			{
				vskQuestionStatus.selectedIndex=0;
			}
			else
			{
				vskQuestionStatus.selectedIndex=2;
			}
		}
		
	}*/
}


private function skipQuestion():void 
{
	for(var i:int=0;i<questions.length;i++)
	{
		//Fix for Bug#17317
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.questionDataGrid.selectedItem=questions[i];
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.setQuestionToSkipped();
	}
	this.dispatchEvent(new Event("QuestionInterfaceRemoved"));
	PopUpManager.removePopUp(this);
}
private function ignoreHandraise():void
{
	this.dispatchEvent(new Event("QuestionInterfaceRemoved"));
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setUserStatus(userName,Constants.HOLD);
	PopUpManager.removePopUp(this);
}
private function getQuestionDetails(value:String):String
{
	var str:String = value;
	var strQuestion:String = '';
		//trace (str.indexOf(":"))
	//arrArray=str.split(":",2);
	//return arrArray[1];
	strQuestion = str.substr(str.indexOf(":")+1,str.length);
	 
	 return strQuestion;
}
private function creationComplete():void
{
	this.setFocus();
	//Fix for Bug#17605:Start
	if(ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName && userName == ClassroomContext.userVO.userName)
	{
		btnInteraction.visible = btnInteraction.includeInLayout = false;
	}
	else
	{
		//Fix for Bug#17605:End
		if(userStatus==Constants.ACCEPT)
		{
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.rejectViewer();
			btnInteraction.source = interactionActionIconStop;
			btnInteraction.toolTip="Stop Interaction with the user";
			
		}
		else
		{
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.acceptViewer();
			btnInteraction.source = interactionActionIconStart;
			btnInteraction.toolTip="Start Interaction with the user";
		}
	}
	//PopUpManager.removePopUp(this);
	
}
//Fix for Bug#17245:Start
private function questionInterfaceCloseHandler():void
{
	this.dispatchEvent(new Event("QuestionInterfaceRemoved"));
	PopUpManager.removePopUp(this);
}
//Fix for Bug#17245:End