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
 * File	    	: ChatBlockScript.as
 * Module		: Video Editing
 * Developer(s) : Vimal Mahendran, Sreelekshmi, Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains all the functionalities of chat block
 * in video editing time line.
 *
 * */

import edu.amrita.aview.core.playback.editing.components.EditingToolContainer;

import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.controls.ToolTip;
/**
 * Distance between scale needles.
 */
private var needleSpacing:Number;

/**
 * XML variable for storing the chat xml data.
 */
private var chatXML:XML;

/**
 * Tooltip for showing while mouse over on chat block.
 */
private var chatBlockTooltip:ToolTip=new ToolTip();

/**
 * Variable holds the tool tip text.
 */
private var chatBlockToolTipText:String;


/**
 *
 * @public
 * Function for setting the value of 'needleSpacing'.
 *
 * @param value of type Number
 * @return void
 *
 */
public function set needleSpacingSetter(value:Number):void{
	needleSpacing=value;
}


/**
 *
 * @private
 * Function invokes when mouse move happens inside the chat block.
 * Creates the tooltip and attaches the chat text.
 *
 * @param event of type MouseEvent.
 * @return void
 *
 */
private function chatBlockMouseMove(event:MouseEvent):void{
	chatXML=EditingToolContainer(Canvas(this.parent).parent).chatXML;
	var time:Number=((event.currentTarget.contentMouseX + (chatXML.msg[0].@ctime / (1000 * 60) * needleSpacing - 1)) / needleSpacing) * (1000 * 60);
	displayChatContent(time);
}



/**
 *
 * @private
 * Function passes the time of chat text to be displayed.
 * Loops through the chat XML and displays the tooltip.
 *
 * @param time of type Number
 * @return void
 *
 */
private function displayChatContent(time:Number):void{
	for (var i:int=0; i < chatXML.children().length(); i++){
		var toolTipX:flash.geom.Point=new flash.geom.Point(this.stage.mouseX, this.stage.mouseY);
		toolTipX=this.globalToLocal(toolTipX);
		var thisX:flash.geom.Point=new flash.geom.Point(this.x, this.y);
		thisX=this.globalToLocal(thisX);
		
		if (Number(chatXML.msg[i].@ctime) > time)
			break;
		chatBlockToolTipText=chatXML.msg[i].@content;
		this.chatBlockTooltip.text=chatBlockToolTipText;
		chatBlockTooltip.x=toolTipX.x;
		if (toolTipX.x + chatBlockTooltip.width > thisX.x + this.width){
			chatBlockTooltip.x=((thisX.x + this.width) - (chatBlockTooltip.width));
		}
	}
}



/**
 *
 * @private
 * Function invokes when the mouse out happens in chat block.
 * Removes the tooltip and sets the default background color.
 *
 * @param event of type MouseEvent
 * @return void
 */
private function chatBlockMouseOut(event:MouseEvent):void{
	this.removeChild(chatBlockTooltip);
	event.stopPropagation();
	event.preventDefault();
	// AKCR: please make the hex value a constant
	this.setStyle("backgroundColor", "#FFD4AA");
}

/**
 * @private
 * Function invokes when the mouse over happens in chat block.
 * Adds the tooltip and changes the background.
 *
 * @param event of type MouseEvent
 * @return void
 *
 */
private function chatBlockMouseOver(event:MouseEvent):void{
	chatBlockTooltip.text=chatBlockToolTipText;
	this.addChild(chatBlockTooltip);
	if (this.stage.mouseX + chatBlockTooltip.width + 10 > this.x + this.width){
		chatBlockTooltip.x=((this.x + this.width) - (chatBlockTooltip.width + 10));
	}
	event.stopPropagation();
	event.preventDefault();
	// AKCR: please make the hex value a constant
	this.setStyle("backgroundColor", "#FFD47F");
}
