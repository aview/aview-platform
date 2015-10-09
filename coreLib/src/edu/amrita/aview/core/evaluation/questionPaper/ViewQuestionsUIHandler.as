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
 * File			: ViewQuestionsUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * ViewQuestionsUIHandler acts as handler for ViewQuestions.mxml
 */

import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

[Bindable]
/**
 * Value Object Instance
 */
public var qbQuestion:QbQuestionVO;

/**
 * @private
 * Used to copy answers in sequence for uniformity in display
 *
 * @return void
 */
//Fix for Bug #11358
//Fix for Bug #11941
private function copyDataBySequence():void
{
	// temporary array to store answers
	var tempAnswerArray:Array;
	tempAnswerArray=new Array(qbQuestion.qbAnswerChoices.length);
	// Set the answer appropriately for the answer
	for (var j:int=0; j < qbQuestion.qbAnswerChoices.length; j++)
	{
		tempAnswerArray[qbQuestion.qbAnswerChoices[j].displaySequence - 1]=qbQuestion.qbAnswerChoices[j];
	}
	qbQuestion.qbAnswerChoices.removeAll();
	ArrayCollectionUtil.copyData(qbQuestion.qbAnswerChoices, new ArrayCollection(tempAnswerArray));
}

/**
 * @private
 * Removes this component
 * @param e type of KeyboardEvent
 * @return void
 */
private function removeIt(e:KeyboardEvent):void
{
	// Remove the popup component , if the enter event takes place
	if (e.keyCode == Keyboard.ENTER)
	{
		PopUpManager.removePopUp(this);
	}
}

/**
 * @private
 * Sets the data provider for the repeater
 *
 * @return void
 */
private function setDataProvider():void
{
	rpQuestionBank.dataProvider=qbQuestion;
}

/**
 * @protected
 * Sets the initial calls for this component
 * @param event type of FlexEvent
 * @return void
 *
 */
protected function creationCompleteHandler(event:FlexEvent):void
{	
	//Fix for Bug #11943
	btnCancel.addEventListener(KeyboardEvent.KEY_DOWN, removeIt);
	btnCancel.setFocus();	
	//Fix for Bug #11941
	copyDataBySequence();
	setDataProvider();
}
