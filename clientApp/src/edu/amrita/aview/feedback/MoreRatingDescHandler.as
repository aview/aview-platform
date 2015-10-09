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
 * File			: MoreRatingDescHandler.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 *
 * File to handle more detailed rating description
 */
//ashCR: TODO; multi line comments can be reduced to single line comments by using // type comments
/**
 * Importing the utils package
 */
import com.adobe.utils.StringUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

/**
 * for storing the close button in the normal state
 */
[Embed(source="assets/images/Medium_close.png")]
[Bindable]
public var closePng:Class;

/**
 * for storing the close button in the mouse over state
 */
[Embed(source="assets/images/Medium_close_over.png")]
[Bindable]
public var closeOverPng:Class;

/**
 * For storing the comments
 */
[Bindable]
public var comment:String='';
/**
 * For storing the comment title
 */
[Bindable]
public var titleName:String='';


/**
 * For storing the component name to identify that which component is selected
 */

[Bindable]
public var componentName:String='';
/**
 * Dynamicaly creating the close button for closing the popup window
 * this button will add to the FeedbackForm title bar at the time of creation complete
 **/
private var closer:mx.controls.Button=new mx.controls.Button();

[Bindable]
public var parentComponent:Object=new Object();

/**
 * @protected
 * This function will invoke at the time of
 * creation complete of the MoreRatingDesc Module
 *
 * @param event type FlexEvent
 * @return void
 */
protected function init(event:FlexEvent):void
{
	
	// ashCR: TODO: what is the login behing the majic numbers 18, 8, 7 etc? Will this cause issues when the content is rendered on different screen sizes
	this.titleBar.addChild(closer);
	closer.width=18;
	closer.height=18;
	closer.x=this.width - closer.width - 8;
	closer.y=7;
	closer.toolTip="Close";
	closer.addEventListener(MouseEvent.CLICK, function(evt:Event):void
	{
		close(event)
	});
	closer.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	closer.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	closer.setStyle('icon', closePng);
	closer.useHandCursor=false;

	if(componentName=='overall')
		titleName = 'Overall Quality';
	else if(componentName=='audio')
		titleName = 'Audio Quality';
	else if(componentName=='video')
		titleName = 'Video Quality';
	else if(componentName=='interaction')
		titleName = 'Interaction';
	else if(componentName=='whiteboard')
		titleName = 'Whiteboard';
	else if(componentName=='document')
		titleName = 'Document Sharing';
	else if(componentName=='desktop')
		titleName = 'Desktop Sharing';
	else if(componentName=='userInterAct')
		titleName = 'Ease of use';
}

/**
 * @private
 * For changing the close button on the mouse over
 * this will invoke from the mouse over in the close button
 *
 * @param event type MouseEvent
 * @return void
 **/
private function mouseOverHandler(event:MouseEvent):void
{
	closer.setStyle('icon', closeOverPng);
}

/**
 * @private
 * For restoring the close button on the mouse out
 * this will invoke from the mouse out in the close button
 *
 * @param event type MouseEvent
 * @return void
 **/
private function mouseOutHandler(event:MouseEvent):void
{
	closer.setStyle('icon', closePng);
}

/**
 * @protected
 * For saving the comments
 * This method will invoke from the btnSave click
 * The method will take the value from the component and saved it to the variable
 * and close the window
 *
 * @param event type MouseEvent
 * @return void
 **/
protected function saveComments(event:MouseEvent):void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.isPopupFeedbackComment=false;
	parentComponent.showComments(StringUtil.trim(txtComment.text), componentName);
	close();
}

/**
 * @private
 * This will close the window
 * This method will invoke from the saveComments
 *
 * @param event type * to handle the close event and mouse event
 * @return void
 **/
private function close(event:*=null):void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.isPopupFeedbackComment=false;
	PopUpManager.removePopUp(this);
}

private function getTitleName():String
{
	var strTitle:String='';
	
	return strTitle;
}