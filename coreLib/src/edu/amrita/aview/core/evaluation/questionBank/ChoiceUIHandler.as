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
 * File			: ChoiceUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * UI component for adding answer choice to question bank question.
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;

import flash.events.Event;

import mx.utils.StringUtil;
[Bindable]
/**
 * Variale to hold answer choice.
 * */
public var choiceItem:Object;

[Bindable]
/**
 * Variale to hold number of choices.
 * */
public var choiceNum:String;

[Bindable]
/**
 * Variale to check whether its from polling.
 * */
public var fromClassroomPolling:Boolean=false;

/**
 * @private
 * Function : deleteClickHandler Handler for delete icon, to remove the choice.
 *
 * @return void
*/
private function deleteClickHandler():void {
	this.dispatchEvent(new Event("removeChoice"));
}

/**
 * @private
 * Function : onChange Change handler for checkbox and radiobutton.
 *
 * @return void
*/
private function onChange():void {
	this.dispatchEvent(new Event("radioButtonChange"));
}

/**
 * @private
 * Function : creationCompleteHandler Creationcomplete handler for this component.
 *
 * @return void
*/
private function creationCompleteHandler():void {
	answerText.setStyle("backgroundColor", "#ffffff");
	if (choiceItem.questionTypeId == QuizContext.MULTIPLE_CHOICE_QUESTION_TYPE_ID 
		|| choiceItem.questionTypeId == QuizContext.POLLING_QUESTION_TYPE_ID
		|| choiceItem.questionTypeId == QuizContext.TRUE_OR_FALSE_QUESTION_TYPE_ID)  
	{
		answerChoiceForMR.visible=false;
	} 
	else if (choiceItem.questionTypeId == QuizContext.MULTIPLE_RESPONSE_QUESTION_TYPE_ID) 
	{
		answerChoiceForMC.visible=false;
		answerChoiceForMR.visible=true;
	}
	//Fix for Bug#16124
	if(choiceItem.questionTypeId == QuizContext.TRUE_OR_FALSE_QUESTION_TYPE_ID)
	{
		deleteButton.visible =  false;
	}
}
/**
 * @private
 * Function : choiceTextChangeHandler Text change handler for choice text
 *
 * @return void
 */
//Fix for Bug#15709,15710 : Change Focusout event to change event.
private function choiceTextChangeHandler():void {
	choiceItem.choiceText=answerText.text;
	this.dispatchEvent(new Event("choiceTextChange"));
}