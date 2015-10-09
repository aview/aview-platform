
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
 * File			: CategoryWiseResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	:
 *
 * CategoryWiseResultUIHandler.as acts as handler for  CategoryWiseResult.mxml
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.vo.QuizVO;

import mx.collections.ArrayCollection;

/**
 * Variable to hold instance of QuizHelper
 */
private var quizHelper:QuizHelper;

/**
 * Variable to set or get quiz id
 */
private var _quizId:int=0;


/**
 * variable to hold the Object of type quiz
 */
[Bindable]
public var quizVO:QuizVO=new QuizVO();


/**
 * Variable to hold list of quiz responses
 */
[Bindable]
private var quizResult:ArrayCollection=new ArrayCollection();


/**
 *
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
 *
 * @public
 * Gets the quiz and responses made by the student
 *
 * @param result type of ArrayCollection
 * @return void
 */
public function getCategoryBasedResultHandler(result:ArrayCollection):void {
	if ((result != null) && (result.length != 0)) {
		var quizResponseResult:ArrayCollection=new ArrayCollection();
		for (var i:Number=0; i < result.length; i++) {
			var tempObj:Object;
			var tempResult:Object=result;
			tempObj=new Object();
			tempObj=tempResult[i];
			var quizQuestionId:Number=tempObj[1];
			// Remove the duplicate entries from the list
			for (var j:Number=0; j < tempResult.length; ) {
				tempObj=tempResult[j];
				if (quizQuestionId == tempObj[1]) {
					quizResponseResult.addItem(tempResult[j]);
					result.removeItemAt(j);
				} else {
					j++;
				}
			}

		}
		generateResultForDisplay(quizResponseResult);
	} else {
		CustomAlert.info("No result available", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
}

/**
 *
 * @private
 * Calls the remote method to get the quiz response
 *
 *
 * @return void
 *
 */
private function initCategoryWiseResult():void {
	quizHelper=new QuizHelper();
	quizHelper.getCategoryBasedResult(quizId,getCategoryBasedResultHandler);
}

/**
 *
 * @private
 * Format the result from remote method for displaying
 * @param questionPaperResult type of ArrayCollection
 * @return void
 *
 */
private function generateResultForDisplay(tempResult:ArrayCollection):void {
	var tempObj:Object=new Object();
	var resultObject:Object=new Object();

	for (var i:int=0; i < tempResult.length; i++) {
		var quizMarks:Object=tempResult;
		tempObj=quizMarks[i];
		resultObject.question=tempObj[0];
		resultObject.subCategory=tempObj[2];
		resultObject.difficultyLevel=tempObj[3];
		resultObject.category=tempObj[7];
		// check if the response is through PC or Mobile
		if (tempObj[6] == QuizContext.PC_RESPONSE_TYPE) {
			resultObject.local=Math.round((tempObj[5] / tempObj[4]) * 100);
		}
		if (tempObj[6] == QuizContext.MOBILE_RESPONSE_TYPE) {
			resultObject.remote=Math.round((tempObj[5] / tempObj[4]) * 100);
		}
	}
	quizResult.addItem(resultObject);
}




