////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: PollingQuestionAnswerUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * PollingQuestionAnswerUIHandler.as file is the script handler for PollingQuestionAnswer.mxml
 * This file contains all the functionalities for polling questions and answers.
 *
 */
import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

/**
 *  ArrayCollection variable to store polling question answer details.It is used for chart preparation
 */
[Bindable]
private var chartDataProvider:ArrayCollection=new ArrayCollection();

/**
 *
 * @private
 * Function : setDataProvider
 * Function used to set dataprovider for chart.
 *
 * @param arr type of ArrayCollection
 * @return void
 *
 */
private function setDataProvider(arr:ArrayCollection):void {
	var obj:Object=null;
	//Fix for Bug #11041
	var tempArrayCollection:ArrayCollection=new ArrayCollection;
	for (var i:int=0; i < arr.length; i++) {
		obj=new Object;
		obj.choiceText=arr[i].choiceText;
		obj.percent=arr[i].correctCountForAnswerChoice;
		tempArrayCollection.addItem(obj);
	}
	chartDataProvider=tempArrayCollection;
}

//Fix for Bug #11041
/**
 *
 * @protected
 * Function : dataChangeHandler
 * Handler for data change event in item renderer component.
 *
 * @param event type of FlexEvent
 * @return void
 *
 */
protected function dataChangeHandler(event:FlexEvent):void {
	if (this.data) {
		setDataProvider(this.data.quizAnswerChoices);
	}
}
