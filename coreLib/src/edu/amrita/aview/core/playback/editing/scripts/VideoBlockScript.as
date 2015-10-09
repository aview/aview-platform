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
 * File			: VideoBlockScript.as
 * Module		: Video Editing
 * Developer(s)	: Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for creating video block, highlighting each slides on mouse over.
 *
 */
import flash.events.MouseEvent;
// AKCR: please use single line comment format

/**
 * Video name displayed on the block.
 */
[Bindable]
public var videoDisplayName:String;

/**
 * Slide block start time.
 */
private var _sTime:int;

/**
 * Slide block end time.
 */
private var _eTime:int;

/**
 * Block description.
 */
private var _videoBlockText:String;

/**
 * Distance between scale needles.
 */
private var _needleSpacing:Number;

/**
 * Setter of 'sTime'.
 */
public function set sTime(value:int):void{
	_sTime=value;
}

/**
 * Setter of 'eTime'.
 */
public function set eTime(value:int):void{
	_eTime=value;
}

/**
 * Setter of 'videoBlockText'.
 */
public function set videoBlockText(value:String):void{
	_videoBlockText=value;
}

/**
 * Setter of 'needleSpacing'.
 */
public function set needleSpacing(value:Number):void{
	_needleSpacing=value;
}

/**
 * @public
 * Function assigns the attribute values and styles to the block.
 * Registers the listners of mouse events.
 *
 * @param void
 * @return void
 */
public function initBlock():void{
	this.verticalScrollPolicy="off";
	this.x=_sTime / (1000 * 60) * _needleSpacing;
	this.width=((_eTime / (1000 * 60)) - (_sTime / (1000 * 60))) * _needleSpacing;
	videoDisplayName=this.label;
	this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
	this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
}

/**
 * @private
 * Function invokes when mouse over happens on video block.
 *
 * @param event of type MouseEvent.
 * @return void
 */
private function mouseOver(event:MouseEvent):void{
	this.setStyle("backgroundColor", "#FFD47F");
}

/**
 * @private
 * Function invokes when mouse out happens on video block.
 *
 * @param event of type MouseEvent.
 * @return void
 */
private function mouseOut(event:MouseEvent):void{
	this.setStyle("backgroundColor", "#FFD4AA");
}
