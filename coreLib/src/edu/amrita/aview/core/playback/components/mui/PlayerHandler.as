////////////////////////////////////////////////////////////////////////////////
//
// Copyright  � 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: PlayerHandler.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:The Multi User Interaction Playback Module the entire session
 * which has already recorded have to playback again .This module contain videos,
 * chat,document sharing and whitboard playback again like in live session .
 * This file maintain the code part of this module
 */
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.common.FileLoaderManager;
import edu.amrita.aview.core.common.Events.FileLoadedEvent;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents.OnSlideChangedEvent;
import edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents.OnSlideClickEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.playback.ConsolidateXmlBuilder;
import edu.amrita.aview.core.playback.ContextSetter;
import edu.amrita.aview.core.playback.DocumentPointerPlayer;
import edu.amrita.aview.core.playback.PttPlayer;
import edu.amrita.aview.core.playback.VodCustomClient;
import edu.amrita.aview.core.playback.WbPlayer;
import edu.amrita.aview.core.playback.WhiteBoardPointerPlayer;
import edu.amrita.aview.core.playback.components.mui.DesktopSharing;
import edu.amrita.aview.core.playback.components.mui.VideoPanel;
import edu.amrita.aview.core.playback.editing.scripts.CloseFileHandler;
import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
import edu.amrita.aview.core.playback.player.MediaEvents.*;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.SoundTransform;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CollectionEvent;
import mx.events.ResizeEvent;
import mx.events.SliderEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

import spark.components.BorderContainer;
import spark.components.Button;
import spark.components.Label;

/**
 * This variable holds the reference to desktop sharing playback window.
 */
private var desktopComp:DesktopSharing=new DesktopSharing();
/**
 * Object of whiteboard player.
 */
public var wbPlayer:WbPlayer;
/**
 * Canvas tha will added to whiteboard drawing area which prevents showing 
 * parts of drawing appearing aotside the drawing area.
 */
private var whiteboardMask:Canvas;
/**
 * The url of fms where presenter videos are stored.
 */
public var presenterFMSUrl:String;	
/**
 * The url of fms where destop sharing  recorded videos are stored.
 */
public var desktopFMSUrl:String;
/**
 * The url of fms where  viewer's recorded videos are stored.
 */
public var viewerFMSUrl:String;

/**
 * Connection object for Presenter's video Server
 */
private var presenterMediaConnection:MediaServerConnection;
/**
 * Connection object for Viewer's video Server
 */
private var viewerMediaConnection:MediaServerConnection;
/**
 * Connection object for desktop's video Server
 */
private var desktopMediaConnection:MediaServerConnection;

/**
 * The sub folder path of the videos in the VOD  media folder.
 */
public var videoFilePath:String;
/**
 * The url for content server where the xml files and  documents are present.
 */
public var contentUrl:String;
/**
 * The sub folder path for the content files.
 */
public var contentFilePath:String;
/**
 * The timer which updates the player play head time.
 */
private var centralTimer:Timer;
/**
 * This variable keep the  id for the setTimeOut function called  in the creation complete.
 */
private var playerUIInitialTimeOut:uint
/**
 * The logging variavle
 */
private var log:ILogger
private var diffSeekValuePresenter:int = 0;
private var diffSeekValueViewer:int = 0;
/**
 * The overa all player volume.
 */
private var playerVolume:Number;

[Bindable]
private var slideList:ArrayCollection=new ArrayCollection();
/**
 * This variable set to true when the xml files get loaded into memory.
 */
private var playerInitialized:Boolean=false;
/**
 * This current play head time of the player.
 */
public var playHeadTime:Number
public var editTime:Label=new Label();
public var editTotalTime:Label=new Label();
/*private var portTesterDesktopTimeoutId:uint;
private var portTesterTimeoutId:uint;*/
/**
 * Store the time when the cetral time starts or restarts.
 */
private var referanceTime:Number;
/**
 * This is a time snap taken in every 10 milliseconds(on the central timer interval).
 * When it reaches 100 milliseconds the playhead time will be updated.
 */
private var currentTimeOffset:uint;
/**
 * This is is used to load all the xml files to local.
 */
public var fileLoaderManager:FileLoaderManager;
/**
 * This is the class object used to obatint the current player context when user seeks the player.
 */
private var contextSetter:ContextSetter;
/**
 * This builds the consolidate xml baed on time  for the player from the individual xml files
 */
private var consolidateXmlBuilder:ConsolidateXmlBuilder;
/**
 * This variable decide whether the payer plays using locally available files.
 */
private var isLocalPlayback:Boolean=false;
/**
 * Refer for pointer sharing in Whiteboard
 */	
private var wbPointerPlayer:WhiteBoardPointerPlayer;
/**
 * For refereing the push to talk class 
 */	
private var pttPlayer:PttPlayer;
/**
 *For refering pointer sharing in Document
 */	
private var docPointerPlayer:DocumentPointerPlayer;
/**
 * The collection viewers video which is already have in interaction 
 */	
private var activeViewers:Array=new Array();
/**
 * The over alla collection of viewer's videos
 */	
private var viewerVideoPlayers:Array=new Array();
/**
 * The object which is refer the presenter's video container 
 */	
private var presenterVideoPlayerObject:Object
/**
 * The object which is refer the presenter's video container 
 */	
private var desktopVideoPlayerObject:Object
/**
 * Video Container  height
 */	
private var objHeight:Number=0;
/**
 * Video Container  Width
 */	
private var objWidth:Number=0;
/**
 * The total count of resize events occured in an component
 */	
private var resizeCount:Number=0;
/**
 * The width which is before the container got resize 
 */	
private var previousWidth:Number=0;
/**
 * To check whether the  viewer's video source has changed or not after seek change
 * @default is false means tot changed
 */	
private var isNewViewerVideoWhileSeeking:Boolean=false;
/**
 * To check whether the presenter's video source has  been changed or not after seek change
 *  @default is false means tot changed
 */	
private var isNewPresenterVideoWhileSeeking:Boolean=false;
/**
 * To check whether the  Desktop video source  has been changed or not after seek change
 *  @default is false means tot changed
 */	
private var isNewDesktopVideoWhileSeeking:Boolean=false;
/**
 * 
 */	
private var viewerVideoTagArray:Array
/**
 * 
 */	
private var presenterVideoTagArray:Array
/**
 * 
 */	
private var deskTopVideoTagArrayconvetTime:Array
/**
 * 
 */	
private var deskTopVideoTagArray:Array
/**
 * To check whether the  Presenters FMS connection has established or not 
 *  @default is false means not established
 */	
private var isPresenterFMSConnected:Boolean=false;
/**
 * To check whether the  Viewer's FMS connection has established or not 
 *  @default is false means not established
 */	
private var isViewerFMSConnected:Boolean=false;
/**
 * To check whether the  Desktop FMS connection has established or not 
 *  @default is false means not established
 */	
private var isDesktopFMSConnected:Boolean=false
/**
 *  To check whether the playback in  editing mode or not 
 *  @default is false means not in Editing mode
 */	
public var editingActive:Boolean = false;
/**
 * To check whether the  editing pop up is initilized  or not 
 * @default is false means not initilized
 */	
private var isCutLecturePopUp:Boolean = false;
/**
 * The default seek value after seek change is -1
 */	
private var seekChangeValue:Number = -1;
/**
 * @private
 * Initilize all modules for play back
 * @return void
 */
private function playerInitilize():void
{
	log=Log.getLogger("aview.modules.RecordingPlayback.Playback.MUIComponents.player");
	PopUpManager.addPopUp(desktopComp,this);	
	mainSeek.seekbar.dataTipFormatFunction=seekBarValue;	
	playerUIInitialTimeOut=setTimeout(loadRecordedFiles,200);	
	desktopComp.x=this.width-desktopComp.width+20;
	desktopComp.y=15;
	desktopComp.defaultPosition=desktopComp.x;
	
}

/**
 * Function for changing volume for active viewers.
 */
private function changeVolumeForViewerVideos():void
{
	for(var index in viewerVideoPlayers) 
	{
		changeVideoVolume(viewerVideoPlayers[index].player,playerVolume);
	}
}
/**
 * Function called when user changes palyer volume  or mute the player.
 * This will changes the volume for all active video pannels.
 */
private function mainSeek_OnVolumeChangedEventHandler(event:OnVolumeChangedEvent):void
{
	 playerVolume=(event.currentVolume)/10;
	 if(presenterVideoPlayerObject)
	 {
		 changeVideoVolume(presenterVideoPlayerObject.player,playerVolume);
	 }
	 changeVolumeForViewerVideos();
	
	
}
/**
 * Function called when user select play , pause or stop oprion in the player.
 */
private function mainSeek_onMediaControlerEventHandler(event:onMediaControlerEvent):void
{
	if(Log.isDebug()) log.debug("In mainSeek_onMediaControlerEventHandler : Value is - " +event.operation);
	
	//VVCR: Try to use switch case here
	if(event.operation == "Play")
	{	
		updateReferenceTime();
		centralTimer.start();
		if(presenterVideoPlayerObject)
		{
			presenterVideoPlayerObject.player.resumePlaying();
		}
		if(desktopVideoPlayerObject)
		{
			desktopVideoPlayerObject.player.resumePlaying();
		}
		resumeAllViewerStreams()
	}
	else if(event.operation == "Pause")
	{
		centralTimer.stop()
		if(presenterVideoPlayerObject)
		{
			presenterVideoPlayerObject.player.pausePlaying();
		}
		if(desktopVideoPlayerObject)
		{
			desktopVideoPlayerObject.player.pausePlaying();
		}
		pauseAllViewerStreams();
	}
	else if(event.operation == "Stop")
	{
		resetPlayer();
		mainSeek.isPlay=false;
	}
}
/**
 * Function called when user select slide from the slide list option.
 */
public function slidelist_OnSlideClickEventHandler(event:OnSlideClickEvent):void
{
	mainSeek.seekbar.value=event.slideobject.ctime/1000;				
	var slideTimeRounded:int=Math.floor(event.slideobject.ctime/100);		
	playHeadTime = (slideTimeRounded*100);
	currentTimeOffset=0;
	updateReferenceTime();
	if(!centralTimer.running)
	{
		centralTimer.start();
		if(Log.isInfo()) log.info("In onSlideSelected- Timer Started");	
	}
	chatWndw.chatPlayer.updateChat(playHeadTime);
	wbPlayer.setContext(event.slideobject.ctime);
	docComp.documentPlayer.setContext(event.slideobject.ctime);
	/*pttPlayer.setContext(playHeadTime);*/
	formatAndDisplayCentralTime();
	seekPresenterVideo(playHeadTime);
	seekViewerVideos(playHeadTime);
	seekDesktopVideo(playHeadTime);
}

/**
 * 
 * @param event
 * 
 */
protected function viewerVideoList_collectionChangeHandler(event:CollectionEvent):void
{
	desktopComp.move(this.width-desktopComp.width,0);
	
}


//VVCR: Please consider removing,if not used
/**
 * 
 * @param event
 * 
 */
protected function tools_mouseOverHandler(event:MouseEvent):void
{
	//tools.alpha=1;				
	// TODO Auto-generated method stub
	
}			

/**
 * 
 * @param event
 * 
 */
protected function playercontrol1_mouseOverHandler(event:MouseEvent):void
{
	// TODO Auto-generated method stub
	mainSeek.alpha=1;
}
//GTMCR::change the function name
/**
 * @protected
 * Handling the seek bar visbility while mouse over
 * @param event of MouseEvent
 * @return void
 */
//GTMCR::change the function name
/**
 * @protected
 * Handling the seek bar visbility while mouse over
 * @param event of MouseEvent
 * @return void
 */
protected function mainSeek_mouseOutHandler(event:MouseEvent):void
{
	// TODO Auto-generated method stub
	mainSeek.alpha=.5;
}
//GTMCR::change the function name 
/**
 * @protected
 * Handling the position of desktop sahring playback window
 * while resizing
 * @param event of ResizeEvent
 * @return void
 */
protected function playerBaseCon_resizeHandler(event:ResizeEvent):void
{
	// TODO Auto-generated method stub
	desktopComp.x=this.width-desktopComp.width+20	
	desktopComp.defaultPosition=desktopComp.x;
}



/**
 * This function loads the xml files from 
 */
/**
 * @private
 * For loading all recoreded contents for play back
 * 
 * @return void
 */
private function loadRecordedFiles():void
{
	clearTimeout(playerUIInitialTimeOut);
	fileLoaderManager=new FileLoaderManager(contentUrl+contentFilePath)  
	fileLoaderManager.addEventListener(FileLoadedEvent.ALL_LOADED,onAllFilesLoaded);
	fileLoaderManager.addEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onFileLoadError);
	fileLoaderManager.loadRecordedFiles();   			
	viewStack.selectedIndex=1;
	
}
/**
 * @private
 * Adding Document component to Play back
 * window
 * 
 */
private function setDocComp():void
{	
	docComp.documentPlayer.setDocPath(contentUrl+contentFilePath);
	docComp.documentPlayer.addEventListener(AviewPlayerEvent.DOC_TAB_CHANGED,onModuleChangeEvent);
	docComp.documentPlayer.addEventListener(AviewPlayerEvent.WB_TAB_CHANGED,onModuleChangeEvent);	
	docComp.addEventListener(AviewPlayerEvent.SlideSlected,onSlideSelected);
	docComp.p2fLoader.visible=true;
}
/**
 * @private
 * Adding whiteboard component to Play back window
 * 
 * @return void
 */
private function createWbComp():void
{
	wbPlayer=new WbPlayer();
	wbPlayer.wbSprite.width=wbCan.width	;
	wbPlayer.wbSprite.height=wbCan.height;
	wbPlayer.addEventListener(AviewPlayerEvent.WB_TAB_CHANGED,onModuleChangeEvent);
	wbPlayer.addEventListener(AviewPlayerEvent.WB_PAGE_CHANGED,onModuleChangeEvent);
	wbPlayer.addEventListener(AviewPlayerEvent.WB_CLEARED,onModuleChangeEvent);
	wbPlayer.wbSprite.drawBackground(0xffffff);
	wbCan.addElement(wbPlayer.wbSprite);
	whiteboardMask=new Canvas;
	whiteboardMask.graphics.beginFill(0xffffff, 1);
	whiteboardMask.graphics.drawRect(0, 0, wbCan.width, wbCan.height);
	wbCan.mask=whiteboardMask;
	wbCan.addElement(whiteboardMask);             
	
}
/**
 * @private
 * Adding Chat component to Play back
 * window
 * 
 */
private function setChatComp():void
{	
	chatWndw.chatPlayer.setUiReference(chatWndw.chatbox);
}
//GTMCR::give the proper function name, mention all parameter
/**
 * @public
 * This function act as data setter of play back
 * @param presenterFMSUrl of String
 * @param viewerFMSUrl of String
 * @return void
 */
public function setValues(presenterFMSUrl:String,viewerFMSUrl:String,videoFilePath:String,contentUrl:String,contentFilePath:String,lectureInfo:String,desktopFMSUrl:String,islocalPlayback:Boolean):void
{
	this.presenterFMSUrl=presenterFMSUrl;
	this.desktopFMSUrl = desktopFMSUrl;
	this.viewerFMSUrl=viewerFMSUrl;
	this.videoFilePath=videoFilePath;
	this.contentUrl=contentUrl;
	this.contentFilePath=contentFilePath;
	ClassroomContext.RECORDED_CONTENT_FILE_PATH = contentFilePath;
	ClassroomContext.RECORDED_CONTENT_URL = contentUrl;
	this.isLocalPlayback=islocalPlayback;
}
//GMTCR::change the parameter evnt to event
/**
 * @private
 * This function invoked after all content loading
 * succesfully done
 * @param evnt of FileLoadedEvent
 * @return void
 */
private function onAllFilesLoaded(evnt:FileLoadedEvent):void
{
	if(Log.isDebug()) log.debug(" All files for playing th lecture are loaded");
	fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED,onAllFilesLoaded);
	fileLoaderManager.removeEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onFileLoadError);
	contextSetter=new ContextSetter(fileLoaderManager);
	consolidateXmlBuilder=new ConsolidateXmlBuilder(fileLoaderManager,contentUrl+contentFilePath);  
	consolidateXmlBuilder.addEventListener(AviewPlayerEvent.CONSOLIDATE_XML_CREATED,initializePlayers);
	consolidateXmlBuilder.buildConsilidateXml();
}
/**
 *  @private
 * This function will invoke have any error occured
 * in file loading Process 
 * @param evnt
 * 
 */
private function onFileLoadError(evnt:FileLoadedEvent):void
{
	if(Log.isDebug()) log.debug(" Failed to load files for playing th lecture.");
	Alert.show("Error Loading the Lecture","Playback Module",4,this);
	this.dispatchEvent(new Event("File error"));
	if(FlexGlobals.topLevelApplication.currentState!="LoginState")
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.editingActiveflag = 0;
	}
	fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED,onAllFilesLoaded);
	fileLoaderManager.removeEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onFileLoadError);
} 

/**
 * @private
 * This function will invoke while user trying to close playback  
 * The viewers video streaming should stop before closing
 * 
 */
private function closeViewerVideoPlayers():void
{
	for(var index in viewerVideoPlayers) 
	{
		viewerVideoPlayers[index].player.stopPlaying();
		delete viewerVideoPlayers[index];
	}
}
//GTMCR::is this function needed?
/**
 * @public
 * For Closing the PlayBack window.
 * 
 * @return void
 */
public function closePlayer():void
{
	centralTimer.removeEventListener(TimerEvent.TIMER,updateCentralSeekBar)
	if(centralTimer && centralTimer.running)
		centralTimer.stop();
	if(Log.isInfo()) log.info("In closePlayer- Timer Storped");
	closeViewerVideoPlayers();
	if(presenterVideoPlayerObject)
	{
		presenterVideoPlayerObject.player.stopPlaying();
		presenterVideoPlayerObject=null
	}
	
	if(desktopVideoPlayerObject)
	{
		desktopVideoPlayerObject.player.stopPlaying();
		desktopVideoPlayerObject=null
	}
	
	//Close document player
	docComp.documentPlayer.closeDocumentPlayer();
	docComp.documentPlayer=null;
	docComp=null;
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.killPlayback();
	}
}

/**
 * @public
 * For maintaing the resolution of Document playback component
 * @param obj
 * @return void
 */
public function getResolution(obj:DisplayObjectContainer):void
{
	if(resizeCount == 0)
	{
		previousWidth = objWidth;
		resizeCount = resizeCount + 1;
	}
	var tempWidth:Number;
	
	objHeight=obj.height;
	tempWidth=(objHeight / 3) * 4;
	if (tempWidth >= obj.width)
	{
		objWidth=obj.width;
		objHeight=(objWidth / 4) * 3;
	}
	else
	{
		objWidth=tempWidth;
	}  
}       		

//GTMCR:: Please check the spelling in the function description 
/**
 * @private
 * Starting the cnetrel timer
 * Based on this timer,playback session will sync with
 * all modules
 * 
 * @return void
 */
private function startCentralTimer():void
{
	if((isPresenterFMSConnected || isViewerFMSConnected || isDesktopFMSConnected)||  isLocalPlayback)
	{
		centralTimer=new Timer(10)
		centralTimer.addEventListener(TimerEvent.TIMER,updateCentralSeekBar)
		playHeadTime=0;
		var date:Date=new Date();
		referanceTime=date.time;
		centralTimer.start(); 
		if(Log.isInfo()) log.info("In startCentralTimer- Timer Started");
		playLecture();
		wbPlayer.playWb(0);
		docComp.documentPlayer.playDocument(0);
		chatWndw.chatPlayer.playChat(0);		
		this.dispatchEvent(new Event("PlayerInitialized"));
	}
}          


/**
 * @private
 * Updating and formating  the centeral Time
 * 
 * @return void
 */
private function formatAndDisplayCentralTime():void
{
	
	var Hours:uint= playHeadTime / (1000*60*60)
	var Minutes:uint = (playHeadTime % (1000*60*60)) / (1000*60);
	var Seconds:uint = ((playHeadTime % (1000*60*60)) % (1000*60)) / 1000;
	mainSeek.centeralTime=Hours.toString()+":"+Minutes.toString()+":"+Seconds.toString()  
	if(editingActive)						
	{	
		var editMinutes:uint= Minutes+(Hours*60);						
		editTime.text=editMinutes.toString()+":"+Seconds.toString();
	}	
	
}
/**
 * @private
 * For Updating refrence time 
 * 
 * @return void
 */
private function updateReferenceTime():void
{
	var date:Date=new Date()
	referanceTime=date.time-playHeadTime-currentTimeOffset;
}

/**
 * 
 * 
 */
//VVCR: Please consider removing,if not used
private function stopPlayingViewerVideos():void
{
	/*for(var index:int = viewerVideoPlayers.length-1 ;index>-1; index--) 
	{		
		if(viewerVideoPlayers[index].player.netStreamVideo && !isLocalPlayback)
			viewerVideoPlayers[index].player.netStreamVideo.close();
		viewerVideoPlayers[index].player.currentVideoSource="";
		viewerVideoPlayers[index].player.previousEtime = 0;
		viewerVideoPlayers[index].player.previousStime = 0;
		
		if(viewerVideoPlayers[index].player.isVideoLoaded && !isLocalPlayback)
		{
			viewerVideoPlayers[index].player.isStreamReady=false
			viewerVideoPlayers[index].player.isVideoLoaded=false;
			viewerVideoPlayers[index].player.clearVideo()
		}
		removeReferences(viewerVideoPlayers[index].player);
		viewerVideoPlayers[index].player=null;
		viewerVideoPlayers.splice(index,1)
	}*/
}
/**
 * 
 * @param palyerObj
 * @param container
 * 
 */
private function stopPlayingVideo(palyerObj:VideoPanel,container:Object):void
{
	//palyerObj.stopPlaying();
	palyerObj.removeEventListener(AviewPlayerEvent.STREAM_READY,manageStreamPlaying);
	palyerObj.removeEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE,manageStreamPlaying);
	palyerObj.removeEventListener(AviewPlayerEvent.STREAM_NOT_READY,manageStreamPlaying);
	removeVideoPlayer(container)
	palyerObj=null;
}

/**
 * @public
 * For refering the video start time and end time and its  convert to time format 
 * @param time of Number
 * @return  Number 
 * 
 */
private function convetTime(time:Number):Number
{
	time=Math.floor((time/100))
	return time=time*100
}
/**
 * @private
 * For return the video Container object
 * @param container
 * @return 
 * 
 */
private function containsVideo(container:Object):Boolean
{
	var containsVideo:Boolean=false;
	for(var i:uint=0;i<container.numElements;i++)
	{
		if(container.getElementAt(i) is VideoPanel)
		{
			containsVideo=true;
			break;
		}
	}
	return containsVideo;
	
}
/**
 * @private
 * For returning the videoplayer object from given container
 * @param container of Object
 * @return videoPanel
 * 
 */
private function getVideoPlayer(container:Object):VideoPanel
{
	var videoPannel:VideoPanel
	for(var i:uint=0;i<container.numElements;i++)
	{
		if(container.getElementAt(i) is VideoPanel)
		{
			videoPannel=VideoPanel(container.getElementAt(i));
			break;
		}
	}
	return videoPannel;
}
/**
 * @private
 * For removing the video player object from given container
 * @param container
 * 
 */
private function removeVideoPlayer(container:Object):void
{
	var videoPannel:VideoPanel
	for(var i:uint=0;i<container.numElements;i++)
	{
		if(container.getElementAt(i) is VideoPanel)
		{
			container.removeElementAt(i);
			break;
		}
	}
	
}

/**
 * @private
 * for swaping the video in to main video panel 
 * @param evnt
 */
private function swapVideos(evnt:MouseEvent):void
{
	
	if(containsVideo(evnt.currentTarget) && !(evnt.target is Button))
	{
		var swappingVideoPannel:VideoPanel=getVideoPlayer(evnt.currentTarget)
		swappingVideoPannel.showMuteButton=false;
		swappingVideoPannel.showPlayerControlComp=true;
		viewerVideosPannel.title=swappingVideoPannel.videoDisplayName;
		var mainViewerVideoPannel:VideoPanel=getVideoPlayer(mainVideoContainer);
		mainViewerVideoPannel.showMuteButton=true;
		mainViewerVideoPannel.showPlayerControlComp=false;
		removeVideoPlayer(mainVideoContainer)
		removeVideoPlayer(evnt.currentTarget)
		mainVideoContainer.addElement(swappingVideoPannel);
		evnt.currentTarget.addElement(mainViewerVideoPannel);
		mainViewerVideoPannel.invalidateProperties();
	}
}

/**
 * @private
 * For getting the viewer's Video container object
 * @param index
 * @return 
 * 
 */
private function getViewerVideoContainerFromIndex(index:int):BorderContainer
{
	
	if(index== 0)
	{	
		return mainVideoContainer;
	}
	else if(index== 1)
	{	
		return viewerVideoContainer1;
	}
	else if(index== 2)
	{
		return viewerVideoContainer2;
	}
	else if(index== 3)
	{
		return viewerVideoContainer3;
	}
	else if(index== 4)
	{
		return viewerVideoContainer4;
	}
	else if(index== 5)
	{
		return viewerVideoContainer5;
	}
	else if(index== 6)
	{
		return viewerVideoContainer6;
	}
	else if(index== 7)
	{
		return viewerVideoContainer7;
	}
	// This is a dummy return to avoid compilation error
	return null;
}

/**
 * @private 
 * For getting the index of viewer's Video container object
 * @param videoPanel
 * @return  Int
 * 
 */
private function getVideoDispalyContainerIndex(videoPanel:VideoPanel):int
{
	
	if(mainVideoContainer.contains(videoPanel))
	{	
		return 0;
	}
	else if(viewerVideoContainer1.contains(videoPanel))
	{	
		return 1;
	}
	else if(viewerVideoContainer2.contains(videoPanel))
	{	
		return 2;
	}
	else if(viewerVideoContainer3.contains(videoPanel))
	{	
		return 3;
	}
	else if(viewerVideoContainer4.contains(videoPanel))
	{	
		return 4;
	}
	else if(viewerVideoContainer5.contains(videoPanel))
	{	
		return 5;
	}
	else if(viewerVideoContainer6.contains(videoPanel))
	{	
		return 6;
	}
	else if(viewerVideoContainer7.contains(videoPanel))
	{	
		return 7;
	}
	// This is a dummy return to avoid compilation error
	return null;
}

/**
 * @private
 * For managing the collection of Viewer's video
 * @param index
 * 
 */
private function manageVideoArray(index:Number):void
{
	//Get the current video dispplay
	var videoDisplayContainerIndex:int=getVideoDispalyContainerIndex(viewerVideoPlayers[index].player);
		//ToDo:::call code to release all reference for the current vidoeplayer.
	
	
	
	var currentVideoDisplayContainer:BorderContainer=getViewerVideoContainerFromIndex(videoDisplayContainerIndex);
	var nextVideoDisplayContainer:BorderContainer
	stopPlayingVideo(viewerVideoPlayers[index].player,currentVideoDisplayContainer)
	viewerVideoPlayers.splice(index,1);
	var nextVideoPannel:VideoPanel;
		
	//Shift the video display	
	for(var i:int=videoDisplayContainerIndex+1;i<=viewerVideoPlayers.length;i++)
	{
		
		nextVideoDisplayContainer=getViewerVideoContainerFromIndex(i);
		nextVideoPannel=getVideoPlayer(nextVideoDisplayContainer);
		removeVideoPlayer(nextVideoDisplayContainer);
		currentVideoDisplayContainer.addElement(nextVideoPannel);
		currentVideoDisplayContainer=nextVideoDisplayContainer;
		if(i==1)
		{
			nextVideoPannel.showMuteButton=false;
			nextVideoPannel.showPlayerControlComp=true;
			viewerVideosPannel.title=nextVideoPannel.videoDisplayName;
		}
		
	}
}
/**
 * @private
 * 
 * @param playheadTime
 * 
 */
//VVCR: Please remove the function, if not used.
private function playViewers(playheadTime:uint):void
{
	
	/*for(var index:int = viewerVideoPlayers.length-1 ;index>-1; index--) 
	{
		if(convetTime((viewerVideoPlayers[index].videoTag).@etime)==playheadTime)
		{
			manageVideoArray(index);
			
		}
		
	}
	
	for each(var video:XML in viewerVideoArray) 
	{
		if(convetTime(video.@stime) == playheadTime)
		{
			//centalTimer.stop();
 			var viewerVideoInfo:Object=new Object();
			viewerVideoInfo.videoTag=video;			
			var videoPlayer:VideoPlayer=new VideoPlayer();
			connectToViewerVideo(videoPlayer,getVideoDispalyFromIndex(viewerVideoPlayers.length),video.@displyname);
			
			viewerVideoInfo.player=videoPlayer;
			viewerVideoPlayers.push(viewerVideoInfo);
			videoPlayer.playVid(playheadTime,"vVideo");
		//	activeViewers.push(video);
		}
	}*/
}


/**
 * @private
 * For stoping all videos From Playback
 * 
 */
private function stopAllVideos():void
{
	if(presenterVideoPlayerObject!=null)
	{
		stopPlayingVideo(presenterVideoPlayerObject.player,presenterVideoConatiner);
		presenterVideoPlayerObject=null;
	}
	for(var index:int = viewerVideoPlayers.length-1 ;index>-1; index--) 
	{
		var videoDisplayContainerIndex:int=getVideoDispalyContainerIndex(viewerVideoPlayers[index].player);		
		var currentVideoDisplayContainer:BorderContainer=getViewerVideoContainerFromIndex(videoDisplayContainerIndex);
		var nextVideoDisplayContainer:BorderContainer
		stopPlayingVideo(viewerVideoPlayers[index].player,currentVideoDisplayContainer)
		viewerVideoPlayers.splice(index,1);
	}
	if(containsVideo(desktopComp.desktopPlayerContainer) && desktopVideoPlayerObject && desktopVideoPlayerObject.videoTag)
	{
		stopPlayingVideo(desktopVideoPlayerObject.player,desktopComp.desktopPlayerContainer);
		desktopVideoPlayerObject=null;	
	}
}
/**
 * @private
 * For Handling the seeking activity  in presenter's Video
 * @param playHeadTime
 * 
 */
private function seekPresenterVideo(playHeadTime:Number):void
{
	var seekValue:Number;
	if(presenterVideoPlayerObject &&  (playHeadTime > convetTime(presenterVideoPlayerObject.videoTag.@etime)|| playHeadTime < convetTime(presenterVideoPlayerObject.videoTag.@stime)))
	{
		stopPlayingVideo(presenterVideoPlayerObject.player,presenterVideoConatiner);
		presenterVideoPlayerObject=null;
		
	}
	else if(presenterVideoPlayerObject && (playHeadTime < convetTime(presenterVideoPlayerObject.videoTag.@etime) &&
		playHeadTime > convetTime(presenterVideoPlayerObject.videoTag.@stime)))
	{
		seekValue=presenterVideoPlayerObject.videoTag.@stime;		
		seekValue=playHeadTime-seekValue;
		presenterVideoPlayerObject.player.seekValue=(seekValue/1000);
	}
	for each(var video:XML in presenterVideoTagArray) 
	{
		
		if((playHeadTime >= convetTime(video.@stime) &&	playHeadTime < convetTime(video.@etime))
			&& (presenterVideoPlayerObject==null || presenterVideoPlayerObject.videoTag!=video))
		{
			if(isLocalPlayback)
			{
				presenterVideoPlayerObject=createVideo(video,null,videoFilePath,false);
			}
			else
			{
				presenterVideoPlayerObject=createVideo(video,presenterMediaConnection,videoFilePath,false);
			}
			presenterVideoConatiner.addElement(presenterVideoPlayerObject.player);
			seekValue=video.@stime;
			seekValue=(playHeadTime-seekValue)/1000;
			presenterVideoPlayerObject.player.seekValue=seekValue;
		}
	}
	
}
/**
 * @private
 * For Handling the seeking activity  in Viewer's Video
 * @param playHeadTime
 * 
 */
private function seekViewerVideos(playHeadTime:Number):void
{
	var seekValue:Number;
	for(var index:int = viewerVideoPlayers.length-1 ;index>-1; index--) 
	{
		if(playHeadTime > convetTime((viewerVideoPlayers[index].videoTag).@etime)|| playHeadTime < convetTime((viewerVideoPlayers[index].videoTag).@stime))
		{
			manageVideoArray(index);
		}
		else if(playHeadTime < convetTime((viewerVideoPlayers[index].videoTag).@etime) &&
			playHeadTime > convetTime((viewerVideoPlayers[index].videoTag).@stime))
		{
			seekValue=(viewerVideoPlayers[index].videoTag).@stime;
			
			seekValue=playHeadTime-seekValue;
			viewerVideoPlayers[index].player.seekValue=(seekValue/1000);
		}
	}
	//stopPlayingViewerVideos();
	for each(var video:XML in viewerVideoTagArray) 
	{
		
		if(playHeadTime >= convetTime(video.@stime) &&
			playHeadTime < convetTime(video.@etime) && !isPlayingNow(video))
		{
			
			isNewViewerVideoWhileSeeking=true;
			var obj:Object=null;
			if(!isLocalPlayback)
			{
				obj=createVideo(video,viewerMediaConnection ,videoFilePath,((viewerVideoPlayers.length<1)?false:true));
			}
			else
			{
				obj=createVideo(video,null,videoFilePath,((viewerVideoPlayers.length<1)?false:true));
			}
			getViewerVideoContainerFromIndex(viewerVideoPlayers.length).addElement(obj.player);
			viewerVideoPlayers.push(obj);			
			seekValue=video.@stime;			
			seekValue=(playHeadTime-seekValue)/1000;
			obj.player.seekValue=seekValue;
			if(viewerVideoPlayers.length==1)
			{
				viewerVideosPannel.title=video.@displyname;
			}
		}
		
	}
	if(viewerVideoPlayers.length==0)
	{
		viewerVideosPannel.title="Viewer's Video";
	}
	
		//checkNewVideoWhile()
	
}

/**
 * For checking the player has been in play mode or not
 * @param videoTag of XML
 * @return  Boolean
 * 
 */
private function isPlayingNow(videoTag:XML):Boolean
{
	var isPlaying:Boolean=false
	
		for(var index in viewerVideoPlayers) 
	{
		if(viewerVideoPlayers[index].videoTag==videoTag)
		{
			isPlaying=true;
		}	
	}	
	return isPlaying;

}
/**
 * @private
 * For creating the video components for viewer's video playback
 * @param video of XML
 * @param mediaServerConnection of MediaServerConnection
 * @param videoFolderpath of String
 * @param showMuteButton of Boolean
 * @param showPlayerControl of Boolean
 * @return Object
 * 
 */
private function createVideo(video:XML,mediaServerConnection:MediaServerConnection,videoFolderpath:String,showMuteButton:Boolean,showPlayerControl:Boolean=true):Object
{
	var obj:Object=new Object();
	obj.videoTag=video;			
	
	var videoPanel:VideoPanel=new VideoPanel;
	if(!isLocalPlayback)
	{
		videoPanel.addEventListener(AviewPlayerEvent.STREAM_READY,manageStreamPlaying);
		videoPanel.addEventListener(AviewPlayerEvent.STREAM_PLAY_COPMLETE,manageStreamPlaying);
		videoPanel.addEventListener(AviewPlayerEvent.STREAM_NOT_READY,manageStreamPlaying);
		videoPanel.netConnectionVideo=mediaServerConnection;
	}
	//videoPanel.isLocalPlayback=isLocalPlayback;
	videoPanel.horizontalCenter=0;
	videoPanel.verticalCenter=0;
	videoPanel.percentHeight=100;
	videoPanel.percentWidth=100;	
	videoPanel.vodFolderPath=videoFolderpath;
	videoPanel.videoFileName=video.@src;
	videoPanel.videoDisplayName=video.@displyname;
	videoPanel.playerVolume=mainSeek.volume.value;
	videoPanel.isMute=mainSeek.isMute;
	if(showPlayerControl && showMuteButton)
	{
		videoPanel.showMuteButton=true;
	}
	else if(showPlayerControl && !showMuteButton)
	{
		videoPanel.showPlayerControlComp=true;
	}
	else if(!showPlayerControl)
	{
		videoPanel.showMuteButton=false;
		videoPanel.showPlayerControlComp=false;
	}
	obj.player=videoPanel;
	
	return obj;
}


/**
 * @private
 * For Playing the Presenter's video 
 * 
 */
private function playPresenterVideo():void
{
	
		if(containsVideo(presenterVideoConatiner) && presenterVideoPlayerObject && presenterVideoPlayerObject.videoTag &&
			convetTime(presenterVideoPlayerObject.videoTag.@etime)==playHeadTime)
		{
			stopPlayingVideo(presenterVideoPlayerObject.player,presenterVideoConatiner);
			presenterVideoConatiner.title="Presenter Video"
			presenterVideoPlayerObject=null;
			
		}
		

	
	for each(var video:XML in presenterVideoTagArray) 
	{
		if(convetTime(video.@stime) == playHeadTime)
		{
			//centalTimer.stop();
			if(presenterMediaConnection!=null)
			{
				presenterVideoPlayerObject=createVideo(video,presenterMediaConnection,videoFilePath,false);
			}
			else
			{
				presenterVideoPlayerObject=createVideo(video,null,videoFilePath,false);
			}
			presenterVideoConatiner.addElement(presenterVideoPlayerObject.player);
			presenterVideoConatiner.title=video.@displyname;
			
		}
	}
}

/**
 * @private
 * For Playing the Viewer's video
 * 
 */
private function playViewerVideos():void
{
	for(var index:int = viewerVideoPlayers.length-1 ;index>-1; index--) 
	{
		if(convetTime((viewerVideoPlayers[index].videoTag).@etime)==playHeadTime)
		{
			manageVideoArray(index);
		
		}
	
	}
	
	for each(var video:XML in viewerVideoTagArray) 
	{
		if(convetTime(video.@stime) == playHeadTime)
		{
			var obj:Object=null;
			if(viewerMediaConnection!=null)
			{
				obj=createVideo(video,viewerMediaConnection,videoFilePath,((viewerVideoPlayers.length<1)?false:true));
			}
			else
			{
				obj=createVideo(video,null,videoFilePath,((viewerVideoPlayers.length<1)?false:true));
			}
			getViewerVideoContainerFromIndex(viewerVideoPlayers.length).addElement(obj.player);
			viewerVideoPlayers.push(obj);
			
			//	activeViewers.push(video);
			if(viewerVideoPlayers.length==1)
			{
				viewerVideosPannel.title=video.@displyname;
			}
		}
		
	}
	if(viewerVideoPlayers.length==0)
	{
		viewerVideosPannel.title="Viewer's Video";
	}
}
/**
 * @private
 * For Playing the Desktop's video
 * 
 */
private function playDesktop():void
{
	if(containsVideo(desktopComp.desktopPlayerContainer) && desktopVideoPlayerObject && desktopVideoPlayerObject.videoTag &&
		convetTime(desktopVideoPlayerObject.videoTag.@etime)==playHeadTime)
	{
		stopPlayingVideo(desktopVideoPlayerObject.player,desktopComp.desktopPlayerContainer);
		desktopVideoPlayerObject=null;	
	}
	
	
	
	for each(var video:XML in deskTopVideoTagArrayconvetTime) 
	{
		if(convetTime(video.@stime) == playHeadTime)
		{
			//centalTimer.stop();
			if(desktopMediaConnection!=null)
			{
				desktopVideoPlayerObject=createVideo(video,desktopMediaConnection,videoFilePath,false,false);
			}
			else
			{
				desktopVideoPlayerObject=createVideo(video,null,videoFilePath,false,false);
			}
			desktopComp.desktopPlayerContainer.addElement(desktopVideoPlayerObject.player);
			
		}
	}
}

/**
 * For handling the seeking in desktop's video
 * @param playHeadTime
 * 
 */
private function seekDesktopVideo(playHeadTime:Number):void
{
	var seekValue:Number;
	if(desktopVideoPlayerObject &&  (playHeadTime > convetTime(desktopVideoPlayerObject.videoTag.@etime)|| playHeadTime < convetTime(desktopVideoPlayerObject.videoTag.@stime)))
	{
		
		stopPlayingVideo(desktopVideoPlayerObject.player,desktopComp.desktopPlayerContainer);
		desktopVideoPlayerObject=null;
		
	}
	else if(desktopVideoPlayerObject && (playHeadTime < convetTime(desktopVideoPlayerObject.videoTag.@etime) &&
		playHeadTime > convetTime(desktopVideoPlayerObject.videoTag.@stime)))
	{
		seekValue=desktopVideoPlayerObject.videoTag.@stime;
		
		seekValue=playHeadTime-seekValue;
		desktopVideoPlayerObject.player.seekValue=(seekValue/1000);
	}
	for each(var video:XML in deskTopVideoTagArray) 
	{
		
		if((playHeadTime >= convetTime(video.@stime) && playHeadTime < convetTime(video.@etime)) && 
			(desktopVideoPlayerObject==null ||desktopVideoPlayerObject.videoTag!=video))
		{
			if(desktopMediaConnection!=null)
			{
				desktopVideoPlayerObject=createVideo(video,desktopMediaConnection,videoFilePath,false,false);
			}
			else
			{
				desktopVideoPlayerObject=createVideo(video,null,videoFilePath,false,false);
			}
			desktopComp.desktopPlayerContainer.addElement(desktopVideoPlayerObject.player);
			seekValue=video.@stime;
			seekValue=(playHeadTime-seekValue)/1000;
			desktopVideoPlayerObject.player.seekValue=seekValue;
		}
	}
	
}
//GTMCR::Give proper function name 
/**
 * @private
 * For updating the seek bar value here.
 * 
 * @return void
 */
private function playLecture():void
{
	/*if(playpauseButton.label=="Play")
	{
		playpauseButton.label="Pause"
	}				
	if(!stopButton.enabled)
	{   
		stopButton.enabled=true;					
	}*/
	if((playHeadTime/1000)>=mainSeek.seekbar.maximum)
	{
		if(Log.isInfo()) log.info("In playLecture Play End- Timer Stopped");	
		resetPlayer();		
	}
	else
	{
		wbPlayer.playWb(playHeadTime);
		docComp.documentPlayer.playDocument(playHeadTime);
		wbPointerPlayer.playWhiteBoardPointer(playHeadTime);
		
		/*pttPlayer.playPtt(playHeadTime);*/
		playPresenterVideo();
		playViewerVideos();
		playDesktop();
		
		if(slideList!=null)
		slideList=docComp.documentPlayer.slideCollection		
		chatWndw.chatPlayer.playChat(playHeadTime);
		if(playHeadTime%1000 ==0)
		{
			mainSeek.seekbar.value=(playHeadTime/1000);
		}
		
	}        
}
/**
 * @protected
 * For Handling the Slide Changes in slide panel  
 * @param event
 * 
 */
protected function slidelist_OnSlideChangedEventHandler(event:OnSlideChangedEvent):void
{
	// TODO Auto-generated method stub
	slidelist.scrolledIndex=event.index;
}

//VVCR: Place varibale declarations on top
private var pausedTimer:Boolean=false;
/**
 * @private
 * For resting the player status of all components  
 */
private function resetPlayer():void
{
	centralTimer.reset();
	centralTimer.stop()	
	pausedTimer=false;
	currentTimeOffset =0;
	stopAllVideos();
	wbPlayer.clearWb();
	docComp.documentPlayer.clearDocumentPlayer();
	chatWndw.chatbox.text="";
	mainSeek.seekbar.value=0;
	mainSeek.centeralTime="00:00:00";
	/*stopButton.enabled=false;*/
	viewStack.selectedIndex=1;
}
/**
 * @private
 * For updating the central Timer value
 * it will invoke while user made changes on seek bar
 * @param event of TimerEvent
 * @return void
 */
private function updateCentralSeekBar(evnt:TimerEvent):void
{ 
	var date:Date = new Date()
	currentTimeOffset=date.time - (referanceTime+playHeadTime);
	if(currentTimeOffset>=100)
	{
		playHeadTime+=100
		formatAndDisplayCentralTime();
		playLecture();
	}
}

/**
 * @private
 * For to seek the player head time to appropriate
 * slide index which is user selected from the slide 
 * panel.
 * @param event of AviewPlayerEvent
 * 
 */
private function onSlideSelected(event:AviewPlayerEvent):void
{
	mainSeek.seekbar.value=event.time/1000;				
	var slideTimeRounded:int=Math.floor(event.time/100);		
	playHeadTime = (slideTimeRounded*100);
	currentTimeOffset=0;
	updateReferenceTime();
	if(!centralTimer.running)
	{
		centralTimer.start();
		if(Log.isInfo()) log.info("In onSlideSelected- Timer Started");	
	}
	chatWndw.chatPlayer.updateChat(playHeadTime);
	wbPlayer.setContext(event.time);
	docComp.documentPlayer.playDocument(event.time);
	formatAndDisplayCentralTime();
	/*presenterVideoPlayer.setContext(playHeadTime, mainSeek.seekbar.value, "pVideo", presenterVid);*/
	/*mainViewerVideoPlayer.setContext(playHeadTime, mainSeek.seekbar.value, "vVideo", viewerVid);*/
	/*if(objDesktopPlayer!=null) 
		objDesktopPlayer.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.videoDisp);*/
}

//VVCR: Local parameters are not documented.
//GMTCR::change the parameter evnt to event
/**
 * @private
 * checking the FMS port for the connection of presenter's video
 * @param evnt of AviewPlayerEvent
 * @return void
 */
private function initializePlayers(evnt:AviewPlayerEvent):void
{
	//RTCR: Need to uncomment when we merge 4.0 recording logic
	/*viewerVideoTagArray=evnt.viewerVideoTagArray;
	presenterVideoTagArray=evnt.presenterVideoTagArray;
	deskTopVideoTagArray=evnt.desktopVideoTagArray;*/
		
	wbPointerPlayer=new WhiteBoardPointerPlayer(consolidateXmlBuilder,wbPlayer.wbSprite);	
	/*pttPlayer=new PttPlayer(presenterVid,viewerVid,consolidateXmlBuilder,contextSetter);*/				
	/*pttPlayer.addEventListener(AviewPlayerEvent.MUTE_PRESENTER_STREAM,mutePresenter);
	pttPlayer.addEventListener(AviewPlayerEvent.MUTE_VIEWER_STREAM,muteViewer);
	pttPlayer.addEventListener(AviewPlayerEvent.UNMUTE_PRESENTER_STREAM,unMutePresenter);
	pttPlayer.addEventListener(AviewPlayerEvent.UNMUTE_VIEWER_STREAM,unMuteViewer);*/
	mainSeek.seekbar.maximum=(fileLoaderManager.endTimeXml.etime)/1000;	
 
	var time:Number=mainSeek.seekbar.maximum*1000;
	var Hours:uint= time / (1000*60*60)
	var Minutes:uint = (time % (1000*60*60)) / (1000*60);
	var Seconds:uint = ((time % (1000*60*60)) % (1000*60)) / 1000;
	/*endTimeLabel.text=Hours.toString()+":"+Minutes.toString()+":"+Seconds.toString() */ 
	if(editingActive)						
	{	
		var editMin:uint=(Minutes+Hours*60)
		editTotalTime.text=editMin.toString()+":"+Seconds.toString();
	}
	docComp.documentPlayer.setConsolidateXMLBuilder(consolidateXmlBuilder);
	docComp.documentPlayer.setContextSetter(contextSetter);
	wbPlayer.setValues(consolidateXmlBuilder,contextSetter);
	chatWndw.chatPlayer.setConsolidateXML(consolidateXmlBuilder);
	mainSeek.seekbar.addEventListener(Event.CHANGE,seekChange)
	mainSeek.seekbar.addEventListener(MouseEvent.MOUSE_DOWN,onSeekBarMouseDown)
		/*mainSeek.seekbar.addEventListener(SliderEvent.THUMB_RELEASE,seekChange);	
	
	mainSeek.seekbar.addEventListener(CloseFileHandler.CUT_RECORDED_INIT, removeSeekChange);
	mainSeek.seekbar.addEventListener(CloseFileHandler.CUT_RECORDED_CLOSE, initializeSeekChange);*/
	if(!isLocalPlayback)
	{	
		var presenterFMSIP:String=presenterFMSUrl.substring(presenterFMSUrl.indexOf("://")+3,presenterFMSUrl.indexOf("/vod"))
		//var presenterPortTester:FMSPortTester = new FMSPortTester(presenterFMSIP,"/"+Constants.COLLABORATION_SERVER_MODULE_NAME+"/ConnectionTester",getConnectedPresenter,this,true);				
		//presenterPortTester.selectFMSPort();	
		getConnectedPresenter();
		if(presenterFMSUrl!=viewerFMSUrl)
		{
			getConnectedViewer();
		}
		if(presenterFMSUrl!=desktopFMSUrl || viewerFMSUrl!=desktopFMSUrl)
		{
		    
			if(desktopFMSUrl==null)
			{
				isDesktopFMSConnected=true
			}
			else
			{
				getConnectedDesktop();
			}
		}
	}
	else
	{
		/*presenterVideoPlayer.setValues(null,videoFilePath,consolidateXmlBuilder,contextSetter
			,fileLoaderManager,presenterVid,null,isLocalPlayback);*/
		startCentralTimer();
	}
}

//VVCR: Here onwards there is no @return and sometime @param specified in the asdoc documentation for functions. Please include the same.
//even if its void or no params we can mention it just there.
/**
 * @private
 * This function for editing purpose will ad description later
 * @param event of CloseFileHandler
 * 
 */
private function removeSeekChange(event:CloseFileHandler):void
{
	isCutLecturePopUp = true;	
}

/**
 * This function for editing purpose will ad description later
 * @param event
 * 
 */
private function initializeSeekChange(event:CloseFileHandler):void
{
	isCutLecturePopUp = false;	
}
/**
 * @private
 * For initilize the connection for Presenter's video playback
 * 
 */
private function getConnectedPresenter():void{
	var presenterFMSIP:String=presenterFMSUrl.substring(presenterFMSUrl.indexOf("://") + 3, presenterFMSUrl.indexOf("/vod"))
	
	presenterMediaConnection=new MediaServerConnection(presenterFMSIP,"vod",null,null,new VodCustomClient());
	presenterMediaConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, onStatusPresenterConnection);
	presenterMediaConnection.initialize();
	playerInitialized=true;
}

/**
 * @private
 * Here the connection status will return from server 
 * @param mediaServerStatus of MediaServerStatusEvent
 * 
 */
private function onStatusPresenterConnection(mediaServerStatus:MediaServerStatusEvent):void{
	if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_SUCCESS){
		//TODO: Figure out what to do..for not do nothing
		
	}
	
	else if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED){
		onConnectionTestFailedHandler("Presenter");
	}
	else if (mediaServerStatus.code == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS){
		presenterConnectionSuccessHandler();
	}
	else{
		connectionUnSuccessfulHanlder(mediaServerStatus.code,"PlaybackPresenter", presenterMediaConnection.netConnection.uri);	
	}
}
/**
 * This is the connection filed handler for all connection
 * @param connectionType of String
 * 
 */
private function onConnectionTestFailedHandler(connectionType:String):void{
	MessageBox.show("Connection to the "+connectionType+" server failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", 
		"Connection Failed", MessageBox.MB_OK, null, null);
}
/**
 * @private
 * This function invoked after the desktop playback connection 
 * has been initilize succesfully
 * 
 */
private function presenterConnectionSuccessHandler():void{
	AuditContext.userAction.connectionSuccessEventLog("PlaybackPresenter", presenterMediaConnection.netConnection.uri, null);
	isPresenterFMSConnected = true;
	startCentralTimer();
	if (presenterFMSUrl == viewerFMSUrl){
		viewerMediaConnection=presenterMediaConnection;
		viewerConnectionSuccessHandler();
	}
}

/**
 * @private
 * For initilize the connection for Viewer's video playback
 * 
 */
private function getConnectedViewer():void{
	//clearTimeout(portTesterViewerTimeoutId);
	var viewerFMSIP:String=viewerFMSUrl.substring(viewerFMSUrl.indexOf("://") + 3, viewerFMSUrl.indexOf("/vod"))
	
	viewerMediaConnection=new MediaServerConnection(viewerFMSIP,"vod",null,null,new VodCustomClient());
	viewerMediaConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, onStatusViewerConnection);
	viewerMediaConnection.initialize();
	
}
/**
 *  @private
 * Here the connection status will return from server 
 * @param mediaServerStatus of MediaServerStatusEvent
 * 
 */
private function onStatusViewerConnection(mediaServerStatus:MediaServerStatusEvent):void{
	if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_SUCCESS){
		//TODO: Figure out what to do..for not do nothing
	}
	else if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED){
		onConnectionTestFailedHandler("Viewer");
	}
	else if (mediaServerStatus.code == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS){
		viewerConnectionSuccessHandler();
	}  
	else{
		connectionUnSuccessfulHanlder(mediaServerStatus.code,"PlaybackViewer", viewerMediaConnection.netConnection.uri);	
	}
}

/**
 * @private
 * This is handling un success full connections
 * @param eventCode
 * @param playerType
 * @param fmsURL
 * 
 */
private function connectionUnSuccessfulHanlder(eventCode:String,playerType:String,fmsURL:String):void
{
	if (eventCode == MediaServerStatusEvent.CODE_NET_STATUS_CLOSED)
		AuditContext.userAction.connectionCloseEventLog(playerType, fmsURL);
	else if (eventCode == MediaServerStatusEvent.CODE_NET_STATUS_FAILED)
		AuditContext.userAction.connectionFailEventLog(playerType, fmsURL);
	else if (eventCode == MediaServerStatusEvent.CODE_NET_STATUS_REJECTED)
		AuditContext.userAction.connectionRejectEventLog(playerType, fmsURL);
}

/**
 * @private
 * This function invoked after the viewer's playback connection 
 * has been initilize succesfully
 * 
 */
private function viewerConnectionSuccessHandler():void
{
	AuditContext.userAction.connectionSuccessEventLog("PlaybackViewer", viewerMediaConnection.netConnection.uri, null);
	isViewerFMSConnected=true;
	startCentralTimer();
}
/**
 * @private
 * For initilize the connection for Desktop playback
 * 
 */
private function getConnectedDesktop():void
{
	var desktopFMSIP:String=desktopFMSUrl.substring(desktopFMSUrl.indexOf("://") + 3, desktopFMSUrl.indexOf("/vod"))
	
	desktopMediaConnection=new MediaServerConnection(desktopFMSIP,"vod",null,null,new VodCustomClient());
	desktopMediaConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, onStatusDesktopConnection);
	desktopMediaConnection.initialize();	
}
/**
 * @private
 * Here the connection status will return from server 
 * @param mediaServerStatus of MediaServerStatusEvent
 * 
 */
private function onStatusDesktopConnection(mediaServerStatus:MediaServerStatusEvent):void{
	if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_SUCCESS){
		//TODO: Figure out what to do..for not do nothing
	}
	else if(mediaServerStatus.code == MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED){
		onConnectionTestFailedHandler("Desktop");
	}
	else if (mediaServerStatus.code == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS){
		desktopConnectionSuccessHandler();
	}  
	else{
		connectionUnSuccessfulHanlder(mediaServerStatus.code,"PlaybackDesktop", viewerMediaConnection.netConnection.uri);	
	}
}
/**
 * @private
 * This function invoked after the desktop playback connection 
 * has been initilize succesfully
 * 
 */
private function desktopConnectionSuccessHandler():void
{
	AuditContext.userAction.connectionSuccessEventLog("PlaybackDesktop", desktopMediaConnection.netConnection.uri, null);
	isDesktopFMSConnected=true;
	startCentralTimer();
}
/**
 * Will add discription and functionality later
 * @param ncObj
 * 
 */
private function onConnectionError(ncObj:Event) :void
{
	//AuditContext.userAction.connectionSuccessEventLog("Playback");
}
/**
 * @private
 * For checking whether the player became ready for streaming
 * or not
 * @return  Boolean
 * 
 */
private function isViewerStreamsReady():Boolean
{
	var isStreamsReady:Boolean=true;
	for(var i:int=0;i<viewerVideoPlayers.length;i++)
	{
		if(!viewerVideoPlayers[i].player.isStreamReady)
		{
			isStreamsReady=false
				break
		}
	}	
	return isStreamsReady;
}
/**
 * @private
 * For Pausing the viewer's video streming 
 * 
 */
private function pauseAllViewerStreams():void
{
	for(var i:int=0;i<viewerVideoPlayers.length;i++)
	{
		viewerVideoPlayers[i].player.pausePlaying();
		
	}
}
/**
 * @private
 * For resuming video streming of viewer
 */
private function resumeAllViewerStreams():void
{
	for(var i:int=0;i<viewerVideoPlayers.length;i++)
	{
		viewerVideoPlayers[i].player.resumePlaying();
	}
}
/**
 * @private
 * For checking in playback whether the video object is 
 * intilized or not,if initilized the stream will resume
 * 
 */
private function checkAndPlayAllVideos():void
{
	if(!centralTimer.running && (presenterVideoPlayerObject==null || 
		(presenterVideoPlayerObject  && presenterVideoPlayerObject.player.isStreamReady)
		&& isViewerStreamsReady()&&
		(desktopVideoPlayerObject==null||(desktopVideoPlayerObject && desktopVideoPlayerObject.player.isStreamReady))))
	{
		if(presenterVideoPlayerObject  && presenterVideoPlayerObject.player.isStreamReady)
		{
			presenterVideoPlayerObject.player.resumePlaying();
		}
		else if(presenterVideoPlayerObject  && presenterVideoPlayerObject.player.isStreamReady &&  !mainSeek.isPlay)
		{
			presenterVideoPlayerObject.player.pausePlaying();
		}
		if(isViewerStreamsReady() && mainSeek.isPlay)
		{
			resumeAllViewerStreams();
		}
		else if(isViewerStreamsReady() && !mainSeek.isPlay)
		{
			pauseAllViewerStreams();
		}
		if(desktopVideoPlayerObject && desktopVideoPlayerObject.player.isStreamReady && mainSeek.isPlay)
		{
			desktopVideoPlayerObject.player.resumePlaying();
		}
		else if(desktopVideoPlayerObject && desktopVideoPlayerObject.player.isStreamReady && !mainSeek.isPlay)
		{
			desktopVideoPlayerObject.player.pausePlaying();
		}
		if(mainSeek.isPlay)
		{
			updateReferenceTime()
			centralTimer.start();
		}
		
	}
}
/**
 * @private
 * For pausing all videos at a same moment 
 * 
 */
private function pauseAllVideos():void
{
	centralTimer.stop(); 
	if(presenterVideoPlayerObject  && presenterVideoPlayerObject.player.isStreamReady)
	{
		presenterVideoPlayerObject.player.pausePlaying();
	}
	if(desktopVideoPlayerObject && desktopVideoPlayerObject.player.isStreamReady )
	{
		desktopVideoPlayerObject.player.resumePlaying();
	}
	pauseAllViewerStreams()
}
/**
 * @private
 * For managing the video streaming in playback
 * @param evnt
 * 
 */
private function manageStreamPlaying(evnt:AviewPlayerEvent):void
{
	if(Log.isDebug()) log.debug(" In manageStreamPlaying:-  Status ::"+evnt.type);
	if(evnt.type==AviewPlayerEvent.STREAM_READY)
	{
		checkAndPlayAllVideos();
	}
	else if(evnt.type==AviewPlayerEvent.STREAM_NOT_READY)
	{
		pauseAllVideos();
	}
	else if(evnt.type==AviewPlayerEvent.STREAM_PLAY_COPMLETE)
	{
		//handle 
		
		var videoPanel:VideoPanel = VideoPanel(evnt.target)
		if(getVideoPlayer(presenterVideoConatiner) == videoPanel)
		{
			stopPlayingVideo(videoPanel,presenterVideoConatiner)
			presenterVideoConatiner.title="Presenter Video"
			presenterVideoPlayerObject=null;	
		}
		else if(getVideoPlayer(desktopComp.desktopPlayerContainer)== videoPanel)
		{
			stopPlayingVideo(videoPanel,desktopComp.desktopPlayerContainer)
			desktopVideoPlayerObject=null;
		}
		else
		{
			var videoDisplayContainerIndex:int=getVideoDispalyContainerIndex(videoPanel);
			var currentVideoDisplayContainer:BorderContainer=getViewerVideoContainerFromIndex(videoDisplayContainerIndex);
			stopPlayingVideo(videoPanel,currentVideoDisplayContainer)
			if(currentVideoDisplayContainer == mainVideoContainer)
			{
				viewerVideosPannel.title="Viewer's Video";
			}
			
		}

		checkAndPlayAllVideos();
	}
	
}

/**
 * @private
 * For handling the index change of Whiteboard and document tab in Playback player
 * @param evnt of AviewPlayerEvent
 * 
 */
private function onModuleChangeEvent(evnt:AviewPlayerEvent):void
{
	if(evnt.type==AviewPlayerEvent.WB_TAB_CHANGED)
	{
		viewStack.selectedIndex=1
	}
	else if(evnt.type==AviewPlayerEvent.WB_PAGE_CHANGED)
	{
		/*pageNo.text="Page No : "+evnt.pageNumber;*/
		viewStack.selectedIndex=1  // shold remove this line later only the above line of code is enough
	}
	else if(evnt.type==AviewPlayerEvent.WB_CLEARED)
	{
		wbPointerPlayer.pointerShape=null;
	}
}
/**
 * @private
 * This function will dispatched the user try to pause the player
 * @param evnt
 * 
 */
private function onSeekBarMouseDown(evnt:Event):void
{
	pauseAllVideos();	
	if(Log.isInfo()) log.info("In onSeekBarMouseDown - Timer stopped");	
}
/**
 * @private
 * For handling the volume in whole playback 
 * will add functionality later 
 * @param event
 * 
 */
private function controlVolume(event:Event):void
{			
	/*if( presenterVid.muteButton.toolTip=="Mute")
		presenterVid.muteButton.toolTip="Unmute"
	else
		presenterVid.muteButton.toolTip="Mute"
	if(viewerVid.muteButton.toolTip=="Mute")
		viewerVid.muteButton.toolTip="Unmute"
	else
		viewerVid.muteButton.toolTip="Mute"
	presenterVolume(null);
	viewerVolume(null);*/
	
}
/**
 * @private
 * For handling the volume change events in Presenter's video
 * will add functionality later 
 * @param event
 * 
 */
private function presenterVolume(event:Event):void
{
	var evnt:AviewPlayerEvent;
	/*if( presenterVid.muteButton.toolTip=="Mute")
	{
		mutePresenter(evnt);
		
	}
	else
	{
		unMutePresenter(evnt);
		
	}*/
}

//VVCR: All initializations goes on top.

private var videoVolume:SoundTransform = new SoundTransform();

/**
 * @private
 * For handling the volume change events
 * will add functionality later 
 * @param videoPlayer
 * @param volume
 * 
 */
//VVCR: Don't know if it used or not
private function changeVideoVolume(videoPlayer:VideoPanel,volume:Number):void
{
	if(mainSeek.isMute)
	{
		//videoPlayer.isMute=true
	}
	else
	{
		//videoPlayer.isMute=false;
	}
	//videoPlayer.setVolume(volume);
}
//GTMCR:: its doing the converstion of time to string please give proper comment and function name, check the return
/**
 * @private
 * Formating the seek bar value of seek bar
 * @param seekValue of Object
 * @return void
 */
private function seekBarValue(seekValue:Object):String
{
	var time:Number=Number(seekValue)*1000;
	var Hours:uint= time / (1000*60*60);
	var Minutes:uint = (time % (1000*60*60)) / (1000*60);
	var Seconds:uint = ((time % (1000*60*60)) % (1000*60)) / 1000
	return Hours.toString()+":"+Minutes.toString()+":"+Seconds.toString() ; 			
}

/**
 * @public
 * The entire playback modules recontext the 
 * appropriate playhead time after seekchange
 * @param evnt
 * 
 */
public function seekChange(evnt:Event):void
{ 
	if(seekChangeValue != mainSeek.seekbar.value)
	{
		/*if(stopButton.enabled )
		{
		*/	
			playHeadTime =Math.floor( mainSeek.seekbar.value * 1000);
			//if seek to the end
			if((playHeadTime/1000)>=Math.floor(mainSeek.seekbar.maximum))
			{
				if(Log.isInfo()) log.info("In seekChange Play End- Timer Stopped");	
				resetPlayer();
				return
				
			}
			wbPlayer.isRestore=true;
			/*timeVariable=Math.floor(evnt.value);	*/
			wbPlayer.clearWb();
			/*if(!isCutLecturePopUp)
				mainSeek.seekbar.setThumbValueAt(evnt.thumbIndex , Math.floor(evnt.value));*/
			seekChangeValue = Math.floor(mainSeek.seekbar.value);
			updateReferenceTime();
			/* seekBar.value=Math.floor(evnt.value);
			playHeadTime=seekBar.value*1000; */
			wbPlayer.setContext(playHeadTime+100);  
			chatWndw.chatPlayer.updateChat(playHeadTime);
			docComp.documentPlayer.setContext(playHeadTime);
			/*presenterVid.lblVideoMode.visible=false;
			viewerVid.lblVideoMode.visible=false;*/
			/*presenterVideoPlayer.setContext(playHeadTime, mainSeek.seekbar.value, "pVideo", presenterVid);*/
			seekPresenterVideo(playHeadTime);
			seekViewerVideos(playHeadTime);
			seekDesktopVideo(playHeadTime);
		/*	mainViewerVideoPlayer.setContext(playHeadTime, mainSeek.seekbar.value, "vVideo", viewerVid);*/
			/*if(objDesktopPlayer!=null)
				objDesktopPlayer.videoPlayer.setContext(playHeadTime, seekBar.value, "desktop", objDesktopPlayer.videoDisp);*/
			//pttPlayer.setContext(playHeadTime);
			if(isLocalPlayback && !centralTimer.running)
			{
					centralTimer.start();
			}
			this.dispatchEvent(new SliderEvent("Notify seek change"));  
			formatAndDisplayCentralTime()
		/*}
		else
		{
			seekBar.value=0;
		}*/
	}
	else if(seekChangeValue == mainSeek.seekbar.value)
	{
		seekChangeValue = -1;
	}
}

//VVCR: All initializations goes on top.
private var isDesktopStoppedManually:Boolean = false;

/**
 * @public
 * For stoping the Timer before closing playback
 * 
 */
public function endAppl():void
{	  	 	   
	centralTimer.stop();
	if(Log.isInfo()) log.info("In endAppl - Timer stopped");	
	
}

/**
 * @private
 * Handling the resize functionality in whiteboard componants 
 * @param evt of ResizeEvent
 * 
 */
private function onResizeWb(evt:ResizeEvent):void
{
	if( wbPlayer && wbPlayer.wbSprite)
	{
		wbCan.removeElement(whiteboardMask);
		wbCan.removeElement(wbPlayer.wbSprite);
		whiteboardMask=null;
		wbPlayer.wbSprite.width=Can.width	;
		wbPlayer.wbSprite.height=Can.height;
		wbPlayer.wbSprite.drawBackground(0xffffff);
		wbCan.addElement(wbPlayer.wbSprite);
		whiteboardMask=new Canvas()
		whiteboardMask.graphics.beginFill(0xffffff,1);
		whiteboardMask.graphics.drawRect(0, 0, Can.width, Can.height);
		wbCan.mask=whiteboardMask;
		wbCan.addElement(whiteboardMask);
		if(playerInitialized )
		{
			wbPlayer.setContext(playHeadTime+100);  
		}
	}
	
}
/**
 * @private
 * For closing the playback 
 * 
 */
private function closePlayback():void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.playBackActiveflag=0
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.player.close();				
}
/**
 * @public
 * Reseting the data before Stoping the playback  
 * 
 */
public function stopPlayBack():void
{   				 				

	
	pausedTimer=false;
	//VVCR: Not sure why the empty if case is required here this could be restated as if(mainseek.btnstop.enabled){resetPlayer();}
	if(!mainSeek.btnStop.enabled)
	{
		/*playpauseButton.label="Pause";	
		if(!centalTimer.running)
		{
			updateReferenceTime();
			centalTimer.start();
			if(Log.isInfo()) log.info("In stopPalayBack- Timer Started");
		}*/
	}
	else
	{
		resetPlayer();
	}
	
	diffSeekValuePresenter = 0;
	diffSeekValueViewer = 0;
}
