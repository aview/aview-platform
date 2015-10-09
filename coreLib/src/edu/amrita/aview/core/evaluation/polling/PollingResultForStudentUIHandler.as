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
 * File			: PollingResultForStudentUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * PollingQuestionAnswerUIHandler.as file is the script handler for PollingResultForStudent.mxml
 * This file contains all the functionalities for polling result at student side.
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionHelper;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionResponseHelper;
import edu.amrita.aview.core.evaluation.polling.PollingResult;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxRenderer;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.ListEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

/**
 * Variable to hold custom alert
*/
private var customAlertTemp:Alert;
/**
 * Variable for PollingResult instance.
 */
private var pollResult:PollingResult;

/**
 * Variable used to store question details
 */
[Bindable]
private var questions:ArrayCollection=new ArrayCollection;
/**
 * Question Helper class instance
 */
private var quizQuestionHelper:QuizQuestionHelper;
/**
 * Quiz question response helper class instance
 */
private var quizQuestionResponseHelper:QuizQuestionResponseHelper;
/**
 * Variable to store quiz id
 */
private var quizId:Number;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.evaluation.polling.PollingResultForStudentUIHandler.as");

/**
 *
 * @public
 * Function : initApp
 * Initialization function which calls server function to retrieve data.
 *
 *
 * @return void
 *
 */
public function initializePollingResult():void {
	quizQuestionHelper=new QuizQuestionHelper();
	quizQuestionResponseHelper=new QuizQuestionResponseHelper();
	quizQuestionHelper.getPollingQuizForStudent(ClassroomContext.userVO.userId,getPollingQuizForStudentResultHandler);
}

/**
 *
 * @public
 * Function : getPollingQuizForStudentResultHandler
 * Result handler for server function 'getPollingQuizForStudent'.
 *
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getPollingQuizForStudentResultHandler(result:ArrayCollection):void {
	//Copying to a local variable and assign it to the bindable variable for performance optimization
	var tmpQuestions:ArrayCollection=new ArrayCollection();
	QuizContext.copyDataByQuizSequence(tmpQuestions,result);
	questions=tmpQuestions;
}

/**
 *
 * @public
 * Function : getResultForPollingQuizResultHandler
 * Result handler for getResultForPollingQuiz .
 *
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getResultForPollingQuizResultHandler(result:ArrayCollection):void {
	var i:int;
	if(Log.isInfo()) log.info(""+result);
	var tmpQuestions:ArrayCollection=new ArrayCollection();
	if (result.length > 0) {
		QuizContext.copyDataByQuizSequence(tmpQuestions, result);
		PopUpManager.removePopUp(pollResult);
		pollResult=PollingResult(PopUpManager.createPopUp(this, PollingResult, true));
		//Fix for Bug #11041,19388
		//pollResult.quizId=this.quizId;
		pollResult.quizQuestionId = dgForPollingQuestion.selectedItem.quizQuestionId;
		pollResult.qbQuestionId=dgForPollingQuestion.selectedItem.qbQuestionId;
		pollResult.pollingResultAC=tmpQuestions;
		PopUpManager.centerPopUp(pollResult);
	} else {
		customAlertTemp=CustomAlert.info("No result available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}

//Fix for Bug #11041
/**
 *
 * @public
 * Function : getResultForPollingQuizFaultHandler
 * Fault handler for 'getResultForPollingQuiz'.
 *
 * Do nothing
 *
 * @return void
 *
 */
public function getResultForPollingQuizFaultHandler():void {

}

/**
 *
 * @private
 * Function : toggleSelection
 * Click handler for check box .
 *
 *
 * @return void
 *
 */
private function toggleSelection():void {
	var col:CheckBoxHeaderColumn=dgForPollingQuestion.columns[0];
	if (questions == null) {
		return;
	}
	//PNCR: use conditional operator
	if (col.selected) {
		dgForPollingQuestion.selectedItems=questions.toArray();
	} else {
		dgForPollingQuestion.selectedItems=[];
	}
}

/**
 * @private
 * Function : getSlNo
 * Label function to get the index number.
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getSlNo(oItem:Object, iCol:int):String {
	var iIndex:int=questions.getItemIndex(oItem) + 1;
	return String(iIndex);
}

/**
 *
 * @private
 * Function : showResult
 * Click handler for 'result' button.
 *
 *
 * @return void
 *
 */

private function showResult():void {
	if (dgForPollingQuestion.selectedItems.length != 1) {
		customAlertTemp=CustomAlert.error("Please select one question for viewing result.", "Result", null, this);
		return;
	} else {
		//Fix for Bug #19388 
		quizQuestionResponseHelper.getResultForPollingQuiz(dgForPollingQuestion.selectedItem.quizQuestionId,dgForPollingQuestion.selectedItem.qbQuestionId,getResultForPollingQuizResultHandler,getResultForPollingQuizFaultHandler);
	}
}

/**
 *
 * @private
 * Function : formatCreatedDate
 * To format created date.
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function formatCreatedDate(oItem:Object, iCol:int):String {
	return dateFormatter.format(oItem.createdDate);
}
//Fix for Bug#8861
protected function dgItemClickHandler(event:ListEvent):void 
{
	if (event.columnIndex == 0) 
	{
		(event.itemRenderer as CheckBoxRenderer).dispatchEvent(new MouseEvent("click"));
	}
	event.stopPropagation();
}
