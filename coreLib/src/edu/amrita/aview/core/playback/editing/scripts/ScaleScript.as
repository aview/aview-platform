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
 * File			: ScaleScript.as
 * Module		: Video Editing
 * Developer(s)	: Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for creating a scale in the Video editing component.
 *
 */
import edu.amrita.aview.core.playback.editing.EditingConstants;

import flash.display.Sprite;

import mx.core.UITextField;

// please use the single line comment format
/**
 * No of needles in the scale .
 */
public var _units:Number;

/**
 * Distance between scale needles.
 */
public var _needleSpacing:Number;

/**
 * Sprite object draws the scale graphics.
 */
private var scaleDisplayObj:Sprite;

/**
 * Height of the needle to be drawn.
 */
private var needleHeight:Number;

/**
 * Setter of 'units'.
 */
public function set units(value:Number):void{
	_units=value;
}

/**
 * Setter of 'needleSpacingFn'.
 */
public function set needleSpacingFn(value:Number):void{
	_needleSpacing=value;
}

/**
 * @public
 * Function creates the sprite object and adds to the component.
 *
 * @param void
 * @return void
 */
public function init():void{
	scaleDisplayObj=new Sprite();
	this.addChild(scaleDisplayObj);
}

/**
 * @public
 * Function draws the scale based on the total playback time.
 *
 * @param parentWidth of type Number - Parent container width
 * @return void
 */
public function drawScale(parentWidth:Number):void{
	scaleDisplayObj.graphics.lineStyle(EditingConstants.SCALE_NEEDLE_THICKNESS, EditingConstants.SCALE_NEEDLE_COLOR, 1); //sets the needle thickness and color
	scaleDisplayObj.graphics.moveTo(EditingConstants.SCALE_START_X_POS, EditingConstants.SCALE_START_Y_POS);
	var scaleLength:Number=_units * _needleSpacing;
	scaleDisplayObj.graphics.lineTo(EditingConstants.SCALE_START_X_POS + scaleLength, EditingConstants.SCALE_START_Y_POS); //draw a line wrt the total time 
	var needleTopXPos:Number=EditingConstants.SCALE_START_X_POS;
	var needleTopYPos:Number=0;
	var needleBottomXPos:Number=0;
	var needleBottomYPos:Number=EditingConstants.SCALE_START_Y_POS;
	
	// Loops through the total time for creating the scale
	for (var i:int=0; i <= _units; i++){
		// Check for condition.
		// If so, Drawing long needle.
		if ((i == 0) || (i == _units) || (i % 10 == 0)){
			needleHeight=EditingConstants.SCALE_LONG_NEEDLE_HT;
			drawTimeText(i, needleTopXPos, needleTopYPos);
		}
			// Drawing small needle.
		else{
			needleHeight=EditingConstants.SCALE_SHORT_NEEDLE_HT;
			if (_units < 10){
				drawTimeText(i, needleTopXPos, needleTopYPos);
			}
		}
		needleTopYPos=EditingConstants.SCALE_START_Y_POS - needleHeight;
		scaleDisplayObj.graphics.moveTo(needleTopXPos, needleTopYPos); //moves the drawing pt 
		scaleDisplayObj.graphics.lineTo(needleTopXPos, needleBottomYPos); //draws a needle from the drawing pt
		needleTopXPos=_needleSpacing + needleTopXPos;
	}
}

/**
 * @public
 * Function draw text above the needle displaying the no of units(mins or secs) .
 *
 * @param unit of type Number - Unit value
 * @param needleTopXPos of type Number - needle X position
 * @param needleTopYPos of type Number - needle Y position
 * @return void
 */
private function drawTimeText(unit:Number, needleTopXPos:Number, needleTopYPos:Number):void{
	var uit:UITextField=new UITextField();
	uit.setColor(EditingConstants.SCALE_TEXT_COLOR);
	uit.text=unit.toString();
	uit.x=needleTopXPos;
	uit.y=(EditingConstants.SCALE_START_Y_POS - EditingConstants.SCALE_LONG_NEEDLE_HT) - EditingConstants.SCALE_TEXT_PADDING;
	scaleDisplayObj.addChild(uit);
}