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
 * File			: DocumentBlockScript.as
 * Module		: Video Editing
 * Developer(s)	: Ashish
 * Reviewer(s)	: Remya T
 *
 * File contains all the functionalities of creating and displaying the document block inside a Video Editing
 * component.
 *
 */
// AKCR: please use the single line comment format
/**
 * Variable holds the document name.
 */
[Bindable]
public var documentName:String;

/**
 * Variable holds the start time of document block.
 */
private var _sTime:int;

/**
 * Variable holds the end time of document block.
 */
private var _eTime:int;

/**
 * Distance between scale needles.
 */
private var _needleSpacing:Number;

/**
 * @public
 * Function for setting the value of 'sTime'.
 *
 * @param value of type int
 * @return void
 *
 */
public function set sTime(value:int):void{
	_sTime=value;
}

/**
 * @public
 * Function for setting the value of 'eTime'.
 *
 * @param value of type int
 * @return void
 */
public function set eTime(value:int):void{
	_eTime=value;
}

/**
 * @public
 * Function for setting the value of 'needleSpacing'.
 *
 * @param value of type Number
 * @return void
 */
public function set needleSpacing(value:Number):void{
	_needleSpacing=value;
}

/**
 * @public
 * Function for calculating the width and position of document block.
 * Also, sets the document name for display.
 *
 * @param void
 * @return void
 */
public function initBlock():void{
	this.verticalScrollPolicy="off"; // removing VScrollbars if any
	this.x=_sTime / (1000 * 60) * _needleSpacing;
	this.width=((_eTime / (1000 * 60)) - (_sTime / (1000 * 60))) * _needleSpacing;
	assignStyleToBlock(Number(this.id), "normalSlideBlock");
	documentName=this.label;
}

/**
 * @private
 * Function for assigning the style based on the attributes
 *
 * @param i of type int
 * @param s of type string
 * @return void
 */
private function assignStyleToBlock(i:int, s:String):void{
	// AKCR: we can use the confitional operator here for better readability
	// AKCR: this.styleName = s + (i%2 == 0) ? "Odd" : "Even";
	if (i % 2 == 0)
		this.styleName=s + "Odd";
	else
		this.styleName=s + "Even";
}
