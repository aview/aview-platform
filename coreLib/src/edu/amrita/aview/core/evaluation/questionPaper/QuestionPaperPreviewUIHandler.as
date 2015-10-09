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
 * File			: QuestionPaperPreviewUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * QuestionPaperPreviewUIHandler acts as handler for QuestionPaperPreview.mxml
 */

import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperQuestionListVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;


[Bindable]
/**
 * Value Object
 */
public var questionPaperVO:QuestionPaperVO;

[Bindable]
/**
 * list of question paper questions
 */
public var questions:ArrayCollection;

[Bindable]
/**
 * used to show or hide answer for a question
 */
public var showAnswers:Boolean;

/**
 * Used to call remote method
 */
private var questionPaperHelper:QuestionPaperHelper;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionPaper.QuestionPaperPreviewUIHandler.as");

/**
 * @public
 * Result handler for questionPaperPreview remote method
 * @param result type of ArrayCollection
 * @return void
 */
public function questionPaperPreviewResultHandler(event:ResultEvent):void {
	if(event.result != null)
	{
		var result:ArrayCollection = event.result as ArrayCollection ;
		if(Log.isInfo()) log.info("getQuestionPaperComplete_resultHandler::event.result::" + event.result);
	
		var qpqListVo:QuestionPaperQuestionListVO;
		var tmpQuestionAnswers:ArrayCollection=new ArrayCollection();
		var tempAnswerArray:ArrayCollection=new ArrayCollection();
		for (var i:int=0; i < result.length; i++) {
			qpqListVo=result.getItemAt(i) as QuestionPaperQuestionListVO;
			if (qpqListVo.questionPaperQuestion.questionPaperQuestionId != 0) {
				qpqListVo.qbQuestion.marks=qpqListVo.questionPaperQuestion.marks;
				tempAnswerArray.addItem(qpqListVo.qbQuestion);
			}
		}
		QuizContext.copyDataBySequence(tmpQuestionAnswers, tempAnswerArray);
		questions=tmpQuestionAnswers;
		if (qpqListVo.questionPaperQuestion.numRandomQuestions > 0) {
			lblRandomText.text="Total Random questions: " + qpqListVo.questionPaperQuestion.numRandomQuestions;
		}
	}
}

/**
 * @private
 * used to set the initial data required for startup of the component
 *
 * @return void
 */
private function creationCompleteQPPreview():void 
{
	//Fix for Bug#10960
	btnClose.setFocus();
	if(Log.isDebug()) log.debug("QuestionPaperPreview::init::questionPaperVO::" + questionPaperVO);
	questionPaperHelper=new QuestionPaperHelper();
	questionPaperHelper.questionPaperPreview(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,questionPaperPreviewResultHandler);
	if (!ClassroomContext.checkIsClassRoom) {
		vBoxQuestion.height=430;
	}
}

/**
 * @private
 * Used to remove the popup component
 *
 * @return void
 */
//PNCR: same function is defined in many files. Please check whether we can create a common function for that.
private function closeQuestionPaperPreview():void 
{
	PopUpManager.removePopUp(this);
}

/**
 * @private
 * Used to detect if answers have to be shown or not
 *
 * @return void
 */
private function toggleShowAnswers():void {
	if(Log.isDebug()) log.debug("toggleShowAnswers::chkShowAnswers.selected::" + chkShowAnswers.selected);
	showAnswers=chkShowAnswers.selected;
}

