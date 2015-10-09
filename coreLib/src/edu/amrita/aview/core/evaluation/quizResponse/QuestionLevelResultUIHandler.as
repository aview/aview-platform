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
 * File			: QuestionLevelResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Thirumalai murugan
 *
 * QuestionLevelResultUIHandler.as acts as handler for QuestionLevelResult.mxml
 *
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionHelper;
import edu.amrita.aview.core.evaluation.vo.QuizAnswerChoiceVO;
import edu.amrita.aview.core.evaluation.vo.QuizQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.utils.ObjectUtil;

/**
 * variable to set/get quizId
 */
private var _quizId:int=0;

/**
 * Flag for question availability , when the first question is displayed
 */
private var hasResults:Boolean=false;

/**
 * Index of question currently being attempted
 */
private var currentIndex:int=0;

// Messages to be displayed on y-series of column chart : Applies for below 2 variables
private var message1:String="Student Response:";
private var message2:String="Total Response For This Choice:";

// Calls remote methods : Applies for below 2 variables
private var quizHelper:QuizHelper;
private var quizQuestionHelper:QuizQuestionHelper;

/**
 * Stores the index of choice using ASCII code
 */
private var choiceLabelIndex:int=0;


/**
 * List of answers , count of user response , question id
 */
[Bindable]
private var quizQuestionResult:ArrayCollection=new ArrayCollection();

/**
 * Variable to list quiz answer choices
 */
[Bindable]
private var quizAnswerChoicesForChart:ArrayCollection=new ArrayCollection();

/**
 * Variable to list question-answer for a quiz
 */
[Bindable]
private var questionAnswerAC:ArrayCollection=new ArrayCollection;

/**
 * Tempory object for storing question-answer for a quiz
 */
[Bindable]
private var questionAnsObj:Object;

/**
 *  Message to be displayed on y-series of column chart
 */
[Bindable]
private var displayMessage:String=message1 + '\n' + message2;


/**
 * @public
 * Get the quiz id
 *
 * @return int
 */
public function get quizId():int {
	return _quizId;
}

/**
 * @public
 * Set the quiz id
 *
 * @param quiz_id type of int
 * @return void
 */
public function set quizId(quiz_id:int):void {
	this._quizId=quiz_id;
}

/**
 * @public
 * Gets the answer and its corresponding attempted count for a quiz
 *
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuizResultByQuestionResultHandler(result:ArrayCollection):void {
	var i:int, j:int;
	var qz:QuizVO;
	var tmpAC:ArrayCollection=new ArrayCollection();
	for (i=0; i < result.length; i++) {
		qz=new QuizVO();
		qz=result[i];

		for (j=0; j < questionAnswerAC.length; j++) {
			var qzq:QuizQuestionVO=questionAnswerAC.getItemAt(j) as QuizQuestionVO;
			if (qz.quizQuestionId == qzq.quizQuestionId) {
				tmpAC.addItem(qz);
				break;
			}

		}
	}
	quizQuestionResult=tmpAC;
	if (quizQuestionResult.length != 0) {
		hasResults=true;
		callFirstQuestion(new Event("questionAC fill"));
	} else {
		nextBtn.enabled=false;
		backBtn.enabled=false;
		CustomAlert.info("No Result Available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}

/**
 *
 * @public
 * Gets quiz questions and answers for a quiz
 *
 * @param result type of ArrayCollection
 * @return void
 */
public function getQuizQuestionsForQuizResultHandler(result:ArrayCollection):void {
	QuizContext.copyDataByQuizSequence(questionAnswerAC, result);

	// disable the next button
	if (result.length <= 1) {
		nextBtn.enabled=false;
	}

	// All questions and answers belong to same quiz , hence taking an object 
	// from result list , to set the quiz id
	var quizQuestionVO:QuizQuestionVO=result[0];
	quizId=quizQuestionVO.quiz.quizId;

	this.dispatchEvent(new Event('questionAC fill'));
	quizHelper.getQuizResultByQuestion(quizId,getQuizResultByQuestionResultHandler);
}

/**
 * @private
 * The initial method called :
 * it initialises the helper objects , enable/disable buttons
 *
 * @return void
 */
private function initQuestionLevelResult():void {
	quizQuestionHelper=new QuizQuestionHelper();
	quizHelper=new QuizHelper();
	quizQuestionHelper.getQuizQuestionsForQuiz(quizId,getQuizQuestionsForQuizResultHandler);
}
//PNCR: the below three functions using similar action. Check whether we can combine in a single function with arguments.
/**
 * @private
 * Displays the answer for the first question in chart's horizontal axis
 *
 * @return void
 */
private function firstQuestion():void {
	choiceLabelIndex=0;
	quizAnswerChoicesForChart=new ArrayCollection();
	nextBtn.enabled=false;
	backBtn.enabled=false;
	qno.text=String(currentIndex + 1) + '.';
	questionAnsObj=ObjectUtil.copy(questionAnswerAC[currentIndex]);
	var i:int, j:int;
	if (questionAnswerAC.length > 1) // enable next button only if there are more than one question
	{
		nextBtn.enabled=true;
	}

	for (i=0; i < quizQuestionResult.length; i++) {
		choiceLabelIndex=0;

		var qzqFirst:QuizVO=quizQuestionResult.getItemAt(i) as QuizVO;
		// check if the attempted question(in quiz) and original question are same
		// Used to set the data provider for chart display , consisting of answer and its count 
		//Fix for bug #19871 Start
		/*if (questionAnsObj.quizQuestionId == qzqFirst.quizQuestionId) {*/
			var tempAC:ArrayCollection=questionAnsObj.quizAnswerChoices as ArrayCollection;
			for (j=0; j < tempAC.length; j++) {
				var qac:QuizAnswerChoiceVO=tempAC[j];
				qac.choiceLabel=String.fromCharCode(choiceLabelIndex + 97); // sets the label of choice starting from alphabet 'a' : ASCII code 97
				choiceLabelIndex++;
				if (qzqFirst.quizAnswerChoiceId == qac.quizAnswerChoiceId) {
					qac.ansCount=qzqFirst.answerChoiceCount;
				}
			}
			questionAnsObj.quizAnswerChoices=tempAC;
			quizAnswerChoicesForChart.addItem(questionAnsObj.quizAnswerChoices);
		/*}
		else {
			chartForQuestionLevelResult.dataProvider=null;
			
		}*/
			//Fix for bug #19871 End
	}
	if (quizAnswerChoicesForChart.length > 0) {
		chartForQuestionLevelResult.dataProvider=quizAnswerChoicesForChart[0];
	}
	if (questionAnsObj != null) {
		allQuestionsVB.visible=true;
		mainCan.addChild(allQuestionsVB);
	}
}

/**
 * @private
 * Calls the first question
 *
 * @param event type of Event
 * @return void
 */
private function callFirstQuestion(event:Event):void {
	if (hasResults) {
		firstQuestion();
	}
}

/**
 * @private
 * Display the answer of next question in chart's horizontal axis
 *
 * @return void
 */
private function displayNextQuestion():void {
	choiceLabelIndex=0;
	quizAnswerChoicesForChart=new ArrayCollection();
	// Check if the current index is less than the total number of questions
	if (currentIndex < (questionAnswerAC.length - 1)) 
	{
		currentIndex++;
		questionAnsObj=ObjectUtil.copy(questionAnswerAC[currentIndex]);
		allQuestionsVB.visible=true;
		mainCan.addChild(allQuestionsVB);
		nextBtn.enabled=false;
		backBtn.enabled=true;
		var i:int, j:int;
		for (i=0; i < quizQuestionResult.length; i++) 
		{
			choiceLabelIndex=0;
			var qzqFirst:QuizVO=quizQuestionResult.getItemAt(i) as QuizVO;
			// check if the attempted question(in quiz) and original question are same
			// Used to set the data provider for chart display , consisting of answer and its count  
			//Fix for bug #19871 Start
			/*if (questionAnsObj.quizQuestionId == qzqFirst.quizQuestionId) 
			{*/
				var tempAC:ArrayCollection=questionAnsObj.quizAnswerChoices as ArrayCollection;
				for (j=0; j < tempAC.length; j++) 
				{
					var qac:QuizAnswerChoiceVO=tempAC[j];
					qac.choiceLabel=String.fromCharCode(choiceLabelIndex + 97); /* sets the label of choice starting from alphabet 'a' : ASCII code 97*/
					choiceLabelIndex++;
					if (qzqFirst.quizAnswerChoiceId == qac.quizAnswerChoiceId) 
					{
						qac.ansCount=qzqFirst.answerChoiceCount;
					}
				}
				questionAnsObj.quizAnswerChoices=tempAC;
				quizAnswerChoicesForChart.addItem(questionAnsObj.quizAnswerChoices);
			/*}
			else 
			{
				chartForQuestionLevelResult.dataProvider=null;
			}*/
				//Fix for bug #19871 End
		}
		if (quizAnswerChoicesForChart.length > 0) 
		{
			chartForQuestionLevelResult.dataProvider=quizAnswerChoicesForChart[0];
		}
		nextBtn.enabled=true;
		backBtn.enabled=true;
	}

	if (currentIndex == (questionAnswerAC.length - 1)) 
	{
		nextBtn.enabled=false;
	}
	qno.text=String(currentIndex + 1) + '.';
}

/**
 *
 * @private
 * Display the answer of previous question in chart's horizontal axis
 *
 *
 * @return void
 *
 */
private function displayPreviousQuestion():void {
	choiceLabelIndex=0;

	quizAnswerChoicesForChart=new ArrayCollection();
	if (currentIndex > 0)
	{
		allQuestionsVB.visible=false;
		currentIndex--;
		questionAnsObj=ObjectUtil.copy(questionAnswerAC[currentIndex]);
		allQuestionsVB.visible=true;
		mainCan.addChild(allQuestionsVB);

		var i:int, j:int;
		for (i=0; i < quizQuestionResult.length; i++) 
		{
			choiceLabelIndex=0;
			var qzqFirst:QuizVO=quizQuestionResult.getItemAt(i) as QuizVO;
			// check if the attempted question(in quiz) and original question are same
			// Used to set the data provider for chart display , consisting of answer and its count
			//Fix for bug #19871 Start
			/*if (questionAnsObj.quizQuestionId == qzqFirst.quizQuestionId) 
			{*/
				var tempAC:ArrayCollection=questionAnsObj.quizAnswerChoices as ArrayCollection;
				for (j=0; j < tempAC.length; j++) 
				{
					var qac:QuizAnswerChoiceVO=tempAC[j];
					qac.choiceLabel=String.fromCharCode(choiceLabelIndex + 97); /* sets the label of choice starting from alphabet 'a' : ASCII code 97*/
					choiceLabelIndex++;
					if (qzqFirst.quizAnswerChoiceId == qac.quizAnswerChoiceId) 
					{
						qac.ansCount=qzqFirst.answerChoiceCount;
					}
				}
				questionAnsObj.quizAnswerChoices=tempAC;
				quizAnswerChoicesForChart.addItem(questionAnsObj.quizAnswerChoices);
			/*} else 
			{
				chartForQuestionLevelResult.dataProvider=null;
			}*/
				//Fix for bug #19871 End
		}
		if (quizAnswerChoicesForChart.length > 0) {
			chartForQuestionLevelResult.dataProvider=quizAnswerChoicesForChart[0];
		}
		nextBtn.enabled=true;
		backBtn.enabled=true;
	}
	if (currentIndex <= 0) 
	{
		backBtn.enabled=false;
	}
	qno.text=String(currentIndex + 1) + '.';
}