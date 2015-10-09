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
 * File			: QuizResultViewerComponentUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 *
 * This component shows result to teacher in different formats :
 *  user wise , question level ,question paper  , location based , category wise
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.evaluation.quizResponse.CategoryWiseResult;
import edu.amrita.aview.core.evaluation.quizResponse.LocationBasedResult;
import edu.amrita.aview.core.evaluation.quizResponse.QuestionLevelResult;
import edu.amrita.aview.core.evaluation.quizResponse.QuestionPaperResult;
import edu.amrita.aview.core.evaluation.quizResponse.StudentWiseResult;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

/**
 * Varibale to hold quiz details. */
[Bindable]
public var quizVO:QuizVO=new QuizVO();

/**
 * Stores the quiz id , for displaying different results
 */
private var tempQuizId:int=0;

/**
 * Stores which button was clicked for viewing result
 */
private var currentButtonClicked:String=null;

/**
 * Constant for student wise result
 */
private const STUDENT_WISE_RESULT : String = "studentWise";

/**
 * Constant for question level result
 */
private const QUESTION_LEVEL_RESULT : String = "questionLevel";

/**
 * Constant for question paper result
 */
private const QUESTION_PAPER_RESULT : String = "questionPaperResult";

/**
 * Constant for location based result
 */
/* Fix for Bug #19913*/
/*private const LOCATION_BASED_RESULT : String = "locationBasedResult";*/

/**
 * Constant for category wise result
 */
private const CATEGORY_WISE_RESULT : String = "categoryWiseResult";

/**
 * @public
 * Getter function for quiz id
 *
 * @return int
 */
public function get quizId():int {
	return tempQuizId;
}

/**
 * @public
 * Setter function for quiz id
 * @param quiz_id type of int
 * @return void
 */
public function set quizId(quiz_id:int):void {
	this.tempQuizId=quiz_id;
}

/**
 * @private
 * Display student wise result
 *
 * @return void
 */
private function addStudentWiseResult():void 
{
	if(!ClassroomContext.checkIsClassRoom)
	{
		this.percentHeight = 100;
		this.percentWidth = 100;
	}
	currentButtonClicked = STUDENT_WISE_RESULT;
	btnStudentWise.enabled = false;
	btnQuestionLevel.enabled = true;
	btnQuestionPaperResult.enabled = true;
	/* Fix for Bug #19913*/
	/*btnLocationBasedResult.enabled = true;*/
	btnCategoryWiseResult.enabled = true;
	canSelectedQuizComp.removeAllChildren();
	var studentWiseResultComp:StudentWiseResult = new StudentWiseResult();
	studentWiseResultComp.quizId = tempQuizId;
	studentWiseResultComp.quizVO = quizVO;
	canSelectedQuizComp.addChild(studentWiseResultComp);
}

/**
 * @private
 * Display question level result
 *
 * @return void
 */
private function addQuestionLevelResult():void 
{
	currentButtonClicked = QUESTION_LEVEL_RESULT;
	btnStudentWise.enabled = true;
	btnQuestionLevel.enabled = false;
	btnQuestionPaperResult.enabled = true;
	/*Fix for Bug #19913*/
	/*btnLocationBasedResult.enabled = true;*/
	btnCategoryWiseResult.enabled = true;
	canSelectedQuizComp.removeAllChildren();
	var questionLevelResultComp:QuestionLevelResult = new QuestionLevelResult();
	questionLevelResultComp.quizId = tempQuizId;
	canSelectedQuizComp.addChild(questionLevelResultComp);
}

/**
 * @private
 * Display question paper result
 * 
 * @return void
 */
private function addQuestionPaperResult():void
{
	currentButtonClicked = QUESTION_PAPER_RESULT;
	btnStudentWise.enabled = true;
	btnQuestionLevel.enabled = true;
	btnQuestionPaperResult.enabled = false;
	/* Fix for Bug #19913*/
	/*btnLocationBasedResult.enabled = true;*/
	btnCategoryWiseResult.enabled = true;
	canSelectedQuizComp.removeAllChildren();
	var questionPaperResultComp:QuestionPaperResult = new QuestionPaperResult();
	questionPaperResultComp.quizId = tempQuizId;
	canSelectedQuizComp.addChild(questionPaperResultComp);
}

/**
 * @private
 * Display location based result
 *
 * @return void
 */
/* Fix for Bug #19913*/
/*private function addLocationBasedResult():void
{
	currentButtonClicked = LOCATION_BASED_RESULT;
	btnStudentWise.enabled = true;
	btnQuestionLevel.enabled = true;
	btnQuestionPaperResult.enabled = true;
	btnLocationBasedResult.enabled = false;
	btnCategoryWiseResult.enabled = true;
	canSelectedQuizComp.removeAllChildren();
	var locationBasedResultComp:LocationBasedResult = new LocationBasedResult();
	locationBasedResultComp.quizId = tempQuizId;
	canSelectedQuizComp.addChild(locationBasedResultComp);
}*/

/**
 * @private
 * Display category wise result
 *
 * @return void
 */
private function addCategoryWiseResult():void
{
	currentButtonClicked = CATEGORY_WISE_RESULT;
	btnStudentWise.enabled = true;
	btnQuestionLevel.enabled = true;
	btnQuestionPaperResult.enabled = true;
	/*Fix for Bug #19913*/
	/*btnLocationBasedResult.enabled = true;*/
	btnCategoryWiseResult.enabled = false;
	canSelectedQuizComp.removeAllChildren();
	var categorywiseResultobj:CategoryWiseResult = new CategoryWiseResult();
	categorywiseResultobj.quizId = tempQuizId;
	canSelectedQuizComp.addChild(categorywiseResultobj);
}

/**
 * @private
 * Refresh the display of result  , by displaying the one that was clicked last
 *
 * @return void
 *
 */
private function onRefresh():void 
{
	switch (currentButtonClicked) 
	{
		case STUDENT_WISE_RESULT :
			addStudentWiseResult();
			break;

		case QUESTION_LEVEL_RESULT :
			addQuestionLevelResult();
			break;

		case QUESTION_PAPER_RESULT :
			addQuestionPaperResult();
			break;
		/*Fix for Bug #19913*/
		/*case LOCATION_BASED_RESULT :
			addLocationBasedResult();
			break;*/

		case CATEGORY_WISE_RESULT :
			addCategoryWiseResult();
			break;
	}
}
