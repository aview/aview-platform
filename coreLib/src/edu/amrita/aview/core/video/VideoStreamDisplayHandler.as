// ActionScript file
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.service.streaming.VideoConnection;
import edu.amrita.aview.core.video.StreamSignalDisplay;
/**Platform specific imports*/
applicationType::desktop{
	import edu.amrita.aview.core.video.VideoStreamDisplayFullScreen;
}

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.List;
import mx.core.DragSource;
import mx.core.FlexGlobals;
import mx.effects.easing.Back;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.logging.Log;
import mx.managers.CursorManager;
import mx.managers.DragManager;

import spark.components.Button;
import flash.media.Video;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.MouseEvent;
import edu.amrita.aview.core.video.VideoTileEvent;
import flash.events.Event;
import mx.logging.ILogger;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import flash.utils.setTimeout;
import mx.controls.Spacer;
import edu.amrita.aview.core.shared.components.ImageButton;
import mx.collections.ArrayCollection;


public const RESIZE_FACTOR_SW:uint=14;
public const RESIZE_FACTOR_MW:uint=15;

public const RESIZE_FACTOR_SW_VIEW:uint=12;
public const RESIZE_FACTOR_MW_VIEW:uint=15;

[Bindable]
public var resizeFactor:Number=RESIZE_FACTOR_SW; //12
[Bindable]
public var path:String="";

public var isStreamDetailsInitialized:Boolean=false;
private var isCreationComplete:Boolean=false;
public var videoConnection:VideoConnection;
public var video:Video=new Video();
private var otherUser:Boolean=false;
public var isFullScreenPresent:Boolean=false;
public var isVideoReset:Boolean=true;
public var userName:String=null;
public var isPTTSet:Boolean=false;
private var videoPauseViewer:Label;
public var isBigScreen:Boolean=false;
public var streamAudioBandwidth:int=0;
public var isFullScreenVideo:Boolean = false;

private static const  VIEWER_EXTENTION:String = "_VIEWER";
private static const  KBPS_EXTENTION:String = "Kbps";

[Bindable]
public var videoCloseButtonStatus:Boolean=false;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/video_refresh.png")]
public var videoRefresh_Icon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/videoshow.png")]
public var videoReceive_Icon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/videohide.png")]
public var videoNotReceive_Icon:Class;

[Bindable]
[Embed(source="assets/images/videoWall_videoFade.png")]
public var videoFade_Icon:Class;

[Bindable]
public var video_Receive:Class;


/* Video wall icons  */
[Bindable]
[Embed(source="assets/images/videoWall_DisabledMic.png")]
public var videoWall_disabledMicIcon:Class;

[Bindable]
[Embed(source="edu/amrita/aview/core/video/assets/images/talk.png")]
public var videoWall_pushToTalkUnmute_Icon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/mute.png")]
public var videoWall_pushToTalkMute_Icon:Class;

[Bindable]
public var videowallFullScreenStatus:Boolean=false;

private var isClosed:Boolean=false;
[Bindable]
public var isViewVideo:Boolean=false;
[Bindable]
private var originalTitle:String=null;
public var imgRecordIndicator:Image=new Image;

private var timerDisplay:Timer;

public var videoHeight:int=0
public var videoWidth:int=0;
public var getUserSOStatus:Function=null;
public var isRecording:Boolean=false;

public var space:Spacer=new Spacer();
public var spa:Spacer=new Spacer();
public var signalDisplay:StreamSignalDisplay=new StreamSignalDisplay();
public var btnVideoRefresh:mx.controls.Button=new mx.controls.Button();
public var btn_studentVideoreceive:mx.controls.Button=new mx.controls.Button();
public var btnFreeTalk:mx.controls.Button=new mx.controls.Button();
public var btnTalk:mx.controls.Button=new mx.controls.Button();
public var btnMute:mx.controls.Button=new mx.controls.Button();


public var btnRecordIndicator:mx.controls.Button=new mx.controls.Button();

public var isVideoNotCopiedToMainTile:Boolean=false;
public var isCopyVideo:Boolean=false;
public var isEmbeddedVideoInVideoWall:Boolean=false;
[Bindable]
public var prgAudioMax:int;

public var widthChangeWatcher:ChangeWatcher=null;
private var resizeStarted:Boolean=false;
private var positionBeforeResizing:Point;
private var increasefactor:int=0;
private var checkStreamDisplay:Boolean=false;
//CRight-click contextmenu for view-video components
private var contextMenuList:List=new List();
private var valuesArray:Array=new Array("CloseVideo", "StartInteraction");
[Bindable]
private var rollOverStatus:Boolean=false;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.video.VideoStreamDisplayHandler.as");

//Bandwidth rating history
public static var STREAM_STRENGTH_CALCULATION_COUNT:int=0;
public static var STREAM_STRENGTH_SUM:Number=0;
public var logInActivityLevel:ArrayCollection= new ArrayCollection;

/**Platform specific variables*/
applicationType::desktop{
	public var videoFullScreenComp:VideoStreamDisplayFullScreen=null;
}
applicationType::web{
	//Set to true if user views Presenter video in pop-out window at first time
	public var isFirstTimePresenterInFullscreen = false;
	//Local shared object to pass the details of the user and the video stream to the module when the Video is made fullscreen
	private var localSharedObject:SharedObject;
	//Set to true when presenter PTT status is Unmute and talk
	private var pttStatus:String;
}

public function initVideoStreamDisplay(streamName:String, title:String, userName:String, videoConnection:VideoConnection, isViewVideo:Boolean):void{
	this.id=streamName;
	this.originalTitle=title;
	this.title=title;
	if (this.title.length > 30){
		this.title=this.title.substr(0, 27) + "...";
	}
	
	this.userName=userName;
	this.otherUser=(userName != ClassroomContext.userVO.userName);
	this.videoConnection=videoConnection;
	this.isViewVideo=isViewVideo;
	
	this.video=new Video(170, 102);
	this.video.smoothing=true;
	
	if (isViewVideo) { //View video
		timerDisplay=new Timer(100, 1);
	timerDisplay.addEventListener(TimerEvent.TIMER_COMPLETE, timerVideoDisplay);
	timerDisplay.start();
	}
	isStreamDetailsInitialized=true;
	isCopyVideo=false;
	startStream();
	if (widthChangeWatcher == null)
		widthChangeWatcher=BindingUtils.bindSetter(setHeight, this, "width");
}

public function setHeight(value:Number):void{
	if (!isBigScreen){
		this.height=Number(value * 0.5625) + 2;
	}
}

public function setValues(bool:Boolean):void{
	this.isFullScreenPresent=bool;
	this.isFullScreenVideo = bool;
}

public function setProperties(title:String, userName:String, isViewVideo:Boolean, videoHeight:int, videoWidth:int):void{
	if (isBigScreen && title != "Presenter"){
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
			return;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName)){
			title=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).userDisplayName;
		}
	}
	this.userName=userName;
	this.isViewVideo=isViewVideo;
	this.originalTitle=title;
	this.title=title;
	this.otherUser=(userName != ClassroomContext.userVO.userName);
	this.videoHeight=videoHeight;
	this.videoWidth=videoWidth;
	isStreamDetailsInitialized=true;
	isCopyVideo=true;
	if (this.title.length > 130){
		this.title=this.title.substr(0, 129) + "...";
	}
}

public function resetLabels():void{
	this.labelVideoToggleNotification.visible=false;
	this.labelFullScreen.visible=false;
	this.labelAudioOnlyNotification.visible=false;
	this.vidDispObj.doubleClickEnabled=false;
	this.isVideoPaused=false;
	
}

public function attachVideo(video:Video, videoConnection:VideoConnection, streamName:String, isVideoPaused:Boolean=false):void{
	isCopyVideo=true;
	this.isVideoPaused=isVideoPaused;
	if (video != null){
		this.video=video;
		this.id=streamName;
		this.videoConnection=videoConnection;
		
	}
	if (this.vidDispObj != null){
		setAudioOnly();
		if (isFullScreenPresent){
			applicationType::desktop{
				videoFullScreenComp.attachVideo(this.vidDispObj, this.video, this.originalTitle + " (A-VIEW Classroom)");
				labelFullScreen.visible=true;
				btn_studentVideoreceive.enabled=false;
				//PNCR: use inline if condition and combine in to a single section.
				if (isVideoPaused){
					videoFullScreenComp.btn_studentVideoreceive.toolTip="Start Viewing Video";
					videoFullScreenComp.video_Receive_FullScreen=videoNotReceive_Icon;
				}
				else{
					videoFullScreenComp.btn_studentVideoreceive.toolTip="Stop Viewing Video";
					videoFullScreenComp.video_Receive_FullScreen=videoReceive_Icon;
				}
			}
			applicationType::web{
				labelFullScreen.visible = true;
				btn_studentVideoreceive.enabled = false;
			}
		}
		else
			vidDispObj.addChild(this.video);
		setVideoSize();
		applicationType::desktop{
			if (!videoBox.hasEventListener(MouseEvent.ROLL_OVER) && FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName) && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).isVideoPublishing && !isFullScreenPresent){
				videoBox.addEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
				videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
			}
		}
		applicationType::web{
			if(!videoBox.hasEventListener(MouseEvent.ROLL_OVER) && FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName)&& FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).isVideoPublishing){
				//Add event listener based on the usertype
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).userRole == Constants.PRESENTER_ROLE && !isFullScreenPresent){
					videoBox.addEventListener(MouseEvent.ROLL_OVER,videoBox_mouseOverHandler);
					videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
				}
				else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).userRole == Constants.VIEWER_ROLE){
					videoBox.addEventListener(MouseEvent.ROLL_OVER,videoBox_mouseOverHandler);
					videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
				}
			}
		}
	}
	if (isVideoPaused){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName) && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).isVideoPublishing)
			labelVideoToggleNotification.visible=true;
		this.isVideoPaused=true;
		video_Receive=videoNotReceive_Icon;
		btn_studentVideoreceive.setStyle('icon', video_Receive);
		this.btn_studentVideoreceive.toolTip="Start Viewing Video";
		this.vidDispObj.doubleClickEnabled=false;
	}
	else{
		this.isVideoPaused=false;
	}
	setAudioSignalValues();
}

public function removeVideo():Video{
	if (this.video != null && this.vidDispObj.contains(this.video)){
		this.vidDispObj.removeChild(this.video);
		if (videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
			videoBox.removeEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
			videoBox.removeEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
			menuBtn.visible=false;
			hboxControlButtonsForSmallWindow.visible=false;
		}
		return this.video;
	}
	return null;
}

//PNCR: remove this function if not necessary
private function timerVideoDisplay(event:TimerEvent):void{
	//this.height = 165;
}

public function closeFullScreen():void{
	applicationType::desktop{
		if (isFullScreenPresent && videoFullScreenComp){
			//close() method is not available for web
			videoFullScreenComp.close();
		}
		videoFullScreenComp=null;
		isFullScreenPresent = false;
	}
	//Fix for issue #18576
	applicationType::web{
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
			//To close video popout.
			ExternalInterface.call("closePopOuts");
		}
	}
}

public var isAudOnly:Boolean=false;

public function setAudioOnly():void{
	var userData:Object=null;
	if (getUserSOStatus != null)
		userData=getUserSOStatus.call(null, userName);
	var audioOnly:Boolean=(userData != null && userData.isVideoPublishing && userData.isAudioOnlyMode);
	//Fix for issue #18563 and #18565
	var audioMuted:Boolean=(userData != null && userData.isVideoPublishing && userData.isAudioMute);
	
	this.labelAudioOnlyNotification.visible=audioOnly;
	
	
	if (audioOnly){
		iconSet(videoFade_Icon);
		this.toolTip="";
		closeFullScreen();
		isFullScreenPresent=false;
		applicationType::desktop{
			videoBox.toolTip="";
			isVideoPaused=false;
			this.btn_studentVideoreceive.enabled=false;
			isAudOnly=true;
			//LabelHideAudioVideo.visible = false;
		}
		applicationType::web{
			var streamPath:String=Constants.PROTOCOL_FMS_SERVER+"://"+ClassroomContext.FMS_USER+"/"+Constants.VIDEO_SERVER_MODULE_NAME+"/"+ClassroomContext.aviewClass.className+"_"+ClassroomContext.aviewClass.classId+"/"+this.id+",true";
			if(this.id == this.userName) //Presenter video
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterFullscreenVideoData(streamPath,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userDisplayName,(userName != ClassroomContext.userVO.userName),Constants.PRESENTER_ROLE,true,this.otherUser);
				videoBox.toolTip = "";
				isVideoPaused = false;
				this.btn_studentVideoreceive.enabled = false;
				isAudOnly = true;
				//Fix for issue #18563 and #18565
				if(audioMuted){
					LabelHideAudioVideo.text="Audio Muted";
					LabelHideAudioVideo.visible=true;
				}
				else{
					LabelHideAudioVideo.text="";
					LabelHideAudioVideo.visible = false;
				}
			}
			else //Selected viewer video
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewerFullscreenVideoData(streamPath,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userDisplayName,(userName != ClassroomContext.userVO.userName),Constants.VIEWER_ROLE,true);
				//Fix for issue #18563 and #18565
				videoBox.toolTip = "";
				isVideoPaused = false;
				this.btn_studentVideoreceive.enabled = false;
				isAudOnly = true;
				if(audioMuted){
					LabelHideAudioVideo.text="Audio Muted";
					LabelHideAudioVideo.visible=true;
				}
				else{
					LabelHideAudioVideo.text="";
					LabelHideAudioVideo.visible = false;
				}
			}
		}
	}
	else{
		iconSet(videoReceive_Icon);
		this.btn_studentVideoreceive.toolTip="Stop Viewing Video";
		this.signalDisplay.toolTip="Signal Strength";
		//videoBox.toolTip = "Double click to view in Fullscreen";
		setFullScreenToolTip();
		if (userData != null && userData.isVideoPublishing){
			this.btn_studentVideoreceive.enabled=!audioOnly;
			if (!isEmbeddedVideoInVideoWall){
				this.vidDispObj.doubleClickEnabled=true;
			}
		}
		isAudOnly=false;
		applicationType::desktop{
			if (videoFullScreenComp){
				videoFullScreenComp.fullScreenButtonStatus(true);
			}
		}
	}
	if(!isAudOnly)
	{
		btnVideoRefresh.toolTip="Refresh incoming video";
	}
	else
	{
		btnVideoRefresh.toolTip="Refresh incoming audio";
	}
}

public function setVideoSize():void{
	if (this.video != null){
		
		if (this.vidDispObj != null && this.vidDispObj.contains(this.video)){
			//PNCR: if (getUserSOStatus == null) return;
			//PNCR: then continue the if code without if. 
			if (getUserSOStatus != null){
				var data:Object=getUserSOStatus.call(null, userName);
				if (data != null){
					videoWidth=data.videoWidth;
					videoHeight=data.videoHeight;
				}
			}
			else
				return;
			
			var factor:int=videoWidth / 4;
			// If videoWidth is 0, it means video is coming from A-VIEW Version 3.5
			if ((videoWidth == 0) || ((factor * 3) >= (videoHeight - 2) && (factor * 3) < (videoHeight + 2))){
				if (isBigScreen){
					if ((this.vidDispObj.width / this.vidDispObj.height) < 1.3333){
						//use max width and calculate height
						this.video.width=this.vidDispObj.width;
						this.video.height=Number(this.vidDispObj.width * 0.75);
					}
					else{
						//use max height and calculate width
						this.video.height=this.vidDispObj.height;
						this.video.width=Number(this.vidDispObj.height * 1.3333);
					}
				}
				else{
					factor=Math.floor((this.vidDispObj.height - 5) / 3);
					this.video.width=factor * 4;
					this.video.height=factor * 3;
				}
			}
			else{
				if ((this.vidDispObj.width / this.vidDispObj.height) < 1.7778){
					//use max width and calculate height
					this.video.width=this.vidDispObj.width;
					this.video.height=Number(this.vidDispObj.width * 0.5625);
				}
				else{
					//use max height and calculate width
					this.video.height=this.vidDispObj.height;
					this.video.width=Number(this.vidDispObj.height * 1.7778);
				}
			}
			this.video.x=(this.vidDispObj.width - this.video.width) / 2;
			this.video.y=(this.vidDispObj.height - this.video.height) / 2;
		}
		//for rearranging the position of the watermark
		resizabletitlewindow1_resizeHandler();
	}
}

//JHCR: Seems like following function is not needed
/* private function updateVideoTile(value:Number):void{
setVideoSize();
} */
public function setCloseButtonVisibility():void{
	var btn:mx.controls.Button=this.mx_internal::closeButton;
	if (ClassroomContext.userVO.userName != ClassroomContext.currentPresenterName && ClassroomContext.userVO.userName != ClassroomContext.moderatorName){
		btn.enabled=false;
	}
	else
		btn.enabled=true;
}

public function startStream():void{
	
	if (Log.isDebug()) 		FlexGlobals.topLevelApplication.mainApp.log.debug("VideoStreamDisplay.startStream:- Entering, userName:" + userName + ", isStreamDetailsInitialized :" + isStreamDetailsInitialized + ", isCreationComplete :" + isCreationComplete + ", isCopyVideo :" + isCopyVideo);
	if (isStreamDetailsInitialized && isCreationComplete && !isCopyVideo && getUserSOStatus.call(null, userName) && getUserSOStatus.call(null, userName).isVideoPublishing){
		clearDisplay();
		if(getUserSOStatus.call(null, userName).isVideoPublishing){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.showViewVideo(getUserSOStatus.call(null, userName).isAudioOnlyMode,getUserSOStatus.call(null, userName).isVideoHide,getUserSOStatus.call(null, userName).isAudioMute,this);
		}
		var receiveAudio:Boolean=(!isViewVideo && otherUser);
		if (videoConnection)
			videoConnection.startStream(video, vidDispObj, this.id, receiveAudio);
		video_Receive=videoReceive_Icon;
		iconSet(videoReceive_Icon);
		if (getUserSOStatus.call(null, userName).isVideoPublishing){
			applicationType::web{
				//(May be needed for desktop version also) Added this check to avoid null object reference issue
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp){
					setAudioOnly();
				}
			}
			applicationType::desktop{
				setAudioOnly();
			}
		}
		else{
			videoBox.toolTip="";
		}
		if (isFullScreenPresent){
			applicationType::desktop{
				videoFullScreenComp.attachVideo(this.vidDispObj, this.video, this.originalTitle + " (A-VIEW Classroom)");
				videoFullScreenComp.video_Receive_FullScreen=video_Receive;
			//Fix for issue #20174 and #20175	
				labelFullScreen.visible=true;
				btn_studentVideoreceive.enabled=false;
			}
		}
		applicationType::web{
			//Fix for issue #17640
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
				//Full screen video stream path
				var streamPath:String=Constants.PROTOCOL_FMS_SERVER+"://"+ClassroomContext.FMS_USER+"/"+Constants.VIDEO_SERVER_MODULE_NAME+"/"+ClassroomContext.aviewClass.className+"_"+ClassroomContext.aviewClass.classId+"/"+this.id+",true";
				//To send stream details to full screen window when Presenter restart his video.
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userRole == Constants.PRESENTER_ROLE){
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterFullscreenVideoData(streamPath,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userDisplayName,(userName != ClassroomContext.userVO.userName),Constants.PRESENTER_ROLE,false,this.otherUser);
						//Stop presenter video to avoid multiple streams
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopPresentersStream();
						clearDisplay();
						labelFullScreen.visible = true;
						//Fix for issue #20174 and #20175
						btn_studentVideoreceive.enabled=false;
					}
				}
				//To send stream details to full screen window when Viewer views Selected viewer video in full screen and Selected restart his/her video 
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerFullScreen.length>0){
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMUISelected){
						for(var i:int=0; i<FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerFullScreen.length; i++){
							if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerFullScreen[i].streamName == this.id){
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewerFullscreenVideoData(streamPath,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userDisplayName,(userName != ClassroomContext.userVO.userName),Constants.VIEWER_ROLE,false);
								clearDisplay();
								labelFullScreen.visible = true;
							}
						}
					}
					else{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userRole != Constants.PRESENTER_ROLE){
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewerFullscreenVideoData(streamPath,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userDisplayName,(userName != ClassroomContext.userVO.userName),Constants.VIEWER_ROLE,false);
							clearDisplay();
							labelFullScreen.visible = true;	
						}
					}
				}
			}
		}
		if (this.isVideoPaused){
			startStopVideo();
		}
		applicationType::desktop{
			if (!isViewVideo && videoBox != null && !videoBox.hasEventListener(MouseEvent.ROLL_OVER) && !isFullScreenPresent){
				videoBox.addEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
				videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
			}
		}
		//Fix for issue #18198
		applicationType::web{
			if (!isViewVideo && videoBox != null && !videoBox.hasEventListener(MouseEvent.ROLL_OVER) && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
				videoBox.addEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
				videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
			}
		}
		
	}
	else if (isCreationComplete && !isCopyVideo){
		video_Receive=videoFade_Icon;
		btn_studentVideoreceive.enabled=false;
	}
	setVideoSize();
	if (isVideoNotCopiedToMainTile){
		this.dispatchEvent(new VideoTileEvent(VideoTileEvent.VIDEOADDED));
		isVideoNotCopiedToMainTile=false;
	}
	setAudioSignalValues();
}

private function setAudioSignalValues():void{
	var objStreamData:Object;
	var streamData:int;
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		return;
	objStreamData=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName);
	if (userName != ClassroomContext.userVO.userName){
		if (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON || ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264){
			streamAudioBandwidth=42;
		}
		else if (objStreamData != null && objStreamData.streamBandwidth != null){
			if (objStreamData.userRole == Constants.PRESENTER_ROLE){
				if (ClassroomContext.subscriber_bandwidthQualityIndex == 0)
					streamData=objStreamData.streamBandwidth.pBandwidth0;
				else if (ClassroomContext.subscriber_bandwidthQualityIndex == 1)
					streamData=objStreamData.streamBandwidth.pBandwidth1;
				if (ClassroomContext.subscriber_bandwidthQualityIndex == 2)
					streamData=objStreamData.streamBandwidth.pBandwidth2;
			}
			else
				streamData=objStreamData.streamBandwidth.vBandwidth;
			
			//PNCR: use case when (single line)
			if (streamData == 28){
				streamAudioBandwidth=12;
			}
			else if (streamData == 56){
				streamAudioBandwidth=18;
			}
			else if (streamData == 128){
				streamAudioBandwidth=20;
			}
			else if (streamData == 256){
				streamAudioBandwidth=32;
			}
			else if (streamData == 512){
				streamAudioBandwidth=64;
			}
			else if (streamData == 768){
				streamAudioBandwidth=64;
			}
			else if (streamData == 1024){
				streamAudioBandwidth=64;
			}
			
		}
	}
	else
		streamAudioBandwidth=0;
	
	prgAudioMax=(streamAudioBandwidth * 1024) / 8;
}

public function enableTalk(event:MouseEvent):void{
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.talk(this.userName);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.talkMute(this.userName);
}

public function getTalk(evt:MouseEvent, talkUserName:String):void{
	if (this.userName == ClassroomContext.currentPresenterName){
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.talkMute(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getFirstAcceptedViewerAdmin());
	/*	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.talk(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getFirstAcceptedViewerAdmin());
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.talk(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getFirstAcceptedViewerAdmin());*/
	}
	else
	{
		//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.talk(talkUserName);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.talkMute(talkUserName);
	}
}

private function init():void{
	/*var btn:mx.controls.Button = new mx.controls.Button();
	btn.right=0;
	btn.top=-20;
	this.addChild(btn);*/
	hboxControlButtons.visible=false;
	hboxControlButtonsForSmallWindow.visible=false;
	btnControls.visible=false;
	if (!isCopyVideo || video_Receive == null)
		video_Receive=videoReceive_Icon;
	disableCanvas.visible=!ClassroomContext.IS_AUDIO_VIDEO_ENABLED;
	disableCanvas.includeInLayout=!ClassroomContext.IS_AUDIO_VIDEO_ENABLED;
	videoBox.visible=ClassroomContext.IS_AUDIO_VIDEO_ENABLED;
	videoBox.includeInLayout=ClassroomContext.IS_AUDIO_VIDEO_ENABLED;
	showHideToolbar();
	uiUpdate();
	
	
	isCreationComplete=true;
	
	setCloseButtonVisibility();
	
	this.signalDisplay.noSignal.visible=false;
	
	if (isViewVideo){
		
		videoBox.percentHeight=100;
		hboxControlButtons.visible=false;
		btnControls.visible=false;
		hboxControlButtonsForSmallWindow.visible=false;
		btnControls.removeAllChildren();
		hboxControlButtons.removeAllChildren();
		hboxControlButtonsForSmallWindow.removeAllChildren();
		hboxControlButtons.includeInLayout=false;
		
	}
	
	if (isPTTSet)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changePTTButtonStatus(this, userName);
	//videoBox.addEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
	//videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
	this.resizeFactorTitleWindow=resizeFactor;
	startStream();
}

/**
 * This is a dummy event listener for handling onMetaData of NetStream object
 * //PNCR: remove function if it is not using
 * @param event of type Object
 * @return void
 */
private function metaDataHandler(infoObject:Object):void{

}

public function videoStreamAdded():void
{
	var ev:VideoTileEvent = new VideoTileEvent(VideoTileEvent.VIDEOADDED);
	this.dispatchEvent(ev);
}

public function createFullScreenWindow(event:MouseEvent=null):void{
	if(event!=null && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout == Constants.PRESENTER_LAYOUT && !isBigScreen)
		return;
	this.isVideoReset=true;
	videoBox.toolTip="";
	
	applicationType::desktop{
		videoFullScreenComp=new VideoStreamDisplayFullScreen();
		videoFullScreenComp.video_Receive_FullScreen=video_Receive;
		videoFullScreenComp.parentWindow=this;
		videoFullScreenComp.open(true);
		videoFullScreenComp.attachVideo(this.vidDispObj, this.video, this.originalTitle + " (A-VIEW)");
		videoFullScreenComp.maximize();
		videoFullScreenComp.LabelHideAudioVideo.text = this.LabelHideAudioVideo.text;
		videoFullScreenComp.LabelHideAudioVideo.visible = true;
	
		videoFullScreenComp.addEventListener(Event.CLOSE, fullscreenClose);
		labelFullScreen.visible=true;
		btn_studentVideoreceive.enabled=false;
		if (isViewVideo){
				videoFullScreenComp.removeVideoPauseButton();
			}
		isFullScreenVideo = true;
		//Fix for issue #20323
		vidDispObj.doubleClickEnabled=false;
		isFullScreenPresent=true;
		
		if (videoBox != null && videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
			videoBox.removeEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
			videoBox.removeEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
		}
		hboxControlButtons.visible=false;
		menuBtn.visible=false;
	}
	applicationType::web{
		//Fix for issue #20036
		if (this.id == this.userName) //For Presenter video	
		{
			createPresenterVideoPopout();
			//Fix for issue #20323
			vidDispObj.doubleClickEnabled=false;
			isFullScreenPresent=true;
			if (videoBox != null && videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
				videoBox.removeEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
				videoBox.removeEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
			}
			hboxControlButtons.visible=false;
			menuBtn.visible=false;
		}
		else if(ClassroomContext.aviewClass.isMultiBitrate == "Y" && this.title == "Presenter")
		{
			createPresenterVideoPopout();
			//Fix for issue #20323
			vidDispObj.doubleClickEnabled=false;
			isFullScreenPresent=true;
			if (videoBox != null && videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
				videoBox.removeEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
				videoBox.removeEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
			}
			hboxControlButtons.visible=false;
			menuBtn.visible=false;
		}
		else{
			
		}
	}
	applicationType::desktop{
		//videoFullScreenComp.LabelHideAudioVideo.text = this.LabelHideAudioVideo.text;
		//videoFullScreenComp.LabelHideAudioVideo.visible = true;
	}
	}
//Fix for issue #20036
applicationType::web{
	private function createPresenterVideoPopout():void{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterPttStatus = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getAudioMuteSOValue();
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterPttStatus == Constants.FREETALK)
		{
			pttStatus = Constants.FREETALK;
		}
		else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterPttStatus == Constants.UN_MUTE)
		{
			pttStatus = Constants.UN_MUTE;
		}
		else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterPttStatus == ClassroomContext.currentPresenterName)
		{
			pttStatus = Constants.UN_MUTE;
		}
		else
		{
			pttStatus = Constants.MUTE;	
		}
		localSharedObject=SharedObject.getLocal("userData","/"); 
		localSharedObject.clear();
		//FMS path
		var streamPath:String;
		if(ClassroomContext.aviewClass.classType == "Meeting")
		{
			streamPath=Constants.PROTOCOL_FMS_SERVER+"://"+ClassroomContext.FMS_USER+"/"+Constants.VIDEO_SERVER_MODULE_NAME+"/"+ClassroomContext.lecture.lectureId+"_"+ClassroomContext.aviewClass.classId+"/"+this.id+",true";
		}
		else
		{
			streamPath=Constants.PROTOCOL_FMS_SERVER+"://"+ClassroomContext.FMS_USER+"/"+Constants.VIDEO_SERVER_MODULE_NAME+"/"+ClassroomContext.aviewClass.className+"_"+ClassroomContext.aviewClass.classId+"/"+this.id+",true";
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.uniqueID = Math.random()*1000;
		localSharedObject.data.uniqueID = this.id;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterVideoLocalConnection = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterVideoLocalConnection + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.uniqueID as LocalConnection;
		//Call javascript function to open pop out window.
		ExternalInterface.call("openPopOutWindow",Constants.PRESENTER_ROLE,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.uniqueID);
		localSharedObject.data.videoType = "Presenter";
		localSharedObject.flush();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setTimeOutID = setTimeout(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.presenterPopOutWindowVideoData,100,streamPath,this.id,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(this.userName).userDisplayName,pttStatus,Constants.PRESENTER_ROLE,false,this.otherUser);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen = true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoStopped = false;
		//Stop presenter video to avoid multiple streams
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopPresentersStream();
		clearDisplay();
		if(videoBox!=null && videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
			videoBox.removeEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
			videoBox.removeEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
		}
		labelFullScreen.visible = true; 
		isFirstTimePresenterInFullscreen=true;
		//Fix for issue #18117
		hboxControlButtons.visible=false;
		menuBtn.visible=false;
		return;
	}
}

public function setFullScreenToolTip():void{
	var userData:Object=null;
	if (getUserSOStatus != null)
		userData=getUserSOStatus.call(null, userName);
	hBoxWaterMark.doubleClickEnabled=false;
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp)
		return;
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		return;
	if ((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoWall && isBigScreen) || (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoWall && userData != null && userData.isVideoPublishing && !userData.isAudioOnlyMode)){
		if (!isVideoPaused){
			//Fix for issue #11782: Disabled doubleClickEnabled property
			applicationType::web{
				hBoxWaterMark.doubleClickEnabled=false;
			}
			applicationType::desktop{
				hBoxWaterMark.doubleClickEnabled=true;
			}
		}
		//Removed toolTip; For web version, temporarily disabled the feature to make individual videos fullscreen.
		applicationType::desktop{
			this.videoBox.toolTip="Double click to view in Fullscreen";
		}
	}
	else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoWall && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName  && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout==Constants.PRESENTER_LAYOUT){
		this.videoBox.toolTip="Click to view in BigScreen";
	}
	else{
		this.videoBox.toolTip="";
	}
}

public function setBigScreen():void{
	isBigScreen=true;
	setFullScreenToolTip();
}

public function resetDisplay():void{
	clearDisplay();
	this.id="";
	this.originalTitle="No Selected Viewer";
	this.title="No Selected Viewer";
	this.userName="";
	this.otherUser=false;
	this.videoConnection=null;
	this.isViewVideo=false;
	this.video=null;
	this.resizable=false;
	isStreamDetailsInitialized=false;
	this.isVideoPaused=false;
	this.isEmbeddedVideoInVideoWall=false;
	this.btn_studentVideoreceive.setStyle('icon', videoReceive_Icon);
	applicationType::desktop{
		//title property is not available for web
		if (videoFullScreenComp){
			videoFullScreenComp.title=this.title;
			videoFullScreenComp.video_Receive_FullScreen=video_Receive;
		}
	}
}

public function clearDisplay():void{
	if(this.id == null)
		return;
	hBoxWaterMark.doubleClickEnabled=false;
	this.btn_studentVideoreceive.toolTip="";
	this.signalDisplay.toolTip="";
	videoBox.toolTip="";
	this.video_Receive=this.videoFade_Icon;
	this.btn_studentVideoreceive.enabled=false;
	this.labelVideoToggleNotification.visible=false;
	this.labelFullScreen.visible=false;
	this.labelAudioOnlyNotification.visible=false;
	this.vidDispObj.removeChildren();
	this.video.clear();
	this.video.attachNetStream(null);
	this.LabelHideAudioVideo.text = "";
	this.LabelHideAudioVideo.visible = false;
	isCopyVideo=false;
	applicationType::desktop{
		if (videoFullScreenComp){
			videoFullScreenComp.vidDisp.removeChildren();
			videoFullScreenComp.signalDisplay.removeSignalStrength();
			videoFullScreenComp.signalDisplay.noSignal.visible=true;
			videoFullScreenComp.fullScreenButtonStatus(false);
		}
	}
	if (this.videoConnection != null){
		this.videoConnection.stopStream(this.id);
	}
	if (videoBox != null && videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
		videoBox.removeEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
		videoBox.removeEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
	}
	this.vidDispObj.doubleClickEnabled=false;
	streamAudioBandwidth=0;
}

public function fullscreenClose(event:Event):void{
	if(Log.isInfo()) log.info("fullscreenclose:");
	applicationType::desktop{
		if (videoFullScreenComp)
			videoFullScreenComp.removeEventListener(Event.CLOSE, fullscreenClose);
	}
	btn_studentVideoreceive.enabled=true;
	labelFullScreen.visible=false;
	isFullScreenPresent=false;
	applicationType::desktop{
		videoFullScreenComp=null;
	}
	if (!isVideoPaused && !isEmbeddedVideoInVideoWall){
		applicationType::desktop{
			vidDispObj.doubleClickEnabled=true;
		}
		setFullScreenToolTip();
	}
	if (!isViewVideo && videoBox != null && !videoBox.hasEventListener(MouseEvent.ROLL_OVER) && this.video_Receive != this.videoFade_Icon){
		videoBox.addEventListener(MouseEvent.ROLL_OVER, videoBox_mouseOverHandler);
		videoBox.addEventListener(MouseEvent.ROLL_OUT, vidDispObj_mouseOutHandler);
	}
	setTimeout(changeBoolFullscreenValue, 3000);
}

private function changeBoolFullscreenValue():void
{
	isFullScreenVideo = false;
}

public function fullscreenVideoControl(event:MouseEvent):void{
	startStopVideo();
}

/**
 * Close event handler.
 *
 *
 * @return void
 * @see null.
 */
private function titleWindow_close(evt:*):void{
	if (!isClosed){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setUserStatus(userName, Constants.HOLD);
		AuditContext.userAction.userInteractionEndedEventLog(userName, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).userInteractedCount);
		//If the rejectedUser is in talk mode,then set currentPresenter to talk.
		if (userName == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getAudioMuteSOValue()){
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.talk(ClassroomContext.currentPresenterName);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.talkMute(ClassroomContext.currentPresenterName);
		}
	}
}

private function mouseDownHandler(event:MouseEvent):void{
	//PNCR: remove else section
	if (event.target is mx.controls.Button || event.target is Image){
		return;
	}
	else{
		//this.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
	}
}

//PNCR: remove section if not using
private function mouseMoveHandler(event:MouseEvent):void{
	/* if(event.target is mx.controls.Button || event.target is Image){
	return;
	}
	else{
	var dragInitiator:ResizableTitleWindow=ResizableTitleWindow(event.currentTarget);
	var ds:DragSource = new DragSource();
	ds.addData(dragInitiator, "selectedViewerComp");
	DragManager.doDrag(dragInitiator, ds, event);
	}
	this.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler); */
}

public function iconSet(iconClass:Class):void{
	video_Receive=iconClass;
	this.btn_studentVideoreceive.setStyle('icon', video_Receive);
}
public var isVideoPaused:Boolean=false;

public function startStopVideo(evt:*=null):void{
	if (videoConnection != null && videoConnection.doesStreamExist(this.id)){
		if (video_Receive == videoReceive_Icon){
			this.isVideoPaused=true;
			if(getUserSOStatus.call(null, userName).isVideoPublishing){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.showViewVideo(getUserSOStatus.call(null, userName).isAudioOnlyMode,getUserSOStatus.call(null, userName).isVideoHide,getUserSOStatus.call(null, userName).isAudioMute,this);
			}
			video_Receive=videoNotReceive_Icon;
			btn_studentVideoreceive.setStyle('icon', videoNotReceive_Icon);
			this.btn_studentVideoreceive.toolTip="Start Viewing Video";
			this.vidDispObj.doubleClickEnabled=false;
			this.hBoxWaterMark.doubleClickEnabled=false;
			
			applicationType::desktop{
				if (videoFullScreenComp != null){
					videoFullScreenComp.btn_studentVideoreceive.toolTip="Start Viewing Video";
					videoFullScreenComp.video_Receive_FullScreen=video_Receive;
					videoFullScreenComp.LabelHideAudioVideo.text = this.LabelHideAudioVideo.text;
					videoFullScreenComp.LabelHideAudioVideo.visible = true;
				}
			}
			//Fix for issue #20174 and #20175
			applicationType::web{
				this.btn_studentVideoreceive.enabled=true;
				//Fix for issue #20186,3#20187 and #20188
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoStopped=true;
			}
			videoBox.toolTip="";
			videoConnection.toggleVideo(this.id, false);
			viewerVideoToggleEventLog("Video Stopped", "", "");
		}
		else if (video_Receive == videoNotReceive_Icon){
			this.isVideoPaused=false;
			if(getUserSOStatus.call(null, userName).isVideoPublishing){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.showViewVideo(getUserSOStatus.call(null, userName).isAudioOnlyMode,getUserSOStatus.call(null, userName).isVideoHide,getUserSOStatus.call(null, userName).isAudioMute,this);
			}
			video_Receive=videoReceive_Icon
			btn_studentVideoreceive.setStyle('icon', videoReceive_Icon);
			this.btn_studentVideoreceive.toolTip="Stop Viewing Video";
			if (!isEmbeddedVideoInVideoWall){
				this.vidDispObj.doubleClickEnabled=true;
			}
			//Fix for issue #11782: Disabled doubleClickEnabled property
			applicationType::web{
				this.hBoxWaterMark.doubleClickEnabled=false;
				//Fix for issue #20186,3#20187 and #20188
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoStopped=false;
			}
			applicationType::desktop{
				this.hBoxWaterMark.doubleClickEnabled=true;
				if (videoFullScreenComp != null){
					videoFullScreenComp.btn_studentVideoreceive.toolTip="Stop Viewing Video";
					videoFullScreenComp.video_Receive_FullScreen=video_Receive;
					videoFullScreenComp.LabelHideAudioVideo.text = this.LabelHideAudioVideo.text;
					videoFullScreenComp.LabelHideAudioVideo.visible = false;
				}
			}
			videoConnection.toggleVideo(this.id, true);
			setFullScreenToolTip();
			viewerVideoToggleEventLog("Video Resumed", "", "");
		}
	}
}
public function videoRefresh(event:MouseEvent):void{
	clearDisplay();
	startStream();
	applicationType::desktop{
		if(videoFullScreenComp){
			refreshVideoFullScreenButtonStatus(false);
			setTimeout(videoFullScreenRefreshUpdate, 2000);
		}	
		else{
			refreshVideoButtonStatus(false);
			setTimeout(videoRefreshUpdate, 2000);
			
		}
	}
	applicationType::web{
		refreshVideoButtonStatus(false);
		setTimeout(videoRefreshUpdate, 2000);
	}
}
/**
 *
 * @private
 * Audits the "ViewerVideoToggle" action, when the user starts/stops an incoming video
 *
 * @param toggleMode - Stop Video/Start Video
 * @param publishingBW - The published bandwidth of incoming video
 * @param viewerUserName - The user name of the incoming video
 * @return void
 *
 */
private function viewerVideoToggleEventLog(toggleMode:String, publishingBW:String, viewerUserName:String):void
{
	AuditContext.userAction.createAction(AuditConstants.viewerVideoToggle, toggleMode, publishingBW, viewerUserName);
}

public function resetAudioActivity():void{
	AudioActivity=0;
	prgBarAudioSignal.setProgress(AudioActivity, prgBarAudioSignal.maximum);
}
private var AudioActivity:int=0;

public function updateStreamAudioActivity():void{
	if (videoConnection && videoConnection.ncVideo.netConnection!=null && !videoConnection.ncVideo.isConnected())
		return;
	//PNCR: inline if
	if (videoConnection != null){
		AudioActivity=videoConnection.getAudiActivity(this.id);
	}
	else{
		AudioActivity=0;
	}
	applicationType::desktop{
		if (isFullScreenPresent && videoFullScreenComp){
			prgBarAudioSignal.setProgress(0, prgBarAudioSignal.maximum);
				videoFullScreenComp.prgBarAudioSignal.setProgress(AudioActivity, prgBarAudioSignal.maximum);
		}
		else
			prgBarAudioSignal.setProgress(AudioActivity, prgBarAudioSignal.maximum);
	}
	applicationType::web{
		if(isFullScreenPresent){
			prgBarAudioSignal.setProgress(0,prgBarAudioSignal.maximum);
		}
		else
			prgBarAudioSignal.setProgress(AudioActivity,prgBarAudioSignal.maximum);
	}
		
}

private function checkViewVideo():void{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewVideoStatus(userName) && ClassroomContext.userVO.role!= Constants.MONITOR_TYPE){
		createRightClickMenu();
	}
}

private function createRightClickMenu():void{
	hideMenu();
	if (videoBox.mouseY < 0){
		contextMenuList.y=0;
	}
	else if (videoBox.mouseY > 70){
		contextMenuList.y=70;
	}
	else{
		contextMenuList.y=videoBox.mouseY;
	}
	
	//PNCR: inline if
	if (videoBox.mouseX > 75){
		contextMenuList.x=75;
	}
	else{
		contextMenuList.x=videoBox.mouseX;
	}
	
	contextMenuList.width=100;
	contextMenuList.height=54;
	contextMenuList.dataProvider=valuesArray;
	contextMenuList.visible=true;
	videoBox.addChild(contextMenuList);
	contextMenuList.addEventListener(MouseEvent.CLICK, callMenuFunctions);
}

private function callMenuFunctions(e:MouseEvent):void{
	var i:int=0;
	for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.dataProvider.length; i++){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.dataProvider[i].id == userName)
			break;
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.selectedIndex=i;
	
	if (contextMenuList.selectedItem.toString() == "CloseVideo"){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.closeViewStudent();
	}
	if (contextMenuList.selectedItem.toString() == "StartInteraction"){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.acceptViewer();
	}
	videoBox.removeChild(contextMenuList);
}

private function hideMenu():void{
	try{
		videoBox.removeChild(contextMenuList);
		resizabletitlewindow1_resizeHandler();
	}
	catch (err:Error){
		if(Log.isError()) log.error("Error in hideMenu method :"+ err.getStackTrace());
	}
}

public function videoBox_mouseOverHandler(event:MouseEvent):void{
	checkStreamDisplay=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.checkStreamSignalStrength();
	if (this.width > 130){
		//hboxControlButtons.visible=true;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName) != null && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(userName).isVideoPublishing)
			this.hboxControlButtons.visible=true;
		else
			this.hboxControlButtons.visible=false;
	}
	else{
		menuBtn.visible=true;
		/* btnControls.visible = true;
		hboxControlButtonsForSmallWindow.visible = true; */
	}
	showhideCloseButton(true);
}

public function showhideCloseButton(status:Boolean):void{
	if (status == true){
		if ((ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName || ClassroomContext.isModerator) && isViewVideo == false && this.name != "pnlTeacher" && !isBigScreen)
			this.btnClose.visible=true;
			//videoCloseButtonStatus =  true;
		else
			this.btnClose.visible=false;
		//videoCloseButtonStatus= false;
	}
	else
		this.btnClose.visible=false;
	//videoCloseButtonStatus =  false;
}


public function vidDispObj_mouseOutHandler(event:MouseEvent):void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.checkStreamDisplay=false;
	if (this.width > 130)
		hboxControlButtons.visible=false;
	else{
		menuBtn.visible=false;
		/* btnControls.visible = false;
		hboxControlButtonsForSmallWindow.visible = false; */
	}
	showhideCloseButton(false);
}

public function prgBar_creationCompleteHandler(event:FlexEvent):void{
	// TODO Auto-generated method stub
	prgBarAudioSignal.setStyle("barColor", "#039911");
}

protected function vidDispObj_creationCompleteHandler(event:FlexEvent):void{
	if (this.video != null && vidDispObj.contains(this.video)){
		this.vidDispObj.addChild(this.video);
	}
	vidDispObj.doubleClickEnabled = true;
	//CRJH: Seems like following LOC is not needed
	//setVideoSize();
}

//PNCR: can change the below 4 functions to a single function with two boolean parameter.
protected function menuBtn_rollOverHandler(event:MouseEvent):void{
	btnControls.visible=true;
	hboxControlButtonsForSmallWindow.visible=true;
}

protected function menuBtn_rollOutHandler(event:MouseEvent):void{
	
	btnControls.visible=false;
	hboxControlButtonsForSmallWindow.visible=false;
	
}

protected function btnControls_mouseOverHandler(event:MouseEvent):void{
	btnControls.visible=true;
	hboxControlButtonsForSmallWindow.visible=true;
}

protected function btnControls_mouseOutHandler(event:MouseEvent):void{
	btnControls.visible=false;
	hboxControlButtonsForSmallWindow.visible=false;
}

private function showHideToolbar():void{
	//Refresh button 
	btnVideoRefresh.addEventListener(MouseEvent.CLICK, videoRefresh); //function(e:MouseEvent): void {getTalk(e,this.userName);}
	btnVideoRefresh.height=30;
	btnVideoRefresh.width=30;
	btnVideoRefresh.doubleClickEnabled=false;
	btnVideoRefresh.useHandCursor=true;
	btnVideoRefresh.buttonMode=true;
	btnVideoRefresh.mouseChildren=false;
	btnVideoRefresh.setStyle('icon', videoRefresh_Icon);
	btnVideoRefresh.setStyle('cornerRadius',50);
	btnVideoRefresh.toolTip="Refresh incoming video";
	btn_studentVideoreceive.addEventListener(MouseEvent.CLICK, startStopVideo);
	btn_studentVideoreceive.height=30;
	btn_studentVideoreceive.width=30;
	btn_studentVideoreceive.toolTip="";
	if (!isAudOnly)
		btn_studentVideoreceive.enabled=true;
	btn_studentVideoreceive.doubleClickEnabled=false;
	btn_studentVideoreceive.setStyle('icon', video_Receive);
	btn_studentVideoreceive.setStyle('cornerRadius',50);
	//talkUserName = this.userName;
	btnTalk.addEventListener(MouseEvent.CLICK, enableTalk); //function(e:MouseEvent): void {getTalk(e,this.userName);}
	//btnTalk.addEventListener(MouseEvent.CLICK,getTalk);
	btnTalk.toolTip="You are on Mute now";
	btnTalk.height=30;
	btnTalk.width=30;
	//btnTalk.enabled = true;
	btnTalk.doubleClickEnabled=false;
	btnTalk.useHandCursor=true;
	btnTalk.buttonMode=true;
	btnTalk.mouseChildren=false;
	//btnTalk.visible=false;
	//btnTalk.includeInLayout=false;
	btnTalk.setStyle('icon', videoWall_pushToTalkMute_Icon);
	btnTalk.setStyle('cornerRadius',50);
	
	//PNCR: seems same functinality repeating 3 times for different object. Please check if we can write this in to a function.
	btnMute.toolTip="You are on Talk now";
	btnMute.height=30;
	btnMute.width=30;
	btnMute.enabled = true;
	btnMute.useHandCursor=true;
	btnMute.buttonMode=true;
	btnMute.mouseChildren=false;
	//btnMute.setStyle('skin',CustomButton);
	//				btnMute.visible=false;
	//btnMute.includeInLayout=false;
	btnMute.doubleClickEnabled=false;
	btnMute.setStyle('icon', videoWall_pushToTalkUnmute_Icon);
	btnMute.setStyle('cornerRadius',50);
	//btnMutePresenterName = ClassroomContext.currentPresenterName;
	btnMute.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
		getTalk(e, ClassroomContext.currentPresenterName);
	});
	//btnMute.addEventListener(MouseEvent.CLICK,getTalk);
	
	btnRecordIndicator.toolTip="Currently recorded viewer";
	//btnRecordIndicator.height=23;
	//btnRecordIndicator.width=30;
	btnRecordIndicator.enabled=false;
	btnRecordIndicator.useHandCursor=true;
	btnRecordIndicator.buttonMode=true;
	btnRecordIndicator.mouseChildren=false;
	if (!isRecording){
		btnRecordIndicator.visible=false;
		btnRecordIndicator.includeInLayout=false;
	}
	btnRecordIndicator.doubleClickEnabled=false;
	btnRecordIndicator.setStyle('icon', FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.RecordIndicatorIcon);
	//btnRecordIndicator.addEventListener(MouseEvent.CLICK,function(e:MouseEvent): void {getTalk(e,ClassroomContext.currentPresenterName);});
	btnRecordIndicator.setStyle('cornerRadius',50);
	btnFreeTalk.toolTip=Constants.FREETALK;
	btnFreeTalk.height=30;
	btnFreeTalk.width=30;
	//btnFreeTalk.enabled = false;
	btnFreeTalk.mouseChildren=false;
	//btnFreeTalk.visible=true;
	//btnFreeTalk.includeInLayout=true;
	btnFreeTalk.setStyle('icon', videoWall_disabledMicIcon);
	btnFreeTalk.setStyle('cornerRadius',50);
	if (!isCopyVideo){
		btnFreeTalk.visible=true;
		btnFreeTalk.enabled=false;
		btnMute.visible=false;
		btnMute.enabled=true;
		btnTalk.enabled=true;
		btnTalk.visible=false;
		btnMute.includeInLayout=false;
		btnFreeTalk.includeInLayout=true;
		btnTalk.includeInLayout=false;
		
	}
	space.percentWidth=100;
	spa.width=3;
}

private function uiUpdate():void{
	hboxControlButtons.includeInLayout=ClassroomContext.IS_AUDIO_VIDEO_ENABLED;
	hboxControlButtons.addChildAt(spa,0);
	hboxControlButtons.addChild(btnVideoRefresh);
	hboxControlButtons.addChild(btn_studentVideoreceive);
	hboxControlButtons.addChild(imgRecordIndicator);
	hboxControlButtons.addChild(btnFreeTalk);
	hboxControlButtons.addChild(btnMute);
	hboxControlButtons.addChild(btnTalk);
	hboxControlButtons.addChild(space);
	hboxControlButtons.addChild(signalDisplay);
	btnControls.removeAllChildren();
	hboxControlButtonsForSmallWindow.removeAllChildren();
	
}

private function set updateToolBar(value:Number):void{
	uiUpdate();
}

//PNCR: please check if we can move the below function to common module.
/**
 * for seting the progressbar(audiosignal) height in video component
 * based on the width
 * need to pass the video component width as parameter
 *
 * */
public function getProgressbarHeight(value:Number):Number{
	if (value >= 600)
		return 10;
	if (value <= 600 && value >= 350)
		return 8;
	else
		return 6;
}

/**
 * for seting the fontsize of the aview watermark in video component
 * based on the width
 * need to pass the video component width as parameter
 * */
private function getFontSize(value:Number):Number{
	if(value>=900)
		return 24;
	if(value<=900 && value>=700)
		return 20;
	if(value<=700 && value>=500)
		return 15;
	if(value<=500 && value>=350)
		return 15;
	else
		return 15;
}

private function getFontSizeForLabel(value:Number):Number{
	if(value>=900)
		return 25;
	if(value<=900 && value>=700)
		return 20;
	if(value<=700 && value>=500)
		return 15;
	if(value<=500 && value>=350)
		return 15;
	else
		return 10;
}
/**
 * for positioning the aview watermark copyright in video component
 * based on the width
 * need to pass the video component width as parameter
 * */

private function getFontSizeforCopyright(value:Number):Number{
	if (value >= 600)
		return 30;
	if (value <= 600 && value >= 350)
		return 15;
	else
		return 10;
}



/**
 * for positioning the aview watermark in video component
 * based on the width
 * need to pass the video component width as parameter
 * */
private function set updateWatermark(value:int):void
{
	if(value >=500)
		hBoxWaterMark.top =((this.vidDispObj.height-this.video.height)/2)+100;
	else
		hBoxWaterMark.top =((this.vidDispObj.height-this.video.height)/2)+30;

}

/**
 * for positioning the aview watermark copyright in video component
 * based on the width
 * need to pass the video component width as parameter
 * */
private function getwidthforCopyright(value:Number):Number{
	if (value >= 600)
		return 30;
	if (value <= 600 && value >= 350)
		return 17;
	else
		return 12;
}

public function calculateSignalStrengthValues():void
{
	if(!videoConnection){
		return;
	}
	var signalPercentage:int=0;
	var userData:Object=null;
	if (getUserSOStatus != null)
		userData=getUserSOStatus.call(null, userName);
	var streamName:String = this.id;
	var publishingBandwidth:int;
	if (userData!=null && userData.isVideoPublishing)
	{
		var streamDetails:Object=userData.streamBandwidth;
		if(streamDetails == null)
			return;
		if(streamName.substring(streamName.length - 7, streamName.length) == VIEWER_EXTENTION)
		{
			publishingBandwidth = streamDetails.vBandwidth;
		}
		else if(streamName.substring(streamName.length - 4, streamName.length) == KBPS_EXTENTION)
		{
			var bandWidthValue:int = int(streamName.substring(streamName.length - 6, streamName.length - 4));
			if(bandWidthValue == streamDetails.pBandwidth1)
				publishingBandwidth = streamDetails.pBandwidth1;
			else if(bandWidthValue == streamDetails.pBandwidth2)
				publishingBandwidth = streamDetails.pBandwidth2;
		}
		else
		{
			publishingBandwidth = streamDetails.pBandwidth0;
		}
		
		signalPercentage = ((videoConnection.streamStrength(this.id) * 8)/1024) / publishingBandwidth * 100;
		if (checkStreamDisplay == true && signalDisplay.noSignal != null)
		{
			signalDisplay.noSignal.visible=false;
			signalDisplay.showSignalStrength(signalPercentage);
			addSignalSrength(signalPercentage);
		}
		applicationType::desktop{
			if (isFullScreenPresent && videoFullScreenComp){
				videoFullScreenComp.signalDisplay.noSignal.visible=false;
				videoFullScreenComp.signalDisplay.showSignalStrength(signalPercentage);
			}
			addSignalSrength(signalPercentage);
		}
	}
	else
	{
		if (checkStreamDisplay == true && signalDisplay.noSignal != null)
		{
			signalDisplay.removeSignalStrength();
			signalDisplay.noSignal.visible=true;
		}
		applicationType::desktop{
			if (isFullScreenPresent && videoFullScreenComp){
				videoFullScreenComp.signalDisplay.removeSignalStrength();
				videoFullScreenComp.signalDisplay.noSignal.visible=true;
			}
		}
	}
	updateStreamAudioActivity();
}

private function addSignalSrength(strenght:Number):void
{
	STREAM_STRENGTH_CALCULATION_COUNT++;
	STREAM_STRENGTH_SUM+=strenght;
}

public function resizabletitlewindow1_resizeHandler():void
{
	if(isBigScreen)
	{
		hBoxWaterMark.top = (this.vidDispObj.height-this.video.height)/2;
	}	
	else
		if(hBoxWaterMark!=null)
			hBoxWaterMark.top =(this.vidDispObj.width-this.video.width)/2;
	
}
public function refreshVideoButtonStatus(bool:Boolean):void{
	applicationType::DesktopWeb{
		btnVideoRefresh.enabled=bool;
	}
}

public function videoRefreshUpdate():void{
	applicationType::DesktopWeb{
		refreshVideoButtonStatus(true);
	}
}
public function refreshVideoFullScreenButtonStatus(bool:Boolean):void{
	applicationType::desktop{
		videoFullScreenComp.btnVideoRefresh.enabled=bool;
	}
}
public function videoFullScreenRefreshUpdate():void{
	applicationType::DesktopWeb{
		refreshVideoFullScreenButtonStatus(true);
	}
}

public function calculateLogInActivity():ArrayCollection{
	if(this.videoConnection !=null){
	logInActivityLevel = this.videoConnection.getLogInActivity(this.id);
	}
	return logInActivityLevel;
}
