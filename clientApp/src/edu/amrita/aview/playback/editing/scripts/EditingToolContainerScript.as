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
 * File			: EditingToolContainerScript.as
 * Module		: Video Editing
 * Developer(s)	: Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File deals with initiating the drawing of ruler scale and ribbon blocks in Video Editing component
 *
 */

import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
import edu.amrita.aview.playback.editing.EditingConstants;
import edu.amrita.aview.playback.editing.components.Ribbon;
import edu.amrita.aview.playback.editing.components.RibbonTitle;
import edu.amrita.aview.playback.editing.components.Scale;

import flash.events.Event;

import mx.logging.ILogger;
import mx.logging.Log;

/**
 * Variable holds the value of ribbon height.
 */
public var ribbonHeight:Number;

/**
 * Variable holds the value for displaying the number of units to
 * display according to the playback time(Scale display).
 */
public var numberUnits:Number;

/**
 * Variable holds the slider value
 */
public var needleSpacing:Number;

/**
 * Reference of aview player fileloadmanager.
 */
public var consolidatedXml:FileLoaderManager;

/**
 * XML for holding the presenter video xml data.
 */
public var presenterVideoXML:XML;

/**
 * XML for holding the viewer video xml data.
 */
public var viewerVideoXML:XML;

/**
 * XML for holding the document sharing xml data.
 */
public var documentSharingXML:XML;

/**
 * XML for holding the whiteboard xml data.
 */
public var whiteboardXML:XML;

/**
 * XML for holding the chat xml data.
 */
public var chatXML:XML;


/**
 * Variable of Scale class.
 */
private var scaleObj:Scale;

/**
 * Variable of Ribbon class for Presenter.
 */
private var presenterRibbon:Ribbon;

/**
 * Variable of Ribbon class for Viewer.
 */
private var viewerRibbon:Ribbon;

/**
 * Variable of Ribbon class for Document Sharing.
 */
private var documentSharingRibbon:Ribbon;

/**
 * Variable of Ribbon class for chat.
 */
public var chatRibbon:Ribbon;

/**
 * Variable of Ribbon class for Whiteboard.
 */
private var whiteBoardRibbon:Ribbon;

/**
 * Variable holds the value for positioning the Ribbon.
 */
private var yPosition:int;

/**
 * Variable holds the value for end time xml value.
 */
private var totalTime:int;

/**
 * XML for holding the end time xml data.
 */
private var endTimeXML:XML;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.playback.editing.scripts.EditingToolContainerScript.as");

/**
 * @public
 * Function for finding the number of units to display
 *  on the scale based on the total playback time.
 *
 * @param totalTime of type int - Total playback time
 * @return of type Number - Returns the calculated value
 *
 */
public function getNumberofUnits(totalTime:int):Number{
	var units:Number;
	// AKCR: please use conditional operator
	// AKCR: for e.g:  return (units < 1) ? totalTime % (1000 * 60) : totalTime / (1000 * 60);
	// AKCR: where is units getting assigned? Is this code being used?
	if (units < 1){
		units=totalTime % (1000 * 60);
	}
	else{
		units=totalTime / (1000 * 60);
	}
	return units;
}

/**
 *
 * @public
 * Function for finding the needle spacing.
 *
 * @param availWidth of type Number - Width of editingToolContainer
 *
 * @param totalTime of type int - Total playback time
 *
 * @return of type Number - Returns the calculated needle spacing.
 *
 */
public function getNeedleSpacing(availWidth:Number, totalTime:int):Number{
	var needleSpacing:Number=((availWidth - (EditingConstants.EDITOR_CONTAINER_RIGHT_PADDING + EditingConstants.SCALE_START_X_POS)) / (totalTime / (1000 * 60))); //distance between consecutive needles
	return needleSpacing;
}

/**
 * @public
 * Function for finding the ribbon height
 * based on the height of parent container.
 *
 * @param void
 * @return of type Number
 */
public function getRibbonHeight():Number{
	var ribonHeight:Number=this.owner.height * (EditingConstants.RIBBON_HEIGHT_PC / 100);
	return ribonHeight;
}

/**
 *
 * @public
 * Function for extracting the file name from the file path
 *
 * @param fullPath of type String
 * @return of type String
 *
 */
public function getFileName(fullPath:String):String{
	var fSlash:int=fullPath.lastIndexOf("/");
	var bSlash:int=fullPath.lastIndexOf("\\"); // reason for the double slash is just to escape the slash so it doesn't escape the quote!!!
	var slashIndex:int=fSlash > bSlash ? fSlash : bSlash;
	return fullPath.substr(slashIndex + 1);
}

/**
 * @public
 * Function is called on the creationComplete event of the outer canvas.
 * Gets the xml data and calls the function for creating the scale component.
 *
 * @param void
 * @return void
 *
 */
public function initEditingContainer():void{
	if(Log.isDebug()) log.debug("" + consolidatedXml);
	endTimeXML=consolidatedXml.endTimeXml;
	presenterVideoXML=consolidatedXml.pVideoXml;
	viewerVideoXML=consolidatedXml.vVideoXml;
	documentSharingXML=consolidatedXml.docXml;
	whiteboardXML=consolidatedXml.wbXml;
	chatXML=consolidatedXml.chatXml;
	ribbonHeight=getRibbonHeight();
	totalTime=endTimeXML.etime[0];
	numberUnits=getNumberofUnits(totalTime);
	needleSpacing=getNeedleSpacing(this.owner.width, totalTime);
	initScale();
}

/**
 * @private
 * Function draws the scale in the component.
 *
 * @param void
 * @return void
 */
private function initScale():void{
	scaleObj=new Scale();
	scaleObj.init();
	scaleObj.units=numberUnits;
	scaleObj.needleSpacingFn=needleSpacing;
	scaleObj.drawScale(this.owner.width);
	this.addChild(scaleObj);
	this.dispatchEvent(new Event("ScaleCreated"));
	drawPresenterVideoRibbon(); //draws a ribbon representing the presenter video
}

/**
 * @public
 * Function draws the ribbon and ribbon title for
 * presenter video in the container based on the xml data.
 *
 * @param void
 * @return void
 */
public function drawPresenterVideoRibbon():void{
	yPosition=EditingConstants.SCALE_START_Y_POS + EditingConstants.SCALE_RIBBON_PADDING;
	addRibbonTitle(yPosition, "../assets/images/videoUnselect.png", "Presenter Video");
	if (presenterRibbon == null){
		presenterRibbon=new Ribbon();
	}
	assignAttributes(presenterRibbon, presenterVideoXML);
	presenterRibbon.initVideoRibbon(presenterRibbon);
	this.addChild(presenterRibbon);
	drawViewerVideoRibbon(); //draws a ribbon representing the viewer video blocks
}

/**
 * @private
 * Function draws the ribbon and ribbon title for viewer
 * video in the container based on the xml data.
 *
 * @param void
 * @return void
 */
private function drawViewerVideoRibbon():void{
	yPosition=presenterRibbon.y + ribbonHeight + EditingConstants.SCALE_RIBBON_PADDING;
	addRibbonTitle(yPosition, "../assets/images/viewerVideo.png", "Viewer Video");
	if (viewerRibbon == null){
		viewerRibbon=new Ribbon();
	}
	assignAttributes(viewerRibbon, viewerVideoXML);
	viewerRibbon.initVideoRibbon(viewerRibbon);
	this.addChild(viewerRibbon);
	drawDocumentSharingRibbon(); //draws a ribbon representing the document sharing slides  
}

/**
 *
 * @private
 * Function draws the ribbon and ribbon title
 * for document sharing in the container based on the xml data.
 *
 * @param void
 * @return void
 */
private function drawDocumentSharingRibbon():void{
	yPosition=viewerRibbon.y + ribbonHeight + EditingConstants.SCALE_RIBBON_PADDING;
	addRibbonTitle(yPosition, "../assets/images/docUnselect.png", "Document");
	if (documentSharingRibbon == null){
		documentSharingRibbon=new Ribbon();
	}
	assignAttributes(documentSharingRibbon, documentSharingXML);
	documentSharingRibbon.initDSRibbon(documentSharingRibbon);
	this.addChild(documentSharingRibbon);
	drawWBRibbon(); //draws a ribbon representing the whiteboard
}

/**
 *
 * @private
 * Function draws the ribbon and ribbon title for whiteboard
 * in the container based on the xml data.
 *
 * @param void
 * @return void
 */
private function drawWBRibbon():void{
	yPosition=documentSharingRibbon.y + ribbonHeight + EditingConstants.SCALE_RIBBON_PADDING;
	addRibbonTitle(yPosition, "../assets/images/whiteboardUnselect.png", "Whiteboard");
	if (whiteBoardRibbon == null){
		whiteBoardRibbon=new Ribbon();
	}
	assignAttributes(whiteBoardRibbon, whiteboardXML);
	whiteBoardRibbon.initWBRibbon(whiteBoardRibbon);
	this.addChild(whiteBoardRibbon);
	drawChatRibbon(); //draws a ribbon representing the chat
}

/**
 * @private
 * Function draws the ribbon and ribbon title for
 *  chat in the container based on the xml data.
 *
 * @param void
 * @return void
 */
private function drawChatRibbon():void{
	yPosition=whiteBoardRibbon.y + ribbonHeight + EditingConstants.SCALE_RIBBON_PADDING;
	addRibbonTitle(yPosition, "../assets/images/chatUnselect.png", "Chat");
	if (chatRibbon == null){
		chatRibbon=new Ribbon();
	}
	assignAttributes(chatRibbon, chatXML);
	chatRibbon.initChatRibbon(chatRibbon);
	this.addChild(chatRibbon);
	if (this.contains(chatRibbon)){
		this.dispatchEvent(new Event("chatBlockCreated"));
	}
}


/**
 * @private
 * Function for creating the ribbon title for each module and adding to the container.
 *
 * @param yPosition of type int - Y co ordinate for placing the ribbon title.
 * @param imageSource of type String - Image source
 * @param description of type String - Description about module.
 * @return void
 *
 */
private function addRibbonTitle(yPosition:int, imageSource:String, description:String):void{
	var ribbonTitle:RibbonTitle=new RibbonTitle();
	ribbonTitle.ribbonHeight=ribbonHeight;
	ribbonTitle.x=EditingConstants.SCALE_START_X_POS - (EditingConstants.RIBBON_TEXT_WIDTH);
	ribbonTitle.width=EditingConstants.RIBBON_TEXT_WIDTH;
	ribbonTitle.yPos=yPosition;
	ribbonTitle.shortName=imageSource;
	ribbonTitle.desc=description;
	ribbonTitle.initRibbonTitle();
	ribbonTitle.setStyle("paddingTop", (ribbonHeight / 2) * 0.5);
	this.addChild(ribbonTitle);
}

/**
 * @private
 * Function for assigining the values to the ribbon.
 *
 * @param ribbon of type Ribbon - Ribbon module name.
 * @param xml of type XML - Module xml data.
 * @return void
 */
private function assignAttributes(ribbon:Ribbon, xml:XML):void{
	ribbon.startXPosn=EditingConstants.SCALE_START_X_POS;
	ribbon.startYPosn=yPosition;
	ribbon.xmlContent=xml;
	ribbon.numUnits=numberUnits;
	ribbon.needleSpacing=needleSpacing;
	ribbon.height=ribbonHeight;
	ribbon.totalTime=totalTime;
}

/**
 * @private
 * Function invoked during the resize of container.
 *
 * @param void
 * @return void
 */
private function resizeEditingToolContainer():void{
	presenterRibbon=viewerRibbon=documentSharingRibbon=whiteBoardRibbon=chatRibbon=null;
	if (scaleObj){
		this.removeAllChildren();
		initEditingContainer();
	}
}
