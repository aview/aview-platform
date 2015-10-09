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
 * File			: StudentViewQuizResponseUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Thirumalai murugan
 *
 * StudentViewQuizResponseUIHandler.as file is the script handler for StudentViewQuizResponse.mxml
 * This file contains all the functionalities for student quiz response.
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.quizResponse.StudentAnswerSheet;
import edu.amrita.aview.core.evaluation.vo.QuizVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;

import flash.events.MouseEvent;

import mx.charts.HitData;
import mx.charts.PieChart;
import mx.charts.series.items.PieSeriesItem;
import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

import spark.skins.spark.DefaultGridItemRenderer;

/**
 * Value Object of QuizVO
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO();
/**
 * Boolean to check whether this result window is called after submitting live quiz.
 */
public var fromLiveQuiz:Boolean = false;


/**
 * Stores quiz result : user , total score etc
 */
[Bindable]
private var quizResult:ArrayCollection=new ArrayCollection();

/**
 * Data provider for pie chart
 */
[Bindable]
private var quizResultForPieChart:ArrayCollection=new ArrayCollection();
/**
 * Data provider for live quiz result
 */
[Bindable]
private var quizResultForLiveQuiz:ArrayCollection=new ArrayCollection();

/**
 * Calls the remote method
 */
private var quizHelper:QuizHelper;

/**
 * Used to display the StudentAnswerSheet component
 */
private var studentAnswerSheet:StudentAnswerSheet;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quizResponse.StudentViewQuizResponseUIHandler.as");

/**
 * @public
 * Result handler function for quiz result
 *
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuizResultForStudentResultHandler(result:ArrayCollection):void {
	if ((result != null) && (result.length != 0)) {
		var i:int;
		quizResult=result;
		if(Log.isInfo()) log.info("getQuizStudentResult_resultHandler " + quizResult)
		for (i=0; i < quizResult.length; i++) {
			var correctPercentage:Number=Math.round(((quizResult.getItemAt(i).score / quizResult.getItemAt(i).totalScore) * 100) * 100) / 100;
			var wrongPercentage:Number=Math.round((((quizResult.getItemAt(i).totalScore - quizResult.getItemAt(i).score) / quizResult.getItemAt(i).totalScore) * 100) * 100) / 100;
			quizResultForPieChart.addItem({fraction: quizResult.getItemAt(i).score, label: "Correct Answer", percentage: correctPercentage});
			var wrongAns:int=quizResult.getItemAt(i).totalScore - quizResult.getItemAt(i).score;
			quizResultForPieChart.addItem({fraction: wrongAns, label: "Wrong Answer", percentage: wrongPercentage});
			if(fromLiveQuiz)
			{
				quizResultForLiveQuiz.addItem({label : "Student Name :",value : quizResult.getItemAt(i).userName});
				quizResultForLiveQuiz.addItem({label : "No. of Questions :",value : quizResult.getItemAt(i).countQuizQuestionId});
				quizResultForLiveQuiz.addItem({label : "Total Marks :",value : quizResult.getItemAt(i).totalScore});
				quizResultForLiveQuiz.addItem({label : "Score :",value : quizResult.getItemAt(i).score});
				quizResultForLiveQuiz.addItem({label : "Percentage :",value : quizResult.getItemAt(i).percentage});
				
				this.currentState = "liveQuizResult";
			}
			
			if (quizResult[i].quizId == quizVO.quizId)
			{
				quizVO.userName = quizResult[i].userName;
				break;
			}
		}
	} 
	else 
	{
		CustomAlert.info("No result available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}

/**
 * @private
 * Calls the remote method to populate the list , for displaying the student result
 *
 * @return void
 */
private function initStudentViewQuizResponse():void {
	quizHelper=new QuizHelper();
	var userId:Number=ClassroomContext.userVO.userId;
	quizHelper.getQuizResultForStudent(quizVO.quizId, userId,getQuizResultForStudentResultHandler);
}

/**
 * @private
 * Displays the tool tip when mouse is rolled over the pie chart
 *
 * @param data type of HitData
 * @return String
 */
private function pieChartToolTipFunction(data:HitData):String {
	var pieSeries:PieSeriesItem=data.chartItem as PieSeriesItem;
	return "<b>" + data.item.label + "<b>" + ": " + "<b>" + data.item.percentage + "<b>" + "%";
}

/**
 * @private
 * When mouse is rolled over pie chart , the tool tip function becomes active
 *
 * @param event type of MouseEvent
 * @return void
 */
private function onRollOverOfPieChart(event:MouseEvent):void {
	PieChart(event.currentTarget).showDataTips=true;
}

/**
 * @private
 * When mouse is rolled out of pie chart , the tool tip function becomes inactive
 *
 * @param event type of MouseEvent
 * @return void
 */
private function onRollOutOfPieChart(event:MouseEvent):void {
	PieChart(event.currentTarget).showDataTips=false;
}

/**
 * @private
 * Gets the quiz id
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function getQuizId(oItem:Object, iCol:int):String {
	return String(quizVO.quizId);
}

/**
 * @private
 * Gets the quiz name
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function getQuizName(oItem:Object, iCol:int):String {
	return String(quizVO.quizName);
}

/**
 * @private
 * Gets the course name
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function getCourseName(oItem:Object, iCol:int):String {
	return String(quizVO.courseName);
}

/**
 * @private
 * Gets the class name
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function getClassName(oItem:Object, iCol:int):String {
	return String(quizVO.className);
}

/**
 * @private
 * Displays the answer sheet of a user, on double click
 *
 * @return void
 */
//Fix for Bug #10947
private function viewStudentAnswerSheet(event:MouseEvent):void {
	if ( event.target is DefaultGridItemRenderer && studentResultDg.selectedIndex != -1) {
		studentAnswerSheet=StudentAnswerSheet(PopUpManager.createPopUp(this, StudentAnswerSheet, true));
		studentAnswerSheet.quizIdForStudentAns=studentResultDg.selectedItem.quizId;
		studentAnswerSheet.quizVO=quizVO;
		studentAnswerSheet.quizVO.userName=studentResultDg.selectedItem.userName;
		PopUpManager.centerPopUp(studentAnswerSheet);
	}
}

/**
 * @private
 * Gets the marks
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function getMarks(oItem:Object, iCol:int):String {
	if(Log.isDebug()) log.debug("getQnType::oItem::" + oItem);
	for (var i:int=0; i < quizResult.length; i++) {
		if (oItem.quizId == quizResult[i].quizId) {
			return String(Math.round(quizResult[i].score * 100) / 100);
		}
	}
	return "";
}
