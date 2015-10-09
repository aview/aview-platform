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
 * File			: InsertLectureTimeScript.as
 * Module		: Video Editing
 * Developer(s)	: Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for validating user entered data and saving the data.
 *
 */
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.playback.editing.scripts.CloseFileHandler;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.controls.Label;
import mx.core.mx_internal;
import mx.events.SliderEvent;

// AKCR: single line comments should be used in their relavant format. Also, description is not always needed for verbose variable names 
/**
 * Variable holds the data of user entered time in seconds for inserting lecture.
 */
public var insertLectureTimeInSeconds:Number=0;

/**
 * Variable holds the data of user entered time in minutes for inserting lecture.
 */
public var insertLectureTimeInMinutes:Number=0;

/**
 * Variable holds the value for high lighting the text values
 */
private var highlightTextOnClick:Boolean=true;


/**
 * @public
 * Function call after the creation complete of 'InsertLectureTime' component.
 * Creates the label for showing 'Min' and 'Sec' and also checks user is publishing video in AVIEW Classroom.
 *
 * @param void
 * @return void
 */
private function insertLectureTimeCreationComplete():void{
	mx_internal::closeButton.height=mx_internal::closeButton.width=18;
	var lbStartMin:Label=new Label(), lbStartSec:Label=new Label(), lbEndMin:Label=new Label(), lbEndSec:Label=new Label();
	lbStartMin.x=lbStartSec.x=lbEndMin.x=lbEndSec.x=txtStartTimeMin.width / 2;
	lbStartMin.y=lbStartSec.y=lbEndMin.y=lbEndSec.y=1;
	lbStartMin.text=lbEndMin.text="Min";
	lbStartSec.text=lbEndSec.text="Sec"
	lbStartMin.width=lbStartSec.width=lbEndMin.width=lbEndSec.width=25;
	lbStartMin.height=lbStartSec.height=lbEndMin.height=lbEndSec.height=20;
	txtStartTimeMin.addChild(lbStartMin);
	txtStartTimeSec.addChild(lbStartSec);
	if (ClassroomContext.isUserPublishingVideo){
		MessageBox.show("Camera is used by another application", "INFO", MessageBox.MB_OK, this, removeInsertTimePopup);
	}
}

/**
 * @private
 * Function calls on the click of 'OK' button of Pop up for notifying user about the camera usage.
 * Calls the cancel function.
 *
 * @param event of type MessageBoxEvent.
 * @return void
 */
private function removeInsertTimePopup(event:MessageBoxEvent):void{
	cancel();
}

/**
 * @private
 * Function dispatches the close event.
 *
 * @param void.
 * @return void
 */
private function cancel():void{
	var dis:CloseFileHandler=new CloseFileHandler(CloseFileHandler.CLOSED_VIDEO_SETTING_CANCEL);
	this.dispatchEvent(dis);
}

/**
 * @private
 * Function saves the user entered time data and dispatches the close event.
 *
 * @param void.
 * @return void
 */
private function saveChanges():void{
	insertLectureTimeInSeconds=Number(txtStartTimeSec.text.toString());
	insertLectureTimeInMinutes=Number(txtStartTimeMin.text.toString());
	// Checks the seconds value is greater than 59
	// If so, alerts the user.
	if (insertLectureTimeInSeconds > 59){
		Alert.show("Invalid time format.\n Please choose different values", "Video Insert", 0, this);
		return;
	}
	var dis:CloseFileHandler=new CloseFileHandler(CloseFileHandler.CLOSED_VIDEO_SETTING_OK);
	this.dispatchEvent(dis);
}

/**
 * @public
 * Finction used for highlight text in textInput field on click
 *
 * @param event of type MouseEvent.
 * @return void
 */
public function onClickTextBox(event:MouseEvent):void{
	var didUserHighlight:Boolean=Boolean(event.target.selectionBeginIndex != event.target.selectionEndIndex);
	if (highlightTextOnClick && !didUserHighlight){
		event.preventDefault();
		event.target.setSelection(0, event.target.text.length);
		highlightTextOnClick=false;
	}
}

/**
 * @public
 * Function invokes when textbox loses the focus.
 *
 * @param event of type FocusEvent.
 * @return void
 */
public function onTextBoxLoseFocus(event:FocusEvent):void{
	highlightTextOnClick=true;
	if (event.currentTarget.text.length <= 1){
		event.currentTarget.text='0' + event.currentTarget.text;
	}
}

/**
 * @public
 * Function invokes when textbox data changes.
 * Validates the time data
 *
 * @param event of type Event.
 * @return void
 */
public function onTextChange(event:Event):void{
	if (((Number(txtStartTimeMin.text) * 60) < this.parentApplication.aviewplayer.seekBar.maximum)){
		this.parentApplication.aviewplayer.seekBar.setThumbValueAt(0, ((Number(txtStartTimeMin.text) * 60) + Number(txtStartTimeSec.text)));
	}
	else{
		Alert.show("Start time must not be greater than total time", "Video Editor", 0, this);
		this.parentApplication.aviewplayer.seekBar.setThumbValueAt(0, this.parentApplication.aviewplayer.seekBar.maximum / 5);
		var evenSLider:SliderEvent=new SliderEvent(SliderEvent.CHANGE);
		this.parentApplication.aviewplayer.seekBar.dispatchEvent(evenSLider);
	}
}
