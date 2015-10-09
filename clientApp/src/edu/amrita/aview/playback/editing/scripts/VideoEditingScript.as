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
 * File	    	: VideoEditingScript.as
 * Module		: VideoEditing
 * Developer(s) : Ashish Pillai
 * Reviewer(s)	: Sivaram SK,Remya T
 *
 * File contains all the functionalities related to
 * video editing and saving the xml to the server.
 *
 */


//--------------------------------------
//  imports
//--------------------------------------
import edu.amrita.aview.core.entry.MyTitleWindow;
import edu.amrita.aview.playback.editing.EditingConstants;
import edu.amrita.aview.playback.editing.components.EditLecture;
import edu.amrita.aview.playback.editing.components.InsertLectureTime;
import edu.amrita.aview.playback.editing.components.VideoRecordComponent;
import edu.amrita.aview.playback.editing.scripts.CloseFileHandler;
import edu.amrita.aview.playback.editing.skins.SliderThumbSkin;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import mx.controls.HSlider;
import mx.controls.sliderClasses.Slider;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.ResizeEvent;
import mx.events.SliderEvent;
import mx.managers.PopUpManager;

import spark.components.Label;


//-----------------------------------------
//  Public Variables
//-----------------------------------------

/**
 * Class holds the icon for video editing.
 */
[Bindable]
public var imgCutSessionIcon:Class=EditingConstants.cutActiveIcon;

/**
 * Class holds the icon for stopping video playback.
 */
[Bindable]
public var imgStopIcon:Class=EditingConstants.stopActiveIcon;

/**
 * Class holds the icon of pause video playback.
 */
[Bindable]
public var imgPlayIcon:Class=EditingConstants.playInactiveIcon;

/**
 * Class holds the icon of inserting video into the existing playback.
 */
[Bindable]
public var imgInsertSessionIcon:Class=EditingConstants.insertActiveIcon;

//------------------------------------------
//  metadata
//------------------------------------------
// AKCR: please use single line comment format

/**
 * Variable of 'HSlider'.
 */
[Bindable]
public var seekBar:HSlider;

/**
 * Variable of 'SliderThumbSkin'
 */
private var sliderThumbSkinObject:SliderThumbSkin=new SliderThumbSkin();

/**
 * Variable of 'Slider'
 */
private var sliderObject:Slider;

/**
 * Variable holds the current thumb value
 */
private var thumbIndex:int;

/**
 * Array hold the data 'Start Time' and 'End Time'
 */
private var arData:Array;

/**
 * Variable hold the seek bar value
 */
private var seekBarValue:Number;

/**
 * Variable hold the value for high lighting the text values
 */
private var highlightTextOnClick:Boolean=true;

/**
 * Variable hold the value for high lighting the text values
 */
private var lblEditNotification:Label=new Label();

/**
 * Variable of 'CutLecture'
 */
private var cutLectureObj:EditLecture;

/**
 * Variable of 'VideoRecordComponent'
 */
private var insertVideoObj:VideoRecordComponent;

/**
 * Variable of 'MyTitleWindow'
 */
private var objRecordVideo:MyTitleWindow;

/**
 * Variable holds the class id data.
 */
private var classIdValue:Array;

/**
 * Variable of 'InsertLectureTime'.
 */
private var objInsertLectureTime:InsertLectureTime;

/**
 * Variable holds the value that user selects for inserting an video into the existing lecture.
 */
private var isInsertLectureClicked:Boolean=false;

/**
 * Variable holds the seconds time of inserting new lecture.
 */
private var insertVideoSecondValue:Number;

/**
 * Variable holds the minute time of inserting new lecture.
 */
private var insertVideoMinuteValue:Number;

/**
 * Variable holds the value of the start time indicating slide.
 */
private var startSlideForCuttingVideo:Number;

/**
 * Variable holds the value of the end time indicating slide.
 */
private var endSlideForCuttingVideo:Number;

/**
 * Variable holds the value of last changed slide(Start and End slide for cutting video).
 */
private var cutSlideValue:Number;

/**
 * Variable holds the value of the slide in video inserting feature.
 */
private var insertSlideValue:Number;

/**
 * Variable holds the data of camera drive selected by user.
 */
private var selectedCameraDrive:String;

/**
 * Variable holds the data of microphone drive selected by user.
 */
private var selectedMicrophoneDrive:String;

/**
 * @private
 * Function for initializing the playback, player properties and listners.
 *
 * @param event of type Event.
 * @return void
 */
private function init(event:Event):void{
	this.imgStop.setFocus();
	aviewPlayer.seekBar=new HSlider();
	aviewPlayer.seekBar.thumbCount=1;
	aviewPlayer.seekBar.allowTrackClick=false;
	aviewPlayer.seekBar.styleName="HSliderStyle";
	aviewPlayer.seekBar.dataTipFormatFunction=showSliderTime;
	aviewPlayer.seekBarContainer.visible=false;
	aviewPlayer.buttonContainer.visible=false;
	
	aviewPlayer.buttonContainer.includeInLayout=false;
	
	aviewPlayer.editTime.visible=true;
	aviewPlayer.editTime.setStyle("color", "#056AB0");
	aviewPlayer.editTotalTime.setStyle("color", "#056AB0");
	aviewPlayer.editTime.setStyle("fontWeight", "bold");
	aviewPlayer.editTotalTime.setStyle("fontWeight", "bold");
	scaleCan.addChild(aviewPlayer.editTime);
	scaleCan.addChild(aviewPlayer.editTotalTime);
	aviewPlayer.can_videos.setStyle("backgroundColor", "#E0EFFB");
	alignPlaybackWindow();
	aviewPlayer.can_videos.verticalScrollPolicy="off";
	arData=["Start Time:", "End Time:"];
	lblEditNotification.styleName="NotificationLabelStyle";
	lblEditNotification.text="Please move the red colored thumb to select portion you want to remove.";
	aviewPlayer.seekBar.addEventListener(SliderEvent.THUMB_PRESS, onThumbPress);
	aviewPlayer.can_videos.addEventListener(ResizeEvent.RESIZE, onResizeAviewplayercan_videos);
	aviewPlayer.addEventListener("PlayerInitialized", onPlayerInitialized);
	aviewPlayer.addEventListener("Notify seek change", onSeekChange);
	aviewPlayer.addEventListener("File error", playBackXMLFileDownloadingError);
	editingToolContainer.addEventListener("chatBlockCreated", onChatBlockCreatedEvent);
	editingToolContainer.addEventListener("ScaleCreated", onScaleCreation);
	aviewPlayer.presenterVid.showCloseButton=false;
	aviewPlayer.viewerVid.showCloseButton=false;
	aviewPlayer.can_bottom.width=0;
	aviewPlayer.addEventListener(CloseFileHandler.PLAYBACK_STOP, playBackStop);
}


/**
 * @private
 * Function invokes when user clicks the stop button of playback.
 * Calls the function 'stopPlay'.
 *
 * @param event of type CloseFileHandler
 * @return void
 */
private function playBackStop(event:CloseFileHandler):void{
	stopVideoEditingPlayback();
}

/**
 * @private
 * Function invokes when Video Editing window got closed.
 *
 * @param event of type CloseFileHandler.
 * @return void
 *
 */
private function videoEditingClose(event:CloseFileHandler):void{
	sliderThumbSkinObject.thumbGraphicsColor=0x5a5a5a;
	aviewPlayer.seekBar.dispatchEvent(new CloseFileHandler(CloseFileHandler.CUT_RECORDED_CLOSE));
	this.dispatchEvent(new CloseFileHandler(CloseFileHandler.CLOSED_VIDEO_EDITING));
	
	// Checks the application is of type desktop.
	// If so, closes the video editing window.
	applicationType::desktop{
		//close() method not available for web.
		FlexGlobals.topLevelApplication.mainApp.mainApp.mainContainerComp.lmsInst.videoEditor.close();
	}
}

/**
 *
 * @private
 * Function invokes when user clicks the slider.
 * Updates and stores the slider value.
 *
 * @param event of type SliderEvent.
 * @return void
 *
 */
private function onThumbPress(event:SliderEvent):void{
	thumbIndex=event.thumbIndex;
}

/**
 * @private
 * Function calls when tool tip got activates.
 * Finds the Slider to display and calculate the display time.
 *
 * @param value of type Number
 * @return the Slider name and display time
 *
 */
private function showSliderTime(value:Number):String{
	var prefix:String=arData[thumbIndex];
	return String(prefix + "" + formatSliderTime(Number(value)));
}


/**
 *
 * @private
 * Function for fdormatting the slider tool tip display time
 *
 * @param value of type int
 * @return of type String. Returns the formatted time values.
 *
 */
private function formatSliderTime(value:int):String{
	var result:String=(value % 60).toString();
	if (result.length == 1){
		result=Math.floor(value / 60).toString() + ":0" + result;
	}
	else{
		result=Math.floor(value / 60).toString() + ":" + result;
	}
	return result;
}


/**
 * @private
 * Function invokes after the creation of scale for
 * representing each module in editing window.
 * Initializes the seekbar position and width
 *
 * @param event of type Event
 * @return void
 */
private function onScaleCreation(event:Event):void{
	aviewPlayer.seekBar.x=EditingConstants.SCALE_START_X_POS;
	aviewPlayer.seekBar.y=EditingConstants.SCALE_START_Y_POS / 2;
	aviewPlayer.seekBar.width=editingToolContainer.numberUnits * editingToolContainer.needleSpacing;
	aviewPlayer.editTotalTime.x=aviewPlayer.seekBar.width - aviewPlayer.editTotalTime.width;
}


/**
 * @private
 * Function invokes when resize happens for video canvas in player.
 * Resets the presenter and viewer canvas height.
 *
 * @param event of type ResizeEvent
 * @return void
 */
private function onResizeAviewplayercan_videos(event:ResizeEvent):void{
	aviewPlayer.presenter.height=aviewPlayer.can_videos.height / 2 - 5;
	aviewPlayer.viewer.y=aviewPlayer.presenter.y + aviewPlayer.presenter.height;
	aviewPlayer.viewer.height=aviewPlayer.can_videos.height / 2 - 5;
}


/**
 * @private
 * Function invokes after the initialization of AVIEW player.
 *
 * @param event of type Event
 * @return void
 */
private function onPlayerInitialized(event:Event):void{
	editingToolContainer.consolidatedXml=aviewPlayer.fileLoaderManager;
	editingToolContainer.initEditingContainer();
	PopUpManager.removePopUp(aviewPlayer.chatWndw);
	PopUpManager.addPopUp(aviewPlayer.chatWndw, chatCan);
	resizeChatCanvas();
	
	aviewPlayer.chatWndw.isPopUp=false;
	aviewPlayer.presenterVid.isPopUp=false;
	aviewPlayer.viewerVid.isPopUp=false;
}

/**
 * @private
 * Function invokes after the chat block got initialized
 * Adds the slider to the editing container.
 *
 * @param event of type event
 * @return void
 *
 */
private function onChatBlockCreatedEvent(event:Event):void{
	editingToolContainer.addChild(aviewPlayer.seekBar);
}


/**
 * @private
 * Function calls after the completion of creation complete event.
 * Sets the percentage height and width of inner canvas.
 *
 * @param void
 * @return void
 *
 */
private function alignPlaybackWindow():void{
	aviewPlayer.can_panel.percentWidth=50;
	aviewPlayer.can_videos.percentWidth=25;
	aviewPlayer.can_top.percentHeight=95;
}

/**
 * @private
 * Function invokes when a resize happend to the AVIEW main container.
 * Dispatch resize event for the inner player component.
 *
 * @param event of type ResizeEvent
 * @return void
 */
private function onAviewPlayerWindowResize(event:ResizeEvent):void{
	if (aviewPlayer != null){
		this.aviewPlayer.seekBar.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	if (cutLectureObj)
		PopUpManager.centerPopUp(cutLectureObj);
	
	// AKCR: can the following 2 conditions be combined with an AND && ?
	if (aviewPlayer && editingToolContainer){
		if (editingToolContainer.chatRibbon && (cutLectureObj)){
			setTimeout(addNotification, 250);
		}
	}
}


/**
 * @private
 * Function adds the label to the 'editingToolContainer'
 * and sets the visibility and position.
 *
 * @param void
 * @return void
 */
private function addNotification():void{
	editingToolContainer.addChild(lblEditNotification);
	lblEditNotification.visible=true;
	lblEditNotification.x=aviewPlayer.seekBar.width / 3;
	lblEditNotification.y=editingToolContainer.chatRibbon.y + editingToolContainer.chatRibbon.height + 5;
}


/**
 * @private
 * Function invokes when user clicks the insert lecture button.
 * Creates and popup the 'InsertLectureTime' for choosing
 * the time for inserting the new lecture in the playback.
 * Also, sets the values and registers the listners.
 *
 * @param void
 * @return void
 */
private function insertLecture():void{
	// Checks if insertlecture object and cutlecture object is not created.
	if (objInsertLectureTime == null && cutLectureObj == null){
		changeEditingButtonStatus(false);
		isInsertLectureClicked=true;
		objInsertLectureTime=new InsertLectureTime();
		PopUpManager.addPopUp(objInsertLectureTime, this);
		PopUpManager.centerPopUp(objInsertLectureTime);
		objInsertLectureTime.y=objInsertLectureTime.y - 20;
		objInsertLectureTime.addEventListener(CloseFileHandler.CLOSED_VIDEO_SETTING_CANCEL, videoInsertTimeCloseHandler);
		objInsertLectureTime.addEventListener(CloseFileHandler.CLOSED_VIDEO_SETTING_OK, videoInsertTimeCloseHandler);
		
		seekBarValue=aviewPlayer.seekBar.value;
		sliderObject=Slider(aviewPlayer.seekBar);
		aviewPlayer.seekBar.thumbCount=1;
		aviewPlayer.seekBar.setThumbValueAt(0, seekBarValue);
		var event:SliderEvent=new SliderEvent(SliderEvent.CHANGE);
		event.value=sliderObject.values[0];
		event.thumbIndex=0;
		aviewPlayer.seekBar.dispatchEvent(event);
		if (imgStopIcon != EditingConstants.stopInactiveIcon)
			aviewPlayer.playpauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		imgCutSessionIcon=EditingConstants.cutInactiveIcon;
		imgPlayIcon=EditingConstants.playActiveIcon;
		imgPlay.toolTip="Play";
	}
}

/**
 * @private
 * Function invokes when user closes the 'InsertLectureTime'.
 * Sets the minute and second value and unregisters the listners.
 *
 * @param event of type CloseFileHandler
 * @return void
 *
 */
private function videoInsertTimeCloseHandler(event:CloseFileHandler):void{
	changeEditingButtonStatus(true);
	isInsertLectureClicked=false;
	insertVideoMinuteValue=objInsertLectureTime.insertLectureTimeInMinutes;
	insertVideoSecondValue=objInsertLectureTime.insertLectureTimeInSeconds;
	PopUpManager.removePopUp(objInsertLectureTime);
	objInsertLectureTime.removeEventListener(CloseFileHandler.CLOSED_VIDEO_SETTING_CANCEL, videoInsertTimeCloseHandler);
	objInsertLectureTime.removeEventListener(CloseFileHandler.CLOSED_VIDEO_SETTING_OK, videoInsertTimeCloseHandler);
	
	// Checks the event is of type 'CLOSED_VIDEO_SETTING_OK' (User clicks the OK button in insert lecture)
	// If so, 'VideoRecordComponent' is initialized for recording new video and sets the parameter.
	if (event.type == CloseFileHandler.CLOSED_VIDEO_SETTING_OK){
		classIdValue=new Array();
		var tempVideoPath:String=aviewPlayer.presenterFMSUrl.toString();
		var tempContentPath:String=aviewPlayer.videoFilePath.toString();
		tempVideoPath=tempVideoPath.substr(0, tempVideoPath.length - 4);
		classIdValue=tempContentPath.split("/");
		insertVideoObj=new VideoRecordComponent();
		insertVideoObj.insertVideoMin=insertVideoMinuteValue;
		insertVideoObj.insertVideoSec=insertVideoSecondValue;
		insertVideoObj.fileLoadManager=aviewPlayer.fileLoaderManager;
		insertVideoObj.classId=classIdValue[2];
		insertVideoObj.arClassDetails=classIdValue;
		insertVideoObj.playbackContentPath=aviewPlayer.contentFilePath;
		insertVideoObj.playbackContentUrl=aviewPlayer.contentUrl;
		insertVideoObj.videoPath=tempVideoPath;
		insertVideoObj.addEventListener(CloseFileHandler.CLOSED_VIDEO_EDITING, videoEditingClose);
		insertVideoObj.addEventListener(CloseFileHandler.CLOSED_VIDEO_EDITING_CANCEL, cancelVideoRecordComponent);
		PopUpManager.addPopUp(insertVideoObj, this, true);
		PopUpManager.centerPopUp(insertVideoObj);
	}
		// Event is of type 'CLOSED_VIDEO_SETTING_CANCEL' (User clicks the CANCEL button in insert lecture)
		// If so, sets the slider value and dispatches the event for playing the lecture.
	else{
		aviewPlayer.seekBar.value=insertSlideValue;
		imgPlayIcon=EditingConstants.playInactiveIcon;
		imgPlay.toolTip="Play";
		if (imgStopIcon != EditingConstants.stopInactiveIcon)
			aviewPlayer.playpauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}
	objInsertLectureTime=null;
}

/**
 * @private
 * Function invokes when user closes the  'VideoRecordComponent' by clicking the cancel button.
 * Dispatches event for resuming the lecture playback.
 *
 * @param event of type CloseFileHandler
 * @return void
 */
private function cancelVideoRecordComponent(event:CloseFileHandler):void{
	aviewPlayer.seekBar.value=insertSlideValue;
	imgPlayIcon=EditingConstants.playInactiveIcon;
	imgPlay.toolTip="Pause";
	aviewPlayer.playpauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
}

/**
 * @private
 * Function invokes when user clicks the edit button.
 * Creates the 'EditLecture' component and sets the properties.
 *
 * @param void
 * @return void
 */
private function editRecordedSession():void{
	var isSliderValue:Boolean=false;
	var sliderFirstValue:Number;
	var sliderSecondValue:Number;
	if (imgStop.toolTip == null){
		aviewPlayer.stopButton.enabled=true;
		setPlayMode(null);
	}
	
	// Checks if insertlecture object and cutlecture object is not created.
	if (cutLectureObj == null && objInsertLectureTime == null){
		cutLectureObj=new EditLecture();
		PopUpManager.addPopUp(cutLectureObj, this);
		PopUpManager.centerPopUp(cutLectureObj);
		cutLectureObj.y=cutLectureObj.y - 20;
		cutLectureObj.fileLoadManager=aviewPlayer.fileLoaderManager;
		cutLectureObj.contentUrl=aviewPlayer.contentUrl;
		cutLectureObj.contentFilePath=aviewPlayer.contentFilePath;
		cutLectureObj.txtStartTimeMin.setFocus();
		cutLectureObj.txtStartTimeMin.setSelection(0, cutLectureObj.txtStartTimeMin.length);
		cutLectureObj.addEventListener(CloseEvent.CLOSE, cutLectureCloseEvent);
		cutLectureObj.addEventListener(CloseFileHandler.CLOSED_VIDEO_EDITING, videoEditingClose);
		changeEditingButtonStatus(false);
		
		seekBarValue=aviewPlayer.seekBar.value;
		sliderObject=Slider(aviewPlayer.seekBar);
		aviewPlayer.seekBar.thumbCount=2;
		
		for (var i:int=10; i > 1; i--){
			if (seekBarValue < aviewPlayer.seekBar.maximum / i){
				isSliderValue=true;
				sliderFirstValue=seekBarValue;
				sliderSecondValue=aviewPlayer.seekBar.maximum / i;
				break;
			}
		}
		if (!isSliderValue){
			sliderFirstValue=aviewPlayer.seekBar.maximum / 2;
			sliderSecondValue=seekBarValue;
		}
		aviewPlayer.seekBar.setThumbValueAt(0, sliderFirstValue);
		aviewPlayer.seekBar.setThumbValueAt(1, sliderSecondValue);
		var event:SliderEvent=new SliderEvent(SliderEvent.CHANGE);
		event.value=sliderObject.values[1];
		event.thumbIndex=1;
		aviewPlayer.seekBar.dispatchEvent(event);
		sliderThumbSkinObject.thumbGraphicsColor=0xe51111;
		lblEditNotification.x=aviewPlayer.seekBar.width / 3;
		lblEditNotification.y=editingToolContainer.chatRibbon.y + editingToolContainer.chatRibbon.height + 5;
		editingToolContainer.addChild(lblEditNotification);
		lblEditNotification.visible=true;
		if (imgPlayIcon == EditingConstants.playInactiveIcon)
			aviewPlayer.playpauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		imgCutSessionIcon=EditingConstants.cutInactiveIcon;
		imgPlayIcon=EditingConstants.playInactiveIcon;
		aviewPlayer.seekBar.dispatchEvent(new CloseFileHandler(CloseFileHandler.CUT_RECORDED_INIT));
	}
}


/**
 * @private
 * Change the button 'enabled' property based on the boolean attribute.
 *
 * @param status of type Boolean.
 * @return void
 */
private function changeEditingButtonStatus(status:Boolean):void{
	imgCutSession.enabled=status;
	imgPlay.enabled=status;
	imgStop.enabled=status;
	imgInsertSession.enabled=status;
}

/**
 * @private
 * Function invokes when user closes the 'CutLecture' component.
 * Dispatches the event for resume playback and sets properties.
 *
 * @param event of type CloseEvent
 * @return void
 */
private function cutLectureCloseEvent(event:CloseEvent):void{
	changeEditingButtonStatus(true);
	cutLectureObj=null;
	lblEditNotification.visible=false;
	aviewPlayer.seekBar.thumbCount=1;
	sliderThumbSkinObject.thumbGraphicsColor=0x5a5a5a;
	aviewPlayer.seekBar.value=cutSlideValue;
	imgCutSessionIcon=EditingConstants.cutActiveIcon;
	imgPlayIcon=EditingConstants.playInactiveIcon;
	imgPlay.toolTip="Pause";
	
	aviewPlayer.playpauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	aviewPlayer.seekBar.dispatchEvent(new CloseFileHandler(CloseFileHandler.CUT_RECORDED_CLOSE));
	
	var eve:SliderEvent=new SliderEvent(SliderEvent.CHANGE);
	eve.value=sliderObject.values[0];
	eve.thumbIndex=0;
	aviewPlayer.seekBar.dispatchEvent(eve);
}

/**
 * @private
 * Function invokes when a resize happens for chat canvas.
 *
 * @param void
 * @return void
 */
private function resizeChatCanvas():void{
	if (aviewPlayer != null && aviewPlayer.chatWndw != null){
		aviewPlayer.chatWndw.x=chatCan.x;
		aviewPlayer.chatWndw.width=chatCan.width;
		aviewPlayer.chatWndw.height=chatCan.height;
	}
}

/**
 * @public
 * Function invokes when user closes the entire video editing window.
 *
 * @param void
 * @return void
 */
public function closeVideoEditing():void{
	aviewPlayer.closePlayer();
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.killEditing();
}


/**
 * @private
 * Function invokes when user seeks the slider.
 *
 * @param event of type SliderEvent
 * @return void
 *
 */
private function onSeekChange(event:SliderEvent):void{
	// Checks if number of slide is more than 1(Cut lecture)
	// If so, updates the slider time values and stores the slide value
	if (aviewPlayer.seekBar.thumbCount > 1){
		// AKCR: please re-write the following 4 formatSliderTime lines
		// AKCR: wrong: a > b ? myvar = 'abc' : myvar = 'def'
		// AKCR: correct: myvar = (a > b) ? 'abc' : 'def'
		
		formatSliderTime(sliderObject.values[0]).split(':')[0].toString().length > 1 ? cutLectureObj.txtStartTimeMin.text=formatSliderTime(sliderObject.values[0]).split(':')[0].toString() : cutLectureObj.txtStartTimeMin.text='0' + formatSliderTime(sliderObject.values[0]).split(':')[0].toString();
		formatSliderTime(sliderObject.values[0]).split(':')[1].toString().length > 1 ? cutLectureObj.txtStartTimeSec.text=formatSliderTime(sliderObject.values[0]).split(':')[1].toString() : cutLectureObj.txtStartTimeSec.text='0' + formatSliderTime(sliderObject.values[0]).split(':')[1].toString();
		formatSliderTime(sliderObject.values[1]).split(':')[0].toString().length > 1 ? cutLectureObj.txtEndTimeMin.text=formatSliderTime(sliderObject.values[1]).split(':')[0].toString() : cutLectureObj.txtEndTimeMin.text='0' + formatSliderTime(sliderObject.values[1]).split(':')[0].toString();
		formatSliderTime(sliderObject.values[1]).split(':')[1].toString().length > 1 ? cutLectureObj.txtEndTimeSec.text=formatSliderTime(sliderObject.values[1]).split(':')[1].toString() : cutLectureObj.txtEndTimeSec.text='0' + formatSliderTime(sliderObject.values[1]).split(':')[1].toString();
		
		// AKCR: please use a conditional operator for the below code
		if (startSlideForCuttingVideo != sliderObject.values[0])
			cutSlideValue=sliderObject.values[0];
		else if (endSlideForCuttingVideo != sliderObject.values[1])
			cutSlideValue=sliderObject.values[1];
		
		startSlideForCuttingVideo=sliderObject.values[0];
		endSlideForCuttingVideo=sliderObject.values[1];
		
	}
		// Checks if number of slide is 1(video record)
		// If so, updates the slider time values and stores the slide value
	else if (aviewPlayer.seekBar.thumbCount == 1 && isInsertLectureClicked){
		
		formatSliderTime(sliderObject.values[0]).split(':')[0].toString().length > 1 ? objInsertLectureTime.txtStartTimeMin.text=formatSliderTime(sliderObject.values[0]).split(':')[0].toString() : objInsertLectureTime.txtStartTimeMin.text='0' + formatSliderTime(sliderObject.values[0]).split(':')[0].toString();
		formatSliderTime(sliderObject.values[0]).split(':')[1].toString().length > 1 ? objInsertLectureTime.txtStartTimeSec.text=formatSliderTime(sliderObject.values[0]).split(':')[1].toString() : objInsertLectureTime.txtStartTimeSec.text='0' + formatSliderTime(sliderObject.values[0]).split(':')[1].toString();
		
		
		insertSlideValue=sliderObject.values[0];
	}
}

/**
 * @private
 * Function invokes when error occured during XML file downloading.
 *
 * @param event of type Event
 * @return void
 */
private function playBackXMLFileDownloadingError(event:Event):void{
	// Checks the application is o typr desktop
	applicationType::desktop{
		//close() method not available for web.
		FlexGlobals.topLevelApplication.mainApp.mainApp.mainContainerComp.lmsInst.videoEditor.close();
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.killEditing();
}

/**
 * @private
 * Function sets the tooltip and icons for stop, play buttons
 *
 * @param event of type Event.
 * @return void
 */
private function setPlayMode(event:Event):void{
	if (imgStop.toolTip == null){
		imgStop.toolTip="Stop";
		imgStopIcon=EditingConstants.stopActiveIcon;
		imgStop.enabled=true;
	}
	
	if (cutLectureObj != null)
		cutLectureObj.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
	aviewPlayer.playPausePlayer();
	if (imgPlayIcon == EditingConstants.playInactiveIcon){
		imgPlayIcon=EditingConstants.playActiveIcon;
		imgPlay.toolTip="Play";
	}
	else{
		imgPlayIcon=EditingConstants.playInactiveIcon;
		imgPlay.toolTip="Pause";
	}
	
}

/**
 * @private
 * Function calls for  stopPlayBack in aviewplayer
 * and sets the icon and tooltip of play button.
 *
 * @param void
 * @return void
 */
private function stopVideoEditingPlayback():void{
	if (imgStop.toolTip == "Stop"){
		imgPlayIcon=EditingConstants.playActiveIcon;
		imgPlay.toolTip="Play";
		imgStop.toolTip=null;
		imgStop.enabled=false;
		imgStopIcon=EditingConstants.stopInactiveIcon;
		aviewPlayer.editTime.text="0:0";
	}
	aviewPlayer.stopPlayBack();
}
