//-----------------------------------------------------------------------------------
// 1. Authors      : Ajith Kumar R,Aneesh P S,Anu P,Chitra S Pai,Ashish Pillai
// 2. Description  : Video_ScriptCode is used to handle all audio/video streaming related functionalities of A-VIEW.
//					 This file has methods for maintaining status of userlist,publishing audio-video stream to FMS, 
//					 recieving audio-video stream from FMS,passing parameters to audio-video encoder,starts encoding,
//					 stop encoding,etc..
// 3. Dependencies : main.mxml,StudentView.mxml,UserList.mxml,VideoModule.mxml,setting.mxml
//-------------------------------------------------------------------------------------------------

import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.service.streaming.*;
import edu.amrita.aview.core.video.AVParameters;
import edu.amrita.aview.core.video.LocalVideo;
import edu.amrita.aview.core.video.MeetingVideoWall;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
	import edu.amrita.aview.core.video.VideoStreamDisplay;
	import edu.amrita.aview.core.video.setting;
	import edu.amrita.aview.core.video.VideoWall;
}
import edu.amrita.aview.core.video.VideoTileEvent;

import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.StatusEvent;
import flash.events.SyncEvent;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Video;
import flash.media.scanHardware;
import flash.net.LocalConnection;
import flash.net.SharedObject;
import flash.system.Capabilities;
import flash.utils.Timer;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;
import flash.net.URLRequest;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.SWFLoader;
import mx.core.FlexGlobals;
import mx.core.UITextField;
import mx.events.CloseEvent;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.core.UIComponent;
import edu.amrita.aview.core.video.IVideoWallLayout;
import edu.amrita.aview.core.video.viewerVideoTile;
import mx.containers.HBox;
import edu.amrita.aview.core.video.ButtonContainer;
import mx.core.mx_internal;
import edu.amrita.aview.core.video.ResizableTitleWindow;
import flash.events.SecurityErrorEvent;
import mx.formatters.DateFormatter;

/**Platform specific imports*/
//NativeProcess, File and FileStream are not available for web
applicationType::desktop{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import edu.amrita.aview.core.video.VideoWallPopOut;
}

/** Variable declarations */
import objectResolver.EntryFac;
import spark.components.Label;
import edu.amrita.aview.core.entry.ClassroomComponent;

import flash.net.NetStream;
import org.osflash.signals.natives.INativeDispatcher;
import edu.amrita.aview.core.video.native.LocalVideoDisplay;

import spark.events.IndexChangeEvent;
import edu.amrita.aview.core.shared.components.notifcations.Notification;
import flash.net.FileReference;
import edu.amrita.aview.core.gclm.vo.PeopleCountVO;
import edu.amrita.aview.core.gclm.helper.PeopleCountHelper;
import org.purepdf.errors.NullPointerError;


applicationType::mobile{
	import edu.amrita.aview.core.shared.components.mobileComponents.FullScreenLabel;
}


[Bindable]
public var checkStreamDisplay:Boolean=false;

//CRJH: API :done(ashwini)
public var snapshotObj = null;

/**
 * Array for storing various bandwidth values.
 * <br>These values are used to decide audio and video bitrates for encoder.</br>
 */
[Bindable]
public var arrBW:Array=new Array();

/**
 * Label for 'btnStart' button(for starting/stoping audio and video publishing) in main.mxml.
 */
[Bindable]
public var btnPublishLabel:String="Start";
/**
 * Array for storing the names of students in 'view video' mode.
 */
//private var studentViewTempArray:ArrayCollection = new ArrayCollection()
public var viewedViewerDisplays:ArrayCollection=new ArrayCollection();

/**
 * Array for storing name of all available video drivers.
 */
public var videodriver:Array=new Array();
/**
 * Array for storing name of all available audio drivers.
 */
public var audiodriver:Array=new Array();
///**
// * Flag variable to check availabilty of audio/video drivers.
// */
//public var areAudioVideoDriversAvailable:Boolean=false;
/**
 * String variable for storing name of selected audio driver.
 */
public var audioDeviceDrive:String="";
/**
 * String variable for storing name of selected video driver.
 */
public var videoDeviceDrive:String="";
/**
 * Integer variable for storing audio bitrate value for encoder.
 */
//public var audioBitrate:int=20;
/**
 * Integer variable for storing video bitrate value for encoder.
 */
//public var videoBitrate:int=108;
/**
 * String variable for storing selected bandwidth value.
 */
[Bindable]
public var selectedPublishingBWKbps:String="";
/**
 * Integer variable for storing video input resolution width.
 */
//public var videoCaptureWidth:int=320;
/**
 * Integer variable for storing video input resolution height.
 */
//public var videoCaptureHeight:int=240;
/**
 * Variable of type File for creating a logfile for storing the audio-video encoder parameters selected by the user.
 */
/* [Bindable]
private var _file_det:File; */
/**
 * Variable of type FileStream for creating a logfile for storing the audio-video encoder parameters selected by the user.
 */
/* [Bindable]
private var _fileStream_det:FileStream; */
/**
 * Variable of type String for temporarly storing the audio-video encoder parameters selected by the user.
 */
/* [Bindable]
private var writeString_det:String=""; */
/**
 * Variable of type SWFLoader for loading the busycursor SWF file shown when the user presses 'Start' button.
 */
private var busycursor_video:SWFLoader;

private var isBusyCursorRunning:Boolean=false;
/**
 * Variable of type Microphone for taking the details of Audio drivers connected to the machine
 */
//private var myMic:Microphone;
/**
 * Variable of type Camera for taking the details of Audio drivers connected to the machine
 */
//private var myCam:Camera;
/**
 * Variable of type Video for holding the video stream of teacher from FMS
 */
[Bindable]
public var teacherVideo:Video;
/**
 * Timer variable for disabling the stop button
 */
//RGCR: Rename this variable to timerVideoStartStopButton
private var timerNativeProcessExit:Timer;

public var timerEnableStartButton:Timer;
/**
 * Variable of type SoundTransform for storing the audio 'mute' state of netstream
 */

private var videoConnectionStatusStudentTimeoutId:uint;

private var videoConnectionStatusTeacherTimeoutId:uint;

private var videoConnectionStatusTimeoutId:uint;

/**
 * Variable of type Boolean for holding the status of local video popup (true-popup is visible,false-popup is closed)
 */
public var isLocalVideoON:Boolean=false;
/**
 * Variable of type localVideo component (local video popup)
 */
public var myVideo:LocalVideo;
/**
 * Is refresh button pressed or not
 */
public var isRefreshPressed:Boolean=false;
public var viewVideoCount:int =0;
public var clearPeopleCountTimeOut:uint = 0;
public var isChangeNotify:Boolean=false; 

public var arrVideoConnections:ArrayCollection=new ArrayCollection();
//{ip:"192.168.172.129",obj:"vC"},{ip:"192.168.172.27",obj:"vC1"}
//public var videoServersData:ArrayCollection=new ArrayCollection([{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"28"},{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"56"},{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"128"},{ip:"192.168.172.27",serverType:"FMS_VIDEO_VIEWER",portNumber:"1935",bandWidth:"56"}]); //{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"28"},{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"56"},
public var videoServersData:ArrayCollection=new ArrayCollection(); //([{ip:"192.168.172.129",serverType:"FMS_VIDEO_VIEWER",portNumber:"1935",bandWidth:"28"},{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"56"},{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"28"},{ip:"192.168.172.129",serverType:"FMS_VIDEO_PRESENTER",portNumber:"1935",bandWidth:"128"}]); 
private var videoPresenterServerData:Array=new Array();
private var videoViewerServerData:Array=new Array();

private var avParametersData:ArrayCollection=new ArrayCollection();
private var cursorTimeOut:uint;
private var publishStatusTimer:Timer;
private var socketPortNo:int;
public var presenterStreamName:String="";
public var prevPresenterStreamName:String="";
public var selectedUserName:String = "";
public var defaultStreamTime:Date = new Date;
public var defaultTime:String = "";

public var isViewerSelected:Boolean=false;
public var isPresenterVideoPublishing:Boolean=false;
private var isStreamPlaying:Boolean=true;
public var isFloatingWindowSelectedStudentPresent:Boolean=false;
public var isFloatingWindowClosedModerator:Boolean=true;
public var viewVideoDoubleClickFlag:Boolean=false;
public var arrViewVideoFullScreen:ArrayCollection=new ArrayCollection();

public var connectionTimeOut:uint;
private var userListCreated:Boolean=false;
//For synchronizing video wall
public var videoWallCollaborationObject:CollaborationObject;
private var isVideoWallSOReconnected:Boolean = false;
private var lastSelectedUser:String=null;
private var lastSelectedStream:String=null;
private var videoWallSelected:Boolean=false;
public var attachedCameraToScreenCamera:Boolean=false;
public var isUserIntraAlertDuringReconnection:Boolean = false;

public var defaultVideoWallLayout:String = Constants.PRESENTER_LAYOUT;
public var videoWallLayout:String = Constants.SIMPLE_LAYOUT;
public var prevVideoWallLayout:String = Constants.SIMPLE_LAYOUT;
public var isDuringModuleChange:Boolean =false;
public var isChangeModule:Boolean =false;
public var isLocalAudioVideoSettings = false; // local Audio/Video Settings
public var byteStrength:int = 0;
public var writeFile:int = 0;
public var totalLogInActivity:ArrayCollection = new ArrayCollection;
public var startPresenterTime:Number;
public var startViewerTime:Number;
public var previousCbps:String= "0";
public var previousViewerCbps:String = "0";
public var previousDroppedFrames:String = "0";
public var startingTime:String = ""; 
public var removedUsersArray:ArrayCollection = new ArrayCollection;
private var startCaptureTimeOutID:uint;
private var isPeopleCountCalled:Boolean = true;
applicationType::DesktopWeb{
	public var userNameInFile:String = ClassroomContext.userVO.userName;
}
applicationType::mobile{
	public var userNameInFile:String;
}
public var timeDate:Date = new Date;
public var fileTimeStamp:String = timeDate.time.toString();
public var countNum:int = 0;
private var peopleCountHelper:PeopleCountHelper;

[Bindable]
private var isPresenterLayout:Boolean = true;
private var isLayoutSOInitialized:Boolean = false;
private var spacerWidth:int;

applicationType::desktop{
	public var filePath:String= File.applicationStorageDirectory.nativePath;
}
applicationType::DesktopWeb{
	public var cameraDeviceType:String=Constants.CAM_TYPE_WEBCAM;
	public var isFMLE:Boolean=false;
}
applicationType::mobile{
	public var cameraDeviceType:String=Constants.CAM_TYPE_WEBCAM;
	public var isFMLE:Boolean=false;
}

public var cameraResolution:String="";

public var cameraVideoQuality:int=0;

public var FPS:int=12;

public var keyFrames:int=12;

public var h264Profile:String="BaseLine";

public var h264ProfileValue:int=3;

public var isAdvancedSettingsChecked:Boolean = false;

public var currentContainer:UIComponent;
public var iVideoWallLayout:IVideoWallLayout =null;
public var sideLayout:IVideoWallLayout;
public var discussionLayout:IVideoWallLayout
public var presentationLayout:IVideoWallLayout
applicationType::DesktopWeb{
	public var currentPresenterDisplay:VideoStreamDisplay
	public var buttonContainer:ButtonContainer;
}
public var viewersDisplays:ArrayCollection;
public var sideBarUIComp:viewerVideoTile; //Left side container
public var videoWallUIComp:UIComponent;
private var isPopOutPresent:Boolean = false;
private var isConnectionDuringLogin:Boolean = true;
public var bigScreenStreamName:String;
public var bigScreenName:String;


[Bindable]
public var videoWallLayoutStatus:String = '';
/**Platform specific variables*/
//Fix for issue  #9006; Flag to set flash player privacy setting
applicationType::web{
	//To set the flag for view video when Presenter viewing viewer view video in full screen.
	public var isViewVideoInFullscreen:Boolean = false;
	//Set flag for video status (Play/Pause)
	public var isVideoStopped:Boolean;
	//To hold user name
	public var userName:String;
	//Flag to identify selected viewer video localconnection is connected or not
	[Bindable]
	public var viewerLocalConnectionIsConnected:Boolean = false;
	//Flag to identify Presenter video localconnection is connected or not
	[Bindable]
	public var presenterLocalConnectionIsConnected:Boolean = false;
	//Flag to identify Presenter video pop out localconnection is connected or not
	[Bindable]
	public var childVideoConnectionIsConnected:Boolean = false;
	//Set connection name for localConnection 
	[Bindable]
	public var connectionName:String;
	//Unique id for localConnection
	public var uniqueID:String;
	//To hold Selected viewer fullscreen details 
	public var selectedViewerFullScreen:ArrayCollection = new ArrayCollection();
	//To hold fullscreen video status 
	public var videoFullscreenStatus:String;
	//To store video fullscreen details
	private var lsoFullscreenDetails:SharedObject;
	//To hold stream name
	private var streamName:String;
	//To hold user type
	private var userType:String;
	//Array to store connection name 
	public var connectionNameArray:Array = new Array();
	// Flag to set flash player privacy setting
	public var isAllow:Boolean = false;
	//This variable holds presenter video path
	private var presenterPopOutVideoPath:String;
	//This variable holds presenter stream name
	private var presenterPopOutStreamName:String;
	//This variable holds presenter full name
	private var presenterPopOutUserFullName:String;
	//This variable holds presenter push to talk status
	private var presenterPopOutReceiveAudio:String;
	//This variable holds userRole of presenter
	private var presenterPopOutUserType:String;
	//This boolean variable holds whether presenter starts his/her video in audio only mode or audio/video mode
	private var presenterPopOutIsAudioOnly:Boolean;
	//This boolean variable holds presenter
	private var presenterPopOutIsViewer:Boolean;
	//This variable holds userRole of user
	private var presenterPopOutPublishingBandwidth:int;
	//To call function after a specified delay
	private var setTimeOutIDPopout:uint;
	//This variable holds whether reconnection happened or not, while presenter popout window is existing
	public var isVideoReconnected:Boolean = false;
	//Local connection object to send Selected viewer video details to child window.
	[Bindable]
	public var viewerVideoLocalConnection:LocalConnection;
	//Local connection object to send Presenter video details to child window.
	public var presenterVideoLocalConnection:LocalConnection;
	//Local connection object to send Presenter video details to child window.
	public var childVideoLocalConnection:LocalConnection;
	//To hold PTT status
	[Bindable]
	public var presenterPttStatus:String;
	//To set flag for Presenter when user viewing Presenter video in full screen at first time
	public var isPresenterVideoInFullscreen:Boolean = false;
	//To set flag for Selected viewer when user viewing Selected viewer video in full screen at first time
	private var isFirstTimeSelectedViewerInFullscreen = false;
	//To store presenter video details to LSO for hiding values in address bar when users open the pop out window
	public var localSharedObject:SharedObject;
	//Fix for issue #19671
	public var isLocalVideoFullscreen:Boolean=false;
}

//NativeProcess not available for web.
applicationType::desktop{
	private var processLaunchScreenCamera:NativeProcess;
	private var processInternalCodecMultipleBitrateSlave:NativeProcess;
	private var processInternalCodecMultipleBitrateSlave2:NativeProcess;
	public var processAttachCam:NativeProcess;
	public var videoWallWindow:VideoWallPopOut = null;
}
applicationType::mobile{
	public var userAudioStrength:ArrayList = new ArrayList();
	private var alrdySelectedViewerArray:ArrayList = new ArrayList([{value:Constants.USER_HAS_BEEN_SELECTED}]);
	public var selectedUserArray:Array;
	public var selectedViewerDetails:ArrayCollection;
	public var isMaximumSelectedViewer:Boolean = false;
	public var isMessageDisplayed:Boolean = false;
	private var isSelectedViewerVideoStopped:Boolean = false;
	private var videoTabNavigationCount:int = 0;
	public var infoMessageDisplayCount:int = 0;
	public var isvideoPublished:Boolean = false;
	public var isRestrictionAdded:Boolean = false;
	private var playSelectedViewerVideo:Boolean = false;
	private var isVideoStoppedManually:Boolean = false;
	//Set to true when Presenter lost his video connection
	private var isPresenterVideoDisconnected:Boolean = false;
	//Set to true when Viewer lost his video connection
	private var isViewerVideoDisconnected:Boolean = false;
	//String variable for storing index of selected video driver.
	public var videoDeviceIndex:int=0;
	public var viewerStreamName:String="";
	public var studentVideo:Video;
	//String variable for storing the name of student who is selected by the teacher for interaction.
	public var fullScreenStudentTitle:String;
	public var objPresenterAudioOnlyMode:FullScreenLabel;
	public var objViewerAudioOnlyMode:Label = new Label();
	private var VIDEO_PAUSE_LABEL_TEACHER:Label = new Label();
	public var VIDEO_PAUSE_LABEL_STUDENT:Label = new Label();
	public var isSelectedViewerVideoPaused:Boolean=false;
	private var isStudentSelected:Boolean;
	//Array for storing the names of students in 'view video' mode.
	public var studentViewArray:Array=new Array();
	//Variable of type ArrayCollection for storing the student names in 'view' mode
	public var dpStudents:ArrayCollection;
	public var isPresenterVideoPaused:Boolean=false;
	public var currentSelectedViewer:String = "";
	//To set flag value when Presenter start his/her video
	public var isPresenterAdded:Boolean = false;
	//To set flag value when viewer selected
	public var isSelectedViewerAdded:Boolean = false;
	public var selectedViewer:String; 
	public var presenterStringVal:String;
	//String variable for storing the name of student who is selected previously by the viewer.
	public var previousSelecViewer:String;
	/**
	 * Variable of type Video for holding the video stream of presenter from FMS for All-in-one mode
	 */
	public var presenterVideo:Video = new Video();
	/**
	 * Variable of type Video for holding the video stream of selected viewer from FMS for All-in-one mode
	 */
	public var viewerVideo:Video= new Video();
	
	
}

/**
 * This function is for creating VideoConnection with MediaServer.This connection is maintained throughout the whole session.
 *
 *
 * @return void
 */
public function createVideoConnection(videoServersData:ArrayCollection):void{
	arrVideoConnections=new ArrayCollection();
	videoPresenterServerData, videoViewerServerData=new Array();
	if (Log.isDebug()) 		FlexGlobals.topLevelApplication.mainApp.log.debug("Video.createVideoConnection:- Entered");
	
	for (var i:int=0; i < videoServersData.length; i++){
		var ipExist:Boolean=false;
		for (var j:int=0; j < arrVideoConnections.length; j++){
			if (videoServersData[i].ip == arrVideoConnections[j].ip){
				ipExist=true;
				break;
			}
		}
		if (!ipExist){
			var obj_videoConnectionData:VideoConnectionData=new VideoConnectionData();
			obj_videoConnectionData.prevState="";
			obj_videoConnectionData.ip=videoServersData[i].ip;
			if(ClassroomContext.aviewClass.classType=="Meeting")
			{
				obj_videoConnectionData.connection=new VideoConnection(videoServersData[i].ip, ClassroomContext.protocolFMS, Constants.VIDEO_SERVER_MODULE_NAME, ClassroomContext.lecture.lectureId.toString(), ClassroomContext.userVO.userName);
			}
			else
			{
				obj_videoConnectionData.connection=new VideoConnection(videoServersData[i].ip, ClassroomContext.protocolFMS, Constants.VIDEO_SERVER_MODULE_NAME, ClassroomContext.aviewClass.className, ClassroomContext.userVO.userName);				
			}
			obj_videoConnectionData.connection.createConnection();
			arrVideoConnections.addItem(obj_videoConnectionData);
		}
		
		var presenterServerType:String = ClassroomContext.aviewClass.classType == "Meeting" ? Constants.MEETING_FMS_PRESENTER : Constants.FMS_PRESENTER;
		var viewerServerType:String = ClassroomContext.aviewClass.classType == "Meeting"? Constants.MEETING_FMS_VIEWER : Constants.FMS_VIEWER;
		if (videoServersData[i].serverType == presenterServerType)
			videoPresenterServerData[videoPresenterServerData.length]=videoServersData[i];
		else if (videoServersData[i].serverType == viewerServerType)
			videoViewerServerData[videoViewerServerData.length]=videoServersData[i];
		}
	
	connectionTimeOut = setInterval(checkVideoConnections, 3000);
	//createLayoutComponents();
}

applicationType::DesktopWeb{
	public function createLayoutComponents():void
	{
		sideLayout = classroomComponentSgl.viewersTile;
		discussionLayout = new MeetingVideoWall();
		presentationLayout = new VideoWall();
		videoWallUIComp = classroomComponentSgl.viewerVideoWallBox;
		/*sideWallUIComp = classroomComponentSgl.viewersTile;
		videoWallUIComp //Right side container
		popoutUIComp //Popout container
		Control buttons bar
		Create all layouts*/
		buttonContainer = new ButtonContainer();
		iVideoWallLayout = sideLayout;
	}
	
	private function connectVideoWallCollabObject():void{
		videoWallCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("videoWallSharedObject");
		videoWallCollaborationObject.setOnClear(onClearVideoWallCollabObject);
		videoWallCollaborationObject.setOnChangeProperty("selectedUser", onChangeSelectedUser);
		videoWallCollaborationObject.setOnChangeProperty("selectedStreamName", onChangeSelectedUser);
		videoWallCollaborationObject.setOnChangeProperty("isSelected", onChangeVideoWall);
		videoWallCollaborationObject.setOnChangeProperty("videoWallLayout", onChangeVideoWallLayOut);
		videoWallCollaborationObject.setOnChangeProperty("isChangeModule", onChangeModules);
		
	}
	
	
	private function closeVideoWallCollabObject():void{
		videoWallCollaborationObject.removeOnClear();
		videoWallCollaborationObject.removeOnChangeProperty("selectedUser");
		videoWallCollaborationObject.removeOnChangeProperty("selectedStreamName");
		videoWallCollaborationObject.removeOnChangeProperty("isSelected");
		videoWallCollaborationObject.removeOnChangeProperty("videoWallLayout");
		ClassroomContext.collaborationService.closeCollaborationObject("videoWallSharedObject");
	}
	private function buttonContainterClose(event:MouseEvent):void
	{
		videoWallLayout = Constants.SIMPLE_LAYOUT;
		if(classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			setDuringModuleChange(false);
			isDuringModuleChange = false;
			trace("buttonContainterClose");
			setVideoWallLayout(videoWallLayout);
		}
		else
		{ 
			layOutDataChange();
		}
	}
	
	private function buttonContainterFullscreen(event:MouseEvent):void
	{
		if(buttonContainer.isFullscreenPresent)
			iVideoWallLayout.closeFullScreenVideo();
		else
		{
			iVideoWallLayout.setFullScreenVideo();
			buttonContainer.fullScreen();
		}
	}
	public function changeFullscreenBtnStatus(event:VideoTileEvent=null):void
	{
		buttonContainer.fullScreen();
	}
}
private function buttonContainterHide(event:MouseEvent):void
{
}

private function buttonContainterPopOut(event:MouseEvent):void
{
	if(!isPopOutPresent)
	{
		applicationType::desktop{
			videoWallWindow = new VideoWallPopOut();
			videoWallWindow.open(true);
			videoWallWindow.maximize();
			iVideoWallLayout.setPopOutLayout(videoWallWindow);
			isPopOutPresent = true;
			buttonContainer.popOutWindow(isPopOutPresent);
			videoWallWindow.addEventListener(Event.CLOSE, popOutWindowCloseEvent);
			classroomComponentSgl.viewerVideoWallBox.removeAllChildren();
			setMessageForFullScreenForMXMLComponents(classroomComponentSgl.viewerVideoWallBox, Constants.FULLSCREEN_MSG);
		}
	}
	
	else
	{
		popOutWindowCloseEvent();
	}
}

private function popOutWindowCloseEvent(event:Event=null):void
{
	applicationType::desktop{
		if(iVideoWallLayout==null)
			return;
		videoWallWindow.close();
		iVideoWallLayout.setParentLayout();
		isPopOutPresent = false;
		buttonContainer.popOutWindow(isPopOutPresent);
		videoWallWindow.removeEventListener(Event.CLOSE, popOutWindowCloseEvent);
		unSetMessageForFullScreenForMXMLComponents(classroomComponentSgl.viewerVideoWallBox);
	}
}

applicationType::DesktopWeb{
	public function changeToVideoTab():void
	{
		if(classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			this._transitionToBaseState("btnShowViewersWall",6);
			setVideoWallLayout(prevVideoWallLayout);
		}
	}
	private function initializeLayout():void
	{
		if(videoWallLayout == prevVideoWallLayout)
			return;
		if(videoWallLayout!=prevVideoWallLayout)
			iVideoWallLayout.closeLayout(false);
		if(videoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			iVideoWallLayout = sideLayout;
			currentContainer = classroomComponentSgl.viewersTile;
		}
		else if(videoWallLayout == Constants.PRESENTER_LAYOUT)
		{
			iVideoWallLayout = presentationLayout;
			currentContainer = videoWallUIComp;
		}
		else if(videoWallLayout == Constants.MEETING_LAYOUT)
		{
			iVideoWallLayout = discussionLayout;
			currentContainer = videoWallUIComp;
		}
		if(!isPopOutPresent)
			iVideoWallLayout.initializeComponent(currentContainer, buttonContainer);
		if(videoWallLayout!=prevVideoWallLayout)
		{
			showPresenterVideoInVideoWall();
			showViewerComponentInVideoWall();
		}
		setTimeout(intializeBigScreen, 3000);
		prevVideoWallLayout = videoWallLayout;
		if(isConnectionDuringLogin && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName && videoWallLayout!=Constants.SIMPLE_LAYOUT)
		{
			//setActiveWindowInSO(0);
			//onChangeModule()
			//isConnectionDuringLogin = false;
		}
	
	}
	private function intializeBigScreen():void
	{
		if(videoWallCollaborationObject.getData()["selectedUser"]==null)
		{
			iVideoWallLayout.changeMainVideoInVideoWall(ClassroomContext.currentPresenterName,getPresenterStreamName());
		}
		else if (videoWallCollaborationObject.getData()["selectedUser"] != null)
		{
			iVideoWallLayout.changeMainVideoInVideoWall(videoWallCollaborationObject.getData()["selectedUser"], videoWallCollaborationObject.getData()["selectedStreamName"]);
		}
	}
	public function initilaizeVideoWallButtonComp():void
	{
		buttonContainer.btnClose.addEventListener(MouseEvent.CLICK, buttonContainterClose);
		buttonContainer.btnFullScreen.addEventListener(MouseEvent.CLICK, buttonContainterFullscreen);
		buttonContainer.btnShow.addEventListener(MouseEvent.CLICK, buttonContainterHide);
		buttonContainer.popOutBtn.addEventListener(MouseEvent.CLICK, buttonContainterPopOut);
		
	}
	public function onClearVideoWallCollabObject():void{
		settingVideoWallData();
	
		if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.videoWallSharedObjectSyncHandler: event.changeList[index].code==clear");
		if(videoWallCollaborationObject.getData()["videoWallLayout"]!=null)
		{
			videoWallLayout=videoWallCollaborationObject.getData()["videoWallLayout"];
			//prevVideoWallLayout = videoWallSharedObject.data["videoWallLayout"];
		}
		initializeLayout();
	}
	
	private function settingVideoWallData():void{
		isLayoutSOInitialized  = true;
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			lastSelectedUser=videoWallCollaborationObject.getData()["selectedUser"];
			lastSelectedStream=videoWallCollaborationObject.getData()["selectedStreamName"];
			videoWallSelected=videoWallCollaborationObject.getData()["isSelected"];
		} 
	}
	
	public function onChangeSelectedUser(newValue:String, oldValue:String, name:String):void{
		settingVideoWallData();
		if(videoWallLayout!=videoWallCollaborationObject.getData()["videoWallLayout"])
		{
			videoWallLayout=videoWallCollaborationObject.getData()["videoWallLayout"];
			layOutDataChange();
		}
		iVideoWallLayout.changeMainVideoInVideoWall(videoWallCollaborationObject.getData()["selectedUser"], videoWallCollaborationObject.getData()["selectedStreamName"]);
	}
	
	public function toggleVideoWallSelection(bool:Boolean):void
	{
		videoWallCollaborationObject.lock();
		videoWallCollaborationObject.setValue("isSelected",bool);
		videoWallCollaborationObject.flush();
		videoWallCollaborationObject.unlock();
	}
	public function setVideoWallSharedObjectData(propertyName:String, propertyValue:String):void
	{
		videoWallCollaborationObject.lock();
		videoWallCollaborationObject.setValue(propertyName, propertyValue);
		videoWallCollaborationObject.flush();
		videoWallCollaborationObject.unlock();
	}
	
	public function setVideoWallLayout(videoWallLayout:String):void
	{
		if(ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName && (prevVideoWallLayout == Constants.PRESENTER_LAYOUT || prevVideoWallLayout == Constants.MEETING_LAYOUT))
		{
			var isSameLayout:Boolean = false;
			if(videoWallCollaborationObject.getData()["videoWallLayout"] == Constants.SIMPLE_LAYOUT)
			{
				isSameLayout = true;
				setVideoWallSharedObjectData("videoWallLayout", null);
			}
			if(isSameLayout)
			{
				setVideoWallSharedObjectData("prevVideoWallLayout", prevVideoWallLayout);
			}
		}
		
		var userProperty = videoWallCollaborationObject.getData()["videoWallLayout"];
		if(userProperty == null)
		{
			if(ClassroomContext.aviewClass.classType == "Meeting")
				userProperty = Constants.MEETING_LAYOUT;
			else
				userProperty = Constants.PRESENTER_LAYOUT;
		}
		videoWallCollaborationObject.lock();
		if(userProperty != Constants.SIMPLE_LAYOUT)
			videoWallCollaborationObject.setValue("prevVideoWallLayout",userProperty);
		videoWallCollaborationObject.setValue("videoWallLayout",videoWallLayout);
		videoWallCollaborationObject.flush();
		videoWallCollaborationObject.unlock();
	}
	
	public function setDuringModuleChange(isChangeModule:Boolean){
		videoWallCollaborationObject.lock();
		videoWallCollaborationObject.setValue("isChangeModule",isChangeModule);
		videoWallCollaborationObject.flush();
		videoWallCollaborationObject.unlock();
	}
	
	public function setVideoWallSharedSO(isSelected:Boolean,selectedUser:String,selectedStream:String, videoWallLayout:String):void
	{
		videoWallCollaborationObject.lock();
		videoWallCollaborationObject.setValue("selectedUser",selectedUser);
		videoWallCollaborationObject.setValue("selectedStreamName",selectedStream);
		videoWallCollaborationObject.setValue("isSelected",isSelected);
		videoWallCollaborationObject.setValue("videoWallLayout",videoWallLayout);
		videoWallCollaborationObject.flush();
		videoWallCollaborationObject.unlock();
	}
	
	public function onChangeVideoWall(newValue:String, oldValue:String, name:String):void{
		settingVideoWallData();
		if (videoWallCollaborationObject.getData()["isSelected"] == false){
			if (videoWallLayout == Constants.PRESENTER_LAYOUT && ClassroomContext.currentPresenterName != ClassroomContext.userVO.userName){
				//toggleVideoWall();
			}
		}
	}
	public function onChangeModules(newValue:String, oldValue:String, name:String):void{
		
		isChangeModule=videoWallCollaborationObject.getData()["isChangeModule"];
		
	}
	
	private function layOutDataChange():void
	{
		if(videoWallLayout == prevVideoWallLayout)
			return;
		iVideoWallLayout.closeLayout(false);
		if(classroomComponentSgl.viewerVideoWallBox.numChildren > 0)
			classroomComponentSgl.viewerVideoWallBox.removeAllChildren();
		if(videoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			iVideoWallLayout = sideLayout;
			currentContainer = classroomComponentSgl.viewersTile;
		}
		else if(videoWallLayout == Constants.PRESENTER_LAYOUT)
		{
			iVideoWallLayout = presentationLayout;
			currentContainer = videoWallUIComp;
		}
		else if(videoWallLayout == Constants.MEETING_LAYOUT)
		{
			iVideoWallLayout = discussionLayout;
			currentContainer = videoWallUIComp;
		}
		if(isPopOutPresent && videoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			applicationType::desktop{
				videoWallWindow.close();
				isPopOutPresent = false;
				buttonContainer.popOutWindow(isPopOutPresent);
				videoWallWindow.removeEventListener(Event.CLOSE, popOutWindowCloseEvent);
				unSetMessageForFullScreen(classroomComponentSgl.viewerVideoWallBox);
			}
		}
		
		//Fix for issue #18511
		applicationType::web{
			//Fix for issue #19533
			if(getUserSO(ClassroomContext.userVO.userName) && getUserSO(ClassroomContext.userVO.userName).userRole){
				//Fix for issue #18576
				if(getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE){
					//Fix for issue #19795
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen && videoWallLayout == Constants.SIMPLE_LAYOUT){
						//To close video popout.
						ExternalInterface.call("closePopOuts");
					}
				}
			}
		}
		if(!isPopOutPresent)
			iVideoWallLayout.initializeComponent(currentContainer, buttonContainer);
		else
		{
			applicationType::desktop{
				videoWallWindow.vidWall.removeAllChildren();
				iVideoWallLayout.initializePopOutComponent(currentContainer, buttonContainer, videoWallWindow);
				setMessageForFullScreenForMXMLComponents(classroomComponentSgl.viewerVideoWallBox, Constants.FULLSCREEN_MSG);
			}
		}
		//Fix for issue #20171
		applicationType::web{
			if(videoWallLayout == Constants.PRESENTER_LAYOUT){
				//Fix for issue #20113
				iVideoWallLayout.resizeBaseContainer();
			}
			//Fix for issue #20186,3#20187 and #20188
			if(isVideoStopped){
				classroomComponentSgl.pnlTeacher.isVideoPaused=true;
			}
			else{
				classroomComponentSgl.pnlTeacher.isVideoPaused=false;
			}
		}
		iVideoWallLayout.addPresenterDisplay(classroomComponentSgl.pnlTeacher);
		//Fix for issue #17969
		applicationType::web{
			//Fix for issues #19795 and #19805
			if(isPresenterVideoInFullscreen){
				var presenterDisplay:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();				
				if(videoWallLayout == Constants.SIMPLE_LAYOUT){
					presenterDisplay.labelFullScreen.visible= true;
				}
			}
			else{
				//Fix for issue #19861
				if(getUserSO(ClassroomContext.userVO.userName) && getUserSO(ClassroomContext.userVO.userName).userRole){
					if(getUserSO(ClassroomContext.userVO.userName).userRole != Constants.PRESENTER_ROLE){
						if(videoWallLayout == Constants.SIMPLE_LAYOUT){
							addPresenterVideoInPresenterpanel();
						}
					}
				}
			}
		}
		showViewerComponentInVideoWall();
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
		if(videoWallCollaborationObject.getData()["selectedUser"]==null || videoWallCollaborationObject.getData()["selectedUser"]=="")
		{
			iVideoWallLayout.changeMainVideoInVideoWall(ClassroomContext.currentPresenterName,getPresenterStreamName());
		}
		else if (videoWallCollaborationObject.getData()["selectedUser"] != null)
		{
			iVideoWallLayout.changeMainVideoInVideoWall(videoWallCollaborationObject.getData()["selectedUser"], videoWallCollaborationObject.getData()["selectedStreamName"]);
		}
		}
		iVideoWallLayout.resizeVideoStreamDisplay();
		prevVideoWallLayout = videoWallLayout;
		
		setVideoWallMessage();
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE || ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
		{
			buttonContainer.btnVideoLayout.visible = true;
			buttonContainer.btnVideoLayout.includeInLayout = true;
			//Fix for issue #19796
			applicationType::desktop{
				buttonContainer.btnControls.width = 93;
				buttonContainer.expand.widthTo = 93;
				buttonContainer.colapse.widthFrom = 93;	
			}
			applicationType::web{
				buttonContainer.btnControls.width = 50;
				buttonContainer.expand.widthTo = 50;
				buttonContainer.colapse.widthFrom = 50;
			}
		}
		else
		{
			buttonContainer.btnVideoLayout.visible = false;
			buttonContainer.btnVideoLayout.includeInLayout = false;
			//Fix for issue #19796
			applicationType::desktop{
				buttonContainer.btnControls.width = 75;
				buttonContainer.expand.widthTo = 75;
				buttonContainer.colapse.widthFrom = 75;	
			}
			applicationType::web{
				buttonContainer.btnControls.width = 28;
				buttonContainer.expand.widthTo = 28;
				buttonContainer.colapse.widthFrom = 28;
			}
		}
	}
	
	private function setVideoWallMessage():void
	{
		if(videoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			if(selectedViewersData.length > 0)
				classroomComponentSgl.lblSelectedViewers.text="Selected Viewers:"
			else
				classroomComponentSgl.lblSelectedViewers.text="No Selected Viewer:";
		}
		else if(videoWallLayout == Constants.PRESENTER_LAYOUT || videoWallLayout == Constants.MEETING_LAYOUT)
		{
			if(selectedViewersData.length > 0)
				classroomComponentSgl.lblSelectedViewers.text="Selected Viewers on Video Wall:"
			else
				classroomComponentSgl.lblSelectedViewers.text="No Selected Viewer:";
		
		}
	}
	
	public function onChangeVideoWallLayOut(newValue:String, oldValue:String, name:String):void{
		settingVideoWallData();
		if(videoWallCollaborationObject.getData()["videoWallLayout"] == Constants.SIMPLE_LAYOUT && isChangeModule && isPopOutPresent){
			return;
		}
		videoWallLayout=videoWallCollaborationObject.getData()["videoWallLayout"];
		layOutDataChange();
		if(videoWallLayout!=null)
			prevVideoWallLayout = videoWallLayout;
		isVideoWallSOReconnected = false;
		
	}
	
	
}
public function onChangeModule():void
{
	if(videoWallLayout != Constants.SIMPLE_LAYOUT && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName){
		isDuringModuleChange = true;
		videoWallLayout = Constants.SIMPLE_LAYOUT;
		//videoWallCollaborationObject.setValue("videoWallLayout",videoWallLayout);
		applicationType::DesktopWeb{
			setDuringModuleChange(true);
			setVideoWallLayout(videoWallLayout);
		}                 
	}
}

public function hideVideoCall(isHide:Boolean):void{
	for (var j:int=0; j < arrVideoConnections.length; j++){
		arrVideoConnections[j].connection.callHideVideo(isHide);
		setLocalVideoStatus(ClassroomContext.userVO.userName, isHide);
	}		
}

public function muteAudioCall(isMute:Boolean):void{
	for(var i:int=0; i < arrVideoConnections.length; i++){
		arrVideoConnections[i].connection.callMuteAudio(isMute);
		setLocalAudioStatus(ClassroomContext.userVO.userName, isMute);
	}
}

public function callSetLocalAudioVideo(isMute:Boolean, isHide:Boolean):void{
	setLocalVideoStatus(ClassroomContext.userVO.userName, isHide);
	setLocalAudioStatus(ClassroomContext.userVO.userName, isMute);
	
	if (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT){ 
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE && isHide)
			stopCapture(Constants.PRESENTER_ROLE);
		else
			startCapture(Constants.PRESENTER_ROLE);
		}
	
	if (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT){
		if (classroomContextObj.userRole  == Constants.VIEWER_ROLE && isHide )
			stopCapture(Constants.VIEWER_ROLE);
		else
			startCapture(Constants.VIEWER_ROLE);
	}
}
public function hideAndMute(userName:String, userRole:String, userStatus:String, isVideoHide:Boolean, isAudioMute:Boolean, isAudioOnlyMode:Boolean):void{
	if(userRole == Constants.PRESENTER_ROLE && userStatus == Constants.ACCEPT ){
		applicationType::DesktopWeb{
			var presenterDisplay:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
			showViewVideo(isAudioOnlyMode,isVideoHide,isAudioMute,presenterDisplay);
		}
		applicationType::mobile{
			showViewVideo(isAudioOnlyMode,isVideoHide,isAudioMute,Constants.PRESENTER_ROLE);
		}
	}
	else{ 
		applicationType::DesktopWeb{
			for (var i:int=0; i < selectedViewerDisplays.length; i++){
				var videoStreamDisplay:VideoStreamDisplay=selectedViewerDisplays[i] as VideoStreamDisplay;
				var viewerDisplay:VideoStreamDisplay=iVideoWallLayout.getViewerVideoStreamDisplay(videoStreamDisplay);
				if(viewerDisplay.userName == userName){
					showViewVideo(isAudioOnlyMode,isVideoHide,isAudioMute,viewerDisplay);
				}
			}
		}
		applicationType::mobile{
			for(var i:int=0; i<selectedViewersData.length; i++){
				if(currentSelectedViewer == userName){
					showViewVideo(isAudioOnlyMode,isVideoHide,isAudioMute,Constants.VIEWER_ROLE);
				}
			}
		}
	}
}
			
applicationType::DesktopWeb{
public function showViewVideo(isAudioOnlyMode:Boolean,isVideoHide:Boolean,isAudioMute:Boolean,hideLabelDisplay:VideoStreamDisplay):void{
	  	if(isAudioOnlyMode){
		if(isAudioMute == true){
			hideLabelDisplay.LabelHideAudioVideo.text ="";
			hideLabelDisplay.LabelHideAudioVideo.text ="Audio Muted";
			hideLabelDisplay.LabelHideAudioVideo.visible=true;
		}
		else{
			hideLabelDisplay.LabelHideAudioVideo.text ="";
			hideLabelDisplay.LabelHideAudioVideo.visible=false;
		}
		
	}
	else{
		if(isVideoHide){
			if(isAudioMute == true){
					hideLabelDisplay.LabelHideAudioVideo.text = "Audio/Video Stopped";
					hideLabelDisplay.LabelHideAudioVideo.visible = true;
					applicationType::desktop{
						if(hideLabelDisplay.videoFullScreenComp != null){
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.text = hideLabelDisplay.LabelHideAudioVideo.text;
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.visible = true;
						}
					}
					
			}
			else{
					hideLabelDisplay.LabelHideAudioVideo.text = "Video Stopped";
					hideLabelDisplay.LabelHideAudioVideo.visible = true;
					applicationType::desktop{
						if(hideLabelDisplay.videoFullScreenComp != null){
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.text = hideLabelDisplay.LabelHideAudioVideo.text;
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.visible = true;
						}
					}
				}
		}
		else if(isAudioMute){
			if(isVideoHide == true){
					hideLabelDisplay.LabelHideAudioVideo.text = "Audio/Video Stopped";
					hideLabelDisplay.LabelHideAudioVideo.visible = true;
					applicationType::desktop{
						if(hideLabelDisplay.videoFullScreenComp != null){
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.text = hideLabelDisplay.LabelHideAudioVideo.text;
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.visible = true;
						}
					}
			}
			else{
				if(hideLabelDisplay.isVideoPaused){
					hideLabelDisplay.LabelHideAudioVideo.text = "Audio/Video Stopped";
					hideLabelDisplay.LabelHideAudioVideo.visible = true;
				}
				else{
					hideLabelDisplay.LabelHideAudioVideo.text = "Audio Muted";
					hideLabelDisplay.LabelHideAudioVideo.visible = true;
					applicationType::desktop{
						if(hideLabelDisplay.videoFullScreenComp != null){
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.text = hideLabelDisplay.LabelHideAudioVideo.text;
							hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.visible = true;
						}
					}
				}
			}	
		}
		else{
			if(hideLabelDisplay.isVideoPaused){
				hideLabelDisplay.LabelHideAudioVideo.text = "Video Stopped";
				hideLabelDisplay.LabelHideAudioVideo.visible = true;
			}
			else{
				hideLabelDisplay.LabelHideAudioVideo.text = "";
				hideLabelDisplay.LabelHideAudioVideo.visible = false;
				applicationType::desktop{
					if(hideLabelDisplay.videoFullScreenComp != null){
						hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.text = hideLabelDisplay.LabelHideAudioVideo.text;
						hideLabelDisplay.videoFullScreenComp.LabelHideAudioVideo.visible = false;
					}
				}
				
			}	
		}
	}
	
}
}
applicationType::mobile{
	public function showViewVideo(isAudioOnlyMode:Boolean,isVideoHide:Boolean,isAudioMute:Boolean,userRole:String):void{
		if(isAudioOnlyMode){
			if(isAudioMute == true){
				if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
					if(userRole == Constants.PRESENTER_ROLE){
						pausePresenterAllinOneVideo("Audio Only Mode\nAudio Muted");
					}else{
						pauseViewerAllinOneVideo("Audio Only Mode\nAudio Muted");
					}
				}else{
					if(userRole == Constants.PRESENTER_ROLE){
						videoPause_notification("Audio Only Mode\nAudio Muted");
					}else{
						videoPause_studentNotification("Audio Only Mode\nAudio Muted");
					}
				}
			}
			else{
				if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
					
					if(userRole == Constants.PRESENTER_ROLE){
						pausePresenterAllinOneVideo("Audio Only Mode");
					}else{
						pauseViewerAllinOneVideo("Audio Only Mode");
					}
				}else{
					
					if(userRole == Constants.PRESENTER_ROLE){
						videoPause_notification("Audio Only Mode");
					}else{
						videoPause_studentNotification("Audio Only Mode");
					}
				}
			}
			
		}
		else{
			if(isVideoHide){
				if(isAudioMute == true){
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
						if(userRole == Constants.PRESENTER_ROLE){
							pausePresenterAllinOneVideo("Audio/Video Stopped");
						}else{
							pauseViewerAllinOneVideo("Audio/Video Stopped");
						}
					}else{
						
						if(userRole == Constants.PRESENTER_ROLE){
							videoPause_notification("Audio/Video Stopped");
						}else{
							videoPause_studentNotification("Audio/Video Stopped");
						}
					}
					
				}
				else{
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
						if(userRole == Constants.PRESENTER_ROLE){
							pausePresenterAllinOneVideo("Video Stopped");
						}else{
							pauseViewerAllinOneVideo("Video Stopped");
						}
					}else{
						if(userRole == Constants.PRESENTER_ROLE){
							videoPause_notification("Video Stopped");
						}else{
							videoPause_studentNotification("Video Stopped");
						}
					}
				}
			}
			else if(isAudioMute){
				if(isVideoHide == true){
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
						if(userRole == Constants.PRESENTER_ROLE){
							pausePresenterAllinOneVideo("Audio/Video Stopped");
						}else{
							pauseViewerAllinOneVideo("Audio/Video Stopped");
						}
					}else{
						if(userRole == Constants.PRESENTER_ROLE){
							videoPause_notification("Audio/Video Stopped");
						}else{
							videoPause_studentNotification("Audio/Video Stopped");
						}
					}
				}
				else{
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
						
						if(userRole == Constants.PRESENTER_ROLE){
							pausePresenterAllinOneVideo("Audio Muted");
						}else{
							pauseViewerAllinOneVideo("Audio Muted");
						}
					}else{
						if(userRole == Constants.PRESENTER_ROLE){
							if(FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon){
								videoPause_notification("Audio/Video Stopped");
							}else{
								videoPause_notification("Audio Muted");
							}
						}else{
							videoPause_studentNotification("Audio Muted");
						}
					}
				}	
			}
			else{
				if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
					//pauseViewerAllinOneVideo("Video Stopped");
					if(userRole == Constants.PRESENTER_ROLE){
						removePausePresenterLabel();
					}else{
						removePauseViewerLabel();
					}
				}else{
					if(userRole == Constants.PRESENTER_ROLE){
						if(FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon){
							videoPause_notification("Video Stopped");
						}else{
							videoUnPauseNotification();
						}
					}else{
						if(FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon){
							videoPause_studentNotification("Video Stopped");
						}else{
							videoUnPauseStudentNotification();
						}
					}
				}
			}
		}
		
	}
}	
applicationType::DesktopWeb{
	public function callSetLocalAudioVideoSettings():void{
		isLocalAudioVideoSettings = true;
		setSetting();
	}
	public function callContinueRestart():void{
		stopBlink(classroomComponentSgl.btnRecord, blinkTimerIntervalForRecordBtn);
		var timer:int = 3000;
		stopPublish();
		classroomComponentSgl.btnStart.enabled = false;
		if (ClassroomContext.aviewClass.videoCodec =="VP6"){
			timer = 15000;
		} 
		setTimeout(enableStart, timer);
	}
	public function enableStart():void{
		classroomComponentSgl.btnStart.enabled = true;
		publishVideo();
	}
}

public function controlVideoPublishingOnStatusChange(currentRole:String, currentStatus:String, previousRole:String, previousStatus:String):void{
	if (Log.isInfo())		FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange Entered:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus);
	//Socket communicatin code to start/stop publishing to the server
	//Works only in windows
	//Removed OS check logic to start/stop video publishing process for web.
	applicationType::web{
		if (ClassroomContext.aviewClass.videoCodec != "VP6"){
			controlVideoPublishingOnStatusChangeHanlder(currentRole, currentStatus, previousRole, previousStatus);
		}
	}
	applicationType::mobile{
		if (ClassroomContext.aviewClass.videoCodec != "VP6"){
			controlVideoPublishingOnStatusChangeHanlder(currentRole, currentStatus, previousRole, previousStatus);
		}
	}
	applicationType::desktop{
		if ((Capabilities.os.toLowerCase().indexOf("win") > -1 || (Capabilities.os.toLowerCase().indexOf("mac") > -1 && ClassroomContext.aviewClass.videoCodec != "VP6"))){
			controlVideoPublishingOnStatusChangeHanlder(currentRole, currentStatus, previousRole, previousStatus);
		}
	}
}
//RTCR: Need to change function name
public function controlVideoPublishingOnStatusChangeHanlder(currentRole:String, currentStatus:String, previousRole:String, previousStatus:String):void{
	if ((currentRole == Constants.VIEWER_ROLE) && ((previousRole == Constants.VIEWER_ROLE) || previousRole == null)){
		if (((previousStatus == Constants.ACCEPT) || (previousStatus == Constants.WAITING)) && (currentStatus == Constants.HOLD)){
			if (!beingViewed)// && ClassroomContext.aviewClass.isMultiBitrate != "Y")
			{
				stopCapture(Constants.VIEWER_ROLE);
			}
			applicationType::DesktopWeb{
				stopSelectedViewersStream(ClassroomContext.userVO.userName, false);
			}
			applicationType::mobile{
				stopSelectedViewersStream(ClassroomContext.userVO.userName);
			}
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange 1:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
		}
		else if (currentStatus == Constants.ACCEPT){
			applicationType::DesktopWeb{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE){
					stopCapture(Constants.PRESENTER_ROLE);
					startCaptureTimeOutID=setTimeout(callStartViewerCaptureHandler,200);
				}else
					startCapture(Constants.VIEWER_ROLE);
			}
			applicationType::mobile{
				startCapture(Constants.VIEWER_ROLE);
			}
			beingViewed=false;
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange 2:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
		}
	}
	else if ((currentRole == Constants.PRESENTER_ROLE) && (previousRole == Constants.VIEWER_ROLE || previousRole == null)){
		beingViewed=false;
		if ((currentStatus == Constants.ACCEPT) && ((previousStatus == Constants.HOLD) || (previousStatus == Constants.WAITING) || previousStatus == null)){
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange Calling Start Capture:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
			startCapture(Constants.PRESENTER_ROLE);
		}
		else if ((currentStatus == Constants.ACCEPT) && (previousStatus == Constants.ACCEPT)){
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange Calling StopCapture & StartCapture:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
			applicationType::DesktopWeb{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE){
					stopCapture(Constants.VIEWER_ROLE);
					startCaptureTimeOutID=setTimeout(callStartPresenterCaptureHandler,200);
				}else{
					stopCapture(Constants.VIEWER_ROLE);
					startCapture(Constants.PRESENTER_ROLE);
				}
			}
			applicationType::mobile{
				stopCapture(Constants.VIEWER_ROLE);
				startCapture(Constants.PRESENTER_ROLE);
			}
		}
	}
	else if (currentRole == Constants.PRESENTER_ROLE && previousRole == Constants.PRESENTER_ROLE){
		//Just ensure that presenter is publishing.
		//Some times only if the video connection is reconnected but the users connection is not reconnected, that presenter's video is not republishing
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange Calling Start Capture:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
		startCapture(Constants.PRESENTER_ROLE);
		if (videoWallLayout!=Constants.SIMPLE_LAYOUT && !isPresenterStreams && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName && getUserSO(ClassroomContext.userVO.userName) && getUserSO(ClassroomContext.userVO.userName).isVideoPublishing){
			startPresentersStream();
		}
	}
	else if (currentRole == Constants.VIEWER_ROLE && !isRefreshPressed && previousRole == Constants.PRESENTER_ROLE){
		//Fix for issue when moderator take back the presenter control, in multi bitrate class teacher user video is stopped.
		
		applicationType::DesktopWeb{
			//if((ClassroomContext.aviewClass.isMultiBitrate != "Y" || (ClassroomContext.aviewClass.isMultiBitrate == "Y" && ClassroomContext.userVO.role != Constants.TEACHER_TYPE)) && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE){
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE){
			stopCapture(Constants.PRESENTER_ROLE);
				if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange 5:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
			}
		}
		applicationType::mobile{
		//	if(ClassroomContext.aviewClass.isMultiBitrate != "Y" || (ClassroomContext.aviewClass.isMultiBitrate == "Y" && ClassroomContext.userVO.role != Constants.TEACHER_TYPE)){
				stopCapture(Constants.PRESENTER_ROLE);
				if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.controlVideoPublishingOnStatusChange 5:- currentRole :" + currentRole + ", previousRole :" + previousRole + ", currentStatus :" + currentStatus + ", previousStatus :" + previousStatus)
			//}
		}
	}
}
private function callStartViewerCaptureHandler():void
{
	clearTimeout(startCaptureTimeOutID);
	startCapture(Constants.VIEWER_ROLE);
}
private function callStartPresenterCaptureHandler():void
{
	clearTimeout(startCaptureTimeOutID);
	startCapture(Constants.PRESENTER_ROLE);
}
public function keyDown_track(event:KeyboardEvent):void{
	
	if (event.ctrlKey && event.keyCode == Constants.SHORTCUT_KEY_PTT){
		AuditContext.userAction.keyBoardShortcutEventLog("Ctrl+" + event.keyCode.toString(), "PushToTalk");
		if (latestAudioMute_COData != null && latestAudioMute_COData != Constants.FREETALK){
			applicationType::DesktopWeb{
				actionButtons.btnTalk.addEventListener(MouseEvent.CLICK, actionButtons.talkMute);
			}
		}
	}
	
	
}

/**
 * Function for handling the onUnpublish callback from FMS.
 *
 *
 * @return void
 * @see null.
 */
public function stoppedStreamHandler():void{
	
	//START-------------------------------
	//call stopPublishing.
	//Check if the record has been started
	//If yes,then display a message to save the recording
	//Else,then display a message to restart the video stream
	//END------------------------------------------------
	//  multiple mode UI 
	
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stoppedStreamHandler:- Entered");
	// stops publishing audio-video  of the user to FMS
	stopPublish();
	
	// checks whether 'Record' button is pressed or not 
	/*if (record.RecordingFlag == 1){
		Alert.show("The video stream to the server is stopped. Please click OK to save the recording", "Alert", Alert.OK, null, listner);
	}*/
	// bug 91
	// In multi window mode, we do not want to show the alert more than once. If the video window is not existing,
	// that means, that alerts has already been shown.
	//else if (FlexGlobals.topLevelApplication.mainApp.savedOption == FlexGlobals.topLevelApplication.mainApp.modearr[1])
	applicationType::DesktopWeb{
		var tempAlertComp:Alert;
		tempAlertComp=Alert.show("Please check whether the camera is available for the application or check whether there is enough bandwidth for streaming video.\nIf bandwidth is less please stream with \n'audio only' option.", "Alert");
		tempAlertComp.width=320;
		tempAlertComp.height=160;
	}
}
public function stopPlayingStreams():void{
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopPlayingStreams:- Entered with isStreamPlaying :" + isStreamPlaying.toString() + ":");
	if (isStreamPlaying){
		isStreamPlaying=false;
		stopPresentersStream();
		applicationType::DesktopWeb{
			clearAllViewerStreamDisplays(selectedViewerDisplays);
			clearAllViewerStreamDisplays(viewedViewerDisplays);
			if (iVideoWallLayout.getMainDisplay()!=null){
				iVideoWallLayout.getMainDisplay().clearDisplay();
			}
		}
	}
}
	
applicationType::DesktopWeb{
	private function startPlayingViewStreams():void{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.startPlayingViewStreams:- Entered");
		if (getUserSO(ClassroomContext.userVO.userName) && (getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE || ClassroomContext.userVO.role == Constants.MONITOR_TYPE) && viewedViewerDisplays.length > 0){
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.startPlayingViewStreams:- Starting the steams for displays ");
			for (var i:int=0; i < viewedViewerDisplays.length; i++){
				var display:VideoStreamDisplay=viewedViewerDisplays[i] as VideoStreamDisplay;
				display.getUserSOStatus=getUserSO;
				display.startStream();
				setViewerVideoDisplaySize(display, false);
			}
		}
		else if (!getUserSO(ClassroomContext.userVO.userName)){
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.startPlayingViewStreams:- User Status is not found:");
		}
		else if (!(getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE)){
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.startPlayingViewStreams:- User role is not presenter role:");
		}
		else{
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.startPlayingViewStreams:- viewedViewerDisplays.length:" + viewedViewerDisplays.length);
		}
	}
	
	
	//signalToAdminTimerCounter allows us to send the message to Admin only once in several timer events to save on the cpu processing..  
	private var signalToAdminTimerCounter:int=90;
	//For so many timer calls, we will send the message to Admin once..
	private var SIGNAL_TO_ADMIN_THRESHOLD:int=100;
	
	
	
	private function addSignalSrength(strenght:Number):void
	{
		VideoStreamDisplay.STREAM_STRENGTH_CALCULATION_COUNT++;
		VideoStreamDisplay.STREAM_STRENGTH_SUM+=strenght;
	}
	
	public function checkStreamSignalStrength():void{
		
		var mainTileDisplay:VideoStreamDisplay=null;
		var activityLogInUser:ArrayCollection = new ArrayCollection;
		var streamName:String;
		var userName:String = "";
		byteStrength++;
		writeFile++;
		if (iVideoWallLayout.getMainDisplay() != null){
			mainTileDisplay=iVideoWallLayout.getMainDisplay();
			mainTileDisplay.calculateSignalStrengthValues();
		}
		if (ClassroomContext.currentPresenterName && getUserSO(ClassroomContext.currentPresenterName) != null)
		{
			var presenterDisplay:VideoStreamDisplay = classroomComponentSgl.pnlTeacher;
			if(mainTileDisplay == null || (mainTileDisplay != null && mainTileDisplay.userName!= presenterDisplay.userName))
				presenterDisplay.calculateSignalStrengthValues();
			if(byteStrength == 10 && ((videoWallLayout != Constants.SIMPLE_LAYOUT && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName)||ClassroomContext.userVO.userName != ClassroomContext.currentPresenterName)){
				
				var presenterVideoDisplay:VideoStreamDisplay = iVideoWallLayout.getPresenterVideoStreamDisplay();
				if(getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing){
					userName = presenterVideoDisplay.userName;
					if(presenterVideoDisplay)
					activityLogInUser = presenterVideoDisplay.calculateLogInActivity();
					for (var i:int=0; i < totalLogInActivity.length; i++)	
					{
						var temp:Object = totalLogInActivity[i];
						
						streamName = presenterVideoDisplay.userName;
						
						if (temp.streamName == streamName && activityLogInUser.length != 0)
						{
							previousCbps = temp.cbps;
							temp.cbps = previousCbps +"," + activityLogInUser[0].cbps;
							trace("previousCbps "+previousCbps+" activityLogInUser[0].cbps "+activityLogInUser[0].cbps)
							/*temp.cbps = previousCbps + "," + activityLogInUser[0].cbps;
							previousCbps = temp.cbps;*/
							previousDroppedFrames = temp.droppedFrames;
							temp.droppedFrames = previousDroppedFrames +"," + activityLogInUser[0].droppedFrames;
							/*temp.droppedFrames = previousDroppedFrames +","+ activityLogInUser[0].droppedFrames;	
							previousDroppedFrames = temp.droppedFrames;*/
							break;
							//trace("temp.cbps =" +temp.cbps+  " temp.droppedFrames=" +temp.droppedFrames);
						}
					}
				}
			}
			
		}
		if (selectedViewersData.length != 0){
			for (var j:int=0; j < selectedViewerDisplays.length; j++)
			{
				if(mainTileDisplay == null || (mainTileDisplay != null && mainTileDisplay.userName!= selectedViewerDisplays[j].userName))
					selectedViewerDisplays[j].calculateSignalStrengthValues();
				if(byteStrength == 10){
					var selectedViewerVideoDisplays:VideoStreamDisplay =  iVideoWallLayout.getViewerVideoStreamDisplay(selectedViewerDisplays[j]);
					if(getUserSO(selectedViewerVideoDisplays.userName).isVideoPublishing){
						userName = selectedViewerVideoDisplays.userName;
						activityLogInUser = selectedViewerVideoDisplays.calculateLogInActivity();
						
						//byteStrength = 0;
						for (var i:int=0; i < totalLogInActivity.length; i++)	
						{
							var temp:Object = totalLogInActivity[i];
							streamName = selectedViewerVideoDisplays.userName+Constants.VIEWER_APPEND_NAME;
							if (temp.streamName == streamName && activityLogInUser.length != 0)
							{
								//
								previousCbps = temp.cbps;
								temp.cbps = previousCbps +"," + activityLogInUser[0].cbps;
								/*temp.cbps = previousCbps + "," + activityLogInUser[0].cbps;
								previousCbps = temp.cbps;*/
								previousDroppedFrames = temp.droppedFrames;
								temp.droppedFrames = previousDroppedFrames +"," + activityLogInUser[0].droppedFrames;
								/*temp.droppedFrames = previousDroppedFrames + "," + activityLogInUser[0].droppedFrames;	
								previousDroppedFrames = temp.droppedFrames;*/
								trace("viewercbps= " +temp.cbps);
								break;
							}
						}
					}
				}
			
			}
		}
		if(byteStrength == 10)
			byteStrength = 0;
		if(writeFile == 30){
			writeToFile();
			writeFile = 0;
		}
		if(isVideoPublished && ClassroomContext.aviewClass.videoCodec != "VP6")
		{
			var microPhoneCameraActivityLevel:String;
			var microPhoneActivityLevel:int = 0;
			var cameraActivityLevel:int = 0;
			
			microPhoneCameraActivityLevel = arrVideoConnections[0].connection.checkprogressBar(ClassroomContext.userVO.userName);	
			var activityLevel:Array = microPhoneCameraActivityLevel.split("_");
			microPhoneActivityLevel = activityLevel[0];
			cameraActivityLevel = activityLevel[1];
			myVideo.callLocalProgressBar(microPhoneActivityLevel, cameraActivityLevel);
		}
		else if(ClassroomContext.aviewClass.videoCodec == "VP6" && isVideoPublished)
			myVideo.displayStreamStrength.noSignal.visible=false;
		if (signalToAdminTimerCounter == SIGNAL_TO_ADMIN_THRESHOLD)
		{
			signalToAdminTimerCounter=0;
			//ASHCR -  need to look into this code
			//ClassroomContext.userDetails.presenterSignalPercentage=(presenterSignalPercentage > 100) ? 100 : presenterSignalPercentage;
			var avgViewerSignalPercentage:int=0;
			//ASHCR -  need to look into this code
			/*if (numViewersSignals > 0)
			{
				avgViewerSignalPercentage=totalViewerSignalPercentage / numViewersSignals;
			}*/
			ClassroomContext.userDetails.viewerSignalPercentage=(avgViewerSignalPercentage > 100) ? 100 : avgViewerSignalPercentage;
			//adminConsoleCollabObject.setValue(ClassroomContext.userVO.userName, null);
			adminConsoleCollabObject.setValue(ClassroomContext.userVO.userName, ClassroomContext.userDetails);
		}
		else
		{
			signalToAdminTimerCounter++;
		}
	}
}

//Go over all the video connection object for each one get the status
private function checkVideoConnections():void{
	//	if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video: checkVideoConnections");
	var streamUnPublish:Boolean=false;
	var isConnectionRejected:Boolean=false;
	var isConnectionMaxTry:Boolean=false;
	ClassroomContext.videoConnectedCount=0;
	ClassroomContext.videoReconnectingCount=0;
	applicationType::DesktopWeb{
		checkStreamSignalStrength();
	}
	applicationType::mobile{
		var tempStudentConnection:VideoConnection=getViewersVideoConnection();
		//Check whether moderator/Presenter video connection is exist.
		if(ClassroomContext.currentPresenterName || ClassroomContext.currentPresenterName != ""){
			if(getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT){
				var presenterVideiStrength:int = tempStudentConnection.streamStrength(ClassroomContext.currentPresenterName);
				if(presenterVideiStrength<=0){
					isPresenterVideoDisconnected = true;
				}else{
					isPresenterVideoDisconnected = false;
				}
			}
		}
		//Check whether Selected viewer video connection is exist.
		if(currentSelectedViewer != ""){
			if(getUserSO(currentSelectedViewer)!=null && getUserSO(currentSelectedViewer).userStatus!= null && getUserSO(currentSelectedViewer).userStatus == Constants.ACCEPT){
				var viewerVideiStrength:int = tempStudentConnection.streamStrength(viewerStreamName);
				if(viewerVideiStrength<=0){
					isViewerVideoDisconnected = true;
				}else{
					isViewerVideoDisconnected = false;
				}
			}else if(getUserSO(currentSelectedViewer)==null || getUserSO(currentSelectedViewer).userStatus== null){
				stopSelectedViewersStream(currentSelectedViewer);
			}
		}
		//To get user's audiStrength and update selectedViewer list
		if(selectedViewersData.length != 0){
			for(var j:int=0; j<selectedViewersData.length; j++){
				var userName:String = selectedViewersData[j].userName;
				if(getUserSO(userName)!=null){
					if(selectedViewersData.length ==1){
						if(FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo){
							FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo.enabled = false;
							if(FlexGlobals.topLevelApplication.videoComp.selectedViewer.isOpen){
								FlexGlobals.topLevelApplication.videoComp.selectedViewer.close();
							}
						}
					}
					
				}
			}
		}else{//To disable the selected viewerList when there is no selected viewer.
			if(FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo){
				FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo.enabled = false;
				if(FlexGlobals.topLevelApplication.videoComp.selectedViewer.isOpen){
					FlexGlobals.topLevelApplication.videoComp.selectedViewer.close();
				}
			}
		}
	}
	for (var i:int=0; i < arrVideoConnections.length; i++){
		var netStatusValue:String=arrVideoConnections[i].connection.getNetConnectionStatus();
		
		if (arrVideoConnections[i].prevState != netStatusValue){
			//if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.checkVideoConnections:- " + arrVideoConnections[i].ip + ", " + netStatusValue + " NetConnection connected:" + arrVideoConnections[i].connection.ncVideo.netConnection.connected + ":");
		}
		
		switch (netStatusValue){
			case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
				//STatus should reflect total succes, total retry
				ClassroomContext.videoConnectedCount++;
				isStreamPlaying=true;
				
				//Create one more variable to check for the init here and call only once.
				if (arrVideoConnections[i].prevState != netStatusValue){
					if (ClassroomContext.videoConnectionFirstTime){
						applicationType::DesktopWeb{
							getvideo_intial();
						}
						ClassroomContext.videoConnectionFirstTime=false;
					}
					else{
						var evt:SyncEvent;
						usersSyncHandler(evt);
					}
					startPlayingViewStreams();
				}
				
				break;
			
			case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
				isConnectionRejected=true;
				
				break;
			
			// The connection to FMS was closed. 
			case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
				applicationType::DesktopWeb{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp){
						ClassroomContext.videoReconnectingCount++;
						//STatus should reflect total succes, total retry
						//updateStatusbar({module: "video", connectionStatus: false});
						//activate is for windows and we don't have any windows for web.
						// Activate main application, if it is minimized 
						applicationType::desktop{
							FlexGlobals.topLevelApplication.activate();
						}
						previousUsers_SO.splice(0);
						stopPlayingStreams();
						if (muiAlert != null){
							PopUpManager.removePopUp(muiAlert);
							muiAlert=null;
							isMUISelected=true;
							actionButtons.isMUISelected = true;
						}
						
						if (!isConnectionRejected && !ClassroomContext.isDuplicateLogin){
							//Check for isMaxConnectionReached method
							//If one reaches then close
							if (arrVideoConnections[i].connection.isMaxRetrysReached){
								if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.checkVideoConnections:- " + arrVideoConnections[i].ip + ", NetConnection.Connect.Closed, MaxRetry:" + arrVideoConnections[i].connection.isMaxConnectionReached());
								isConnectionMaxTry=true;
							}
						}
					}
					else
						; //PNCR: please check whether it is required.
				}
				//Fix for issue #20093
				applicationType::web{
					if(classroomComponentSgl.isFullScreen){
						classroomComponentSgl.fullScreenSelected();
					}
				}
				applicationType::mobile{
					previousUsers_SO.splice(0);
					stopPlayingStreams();
					if (!isConnectionRejected && !ClassroomContext.isDuplicateLogin){
						//Check for isMaxConnectionReached method
						//If one reaches then close
						if (arrVideoConnections[i].connection.isMaxRetrysReached){
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.checkVideoConnections:- " + arrVideoConnections[i].ip + ", NetConnection.Connect.Closed, MaxRetry:" + arrVideoConnections[i].connection.isMaxConnectionReached());
							isConnectionMaxTry=true;
						}
					}
				}
				break;
			
			case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
				ClassroomContext.videoReconnectingCount++;
				previousUsers_SO.splice(0);
				applicationType::DesktopWeb{
					stopPlayingStreams();
				}
				if (!isConnectionRejected && !ClassroomContext.isDuplicateLogin){
					//Check for isMaxConnectionReached method
					//If one reaches then close
					if (arrVideoConnections[i].connection.isMaxConnectionReached()){
						if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.checkVideoConnections:- " + arrVideoConnections[i].ip + ", NetConnection.Connect.Failed, MaxRetry:" + arrVideoConnections[i].connection.isMaxConnectionReached());
						isConnectionMaxTry=true;
					}
				}
				applicationType::DesktopWeb{
					if (muiAlert != null){
						PopUpManager.removePopUp(muiAlert);
						muiAlert=null;
						isMUISelected=true;
						actionButtons.isMUISelected = true;
					}
				}
				break;
			
			
			default:
				break;
		}
		arrVideoConnections[i].prevState=netStatusValue;
		if (arrVideoConnections[i].connection.streamUnPublish){
			arrVideoConnections[i].connection.streamUnPublish=false;
			streamUnPublish=true;
		}
		
	}
	if (isConnectionRejected){
		//Even if a single connection is rejected
		if (!closeAlertIssued){
			closeAlertIssued=true;
			Alert.show("Connection Rejected", "WARNING", 0, null, closeapp_error);
		}
	}
	else if (isConnectionMaxTry){
		if (!closeAlertIssued){
			closeAlertIssued=true;
			Alert.show("Video connection to the server could not be established.\n" + " Please login again.", "Alert", 0, null, closeapp_error);
		}
	}
	else if (streamUnPublish){
		applicationType::DesktopWeb{
				//stoppedStreamHandler();
		}
	}
	//	if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video: isConnectionRejected " + isConnectionRejected+" isConnectionMaxTry "+isConnectionMaxTry +" streamUnPublish "+streamUnPublish.toString());
	applicationType::DesktopWeb{
		updateStatusbar({module: "video", connectionStatus: true});
	}
	applicationType::mobile{
		updateStatusbar({connectionStatus: true});
	}
	
	
}


public function checkBandwidthQualityIndex():void{
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.checkBandwidthQualityIndex:- ClassroomContext.subscriber_bandwidthQualityIndex " + ClassroomContext.subscriber_bandwidthQualityIndex.toString());
	if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE && ClassroomContext.userVO.userName != ClassroomContext.currentPresenterName && ClassroomContext.aviewClass.isMultiBitrate == "Y"){
		if (ClassroomContext.subscriber_bandwidthQualityName == "Low Quality" + " (" + videoServersData[0].bandWidth.toString() + "Kbps)"){
			ClassroomContext.subscriber_bandwidthQualityIndex=0;
		}
		else if (ClassroomContext.subscriber_bandwidthQualityName == "Medium Quality" + " (" + videoServersData[1].bandWidth.toString() + "Kbps)"){
			ClassroomContext.subscriber_bandwidthQualityIndex=1;
		}
		else if (ClassroomContext.aviewClass.classType != "Meeting"){
			if (ClassroomContext.subscriber_bandwidthQualityName == "High Quality" + " (" + videoServersData[2].bandWidth.toString() + "Kbps)"){
				ClassroomContext.subscriber_bandwidthQualityIndex=2;
			}
		}
	}
}

private var videoTimer_PRENTR_Fullscreem:Timer;



/**
 * This function is for playing teacher's stream in student nodes
 *
 *
 * @return void
 */
public function startPresentersStream():void{
	applicationType::DesktopWeb{
		if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE){
			for (var i:int=0; i < viewedViewerDisplays.length; i++){
			var display:VideoStreamDisplay=viewedViewerDisplays[i] as VideoStreamDisplay;
				if(ClassroomContext.currentPresenterName == display.userName)
					removeViewerFromViewPanel(ClassroomContext.currentPresenterName);
				}
		return;
		}
	}
	if (!ClassroomContext.IS_AUDIO_VIDEO_ENABLED)
		return;
	if (startPresentersStreamTimeoutId){
		clearTimeout(startPresentersStreamTimeoutId);
	}
	if (ClassroomContext.currentPresenterName == ""){
		return;
	}
	if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startPresentersStream:- ClassroomContext.currentPresenterName " + ClassroomContext.currentPresenterName);
	applicationType::mobile{
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
			stopPresentersStream();
		}
	}
	applicationType::DesktopWeb{
		stopPresentersStream();
	}
	checkBandwidthQualityIndex();
	if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startPresentersStream:- ClassroomContext.subscriber_bandwidthQualityIndex" + ClassroomContext.subscriber_bandwidthQualityIndex)
	var presenterConnection:VideoConnection=getPresentersVideoConnection(ClassroomContext.subscriber_bandwidthQualityIndex);
	
	if (!presenterConnection || !presenterConnection.ncVideo.isConnected()){
		waitForVideoConnectionForTeacher();
		return;
	}
	
	presenterStreamName=getPresenterStreamName();

	var streamDetails:Object = new Object;
	streamDetails.userName = ClassroomContext.currentPresenterName;
	streamDetails.userRole = Constants.PRESENTER_ROLE;
	streamDetails.streamName = presenterStreamName;
	streamDetails.timeInterval = 30;
	streamDetails.cbps = 0;
	streamDetails.droppedFrames = 0;
	defaultTime = getCurrentTime();
	streamDetails.startTime = defaultTime;
	getStreamTime(presenterStreamName);
	totalLogInActivity.addItem(streamDetails);
	trace("userName= "+ClassroomContext.currentPresenterName+ " userRole= "+streamDetails.userRole+ " streamName= "+streamDetails.streamName+ " Time = " +streamDetails.startTime);

	applicationType::DesktopWeb{
		classroomComponentSgl.pnlTeacher.getUserSOStatus=getUserSO;
	}
	
	//START-------------------------------
	//Check if the loggedin (this) user is a teacher
	//If yes,do nothing
	//Else,then display Teacher's stream video
	//END------------------------------------------------
	//if (classroomContextObj.userRole != Constants.PRESENTER_ROLE)
	{
		presenterConnection.stopStream(prevPresenterStreamName)
		
		//START-------------------------------
		//Check if the connection with FMS is active
		//If yes,create new teacher's stream and start displaying it
		//END------------------------------------------------
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.startPresentersStream:- Presenter NetConnection.connected:" + presenterConnection.ncVideo.isConnected());
		
		isPresenterVideoPublishing=true;
		if (usersCollaborationObject.getData()[ClassroomContext.currentPresenterName] != null && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT){
			applicationType::DesktopWeb{
				var presenterDisplay:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
				if (prevPresenterStreamName != presenterStreamName && !isRefreshPressed){
					presenterDisplay.isVideoPaused=false;
					presenterDisplay.btn_studentVideoreceive.setStyle('icon', presenterDisplay.videoReceive_Icon);
				}
				presenterDisplay.getUserSOStatus=getUserSO;
				presenterDisplay.initVideoStreamDisplay(presenterStreamName, "Presenter", ClassroomContext.currentPresenterName, presenterConnection, false);
				if (classroomComponentSgl.pnlTeacher.userName != ClassroomContext.currentPresenterName){
					classroomComponentSgl.pnlTeacher.setProperties("Presenter", ClassroomContext.currentPresenterName, false, 0, 0);
				}
				//Fix for issue #18829
				applicationType::web{
					if(isPresenterVideoInFullscreen){
						presenterDisplay.labelFullScreen.visible = true;
					}
					else{
						presenterDisplay.labelFullScreen.visible = false;
						presenterDisplay.isFullScreenPresent = false;
				
					}
					//Fix for issue #20186,3#20187 and #20188
					if(isVideoStopped){
						presenterDisplay.isVideoPaused=true;
						presenterDisplay.labelVideoToggleNotification.visible = true;
					}
					else{
						presenterDisplay.isVideoPaused=false;
						presenterDisplay.labelVideoToggleNotification.visible = false;
					}
				}
				if (presenterDisplay != classroomComponentSgl.pnlTeacher){
					classroomComponentSgl.pnlTeacher.labelBigScreenNotification.visible=true;
					classroomComponentSgl.pnlTeacher.labelVideoToggleNotification.visible=false;
					classroomComponentSgl.pnlTeacher.labelAudioOnlyNotification.visible=false;
					if(!classroomComponentSgl.pnlTeacher.isFullScreenPresent)
						classroomComponentSgl.pnlTeacher.labelFullScreen.visible=false;
					classroomComponentSgl.pnlTeacher.videoBox.toolTip="";
				}
			}
		}
		applicationType::DesktopWeb{
			setViewersPresenterPanelDimensions();
		}
	}
	applicationType::mobile{
		//Check whether presenter has started his/her video
		if(getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT){
			if (classroomContextObj.userRole != Constants.PRESENTER_ROLE){
				try{
						if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE)
						{
							FlexGlobals.topLevelApplication.consolidated.videoContainer.percentWidth =100;
							FlexGlobals.topLevelApplication.consolidated.videoContainer.percentHeight =45;
							FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.presenterVideoContainer.width = 100;
							if( isPresenterAdded == false){
								isPresenterAdded = true;
								var presenterObj:Object = new Object();
								FlexGlobals.topLevelApplication.consolidated.presenterTitle = Constants.PRESENTER_VIDEO_TITLE+ getUserSO(ClassroomContext.currentPresenterName).userDisplayName;
								presenterObj.contextName = FlexGlobals.topLevelApplication.consolidated.presenterTitle+"(Video)";
								FlexGlobals.topLevelApplication.consolidated.setPresenterArray(presenterObj);
							}
							FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideo.addElement(FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideoDisplay);
							if(FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.selectedIndex != 1)
							{
								FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.selectedIndex = 1;
								FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
							}
							removePausePresenterLabel();
						}
						else
						{
							teacherVideo = getVideoDisplaySize(classroomContextObj.userRole,Constants.PRESENTER_ROLE);
							if(FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo!=null)
							{
								FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.removeAllElements();
							}
							videoUnPauseNotification();
							FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.addElement(FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideoDisplay);
							var streamingStatusCount:Object = selectedViewerStreamingCount();
							if(streamingStatusCount.videoCount >=1)
							{
								FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=true;
								FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=true;
								FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=true;
								FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=true;
								FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=true;
								FlexGlobals.topLevelApplication.videoComp.container.visible=true;
								FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.percentWidth=50;
								FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.percentWidth=50;
								if(FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.width == teacherVideo.width)
								{
									presenterVideoChange(FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.width,FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.height);
								}
							}
							else
							{
								if(FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer!= null){
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.percentWidth = 100;
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=true;
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=true;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=false;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=false;
									FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=false;
									FlexGlobals.topLevelApplication.videoComp.container.visible=false;
								}
							}
							if(isSelectedViewerVideoPaused){
								setTimeout(videoPause_studentNotification,500);
							}
						}
				}
				catch(err:Error){}
				if(teacherVideo){
					teacherVideo.clear();
				}
				//teacherVideo.smoothing=true;
				presenterConnection.stopStream(prevPresenterStreamName)
				
				//Check if the connection with FMS is active
				//If yes,create new teacher's stream and start displaying it
				if(Log.isDebug()) log.debug("Video.startPresentersStream:- Presenter NetConnection.connected:" + presenterConnection.ncVideo.isConnected());
				if (presenterConnection.ncVideo.isConnected()){
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE)
					{
						presenterConnection.startStream(presenterVideo,null,presenterStreamName,true);
						if(FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideo!=null){
							presenterVideo.clear();
							FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideoDisplay.addChild(presenterVideo);
						}
					}
					else{
						presenterConnection.startStream(teacherVideo,null,presenterStreamName,true);
						if(FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo!=null)
						{
							FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideoDisplay.addChild(teacherVideo);
							FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = Constants.PRESENTER_VIDEO_TITLE+ getUserSO(ClassroomContext.currentPresenterName).userDisplayName;
						}
						isPresenterVideoPublishing=true;
						if (usersCollaborationObject.getData()[ClassroomContext.currentPresenterName] != null && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT){
							FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoReceiveIcon;
							if(FlexGlobals.topLevelApplication.videoComp.btnVideoReceive != null){
								FlexGlobals.topLevelApplication.videoComp.btnVideoReceive.enabled = true;
							}
							FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = Constants.PRESENTER_VIDEO_TITLE + getUserSO(ClassroomContext.currentPresenterName).userDisplayName;
						}
					}
				}
				if(getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing){
					setTimeout(showViewVideo,1000,getUserSO(ClassroomContext.currentPresenterName).isAudioOnlyMode,getUserSO(ClassroomContext.currentPresenterName).isVideoHide,getUserSO(ClassroomContext.currentPresenterName).isAudioMute,Constants.PRESENTER_ROLE);
				}
			}
			if (isPresenterVideoPaused == true){
				startStopPresenterVideo();
			}
		}
	}
	ClassroomContext.subscriber_prev_bandwidthQualityIndex=ClassroomContext.subscriber_bandwidthQualityIndex;
	prevPresenterStreamName=presenterStreamName;
	setAudioMuteStatusForStream();
	isPresenterStreams=true;
	applicationType::DesktopWeb{
		changePTTButtonStatus(presenterDisplay, ClassroomContext.currentPresenterName);
	}
	applicationType::mobile{
		if(usersCollaborationObject.getData()[ClassroomContext.currentPresenterName]!=null && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT && getUserSO(ClassroomContext.currentPresenterName).isAudioOnlyMode){
			//To change and disable the video start/stop button.
			FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoFadeIcon;
			if(FlexGlobals.topLevelApplication.videoComp.btnVideoReceive != null){
				FlexGlobals.topLevelApplication.videoComp.btnVideoReceive.enabled = false;
			}
		}
		//To navigates to video tab when presenter started his/her video.
		if(videoTabNavigationCount == 0 && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT){
			if(!FlexGlobals.topLevelApplication.isWhiteBoardIntialized){
				return;
			}
			videoTabNavigationCount++;
		}
	}
}

public function getCurrentTime():String{
	var CurrentDF:DateFormatter = new DateFormatter();
	CurrentDF.formatString = "MM/DD/YY HH:NN:SS"	
	var DateTimeString:String = CurrentDF.format(defaultStreamTime);
	return DateTimeString;
}
public function getPresenterStreamName():String{
	var presenterStream:String="";
	if (ClassroomContext.subscriber_bandwidthQualityIndex == 0){
		presenterStream=ClassroomContext.currentPresenterName;
	}
	else{
		presenterStream=ClassroomContext.currentPresenterName + "_" + videoServersData[ClassroomContext.subscriber_bandwidthQualityIndex].bandWidth + "Kbps";
	}
	
	return presenterStream;
}
private var presenterWatcher:ChangeWatcher=null;
applicationType::DesktopWeb{
	public function setViewersPresenterPanelDimensions():void{
		if (videoWallLayout == Constants.SIMPLE_LAYOUT || classroomComponentSgl.controlvidbox.contains(classroomComponentSgl.pnlTeacher))
		{
			if (classroomComponentSgl.controlvidbox.width > 0)
			{
				var factor:uint=Math.floor(classroomComponentSgl.controlvidbox.width / 16);
				var vidDisplay:VideoStreamDisplay = classroomComponentSgl.pnlTeacher;
				vidDisplay.resizeFactorTitleWindow=factor;
				vidDisplay.resizeFactor=factor;
				vidDisplay.width = vidDisplay.resizeFactorTitleWindow * 16;
				vidDisplay.height = vidDisplay.resizeFactorTitleWindow * 9;
			}
			else
			{
				if (presenterWatcher == null)
					presenterWatcher=ChangeWatcher.watch(classroomComponentSgl.controlvidbox, "width", onChangePresenterVideo);
			}
			classroomComponentSgl.spacerBelowPresenterVideo.visible=true;
			classroomComponentSgl.spacerBelowPresenterVideo.includeInLayout=true;
			
		}
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			classroomComponentSgl.pnlTeacher.visible=true;
			classroomComponentSgl.pnlTeacher.includeInLayout=true;
		}
	}
	
	private function onChangePresenterVideo(value:Number):void{
		if (classroomComponentSgl.controlvidbox.width > 0){
			var factor:uint=Math.floor(classroomComponentSgl.controlvidbox.width / 16);
			classroomComponentSgl.pnlTeacher.resizeFactorTitleWindow=factor;
			classroomComponentSgl.pnlTeacher.resizeFactor=factor;
			presenterWatcher.unwatch();
			presenterWatcher=null;
			
		}
		
	}
	
	public function setPresentersPresenterPanelDimensions():void{
		if (videoWallLayout == Constants.SIMPLE_LAYOUT){
			classroomComponentSgl.pnlTeacher.isVideoReset=false;
			classroomComponentSgl.pnlTeacher.closeFullScreen();
			classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
			classroomComponentSgl.pnlTeacher.resizeFactorTitleWindow=0;
			classroomComponentSgl.pnlTeacher.resizeFactor=0;
			classroomComponentSgl.pnlTeacher.visible=false;
			classroomComponentSgl.pnlTeacher.includeInLayout=false;
			classroomComponentSgl.pnlTeacher.isVideoPaused=false;
			classroomComponentSgl.pnlTeacher.btn_studentVideoreceive.setStyle('icon', classroomComponentSgl.pnlTeacher.videoReceive_Icon);
			spacerWidth = classroomComponentSgl.spacerBelowPresenterVideo.width;
		}
		classroomComponentSgl.spacerBelowPresenterVideo.visible=false;
		classroomComponentSgl.spacerBelowPresenterVideo.includeInLayout=false;
		applicationType::web{
			//To close presenter pop-out window, when user is getting presenter control
			if(isPresenterVideoInFullscreen){
				classroomComponentSgl.pnlTeacher.isVideoReset = false;
				classroomComponentSgl.pnlTeacher.isFullScreenPresent = false;
				if(getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE && !isVideoReconnected){
					ExternalInterface.call("closePresenterPopOutWindow");
				}
			}
		}
	}
	
	public function selection_change():void{
		if (usersCollaborationObject.getData()[ClassroomContext.currentPresenterName] != null && getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing == true && classroomContextObj.userRole != Constants.PRESENTER_ROLE){
			stopPresentersStream();
			startPresentersStream();
			//Fix for issue #20443
			applicationType::web{
				if(getUserSO(ClassroomContext.userVO.userName).userRole != Constants.PRESENTER_ROLE){
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen && videoWallLayout == Constants.SIMPLE_LAYOUT){
						if(ClassroomContext.aviewClass.isMultiBitrate == "Y")
						{
							//To close video popout.
							ExternalInterface.call("closePopOuts");
						}
					}
				}
			}
			videoBitrateSelectionEventLog(ClassroomContext.currentPresenterName, ClassroomContext.subscriber_bandwidthQualityName);
		}
	}
}
/**
 *
 * @private
 * Audits the "VideoBitrateSelection" action, when the user selects a bitrate of presenter's multibit rate video
 *
 * @param currentPresenter - User name of the current presenter
 * @param selectedBitRate - Selected bit rate of incoming video of the presenter.
 * @return void
 *
 */
private function videoBitrateSelectionEventLog(currentPresenter:String, selectedBitRate:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoBitrateSelection, currentPresenter, selectedBitRate, null);
}
applicationType::DesktopWeb{
	public function stopVideo():void{
		if (recorder.isRecording){
			stopPublish();
		}
		else{
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video: Calling stopPublish from publishVideo (!vidteacher && lblStart != Start &&RecordingFlag != 1");
			stopPublish();
		}
	}
}
/**
 * This function is used for asking the user to continue with the default audio/video settings.
 * This function is called by clicking the 'Start' button in main.mxml
 *
 *
 * @return void
 */
public function callVideo():void{
	applicationType::DesktopWeb{
		if (canPublishVideo() == true){
			// start publishing audio-video stream of the user 
			publishVideo();
		}
		else{
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callVideo:- canPublishVideo method call returned false");
			stopPublish();
		}
	}
}


private var driverCheckTimeout:uint;
applicationType::DesktopWeb{
	private function checkDriverListPopulated():void{
		clearInterval(driverCheckTimeout);
		if (pop.isDriverListPopulated){
			publishVideo();
		}
		else{
			driverCheckTimeout=setTimeout(checkDriverListPopulated, 500);
		}
	}
	
	///**
	// * This method checks the publish button lables to figure out if video can be published or not.
	// * This flag is used to determine wheather to start the video or not when video connection fails
	// */
	private function canPublishVideo():Boolean{
		var canPublish:Boolean=false;
		if (classroomComponentSgl.lblStart.text == "Start"){
			canPublish=true;
		}
		return canPublish;
	}
}
/**
 * This method for checking the video and audio driver list. Also, checks the selected video/audio devices
 * are plugged in or not before publishing the stream.
 * */
private function audioVideoDevicesAvailable():Boolean{
	var isVideoDriver:Boolean=false;
	var isAudioDriver:Boolean=false;
	var deviceDriverCheck:Boolean=true;
	applicationType::DesktopWeb{
		refreshDriverList();
	}
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.audioVideoDevicesAvailable:- Entered");
	if (videodriver.length == 0 && audiodriver.length == 0 && !ClassroomContext.isAudioOnlyMode){
		deviceDriverCheck=false;
			Alert.show("Audio and Video devices are not found!\nPlease check and retry.", "   Hardware Error");
	}
		
	else if (videodriver.length == 0 || audiodriver.length == 0){
		
		if (videodriver.length == 0 && !ClassroomContext.isAudioOnlyMode){
			deviceDriverCheck=false;
			Alert.show("Video device is not found!\nPlease check and retry.", "    Camera Error");
		}
			
		else if (audiodriver.length == 0){
			deviceDriverCheck=false;
			Alert.show("Audio device is not found!\nPlease check and retry.", "   Audio Device Error");
		}
	}
	else{
		//Fix for issue #20360
		applicationType::DesktopMobile{
			if (videoDeviceDrive != ""){
				for (var i:int=0; i < videodriver.length; i++){
					if (videoDeviceDrive == videodriver[i]){
						isVideoDriver=true;
						break;
					}
				}
			}
			else{
				isVideoDriver=true;
			}
		}
		applicationType::web{
			if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
				if(!ClassroomContext.isAudioOnlyMode){
					if (videoDeviceDrive != ""){
						for (var i:int=0; i < videodriver.length; i++){
							if (videoDeviceDrive == videodriver[i]){
								isVideoDriver=true;
								break;
							}
						}
					}
					else{
						isVideoDriver=true;
					}
				}
			}
			else{
				if (videoDeviceDrive != ""){
					for (var i:int=0; i < videodriver.length; i++){
						if (videoDeviceDrive == videodriver[i]){
							isVideoDriver=true;
							break;
						}
					}
				}
				else{
					isVideoDriver=true;
				}
			}
		}
		
		if (audioDeviceDrive != ""){
			for (var j:int=0; j < audiodriver.length; j++){
				if (audioDeviceDrive == audiodriver[j]){
					isAudioDriver=true;
					break;
				}
			}
		}
		else{
			isAudioDriver=true;
		}
		
		if (!isVideoDriver && !isAudioDriver){
			deviceDriverCheck=false;
			Alert.show("Selected Audio and Video devices are not detected!\nPlease check and retry.", "   Hardware Error");
		}
		else if (!isVideoDriver  && !ClassroomContext.isAudioOnlyMode){
			deviceDriverCheck=false;
			Alert.show("Selected Video device is not detected!\nPlease check and retry.", "   Hardware Error");
		}
		else if (!isAudioDriver){
			deviceDriverCheck=false;
			Alert.show("Selected Audio device is not detected!\nPlease check and retry.", "   Hardware Error");
		}
	}
	//Alert.show("2 v l"+videodriver.length+"a l"+audiodriver.length.toString()+"videoDeviceDrive "+videoDeviceDrive+"audioDeviceDrive"+ audioDeviceDrive);
	return deviceDriverCheck;
}

public var publishingBandWidth:String="";

private function setpublishingBandWidth(bw:int):void{
	publishingBandWidth+=((publishingBandWidth != "") ? "," : "") + bw;
}

public var streamDataObjects:Object;

private function resetpublishingBandWidth():void{
	publishingBandWidth="";
}
private var isVideoPublished:Boolean=false;
private var videoCaptureHeight:int=0;
private var videoCaptureWidth:int=0;

private function dumyValues():void
{
	var object:Object = new Object();
	object.peopleCount = 2;
	object.lastUpdated = 34343434343;
	peopleCountCollaborationObject.setValue("ashish", object);
	/*peopleCountCollaborationObject.setValue("ajith", object);
	peopleCountCollaborationObject.setValue("ramesh_t", object);
	peopleCountCollaborationObject.setValue("ramesh_s", object);*/
	
}
/**
 * This function is used for start publishing audio/video stream of the user.
 *
 *
 * @return void
 */
public function publishVideo():void{
	var presenterPublishedStreamNumber:int=0;
	var viewerPublishedStreamNumber:int=0;
	isVideoPublished=true;
	applicationType::DesktopWeb{
		resumePublishing=false;
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.resumePublishing=false;
	}
	streamDataObjects=new Object();
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- Entered");
	var cameraIndex:int;
	var tempVideoDeviceDriver:String;
	var microPhoneIndex:int;
	var micNames:Array=new Array();
	var camNames:Array=new Array();
	var videoStreamFlag:int=Constants.HOLD_VIDEO;
	var desktoSharingFlag:int=Constants.DESKTOP_SHARING_DISABLE;
	//Variable for holding local FileWriteEnable status(0-false,1-true)
	var outputFileWriteEnable:int=0;
	var i:int=0;
	var serverType:String;
	camNames=Camera.names;
	micNames=Microphone.names;
	socketPortNo=Constants.SOCKET_PORT_NO;
	applicationType::DesktopWeb{
		if (audioVideoDevicesAvailable()){
			resetpublishingBandWidth();
			
			//The devices are populated here because the setting.mxml's onOK is not called, only the init is called
			//Fix for issue #17085
			applicationType::DesktopMobile{
				audioDeviceDrive=pop.micSelect.selectedItem.toString();
			}
			applicationType::web{
				if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
					for(var i:int=0; i<audiodriver.length; i++)
					{
						if(pop.micSelect.selectedIndex == i)
						{
							audioDeviceDrive=audiodriver[i];
						}
					}
				}
				else
				{
					audioDeviceDrive=pop.micSelect.selectedItem.toString();
				}
			}
			if (!ClassroomContext.isAudioOnlyMode)
			{
				//Fix for issue #17085
				applicationType::DesktopMobile{
					videoDeviceDrive=pop.camSelect.selectedItem.toString();
				}
				applicationType::web{
					if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
						for(var i:int=0; i<videodriver.length; i++)
						{
							if(pop.camSelect.selectedIndex == i)
							{
								videoDeviceDrive=videodriver[i];
							}
						}
					}
					else
					{
						videoDeviceDrive=pop.camSelect.selectedItem.toString();
					}
				}
			}
			//selectedPublishingBWKbps=pop.bandwidthSelect.selectedItem.index;
			selectedPublishingBWKbps=pop.bandwidthSelect.textInput.text;
			
			cameraIndex = camNames.indexOf(videoDeviceDrive)
			tempVideoDeviceDriver=videoDeviceDrive;
			microPhoneIndex = micNames.indexOf(audioDeviceDrive);
			for (i=0; i < videoServersData.length; i++){
				var connectionIndex:int;
				var streamName:String="";
				var obj:Object=null;
				for (var j:int=0; j < arrVideoConnections.length; j++){
					if (videoServersData[i].ip == arrVideoConnections[j].ip)
						break;
				}
				
				//Return if the video connection is not made yet
				if(!arrVideoConnections[j].connection.ncVideo.isConnected())
				{
					break;
				}
				connectionIndex=j;
				streamName=ClassroomContext.userVO.userName;
				var studentPresenterAVParam:Boolean=false;
				var viewerAVParam:Boolean=false;
				
				if(isVideoPublished){
					usersConnection.netConnection.call("setLocalAudioStatus", null, ClassroomContext.userVO.userName, false);
					if(ClassroomContext.isAudioOnlyMode){
						
						usersConnection.netConnection.call("setLocalVideoStatus", null, ClassroomContext.userVO.userName, true);
					}
					else 
						usersConnection.netConnection.call("setLocalVideoStatus", null, ClassroomContext.userVO.userName, false);	
				}
				
				if (videoServersData[i].serverType == Constants.FMS_PRESENTER || videoServersData[i].serverType == Constants.MEETING_FMS_PRESENTER){
					presenterPublishedStreamNumber++;
					if (presenterPublishedStreamNumber > 1){
						streamName=ClassroomContext.userVO.userName + "_" + videoServersData[i].bandWidth + "Kbps";
						if (ClassroomContext.aviewClass.videoCodec == "VP6")
							tempVideoDeviceDriver="ScreenCamera HR";
					}
					if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
						videoStreamFlag=Constants.STREAM_VIDEO;
					}
					else{
						videoStreamFlag=Constants.HOLD_VIDEO;
					}
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- videoStreamFlag " + videoStreamFlag);
					
					if ((ClassroomContext.userVO.role == Constants.STUDENT_TYPE && presenterPublishedStreamNumber == 1) || (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)){
						obj=new Object();
						obj.ip=videoServersData[i].ip;
						obj.bandWidth=videoServersData[i].bandWidth;
						
					
						serverType= ClassroomContext.aviewClass.classType == "Meeting"? Constants.MEETING_FMS_PRESENTER: Constants.FMS_PRESENTER;
						obj.parameters=new AVParameters(audioDeviceDrive,tempVideoDeviceDriver,videoServersData[i].bandWidth,outputFileWriteEnable,streamName,arrVideoConnections[j].ip,videoStreamFlag,desktoSharingFlag,ClassroomContext.aviewClass.videoCodec,socketPortNo,microPhoneIndex,cameraIndex,Constants.FMS_PRESENTER,connectionIndex,ClassroomContext.isAudioOnlyMode,presenterPublishedStreamNumber,cameraDeviceType,keyFrames);
						if(isAdvancedSettingsChecked && ClassroomContext.aviewClass.isMultiBitrate != "Y")
							obj.parameters.setAdvancedParameters(cameraResolution, cameraVideoQuality, FPS, h264Profile, h264ProfileValue);
						
						avParametersData.addItem(obj);
						arrVideoConnections[j].connection.publishVideo(avParametersData[avParametersData.length - 1].parameters);
				
						//For auditing		
						if (videoStreamFlag){
							setpublishingBandWidth(videoServersData[i].bandWidth);
						}
						if (i == 0){
							if (!ClassroomContext.isAudioOnlyMode)
								streamDataObjects.pBandwidth0=videoServersData[i].bandWidth;
							else
								streamDataObjects.pBandwidth0=20
						}
						else if (i == 1){
							if (!ClassroomContext.isAudioOnlyMode)
								streamDataObjects.pBandwidth1=videoServersData[i].bandWidth;
							else
								streamDataObjects.pBandwidth1=20
						}
						else if (i == 2){
							if (!ClassroomContext.isAudioOnlyMode)
								streamDataObjects.pBandwidth2=videoServersData[i].bandWidth;
							else
								streamDataObjects.pBandwidth2=20
						}
					}
				}
				else if (videoServersData[i].serverType == Constants.FMS_VIEWER || videoServersData[i].serverType == Constants.MEETING_FMS_VIEWER){
					viewerPublishedStreamNumber++
					//PNCR: please replace the below logic to inline if contion
					if (classroomContextObj.userRole == Constants.VIEWER_ROLE && (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT)){
						videoStreamFlag=Constants.STREAM_VIDEO;
					}
					else{
						videoStreamFlag=Constants.HOLD_VIDEO;
					}
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- viewer videoStreamFlag " + videoStreamFlag);
					streamName=ClassroomContext.userVO.userName + Constants.VIEWER_APPEND_NAME;
					var publishingStreamExist:Boolean=false;
					for (var k:int=0; k < avParametersData.length; k++){
						if ((videoServersData[i].ip == avParametersData[k].ip) && (streamName == avParametersData[k].parameters.streamName)) { //Check for both bandwidth and ip
							publishingStreamExist=true
							break;
						}
						
					}
					if (!publishingStreamExist){
						obj=new Object();
						obj.ip=videoServersData[i].ip;
						obj.bandWidth=videoServersData[i].bandWidth;
						serverType = ClassroomContext.aviewClass.classType == "Meeting"? Constants.MEETING_FMS_VIEWER: Constants.FMS_VIEWER;
						obj.parameters=new AVParameters(audioDeviceDrive,tempVideoDeviceDriver,videoServersData[i].bandWidth,outputFileWriteEnable,streamName,arrVideoConnections[j].ip,videoStreamFlag,desktoSharingFlag,ClassroomContext.aviewClass.videoCodec,socketPortNo,microPhoneIndex,cameraIndex,Constants.FMS_VIEWER,connectionIndex,ClassroomContext.isAudioOnlyMode,viewerPublishedStreamNumber,cameraDeviceType,keyFrames);
						if(isAdvancedSettingsChecked  && ClassroomContext.aviewClass.isMultiBitrate != "Y")
							obj.parameters.setAdvancedParameters(cameraResolution, cameraVideoQuality, FPS, h264Profile, h264ProfileValue);
						
						avParametersData.addItem(obj);
						arrVideoConnections[j].connection.publishVideo(avParametersData[avParametersData.length - 1].parameters);
						//getthe videoidth and height to send toFMS
						videoCaptureHeight=(obj.parameters as AVParameters).videoCaptureHeight;
						videoCaptureWidth=(obj.parameters as AVParameters).videoCaptureWidth;
						//For auditing					
						if (classroomContextObj.userRole == Constants.VIEWER_ROLE){
							setpublishingBandWidth(videoServersData[i].bandWidth);
						}
					}
					else{
						obj=new Object();
						obj.ip=avParametersData[k].ip;
						obj.bandWidth=avParametersData[k].bandWidth;
						serverType = ClassroomContext.aviewClass.classType == "Meeting"? Constants.MEETING_FMS_VIEWER: Constants.FMS_VIEWER;
						obj.parameters=new AVParameters(audioDeviceDrive,tempVideoDeviceDriver,videoServersData[i].bandWidth,outputFileWriteEnable,streamName,arrVideoConnections[j].ip,videoStreamFlag,desktoSharingFlag,ClassroomContext.aviewClass.videoCodec,socketPortNo,microPhoneIndex,cameraIndex,Constants.FMS_VIEWER,connectionIndex,ClassroomContext.isAudioOnlyMode,viewerPublishedStreamNumber,cameraDeviceType,keyFrames);
						if(isAdvancedSettingsChecked  && ClassroomContext.aviewClass.isMultiBitrate != "Y")
							obj.parameters.setAdvancedParameters(cameraResolution, cameraVideoQuality, FPS, h264Profile, h264ProfileValue);
						avParametersData.addItem(obj);
						if (videoStreamFlag == Constants.STREAM_VIDEO){
							if (videoServersData[i].serverType == Constants.FMS_VIEWER){
								startCapture(Constants.FMS_VIEWER);
							}
							else{
								startCapture(Constants.MEETING_FMS_VIEWER);
								
							}
						}
						//For auditing					
						if (classroomContextObj.userRole == Constants.VIEWER_ROLE){
							setpublishingBandWidth(avParametersData[k].bandWidth);
						}
					}
					if (!ClassroomContext.isAudioOnlyMode)
						streamDataObjects.vBandwidth=videoServersData[i].bandWidth;
					else
						streamDataObjects.vBandwidth=20
				}
				socketPortNo++;
			}
			
			if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE){
				prepareClassDetails();
				adminConsoleCollabObject.setValue(ClassroomContext.userVO.userName, ClassroomContext.userDetails);
					//AuditContext.userSetting.auditUserSetting(publishingBandWidth);
			}
			
			if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				// display busy cursor until the stream get started
				callBusycursor_video();
				cursorTimeOut=setTimeout(removeCursor, 1000);
			}
			if (ClassroomContext.isModerator && automaticRecording && !recorder.isRecording){
				checkWAMPserver();
			}
			else if (ClassroomContext.isModerator && !recordButtonBlinkedOnce && recordIcon == startRecordIcon){
				recordButtonBlinkedOnce=true;
				blinkTimerIntervalForRecordBtn=startBlink(classroomComponentSgl.btnRecord, 200, 0);
			}
			
			setVideoPublishStatus(ClassroomContext.userVO.userName, true, streamDataObjects, videoCaptureHeight, videoCaptureWidth);
			applicationType::desktop{
				if (Capabilities.os.toLowerCase().indexOf("win") > -1 || Capabilities.os.toLowerCase().indexOf("mac") > -1){
					callLocalVideo();
					classroomComponentSgl.btnLocalVideo.visible=true;
				}
			}
			//Removed OS check for web, to view the local video preview window
			applicationType::web{
				callLocalVideo();
				//RTCR:Need to discuss with the video team. 
				classroomComponentSgl.btnLocalVideo.visible=true;
			}
			// consolidated mode UI 
				classroomComponentSgl.lblStart.text="Stop";
				startStopVideoToggleIcon=stopVideoIcon;
				if (ClassroomContext.isAudioOnlyMode)
					classroomComponentSgl.btnStart.toolTip="Stop your audio";
				else
					classroomComponentSgl.btnStart.toolTip="Stop your video";
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- Exited publish video");
			if (ClassroomContext.aviewClass.videoCodec == "VP6"){
				isStartAVButtonCanbeEnabled=false;
			}
		}
		ClassroomContext.isUserPublishingVideo=true;
		isAdvancedSettingsChecked = false;
	}
	applicationType::mobile{
		resetpublishingBandWidth();
		if(!ClassroomContext.isAudioOnlyMode)
		{
			//To avoid null object refrence issue.
			if(FlexGlobals.topLevelApplication.sliderDrawer.audioSetting != null && FlexGlobals.topLevelApplication.sliderDrawer.audioSetting.toggleCamera != null){
				videoDeviceDrive=FlexGlobals.topLevelApplication.sliderDrawer.audioSetting.selectedDriverName;//videoDriverName;
				cameraIndex = FlexGlobals.topLevelApplication.sliderDrawer.audioSetting.camIndex;
			}else{
				if(camNames.length == 1){
					videoDeviceDrive = "Primary Camera";
					videoDeviceIndex = 0;
					cameraIndex = 0;
				}else if(camNames.length >= 2){
					videoDeviceDrive = "Secondary Camera";
					videoDeviceIndex = 1;
					cameraIndex = 1;
				}
			}
		}
		if(selectedPublishingBWKbps == "")
		{
			selectedPublishingBWKbps = "56";
		}
		
		for(i=0;i<camNames.length;i++)
		{
			if(camNames[i]==videoDeviceDrive)
			{
				cameraIndex=i;
				break;
			}
		}
		tempVideoDeviceDriver=videoDeviceDrive;
		audioDeviceDrive = micNames[0];
		var camera:Camera= Camera.getCamera(cameraIndex.toString());
		camera.setMode(500, 450, 15);
		for(i=0;i<videoServersData.length;i++)
		{
			var connectionIndex:int;
			var streamName:String="";
			var obj:Object = null;
			for(var j:int=0;j<arrVideoConnections.length;j++)
			{
				if(videoServersData[i].ip==arrVideoConnections[j].ip)
					break;
			}
			//Return if the video connection is not made yet
			if(!arrVideoConnections[j].connection.ncVideo.isConnected())
			{
				break;
			}
			connectionIndex=j;
			streamName=ClassroomContext.userVO.userName;
			var studentPresenterAVParam:Boolean=false;
			var viewerAVParam:Boolean=false;
			
			if(isVideoPublished){
				usersConnection.netConnection.call("setLocalAudioStatus", null, ClassroomContext.userVO.userName, false);
				if(ClassroomContext.isAudioOnlyMode){
					
					usersConnection.netConnection.call("setLocalVideoStatus", null, ClassroomContext.userVO.userName, true);
				}
				else 
					usersConnection.netConnection.call("setLocalVideoStatus", null, ClassroomContext.userVO.userName, false);	
			}
			if(videoServersData[i].serverType==Constants.FMS_PRESENTER || videoServersData[i].serverType==Constants.MEETING_FMS_PRESENTER){
				presenterPublishedStreamNumber++;
				if (presenterPublishedStreamNumber > 1){
					streamName=ClassroomContext.userVO.userName + "_" + videoServersData[i].bandWidth + "Kbps";
					if (ClassroomContext.aviewClass.videoCodec == "VP6")
						tempVideoDeviceDriver="ScreenCamera HR";
				}
				if(classroomContextObj.userRole == Constants.PRESENTER_ROLE)
				{
					videoStreamFlag=Constants.STREAM_VIDEO;
				}
				else
				{
					videoStreamFlag=Constants.HOLD_VIDEO;
				}
				if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- videoStreamFlag "+videoStreamFlag);
				
				if((ClassroomContext.userVO.role==Constants.STUDENT_TYPE && presenterPublishedStreamNumber==1) || (ClassroomContext.userVO.role==Constants.TEACHER_TYPE))
				{
					obj=new Object();
					obj.ip=videoServersData[i].ip;
					obj.bandWidth=videoServersData[i].bandWidth;
					serverType= ClassroomContext.aviewClass.classType == "Meeting"? Constants.MEETING_FMS_PRESENTER: Constants.FMS_PRESENTER;
					obj.parameters=new AVParameters(audioDeviceDrive,tempVideoDeviceDriver,videoServersData[i].bandWidth,outputFileWriteEnable,streamName,arrVideoConnections[j].ip,videoStreamFlag,desktoSharingFlag,ClassroomContext.aviewClass.videoCodec,socketPortNo,microPhoneIndex,cameraIndex,Constants.FMS_PRESENTER,connectionIndex,ClassroomContext.isAudioOnlyMode,presenterPublishedStreamNumber,cameraDeviceType,keyFrames);
					avParametersData.addItem(obj);
					arrVideoConnections[j].connection.publishVideo(avParametersData[avParametersData.length-1].parameters);
					//For auditing		
					if(videoStreamFlag)
					{
						setpublishingBandWidth(videoServersData[i].bandWidth);
					}
					if(i == 0)
					{
						if(!ClassroomContext.isAudioOnlyMode)
							streamDataObjects.pBandwidth0 = videoServersData[i].bandWidth;
						else
							streamDataObjects.pBandwidth0 = 20
					}
					else if(i == 1)
					{
						if(!ClassroomContext.isAudioOnlyMode)
							streamDataObjects.pBandwidth1 = videoServersData[i].bandWidth;
						else
							streamDataObjects.pBandwidth1 = 20
					}
					else if(i == 2)
					{
						if(!ClassroomContext.isAudioOnlyMode)
							streamDataObjects.pBandwidth2 = videoServersData[i].bandWidth;
						else
							streamDataObjects.pBandwidth2 = 20
					}
				}
			}
			else if(videoServersData[i].serverType==Constants.FMS_VIEWER ||videoServersData[i].serverType==Constants.MEETING_FMS_VIEWER)
			{
				viewerPublishedStreamNumber++
				//PNCR: please replace the below logic to inline if contion
				if (classroomContextObj.userRole == Constants.VIEWER_ROLE && (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT)){
					videoStreamFlag=Constants.STREAM_VIDEO;
				}
				else{
					videoStreamFlag=Constants.HOLD_VIDEO;
				}
				if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- viewer videoStreamFlag " + videoStreamFlag);
				streamName=ClassroomContext.userVO.userName + Constants.VIEWER_APPEND_NAME;
				var publishingStreamExist:Boolean=false;
				for (var k:int=0; k < avParametersData.length; k++){
					if ((videoServersData[i].ip == avParametersData[k].ip) && (streamName == avParametersData[k].parameters.streamName)) { //Check for both bandwidth and ip
						publishingStreamExist=true
						break;
					}
					
				}
				if(!publishingStreamExist)
				{
					obj=new Object();
					obj.ip=videoServersData[i].ip;
					obj.bandWidth=videoServersData[i].bandWidth;
					serverType = ClassroomContext.aviewClass.classType == "Meeting"? Constants.MEETING_FMS_VIEWER: Constants.FMS_VIEWER;
					obj.parameters=new AVParameters(audioDeviceDrive,tempVideoDeviceDriver,videoServersData[i].bandWidth,outputFileWriteEnable,streamName,arrVideoConnections[j].ip,videoStreamFlag,desktoSharingFlag,ClassroomContext.aviewClass.videoCodec,socketPortNo,microPhoneIndex,cameraIndex,Constants.FMS_VIEWER,connectionIndex,ClassroomContext.isAudioOnlyMode,viewerPublishedStreamNumber,cameraDeviceType,keyFrames);
					avParametersData.addItem(obj);
					arrVideoConnections[j].connection.publishVideo(avParametersData[avParametersData.length-1].parameters);
					//getthe videoidth and height to send toFMS
					videoCaptureHeight=(obj.parameters as AVParameters).videoCaptureHeight;
					videoCaptureWidth=(obj.parameters as AVParameters).videoCaptureWidth;
					//For auditing					
					if(classroomContextObj.userRole == Constants.VIEWER_ROLE)
					{
						setpublishingBandWidth(videoServersData[i].bandWidth);
					}
				}
				else
				{
					obj=new Object();
					obj.ip=avParametersData[k].ip;
					obj.bandWidth=avParametersData[k].bandWidth;
					obj.parameters=new AVParameters(audioDeviceDrive,tempVideoDeviceDriver,avParametersData[k].bandWidth,outputFileWriteEnable,streamName,arrVideoConnections[j].ip,videoStreamFlag,desktoSharingFlag,ClassroomContext.aviewClass.videoCodec,avParametersData[k].parameters.socketPortNo,microPhoneIndex,cameraIndex,Constants.FMS_VIEWER,connectionIndex,ClassroomContext.isAudioOnlyMode,viewerPublishedStreamNumber,cameraDeviceType,keyFrames);
					avParametersData.addItem(obj);
					if (videoStreamFlag == Constants.STREAM_VIDEO){
						if (videoServersData[i].serverType == Constants.FMS_VIEWER){
							startCapture(Constants.FMS_VIEWER);
						}
						else{
							startCapture(Constants.MEETING_FMS_VIEWER);
							
						}
					}
					//For auditing					
					if(classroomContextObj.userRole == Constants.VIEWER_ROLE)
					{
						setpublishingBandWidth(avParametersData[k].bandWidth);
					}
				}
				if(!ClassroomContext.isAudioOnlyMode)
					streamDataObjects.vBandwidth = videoServersData[i].bandWidth;
				else
					streamDataObjects.vBandwidth = 20
			}
			socketPortNo++;
		}
		
		if(ClassroomContext.userVO.role != Constants.ADMIN_TYPE &&  ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE)
		{
			prepareUserDetails();
			adminConsoleCollabObject.setValue(ClassroomContext.userVO.userName, ClassroomContext.userDetails);
		}
		setVideoPublishStatus(ClassroomContext.userVO.userName,true, streamDataObjects, videoCaptureHeight, videoCaptureWidth);
		if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishVideo:- Exited publish video");
		if(ClassroomContext.aviewClass.videoCodec=="VP6")
		{
		}
		ClassroomContext.isUserPublishingVideo=true;
	}
}

private function publishStatusSet(event:TimerEvent):void{
	var obj:Object=new Object();
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishStatusSet:- Entered");
	applicationType::desktop{
	if (classroomComponentSgl.lblStart.text == "Stop" || classroomComponentSgl.lblStart.text == "Stopping..."){
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.publishStatusSet:- classroomComponentSgl.lbl_start.text :" + classroomComponentSgl.lblStart.text);
			setVideoPublishStatus(ClassroomContext.userVO.userName, true, obj, 0, 0);
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.videoComp){
			setVideoPublishStatus(ClassroomContext.userVO.userName, true, obj, 0, 0);
		}
	}
}

private function removeCursor():void{
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.removeCursor:- Entered");
	var publishedCount:int=0;
	var notPublishedCount:int=0;
	
	for (var j:int=0; j < arrVideoConnections.length; j++){ 
		if (!arrVideoConnections[j].connection.areAllStreamsInPublishedState())
			notPublishedCount++;
	}
	applicationType::DesktopWeb{
		if (notPublishedCount == 0){
			if (automaticRecording && !recorder.isRecording){
				checkWAMPserver();
			}
			removeBusyCursor();
			clearTimeout(cursorTimeOut);
		}
	}
	//To remove the busy cursor if the video compression of the class has been set to 'Low Bandwidth'.
	applicationType::web{
		if (ClassroomContext.aviewClass.videoCodec == "VP6"){
			removeBusyCursor();
			clearTimeout(cursorTimeOut);
		}
	}
	//Web version we don't have recording	
	applicationType::desktop{
		if (!recordButtonBlinkedOnce && recordIcon == startRecordIcon){
			recordButtonBlinkedOnce=true;
			blinkTimerIntervalForRecordBtn=startBlink(classroomComponentSgl.btnRecord, 200, 0);
		}
	}
	applicationType::DesktopWeb{
		removeBusyCursor();
	}
		clearTimeout(cursorTimeOut);
}
public var blinkTimerIntervalForRecordBtn:uint;
applicationType::DesktopWeb{
	private function changingButtonStatusToStopping():void{
		if (classroomComponentSgl){
			classroomComponentSgl.btnStart.enabled=false;
			classroomComponentSgl.lblStart.text="Stopping...";
			classroomComponentSgl.btnStart.toolTip="Stopping...";
		}
	}
	
	private function changingButtonStatusToStart():void{
		if (classroomComponentSgl && classroomComponentSgl.lblStart.text == "Stopping..."){
			classroomComponentSgl.btnStart.toolTip="Start your video";
			classroomComponentSgl.lblStart.text="Start";
			startStopVideoToggleIcon=startVideoIcon;
			classroomComponentSgl.btnStart.enabled=true;
		}
		
	}
}
/**
 *  Function for handling the complete event of timer and removes the event listner.
 *
 *  @param event of type TimerEvent
 *  @return void
 *
 */
//RGCR: Rename this method
private function timerNativeProcessExitHandler(event:TimerEvent):void{
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.timerNativeProcessExitHandler:- Entered");
	timerNativeProcessExit.stop();
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.timerNativeProcessExitHandler:- After timerNativeProcessExit.stop()");
	timerNativeProcessExit.removeEventListener(TimerEvent.TIMER_COMPLETE, timerNativeProcessExitHandler);
	applicationType::DesktopWeb{
		changingButtonStatusToStart();
	}
	
}

/**
 * This function is used for stop publishing audio/video stream of the user.
 *
 * @param flag of type uint (indicate whether it is called for multiple or consolidate)
 * @return void
 */
public function stopPublish():void{
	var obj:Object=new Object();
	isVideoPublished=false;
	applicationType::DesktopWeb{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopPublish:- Entered ");
		//bug #81
		// Enables the timer for 10 seconds
		timerNativeProcessExit=new Timer(10000, 1);
		// Event listner for timer complete event
		timerNativeProcessExit.addEventListener(TimerEvent.TIMER_COMPLETE, timerNativeProcessExitHandler);
		//Uncommented this check to fix for issue #8830
		if (ClassroomContext.aviewClass && ClassroomContext.aviewClass.videoCodec == "VP6"){
			timerSocket=new Timer(1000, 13);
			//JHCR: Have to remove or uncomment the following line when we merge from dekstop's latest code
			//timerSocket.addEventListener(TimerEvent.TIMER_COMPLETE,timerStartButtonEnable);
			timerSocket.start();
		}
		// Starts the timer
		timerNativeProcessExit.start();
		setVideoPublishStatus(ClassroomContext.userVO.userName, false, obj, 0, 0);
		//Uncommented this check to fix for issue #8830
		if (ClassroomContext.aviewClass && ClassroomContext.aviewClass.videoCodec == "VP6"){
			changingButtonStatusToStopping();
		}
		else{
			ClassroomContext.isUserPublishingVideo=false;
				if (classroomComponentSgl){
					classroomComponentSgl.btnStart.toolTip="Start your video";
					classroomComponentSgl.lblStart.text="Start";
					classroomComponentSgl.btnStart.enabled=true;
				}
				startStopVideoToggleIcon=startVideoIcon;
		}
		for (var i:int=0; i < arrVideoConnections.length; i++){
			arrVideoConnections[i].connection.stopPublish();
		}
		
		//  multiple mode UI 
		
		if (myVideo){
			myVideo.closePopup();
			myVideo=null;
		}
		if (classroomComponentSgl && classroomComponentSgl.btnLocalVideo){
			classroomComponentSgl.btnLocalVideo.visible=false;
		}
		if (avParametersData)
			avParametersData.removeAll();
		removeBusyCursor();
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopPublish:- Exited ");
		
		//CRJH: API : done(ashwini)
		if (snapshotObj){
			//removeSnapshotComp();
			snapshotObj.stopSnapshotTimer();
			snapshotObj.faceImage.attachCamera(null);
		}
		/*if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		{*/
		isHide=false;
		isMute=false;
		//}
	}
	applicationType::mobile{
		setVideoPublishStatus(ClassroomContext.userVO.userName, false, obj, 0, 0);
		if (ClassroomContext.aviewClass && ClassroomContext.aviewClass.videoCodec != "VP6"){
			ClassroomContext.isUserPublishingVideo=false;
		}
		for (var i:int=0; i < arrVideoConnections.length; i++){
			arrVideoConnections[i].connection.stopPublish();
		}
		if (avParametersData)
			avParametersData.removeAll();
	}
}

/*public function setCollaborationPeopleCount(userName:String, pcObjDetails:Object):void{
	peopleCountCollaborationObject.lock();
	peopleCountCollaborationObject.setValue(userName, pcObjDetails);
	peopleCountCollaborationObject.flush();
	peopleCountCollaborationObject.unlock();
}*/

 public function peopleCountHandler(newValue:String=null, oldValue:String=null):void{
	 applicationType::DesktopWeb{
	  if(ClassroomContext.isModerator && ClassroomContext.aviewClass.enablePeopleCount == "Yes")
		  peopleCountFlag = false;
	 }
 }

public function peopleCountSOHandler(newValue:Object=null, oldValue:Object=null):void
{
	applicationType::DesktopWeb{
		//trace(ClassroomContext.aviewClass.enablePeopleCount);
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("peopleCountSOHandler init ClassroomContext.isModerator"+ClassroomContext.isModerator+" ClassroomContext.aviewClass.enablePeopleCount "+ClassroomContext.aviewClass.enablePeopleCount+" peopleCountCollaborationObject.syncEventCount"+peopleCountCollaborationObject.syncEventCount);
		if(ClassroomContext.isModerator && ClassroomContext.aviewClass.enablePeopleCount == "Yes" && peopleCountCollaborationObject.syncEventCount > 2)
		{
			if (lstUsers) lstUsers.sortUserList();
			if(isPeopleCountCalled)
			{
				isPeopleCountCalled = false;
				//trace(ClassroomContext.userVO.photoCaptureFrequencySecs);
				//trace(((ClassroomContext.aviewClass.monitorIntervalFreq * 60 * 1000) - 120000));
				if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("peopleCountSOHandler calling storePeopleCountDetails");
				trace(" ClassroomContext.aviewClass.monitorIntervalFreq  "+ClassroomContext.aviewClass.monitorIntervalFreq);
				clearPeopleCountTimeOut = setTimeout(storePeopleCountDetails, ((ClassroomContext.aviewClass.monitorIntervalFreq * 60 * 1000) - 120000));
			}
		}
	}
}

private function storePeopleCountDetails():void
{
	trace("storePeopleCountDetails ");
	clearInterval(clearPeopleCountTimeOut);
	var peopleCountVO:PeopleCountVO = new PeopleCountVO();
	peopleCountHelper = new PeopleCountHelper();
	var peopleData:String="";
	peopleCountVO.lectureId = ClassroomContext.lecture.lectureId;
	peopleCountVO.statusId = ClassroomContext.userVO.statusId;
	for (var uName in peopleCountCollaborationObject.getData())
	{
		peopleData += "("+uName+"`"+peopleCountCollaborationObject.getData()[uName].peopleCount+"`"+peopleCountCollaborationObject.getData()[uName].lastUpdated+");";
	}
	peopleCountVO.peopleCountData = peopleData;
	
	peopleCountHelper.createPeopleCount(peopleCountVO,ClassroomContext.userVO.userId);
	isPeopleCountCalled = true;
}
 
//Issue #30 & #178
/**
 * This function is used to stop the teacher's stream. It cleans the stream and
 * any related components
 *
 * @return void
 */
public function stopPresentersStream():void{
	applicationType::DesktopWeb{
		try{
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopPresentersStream:- ClassroomContext.subscriber_prev_bandwidthQualityIndex :" + ClassroomContext.subscriber_prev_bandwidthQualityIndex);
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopPresentersStream:- prevPresenterStreamName :" + prevPresenterStreamName);
			isPresenterVideoPublishing=false;
			var presenterDisplay:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
			presenterDisplay.clearDisplay();
			if (presenterDisplay.name != classroomComponentSgl.pnlTeacher.name){
				classroomComponentSgl.pnlTeacher.removeVideo();
			}
			ClassroomContext.subscriber_prev_bandwidthQualityIndex=ClassroomContext.subscriber_bandwidthQualityIndex;
			prevPresenterStreamName=presenterStreamName;
			for(var i:int; i< totalLogInActivity.length;i++)
			{
				if(totalLogInActivity[i].streamName == presenterStreamName)
				{
					trace("removedpresentercbps=" +totalLogInActivity[i].cbps+ "droppedframes=" +totalLogInActivity[i].droppedFrames);
					removedUsersArray.addItem(totalLogInActivity[i]);
					totalLogInActivity.removeItemAt(i);
					break;
				}
				
			}
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopPresentersStream:- prevPresenterStreamName :" + prevPresenterStreamName)
		}
		catch (err:Error){
			if(Log.isError()) log.error("Error in stopPresentersStream method:"+err.getStackTrace());
		}
	}
	applicationType::mobile{
		try
		{
			if(FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex != 5){
				if (presenterVideo!=null){
					presenterVideo.clear();
					for(var i:int = 0; i < FlexGlobals.topLevelApplication.consolidated.presenterValuesArray.length; i++){
						if(FlexGlobals.topLevelApplication.consolidated.presenterValuesArray[i].contextName == FlexGlobals.topLevelApplication.consolidated.presenterTitle+"(Video)"){
							FlexGlobals.topLevelApplication.consolidated.presenterValuesArray.removeItemAt(i);
						}
					}
					FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.selectedIndex = 0;
					FlexGlobals.topLevelApplication.consolidated.presenterListChangeHandler();
					isPresenterAdded= false;
				}
			}
			var tempButton:Button;
			if(Log.isDebug()) log.debug("Video.stopPresentersStream:- ClassroomContext.subscriber_prev_bandwidthQualityIndex :"+ClassroomContext.subscriber_prev_bandwidthQualityIndex);
			var tempPrevPresenterConnection:VideoConnection=getVideoConnectionByIP(
				videoPresenterServerData[ClassroomContext.subscriber_prev_bandwidthQualityIndex].ip
			);
			
			tempPrevPresenterConnection.stopStream(prevPresenterStreamName);
			//var tempPresenterConnection:VideoConnection=getPresentersVideoConnection(ClassroomContext.subscriber_prev_bandwidthQualityIndex);
			if(Log.isDebug()) log.debug("Video.stopPresentersStream:- prevPresenterStreamName :"+prevPresenterStreamName );
			isPresenterVideoPublishing=false;
			if (teacherVideo)
			{
				teacherVideo.clear();
			}
			//For AVCM: Added to clear the presenter video last frame from pnlTeacherVideo (Group), when presenter stops his/her local the video.
			if(FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideoDisplay!=null && FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo)
			{
				FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideoDisplay.removeChild(teacherVideo);
			}
			try
			{
				FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.removeElement(objPresenterAudioOnlyMode);
			}
			catch(er:Error){}
			
			if(!getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)				{
				FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = "";
			} 
			
			videoUnPauseNotification();
			ClassroomContext.subscriber_prev_bandwidthQualityIndex=ClassroomContext.subscriber_bandwidthQualityIndex;
			prevPresenterStreamName=presenterStreamName;
			//For AVCM:--- Starts----
			//To change icon and disable video start/stop button.
			FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoFadeIcon;
			FlexGlobals.topLevelApplication.videoComp.btnVideoReceive.enabled = false;
			//To make presenterStreamName as null.
			presenterStreamName = "";
			videoTabNavigationCount = 0;
			//For AVCM:--- Stops----
			if(Log.isDebug()) log.debug("Video.stopPresentersStream:- prevPresenterStreamName :"+prevPresenterStreamName )
				var streamingStatusCount:Object = selectedViewerStreamingCount();
				if(streamingStatusCount.videoCount >=1 && studentVideo != null){
						FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.percentWidth = 100;
						FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=false;
						FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=false;
						FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=true;
						FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=true;
						FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=false;
						FlexGlobals.topLevelApplication.videoComp.container.visible=false;
						setTimeout(FlexGlobals.topLevelApplication.videoComp.setStudentWidth,1000,FlexGlobals.topLevelApplication.width);
				}
				else if(streamingStatusCount.videoCount == 0 && !getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing ){
					FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=true;
					FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=true;
					FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=true;
					FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=true;
					FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=true;
					FlexGlobals.topLevelApplication.videoComp.container.visible=true;
					FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.percentWidth=50;
					FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.percentWidth=50;
				}
		}
		catch (err:Error)
		{
		}
		if(FlexGlobals.topLevelApplication.screenTypes != Constants.SCREENTYPE_ALLINONE && isSelectedViewerVideoPaused){
			setTimeout(videoPause_studentNotification,500);
		}
	}
	isPresenterStreams=false;
}

public function writeToFile():void{
	countNum++;
	var userName:String = "" ;
	var userRole:String = "" ;
	var streamName:String = "" ;
	var streamTime:String = "" ;
	var timeInterval:String = "";
	var cbps:String = "";
	var droppedFrames:String = "";
	applicationType::desktop{
		var fileStream:FileStream = new FileStream();
		var file:File = new File(filePath + "/Logs/"+userNameInFile+"_"+fileTimeStamp+".txt");
		fileStream.open(file, FileMode.WRITE);
		for(var i:int = 0; i < removedUsersArray.length; i++){
			//if(removedUsersArray[i].userName == removedUserName){
			userName = removedUsersArray[i].userName ;
			userRole= removedUsersArray[i].userRole;
			streamName = removedUsersArray[i].streamName;
			timeInterval = removedUsersArray[i].timeInterval;
			streamTime = removedUsersArray[i].startTime;
			cbps= removedUsersArray[i].cbps;
			droppedFrames = removedUsersArray[i].droppedFrames; 
			fileStream.writeUTFBytes(" UserName :" +userName);
			fileStream.writeUTFBytes(" UserRole :" +userRole);
			fileStream.writeUTFBytes(" StreamName :" +streamName);
			fileStream.writeUTFBytes(" TimeInterval :" +timeInterval);
			fileStream.writeUTFBytes(" StreamTime :" +streamTime);
			fileStream.writeUTFBytes(" CurrentBytesperSecond :" +cbps);
			fileStream.writeUTFBytes(" DroppedFrames :" +droppedFrames);
			fileStream.writeUTFBytes("\r\n");
			//break;
		}
		for(var i:int = 0; i < totalLogInActivity.length; i++){
			userName = totalLogInActivity[i].userName ;
			userRole = totalLogInActivity[i].userRole;
			streamName = totalLogInActivity[i].streamName;
			timeInterval = totalLogInActivity[i].timeInterval;
			streamTime = totalLogInActivity[i].startTime;
			cbps = totalLogInActivity[i].cbps;
			droppedFrames = totalLogInActivity[i].droppedFrames; 
			fileStream.writeUTFBytes(" UserName :" +userName);
			fileStream.writeUTFBytes(" UserRole :" +userRole);
			fileStream.writeUTFBytes(" StreamName :" +streamName);
			fileStream.writeUTFBytes(" TimeInterval :" +timeInterval);
			fileStream.writeUTFBytes(" StreamTime :" +streamTime);
			fileStream.writeUTFBytes(" CurrentBytesperSecond :" +cbps);
			fileStream.writeUTFBytes(" DroppedFrames :" +droppedFrames);
			fileStream.writeUTFBytes("\r\n");
			trace("Writing to File");
		}
		uploadFileToFolder(file);
		fileStream.close();
	}
}
applicationType::desktop{
	public function uploadFileToFolder(file:File):void{
		if( FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.isConnected()){
			var tempPath:String="AVContent/VideoData/"+ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId
			+"/"+ClassroomContext.lecture.lectureId;
			file.addEventListener(Event.COMPLETE,deleteTempFile);
			file.addEventListener(IOErrorEvent.IO_ERROR,errorInUpload);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorInUpload);
			var url:String=encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP + "/AVScript/Common/upload.php?folderPath="+ tempPath);
			file.upload(new URLRequest(url));
			trace("Uploading...");
		}
	}
}
private function deleteTempFile(evnt:Event):void
{
	trace("delete temp files");
	
}

private function errorInUpload(evnt:Event):void
{
	trace("error in upload");
}

private var isPresenterStreams:Boolean=false;
applicationType::DesktopWeb{
	private var emptyVideoDisplay:VideoStreamDisplay=null;
}

/**
 * This function stops the student's stream, cleans the related components and sets the
 * appropriate title. If the title of the windo is more than 30 chars, then it trims the
 * title
 *
 * @param title of type String. The title of the new student window.
 * @return void
 */
applicationType::DesktopWeb{
	public function stopSelectedViewersStream(userName:String, callingFromVideoWindowClose:Boolean):void{
		if(iVideoWallLayout==null)
			return;
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopSelectedViewersStream:- userName :" + userName)
		
		if( ClassroomContext.isModerator &&  recorder.isRecording && selectedViewersData.length>0  && !callingFromVideoWindowClose) 
		{ 
			if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("stopSelectedViewersStream: Calling endTime for the viewer ; Stream Name: " + userName+"_VIEWER");
			if(recorder.viewerVideoRecorder.currentrecordingStream== userName+"_VIEWER" )
			{
				stopRecordingViewer(userName);
				if( selectedViewersData.length>1)
				{
					if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("stopSelectedViewersStream: Calling recordStream for the viewer ; Stream Name: " + userName+"_VIEWER");
					if (getAudioMuteSOValue() == Constants.FREETALK)
					{
						recordViewer(selectedViewersData[1].userName,getUserSO(selectedViewersData[1].userName).userDisplayName);
					}
				}
			}
				//User log out case
			else if(recorder.viewerVideoRecorder.currentrecordingStream=="" && selectedViewersData.length>1)
			{
				if (getAudioMuteSOValue() == Constants.FREETALK)
				{
					recordViewer(selectedViewersData[1].userName,getUserSO(selectedViewersData[1].userName).userDisplayName);
				}
			}
		} 
		
		var i:int;
		//Remove from the Data array
		for (i=0; i < selectedViewersData.length; i++){
			if (selectedViewersData[i].userName == userName){
				selectedViewersData.removeItemAt(i);
				break;
			}
		}
		for(var j:int=0; j< totalLogInActivity.length; j++)
		{
			if(totalLogInActivity[j].streamName == userName+Constants.VIEWER_APPEND_NAME)
			{
				trace("removeUsercbps = " +totalLogInActivity[j].cbps+ "totalLogInActivity[j].droppedframes =" +totalLogInActivity[j].droppedFrames);
				removedUsersArray.addItem(totalLogInActivity[j]);
				totalLogInActivity.removeItemAt(j);
				break;
			}
		}
		
		iVideoWallLayout.removeVideoDisplay(userName);
		//Bug fix: #7636 - Issue when moderator selects a viewer for interaction.
		//When the last selected user is getting unselected and if the window is in full screen, instead of closing the display, we are just emptying it.
		applicationType::desktop{
			if (selectedViewerDisplays.length == 1 && (selectedViewerDisplays[0] as VideoStreamDisplay).videoFullScreenComp && selectedViewerDisplays[0].userName == userName){
				emptyVideoDisplay=selectedViewerDisplays[0] as VideoStreamDisplay;
				emptyVideoDisplay.resetDisplay();
				selectedViewerDisplays.removeItemAt(0);
			}
			else{
				//Remove from the component array
				for (i=0; i < selectedViewerDisplays.length; i++){
					var videoDisplay:VideoStreamDisplay=selectedViewerDisplays[i] as VideoStreamDisplay;
					if (videoDisplay.userName == userName){
						videoDisplay.closeFullScreen();
						videoDisplay.clearDisplay();
						selectedViewerDisplays.removeItemAt(i);
						break;
					}
				}
			}
		}
		applicationType::web{
			if(selectedViewerDisplays.length == 1 && selectedViewerDisplays[0].userName == userName && isPresenterVideoInFullscreen){
				//Instead of emptyVideoDisplay, used local variable to fix for issue #13940
				var userVideoDisplay:VideoStreamDisplay = selectedViewerDisplays[0] as VideoStreamDisplay;
				userVideoDisplay.resetDisplay();
				selectedViewerDisplays.removeItemAt(0);
			}
			else{
				//Remove from the component array
				for(var i:int=0; i<selectedViewerDisplays.length; i++){
					var videoDisplay:VideoStreamDisplay = selectedViewerDisplays[i] as VideoStreamDisplay;
					if(videoDisplay.userName == userName){
						videoDisplay.closeFullScreen();
						videoDisplay.clearDisplay();
						selectedViewerDisplays.removeItemAt(i);
						break;
					}
				}
			}
		}
		if (selectedViewersData.length == 0){
			classroomComponentSgl.lblSelectedViewers.text="No Selected Viewer";
		}
		if (wbComp && userName == ClassroomContext.userVO.userName){
			wbComp.setDrawingPermission();
		}
		if(userName == ClassroomContext.userVO.userName)
			isChangeNotify = false;
	}
	
	public function setSelectedVideoInVideoWall(userName:String, streamName:String):void{
		videoWallCollaborationObject.lock();
		videoWallCollaborationObject.setValue("selectedUser", userName);
		videoWallCollaborationObject.setValue("selectedStreamName", streamName);
		videoWallCollaborationObject.flush();
		videoWallCollaborationObject.unlock();
	}
}

private var usersNamesForRepublish:ArrayCollection=new ArrayCollection();

private function waitForVideoConnectionForStudent(streamName:String):void{
	usersNamesForRepublish.addItem(streamName);
	clearTimeout(videoConnectionStatusStudentTimeoutId);
	if (!getViewersVideoConnection().ncVideo.isConnected()){
		videoConnectionStatusStudentTimeoutId=setTimeout(waitForVideoConnectionForStudent, 1000, streamName);
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.waitForVideoConnectionForStudent:- VideoConnection is not available. Waiting..SetTimeOutId:" + videoConnectionStatusStudentTimeoutId);
	}
	else{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.waitForVideoConnectionForStudent:- VideoConnection is available.");
		for (var i:int=0; i < usersNamesForRepublish.length; i++){
			startSelectedViewersStream(usersNamesForRepublish[i]);
		}
		usersNamesForRepublish.removeAll();
	}
}

private function waitForVideoConnectionForTeacher():void{
	clearTimeout(videoConnectionStatusTeacherTimeoutId);
	var presenterConnection:VideoConnection=getPresentersVideoConnection(ClassroomContext.subscriber_bandwidthQualityIndex);
	if (!presenterConnection || !presenterConnection.ncVideo.isConnected()){
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.waitForVideoConnectionForTeacher:- VideoConnection is not available. Waiting..");
		videoConnectionStatusTeacherTimeoutId=setTimeout(waitForVideoConnectionForTeacher, 1000);
	}
	else{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.waitForVideoConnectionForTeacher:- VideoConnection is available.");
		startPresentersStream();
	}
}
[Bindable]
public var selectedViewersData:ArrayCollection=new ArrayCollection();
applicationType::DesktopWeb{
	public function resumeSelectedViewersStream(userName:String):void{
		if (!userName || userName == ""){
			return;
		}
		
		var mainTile:VideoStreamDisplay=null
		mainTile=iVideoWallLayout.getMainDisplay();
	
		if (mainTile != null && mainTile.userName == userName){
			mainTile.startStream();
		}
		else{
			for (var i:int=0; i < selectedViewerDisplays.length; i++){
				if (selectedViewerDisplays[i].id == userName + Constants.VIEWER_APPEND_NAME){
					selectedViewerDisplays[i].isCopyVideo=false;
					selectedViewerDisplays[i].startStream();
					break;
				}
			}
		}
		iVideoWallLayout.resizeVideoStreamDisplay();
	}
	
	public function clearViewerStreamDisplay(userName:String):void{
		var mainTile:VideoStreamDisplay=null
		mainTile=iVideoWallLayout.getMainDisplay();
		if (mainTile != null && mainTile.userName == userName){
			mainTile.clearDisplay();
		}
		else{
			for (var i:int=0; i < selectedViewerDisplays.length; i++){
				var display:VideoStreamDisplay=selectedViewerDisplays[i] as VideoStreamDisplay;
				if (display.userName == userName){
					display.clearDisplay();
					break;
				}
			}
		}
	}
	
	public function closeAllFullScreens():void{
		applicationType::web{
			//To close all video popouts.
			ExternalInterface.call("closePopOuts");
		}
		//Close selected viewer full screens
		if (selectedViewerDisplays)
			closeAllViewerFullScreens(selectedViewerDisplays);
		//Close viewed viewer full screens
		if (viewedViewerDisplays)
			closeAllViewerFullScreens(viewedViewerDisplays);
		//Close presenter full screen
		closePresenterFullScreen();
	}
	
	public function closeAllViewerFullScreens(displays:ArrayCollection):void{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.closeAllViewerFullScreens");
		
		for (var i:int=0; i < displays.length; i++){
			var display:VideoStreamDisplay=displays[i] as VideoStreamDisplay;
			display.closeFullScreen();
		}
	}
	
	public function closePresenterFullScreen():void{
		if (iVideoWallLayout) {
			var display:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
			display.closeFullScreen();
		}
	}
	
	public function clearAllViewerStreamDisplays(displays:ArrayCollection):void{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.clearAllViewerStreamDisplays");
		
		for (var i:int=0; i < displays.length; i++){
			var display:VideoStreamDisplay=iVideoWallLayout.getViewerVideoStreamDisplay(displays[i]);
			display.clearDisplay();
		}
	}
	
}
private function closeInteractedUsers():void{
	applicationType::DesktopWeb{
		var interactedViewerDetails:ArrayCollection=selectedViewersData;
		for (var i:int=1; i < interactedViewerDetails.length; i++){
			setUserStatus(interactedViewerDetails[i].userName, Constants.HOLD);
			AuditContext.userAction.userInteractionEndedEventLog(interactedViewerDetails[i].userName, getUserSO(interactedViewerDetails[i].userName).userInteractedCount);
		}
	
	
		if (getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE && actionButtons.chkboxPushToTalk.selected)
		{
			if (getAudioMuteSOValue() != ClassroomContext.currentPresenterName && getAudioMuteSOValue() != selectedViewersData[0].userName)
			{
				setAudioMuteSOValue(ClassroomContext.currentPresenterName);
			}
		}
	}
	applicationType::mobile{
		//selectedViewersData value is set to be null, when moderator/presenter changes video settings to OFF. so used selectedUserArray instead of 'selectedViewersData'.
		if(FlexGlobals.topLevelApplication.isVideoPrefrenceON){
			var interactedViewerDetails:ArrayCollection = selectedViewersData;
			for(var i:int=1; i<interactedViewerDetails.length; i++){
				setUserStatus(interactedViewerDetails[i].userName,Constants.HOLD);
			}
		}else{
			var interactedViewerDetails:ArrayCollection = selectedViewerDetails;
			for(var i:int=1; i<interactedViewerDetails.length; i++){
				setUserStatus(interactedViewerDetails[i].userName,Constants.HOLD);
			}
		}
		if (getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE && actionButtons.pttCheckBoxState){
			if (getAudioMuteSOValue() != ClassroomContext.currentPresenterName && getAudioMuteSOValue() != selectedViewersData[0].userName){
				setAudioMuteSOValue(ClassroomContext.currentPresenterName);
			}
		}
	}
}
private function createSelectedViewerObject(userName:String, streamName:String):Object{
	var selectedViewerObj:Object=new Object();
	selectedViewerObj.userName=userName;
	selectedViewerObj.streamName=streamName;
	return selectedViewerObj;
}
private function createAllinoneItemsObject(contextName:String):Object{
	var itemsObj:Object = new Object();
	itemsObj.contextName = contextName;
	return itemsObj;
}
/**
 * This function is for playing selected student's stream
 *
 * @param streamName of type String (username of selected student)
 * @return void
 */
public function startSelectedViewersStream(userName:String):void{
	applicationType::DesktopWeb{
		if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
			return;
		if (!ClassroomContext.IS_AUDIO_VIDEO_ENABLED)
			return;
		if (!userName || userName == "" || getUserSO(userName).userStatus != Constants.ACCEPT){
			return;
		}
		
		var tempStudentConnection:VideoConnection=getViewersVideoConnection();
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startSelectedViewersStream:- NetConnection Status:" + tempStudentConnection.ncVideo.isConnected());
		
		if (!tempStudentConnection.ncVideo.isConnected()){
			waitForVideoConnectionForStudent(userName);
			return;
		}
		var streamDetails:Object = new Object;
		streamDetails.userName = userName;
		streamDetails.userRole = Constants.VIEWER_ROLE;
		streamDetails.streamName = userName+Constants.VIEWER_APPEND_NAME;
		//var viewerStream:String = streamDetails.streamName;
		streamDetails.timeInterval = 30;
		streamDetails.cbps = 0;
		streamDetails.droppedFrames = 0;
		defaultTime = getCurrentTime();
		streamDetails.startTime = defaultTime;
		getStreamTime(streamDetails.userName);
		/*if(streamDetails.userName == resultInfo.userName){
			streamDetails.startTime = resultInfo.time;
			streamDetails.userName = resultInfo.userName;
		}*/
		totalLogInActivity.addItem(streamDetails);
		trace(" userName= "+userName+ " userRole= "+streamDetails.userRole+ " streamName= "+streamDetails.streamName+" Time= "+streamDetails.startTime);

		if (viewVideoStatus(userName)){
			removeViewerFromViewPanel(userName);
		}
		//If Display is already present, then do not create it again. Simply restart the stream
		for (var i:int=0; i < selectedViewerDisplays.length; i++){
			var videoStreamDisplay:VideoStreamDisplay=selectedViewerDisplays[i] as VideoStreamDisplay;
			if (videoStreamDisplay.userName == userName){
				videoStreamDisplay = iVideoWallLayout.getViewerVideoStreamDisplay(videoStreamDisplay);
				videoStreamDisplay.clearDisplay();
				videoStreamDisplay.startStream();
				iVideoWallLayout.resizeVideoStreamDisplay();
				return;
			}
		}
		selectedViewersData.addItem(createSelectedViewerObject(userName, userName + Constants.VIEWER_APPEND_NAME));
		if (selectedViewersData.length == 1 && videoWallLayout!=Constants.SIMPLE_LAYOUT)
			classroomComponentSgl.lblSelectedViewers.text="Selected Viewers on Video Wall:";
		else if (selectedViewersData.length == 1)
			classroomComponentSgl.lblSelectedViewers.text="Selected Viewers:";
		createSelctedViewerVideoStreamDisplay(userName);
		if (selectedViewersData.length > 0 && ClassroomContext.isModerator && recorder.isRecording && 
			getUserSO(userName).userRole == Constants.VIEWER_ROLE && selectedViewersData[0].userName == userName){
			//When presenter select a viewer for first time, then he is the first accepted viewer
			//If PTT is enabled then we should record the viewer only if he is in un-mute state
			if (getAudioMuteSOValue() == Constants.FREETALK){
				recordViewer(userName, usersCollaborationObject.getData()[userName].userDisplayName);
			}
			else
			{
				//controlViewerRecording();
			}
		}
		
		setupMUIPTT(userName);
		var evt:SyncEvent; //Bug #11318
		audioMuteSyncHandler(evt);
		if (wbComp && userName == ClassroomContext.userVO.userName){
			wbComp.setDrawingPermission();
		}
		if(userName == ClassroomContext.userVO.userName)
			isChangeNotify = false;
		if (getAudioMuteSOValue() != Constants.FREETALK && userName == ClassroomContext.userVO.userName)
		{
			isChangeNotify = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER_MUTED;
			Notification.show(Constants.MUTE_NOTIFICATION, null,Notification.micMute);
				
		}
		
	}
	applicationType::mobile{
		var tempStudentConnection:VideoConnection=getViewersVideoConnection();
		if(!userName || userName == "")
		{
			return;
		}
		
		if(Log.isInfo()) log.info("Video.startSelectedViewersStream:- NetConnection Status:"+tempStudentConnection.ncVideo.isConnected());
		
		if (!tempStudentConnection.ncVideo.isConnected())
		{
			waitForVideoConnectionForStudent(userName);
			return;
		}
		
		isStudentSelected=true;
		//For AVCM: To remove selected viewer stream details from selectedViewersData array and arrLst, if the stream name is already exist.
		for(var j:int=0; j<selectedViewersData.length; j++)
		{
			if(tempStudentConnection.selectedViewerAudioLevelLst.length !=0 && j<tempStudentConnection.selectedViewerAudioLevelLst.length)
			{
				if(tempStudentConnection.selectedViewerAudioLevelLst.source[j].selectedViewerName == userName+Constants.VIEWER_APPEND_NAME)
				{
					tempStudentConnection.selectedViewerAudioLevelLst.removeItemAt(j);
				}
			}
			if(selectedViewersData[j].userName == userName)
			{
				return;
			}
		}
		//For AVCM: To add selected viewer details to selectedViewersData array ,if stream is not exist.
		if(selectedViewersData.length == 0)
		{
			selectedViewersData.addItem(createSelectedViewerObject(userName,userName+Constants.VIEWER_APPEND_NAME));
			//Play selected viewer video after 1 second delay.
			if(FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo)
			{
				FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo.enabled = false;
			}
			FlexGlobals.topLevelApplication.consolidated.viewerTitle = userName;
			FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.addItem(createAllinoneItemsObject(userName));
			FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.refresh();
			if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){	
				setTimeout(setSelectedIndex,100,2);
			}else{
				setTimeout(addSelectedViewerVideoToPanel,1000,null,false);
			}
		}
		else
		{
			for(var i:int=0; i<selectedViewersData.length; i++)
			{
				if(selectedViewersData[i].userName != userName)
				{
					selectedViewersData.addItem(createSelectedViewerObject(userName,userName+Constants.VIEWER_APPEND_NAME));
					addToSelectedViewerList();
					FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.addItem(createAllinoneItemsObject(userName));
					FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.refresh();
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
						if(playSelectedViewerVideo == false)
						{
							stopViewerVideo(userName);
						}
					}
					else{
						setTimeout(setSelectedIndex,100,2);
					}
					//Added to avoid noise, if the user is one among the selected viewer, stops the user stream.
					if(ClassroomContext.userVO.userName != userName)
					{
						//To set viewer video width and height.
						var userVideo:Video;
						if(userVideo != null)
						{
							userVideo.clear();
						}
						userVideo = getVideoDisplaySize(classroomContextObj.userRole);
						tempStudentConnection.stopStream(userName+Constants.VIEWER_APPEND_NAME);
						//Start stream of selected viewer stream.
						tempStudentConnection.startStream(userVideo,null,userName+Constants.VIEWER_APPEND_NAME,true);
						if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
							if(FlexGlobals.topLevelApplication.videoComp!=null){
								FlexGlobals.topLevelApplication.videoComp.selectedViewerType_changeHandler();
							}
						}
					}
					isMaximumSelectedViewer = true;
					break;
				}
			}
			//To display the CPU optimize message , when presenter selects more than one user for interaction.
			if((isMUISelected || isMaximumSelectedViewer) && selectedViewersData.length > 1 && FlexGlobals.topLevelApplication.colbTools.btnVideoModule.enabled == false)
			{
				if(!isMessageDisplayed && selectedViewersData.length>1)
				{
					setTimeout(cpuOptimizeMessage,1000);
				}
			}
		}
		var evt:SyncEvent; //Bug #11318
		audioMuteSyncHandler(evt);
		if (FlexGlobals.topLevelApplication.wbComp && userName == ClassroomContext.userVO.userName){
			FlexGlobals.topLevelApplication.wbComp.setDrawingPermission();
		}
		if(userName == ClassroomContext.userVO.userName)
			isChangeNotify = false;
		if (getAudioMuteSOValue() != Constants.FREETALK && userName == ClassroomContext.userVO.userName){
			isChangeNotify = true;
			Notification.show(Constants.MUTE_NOTIFICATION, null,Notification.micMute);
		}
	}
}
applicationType::mobile{
	private function setSelectedIndex(index:int):void{
		FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = index;
		FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
	}
}
applicationType::DesktopWeb{
	private function setViewerVideoDisplaySize(videoStreamDisplay:VideoStreamDisplay, videoWallPersistence:Boolean):void{
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE){
			if (videoStreamDisplay.isViewVideo){
				videoStreamDisplay.width=160;
			}
			else{
				videoStreamDisplay.percentWidth=90;
			}
		}
	}
}

private function setCloseButtonVideoStreamDisplay():void{
	for (var i:int=0; i < selectedViewerDisplays.length; i++){
		selectedViewerDisplays[i].setCloseButtonVisibility();
	}
}

private var isVideoWallPresent:Boolean=false;
private var isCallFromStartViewersFunction:Boolean=false;
public var selectedViewerDisplays:ArrayCollection=new ArrayCollection();

applicationType::DesktopWeb{
	private function createVideoDisplay(userName:String, isViewVideo:Boolean, streamName:String, videoConnection:VideoConnection):VideoStreamDisplay{
		var displayName:String=getUserSO(userName).userDisplayName;
		var objSelectedViewerComponent:VideoStreamDisplay=null;
		
		//Bug fix: #7636 - Issue when moderator selects a viewer for interaction.
		//When the new user is getting selected, we need to see if there is an empty full screen window or video tile and fill it with new details..
		if (emptyVideoDisplay != null && !isViewVideo){
			objSelectedViewerComponent=emptyVideoDisplay;
			emptyVideoDisplay=null;
		}
		else{
			objSelectedViewerComponent=new VideoStreamDisplay();
		}
		
		objSelectedViewerComponent.getUserSOStatus=getUserSO;
		objSelectedViewerComponent.initVideoStreamDisplay(streamName, displayName, userName, videoConnection, isViewVideo);
		return objSelectedViewerComponent;
	}
}


/**
 *
 * @param objSelectedVideoComponent
 * @param title
 * @param userName
 * @param streamName
 * @param video
 * @param videoConnection
 * @param isVideoPaused
 *
 * This method is invoked when the video needs to be copied to bigscreen from bottompanel.
 *
 *
 */
applicationType::DesktopWeb{
	public function setMainVideoDisplayParams(objSelectedVideoComponent:VideoStreamDisplay, title:String, userName:String, streamName:String, video:Video, videoConnection:VideoConnection, isVideoPaused:Boolean):void{
		var displayName:String=getUserSO(userName).userDisplayName;
		objSelectedVideoComponent.setProperties(title, userName, false, getUserSO(userName).videoHeight, getUserSO(userName).videoWidth);
		objSelectedVideoComponent.getUserSOStatus=getUserSO;
		if (video != null){
			objSelectedVideoComponent.attachVideo(video, videoConnection, streamName, isVideoPaused);
			
		}
		else{
			objSelectedVideoComponent.initVideoStreamDisplay(streamName, title, userName, videoConnection, false);
		}
		changePTTButtonStatus(objSelectedVideoComponent, userName);
	}

	private function createSelctedViewerVideoStreamDisplay(userName:String):void{
		if (!userName || userName == ""){
			return;
		}
		var streamName:String=userName + Constants.VIEWER_APPEND_NAME;
		
		var objSelectedViewerComponent:VideoStreamDisplay=createVideoDisplay(userName, false, streamName, getViewersVideoConnection());
		iVideoWallLayout.addViewerDisplay(objSelectedViewerComponent);
		selectedViewerDisplays.addItem(objSelectedViewerComponent);
	}

	public function maintainFullScreenVideo(selectedViewer:VideoStreamDisplay, vidDisplay:VideoStreamDisplay):void{
		if (vidDisplay.isVideoPaused){
			selectedViewer.video_Receive=selectedViewer.videoReceive_Icon;
			selectedViewer.startStopVideo();
			selectedViewer.isVideoPaused=true;
		}
		applicationType::desktop{
			selectedViewer.videoFullScreenComp=vidDisplay.videoFullScreenComp;
			vidDisplay.videoFullScreenComp.parentWindow=selectedViewer;
			vidDisplay.videoFullScreenComp.vidDispObjParent=selectedViewer.vidDispObj;
			vidDisplay.videoFullScreenComp.removeEventListener(Event.CLOSE, vidDisplay.fullscreenClose);
			selectedViewer.videoFullScreenComp.addEventListener(Event.CLOSE, selectedViewer.fullscreenClose);
			selectedViewer.isVideoReset = true;
		}
		selectedViewer.labelFullScreen.visible=true;
		selectedViewer.btn_studentVideoreceive.enabled=false;
		selectedViewer.vidDispObj.doubleClickEnabled=false;
		selectedViewer.setValues(true);
		vidDisplay.isFullScreenPresent=false;
		vidDisplay.labelFullScreen.visible = false;
		changePTTButtonStatus(selectedViewer, selectedViewer.userName);
	}

	private var timer1:Timer=null;
	
	public function resetPresenterDisplay():void
	{
		if (classroomComponentSgl.pnlTeacher != null){
			var vidDisplay:VideoStreamDisplay=classroomComponentSgl.pnlTeacher;
			vidDisplay.isEmbeddedVideoInVideoWall=false;
			vidDisplay.vidDispObj.doubleClickEnabled=true;
			vidDisplay.resizable=false;
			
			if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				stopPresentersStream();
				vidDisplay.video_Receive=vidDisplay.videoReceive_Icon;
				vidDisplay.btn_studentVideoreceive.setStyle('icon', vidDisplay.videoReceive_Icon);
			}
			if (vidDisplay.widthChangeWatcher == null){
				vidDisplay.widthChangeWatcher=BindingUtils.bindSetter(vidDisplay.setHeight, vidDisplay, "width");
			}
			
			if(classroomComponentSgl.spacerBelowPresenterVideo.width <= 0)
			{
				if(spacerWidth <= 0)
					spacerWidth = classroomComponentSgl.leftPanelTabCanvas.width;
				classroomComponentSgl.spacerBelowPresenterVideo.width = spacerWidth;
			}
			if(classroomComponentSgl.spacerBelowPresenterVideo.width > 0)
				vidDisplay.width=classroomComponentSgl.spacerBelowPresenterVideo.width;
			vidDisplay.setVideoSize();
			vidDisplay.labelBigScreenNotification.visible=false;
		}
	}
	
	private function funTimer(event:TimerEvent):void{
		
		if (classroomContextObj.userRole != Constants.PRESENTER_ROLE){
			classroomComponentSgl.controlvidbox.addChildAt(classroomComponentSgl.pnlTeacher, 0);
			setViewersPresenterPanelDimensions();
		}
		classroomComponentSgl.pnlTeacher.labelBigScreenNotification.visible=false;
		//classroomComponentSgl.pnlTeacher.removeEventListener(MouseEvent.CLICK, onClickVideoTile);
		
		timer1.removeEventListener(TimerEvent.TIMER_COMPLETE, funTimer);
		timer1.stop();
		timer1=null;
	}
	public var notAttachFullscreenVideo:Boolean=false;
	public var viewerStreamNameChecking:String="";
	
	public function showViewerComponentInVideoWall():void{
		var tempStudentConnection:VideoConnection=getViewersVideoConnection();
		var objSelectedViewerComponent:VideoStreamDisplay=new VideoStreamDisplay();
		for (var i:int=0; i < selectedViewerDisplays.length; i++)
		{
			iVideoWallLayout.addViewerDisplay(selectedViewerDisplays[i]);
			if (selectedViewerDisplays[i].isFullScreenPresent && selUser != selectedViewerDisplays[i].userName  && videoWallLayout==Constants.PRESENTER_LAYOUT){
				selectedViewerDisplays[i].isVideoReset=true;
				selectedViewerDisplays[i].closeFullScreen();
				selectedViewerDisplays[i].isFullScreenPresent=false;
			}
		}
	}
	private var userTimeOut:uint;
	
	public function onVideoAdded(event:VideoTileEvent):void{
			var videoTile:VideoStreamDisplay=(event.target as VideoStreamDisplay);
			if (videoTile.userName == videoWallCollaborationObject.getData()["selectedUser"]){
				setMainVideoDisplayParams(iVideoWallLayout.getMainDisplay(), videoTile.title, videoTile.userName, videoTile.id, videoTile.removeVideo(), videoTile.videoConnection, videoTile.isVideoPaused);
			}
			else{
				videoTile.isVideoNotCopiedToMainTile=false;
				videoTile.isCopyVideo=false;
				videoTile.labelBigScreenNotification.visible=false;
				videoTile.startStream();
			}
			videoTile.labelVideoToggleNotification.visible=false;
			videoTile.removeEventListener(VideoTileEvent.VIDEOADDED, onVideoAdded);
	}
	
	public function showPresenterVideoInVideoWall():void
	{
		iVideoWallLayout.addPresenterDisplay(classroomComponentSgl.pnlTeacher);
		classroomComponentSgl.pnlTeacher.id = getPresenterStreamName();
	}
	
	//ASH
	public var objVideoWall:VideoWall=null;
	public var isVideoWall:Boolean=false;
	public var objMeetingVideoWall:edu.amrita.aview.core.video.MeetingVideoWall= null;
	
	public function toggleVideoWall():void
	{
		if(!usersConnection.netConnection.connected)
		{
			CustomAlert.customMessage("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING");
			return;
		}
		if(videoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			showViewerWall(true);
		}
		else if(videoWallLayout != Constants.SIMPLE_LAYOUT)
		{
			videoWallLayout = Constants.SIMPLE_LAYOUT;
			layOutDataChange();
			click_Conso_doc();
			if(classroomComponentSgl!=null)
			{
				classroomComponentSgl.btnShowVideoWall.toolTip = "Show in Video Wall";
				classroomComponentSgl.btnShowVideoWall.setStyle('icon',FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.imgMultiViewerMaximize);
				classroomComponentSgl.btnShowViewersWall.setStyle('disabledIcon',FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multiVideoWall);
				classroomComponentSgl.btnShowViewersWall.useHandCursor=false;
				if(selectedViewersData.length > 0)
				{
					classroomComponentSgl.lblSelectedViewers.text = "Selected Viewers:";
				}
				else
				{
					classroomComponentSgl.lblSelectedViewers.text = "No Selected Viewer";
				}
				
			}
			if(selectedViewerDisplays.length > 0)
				classroomComponentSgl.leftPanelTabNav.selectedIndex = 2;
		}
	}
}
//Fix for issue #17990
public function videoWallResizeHandler():void{
	applicationType::web{
		if(presentationLayout){
			iVideoWallLayout.resizeBaseContainer();
		}
	}
}

public var selUser:String=null;


/**
 *
 * @private
 * Audits the "VideoWallOpen" action, when the presenter/user switches to video wall
 *
 * @return void
 *
 */
private function videoWallOpenEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.videoWallOpen, null, null, null);
}

/*public function setVideoSharedSO(isSelected:Boolean,selectedUser:String,selectedStream:String, videoWallLayout:String):void
{
	usersConnection.netConnection.call("setVideoWallSharedSO",null,isSelected,selectedUser,selectedStream,videoWallLayout);
}*/

/*public function setVideoWallLayout():void
{
	usersConnection.netConnection.call("setVideoWallLayout", null, videoWallLayout);
}*/
applicationType::DesktopWeb{
	public function layoutSelectionChange():void
	{
		if( usersConnection &&!usersConnection.netConnection.connected)
		{
			CustomAlert.customMessage("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING");
			return;
		}
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.vidLayout.rbgLayout.selection == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.vidLayout.rbPresentation)
		{
			videoWallLayout = Constants.PRESENTER_LAYOUT;
		}
		else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.vidLayout.rbgLayout.selection == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.vidLayout.rbDiscussion)
		{
			videoWallLayout = Constants.MEETING_LAYOUT;
		}
		else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.vidLayout.rbgLayout.selection == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.vidLayout.rbSimple)
		{
			setDuringModuleChange(false);
			isDuringModuleChange = false;
			trace("videoWallOpenEventLog");
			videoWallLayout = Constants.SIMPLE_LAYOUT;
		}
		setVideoWallLayout(videoWallLayout);
		/*if(prevVideoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			showViewerWall(true);
		}
		else if(videoWallLayout == Constants.SIMPLE_LAYOUT)
		{
			toggleVideoWall();
		}
		else if(prevVideoWallLayout == Constants.PRESENTER_LAYOUT && videoWallLayout == Constants.MEETING_LAYOUT)
		{
			changetoMeetingLayout();
		}
		else if(prevVideoWallLayout == Constants.MEETING_LAYOUT && videoWallLayout == Constants.PRESENTER_LAYOUT)
		{
			changetoPresenterLayout();
		}
		
		prevVideoWallLayout = videoWallLayout;*/
	}
	
	public function tabButttonChange():void
	{
		classroomComponentSgl.btnShowViewersWall.visible  = true;
		classroomComponentSgl.btnShowViewersWall.enabled  = false;
		classroomComponentSgl.Conso_Doc.enabled=true;
		classroomComponentSgl.Conso_Whiteboard.enabled=true;
		classroomComponentSgl.Conso_vidsharing.enabled=true;
		classroomComponentSgl.Conso_LiveQuiz.enabled = true ;
		classroomComponentSgl.Conso_3DViewer.enabled=true;
		classroomComponentSgl.Conso_PollingQuiz.enabled = true;
		classroomComponentSgl.Conso_2DViewer.enabled=true;
		//Fix for issue #15542
		classroomComponentSgl.btnDesktopSharing.enabled = true;
		pollingFlag=false;
		evaluationFlag=false;
		if (viewer3DLoaded && viewer3DComp && viewer3DComp.viewer3DSWC)
		{
			initviewer3D_flag=0;
			viewer3DComp.viewer3DSWC.removeComponent();
			viewer3DLoaded=false;
		}
		classroomComponentSgl.btnShowViewersWall.useHandCursor=true;
		videoWallOpenEventLog();
	}
	
	private function closeVideoWall(isExitClassroom:Boolean=false):void
	{
		if(iVideoWallLayout==null)
			return;
		applicationType::desktop{
			if(isPopOutPresent)
			{
				videoWallWindow.close();
				isPopOutPresent = false;
				buttonContainer.popOutWindow(isPopOutPresent);
				videoWallWindow.removeEventListener(Event.CLOSE, popOutWindowCloseEvent);
				unSetMessageForFullScreen(classroomComponentSgl.viewerVideoWallBox);
			}
		}
		if (iVideoWallLayout)iVideoWallLayout.closeLayout(true)
		
		videoWallCloseEventLog();
		if(classroomContextObj.userRole==Constants.PRESENTER_ROLE )
		{	
			var selectedUser:String=videoWallCollaborationObject.getData()["selectedUser"];
			if(!isExitClassroom)
			{
				//usersConnection.netConnection.call("toggleVideoWallSelection",null,false);
				toggleVideoWallSelection(false);
				setActiveWindowInSO(0);
			}
			if(!isExitClassroom || selectedUser == ClassroomContext.currentPresenterName)
				setSelectedVideoInVideoWall(null, null);
		}
		applicationType::web{
			//To add fullscreen label to presenter panel, if presenter video pop-out is exist when user closes videoWall
			if(isPresenterVideoInFullscreen){
				classroomComponentSgl.pnlTeacher.labelFullScreen.visible = true;
				//To close presenter pop-out window, while presenter closes video wall
				if(getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE){
					ExternalInterface.call("closePresenterPopOutWindow");
				}
			}
		}
	}
	
	/**
	 *
	 * @private
	 * Audits the "VideoWallClose" action, when the presenter/user closes the video wall
	 *
	 * @return void
	 *
	 */
	private function videoWallCloseEventLog():void
	{
		AuditContext.userAction.createAction(AuditConstants.videoWallClose, null, null, null);
	}
	
	//Issue #176
	/**
	 * This function for removing the 'view video' display object of a student
	 *
	 *
	 * @return void
	 */
	private function remove_viewVideo(selectedItemLabel:String):void{
		removeViewerFromViewPanel(selectedItemLabel);
	}
	
	public function removeAllViewedViewers():void{
		var removeAllViewers:Array;
		classroomComponentSgl.viewVideoTile.removeChildren();
		viewedViewerDisplays.removeAll();
		if (viewedViewerDisplays.length == 0){
			classroomComponentSgl.viewersTile.percentHeight=100;
			setVisiblityViewVideoTile(false);
		}
	}
	
	public function addViewerToViewPanel(uName:String, displayName:String):void{
		var streamName:String=uName + Constants.VIEWER_APPEND_NAME;
		
		var objSelectedViewerComponent:VideoStreamDisplay=createVideoDisplay(uName, true, streamName, getViewersVideoConnection());
		
		viewedViewerDisplays.addItem(objSelectedViewerComponent);
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			setSpaceForViewVideo();
			classroomComponentSgl.viewVideoTile.addElement(objSelectedViewerComponent);
			setViewerVideoDisplaySize(objSelectedViewerComponent, false);
			objSelectedViewerComponent.showCloseButton=false;
		}
		else
		{
			objSelectedViewerComponent.showCloseButton=true;
			iVideoWallLayout.addViewerDisplay(objSelectedViewerComponent);
			
		}
		
		
		objSelectedViewerComponent.getUserSOStatus=getUserSO;
		objSelectedViewerComponent.resizeFactor=objSelectedViewerComponent.RESIZE_FACTOR_SW_VIEW;
		
		objSelectedViewerComponent.resizeFactorTitleWindow=objSelectedViewerComponent.RESIZE_FACTOR_SW_VIEW;
		
	}
	
	
	public function removeViewerFromViewPanel(uName:String):void{
		var tempStudentConnection:VideoConnection=getViewersVideoConnection();
		tempStudentConnection.stopStream(uName + Constants.VIEWER_APPEND_NAME);
		var selectedViewerArray:Array=new Array();
		var i:int;
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			for (i=0; i < classroomComponentSgl.viewVideoTile.numElements; i++){
				selectedViewerArray.push(classroomComponentSgl.viewVideoTile.getElementAt(i));
			}
		}
		else
		{
			iVideoWallLayout.removeVideoDisplay(uName);
		}
		
		for (i=0; i < selectedViewerArray.length; i++){
			if (selectedViewerArray[i].id == uName + Constants.VIEWER_APPEND_NAME){
				classroomComponentSgl.viewVideoTile.removeElementAt(i);
				break;
			}
		}
		for (i=0; i < viewedViewerDisplays.length; i++){
			if (uName + Constants.VIEWER_APPEND_NAME == viewedViewerDisplays[i].id){
				viewedViewerDisplays[i].closeFullScreen();
				viewedViewerDisplays.removeItemAt(i);
				break;
			}
		}
		if (viewedViewerDisplays.length == 0){
			classroomComponentSgl.viewersTile.percentHeight=100;
			setVisiblityViewVideoTile(false);
		}
	}
}

private function refreshButtonStatus(bool:Boolean):void{
	applicationType::DesktopWeb{
		classroomComponentSgl.btnRefresh.enabled=bool;
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.isRefreshBtnEnabled = false;
	}
}

private function timerRefreshUpdate(event:TimerEvent):void{
	applicationType::DesktopWeb{
		refreshButtonStatus(true);
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.isRefreshBtnEnabled = true;
	}
}

/**
 * This function is for refreshing all playing streams(teacher,selected student and all students in view mode).
 *
 *
 * @return void
 */
public function refreshVideo():void{
	applicationType::DesktopWeb{
		var mainVideoTile:VideoStreamDisplay=iVideoWallLayout.getMainDisplay();
		/*if (mainVideoTile!=null && mainVideoTile.labelVideoToggleNotification.visible){
			mainVideoTile.isVideoPaused=true;
		}*/
		
		clearAllViewerStreamDisplays(viewedViewerDisplays);
	}
	
	refreshButtonStatus(false);
	//CRJH: Either the timer has to be stopped after use or replace it with setTimeOut and clear it after use
	var timerRefresh:Timer=new Timer(2000, 1);
	timerRefresh.addEventListener(TimerEvent.TIMER_COMPLETE, timerRefreshUpdate);
	timerRefresh.start();
	applicationType::mobile{
		//For AVCM:Starts------
		//To clear the stream of selected viewer and presenter.
		clearDisplay(viewerStreamName.slice(0,viewerStreamName.lastIndexOf("_")));
		stopPresentersStream();
	}
	//Cleanup the previousUsers_SO, so that we can re process all the users statuses again
	applicationType::DesktopWeb{
		if(ClassroomContext.userVO.role==Constants.MONITOR_TYPE){
			  isRefreshPressed=true;
			for (var i:int=0; i < viewedViewerDisplays.length; i++){
				var display:VideoStreamDisplay=viewedViewerDisplays[i] as VideoStreamDisplay;
				//display.getUserSOStatus=getUserSO;
				display.startStream();
				setViewerVideoDisplaySize(display, false);
			}
				isRefreshPressed=false;
		}
		else{
		clearPreviousUsers_SO();
	}
	applicationType::mobile{
		clearPreviousUsers_SO();
	}
	isRefreshPressed=true;
	
	var evt:SyncEvent;
	applicationType::DesktopWeb{
		videoRefreshEventLog(ClassroomContext.currentPresenterName, "");
	}
	usersSyncHandler(evt);
	startPlayingViewStreams();
	isRefreshPressed=false;
	}
	applicationType::DesktopWeb{
		if (videoWallLayout!=Constants.SIMPLE_LAYOUT && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName){
			startPresentersStream();
		}
		//To resize and re-position video elements in video wall
		iVideoWallLayout.resizeVideoStreamDisplay();
	}
	applicationType::mobile{
		//To strat the stream of selected viewer and presenter.
		if(FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon)
		{
			addSelectedViewerVideoToPanel(viewerStreamName.slice(0,viewerStreamName.lastIndexOf("_")),false);
		}
		else
		{
			addSelectedViewerVideoToPanel(viewerStreamName.slice(0,viewerStreamName.lastIndexOf("_")),true);
		}
		startPresentersStream();
		//For AVCM:Ends------
		startPlayingViewStreams();
		isRefreshPressed = false;
	}
}

/**
 *
 * @private
 * Audits the "VideoRefresh" action, when the presses the refresh button on any video display
 *
 * @param presenterUserName - Username of the current presenter
 * @param viewerUserName - Username of the current interacting viewer
 * @return void
 *
 */
private function videoRefreshEventLog(presenterUserName:String, viewerUserName:String):void
{
	if (viewerUserName == "")
	{
		viewerUserName=null;
	}
	AuditContext.userAction.createAction(AuditConstants.videoRefresh, presenterUserName, viewerUserName, null);
}

/**
 * Function for listing all available audio and video drivers in the corresponding combo box.
 *
 *
 * @return void
 * @see null.
 */
public function initCamList():void{
	applicationType::DesktopWeb{
		//Audio-video setting popup in VideoModule
		pop=new setting;
	}
	videodriver=Camera.names;
	audiodriver=Microphone.names;
	
	//START-----------------------------
	//Check if number of audio and video driver is greater than zero.
	//If yes,set the camselect_flag to 1.
	//		 calling startVideoDisplay().
	//Else ,then no audio and video drivers available.
	//If yes,show appropriate alert message.
	//END-------------------------------
	if (audiodriver.length <= 0){
		Alert.show("Please check your microphone", "Alert");
			//btnStart.enabled=false;
	}
	initApplication();
}

/**
 * Function is used for adding event listener(close event) for A-VIEW.
 *
 *
 * @return void
 * @see initCamList()
 */
public function initApplication():void{
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.initApplication:- Adding the event listener for closing the application");
	//CLOSING event is not available for web
	//Create listener for closing event of the main application 
	applicationType::desktop{
		this.addEventListener(Event.CLOSING, closingApplication);
	}
}
applicationType::mobile{
	private function cleanupVideo():void
	{
		var obj:Object = new Object();
		stopPublish();
		if(Log.isInfo()) log.info("Video.cleanupVideo:- Stopping Presenters stream");
		stopPresentersStream();
		if(Log.isInfo()) log.info("Video.cleanupVideo:- Stopping Selected viewers stream");
		var i:int;
		for (i=0; i < selectedViewersData.length; i++){	
			stopSelectedViewersStream(selectedViewersData[i].userName);
			i=i - 1;
		}
		for (i=0; i < arrVideoConnections.length; i++){
			if (arrVideoConnections[i].connection != null 
				&& arrVideoConnections[i].connection.ncVideo != null 
				&& arrVideoConnections[i].connection.ncVideo.isConnected()){
				if (Log.isInfo()) log.info("Video.cleanupVideo:- Closing the connection, ip :" + arrVideoConnections[i].ip + ":");
				arrVideoConnections[i].connection.closeConnection();
			}
		}
		setVideoPublishStatus(ClassroomContext.userVO.userName, false, obj, 0, 0);
		if(Log.isInfo()) log.info("Video.cleanupVideo:- Exited");
	}
}
applicationType::DesktopWeb{
	private function cleanupVideo():void{
		
		var mainVideoDisplay:VideoStreamDisplay = (iVideoWallLayout != null)? iVideoWallLayout.getMainDisplay() : null;
		if (mainVideoDisplay!=null && mainVideoDisplay.isFullScreenPresent)
		{
			mainVideoDisplay.isVideoReset=false;
			mainVideoDisplay.closeFullScreen();
			mainVideoDisplay.isFullScreenPresent=false;
		}
		var obj:Object=new Object();
		stopPublish();
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.cleanupVideo:- Stopping Presenters stream");
		stopPresentersStream();
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.cleanupVideo:- Stopping Selected viewers stream");
		var i:int;
		for (i=0; i < selectedViewersData.length; i++){
			stopSelectedViewersStream(selectedViewersData[i].userName, false);
			i=i - 1;
		}
		for (i=0; i < arrVideoConnections.length; i++){
			if (arrVideoConnections[i].connection != null 
				&& arrVideoConnections[i].connection.ncVideo != null 
				/*&& arrVideoConnections[i].connection.ncVideo.netConnection */
				&& arrVideoConnections[i].connection.ncVideo.isConnected()){
				if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.cleanupVideo:- Closing the connection, ip :" + arrVideoConnections[i].ip + ":");
				arrVideoConnections[i].connection.closeConnection();
			}
		}
		applicationType::DesktopWeb{
			if (emptyVideoDisplay != null && emptyVideoDisplay.isFullScreenPresent){
				emptyVideoDisplay.isVideoReset=false;
				emptyVideoDisplay.closeFullScreen();
			}
		}
		setVideoPublishStatus(ClassroomContext.userVO.userName, false, obj, 0, 0);
		
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.cleanupVideo:- Exited");
	}
	
	
	/**
	 * Function is used for calling exitEXE fuction.
	 *
	 * @param event of type Event
	 * @return void
	 * @see null
	 */
	public function closingApplication(evt:Event=null):void{
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.closingApplication:- Entering");
		classroomExited = true;
		cleanupVideo();
	}
	
	/**
	 * Function is the event listener of nc.client.stoppedStream for stopping the recording of audio/video stream.
	 *
	 * @param evnt of type CloseEvent
	 * @return void
	 * @see closeapp_error,startRecord()- main.mxml.
	 */
	private function listner(evnt:CloseEvent):void{
		startRecord();
	}
	
	/**
	 * Function is used to display busy cursor, when the 'start' button is applied.
	 *
	 *
	 * @return void
	 * @see removeBusyCursor().
	 */
	public function callBusycursor_video():void{
		// Attaching the busy cursor swf to the swfloader 
		busycursor_video=new SWFLoader;
		busycursor_video.source="assets/flash/video_busyCur.swf";
		
		//START-------------------------------
		//Check if display in multiple mode UI
		//If yes,then sets the x and y position of swfloader.Also,attaches the loader to the video panel.
		//Else,then displayed in consolidated mode UI.
		//Check if user logged in as teacher.
		//If yes,then sets the x and y position of swfloader.Also,attaches the loader to the canvas.
		//Else,logged in as student.
		//If yes,then sets the x and y position of swfloader.Also,attaches the loader to the video panel.
		//END---------------------------------
	
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			busycursor_video.y=classroomComponentSgl.UserlistCanvas.height / 2;
			busycursor_video.x=classroomComponentSgl.UserlistCanvas.width / 2;
			classroomComponentSgl.UserlistCanvas.addChild(busycursor_video);
		}
		else{
			busycursor_video.y=classroomComponentSgl.pnlTeacher.height / 2;
			busycursor_video.x=classroomComponentSgl.pnlTeacher.width / 2;
			classroomComponentSgl.pnlTeacher.addChild(busycursor_video);
		}
		isBusyCursorRunning=true;
	}
	/**
	 * Function is used to remove busy cursor after the user's stream gets started.
	 *
	 *
	 * @return void
	 * @see callBusycursor_video()
	 */
	private function removeBusyCursor():void{
		try{
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.removeBusyCursor:- Entered");
			//START-------------------------------
			//Check if display in multiple mode UI
			//If yes,then remove the busy cursor video.
			//Else,then displayed in consolidated mode UI.
			//Check if user logged in as teacher.
			//If yes,then remove the busy cursor video.
			//Else,logged in as student.
			//If yes,then remove the busy cursor video
			//END---------------------------------
			if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.removeBusyCursor:-  PRESENTER_ROLE");
				if(busycursor_video)
					classroomComponentSgl.UserlistCanvas.removeChild(busycursor_video);
			}
			else{
				if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.removeBusyCursor:-  not PRESENTER_ROLE");
				if(busycursor_video)
					classroomComponentSgl.pnlTeacher.removeChild(busycursor_video);
			}
		}
		catch (Err:Error){
			if(Log.isError()) log.error("Error in removeBusyCursor method :"+ Err.getStackTrace());
		}
		try{
			if(busycursor_video)
				classroomComponentSgl.UserlistCanvas.removeChild(busycursor_video);
		}
		catch (er:Error){
			if(Log.isError()) log.error("Error in removeBusyCursor method::busycursor_video:"+ er.getStackTrace());
		}
	
		isBusyCursorRunning=false;
	}
}
public function muteTeacherAudio(status:Boolean):void{
	try{
		var tempPresenterConnection:VideoConnection;
		tempPresenterConnection=getPresentersVideoConnection(ClassroomContext.subscriber_bandwidthQualityIndex);
		if (tempPresenterConnection){
			tempPresenterConnection.mutePTTStream(getPresenterStreamName(),status);
		}
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.muteTeacherAudio:- presenterStreamName" + getPresenterStreamName()+", isMute :"+status);
		
	}
	catch (Er:Error){
		if(Log.isError()) log.error("Error in muteTeacherAudio method :"+ Er.getStackTrace());
	}
}

public function muteAllOtherViewerStreams(unMuteViewerName:String=""):void{
	try{
		var tempViewerConnection:VideoConnection;
		tempViewerConnection=getViewersVideoConnection();
		tempViewerConnection.muteAllOtherStreams(unMuteViewerName + Constants.VIEWER_APPEND_NAME, getPresenterStreamName());
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.muteSelectedStudentAudio");
	}
	catch (Er:Error){
		if(Log.isError()) log.error("Error in muteAllOtherViewerStreams method :"+ Er.getStackTrace());
	}
}

public function unMuteAllViewerStreams():void{
	try{
		var tempViewerConnection:VideoConnection;
		tempViewerConnection=getViewersVideoConnection();
		tempViewerConnection.unMuteAllStreams();
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.unmuteSelectedStudentAudio");
	}
	catch (Er:Error){
		if(Log.isError()) log.error("Error in unMuteAllViewerStreams method :"+ Er.getStackTrace());
	}
}

/**
 * Function for refreshing audio and video drivers list.
 *
 * @param check of type Boolean
 * @return void
 * @see null.
 */
applicationType::DesktopWeb{
	public function refreshDriverList():void{
		try{
			//Removed OS check, to refresh the audio and video drivers list for all OS.
			applicationType::web{
				var playerVersion:String=Capabilities.version;
				playerVersion=playerVersion.slice(4, 8);
				//JHCR: Why is this checking for Flash Player 11.2?
				if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag && playerVersion != "11,2")
					scanHardware();
			}
			applicationType::desktop{
				//JHCR: Do we really need the check for windows OS, we can disable the scanHardwareEnableFlag for MAC if scanHardware won't work for MAC?
				if ((Capabilities.os.toLowerCase().indexOf("win") > -1) && (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag))
						scanHardware();
			}
		}
		catch (e:Error)	{
			if(Log.isError()) log.error("Error in refreshDriverList method :"+ e.getStackTrace());
		}
		videodriver=Camera.names;
		//Exclude known desktop capturing drivers like 'Screencamera' and 'UscreenCapture' from the video driver list.
		for (var i:int=0; i < videodriver.length; i++){
			if (videodriver[i] == "UScreenCapture" || videodriver[i] == "ScreenCamera HR" || videodriver[i] == "ScreenCamera IM Device")
				videodriver.splice(i, 1);
		}
		audiodriver=Microphone.names;
		if (audiodriver.length > 0 && videodriver.length > 0 && classroomComponentSgl.lblStart.text == "Start")
			classroomComponentSgl.btnStart.enabled=true;
	}
}
/**
 * Function for writing default settings values for Screencamera application.
 *
 *
 * @return void
 * @see null.
 */
public function writeScreenCamFile(installationPath:String):void{
	var writeString_det:String=""
	writeString_det="[webcam]\ndevice=0\nfps=15\nkeepaspectratio=1\nautoconnectdisconnect=1\n" + "userconnect=0\nshow=0\n[screen]\nfps=8\nlayered=0\nshow=0\n[global]\nfirsttime=0\n" + "ontop=0\nvideoformat=720x480\n[snapshot]\nfolder=0\n[videocapture]\nrecordfolder=0\n" + "[video]\naudioline=1\n";
	//File is not available for web
	applicationType::desktop{
		var path:String="file:///" + File.desktopDirectory.nativePath.toString().charAt(0) + ":/Program Files/ScreenCamera/general.ini";
		var _file_det:File=new File(path);
		var _fileStream_det:FileStream=new FileStream();
		_fileStream_det.addEventListener(Event.CLOSE, completeHandler);
		_fileStream_det.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		_fileStream_det.openAsync(_file_det, FileMode.WRITE);
		_fileStream_det.writeUTFBytes(writeString_det);
		_fileStream_det.close();
	}
}

/**
 * Function for handling CLOSE event of filestream (used for writing Screencamera settings file).
 *
 * @param event of type Event
 * @return void
 * @see null.
 */
private function completeHandler(event:Event):void{
	launchScreenCamera("1");
}

/**
 * Function for handling IO_ERROR event of filestream (used for writing Screencamera settings file).
 *
 * @param event of type Event
 * @return void
 * @see null.
 */
private function errorHandler(event:Event):void{
	launchScreenCamera("1");
}

/**
 * Function for launching/terminating Screencamera SDK.
 *
 * @param tempS of type String
 * @return void
 * @see null.
 */
public function launchScreenCamera(tempS:String):void{
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.launchScreenCamera:- Entering");
	if (Capabilities.os.toLowerCase().indexOf("win") > -1){
		//Native access is not available for web
		applicationType::desktop{
			var process:NativeProcess;
			var file:File=File.applicationDirectory;
			if (Capabilities.os.toLowerCase().indexOf("win") > -1){
				file=file.resolvePath("NativeApps/Windows/bin/callSC.exe");
			}
			var nativeProcessStartupInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable=file;
			var processArgs:Vector.<String>=new Vector.<String>(); // Variable for holding parameters
			processArgs[0]="," + tempS;
			nativeProcessStartupInfo.arguments=processArgs;
			processLaunchScreenCamera=new NativeProcess();
			//processLaunchScreenCamera.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			processLaunchScreenCamera.start(nativeProcessStartupInfo);
			if (tempS != "0")
				startStopVideoAfterScreenCameraCheck(videoStartButtonStatus);
		}
	}
}

public function onOutputData(event:ProgressEvent):void{
	applicationType::DesktopWeb{
		//var result:String=processLaunchScreenCamera.standardOutput.readUTFBytes(processLaunchScreenCamera.standardOutput.bytesAvailable);
		startStopVideoAfterScreenCameraCheck(videoStartButtonStatus);
	}
}


/**
 * Function for creating popup for displaying local video of the user in A-VIEW.
 *
 *
 * @return void
 * @see null.
 */
public function callLocalVideo():void{
	
	if (isLocalVideoON == false){
		applicationType::desktop{
			if (Capabilities.os.toLowerCase().indexOf("win") > -1){
				createAndAddMyVideo();
				myVideo.x=FlexGlobals.topLevelApplication.mainApp.stage.stageWidth - myVideo.width - 12;
				myVideo.y=myVideo.height - 10;
			}
			else if (Capabilities.os.toLowerCase().indexOf("mac") > -1){
				createAndAddMyVideo();
				myVideo.x=FlexGlobals.topLevelApplication.mainApp.stage.stageWidth - myVideo.width - 12;
				myVideo.y=myVideo.height - 10;
			}
		}
		//Removed OS check, to view the local video preview window
		applicationType::web{
			createAndAddMyVideo();
		}
	}
}
//RTCR: Need to change the function name
public function createAndAddMyVideo():void
{
	myVideo=new LocalVideo;
	applicationType::desktop{
		PopUpManager.addPopUp(myVideo, this, false);
	}
	//Fix for local video position issue in full screen mode.
	applicationType::web{
		classroomComponentSgl.canvas3.addElement(myVideo);
		myVideo.x=classroomComponentSgl.canvas3.width  - myVideo.width - 12;
		myVideo.y=45;
	}
	isLocalVideoON=true;
}
//Fix for issue #19671
public function myVideoFullscreen():void
{
	applicationType::web{
		if(isLocalVideoFullscreen==false){
			myVideo=new LocalVideo;
			if (!myVideo.isResized){
				myVideo.isFullScreen = true;
				isLocalVideoFullscreen =true;
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.isFullScreen == false){
					FlexGlobals.topLevelApplication.addElement(myVideo);
					isLocalVideoON=true;
					//Set Titlewindow width and height as screen width and application height.Changed width to avoid the close button missing issue when my video is in full screen.
					myVideo.width=this.stage.stageWidth;
					myVideo.height=this.stage.stageHeight;
				}
				else{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.addElement(myVideo);
					isLocalVideoON=true;
					//Set Titlewindow width and height as screen width and application height.Changed width to avoid the close button missing issue when my video is in full screen.
					myVideo.width=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.width//stage.stageWidth;
					myVideo.height=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.height;//stage.stageHeight;
				}
						
				myVideo.canVideo.height = myVideo.height-30;
				myVideo.canVideo.visible = true;
				myVideo.x=0;
				myVideo.y=0;
				myVideo.isResized=true;
				myVideo.toolTip="Double click to tabbed view";
				myVideo.btnShowHide.visible = false;
				myVideo.btnPopoout.visible = false;
				//Added this check to avoid null object reference issue when user resize the browser
				if(myVideo.canVideo.contains(myVideo.displayStreamStrength)){
					myVideo.canVideo.removeElement(myVideo.displayStreamStrength);
				}
				myVideo.buttonContainer.addElement(myVideo.displayStreamStrength);
				myVideo.btnAudioVideoSettings.visible=false;
				myVideo.btnAudioVideoSettings.includeInLayout=false;
			}
		}
		else{
			isLocalVideoFullscreen=false;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.contains(myVideo)){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.removeElement(myVideo);
			}
			if(FlexGlobals.topLevelApplication.contains(myVideo)){
				FlexGlobals.topLevelApplication.removeElement(myVideo);
			}
			myVideo.closePopup();
			createAndAddMyVideo();
			myVideo.setWidowPosition();
		}
	}
}
/**
 * Function for changing position of local video display popup according to A-VIEW's window changes.
 *
 * @param e of type Event
 * @return void
 * @see null.
 */
public function changeMyVideoPosision(e:Event=null):void{
	if (isLocalVideoON == true && myVideo){
		myVideo.setWidowPosition();
	}
}

public function getPresentersVideoConnection(selectedBandwidthIndex:int):VideoConnection{
	if (!ClassroomContext.currentPresenterName || ClassroomContext.currentPresenterName == ""){
		return null;
	}
	var ip:String="";
	if (getUserSO(ClassroomContext.currentPresenterName).userType.toString() == Constants.STUDENT_TYPE){
		ClassroomContext.subscriber_bandwidthQualityIndex=0;
		selectedBandwidthIndex=0;
	}
	
	ClassroomContext.presenterBandwidth=videoPresenterServerData[selectedBandwidthIndex].bandWidth;
	
	return getVideoConnectionByIP(videoPresenterServerData[selectedBandwidthIndex].ip);
}

public function getVideoConnectionByIP(ip:String):VideoConnection{
	//	if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.getVideoConnectionByIP:- ip:"+ip+":");
	
	var vc : VideoConnection = null;
	for (var j:int=0; j < arrVideoConnections.length; j++){
		if (arrVideoConnections[j].ip == ip){
			vc =  arrVideoConnections[j].connection;
			break;
		}
	}	
	return vc;
}

////Issue #226 ---END
private function getViewersVideoConnection():VideoConnection{
	var vc : VideoConnection = null;
	for (var j:int=0; j < arrVideoConnections.length; j++){
		if (arrVideoConnections[j].ip == videoViewerServerData[0].ip){
			ClassroomContext.viewerBandwidth=videoViewerServerData[0].bandWidth;
			vc = arrVideoConnections[j].connection; 
			break;
		}
	}
	return vc;
}

public function getAverageBandwidthRating():Number{
	var ave:Number=0;
	applicationType::DesktopWeb{
		if (VideoStreamDisplay.STREAM_STRENGTH_CALCULATION_COUNT > 0)
		{
			ave=VideoStreamDisplay.STREAM_STRENGTH_SUM / VideoStreamDisplay.STREAM_STRENGTH_CALCULATION_COUNT;
		}
	}
	return ave;
}

private function sameServersForPresenterANDViewer():Boolean{
	//In Multibit rate, return false
	if (videoPresenterServerData.length > 1){
		return false;
	}
	
	if (getViewersVideoConnection().ipFMS == getPresentersVideoConnection(0).ipFMS){
		return true;
	}
	return false;
}

private function startCapture(userRole:String):void{
	if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startCapture:- entered with userRole:" + userRole);
	var i:int=0;
	if(userRole == Constants.VIEWER_ROLE){
		isUserIntraAlertDuringReconnection = true;
	}
	for (i=0; i < avParametersData.length; i++){
		if (arrVideoConnections[avParametersData[i].parameters.connectionIndex].connection.ncVideo.isConnected()){
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startCapture:- Video is connected");
			if (avParametersData[i].parameters.serverType == ((userRole == Constants.PRESENTER_ROLE) ? Constants.FMS_PRESENTER : Constants.FMS_VIEWER) || avParametersData[i].parameters.serverType == ((userRole == Constants.PRESENTER_ROLE) ? Constants.MEETING_FMS_PRESENTER : Constants.MEETING_FMS_VIEWER)){
				if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startCapture:- calling callStartCapture");
				callStartCapture(avParametersData[i]);
				if (avParametersData[i].parameters.serverType == Constants.FMS_VIEWER || avParametersData[i].parameters.serverType == Constants.MEETING_FMS_VIEWER){
					break;
				}
			}
		}
		else{
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startCapture:- Video is NOT connected");
			waitForConnection(userRole);
			break;
		}
	}
}

private function waitForConnection(userRole:String):void{
	if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.waitForConnection:- entered with userRole:" + userRole);
	clearTimeout(videoConnectionStatusTimeoutId);
	var isAllConnected:Boolean=true;
	for (var i:int=0; i < avParametersData.length; i++){
		if (!arrVideoConnections[avParametersData[i].parameters.connectionIndex].connection.ncVideo.isConnected()){
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.waitForConnection:- video is NOT connected");
			isAllConnected=false
			break;
		}
	}
	if (isAllConnected){
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.waitForConnection:- VideoConnection is available.");
		startCapture(userRole);
	}
	else{
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.waitForConnection:- video is NOT connected waiting for 1 more sec");
		videoConnectionStatusTimeoutId=setTimeout(waitForConnection, 1000, userRole);
	}
}

private function callStartCapture(avParametersData:Object):void{
	applicationType::DesktopWeb{
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
		{
			if(Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callStartCapture:- Calling startCapture with PortNo:"+avParametersData.parameters.socketPortNo);
			arrVideoConnections[avParametersData.parameters.connectionIndex].connection.startCapture(avParametersData.parameters.socketPortNo,"startCapture")
			return;
		}
	}
	applicationType::mobile{
			FlexGlobals.topLevelApplication.sliderDrawer.stopLocalVideo();
			setTimeout(FlexGlobals.topLevelApplication.sliderDrawer.startLocalVideo,1000);
	}
	if (!VideoConnection.isInternalCodec(ClassroomContext.aviewClass.videoCodec)){
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callStartCapture:- Calling startCapture with PortNo:" + avParametersData.parameters.socketPortNo);
		
		arrVideoConnections[avParametersData.parameters.connectionIndex].connection.startCapture(avParametersData.parameters.socketPortNo, "startCapture")
	}
	else{
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callStartCapture:- Calling startInternalCodecCapture with PortNo:" + avParametersData.parameters.socketPortNo);
		arrVideoConnections[avParametersData.parameters.connectionIndex].connection.startInternalCodecCapture(avParametersData.parameters.socketPortNo);
	}
}

private function stopCapture(userRole:String):void{
	var i:int=0;
	if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.stopCapture:- userRole:" + userRole + ":");
	for (i=0; i < avParametersData.length; i++){
		if (arrVideoConnections[avParametersData[i].parameters.connectionIndex].connection.ncVideo.isConnected()){
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.stopCapture:- Video is connected");
			if (avParametersData[i].parameters.serverType == ((userRole == Constants.PRESENTER_ROLE) ? Constants.FMS_PRESENTER : Constants.FMS_VIEWER) || avParametersData[i].parameters.serverType == ((userRole == Constants.PRESENTER_ROLE) ? Constants.MEETING_FMS_PRESENTER : Constants.MEETING_FMS_VIEWER)){
				if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.stopCapture:-calling callStopCapture method");
				callStopCapture(avParametersData[i]);
				if (avParametersData[i].parameters.serverType == Constants.FMS_VIEWER || avParametersData[i].parameters.serverType == Constants.MEETING_FMS_VIEWER){
					break;
				}
			}
		}
		else{
			if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.stopCapture:- Video is NOT connected");
		}
	}
	isUserIntraAlertDuringReconnection = false;
}

private function callStopCapture(avParametersData:Object):void{
	applicationType::DesktopWeb{
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
		{
			if(Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callStopCapture:- Calling VideoConnection.stopCapture with PortNo"+avParametersData.parameters.socketPortNo);
			arrVideoConnections[avParametersData.parameters.connectionIndex].connection.stopCapture(avParametersData.parameters.socketPortNo,"stopCapture");
			return;
		}
	}
	if (!VideoConnection.isInternalCodec(ClassroomContext.aviewClass.videoCodec)){
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callStopCapture:- Calling VideoConnection.stopCapture with PortNo" + avParametersData.parameters.socketPortNo);
		arrVideoConnections[avParametersData.parameters.connectionIndex].connection.stopCapture(avParametersData.parameters.socketPortNo, "stopCapture")
	}
	else{
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.callStopCapture:- Calling VideoConnection.stopInternalCodecCapture with PortNo" + avParametersData.parameters.socketPortNo);
		arrVideoConnections[avParametersData.parameters.connectionIndex].connection.stopInternalCodecCapture(avParametersData.parameters.socketPortNo);
	}
}

public function setPublishingBandwidth():void{
	/*if(ClassroomContext.userVO.role==Constants.STUDENT_TYPE){*/
	var i:int;
	if (ClassroomContext.aviewClass.isMultiBitrate == "Y"){
		for (i=0; i < videoServersData.length; i++){
			if (videoServersData[i].serverType == Constants.FMS_VIEWER || videoServersData[i].serverType == Constants.MEETING_FMS_VIEWER){
				videoServersData[i].bandWidth=ClassroomContext.publisherVideoQuality;
				break;
			}
		}
	}
	else{
		for (i=0; i < videoServersData.length; i++){
			videoServersData[i].bandWidth=ClassroomContext.publisherVideoQuality;
		}
	}
}

public function isVideoPublishedState():Boolean{
	var publishedState:Boolean=false;
	for (var i:int=0; i < arrVideoConnections.length; i++){
		if (arrVideoConnections[i].connection.isVideoInPublish()){
			publishedState=true;
			break;
		}
	}
	return publishedState;
}

public function internalCodecMultipleBitratePublish(i:int):Object{
	var paramObj:Object;
	applicationType::DesktopWeb{
		var cameraIndex:int=0;
		for (cameraIndex=0; cameraIndex < Camera.names.length; cameraIndex++){
			if (Camera.names[cameraIndex] == "ScreenCamera HR"){
				break;
			}
		}
		paramObj=new Object();
		paramObj.camIndex=cameraIndex;
		paramObj.micIndex=pop.micSelect.selectedIndex;
		paramObj.camWidth=avParametersData[i].parameters.videoCaptureWidth;
		paramObj.camHeight=avParametersData[i].parameters.videoCaptureHeight;
		if (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264){
			paramObj.codec="h264";
		}
		else if (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON){
			paramObj.codec="sorenson";
		}
		
		paramObj.camFPS=avParametersData[i].parameters.fps;
		paramObj.bandwidth=avParametersData[i].parameters.bandwidth;
		paramObj.quality=avParametersData[i].parameters.quality;
		paramObj.streamName=avParametersData[i].parameters.streamName;
		paramObj.FMS_URL=ClassroomContext.protocolFMS + "://" + videoPresenterServerData[i].ip + ":" + ClassroomContext.portFMS + "/" + Constants.VIDEO_SERVER_MODULE_NAME + "/" + avParametersData[i].parameters.className.toString() + "_" + ClassroomContext.aviewClass.classId;
	}
	return paramObj;
}

public function cameraToScreenCamera(attachStatus:uint, videoDriverName:String):void{
	//File and nativeprocess are not available for web.
	applicationType::desktop{
		var file:File=File.applicationDirectory;
		var nativeProcessStartupInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
		var processArgs:Vector.<String>=new Vector.<String>();
		
		processArgs.push("," + attachStatus.toString() + "," + videoDriverName + ",");
		nativeProcessStartupInfo.arguments=processArgs;
		file=file.resolvePath("NativeApps/Windows/bin/AttachCam.exe");
		nativeProcessStartupInfo.executable=file;
		processAttachCam=new NativeProcess();
		processAttachCam.start(nativeProcessStartupInfo);
		
		if (attachStatus == 1)
			attachedCameraToScreenCamera=true;
		else
			attachedCameraToScreenCamera=false;
	}
}



public function muiHandler(newValue:String=null, oldValue:String=null):void{
	
	if (muiCollaborationObject.getData()["MUIData"] == "true"){
		isMUISelected=true;
		actionButtons.isMUISelected = true;
		interactionMUICount=ClassroomContext.aviewClass.maxViewerInteraction;
		applicationType::mobile{
			addRestrictionUserSelection();
		}
	}
	else{
		isMUISelected=false;
		actionButtons.isMUISelected = false;
		interactionMUICount=1;
		applicationType::mobile{
			removeRestrictionUserSelection();
		}
	}
	if(	ClassroomContext.aviewClass.classType=="Meeting" &&
		ClassroomContext.isModerator &&
		(muiCollaborationObject.getData()["MUIData"]==undefined ||
			muiCollaborationObject.getData()["MUIData"]==null) )
	{
		interactionMUICount = ClassroomContext.aviewClass.maxViewerInteraction;
		isMUISelected = true;
		actionButtons.isMUISelected = true;
	}
	
}

private function muiSOValueSet(value:String):void{
	muiCollaborationObject.lock();
	muiCollaborationObject.setValue("MUIData", "null");
	muiCollaborationObject.setValue("MUIData", value);
	muiCollaborationObject.flush();
	muiCollaborationObject.unlock();
}


/**
 * This function closes the video connection
 */
public function closeVideoConnections():void{
	for (var i:int=0; i < arrVideoConnections.length; i++){
		arrVideoConnections[i].connection.isConnectionDroppedManually=true;
		arrVideoConnections[i].connection.closeConnection();
	}
}

private function selectViewerTab():void{
	applicationType::DesktopWeb{
		if (ClassroomContext.currentPresenterName != "" && ClassroomContext.userVO.userName != ClassroomContext.currentPresenterName && isViewerSelected){
			if (userListCreated){
				classroomComponentSgl.leftPanelTabNav.selectedIndex=2;
			}
		}
	}
}

public function userListCreationCompleteHandler():void{
	userListCreated=true;
	selectViewerTab();
}

public function updateMemberAudioActivityLevel():void{
	applicationType::DesktopWeb{
		//set to true if the audio level of any participant is varied by a margin of 300
		var audioBitRateChanged:Boolean=false;
		for (var index:int=0; index < selectedViewerDisplays.length; index++){
			//current audioBytesPerSecond of audio of netstream  
			(selectedViewerDisplays[index] as VideoStreamDisplay).updateStreamAudioActivity();
			
		}
		if (classroomComponentSgl){
			classroomComponentSgl.pnlTeacher.updateStreamAudioActivity();
		}
	}
}

/////////snapshot///////
public function createSnapshotComp():void{
	applicationType::DesktopWeb{
		if(Log.isDebug()) log.debug("createSnapshotComp");
		//SMCR: whenever createSnapshotComp() is invoked , a new snapshotObj is created. a new snapshotComponent is only needed
		//when this function is invoked
		snapshotObj =  entryFac.snapshotComponent();
		snapshotObj.faceImage.visible=false;
		this.addElement(snapshotObj);
		//snapshotObj.setValues(ClassroomContext.CONTENT_RECORD_SERVER, ClassroomContext.portWAMP, ClassroomContext.aviewClass.className, ClassroomContext.userVO.userName, ClassroomContext.userVO.photoCaptureFrequencySecs); //delay in seconds
		snapshotObj.setValues(ClassroomContext.CONTENT_RECORD_SERVER,ClassroomContext.portWAMP,ClassroomContext.FMS_USER,ClassroomContext.portFMS,Constants.COLLABORATION_SERVER_MODULE_NAME,ClassroomContext.lecture.lectureId,ClassroomContext.aviewClass.className,ClassroomContext.aviewClass.classId,ClassroomContext.aviewClass.classType,ClassroomContext.userVO.userName,(ClassroomContext.aviewClass.monitorIntervalFreq*60)); //delay in seconds
	
	}
}

public function removeSnapshotComp():void{
	if(Log.isDebug()) log.debug("removeSnapshotComp()");
	snapshotObj.stopSnapshotTimer();
	snapshotObj.faceImage.attachCamera(null);
	this.removeElement(snapshotObj);
	snapshotObj=null;
}

private function changeLayoutMessgeReconnection():void
{
	applicationType::DesktopWeb{
		if(getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT)
		{
			if(iVideoWallLayout.getMainDisplay().userName != ClassroomContext.userVO.userName)
			{
				for (var i:int=0; i < selectedViewerDisplays.length; i++){
					var videoStreamDisplay:VideoStreamDisplay=selectedViewerDisplays[i] as VideoStreamDisplay;
					if (videoStreamDisplay.userName == ClassroomContext.userVO.userName){
						//videoStreamDisplay = iVideoWallLayout.getViewerVideoStreamDisplay(videoStreamDisplay);
						videoStreamDisplay.labelBigScreenNotification.visible = false;
						return;
					}
				}
			}
		}
	}
}
/////////////////
applicationType::web{
	//This function will be invoked from javascript when users close the pop out window.
	public function popOutCloseHandler(streamName:String,userType:String):void{
		var userActionSharedObject:SharedObject = SharedObject.getLocal("lsoStatus"+streamName,"/");
		var localSharedObjectStatus:String = userActionSharedObject.data.lsoStatus;
		presenterPttStatus ="";
		//When user gets presenter control
		if(streamName == "isPopOutClosedByAview"){
			if(presenterLocalConnectionIsConnected && presenterVideoLocalConnection){
				try{
					presenterVideoLocalConnection.close();
				}
				catch(e:Error){
					trace(e.toString());
				}
			}
			//Fix for issue #16782
			if (videoWallLayout != Constants.SIMPLE_LAYOUT ) {
				showPresenterVideoInVideoWall();
			}
			classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
			classroomComponentSgl.pnlTeacher.labelFullScreen.visible = false;
			isPresenterVideoInFullscreen = false;
			classroomComponentSgl.btnRefresh.enabled=true;
			classroomComponentSgl.pnlTeacher.doubleClickEnabled=true;
			return;
		}
		if(localSharedObjectStatus == "streamNotStarted"){
			//Fix for issue #18558
			if(presenterLocalConnectionIsConnected && presenterVideoLocalConnection){
				try{
					presenterVideoLocalConnection.close();
				}
				catch(e:Error){
					trace(e.toString());
				}
			}
			if(videoWallCollaborationObject.getData()["isSelected"]==true){
				//Fix for issue #16782
				if (videoWallLayout == Constants.PRESENTER_LAYOUT ) {
					showPresenterVideoInVideoWall();
				}
				else{
					addPresenterVideoInPresenterpanel();
				}
			}
			else{
				//To close video wall, if presenter video reconnection has happened and viewer had manually opened video wall and viewed presenter video in popout
				addPresenterVideoInPresenterpanel();
			}
			classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
			classroomComponentSgl.pnlTeacher.labelFullScreen.visible = false;
			isPresenterVideoInFullscreen = false;
			classroomComponentSgl.btnRefresh.enabled=true;
			return;
		}	
		
		var userNameFromStream:String;
		//Local Shared Object for communication when the Video in fullscreen is closed
		var videoFlagSharedObject:SharedObject=SharedObject.getLocal(streamName + "_videoData","/");
		isVideoStopped=videoFlagSharedObject.data.isVideoStopped;
		userName = videoFlagSharedObject.data.streamName;
		videoFlagSharedObject.clear();
		//If viewer has opened presenter video in pop-out window from presenter panel/Video wall
		if(userType == Constants.PRESENTER_ROLE && classroomContextObj.userRole != Constants.PRESENTER_ROLE){
			if(presenterLocalConnectionIsConnected && presenterVideoLocalConnection){
				try{
					presenterVideoLocalConnection.close();
				}
				catch(e:Error){
					trace(e.toString());
				}
			}
			if(videoWallCollaborationObject.getData()["isSelected"]==true){
				//Fix for issue #16782
				if (videoWallLayout == Constants.PRESENTER_LAYOUT ) {
					showPresenterVideoInVideoWall();
				}
				else{
					addPresenterVideoInPresenterpanel();
				}
			}
			else{
				//Fix for issue #17238
				//To close video wall, if presenter video reconnection has happened and viewer had manually opened video wall and viewed presenter video in popout
				addPresenterVideoInPresenterpanel();
				
			}
			classroomComponentSgl.btnRefresh.enabled=true;
		}
			//If presenter has opened his/her video in pop-out window from Video wall
		else if(userType == Constants.PRESENTER_ROLE && classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			if(presenterLocalConnectionIsConnected && presenterVideoLocalConnection){
				try{
					presenterVideoLocalConnection.close();
				}
				catch(e:Error){
					trace(e.toString());
				}
			}
			//Fix for issue #16782
			if (videoWallLayout != Constants.SIMPLE_LAYOUT ) {
				//Fix for issue #17640
				addPresenterVideoInPresenterpanel();
			}
			classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
			classroomComponentSgl.pnlTeacher.labelFullScreen.visible = false;
			isPresenterVideoInFullscreen = false;
			classroomComponentSgl.btnRefresh.enabled=true;
		}
		else if(userType == Constants.PRESENTER_ROLE && ClassroomContext.currentPresenterName != streamName){
			if(presenterLocalConnectionIsConnected && presenterVideoLocalConnection){
				try{
					presenterVideoLocalConnection.close();
				}
				catch(e:Error){
					trace(e.toString());
				}
			}
			classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
			isPresenterVideoInFullscreen = false;
		}
		else if(userType == Constants.VIEWER_ROLE){ //For Selected viewer video
			userNameFromStream = streamName.substring(0,streamName.lastIndexOf("_"));
			for(var i:int =0; i<selectedViewerDisplays.length; i++){
				var videoStreamDisplay:VideoStreamDisplay = selectedViewerDisplays[i] as VideoStreamDisplay;
				if(videoStreamDisplay.userName == userNameFromStream){
					//Stop the Selected viewer video if user clicks on stop video button in pop out window. 
					if(isVideoStopped==true && userName == userNameFromStream+Constants.VIEWER_APPEND_NAME){
						videoStreamDisplay.isVideoPaused = true;
						videoStreamDisplay.video_Receive = videoStreamDisplay.videoNotReceive_Icon;
						videoStreamDisplay.labelVideoToggleNotification.visible = true;
						videoStreamDisplay.btn_studentVideoreceive.toolTip = "Start Viewing Video";
						videoStreamDisplay.vidDispObj.doubleClickEnabled = false;
						stopSelectedViewersStream(streamName,false);
					}
				}
				for(var j:int=0; j<selectedViewerFullScreen.length; j++){
					if(selectedViewerFullScreen[j].streamName == streamName){
						if(viewerLocalConnectionIsConnected){
							viewerVideoLocalConnection.close();
							viewerLocalConnectionIsConnected = false;
						}
						if(selectedViewerDisplays[i].userName == userNameFromStream){
							selectedViewerFullScreen.removeItemAt(j);
							videoStreamDisplay.labelFullScreen.visible = false;
							//To publish Selected viewer Stream
							startSelectedViewersStream(userNameFromStream);
						}
					}
				}
			}
			//Fix for issue #8542;
			for(var i:int=0; i<connectionNameArray.length;i++){
				if(connectionNameArray[i] == "AVIEWViewerVideoParent_" + streamName){
					//Remove connection name from array
					connectionNameArray.splice(i,1);
				}
			}
		}
		else{ //For View Video
			userNameFromStream = streamName.substring(0,streamName.lastIndexOf("_"));
			//Added this check to avoid view video blank issue when Presenter close view video
			if(viewVideoStatus(userNameFromStream)){
				remove_viewVideo(userNameFromStream);
				addViewerToViewPanel(userNameFromStream,getUserSO(userNameFromStream).userDisplayName);
				isViewVideoInFullscreen = false;
			}
		}
	}
	//Function to send stream details to full screen window receivedStreamDetailsFromParent is a function defined in the videoPopOut module loader.
	public function presenterFullscreenVideoData(videoPath:String,streamName:String,userFullName:String,receiveAudio:String,userType:String,isAudioOnly:Boolean,isViewer:Boolean):void{
		if(setTimeOutID){
			clearTimeout(setTimeOutID);
		}
		//Get presenter video publish bandwidth
		var publishingBandwidth:int;
		var streamDetails:Object = getUserSO(ClassroomContext.currentPresenterName).streamBandwidth;
		if(ClassroomContext.subscriber_bandwidthQualityIndex == 0 && streamDetails!=null){
			publishingBandwidth = streamDetails.pBandwidth0;
		}
		else if(ClassroomContext.subscriber_bandwidthQualityIndex == 1 && streamDetails!=null){
			publishingBandwidth = streamDetails.pBandwidth1;
		}
		else if(ClassroomContext.subscriber_bandwidthQualityIndex == 2 && streamDetails!=null){
			publishingBandwidth = streamDetails.pBandwidth2;
		}
		if(presenterVideoLocalConnection){
			presenterVideoLocalConnection.send("AVIEWPresenterVideoParent", "receivedStreamDetailsFromParent", videoPath,streamName,userFullName,receiveAudio,userType,isAudioOnly,publishingBandwidth,isViewer);
		}
	}
	//Function to send stream details to full screen window receivedStreamDetailsFromParent is a function defined in the videoPopOut module loader.
	public function viewerFullscreenVideoData(videoPath:String,streamName:String,userFullName:String,receiveAudio:Boolean,userType:String,isAudioOnly:Boolean):void{
		if(setTimeOutID){
			clearTimeout(setTimeOutID);
		}
		//Fix for issue #8542;
		if(isMUISelected){ //MUI is ON
			for(var i:int=0; i<connectionNameArray.length;i++){
				if(connectionNameArray[i] == "AVIEWViewerVideoParent_" + streamName){
					if(viewerVideoLocalConnection){
						viewerVideoLocalConnection.send(connectionNameArray[i], "receivedStreamDetailsFromParent", videoPath,streamName,userFullName,receiveAudio,userType,isAudioOnly);
						break;
					}
				}
			}
		}
		else {//MUI is OFF
			if(viewerVideoLocalConnection){
				viewerVideoLocalConnection.send(connectionName, "receivedStreamDetailsFromParent", videoPath,streamName,userFullName,receiveAudio,userType,isAudioOnly);
			}
		}
	}
	//Create Local Shared Object to get selected viewers video fullscreen details (streamName, userType and status).This function is invoked from javascript
	public function getLSOStatus(streaName:String,usertype:String):void{
		lsoFullscreenDetails = SharedObject.getLocal("lsoStatus"+streaName ,"/"); 
		if(lsoFullscreenDetails.data.streamName == null){
			streamName = streaName;
			userType = usertype;
		}
		else{
			streamName = lsoFullscreenDetails.data.streamName ;
			userType = lsoFullscreenDetails.data.userType ;
		}
		videoFullscreenStatus = lsoFullscreenDetails.data.lsoStatus ;
		if(videoFullscreenStatus == null){
			return;
		}
		for(var j:int=0; j<selectedViewerFullScreen.length; j++){
			//Added this check to fix issues #8538 and #8564
			if(isMUISelected){
				if(selectedViewerFullScreen[j].streamName == streamName){
					selectedViewerFullScreen.removeItemAt(j);
					selectedViewerFullScreen.addItem(createSelectedViewerFullScreenObject(streamName,userType,videoFullscreenStatus));
				}
			}
			else{
				//remove current selected viewer from array and add new selected viewer details
				selectedViewerFullScreen.removeItemAt(j);
				selectedViewerFullScreen.addItem(createSelectedViewerFullScreenObject(streamName,userType,videoFullscreenStatus));
			}
		}
	}
	//Function to create selected viewers fullscreen details.This function will be invoked from javascript when users open the pop out window.
	public function createSelectedViewerFullScreenArray(streamName:String,userType:String,fullscreenVideoStatus:String):void{
		if(userType == Constants.VIEWER_ROLE){
			selectedViewerFullScreen.addItem(createSelectedViewerFullScreenObject(streamName,userType,fullscreenVideoStatus));
		}
	}
	//Function to create selected viewers fullscreen object.
	public function createSelectedViewerFullScreenObject(streamName:String,userType:String,fullscreenVideoStatus:String):Object{
		var selectedViewerFullscreenObj:Object = new Object();
		selectedViewerFullscreenObj.userType = userType;
		selectedViewerFullscreenObj.streamName = streamName;
		selectedViewerFullscreenObj.videoStatus = fullscreenVideoStatus;
		return selectedViewerFullscreenObj;
	}
	//Function to update selected viewers fullscreen details.This function will be invoked from javascript when users close the pop out window.
	public function updateVideoFullscreenLSO(streamName:String,userType:String):void{
		lsoFullscreenDetails = SharedObject.getLocal("lsoStatus"+streamName,"/"); 
		if(streamName == null || userType == null){
			lsoFullscreenDetails.data.lsoStatus = "streamNotStarted";
		}
		else{
			lsoFullscreenDetails.data.lsoStatus = "streamClose";
		}
		lsoFullscreenDetails.flush();
	}
	//To send PTT status to Presenter pop-out window , if Presenter video is in pop-out window.
	//receivedAudioStatusFromParent is a function, which is defined in videoPopOut module loader.
	public function presenterAudioStatusData(pttStatus:String):void{
		if(presenterVideoLocalConnection){
			presenterVideoLocalConnection.send("AVIEWPresenterVideoParent", "receivedAudioStatusFromParent", pttStatus);
		}
		else{
			presenterPopOutReceiveAudio = pttStatus;
		}
	}
	//To view presenter video in presenter panel, after closing presenter pop-out window
	private function addPresenterVideoInPresenterpanel():void{
		classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
		classroomComponentSgl.pnlTeacher.labelFullScreen.visible = false;
		isPresenterVideoInFullscreen = false;
		//Stop Presenter video if user clicks on stop video button in pop-out window. 
		if(isVideoStopped==true){
			//To stop presenter video
			classroomComponentSgl.pnlTeacher.isVideoPaused = true;
		}
		//To publish Presenter stream
		startPresentersStream();
		classroomComponentSgl.pnlTeacher.doubleClickEnabled=true;
	}
	//To view presenter video in video wall, after closing presenter pop-out window
	private function addPresenterVideoInVideoWall():void{
		objVideoWall.bigScreenDisplay.isFullScreenPresent=false;
		for(var i:int=1;i<objVideoWall.baseContainer.numElements;i++){
			var currentTile:VideoStreamDisplay=objVideoWall.baseContainer.getElementAt(i) as VideoStreamDisplay;
			if(currentTile.name == "pnlTeacher"){
				currentTile.isFullScreenPresent = false;
				currentTile.labelFullScreen.visible = false;
				break;
			}
		}
		isPresenterVideoInFullscreen = false;
		//Stop Presenter video if user clicks on stop video button in pop-out window. 
		if(isVideoStopped==true){
			//To stop presenter video in videoWall
			objVideoWall.bigScreenDisplay.isVideoPaused = true;
		}
		//To publish Presenter stream
		startPresentersStream();
		objVideoWall.bigScreenDisplay.doubleClickEnabled=true;
	}
	//To view presenter video in meeting video wall, after closing presenter pop-out window
	private function addPresenterVideoInMeetingVideoWall():void{
		var currentTile:VideoStreamDisplay;
		for(var i:int=0;i<objMeetingVideoWall.mainTile.numElements;i++){
			currentTile=objMeetingVideoWall.mainTile.getElementAt(i) as VideoStreamDisplay;
			if(currentTile.name == "pnlTeacher"){
				currentTile.isFullScreenPresent = false;
				currentTile.labelFullScreen.visible = false;
				currentTile.isFullScreenPresent = false;
				break;
			}
		}
		isPresenterVideoInFullscreen = false;
		//Stop Presenter video if user clicks on stop video button in pop-out window. 
		if(isVideoStopped==true){
			//To stop presenter video in videoWall
			currentTile.isVideoPaused = true;
		}
		//To publish Presenter stream
		startPresentersStream();
		currentTile.doubleClickEnabled=true;
	}
	//This method will get called from popout child window, if there is any changes in PTT.
	public function receivedAudioStatusFromChild(audioState:String,userName:String):void {
		if(audioState == "mute"){
			if(userName == ClassroomContext.currentPresenterName){
				actionButtons.talkMute(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getFirstAcceptedViewerAdmin());
			}
			else{
				actionButtons.talkMute(userName);
			}
		}
		else{
			actionButtons.talkMute(userName);
		}
	}
	//Fix for issue #17750
	//This method will get called from popout child window, if there is any changes in video start/stop.
	public function receivedVideoStatusFromChild(videoState:String,userName:String):void {
		var presenterDisplay:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
		var mainDisplay:VideoStreamDisplay=iVideoWallLayout.getMainDisplay();
		if(videoState == "stop"){
			presenterDisplay.isVideoPaused=true;
			mainDisplay.video_Receive=mainDisplay.videoNotReceive_Icon;
			mainDisplay.btn_studentVideoreceive.setStyle('icon', mainDisplay.videoNotReceive_Icon);
			presenterDisplay.btn_studentVideoreceive.toolTip="Start Viewing Video";
			presenterDisplay.vidDispObj.doubleClickEnabled=false;
			presenterDisplay.hBoxWaterMark.doubleClickEnabled=false;
			presenterDisplay.videoConnection.toggleVideo(userName, false);
		}
		else{
			presenterDisplay.isVideoPaused=false;
			mainDisplay.video_Receive=mainDisplay.videoReceive_Icon
			mainDisplay.btn_studentVideoreceive.setStyle('icon', mainDisplay.videoReceive_Icon);
			presenterDisplay.btn_studentVideoreceive.toolTip="Stop Viewing Video";
			mainDisplay.setFullScreenToolTip();
			presenterDisplay.videoConnection.toggleVideo(userName, true);
		}
	}
	
	//This function will be invoked from javascript when pop out window is getting loaded.
	public function getValueFromPopOutWindow():void{
		presenterVideoLocalConnection = new LocalConnection();
		presenterVideoLocalConnection.client = this;
		presenterVideoLocalConnection.allowDomain("*");
		try{
			presenterVideoLocalConnection.addEventListener(StatusEvent.STATUS,onStatusChange);
			presenterVideoLocalConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);
			presenterVideoLocalConnection.connect("AVIEWPresenterPopOutChild");
		}
		catch(error:ArgumentError){
			trace(error.toString());
		}
		setTimeout(sendDetailsToChildWindow,100);
	}
	//To send presenter video stream details to popout window
	private function sendDetailsToChildWindow():void{
		if(setTimeOutIDPopout){
			clearTimeout(setTimeOutIDPopout);
		}
		if(presenterVideoLocalConnection){
			    presenterVideoLocalConnection.send("AVIEWPresenterVideoParent", "receivedStreamDetailsFromParent",presenterPopOutVideoPath,presenterPopOutStreamName,presenterPopOutUserFullName,presenterPopOutReceiveAudio,presenterPopOutUserType,presenterPopOutIsAudioOnly,presenterPopOutPublishingBandwidth,presenterPopOutIsViewer);
		}
	}
	//To save presenter video details
	public function presenterPopOutWindowVideoData(videoPath:String,streamName:String,userFullName:String,audioStatus:String,userType:String,isAudioOnly:Boolean,isViewer:Boolean):void
{
		presenterPopOutVideoPath = videoPath;
		presenterPopOutStreamName = streamName;
		presenterPopOutUserFullName = userFullName;
		presenterPopOutReceiveAudio = audioStatus;
		presenterPopOutUserType = userType;
		presenterPopOutIsAudioOnly = isAudioOnly;
		presenterPopOutIsViewer = isViewer;
		//Get presenter video publish bandwidth
		var publishingBandwidth:int;
		var streamDetails:Object = getUserSO(ClassroomContext.currentPresenterName).streamBandwidth;
		if(ClassroomContext.subscriber_bandwidthQualityIndex == 0 && streamDetails!=null){
			publishingBandwidth = streamDetails.pBandwidth0;
		}
		else if(ClassroomContext.subscriber_bandwidthQualityIndex == 1 && streamDetails!=null){
			publishingBandwidth = streamDetails.pBandwidth1;
		}
		else if(ClassroomContext.subscriber_bandwidthQualityIndex == 2 && streamDetails!=null){
			publishingBandwidth = streamDetails.pBandwidth2;
		}
		presenterPopOutPublishingBandwidth = publishingBandwidth;
	}
	//Status change event listner for LocalConnection
	private function onStatusChange(event:StatusEvent):void{
		switch (event.level) {
			case "status":
				presenterLocalConnectionIsConnected = true;
				trace("LocalConnection connected");
				break;
			case "error":
				presenterLocalConnectionIsConnected = false;
				trace("LocalConnection connection failed");
				break;
		}
	}
	//Async error handler
	private function asyncErrorHandler(event:AsyncErrorEvent):void {
		trace("AsyncErrorEvent: " + event);
	}
}
applicationType::mobile{
	public function stopSelectedViewersStream(userName:String):void
	{
		var tempStudentConnection:VideoConnection=getViewersVideoConnection();
		if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.stopSelectedViewersStream:- viewerStreamName :"+userName);
		//AVCM: To remove selected viewer stream details from selectedViewersData array and arrLst.
		for(var i:int=0; i<selectedViewersData.length; i++)
		{
			if(tempStudentConnection.selectedViewerAudioLevelLst.length !=0 && i<tempStudentConnection.selectedViewerAudioLevelLst.length)
			{
				if(tempStudentConnection.selectedViewerAudioLevelLst.source[i].selectedViewerName == userName+Constants.VIEWER_APPEND_NAME)
				{
					tempStudentConnection.selectedViewerAudioLevelLst.removeItemAt(i);
				}
			}
			if(selectedViewersData[i].userName == userName)
			{
				selectedViewersData.removeItemAt(i);
				if(FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType != null){//FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
					if(selectedViewersData.length > 1){
						FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.selectedIndex = selectedViewersData.length-1;
						break;
					}else{
						FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.visible=false;
						FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.includeInLayout=false;
						FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.visible = true;
						FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.includeInLayout = true;
						FlexGlobals.topLevelApplication.videoComp.viewerVideoTitle = Constants.VIEWER_VIDEO_TITLE+getUserSO(currentSelectedViewer).userDisplayName;
					}
					FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
				}
				if(selectedViewersData.length == 0){
					currentSelectedViewer = "";
				}
				if(getUserSO(userName)!= null)
				{
					if(getUserSO(userName).userStatus != Constants.ACCEPT)
					{
						removeFromSelectedviewerList(userName);
					}
				}
				isSelectedViewerVideoStopped = false;
				if(viewerStreamName == userName+Constants.VIEWER_APPEND_NAME)
				{
					videoUnPauseStudentNotification();
					if (studentVideo)
					{
						studentVideo.clear();
					}					
					try
					{
						viewerStreamName="";
						FlexGlobals.topLevelApplication.videoComp.viewerVideoTitle = "";
						FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoFadeIcon;
						FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.enabled = false;
						FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.removeElement(objViewerAudioOnlyMode);
					}
					catch(er:Error)
					{
						
					}
					break;
				}
			}
		}
		for(var j:int = 0; j < FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length; j++){
			if(FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length >=(j+3)){
				if(FlexGlobals.topLevelApplication.consolidated.allinoneItemsData[j+2].contextName == userName){
					FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.removeItemAt(j+2);
					FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.refresh();
						if(FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length >= 3){
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length-1;
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
							break;
						}else{
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex =0;
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
						}
				}
			}
		}
		var streamingStatusCount:Object = selectedViewerStreamingCount();
		if(streamingStatusCount.videoCount == 0 && teacherVideo != null){
			if(streamingStatusCount.videoCount == 0 && getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing){
				FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.percentWidth = 100;
				FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=true;
				FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=true;
				FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=false;
				FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=false;
				FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=false;
				FlexGlobals.topLevelApplication.videoComp.container.visible=false;
			}
			else if(streamingStatusCount.videoCount == 0 && !getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing )
			{
				FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=true;
				FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=true;
				FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=true;
				FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=true;
				FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=true;
				FlexGlobals.topLevelApplication.videoComp.container.visible=true;
				FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.percentWidth=50;
				FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.percentWidth=50;
			}
		}
		tempStudentConnection.stopStream(userName+Constants.VIEWER_APPEND_NAME);
		//AVCM:To reset isVideoStoppedManually, when there is no user for interaction
		if(selectedViewersData.length == 0)
		{
			if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
				for(var i:int = 0; i < FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length; i++){
					if(FlexGlobals.topLevelApplication.consolidated.allinoneItemsData[i].contextName == FlexGlobals.topLevelApplication.consolidated.viewerTitle){
						FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.removeItemAt(i);
					}
				}
				FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = 0;
			}
			isVideoStoppedManually = false;
		}
		if (FlexGlobals.topLevelApplication.wbComp && userName == ClassroomContext.userVO.userName){
			FlexGlobals.topLevelApplication.wbComp.setDrawingPermission();
		}
		if(FlexGlobals.topLevelApplication.screenTypes != Constants.SCREENTYPE_ALLINONE && isPresenterVideoPaused){
			setTimeout(videoPause_notification,300);
		}
		if(userName == ClassroomContext.userVO.userName){
			isChangeNotify = false;
		}
	}
	
	//For AVCM: To add Selected Viewer Video to panel if any one of the selected viewer released the interaction and Selected viewer count is more than 2. 
	public function addSelectedViewerVideoToPanel(userName:String,callFromList:Boolean):void
	{
		var tempStudentConnection:VideoConnection = getViewersVideoConnection();
		//If video connection is not exist
		if(!tempStudentConnection.ncVideo.isConnected())
		{
			return;
		}
		
		//To remove selected viewer stream details from selectedViewersData arrLst.
		for(var j:int=0; j<selectedViewersData.length; j++)
		{
			if(userName != null)
			{
				currentSelectedViewer = userName;
			}
			else
			{
				currentSelectedViewer = selectedViewersData[i].userName;
			}
			/*if(tempStudentConnection.selectedViewerAudioLevelLst != null)
			{
				if(tempStudentConnection.selectedViewerAudioLevelLst.length != 0 && j<tempStudentConnection.selectedViewerAudioLevelLst.length)
				{
					if(tempStudentConnection.selectedViewerAudioLevelLst.source[j].selectedViewerName == currentSelectedViewer+Constants.VIEWER_APPEND_NAME)
					{
						tempStudentConnection.selectedViewerAudioLevelLst.removeItemAt(j);
					}
				}
				tempStudentConnection.stopStream(userName+Constants.VIEWER_APPEND_NAME);
			}*/
			tempStudentConnection.stopStream(previousSelecViewer+Constants.VIEWER_APPEND_NAME);
		}
		//To add selected viewer to panel based on the priority of the selection.
		for(var i:int = 0;i<selectedViewersData.length; i++)
		{
			playSelectedViewerVideo = false;
			if(userName != null)
			{
				currentSelectedViewer = userName;
			}
			else
			{
				if(viewerStreamName != "")
				{
					currentSelectedViewer = viewerStreamName.slice(0,viewerStreamName.lastIndexOf("_"));
				}
				else
				{
					if(FlexGlobals.topLevelApplication.isVideoPrefrenceON)
					{
						for(var k:int = 0;k<selectedViewersData.length;k++)
						{
							currentSelectedViewer = selectedViewersData[k].userName;
							break;
						}
					}
					else
					{
						for(var l:int = 0;l<selectedViewerDetails.length;l++)
						{
							currentSelectedViewer = selectedViewerDetails[l].userName;
							break;
						}
					}
				}
				if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
					if(playSelectedViewerVideo == false)
					{
						stopViewerVideo(currentSelectedViewer);
					}
				}
				
			}
			//To avoid null abject reference issue.
			if(getUserSO(currentSelectedViewer)!= null)
			{
				if(getUserSO(currentSelectedViewer).userStatus == Constants.ACCEPT)
				{
					tempStudentConnection.stopStream(currentSelectedViewer+Constants.VIEWER_APPEND_NAME);
					var isSelectedDifferentUser:Boolean=true;
					if (currentSelectedViewer == ClassroomContext.userVO.userName)
					{
						isSelectedDifferentUser=false;
					}
					if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
						if(viewerVideo != null){
							viewerVideo.clear();
						}
						tempStudentConnection.startStream(viewerVideo,null,currentSelectedViewer+Constants.VIEWER_APPEND_NAME,isSelectedDifferentUser);
						FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.viewerVideoContainer.width = 100;
						viewerVideo.visible = true;
						removePauseViewerLabel();
						FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideoDisplay.addChild(viewerVideo);
						FlexGlobals.topLevelApplication.consolidated.viewerTitle = Constants.VIEWER_VIDEO_TITLE+getUserSO(currentSelectedViewer).userDisplayName;
					}
					else{
						//To set selcted viewer video width and height based on the user type.
						if(studentVideo != null)
						{
							studentVideo.clear();
							//Mobile: For future reference
							/*if(studentVideo!=null && FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay!=null && FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo!=null){
								FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay.removeChild(studentVideo);
							}*/
						}
						studentVideo = getVideoDisplaySize(classroomContextObj.userRole,Constants.VIEWER_ROLE);
						studentVideo.smoothing = true;
						if(Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("Video.startSelectedViewersStream:- studentVideo.width :"+studentVideo.width+", studentVideo.height :"+studentVideo.height.toString());
						//Start viewing selected viewer stream
						tempStudentConnection.startStream(studentVideo,null,currentSelectedViewer+Constants.VIEWER_APPEND_NAME,isSelectedDifferentUser);
						videoUnPauseStudentNotification();
						//To set selcted viewer title and icon
						if(FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo!=null)
						{
							FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay.addChild(studentVideo);
							FlexGlobals.topLevelApplication.videoComp.viewerVideoTitle = Constants.VIEWER_VIDEO_TITLE+getUserSO(currentSelectedViewer).userDisplayName;
							//if selected viewer stops his/her video
							if(getUserSO(currentSelectedViewer).isVideoPublishing)
							{
								FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoReceiveIcon;
								FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.enabled = true;
							}
						}
						if(FlexGlobals.topLevelApplication.videoComp!= null && FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType!= null && FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.visible && FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.selectedIndex == -1){
							for(var m:int = 0;m<selectedViewersData.length; m++)
							{
								if(currentSelectedViewer == selectedViewersData[m].userName){
									FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.selectedIndex = m;
									break;
								}
							}
						}
						try{
							if((getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing))
							{
								if(FlexGlobals.topLevelApplication.videoComp.studentVideoContainer!= null){
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=true;
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=true;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=true;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=true;
									FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=true;
									FlexGlobals.topLevelApplication.videoComp.container.visible=true;
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.percentWidth=50;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.percentWidth=50;
									if(FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.width == studentVideo.width)
									{
										studentVideoChange(FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.width,FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.height);
									}
									else{
										setTimeout(FlexGlobals.topLevelApplication.videoComp.setStudentWidth,100,FlexGlobals.topLevelApplication.width);
									}
								}
								if(isPresenterVideoPaused){
									setTimeout(videoPause_notification,500);
								}
							}
							else
							{
								if(FlexGlobals.topLevelApplication.videoComp.studentVideoContainer!= null){
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.percentWidth = 100;
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.includeInLayout=false;
									FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible=false;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.includeInLayout=true;
									FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible=true;
									FlexGlobals.topLevelApplication.videoComp.container.includeInLayout=false;
									FlexGlobals.topLevelApplication.videoComp.container.visible=false;
									studentVideoChange(FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.width,FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.height);
								}
							}
						}
						catch(err:Error){}
						if(isVideoStoppedManually && !callFromList)//To stop the video, if user maualy pause the video
						{
							startStopViewerVideo(true);
						}
						else if(!callFromList && !playSelectedViewerVideo)//To stop selected viewer video, if presenter selects multiple user for interaction
						{
							stopViewerVideo(currentSelectedViewer);
						}
						//To display the CPU optimize message , when presenter selects more than one user for interaction.
						if((isMUISelected || isMaximumSelectedViewer) && selectedViewersData.length > 1 && FlexGlobals.topLevelApplication.colbTools.btnVideoModule.enabled == false)
						{
							if(!isMessageDisplayed && selectedViewersData.length>1)
							{
								setTimeout(cpuOptimizeMessage,1000);
							}
						}
					}
					if(getUserSO(currentSelectedViewer).isVideoPublishing){
						setTimeout(showViewVideo,500,getUserSO(currentSelectedViewer).isAudioOnlyMode,getUserSO(currentSelectedViewer).isVideoHide,getUserSO(currentSelectedViewer).isAudioMute,Constants.VIEWER_ROLE);
					}
					//To change the icon and add 'Audio only Notification', If seelcted viewer in Audio only mode,
					if(getUserSO(currentSelectedViewer)!= null && getUserSO(currentSelectedViewer).isAudioOnlyMode)
					{
						//viewerAudioOnlyNotification();
						FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoFadeIcon;
						if(FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive != null)
						{
							FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.enabled = false;
						}
					}
					viewerStreamName = currentSelectedViewer+Constants.VIEWER_APPEND_NAME;
					setAudioMuteStatusForStream();
					removeFromSelectedviewerList(currentSelectedViewer);
					addToSelectedViewerList();
					previousSelecViewer = currentSelectedViewer;
					break;
				}
			}
		}
	}
	//For AVCM: To check whether user is selectyedviewer or not.
	public function isSelectedUser(userName:String):Boolean
	{
		var isExist:Boolean = false;
		for(var i:int = 0;i<selectedViewersData.length ; i++)
		{
			if(selectedViewersData[i].userName == userName)
			{
				isExist = true;
				break;
			}
		}
		return isExist;
	}
	private function setSelectedStudentVideoTitle(displayName:String):void
	{
		if(AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES)
		{
			var regularPanelTitle:String;
			if(displayName != null)
			{
				regularPanelTitle = displayName;
				fullScreenStudentTitle=regularPanelTitle +" (A-VIEW Classroom)";
			}
			else
			{
				regularPanelTitle = "No Viewer Selected";
				fullScreenStudentTitle=regularPanelTitle +" (A-VIEW Classroom)";
			}
		}
		else
		{
			
		}
	}
	//Add the restriction to interact with tablet user , when presenter is turned ON the MUI.
	private function addRestrictionUserSelection():void{
		/*if(!isvideoPublished && FlexGlobals.topLevelApplication.videoPublishStatus && getUserSO(ClassroomContext.userVO.userName).userRole == Constants.VIEWER_ROLE)
		{
			isRestrictionAdded = true;
			FlexGlobals.topLevelApplication.sendMuiStatus();
			isvideoPublished = true;
			//To set user status as HOLD.
			setUserStatus(ClassroomContext.userVO.userName,Constants.HOLD);
			MessageBox.show("Your video has been stopped as the presenter has turned on Multiple User Interaction(MUI) feature. Once the presenter turns off MUI, your video will start automatically and you can handraise/interact with the Presenter.","Info - CPU usage optimization",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
		}*/
	}
	//Remove the restriction to interact with tablet user, when presenter is turned OFF the MUI.
	private function removeRestrictionUserSelection():void{
		/*if(isvideoPublished && !FlexGlobals.topLevelApplication.videoPublishStatus && getUserSO(ClassroomContext.userVO.userName).userRole == Constants.VIEWER_ROLE)
		{
			FlexGlobals.topLevelApplication.sendMuiStatus();
			isvideoPublished = false;
		}*/
		if(FlexGlobals.topLevelApplication.videoComp!= null && FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType!= null){
			FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.visible = false;
		}
	}
	//To display the CPU optimize message.
	public function cpuOptimizeMessage():void
	{
		var streamingStatusCount:Object = selectedViewerStreamingCount();
		if(infoMessageDisplayCount==0 && streamingStatusCount.videoCount>=2)
		{
			MessageBox.show("Video of Selected Viewer is stopped to optimize your CPU usage, but you will be able to hear everyone.","Info",MessageBox.MB_OK, null,null,null,MessageBox.IC_INFO);
			//To set flag for message diaplay at viewer's end.
			isMessageDisplayed = true;
			infoMessageDisplayCount++;
		}
	}
	public function startStopViewerVideo(isManual:Boolean):void
	{
		var tempPresenterConnection:VideoConnection;
		var isStreamManipulated:Boolean=false;
		var netStreamStatus:Boolean=false;
		
		tempPresenterConnection=getViewersVideoConnection();
		
		netStreamStatus=tempPresenterConnection.doesStreamExist(viewerStreamName);
		if(getUserSO(currentSelectedViewer).isVideoHide == false && getUserSO(currentSelectedViewer).isAudioMute == false){
			if(netStreamStatus)
			{
				isStreamManipulated=true;
				if (FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoReceiveIcon)
				{
					//AVCM:AuditContext.userAction.viewerVideoToggleEventLog("Video Stopped",ClassroomContext.viewerBandwidth,ClassroomContext.currentViewerName);
					isSelectedViewerVideoPaused=true;
					videoPause_studentNotification();
					//To remove the last frame of selected viewer.
					if (studentVideo)
					{
						studentVideo.visible = false;
						studentVideo.clear();
					}
					FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon;
					FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.toolTip="Start Viewing Video";
					//To stop the video, if user maualy pause the video
					if(isManual)
					{
						isVideoStoppedManually = true;
					}
					netStreamStatus=tempPresenterConnection.toggleVideo(viewerStreamName,false);
					
				}
				else if (FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon)
				{
					//AVCM:	AuditContext.userAction.viewerVideoToggleEventLog("Video Resumed",ClassroomContext.viewerBandwidth,ClassroomContext.currentViewerName);
					isSelectedViewerVideoPaused=false;
					videoUnPauseStudentNotification();
					//Set video visibilty as true to view the video of presenter
					if (studentVideo)
					{
						studentVideo.visible = true;
						FlexGlobals.topLevelApplication.videoComp.viewerVideoTitle = Constants.VIEWER_VIDEO_TITLE+getUserSO(currentSelectedViewer).userDisplayName;
					}
					FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoReceiveIcon;
					//Play the video for entire session when selected viewer video had stopped and if user clicks on unmute video button.
					if(isSelectedViewerVideoStopped && isManual)
					{
						playSelectedViewerVideo = true;
					}
					FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.toolTip="Stop Viewing Video";
					if(isManual)
					{
						isVideoStoppedManually = false;
					}
					netStreamStatus=tempPresenterConnection.toggleVideo(viewerStreamName,true);
				}
			}
		}
	}
	//For AVCM: To remove selected user from selectedviewerList component, if presenter stops interaction with user.
	private function removeFromSelectedviewerList(viewerName:String):void{
		for(var j:int=0; j<userAudioStrength.length; j++)
		{
			if(userAudioStrength.source[j].selectedViewerName == viewerName+Constants.VIEWER_APPEND_NAME)
			{
				userAudioStrength.removeItemAt(j);
				FlexGlobals.topLevelApplication.videoComp.selectedViewer.dataProvider = userAudioStrength;
				FlexGlobals.topLevelApplication.videoComp.selectedViewer.updateList();
				break;
			}
		}
	}
	//For AVCM: Add selected user to selectedviewerList component, if presenter add user for interaction.
	private function addToSelectedViewerList():void{
		if(selectedViewersData.length != 0)
		{
			for(var j:int=0; j<selectedViewersData.length; j++)
			{
				var userName:String = selectedViewersData[j].userName;
				var isUserExist:Boolean = false;
				if(getUserSO(userName)!=null)
				{
					if(getUserSO(userName).userStatus == Constants.ACCEPT && userName+Constants.VIEWER_APPEND_NAME !=viewerStreamName)
					{
						if(FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo)
						{
							FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo.enabled = true;
						}
						//Check whether username is already exist in userAudioStrength arraylist.
						for(var i:int=0; i<userAudioStrength.length; i++)
						{
							if(userAudioStrength.source[i].selectedViewerName == userName+Constants.VIEWER_APPEND_NAME)
							{
								isUserExist = true;
							}
						}
						//If username is not exist, add userdetails to arraylist.
						if(!isUserExist)
						{
							userAudioStrength.addItem({selectedViewerName:userName+Constants.VIEWER_APPEND_NAME,selectedViewerAudioStrength:0});
							FlexGlobals.topLevelApplication.videoComp.selectedViewer.dataProvider = userAudioStrength;
							FlexGlobals.topLevelApplication.videoComp.selectedViewer.updateList();
							break;
						}
					}
				}
			}
		}
		
	}
	private function getVideoDisplaySize(type:String,videoType:String = null):Video
	{
		var videoSize:Video;
		if(type == Constants.PRESENTER_ROLE && FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo)
		{
			var videoWidth:int = (FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.height*4)/3;
			if(FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.width == FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.width+3)
			{
				videoSize = new Video(videoWidth+14,FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.height);
			}else{
				videoSize = new Video(videoWidth,FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.height);
			}
		}
		else if(type == Constants.VIEWER_ROLE && FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo)
		{
			if(videoType == Constants.VIEWER_ROLE)
			{
				videoSize = new Video(FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.width,FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.height);
			}
			else
			{
				videoSize = new Video(FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.width,FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.height);
			}
		}
		else
		{
			videoSize = new Video(310,290);
		}
		return videoSize;
	}
	//For AVCM: To return the selected viewer streaming options count
	public function selectedViewerStreamingCount():Object{
		var audioOnlyModeUserCount:int = 0;
		var videoUserCount:int = 0;
		var userStreamingCount:Object = new Object();
		for(var i:int=0; i<selectedViewersData.length; i++)
		{
			if(getUserSO(selectedViewersData[i].userName).isAudioOnlyMode)
			{
				audioOnlyModeUserCount++;
			}
			else
			{
				videoUserCount++;
			}
		}
		userStreamingCount.audioCount = audioOnlyModeUserCount;
		userStreamingCount.videoCount = videoUserCount;
		return userStreamingCount;
	}
	//For AVCM:Stop the selected viewer video, if selected viewer count is more than 1 and if user streaming mode is 'Audio-Video mode'.
	private function stopViewerVideo(userName:String):void
	{
		var streamingStatusCount:Object = selectedViewerStreamingCount();
		if(streamingStatusCount.videoCount>=2)
		{
			if(FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType!=null){
				FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.visible=true;
				FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.includeInLayout=true;
				FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.visible = false;
				FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.includeInLayout = false;
			}
			if(!getUserSO(userName).isAudioOnlyMode)
			{
				
				if(!isSelectedViewerVideoStopped || selectedViewersData.length >1 && viewerStreamName != "" && FlexGlobals.topLevelApplication.colbTools.btnVideoModule.enabled == false)
				{
					setTimeout(stopSelectedViewerVideoStream,100,viewerStreamName);
					isSelectedViewerVideoStopped = true;
				}
			}
		}
		else{
			if(FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType!= null){
				FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.visible=false;
				FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.includeInLayout=false;
			}
			if(FlexGlobals.topLevelApplication.videoComp.studentVideoTitle!= null){
				FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.visible = true;
				FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.includeInLayout = true;
			}
		}
	}
	private function viewerAudioOnlyNotification():void
	{
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
			pauseViewerAllinOneVideo("Audio Only Mode");
		}else{
			videoPause_studentNotification("Audio Only Mode");
		}
	}
	//For AVCM: To stop the selected viewer video, if selected viewer count is more than 1/previous video start/stop state is STOP.
	private function stopSelectedViewerVideoStream(userName:String):void
	{
		var tempStudentConnection:VideoConnection = getViewersVideoConnection();
		for(var i:int = 0;i<selectedViewersData.length; i++)
		{
			if(viewerStreamName == selectedViewersData[i].streamName && !getUserSO(selectedViewersData[i].userName).isAudioOnlyMode)
			{
				videoPause_studentNotification();
				//To remove the last frame of selected viewer.
				if (studentVideo)
				{
					studentVideo.visible = false;
					studentVideo.clear();
				}
				FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon;
				tempStudentConnection.toggleVideo(viewerStreamName,false);
				break;
			}
		}
		if(FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive!=null){
			FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.toolTip="Start Viewing Video";
		}
	}
	/**
	 * Function for resuming the teacher video.
	 *
	 * @param null
	 * @return void
	 * @see null.
	 */
	private function videoUnPauseNotification():void
	{
		try{
			if(FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.contains(VIDEO_PAUSE_LABEL_TEACHER)){
				FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.removeElement(VIDEO_PAUSE_LABEL_TEACHER);
			}
		}catch (er:Error){}
	}
	private function removePausePresenterLabel():void
	{
		try{
			if(FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideo.contains(VIDEO_PAUSE_LABEL_TEACHER)){
				FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideo.removeElement(VIDEO_PAUSE_LABEL_TEACHER);
			}
		}catch (er:Error){
		}
	}
	/**
	 * Function for resuming the selected student's video.
	 *
	 * @param null
	 * @return void
	 * @see null.
	 */
	private function videoUnPauseStudentNotification():void{
		try{
			if(FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.contains(VIDEO_PAUSE_LABEL_STUDENT)){
				FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.removeElement(VIDEO_PAUSE_LABEL_STUDENT);
			}
		}catch (er:Error){}
	}
	private function videoPause_studentNotification(text:String = null):void
	{
		//AVCM: To add label to proper place on student panel based on the usertype.
		if(FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo != null)
		{
			if(classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				VIDEO_PAUSE_LABEL_STUDENT.x = (FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.width+14) - 60;
				VIDEO_PAUSE_LABEL_STUDENT.y = FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.height / 2 - 20;
			}
			else
			{
				VIDEO_PAUSE_LABEL_STUDENT.x=FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.width /2 - 60 ;
				VIDEO_PAUSE_LABEL_STUDENT.y=FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.height / 2 - 20;
			}
			if(text == null){
				VIDEO_PAUSE_LABEL_STUDENT.text = "Video Stopped";
			}else{
				VIDEO_PAUSE_LABEL_STUDENT.text = text;
			}
			VIDEO_PAUSE_LABEL_STUDENT.setStyle("color","0xFF0000");
			FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.addElement(VIDEO_PAUSE_LABEL_STUDENT);
		}
	}
	private function pauseViewerAllinOneVideo(text:String = null):void
	{
		if(classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			VIDEO_PAUSE_LABEL_STUDENT.x = (FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.width+14) - 60;
			VIDEO_PAUSE_LABEL_STUDENT.y = FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.height / 2 - 20;
		}
		else
		{
			VIDEO_PAUSE_LABEL_STUDENT.x=FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.width /2+10 ;
			VIDEO_PAUSE_LABEL_STUDENT.y=FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.height / 2;
		}
		if(text == null){
			VIDEO_PAUSE_LABEL_STUDENT.text = "Video is Stopped";
		}else{
			VIDEO_PAUSE_LABEL_STUDENT.text = text;
		}
		VIDEO_PAUSE_LABEL_STUDENT.width = FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.width;
		VIDEO_PAUSE_LABEL_STUDENT.setStyle("color","0xFF0000");
		VIDEO_PAUSE_LABEL_STUDENT.setStyle("textAlign","center");
		FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideo.addElement(VIDEO_PAUSE_LABEL_STUDENT);
	}
	private function pausePresenterAllinOneVideo(text:String = null):void
	{
		VIDEO_PAUSE_LABEL_TEACHER.x=FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.width /2+10 ;
		VIDEO_PAUSE_LABEL_TEACHER.y=FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.height / 2;
		if(text == null){
			VIDEO_PAUSE_LABEL_TEACHER.text = "Video is Stopped";
		}else{
			VIDEO_PAUSE_LABEL_TEACHER.text = text;
		}
		VIDEO_PAUSE_LABEL_TEACHER.width = FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.width;
		VIDEO_PAUSE_LABEL_TEACHER.setStyle("color","0xFF0000");
		VIDEO_PAUSE_LABEL_TEACHER.setStyle("textAlign","center");
		FlexGlobals.topLevelApplication.consolidated.presenterVideoContainer.pnlPresenterVideo.addElement(VIDEO_PAUSE_LABEL_TEACHER);
	}
	private function removePauseViewerLabel():void{
		try{
			if(FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideo.contains(VIDEO_PAUSE_LABEL_STUDENT)){
				FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideo.removeElement(VIDEO_PAUSE_LABEL_STUDENT);
			}
		}catch (er:Error){
		}
	}
	//For AVCM: To clear the stream of selected viewer when tablet user clicks on refresh button.
	private function clearDisplay(userName:String):void
	{
		applicationType::mobile{
			var viewerConnection:VideoConnection = getViewersVideoConnection();
			if(viewerStreamName == userName+Constants.VIEWER_APPEND_NAME){
				videoUnPauseStudentNotification();
				if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
					if(viewerVideo != null){
						viewerVideo.clear();
					}
					//Added to clear the elements from pnlStudentVideo (Group), when stop the selected viewer stream.
					if(FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideoDisplay!=null && FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideo){
						//FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideo.removeAllElements();
						FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideoDisplay.removeChild(viewerVideo);
					}
				}else{
					if (studentVideo){
						studentVideo.clear();
					}
					//Added to clear the elements from pnlStudentVideo (Group), when stop the selected viewer stream.
					if(FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay!=null && FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo){
						//FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.removeAllElements();
						FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay.removeChild(studentVideo);
					}
					try{
						FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo.removeElement(objViewerAudioOnlyMode);
					}
					catch(er:Error){
					}
					if(FlexGlobals.topLevelApplication.videoComp!= null && FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive!=null){
						FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.enabled = false;
					}
				}
				viewerConnection.stopStream(userName+Constants.VIEWER_APPEND_NAME);
			}
		}
	}
	private function startPlayingViewStreams():void
	{
		//For AVCM:To navigates to start the stream of Presenter/Selected viewer video, When moderator get back video connection.
		if(isViewerVideoDisconnected)
		{
			addSelectedViewerVideoToPanel(null,false);
		}
		if(isPresenterVideoDisconnected)
		{
			startPresentersStream();
		}
	}
	public function removeStudentStream(uName:String):void
	{
		try
		{
			var videoIndex:int=-1;
			//For AVCM: To remove the selected viewer details from selectedViewerList if selected viewer stops his video.Since there is no stream.
			var tempStudentConnection:VideoConnection=getViewersVideoConnection();
			for(var i:int=0; i<selectedViewersData.length; i++)
			{
				if(tempStudentConnection.selectedViewerAudioLevelLst.length !=0 && i<tempStudentConnection.selectedViewerAudioLevelLst.length)
				{
					if(tempStudentConnection.selectedViewerAudioLevelLst.source[i].selectedViewerName == uName+Constants.VIEWER_APPEND_NAME)
					{
						tempStudentConnection.selectedViewerAudioLevelLst.removeItemAt(i);
					}
				}
			}
			//For AVCM: To remove the selected viewer stream and add another selected viewer stream to pnlStudentVideo if selected viewer stops his video.
			for(var j:int=0; j<selectedViewersData.length; j++)
			{
				if(getUserSO(selectedViewersData[j].userName).isVideoPublishing)
				{
					startSelectedViewersStream(selectedViewersData[j].userName);
				}
				else
				{
					if(viewerStreamName == selectedViewersData[j].streamName)
					{
						if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
							if (viewerVideo){
								viewerVideo.clear();
							}
							viewerVideo.visible = true;
							removePauseViewerLabel();
							FlexGlobals.topLevelApplication.consolidated.viewerVideoContainer.pnlViewerVideoDisplay.removeChild(viewerVideo);
						}else{
							if (studentVideo){
								studentVideo.visible = false;
								studentVideo.clear();
							}
							videoUnPauseStudentNotification();
							FlexGlobals.topLevelApplication.videoComp.mobileStudentVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoFadeIcon;
							FlexGlobals.topLevelApplication.videoComp.btnStudentVideoReceive.enabled = false;
						}
					}
				}
			}
		}
		catch (err:Error)
		{
		}
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
			if(currentSelectedViewer != "" && getUserSO(currentSelectedViewer)!=null && getUserSO(currentSelectedViewer).userStatus!= null && getUserSO(currentSelectedViewer).userStatus != Constants.ACCEPT){
				for(var k:int = 0; k < FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length; k++){
					if(FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length >=(k+3)){
						FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.removeItemAt(k+2);
						FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.refresh();
						if(FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length >= 3){
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length-1;
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
							break;
						}else{
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex =0;
							FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
						}
					}
				}
			}
		}
	}
	public function removeViewerFromViewPanel(uName:String):void
	{
		var flag:int=0;
		for (var i:int=0; i < studentViewArray.length; i++)
		{
			if (uName == studentViewArray[i].identifier)
			{
				flag=1;
				break;
			}
		}
		if (flag == 1)
		{
			studentViewArray.splice(i, 1);
			setViewersInViewPanel(studentViewArray)							
		}
		if(studentViewArray.length == 0)
		{
		}
	}
	public function setViewersInViewPanel(studentViewArray:Array):void
	{
		//AVCM:
		//setSpaceForViewVideo();
		dpStudents=new ArrayCollection(studentViewArray);
		//AVCM	
		/*if (videoComp)
		{
		videoComp.rpStudents.dataProvider=dpStudents;
		}
		else
		{
		rpStudents.dataProvider=dpStudents;
		}*/
	}
	private function presenterAudioOnlyNotification():void{
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
			pausePresenterAllinOneVideo("Audio Only Mode");
		}else{
			videoPause_notification("Audio Only Mode");
		}
	}
	/**
	 * Function for notifying the user regarding the teacher's video is stopped.
	 *
	 * @param null
	 * @return void
	 * @see null.
	 */
	private function videoPause_notification(text:String = null):void{
		videoUnPauseNotification();
		VIDEO_PAUSE_LABEL_TEACHER.x=FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.width / 2 - 60;
		VIDEO_PAUSE_LABEL_TEACHER.y=FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.height / 2 - 20;
		if(text == null){
			VIDEO_PAUSE_LABEL_TEACHER.text = "Video Stopped";
		}else{
			VIDEO_PAUSE_LABEL_TEACHER.text = text;
		}
		VIDEO_PAUSE_LABEL_TEACHER.setStyle("color","0xFF0000");
		FlexGlobals.topLevelApplication.videoComp.pnlTeacherVideo.addElement(VIDEO_PAUSE_LABEL_TEACHER);
	}
	/**
	 * Function is used for displaying/restricting teacher's video based on user preference.
	 * Also icons are changed based on selection.
	 *
	 * @param null
	 * @return void
	 */
	public function startStopPresenterVideo():void{
		var isStreamManipulated:Boolean=false;
		var netStreamStatus:Boolean=false;
		var tempPresenterConnection:VideoConnection;
		tempPresenterConnection=getPresentersVideoConnection(ClassroomContext.subscriber_bandwidthQualityIndex); 
		if(!tempPresenterConnection){
			return;
		}
		netStreamStatus=tempPresenterConnection.doesStreamExist(presenterStreamName);
		if(getUserSO(ClassroomContext.currentPresenterName).isVideoHide == false && getUserSO(ClassroomContext.currentPresenterName).isAudioMute == false){
			if(netStreamStatus){
				isStreamManipulated=true;
				if (FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoReceiveIcon){
					isPresenterVideoPaused=true;
					videoPause_notification();
					//To remove the last frame of presenter
					if(teacherVideo){
						teacherVideo.visible = false;
						teacherVideo.clear();
					}
					FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon;
					FlexGlobals.topLevelApplication.videoComp.btnVideoReceive.toolTip="Start Viewing Video";
					netStreamStatus=tempPresenterConnection.toggleVideo(presenterStreamName,false);
					
				}else if (FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive == FlexGlobals.topLevelApplication.videoComp.mobileVideoNotReceiveIcon){
					isPresenterVideoPaused=false;
					videoUnPauseNotification();
					//Set video visibilty as true to view the video of presenter
					if(teacherVideo){
						teacherVideo.visible = true;
					}
					FlexGlobals.topLevelApplication.videoComp.mobileVideoReceive = FlexGlobals.topLevelApplication.videoComp.mobileVideoReceiveIcon;
					FlexGlobals.topLevelApplication.videoComp.btnVideoReceive.toolTip="Stop Viewing Video";
					netStreamStatus=tempPresenterConnection.toggleVideo(presenterStreamName,true);
				}
			}
		}
	}
	//To change the width and height of the studentvideo for Individual mode
	public function studentVideoChange(width:Number,height:Number):void{
		
		if(FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible &&  FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible )
		{
			userVideoChange(width,height);
		}
		else
		{
			if(studentVideo != null){
				studentVideo.clear();
				studentVideo.width = width;
				studentVideo.height = height;
				if(width>height){
					studentVideo.width = studentVideo.height*(16/9);
					studentVideo.y = (height-studentVideo.height);
					studentVideo.x = (FlexGlobals.topLevelApplication.width-studentVideo.width)/2;
				}else{
					studentVideo.height = studentVideo.width*(9/16);
					studentVideo.y = (height-studentVideo.height);
				}
			}
		}
	}
	//To change the width and height of the teachervideo for Individual mode
	public function presenterVideoChange(width:Number,height:Number):void{
		if(FlexGlobals.topLevelApplication.videoComp.teacherVideoContainer.visible &&  FlexGlobals.topLevelApplication.videoComp.studentVideoContainer.visible )
		{
			userVideoChange(width,height);
		}
		else
		{
			if(teacherVideo != null){
				teacherVideo.clear();
				teacherVideo.width = width;
				teacherVideo.height = height;
				if(width>height)
				{
					teacherVideo.width = teacherVideo.height*(16/9);
//					teacherVideo.height = teacherVideo.height -(FlexGlobals.topLevelApplication.videoComp.teacherVideoTitle.height + FlexGlobals.topLevelApplication.videoComp.presenterActionGroup.height);
					teacherVideo.y = (height-teacherVideo.height);
					teacherVideo.x = (FlexGlobals.topLevelApplication.width-teacherVideo.width)/2;

				}else{
					teacherVideo.height = teacherVideo.width*(9/16);
					teacherVideo.y = (height-teacherVideo.height);
				}
			}
		}
		
	}
	//To change the width and height of the presentervideo for All-in-one mode
	public function teacherVideoChange(width:Number, height:Number)
	{
		if(presenterVideo != null){
			presenterVideo.clear();
			presenterVideo.width = width;
			presenterVideo.height = height;
			presenterVideo.height = FlexGlobals.topLevelApplication.consolidated.videoContainer.height-FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.height;
			presenterVideo.width = FlexGlobals.topLevelApplication.consolidated.videoContainer.width;
			var y:Number = FlexGlobals.topLevelApplication.consolidated.videoContainer.height;
			presenterVideo.y = (y-presenterVideo.height)/2;
			presenterVideo.smoothing=true;
		}
	}
	//To change the width and height of the viewervideo for All-in-mode
	public function viewerVideoChange(width:Number, height:Number)
	{
		if(viewerVideo != null){
			viewerVideo.clear();
			viewerVideo.width = width;
			viewerVideo.height = height;
			viewerVideo.height = FlexGlobals.topLevelApplication.consolidated.chatContainer.height-FlexGlobals.topLevelApplication.consolidated.dropdownViewer.height;
			viewerVideo.width = FlexGlobals.topLevelApplication.consolidated.chatContainer.width;
			var y:Number = FlexGlobals.topLevelApplication.consolidated.chatContainer.height;
			viewerVideo.y = (y-viewerVideo.height)/2;
			viewerVideo.smoothing=true;
		}
	}
	public function userVideoChange(width:Number,height:Number):void{
		if(studentVideo != null){
			studentVideo.clear();
			if(FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay!=null && FlexGlobals.topLevelApplication.videoComp.pnlStudentVideo){
				FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay.removeChild(studentVideo);
			}
			studentVideo.width = width;
			studentVideo.height = height;
			studentVideo.height = studentVideo.width*(9/16);
			var y:Number = height - (FlexGlobals.topLevelApplication.videoComp.studentVideoTitle.height + FlexGlobals.topLevelApplication.videoComp.studentActionGroup.height);
			studentVideo.y = (y-studentVideo.height)/2;
			studentVideo.x = 0;
			studentVideo.smoothing=true;
			FlexGlobals.topLevelApplication.videoComp.pnlStudentVideoDisplay.addChild(studentVideo);
		}
		if(teacherVideo != null){
			teacherVideo.clear();
			teacherVideo.width = width;
			teacherVideo.height = height;
			teacherVideo.height = teacherVideo.width*(9/16);
			var y:Number = height - (FlexGlobals.topLevelApplication.videoComp.teacherVideoTitle.height + FlexGlobals.topLevelApplication.videoComp.presenterActionGroup.height);
			teacherVideo.x = 0;
			teacherVideo.y = (y-teacherVideo.height)/2;
			teacherVideo.smoothing=true;
		}
	}
}