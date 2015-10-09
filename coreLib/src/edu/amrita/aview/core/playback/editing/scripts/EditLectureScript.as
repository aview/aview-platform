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
 * File			: EditLectureScript.as
 * Module		: Video Editing
 * Developer(s)	: Ashish
 * Reviewer(s)	: Remya T
 *
 * File contains all the functionalities of editing a recorded lecture within a time frame
 *  and saving the edited lecture in the corresponding server.
 *
 */
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;

import mx.controls.Alert;
import mx.controls.Label;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.SliderEvent;
import mx.managers.PopUpManager;
applicationType::desktop{
	/* File and FileStream not available for web.*/
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import edu.amrita.aview.core.playback.editing.VideoEditing;
}
import flash.net.URLRequest;
import flash.xml.XMLNode;


import edu.amrita.aview.core.playback.editing.scripts.CloseFileHandler;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

// AKCR: please use single line comments; dont need comments for variables, if they are self explanatory
import mx.logging.Log;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import mx.logging.ILogger;
import edu.amrita.aview.core.common.FileLoaderManager;

/**
 * Variable holds the reference of 'FileLoaderManager' from aviewplayer.
 */
public var fileLoadManager:FileLoaderManager;

/**
 * Variable holds the reference of 'contentUrl' from aviewplayer.
 */
public var contentUrl:String;

/**
 * Variable holds the reference of 'contentFilePath' from aviewplayer.
 */
public var contentFilePath:String;


/**
 *  Variable holds the time difference between start time
 */
private var totalEditingTime:Number=0;

/**
 *  Variable holds the time value of start time for editing in 'seconds'.
 */
private var startTimeInSeconds:Number=0;

/**
 *  Variable holds the time value of end time for editing in 'seconds'.
 */
private var endTimeInSeconds:Number=0;

/**
 *  New PTT XML after video editing.
 */
private var newPttXml:XML;

/**
 *  New Whiteboard pointer XML after video editing.
 */
private var newWbPointerXml:XML;

/**
 *  New Document pointer XML after video editing.
 */
private var newDocPointerXml:XML;

/**
 *  New Presenter Video XML after video editing.
 */
private var newPresenterVideoXml:XML;

/**
 *  New Chat XML after video editing.
 */
private var newChatXml:XML;

/**
 *  New Viewer Video XML after video editing.
 */
private var newViewerVideoXml:XML;

/**
 *  New Document XML after video editing.
 */
private var newDocXml:XML;

/**
 *  New Whiteboard XML after video editing.
 */
private var newWbXml:XML;

/**
 *  New End XML after video editing.
 */
private var newEndXml:XML;

/**
 *  Variable holds the count of xml created during video editing.
 */
private var xmlFileCreationCount:int;

/**
 *  Variable holds the count of file uploads to server.
 */
private var fileUploadCount:int;

/**
 * Variable hold the value for high lighting the text values
 */
private var highlightTextOnClick:Boolean=true;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.playback.editing.scripts.EditLectureScript.as");

/* File and FileStream not available for web.*/
applicationType::desktop{
	/**
	 * File for saving the Whiteboard XML data.
	 */
	private var wbFile:File;
	
	/**
	 * Filestream for saving the Whiteboard XML data.
	 */
	private var wbFileStream:FileStream;
	
	/**
	 * File for saving the document XML data.
	 */
	private var docFile:File;
	
	/**
	 * Filestream for saving the document XML data.
	 */
	private var docFileStream:FileStream;
	
	/**
	 * File for saving the chat XML data.
	 */
	private var chatFile:File;
	
	/**
	 * Filestream for saving the chat XML data.
	 */
	private var chatFileStream:FileStream;
	
	/**
	 * File for saving the whiteboard pointer XML data.
	 */
	private var wbPointerFile:File;
	
	/**
	 * Filestream for saving the whiteboard pointer XML data.
	 */
	private var wbPointerFileStream:FileStream;
	
	/**
	 * File for saving the document pointer XML data.
	 */
	private var docPointerFile:File;
	
	/**
	 * Filestream for saving the document pointer XML data.
	 */
	private var docPointerFileStream:FileStream;
	
	/**
	 * File for saving the presenter video XML data.
	 */
	private var presenterVideoFile:File;
	
	/**
	 * Filestream for saving the presenter video XML data.
	 */
	private var presenterVideoFileStream:FileStream;
	
	/**
	 * File for saving the viewer video XML data.
	 */
	private var viewerVideoFile:File;
	
	/**
	 * Filestream for saving the viewer video XML data.
	 */
	private var viewerVideoFileStream:FileStream;
	
	/**
	 * File for saving the PTT XML data.
	 */
	private var pttFile:File;
	
	/**
	 * Filestream for saving the PTT XML data.
	 */
	private var pttFileStream:FileStream;
	
	/**
	 * File for saving the endfile XML data.
	 */
	private var endFile:File;
	
	/**
	 * Filestream for saving the endfile XML data.
	 */
	private var endFileStream:FileStream;
	
	/**
	 * Variable holds the location for file storage.
	 */
	private const FILE_LOCATION:String=File.applicationStorageDirectory.nativePath + "/Editing/";
}

/**
 * Total number of files for uploading is 9.
 */
private static const TOTAL_FILES:int=9;


/**
 * @privates
 * Function checks the validation and also calls the
 * functions for creating the new XML tags.
 *
 * @param timeStartMin of type Number -  Video editing Start time (Minute)
 * @param timeStartSec of type Number -  Video editing Start time (Seconds)
 * @param timeEndMin of type Number -  Video editing End time (Minute)
 * @param timeEndSec of type Number -  Video editing End time (Seconds)
 * @return void
 */
private function createNewXmlValues(timeStartMin:Number, timeStartSec:Number, timeEndMin:Number, timeEndSec:Number):void{
	xmlFileCreationCount=0;
	startTimeInSeconds=timeStartMin * 60;
	startTimeInSeconds=((startTimeInSeconds + timeStartSec) * 1000)
	endTimeInSeconds=timeEndMin * 60;
	endTimeInSeconds=((endTimeInSeconds + timeEndSec) * 1000)
	
	// Checks the start time value is less than 1000 milliseconds or end time value is greater than etime of end xml
	// If so, alerts the user and returns the flow.
	if (startTimeInSeconds < 1000 || endTimeInSeconds >= Number(fileLoadManager.endTimeXml.etime) - 1000){
		Alert.show("Please choose different values", "Error", Alert.OK, this);
		return;
	}
	
	// Checks the start time value and end time value are equal.
	// If so, alerts the user and returns the flow.
	if (startTimeInSeconds == endTimeInSeconds){
		Alert.show("Start time and end time should not be equal.\n Please choose different values", "Video Editor", 0, this);
		return;
	}
	
	// Checks the start time value is greater than end time.
	// If so, alerts the user and returns the flow.
	if (startTimeInSeconds > endTimeInSeconds){
		Alert.show("End time should be greater than Start time.\n Please choose different values", "Video Editor", 0, this);
		return;
	}
	
	// Checks the time entered in seconds column is greater than 59.
	// If so, alerts the user and returns the flow.
	if (timeStartSec > 59 || timeEndSec > 59){
		Alert.show("Invalid time format.\n Please choose different values", "Video Editor", 0, this);
		return;
	}
	
	this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
	newPttXml=new XML();
	newEndXml=new XML();
	newWbXml=new XML();
	newWbPointerXml=new XML();
	newDocPointerXml=new XML();
	newPresenterVideoXml=new XML();
	newChatXml=new XML();
	newViewerVideoXml=new XML();
	newDocXml=new XML();
	totalEditingTime=endTimeInSeconds - startTimeInSeconds;
	
	createFileTags();
	createNewPresenterVideoXMLValues();
	createNewChatXMLValues();
	createNewViewerVideoXMLValues();
	createNewDocPointerValues();
	createNewWbPointerValues();
	createNewPttValues();
	createNewDocValues();
	createNewWbValues();
	createNewEndTimeValues();
}

/**
 * @private
 * Function for initializing the file and filestreams for each module.
 *
 * @param void
 * @return void
 */
private function createFileTags():void{
	applicationType::desktop{
		/*File and FileStream not available for web.*/
		wbFile=new File(FILE_LOCATION + "wb.xml");
		wbFileStream=new FileStream();
		
		docFile=new File(FILE_LOCATION + "doc.xml");
		docFileStream=new FileStream();
		
		chatFile=new File(FILE_LOCATION + "chat.xml");
		chatFileStream=new FileStream();
		
		wbPointerFile=new File(FILE_LOCATION + "wbPointer.xml");
		wbPointerFileStream=new FileStream();
		
		docPointerFile=new File(FILE_LOCATION + "docPointer.xml");
		docPointerFileStream=new FileStream();
		
		presenterVideoFile=new File(FILE_LOCATION + "pVideo.xml");
		presenterVideoFileStream=new FileStream();
		
		viewerVideoFile=new File(FILE_LOCATION + "vVideo.xml");
		viewerVideoFileStream=new FileStream();
		
		pttFile=new File(FILE_LOCATION + "ptt.xml");
		pttFileStream=new FileStream();
		
		endFile=new File(FILE_LOCATION + "endTime.xml");
		endFileStream=new FileStream();
	}
}

/**
 * @private
 * Function for creating the new xml tags for
 * presenter video after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewPresenterVideoXMLValues():void{
	newPresenterVideoXml=<presenter></presenter>;
	var tempVideoXml:XML=<presenter></presenter>;
	var tempXml:XML;
	// Loops through the presenter video xml tags
	for (var i:int=0; i < fileLoadManager.pVideoXml.video.length(); i++){
		tempXml=<video></video>;
		tempXml.@stime=fileLoadManager.pVideoXml.video[i].@stime;
		tempXml.@uname=fileLoadManager.pVideoXml.video[i].@uname;
		tempXml.@displyname=fileLoadManager.pVideoXml.video[i].@displyname;
		tempXml.@src=fileLoadManager.pVideoXml.video[i].@src;
		tempXml.@etime=fileLoadManager.pVideoXml.video[i].@etime;
		tempXml.@seekStartValue=fileLoadManager.pVideoXml.video[i].@seekStartValue;
		tempXml.@seekExist=fileLoadManager.pVideoXml.video[i].@seekExist;
		tempXml.@seekTime=fileLoadManager.pVideoXml.video[i].@seekTime;
		
		// Checks stime attribute value is less than or equal to startTimeInSeconds and etime is greater than or equal to startTimeInSeconds
		// If so, adds the xml tag and change the etime to startTimeInSeconds.
		if (Number(fileLoadManager.pVideoXml.video[i].@stime) <= startTimeInSeconds && Number(fileLoadManager.pVideoXml.video[i].@etime) >= startTimeInSeconds){
			tempXml.@etime=startTimeInSeconds;
			newPresenterVideoXml.appendChild(tempXml);
			// Checks etime is greater than or equal to endTimeInSeconds
			if (Number(fileLoadManager.pVideoXml.video[i].@etime) >= endTimeInSeconds){
				tempXml=<video></video>;
				tempXml.@stime=fileLoadManager.pVideoXml.video[i].@stime;
				tempXml.@uname=fileLoadManager.pVideoXml.video[i].@uname;
				tempXml.@displyname=fileLoadManager.pVideoXml.video[i].@displyname;
				tempXml.@src=fileLoadManager.pVideoXml.video[i].@src;
				tempXml.@etime=fileLoadManager.pVideoXml.video[i].@etime;
				tempXml.@seekStartValue=startTimeInSeconds / 1000;
				tempXml.@seekExist="true";
				tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.pVideoXml.video[i].@stime)) / 1000 + Number(fileLoadManager.pVideoXml.video[i].@seekTime);
				tempXml.@stime=endTimeInSeconds;
				newPresenterVideoXml.appendChild(tempXml);
			}
			else{
				// Loops through the rest of tag values for finding the 'endTimeInSeconds' value.
				for (var j:int=i; j < fileLoadManager.pVideoXml.video.length(); j++){
					// Check the stime is less than or equal to endTimeInSeconds and etime is greater than endTimeInSeconds.
					// If so, adds the tag with changes.
					if (Number(fileLoadManager.pVideoXml.video[j].@stime) <= endTimeInSeconds && Number(fileLoadManager.pVideoXml.video[j].@etime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.pVideoXml.video[j].@stime;
						tempXml.@uname=fileLoadManager.pVideoXml.video[j].@uname;
						tempXml.@displyname=fileLoadManager.pVideoXml.video[j].@displyname;
						tempXml.@src=fileLoadManager.pVideoXml.video[j].@src;
						tempXml.@etime=fileLoadManager.pVideoXml.video[j].@etime;
						tempXml.@seekStartValue=startTimeInSeconds / 1000; //+ Number(fileLoadManager.pVideoXml.video[j].@seekStartValue);
						tempXml.@seekExist="true";
						tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.pVideoXml.video[j].@stime)) / 1000 + Number(fileLoadManager.pVideoXml.video[j].@seekTime);
						tempXml.@stime=endTimeInSeconds;
						newPresenterVideoXml.appendChild(tempXml);
						i=j;
						break;
					}
						// Check the etime is less than or equal to endTimeInSeconds and next tag stime is greater than endTimeInSeconds.
						// If so, adds the tag with changes.
					else if (Number(fileLoadManager.pVideoXml.video[j].@etime) <= endTimeInSeconds && Number(fileLoadManager.pVideoXml.video[(j + 1)].@stime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.pVideoXml.video[j + 1].@stime;
						tempXml.@uname=fileLoadManager.pVideoXml.video[j + 1].@uname;
						tempXml.@displyname=fileLoadManager.pVideoXml.video[j + 1].@displyname;
						tempXml.@src=fileLoadManager.pVideoXml.video[j + 1].@src;
						tempXml.@etime=fileLoadManager.pVideoXml.video[j + 1].@etime;
						tempXml.@seekStartValue=fileLoadManager.pVideoXml.video[j + 1].@seekStartValue;
						tempXml.@seekExist=fileLoadManager.pVideoXml.video[j + 1].@seekExist;
						tempXml.@seekTime=fileLoadManager.pVideoXml.video[j + 1].@seekTime;
						newPresenterVideoXml.appendChild(tempXml);
						i=j + 1;
						break;
					}
				}
			}
		}
			// Check the etime is less than or equal to startTimeInSeconds and next tag stime is greater than startTimeInSeconds.
			// If so, adds the tag.
		else if (Number(fileLoadManager.pVideoXml.video[i].@etime) <= startTimeInSeconds && Number(fileLoadManager.pVideoXml.video[i + 1].@stime) >= startTimeInSeconds){
			newPresenterVideoXml.appendChild(tempXml);
			// Check the etime is greater than or equal to endTimeInSeconds
			// If so, adds the tag with changes. 
			if (Number(fileLoadManager.pVideoXml.video[i].@etime) >= endTimeInSeconds){
				tempXml=<video></video>;
				tempXml.@stime=fileLoadManager.pVideoXml.video[i].@stime;
				tempXml.@uname=fileLoadManager.pVideoXml.video[i].@uname;
				tempXml.@displyname=fileLoadManager.pVideoXml.video[i].@displyname;
				tempXml.@src=fileLoadManager.pVideoXml.video[i].@src;
				tempXml.@etime=fileLoadManager.pVideoXml.video[i].@etime;
				tempXml.@seekStartValue=startTimeInSeconds / 1000;
				tempXml.@seekExist="true";
				tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.pVideoXml.video[i].@stime)) / 1000 + Number(fileLoadManager.pVideoXml.video[i].@seekTime);
				tempXml.@stime=endTimeInSeconds;
				newPresenterVideoXml.appendChild(tempXml);
			}
			else{
				// Loops through the rest of tag values for finding the 'endTimeInSeconds' value.
				for (var k:int=i; k < fileLoadManager.pVideoXml.video.length(); k++){
					// Check the stime is less than or equal to endTimeInSeconds and etime is greater than startTimeInSeconds.
					// If so, adds the tag.
					if (Number(fileLoadManager.pVideoXml.video[k].@stime) <= endTimeInSeconds && Number(fileLoadManager.pVideoXml.video[k].@etime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.pVideoXml.video[k].@stime;
						tempXml.@uname=fileLoadManager.pVideoXml.video[k].@uname;
						tempXml.@displyname=fileLoadManager.pVideoXml.video[k].@displyname;
						tempXml.@src=fileLoadManager.pVideoXml.video[k].@src;
						tempXml.@etime=fileLoadManager.pVideoXml.video[k].@etime;
						tempXml.@seekStartValue=startTimeInSeconds / 1000;
						tempXml.@seekExist="true";
						tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.pVideoXml.video[k].@stime)) / 1000 + Number(fileLoadManager.pVideoXml.video[k].@seekTime);
						tempXml.@stime=endTimeInSeconds;
						newPresenterVideoXml.appendChild(tempXml);
						i=k;
						break;
					}
						// Check the etime is less than or equal to endTimeInSeconds and next tag stime is greater than endTimeInSeconds.
						// If so, adds the tag with changes. 
					else if (Number(fileLoadManager.pVideoXml.video[k].@etime) <= endTimeInSeconds && Number(fileLoadManager.pVideoXml.video[(k + 1)].@stime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.pVideoXml.video[k + 1].@stime;
						tempXml.@uname=fileLoadManager.pVideoXml.video[k + 1].@uname;
						tempXml.@displyname=fileLoadManager.pVideoXml.video[k + 1].@displyname;
						tempXml.@src=fileLoadManager.pVideoXml.video[k + 1].@src;
						tempXml.@etime=fileLoadManager.pVideoXml.video[k + 1].@etime;
						tempXml.@seekStartValue=fileLoadManager.pVideoXml.video[k + 1].@seekStartValue;
						tempXml.@seekExist=fileLoadManager.pVideoXml.video[k + 1].@seekExist;
						tempXml.@seekTime=fileLoadManager.pVideoXml.video[k + 1].@seekTime;
						newPresenterVideoXml.appendChild(tempXml);
						i=k + 1;
						break;
					}
				}
			}
		}
			// Check the tag stime and etime not in editing time
			// If so, adds the tag. 
		else if (!(Number(fileLoadManager.pVideoXml.video[i].@stime) >= startTimeInSeconds && Number(fileLoadManager.pVideoXml.video[i].@etime) <= endTimeInSeconds)){
			newPresenterVideoXml.appendChild(tempXml);
		}
	}
	
	// Loops through the newly created xml tag values and decreases the endTimeInSeconds.
	for (var l:int=0; l < newPresenterVideoXml.video.length(); l++){
		if (newPresenterVideoXml.video[l].@etime >= endTimeInSeconds)
			newPresenterVideoXml.video[l].@etime=newPresenterVideoXml.video[l].@etime - totalEditingTime;
		if (newPresenterVideoXml.video[l].@stime >= endTimeInSeconds)
			newPresenterVideoXml.video[l].@stime=newPresenterVideoXml.video[l].@stime - totalEditingTime;
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function for creating the new xml tags for Chat after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewChatXMLValues():void{
	newChatXml=<chat></chat>;
	// Loops through the Chat xml tags
	for (var i:int=0; i < fileLoadManager.chatXml.msg.length(); i++){
		var tempXml:XML=<msg></msg>;
		tempXml.@ctime=fileLoadManager.chatXml.msg[i].@ctime;
		tempXml.@content=fileLoadManager.chatXml.msg[i].@content;
		tempXml.@textSize=fileLoadManager.chatXml.msg[i].@textSize;
		//Checks the ctime falls between startTimeInSeconds and endTimeInSeconds.
		// If so, decrease the ctime.
		if (Number(tempXml.@ctime) > startTimeInSeconds && Number(tempXml.@ctime) <= endTimeInSeconds){
			tempXml.@ctime=endTimeInSeconds - totalEditingTime;
		}
		//Checks the ctime is greater than endTimeInSeconds.
		// If so, decrease the ctime.
		if (tempXml.@ctime > endTimeInSeconds)
			tempXml.@ctime=tempXml.@ctime - totalEditingTime;
		newChatXml.appendChild(tempXml);
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function for creating the new xml tags for
 * Viewer video after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewViewerVideoXMLValues():void{
	newViewerVideoXml=<viewer></viewer>;
	var tempVideoXml:XML=<viewer></viewer>;
	var tempXml:XML;
	// Loops through the presenter video xml tags
	for (var i:int=0; i < fileLoadManager.vVideoXml.video.length(); i++){
		tempXml=<video></video>;
		tempXml.@stime=fileLoadManager.vVideoXml.video[i].@stime;
		tempXml.@uname=fileLoadManager.vVideoXml.video[i].@uname;
		tempXml.@displyname=fileLoadManager.vVideoXml.video[i].@displyname;
		tempXml.@src=fileLoadManager.vVideoXml.video[i].@src;
		tempXml.@etime=fileLoadManager.vVideoXml.video[i].@etime;
		tempXml.@seekStartValue=fileLoadManager.vVideoXml.video[i].@seekStartValue;
		tempXml.@seekExist=fileLoadManager.vVideoXml.video[i].@seekExist;
		tempXml.@seekTime=fileLoadManager.vVideoXml.video[i].@seekTime;
		// Checks stime attribute value is less than or equal to startTimeInSeconds and etime is greater than or equal to startTimeInSeconds
		// If so, adds the xml tag and change the etime to startTimeInSeconds.
		if (Number(fileLoadManager.vVideoXml.video[i].@stime) <= startTimeInSeconds && Number(fileLoadManager.vVideoXml.video[i].@etime) >= startTimeInSeconds){
			tempXml.@etime=startTimeInSeconds;
			newViewerVideoXml.appendChild(tempXml);
			// Checks etime is greater than or equal to endTimeInSeconds
			if (Number(fileLoadManager.vVideoXml.video[i].@etime) >= endTimeInSeconds){
				tempXml=<video></video>;
				tempXml.@stime=fileLoadManager.vVideoXml.video[i].@stime;
				tempXml.@uname=fileLoadManager.vVideoXml.video[i].@uname;
				tempXml.@displyname=fileLoadManager.vVideoXml.video[i].@displyname;
				tempXml.@src=fileLoadManager.vVideoXml.video[i].@src;
				tempXml.@etime=fileLoadManager.vVideoXml.video[i].@etime;
				tempXml.@seekStartValue=startTimeInSeconds / 1000;
				tempXml.@seekExist="true";
				tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.vVideoXml.video[i].@stime)) / 1000 + Number(fileLoadManager.vVideoXml.video[i].@seekTime);
				tempXml.@stime=endTimeInSeconds;
				newViewerVideoXml.appendChild(tempXml);
			}
			else{
				// Loops through the rest of tag values for finding the 'endTimeInSeconds' value.
				for (var j:int=i; j < fileLoadManager.vVideoXml.video.length(); j++){
					// Check the stime is less than or equal to endTimeInSeconds and etime is greater than endTimeInSeconds.
					// If so, adds the tag with changes.
					if (Number(fileLoadManager.vVideoXml.video[j].@stime) <= endTimeInSeconds && Number(fileLoadManager.vVideoXml.video[j].@etime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.vVideoXml.video[j].@stime;
						tempXml.@uname=fileLoadManager.vVideoXml.video[j].@uname;
						tempXml.@displyname=fileLoadManager.vVideoXml.video[j].@displyname;
						tempXml.@src=fileLoadManager.vVideoXml.video[j].@src;
						tempXml.@etime=fileLoadManager.vVideoXml.video[j].@etime;
						tempXml.@seekStartValue=startTimeInSeconds / 1000;
						tempXml.@seekExist="true";
						tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.vVideoXml.video[i].@stime)) / 1000 + Number(fileLoadManager.vVideoXml.video[i].@seekTime);
						tempXml.@stime=endTimeInSeconds;
						newViewerVideoXml.appendChild(tempXml);
						i=j;
						break;
					}
						// Check the etime is less than or equal to endTimeInSeconds and next tag stime is greater than endTimeInSeconds.
						// If so, adds the tag with changes.
					else if (Number(fileLoadManager.vVideoXml.video[j].@etime) <= endTimeInSeconds && (j + 1 <= fileLoadManager.vVideoXml.video.length() - 1) && Number(fileLoadManager.vVideoXml.video[(j + 1)].@stime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.vVideoXml.video[j + 1].@stime;
						tempXml.@uname=fileLoadManager.vVideoXml.video[j + 1].@uname;
						tempXml.@displyname=fileLoadManager.vVideoXml.video[j + 1].@displyname;
						tempXml.@src=fileLoadManager.vVideoXml.video[j + 1].@src;
						tempXml.@etime=fileLoadManager.vVideoXml.video[j + 1].@etime;
						tempXml.@seekStartValue=fileLoadManager.vVideoXml.video[j + 1].@seekStartValue;
						tempXml.@seekExist=fileLoadManager.vVideoXml.video[j + 1].@seekExist;
						tempXml.@seekTime=fileLoadManager.vVideoXml.video[j + 1].@seekTime;
						newViewerVideoXml.appendChild(tempXml);
						i=j + 1;
						break;
					}
				}
			}
		}
			// Check the etime is less than or equal to startTimeInSeconds and next tag stime is greater than startTimeInSeconds.
			// If so, adds the tag.
		else if (Number(fileLoadManager.vVideoXml.video[i].@etime) <= startTimeInSeconds && Number(fileLoadManager.vVideoXml.video[i + 1].@stime) >= startTimeInSeconds){
			newViewerVideoXml.appendChild(tempXml);
			// Check the etime is greater than or equal to endTimeInSeconds
			// If so, adds the tag with changes. 
			if (Number(fileLoadManager.vVideoXml.video[i].@etime) >= endTimeInSeconds){
				tempXml=<video></video>;
				tempXml.@stime=fileLoadManager.vVideoXml.video[i].@stime;
				tempXml.@uname=fileLoadManager.vVideoXml.video[i].@uname;
				tempXml.@displyname=fileLoadManager.vVideoXml.video[i].@displyname;
				tempXml.@src=fileLoadManager.vVideoXml.video[i].@src;
				tempXml.@etime=fileLoadManager.vVideoXml.video[i].@etime;
				tempXml.@seekStartValue=startTimeInSeconds / 1000;
				tempXml.@seekExist="true";
				tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.vVideoXml.video[i].@stime)) / 1000 + Number(fileLoadManager.vVideoXml.video[i].@seekTime);
				tempXml.@stime=endTimeInSeconds;
				newViewerVideoXml.appendChild(tempXml);
			}
			else{
				// Loops through the rest of tag values for finding the 'endTimeInSeconds' value.
				for (var k:int=i; k < fileLoadManager.vVideoXml.video.length(); k++){
					// Check the stime is less than or equal to endTimeInSeconds and etime is greater than startTimeInSeconds.
					// If so, adds the tag.
					if (Number(fileLoadManager.vVideoXml.video[k].@stime) <= endTimeInSeconds && Number(fileLoadManager.vVideoXml.video[k].@etime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.vVideoXml.video[k].@stime;
						tempXml.@uname=fileLoadManager.vVideoXml.video[k].@uname;
						tempXml.@displyname=fileLoadManager.vVideoXml.video[k].@displyname;
						tempXml.@src=fileLoadManager.vVideoXml.video[k].@src;
						tempXml.@etime=fileLoadManager.vVideoXml.video[k].@etime;
						tempXml.@seekStartValue=startTimeInSeconds / 1000;
						tempXml.@seekExist="true";
						tempXml.@seekTime=(endTimeInSeconds - Number(fileLoadManager.vVideoXml.video[i].@stime)) / 1000 + Number(fileLoadManager.vVideoXml.video[i].@seekTime);
						tempXml.@stime=endTimeInSeconds;
						newViewerVideoXml.appendChild(tempXml);
						i=k;
						break;
					}
						// Check the etime is less than or equal to endTimeInSeconds and next tag stime is greater than endTimeInSeconds.
						// If so, adds the tag with changes. 
					else if (Number(fileLoadManager.vVideoXml.video[k].@etime) <= endTimeInSeconds && Number(fileLoadManager.vVideoXml.video[(k + 1)].@stime) >= endTimeInSeconds){
						tempXml=<video></video>;
						tempXml.@stime=fileLoadManager.vVideoXml.video[k + 1].@stime;
						tempXml.@uname=fileLoadManager.vVideoXml.video[k + 1].@uname;
						tempXml.@displyname=fileLoadManager.vVideoXml.video[k + 1].@displyname;
						tempXml.@src=fileLoadManager.vVideoXml.video[k + 1].@src;
						tempXml.@etime=fileLoadManager.vVideoXml.video[k + 1].@etime;
						tempXml.@seekStartValue=fileLoadManager.vVideoXml.video[k + 1].@seekStartValue;
						tempXml.@seekExist=fileLoadManager.vVideoXml.video[k + 1].@seekExist;
						tempXml.@seekTime=fileLoadManager.vVideoXml.video[k + 1].@seekTime;
						newViewerVideoXml.appendChild(tempXml);
						i=k + 1;
						break;
					}
				}
			}
		}
			// Check the tag stime and etime not in editing time
			// If so, adds the tag. 
		else if (!(Number(fileLoadManager.vVideoXml.video[i].@stime) >= startTimeInSeconds && Number(fileLoadManager.vVideoXml.video[i].@etime) <= endTimeInSeconds)){
			newViewerVideoXml.appendChild(tempXml);
		}
	}
	
	// Loops through the newly created xml tag values and decreases the endTimeInSeconds.
	for (var l:int=0; l < newViewerVideoXml.video.length(); l++){
		if (newViewerVideoXml.video[l].@etime >= endTimeInSeconds)
			newViewerVideoXml.video[l].@etime=newViewerVideoXml.video[l].@etime - totalEditingTime;
		if (newViewerVideoXml.video[l].@stime >= endTimeInSeconds)
			newViewerVideoXml.video[l].@stime=newViewerVideoXml.video[l].@stime - totalEditingTime;
		
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function for creating the new xml tags for
 * Document pointer after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewDocPointerValues():void{
	newDocPointerXml=<pointer></pointer>;
	// Loops through the Document pointer xml tags
	for (var i:int=0; i < fileLoadManager.docPointerXml.event.length(); i++){
		// Checks if ctime is not in between startTimeInSeconds and endTimeInSeconds.
		// If so, add tags.
		if (!(Number(fileLoadManager.docPointerXml.event[i].@ctime) > startTimeInSeconds && Number(fileLoadManager.docPointerXml.event[i].@ctime) <= endTimeInSeconds)){
			var tempXml:XML=<event></event >;
			tempXml.@ctime=fileLoadManager.docPointerXml.event[i].@ctime;
			tempXml.@x=fileLoadManager.docPointerXml.event[i].@x;
			tempXml.@y=fileLoadManager.docPointerXml.event[i].@y;
			tempXml.@cwidth=fileLoadManager.docPointerXml.event[i].@cwidth;
			tempXml.@cheight=fileLoadManager.docPointerXml.event[i].@cheight;
			tempXml.@container=fileLoadManager.docPointerXml.event[i].@container;
			if (Number(fileLoadManager.docPointerXml.event[i].@ctime) > endTimeInSeconds)
				tempXml.@ctime=tempXml.@ctime - totalEditingTime;
			newDocPointerXml.appendChild(tempXml);
		}
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function for creating the new xml tags for
 * Whiteboard pointer after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewWbPointerValues():void{
	newWbPointerXml=<pointer></pointer>;
	// Loops through the Whiteboard pointer xml tags
	for (var i:int=0; i < fileLoadManager.wbPointerXml.event.length(); i++){
		// Checks if ctime is not in between startTimeInSeconds and endTimeInSeconds.
		// If so, add tags.
		if (!(Number(fileLoadManager.wbPointerXml.event[i].@ctime) > startTimeInSeconds && Number(fileLoadManager.wbPointerXml.event[i].@ctime) <= endTimeInSeconds)){
			var tempXml:XML=<event></event >;
			tempXml.@ctime=fileLoadManager.wbPointerXml.event[i].@ctime;
			tempXml.@x=fileLoadManager.wbPointerXml.event[i].@x;
			tempXml.@y=fileLoadManager.wbPointerXml.event[i].@y;
			tempXml.@cwidth=fileLoadManager.wbPointerXml.event[i].@cwidth;
			tempXml.@cheight=fileLoadManager.wbPointerXml.event[i].@cheight;
			tempXml.@container=fileLoadManager.wbPointerXml.event[i].@container;
			if (Number(fileLoadManager.wbPointerXml.event[i].@ctime) > endTimeInSeconds)
				tempXml.@ctime=tempXml.@ctime - totalEditingTime;
			newWbPointerXml.appendChild(tempXml);
		}
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function for creating the new xml tags for PTT after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewPttValues():void{
	newPttXml=<ptt></ptt>;
	var inBetweenTimeLine:Boolean=false;
	var lastStatus:String="";
	var tempXml:XML;
	// Loops through the PTT xml tags
	for (var i:int=0; i < fileLoadManager.pttXml.state.length(); i++){
		// Checks if ctime is not in between startTimeInSeconds and endTimeInSeconds.
//		AKCR: can the following 2 if conditions be combined?
		if (!(Number(fileLoadManager.pttXml.state[i].@ctime) > startTimeInSeconds && Number(fileLoadManager.pttXml.state[i].@ctime) <= endTimeInSeconds)){
			// For getting the last PTT state after the editing is done.
			if ((!inBetweenTimeLine) && Number(fileLoadManager.pttXml.state[(i - 1)].@ctime) > 
				startTimeInSeconds && Number(fileLoadManager.pttXml.state[(i - 1)].@ctime) <= endTimeInSeconds){
				inBetweenTimeLine=true;
				if (Number(fileLoadManager.pttXml.state[i].@ctime) != endTimeInSeconds){
					tempXml=<state></state >;
					tempXml.@ctime=endTimeInSeconds - totalEditingTime;
					tempXml.@state=fileLoadManager.pttXml.state[(i - 1)].@state;
					newPttXml.appendChild(tempXml);
				}
			}
			tempXml=<state></state >;
			tempXml.@ctime=fileLoadManager.pttXml.state[i].@ctime;
			tempXml.@state=fileLoadManager.pttXml.state[i].@state;
			if (tempXml.@ctime > endTimeInSeconds)
				tempXml.@ctime=tempXml.@ctime - totalEditingTime;
			newPttXml.appendChild(tempXml);
		}
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 *
 * @private
 * Function for creating the new xml tags for
 * Whiteboard after video editing done.
 *
 * @param void
 * @return void
 */
// AKCR: IMPORTANT: what is the performance of this function? There is 5 levels of nesting of FOR loop in this function
// AKCR: IMPORTANT: page > size > whiteboard xml shape > page lenght > shape length
// AKCR: IMPORTANT: please consider creating an object/json map and using a library function to emit XML document
// AKCR: Further optimization is possible by storing the values in a meaningful manner during video editing
private function createNewWbValues():void{
	newWbXml=<wb></wb>;
	var boolEndTime:Boolean=false;
	var tempXml:XML;
	var tempPage:XML;
	var tempSize:XML;
	// Loops through the Whiteboard xml page tags
	for (var i:int=0; i < fileLoadManager.wbXml.page.length(); i++){
		// Checks if ctime of current and next tag is less than startTimeInSeconds.
		// If so, adds the tag.
		if (fileLoadManager.wbXml.page[i].@ctime < startTimeInSeconds && i != (fileLoadManager.wbXml.page.length() - 1) && fileLoadManager.wbXml.page[(i + 1)].@ctime < startTimeInSeconds){
			tempXml=fileLoadManager.wbXml.page[i];
			newWbXml.appendChild(tempXml);
			continue;
		}
		
		tempPage=<page></page>;
		tempPage.@ctime=fileLoadManager.wbXml.page[i].@ctime;
		tempPage.@num=fileLoadManager.wbXml.page[i].@num;
		newWbXml.appendChild(tempPage);
		
		// Checks if ctime is greater than startTimeInSeconds.
		// If so, change the ctime value.
		if (i == 0 && fileLoadManager.wbXml.page[i].@ctime > startTimeInSeconds){
			tempPage.@ctime=endTimeInSeconds - totalEditingTime;
		}
		
		// Loops through the Whiteboard xml size tags
		for (var j:int=0; j < fileLoadManager.wbXml.page[i].size.length(); j++){
			// Checks if ctime of current and next tag is less than startTimeInSeconds.
			// If so, adds the tag.
			if (fileLoadManager.wbXml.page[i].size[j].@ctime < startTimeInSeconds && j != (fileLoadManager.wbXml.page[i].size.length() - 1) && fileLoadManager.wbXml.page[i].size[(j + 1)].@ctime < startTimeInSeconds){
				tempXml=fileLoadManager.wbXml.page[i].size[j];
				tempPage.appendChild(tempXml);
				continue;
			}
			
			tempSize=<size></size>;
			tempSize.@ctime=fileLoadManager.wbXml.page[i].size[j].@ctime;
			tempSize.@width=fileLoadManager.wbXml.page[i].size[j].@width;
			tempSize.@height=fileLoadManager.wbXml.page[i].size[j].@height;
			tempPage.appendChild(tempSize);
			
			// Checks if ctime is greater than startTimeInSeconds.
			// If so, change the ctime value.
			if (j == 0 && fileLoadManager.wbXml.page[i].size[j].@ctime > startTimeInSeconds){
				tempSize.@ctime=endTimeInSeconds - totalEditingTime;
			}
			
			// Loops through the Whiteboard xml shape tags
			for (var k:int=0; k < fileLoadManager.wbXml.page[i].size[j].shape.length(); k++){
				// Checks if ctime is greater than startTimeInSeconds.
				// If so, add the tag.
				if (fileLoadManager.wbXml.page[i].size[j].shape[k].@ctime < startTimeInSeconds){
					tempXml=fileLoadManager.wbXml.page[i].size[j].shape[k];
					tempSize.appendChild(tempXml);
				}
				else{
					break;
				}
			}
			
			// Loops through each tags and inner tags for finding the xml tag after the endtime.
			for (var tempi:int=0; tempi < fileLoadManager.wbXml.page.length(); tempi++){
				if (fileLoadManager.wbXml.page[tempi].@ctime < startTimeInSeconds && tempi != (fileLoadManager.wbXml.page.length() - 1) && fileLoadManager.wbXml.page[(tempi + 1)].@ctime < startTimeInSeconds){
					continue;
				}
				boolEndTime=false;
				var tempContent:XML=<content></content>;
				var tempACWbData:ArrayCollection=new ArrayCollection();
				var tempPageNum:Number=fileLoadManager.wbXml.page[tempi].@num;
				if (tempi != i){
					tempSize=<size></size>;
					tempPage=<page></page>;
				}
				for (var tempj:int=0; tempj < fileLoadManager.wbXml.page[tempi].size.length(); tempj++){
					j=tempj;
					if (fileLoadManager.wbXml.page[tempi].size[tempj].@ctime < startTimeInSeconds && tempj != (fileLoadManager.wbXml.page[tempi].size.length() - 1) && fileLoadManager.wbXml.page[tempi].size[(tempj + 1)].@ctime < startTimeInSeconds){
						continue;
					}
					for (var tempk:int=0; tempk < fileLoadManager.wbXml.page[tempi].size[tempj].shape.length(); tempk++){
						k=tempk;
						if (fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk].@ctime < startTimeInSeconds){
							continue;
						}
						
						// Checks the ctime is greater than endTimeInSeconds.
						// If so, adds the tag value.
						if (fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk].@ctime < endTimeInSeconds){
							boolEndTime=true;
							var tempValue:XML=fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk];
							tempValue.@ctime=endTimeInSeconds - totalEditingTime;
							tempACWbData.addItem(tempValue);
							if (tempk == (fileLoadManager.wbXml.page[tempi].size[tempj].shape.length() - 1) && tempi != (fileLoadManager.wbXml.page.length() - 1) && fileLoadManager.wbXml.page[(tempi + 1)].@ctime >= endTimeInSeconds){
								boolEndTime=false;
								if (tempi != i){
									i=tempi;
									j=tempj;
									k=tempk;
									tempPage.@ctime=endTimeInSeconds - totalEditingTime;
									tempPage.@num=fileLoadManager.wbXml.page[tempi].@num;
									newWbXml.appendChild(tempPage);
									
									tempSize.@ctime=endTimeInSeconds - totalEditingTime;
									tempSize.@width=fileLoadManager.wbXml.page[tempi].size[tempj].@width;
									tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
									tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
									tempPage.appendChild(tempSize);
								}
								for each (var tXml:XML in tempACWbData){
									tempSize.appendChild(tXml);
								}
							}
						}
						else{
							if (boolEndTime){
								boolEndTime=false;
								if (tempi != i){
									i=tempi;
									j=tempj;
									k=tempk;
									tempPage.@ctime=endTimeInSeconds - totalEditingTime;
									tempPage.@num=fileLoadManager.wbXml.page[tempi].@num;
									newWbXml.appendChild(tempPage);
									
									tempSize.@ctime=endTimeInSeconds - totalEditingTime;
									tempSize.@width=fileLoadManager.wbXml.page[tempi].size[tempj].@width;
									tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
									tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
									tempPage.appendChild(tempSize);
								}
								for each (var tmpXml:XML in tempACWbData){
									tempSize.appendChild(tmpXml);
								}
							}
							if (tempi != i){
								i=tempi;
								j=tempj;
								k=tempk;
								tempPage.@ctime=Number(fileLoadManager.wbXml.page[tempi].@ctime) - totalEditingTime;
								tempPage.@num=fileLoadManager.wbXml.page[tempi].@num;
								newWbXml.appendChild(tempPage);
								
								tempSize.@ctime=Number(fileLoadManager.wbXml.page[tempi].size[tempj].@ctime) - totalEditingTime;
								tempSize.@width=fileLoadManager.wbXml.page[tempi].size[tempj].@width;
								tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
								tempPage.appendChild(tempSize);
							}
							tempXml=fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk];
							tempXml.@ctime=tempXml.@ctime - totalEditingTime;
							tempSize.appendChild(tempXml);
						}
					}
				}
				i=tempi;
				j=tempj;
				k=tempk;
			}
		}
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 *
 * @private
 * Function for creating the new xml tags for
 * Document Sharing after video editing done.
 *
 * @param void
 * @return void
 */
// AKCR: IMPORTANT: there is lot of constants in this function. Perhaps, there should be some pre-defined XML/json document already that should be
// AKCR: IMPORTANT: instantiated in here and populated with values.
// AKCR: there is deep nesting of FOR loops, making this function very in-efficient
private function createNewDocValues():void{
	newDocXml=<document></document>;
	var tempZoom:XML=<event action="zoom"></event>;
	var tempPage:XML=<event action="page"></event>;
	var tempRotation:XML=<event action="rotation" value="0"></event>;
	var tempScroll:XML=<event action="scroll" scrollDirction="vertical" scrollPosition="0"></event>;
	var tempAnimation:XML=<event action="animation"></event>;
	var boolEndTime:Boolean=false;
	var tempXml:XML;
	var tempSize:XML;
	var tempDocloaded:XML;
	// Loops through the Document Sharing xml docloaded tags
	for (var i:int=0; i < fileLoadManager.docXml.docloaded.length(); i++){
		// Checks if ctime of current and next tag is less than startTimeInSeconds.
		// If so, adds the tag.
		if (fileLoadManager.docXml.docloaded[i].@ctime < startTimeInSeconds && i != (fileLoadManager.docXml.docloaded.length() - 1) && fileLoadManager.docXml.docloaded[(i + 1)].@ctime < startTimeInSeconds){
			tempXml=fileLoadManager.docXml.docloaded[i];
			newDocXml.appendChild(tempXml);
			continue;
		}
		
		tempDocloaded=<docloaded></docloaded>;
		tempDocloaded.@ctime=fileLoadManager.docXml.docloaded[i].@ctime;
		tempDocloaded.@src=fileLoadManager.docXml.docloaded[i].@src;
		tempDocloaded.@type=fileLoadManager.docXml.docloaded[i].@type;
		tempDocloaded.@orginalName=fileLoadManager.docXml.docloaded[i].@orginalName;
		newDocXml.appendChild(tempDocloaded);
		// Checks if ctime is greater than startTimeInSeconds.
		// If so, change the ctime value.
		if (i == 0 && fileLoadManager.docXml.docloaded[i].@ctime > startTimeInSeconds){
			tempDocloaded.@ctime=endTimeInSeconds - totalEditingTime;
		}
		// Loops through the Document Sharing xml size tags
		for (var j:int=0; j < fileLoadManager.docXml.docloaded[i].size.length(); j++){
			// Checks if ctime of current and next tag is less than startTimeInSeconds.
			// If so, adds the tag.
			if (fileLoadManager.docXml.docloaded[i].size[j].@ctime < startTimeInSeconds && j != (fileLoadManager.docXml.docloaded[i].size.length() - 1) && fileLoadManager.docXml.docloaded[i].size[(j + 1)].@ctime < startTimeInSeconds){
				tempXml=fileLoadManager.docXml.docloaded[i].size[j];
				tempDocloaded.appendChild(tempXml);
				continue;
			}
			
			tempSize=<size></size>;
			tempSize.@ctime=fileLoadManager.docXml.docloaded[i].size[j].@ctime;
			tempSize.@maxx=fileLoadManager.docXml.docloaded[i].size[j].@maxx;
			tempSize.@maxy=fileLoadManager.docXml.docloaded[i].size[j].@maxy;
			tempSize.@width=fileLoadManager.docXml.docloaded[i].size[j].@width;
			tempSize.@height=fileLoadManager.docXml.docloaded[i].size[j].@height;
			tempSize.@zoomfactorX=fileLoadManager.docXml.docloaded[i].size[j].@zoomfactorX;
			tempSize.@zoomfactorY=fileLoadManager.docXml.docloaded[i].size[j].@zoomfactorY;
			tempDocloaded.appendChild(tempSize);
			
			// Checks if ctime is greater than startTimeInSeconds.
			// If so, change the ctime value.
			if (j == 0 && fileLoadManager.docXml.docloaded[i].size[j].@ctime > startTimeInSeconds){
				tempSize.@ctime=endTimeInSeconds - totalEditingTime;
			}
			
			// Loops through the Document Sharing xml event tags
			for (var k:int=0; k < fileLoadManager.docXml.docloaded[i].size[j].event.length(); k++){
				// Checks if ctime is greater than startTimeInSeconds.
				// If so, add the tag.
				if (fileLoadManager.docXml.docloaded[i].size[j].event[k].@ctime < startTimeInSeconds){
					tempXml=fileLoadManager.docXml.docloaded[i].size[j].event[k];
					tempSize.appendChild(tempXml);
				}
				else{
					break;
				}
			}
			
			// Loops through each tags and inner tags for finding the xml tag after the endtime.
			for (var tempi:int=0; tempi < fileLoadManager.docXml.docloaded.length(); tempi++){
				if (fileLoadManager.docXml.docloaded[tempi].@ctime < startTimeInSeconds && tempi != (fileLoadManager.docXml.docloaded.length() - 1) && fileLoadManager.docXml.docloaded[(tempi + 1)].@ctime < startTimeInSeconds){
					continue;
				}
				tempPage=<event action="page"></event>;
				tempScroll=<event action="scroll" scrollDirction="vertical" scrollPosition="0"></event>;
				tempAnimation=<event action="animation"></event>;
				if (tempi == 0 || (fileLoadManager.docXml.docloaded[tempi - 1].@orginalName != fileLoadManager.docXml.docloaded[tempi].@orginalName)){
					boolEndTime=false;
					tempZoom=<event action="zoom"></event>;
					tempRotation=<event action="rotation" value="0"></event>;
				}
				if (tempi != i){
					tempSize=<size></size>;
					tempDocloaded=<docloaded></docloaded>;
				}
				for (var tempj:int=0; tempj < fileLoadManager.docXml.docloaded[tempi].size.length(); tempj++){
					j=tempj;
					if (fileLoadManager.docXml.docloaded[tempi].size[tempj].@ctime < startTimeInSeconds && tempj != (fileLoadManager.docXml.docloaded[tempi].size.length() - 1) && fileLoadManager.docXml.docloaded[tempi].size[(tempj + 1)].@ctime < startTimeInSeconds){
						continue;
					}
					for (var tempk:int=0; tempk < fileLoadManager.docXml.docloaded[tempi].size[tempj].event.length(); tempk++){
						
						k=tempk;
						if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime < startTimeInSeconds){
							continue;
						}
						
						if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime < endTimeInSeconds){
							boolEndTime=true;
							if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action == "page"){
								tempScroll=<event action="scroll" scrollDirction="vertical" scrollPosition="0"></event>;
								tempPage.@action=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action;
								tempPage.@ctime=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime;
								tempPage.@pageno=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@pageno;
							}
							else if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action == "rotation"){
								tempRotation.@action=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action;
								tempRotation.@ctime=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime;
								tempRotation.@value=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@value;
							}
							else if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action == "zoom"){
								tempZoom.@action=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action;
								tempZoom.@ctime=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime;
								tempZoom.@zoomX=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@zoomX;
								tempZoom.@zoomY=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@zoomY;
							}
							else if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action == "scroll"){
								tempScroll.@action=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action;
								tempScroll.@ctime=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime;
								tempScroll.@scrollDirction=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@scrollDirction;
								tempScroll.@scrollPosition=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@scrollPosition;
							}
							else if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action == "animation"){
								tempAnimation.@action=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@action;
								tempAnimation.@ctime=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime;
								tempAnimation.@value=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@value;
								tempAnimation.@pageno=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@pageno;
							}
						}
						else{
							
							if (boolEndTime){
								boolEndTime=false;
								tempPage.@ctime=endTimeInSeconds - totalEditingTime;
								tempAnimation.@ctime=endTimeInSeconds - totalEditingTime;
								tempScroll.@ctime=endTimeInSeconds - totalEditingTime;
								tempZoom.@ctime=endTimeInSeconds - totalEditingTime;
								tempRotation.@ctime=endTimeInSeconds - totalEditingTime;
								tempSize.appendChild(tempPage);
								if (tempAnimation.hasOwnProperty("@value"))
									tempSize.appendChild(tempAnimation);
								tempSize.appendChild(tempScroll);
								if (tempZoom.hasOwnProperty("@zoomX"))
									tempSize.appendChild(tempZoom);
								tempSize.appendChild(tempRotation);
								if (tempi != i){
									i=tempi;
									tempDocloaded.@ctime=endTimeInSeconds - totalEditingTime;
									tempDocloaded.@src=fileLoadManager.docXml.docloaded[tempi].@src;
									tempDocloaded.@type=fileLoadManager.docXml.docloaded[tempi].@type;
									tempDocloaded.@orginalName=fileLoadManager.docXml.docloaded[tempi].@orginalName;
									newDocXml.appendChild(tempDocloaded);
									
									j=tempj;
									k=tempk;
									tempSize.@ctime=endTimeInSeconds - totalEditingTime;
									tempSize.@maxx=fileLoadManager.docXml.docloaded[tempi].size[tempj].@maxx;
									tempSize.@maxy=fileLoadManager.docXml.docloaded[tempi].size[tempj].@maxy;
									tempSize.@width=fileLoadManager.docXml.docloaded[tempi].size[tempj].@width;
									tempSize.@height=fileLoadManager.docXml.docloaded[tempi].size[tempj].@height;
									tempSize.@zoomfactorX=fileLoadManager.docXml.docloaded[tempi].size[tempj].@zoomfactorX;
									tempSize.@zoomfactorY=fileLoadManager.docXml.docloaded[tempi].size[tempj].@zoomfactorY;
									tempDocloaded.appendChild(tempSize);
								}
							}
							if (tempi != i){
								i=tempi;
								
								tempDocloaded.@ctime=fileLoadManager.docXml.docloaded[tempi].@ctime - totalEditingTime;
								tempDocloaded.@src=fileLoadManager.docXml.docloaded[tempi].@src;
								tempDocloaded.@type=fileLoadManager.docXml.docloaded[tempi].@type;
								tempDocloaded.@orginalName=fileLoadManager.docXml.docloaded[tempi].@orginalName;
								newDocXml.appendChild(tempDocloaded);
								
								j=tempj;
								k=tempk;
								tempSize.@ctime=fileLoadManager.docXml.docloaded[tempi].size[tempj].@ctime - totalEditingTime;
								tempSize.@maxx=fileLoadManager.docXml.docloaded[tempi].size[tempj].@maxx;
								tempSize.@maxy=fileLoadManager.docXml.docloaded[tempi].size[tempj].@maxy;
								tempSize.@width=fileLoadManager.docXml.docloaded[tempi].size[tempj].@width;
								tempSize.@height=fileLoadManager.docXml.docloaded[tempi].size[tempj].@height;
								tempSize.@zoomfactorX=fileLoadManager.docXml.docloaded[tempi].size[tempj].@zoomfactorX;
								tempSize.@zoomfactorY=fileLoadManager.docXml.docloaded[tempi].size[tempj].@zoomfactorY;
								tempDocloaded.appendChild(tempSize);
							}
							tempXml=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk];
							tempXml.@ctime=Number(tempXml.@ctime) - totalEditingTime
							tempSize.appendChild(tempXml);
						}
					}
				}
				
				i=tempi;
				j=tempj;
				k=tempk;
			}
		}
	}
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}


/**
 *
 * @private
 * Function for creating the new xml tags for End time file after video editing done.
 *
 * @param void
 * @return void
 */
private function createNewEndTimeValues():void{
	newEndXml=<time></time>;
	var tempXml:XML=<etime></etime>;
	var time:Number=fileLoadManager.endTimeXml.etime;
	newEndXml.etime=time - totalEditingTime;
	xmlFileCreationCount++;
	createBackUpFilesServerSide();
}

/**
 *
 * @private
 * Function for calling the corresponding PHP
 * for taking a back up of the original folder.
 *
 * @param void
 * @return void
 */
private function createBackUpFilesServerSide():void{
	if (xmlFileCreationCount == TOTAL_FILES){
		var backUpServerFiles:HTTPService=new HTTPService();
		var tempUrl:String=contentUrl + "/AVScript/Editing/backup.php?recordingFolderPath=" + contentFilePath;
		backUpServerFiles.url=tempUrl;
		backUpServerFiles.addEventListener(ResultEvent.RESULT, serverSideBackUpCreated);
		backUpServerFiles.addEventListener(FaultEvent.FAULT, failToCreateServerSideFolder);
		backUpServerFiles.send();
	}
	
}

/**
 *
 * @private
 * Function for saving the file in local disk and
 * uploading to the content server.
 *
 * @param event of type ResultEvent
 * @return void
 */
private function serverSideBackUpCreated(event:ResultEvent):void{
	applicationType::desktop{
		/* File and FileStream not available for web.*/
		saveAndUpload(wbFile, wbFileStream, newWbXml.toXMLString());
		saveAndUpload(docFile, docFileStream, newDocXml.toXMLString());
		saveAndUpload(chatFile, chatFileStream, newChatXml.toXMLString());
		saveAndUpload(presenterVideoFile, presenterVideoFileStream, newPresenterVideoXml.toXMLString());
		saveAndUpload(viewerVideoFile, viewerVideoFileStream, newViewerVideoXml.toXMLString());
		saveAndUpload(wbPointerFile, wbPointerFileStream, newWbPointerXml.toXMLString());
		saveAndUpload(docPointerFile, docPointerFileStream, newDocPointerXml.toXMLString());
		saveAndUpload(pttFile, pttFileStream, newPttXml.toXMLString());
		saveAndUpload(endFile, endFileStream, newEndXml.toXMLString());
	}
}

/**
 * @private
 * Function for opening the file and writing the contents
 * into it and calling PHP for uploading.
 *
 * @param tempFile of type File
 * @param tempFileStream of FileStream
 * @param tempXml of String
 * @return void
 */
applicationType::desktop{
	/* File and FileStream not available for web.*/
	private function saveAndUpload(tempFile:File, tempFileStream:FileStream, tempXml:String):void{
		tempFileStream.open(tempFile, FileMode.WRITE);
		// AKCR: please use configuration values for such common strings
		tempFileStream.writeUTFBytes("<?xml version=\"1.0\" encoding=\"utf-8\"?>" + tempXml);
		tempFileStream.close();
		// AKCR: please define the file path in some constant. For the client code, this values is hard-coded in about 5-7 places, which is not good
		var url:String=contentUrl + "/AVScript/Common/upload.php?folderPath=" + contentFilePath;
		tempFile.upload(new URLRequest(url));
		tempFile.addEventListener(Event.COMPLETE, fileUploadSuccess);
		tempFile.addEventListener(IOErrorEvent.IO_ERROR, failToCreateServerSideFolder);
		tempFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, failToCreateServerSideFolder);
	}
}

/**
 * @private
 * Function invokes after the successful upload of
 * file to content server.
 *
 * @param event of type Event
 * @return void
 */
private function fileUploadSuccess(event:Event):void{
	fileUploadCount++;
	if (fileUploadCount == TOTAL_FILES){
		fileUploadCount=0;
		this.dispatchEvent(new CloseFileHandler(CloseFileHandler.CLOSED_VIDEO_EDITING));
	}
}

/**
 * @private
 * Function invokes when fails to upload of file to content server.
 *
 * @param event of type Event
 * @return void
 */
private function failToCreateServerSideFolder(event:Event):void{
	Alert.show("Video Editing of Recorded files failed", "INFO", 4, this);
}

/**
 * @private
 * Function invokes after the creation complete of EditLecture component.
 *
 * @param void
 * @return void
 */
private function editLectureCreationCompleteEvent():void{
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
	txtEndTimeMin.addChild(lbEndMin);
	txtEndTimeSec.addChild(lbEndSec);
}

/**
 * @public
 * Function used for highlight text in textInput field on click
 *
 * @param event of type MouseEvent
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
 * @param event of type FoucsEvent
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
 * Function invokes when data in text box changes.
 * Need to change the slider position according to that.
 *
 * @param event of type Event
 * @return void
 */
public function onTextChange(event:Event):void{
	
	if (((Number(txtStartTimeMin.text) * 60) < this.parentApplication.aviewplayer.seekBar.maximum) && ((Number(txtEndTimeMin.text) * 60) < this.parentApplication.aviewplayer.seekBar.maximum)){
		this.parentApplication.aviewplayer.seekBar.setThumbValueAt(0, ((Number(txtStartTimeMin.text) * 60) + Number(txtStartTimeSec.text)));
		this.parentApplication.aviewplayer.seekBar.setThumbValueAt(1, ((Number(txtEndTimeMin.text) * 60) + Number(txtEndTimeSec.text)));
	}
	else{
		Alert.show("Start time and end time must not be greater than total time", "Video Editor", 0, this);
		this.parentApplication.aviewplayer.seekBar.setThumbValueAt(0, this.parentApplication.aviewplayer.seekBar.maximum / 5);
		this.parentApplication.aviewplayer.seekBar.setThumbValueAt(1, this.parentApplication.aviewplayer.seekBar.maximum / 4);
		var eventSlider:SliderEvent=new SliderEvent(SliderEvent.CHANGE);
		this.parentApplication.aviewplayer.seekBar.dispatchEvent(eventSlider);
	}
}

/**
 * @private
 * Function clears the textbox values.
 *
 * @param void
 * @return void
 */
private function clearTextAndLabelFields():void{
	txtStartTimeSec.text="00";
	txtStartTimeMin.text="00";
	txtEndTimeMin.text="00";
	txtEndTimeSec.text="00";
}

/**
 * @private
 * Function invokes when user clicks the save button.
 * Calls the function for creating new xml tags based on the time entered.
 *
 * @param void
 * @return void
 */
private function saveChanges():void{
	createNewXmlValues(Number(txtStartTimeMin.text.toString()), Number(txtStartTimeSec.text.toString()), Number(txtEndTimeMin.text.toString()), Number(txtEndTimeSec.text.toString()));
}

/**
 * @private
 * Function invokes when user clicks the cancel button.
 *
 * @param void
 * @return void
 */
private function cancel():void{
	this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
	PopUpManager.removePopUp(this);
}
