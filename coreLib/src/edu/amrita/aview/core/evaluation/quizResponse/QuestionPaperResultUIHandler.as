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
 * File			: QuestionPaperResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Thirumalai murugan
 *
 * QuestionPaperResultUIHandler.as acts as handler for QuestionPaperResult.mxml
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;

/**
 * Value Object of QuizVO
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO();

/**
 * List of quiz response : total score , users , marks
 */
[Bindable]
private var quizResponseResult:ArrayCollection=new ArrayCollection();

/**
 * List of question papers
 */
[Bindable]
private var questionPaperResult:ArrayCollection=new ArrayCollection();

/**
 * Object of QuizHelper
 */
private var quizHelper:QuizHelper;

/**
 * Used in getter/setter constructor
 */
private var _quizId:int=0;

/**
 * @public
 * To get quiz id
 *
 * @return int
 */
public function get quizId():int {
	return _quizId;
}

/**
 * @public
 * To set quiz id
 *
 * @param quiz_id type of int
 * @return void
 */
public function set quizId(quiz_id:int):void {
	this._quizId=quiz_id;
}

/**
 * @public
 * Gets the quiz response : score , total marks , users
 *
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuestionPaperResultForChartResultHandler(result:ArrayCollection):void {
	var tempObj:Object;

	if ((result != null) && (result.length != 0)) 
	{
		var i:int;

		tempObj=new Object();

		// For displaying the chart , grid having different levels
		var veryPoorStudentsCount : Number = 0;
		var poorStudentsCount : Number = 0;
		var satisfactoryStudentsCount : Number = 0;
		var goodStudentsCount : Number = 0;
		var excellentStudentsCount : Number = 0;

		for (i=0; i < result.length; i++) {
			var resultObj:Object=new Object();
			tempObj=result[i];
			var percentage:int=(tempObj[1] / tempObj[2]) * 100;
			//PNCR: use switch cases instead of nested if.
			if (percentage == 0) {
				veryPoorStudentsCount++;
			} else if ((percentage > 0) && (percentage <= 25)) {
				poorStudentsCount++;
			} else if ((percentage > 25) && (percentage <= 50)) {
				satisfactoryStudentsCount++;
			} else if ((percentage > 50) && (percentage <= 75)) {
				goodStudentsCount++;
			} else if ((percentage > 76) && (percentage <= 100)) {
				excellentStudentsCount++;
			}
		}
		
		addQuizResponse("Very Poor(0%)" , veryPoorStudentsCount);
		addQuizResponse("Poor(1%-25%)" , poorStudentsCount);
		addQuizResponse("Satisfactory(26%-50%)" , satisfactoryStudentsCount);
		addQuizResponse("Good(51%-75%)" , goodStudentsCount);
		addQuizResponse("Excellent(76%-100%)" , excellentStudentsCount);
	} 
	else 
	{
		CustomAlert.info("No result available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}

/**
 *@public
 * Gets list of question paper details
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuizResultByQuestionPaperResultHandler(result:ArrayCollection):void {
	var tempObj:Object;
	if ((result != null) && (result.length != 0)) {
		var i:int;
		var questionResultObj:Object=result;
		tempObj=new Object();
		for (i=0; i < questionResultObj.length; i++) {
			var resultObj:Object=new Object();
			tempObj=questionResultObj[i];
			resultObj.quizId=tempObj[0];
			resultObj.quizName=tempObj[1];
			resultObj.questionPaperName=tempObj[2];
			resultObj.className=tempObj[3];
			resultObj.courseName=tempObj[4];
			resultObj.noOfQuestions=tempObj[5];
			resultObj.totalStudent=tempObj[6];
			resultObj.submittedStudent=tempObj[7];
			questionPaperResult.addItem(resultObj);
		}
	}

}
/**
 * @private
 * To add quiz response result
 * @param marks type of String
 * @param numberOfStudents type of Number
 * 
 */
private function addQuizResponse(marks : String , numberOfStudents : Number):void
{
	var tempObj:Object = new Object();
	tempObj.marks = marks;
	tempObj.students = numberOfStudents;
	quizResponseResult.addItem(tempObj);
}
/**
 * @private
 * Calls the remote methods for displaying the initial GUI
 *
 * @return void
 */
private function initQuestionPaperResult():void {
	quizHelper=new QuizHelper();
	quizHelper.getQuizResultByQuestionPaper(quizId,getQuizResultByQuestionPaperResultHandler);
	quizHelper.getQuestionPaperResultForChart(quizId,getQuestionPaperResultForChartResultHandler);
	resultAsTable.visible=true;
	questionResultTableId.enabled=false;
	qpResultDg.visible=true;
	resultAsChart.visible=false;
}

/**
 * @protected
 * Hide the components which are not necessary while displaying result as chart
 *
 * @param event type of Mouse Event
 * @return void
 */
protected function questionResultChartIdClickHandler(event:MouseEvent):void {
	qpResultDg.visible=false;
	questionResultChartId.enabled=false;
	questionResultTableId.enabled=true;
	resultAsTable.visible=false;
	resultAsChart.visible=true;
}

/**
 * @protected
 * Hide the components which are not necessary while displaying result as table
 *
 * @param event type of Mouse Event
 * @return void
 */
protected function questionResultTableIdClickHandler(event:MouseEvent):void {
	qpResultDg.visible=true;
	questionResultChartId.enabled=true;
	questionResultTableId.enabled=false;
	resultAsTable.visible=true;
	resultAsChart.visible=false;
}
