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
 * File			: RibbonScript.as
 * Module		: Video Editing
 * Developer(s)	: Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for creating ribbons for video, document sharing, chat, whiteboard.
 *
 */
import edu.amrita.aview.playback.editing.components.ChatBlock;
import edu.amrita.aview.playback.editing.components.ChatLine;
import edu.amrita.aview.playback.editing.components.DocumentBlock;
import edu.amrita.aview.playback.editing.components.SlideBlock;
import edu.amrita.aview.playback.editing.components.VideoBlock;

import mx.controls.Label;

/**
 * XML data of corresponding module.
 */
private var _xmlContent:XML;

/**
 * Variable holds the value for displaying the number of units to display according to the playback time(Scale display).
 */
private var _numUnits:Number;

/**
 * Variable holds the data of X co ordinate position of ribbon.
 */
private var _startXPosn:Number;

/**
 * Variable holds the data of Y co ordinate position of ribbon.
 */
private var _startYPosn:Number;

/**
 * Distance between scale needles.
 */
private var _needleSpacing:Number;

/**
 * Variable holds the height of ribbon.
 */
private var _ribbonHeight:Number;

/**
 * Variable holds the data of total playback time.
 */
private var _totalTime:Number;

/**
 * Variable of 'ChatLine'.
 */
private var chatLine:ChatLine;

/**
 * X coordinate value for displaying the chat line.
 */
private var chatLineXCoordinate:Number;

/**
 * Y coordinate value for displaying the chat line.
 */
private var chatLineYCoordinate:Number;

/**
 * Length of chat line.
 */
private var lineLength:Number;

/**
 * Setter of 'numUnits'.
 */
public function set numUnits(value:Number):void{
	_numUnits=value;
}

/**
 * Setter of 'xmlContent'.
 */
public function set xmlContent(value:XML):void{
	_xmlContent=value;
}

/**
 * Setter of 'startXPosn'.
 */
public function set startXPosn(value:Number):void{
	_startXPosn=value;
}

/**
 * Setter of 'startYPosn'.
 */
public function set startYPosn(value:Number):void{
	_startYPosn=value;
}

/**
 * Setter of 'needleSpacing'.
 */
public function set needleSpacing(value:Number):void{
	_needleSpacing=value;
}

/**
 * Setter of 'totalTime'.
 */
public function set totalTime(value:int):void{
	_totalTime=value;
}

/**
 * @public
 * Function draws the video ribbon based on the XML data.
 *
 * @param rb of type Ribbon
 * @return void
 */
public function initVideoRibbon(rb:Ribbon):void{
	var startTime:int;
	var endTime:int;
	var filePath:String;
	var noOfVids:int;
	noOfVids=_xmlContent.children().length();
	positionRibbon();
	// Check if video tag exist or not
	if (noOfVids > 0){
		// Loops through the video tag for creating seperate block for each tag
		for (var i:int=0; i < _xmlContent.children().length(); i++){
			startTime=_xmlContent.video[i].attribute("stime");
			endTime=_xmlContent.video[i].attribute("etime");
			filePath=_xmlContent.video[i].attribute("displyname");
			createVideoBlock(startTime, endTime, getFileName(filePath), rb);
		}
	}
	else{
		drawEmptyRibbon("No videos were recorded");
	}
}

/**
 * @public
 * Function extracts the file name.
 *
 * @param fullPath of type String
 * @return of type String
 */
// AKCR: IMPORTANT: this exact function is already defined in EditingToolContainerScript.as file. Please remove this function
public function getFileName(fullPath:String):String{
	var fSlash:int=fullPath.lastIndexOf("/");
	var bSlash:int=fullPath.lastIndexOf("\\"); // reason for the double slash is just to escape the slash so it doesn't escape the quote!!!
	var slashIndex:int=fSlash > bSlash ? fSlash : bSlash;
	return fullPath.substr(slashIndex + 1);
}


/**
 * @public
 * Function draws the document ribbon based on the XML data.
 *
 * @param rb of type Ribbon
 * @return void
 */
public function initDSRibbon(rb:Ribbon):void{
	var startTime:int;
	var endTime:int;
	var filePath:String;
	var noOfDocs:int;
	var slideStartTime:int;
	var slideEndTime:int;
	var docName:String;
	var thumbSource:String;
	var pageNo:int;
	noOfDocs=_xmlContent.children().length();
	positionRibbon();
	// Check if document tag exist or not
	if (noOfDocs > 0){
		// Loops through the document tag for creating document block
		for (var i:int=0; i < _xmlContent.children().length(); i++){
			// AKCR: for this single if/else, please use the conditional operators
			if (i == 0){
				startTime=_xmlContent.docloaded[i].attribute("ctime");
			}
			else{
				startTime=_xmlContent.docloaded[i].size.attribute("ctime");
			}
			
			// AKCR: for this single if/else, please use the conditional operators
			if (i == (_xmlContent.children().length() - 1)){
				endTime=_totalTime;
			}
			else{
				endTime=_xmlContent.docloaded[i + 1].size.attribute("ctime");
			}
			//getFileName gets the name of the file and passes to docName variable 
			docName=getFileName(_xmlContent.docloaded[i].attribute("src"));
			
			createDocBlock(startTime, endTime, "Doc-" + (i + 1), rb, i);
			
			var pages:XMLList=_xmlContent.docloaded[i].size.event.(@action == 'page');
			var pagesXML:XML=new XML("<pages>" + pages.toXMLString() + "</pages>");
			// Loops through the document page tag for creating slide block
			for (var j:int=0; j < pagesXML.children().length(); j++){
				pageNo=pagesXML.event[j].attribute("pageno");
				// AKCR: for this single if/else, please use the conditional operators
				if (i == 0 && j == 0){
					slideStartTime=_xmlContent.docloaded[i].attribute("ctime");
				}
				else{
					slideStartTime=pagesXML.event[j].attribute("ctime");
				}
				
				// AKCR: for this single if/else, please use the conditional operators
				if (j == (pagesXML.children().length() - 1)){
					slideEndTime=endTime;
				}
				else{
					slideEndTime=pagesXML.event[j + 1].attribute("ctime");
				}
				var src:String=_xmlContent.docloaded[i].attribute("src");
				
				thumbSource=src.substring(0, src.lastIndexOf("/") + 1) + "@@-Thumbnails-@@/" + _xmlContent.docloaded[i].attribute("orginalName") + "_files/" + src.substr(src.lastIndexOf("/") + 1) + "/thumbnail_" + pageNo + ".jpg";
				createSlideBlock(slideStartTime, slideEndTime, docName, thumbSource, rb, j);
			}
		}
	}
	else{
		drawEmptyRibbon("No documents were used");
	}
}

/**
 * @public
 * Function draws the whiteboard ribbon based on the XML data.
 *
 * @param rb of type Ribbon
 * @return void
 */
public function initWBRibbon(rb:Ribbon):void{
	var startTime:int;
	var endTime:int;
	var filePath:String;
	var pageNum:int;
	var isEmpty:Boolean=true;
	
	positionRibbon();
	// Check if whiteboard tag exist or not
	if (_xmlContent.children().length() > 0){
		// Loops through the whiteboard tag for creating block
		for (var i:int=0; i < _xmlContent.children().length(); i++){
			// Check for sub tags
			// If so, create whiteboard block
			if (_xmlContent.page[i].children().length() > 0){
				pageNum=_xmlContent.page[i].attribute("num");
				startTime=_xmlContent.page[i].attribute("ctime");
				// AKCR: for this single if/else, please use the conditional operators
				if (i == (_xmlContent.children().length() - 1)){
					endTime=_totalTime;
				}
				else{
					endTime=_xmlContent.page[i + 1].attribute("ctime");
				}
				createVideoBlock(startTime, endTime, "p" + pageNum, rb);
				isEmpty=false;
			}
		}
	}
	
	if (isEmpty == true){
		drawEmptyRibbon("Nothing was drawn on the whiteboard");
	}
}

/**
 * @public
 * Function draws the chat ribbon based on the XML data.
 *
 * @param rb of type Ribbon
 * @return void
 */
public function initChatRibbon(rb:Ribbon):void{
	var startTime:int;
	var endTime:int;
	var filePath:String;
	var noOfVids:int;
	var chatContentLength:int=_xmlContent.children().length();
	positionRibbon();
	// Check if chat xml tag exist or not
	if (chatContentLength > 0){
		var block:ChatBlock=new ChatBlock();
		block.x=_xmlContent.msg[0].attribute("ctime") / (1000 * 60) * _needleSpacing - 1;
		block.width=(_totalTime / (1000 * 60) - _xmlContent.msg[0].attribute("ctime") / (1000 * 60)) * _needleSpacing;
		block.height=this.height * (95 / 100);
		block.needleSpacingSetter=_needleSpacing;
		rb.addChild(block);
		// loops thrpugh each xml tag for creating a line between them
		for (var i:int=0; i < _xmlContent.children().length(); i++){
			chatLineXCoordinate=(_xmlContent.msg[i].attribute("ctime") / (1000 * 60) * _needleSpacing) - block.x + 1;
			chatLineYCoordinate=block.y + block.height / 2;
			lineLength=block.height / 3;
			chatLine=new ChatLine();
			chatLine.init(chatLineXCoordinate, chatLineYCoordinate, lineLength);
			block.addChild(chatLine);
		}
	}
	else{
		drawEmptyRibbon("No chat were recorded");
	}
}

/**
 * @private
 * Function places the ribbon position.
 *
 * @param void
 * @return void
 */
private function positionRibbon():void{
	this.x=_startXPosn;
	this.y=_startYPosn;
	this.width=_needleSpacing * _numUnits; //width of the ribbon where the blocks will be placed
}

/**
 * @private
 * Function adds empty message in the corresponding ribbon.
 *
 * @param emptyString of type String
 * @return void
 */
private function drawEmptyRibbon(emptyString:String):void{
	var noVidLabel:Label=new Label();
	noVidLabel.text=emptyString;
	noVidLabel.styleName="noVideoBlock";
	noVidLabel.percentWidth=100;
	this.addChild(noVidLabel);
}

/**
 * @public
 * Function creates a video block with text content.
 *
 * @param sTime of type int - Start time.
 * @param eTime of type int - End time.
 * @param videoBlockText of type String - Text to display.
 * @param rb of type Ribbon.
 *
 * @return void
 */
/**
 * creates a text area which denotes a video block with text content
 * inputs - start time, end time and text to be displayed
 */
public function createVideoBlock(sTime:int, eTime:int, videoBlockText:String, rb:Ribbon):void{
	var block:VideoBlock=new VideoBlock();
	block.sTime=sTime;
	block.eTime=eTime;
	block.label=videoBlockText;
	block.needleSpacing=_needleSpacing;
	block.height=this.height * (95 / 100);
	block.setStyle("paddingTop", (_ribbonHeight / 2) * 0.4);
	block.initBlock();
	rb.addChild(block);
}

/**
 * @public
 * Function creates a document block with text content.
 *
 * @param sTime of type int - Start time.
 * @param eTime of type int - End time.
 * @param videoBlockText of type String - Text to display.
 * @param rb of type Ribbon.
 * @param docCount of type int - Document Count.
 *
 * @return void
 */
public function createDocBlock(sTime:int, eTime:int, videoBlockText:String, rb:Ribbon, docCount:int):void{
	var block:DocumentBlock=new DocumentBlock();
	block.sTime=sTime;
	block.eTime=eTime;
	block.needleSpacing=_needleSpacing;
	block.height=this.height * (95 / 100);
	block.label=videoBlockText;
	block.setStyle("borderThickness", 2.5);
	block.setStyle("cornerRadius", 10);
	block.setStyle("fontWeight", "bold");
	block.setStyle("cornerRadius", 7);
	block.alpha=1;
	block.setStyle("paddingTop", (_ribbonHeight / 2) * 0.4);
	block.id=docCount.toString();
	block.initBlock();
	rb.addChild(block);
}

/**
 * @public
 * Function creates a slide block with text content.
 *
 * @param sTime of type int - Start time.
 * @param eTime of type int - End time.
 * @param docName of type String - Text to display.
 * @param thumbSource of type String - Image source.
 * @param rb of type Ribbon.
 * @param docCount of type int - Document Count.
 *
 * @return void
 */
public function createSlideBlock(sTime:int, eTime:int, docName:String, thumbSource:String, rb:Ribbon, docCount:int):void{
	var block:SlideBlock=new SlideBlock();
	block.sTime=sTime;
	block.eTime=eTime;
	block.needleSpacing=_needleSpacing;
	block.docName=docName;
	block.thumbSource=thumbSource;
	block.pageNo=docCount + 1;
	block.height=this.height * (95 / 100);
	block.setStyle("paddingTop", (_ribbonHeight / 2) * 0.4);
	block.initBlock();
	rb.addChild(block);
}