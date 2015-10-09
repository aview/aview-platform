////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////


/**
 *
 * File			: PollingResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * PollingResultUIHandler.as file is the script handler for PollingResult.mxml
 * This file contains all the functionalities for polling result.
 *
 */

import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionResponseHelper;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;

[Bindable]
/**
 * Arraycollection varaible to store polling results.
 */
public var pollingResultAC:ArrayCollection;


/**
 * Variable to store quiz id
 */
[Bindable]
public var quizId:Number;

//Fix for Bug #19388 
/**
 * Variable to store quiz QuestionId
 */
[Bindable]
public var quizQuestionId:Number;

/**
 * Variable to store question bank question id
 */
[Bindable]
public var qbQuestionId:Number;

//Fix for Bug #11041
/**
 *
 * @public
 * Function : getResultForPollingQuizResultHandler
 * Result handler for 'getResultForPollingQuiz'.
 *
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getResultForPollingQuizResultHandler(result:ArrayCollection):void {
	var tmpquestions:ArrayCollection=new ArrayCollection;
	QuizContext.copyDataByQuizSequence(tmpquestions, result);
	dgPollingQuestionAnswer.dataProvider=tmpquestions;
}

//Fix for Bug #11041
/**
 *
 * @public
 * Function : getResultForPollingQuizFaultHandler
 * Fault handler for 'getResultForPollingQuiz'.
 *
 *
 * @return void
 *
 */
public function getResultForPollingQuizFaultHandler():void {
	//Do Nothing
}

/**
 *
 * @private
 * Function : closePollingResultWindow
 * To remove this display component.
 *
 *
 * @return void
 *
 */
private function closePollingResultWindow():void {
	PopUpManager.removePopUp(this);
}

/**
 *
 * @protected
 * Function : creationCompleteHandler
 * Handler for creationComplete event in this component.
 *
 *
 * @return void
 *
 */
protected function creationCompleteHandler():void {
	this.btnClose.setFocus();
	//Fix for Bug #11041
	dgPollingQuestionAnswer.dataProvider=pollingResultAC;
}

/**
 * @protected
 * Function : refreshClickHandler
 * Click handler for refresh button.
 *
 * @param event type of MouseEvent
 * @return void
 *
 */
//Fix for Bug #19388 
protected function refreshClickHandler(event:MouseEvent):void {
	var quizQuestionResponseHelper:QuizQuestionResponseHelper=new QuizQuestionResponseHelper;
	quizQuestionResponseHelper.getResultForPollingQuiz(quizQuestionId, qbQuestionId,getResultForPollingQuizResultHandler,getResultForPollingQuizFaultHandler)
}
