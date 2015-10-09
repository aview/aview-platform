// ActionScript file
applicationType::DesktopWeb{
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.video.VideoStreamDisplay;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Video;
import flash.utils.Timer;

import mx.controls.VideoDisplay;
import mx.core.FlexGlobals;
import mx.events.ResizeEvent;

public var vidDispObjParent:VideoDisplay;
public var video:Video;
public var titleName:String;

[Bindable]
public var video_Receive_FullScreen:Class;
[Bindable]
public var parentWindow:VideoStreamDisplay=null;
public var creationComplete:Boolean=false;
public var btnTalk:spark.components.Button=new spark.components.Button();
public var btnMute:spark.components.Button=new spark.components.Button();
public var btnRecordIndicator:spark.components.Button=new spark.components.Button();
public var btnFreeTalk:spark.components.Button=new spark.components.Button();

private function init():void{
	initializeButtons();
	this.stage.addEventListener(KeyboardEvent.KEY_DOWN, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.keyDown_track);
	this.addEventListener(ResizeEvent.RESIZE, reSizeVideo);
	//setupVideoDisplay();
}

private function initializeButtons():void{
	btnTalk.addEventListener(MouseEvent.CLICK, parentWindow.enableTalk); //function(e:MouseEvent): void {getTalk(e,this.userName);}
	//btnTalk.addEventListener(MouseEvent.CLICK,getTalk);
	btnTalk.toolTip="You are on Mute now";
	btnTalk.height=30;
	btnTalk.width=30;
	//btnTalk.enabled = true;
	btnTalk.doubleClickEnabled=false;
	btnTalk.useHandCursor=true;
	btnTalk.buttonMode=true;
	btnTalk.mouseChildren=false;
	btnTalk.visible=false;
	btnTalk.includeInLayout=false;
	btnTalk.setStyle('icon', parentWindow.videoWall_pushToTalkMute_Icon);
	btnTalk.setStyle('cornerRadius',50);
	
	btnMute.toolTip="You are on Talk now";
	btnMute.height=30;
	btnMute.width=30;
	//btnMute.enabled = true;
	btnMute.useHandCursor=true;
	btnMute.buttonMode=true;
	btnMute.mouseChildren=false;
	btnMute.visible=false;
	btnMute.includeInLayout=false;
	btnMute.doubleClickEnabled=false;
	btnMute.setStyle('icon', parentWindow.videoWall_pushToTalkUnmute_Icon);
	btnMute.setStyle('cornerRadius',50);
	//btnMutePresenterName = ClassroomContext.currentPresenterName;
	btnMute.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
		parentWindow.getTalk(e, ClassroomContext.currentPresenterName);
	});
	//btnMute.addEventListener(MouseEvent.CLICK,getTalk);
	
	btnRecordIndicator.toolTip="Currently recorded viewer";
	btnRecordIndicator.height=30;
	btnRecordIndicator.width=30;
	btnRecordIndicator.enabled=false;
	btnRecordIndicator.useHandCursor=true;
	btnRecordIndicator.buttonMode=true;
	btnRecordIndicator.mouseChildren=false;
	if (!parentWindow.btnRecordIndicator.visible){
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
	btnFreeTalk.enabled=false;
	btnFreeTalk.mouseChildren=false;
	btnFreeTalk.visible=false;
	btnFreeTalk.includeInLayout=false;
	btnFreeTalk.setStyle('icon', parentWindow.videoWall_disabledMicIcon);
	btnFreeTalk.setStyle('cornerRadius',50);
	
	btnhbox1.addChild(btnRecordIndicator);
	btnhbox1.addChild(btnFreeTalk);
	btnhbox1.addChild(btnMute);
	btnhbox1.addChild(btnTalk);
	
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changePTTButtonStatus(parentWindow, parentWindow.userName);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.checkStreamSignalStrength();
	
}

public function fullScreenButtonStatus(bool:Boolean):void{
	if(ClassroomContext.userVO.role!=Constants.MONITOR_TYPE)
		this.btnhbox.visible=bool;
}

public function removeVideoPauseButton():void{
	btnhbox.visible=false;
	btn_studentVideoreceive.visible=false;
}

private function addVideoOnTimerComplete(event:TimerEvent):void{
	video.width=this.width;
	video.height=this.height - 18;
	video.x=0;
	video.y=0;
	video.smoothing=true;
	vidDisp.addChild(video);
	addVideoTimer.stop();
	addVideoTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, addVideoOnTimerComplete);
}

private function addVideoToParentOnTimerComplete(event:TimerEvent):void{
	vidDispObjParent.addChild(video);
	parentWindow.video=video;
	parentWindow.setVideoSize();
	parentWindow.videoStreamAdded();
	addVideoToParentTimer.stop();
	addVideoToParentTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, addVideoToParentOnTimerComplete);
}

private var addVideoTimer:Timer=new Timer(500, 1);
private var addVideoToParentTimer:Timer=new Timer(500, 1);

private function setupVideoDisplay():void{
	addVideoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, addVideoOnTimerComplete);
	addVideoToParentTimer.addEventListener(TimerEvent.TIMER_COMPLETE, addVideoToParentOnTimerComplete);
	if (vidDisp && video && !vidDisp.contains(video)){
		if (vidDispObjParent.contains(video))
			vidDispObjParent.removeChild(video);
		addVideoTimer.start();
		//title property is not available for canvas
		applicationType::desktop{
			parentWindow.videoFullScreenComp.title=titleName;
		}
	}
}

public function attachVideo(vidDispObj:VideoDisplay, selectedVideo:Video, title:String):void{
	vidDispObjParent=vidDispObj;
	video=selectedVideo;
	this.titleName=title;
	setupVideoDisplay();
}

public function reSizeVideo(event:ResizeEvent):void{
	video.width=this.width;
	video.height=this.height - 18;
}

public function closeHandler():void{
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		return;
	if (parentWindow.isVideoReset){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewerStreamNameChecking != this.titleName || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewerStreamNameChecking == this.titleName && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.notAttachFullscreenVideo)){
			vidDisp.removeChildren();
			video.width=vidDispObjParent.width;
			video.height=vidDispObjParent.height;
			addVideoToParentTimer.start();
		}
		else{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewerStreamNameChecking="";
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.notAttachFullscreenVideo=false;
		}
	}
	//this.close();
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
private function getLabelPosition(value:Number):Number{
	return ((parentWindow.vidDispObj.height-parentWindow.video.height)/2);
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
}