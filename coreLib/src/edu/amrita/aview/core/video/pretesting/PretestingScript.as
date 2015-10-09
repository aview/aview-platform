import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import flash.events.ActivityEvent;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.filesystem.FileStream;
import flash.media.AudioDecoder;
import flash.media.AudioPlaybackMode;
import flash.media.Camera;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.media.Sound;
import flash.media.Video;
import flash.media.VideoStreamSettings;
import flash.media.scanHardware;
import flash.net.NetStream;
import flash.net.Socket;
import flash.system.Capabilities;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

/**
 * Array collection for storing the available microphone driver list.
 */
[Bindable]
private var acMicrophoneDriverList:ArrayCollection;

/**
 * Array collection for storing the available camera driver list.
 */
[Bindable]
private var acCameraDriverList:ArrayCollection;

/**
 * Net connection for playing the recorded questions.
 */
public var ncPlayingQuestions:MediaServerConnection;

/**
 * Net connection established for publishing the streams to FMS server.
 * Also recording the streams and deleting the recorded files after pretesting.
 */
public var ncPreTesting:MediaServerConnection;
/**
 * Array for getting the available microphone driver list from microphone class.
 */
private var arMicrophoneDrivers:Array;
/**
 * Array for getting the available audio driver list .
 */
private var arrAudioDrivers:Array;
/**
 * Array for getting the available camera driver list from camera class.
 */
private var arCameraDrivers:Array;

/**
 * Net stream for publishing the audio/video to FMS server.
 */
private var nsPreTesting:NetStream;

/**
 * Net stream for playing the recorded questions.
 */
private var nsPlayingQuestions:NetStream;

/**
 * Net stream for playing the recorded stream files based on user input.
 */
private var nsAudioPlayBack:NetStream;

/**
 * Stores the stream count to be played/recorded.
 */
private var streamCount:int;

/**
 * Stores the name of microphone driver selected by the user.
 */
private var selectedMicrophone:String=null;

/**
 * Stores the data that if user started speaker testing or not.
 */
private var isSpeakerTestingStarted:Boolean=false;

/**
 * Timer updates the microphone signal strength during microphone testing.
 */
private var timerMicStreamStrength:Timer;

/**
 * Timer updates the microphone signal strength during camera testing.
 */
private var timerMicAVStreamStrength:Timer;

/**
 * Publishing using h264 codec.
 */
private var h264Codec:H264VideoStreamSettings=new H264VideoStreamSettings();

/**
 *  Publishing using sorenson codec.
 */
private var sorensonCodec:VideoStreamSettings=new VideoStreamSettings();

/**
 * Check whether the application is initialized or not.
 */
private var isApplicationInitialized:Boolean=false;

/**
 * Hold the current page number of best practises.
 */
private var pageNumber:int=0;

/**
 * Holds the video codec choosen by the administrator from database for the corresponding class.
 */
private var classVideoCodec:String;
/**
 * Contains the argument list for passing into external exe for publishing.
 */
private var nativeProcessArguments:Vector.<String>;

/**
 * Contains the parameters like username, FMS server, port no: etc for external exe publishing.
 */
private var flixParameters:String;
/**
 * Enables the communication between the exe and flex application.
 */
private var socket:Socket;

/**
 * Hold the command needs to be passed to external exe.
 */
private var socketCommand:String;

/**
 * Holds the stream from camera for sending to server.
 */
private var vidCameraStream:Video;

/**
 * Holds the name of video device driver selected by the user.
 */
private var cameraDeviceSelected:String='';

/**
 * Holds the index of video device driver selected by the user.
 */
private var selectedCameraIndex:int;

/**
 * Hold the value of socket connection created or not.
 */
private var isSocketConnectionEstablished:Boolean=false;

/**
 * Microphone object for sending the audio stream to FMS server in microphone testing.
 */
private var objMicForMicTesting:Microphone;

/**
 * Microphone object for sending the audio stream to FMS server in camera testing.
 */
private var objMicForCameraTesting:Microphone

/**
 * Holds the recorded stream for playback.
 */
private var videoPlayBackStream:Video;

/**
 * Variable decides to show the alert while saving the user selected device driver to disk.
 */
private var isSavedAlertTobeShown:Boolean=true;

/**
 * Checks the existence of user details file for storing and retrieving user selected data.
 */
private var isUserDetailsFilePresent:Boolean=true;

/**
 * XML data for saving and retrieving the user selected drivers in xml file.
 */
private var xmlDriverDetails:XML;

/**
 * Service used for retrieving the data from xml file.
 */
private var httpServiceSavedDeviceNames:HTTPService;

/**
 * Hold the value of previously saved microphone driver.
 */
private var prevSelectedMicrophoneName:String;

/**
 * Hold the value of previously saved camera driver.
 */
private var prevSelectedCameraName:String;

/**
 * Holds the xml values for saving.
 */
private var xmlString:String;

/**
 * Timer for clearing the recorded streams from server.
 */
private var timerClearingRecordedStreams:uint;

/**
 * Holds the publishing stream names in microphone and camera testing
 */
private var arPublishingStreamNames:Array=new Array();

/**
 * Holds the value that current playing streams is repeating or not.
 */
private var isPlayingPrevStream:Boolean=false;

/**
 * Variabel for start publishing using VP6 codec.
 */
private var uintVP6Timer:uint;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/play.png")]
public var startSpeaker:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/stop.png")]
public var stopSpeaker:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/record.png")]
public var recordAudio:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/playbtn.png")]
public var speakerTestStart:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/stopbtn.png")]
public var speakerTestStop:Class;
[Bindable]
private  var micCheckingStatus:String='';
[Bindable]
private var activeMicrophone:Microphone;
/**
 * For debug log
 */
private var startTime:Number;
private var endTime:Number;
private var preTestingTimer:Timer;
private var timeoutID:uint;

private var log:ILogger=Log.getLogger("aview.modules.video.pretesting.PretestingScript.as");

/**Platform specific variables*/
applicationType::desktop
{
	/**
	 * Native process used for invoking the external exe for publishing using VP6 codec.
	 */
	public var npPublishVP6Video:NativeProcess;
	/**
	 * Hold the argument list and external exe path for publishing using VP6 codec.
	 */
	private var nativeProcessStartupInfo:NativeProcessStartupInfo;
	/**
	 * Hold the external exe file path.
	 */
	private var externalExeFile:File;
}
//Fix for issue #17153
applicationType::web{
	//To store users video details to Local Shared Object
	private var audioVideoDetailsSharedObject:SharedObject;
}

/**
 *
 * @private
 * Function used for establishing the netconnection with FMS server
 * for playing questions and intitializing their handlers.
 * Also sets the video codec for pretesting according to class.
 *
 * @param void
 * @return void
 *
 ***/
private function initializePretesting():void
{
	btnStartStop.enabled=false;
	btnRecord.enabled=false;
	
	log.info("initializePreTesting - refresh driver list");
	refreshDriverList(false);
	
	classVideoCodec=ClassroomContext.aviewClass.videoCodec;
	// Since h264 is not supported in Red5 server, checks for that and assigns Sorenson as codec.
	if ((ClassroomContext.FMS_USER_SERVER_CATEGORY == "RED5-LIN" || ClassroomContext.FMS_USER_SERVER_CATEGORY == "RED5-WIN") && classVideoCodec == "H.264")
		classVideoCodec="Sorenson";
	
	isApplicationInitialized=true;
	
	var connectionParams:ArrayList = new ArrayList();
	connectionParams.addItem(ClassroomContext.userVO.userName);
	connectionParams.addItem(ClassroomContext.userDetails);
	connectionParams.addItem(ClassroomContext.hardwareAddress);
	connectionParams.addItem(ClassroomContext.userVO.role);
	connectionParams.addItem(ClassroomContext.aviewClass.maxStudents);
	connectionParams.addItem(ClassroomContext.hardwareAddress);
	connectionParams.addItem(ClassroomContext.lecture.lectureId);
	ncPlayingQuestions=new MediaServerConnection(ClassroomContext.FMS_USER,Constants.PRETESTING_SERVER_MODULE_NAME,null,connectionParams,this);
	ncPlayingQuestions.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, playingQuestionsNetStatusHandler);
	ncPlayingQuestions.initialize();
	startTimer();
}

private function startTimer():void
{
	startTime = new Date().time;
	endTime = new Date().time + Number(07) * 1000;
	if(preTestingTimer==null)
		preTestingTimer = new Timer(500);
	preTestingTimer.addEventListener(TimerEvent.TIMER, onTimerInterval);
	preTestingTimer.start();
}

private function onTimerInterval(event:Event):void{
	var now:Number = new Date().time;
	if(endTime <= now){
		btnStartStop.enabled=true;
		btnRecord.enabled=true;
		preTestingTimer.stop();
	}else{
		//countDownTimerDisplay.text = Math.round((endTime - now)/1000).toString();
		preTestingTimer.start();
	}
}


private function playingQuestionsNetStatusHandler(event:MediaServerStatusEvent):void
{
	switch (event.code)
	{
		case MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED:
			Alert.show("Pretesting connection to the server for playing questions is failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", "Connection Failed", 0, null);
			break;
		
		case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
			AuditContext.userAction.connectionSuccessEventLog("Pretesting PlayQuestions", ClassroomContext.FMS_USER,ncPlayingQuestions.connectionRetrys+"");
			//netConnectionForPreTesting();
			break;
		
		// Connection to server is failed to connect
		case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
			AuditContext.userAction.connectionFailEventLog("Pretesting PlayQuestions", ClassroomContext.FMS_USER);
			Alert.show("Pretesting connection to the server for playing questions is failed.\n" + " Please wait while reconneting...", "Alert", 0, null);
			break;
		
		// Server has rejected the connection.
		case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
			AuditContext.userAction.connectionRejectEventLog("Pretesting PlayQuestions", ClassroomContext.FMS_USER);
			Alert.show("Pretesting connection to the server for playing questions is rejected.\n" + " Please Close the Pretesting and try again.", "Alert", 0, null);
			break;
		
		// Connection established become closed.
		case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
			AuditContext.userAction.connectionCloseEventLog("Pretesting PlayQuestions", ClassroomContext.FMS_USER);
			Alert.show("Pretesting connection to the server for playing questions is closed.\n" + " Please wait while reconneting...", "Alert", 0, null);
			break;
		
	}
}
/*
private function netConnectionForPreTesting():void
{
	var connectionParams:ArrayList = new ArrayList();
	connectionParams.addItem(ClassroomContext.userVO.userName);
	connectionParams.addItem(ClassroomContext.userDetails);
	connectionParams.addItem(ClassroomContext.hardwareAddress);
	
	ncPreTesting=new MediaServerConnection(ClassroomContext.FMS_USER,Constants.PRETESTING_SERVER_MODULE_NAME,ClassroomContext.aviewClass.className + "_" + ClassroomContext.aviewClass.classId,connectionParams,this);
	ncPreTesting.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, precheckingNetStatusHandler);
	ncPreTesting.initialize();
}**/

/**
 *
 * @private
 * Function is the event listener for Pretesting Connection
 *
 * @param event of Net Status
 * @return void
 *
 ***/
private function precheckingNetStatusHandler(event:MediaServerStatusEvent):void
{
	switch (event.code)
	{
		case MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED:
			Alert.show("Pretesting connection to the server is failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", "Connection Failed", 0, null);
			break;
		
		case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
			AuditContext.userAction.connectionSuccessEventLog("Pretesting", ClassroomContext.FMS_USER, ncPreTesting.connectionRetrys+"");
			// Succesfully established a net connection for pretesting and enables the button for starting the pretesting functionalities.
			/*btnStartMicChecking.enabled=true;
			btnStartSpeakerTest.enabled=true;*/
			
			// Checks if the OS is mac or its a browser version and video codec is VP6, if so disables the main camera and microphone buttons.
			/*if ((Capabilities.os.toLowerCase().indexOf("mac") > -1 || AVCEnvironment.runTime == AVCEnvironment.BROWSER) && classVideoCodec == "VP6")
			{
				btnHeaderCamera.enabled=false;
				btnHeaderMicrophone.enabled=false;
			}
			else
			{
				btnHeaderCamera.enabled=true;
				btnHeaderMicrophone.enabled=true;
			}*/
			break;
		
		// Connection to server is failed to connect
		case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
			AuditContext.userAction.connectionFailEventLog("Pretesting", ClassroomContext.FMS_USER);
			Alert.show("Pretesting connection to the server is failed.\n" + " Please wait while reconneting...", "Alert", 0, null);
			break;
		
		// Server has rejected the connection.
		case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
			AuditContext.userAction.connectionRejectEventLog("Pretesting", ClassroomContext.FMS_USER);
			Alert.show("Pretesting connection to the server is rejected.\n" + " Please Close the Pretesting and try again.", "Alert", 0, null);
			break;
		
		// Connection established become closed.
		case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
			AuditContext.userAction.connectionCloseEventLog("Pretesting", ClassroomContext.FMS_USER);
			Alert.show("Pretesting connection to the server is closed.\n" + " Please wait while reconneting...", "Alert", 0, null);
			break;
		
		// Invokes after the stopping of playing streams.
		case "NetStream.Play.Stop":
			clearLastStreams();
			break;
		
	}
}
private function clearLastStreams():void
{
	timerClearingRecordedStreams=setTimeout(streamClear, 1000);
}
private function streamClear():void
{
	clearTimeout(timerClearingRecordedStreams);
	if (!isPlayingPrevStream && vdAVPlaying1)
		vdAVPlaying1.removeAllElements();
	isPlayingPrevStream=false;
}
private function closePretesting():void
{
	stopMic();
	if(vdAVPlaying.numChildren!=0)
		vdAVPlaying.removeChildAt(0);
	//vdAVPlaying.removeChild(videoPlayBackStream);
	if (nsAudioPlayBack)
		nsAudioPlayBack.close();
	if (nsPlayingQuestions)
		nsPlayingQuestions.close();
	if (nsPreTesting)
		nsPreTesting.close();
	
	if(timerMicAVStreamStrength!=null)
	{
		timerMicAVStreamStrength.stop();
		timerMicAVStreamStrength = null;
	}
	
	if (vidCameraStream)
	{
		vidCameraStream.attachCamera(null);
	}
	
	//if (arPublishingStreamNames.length > 0)
		//ncPreTesting.netConnection.call("deleteFile", null, ClassroomContext.userVO.userName, ClassroomContext.aviewClass.className + "_" + ClassroomContext.aviewClass.classId, arPublishingStreamNames);
	
	try
	{
		if (isSocketConnectionEstablished)
		{
			socketCommand="quit";
			socket.connect("127.0.0.1", 9125);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.restrictPublishVideo();
		}
	}
	catch (er:Error)
	{
		if(Log.isError()) FlexGlobals.topLevelApplication.mainApp.log.error("Pretesting.closePretesting:- Error:"+ er.getStackTrace());
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.removePreTestingPopUp();
	
}
private function callScanHardwareFunction():void
{
	if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag)
	{
		log.info("calling scanHardware");
		scanHardware();
	}
}

private function refreshDriverList(scan:Boolean):void
{
	log.info("refreshDriverList");
	
	if (scan)
	{
		// First do scan hardware with a small delay
		applicationType::desktop
		{
			if (Capabilities.os.toLowerCase().indexOf("win") > -1)
			{
				callScanHardwareFunction();
			}
		}
		// Removed OS check, to refresh the audio and video drivers list for all OS.
		applicationType::web
		{
			callScanHardwareFunction();
		}
	}
	
	micCheckingStatus="";
	
	if(vdAVPlaying.numChildren!=0)
		vdAVPlaying.removeChildAt(0);
	
	refreshAVDriverList();
	refreshMicDriverList();
	
	if (cmbAVVideo.selectedIndex >= 0)
		startCameraTesting();
}


/**
 *
 * @private
 * Functions refreshes the audio/video driver list
 * and assigns the result to corresponding combo box.
 *
 * @param void
 * @return void
 *
 ***/
private function refreshAVDriverList():void
{
	
	acMicrophoneDriverList=new ArrayCollection();
	//Adding microphone names to the list
	//Fix for issue #17085
	applicationType::DesktopMobile{
		for (var k:int=0; k < Microphone.names.length; k++)
		{
			acMicrophoneDriverList.addItem(Microphone.names[k]);
		}
	}
	applicationType::web{
		if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){			
			for (var k:int=0; k < Microphone.names.length; k++){
				acMicrophoneDriverList.addItem("Audio Driver " + (k+1));
			}
		}
		else{
			for (var k:int=0; k < Microphone.names.length; k++)
			{
				acMicrophoneDriverList.addItem(Microphone.names[k]);
			}
		}
	}
	cmbAVAudio.dataProvider=acMicrophoneDriverList;
	if (Microphone.names.length >= 1)
	{
		cmbAVAudio.selectedIndex = 0;
	}
	else
	{
		cmbAVAudio.selectedIndex = -1;		
	}
	
	arCameraDrivers=Camera.names;
	for (var i:int=0; i < arCameraDrivers.length; i++)
	{
		//Avoiding Screencamera and uscreencapture from driver list.
		if (arCameraDrivers[i] == "UScreenCapture" || arCameraDrivers[i] == "ScreenCamera HR" || arCameraDrivers[i] == "ScreenCamera Video Camera" || arCameraDrivers[i] == "ScreenCamera IM Device")
			arCameraDrivers.splice(i, 1);
	}
	acCameraDriverList=new ArrayCollection();
	//Fix for issue #17085
	applicationType::DesktopMobile{
		for (var j:int; j < arCameraDrivers.length; j++)
		{
			acCameraDriverList.addItem(arCameraDrivers[j]);
		}
	}
	applicationType::web{
		if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
			for (var j:int; j < arCameraDrivers.length; j++)
			{
				acCameraDriverList.addItem("Camera "+(j+1));
			}
		}
		else{
			for (var j:int; j < arCameraDrivers.length; j++)
			{
				acCameraDriverList.addItem(arCameraDrivers[j]);
			}
		}
	}
	cmbAVVideo.dataProvider=acCameraDriverList;
	if (arCameraDrivers.length >= 1)
	{
		cmbAVVideo.selectedIndex = 0;
	}
	else
	{
		cmbAVVideo.selectedIndex = -1;		
	}
}

private function refreshAudioDriverList():void
{
	//arrAudioDrivers=flash.media.AudioPlaybackMode.MEDIA
	acMicrophoneDriverList=new ArrayCollection();
	// Adding microphone list
	for (var k:int=0; k < arMicrophoneDrivers.length; k++)
	{
		acMicrophoneDriverList.addItem(arMicrophoneDrivers[k]);
	}
	cmbMicrophoneDrivers.dataProvider=acMicrophoneDriverList;
}


private function refreshMicDriverList():void
{
	applicationType::desktop
	{
		if (Capabilities.os.toLowerCase().indexOf("win") > -1)
		{
			callScanHardwareFunction();
		}
	}
	//Removed OS check, to refresh the audio and video drivers list for all OS.
	applicationType::web
	{
		callScanHardwareFunction();
	}
	
	
	arMicrophoneDrivers=Microphone.names;
	acMicrophoneDriverList=new ArrayCollection();
	// Adding microphone list
	//Fix for issue #17085
	applicationType::DesktopMobile{
		for (var k:int=0; k < arMicrophoneDrivers.length; k++)
		{
			acMicrophoneDriverList.addItem(arMicrophoneDrivers[k]);
		}
	}
	applicationType::web{
		if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){			
			for (var k:int=0; k < arMicrophoneDrivers.length; k++){
				acMicrophoneDriverList.addItem("Audio Driver " + (k+1));
			}
		}
		else{
			for (var k:int=0; k < arMicrophoneDrivers.length; k++)
			{
				acMicrophoneDriverList.addItem(arMicrophoneDrivers[k]);
			}	
		}
	}
	cmbMicrophoneDrivers.dataProvider=acMicrophoneDriverList;
	if (arMicrophoneDrivers.length >= 1)
	{
		cmbMicrophoneDrivers.selectedIndex = 0;
	}
	else
	{
		cmbMicrophoneDrivers.selectedIndex = -1;
	}
}
/**
 *
 * @private
 * Function for publishing using VP6 codec.
 * Calling an eternal exe by passing parameters into it.
 *
 * @param void
 * @return void
 *
 ***/
private function publishVP6Video():void
{
	/*No NativeProcessStartupInfo property for web application.*/
	applicationType::desktop
	{
		nativeProcessStartupInfo=new NativeProcessStartupInfo();
		nativeProcessArguments=new Vector.<String>();
		flixParameters="," + ClassroomContext.FMS_USER + ":" + ClassroomContext.portFMS + "," + Constants.PRETESTING_SERVER_MODULE_NAME + "/" + ClassroomContext.aviewClass.className + "_" + ClassroomContext.aviewClass.classId + "," + ClassroomContext.userVO.userName + "," + cmbAVVideo.selectedItem.toString() + "," + cmbAVAudio.selectedItem.toString() + "," + "38" + "," + "18" + "," + 1 + "," + 1 + "," + "320" + "," + "240" + "," + "0" + "," + "15" + "," + "1" + "," + "0" + "," + 1 + "," + "9125";
		externalExeFile=File.applicationDirectory;
		externalExeFile=externalExeFile.resolvePath("app:///NativeApps/Windows/bin/akr.exe");
		nativeProcessArguments.push(flixParameters);
		nativeProcessStartupInfo.executable=externalExeFile;
		nativeProcessStartupInfo.arguments=nativeProcessArguments;
		npPublishVP6Video=new NativeProcess();
		
		// Checks whether native process is supported otherwise throws an alert.
		if (NativeProcess.isSupported == true)
		{
			if (npPublishVP6Video.running == false)
			{
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
 * Function initializes the video object and
 * attaches the camera stream with it.
 * Calls the function for playing the audio files.
 *
 * @param void
 * @return void
 *
 ***/
private function startCameraTesting():void
{
	log.info("startcameratesting");
	
	// Calls for deleting at server side if any stream file exists.
	//if (arPublishingStreamNames.length > 0)
		//ncPreTesting.netConnection.call("deleteFile", null, ClassroomContext.userVO.userName, ClassroomContext.aviewClass.className + "_" + ClassroomContext.aviewClass.classId, arPublishingStreamNames);
	arPublishingStreamNames=new Array();
	//btnAVReTest.enabled=true;
	vidCameraStream=new Video();
	vidCameraStream.width=vdAVPlaying.width;
	vidCameraStream.height=vdAVPlaying.height;
	if (cmbAVVideo.selectedItem != null)
		cameraDeviceSelected=cmbAVVideo.selectedItem.toString();
	var camNames:Array=Camera.names;
	var i:int;
	// Getting the index of camera which is being selected by the user.
	//PNCR: Remove unnecessary looping. Use as below 
	//PNCR: selectedCameraIndex = camNames.indexOf(cameraDeviceSelected)
	for (i=0; i < camNames.length; i++)
	{
		if (camNames[i] == cameraDeviceSelected)
		{
			selectedCameraIndex=i;
			break;
		}
	}
	
	// Checks whether the codec is VP6.
	// If so, selects the index of screen camera for publishing.
	if (classVideoCodec == "VP6")
	{
		var camArray:Array=Camera.names;
		// Function for publishing using VP6 codec.
		publishVP6Video();
		//Loops throught the camera array for getting the index of ScreenCamera device.
		for (i=0; i < camArray.length; i++)
		{
			
			if (camArray[i] == FlexGlobals.topLevelApplication.mainApp.SCREEN_CAMERA_DRIVER_NAME)
			{
				break;
			}
		}
		vidCameraStream.attachCamera(Camera.getCamera(i.toString()));
	}
	else
	{
		vidCameraStream.attachCamera(Camera.getCamera(selectedCameraIndex.toString()));
	}
	vdAVPlaying.addChild(vidCameraStream);
	
	streamCount=0;
	/*cmbAVAudio.enabled=false;
	cmbAVVideo.enabled=false;*/
		// Checks for the VP6 codec, 
	if (classVideoCodec == "VP6")
	{
		uintVP6Timer=setTimeout(startAudioVideoPlaying, 1000);
	}
	else
	{
		//playCameraTestingQuestions();
	}
}
/**
 *
 * @private
 * Function for playing the audio files for pretesting.
 *
 * @param void
 * @return void
 *
 ***/
private function startAudioVideoPlaying():void
{
	clearTimeout(uintVP6Timer);
	//playCameraTestingQuestions();
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
private function createSocket():void
{
	socket=new Socket();
	socket.addEventListener(IOErrorEvent.IO_ERROR, socketErrorHandler);
	socket.addEventListener(Event.CONNECT, onSocketConnect);
	socketCommand=null;
	isSocketConnectionEstablished=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isStartAVButtonCanbeEnabled=false;
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
private function socketErrorHandler(event:IOErrorEvent):void
{
	Alert.show("socketErrorHandler::" + event.toString(), "Pre Test");
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
private function onSocketConnect(event:Event):void
{

	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerSocket=new Timer(1000, 13);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerSocket.addEventListener(TimerEvent.TIMER_COMPLETE, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerStartButtonEnable);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerSocket.start();
	socket.writeUTFBytes(socketCommand);
	socket.flush();
	socket.close();
	socketCommand=null;
	isSocketConnectionEstablished=false;
}
private function startStopSpeakerTesting():void
{
	log.info("startStopSpeakerTesting");
	
	// Checks for any previously opened netstream, if so closes them.
	if (nsPlayingQuestions)
		nsPlayingQuestions.close();
	if (nsAudioPlayBack)
		nsAudioPlayBack.close();
	if (nsPreTesting)
		nsPreTesting.close();
	
	
	// Checks the socket connection status, if exist closes by passing the 'quit' message.
	try
	{
		if (isSocketConnectionEstablished)
		{
			socketCommand="quit";
			socket.connect("127.0.0.1", 9125);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.restrictPublishVideo();
		}
	}
	catch (er:Error)
	{
		if(Log.isError()) FlexGlobals.topLevelApplication.mainApp.log.error("Pretesting startStopSpeakerTesting Socket error:"+ er.getStackTrace());
	}
	
	// Checks the netconnection connectivity
	if (ncPlayingQuestions && ncPlayingQuestions.netConnection.connected) // && ncPreTesting && ncPreTesting.netConnection.connected)
	{
		//Checks whether the pretesting started or not
		if (!isSpeakerTestingStarted)
		{
			log.info("speaker testing started");
			
			isSpeakerTestingStarted=true;
			
			//btnStartSpeakerTest.label="STOP"
			btnStartStop.source=speakerTestStop;
			nsPlayingQuestions=new NetStream(ncPlayingQuestions.netConnection);
			nsPlayingQuestions.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncError);
			nsPlayingQuestions.play("intro_new");
			btnStartStop.toolTip="Stop test sound";
			timeoutID = setTimeout(audioPlayDuration, 30000);
			
		}
		else if (isSpeakerTestingStarted)
		{
			log.info("speaker testing stopped");
			
			isSpeakerTestingStarted=false;
			btnStartStop.source=speakerTestStart;
			//btnStartSpeakerTest.label="START";
			btnStartStop.toolTip="Play test sound";
			
		}
	}
}
private function audioPlayDuration():void
{
	btnStartStop.source=speakerTestStart;
	btnStartStop.toolTip="Play test sound";
}
private function asyncError(event:AsyncErrorEvent):void
{
	if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Pretesting : AsyncError while creating connection " + event.text);
}

/**
 *
 * @private
 * Function tries to get the user saved data
 * of drivers from the xml file.
 *
 * @param void
 * @return void
 *
 ***/

private function getDriverDetails():void
{
	stopMic();
	
	if(cmbAVVideo.selectedIndex!=-1 && cmbMicrophoneDrivers.selectedIndex!=-1)
	{
		prevSelectedMicrophoneName="";
		prevSelectedCameraName="";
		httpServiceSavedDeviceNames=new HTTPService();
		httpServiceSavedDeviceNames.addEventListener(ResultEvent.RESULT, driversPopulating);
		httpServiceSavedDeviceNames.addEventListener(FaultEvent.FAULT, faultHandler);
		//There is no File property for web application.
		applicationType::desktop
		{
			httpServiceSavedDeviceNames.url=File.applicationStorageDirectory.nativePath + "\\UserDetails.xml";
		}
		httpServiceSavedDeviceNames.resultFormat="e4x"
		httpServiceSavedDeviceNames.send();
		//Fix for issue #17153
		applicationType::web{
			loadPreviousDetails();
		}
	}
	else
	{
		//fix for #16254
		if(cmbAVVideo.selectedIndex<=-1 && cmbMicrophoneDrivers.selectedIndex<=-1)
		{
			Alert.show("Select the audio and video driver","Error");
		}
		else if(cmbAVVideo.selectedIndex<=-1)
		{
			Alert.show("Select the video driver","Error");
		}
		else if(cmbMicrophoneDrivers.selectedIndex<=-1)
		{
			Alert.show("Select the audio driver","Error");
		}
	}
}
/**
 *
 * @private
 * Function for handling the error occured
 * while fetching the xml data.
 * Saves the data.
 *
 * @param event of Fault
 * @return void
 *
 ***/
private function faultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("video::pretesting::PretestingScript::faultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	isUserDetailsFilePresent=false;
	prevSelectedCameraName=cmbAVVideo.selectedItem.toString();
	prevSelectedMicrophoneName=cmbMicrophoneDrivers.selectedItem.toString();
	//Fix for issue #18434
	applicationType::desktop{
		saveDeviceDrivers();
	}
}

/**
 *
 * @private
 * Function for handling the result event
 * while fetching the xml data.
 *
 * @param event of Result
 * @return void
 *
 ***/
private function driversPopulating(event:ResultEvent):void
{
	xmlDriverDetails=event.result as XML;
	prevSelectedMicrophoneName=xmlDriverDetails.audioDriver.toString();
	prevSelectedCameraName=xmlDriverDetails.videoDriver.toString();
	
	// Getting the selected camera and microphone names from Camera page.
	
		//prevSelectedMicrophoneName=cmbAVAudio.selectedItem.toString();
		if (cmbAVVideo.selectedItem != null)
			prevSelectedCameraName=cmbAVVideo.selectedItem.toString();
	
		prevSelectedMicrophoneName=cmbMicrophoneDrivers.selectedItem.toString();
	
	saveDeviceDrivers();
	
}
//Fix for issue #17153
applicationType::web{
	private function loadPreviousDetails():void{
		audioVideoDetailsSharedObject = SharedObject.getLocal("UserDetails_"+ClassroomContext.userVO.userName,"/");
		var values:String = audioVideoDetailsSharedObject.data.value;
		xmlDriverDetails=XML(values);
		prevSelectedMicrophoneName=xmlDriverDetails.audioDriver.toString();
		prevSelectedCameraName=xmlDriverDetails.videoDriver.toString();		
		// Getting the selected camera and microphone names from Camera page.		
		if (cmbAVVideo.selectedItem != null)
			prevSelectedCameraName=cmbAVVideo.selectedItem.toString();		
		prevSelectedMicrophoneName=cmbMicrophoneDrivers.selectedItem.toString();		
		saveDeviceDrivers();
	}
}


/**
 *
 * @private
 * Function saves the user selected device driver into the disk.
 *
 * @param void
 * @return void
 *
 ***/
private function saveDeviceDrivers():void
{
	//xmlString="<user>\n<username></username>\n<password>\n</password><audioDriver>\n" + prevSelectedMicrophoneName + "</audioDriver>\n<videoDriver>\n" + prevSelectedCameraName + "</videoDriver>\n<videoDeviceType>\n"+Constants.CAM_TYPE_WEBCAM+"</videoDeviceType>\n</user>";
	xmlString="<user>\n<username></username>\n<password>\n</password>" +
		"<audioDriver>\n"+prevSelectedMicrophoneName+"</audioDriver>\n" +
		"<videoDriver>\n"+prevSelectedCameraName+"</videoDriver>\n" +
		"<bandwidth>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps+"</bandwidth>\n" +
		"<videoDeviceType>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType +"</videoDeviceType>\n" +
		"<isAdvancedChecked>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAdvancedSettingsChecked+"</isAdvancedChecked>\n" +
		"<camResolution>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraResolution+"</camResolution>\n" +
		"<videoQuality>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraVideoQuality+"</videoQuality>\n" +
		"<fps>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.FPS+"</fps>\n" +
		"<h264Profile>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.h264Profile+"</h264Profile>\n" +
		"<h264ProfileValue>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.h264ProfileValue+"</h264ProfileValue>\n" +
		"<keyFrames>\n" + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.keyFrames + "</keyFrames>\n"+
		"<useFMLE>\n" + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE + "</useFMLE>\n";
	applicationType::desktop
	{
		var path:String="file:///" + File.applicationStorageDirectory.nativePath.toString() + "\\UserDetails.xml";
		var _file_det:File=new File(path);
		var _fileStream_det:FileStream=new FileStream();
		_fileStream_det.addEventListener(Event.CLOSE, fileStreamResultHandler);
		_fileStream_det.addEventListener(IOErrorEvent.IO_ERROR, fileStreamErrorHandler);
		_fileStream_det.openAsync(_file_det, FileMode.WRITE);
		_fileStream_det.writeUTFBytes(xmlString);
		_fileStream_det.close();
	}
	//Fix for issue #17153
	applicationType::web{
		audioVideoDetailsSharedObject = SharedObject.getLocal("UserDetails_"+ClassroomContext.userVO.userName,"/"); 
		audioVideoDetailsSharedObject.data.value= xmlString;
		audioVideoDetailsSharedObject.flush();
		//Fix for issue #19668
		Alert.show("Your Settings have been saved!!!", "INFO",4,null,function(event:CloseEvent):void {closePretestingWindow(event)});
	}
}

/**
 *
 * @private
 * Functions shows notification to user
 * after successfull storing of xml file.
 *
 * @param event of type Event
 * @return void
 *
 ***/
private function fileStreamResultHandler(event:Event):void
{
		pretestingSaveEventLog("Microphone", prevSelectedMicrophoneName, prevSelectedCameraName);
		pretestingSaveEventLog("Camera", prevSelectedMicrophoneName, prevSelectedCameraName);
	
	if (isSavedAlertTobeShown)
	{
		//if (isUserDetailsFilePresent)
		{
			Alert.show("Your Settings have been saved!!!", "INFO",4,null,function(event:CloseEvent):void {closePretestingWindow(event)});
		}
		//fix for 15506
		//closePretesting();
	}
	else
	{
		closePretesting();
	}
	isSavedAlertTobeShown=true;
	isUserDetailsFilePresent=true;
}

private function closePretestingWindow(event:CloseEvent):void {

		if (event.detail == Alert.OK) 
		{
			closePretesting();
		}
}

/**
 *
 * @private
 * Audits the "Pre-CheckSave" action, when the user clicks on the save button which saves the selcted/passed audio/video drivers
 *
 * @param savedTab - Tab on which the save button is clicked, Mike or Camera.
 * @param audioDriver - Chosen audio driver
 * @param videoDriver - Chosen video driver
 * @return void
 *
 */
private function pretestingSaveEventLog(savedTab:String, audioDriver:String, videoDriver:String):void
{
	AuditContext.userAction.createAction(AuditConstants.pretestingSave, savedTab, audioDriver, videoDriver);
}

/**
 *
 * @private
 * Function handles the error event occured during storing of xml file.
 *
 * @param eve of type Event
 * @return void
 *
 ***/
private function fileStreamErrorHandler(eve:Event):void
{
	if (isSavedAlertTobeShown)
	{
		if (isUserDetailsFilePresent)
		{
			Alert.show("Error during saving.\nPlease contact A-VIEW Administrator!", "WARNING");
		}
	}
	else
	{
		closePretesting();
	}
	isSavedAlertTobeShown=true;
	isUserDetailsFilePresent=true;
}

/**
 *
 * @private
 * Function for changing the button statuses and
 * calls the function for playing the questions.
 *
 * @param void
 * @return void
 *
 ***/
private function initializeMicTesting():void
{
	if(micCheckingStatus=="")
	{
	
		if(cmbMicrophoneDrivers.selectedIndex!=-1)
		{
			log.info("start Mic");
			
			micLevelCanvas.visible=true;
			
			
			activeMicrophone = Microphone.getMicrophone();
			activeMicrophone.setLoopBack(true);
			
			
			micCheckingStatus="RecordStart";
			btnRecord.source = stopSpeaker;
			/*if (arPublishingStreamNames.length > 0)
				ncPreTesting.netConnection.call("deleteFile", null, ClassroomContext.userVO.userName, ClassroomContext.aviewClass.className + "_" + ClassroomContext.aviewClass.classId, arPublishingStreamNames);
			arPublishingStreamNames=new Array();*/
			streamCount=0;
			selectedMicrophone=cmbMicrophoneDrivers.selectedItem.toString();
			cmbMicrophoneDrivers.enabled=false;
			//Fix for issue #19721
			applicationType::web{
				bcMicrophone.enabled=false;
				btnRecord.setFocus();
			}
			applicationType::desktop{
				cmbMicrophoneDrivers.enabled=false;
			}
			btnRefreshMicDriverList.enabled=false;
			//playMicQuestions();
			
			log.info("loopback turned on, installing activity change handler and timer\n");		
			activeMicrophone.addEventListener(ActivityEvent.ACTIVITY, mic_ActivityEventHandler);
			
			if(timerMicAVStreamStrength!=null)
			{
				timerMicAVStreamStrength.stop();
				timerMicAVStreamStrength = null;
			}
			
			timerMicAVStreamStrength = new Timer(750);
			timerMicAVStreamStrength.addEventListener(TimerEvent.TIMER, updateMicActivityLevel);
			timerMicAVStreamStrength.start();
		}
		else
			Alert.show("Select the Microphone","Error");
	}
	/*else if(micCheckingStatus=="RecordStart")
	{
		//activeMicrophone=null;
		micCheckingStatus="PlayBack";
		btnRecord.source = startSpeaker;
		micLevelCanvas.visible=false;
		btnRecord.toolTip = "Play recorded audio";
		if (nsPreTesting)
		{
			nsPreTesting.close();
		}
	}
	else if(micCheckingStatus=="PlayBack")
	{
		btnRecord.source = stopSpeaker;
		micCheckingStatus="PlayBackStop";
		initMicAnswerPlayback();
		btnRecord.toolTip = "Stop";
	}*/
	else
	{
		/*if (nsAudioPlayBack)
		{
			nsAudioPlayBack.close();
		}*/
		stopMic();
	}
		
}
private function stopMic():void
{
	log.info("stopMic");
	
	btnRecord.source = recordAudio;
	micCheckingStatus="";
	if(activeMicrophone!=null)
	{
		log.info("cleaning up");
		
		// stop the timer first to prevent canvas update
		if (timerMicAVStreamStrength != null)
		{
			timerMicAVStreamStrength.stop();
			timerMicAVStreamStrength = null;
		}
		
		// hide the canvas
		micLevelCanvas.visible=false;
		
		// turn off the microphone
		activeMicrophone.setLoopBack(false);
		activeMicrophone.removeEventListener(ActivityEvent.ACTIVITY, mic_ActivityEventHandler);
	}
	cmbMicrophoneDrivers.enabled=true;
	//Fix for issue #19721
	applicationType::web{
		bcMicrophone.enabled=true;
	}
	//Fix for issue #18986
	if(FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag){
		btnRefreshMicDriverList.enabled=true;
	}
	btnRecord.toolTip = "Speak on your microphone and look for audio signal";
	micLevelCanvas.visible=false;
}
/**
 *
 * @private
 * Function plays the audio files based
 * on the stream count variable.
 *
 * @param void
 * @return void
 *
 ***/
/*private function playMicQuestions():void
{
	if (nsPlayingQuestions)
	{
		nsPlayingQuestions.close();
	}
	
	
	// Checks the netconnection connectivity.
	if (ncPlayingQuestions.netConnection.connected && ncPreTesting.netConnection.connected)
	{
		nsPlayingQuestions=new NetStream(ncPlayingQuestions.netConnection);
		nsPlayingQuestions.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncError);
		//Checks the streamcount for playing the correspoding audio file
	
		audioRecording();
		
	}
}*/
/**
 *
 * @private
 * Function for publishing and recording the audio streams.
 *
 * @param void
 * @return void
 *
 ***/
/*private function audioRecording():void
{
	if (nsPreTesting)
	{
		nsPreTesting.close();
	}
	if(timerMicStreamStrength)
	{
		timerMicStreamStrength.stop();
	}
	
	// Checks the netconnection connectivity.
	// Publishes and records the streams.
	if (ncPlayingQuestions.netConnection.connected && ncPreTesting.netConnection.connected)
	{
		var tempDate:Date=new Date();
		var tempPublishname:String;
		nsPreTesting=new NetStream(ncPreTesting.netConnection);
		objMicForMicTesting=Microphone.getMicrophone(cmbMicrophoneDrivers.selectedIndex);
		nsPreTesting.attachAudio(objMicForMicTesting);
		//Based on the stream count, creates the publishing name and records.
		btnRecord.source = stopSpeaker;
		btnRecord.toolTip= "Stop";
		if (streamCount == 0)
		{
			tempPublishname=ClassroomContext.userVO.userName + "answ1" + tempDate.getTime().toString();
			arPublishingStreamNames.push(tempPublishname);
			nsPreTesting.publish(tempPublishname, "record");
		}
		else if (streamCount == 1)
		{
			tempPublishname=ClassroomContext.userVO.userName + "answ2" + tempDate.getTime().toString();
			arPublishingStreamNames.push(tempPublishname);
			nsPreTesting.publish(tempPublishname, "record");
		}
		else if (streamCount == 2)
		{
			tempPublishname=ClassroomContext.userVO.userName + "answ3" + tempDate.getTime().toString();
			arPublishingStreamNames.push(tempPublishname);
			nsPreTesting.publish(tempPublishname, "record");
			//glowEffectQuestion.stop();
		}
		else if (streamCount == 3)
		{
			nsPreTesting.publish("answ4", "record");
		}
		streamCount++;
	}
//	timerMicStreamStrength.start();
}*/

/**
 *
 * @private
 * Functions changes the button statuses and
 * calls the function for audio playback answers.
 *
 * @param void
 * @return void
 *
 ***/
/*private function initMicAnswerPlayback():void
{
	if (nsPreTesting)
	{
		nsPreTesting.close();
	}
	/*if(vidCameraStream)
	{
		vdAVPlaying.removeChild(vidCameraStream);
	}*/
	

/*	streamCount=0;
	microphonePlaybackAnswers();
}*/
/**
 *
 * @private
 * Function plays the audio files
 * based on the stream count variable.
 *
 * @param void
 * @return void
 *
 ***/
/*private function microphonePlaybackAnswers():void
{

	if (nsAudioPlayBack)
	{
		nsAudioPlayBack.close();
	}
	
	// Checks the netconnnection connectivity.
	// Plays the stream based on count.
	if (ncPlayingQuestions.netConnection.connected && ncPreTesting.netConnection.connected)
	{
		nsAudioPlayBack=new NetStream(ncPreTesting.netConnection);
		nsAudioPlayBack.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncError);
		if (streamCount == 0)
		{
			nsAudioPlayBack.play(arPublishingStreamNames[0]);
			
		}
		else if (streamCount == 1)
		{
			nsAudioPlayBack.play(arPublishingStreamNames[1]);
	
		}
		else if (streamCount == 2)
		{
			nsAudioPlayBack.play(arPublishingStreamNames[2]);
		}
		streamCount++;
	}
}*/
/*private function creationComplete_Handler():void
{
	activeMicrophone = Microphone.getMicrophone();
	activeMicrophone.setLoopBack(true);
	
	
	activeMicrophone.addEventListener(StatusEvent.STATUS, mic_StatusEventHandler);
	activeMicrophone.addEventListener(ActivityEvent.ACTIVITY, mic_ActivityEventHandler);
	
}

private function mic_StatusEventHandler(e:StatusEvent):void
{
	trace("ststus event: " + e.toString()); 
}
*/

var activityLevelOld:Number;

private function updateMicActivityLevel(event:Event):void
{
	if (micLevelCanvas != null && activeMicrophone != null)
	{
		var activityLevel:Number = activeMicrophone.activityLevel*2;
				
		log.info("updateMicActivityLevel - new actiivtyLevel " + activityLevel);
		
		if (Math.abs(activityLevel-activityLevelOld) < 3)
		{
			// log.info("no significant change - skip");
		}
		else
		{
			micLevelCanvas.visible = false;
			micLevelCanvas.graphics.clear();
			micLevelCanvas.graphics.beginFill(0X33aa00, 1);
			micLevelCanvas.graphics.drawRect(0, 0, Math.abs(activityLevel), 10);
			micLevelCanvas.graphics.endFill();
			micLevelCanvas.visible = true;
		}
		activityLevelOld = activityLevel;
		timerMicAVStreamStrength.start(); // restart the timer
	}
}

private function mic_ActivityEventHandler(e:ActivityEvent):void
{
	//trace("Activity Event");
	log.info("mic_ActivityEventHandler enter & exit");
	//addEventListener(Event.ENTER_FRAME, mic_EnterFrame_EventHandler);
}

/*private function mic_EnterFrame_EventHandler(e:Event):void
{
	micLevelCanvas.graphics.clear();
	
	micLevelCanvas.graphics.beginFill(0X33aa00, 1);
	micLevelCanvas.graphics.drawRect(0, 0, (activeMicrophone.activityLevel * 2), 10);
	micLevelCanvas.graphics.endFill();
}
*/
