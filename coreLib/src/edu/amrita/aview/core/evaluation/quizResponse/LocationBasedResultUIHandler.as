
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
 * File			: LocationBasedResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Thirumalai murugan
 *
 * LocationBasedResultUIHandler.as acts as handler for LocationBasedResult.mxml
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import mx.collections.ArrayCollection;

/**
 *  Variable to hold instance of QuizHelper
 */
private var quizHelper:QuizHelper;

/**
 * Variable is used for getter/setter quizId
 */
private var _quizId:int=0;

/**
 * Nos. of students registered for a quiz
 */
private var totalStudents:Number=0;

// Swati :: Not necessary to change the name , it specifies its purpose
/**
 * Nos. of students attempted the quiz from PC
 */
private var totalLocalStudent:Number=0;

// Swati :: Not necessary to change the name , it specifies its purpose
/**
 * Nos. of students attempted the quiz from Mobile
 */
private var totalRemoteStudent:Number=0;

// Swati :: Quiz response is the result , for GUI its result , but the collection consists of quiz response object
/**
 * Variable to list quiz response for a quiz
 */
[Bindable]
private var quizResult:ArrayCollection=new ArrayCollection();

/**
 * Variable which stores details of location based result like response type ,
 * nos.of students  and correct answers
 */
[Bindable]
private var locationBasedACForChart:ArrayCollection=new ArrayCollection();

/**
 * Value Object of type quiz
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO();

/**
 * Constant for response type : local
 */
private const RESPONSE_TYPE_LOCAL : String = "Local";

/**
 * Constant for response type : remote
 */
private const RESPONSE_TYPE_REMOTE : String = "Remote";

/**
 *
 * @public
 * Getter to get quiz id
 *
 *
 * @return int
 *
 */
public function get quizId():int {
	return _quizId;
}

/**
 *
 * @public
 * Setter to set quiz id
 * 
 * @param tempQuizId type of int
 * @return void
 *
 */
public function set quizId(tempQuizId:int):void {
	this._quizId=tempQuizId;
}

/**
 *
 * @public
 * Gets the quiz response for a quiz
 *
 * @param result type of array collection
 * @return void
 *
 */
public function getQuizResultByLocationResultHandler(result:ArrayCollection):void {
	if ((result != null) && (result.length != 0)) {
		var tempQuizResult:ArrayCollection=new ArrayCollection();
		var tempObj:Object;

		for (var i:Number=0; i < result.length; i++) {
			var quizMarks:Object=result;
			tempObj=new Object();
			tempObj=quizMarks[i];
			var quizQuestionId:Number=tempObj[1];
			for (var j:Number=0; j < quizMarks.length; ) {
				tempObj=quizMarks[j];
				if (quizQuestionId == tempObj[1]) {
					tempQuizResult.addItem(quizMarks[j]);
					result.removeItemAt(j);
				} else {
					j++;
				}
			}

		}
		populateQuizResult(tempQuizResult);

		tempObj=new Object();
		tempObj.totalStudents=totalStudents;
		tempObj.correctAnswer=totalLocalStudent;
		tempObj.responseType = RESPONSE_TYPE_LOCAL;
		locationBasedACForChart.addItem(tempObj);
		tempObj=new Object();
		tempObj.totalStudents=totalStudents;
		tempObj.correctAnswer=totalRemoteStudent;
		tempObj.responseType = RESPONSE_TYPE_REMOTE;
		locationBasedACForChart.addItem(tempObj);
	} else {
		CustomAlert.info("No result available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}
/**
 *
 * @private
 * Calls the remote method to display the location base result
 * This is the initialise function of the component
 *
 *
 * @return void
 *
 */
private function initLocationBaseResult():void {
	quizHelper=new QuizHelper();
	quizHelper.getQuizResultByLocation(quizId,getQuizResultByLocationResultHandler);

}

/**
 *
 * @private
 * Populates the quiz result
 *
 * @param questionPaperResult type of array collection
 * @return void
 *
 */
private function populateQuizResult(questionPaperResult:ArrayCollection):void {
	var tempObj:Object=new Object();
	var resultObject:Object=new Object();

	for (var i:int=0; i < questionPaperResult.length; i++) {
		var quizMarks:Object=questionPaperResult;
		tempObj=quizMarks[i];
		tempObj.qno=tempObj[1]; // quiz question id  : tempObj[1] 
		totalStudents=tempObj[2]; // nos. of students registered for a quiz : tempObj[2] 
		resultObject.question=tempObj[0]; // question text  : tempObj[0] 
		resultObject.totalStudents=totalStudents;
		if (tempObj[4] == QuizContext.PC_RESPONSE_TYPE)
		{
			resultObject.correctAnswer = tempObj[3]; // nos. of students attempted the quiz  : tempObj[3] 
			resultObject.correctPercent = Math.round((tempObj[3] / totalStudents) * 100);
			resultObject.correctAnswerRemote = 0
			resultObject.correctPercentRemote = 0;
			totalLocalStudent += tempObj[3];
		}
		else if (tempObj[4] == QuizContext.MOBILE_RESPONSE_TYPE)
		{
			resultObject.correctAnswer = 0;
			resultObject.correctPercent = 0;
			resultObject.correctAnswerRemote = tempObj[3];
			resultObject.correctPercentRemote = Math.round((tempObj[3] / totalStudents) * 100);
			totalRemoteStudent = totalRemoteStudent + tempObj[3];
		}
	}
	quizResult.addItem(resultObject);
}
