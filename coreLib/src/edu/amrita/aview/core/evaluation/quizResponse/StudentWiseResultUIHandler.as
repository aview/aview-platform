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
 * File			: StudentWiseResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Thirumalai murugan
 *
 * StudentWiseResultUIHandler.as file is the script handler for StudentWiseResult.mxml
 * This file contains all the functionalities for student wise result.
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.quizResponse.StudentAnswerSheet;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
/**
 * Instance of quiz vo class component
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO();

/**
 * List of quiz result : users , total score etc
 */
[Bindable]
private var quizResult:ArrayCollection=new ArrayCollection();

/**
 * Instance of quiz helper class component
 */
private var quizHelper:QuizHelper;

/**
 * Used in setter/getter
 */
private var _quizId:int=0;
/**
 * Instance of student answer sheet component
 */
private var studentAnswerSheet:StudentAnswerSheet;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quizResponse.StudentWiseResultUIHandler.as");

/**
 * @public
 * Getter function to get quiz id
 *
 * @return int
 */
public function get quizId():int {
	return _quizId;
}

/**
 * @public
 * Setter function to set quiz id
 *
 * @param quiz_id type of int
 * @return void
 */
public function set quizId(quiz_id:int):void {
	this._quizId=quiz_id;
}

/**
 * @private
 * Calls the remote method to populate the dataprovider of the datagrid .
 *
 * @return void
 */
private function creationCompleteHandler():void {
	quizHelper=new QuizHelper();
	var userId:Number=ClassroomContext.userVO.userId;
	quizHelper.getQuizResultForStudent(quizId, userId,getQuizResultForStudentResultHandler);
}

/**
 * @private
 * Gets the serial nos. for datagrid column
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function getSlNo(oItem:Object, iCol:int):String {
	var iIndex:int=quizResult.getItemIndex(oItem) + 1;
	return String(iIndex);
}

/**
 * @public
 * Gets the result of a user : users, total score etc
 *
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuizResultForStudentResultHandler(result:ArrayCollection):void {
	if ((result != null) && (result.length != 0)) {
		quizResult=result;
		if(Log.isInfo()) log.info("getQuizStudentResult_resultHandler " + quizResult);
	} else {
		CustomAlert.info("No Result Available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}

/**
 * @private
 * Gets the marks
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return Number
 */
private function getMarks(oItem:Object, iCol:int):Number {
	if(Log.isDebug()) log.debug("getQnType::oItem::" + oItem);
	for (var i:int=0; i < quizResult.length; i++) {
		// Fixed Bug 4858 . Added checking for user id if multiple user attend same quiz
		if ((oItem.userId == quizResult[i].userId) && (oItem.quizId == quizResult[i].quizId)) {
			oItem.score=(Math.round(quizResult[i].score * 100) / 100);
			return oItem.score;
		}
	}
	return oItem.score;
}

/**
 * @private
 * Gets the wrong answer
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return Number
 */
private function getWrongAnswer(oItem:Object, iCol:int):Number {
	if(Log.isDebug()) log.debug("getQnType::oItem::" + oItem);
	for (var i:int=0; i < quizResult.length; i++) {
		if ((oItem.userId == quizResult[i].userId) && (oItem.quizId == quizResult[i].quizId)) {
			//Fix for Bug# 10671, 10616
			oItem.wrongAnswerCount=quizResult[i].attemptedQuestions - quizResult[i].fraction;
			return oItem.wrongAnswerCount;
		}
	}
	return oItem.wrongAnswerCount;
}

/**
 * @private
 * Gets the number of unattempted questions
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return Number
 */
//Fix for Bug# 10671, 10616
private function getUnattemptedQuestions(oItem:Object, iCol:int):Number {
	if(Log.isDebug()) log.debug("getQnType::oItem::" + oItem);
	for (var i:int=0; i < quizResult.length; i++) {
		if ((oItem.userId == quizResult[i].userId) && (oItem.quizId == quizResult[i].quizId)) {
			var unAttemptedQuestionsCount:Number=quizResult[i].countQuizQuestionId - quizResult[i].attemptedQuestions;
			return unAttemptedQuestionsCount;
		}
	}
	return unAttemptedQuestionsCount;
}

/**
 * @private
 * Displays the answer sheet of the user
 *
 * @return void
 */
private function viewStudentAnswerSheet():void {
	if (teacherResultDg.selectedIndex != -1) {
		studentAnswerSheet=StudentAnswerSheet(PopUpManager.createPopUp(this, StudentAnswerSheet, true));
		studentAnswerSheet.quizIdForStudentAns=teacherResultDg.selectedItem.quizId;
		studentAnswerSheet.quizVO=quizVO;
		studentAnswerSheet.quizVO.userName=teacherResultDg.selectedItem.userName;
		PopUpManager.centerPopUp(studentAnswerSheet);
	}
}

/**
 * @private
 * Displays the tool tip on mouse roll over the datagrid
 *
 * @return void
 */
private function addTooltip():void {
	teacherResultDg.toolTip="Double click a row to view answersheet";
}

/**
 * @private
 * Remove the tool tip on mouse roll out of the datagrid
 *
 * @return void
 */
private function removeTooltip():void {
	teacherResultDg.toolTip="";
}
