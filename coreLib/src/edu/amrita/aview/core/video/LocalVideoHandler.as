// ActionScript file
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.service.streaming.VideoConnection;
import edu.amrita.aview.core.video.StreamSignalDisplay;
import edu.amrita.aview.core.video.VideoStreamDisplay;
/**Platform specific imports*/
applicationType::desktop
{
	import edu.amrita.aview.core.video.LocalVideoFullscreen;
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.media.Video;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.events.MoveEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.net.NetStream;
import flash.events.AsyncErrorEvent;
import com.adobe.protocols.dict.events.ConnectedEvent;
import mx.core.mx_internal;

/**
 * Variable for holding the local video stream
 */
public var video:Video;
//	Retain the new VD position
private var xPercentage:Number=0;
private var yPercentage:Number=0;
//public var ismute = false;
//public var ishide = false;
public var ismutehide = false;
public var isFullScreen:Boolean=false;


/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.LocalVideo");

public var camTemp:Camera;
private var camTimer:Timer=new Timer(900, 0);
private var camAvailabile:Boolean=false;
private	var nsDown:NetStream;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoPublish.jpg")]
public var videoON:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoStop.jpg")]
public var videoOFF:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoMic.jpg")]
public var audioON:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoMicMute.jpg")]
public var audioOFF:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoAudioPublish.jpg")]
public var videoAudioON:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoAudioStop.jpg")]
public var videoAudioOFF:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/multibitRate.png")]
public var multiBitrateON:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/multibitRateMute.png")]
public var multiBitrateOFF:Class;

[Bindable]
public var audioStatus:Class = audioON;
[Bindable]
public var videoStatus:Class = videoON;
[Bindable]
public var audioVideoStatus:Class = videoON;

[Bindable]
public var audioStatusTooltip:String='Mute Audio';
[Bindable]
public var videoStatusTooltip:String='Stop Video';
[Bindable]
public var audioVideoStatusTooltip:String='Stop Video and Audio';


/**Platform specific variables*/
applicationType::web{
	//Set appWidth as Screen width.
	[Bindable]
	public var appWidth:Number=Capabilities.screenResolutionX;
	[Bindable]
	public var appHeight:Number=FlexGlobals.topLevelApplication.height;
	//Flag to check whether the local video is resized or not 
	public var isResized:Boolean=false;
	// Stores the current y coordinate of the local video
	[Bindable]
	public var currTop:int;
	// Stores the current x coordinate of the local video
	[Bindable]
	public var currLeft:int;
}

applicationType::desktop{
	public var localVideoFullScreenComp:LocalVideoFullscreen;
}

protected function showHideVideo(event:MouseEvent):void
{
	if(this.height==52)
	{
		showVideo.play();
		hideVideo.stop();
		rotateShowIcon.play();
		rotateHideIcon.stop();
		//this.height=184;
		
	}
	else
	{
		hideVideo.play();
		showVideo.stop();
		rotateHideIcon.play();
		rotateShowIcon.stop();
		//this.height=50;
	}
	
}


private function PopOutMyVideo():void
{
	
}

/**
 * Function for displaying local video of the user in A-VIEW.
 *
 *
 * @return void
 * @see null.
 */
private function displayLocalVideo():void{
	
	//if (Log.isDebug()) log.debug("displayLocalVideo ");
	//	SRS retain the new VD position
	this.addEventListener(MouseEvent.MOUSE_UP, videoDisplayCoords);
	//camTimer.addEventListener(TimerEvent.TIMER, checkCameraAvailabilityTimer); //bug##15193,#15330
	//	SRS
	
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnLocalVideo.enabled=false;
	
	if (Log.isDebug()) log.debug("displayLocalVideo ClassroomContext.isAudioOnlyMode" + ClassroomContext.isAudioOnlyMode.toString());
	if (!ClassroomContext.isAudioOnlyMode){
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
		{
			playLocalVideoStream();
		}
		else
		{
			var camArray:Array=new Array();
			camArray=Camera.names;
			var i:int;
			var camera_name:String;
			if (VideoConnection.isInternalCodec(ClassroomContext.aviewClass.videoCodec) && ((ClassroomContext.aviewClass.isMultiBitrate == "N") || (ClassroomContext.aviewClass.isMultiBitrate == "Y" && ClassroomContext.userVO.role != Constants.TEACHER_TYPE))){
				camera_name=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive.toString();
			}
			else{
				camera_name=FlexGlobals.topLevelApplication.mainApp.SCREEN_CAMERA_DRIVER_NAME;
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.attachedCameraToScreenCamera == false && VideoConnection.isInternalCodec(ClassroomContext.aviewClass.videoCodec) && ClassroomContext.userVO.role == Constants.TEACHER_TYPE){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraToScreenCamera(1, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive.toString());
				}
			}
			
			//camera_name=FlexGlobals.topLevelApplication.mainApp.videoDeviceDrive.toString();
			for (i=0; i < camArray.length; i++){
				
				if (camArray[i] == camera_name){
					break;
				}
			}
			video=new Video();
			video.width=localVideoDisplay.width;
			video.height=localVideoDisplay.height;
			
			camTemp=Camera.getCamera(i.toString());
			//Fix for issue  #9006: Added StatusEvent to get flash player privacy setting
			applicationType::web{
				camTemp.addEventListener(StatusEvent.STATUS, onStatus);
				//Added tool tip for video component
				this.toolTip="Double click to fullscreen";
			}
			if(ClassroomContext.currentPresenterName!=ClassroomContext.userVO.userName)
			{
				if(Constants.CAM_TYPE_EASYCAP == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType)
				{
					camTemp.setMode(720,576,15);
				}
				/*else if(Constants.CAM_TYPE_FMLE == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType)
				{
					camTemp.setMode(1920,1080,15);
				}*/
			}
			video.attachCamera(camTemp);
			video.smoothing=true;
			localVideoDisplay.addChild(video);
			
			if (camera_name != FlexGlobals.topLevelApplication.mainApp.SCREEN_CAMERA_DRIVER_NAME){
				camAvailabile=false;
				//Fix for issue  #9006
				applicationType::web{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAllow){
						camTimer.start();
					}
				}
				applicationType::desktop{
					camTimer.start();
				}
			}
			
			try{
				//Activate snapshot feature
				//if (ClassroomContext.SYSTEM_PARAMETERS["EnablePhotoCapture"] == "Yes" && ClassroomContext.userVO.photoCaptureFrequencySecs > 0 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj != null && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj.snapshotTimer.running)
				if (ClassroomContext.aviewClass.canMonitor == "Yes" && ClassroomContext.aviewClass.monitorIntervalFreq > 0 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj != null && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj.snapshotTimer.running)
				{
					
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj.setCameraDriver(i.toString());
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj.takeSnapshot();
					if (Log.isDebug()) log.debug("displayLocalVideo::EnablePhotoCapture");
				}
			}
			catch (e:Error){
				if(Log.isError()) log.error("Error in displayLocalVideo method :"+ e.getStackTrace());
			}
		}
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute ){
				LabelAudioVideoHide.text =" Audio/Video is Stopped";
				canVideoHide.visible=true;
				audioStatus = audioOFF;
				audioStatusTooltip = 'Unmute Audio';
			}
			else{
				LabelAudioVideoHide.text ="Video Stopped";
				canVideoHide.visible=true;
			}
			videoStatus = videoOFF;
			videoStatusTooltip = 'Start Video';
		}
		else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
				LabelAudioVideoHide.text =" Audio/Video is Stopped";
				canVideoHide.visible=true;
				audioStatus = audioOFF;
				audioStatusTooltip = 'Unmute Audio';
			}
			else{
				LabelAudioHide.text="Audio Muted";
				LabelAudioHide.visible=true;
				canVideoHide.visible=false;
			}
			audioStatus = audioOFF;
			audioStatusTooltip = 'Unmute Audio';
		}
		else{
			LabelAudioVideoHide.text ="";
			canVideoHide.visible=false;
		}
		LabelAudioVideoHide.visible = true;
		
	}
	else{
		this.toolTip="Audio Only Mode";
		objLabelAudioNotification.visible=true;
		btnVideoStatus.visible=false;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
			LabelAudioHide.text="Audio Muted";
			LabelAudioHide.visible=true;
			canVideoHide.visible=false;
			audioStatus = audioOFF;
			audioStatusTooltip = 'Unmute Audio';
		}
		else{
			LabelAudioHide.text= "";
			LabelAudioHide.visible=false;
			canVideoHide.visible=false;
		}
	}
	this.isPopUp=true;
	//To store current x and y position of local video.
	applicationType::web{
		currTop=this.y;
		currLeft=this.x;
	}
	if (!ClassroomContext.isAudioOnlyMode && camTemp && video && localVideoDisplay)
		if (Log.isDebug()) log.debug("displayLocalVideo::"+"camTemp.name:"+camTemp.name+",camTemp.width:"+camTemp.width+",camTemp.height:"+camTemp.height+",camTemp.fps:"+camTemp.fps+",camTemp.keyFrameInterval:"+camTemp.keyFrameInterval+",camTemp.bandwidth:"+camTemp.bandwidth+",video.width:"+video.width+",video.height:"+video.height+",localVideoDisplay.width:"+localVideoDisplay.width+",localVideoDisplay.height:"+localVideoDisplay.height);
}

public function playLocalVideoStream():void
{
	//Fix for issue #19930
	applicationType::desktop{
		var videoConnection:VideoConnection=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresentersVideoConnection(0);
		if(video)
		{
			if(!isFullScreen)
				localVideoDisplay.removeChild(video);
			else
				localVideoFullScreenComp.localVideoDisplay.removeChild(video);
			video=null;
		}
		if(nsDown)
		{
			nsDown.close();
			nsDown=null;
		}
		video=new Video();
		nsDown=new NetStream(videoConnection.ncVideo.netConnection);
		nsDown.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorEventHandler);
		//nsDown.bufferTime=0.1;
		nsDown.receiveAudio(false);
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.VIEWER_ROLE && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT)
		{
			nsDown.play(ClassroomContext.userVO.userName+Constants.VIEWER_APPEND_NAME+"_local");
		}
		else
		{
			nsDown.play(ClassroomContext.userVO.userName+"_local");
		}
		video.attachNetStream(nsDown);
		video.height=localVideoDisplay.height;
		video.width=localVideoDisplay.width;
		video.smoothing=true;
		if(!isFullScreen)
		{
			localVideoDisplay.addChild(video);
		}
		else
		{
			localVideoFullScreenComp.localVideoDisplay.addChild(video);
			video.width=localVideoFullScreenComp.width;
			video.height=localVideoFullScreenComp.height;
		}
	}
}	
private function asyncErrorEventHandler(event:Event):void
{
}

/**
 * Function for setting position of local video display popup according to A-VIEW's window changes.
 *
 *
 * @return void
 * @see null.
 */
public function setWidowPosition():void{
	var xValue:Number=this.x;
	var yValue:Number=this.y;
	if (xPercentage == 0 && yPercentage == 0){
		applicationType::desktop{
			if (this.parent.width >= 1024)
				this.x=(this.parent.width - 12) - this.width;
			this.y=(this.parent.y + 150);
		}
		//Fix for local video position issue in full screen mode.
		applicationType::web{
			this.x=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.width - this.width - 12;
			this.y=45;
		}
	}
	else{
		if (this.parent.width >= 1024){
			var xVal:Number=((this.parent.width * xPercentage) / 100);
			var yVal:Number=((this.parent.height * yPercentage) / 100);
			if (xVal > ((this.parent.width - 12) - this.width)){
				this.x=(this.parent.width - 12) - this.width;
			}
			else{
				this.x=xVal;
			}
			this.y=yVal;
		}
	}
	
	if (this.x < 0){
		this.x=xValue;
	}
	if (this.y < 150){
		this.y=yValue;
	}
}

private function videoDisplayCoords(e:Event):void{
	xPercentage=((e.currentTarget.x * 100) / this.parent.width);
	yPercentage=((e.currentTarget.y * 100) / this.parent.height);
	if (xPercentage < 0){
		xPercentage=0;
	}
	if (yPercentage < 0){
		yPercentage=0;
	}
	if (xPercentage > 96 || yPercentage > 96){
		xPercentage=0;
		yPercentage=0;
	}
}

/**
 * Function for closing the local video in the popup when the user press 'Stop' button.
 *
 *
 * @return void
 * @see null.
 */
public function closePopup():void{
	if (video && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop"){
		video.attachCamera(null);
	}
	applicationType::desktop{
		PopUpManager.removePopUp(this);
	}
	//Fix for local video position issue in full screen mode.
	applicationType::web{
		//Fix for issue #19671
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.isFullScreen == false){
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.contains(this)){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.removeElement(this);
			
			}//Fix for issue #18461
			else{
				if(isFullScreen){
					if(FlexGlobals.topLevelApplication.contains(this)){
						FlexGlobals.topLevelApplication.removeElement(this);
					}
				}
			}
		}
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoON=false;
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE && nsDown)
	{
		nsDown.close();
	}
}

/**
 * Close event handler for local video popup.
 *
 *
 * @return void
 * @see null.
 */
private function titleWindow_close(obj:*):void{
	applicationType::desktop{
		PopUpManager.removePopUp(obj as IFlexDisplayObject);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnLocalVideo.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoON=false;
	}
	//Fix for local video position issue in full screen mode.
	applicationType::web{
		//Fix for issues #18461 and #18763
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.isFullScreen == false){
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.contains(this)){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.removeElement(this);
				//Fix for issue #19198
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnLocalVideo.enabled=true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoON=false;
			}
			else{
				if(isFullScreen){
					//Fix for issue #19671
					if(FlexGlobals.topLevelApplication.contains(this)){
						FlexGlobals.topLevelApplication.removeElement(this);
					}
					isFullScreen = false;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoFullscreen=false;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.createAndAddMyVideo();
				}
			}
		}
		else{
			if(isFullScreen){
				//Fix for issue #19671
				if(FlexGlobals.topLevelApplication.contains(this)){
					FlexGlobals.topLevelApplication.removeElement(this);
				}
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.contains(this)){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.removeElement(this);
				}
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoON=false;
				isFullScreen = false;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoFullscreen=false;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.createAndAddMyVideo();
			}
			else{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.contains(this)){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.removeElement(this);
					//Fix for issue #19198
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnLocalVideo.enabled=true;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoON=false;
					isFullScreen = false;
					//Fix for issue #19671
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalVideoFullscreen=false;
				}
			}
		}
	}
	
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE&& nsDown)
	{
		nsDown.close();
	}
}
private var counter:int=1;

private function checkCameraAvailabilityTimer(event:TimerEvent):void{
	//if (camTemp.currentFPS != 0)
	if (camTemp.activityLevel != -1 || camTemp.currentFPS != 0)
	{
		camAvailabile=true;
	}
	if (counter == 10){
		if (Log.isDebug()) log.debug("checkCameraAvailabilityTimer()::camTemp.activityLevel="+camTemp.activityLevel+",camTemp.width="+camTemp.width+",camTemp.height="+camTemp.height+",camTemp.fps="+camTemp.fps+",camTemp.keyFrameInterval="+camTemp.keyFrameInterval+",camTemp.name="+camTemp.name);
		if (!camAvailabile){
			var parent:Sprite=null;
			var tempAlert:Alert;
			tempAlert=Alert.show("Camera is used by another application.\nPlease retry after sometime.\n", "A-VIEW", Alert.OK, parent, callStopVideo);
			tempAlert.width=260;
			tempAlert.height=110;
		}
		counter=1;
		camTimer.stop();
	}
	else{
		counter++;
	}
}

//Fix for issue  #9006: StatusEvent handler for flash player privacy setting
applicationType::web{
	private function onStatus(event:StatusEvent):void{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAllow=true;
		camTimer.start();
	}
}

private function callStopVideo(e:Event):void{
	if (video && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop"){
		video.attachCamera(null);
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopVideo();
}

public function localVideoFullScreen():void{
	if (!ClassroomContext.isAudioOnlyMode){
		applicationType::desktop{
			isFullScreen = true;
			localVideoFullScreenComp=new LocalVideoFullscreen();
			localVideoFullScreenComp.open(true);
			localVideoFullScreenComp.localVideoDisplay.addChild(video);
			localVideoFullScreenComp.minWidth=320;
			localVideoFullScreenComp.minHeight=240;
			video.width=320;
			video.height=240 - 15;
			this.visible=false;
			localVideoFullScreenComp.maximize();
		}
		applicationType::web{
			//Fix for issue #19671
			closePopup();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideoFullscreen();
			
		}
		applicationType::desktop{
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute ){
					localVideoFullScreenComp.LabelAudioVideoHide.text =" Audio/Video is Stopped";
					localVideoFullScreenComp.canVideoHide.visible=true;
				}
				else{
					localVideoFullScreenComp.LabelAudioVideoHide.text ="Video Stopped";
					localVideoFullScreenComp.canVideoHide.visible=true;
				}
				localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
				localVideoFullScreenComp.videoStatus = videoOFF;
				localVideoFullScreenComp.videoStatusTooltip = 'Start Video';
			}
			else
			{
				if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
						localVideoFullScreenComp.LabelAudioHide.text="Audio Muted";
						localVideoFullScreenComp.LabelAudioHide.visible=true;
						localVideoFullScreenComp.canVideoHide.visible=false;
						localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
					}
					else{ 
						localVideoFullScreenComp.LabelAudioVideoHide.visible = false;
						localVideoFullScreenComp.LabelAudioHide.visible=false;
						localVideoFullScreenComp.canVideoHide.visible=false;
					}
				}
				localVideoFullScreenComp.videoStatusTooltip = 'Stop Video';
				localVideoFullScreenComp.videoStatus = videoON;	
			}
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide ){
					localVideoFullScreenComp.LabelAudioVideoHide.text ="Audio/Video is Stopped";
					localVideoFullScreenComp.canVideoHide.visible=true;
				}
				else{ 
					localVideoFullScreenComp.LabelAudioHide.text="Audio Muted";
					localVideoFullScreenComp.LabelAudioHide.visible=true;
					localVideoFullScreenComp.canVideoHide.visible=false;
				}
				localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
				localVideoFullScreenComp.audioStatus = audioOFF;
				localVideoFullScreenComp.audioStatusTooltip = 'Unmute Audio';
			}
			else 
			{
				if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
						localVideoFullScreenComp.LabelAudioVideoHide.text ="Video Stopped";
						localVideoFullScreenComp.canVideoHide.visible=true;
						localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
					}
					else{
						localVideoFullScreenComp.LabelAudioVideoHide.visible = false;
						localVideoFullScreenComp.LabelAudioHide.visible=false;
						localVideoFullScreenComp.canVideoHide.visible=false;
					}
					localVideoFullScreenComp.audioStatus = audioON;
					localVideoFullScreenComp.audioStatusTooltip = "Mute Audio";
				}
			}
		}
	}
	else{
		Alert.show("Audio Only mode doesn't have fullscreen option.", "INFO");
	}
}

private function closeFullScreen():void{
	//close() method not available for web
	applicationType::desktop{
		if (localVideoFullScreenComp){
			localVideoFullScreenComp.close();
		}
	}
}

public function callLocalProgressBar(microPhoneActivityLevel:int, cameraActivityLevel:int):void{
	var signalPercentage:int = 0;
	localPrgBarAudioSignal.setProgress(microPhoneActivityLevel, 100);
	if(!ClassroomContext.isAudioOnlyMode)
	displayStreamStrength.noSignal.visible=false;
	displayStreamStrength.showSignalStrength(cameraActivityLevel);
	
}

public function hideTheVideo():void{
	if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=true;

	    if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute ){
			LabelAudioVideoHide.text =" Audio/Video is Stopped";
			canVideoHide.visible=true;
		}
		else{
			LabelAudioVideoHide.text ="Video Stopped";
			canVideoHide.visible=true;
		}
		if(isFullScreen){
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=true;
			else
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=false;
			hideFullScreenVideo();
		}
		LabelAudioVideoHide.visible = true;
		videoStatus = videoOFF;
		videoStatusTooltip = 'Start Video';
	}
	else{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=false;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
			//LabelAudioVideoHide.text ="Audio Muted";
			LabelAudioHide.text="Audio Muted";
			LabelAudioHide.visible=true;
			canVideoHide.visible=false;
			LabelAudioVideoHide.visible = true;
		}
		else{ 
			LabelAudioVideoHide.visible = false;
			LabelAudioHide.visible=false;
			canVideoHide.visible=false;
		}
		if(isFullScreen){
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=true;
			else
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=false;
			hideFullScreenVideo();
		}
		videoStatusTooltip = 'Stop Video';
		videoStatus = videoON;
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.hideVideoCall(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide);
	
}

public function muteTheAudio():void{
	if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide ){
			LabelAudioVideoHide.text ="Audio/Video is Stopped";
			canVideoHide.visible=true;
		}
		else{ 
			//LabelAudioVideoHide.text ="Audio Muted";
			LabelAudioHide.text="Audio Muted";
			LabelAudioHide.visible=true;
			canVideoHide.visible=false;
		}
		if(isFullScreen){
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute=true;
			else
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute=false;
			muteFullScreenAudio();
		}
		LabelAudioVideoHide.visible = true;
		audioStatus = audioOFF;
		audioStatusTooltip = 'Unmute Audio';
		
		}
	else 
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
			LabelAudioVideoHide.text ="Video Stopped";
			canVideoHide.visible=true;
			LabelAudioVideoHide.visible = true;
		}
		else{
			LabelAudioVideoHide.visible = false;
			LabelAudioHide.visible=false;
			canVideoHide.visible=false;
		}
		if(isFullScreen){
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute=true;
			else
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute=false;
			muteFullScreenAudio();
		}
		audioStatus = audioON;
		audioStatusTooltip = "Mute Audio";
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.muteAudioCall(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute);
}

public function stopLocalAudioVideo():void{
	if(!ismutehide){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = true;
		ismutehide=true;
		audioVideoStatus = videoOFF;
		audioVideoStatusTooltip = "Start Video and Audio";
		LabelAudioVideoHide.text ="Audio/Video is Stopped";
		LabelAudioVideoHide.visible = true;
		canVideoHide.visible=true;
		
		if(isFullScreen){
			if(!ismutehide){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = true;
			}
			else{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
				    FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = false;
			}
			stopFullScreenLocalAudioVideo();
		}
	}
	else {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = false;
		ismutehide=false;
		audioVideoStatus = videoON;
		audioVideoStatusTooltip = "Stop Video and Audio";
		LabelAudioVideoHide.visible = false;
		LabelAudioHide.visible=false;
		canVideoHide.visible=false;
		if(isFullScreen){
			if(!ismutehide){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = true;
			}
			else{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = false;
			}
			stopFullScreenLocalAudioVideo();
		}
	}
		
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callSetLocalAudioVideo(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide);
}

public function setLocalAudioVideoSettings():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callSetLocalAudioVideoSettings();
}

public function hideFullScreenVideo():void{
	applicationType::desktop{
		if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=true;
			
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute ){
				localVideoFullScreenComp.LabelAudioVideoHide.text =" Audio/Video is Stopped";
				localVideoFullScreenComp.canVideoHide.visible=true;
			}
			else{
				localVideoFullScreenComp.LabelAudioVideoHide.text ="Video Stopped";
				localVideoFullScreenComp.canVideoHide.visible=true;
			}
			
			localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
			localVideoFullScreenComp.videoStatus = videoOFF;
			localVideoFullScreenComp.videoStatusTooltip = 'Start Video';
		}
		else{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=false;
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
					//LabelAudioVideoHide.text ="Audio Muted";
					localVideoFullScreenComp.LabelAudioHide.text="Audio Muted";
					localVideoFullScreenComp.LabelAudioHide.visible=true;
					localVideoFullScreenComp.canVideoHide.visible=false;
					localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
				}
				else{ 
					localVideoFullScreenComp.LabelAudioVideoHide.visible = false;
					localVideoFullScreenComp.LabelAudioHide.visible=false;
					localVideoFullScreenComp.canVideoHide.visible=false;
				}
			localVideoFullScreenComp.videoStatusTooltip = 'Stop Video';
			localVideoFullScreenComp.videoStatus = videoON;
		}
	}
	//Fix for issue #17743
	applicationType::web{
		if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=true;
			
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute ){
				LabelAudioVideoHide.text =" Audio/Video is Stopped";
				canVideoHide.visible=true;
			}
			else{
				LabelAudioVideoHide.text ="Video Stopped";
				canVideoHide.visible=true;
			}			
			LabelAudioVideoHide.visible = true;
			videoStatus = videoOFF;
			videoStatusTooltip = 'Start Video';
		}
		else{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide=false;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
				LabelAudioHide.text="Audio Muted";
				LabelAudioHide.visible=true;
				canVideoHide.visible=false;
				LabelAudioVideoHide.visible = true;
			}
			else{ 
				LabelAudioVideoHide.visible = false;
				LabelAudioHide.visible=false;
				canVideoHide.visible=false;
			}			
			videoStatusTooltip = 'Stop Video';
			videoStatus = videoON;
		}
	}
}
 
public function muteFullScreenAudio():void{
	applicationType::desktop{
		if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide ){
				localVideoFullScreenComp.LabelAudioVideoHide.text ="Audio/Video is Stopped";
				localVideoFullScreenComp.canVideoHide.visible=true;
			}
			else{ 
				//LabelAudioVideoHide.text ="Audio Muted";
				localVideoFullScreenComp.LabelAudioHide.text="Audio Muted";
				localVideoFullScreenComp.LabelAudioHide.visible=true;
				localVideoFullScreenComp.canVideoHide.visible=false;
			}
			localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
			localVideoFullScreenComp.audioStatus = audioOFF;
			localVideoFullScreenComp.audioStatusTooltip = 'Unmute Audio';
		}
		else 
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
				localVideoFullScreenComp.LabelAudioVideoHide.text ="Video Stopped";
				localVideoFullScreenComp.canVideoHide.visible=true;
				localVideoFullScreenComp.LabelAudioVideoHide.visible = true;
			}
			else{
				localVideoFullScreenComp.LabelAudioVideoHide.visible = false;
				localVideoFullScreenComp.LabelAudioHide.visible=false;
				localVideoFullScreenComp.canVideoHide.visible=false;
			}
			localVideoFullScreenComp.audioStatus = audioON;
			localVideoFullScreenComp.audioStatusTooltip = "Mute Audio";
		}
	}
	//Fix for issue #17742
	applicationType::web{
		if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide ){
				LabelAudioVideoHide.text ="Audio/Video is Stopped";
				canVideoHide.visible=true;
			}
			else{ 
				LabelAudioHide.text="Audio Muted";
				LabelAudioHide.visible=true;
				canVideoHide.visible=false;
			}
			LabelAudioVideoHide.visible = true;
			audioStatus = audioOFF;
			audioStatusTooltip = 'Unmute Audio';
		}
		else 
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide){
				LabelAudioVideoHide.text ="Video Stopped";
				canVideoHide.visible=true;
				LabelAudioVideoHide.visible = true;
			}
			else{
				LabelAudioVideoHide.visible = false;
				LabelAudioHide.visible=false;
				canVideoHide.visible=false;
			}
			audioStatus = audioON;
			audioStatusTooltip = "Mute Audio";
		}
	}
}
public function stopFullScreenLocalAudioVideo():void{
	if(!ismutehide){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = true;
		applicationType::desktop{
			localVideoFullScreenComp.audioVideoStatus = videoAudioOFF;
			localVideoFullScreenComp.audioVideoStatusTooltip = "Start Video and Audio";
			localVideoFullScreenComp.LabelAudioVideoHide.text ="Audio/Video is Stopped";
			localVideoFullScreenComp.canVideoHide.visible=true;
		}
	}
	else {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMute = false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isHide = false;
		audioVideoStatus = videoAudioON;
		audioVideoStatusTooltip = "Stop Video and Audio";
		applicationType::desktop{
			localVideoFullScreenComp.LabelAudioVideoHide.text ="Audio/Video is Stopped";
			localVideoFullScreenComp.canVideoHide.visible=true;
		}
	}
	
}

