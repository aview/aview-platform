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
 * File			: VideoRecordingComponentScript.as
 * Module		: Video Editing
 * Developer(s)	: Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for establishing a FMS connection, sending streams to server, creates new
 * XML tags and uploads to server.
 *
 */
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.playback.editing.scripts.CloseFileHandler;

import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.media.SoundCodec;
import flash.media.Video;
import flash.media.VideoStreamSettings;
import flash.media.scanHardware;
import flash.net.NetStream;
import flash.net.Socket;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.controls.VideoDisplay;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

applicationType::desktop{
	/*File and FileStream not available for web.*/
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
}
// AKCR: please use the single line comment format
// AKCR: variable do not need explanation if they are verbose
/**
 * Audio bitrate value based on bandwidth selected.
 */
public var audioBitrate:int;

/**
 * Video bitrate value based on bandwidth selected.
 */
public var videoBitrate:int;

/**
 * Video capturing width based on bandwidth selected.
 */
public var videoCaptureWidth:int;

/**
 * Video capturing height based on bandwidth selected.
 */
public var videoCaptureHeight:int;

/**
 * Video publishing bandwidth.
 */
public var videoBandwidth:int;

/**
 * Video publishing quality.
 */
public var videoQuality:int;

/**
 * Video capturing frames per second.
 */
public var fps:int;

/**
 * Total time taken for recording.
 */
private var recordingTime:Number;

/**
 * Time at which newly recorded lecure to be inserted.
 */
private var insertingTime:Number;

/**
 *  New PTT XML after video inserting.
 */
private var newPttXml:XML;

/**
 *  New Whiteboard pointer XML after video inserting.
 */
private var newWbPointerXml:XML;

/**
 *  New Document pointer XML after video inserting.
 */
private var newDocPointerXml:XML;

/**
 *  New Presenter Video XML after video inserting.
 */
private var newPresenterVideoXml:XML;

/**
 *  New Chat XML after video inserting.
 */
private var newChatXml:XML;

/**
 *  New Viewer XML after video inserting.
 */
private var newViewerVideoXml:XML;

/**
 *  New Document sharing XML after video inserting.
 */
private var newDocumentXml:XML;

/**
 *  New Whiteboard XML after video inserting.
 */
private var newWhiteboardXml:XML;

/**
 *  New End XML after video inserting.
 */
private var newEndXml:XML;

/**
 *  Variable holds the count of xml created during video inserting.
 */
private var xmlFileCreationCOunt:int;

/**
 * Total number of files for uploading is 9.
 */
private static const TOTAL_FILES:int=9;

/**
 * Total number of files for uploading to server.
 */
private var numFileUpload:int;

/**
 * Array holds the camera driver names.
 */
private var arCameraDriverNames:Array;

/**
 * Array holds the microphone driver names.
 */
private var arMicroPhoneDriverNames:Array;

/**
 * Variable holds the user selected bandwidth.
 */
private var selectedBandwidth:int;

/**
 * Variable of 'ClassHelper'.
 */
private var classHelper:ClassHelper=null;

/**
 * Variable holds the video codec for the class.
 */
private var videoCodec:String;

/**
 * Variable holds the application name for connecting to server.
 */
private var aviewClassName:String;

/**
 * Variable holds the user name.
 */
private var userName:String;

/**
 * Variable holds the publishing stream name.
 */
private var streamName:String;

/**
 * Array having the splitted file path.
 */
private var ipFMS:Array;

/**
 * Variable of 'Date' of video start time.
 */
private var videoStartTime:Date;

/**
 * Variable of 'Date' of video end time.
 */
private var videoEndTime:Date;

/**
 * Variable of 'Timer' for recording.
 */
private var recordingTimer:Timer;

/**
 * For Log API
 */
private var logger:ILogger=Log.getLogger("aview.edu.amrita.aview.playback.editing.components");

/**
 * FMS url path.
 */
private var fmsURL:String="";

/**
 * Variable of 'MessageBox' for notifying if recording in progress.
 */
private var recordingMessageBox:MessageBox;

/**
 * Http service for copying xml files to server.
 */
private var videoFileCopyService:HTTPService;

/**
 * Recording time in seconds.
 */
private var recordingTimeSeconds:int=00;

/**
 * Recording time in minutes.
 */
private var recordingTimeMinutes:int=00;

/**
 * Recording time in hour.
 */
private var recordingTimeHour:int=00;

/**
 * Timer for stops video recording after 3 seconds.
 */
private var stopRecordingTimer:Timer;

/**
 * File name including the extension.
 */
private var sourceFileName:String="";

/**
 * Index of camera driver choosen.
 */
private var cameraIndex:int;

/**
 * Index of microphone driver choosen.
 */
private var microPhoneIndex:int;

/**
 * Variable of 'Video' for local playback.
 */
private var videoLocalPlaying:Video;

/**
 * Variable of 'VideoDisplay' for local playback.
 */
private var videoLocalDisplay:VideoDisplay;

/**
 * Variable of 'Camera' for local playback.
 */
private var camera:Camera;

/**
 * Variable holds the data that is user publishing with video or not.
 */
private var isAudioOnlyOptionSelected:Boolean=false;

/**
 * Data for publishing using VP6
 */
private var processArgs:Vector.<String>;

/**
 * Data passing into flix codec.
 */
private var flixParameters:String;

/**
 * Variable of 'socket'.
 */
private var socket:Socket;

/**
 * Command needed to pass into socket.
 */
private var socketCommand:String;

/**
 * Variable of h264 codec class.
 */
private var h264Codec:H264VideoStreamSettings=new H264VideoStreamSettings();

/**
 * Variable of sorenson codec class.
 */
private var sorensonCodec:VideoStreamSettings=new VideoStreamSettings();

/**
 * Variable of 'Camera' for stream publish to server.
 */
private var cameraObj:Camera;

/**
 * Variable of 'Microphone' for stream publish to server.
 */
private var microPhoneObj:Microphone;

/**
 * Timer for maintaining a gap after stopping publish.
 */
private var timerSocket:Timer;

/**
 * Data about socket connection.
 */
private var socketRunning:Boolean=false;

/**
 * Netstream for publishing video.
 */
private var nsPublish:NetStream;


/**Platform specific variables*/
applicationType::desktop{
	/*File and FileStream not available for web.*/
	
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
	 * File for saving the endfile XML data.
	 */
	private var endFileStream:FileStream;
	
	/**
	 * Variable holds the location for file storage.
	 */
	private const FILE_LOCATION:String=File.applicationStorageDirectory.nativePath + "/Video_Inserting/";
	
	/**
	 * Hold the argument list and external exe path for publishing using VP6 codec.
	 */
	private var nativeProcessStartupInfo:NativeProcessStartupInfo;
	
	/**
	 * Hold the external exe file path.
	 */
	private var externalExeFile:File;
	
	/**
	 * Native process used for invoking the external exe for publishing using VP6 codec.
	 */
	public var npPublishVP6Video:NativeProcess;
}

/**
 * Camera device name selected for publishing.
 */
public var selectedCameraDevice:String=null;

/**
 * Microphone device name selected for publishing.
 */
public var selectedMicrophoneDevice:String=null;

/**
 * URL where video stores.
 */
public var videoPath:String;

/**
 * Class ID.
 */
public var classId:Number;

/**
 * Variable of 'MediaServerConnection'.
 */
public var ncVideoInsert:MediaServerConnection;

/**
 * Time in seconds at which video is to be inserted.
 */
public var insertVideoSec:Number;

/**
 * Time in minutes at which video is to be inserted.
 */
public var insertVideoMin:Number;

/**
 * Array containing the class details data.
 */
public var arClassDetails:Array=new Array();

/**
 * Reference of aviewplayer FileLoaderManager.
 */
public var fileLoadManager:FileLoaderManager;

/**
 * Path details of file inside the 'AVContent' folder.
 */
public var playbackContentPath:String;

/**
 * Playback URL path.
 */
public var playbackContentUrl:String;

/**
 * @private
 * Function calculates the inserting time, initializes the XML and calls functions for calculating the new XML values.
 *
 * @param void
 * @return void
 */
private function editingXMLValues():void{
	insertingTime=insertVideoMin * 60;
	insertingTime=(insertingTime + insertVideoSec) * 1000;
	
	newPttXml=new XML();
	newEndXml=new XML();
	newWhiteboardXml=new XML();
	newWbPointerXml=new XML();
	newDocPointerXml=new XML();
	newPresenterVideoXml=new XML();
	newChatXml=new XML();
	newViewerVideoXml=new XML();
	newDocumentXml=new XML();
	
	createFileTags();
	createNewPresenterVideoXMLValues();
	
	createNewViewerVideoXMLValues();
	
	createNewWbPointerValues();
	createNewDocPointerValues();
	createNewChatXMLValues();
	createNewPttValues();
	createNewDocValues();
	createNewWbValues();
	createNewEndTimeValues();
}

/**
 * @private
 * Function creates new XML tags for viewer video based on the inserting time.
 *
 * @param void
 * @return void
 */
// AKCR: please define a barebones json/object map and manipulate it. After that convert it to an XML document. This will help us port
// AKCR: the code across various wire formats
private function createNewViewerVideoXMLValues():void{
	var videoXMLEditionOver:Boolean=false;
	newViewerVideoXml=<viewer></viewer>;
	var tempVideoXml:XML=<viewer></viewer>;
	var tempXml:XML;
	// Loops through each viewer video xml tag for insertion.
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
		tempXml.@isAudioOnly=fileLoadManager.vVideoXml.video[i].@isAudioOnly;
		// Checks the xml tag stime and etime values is between insertingTime
		// If so, check the 'videoXMLEditionOver' for new xml tag added or not 
		// Change the etime to insertingTime and append the value also creates new tag for new video
		// else, adds recording time to stime and etime.
		if (Number(fileLoadManager.vVideoXml.video[i].@stime) <= insertingTime && Number(fileLoadManager.vVideoXml.video[i].@etime) >= insertingTime){
			if (!videoXMLEditionOver){
				videoXMLEditionOver=true;
				tempXml.@etime=insertingTime;
				newViewerVideoXml.appendChild(tempXml);
				
				tempXml=<video></video>;
				tempXml.@stime=insertingTime + recordingTime;
				tempXml.@uname=fileLoadManager.vVideoXml.video[i].@uname;
				tempXml.@displyname=fileLoadManager.vVideoXml.video[i].@displyname;
				tempXml.@src=fileLoadManager.vVideoXml.video[i].@src;
				tempXml.@etime=Number(fileLoadManager.vVideoXml.video[i].@etime) + recordingTime;
				tempXml.@seekStartValue=0;
				tempXml.@seekExist="true";
				tempXml.@seekTime=insertingTime / 1000;
				tempXml.@isAudioOnly=fileLoadManager.vVideoXml.video[i].@isAudioOnly;
				newViewerVideoXml.appendChild(tempXml);
			}
			else{
				tempXml.@stime=Number(tempXml.@stime) + recordingTime;
				tempXml.@etime=Number(tempXml.@etime) + recordingTime;
				newPresenterVideoXml.appendChild(tempXml);
			}
		}
			// Checks whether the stime is greater than inserting time
			// If so, changes the stime and appends the value.
		else if (i == 0 && Number(fileLoadManager.vVideoXml.video[i].@stime) > insertingTime){
			if (!videoXMLEditionOver){
				videoXMLEditionOver=true;
				tempXml=<video></video>;
				tempXml.@stime=Number(fileLoadManager.vVideoXml.video[i].@stime) + recordingTime;
				tempXml.@uname=fileLoadManager.vVideoXml.video[i].@uname;
				tempXml.@displyname=fileLoadManager.vVideoXml.video[i].@displyname;
				tempXml.@src=fileLoadManager.vVideoXml.video[i].@src;
				tempXml.@etime=Number(fileLoadManager.vVideoXml.video[i].@etime) + recordingTime;
				tempXml.@seekStartValue=fileLoadManager.vVideoXml.video[i].@seekStartValue;
				tempXml.@seekExist=fileLoadManager.vVideoXml.video[i].@seekExist;
				tempXml.@isAudioOnly=fileLoadManager.vVideoXml.video[i].@isAudioOnly;
				tempXml.@seekTime=fileLoadManager.vVideoXml.video[i].@seekTime;
				newViewerVideoXml.appendChild(tempXml);
			}
			
		}
			// Checks whether the stime is less than inserting time and next stime values is greater than inserting time.
			// If so, appends the value.
		else if (Number(fileLoadManager.vVideoXml.video[i].@stime) <= insertingTime && ((i + 1) != fileLoadManager.vVideoXml.video.length()) && Number(fileLoadManager.vVideoXml.video[(i + 1)].@stime) >= insertingTime){
			if (!videoXMLEditionOver){
				videoXMLEditionOver=true;
				newViewerVideoXml.appendChild(tempXml);
			}
		}
			// Checks for last tag
			// If so, appends the value.
		else if ((i + 1) == fileLoadManager.vVideoXml.video.length() && Number(fileLoadManager.vVideoXml.video[i].@etime) < insertingTime){
			if (!videoXMLEditionOver){
				videoXMLEditionOver=true;
				newViewerVideoXml.appendChild(tempXml);
			}
		}
			// Increase the stime and etime for rest of tags
		else{
			if (Number(tempXml.@stime) > insertingTime){
				tempXml.@stime=Number(tempXml.@stime) + recordingTime;
			}
			if (Number(tempXml.@etime) > insertingTime){
				tempXml.@etime=Number(tempXml.@etime) + recordingTime;
			}
			newViewerVideoXml.appendChild(tempXml);
		}
	}
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}


/**
 * @private
 * Function creates new XML tags for presenter video based on the inserting time.
 *
 * @param void
 * @return void
 */
private function createNewPresenterVideoXMLValues():void{
	var videoXMLEditionOver:Boolean=false;
	newPresenterVideoXml=<presenter></presenter>;
	var tempVideoXml:XML=<presenter></presenter>;
	var tempXml:XML;
	if (fileLoadManager.pVideoXml.hasOwnProperty("video")){
		// Loops through each viewer video xml tag for insertion.
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
			tempXml.@isAudioOnly=fileLoadManager.pVideoXml.video[i].@isAudioOnly;
			// Checks the xml tag stime and etime values is between insertingTime
			// If so, check the 'videoXMLEditionOver' for new xml tag added or not 
			// Change the etime to insertingTime and append the value also creates new tag for new video
			// else, adds recording time to stime and etime.
			if (Number(fileLoadManager.pVideoXml.video[i].@stime) <= insertingTime && Number(fileLoadManager.pVideoXml.video[i].@etime) >= insertingTime){
				if (!videoXMLEditionOver){
					videoXMLEditionOver=true;
					tempXml.@etime=insertingTime;
					newPresenterVideoXml.appendChild(tempXml);
					
					tempXml=<video></video>;
					tempXml.@stime=insertingTime;
					tempXml.@uname=fileLoadManager.pVideoXml.video[i].@uname;
					tempXml.@displyname=fileLoadManager.pVideoXml.video[i].@displyname;
					tempXml.@src=streamName;
					tempXml.@etime=insertingTime + recordingTime;
					tempXml.@seekStartValue=fileLoadManager.pVideoXml.video[i].@seekStartValue;
					tempXml.@seekExist=fileLoadManager.pVideoXml.video[i].@seekExist;
					tempXml.@seekTime=fileLoadManager.pVideoXml.video[i].@seekTime;
					if (isAudioOnlyOptionSelected)
						tempXml.@isAudioOnly="true";
					newPresenterVideoXml.appendChild(tempXml);
					
					if (fileLoadManager.pVideoXml.video[i].@etime > insertingTime){
						tempXml=<video></video>;
						tempXml.@stime=insertingTime + recordingTime;
						tempXml.@uname=fileLoadManager.pVideoXml.video[i].@uname;
						tempXml.@displyname=fileLoadManager.pVideoXml.video[i].@displyname;
						tempXml.@src=fileLoadManager.pVideoXml.video[i].@src;
						tempXml.@isAudioOnly=fileLoadManager.pVideoXml.video[i].@isAudioOnly;
						tempXml.@etime=Number(fileLoadManager.pVideoXml.video[i].@etime) + recordingTime;
						tempXml.@seekStartValue=0;
						tempXml.@seekExist="true";
						tempXml.@seekTime=insertingTime / 1000;
						newPresenterVideoXml.appendChild(tempXml);
					}
				}
				else{
					tempXml.@stime=Number(tempXml.@stime) + recordingTime;
					tempXml.@etime=Number(tempXml.@etime) + recordingTime;
					newPresenterVideoXml.appendChild(tempXml);
				}
				
				
			}
				// Checks whether the stime is greater than inserting time
				// If so, changes the stime and appends the value.
			else if (i == 0 && Number(fileLoadManager.pVideoXml.video[i].@stime) > insertingTime){
				if (!videoXMLEditionOver){
					videoXMLEditionOver=true;
					tempXml=<video></video>;
					tempXml.@stime=insertingTime;
					tempXml.@uname=ClassroomContext.userVO.userName;
					tempXml.@displyname=ClassroomContext.userVO.userDisplayName;
					tempXml.@src=streamName;
					tempXml.@etime=recordingTime;
					if (isAudioOnlyOptionSelected)
						tempXml.@isAudioOnly="true";
					newPresenterVideoXml.appendChild(tempXml);
					
					tempXml=<video></video>;
					tempXml.@stime=Number(fileLoadManager.pVideoXml.video[i].@stime) + recordingTime;
					tempXml.@uname=fileLoadManager.pVideoXml.video[i].@uname;
					tempXml.@displyname=fileLoadManager.pVideoXml.video[i].@displyname;
					tempXml.@src=fileLoadManager.pVideoXml.video[i].@src;
					tempXml.@etime=Number(fileLoadManager.pVideoXml.video[i].@etime) + recordingTime;
					tempXml.@seekStartValue=fileLoadManager.pVideoXml.video[i].@seekStartValue;
					tempXml.@seekExist=fileLoadManager.pVideoXml.video[i].@seekExist;
					tempXml.@isAudioOnly=fileLoadManager.pVideoXml.video[i].@isAudioOnly;
					tempXml.@seekTime=fileLoadManager.pVideoXml.video[i].@seekTime;
					newPresenterVideoXml.appendChild(tempXml);
				}
			}
				// Checks whether the stime is less than inserting time and next stime values is greater than inserting time.
				// If so, appends the value.
			else if (Number(fileLoadManager.pVideoXml.video[i].@stime) <= insertingTime && ((i + 1) != fileLoadManager.pVideoXml.video.length()) && Number(fileLoadManager.pVideoXml.video[(i + 1)].@stime) >= insertingTime){
				if (!videoXMLEditionOver){
					videoXMLEditionOver=true;
					newPresenterVideoXml.appendChild(tempXml);
					
					tempXml=<video></video>;
					tempXml.@stime=insertingTime;
					tempXml.@uname=ClassroomContext.userVO.userName;
					tempXml.@displyname=ClassroomContext.userVO.userDisplayName;
					tempXml.@src=streamName;
					tempXml.@etime=insertingTime + recordingTime;
					if (isAudioOnlyOptionSelected)
						tempXml.@isAudioOnly="true";
					newPresenterVideoXml.appendChild(tempXml);
				}
			}
				// Checks for last tag
				// If so, appends the value.
			else if ((i + 1) == fileLoadManager.pVideoXml.video.length() && Number(fileLoadManager.pVideoXml.video[i].@etime) < insertingTime){
				if (!videoXMLEditionOver){
					videoXMLEditionOver=true;
					newPresenterVideoXml.appendChild(tempXml);
					
					tempXml=<video></video>;
					tempXml.@stime=insertingTime;
					tempXml.@uname=ClassroomContext.userVO.userName;
					tempXml.@displyname=ClassroomContext.userVO.userDisplayName;
					tempXml.@src=streamName;
					tempXml.@etime=insertingTime + recordingTime;
					if (isAudioOnlyOptionSelected)
						tempXml.@isAudioOnly="true";
					newPresenterVideoXml.appendChild(tempXml);
				}
			}
				// Increase the stime and etime for rest of tags
			else{
				if (Number(tempXml.@stime) > insertingTime){
					tempXml.@stime=Number(tempXml.@stime) + recordingTime;
				}
				if (Number(tempXml.@etime) > insertingTime){
					tempXml.@etime=Number(tempXml.@etime) + recordingTime;
				}
				newPresenterVideoXml.appendChild(tempXml);
			}
		}
	}
	else{
		tempXml=<video></video>;
		tempXml.@stime=insertingTime;
		tempXml.@uname=ClassroomContext.userVO.userName;
		tempXml.@displyname=ClassroomContext.userVO.userDisplayName;
		tempXml.@src=streamName;
		tempXml.@etime=recordingTime;
		if (isAudioOnlyOptionSelected)
			tempXml.@isAudioOnly="true";
		newPresenterVideoXml.appendChild(tempXml);
	}
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function creates new XML tags for whiteboard pointer based on the inserting time.
 *
 * @param void
 * @return void
 */
private function createNewWbPointerValues():void{
	newWbPointerXml=<pointer></pointer>;
	// Loops through each viewer video xml tag for insertion.
	for (var i:int=0; i < fileLoadManager.wbPointerXml.event.length(); i++){
		var tempXml:XML=<event></event >;
		tempXml.@ctime=fileLoadManager.wbPointerXml.event[i].@ctime;
		tempXml.@x=fileLoadManager.wbPointerXml.event[i].@x;
		tempXml.@y=fileLoadManager.wbPointerXml.event[i].@y;
		tempXml.@cwidth=fileLoadManager.wbPointerXml.event[i].@cwidth;
		tempXml.@cheight=fileLoadManager.wbPointerXml.event[i].@cheight;
		tempXml.@container=fileLoadManager.wbPointerXml.event[i].@container;
		//Checks the ctime is greater than insertingTime
		// If so, adds the recordingTime and appends
		if (Number(fileLoadManager.wbPointerXml.event[i].@ctime) > insertingTime)
			tempXml.@ctime=Number(tempXml.@ctime) + recordingTime;
		newWbPointerXml.appendChild(tempXml);
	}
	
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function creates new XML tags for document pointer based on the inserting time.
 *
 * @param void
 * @return void
 */
private function createNewDocPointerValues():void{
	newDocPointerXml=<pointer></pointer>;
	// Loops through each viewer video xml tag for insertion.
	for (var i:int=0; i < fileLoadManager.docPointerXml.event.length(); i++){
		var tempXml:XML=<event></event >;
		tempXml.@ctime=fileLoadManager.docPointerXml.event[i].@ctime;
		tempXml.@x=fileLoadManager.docPointerXml.event[i].@x;
		tempXml.@y=fileLoadManager.docPointerXml.event[i].@y;
		tempXml.@cwidth=fileLoadManager.docPointerXml.event[i].@cwidth;
		tempXml.@cheight=fileLoadManager.docPointerXml.event[i].@cheight;
		tempXml.@container=fileLoadManager.docPointerXml.event[i].@container;
		//Checks the ctime is greater than insertingTime
		// If so, adds the recordingTime and appends
		if (Number(fileLoadManager.docPointerXml.event[i].@ctime) > insertingTime)
			tempXml.@ctime=Number(tempXml.@ctime) + recordingTime;
		newDocPointerXml.appendChild(tempXml);
	}
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function creates new XML tags for chat based on the inserting time.
 *
 * @param void
 * @return void
 */
private function createNewChatXMLValues():void{
	newChatXml=<chat></chat>;
	// Loops through each viewer video xml tag for insertion.
	for (var i:int=0; i < fileLoadManager.chatXml.msg.length(); i++){
		var tempXml:XML=<msg></msg>;
		tempXml.@ctime=fileLoadManager.chatXml.msg[i].@ctime;
		tempXml.@content=fileLoadManager.chatXml.msg[i].@content;
		tempXml.@textSize=fileLoadManager.chatXml.msg[i].@textSize;
		//Checks the ctime is greater than insertingTime
		// If so, adds the recordingTime and appends
		if (tempXml.@ctime >= insertingTime)
			tempXml.@ctime=Number(tempXml.@ctime) + recordingTime;
		newChatXml.appendChild(tempXml);
	}
	
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function creates new XML tags for ptt based on the inserting time.
 *
 * @param void
 * @return void
 */
private function createNewPttValues():void{
	newPttXml=<ptt></ptt>;
	var inBetweenTimeLine:Boolean=false;
	var lastStatus:String="";
	var tempXml1:XML;
	// Loops through each viewer video xml tag for insertion.
	for (var i:int=0; i < fileLoadManager.pttXml.state.length(); i++){
		var tempXml:XML=<state></state >;
		tempXml.@ctime=fileLoadManager.pttXml.state[i].@ctime;
		tempXml.@state=fileLoadManager.pttXml.state[i].@state;
		//Checks the ctime is greater than insertingTime
		// If so, for the first tag add freetalk
		if (tempXml.@ctime > insertingTime){
			inBetweenTimeLine=true;
			if (inBetweenTimeLine){
				inBetweenTimeLine=false;
				tempXml1=<state></state >;
				tempXml1.@ctime=insertingTime;
				tempXml1.@state=Constants.FREETALK;
				newPttXml.appendChild(tempXml1);
				
				tempXml1=<state></state >;
				tempXml1.@ctime=insertingTime + recordingTime;
				tempXml1.@state=fileLoadManager.pttXml.state[i - 1].@state;
				newPttXml.appendChild(tempXml1);
			}
			tempXml.@ctime=Number(tempXml.@ctime) + recordingTime;
		}
		
		newPttXml.appendChild(tempXml);
	}
	
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function creates new XML tags for document based on the inserting time.
 *
 * @param void
 * @return void
 */
// AKCR: there is heavy nesting of FOR & IF. Please reconsider the datastructure and use some light weight protocol such as JSON or object map
private function createNewDocValues():void{
	newDocumentXml=<document></document>;
	var tempZoom:XML=<event action="zoom"></event>;
	var tempPage:XML=<event action="page"></event>;
	var tempRotation:XML=<event action="rotation" value="0"></event>;
	var tempScroll:XML=<event action="scroll" scrollDirction="vertical" scrollPosition="0"></event>;
	var tempAnimation:XML=<event action="animation"></event>;
	var boolEndTime:Boolean=false;
	var tempDocloaded:XML;
	var tempXml:XML;
	var tempSize:XML;
	for (var i:int=0; i < fileLoadManager.docXml.docloaded.length(); i++){
		if (fileLoadManager.docXml.docloaded[i].@ctime < insertingTime && i != (fileLoadManager.docXml.docloaded.length() - 1) && fileLoadManager.docXml.docloaded[(i + 1)].@ctime < insertingTime){
			tempXml=fileLoadManager.docXml.docloaded[i];
			newDocumentXml.appendChild(tempXml);
			continue;
		}
		
		tempDocloaded=<docloaded></docloaded>;
		tempDocloaded.@ctime=fileLoadManager.docXml.docloaded[i].@ctime;
		tempDocloaded.@src=fileLoadManager.docXml.docloaded[i].@src;
		tempDocloaded.@type=fileLoadManager.docXml.docloaded[i].@type;
		tempDocloaded.@orginalName=fileLoadManager.docXml.docloaded[i].@orginalName;
		newDocumentXml.appendChild(tempDocloaded);
		if (i == 0 && fileLoadManager.docXml.docloaded[i].@ctime > insertingTime){
			tempDocloaded.@ctime=recordingTime;
		}
		
		for (var j:int=0; j < fileLoadManager.docXml.docloaded[i].size.length(); j++){
			if (fileLoadManager.docXml.docloaded[i].size[j].@ctime < insertingTime && j != (fileLoadManager.docXml.docloaded[i].size.length() - 1) && fileLoadManager.docXml.docloaded[i].size[(j + 1)].@ctime < insertingTime){
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
			
			if (j == 0 && fileLoadManager.docXml.docloaded[i].size[j].@ctime > insertingTime){
				tempSize.@ctime=recordingTime;
			}
			
			for (var k:int=0; k < fileLoadManager.docXml.docloaded[i].size[j].event.length(); k++){
				if (fileLoadManager.docXml.docloaded[i].size[j].event[k].@ctime < insertingTime){
					tempXml=fileLoadManager.docXml.docloaded[i].size[j].event[k];
					tempSize.appendChild(tempXml);
				}
				else{
					break;
				}
			}
			
			for (var tempi:int=0; tempi < fileLoadManager.docXml.docloaded.length(); tempi++){
				if (fileLoadManager.docXml.docloaded[tempi].@ctime < insertingTime && tempi != (fileLoadManager.docXml.docloaded.length() - 1) && fileLoadManager.docXml.docloaded[(tempi + 1)].@ctime < insertingTime){
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
					if (fileLoadManager.docXml.docloaded[tempi].size[tempj].@ctime < insertingTime && tempj != (fileLoadManager.docXml.docloaded[tempi].size.length() - 1) && fileLoadManager.docXml.docloaded[tempi].size[(tempj + 1)].@ctime < insertingTime){
						continue;
					}
					for (var tempk:int=0; tempk < fileLoadManager.docXml.docloaded[tempi].size[tempj].event.length(); tempk++){
						if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime < insertingTime){
							continue;
						}
						
						if (fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk].@ctime > insertingTime){
							if (tempi != i){
								i=tempi;
								tempDocloaded.@ctime=Number(fileLoadManager.docXml.docloaded[tempi].@ctime) + recordingTime;
								tempDocloaded.@src=fileLoadManager.docXml.docloaded[tempi].@src;
								tempDocloaded.@type=fileLoadManager.docXml.docloaded[tempi].@type;
								tempDocloaded.@orginalName=fileLoadManager.docXml.docloaded[tempi].@orginalName;
								newDocumentXml.appendChild(tempDocloaded);
								
								j=tempj;
								tempSize.@ctime=Number(fileLoadManager.docXml.docloaded[tempi].size[tempj].@ctime) + recordingTime;
								tempSize.@maxx=fileLoadManager.docXml.docloaded[tempi].size[tempj].@maxx;
								tempSize.@maxy=fileLoadManager.docXml.docloaded[tempi].size[tempj].@maxy;
								tempSize.@width=fileLoadManager.docXml.docloaded[tempi].size[tempj].@width;
								tempSize.@height=fileLoadManager.docXml.docloaded[tempi].size[tempj].@height;
								tempSize.@zoomfactorX=fileLoadManager.docXml.docloaded[tempi].size[tempj].@zoomfactorX;
								tempSize.@zoomfactorY=fileLoadManager.docXml.docloaded[tempi].size[tempj].@zoomfactorY;
								tempDocloaded.appendChild(tempSize);
							}
							tempXml=fileLoadManager.docXml.docloaded[tempi].size[tempj].event[tempk];
							tempXml.@ctime=Number(tempXml.@ctime) + recordingTime;
							tempSize.appendChild(tempXml);
						}
					}
				}
				i=tempi;
				j=tempj;
			}
		}
	}
	
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function creates new XML tags for whiteboard based on the inserting time.
 *
 * @param void
 * @return void
 */
// AKCR: there is too much nesting here again. Please reconsider re-writing this code
private function createNewWbValues():void{
	newWhiteboardXml=<wb></wb>;
	var boolEndTime:Boolean=false;
	var tempXml:XML;
	var tempSize:XML;
	var tempPage:XML;
	for (var i:int=0; i < fileLoadManager.wbXml.page.length(); i++){
		if (fileLoadManager.wbXml.page[i].@ctime < insertingTime && i != (fileLoadManager.wbXml.page.length() - 1) && fileLoadManager.wbXml.page[(i + 1)].@ctime < insertingTime){
			tempXml=fileLoadManager.wbXml.page[i];
			newWhiteboardXml.appendChild(tempXml);
			continue;
		}
		
		tempPage=<page></page>;
		tempPage.@ctime=fileLoadManager.wbXml.page[i].@ctime;
		tempPage.@num=fileLoadManager.wbXml.page[i].@num;
		newWhiteboardXml.appendChild(tempPage);
		if (i == 0 && fileLoadManager.wbXml.page[i].@ctime > insertingTime){
			tempPage.@ctime=recordingTime;
		}
		
		for (var j:int=0; j < fileLoadManager.wbXml.page[i].size.length(); j++){
			if (fileLoadManager.wbXml.page[i].size[j].@ctime < insertingTime && j != (fileLoadManager.wbXml.page[i].size.length() - 1) && fileLoadManager.wbXml.page[i].size[(j + 1)].@ctime < insertingTime){
				tempXml=fileLoadManager.wbXml.page[i].size[j];
				tempPage.appendChild(tempXml);
				continue;
			}
			
			tempSize=<size></size>;
			tempSize.@ctime=fileLoadManager.wbXml.page[i].size[j].@ctime;
			tempSize.@width=fileLoadManager.wbXml.page[i].size[j].@width;
			tempSize.@height=fileLoadManager.wbXml.page[i].size[j].@height;
			tempPage.appendChild(tempSize);
			
			if (j == 0 && fileLoadManager.wbXml.page[i].size[j].@ctime > insertingTime){
				tempSize.@ctime=recordingTime;
			}
			
			for (var k:int=0; k < fileLoadManager.wbXml.page[i].size[j].shape.length(); k++){
				if (fileLoadManager.wbXml.page[i].size[j].shape[k].@ctime < insertingTime){
					tempXml=fileLoadManager.wbXml.page[i].size[j].shape[k];
					tempSize.appendChild(tempXml);
				}
				else{
					break;
				}
			}
			
			for (var tempi:int=0; tempi < fileLoadManager.wbXml.page.length(); tempi++){
				if (fileLoadManager.wbXml.page[tempi].@ctime < insertingTime && tempi != (fileLoadManager.wbXml.page.length() - 1) && fileLoadManager.wbXml.page[(tempi + 1)].@ctime < insertingTime){
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
					if (fileLoadManager.wbXml.page[tempi].size[tempj].@ctime < insertingTime && tempj != (fileLoadManager.wbXml.page[tempi].size.length() - 1) && fileLoadManager.wbXml.page[tempi].size[(tempj + 1)].@ctime < insertingTime){
						continue;
					}
					for (var tempk:int=0; tempk < fileLoadManager.wbXml.page[tempi].size[tempj].shape.length(); tempk++){
						if (fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk].@ctime < insertingTime){
							continue;
						}
						
						if (fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk].@ctime >= insertingTime){
							var tempValue:XML=fileLoadManager.wbXml.page[tempi].size[tempj].shape[tempk];
							tempValue.@ctime=Number(tempValue.@ctime) + recordingTime;
							if (tempi != i){
								i=tempi;
								tempPage.@ctime=Number(fileLoadManager.wbXml.page[tempi].@ctime) + recordingTime;
								tempPage.@num=fileLoadManager.wbXml.page[tempi].@num;
								newWhiteboardXml.appendChild(tempPage);
								
								tempSize.@ctime=Number(fileLoadManager.wbXml.page[tempi].size[tempj].@ctime) + recordingTime;
								tempSize.@width=fileLoadManager.wbXml.page[tempi].size[tempj].@width;
								tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
								tempSize.@height=fileLoadManager.wbXml.page[tempi].size[tempj].@height;
								tempPage.appendChild(tempSize);
							}
							tempSize.appendChild(tempValue);
						}
					}
				}
				i=tempi;
			}
		}
	}
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 * @private
 * Function for initializing the file and filestreams for each module.
 *
 * @param void
 * @return void
 */
// AKCR: please move the constants out of this file into a shared configuration
private function createFileTags():void{
	applicationType::desktop{
		/* File and FileStream not available for web.*/
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
 * Function creates new XML tags for endtime based on the inserting time.
 *
 * @param void
 * @return void
 */
private function createNewEndTimeValues():void{
	newEndXml=<time></time>;
	var tempNum:Number=fileLoadManager.endTimeXml.etime;
	newEndXml.etime=tempNum + recordingTime;
	
	xmlFileCreationCOunt++;
	createBackUpFilesServerSide();
}

/**
 *
 * @private
 * Function for calling the corresponding PHP
 * for taking a back up of the orginal folder.
 *
 * @param void
 * @return void
 */
private function createBackUpFilesServerSide():void{
	if (xmlFileCreationCOunt == TOTAL_FILES){
		var backUpServerFiles:HTTPService=new HTTPService();
		// AKCR: hard coded string should be moved to a constants file to avoid duplication
		var tempUrl:String=playbackContentUrl + "/AVScript/Editing/backup.php?recordingFolderPath=" + playbackContentPath;
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
 * @param event of ResultEvent
 * @return void
 */
private function serverSideBackUpCreated(event:ResultEvent):void{
	applicationType::desktop{
		/* File and FileStream not available for web.*/
		saveAndUpload(wbFile, wbFileStream, newWhiteboardXml.toXMLString());
		saveAndUpload(docFile, docFileStream, newDocumentXml.toXMLString());
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
	/*File and FileStream not available for web.*/
	private function saveAndUpload(tempFile:File, tempFileStream:FileStream, tempXml:String):void{
		tempFileStream.open(tempFile, FileMode.WRITE);
		tempFileStream.writeUTFBytes("<?xml version=\"1.0\" encoding=\"utf-8\"?>" + tempXml);
		tempFileStream.close();
		var url:String=playbackContentUrl + "/AVScript/Common/upload.php?folderPath=" + playbackContentPath;
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
	numFileUpload++;
	if (numFileUpload == TOTAL_FILES){
		numFileUpload=0;
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
	Alert.show("Video Inserting in Recorded files failed", "INFO");
	cancelRecording();
}

/**
 * @private
 * Function assigns values for camer and microphone drivers.
 *
 * @param void
 * @return void
 */
private function initVideoRecordComponent():void{
	ipFMS=new Array();
	classHelper=new ClassHelper();
	classHelper.getClassByID(classId,getClassByIDResultHandler);
	videoCodec=null;
	ipFMS=videoPath.split("/");
	createConnection();
	try{
		// AKCR: can the following 2 IF conditions be combined using AND operator?
		if (Capabilities.os.toLowerCase().indexOf("win") > -1){
			if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag){
				scanHardware();
			}
		}
	}
	catch (e:Error){
		if(Log.isError()) logger.error("Error in initVideoRecordComponent method in VideoRecordComponentScript:"+ e.getStackTrace());
	}
	arCameraDriverNames=Camera.names;
	//Exclude known desktop capturing drivers like 'Screencamera' and 'UscreenCapture' from the video driver list.
	for (var i:int=0; i < arCameraDriverNames.length; i++){
		if (arCameraDriverNames[i] == "UScreenCapture" || arCameraDriverNames[i] == "ScreenCamera HR" || arCameraDriverNames[i] == "ScreenCamera Video Camera" || arCameraDriverNames[i] == "ScreenCamera IM Device")
			arCameraDriverNames.splice(i, 1);
	}
	arMicroPhoneDriverNames=Microphone.names;
	cmbCameraSelect.dataProvider=arCameraDriverNames;
	cmbMicSelect.dataProvider=arMicroPhoneDriverNames;
}

/**
 * @private
 * Function establishes connection with the FMS server.
 *
 * @param void
 * @return void
 */
public function createConnection():void{
	var tempDate:Date=new Date();
	aviewClassName="VideoEditing" + "_" + tempDate.time.toString();
	userName=ClassroomContext.userVO.userName; //;+ "" + tempDate.time.toString();

	var connectionParams:ArrayList = new ArrayList();
	connectionParams.addItem(userName);
	connectionParams.addItem(ClassroomContext.userDetails);
	connectionParams.addItem(ClassroomContext.hardwareAddress);

	ncVideoInsert=new MediaServerConnection(videoPath,Constants.VIDEO_SERVER_MODULE_NAME,aviewClassName,connectionParams,this);
	ncVideoInsert.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, netStatusHandler);
	ncVideoInsert.initialize();
}

/**
 * @private
 * Callback function from server after the video publish to server.
 * Calls the server function for recording the stream.
 *
 * @param callBackStreamName of type String - Stream name
 * @return void
 */
public function startedStream(callBackStreamName:String):void{
	var tempDate:Date=new Date();
	videoStartTime=new Date();
	var isF4V:Boolean=(videoCodec == Constants.CODEC_H264);
	var extenstion:String;
	// AKCR: please use the conditional operator here
	if (isF4V)
		extenstion=".f4v";
	else
		extenstion=".flv";
	streamName=userName + tempDate.time + extenstion;
	if (Log.isDebug()) logger.debug("Calling server side method for recording. Stream : " + userName);
	ncVideoInsert.netConnection.call("recordStream", null, "true", userName, streamName, null, isF4V);
}

/**
 * @public
 * Callback function from server.
 * Because using the same server code of AVIEW video module a blank function is needed.
 *
 * @param obj of type Object
 * @return void
 */
public function recordingStatus(obj:Object):void{
}

/**
 * @public
 * Callback function from server.
 * Because using the same server code of AVIEW video module a blank function is needed.
 *
 * @param temString of type String
 * @param tempValue of type int
 * @return void
 */
public function stoppedStream(temString:String, tempValue:int):void{
	
}

/**
 * @private
 * Function for handling the netstatus events.
 *
 * @param event of type MediaServerStatusEvent
 * @return void
 */
private function netStatusHandler(event:MediaServerStatusEvent):void{
	var netConnectionStatus:String=event.code;
	switch (netConnectionStatus){
		case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
			
			AuditContext.userAction.connectionSuccessEventLog("VideoEditing", fmsURL, null);
			btnStart.enabled=true;
			
			break;
		
		case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
			AuditContext.userAction.connectionRejectEventLog("VideoEditing", fmsURL);
			break;
		
		case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
			AuditContext.userAction.connectionCloseEventLog("VideoEditing", fmsURL);
			break;
		
		case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
			AuditContext.userAction.connectionFailEventLog("VideoEditing", fmsURL);
			break;
		default:
			
			break;
	}
}

/**
 * @private
 * Function for handling the netstatus error events.
 *
 * @param event of type AsyncErrorEvent
 * @return void
 */
private function asyncError(event:AsyncErrorEvent):void{
	
}

/**
 * @public
 * Result handler for getting the class details from server.
 *
 * @param event of type AsyncErrorEvent
 * @return void
 */
public function getClassByIDResultHandler(classVO:ClassVO):void{
	videoCodec=classVO.videoCodec.toString();
	if (videoCodec == Constants.CODEC_VP6){
		FlexGlobals.topLevelApplication.mainApp.findScreenCameraInstallationPath();
		rbgAudioOption.enabled=false;
	}
}

/**
 * @private
 * Function closes the socket and netstream.
 * Dispatches the cancel event.
 *
 * @param void
 * @return void
 */
private function cancelRecording():void{
	if (socketRunning){
		socketCommand="quit";
		socket.connect("127.0.0.1", 9126);
	}
	if (nsPublish)
		nsPublish.close();
	if (videoLocalPlaying)
		videoLocalPlaying.attachCamera(null);
	PopUpManager.removePopUp(this);
	this.dispatchEvent(new CloseFileHandler(CloseFileHandler.CLOSED_VIDEO_EDITING_CANCEL));
}

/**
 * @private
 * Function recalls the 'initVideoRecordComponent' function while refresh button click.
 *
 * @param void
 * @return void
 */
private function refresh():void{
	initVideoRecordComponent();
}

/**
 * @private
 * Function checks the availability of camera and microphone drivers.
 *
 * @param void
 * @return void
 */
private function startVideo():void{
	if (arCameraDriverNames.length == 0 && arMicroPhoneDriverNames.length == 0){
		Alert.show("No Camera\Audio Devices Detected!\nPlease check your Camera\Audio Devices", "   Hardware Error", Alert.OK, this);
	}
	else if (arCameraDriverNames.length == 0){
		Alert.show("No Camera Detected!\nPlease plugin a Camera & refresh the Application", "   Hardware Error", Alert.OK, this);
	}
	else if (arMicroPhoneDriverNames.length == 0){
		Alert.show("No Audio Devices Detected!\nPlease check your audio devices", "   Hardware Error", Alert.OK, this);
	}
	else{
		// Check if recording is not started.
		// Calls corresponding function for publishing based on codec.
		// Enables timer for showing the time taken for recording.
		if (btnStart.label == "Start"){
			cmbCameraSelect.enabled=false;
			cmbMicSelect.enabled=false;
			cmbBandwidthSelect.enabled=false;
			btnRefresh.enabled=false;
			btnStart.label="Stop";
			selectedBandwidth=parseInt(cmbBandwidthSelect.text);
			selectedCameraDevice=cmbCameraSelect.selectedItem.toString();
			selectedMicrophoneDevice=cmbMicSelect.selectedItem.toString();
			startLocalVideo();
			if (videoCodec == Constants.CODEC_VP6){
				setVP6Parameters(selectedBandwidth);
				publishVP6Video();
			}
			else if (videoCodec == Constants.CODEC_SORENSON){
				setSorensonParameters(selectedBandwidth);
				publishSorensonVideo();
			}
			else{
				setH264Parameters(selectedBandwidth);
				publishH264Video();
			}
			
			lblRecordingTime.visible=true;
			recordingTimer=new Timer(1000);
			recordingTimer.addEventListener(TimerEvent.TIMER, videoRecordingTime);
			recordingTimer.start();
		}
			// Stops recording after 3 seconds, since delay in streaming.
		else{
			recordingMessageBox=MessageBox.show("Please wait while recorded lecture is getting saved", "Recording", null, this);
			videoEndTime=new Date();
			stopRecordingTimer=new Timer(3000, 1);
			stopRecordingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, initiateStopRecording);
			stopRecordingTimer.start();
			
			recordingTimer.stop();
			recordingTimer.removeEventListener(TimerEvent.TIMER, videoRecordingTime);
		}
	}
}

/**
 * @private
 * Function calls PHP for copying the video file to VOD folder.
 *
 * @param event of type TimerEvent
 * @return void
 */
private function initiateStopRecording(event:TimerEvent):void{
	PopUpManager.removePopUp(recordingMessageBox);
	sourceFileName="";
	var isF4V:Boolean=(videoCodec == Constants.CODEC_H264);
	// AKCR: please use conditional operator
	if (isF4V)
		sourceFileName=userName + ".f4v";
	else
		sourceFileName=userName + ".flv";
	
	videoFileCopyService=new HTTPService();
	var tempFolderPath:String=arClassDetails[0] + "/" + arClassDetails[1] + "/" + arClassDetails[2] + "/" + arClassDetails[3];
	// AKCR: please move the hard-coded string to the constants file
	videoFileCopyService.url=encodeURI("http://" + ipFMS[2] + ":" + ClassroomContext.portWAMP + "/AVScript/Record/copyVideoFile.php?sourceFile=" + sourceFileName + "&destinationFile=" + streamName + "&folderPath=" + tempFolderPath + "&classname=" + aviewClassName);
	videoFileCopyService.send();
	videoFileCopyService.addEventListener(ResultEvent.RESULT, videoCopyResultHandler);
	videoFileCopyService.addEventListener(FaultEvent.FAULT, videoCopyFaultHandler);
	
	btnStart.label="Start";
	
	stopRecordingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, initiateStopRecording);
	stopRecordingTimer.stop();
}

/**
 * @private
 * Function updates the recording time in one second interval
 *
 * @param event of type TimerEvent
 * @return void
 */
private function videoRecordingTime(event:TimerEvent):void{
	recordingTimeSeconds++;
	if (recordingTimeSeconds > 59){
		recordingTimeSeconds=00;
		recordingTimeMinutes++;
	}
	if (recordingTimeMinutes > 59){
		recordingTimeMinutes=00;
		recordingTimeHour++;
	}
	
	var tSec:String=String(recordingTimeSeconds);
	var tMin:String=String(recordingTimeMinutes);
	var tHr:String=String(recordingTimeHour);
	
	if (tSec.length == 1)
		tSec="0" + tSec;
	if (tMin.length == 1)
		tMin="0" + tMin;
	if (tHr.length == 1)
		tHr="0" + tHr;
	
	lblRecordingTime.text=tHr + " : " + tMin + " : " + tSec;
}

/**
 * @private
 * Result event of 'videoFileCopyService'.
 *
 * @param event of type ResultEvent
 * @return void
 */
private function videoCopyResultHandler(event:ResultEvent):void{
	stopRecording();
	
	
	recordingTime=videoEndTime.time - videoStartTime.time;
	editingXMLValues();
	if(Log.isInfo()) logger.info(""+recordingTime);
}

/**
 * @private
 * Fault event of 'videoFileCopyService'.
 *
 * @param void
 * @return void
 */
private function stopRecording():void{
	var isF4V:Boolean=(videoCodec == Constants.CODEC_H264);
	var extenstion:String;
	// AKCR: use conditional operator
	if (isF4V)
		extenstion=".f4v";
	else
		extenstion=".flv";
	
	ncVideoInsert.netConnection.call("stopRecordStream", null, userName, isF4V);
	
	if (socketRunning){
		socketCommand="quit";
		socket.connect("127.0.0.1", 9126);
	}
	if (nsPublish)
		nsPublish.close();
}

/**
 * @private
 * Function calls the server function for stopping the recording.
 * Closes the netstream.
 *
 * @param void
 * @return void
 */
private function videoCopyFaultHandler(event:FaultEvent):void{
	if(Log.isError()) logger.error("playback::editing::scripts::VideoRecordComponentScript::videoCopyFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	Alert.show("Recording Error", "Video");
	stopRecording();
	
}

/**
 * @private
 * Function uses the h264 class for publishing.
 * Attaches the camera, micrphone object and publish to server.
 *
 * @param void
 * @return void
 */
private function publishH264Video():void{
	var h264Codec:H264VideoStreamSettings=new H264VideoStreamSettings();
	nsPublish=new NetStream(ncVideoInsert.netConnection);
	
	microPhoneObj=Microphone.getEnhancedMicrophone(microPhoneIndex);
	microPhoneObj.codec=SoundCodec.SPEEX;
	microPhoneObj.setUseEchoSuppression(true);
	microPhoneObj.gain=75;
	nsPublish.attachAudio(microPhoneObj);
	if (!isAudioOnlyOptionSelected){
		h264Codec.setProfileLevel(H264Profile.BASELINE, "3");
		nsPublish.videoStreamSettings=h264Codec;
		cameraObj=Camera.getCamera(cameraIndex.toString());
		cameraObj.setQuality(videoBandwidth, videoQuality);
		cameraObj.setMode(videoCaptureWidth, videoCaptureHeight, fps);
		nsPublish.attachCamera(cameraObj);
	}
	nsPublish.publish(userName);
}


/**
 * @private
 * Function finds the camera and microphone driver index and starts playing.
 *
 * @param void
 * @return void
 */
private function startLocalVideo():void{
	var tempCameraNames:Array=Camera.names;
	videoLocalPlaying=new Video();
	videoLocalDisplay=new VideoDisplay();
	videoLocalDisplay.width=hbxVideoDisplay.width;
	videoLocalDisplay.height=hbxVideoDisplay.height;
	videoLocalPlaying.width=hbxVideoDisplay.width;
	videoLocalPlaying.height=hbxVideoDisplay.height;
	
	for (var i:int=0; i < tempCameraNames.length; i++){
		if (tempCameraNames[i] == selectedCameraDevice){
			cameraIndex=i;
			break;
		}
	}
	for (var j:int=0; j < arMicroPhoneDriverNames.length; j++){
		if (arMicroPhoneDriverNames[j] == selectedMicrophoneDevice){
			microPhoneIndex=j;
			break;
		}
	}
	if (videoCodec == Constants.CODEC_VP6){
		for (var k:int=0; k < tempCameraNames.length; k++){
			
			if (tempCameraNames[k] == FlexGlobals.topLevelApplication.mainApp.SCREEN_CAMERA_DRIVER_NAME){
				camera=Camera.getCamera(k.toString());
				break;
			}
		}
		videoLocalPlaying.attachCamera(camera);
	}
	else if (!isAudioOnlyOptionSelected)
		videoLocalPlaying.attachCamera(Camera.getCamera(cameraIndex.toString()));
	else if (isAudioOnlyOptionSelected)
		lblAudioNotification.visible=true;
	videoLocalDisplay.addChild(videoLocalPlaying);
	hbxVideoDisplay.addChild(videoLocalDisplay);
}

/**
 * @private
 * Function uses the sorenson class for publishing.
 * Attaches the camera, microphone object and publish to server.
 *
 * @param void
 * @return void
 */
private function publishSorensonVideo():void{
	var sorensonCodec:VideoStreamSettings=new VideoStreamSettings();
	nsPublish=new NetStream(ncVideoInsert.netConnection);
	
	microPhoneObj=Microphone.getEnhancedMicrophone(microPhoneIndex);
	microPhoneObj.codec=SoundCodec.SPEEX;
	microPhoneObj.setUseEchoSuppression(true);
	microPhoneObj.gain=50;
	nsPublish.attachAudio(microPhoneObj);
	if (!isAudioOnlyOptionSelected){
		nsPublish.videoStreamSettings=sorensonCodec;
		cameraObj=Camera.getCamera(cameraIndex.toString());
		cameraObj.setQuality(videoBandwidth, videoQuality);
		cameraObj.setMode(videoCaptureWidth, videoCaptureHeight, fps);
		nsPublish.attachCamera(cameraObj);
	}
	nsPublish.publish(userName);
}

/**
 * @private
 * Function attaches the arguments to external exe for publishing.
 *
 * @param void
 * @return void
 */
private function publishVP6Video():void{
	applicationType::desktop{
		/*File and NativeProcessStartupInfo not available for web.*/
		nativeProcessStartupInfo=new NativeProcessStartupInfo();
		processArgs=new Vector.<String>();
		flixParameters="," + ipFMS[2] + ":" + ClassroomContext.portFMS + "," + Constants.VIDEO_SERVER_MODULE_NAME + "/" + aviewClassName + "," + userName + "," + selectedCameraDevice + "," + selectedMicrophoneDevice + "," + videoBitrate.toString() + "," + audioBitrate.toString() + "," + 1 + "," + 1 + "," + videoCaptureWidth.toString() + "," + videoCaptureHeight.toString() + "," + "0" + "," + "15" + "," + "1" + "," + "0" + "," + 1 + "," + "9126";
		externalExeFile=File.applicationDirectory;
		externalExeFile=externalExeFile.resolvePath("app:///edu/amrita/aview/video/native/Windows/bin/akr.exe");
		processArgs.push(flixParameters);
		
		nativeProcessStartupInfo.executable=externalExeFile;
		nativeProcessStartupInfo.arguments=processArgs;
		
		npPublishVP6Video=new NativeProcess();
		if (NativeProcess.isSupported == true){
			if (npPublishVP6Video.running == false){
				npPublishVP6Video.start(nativeProcessStartupInfo);
				createSocket();
			}
		}
		else
			Alert.show("not supported", "Pre Test");
	}
}

/**
 *
 * @private
 * Function for establishing a connection with
 * socket class and initializes its handlers.
 *
 * @param void
 * @return void
 *
 ***/
private function createSocket():void{
	socket=new Socket();
	socket.addEventListener(IOErrorEvent.IO_ERROR, socketErrorHandler);
	socket.addEventListener(Event.CONNECT, onSocketConnect);
	socketCommand=null;
	socketRunning=true;
}

/**
 *
 * @private
 * Function for handling the errors occuring
 * while establishing a socket connection.
 *
 * @param event of IO Error
 * @return void
 *
 ***/
private function socketErrorHandler(e:IOErrorEvent):void{
	Alert.show("socketErrorHandler::" + e.toString(), "Pre Test");
}

/**
 *
 * @private
 * Function invoked when a connection is established
 * between a socket and application.
 * Socket command is passed and closes the connection.
 *
 * @param event of type Event
 * @return void
 *
 ***/
private function onSocketConnect(event:Event):void{
	btnStart.enabled=false;
	timerSocket=new Timer(1000, 13);
	timerSocket.addEventListener(TimerEvent.TIMER_COMPLETE, timerStartButtonEnable);
	timerSocket.start();
	socket.writeUTFBytes(socketCommand);
	socket.flush();
	socket.close();
	socketCommand=null;
	socketRunning=false;
}

/**
 *
 * @public
 * Function for enabling the start button after 13 seconds gap.
 *
 * @param event of type Event
 * @return void
 *
 ***/
public function timerStartButtonEnable(event:TimerEvent):void{
	btnStart.enabled=true;
}

/**
 *
 * @private
 * Function calculates the audioBitrate, videoBitrate, videoCaptureWidth, videoCaptureHeight based on the
 * bandwidth selected for VP6 publishing.
 *
 * @param selectedBWKbps of type int
 * @return void
 *
 ***/
private function setVP6Parameters(selectedBWKbps:int):void{
	//START-----------------------------------
	//Check if bandwidth selected from the combobox is 28Kbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	//Check else bandwidth selected from the combobox is 56Kbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	//Check else bandwidth selected from the combobox is 128Kbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	//Check else bandwidth selected from the combobox is 256Kbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	//Check else bandwidth selected from the combobox is 512Kbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	//Check else bandwidth selected from the combobox is 768Kbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	//Check else bandwidth selected from the combobox is 1Mbps
	//If yes,sets the audiobitrate,videobitrate,videoCaptureWidth and videoCaptureWidth.
	
	// AKCR: please re-write this function by seprating constants and logic. For eg use the following logic
	// var constVar = {
	//  AKCR: 28  -> { au : 12, vb : 8, vcw : 320, vch : 240}
	//  AKCR: 56  -> { au : 18, vb : 38, vcw : 320, vch : 240}
	//  AKCR: 128 -> { au : 20, vb : 108, vcw : 320, vch : 240}
	//  AKCR: 256 -> { au : 32, vb : 180, vcw : 320, vch : 240}
	//  AKCR: 512 -> { au : 64, vb : 440, vcw : 320, vch : 240}
	//  AKCR: 786 -> { au : 64, vb : 700, vcw : 320, vch : 240}
	//  AKCR: 1024-> { au : 64, vb : 900, vcw : 640, vch : 480} }
	//  AKCR: audioBitrate = consVar[selectedBWKbps].au 
	//  AKCR: videoBitrate = consVar[selectedBWKbps].vb
	//  AKCR: videoCaptureWidth  = consVar[selectedBWKbps].vcw
	//  AKCR: videoCaptureHeight = consVar[selectedBWKbps].vch
	//  AKCR: by writing the code like above, you are separating config from code and its much cleaner and less error prone to changes 
	
	
	if (selectedBWKbps == 28){
		audioBitrate=12;
		videoBitrate=8;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
	}
	else if (selectedBWKbps == 56){
		audioBitrate=18;
		videoBitrate=38;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
	}
	else if (selectedBWKbps == 128){
		audioBitrate=20;
		videoBitrate=108;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
	}
	else if (selectedBWKbps == 256){
		audioBitrate=32;
		videoBitrate=180;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
	}
	else if (selectedBWKbps == 512){
		audioBitrate=64;
		videoBitrate=440;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
	}
	else if (selectedBWKbps == 768){
		audioBitrate=64;
		videoBitrate=700;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
	}
	else if (selectedBWKbps == 1024){
		audioBitrate=64;
		videoBitrate=900;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
	}
}

/**
 *
 * @private
 * Function calculates the videoBandwidth, videoQuality, videoCaptureWidth, videoCaptureHeight, fps based on the
 * bandwidth selected for sorenson publishing.
 *
 * @param selectedBWKbps of type int
 * @return void
 *
 ***/
private function setSorensonParameters(selectedBWKbps:int):void{
	// AKCR: please re-write this function by seprating constants and logic. For eg use the following logic
	// var constVar = {
	//  AKCR: 28  -> { vb : (28 * 1024) / 8, vq : 70, vcw : 160, vch : 120}
	//  AKCR: 56  -> { vb : 18, vq : 38, vcw : 320, vch : 240}
	//  AKCR: 128 -> { vb : 20, vq : 108, vcw : 320, vch : 240}
	//  AKCR: 256 -> { vb : 32, vq : 180, vcw : 320, vch : 240}
	//  AKCR: 512 -> { vb : 64, vq : 440, vcw : 320, vch : 240}
	//  AKCR: 786 -> { vb : 64, vq : 700, vcw : 320, vch : 240}
	//  AKCR: 1024-> { vb : 64, vq : 900, vcw : 640, vch : 480} }
	//  AKCR: audioBitrate = consVar[selectedBWKbps].vb 
	//  AKCR: videoBitrate = consVar[selectedBWKbps].vq
	//  AKCR: videoCaptureWidth  = consVar[selectedBWKbps].vcw
	//  AKCR: videoCaptureHeight = consVar[selectedBWKbps].vch
	//  AKCR: by writing the code like above, you are separating config from code and its much cleaner and less error prone to changes 

	if (selectedBWKbps == 28){
		videoBandwidth=(28 * 1024) / 8;
		videoQuality=70;
		videoCaptureWidth=160;
		videoCaptureHeight=120;
		fps=8;
	}
	else if (selectedBWKbps == 56){
		videoBandwidth=(56 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
		fps=10;
	}
	else if (selectedBWKbps == 128){
		videoBandwidth=(128 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
		fps=15;
	}
	else if (selectedBWKbps == 256){
		videoBandwidth=(256 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
		fps=15;
	}
	else if (selectedBWKbps == 512){
		videoBandwidth=(512 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
		fps=15;
	}
	else if (selectedBWKbps == 768){
		videoBandwidth=(768 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
		fps=15;
	}
	else if (selectedBWKbps == 1024){
		videoBandwidth=(1024 * 1024) / 8;
		videoQuality=100;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
		fps=15;
	}
}

/**
 *
 * @private
 * Function calculates the videoBandwidth, videoQuality, videoCaptureWidth, videoCaptureHeight, fps based on the
 * bandwidth selected for h264 publishing.
 *
 * @param selectedBWKbps of type int
 * @return void
 *
 ***/
// AKCR: please refer to comments made for the previous 2 functions and make them here too
private function setH264Parameters(selectedBWKbps:int):void{
	if (selectedBWKbps == 28){
		videoBandwidth=(28 * 1024) / 8;
		videoQuality=70;
		videoCaptureWidth=160;
		videoCaptureHeight=120;
		fps=8;
	}
	else if (selectedBWKbps == 56){
		videoBandwidth=(56 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
		fps=10;
	}
	else if (selectedBWKbps == 128){
		videoBandwidth=(128 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
		fps=15;
	}
	else if (selectedBWKbps == 256){
		videoBandwidth=(256 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=320;
		videoCaptureHeight=240;
		fps=15;
	}
	else if (selectedBWKbps == 512){
		videoBandwidth=(512 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
		fps=15;
	}
	else if (selectedBWKbps == 768){
		videoBandwidth=(768 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
		fps=15;
	}
	else if (selectedBWKbps == 1024){
		videoBandwidth=(1024 * 1024) / 8;
		videoQuality=80;
		videoCaptureWidth=640;
		videoCaptureHeight=480;
		fps=15;
	}
}

/**
 *
 * @private
 * Function sets the audio only option based on the data.
 *
 * @param void
 * @return void
 *
 ***/
private function streamingOptionChange():void{
	if (rbgAudioOption.selection == rbAudioOnly){
		cmbBandwidthSelect.enabled=false;
		cmbCameraSelect.enabled=false;
		isAudioOnlyOptionSelected=true;
	}
	else{
		cmbBandwidthSelect.enabled=true;
		cmbCameraSelect.enabled=true;
		isAudioOnlyOptionSelected=false;
	}
}
