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
 * File			: QuizQuestionAnswerUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This component is used to display question-answer in live quiz
 *
 */

import edu.amrita.aview.core.evaluation.vo.QuizQuestionVO;

import mx.events.FlexEvent;

[Bindable]
/**
 * Object of QuizQuestionVO
 */
public var quizQuestion:QuizQuestionVO;

[Bindable]
/**
 * Flag to detect if it the question is polling type
 */
public var isPolling:Boolean=false;

/**
 * @protected
 *
 * Set the user answer , so that it is displayed next time user traverses the questions
 * @param event type of FlexEvent
 * @return void
 */
protected function dataGroupCreationCompleteHandler(event:FlexEvent):void {

	var i:int;
	/**
	 * Adding all answer choices of a question to a specific radio button group.
	 * Then setting it back to the same arraycollection. */
	for (i=0; i < quizQuestion.quizAnswerChoices.length; i++) {
		var obj:Object=new Object;
		obj=quizQuestion.quizAnswerChoices[i];		
		obj.group=rbgAnswer;
		quizQuestion.quizAnswerChoices.removeItemAt(i);
		quizQuestion.quizAnswerChoices.addItemAt(obj, i);
	}
}
