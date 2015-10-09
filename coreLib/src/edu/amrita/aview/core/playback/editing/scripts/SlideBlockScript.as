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
 * File			: SlideBlockScript.as
 * Module		: Video Editing
 * Developer(s)	: Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for creating slide block, highlighting each slides on mouse over.
 *
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.playback.editing.components.PopUpDocumentThumbNail;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

/**
 * Variable of 'PopUpDocumentThumbNail'.
 */
private var popupObj:PopUpDocumentThumbNail;

/**
 * Variable of 'DropShadowFilter'.
 */
private var shadow:DropShadowFilter;

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
 * Variable for holding document name.
 */
private var _docName:String;

/**
 * Variable for holding the image source of document page.
 */
private var _thumbSource:String;

/**
 * Variable for holding the current page number.
 */
private var _pageNo:int;

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
 * Setter of 'needleSpacing'.
 */
public function set needleSpacing(value:Number):void{
	_needleSpacing=value;
}

/**
 * Setter of 'docName'.
 */
public function set docName(value:String):void{
	_docName=value;
}

/**
 * Setter of 'thumbSource'.
 */
public function set thumbSource(value:String):void{
	_thumbSource=value;
}

/**
 * Setter of 'pageNo'.
 */
public function set pageNo(value:int):void{
	_pageNo=value;
}

/**
 * @public
 * Function assigns the attribute values and styles to the block.
 *
 * @param void
 * @return void
 */
public function initBlock():void{
	this.htmlText=_videoBlockText;
	this.verticalScrollPolicy="off"; // removing VScrollbars if any
	this.x=_sTime / (1000 * 60) * _needleSpacing;
	this.width=((_eTime / (1000 * 60)) - (_sTime / (1000 * 60))) * _needleSpacing;
	this.selectable=false;
	assignStyleToBlock(Number(this.id), "normalSlideBlock");
}

/**
 * @private
 * Function styles the block.
 *
 * @param value of type int
 * @param data of type String
 * @return void
 */
private function assignStyleToBlock(value:int, data:String):void{
	// AKCR: DUPLICATE please use the conditional operator for thsi simeple if else. This is a duplicate function defined in DocumentBlockScript.as	 
	if (value % 2 == 0)
		this.styleName=data + "Odd";
	else
		this.styleName=data + "Even";
}

/**
 * @private
 * Function invokes on the mouse over of slide block.
 *
 * @param event of type MouseEvent
 * @return void
 */
private function highlightSlideBlock(event:MouseEvent):void{
	assignStyleToBlock(Number(this.id), "highlightSlideBlock");
	showThumbnail(event);
}

/**
 * @private
 * Function invokes on the mouse out of slide block.
 *
 * @param event of type MouseEvent
 * @return void
 */
private function normalSlideBlock(event:MouseEvent):void{
	assignStyleToBlock(Number(this.id), "normalSlideBlock");
	hideThumbnail(event);
}


/**
 * @private
 * Function creates shadow effect for block.
 *
 * @param void
 * @return void
 */
private function init():void{
	shadow=new DropShadowFilter();
	shadow.distance=10;
	shadow.angle=25;
}

/**
 * @private
 * Function invokes on the mouse over for displaying the thumbnail of block as tooltip.
 *
 * @param event of type MouseEvent
 * @return void
 */
private function showThumbnail(event:MouseEvent):void{
	init();
	if (!popupObj){
		popupObj=new PopUpDocumentThumbNail();
		PopUpManager.addPopUp(popupObj, this);
		var point1:flash.geom.Point=new flash.geom.Point(0, 0);
		point1=event.currentTarget.localToGlobal(point1);
		if (point1.x + 140 > FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.videoEditor.width){
			var point:int=point1.x + 150 - FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.videoEditor.width;
			point1.x=point1.x - point;
		}
		popupObj.x=point1.x + 5;
		popupObj.y=point1.y - (popupObj.height + 15);
		popupObj.filters=[shadow]
		popupObj.lblDocumentName.text=_docName; // Name of the document
		popupObj.imgSlideThumb.source=ClassroomContext.RECORDED_CONTENT_URL + "/" + ClassroomContext.RECORDED_CONTENT_FILE_PATH + "/Contents/" + _thumbSource;
		popupObj.lblPageNo.text="Page No:" + _pageNo; // Page number of the document
	}
}

/**
 * @private
 * Function invokes on the mouse out for removing the thumbnail.
 *
 * @param event of type MouseEvent
 * @return void
 */
private function hideThumbnail(event:MouseEvent):void{
	PopUpManager.removePopUp(popupObj);
	popupObj=null;
}
