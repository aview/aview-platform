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
 * File			: StudentAnswerSheetUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Thirumalai murugan
 *
 * StudentAnswerSheetUIHandler.as acts as handler for StudentAnswerSheet.mxml
 */
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionResponseHelper;
import edu.amrita.aview.core.evaluation.vo.QuizResponseVO;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

/**
 * Quiz id selected by user for viewing result
 */
[Bindable]
public var quizIdForStudentAns:Number=0;

/**
 * Value Object of QuizVO
 */
[Bindable]
public var quizVO:QuizVO;

/**
 * List of quiz questions
 */
[Bindable]
public var questions:ArrayCollection;

/**
 * Value Object of QuizResponseVO
 */
[Bindable]
private var quizResponseVO:QuizResponseVO;

/**
 * Calls the remote method
 */
private var quizQuestionResponseHelper:QuizQuestionResponseHelper;
/**
 * Icon class for tick image
 */
[Embed(source="assets/images/tick-icon.png")]
private var iconClass:Class;
/**
 * @public
 * Get the answer sheet of the student
 *
 * @param event type of ResultEvent
 * @return void
 */
public function getStudentAnswerSheetResultHandler(event:ResultEvent):void {
	var tempAnswerArray:ArrayCollection=new ArrayCollection();
	var tmpQuestions:ArrayCollection=new ArrayCollection();
	quizResponseVO=event.result.quizResponse;
	tempAnswerArray=event.result.quizQuestions as ArrayCollection;
	QuizContext.copyDataByQuizSequence(tmpQuestions, tempAnswerArray);
	questions=tmpQuestions;
}

/**
 * @private
 * Calls the remote method to get the answer sheet of a user
 *
 * @return void
 */
private function initAppStudentAnswerSheet():void {
	
	this.title = quizVO.userName + "'s Answersheet "; 
	quizQuestionResponseHelper=new QuizQuestionResponseHelper();
	quizQuestionResponseHelper.getStudentAnswerSheet(quizIdForStudentAns, quizVO.userName,getStudentAnswerSheetResultHandler);
}

/**
 * @private
 * Removes a pop up component
 *
 * @return void
 */
//PNCR: removeMe function is used in many other packages and files. Check whether we can use a common global function for this. 
private function closeStudentAnswerSheet():void 
{
	PopUpManager.removePopUp(this);
}
