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
 * File			: RibbonTitleScript.as
 * Module		: Video Editing
 * Developer(s)	: Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for creating image and tooltip for ribbon header.
 *
 */

import mx.controls.Image;
// AKCR: please use the single line comment format
/**
 * Variable holds the height of ribbon title.
 */
private var _ribbonHeight:Number;

/**
 * Variable holds the data of Y co ordinate position of ribbon header.
 */
private var _yPos:int;

/**
 * Variable holds the data of title name.
 */
private var _shortName:String;

/**
 * Variable holds the data of title description.
 */
private var _desc:String;

/**
 * Title image.
 */
private var ribbonImg:Image=new Image();

/**
 * Setter of 'ribbonHeight'.
 */
public function set ribbonHeight(value:Number):void{
	_ribbonHeight=value;
}

/**
 * Setter of 'yPos'.
 */
public function set yPos(value:int):void{
	_yPos=value;
}

/**
 * Setter of 'shortName'.
 */
public function set shortName(value:String):void{
	_shortName=value;
}

/**
 * Setter of 'desc'.
 */
public function set desc(value:String):void{
	_desc=value;
}

/**
 * @public
 * Function creates the ribbon title.
 * Assigns the attribute values.
 *
 * @param void
 * @return void
 */
public function initRibbonTitle():void{
	this.addChild(ribbonImg);
	ribbonImg.source=_shortName;
	ribbonImg.height=_ribbonHeight;
	ribbonImg.width=this.width;
	this.y=_yPos;
	this.toolTip=_desc;
	this.height=_ribbonHeight;
}