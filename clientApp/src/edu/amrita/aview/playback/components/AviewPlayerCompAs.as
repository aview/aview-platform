////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
//RTCR: Avoid 'this' from description and use component name instead of 'this'.
/**
 *
 * File			: AviewPlayerCompAs.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 *  Reviewer(s)	: Remya T
 *
 * This file is old play back full screen component for Playback.This file not used in new MUI play back
 *
 */
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
import edu.amrita.aview.common.components.fileloader.events.FileLoadedEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.playback.ConsolidateXmlBuilder;
import edu.amrita.aview.playback.ContextSetter;
import edu.amrita.aview.playback.DesktopPlayback;
import edu.amrita.aview.playback.DocumentPointerPlayer;
import edu.amrita.aview.playback.PttPlayer;
import edu.amrita.aview.playback.VodCustomClient;
import edu.amrita.aview.playback.WbPlayer;
import edu.amrita.aview.playback.WhiteBoardPointerPlayer;
import edu.amrita.aview.playback.components.*;
import edu.amrita.aview.playback.editing.scripts.CloseFileHandler;
import edu.amrita.aview.playback.events.AviewPlayerEvent;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.SoundTransform;
import flash.ui.Keyboard;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.sliderClasses.Slider;
import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.events.SliderEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

import spark.components.Label;

/**Platform specific imports*/
applicationType::desktop{
	import edu.amrita.aview.playback.components.FullScreenComp;
	import edu.amrita.aview.playback.DesktopPlaybackWindow;
}
//RTCR: Give description for all variables
/**
 * For Log API
 */
private var log:ILogger

public var chatWndw:ChatCom;
public var wbPlayer:WbPlayer;
public var presenterVid:VideoComp;
public var viewerVid:VideoComp;
private var wbPointerPlayer:WhiteBoardPointerPlayer;
private var pttPlayer:PttPlayer;
private var docPointerPlayer:DocumentPointerPlayer;
public var chatBool:Boolean=true;
public var PresenterBool:Boolean=true;
public var ViewerBool:Boolean=true;
public var fullScreenPresenterBool:Boolean=false;
public var fullScreenViewerBool:Boolean=false;
public var fullScreenChatBool:Boolean=false;
//RTCR: Whether the commented code is needed or not?
//public var seek:seekbar;
public var presenterFMSUrl:String;
public var desktopFMSUrl:String;
private var presenterMediaConnection:MediaServerConnection;
private var viewerMediaConnection:MediaServerConnection;
private var desktopMediaConnection:MediaServerConnection;
[Bindable]
public var STATE_ARRAY:Array=[{label: "Document", data: "1"}, {label: "WhiteBoard", data: "2"}];

private var consolidateXmlBuilder:ConsolidateXmlBuilder
private var contextSetter:ContextSetter
private var centalTimer:Timer;

private var playerInitialized:Boolean=false;
//RTCR: Whether the commented code is needed or not?
// private var wbSprite:ScratchArea
public var fileLoaderManager:FileLoaderManager
private var fullScreenPresenterSet:Boolean=false;
private var fullScreenViewerSet:Boolean=false;
//RTCR: Whether the Bindable part is needed or not?
[Bindable]
//RTCR: Whether the commented code is needed or not?
// private var timeVariable:int=0;
private var videoVolume:SoundTransform=new SoundTransform();
private var diffSeekValuePresenter:int=0;
private var diffSeekValueViewer:int=0;
//This variable is used to checks whether the editing page is active or not.       
public var editingActive:Boolean=false;
private var pausedTimer:Boolean=false;
private var whiteboardMask:Canvas;
[Bindable]
private var lectureTitle:String;
private var playerUIInitialTimeOut:uint

private var isLocalPlayback:Boolean=false;

/**Platform specific variables*/
applicationType::web{
	public var objDesktopPlayer:DesktopPlayback=null;
}
applicationType::desktop{
	public var objDesktopPlayer:DesktopPlaybackWindow=null;
	public var fullScreenPresenter:FullScreenComp;
	public var fullScreenViewer:FullScreenComp;
	public var fullScreenChat:FullScreenComp;
}

//RTCR: Follow the rules to add description for all the functions in this file.
/**
 * It creates the different UI components such as Video components, chat components
 * etc
 */
private function initPlayer():void{
	//isLocalPlayback=FlexGlobals.topLevelApplication.mainApp.lmsInst.isLocalPlay;
	createDocComp();
	createPresenterVideoComp();
	createViewerVideoComp();
	createChatComp();
	log=Log.getLogger("aview.edu.amrita.aview.playback.Components.AviewPlayerComp");
	//createWbComp();
	playerUIInitialTimeOut=setTimeout(loadRecordedFiles, 200);
	playpauseButton.addEventListener(KeyboardEvent.KEY_DOWN, btn_keyBoardStroke);
	stopButton.addEventListener(KeyboardEvent.KEY_DOWN, btn_keyBoardStroke);
	closeWndowButton.addEventListener(KeyboardEvent.KEY_DOWN, btn_keyBoardStroke);
}

//VVCR: It would be nice if all the variable declaration comes on top in one place.
private var timeOutId:uint

//PNCR: please check whether these functions are required or not
public function playerResizeHandler(event:ResizeEvent):void{
	//RTCR: Whether the commented code is needed or not?
	/*if(docComp && docComp.slidelist ){
	docComp.slidelist.executeBindings();
	if(docSlideIndex>-1){
	timeOutId=setTimeout(setIndex,100);
	}
	}*/
}

private function setIndex():void{
	//RTCR: Whether the commented code is needed or not?
	/*clearTimeout(timeOutId);;
	docComp.slidelist.scrollToIndex(docSlideIndex);
	docComp.slidelist.selectedIndex=docSlideIndex;*/
}

private function loadRecordedFiles():void{
	clearTimeout(playerUIInitialTimeOut);
	fileLoaderManager=new FileLoaderManager(contentUrl + "/" + contentFilePath)
	fileLoaderManager.addEventListener(FileLoadedEvent.ALL_LOADED, onAllFilesLoaded);
	fileLoaderManager.addEventListener(FileLoadedEvent.FILES_NOT_EXISTS, onFileLoadError);
	fileLoaderManager.loadRecordedFiles();
	tn.selectedIndex=1;
	
}

//PNCR: combine the common logic in the below functions to a single function
private function createPresenterVideoComp():void{
	presenterVid=new VideoComp();
	presenterVid.width=presenter.width;
	presenterVid.height=presenter.height;
	PopUpManager.addPopUp(presenterVid, presenter);
	presenterVid.title="Presenter Video :";
	presenterVid.muteButton.addEventListener(MouseEvent.CLICK, presenterVolume);
	presenterVid.volumeSeek.addEventListener(SliderEvent.CHANGE, controlVolume);
	if (editingActive == false){
		presenterVid.doubleClickEnabled=true;
		presenterVid.addEventListener(CloseEvent.CLOSE, closePresenterWndw);
		presenterVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK, presenterVideoFullscreen);
		presenterVid.addEventListener(MouseEvent.MOUSE_DOWN, addMoveListnerPresenterVd);
		presenterVid.addEventListener(MouseEvent.MOUSE_UP, removeMoveListnerPresenterVd);
	}
}

private function createViewerVideoComp():void{
	viewerVid=new VideoComp();
	PopUpManager.addPopUp(viewerVid, viewer);
	viewerVid.width=viewer.width;
	viewerVid.height=viewer.height;
	viewerVid.x=viewer.x;
	viewerVid.y=viewer.y;
	viewerVid.title="Viewer Video :";
	viewerVid.muteButton.addEventListener(MouseEvent.CLICK, viewerVolume);
	viewerVid.volumeSeek.addEventListener(SliderEvent.CHANGE, controlVolume);
	if (editingActive == false){
		viewerVid.doubleClickEnabled=true;
		viewerVid.addEventListener(CloseEvent.CLOSE, closeViewerWndw);
		viewerVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK, viewerVideoFullscreen);
		viewerVid.addEventListener(MouseEvent.MOUSE_DOWN, addMoveListnerViewerVd);
		viewerVid.addEventListener(MouseEvent.MOUSE_UP, removeMoveListnerViewerVd);
	}
	else{
		playpauseButton.visible=false;
		stopButton.visible=false;
		closeWndowButton.visible=false;
	}
}

private function createDocComp():void{
	docComp=new DocComp();
	documentTab.addChild(docComp);
	docComp.documentPlayer.setDocPath(contentUrl + "/" + contentFilePath);
	docComp.documentPlayer.addEventListener(AviewPlayerEvent.DOC_TAB_CHANGED, onDocPlayerEvent);
	docComp.documentPlayer.addEventListener(AviewPlayerEvent.WB_TAB_CHANGED, onDocPlayerEvent)
	docComp.addEventListener(AviewPlayerEvent.SLIDE_PANNEL_CLOSSED, onSlidePannelClose);
	docComp.documentPlayer.addEventListener(AviewPlayerEvent.SLIDE_CHANGE, onSlideChange);
	docComp.addEventListener(AviewPlayerEvent.SlideSlected, onSlideSelected);
	docComp.p2fLoader.visible=true;
}

//VVCR: Variable declaration needs to be on top, in one place 
private var docSlideIndex:int=-1

//PNCR: check whether the function is required
private function onSlideChange(evnt:AviewPlayerEvent):void{
	//RTCR: Whether the commented code is needed or not?
	/*docSlideIndex=evnt.currentSlideIndex;
	docComp.slidelist.scrollToIndex(docSlideIndex);
	docComp.slidelist.selectedIndex=docSlideIndex;*/
}

private function createWbComp():void{
	wbPlayer=new WbPlayer();
	wbPlayer.whiteBoardSprite.width=wbCan.width;
	wbPlayer.whiteBoardSprite.height=wbCan.height;
	wbPlayer.addEventListener(AviewPlayerEvent.WB_TAB_CHANGED, onWbPlayerEvent);
	wbPlayer.addEventListener(AviewPlayerEvent.WB_PAGE_CHANGED, onWbPlayerEvent);
	wbPlayer.addEventListener(AviewPlayerEvent.WB_CLEARED, onWbPlayerEvent);
	wbPlayer.whiteBoardSprite.drawBackground(0xffffff);
	wbCan.addChild(wbPlayer.whiteBoardSprite);
	whiteboardMask=new Canvas;
	whiteboardMask.graphics.beginFill(0xffffff, 1);
	whiteboardMask.graphics.drawRect(0, 0, wbCan.width, wbCan.height);
	wbCan.mask=whiteboardMask;
	wbCan.addChild(whiteboardMask);
}

private function createChatComp():void{
	chatWndw=new ChatCom();
	if (editingActive == false){
		chatWndw.doubleClickEnabled=true;
		chatWndw.addEventListener(MouseEvent.DOUBLE_CLICK, chatWindowFullscreen)
		chatWndw.width=chat.width;
		chatWndw.height=chat.height;
		chatWndw.x=chat.x;
		chatWndw.y=chat.y + 5.5;
		chatWndw.addEventListener(MouseEvent.MOUSE_DOWN, addMoveListnerChat);
		chatWndw.addEventListener(MouseEvent.MOUSE_UP, removeMoveListnerChat);
		chatWndw.addEventListener(CloseEvent.CLOSE, closeChatWndw);
	}
	PopUpManager.addPopUp(chatWndw, chat);
	//RTCR: Whether the commented code is needed or not?
	//chatWndw.chatPlayer.setUiReference(chatWndw.chatbox);
}

public function setValues(presenterFMSUrl:String, viewerFMSUrl:String, videoFilePath:String, contentUrl:String, contentFilePath:String, lectureInfo:String, desktopFMSUrl:String, isLocalPlay:Boolean):void{
	isLocalPlayback=isLocalPlay;
	this.presenterFMSUrl=presenterFMSUrl;
	this.desktopFMSUrl=desktopFMSUrl;
	this.viewerFMSUrl=viewerFMSUrl;
	this.videoFilePath=videoFilePath;
	this.contentUrl=contentUrl;
	this.contentFilePath=contentFilePath;
	ClassroomContext.RECORDED_CONTENT_FILE_PATH=contentFilePath;
	ClassroomContext.RECORDED_CONTENT_URL=contentUrl;
	lectureTitle="Lecture Topic:" + lectureInfo;
}

private function onAllFilesLoaded(evnt:FileLoadedEvent):void{
	if (fileLoaderManager.desktopXml.hasOwnProperty("video")) createDesktopPlayer();
	fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED, onAllFilesLoaded);
	fileLoaderManager.removeEventListener(FileLoadedEvent.FILES_NOT_EXISTS, onFileLoadError);
	contextSetter=new ContextSetter(fileLoaderManager);
	consolidateXmlBuilder=new ConsolidateXmlBuilder(fileLoaderManager, contentUrl + "/" + contentFilePath);
	consolidateXmlBuilder.addEventListener(AviewPlayerEvent.CONSOLIDATE_XML_CREATED, initializePlayers);
	consolidateXmlBuilder.buildConsilidateXml();
}

private function onFileLoadError(evnt:FileLoadedEvent):void{
	Alert.show("Error Loading the Lecture", "Playback Module", 4, this);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.editingActiveflag=0;
	this.dispatchEvent(new Event("File error"));
	fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED, onAllFilesLoaded);
	fileLoaderManager.removeEventListener(FileLoadedEvent.FILES_NOT_EXISTS, onFileLoadError);
}

public function closePlayer():void{
	applicationType::desktop{
		//close() method is not available for web.
		if (fullScreenPresenter) fullScreenPresenter.close();
		if (fullScreenChat) fullScreenChat.close();
		if (fullScreenViewer) fullScreenViewer.close();
	}
	if (centalTimer && centalTimer.running) centalTimer.stop();
	if (Log.isInfo()) log.info("In closePlayer- Timer Stopped");
	viewerVid.videoPlayer.stopVideoPlayer();
	viewerVid.videoPlayer=null;
	viewerVid=null;
	//Close presenter video player
	presenterVid.videoPlayer.stopVideoPlayer();
	presenterVid.videoPlayer=null;
	presenterVid=null;
	
	if (objDesktopPlayer != null){
		applicationType::web{
			objDesktopPlayer.videoPlayer.stopVideoPlayer();
			objDesktopPlayer.videoPlayer=null;
		}
		applicationType::desktop{
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.stopVideoPlayer();
			objDesktopPlayer.desktopPlaybackComp.videoPlayer=null;
			//close() method is not available for web.
			objDesktopPlayer.close();
		}
		objDesktopPlayer=null;
	}
	
	//Close document player
	docComp.documentPlayer.closeDocumentPlayer();
	docComp.documentPlayer=null;
	docComp=null;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp) 
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.killPlayback();
}
//RTCR: Move following variable to top
private var objHeight:Number=0;
private var objWidth:Number=0;
private var resizeCount:Number=0;
private var previousWidth:Number=0;

public function getResolution(obj:DisplayObjectContainer):void{
	if (resizeCount == 0){
		previousWidth=objWidth;
		resizeCount=resizeCount + 1;
	}
	var tempWidth:Number;
	
	objHeight=obj.height;
	tempWidth=(objHeight / 3) * 4;
	if (tempWidth >= obj.width){
		objWidth=obj.width;
		objHeight=(objWidth / 4) * 3;
	}
	else objWidth=tempWidth;
}

//PNCR: create a common function for the below function actions
private function presenterResize():void{
	if (presenterVid && (presenterVid.videoDisp.hasEventListener(MouseEvent.DOUBLE_CLICK) || editingActive)){
		presenterVid.width=presenter.width;
		presenterVid.height=presenter.height;
		presenterVid.x=presenter.x;
		presenterVid.y=presenter.y;
	}
}

private function viewerResize():void{
	if (viewerVid && (viewerVid.videoDisp.hasEventListener(MouseEvent.DOUBLE_CLICK) || editingActive)){
		viewerVid.width=viewer.width;
		viewerVid.height=viewer.height;
		viewerVid.x=viewer.x;
		viewerVid.y=presenter.y + presenter.height + 10;
	}
}

private function chatResize():void{
	if (chatWndw && editingActive == false && (chatWndw.hasEventListener(MouseEvent.DOUBLE_CLICK) || editingActive)){
		chatWndw.width=chat.width;
		chatWndw.height=chat.height;
		chatWndw.x=chat.x;
		chatWndw.y=viewerVid.y + viewerVid.height + 10;
	}
}
//RTCR: Move following variable to top
private var referanceTime:Number;
private var currentTimeOffset:uint;

private function startCentralTimer():void{
	if ((isPresenterFMSConnected && isViewerFMSConnected) || isLocalPlayback){
		if (fileLoaderManager.desktopXml.hasOwnProperty("video") && !isDesktopFMSConnected)
			return;
		centalTimer=new Timer(10)
		centalTimer.addEventListener(TimerEvent.TIMER, updateCentralSeekBar)
		seekUpdateCount=1;
		playHeadTime=0;
		var date:Date=new Date();
		referanceTime=date.time;
		centalTimer.start();
		if (Log.isInfo()) log.info("In startCentralTimer- Timer Started");
		playLecture()
		//RTCR: Whether the commented code is needed or not?
		/*wbPlayer.playWb(0);
		docComp.documentPlayer.playDocument(0);
		chatWndw.chatPlayer.playChat(0);*/
		
		this.dispatchEvent(new Event("PlayerInitialized"));
	}
}

//RTCR: Move following variable to top
public var viewerFMSUrl:String;
public var videoFilePath:String;
public var contentUrl:String;
public var contentFilePath:String;
private var seekUpdateCount:uint;
public var playHeadTime:Number
private var scaleFactorX:Number;
private var scaleFactorY:Number;
private var previousPlayTime:Number=-1;
private var previousViewerPlayTime:Number=-1;
public var editTime:Label=new Label();
public var editTotalTime:Label=new Label();
private var portTesterDesktopTimeoutId:uint;
private var portTesterViewerTimeoutId:uint;

private function formatAndDisplayCentralTime():void{
	var Hours:uint=playHeadTime / (1000 * 60 * 60)
	var Minutes:uint=(playHeadTime % (1000 * 60 * 60)) / (1000 * 60);
	var Seconds:uint=((playHeadTime % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
	centralTimeLabel.text=Hours.toString() + ":" + Minutes.toString() + ":" + Seconds.toString()
	if (editingActive){
		var editMinutes:uint=Minutes + (Hours * 60);
		editTime.text=editMinutes.toString() + ":" + Seconds.toString();
	}
}

private function updateReferenceTime():void{
	var date:Date=new Date()
	referanceTime=date.time - playHeadTime - currentTimeOffset;
}

private function stopPlayingVideo():void{
	if (presenterVid.videoPlayer.netStreamVideo && (!isLocalPlayback)) presenterVid.videoPlayer.netStreamVideo.close();
	else if (isLocalPlayback && presenterVid.videoPlayer.isVideoLoaded) presenterVid.videoDisp.stop();
	//RTCR: Whether the commented code is needed or not?
	//presenterVid.videoPlayer.currentVideoEndTime=0;
	presenterVid.videoPlayer.currentVideoSource="";
	
	presenterVid.videoPlayer.previousEtime=0;
	presenterVid.videoPlayer.previousStime=0;
	presenterVid.lblVideoMode.visible=false;
	if (viewerVid.videoPlayer.netStreamVideo && (!isLocalPlayback)) viewerVid.videoPlayer.netStreamVideo.close();
	else if (isLocalPlayback && viewerVid.videoPlayer.isVideoLoaded) viewerVid.videoDisp.stop();
	//RTCR: Whether the commented code is needed or not?
	//viewerVid.videoPlayer.currentVideoEndTime=0;
	viewerVid.videoPlayer.currentVideoSource="";
	viewerVid.videoPlayer.previousEtime=0;
	viewerVid.videoPlayer.previousStime=0;
	viewerVid.lblVideoMode.visible=false;
	applicationType::web{
		if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.netStreamVideo) objDesktopPlayer.videoPlayer.netStreamVideo.close();
		if (objDesktopPlayer != null){
			objDesktopPlayer.videoPlayer.currentVideoSource="";
			objDesktopPlayer.videoPlayer.previousEtime=0;
			objDesktopPlayer.videoPlayer.previousStime=0;
		}
	}
	applicationType::desktop{
		if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo) objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.close();
		if (objDesktopPlayer != null){
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.currentVideoSource="";
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.previousEtime=0;
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.previousStime=0;
		}
	}
	if (presenterVid.videoPlayer.isVideoLoaded && (!isLocalPlayback)) presenterVid.videoPlayer.isStreamReady=false;
	presenterVid.videoPlayer.isVideoLoaded=false;
	presenterVid.videoDisp.mx_internal::videoPlayer.clear();
	
	if (viewerVid.videoPlayer.isVideoLoaded && (!isLocalPlayback)) viewerVid.videoPlayer.isStreamReady=false
	viewerVid.videoPlayer.isVideoLoaded=false;
	viewerVid.videoDisp.mx_internal::videoPlayer.clear();
	
	centalTimer.stop();
	applicationType::web{
		if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isVideoLoaded){
			objDesktopPlayer.videoPlayer.isStreamReady=false
			objDesktopPlayer.videoPlayer.isVideoLoaded=false;
			objDesktopPlayer.videoDisp.mx_internal::videoPlayer.clear();
		}
	}
	applicationType::desktop{
		if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded){
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady=false
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded=false;
			objDesktopPlayer.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
		}
	}
}

private function playLecture():void{
	if (playpauseButton.label == "Play") playpauseButton.label="Pause"
	if (!stopButton.enabled) stopButton.enabled=true;
	if ((playHeadTime / 1000) >= seekBar.maximum){
		if (Log.isInfo()) log.info("In playLecture Play End- Timer Stopped");
		resetPlayer();
		this.dispatchEvent(new CloseFileHandler(CloseFileHandler.PLAYBACK_STOP));
	}
	else{
		wbPlayer.playWhiteBoard(playHeadTime);
		wbPointerPlayer.playWhiteBoardPointer(playHeadTime);
		pttPlayer.playPtt(playHeadTime);
		presenterVid.videoPlayer.playVid(playHeadTime, "pVideo");
		viewerVid.videoPlayer.playVid(playHeadTime, "vVideo");
		if (objDesktopPlayer != null){
			applicationType::web{
				objDesktopPlayer.videoPlayer.playVid(playHeadTime, "desktop");
			}
			applicationType::desktop{
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.playVid(playHeadTime, "desktop");
			}
		}		
		chatWndw.chatPlayer.playChat(playHeadTime);
		if (playHeadTime % 1000 == 0) seekBar.value=(playHeadTime / 1000);
		//PNCR: check whether we can combine the presentVI and viewerVId if else condition to a single function
		if (presenterVid.videoPlayer.isVideoSeekedManually){
			presenterVid.videoPlayer.isVideoSeekedManually=false;
			presenterVid.videoPlayer.isVideoSeekedAutomatically=false;
			presenterVid.videoPlayer.isSeekValueSetZero=false;
			diffSeekValuePresenter=presenterVid.videoPlayer.videoSeekValue;
		}
		else if (presenterVid.videoPlayer.isVideoSeekedAutomatically){
			presenterVid.videoPlayer.isVideoSeekedManually=false;
			presenterVid.videoPlayer.isVideoSeekedAutomatically=false;
			presenterVid.videoPlayer.isSeekValueSetZero=false;
			diffSeekValuePresenter=presenterVid.videoPlayer.videoSeekValue - seekBar.value;
		}
		else if (presenterVid.videoPlayer.isSeekValueSetZero){
			diffSeekValuePresenter=0;
		}
		
		if (viewerVid.videoPlayer.isVideoSeekedAutomatically){
			viewerVid.videoPlayer.isVideoSeekedManually=false;
			viewerVid.videoPlayer.isVideoSeekedAutomatically=false;
			viewerVid.videoPlayer.isSeekValueSetZero=false;
			diffSeekValueViewer=viewerVid.videoPlayer.videoSeekValue - seekBar.value;
		}
		else if (viewerVid.videoPlayer.isVideoSeekedManually){
			viewerVid.videoPlayer.isVideoSeekedManually=false;
			viewerVid.videoPlayer.isVideoSeekedAutomatically=false;
			viewerVid.videoPlayer.isSeekValueSetZero=false;
			diffSeekValueViewer=viewerVid.videoPlayer.videoSeekValue;
		}
		else if (viewerVid.videoPlayer.isSeekValueSetZero){
			diffSeekValueViewer=0;
		}
		//PNCR: check whether we can combine these two sections into a single function
		applicationType::web{
			if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isVideoSeekedManually){
				objDesktopPlayer.videoPlayer.isVideoSeekedManually=false;
				objDesktopPlayer.videoPlayer.isVideoSeekedAutomatically=false;
				objDesktopPlayer.videoPlayer.isSeekValueSetZero=false;
				diffSeekValuePresenter=objDesktopPlayer.videoPlayer.videoSeekValue;
			}
			else if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isVideoSeekedAutomatically){
				objDesktopPlayer.videoPlayer.isVideoSeekedManually=false;
				objDesktopPlayer.videoPlayer.isVideoSeekedAutomatically=false;
				objDesktopPlayer.videoPlayer.isSeekValueSetZero=false;
				diffSeekValuePresenter=objDesktopPlayer.videoPlayer.videoSeekValue - seekBar.value;
			}
			else if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isSeekValueSetZero){
				diffSeekValuePresenter=0;
			}
		}
		applicationType::desktop{
			if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoSeekedManually){
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoSeekedManually=false;
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoSeekedAutomatically=false;
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.isSeekValueSetZero=false;
				diffSeekValuePresenter=objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoSeekValue;
			}
			else if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoSeekedAutomatically){
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoSeekedManually=false;
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoSeekedAutomatically=false;
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.isSeekValueSetZero=false;
				diffSeekValuePresenter=objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoSeekValue - seekBar.value;
			}
			else if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isSeekValueSetZero){
				diffSeekValuePresenter=0;
			}
		}
	}
}

private function resetPlayer():void{
	centalTimer.stop()
	centalTimer.reset();
	if (presenterVid)
		presenterVid.lblVideoMode.visible=false;
	if (viewerVid)
		viewerVid.lblVideoMode.visible=false;
	pausedTimer=false;
	playHeadTime=-100;
	currentTimeOffset=0;
	seekUpdateCount=1;
	stopPlayingVideo();
	wbPlayer.clearWhiteBoard();

	chatWndw.chatbox.text="";
	playpauseButton.label="Play";
	seekBar.value=0;
	centralTimeLabel.text="00:00:00";
	stopButton.enabled=false;
	tn.selectedIndex=1;
	presenterVid.playBackIcon=presenterVid.playBack_unclicked;
	presenterVid.muteButton.toolTip="Mute";
	viewerVid.playBackIcon=viewerVid.playBack_unclicked;
	viewerVid.muteButton.toolTip="Mute";
}

private function updateCentralSeekBar(evnt:TimerEvent):void{
	var date:Date=new Date()
	currentTimeOffset=date.time - (referanceTime + playHeadTime);
	if (currentTimeOffset >= 100){
		playHeadTime+=100
		formatAndDisplayCentralTime();
		playLecture();
	}
}

//VVCR: Variable declaration comes on top
public var docComp:DocComp=new DocComp();

private function onDocPlayerEvent(evnt:AviewPlayerEvent):void{
	if (evnt.type == AviewPlayerEvent.DOC_TAB_CHANGED) tn.selectedIndex=0;
	if (evnt.type == AviewPlayerEvent.WB_TAB_CHANGED) tn.selectedIndex=1;
}

private function onSlideSelected(event:AviewPlayerEvent):void{
	seekBar.value=event.time / 1000;
	var slideTimeRounded:int=Math.floor(event.time / 100);
	playHeadTime=(slideTimeRounded * 100);
	currentTimeOffset=0;
	updateReferenceTime();
	if (!centalTimer.running){
		centalTimer.start();
		if (Log.isInfo()) log.info("In onSlideSelected- Timer Started");
	}
	chatWndw.chatPlayer.updateChat(playHeadTime);
	wbPlayer.setContext(event.time);
	//RTCR: Whether the commented code is needed or not?
	//docComp.documentPlayer.setContext(event.time);
	formatAndDisplayCentralTime();
	presenterVid.videoPlayer.setContext(playHeadTime, seekBar.value, "pVideo", presenterVid.videoDisp);
	viewerVid.videoPlayer.setContext(playHeadTime, seekBar.value, "vVideo", viewerVid.videoDisp);
	if (objDesktopPlayer != null){
		applicationType::web{
			objDesktopPlayer.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.videoDisp);
		}
		applicationType::desktop{
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.desktopPlaybackComp.videoDisp);
		}
	}
}

private function onSlidePannelClose(evnt:AviewPlayerEvent):void{
	slideBtn.enabled=true;
}

private function initializePlayers(evnt:AviewPlayerEvent):void{
	wbPointerPlayer=new WhiteBoardPointerPlayer(consolidateXmlBuilder, wbPlayer.whiteBoardSprite);
	//RTCR: Whether the commented code is needed or not?
	//pttPlayer=new PttPlayer(presenterVid,viewerVid,consolidateXmlBuilder,contextSetter);				
	pttPlayer.addEventListener(AviewPlayerEvent.MUTE_PRESENTER_STREAM, mutePresenter);
	pttPlayer.addEventListener(AviewPlayerEvent.MUTE_VIEWER_STREAM, muteViewer);
	pttPlayer.addEventListener(AviewPlayerEvent.UNMUTE_PRESENTER_STREAM, unMutePresenter);
	pttPlayer.addEventListener(AviewPlayerEvent.UNMUTE_VIEWER_STREAM, unMuteViewer);
	seekBar.maximum=(fileLoaderManager.endTimeXml.etime) / 1000;
	var time:Number=seekBar.maximum * 1000;
	var Hours:uint=time / (1000 * 60 * 60)
	var Minutes:uint=(time % (1000 * 60 * 60)) / (1000 * 60);
	var Seconds:uint=((time % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
	endTimeLabel.text=Hours.toString() + ":" + Minutes.toString() + ":" + Seconds.toString()
	if (editingActive){
		var editMin:uint=(Minutes + Hours * 60)
		editTotalTime.text=editMin.toString() + ":" + Seconds.toString();
	}
	docComp.documentPlayer.setConsolidateXMLBuilder(consolidateXmlBuilder);
	docComp.documentPlayer.setContextSetter(contextSetter);
	wbPlayer.setValues(consolidateXmlBuilder, contextSetter);
	chatWndw.chatPlayer.setConsolidateXML(consolidateXmlBuilder);
	seekBar.addEventListener(SliderEvent.CHANGE, seekChange)
	seekBar.addEventListener(SliderEvent.THUMB_RELEASE, seekChange);
	seekBar.addEventListener(MouseEvent.MOUSE_DOWN, onSeekBarMouseDown)
	seekBar.addEventListener(CloseFileHandler.CUT_RECORDED_INIT, removeSeekChange);
	seekBar.addEventListener(CloseFileHandler.CUT_RECORDED_CLOSE, initializeSeekChange);
	if (!isLocalPlayback){
		getConnectedPresenter();
		if (presenterFMSUrl != viewerFMSUrl) portTesterViewerTimeoutId=setTimeout(getConnectedViewer, 100);
		if (presenterFMSUrl != desktopFMSUrl || viewerFMSUrl != desktopFMSUrl) portTesterDesktopTimeoutId=setTimeout(getConnectedDesktop, 200);
	}
	
}

//VVCR:Move variable declarations on top 
private var isCutLecturePopUp:Boolean=false;

private function removeSeekChange(event:CloseFileHandler):void{
	isCutLecturePopUp=true;
}

private function initializeSeekChange(event:CloseFileHandler):void{
	isCutLecturePopUp=false;
}

//VVCR:Move variable declarations on top 
private var isPresenterFMSConnected:Boolean=false;
private var isViewerFMSConnected:Boolean=false;
private var isDesktopFMSConnected:Boolean=false;

private function connectToViewerVideo():void{
	//RTCR: Whether the commented code is needed or not?
	//	viewerVid.videoPlayer.setValues(viewerFmsConnection.netConnection,videoFilePath,consolidateXmlBuilder,contextSetter
	//		,fileLoaderManager,viewerVid,null,isLocalPlayback);
	viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_READY, onViewerStreamStatus);
	viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_NOT_READY, onViewerStreamStatus);
	viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE, onViewerStreamStatus);
	viewerVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_SEEK, startTimeUpdate);
	viewerVid.videoPlayer.connectToVod();
	isViewerFMSConnected=true;
}

private function connectToDesktopVideo():void{
	if (objDesktopPlayer != null){
		applicationType::web{
			objDesktopPlayer.videoPlayer.setValues(desktopMediaConnection.mediaServerConnection, videoFilePath, consolidateXmlBuilder, contextSetter, fileLoaderManager, null, objDesktopPlayer);
			objDesktopPlayer.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_READY, onDesktopStreamStatus);
			objDesktopPlayer.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_NOT_READY, onDesktopStreamStatus);
			objDesktopPlayer.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE, onDesktopStreamStatus);
			objDesktopPlayer.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_SEEK, startTimeUpdate);
			objDesktopPlayer.videoPlayer.connectToVod();
		}
		applicationType::web{
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.setValues(desktopMediaConnection.mediaServerConnection, videoFilePath, consolidateXmlBuilder, contextSetter, fileLoaderManager, null, objDesktopPlayer);
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_READY, onDesktopStreamStatus);
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_NOT_READY, onDesktopStreamStatus);
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE, onDesktopStreamStatus);
			objDesktopPlayer.desktopPlaybackComp.addEventListener(AviewPlayerEvent.STREAM_SEEK, startTimeUpdate);
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.connectToVod();
		}
		isDesktopFMSConnected=true;
	}
}

private function getConnectedPresenter():void{
	
	//VVCR: The connection parameters can be taken from an configuration file or something where we have the flexibility of
	//changing the parameters. Now in this case the,the code will break if the hard coded "/vod" is getting changed in
	//somewhere else like where the recording happens etc. Atleast this can be specified in a global constants file so that
	//changes will only happen there and will be reflected through out the code base.
	var presenterFMSIP:String=presenterFMSUrl.substring(presenterFMSUrl.indexOf("://") + 3, presenterFMSUrl.indexOf("/vod"))
	
	presenterMediaConnection=new MediaServerConnection(presenterFMSIP,"vod",null,null,new VodCustomClient());
	presenterMediaConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, onStatusPresenterConnection)
	playerInitialized=true;
}

private function onStatusPresenterConnection(mediaServerStatus:MediaServerStatusEvent):void{
	if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED){
		onConnectionTestFailedHandler("Presenter");
	}
	else if (mediaServerStatus.code == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS){
		presenterConnectionSuccessHandler();
	}
	else{
		connectionUnSuccessfulHanlder(mediaServerStatus.code,"PlaybackPresenter", presenterMediaConnection.netConnection.uri);	
	}
}

private function onConnectionTestFailedHandler(connectionType:String):void{
	MessageBox.show("Connection to the "+connectionType+" server failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", 
		"Connection Failed", MessageBox.MB_OK, null, null);
}
	

private function presenterConnectionSuccessHandler():void{
	AuditContext.userAction.connectionSuccessEventLog("PlaybackPresenter", presenterMediaConnection.netConnection.uri, null);
	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_READY, onPresenterStreamStatus);
	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_NOT_READY, onPresenterStreamStatus);
	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE, onPresenterStreamStatus);
	presenterVid.videoPlayer.addEventListener(AviewPlayerEvent.STREAM_SEEK, startTimeUpdate);
	presenterVid.videoPlayer.connectToVod();
	
	isPresenterFMSConnected=true;
	if (presenterFMSUrl == viewerFMSUrl){
		viewerMediaConnection=presenterMediaConnection;
		viewerConnectionSuccessHandler();
	}
	startCentralTimer();
}

private function getConnectedViewer():void{
	clearTimeout(portTesterViewerTimeoutId);
	//VVCR: The connection parameters can be taken from an configuration file or something where we have the flexibility of
	//changing the parameters. Now in this case the,the code will break if the hard coded "/vod" is getting changed in
	//somewhere else like where the recording happens etc. Atleast this can be specified in a global constants file so that
	//changes will only happen there and will be reflected through out the code base.
	var viewerFMSIP:String=viewerFMSUrl.substring(viewerFMSUrl.indexOf("://") + 3, viewerFMSUrl.indexOf("/vod"))
	
	viewerMediaConnection=new MediaServerConnection(viewerFMSIP,"vod",null,null,new VodCustomClient());
	viewerMediaConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, onStatusViewerConnection)
	
}

private function onStatusViewerConnection(mediaServerStatus:MediaServerStatusEvent):void{
	if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED){
		//VVCR: The connetionType parameter can be stored in a gloabl constants file and refered here.That way code base will be more consistent 
		onConnectionTestFailedHandler("Viewer");
	}
	else if (mediaServerStatus.code == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS){
		viewerConnectionSuccessHandler();
	}  
	else{
		//VVCR: The playerType parameter can be stored in a gloabl constants file and refered here.That way code base will be more consistent 
		connectionUnSuccessfulHanlder(mediaServerStatus.code,"PlaybackViewer", viewerMediaConnection.netConnection.uri);	
	}
}

private function viewerConnectionSuccessHandler():void
{
	//VVCR: The playerType parameter can be stored in a gloabl constants file and refered here.That way code base will be more consistent 
	AuditContext.userAction.connectionSuccessEventLog("PlaybackViewer", viewerMediaConnection.netConnection.uri, null);
	connectToViewerVideo();
	startCentralTimer();
	if (viewerFMSUrl == desktopFMSUrl){
		desktopMediaConnection=viewerMediaConnection;
		desktopConnectionSuccessHandler();
	}
}

private function getConnectedDesktop():void{
	clearTimeout(portTesterDesktopTimeoutId);
	if (desktopFMSUrl != null){
		var desktopFMSIP:String=desktopFMSUrl.substring(desktopFMSUrl.indexOf("://") + 3, desktopFMSUrl.indexOf("/vod"))
		
		desktopMediaConnection=new MediaServerConnection(desktopFMSIP,"vod",null,null,new VodCustomClient());
		desktopMediaConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, onStatusDesktopConnection)
	}
}

private function onStatusDesktopConnection(mediaServerStatus:MediaServerStatusEvent):void{
	
	//VVCR: Use of a switch case rather than if statement makes more sense here.
	if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED){
		//VVCR: The playerType parameter can be stored in a gloabl constants file and refered here.That way code base will be more consistent 
		onConnectionTestFailedHandler("Desktop sharing");
	}
	else if (mediaServerStatus.code == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS){
		desktopConnectionSuccessHandler();
	}
	else{
		connectionUnSuccessfulHanlder(mediaServerStatus.code,"PlaybackDesktop", desktopMediaConnection.netConnection.uri);	
	}
	isDesktopStoppedManually=false;
}

private function desktopConnectionSuccessHandler():void
{
	isDesktopFMSConnected = true;
	AuditContext.userAction.connectionSuccessEventLog("PlaybackDesktop", desktopMediaConnection.netConnection.uri, null);
	connectToDesktopVideo();
	if (isDesktopStoppedManually == false)
		startCentralTimer();
	else if (playpauseButton.label != "Play"){
		applicationType::web{
			objDesktopPlayer.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.videoDisp);
		}
		applicationType::desktop{
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.desktopPlaybackComp.videoDisp);
		}
	}
}

private function connectionUnSuccessfulHanlder(eventCode:String,playerType:String,fmsURL:String):void
{
	if (eventCode == MediaServerStatusEvent.CODE_NET_STATUS_CLOSED)
		AuditContext.userAction.connectionCloseEventLog(playerType, fmsURL);
	else if (eventCode == MediaServerStatusEvent.CODE_NET_STATUS_FAILED)
		AuditContext.userAction.connectionFailEventLog(playerType, fmsURL);
	else if (eventCode == MediaServerStatusEvent.CODE_NET_STATUS_REJECTED)
		AuditContext.userAction.connectionRejectEventLog(playerType, fmsURL);
}
	
private function onPresenterStreamStatus(evnt:AviewPlayerEvent):void{
	if (Log.isInfo()) log.info("In onPresenterStreamStatus Eventsd :-" + evnt.type);
	if (evnt.type == AviewPlayerEvent.STREAM_READY){
		playStreams();
		
	}
	else if (evnt.type == AviewPlayerEvent.STREAM_NOT_READY){
		if (viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded){
			viewerVid.videoPlayer.netStreamVideo.pause();
			
		}
		applicationType::web{
			if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isStreamReady && objDesktopPlayer.videoPlayer.isVideoLoaded){
				objDesktopPlayer.videoPlayer.netStreamVideo.pause();
			}
		}
		applicationType::desktop{
			if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded){
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.pause();
			}
		}
		centalTimer.stop();
		
	}
	if (evnt.type == AviewPlayerEvent.STREAM_PLAY_COPMLETE && presenterVid){
		presenterVid.videoPlayer.videoToggled=false;
		presenterVid.videoPlayer.timerRun=false;
		presenterVid.videoDisp.mx_internal::videoPlayer.clear();
		presenterVid.videoPlayer.netStreamVideo.close();
		presenterVid.videoPlayer.currentVideoSource="";
		presenterVid.videoPlayer.previousEtime=0;
		presenterVid.videoPlayer.previousStime=0;
	}
	
	controlVolume(null);
}

private function playStreams():void{
	if (presenterVid && !presenterVid.videoPlayer.isStreamReady && !presenterVid.videoPlayer.isVideoLoaded){
		presenterVid.videoPlayer.netStreamVideo.close();
		presenterVid.videoDisp.mx_internal::videoPlayer.clear();
	}
	if (viewerVid && !viewerVid.videoPlayer.isStreamReady && !viewerVid.videoPlayer.isVideoLoaded){
		viewerVid.videoPlayer.netStreamVideo.close();
		viewerVid.videoDisp.mx_internal::videoPlayer.clear();
	}
	applicationType::web{
		if (objDesktopPlayer != null && !objDesktopPlayer.videoPlayer.isStreamReady && !objDesktopPlayer.videoPlayer.isVideoLoaded){
			objDesktopPlayer.videoPlayer.netStreamVideo.close();
			objDesktopPlayer.videoDisp.mx_internal::videoPlayer.clear();
		}
		if (!centalTimer.running && ((presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded) || (presenterVid && !presenterVid.videoPlayer.isStreamReady && !presenterVid.videoPlayer.isVideoLoaded)) && ((viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded) || (viewerVid && !viewerVid.videoPlayer.isStreamReady && !viewerVid.videoPlayer.isVideoLoaded)) && ((objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isStreamReady && objDesktopPlayer.videoPlayer.isVideoLoaded) || (objDesktopPlayer && !objDesktopPlayer.videoPlayer.isStreamReady && !objDesktopPlayer.videoPlayer.isVideoLoaded))){
			playStreamHandler();
		}
	}
	applicationType::desktop{
		if (objDesktopPlayer != null && !objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && !objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded){
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.close();
			objDesktopPlayer.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
		}
		if (!centalTimer.running && ((presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded) || (presenterVid && !presenterVid.videoPlayer.isStreamReady && !presenterVid.videoPlayer.isVideoLoaded)) && ((viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded) || (viewerVid && !viewerVid.videoPlayer.isStreamReady && !viewerVid.videoPlayer.isVideoLoaded)) && ((objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded) || (objDesktopPlayer && !objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && !objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded)))
			playStreamHandler();
	}
}
//RTCR: Need to change the function name
private function playStreamHandler():void{
	if (playBackBufferingMessageComp.source != null)
		playBackBufferingMessageComp.unloadAndStop();
	
	//PNCR: please check where we can write a function for this
	if (presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded && playpauseButton.label == "Pause")
		presenterVid.videoPlayer.netStreamVideo.resume();
	
	else if (presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded && playpauseButton.label == "Play")
		presenterVid.videoPlayer.netStreamVideo.pause();
	
	if (viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded && playpauseButton.label == "Pause")
		viewerVid.videoPlayer.netStreamVideo.resume();
	
	else if (viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded && playpauseButton.label == "Play")
		presenterVid.videoPlayer.netStreamVideo.pause();
	
	applicationType::web{
		if (objDesktopPlayer && objDesktopPlayer.videoPlayer.isStreamReady && objDesktopPlayer.videoPlayer.isVideoLoaded && playpauseButton.label == "Pause"){
			objDesktopPlayer.videoPlayer.netStreamVideo.resume();
		}
		else if (objDesktopPlayer && presenterVid.videoPlayer.isStreamReady && objDesktopPlayer.videoPlayer.isVideoLoaded && playpauseButton.label == "Play"){
			objDesktopPlayer.videoPlayer.netStreamVideo.pause();
		}
	}
	applicationType::desktop{
		if (objDesktopPlayer && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded && playpauseButton.label == "Pause"){
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.resume();
		}
		else if (objDesktopPlayer && presenterVid.videoPlayer.isStreamReady && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded && playpauseButton.label == "Play"){
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.pause();
		}
	}
	if (playpauseButton.label == "Pause"){
		updateReferenceTime()
		centalTimer.start();
	}
}

private function onViewerStreamStatus(evnt:AviewPlayerEvent):void{
	if (Log.isInfo()) log.info("In onViewerStreamStatus Eventsd :-" + evnt.type);
	if (evnt.type == AviewPlayerEvent.STREAM_READY) playStreams();
	else if (evnt.type == AviewPlayerEvent.STREAM_NOT_READY){
		if (presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded) presenterVid.videoPlayer.netStreamVideo.pause();
		applicationType::web{
			if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isStreamReady && objDesktopPlayer.videoPlayer.isVideoLoaded) objDesktopPlayer.videoPlayer.netStreamVideo.pause();
		}
		applicationType::desktop{
			if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded) objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.pause();
		}
		centalTimer.stop();
	}
	if (evnt.type == AviewPlayerEvent.STREAM_PLAY_COPMLETE && viewerVid){
		viewerVid.videoPlayer.videoToggled=false;
		viewerVid.videoPlayer.timerRun=false;
		viewerVid.videoDisp.mx_internal::videoPlayer.clear();
		viewerVid.videoPlayer.netStreamVideo.close();
		viewerVid.videoPlayer.currentVideoSource="";
		viewerVid.videoPlayer.previousEtime=0;
		viewerVid.videoPlayer.previousStime=0;
	}
	
	controlVolume(null);
}



private function onDesktopStreamStatus(evnt:AviewPlayerEvent):void{
	if (Log.isInfo()) log.info("In onDesktopStreamStatus Eventsd :-" + evnt.type);
	if (evnt.type == AviewPlayerEvent.STREAM_READY) playStreams();
	else if (evnt.type == AviewPlayerEvent.STREAM_NOT_READY){
		if (presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded) presenterVid.videoPlayer.netStreamVideo.pause();
		if (viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded) viewerVid.videoPlayer.netStreamVideo.pause();
		centalTimer.stop();
	}
	if (evnt.type == AviewPlayerEvent.STREAM_PLAY_COPMLETE && objDesktopPlayer != null){
		applicationType::web{
			objDesktopPlayer.videoPlayer.videoToggled=false;
			objDesktopPlayer.videoPlayer.timerRun=false;
			objDesktopPlayer.videoDisp.mx_internal::videoPlayer.clear();
			objDesktopPlayer.videoPlayer.netStreamVideo.close();
			objDesktopPlayer.videoPlayer.currentVideoSource="";
			objDesktopPlayer.videoPlayer.previousEtime=0;
			objDesktopPlayer.videoPlayer.previousStime=0;
		}
		applicationType::desktop{
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoToggled=false;
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.timerRun=false;
			objDesktopPlayer.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.close();
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.currentVideoSource="";
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.previousEtime=0;
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.previousStime=0;
		}
	}
	
	controlVolume(null);
}

private function startTimeUpdate(evnt:AviewPlayerEvent):void{
	applicationType::web{
		if ((!presenterVid.videoPlayer.timerRun) && (!viewerVid.videoPlayer.timerRun) && (objDesktopPlayer != null && !objDesktopPlayer.videoPlayer.timerRun))
			if ((!presenterVid.videoPlayer.isVideoLoaded) && (!viewerVid.videoPlayer.isVideoLoaded) && (!objDesktopPlayer.videoPlayer.isVideoLoaded))
				startTimeUpdateHandler();
	}
	applicationType::desktop{
		if ((!presenterVid.videoPlayer.timerRun) && (!viewerVid.videoPlayer.timerRun) && (objDesktopPlayer != null && !objDesktopPlayer.desktopPlaybackComp.videoPlayer.timerRun))
			if ((!presenterVid.videoPlayer.isVideoLoaded) && (!viewerVid.videoPlayer.isVideoLoaded) && (!objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded))
				startTimeUpdateHandler();
	}
}
//RTCR: Need to change the function name
private function startTimeUpdateHandler():void{
	if (!pausedTimer){
		if (!centalTimer.running){
			updateReferenceTime()
			centalTimer.start();
			if(playBackBufferingMessageComp.source!=null)
			{
				playBackBufferingMessageComp.unloadAndStop();
			}
			if (Log.isInfo())log.info("In startTimeUpdate- Timer Started");
		}
	}
	else{
		viewerVid.videoPlayer.previousEtime=0;
		viewerVid.videoPlayer.previousStime=0;
		presenterVid.videoPlayer.previousEtime=0;
		presenterVid.videoPlayer.previousStime=0;
		
		if (objDesktopPlayer != null){
			applicationType::web{
				objDesktopPlayer.videoPlayer.previousEtime=0;
				objDesktopPlayer.videoPlayer.previousStime=0;
				objDesktopPlayer.videoPlayer.currentVideoSource="";
				objDesktopPlayer.videoPlayer.netStreamVideo.close();
				objDesktopPlayer.videoDisp.mx_internal::videoPlayer.clear();
			}
			applicationType::desktop{		
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.previousEtime=0;
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.previousStime=0;
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.currentVideoSource="";
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.close();
				objDesktopPlayer.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
			}
		}
		presenterVid.videoPlayer.currentVideoSource="";
		viewerVid.videoPlayer.currentVideoSource="";
		//RTCR: Whether the commented code is needed or not?
		//viewerVid.videoPlayer.currentVideoEndTime=0;
		// presenterVid.videoPlayer.currentVideoEndTime=0;
		//Need to change lvn
		viewerVid.videoPlayer.netStreamVideo.close();
		presenterVid.videoPlayer.netStreamVideo.close();
		
		presenterVid.videoDisp.mx_internal::videoPlayer.clear();
		viewerVid.videoDisp.mx_internal::videoPlayer.clear();
	}
}

private function onWbPlayerEvent(evnt:AviewPlayerEvent):void{
	if (evnt.type == AviewPlayerEvent.WB_TAB_CHANGED) tn.selectedIndex=1;
	else if (evnt.type == AviewPlayerEvent.WB_PAGE_CHANGED){
		pageNo.text="Page No : " + evnt.pageNumber;
		tn.selectedIndex=1 // shold remove this line later only the above line of code is enough
	}
	else if (evnt.type == AviewPlayerEvent.WB_CLEARED) wbPointerPlayer.pointerShape=null;
}

private function onSeekBarMouseDown(evnt:Event):void{
	if(stopButton.enabled)
		playBackBufferingMessageComp.load("assets/flash/playBackLoading.swf");
	centalTimer.stop();
	if (!isLocalPlayback){
		if (viewerVid && viewerVid.videoPlayer.isStreamReady && viewerVid.videoPlayer.isVideoLoaded) viewerVid.videoPlayer.netStreamVideo.pause();
		if (presenterVid && presenterVid.videoPlayer.isStreamReady && presenterVid.videoPlayer.isVideoLoaded) presenterVid.videoPlayer.netStreamVideo.pause();
	}
	applicationType::web{
		if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isStreamReady && objDesktopPlayer.videoPlayer.isVideoLoaded) objDesktopPlayer.videoPlayer.netStreamVideo.pause();
	}
	applicationType::desktop{
		if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded) objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.pause();
	}
	if (Log.isInfo())log.info("In onSeekBarMouseDown - Timer stopped");
}

private function controlVolume(event:Event):void{
	//PNCR: use inline if
	//VVCR: Also a good candidate for switch case implementation. The comparing values can be kept in a global constants file for more consistent code behaviour.
	if (presenterVid.muteButton.toolTip == "Mute")
		presenterVid.muteButton.toolTip="Unmute"
	else
		presenterVid.muteButton.toolTip="Mute"
	if (viewerVid.muteButton.toolTip == "Mute")
		viewerVid.muteButton.toolTip="Unmute"
	else
		viewerVid.muteButton.toolTip="Mute"
	presenterVolume(null);
	viewerVolume(null);
	
}

private function presenterVolume(event:Event):void{
	var evnt:AviewPlayerEvent;
	if (presenterVid.muteButton.toolTip == "Mute") mutePresenter(evnt);
	else unMutePresenter(evnt);
}

private function mutePresenter(evnt:AviewPlayerEvent):void{
	if (presenterVid && presenterVid.videoPlayer && presenterVid.videoPlayer.netStreamVideo){
		videoVolume.volume=0;
		if (!isLocalPlayback) presenterVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
		else presenterVid.videoDisp.volume=0;
		presenterVid.playBackIcon=presenterVid.playBack_clicked;
		presenterVid.muteButton.toolTip="Unmute";
	}
}

private function unMutePresenter(evnt:AviewPlayerEvent):void{
	if (evnt != null && presenterVid.playBackIcon == presenterVid.playBack_clicked) return;
	if (presenterVid && presenterVid.videoPlayer && presenterVid.videoPlayer.netStreamVideo){
		videoVolume.volume=(presenterVid.volumeSeek.value / 100)
		presenterVid.playBackIcon=presenterVid.playBack_unclicked;
		if (!isLocalPlayback) presenterVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
		else presenterVid.videoDisp.volume=(presenterVid.volumeSeek.value / 100);
		presenterVid.muteButton.toolTip="Mute";
		
	}
}

private function unMuteViewer(evnt:AviewPlayerEvent):void{
	if (viewerVid && viewerVid.videoPlayer && viewerVid.videoPlayer.netStreamVideo){
		videoVolume.volume=(viewerVid.volumeSeek.value / 100);
		viewerVid.playBackIcon=viewerVid.playBack_unclicked;
		if (!isLocalPlayback) viewerVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
		else viewerVid.videoDisp.volume=0;
		viewerVid.muteButton.toolTip="Mute";
	}
}

private function muteViewer(evnt:AviewPlayerEvent):void{
	if (viewerVid && viewerVid.videoPlayer && viewerVid.videoPlayer.netStreamVideo){
		videoVolume.volume=0;
		if (!isLocalPlayback) viewerVid.videoPlayer.netStreamVideo.soundTransform=videoVolume;
		else viewerVid.videoDisp.volume=0;
		viewerVid.playBackIcon=viewerVid.playBack_clicked;
		viewerVid.muteButton.toolTip="Unmute";
	}
}

private function viewerVolume(event:Event):void{
	var evnt:AviewPlayerEvent;
	if (viewerVid.muteButton.toolTip == "Mute") muteViewer(evnt);
	else unMuteViewer(evnt);
}

private function addMoveListnerPresenterVd(ev:MouseEvent):void{
	presenterVid.addEventListener(MoveEvent.MOVE, presenterVidMove);
}

private function removeMoveListnerPresenterVd(ev:MouseEvent):void{
	presenterVid.removeEventListener(MoveEvent.MOVE, presenterVidMove);
}

private function addMoveListnerViewerVd(ev:MouseEvent):void{
	viewerVid.addEventListener(MoveEvent.MOVE, viewerVidMove);
}

private function removeMoveListnerViewerVd(ev:MouseEvent):void{
	viewerVid.removeEventListener(MoveEvent.MOVE, viewerVidMove);
}

private function addMoveListnerChat(ev:MouseEvent):void{
	chatWndw.addEventListener(MoveEvent.MOVE, chatMove);
}

private function removeMoveListnerChat(ev:MouseEvent):void{
	chatWndw.removeEventListener(MoveEvent.MOVE, chatMove);
}

//PNCR: check whether we can combine the functions below
private function presenterVidMove(ev:MoveEvent):void{
	if (ev.oldY > (viewer.height / 2) && !fullScreenViewerBool) viewerVid.move(presenter.x, presenter.y);
	if (ev.oldY > (viewer.height / 2 + presenter.height) && !fullScreenChatBool) chatWndw.move(viewer.x, viewer.y);
	if (ev.oldY < (presenter.height / 2) && !fullScreenViewerBool) viewerVid.move(viewer.x, viewer.y);
	if (ev.oldY < (viewer.height / 2 + presenter.height) && !fullScreenChatBool) chatWndw.move(chat.x, chat.y);
}

private function viewerVidMove(ev:MoveEvent):void{
	if (ev.oldY < (viewer.height / 2) && !fullScreenPresenterBool) presenterVid.move(viewer.x, viewer.y);
	if (ev.oldY > (viewer.height / 2) && !fullScreenPresenterBool) presenterVid.move(presenter.x, presenter.y);
	if (ev.oldY > (viewer.height / 2 + presenter.height) && !fullScreenChat) chatWndw.move(viewer.x, viewer.y); 
	if (ev.oldY < (viewer.height / 2 + presenter.height) && !fullScreenChat) chatWndw.move(chat.x, chat.y);
}

private function chatMove(ev:MoveEvent):void{
	if (ev.oldY < (viewer.height / 2 + presenter.height) && !fullScreenViewerBool) viewerVid.move(chat.x, chat.y);
	if (ev.oldY > (viewer.height / 2 + presenter.height) && !fullScreenViewerBool) viewerVid.move(viewer.x, viewer.y);
	if (ev.oldY < (viewer.height / 2) && !fullScreenPresenterBool) presenterVid.move(viewer.x, viewer.y);
	if (ev.oldY > (viewer.height / 2) && !fullScreenPresenterBool) presenterVid.move(presenter.x, presenter.y);
}

//PNCR: seems the below three functions can combine.
private function presenterVideoFullscreen(evnt:MouseEvent):void{
	PopUpManager.removePopUp(presenterVid);
	presenterVid.showCloseButton=false;
	presenterVid.setStyle("headerHeight", 0);
	fullScreenPresenterBool=true;
	presenterVid.videoDisp.removeEventListener(MouseEvent.DOUBLE_CLICK, presenterVideoFullscreen);
	applicationType::desktop{
		fullScreenPresenter=new FullScreenComp();
		fullScreenPresenter.videoComp=presenterVid;
		fullScreenPresenter.addEventListener(Event.CLOSING, onPresnterVideoToNormalState);
		fullScreenPresenter.title=presenterVid.title;
		fullScreenPresenter.open();
	}
}

private function onPresnterVideoToNormalState(evnt:Event):void{
	presenterVid.showCloseButton=true;
	presenterVid.clearStyle("headerHeight");
	fullScreenPresenterBool=false;
	presenterVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK, presenterVideoFullscreen);
	applicationType::desktop{
		fullScreenPresenter.removeEventListener(Event.CLOSING, onPresnterVideoToNormalState)
		fullScreenPresenter.removeAllChildren();
	}
	if (viewerVid && !fullScreenViewerBool){
		viewerVid.x=viewer.x;
		viewerVid.y=viewer.y;
	}
	if (chatWndw && !fullScreenChatBool){
		chatWndw.x=chat.x;
		chatWndw.y=chat.y;
	}
	PopUpManager.addPopUp(presenterVid, presenter);
	presenterVid.width=presenter.width;
	presenterVid.height=presenter.height;
	presenterVid.doubleClickEnabled=true;
}

private function viewerVideoFullscreen(evnt:MouseEvent):void{
	viewerVid.showCloseButton=false;
	viewerVid.setStyle("headerHeight", 0);
	fullScreenViewerBool=true;
	PopUpManager.removePopUp(viewerVid);
	viewerVid.videoDisp.removeEventListener(MouseEvent.DOUBLE_CLICK, viewerVideoFullscreen);
	applicationType::desktop{
		fullScreenViewer=new FullScreenComp();
		fullScreenViewer.videoComp=viewerVid;
		fullScreenViewer.title=viewerVid.title;
		fullScreenViewer.open();
		fullScreenViewer.addEventListener(Event.CLOSE, onViewerVideoToNormalState);
	}
}

private function onViewerVideoToNormalState(evnt:Event):void{
	if (viewerVid){
		viewerVid.showCloseButton=true;
		viewerVid.clearStyle("headerHeight");
		fullScreenViewerBool=false;
		applicationType::desktop{
			fullScreenViewer.removeEventListener(Event.CLOSING, onPresnterVideoToNormalState);
			fullScreenViewer.removeAllChildren();
		}
		viewerVid.videoDisp.addEventListener(MouseEvent.DOUBLE_CLICK, viewerVideoFullscreen);
		if (presenterVid && !fullScreenPresenterBool){
			presenterVid.x=presenter.x;
			presenterVid.y=presenter.y;
		}
		if (chatWndw && !fullScreenChatBool){
			chatWndw.x=chat.x;
			chatWndw.y=chat.y;
		}
		viewerVid.width=viewer.width;
		viewerVid.height=viewer.height;
		viewerVid.x=viewer.x;
		viewerVid.y=viewer.y;
		PopUpManager.addPopUp(viewerVid, viewer);
		viewerVid.doubleClickEnabled=true;
	}
}

private function chatWindowFullscreen(evnt:MouseEvent):void{
	//RTCR: Whether the commented code is needed or not?
	//chatWndw.title="";
	//chatWndw.closeButton.visible=false;	
	chatWndw.setStyle("headerHeight", 0);
	fullScreenChatBool=true;
	chatWndw.removeEventListener(MouseEvent.DOUBLE_CLICK, chatWindowFullscreen);
	PopUpManager.removePopUp(chatWndw);
	applicationType::desktop{
		fullScreenChat=new FullScreenComp();
		fullScreenChat.chatComp=chatWndw;
		fullScreenChat.title="Chat";
		fullScreenChat.open();
		fullScreenChat.addEventListener(Event.CLOSE, onChatWindowToNormalState);
	}
}

private function onChatWindowToNormalState(evnt:Event):void{
	if (chatWndw){
		//RTCR: Whether the commented code is needed or not?
		// chatWndw.title="Chat";
		//chatWndw.closeButton.visible=true;
		// chatWndw.clearStyle("headerHeight");
		fullScreenChatBool=false;
		applicationType::desktop{
			//CLOSING method is not available for web.
			fullScreenChat.removeEventListener(Event.CLOSING, onChatWindowToNormalState);
			fullScreenChat.removeAllChildren();
		}
		chatWndw.addEventListener(MouseEvent.DOUBLE_CLICK, chatWindowFullscreen);
		if (presenterVid && !fullScreenPresenterBool){
			presenterVid.x=presenter.x;
			presenterVid.y=presenter.y;
		}
		if (viewerVid && !fullScreenViewerBool){
			viewerVid.x=viewer.x;
			viewerVid.y=viewer.y;
		}
		chatWndw.width=chat.width;
		chatWndw.height=chat.height;
		chatWndw.x=chat.x;
		chatWndw.y=chat.y;
		PopUpManager.addPopUp(chatWndw, chat);
		chatWndw.doubleClickEnabled=true;
	}
}

//PNCR: check whether the function is using or not
private function toFullscreen(evnt:MouseEvent):void{
	if (evnt.target == presenterVid){
	}
	else if (evnt.target == viewerVid){
	}
	else if (evnt.currentTarget == presenterVid){
		
	}
	
}

//PNCR: check whether the function is using or not
private function closePstrFSWndw(ev:KeyboardEvent):void{
	//RTCR: Whether the commented code is needed or not?
	/* if(ev.charCode==27){
	fullScreenPresenter.close();
	} */
}

//PNCR: check whether the function is using or not
private function closeVvrFSWndw(ev:KeyboardEvent):void{
	//RTCR: Whether the commented code is needed or not?
	/* if(ev.charCode==27){
	fullScreenViewer.close();
	} */
}

//PNCR: check whether the function is using or not
private function closeChatFSWndw(ev:KeyboardEvent):void{
	//RTCR: Whether the commented code is needed or not?
	/* if(ev.charCode==27){
	fullScreenChat.close();
	} */
}

//PNCR: check whether the function is using or not
private function wndslide(ev:SliderEvent):void{
	/*fullScreenPresenter.Videodisp.playheadTime=ev.value; */
}

private function seekBarValue(seekValue:Object):String{
	var time:Number=Number(seekValue) * 1000;
	var Hours:uint=time / (1000 * 60 * 60);
	var Minutes:uint=(time % (1000 * 60 * 60)) / (1000 * 60);
	var Seconds:uint=((time % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
	return Hours.toString() + ":" + Minutes.toString() + ":" + Seconds.toString();
}
//RTCR: Move following variable to topp
private var seekChangeValue:Number=-1;

public function seekChange(evnt:SliderEvent):void{
	var sliderObject:Slider=Slider(seekBar);
	//RTCR: Whether the commented code is needed or not?
	//if(seekChangeValue != sliderObject.values[evnt.thumbIndex]){
	if (stopButton.enabled){
		
		playHeadTime=Math.floor(sliderObject.values[evnt.thumbIndex] * 1000);
		//if seek to the end
		if ((playHeadTime / 1000) >= Math.floor(seekBar.maximum)){
			if (Log.isInfo()) log.info("In seekChange Play End- Timer Stopped");
			resetPlayer();
			return;
			
		}
		wbPlayer.isRestore=true;
		//RTCR: Whether the commented code is needed or not?
		/*timeVariable=Math.floor(evnt.value);	*/
		wbPlayer.clearWhiteBoard();
		if (!isCutLecturePopUp)
			seekBar.setThumbValueAt(evnt.thumbIndex, Math.floor(evnt.value));
		seekChangeValue=Math.floor(evnt.value);
		updateReferenceTime();
		//RTCR: Whether the commented code is needed or not?
		/* seekBar.value=Math.floor(evnt.value);
		playHeadTime=seekBar.value*1000; */
		wbPlayer.setContext(playHeadTime + 100);
		chatWndw.chatPlayer.updateChat(playHeadTime);
		docComp.documentPlayer.setContext(playHeadTime);
		presenterVid.lblVideoMode.visible=false;
		viewerVid.lblVideoMode.visible=false;
		presenterVid.videoPlayer.setContext(playHeadTime, seekBar.value, "pVideo", presenterVid.videoDisp);
		viewerVid.videoPlayer.setContext(playHeadTime, seekBar.value, "vVideo", viewerVid.videoDisp);
		if (objDesktopPlayer != null){
			applicationType::web{
				objDesktopPlayer.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.videoDisp);
			}
			applicationType::desktop{
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.desktopPlaybackComp.videoDisp);
			}
		}
		pttPlayer.setContext(playHeadTime);
		seekUpdateCount=1;
		//RTCR: Whether the commented code is needed or not?
		//centalTimer.start();
		this.dispatchEvent(new SliderEvent("Notify seek change"));
		formatAndDisplayCentralTime();
	}
	else seekBar.value=0;
//}
//RTCR: Whether the commented code is needed or not?
//else if(seekChangeValue == sliderObject.values[evnt.thumbIndex])
//{
//	seekChangeValue = -1;
//}
	if (isLocalPlayback && presenterVid.videoPlayer.isVideoLoaded && (!presenterVid.videoPlayer.pausedCheck)) centalTimer.start();
	else{
		if (presenterVid.videoPlayer.isVideoLoaded) presenterVid.videoDisp.pause();
		if (viewerVid.videoPlayer.isVideoLoaded) viewerVid.videoDisp.pause();
	}
}

private function addPopupWndw(ev:MouseEvent):void{
	
	//VVCR: Store module names and other constant values in a global constast file and refer from there. 
	if (ev.currentTarget.label == "CHAT" && !chatBool){
		PopUpManager.addPopUp(chatWndw, chat);
		chatWndw.width=chat.width;
		chatWndw.height=chat.height;
		chatWndw.x=chat.x;
		chatWndw.y=viewer.y + viewer.height + 10;
		chatBool=true;
		chatBtn.enabled=false;
		if (presenterVid && !fullScreenPresenterBool){
			presenterVid.x=presenter.x;
			presenterVid.y=presenter.y;
		}
		if (viewerVid && !fullScreenViewerBool){
			viewerVid.x=viewer.x;
			viewerVid.y=presenter.y + presenter.height + 10;
		}
	}
	if (ev.currentTarget.label == "PRESENTER" && !PresenterBool){
		PopUpManager.addPopUp(presenterVid, presenter);
		presenterVid.x=presenter.x;
		presenterVid.y=presenter.y;
		PresenterBool=true;
		pvdoBtn.enabled=false;
		if (viewerVid && !fullScreenViewerBool){
			viewerVid.x=viewer.x;
			viewerVid.y=presenter.y + presenter.height + 10;
		}
		if (chat && !fullScreenChatBool){
			chatWndw.x=chat.x;
			chatWndw.y=viewer.y + viewer.height + 10;
		}
	}
	if (ev.currentTarget.label == "VIEWER" && !ViewerBool){
		PopUpManager.addPopUp(viewerVid, viewer);
		viewerVid.width=viewer.width;
		viewerVid.height=viewer.height;
		viewerVid.x=viewer.x;
		viewerVid.y=presenter.y + presenter.height + 10;
		ViewerBool=true;
		vvdoBtn.enabled=false;
		if (presenterVid && !fullScreenPresenterBool){
			presenterVid.x=presenter.x;
			presenterVid.y=presenter.y;
		}
		if (chat && !fullScreenChatBool){
			chatWndw.x=chat.x;
			chatWndw.y=viewer.y + viewer.height + 10;
		}
	}
}
//RTCR: Move following variable to topp
public var pop:VideoComp;

public function createDesktopPlayer():void{
	if (objDesktopPlayer == null){
		desktopBtn.enabled=false;
		applicationType::web{
			objDesktopPlayer=new DesktopPlayback();
		}
		applicationType::desktop{
			objDesktopPlayer=new DesktopPlaybackWindow();
			//open() method is not available for web.
			objDesktopPlayer.open(true);
		}
		objDesktopPlayer.addEventListener(Event.CLOSE, desktopClose);
	}
}
//RTCR: Move following variable to topp
private var isDesktopStoppedManually:Boolean=false;

private function desktopClose(event:Event):void{
	desktopBtn.enabled=true;
	if (objDesktopPlayer){
		applicationType::web{
			objDesktopPlayer.videoPlayer.netStreamVideo.close();
			objDesktopPlayer.videoPlayer=null;
		}
		applicationType::desktop{
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.close();
			objDesktopPlayer.desktopPlaybackComp.videoPlayer=null;
			//close() method is not available for web.
			objDesktopPlayer.close();
		}
		objDesktopPlayer=null;
		isDesktopStoppedManually=true;
	}
}

private function addSlideWndw():void{
	//RTCR: Whether the commented code is needed or not?
	/*docComp.addChild(docComp.slideWndw);*/
	docComp.baseContainer.percentWidth=100;
	slideBtn.enabled=false;
}

private function closePresenterWndw(ev:CloseEvent):void{
	PopUpManager.removePopUp(presenterVid);
	pvdoBtn.enabled=true;
	PresenterBool=false;
}

private function closeViewerWndw(ev:CloseEvent):void{
	PopUpManager.removePopUp(viewerVid);
	vvdoBtn.enabled=true;
	ViewerBool=false;
}

private function closeChatWndw(ev:CloseEvent):void{
	PopUpManager.removePopUp(chatWndw);
	chatBtn.enabled=true;
	chatBool=false;
}

public function endAppl():void{
	centalTimer.stop();
	if (Log.isInfo()) log.info("In endAppl - Timer stopped");
	
}

private function presenterFullWndwClose(ev:Event):void{
	PopUpManager.addPopUp(presenterVid, presenter);
	prstlbl.visible=false;
	//RTCR: Whether the commented code is needed or not?
	//fullScreenPresenter.Videodisp.removeEventListener(VideoEvent.PLAYHEAD_UPDATE,changevaluePstr);
	presenterVid.x=presenter.x;
	presenterVid.y=presenter.y;
	fullScreenPresenterBool=false;
	fullScreenPresenter=null;
}

private function viewerFullWndwClose(ev:Event):void{
	PopUpManager.addPopUp(viewerVid, viewer);
	viwrlbl.visible=false;
	viewerVid.width=viewer.width;
	viewerVid.height=viewer.height;
	viewerVid.x=viewer.x;
	viewerVid.y=presenterVid.y + presenterVid.height + 10;
	fullScreenViewerBool=false;
	fullScreenViewer=null;
}

private function chatFullWndwClose(ev:Event):void{
	PopUpManager.addPopUp(chatWndw, FlexGlobals.topLevelApplication.mainApp.chat);
	FlexGlobals.topLevelApplication.mainApp.chatWndw.width=chat.width;
	FlexGlobals.topLevelApplication.mainApp.chatWndw.height=chat.height;
	FlexGlobals.topLevelApplication.mainApp.chatWndw.x=chat.x;
	FlexGlobals.topLevelApplication.mainApp.chatWndw.y=viewerVid.y + viewerVid.height + 10;
	chatlbl.visible=false;
	fullScreenChatBool=false;
}
//RTCR: Move following variable to topp
public var tempCanWidth:Number=0;

private function onResizeWb(evt:ResizeEvent):void{
	if (wbPlayer && wbPlayer.whiteBoardSprite){
		wbCan.removeChild(whiteboardMask);
		wbCan.removeChild(wbPlayer.whiteBoardSprite);
		whiteboardMask=null;
		wbPlayer.whiteBoardSprite.width=wbCan.width;
		wbPlayer.whiteBoardSprite.height=wbCan.height;
		wbPlayer.whiteBoardSprite.drawBackground(0xffffff);
		wbCan.addChild(wbPlayer.whiteBoardSprite);
		whiteboardMask=new Canvas()
		whiteboardMask.graphics.beginFill(0xffffff, 1);
		whiteboardMask.graphics.drawRect(0, 0, wbCan.width, wbCan.height);
		wbCan.mask=whiteboardMask;
		wbCan.addChild(whiteboardMask);
		if (playerInitialized){
			wbPlayer.setContext(playHeadTime + 100);
		}
	}
}

public function playPausePlayer():void{
	if (playpauseButton.label == "Play" && (!stopButton.enabled)){
		pausedTimer=false;
		if (slideBtn.enabled) addSlideWndw();
		playpauseButton.label="Pause";
		if (!centalTimer.running){
			updateReferenceTime();
			centalTimer.start();
			if (Log.isInfo()) log.info("In playPausePlayer - Timer started");
		}
	}
	else if (playpauseButton.label == "Play"){
		presenterVid.videoPlayer.pausedCheck=false;
		viewerVid.videoPlayer.pausedCheck=false;
		if (objDesktopPlayer != null){
			applicationType::web{
				objDesktopPlayer.videoPlayer.pausedCheck=false;
			}
			applicationType::desktop{
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.pausedCheck=false;
			}
		}
		if (presenterVid.videoPlayer.videoToggled){
			if (!isLocalPlayback) presenterVid.videoPlayer.netStreamVideo.togglePause();
			else presenterVid.videoDisp.play();
			presenterVid.videoPlayer.videoToggled=false;
		}
		if (viewerVid.videoPlayer.videoToggled){
			if (!isLocalPlayback) viewerVid.videoPlayer.netStreamVideo.togglePause();
			else viewerVid.videoDisp.play();
			viewerVid.videoPlayer.videoToggled=false;
		}
		applicationType::web{
			if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.videoToggled){
				objDesktopPlayer.videoPlayer.netStreamVideo.togglePause();
				objDesktopPlayer.videoPlayer.videoToggled=false;
			}
		}
		applicationType::desktop{
			if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoToggled){
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.togglePause();
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoToggled=false;
			}
		}
		pausedTimer=false;
		playpauseButton.label="Pause";
		if (!centalTimer.running){
			updateReferenceTime();
			centalTimer.start();
			if (Log.isInfo()) log.info("In playPausePlayer 2 - Timer started");
		}
		if (!isLocalPlayback){
			if (viewerVid.videoPlayer.isStreamReady) viewerVid.videoPlayer.isVideoLoaded=true;
			if (presenterVid.videoPlayer.isStreamReady) presenterVid.videoPlayer.isVideoLoaded=true;
			applicationType::web{
				if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.isStreamReady) objDesktopPlayer.videoPlayer.isVideoLoaded=true;
			}
			applicationType::desktop{
				if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady) objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded=true;
			}
		}
		else{ //Need change lvn
			if (viewerVid.videoDisp.source != "" && viewerVid.videoDisp.source != null) viewerVid.videoPlayer.isVideoLoaded=true;
			if (presenterVid.videoDisp.source != "" && presenterVid.videoDisp.source != null) presenterVid.videoPlayer.isVideoLoaded=true;
		}
		setTimeout(clearVideo, 100);
	}
	else{
		presenterVid.videoPlayer.pausedCheck=true;
		viewerVid.videoPlayer.pausedCheck=true;
		if (objDesktopPlayer != null){
			applicationType::web{
				objDesktopPlayer.videoPlayer.pausedCheck=true;
			}
			applicationType::desktop{
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.pausedCheck=true;
			}
		}
		pausedTimer=true;
		playpauseButton.label="Play";
		centalTimer.stop();
		if (Log.isInfo()) log.info("In playPausePlayer - Timer stopped");
		if (!isLocalPlayback){
			if (presenterVid.videoPlayer.isStreamReady || presenterVid.videoPlayer.isVideoLoaded){
				presenterVid.videoPlayer.netStreamVideo.pause();
				presenterVid.videoPlayer.videoToggled=true;
			}
			if (viewerVid.videoPlayer.isStreamReady || viewerVid.videoPlayer.isVideoLoaded){
				viewerVid.videoPlayer.netStreamVideo.pause();
				viewerVid.videoPlayer.videoToggled=true;
			}
		}
		else{
			if (presenterVid.videoPlayer.isVideoLoaded){
				presenterVid.videoDisp.pause();
				presenterVid.videoPlayer.videoToggled=true;
			}
			if (viewerVid.videoPlayer.isVideoLoaded){
				viewerVid.videoDisp.pause();
				viewerVid.videoPlayer.videoToggled=true;
			}
		}
		applicationType::web{
			if (objDesktopPlayer != null && (objDesktopPlayer.videoPlayer.isStreamReady || objDesktopPlayer.videoPlayer.isVideoLoaded)){
				objDesktopPlayer.videoPlayer.netStreamVideo.pause();
				objDesktopPlayer.videoPlayer.videoToggled=true;
			}
		}
		applicationType::desktop{
			if (objDesktopPlayer != null && (objDesktopPlayer.desktopPlaybackComp.videoPlayer.isStreamReady || objDesktopPlayer.desktopPlaybackComp.videoPlayer.isVideoLoaded)){
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.pause();
				objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoToggled=true;
			}
		}
	}
}

private function clearVideo():void{
	if (presenterVid.videoPlayer.currentVideoEndTime < playHeadTime){
		presenterVid.videoDisp.mx_internal::videoPlayer.clear();
		if (!isLocalPlayback) presenterVid.videoPlayer.netStreamVideo.close();
		else presenterVid.videoDisp.source="";
	}
	if (viewerVid.videoPlayer.currentVideoEndTime < playHeadTime){
		viewerVid.videoDisp.mx_internal::videoPlayer.clear();
		if (!isLocalPlayback) viewerVid.videoPlayer.netStreamVideo.close();
		else presenterVid.videoDisp.source != ""
	}
	applicationType::web{
		if (objDesktopPlayer != null && objDesktopPlayer.videoPlayer.currentVideoEndTime < playHeadTime){
			objDesktopPlayer.videoDisp.mx_internal::videoPlayer.clear();
			objDesktopPlayer.videoPlayer.netStreamVideo.close();
		}
	}
	applicationType::desktop{
		if (objDesktopPlayer != null && objDesktopPlayer.desktopPlaybackComp.videoPlayer.currentVideoEndTime < playHeadTime){
			objDesktopPlayer.desktopPlaybackComp.videoDisp.mx_internal::videoPlayer.clear();
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.netStreamVideo.close();
		}
	}
	if (playpauseButton.label != "Pause"){
		if (!centalTimer.running){
			updateReferenceTime();
			centalTimer.start();
			if (Log.isInfo()) log.info("In clearVideo- Timer Started");
		}
	}
}

public function closePlayback():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.playBackActiveflag=0
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.player.close();
}

public function stopPlayBack():void{
	presenterVid.videoPlayer.pausedCheck=false;
	viewerVid.videoPlayer.pausedCheck=false;
	applicationType::web{
		if (objDesktopPlayer != null){
			objDesktopPlayer.videoPlayer.pausedCheck=false;
			objDesktopPlayer.videoPlayer.videoToggled=false;
		}
	}
	applicationType::desktop{
		if (objDesktopPlayer != null){
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.pausedCheck=false;
			objDesktopPlayer.desktopPlaybackComp.videoPlayer.videoToggled=false;
		}
	}
	presenterVid.videoPlayer.videoToggled=false;
	viewerVid.videoPlayer.videoToggled=false;
	
	pausedTimer=false;
	if (!stopButton.enabled){
		playpauseButton.label="Pause";
		if (!centalTimer.running){
			updateReferenceTime();
			centalTimer.start();
			if (Log.isInfo()) log.info("In stopPalayBack- Timer Started");
		}
	}
	else{
		if (playBackBufferingMessageComp.source != null) playBackBufferingMessageComp.unloadAndStop();
		resetPlayer();
	}
	diffSeekValuePresenter=0;
	diffSeekValueViewer=0;
}

private function btn_keyBoardStroke(event:KeyboardEvent):void{
	if ((event.keyCode == Keyboard.ENTER) || (event.keyCode == Keyboard.SPACE)){
		if (event.target.id == "playpauseButton"){
			playPausePlayer();
			event.stopImmediatePropagation();
			return;
		}
		if (event.target.id == "stopButton"){
			stopPlayBack();
			event.stopImmediatePropagation();
			return;
		}
		if (event.target.id == "closeWndowButton"){
			closePlayback();
			event.stopImmediatePropagation();
			return;
		}
	}
}
