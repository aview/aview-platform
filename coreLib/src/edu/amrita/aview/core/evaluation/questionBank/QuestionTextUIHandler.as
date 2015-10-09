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
 * File			: QuestionTextUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * TextArea for question text in  CreateQuestionBankQuestion.
 *
 */

import flash.events.Event;

/**
 * Flag that indicates if the text is auto resizable or not
 */
private var _autoResizable:Boolean=false;

/**
 * @public
 * Get the boolean value
 *
 * @return boolean
 */
[Bindable(event="changeAutoResize")]
public function get autoResize():Boolean {
	return _autoResizable;
}

/**
 * @public
 * Set the boolean value
 * @param b type of Boolean
 * @return void
 */

public function set autoResize(b:Boolean):void {
	_autoResizable=b;
	// if the text field component is created
	// and is auto resizable
	// we call the resize method
	if (this.mx_internal::getTextField() != null && _autoResizable == true) {
		resizeTextArea();
	}
	// dispatch event to make the autoResize 
	// property bindable
	this.dispatchEvent(new Event("changeAutoResize"));
}

/**
 *@private
 *The resize function for the text area
 *@param null
 *@return void
 *
 */
private function resizeTextArea():void {
	// initial height value
	// if set to 0 scroll bars will 
	// appear to the resized text area 
	var totalHeight:uint=2;
	// validating the object
	this.validateNow();
	// find the total number of text lines 
	// in the text area
	var noOfLines:int=this.mx_internal::getTextField().numLines;
	// iterating through all lines of 
	// text in the text area
	for (var i:int=0; i < noOfLines; i++) {
		// getting the height of one text line
		var textLineHeight:int=this.mx_internal::getTextField().getLineMetrics(i).height;
		// adding the height to the total height
		totalHeight+=textLineHeight;
	}
	// setting the new calculated height
	this.height=totalHeight;
}

/**
 * @override
 * The setter override
 * @param value type of String
 * @return void
 *
 */
override public function set text(value:String):void {
	// calling super method 
	super.text=value;
	// if is auto resizable we call 
	// the resize method
	if (_autoResizable) {
		resizeTextArea();
	}
}
