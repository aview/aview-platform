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
 * File			: LiveQuestionPaperPreviewUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * LiveQuestionPaperPreviewUIHandler acts as handler for LiveQuestionPaperPreview.mxml
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.QuizCreatedEvent;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.quiz.CreateQuizComponent;
import edu.amrita.aview.core.evaluation.quiz.LiveQuizResult;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

/**
 * Value Object
 */
private var questionPaperVO:QuestionPaperVO;
/**
 * Used to invoke the quiz component
 */
private var quizInst:CreateQuizComponent;
/**
 * Constant for view result state
 */
private const VIEW_RESULT_STATE : String = "viewResult";
/**
 * Constant for list result state
 */
private const LIST_RESULT_STATE : String = "listResult";
/**
 * Constant for quiz result title
 */
private const QUIZ_RESULT_TITLE : String = "Quiz Result : ";

/**
 * @public
 * Sets the initial data , when this component is invoked
 * @param questionPaperVO of type QuestionPaperVO
 * @return void
 */
public function initLiveQPPreview(questionPaperVO:QuestionPaperVO):void {
	previewBox.questionPaperVO=questionPaperVO;
	this.questionPaperVO=questionPaperVO;
	ClassroomContext.questionPaperId=questionPaperVO.questionPaperId;
}

/**
 * @public
 * Gets active quizzes for a question paper
 * @param result of type ArrayCollection
 * @return void
 *
 */
public function getAllActiveQuizzesForQuestionPaperResultHandler(result:ArrayCollection):void {
	//To set result button enabled
	setResultButtonEnabled(true);
	// If no result is returned , display an alert
	if (result.length == 0) {
		CustomAlert.info("No result available", QuizContext.ALERT_TITLE_INFORMATION );
	}
	// Else display the quiz result
	else {
		var resultWindow:LiveQuizResult=new LiveQuizResult();
		resultWindow.addEventListener(FlexEvent.REMOVE, closeLiveQuizResultWindowHandler);
		//PNCR: Title string part should be in global constant. (It is using in other place, please change there also.)
		resultWindow.title= QUIZ_RESULT_TITLE + questionPaperVO.questionPaperName;
		// if there is a single quiz in the result returned then display the result
		//Fix for Bug #15857 : Code commented
		/*if (result.length == 1) {
			resultWindow.quizVO = result[0] as QuizVO;
			resultWindow.currentState = VIEW_RESULT_STATE ;
		}*/
		// else display the list of quizzes
		/*else {*/
			resultWindow.quizzesArray = result
			resultWindow.currentState = LIST_RESULT_STATE;
		/*}*/
		//Fix for Bug #10691
		PopUpManager.addPopUp(resultWindow, FlexGlobals.topLevelApplication.mainApp.mainComponentContainer, true);
		PopUpManager.centerPopUp(resultWindow);
	}
}

/**
 * @public
 * Fault handler for getting active quizzes for question paper
 *
 * @return void
 */
public function getAllActiveQuizzesForQuestionPaperFaultHandler():void {
	setResultButtonEnabled(true);
}

/**
 * @private
 * Starts a quiz in live classroom
 *
 * @return void
 */
private function sendLiveQuiz():void {
	//To set start quiz button disabled
	setStartQuizButtonEnabled(false);

	// Allow creation of quiz , only if the question paper is complete
	// else display an error
	if (questionPaperVO.isComplete == QuizContext.YES) {
		quizInst=new CreateQuizComponent();
		quizInst.addEventListener(QuizCreatedEvent.QUIZ_CREATED, quizCreatedHandler);
		quizInst.addEventListener(FlexEvent.REMOVE, startQuizWindowRemoveHandler);
		quizInst.flagMainPage=true;
		PopUpManager.addPopUp(quizInst, this, true);
		PopUpManager.centerPopUp(quizInst);
		quizInst.txtInpQuizName.setFocus();
		quizInst.initApp(null);
	} else {
		//To set start quiz button enabled
		setStartQuizButtonEnabled(true);
		//Fix for Bug #11375
		CustomAlert.error("The selected question paper is not valid, Please validate.", "Information", null, this);
	}
}

/**
 * @private
 * Handler to store quiz details which is started in the classroom session.
 * Execute after successful quiz creation.
 * @param event of type QuizCreatedEvent
 * @return void
 *
 */
private function quizCreatedHandler(event:QuizCreatedEvent):void {
	// Initialise the array collection
	//Fix for Bug #15857 : Code commented
	/*if (ClassroomContext.conductedLiveQuizzes == null) {
		ClassroomContext.conductedLiveQuizzes=new ArrayCollection;
	}
	// Remove the quizzes that are already conducted
	for (var i:int=0; i < ClassroomContext.conductedLiveQuizzes.length; i++) {
		if (ClassroomContext.conductedLiveQuizzes[i].questionPaperId == event.quiz.questionPaperId) {
			ClassroomContext.conductedLiveQuizzes.removeItemAt(i);
			break;
		}
	}
	ClassroomContext.conductedLiveQuizzes.addItem(event.quiz);*/
	btnQuizResult.visible=true;

}

/**
 * @private
 * Used to display the live quiz result.
 *
 * @return void
 */
private function showLiveQuizResult():void {
	//Fix for Bug #10647
	setResultButtonEnabled(false);

	/* Flag to check if the quiz was attended */
	var resultFlag:Boolean=false;
	//Fix for Bug #15857 : Code commented
	/*for (var i:int=0; i < ClassroomContext.conductedLiveQuizzes.length; i++) {
		// Show the quiz result if the question paper matches the current question paper
		if (questionPaperVO.questionPaperId == ClassroomContext.conductedLiveQuizzes[i].questionPaperId) {
			resultFlag=true;
			var resultWindow:LiveQuizResult = new LiveQuizResult();
			resultWindow.quizVO = ClassroomContext.conductedLiveQuizzes[i];
			//Fix for Bug #10691
			resultWindow.title = QUIZ_RESULT_TITLE + ClassroomContext.conductedLiveQuizzes[i].quizName;
			resultWindow.addEventListener(FlexEvent.REMOVE, closeLiveQuizResultWindowHandler);
			resultWindow.currentState=VIEW_RESULT_STATE;
			//Fix for Bug #10691
			PopUpManager.addPopUp(resultWindow, FlexGlobals.topLevelApplication.mainApp.mainComponentContainer, true);
			PopUpManager.centerPopUp(resultWindow);
			break;
		}
	}*/
	// If the quiz result is not found , get active quizzes for the question paper
	if (!resultFlag) {
		var quizHelper:QuizHelper=new QuizHelper;
		quizHelper.getAllActiveQuizzesForQuestionPaper(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,getAllActiveQuizzesForQuestionPaperResultHandler,getAllActiveQuizzesForQuestionPaperFaultHandler);
	}
}


/**
 * @private
 * Handles the changes to be done after the  the live quiz result component is closed
 * @param e type of Event
 * @return void
 *
 */
private function closeLiveQuizResultWindowHandler(e:Event):void {
	setResultButtonEnabled(true);
}

/**
 * @private
 * To set result quiz button enabled/disabled
 * @param flag type of Boolean
 * @return void
 *
 */
private function setResultButtonEnabled(flag:Boolean):void {
	btnQuizResult.enabled=flag;
}

/**
 * @private
 * To set start quiz button enabled/disabled
 * @param flag of type Boolean
 * @return void
 */
private function setStartQuizButtonEnabled(flag:Boolean):void {
	btnSend.enabled=flag;
}

/**
 * @private
 * Action to be done when the live quiz window is closed
 * @param e type of Event
 * @return void
 */
private function startQuizWindowRemoveHandler(e:Event):void {
	setStartQuizButtonEnabled(true);
}
