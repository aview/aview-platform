/**
	*	Authors: Anu P,Aravind BC, Chitra S Pai, Jayahari, Sreelekshmy S
	*
	*	The A-VIEW playback module,part of A-VIEW replays the recorded lectures.
	*   These recorded lectures simulates the actual class session in same sequence.
	*	The A-VIEW modules namely Audio/Video, Document Sharing, Whiteboard, Text Chat are played-
	*   back simultaneously in the same order in which they were recorded.
	*	During playback all the XML Sync files generated during recording are loaded.
	*   The XML Sync files are fetched from the WAMP server where it is stored after recording.
	*	Then the corresponding module resources are loaded from the WAMP server.
	*   After loading all the module resources, the Video starts playing.
	*	Video is played through progressive download over HTTP and other modules syncs with video.
	*	The chat,document,whiteboard are loaded using the events recorded in the XML Sync files at WAMP server.
	*
	* Revisions: NIL
	**/

import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.playback.oldPlayback.PlaybackLoading;
import edu.amrita.aview.core.playback.oldPlayback.Playback_Video_fullscreen;
import edu.amrita.aview.core.playback.oldPlayback.Print2Flash.Point;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.containers.HBox;
import mx.controls.Alert;
import mx.controls.Label;
import mx.controls.Text;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.VideoEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import mx.utils.ArrayUtil;
import mx.utils.ObjectProxy;
import mx.utils.StringUtil;

[Bindable]
[Embed(source="assets/images/windows_nofullscreen.png")]
private var fullScreenbtnIcon:Class;

/* Icon declaration for toggle button to get default size screen functionality */
[Bindable]
[Embed(source="assets/images/view-fullscreen1.png")]
private var defaultViewbtnIcon:Class;



/* Sprite component is used to draw whiteboard. To hold sprite component we need this component  */
private var objUIComponent:UIComponent=new UIComponent;
/*The Sprite component is used to draw whiteboard  This variable is used by modules.playback.fxxomponents.controls.FXVideo.as  */
public var objSprite:Sprite=new Sprite();
/* This label displays the current lecture information in whiteboard for eg: Lecture No: lec2 */
private var lectureNameWBobj:Label;
/* This label displays the current page number of whiteboard for eg: Page No:1 */
private var pageNoWBLabelDispObj:Label;
/*  This Horizontal box holds the lecture and pageno_label labels and aligns accordingly*/
private var hboxWBLectureDetail:HBox;
/* This service checks is the video flv file, whiteboard, document,and chat xml files are there. */
private var searchFileService:HTTPService;

/* This flag is used for switching the view of document,whiteboard with Video in the bigger space. This flag is used in fxcomponents.controls.FXVideo.as file */
public var switchViewFlag:Boolean=false;
/*  This flags ensures that removing of the loading popup is done only once */
private var firstTime:Boolean;
/* This flag keeps the current state of playback window view. The value of the flag can be normal view (false)/full screen(true) */
private var switchViewNormalFullStatus:Boolean=false;
/*  This variable checks if the whiteboard playback is called as normal or when resized. */
private var switchWhiteboardRedrawFlag:Boolean=false;


/* This variable holds the source video file path */
private var videoPath:String="";
/* This variable holds the source video file name */
private var videoFile:String="";
/* This variable holds the source video file ext */
private var videoFileExt:String="";
/*  This variable holds the path of the whiteboard, document and chat xml file */
private var xmlPath:String="";
/* This variable holds the xml file name of document  */
private var pptXmlFile:String="";
/*  This variable holds the xml file name of chat data*/
private var chatXmlFile:String="";
/* This variable holds the xml file name of whiteboard data */
private var whiteXmlFile:String="";
/* This variable holds the document (swf) file name */
private var pptFileName:String="";
/* This String variable holds the chat data  from the xml to display */
private var chatMsg:String="";
/*This variable holds the error message to display if the recorded files like video.flv, whiteboard, chat and document xml files are missing  */
private var xmlLoadErrorMessage:String="";
/*This variable holds the current document name and informs if no document is used in the recording  */
private var currentPPTName:String=null;
/* This variable holds the current whiteboard lecture name */
private var currentWBLectureName:String;
/* This variable holds the current page number of whiteboard */
private var currentPageNumber:String='0';

/*These variables are used for redrawing variables when we switch the view or when dragged the video slider.
 The whiteboard code look very similar to that of playWhiteboard function.
 Need to find out the difference if poosible need to make the all the three functions into one
*/
private var currentPageNumberSwitchViewRedraw:String='0';
private var currentPageNumberRedraw:String='0';

// End of the above code


/* The variable holds the data read from the xml file which holds the document sync data */
[Bindable]
private var pptXmlDataArrColl:ArrayCollection;
/* The variable holds the data read from the xml file which holds the whiteboard drawing data */
private var WBXmlDataArrColl:ArrayCollection;
/* The variable holds the data read from the xml file which holds the chat message data */
private var chatXmlDataArrColl:ArrayCollection;
/* The variable holds the data read from the xml file which holds the whiteboard drawing data for redraw purpose only */
private var WBXmlDataArrCollReplica:ArrayCollection;
/* The variables holds the time points where document value is changed */
private var pptChangedTimeData:ArrayCollection;
/* This variable holds the Slide number which are displayed in the right most corner i.e. the order of slides */
[Bindable]
private var pptSlideNumberArray:ArrayCollection;


/* This variable holds the maximum scroll y position(height) of document. This is changed when playback window is resized. */
private var documentMaxScrollPosY:Number;
/* This variable holds the maximum scroll x position(width) of document. This is changed when playback window is resized.  */
private var documentMaxScrollPosX:Number;

/* This variable holds current scroll x position(width) of document. */
private var documentCurrentScrollPosX:Number;
/* This variable holds current scroll y position(height) of document. */
private var documentCurrentScrollPosY:Number;
/* This variable holds the resized width of document container. This var is manipulated when the window is resized or view is switched */
private var documentResizedWidth:Number;
/*   This variable holds the resized height of document container. This var is manipulated when the window is resized or view is switched*/
private var documentResizedHeight:Number;
/*  This variable holds total number of pages in the document. Using this we check is the whole document is loaded or not. */
private var documentTotalpages:Number;
/*   This variable holds the total number of pages that are loaded. And is incremented as each page is loaded.*/
private var documentCurrentPageNum:Number;
/* This variable holds the clicked playhead time in the video slider. */
private var CurrentSliderClickedPoint:Number;



/* This variable holds the current height of the video container. This var is used for switching the view */
private var currentVideoContHeight:int;
/* This variable holds the current width of the video container. This var is used for switching the view */
private var currentVideoContWidth:int;
/* This variable holds the current width of the whiteboard container. */
private var currentWhiteboardWidth:int=-1;
/* This variable holds the current height of the whiteboard container. */
private var currentWhiteboardHeight:int=-1;

/* This variable holds the current playhead time */
private var CurrentPlayheadtime:int;
/* This variable holds the whiteboard,Chat and document sync time */
private var CurrentWhiteboardDocumentChatSyncPointer:int;
/* Flags indicating the completion of document loading. It can have three value loaded sucessfully(1), not loaded(0), some fault occured (-1) */
private var docLoadCompleteFlag:int=0;
/*  Flags indicating the completion of whiteboard  loading. It can have three value loaded sucessfully(1), not loaded(0), some fault occured (-1) */
private var WBLoadCompleteFlag:int=0;
/* Flags indicating the completion of chat loading. It can have three value loaded sucessfully(1), not loaded(0), some fault occured (-1) */
private var chatLoadCompleteFlag:int=0;
/* Flags indicating the completion of respective slide of document loading. It can have three value loaded sucessfully(1), not loaded(0), some fault occured (-1) */
private var slideLoadCompleteFlag:int=0;
/*This flag indicate the rotate directions like 0 means no rotation and 1 means one rotate and like that.  */
private var documentRotateStatusFlag:int=0;


/* The variable holds an instance of waiting cursor during loading file thus locking the app  */
private var pop_toolbox:PlaybackLoading;



//////////////////////////////
//NEW WORK STARTS


/* This flag is set true when the player has loaded the video successfully*/
private var flagVideoLoaded:Boolean=false;

/* This variable stores the rounded playhead time*/
private var roundedPlayheadTime:Number;

/* This variable is set when we drag/click on the seekBar*/
private var seekBarDragged:Boolean=false;

/* 'p2fHeight' and 'p2fWidht' are used to set the print2flash container size on resizing Playback window*/
private var p2fHeight:Number=0;
private var p2fWidth:Number=0;

/* This variable is an instance of the fullscreen Video window*/
private var fullScreenInstance:Playback_Video_fullscreen;

/* This variable is used to store the volume before muting the video*/
private var previousVolume:Number;

/* This variable is used to store last playhead time at which wb was redrawn during seek */
private var lastWBRedrawTime:Number;

/* This variable is used to store last playhead time at which slide was loaded during seek */
private var lastPPTLoadedTime:Number;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.playback.oldPlayback.PlaybackCode.as");

/********************************************* PART 1 ********************************************************************************************/
/****************************************Here Starts the methods definition of Playback code.
 * This part deals with the intialization of the Playback module.
 * ***************************************************************************************************/

/**
* For establishing a connection to the server.
* This method is invoked after retrieving recorded files path,video file name and other related files
* This method is called by LMS modules i.e.  edu.amrita.aview.core.lms.LMS.mxml
* It searches for the video file and navigates according to the result.
*
* @param getvideoPath describes the path of the videofile.
* @param getxmlFilePath describes the path of the xml file.
* @param getvideoFilename describes the name of the video file.
* @return void
*/

public function intializePlaybackModule(getvideoPath:String, getxmlFilePath:String, getvideoFilename:String):void
{
	//Calling the method loadingPopup which will load the busy cursor and
	//lock the application till the loading completes
	
	//Todo: I assume that P2f is holding mousePointer and for the same have created the PlaybackLoading.mxml Component- Chitra
	//Bug Fix for Issue #146 
	loadingPopup();
	//Sets the Icon for play and pause button as pause
	PlayPause=PlayPause_Pause;
	//Sets the Icon for volume mute button as normal (unmuted)
	MuteOnOff=Mute_Off;
	//Instializing all the flags to default  
	firstTime=true;
	xmlLoadErrorMessage="";
	docLoadCompleteFlag=0;
	WBLoadCompleteFlag=0;
	slideLoadCompleteFlag=0;
	chatLoadCompleteFlag=0;
	//Setting the Selected VideoPath, Other document XML Path and Video filename 
	videoPath=getvideoPath;
	xmlPath=getxmlFilePath;
	videoFile=getvideoFilename;
	
	if (videoFile && videoFile.length > 4)
	{
		videoFileExt=videoFile.slice(videoFile.length - 4);
	}
	
	//From video file name retreving the other modules file name
	//teacher_TestingTeam_04-02-2010_14-53-31_VIDEO.flv ----> teacher_TestingTeam_04-02-2010_14-53-31
	var commonFileName:String=videoFile.slice(0, videoFile.length - 10);
	whiteXmlFile=commonFileName + "_WB.xml";
	chatXmlFile=commonFileName + "_CHAT.xml";
	pptXmlFile=commonFileName + "_DOC.xml";
	
	parseVideoPath();
	startPlayback();
}

private function startPlayback():void
{
	var videoWebServerPath:String="";
	setVideoFileSource();
	//VVCR: The hardcoded path variables can be read from a config script or from a global constants class to make the code more consistent
	videoWebServerPath=encodeURI("http://" + getIpFromURL(videoPath) + "/RecordFilesAview/");
	searchFileService=new HTTPService();
	searchFileService.url=videoWebServerPath + "checkfiles.php?filename=Videos/" + videoFile;
	searchFileService.addEventListener(ResultEvent.RESULT, searchVideoFileResultHandler);
	searchFileService.addEventListener(FaultEvent.FAULT, searchVideoFileFaultHandler);
	searchFileService.send();
	
	//Event Listeners for VideoDisplay
	//When video is fully loaded
	videoDisplay.addEventListener(mx.events.VideoEvent.READY, videoLoaded);
	//While playing
	videoDisplay.addEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE, videoPlayheadUpdateEventHandler);
	//When player finishes playing 
	videoDisplay.addEventListener(mx.events.VideoEvent.COMPLETE, finishedPlaying);
}

private function getIpFromURL(url:String):String
{
	var startIndex:int=url.indexOf("//");
	startIndex+=2; //Added for //
	var endIndex:int=url.indexOf("/", startIndex);
	var ip:String="";
	if (startIndex != -1 && endIndex != -1)
	{
		ip=url.slice(startIndex, endIndex);
	}
	return ip;
}

/**
 * This method is called initially when video and other components are starting to load from intializePlaybackModule()
 * This creates an instance of PlaybackLoading module and adds as a Pop up to the application.
 * The popup modality true means the parent window(Playback)will locked till popup is removed.
 *  */
private function loadingPopup():void
{
	//Using PopUp Manager Class the PlaybackLoading window is added to the Playback window 
	pop_toolbox=PlaybackLoading(PopUpManager.createPopUp(this, PlaybackLoading, true));
	PopUpManager.centerPopUp(pop_toolbox);
}

/**
* The method is called if videofile is succesfully located.
* The method checks if the video files is corrupted. If no an error message is displayed to user.
* Otherwise the method loads the other recorded components like whiteboard, document and chat xml files
*
* @param Resultevent triggers faultevent if selected video file is found in specified path..
* @return void
*/
private function searchVideoFileResultHandler(event:ResultEvent):void
{
	// if the searched video file exits then loads other module components
	if (event.result.root.files.toString() == "yes")
	{
		loadDocWBChatComponents();
	}
	// else remove the pop up and show the error that the file doent exist
	else
	{
		PopUpManager.removePopUp(pop_toolbox);
		hbox.visible=true;
		//////////////////////////////////////////////////////////////////////
		// The error message is changed so that users can understand it clearly
		// Issue #187 ---STARTS
		Alert.show("Error in loading the selected lecture\nPlease contact A-VIEW Administrator", "File Error", 0, this, closeFileMissing);
		// Issue #187 ---ENDS
		lblVideoTime.text="0:00/0:00";
	}
}

/**
* This method is called if the video file is not found the specific path
* It displays an error message to the user.
* @param event triggers faultevent if selected video file is not found in specified path.
* @return void
*/
private function searchVideoFileFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("playback::oldPlayback::PlaybackCode::searchVideoFileFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	// If the file is not found the pop is removed and the error is shown that file don't exist
	PopUpManager.removePopUp(pop_toolbox);
	hbox.visible=true;
	//////////////////////////////////////////////////////////////////////
	// The error message is changed so that users can understand it clearly
	// Issue #187 ---STARTS
	Alert.show("Error in locating the archive server\nPlease contact A-VIEW Administrator. Fault string:" + event.fault.faultString, "Server Error", 0, this, closeFileMissing);
	// Issue #187 ---ENDS
	lblVideoTime.text="0:00/0:00";
}

/**
* This method is also called by modules.playback.fxcomponents.controls.FXVideo.as
* It loads the recorded xml files of document,whiteboard and chat module.
* @return void
*/

public function loadDocWBChatComponents():void
{
	// Load the Slide List in the left pane and document component in the right pane
	tn.selectedChild=slide;
	tn1.selectedChild=doc;
	can.addChild(objUIComponent);
	objUIComponent.addChild(objSprite);
	CurrentWhiteboardDocumentChatSyncPointer=-1;
	
	//VVCR: The hardcoded path variables can be read from a config script or from a global constants class to make the code more consistent
	// Searches if the selected document file exist in the WAMP Server using PHP Server
	var readppt_xml:String=xmlPath + "/RecordFilesAview/" + pptXmlFile;
	var ppt_http_service:HTTPService=new HTTPService();
	ppt_http_service.url=readppt_xml;
	ppt_http_service.send();
	ppt_http_service.addEventListener(ResultEvent.RESULT, pptXMLFileSearchResultHandler);
	ppt_http_service.addEventListener(FaultEvent.FAULT, pptXMLFileSearchFaultHandler);
	
	// Searches if the selected Whiteboard xml file exist in the WAMP Server using PHP Server
	whiteXmlFile=xmlPath + "/RecordFilesAview/" + whiteXmlFile;
	var white_http_service:HTTPService=new HTTPService();
	white_http_service.url=whiteXmlFile;
	white_http_service.send();
	white_http_service.addEventListener(ResultEvent.RESULT, WBXMLFileSearchResultHandler);
	white_http_service.addEventListener(FaultEvent.FAULT, WBXMLFileSearchFaultHandler);
	
	// Searches if the selected Chat xml file exist in the WAMP Server using PHP Server
	chatXmlFile=xmlPath + "/RecordFilesAview/" + chatXmlFile;
	var chat_http_service:HTTPService=new HTTPService();
	chat_http_service.url=chatXmlFile;
	chat_http_service.send();
	chat_http_service.addEventListener(ResultEvent.RESULT, chatXMLFileSearchResultHandler);
	chat_http_service.addEventListener(FaultEvent.FAULT, chatXMLFileSearchFaultHandler);
}


/**
 * This method handles errors like the file is not found and the respective message is displayed
 *  @return void
 */

private function SetSource():void
{
	// checks if the Playback module is not closed then only gets into the function
	if (close_flag == false)
	{
		if(Log.isDebug()) log.debug("In SetSource")
		//checks if the loading of all the components are completed then only it gets into the code block 
		if (WBLoadCompleteFlag != 0 && docLoadCompleteFlag != 0 && chatLoadCompleteFlag != 0 && slideLoadCompleteFlag != 0)
		{
			// checks if the whiteboard file is not found then adds that information to the User Alert
			if (WBLoadCompleteFlag == -1)
			{
				if (xmlLoadErrorMessage != "")
				{
					xmlLoadErrorMessage+=",White Board File";
				}
				else
				{
					xmlLoadErrorMessage+="White Board File";
				}
			}
			// checks if the document file is not found then adds that information to the User Alert
			if (docLoadCompleteFlag == -1 || slideLoadCompleteFlag == -1)
			{
				if (xmlLoadErrorMessage != "")
				{
					xmlLoadErrorMessage+=",Document File";
				}
				else
				{
					xmlLoadErrorMessage+="Document File";
				}
			}
			// checks if the chat file is not found then adds that information to the User Alert
			if (chatLoadCompleteFlag == -1)
			{
				if (xmlLoadErrorMessage != "")
				{
					xmlLoadErrorMessage+=",Chat File";
				}
				else
				{
					xmlLoadErrorMessage+="Chat File";
				}
			}
		}
		// checks if all the documents are loaded sucessfully then sets video source to the player
		if (WBLoadCompleteFlag == 1 && docLoadCompleteFlag == 1 && chatLoadCompleteFlag == 1 && slideLoadCompleteFlag == 1)
		{
			videoDisplay.source=videoFileSource;
		}
	}

}

private var protocol:String=null;
private var videoServerIP:String=null;
private var videoFileSource:String=null;
private var videoPathSuffix:String="";

private function parseVideoPath():void
{
	protocol=videoPath.slice(0, 4);
	
	const MEDIA:String="/media";
	var mediaIndex:int=videoPath.indexOf(MEDIA);
	
	if (mediaIndex != -1)
	{
		if (videoPath.length > mediaIndex + MEDIA.length + 1)
		{
			videoPath=videoPath.slice(0, mediaIndex) + videoPath.slice(mediaIndex + MEDIA.length);
		}
		else
		{
			videoPath=videoPath.slice(0, mediaIndex);
		}
	}
	
	var startIndex:int=videoPath.indexOf("//");
	startIndex+=2; //Added for //
	var endIndex:int=videoPath.indexOf("/", startIndex);
	if (startIndex != -1 && endIndex != -1)
	{
		videoServerIP=videoPath.slice(startIndex, endIndex);
		videoPathSuffix=videoPath.slice(endIndex, videoPath.length);
	}

}

private function setVideoFileSource():void
{
	if (protocol == "http")
	{
		videoFileSource=videoPath + "/" + videoFile;
	}
	else if (protocol == "rtmp")
	{
		//Insert FMS port to videoPath
		var videoPathTemp:String="";
		
		videoPathTemp=protocol + "://" + videoServerIP + ":" + ClassroomContext.portFMS + videoPathSuffix;
		
		if (videoFileExt == ".f4v")
		{
			videoFileSource=videoPathTemp + "/mp4:" + videoFile;
		}
		else
		{
			videoFileSource=videoPathTemp + "/" + videoFile;
		}
	}

}

/**
* This method is invoked when the video get stopped.
* It sets text of label that hold the elapsed and total time and Hslider value
* invokes methods to clear whiteboard,load slide,draw white board content and chat content at time 0.
* @return void
*/
private function SetToInitialStage():void
{
	lblVideoTime.text="0:00 / " + formatTime(videoDisplay.totalTime);
	clearWBChatifDataisNull();
	seekBar.value=0;
	loadSlide(0, 0);
	playbackWBLogic(0, 0, 0);
	syncChatwithVideo();
}

/***************************************** PART 2 ********************************************************************
 *  **************This part deals with the UI i.e switching the view, resizing the playback window, making fullscreen mode*********/

/**
 * This method handles the resizing of the Aview Playback window.
 * This function is invoked when the A-VIEW playback window is resized.
 * The whiteboard and document sharing window are also resized according to the change in Playback window.
 * @return void
 */
public function PlaybackWindowResizeHandler():void
{
	// The following code makes the loading window centered on resizing the Playback window
	if (pop_toolbox)
	{
		PopUpManager.centerPopUp(pop_toolbox);
	}
	
	//Bug Fix for Issue #37
	var selectedchild:int=tn1.selectedIndex;
	// Sets new width and height to Whiteboard, Document container 
	//Bug Fix for Issues #6& #2
	
	redrawWBduringResize(CurrentPlayheadtime, tn1.width, tn1.height);
	setDocumentContainerSize(tn1.width, tn1.height, 50);
	
	// Added a null check to avoid null pointer exception when no document was
	// loaded during the actual recording. 
	/* if(document.source!=null)
	{
		document.setScrollPosition(new edu.amrita.aview.core.documentSharing.Print2Flash.Point(documentCurrentScrollPosX *(documentCurrentScrollPosX/documentMaxScrollPosX) ,documentCurrentScrollPosY*(documentCurrentScrollPosY/documentMaxScrollPosY)));
	} */
	
	/* if(switchViewFlag==false)
	{
		//SetContainersWidthHeightforDefaultView();
		redrawWBduringResize(CurrentPlayheadtime,can.width,can.height);
		//setDocumentContainerSize(tn1.width,tn1.height,50);
		//document.setSize(documentResizedWidth,documentResizedHeight);
	}
	else if(switchViewFlag==true)
	{
		//SetContainersWidthHeightforDefaultView();
	
		redrawWBduringResize(CurrentPlayheadtime,can.width,can.height);
	//document.setSize(videoCan.width-40,videoCan.height-40);
	} */
	
	// Also sets the selected child to the container. Other wise the selected tab was not set at same order
	//Bug Fix for Issue #37
	tn1.selectedIndex=selectedchild;

}


//TODO: Remove this function, not used anywhere  
/**
* This method ports the A-View playback window to the FULL SCREEN mode.
*
* This function is invoked when we click the fullscreen button on the A-View playback window.
* The system ports back to the NORMAL mode when the fullscreen button is clicked for a second time.
 * @return void
*/

/* private function PlaybackWindowFullScreenHandler():void
{
   //if the  Playback window is normal/restore state then change to the full screen mode
   if( stage.displayState == StageDisplayState.NORMAL )
   {
	   ////To change the icon of fullscreen button///////
	   //fs.setStyle("icon",fullScreenbtnIcon);
	   switchViewNormalFullStatus=false;
	   //fs.toolTip="Normal";
	   stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
	   //checks if the selected window View is Video right screen mode
	   if(switchViewFlag==true)
	   {
		   SetChangedContainersWidthHeight();
		   if(document.source!=null)
		   {
			   document.setSize(videoCan.width-40,videoCan.height-40);
		   }
	   }
	   checks if the selected window View is Video left screen mode
	   else
	   {
		   SetContainersWidthHeightforDefaultView();
		if(document.source!=null)
	   {
		   document.setSize(documentResizedWidth,documentResizedHeight);
	   }
   }
   //if the  Playback window is full screen state then change to the normal state
   else
   {
	   //fs.setStyle("icon",defaultViewbtnIcon);
	   switchViewNormalFullStatus=true;
	   //fs.toolTip="FullScreen";
	   stage.displayState = StageDisplayState.NORMAL;
	   //checks if the selected window View is Video right screen mode
	   if(switchViewFlag==true)
	   {
		   tn1.height=videoCan.height;
		   tn1.width=videoCan.width;
		   videoDisplay.height=part2.height-45;
		   videoDisplay.width=part2.width-45;
		   if(document.source!=null)
		   {
			   document.setSize(videoCan.width-40,videoCan.height-40);
		   }
	   }
	   //checks if the selected window View is Video left screen mode
	   //else
	   //{
		   tn1.percentHeight=100;
		   tn1.percentWidth=100;
		   //document.setSize(documentResizedWidth,documentResizedHeight);
	   //}
   }
   }
} */

/**
 * This method assigns the containers the normal view width and height
 * This method is called when the switchview is called second time to set the view to normal mode
 * @return void
 */
/* private function SetContainersWidthHeightforDefaultView():void
{
	tn1.width=part2.width;
	tn1.height=part2.height;
maskcan.width = can.width;
	maskcan.height = can.height
	wrapcan.width = tn1.width;
	wrapcan.height = tn1.height;
}   */
/**
 * This method assigns the containers the switched view width and height
 * This method is called when the switchview is called first.
 * This ports the video in the fullscreen and document/whiteboard in the smaller area
 * @return void
 */
/* private function SetChangedContainersWidthHeight():void
{
	tn1.height=videoCan.height;
	tn1.width=videoCan.width;
	videoDisplay.height=part2.height-20;
	videoDisplay.width=part2.width;
} */

/**
 * This method is invoked when the user double clicks on the Video Panel.
 * This creates an instance of Playback_Video_fullscreen component and loads
 * the video into that.
 *
 *
 * @return void
 */
private function viewInFullScreen():void
{
	videoPanel.doubleClickEnabled=false;
	fullScreenInstance=new Playback_Video_fullscreen();
	//For Web: Commented following logic.Since open() method not available for web.
	//fullScreenInstance.open(true);
	fullScreenInstance.playbackInstance=this;
	fullScreenInstance.videoFullScreenLoader.addChild(videoContainer);
}

//TODO: Add this feature and remove the bugs in this
/**
 * Switches the video display and the document\whiteboard window for the ease of the user
 * This method is invoked when we click the switchview button in the A-View playback window.
 * @return void
 */
/* private function switchUIView():void
{
	var p2:int;
	 var p2w:int;
	 //checks if the selected window View is Video left screen mode and sets flag accordingly
	if(switchViewFlag==false)
	{
		switchViewFlag=true;
	}
	 //checks if the selected window View is Video right screen mode
	else
	{
		switchViewFlag=false;
	}
	 //if the selected window View is Video right screen mode then changes the container size accordingly
	if(switchViewFlag==true)
	{
		//switchview.toolTip="Default View";

		p2=part2.height;
		currentVideoContHeight=videoDisplay.height;
		currentVideoContWidth=videoDisplay.width;
		p2w=part2.width;


		part2.removeChild(wrapcan);
		videoCan.removeChild(videoDisplay);

		// Arranging based on the view////////
		videoDisplay.height=p2-20;
		videoDisplay.width=p2w;

		tn1.width= videoCan.width;
		tn1.height= videoCan.height;
		maskcan.width = videoCan.width;
		maskcan.height = (videoCan.height)*90/100;
		wrapcan.width = videoCan.width;
		wrapcan.height = videoCan.height;

		  videoCan.addChild(wrapcan);
		part2.addChild(videoDisplay);
		redrawWBduringResize(CurrentPlayheadtime,can.width,can.height);
		if(pptXmlDataArrColl==null)
	  {
		document.width=videoCan.width-40;
		document.height=videoCan.height-40;

	  }
	  else
	  {
		///To load the document during switchview/////
		document.setSize(videoCan.width-40,videoCan.height-40);
	  }


	 }
	  //if the selected window View is Video left screen mode then changes the container size accordingly

	 else if(switchViewFlag==false)
	 {
		//switchview.toolTip="Switch View";

		videoDisplay.height=currentVideoContHeight;
		videoDisplay.width=currentVideoContWidth;

			//not needed starts

		tn1.height=part2.height;
		tn1.width=part2.width;
		maskcan.height = (part2.height)*96/100;
		maskcan.width = part2.width

		wrapcan.width = part2.width;
		wrapcan.height = part2.height;

			//not needed ends

		//switchview.enabled=true;

		videoCan.removeChild(wrapcan);
		part2.removeChild(videoDisplay);
		videoCan.addChild(videoDisplay);

		part2.addChild(wrapcan);
		//Bug Fix for Issues #6& #2
	  redrawWBduringResize(CurrentPlayheadtime,can.width,can.height);
		setDocumentContainerSize(tn1.width,tn1.height,50);
		document.setSize(documentResizedWidth,documentResizedHeight);
	 }

} */






/******************************************** PART 3 ************************************************
 * **************************This portion handles the document playback **************************************************/


/* private var objForCuePoint:Object;
private var newCuePoint:Array=new Array();

private function reachedCuePoint(evt:CuePointEvent):void
{
	//Alert.show(evt.cuePointTime.toString());
	newCuePoint.pop();
	// Remove cue point.
	newCuePoint.name=evt.cuePointName;
	newCuePoint.time=evt.cuePointTime;
	videoDisplay.cuePointManager.removeCuePoint(newCuePoint);

} */

/**
 * This method synchronizes videoplayback and document according to the corresponding changes in the slide/page list.
 * This method is invoked when we click the slide/page list.
* It sets the slides/pages according to the xml list.
* First this method takes the index of selected item in the list and stores the value in to a variable named Slide.
 * Then it gets the loaded time of that slide and update the playheadTime accordingly.
 * This also sets the flag seekBarDragged to true, so as to load current page, whiteboard drawings and chat conversations.
 * @return void
 */
private function getSelectedPPTSlide():void
{
	var ppt_time:Number;
	//START--------------------------------------------
	//Check if the state of videoDisplay is stopped or not 
	//If yes, then invokes the eventHandler which updates the seekbar according to video PlayheadTime
	//else, do nothing.
	//END----------------------------------------------
	if (videoDisplay.state == mx.events.VideoEvent.STOPPED)
	{
		videoDisplay.addEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE, videoPlayheadUpdateEventHandler);
	}
	else
	{
		
	}
	if (tn1.selectedChild != doc)
	{
		tn1.selectedChild=doc;
	}
	if (doc.visible == false)
	{
		doc.visible=true;
	}
	if (list.selectedItem)
	{
		var Slide:Number=list.selectedItem.index;
		ppt_time=parseFloat(pptXmlDataArrColl[Slide].time);
		if(Log.isDebug()) log.debug("This slide was loaded at " + ppt_time.toString() + " seconds");
		seekBar.value=videoDisplay.playheadTime=ppt_time;
		updateTimer();
		seekBarDragged=true;
	}
	//videoDisplay.removeEventListener(VideoEvent.PLAYHEAD_UPDATE,videoPlayheadUpdateEventHandler);
	//videoDisplay.cuePointManagerClass=mx.controls.videoClasses.CuePointManager;
	//Alert.show(videoDisplay.cuePoints.toString());
	//videoDisplay.cuePointManager.setCuePoints(pptChangedTimeData.toArray());


/* objForCuePoint=new Object();
objForCuePoint.name=pptXmlDataArrColl[Slide].fileName + pptXmlDataArrColl[Slide].time;
objForCuePoint.time=pptXmlDataArrColl[Slide].time;
newCuePoint.push(objForCuePoint);

/*
videoDisplay.cuePointManager.removeCuePoints();
videoDisplay.cuePointManager.setCuePoints(newCuePoint);
videoDisplay.addEventListener(CuePointEvent.CUE_POINT,reachedCuePoint); */

	// Code for Rotation
/* if(documentRotateStatusFlag == 0)
{
	//no rotation
}
else
{
	var value:Number = 4-documentRotateStatusFlag;
	for(var i:int=0;i<value;i++)
	{
		document.Rotate();
	}
	documentRotateStatusFlag = 0;
} */
}

/**
 * This method handles the ResultEvent for document.
 * Retrieves all the items from the XML list and stores in to an array collection called pptxml_data.
 * Sets an array called slide_array where all the slide numbers are stored.
 * Then that array is pushed in to the slide list and the document source is set to the xml path.
 * @param ResultEvent the serached document file is found
 * @return void
 */
private function pptXMLFileSearchResultHandler(event:ResultEvent):void
{
	var listPointer:int=0;
	docLoadCompleteFlag=1;
	SetSource();
	
	pptXmlDataArrColl=new ArrayCollection();
	if (event.result.Items.item is ArrayCollection)
	{
		pptXmlDataArrColl=event.result.Items.item as ArrayCollection;
	}
	else if (event.result.Items.item is ObjectProxy)
	{
		pptXmlDataArrColl=new ArrayCollection(ArrayUtil.toArray(event.result.Items.item));
	}
	else
	{
		try
		{
			pptXmlDataArrColl=event.result.Items.item as ArrayCollection;
		}
		catch (e:Error)	{
			if(Log.isError()) log.error("Error in pptXMLFileSearchResultHandler method in PlaybackCode.as"+ e.getStackTrace());
		}
	}
	var ob:Object;
	var timeob:Object;
	if (pptXmlDataArrColl != null)
	{
		pptSlideNumberArray=new ArrayCollection();
		pptChangedTimeData=new ArrayCollection();
		listPointer=-1;
		
		if (pptXmlDataArrColl.length == 1)
		{
			ob=new Object();
			ob.Slide="Slide " + (pptXmlDataArrColl[i].page).toString();
			ob.index=i;
			listPointer++;
			ob.lPntr=listPointer;
			pptSlideNumberArray.addItem(ob);
			
		}
		
		///////To push the Slide numbers to the List//////		
		for (var i:int=0; i < pptXmlDataArrColl.length - 1; i++)
		{
			
			timeob=new Object();
			timeob=pptXmlDataArrColl[i].time;
			pptChangedTimeData.addItem(timeob);
			
			//////To remove the slide redundancy//////
			if (i == 0)
			{
				ob=new Object();
				ob.Slide="Slide " + (pptXmlDataArrColl[i].page).toString();
				ob.index=i;
				listPointer++;
				ob.lPntr=listPointer;
				pptSlideNumberArray.addItem(ob);
			}
			
			if (((pptXmlDataArrColl[i].page) != (pptXmlDataArrColl[i + 1].page)) || (pptXmlDataArrColl[i].fileName != pptXmlDataArrColl[i + 1].fileName))
			{
				
				ob=new Object();
				ob.Slide="Slide " + (pptXmlDataArrColl[i + 1].page).toString();
				ob.index=i + 1;
				listPointer++;
				ob.lPntr=listPointer;
				pptSlideNumberArray.addItem(ob);
				
			}
		}
		
		//To load the first ppt at the time of completion//	
		pptFileName=pptXmlDataArrColl[0].fileName;
		documentCurrentPageNum=0;
		searchDocumentFile(xmlPath + "checkfiles.php?filename=" + "Slides/" + pptFileName);
	}
	else
	{
		slideLoadCompleteFlag=1;
		SetSource();
	}
}

/**
* This method searches for the document at the specific location that is passed as the parameter.
 * @param fName the parameter holds the document path and file name
 * @return void
*/
private function searchDocumentFile(fName:String):void
{
	searchFileService=new HTTPService();
	searchFileService.url=fName;
	searchFileService.addEventListener(ResultEvent.RESULT, searchDocumentFileResultHandler);
	searchFileService.addEventListener(FaultEvent.FAULT, searchDocumentFileFaultHandler);
	searchFileService.send();
}

/**
* This method is invoked if the recoded document xml file is sucessfully located
 * This inturn invokes the page load complete method to check if all the pages are loaded successfully
 * @param event ResultEvent triggers when documetn recording xml file is found
 * @return void
*/
private function searchDocumentFileResultHandler(event:ResultEvent):void
{
	//If the file is found in the WAMP Server then adds that as a source to P2F
	if (event.result.root.files.toString() == "yes")
	{
		document.addEventListener("onPageLoaded", pptSlideLoadCompleteHandler);
		document.source=xmlPath + "RecordFilesAview/Slides/" + pptFileName;
	}
	else
	{
		slideLoadCompleteFlag=-1;
		SetSource();
	}
}

/**
* This method is invoked when all the pages of the loaded document is loaded successfully.
 * @param event Event This triggers when the ppt completes
 * @return void
*/
private function pptSlideLoadCompleteHandler(event:Event):void
{
	// If the loading is completed then checks if total page number is equal to loaded page number 
	documentCurrentPageNum++;
	if (documentCurrentPageNum == documentTotalpages)
	{
		slideLoadCompleteFlag=1;
		SetSource();
	}
}

/**
* This method is invoked when the document file is not found in the specified location.
 * @param Event fault event if file is not found in the specified position
 * @return void
*/
private function pptXMLFileSearchFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("playback::oldPlayback::PlaybackCode::pptXMLFileSearchFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	Alert.show("Error while loading Document control file\nPlease contact A-VIEW Administrator. Fault string:" + event.fault.faultString, "Server Error", 0, this, closeFileMissing);
	docLoadCompleteFlag=-1;
	SetSource();
}


/**
* This method is invoked when the document file is not found in the specified location.
* @param event FaultEvent if the document shraing xml file is not found
* @return void
*/
private function searchDocumentFileFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("playback::oldPlayback::PlaybackCode::searchDocumentFileFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	Alert.show("Error while loading Document file\nPlease contact A-VIEW Administrator. Fault string:" + event.fault.faultString, "Server Error", 0, this, closeFileMissing);
	slideLoadCompleteFlag=-1;
	SetSource();
}



/**
 * This method is used to set the total number of pages of document from the PrinttoFlash API .
 *  Using this value we check if the document is loaded successfully
 * @param num the total number of pages
 * @return void
 **/
private function getDocumentPageNumber(num:Number):void
{
	documentTotalpages=num;
	if (documentTotalpages == documentCurrentPageNum)
	{
		slideLoadCompleteFlag=1;
		SetSource();
	}
}

/**
 * This method is used to set the maximum scroll width and height of document from the Print2Flash API .
 * @param pos the scroll object from the PrinttoFlash API .
 * @return void
 **/
private function getDocumentMaxscroll(pos:Object):void
{
	documentMaxScrollPosY=pos.y;
	documentMaxScrollPosX=pos.x;

}

/**
 * This method calculates the width and height according to which the document container is resized.
 *  This function is invoked in correspondence with the resize function. This is called in normal view
 * The new height and width are computed by taking the width and height of the tabnavigator as the inputs.
 * @param contWidth the current container width to scale
 * @param contHeight the current container height to scale
 * @param tuningNum the adjustment factor for Printtoflash container to documents in place
 * @return void
 */
private function setDocumentContainerSize(contWidth:int, contHeight:int, tuningNum:int):void
{
	if(Log.isDebug()) log.debug("In setsizeresolution" + close_flag);
	
	var tempWidth:Number;
	
	documentResizedHeight=contHeight - tuningNum;
	tempWidth=(documentResizedHeight / 3) * 4;
	
	// not sure why this checked 
	if (tempWidth >= contWidth)
	{
		documentResizedWidth=contWidth - tuningNum;
		documentResizedHeight=(documentResizedWidth / 4) * 3;
	}
	else
	{
		documentResizedWidth=tempWidth;
	}
	if(Log.isDebug()) log.debug("Out of setsizeresolution");
	if (document.source != null)
	{
		document.setSize(documentResizedWidth, documentResizedHeight);
	}
	//////////////////////////////
	// While resizing, the scroll position of the page changes a little bit.
	// To avoid this, the method 'docSyncDuringSeek' is invoked
	docSyncDuringSeek(Math.round(videoDisplay.playheadTime));

}

/**
 * This method is invoked according to the video playhead time.
 * It changes the current slide/page of document according to the video playhead time.
 *
 * @param timeValue the current playhead time.
 * @return void.
 *
 */
public function syncSlidewithVideo(timeValue:Number):void
{
	var count:int;
	var time_value:Number;
	try
	{
		for (count=0; count < pptXmlDataArrColl.length; count++)
		{
			time_value=pptXmlDataArrColl[count].time;
			
			if (timeValue == time_value)
			{
				///////To show document tab when it is invoked///////
				tn1.selectedChild=doc;
				loadSlide(Math.round(videoDisplay.playheadTime), count);
			}
		}
	}
	catch (err:Error)	{
		if(Log.isError()) log.error("Error in syncSlidewithVideo method in PlaybackCode.as"+ err.getStackTrace());
	}
}

/**
 * This method is invoked when we seek the video.
 * It is called from the method videoPlayheadUpdateEventHandler.
 * It changes the current slide/page of document according to the new time of the seekBar.
 *
 * @param timeValue the current playhead time.
 * @return void.
 */
public function docSyncDuringSeek(timeValue:Number):void
{
	var count:int;
	var isSlideLoaded:Boolean=false;
	var prevCount:int;
	var time_value:Number;
	
	lastPPTLoadedTime=videoDisplay.playheadTime;
	
	try
	{
		for (count=0; count < pptXmlDataArrColl.length; count++)
		{
			time_value=pptXmlDataArrColl[count].time;
			
			// To load slide loaded at that second (if any)
			if (timeValue == time_value)
			{
				///////To show document tab when it is invoked///////
				isSlideLoaded=true;
				tn1.selectedChild=doc;
				if (doc.visible == false)
				{
					doc.visible=true;
				}
				loadSlide(Math.round(videoDisplay.playheadTime), count);
				break;
			}
			// To load slide loaded earlier (i.e. at some time less than current time)
			if (timeValue < time_value)
			{
				isSlideLoaded=true;
				if (doc.visible == false)
				{
					doc.visible=true;
				}
				prevCount=count - 1;
				loadSlide(Math.round(videoDisplay.playheadTime), prevCount);
				break;
			}
			else
			{
				prevCount=count;
			}
		}
		if (!isSlideLoaded)
		{
			loadSlide(Math.round(videoDisplay.playheadTime), prevCount);
		}
	}
	catch (err:Error)	{
		if(Log.isError()) log.error("Error in docSyncDuringSeek method in PlaybackCode.as"+ err.getStackTrace());
	}
}

public function loadSlide(timeValue:Number, count:int):void
{
	//checks whether the arraycollection that hold xml value of doc is not null.
	if (pptXmlDataArrColl != null)
	{
		if ((pptXmlDataArrColl[count].fileName) == null)
		{
			return;
		}
		
		documentCurrentScrollPosX=pptXmlDataArrColl[count].scrollX;
		documentCurrentScrollPosY=pptXmlDataArrColl[count].scrollY;
		
		if ((pptXmlDataArrColl[count].fileName) == pptFileName)
		{
			if (doc.visible == false)
			{
				doc.visible=true;
			}
			document.setCurrentPage(parseFloat(pptXmlDataArrColl[count].page));
			//document.setScrollPosition(new edu.amrita.aview.core.documentSharing.Print2Flash.Point(scrollXvalue,scrollYvalue));	         			   
			
			/////////////Rotation/////////////////
			if (pptXmlDataArrColl[count].rotation != documentRotateStatusFlag)
			{
				document.Rotate();
				documentRotateStatusFlag=pptXmlDataArrColl[count].rotation;
			}
			//vat tempevent:	         			  
			/////To highlight the Slide number in the list according to the slide change/////
			for (var j:int=0; j < pptSlideNumberArray.length; j++)
			{
				if (pptSlideNumberArray[j].index == count)
				{
					list.selectedIndex=pptSlideNumberArray[j].lPntr;
					/* if(pptSlideNumberArray.length>13)
					{
						list.verticalScrollPosition+=list.selectedIndex*.1;
					
						This can be used instead (if needed) [to display last set of slides]:
						updateComplete = "txtChatBox.verticalScrollPosition = txtChatBox.maxVerticalScrollPosition + 1"
					} */
					break;
				}
			}
		}
		else
		{
			if (pptXmlDataArrColl[count].tab != "tab")
			{
				tn.selectedChild=slide;
				pptFileName=pptXmlDataArrColl[count].fileName;
				document.source=xmlPath + "RecordFilesAview/Slides/" + pptFileName;
				document.setCurrentPage(parseFloat(pptXmlDataArrColl[count].page));
				document.setScrollPosition(new edu.amrita.aview.core.playback.oldPlayback.Print2Flash.Point(documentCurrentScrollPosX, documentCurrentScrollPosY));
			}
		}
		/////To show slide tab in tabnavigator/////
		tn.selectedChild=slide;
	}
}

/**************************************** PART 4 ********************************************************
 * **************************This portion handles the whiteboard playback **************************************************/


/**
* This method handles the ResultEvent for the search of the recorded whiteboard xml file.
* Retrieves all the items in whiteboard XML file to the array collection named whitexml_data.
* Retrieves the Lecture number from whiteboard and displays it using a label.
*
* @param ResultEvent Describes the resultevent for whiteboard.
* @return void
*/
private function WBXMLFileSearchResultHandler(e:ResultEvent):void
{
	WBLoadCompleteFlag=1;
	SetSource();
	WBXmlDataArrColl=new ArrayCollection();
	if (e.result.Items.item is ArrayCollection)
	{
		WBXmlDataArrColl=e.result.Items.item as ArrayCollection;
	}
	else if (e.result.Items.item is ObjectProxy)
	{
		WBXmlDataArrColl=new ArrayCollection(ArrayUtil.toArray(e.result.Items.item));
	}
	else
	{
		try
		{
			WBXmlDataArrColl=e.result.Items.item as ArrayCollection;
		}
		catch (err:Error){
			if(Log.isError()) log.error("Error in WBXMLFileSearchResultHandler method"+ err.getStackTrace());
		}
	}
	
	hboxWBLectureDetail=new HBox;
	can.addChild(hboxWBLectureDetail);
	pageNoWBLabelDispObj=new Label();
	hboxWBLectureDetail.addChild(pageNoWBLabelDispObj);
	lectureNameWBobj=new Label();
	lectureNameWBobj.move((can.width) / 2, 0);
	hboxWBLectureDetail.addChild(lectureNameWBobj);
	WBXmlDataArrCollReplica=WBXmlDataArrColl;
}

/**
* This method handles the FaultEvent for the search of the recorded whiteboard xml file.
* If fault is found the method redirects to the error display
*
* @param FaultEvent Describes the faultevent for whiteboard.
* @return void
*/
private function WBXMLFileSearchFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("playback::oldPlayback::PlaybackCode::WBXMLFileSearchFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	Alert.show("Error while loading Whiteboard file\nPlease contact A-VIEW Administrator. Fault string:" + event.fault.faultString, "Server Error", 0, this, closeFileMissing);
	WBLoadCompleteFlag=-1;
	SetSource();
}

/**
* This method maps the pencil thickness to the text font size.
* (Improvement)This is a hard corded method can be mapped to xml file and read from the same
*
* @param thickness_temp of type int, The thickness of the pencil
* @return int, the font value of the text tool
*/
private function WBthicknessToFontMapping(thickness_temp:int):int
{
	var thickness_result:int;
	switch (thickness_temp)
	{
		case 1:
			
			thickness_result=12;
			break;
		case 2:
			thickness_result=14;
			break;
		case 3:
			thickness_result=16;
			break;
		case 4:
			thickness_result=18;
			break;
		case 5:
			thickness_result=20;
			break;
		case 6:
			thickness_result=24;
			break;
		case 7:
			thickness_result=28;
			break;
		case 8:
			thickness_result=30;
			break;
		case 9:
			thickness_result=33;
			break;
		case 10:
			thickness_result=36;
			break;
	}
	return (thickness_result);

}


/**
* This method is invoked when normal playback is occuring.
* The points of the whiteboard are read from the whitexml_data array coolection which are read from the xml files
* And according to the video playhead time ,the whiteboard is drawn
* This method inturns call the  playWhiteBoardLogic() which has the logic of whiteboard drawing
*  @return void
*/

private var WBfirstTime:Boolean=true;

private function syncWhiteboardwithVideo():void
{
	CurrentWhiteboardDocumentChatSyncPointer=CurrentPlayheadtime;
	var i:int, j:int;
	if (WBXmlDataArrColl != null)
	{
		for (i=0; i < WBXmlDataArrColl.length - 1; i++)
		{
			if (WBXmlDataArrColl[i].time > CurrentPlayheadtime)
			{
				break;
			}
			if (CurrentPlayheadtime == parseInt(WBXmlDataArrColl[i].time))
			{
				///////To change the tab when whiteboard is called/////////		
				tn1.selectedChild=can;
				playbackWBLogic(i, 0, 0);
			}
		}
		
		if (WBXmlDataArrColl.length > 1)
		{
			if (CurrentPlayheadtime == parseInt(WBXmlDataArrColl[WBXmlDataArrColl.length - 1].time))
			{
				if (WBXmlDataArrColl[WBXmlDataArrColl.length - 2].graphicnumber != WBXmlDataArrColl[WBXmlDataArrColl.length - 1].graphicnumber)
				{
					if (WBXmlDataArrColl[WBXmlDataArrColl.length - 1].selectedtool == "txt")
					{
						var temp_thick:int;
						temp_thick=WBthicknessToFontMapping(parseInt(WBXmlDataArrColl[WBXmlDataArrColl.length - 1].linethickness));
						var txt:Text=new Text();
						var tempX1:String=WBXmlDataArrColl[WBXmlDataArrColl.length - 1].x;
						var tempY1:String=WBXmlDataArrColl[WBXmlDataArrColl.length - 1].y;
						txt.x=parseInt(tempX1.substring(0, tempX1.indexOf("$")));
						;
						txt.y=parseInt(tempY1.substring(0, tempY1.indexOf("$")));
						;
						txt.text=WBXmlDataArrColl[WBXmlDataArrColl.length - 1].textdata;
						txt.setStyle('fontSize', temp_thick);
						txt.setStyle('color', WBXmlDataArrColl[WBXmlDataArrColl.length - 1].linecolor);
						can.addChild(txt);
					}
					
				}
			}
		}
	}
}

/**
* This method is invoked by three other methods playWhiteBoard,whiteboardRedraw, redrawWhiteBoard..
* This method has the logic of whiteboard drawing.
* According to the tools selected the drawing the logic for various tools is described based on the live whiteboard module
* This method also does the scaling for mapping the content in the available space
* @param i - the cuurent drawing object
* @param xf - current whiteboard width
* @param yf - current whiteboard height
*  @return void
*/

private function playbackWBLogic(i:int, xf:Number, yf:Number):void
{
	var XX1:Number;
	var XX2:Number;
	var YY1:Number;
	var YY2:Number;
	//checks whether the arraycollection that hold xml value of wb is not null.
	if (WBXmlDataArrColl != null)
	{
		if (WBXmlDataArrColl[i].selectedtool != "tab")
		{
			var tempX1:String=WBXmlDataArrColl[i].x;
			var tempY1:String=WBXmlDataArrColl[i].y;
			var tempX2:String=WBXmlDataArrColl[i + 1].x;
			var tempY2:String=WBXmlDataArrColl[i + 1].y;
			
			var tempW2:Number=parseInt(tempX2.substring(tempX2.indexOf("$") + 1, tempX2.length));
			var tempH2:Number=parseInt(tempY2.substring(tempY2.indexOf("$") + 1, tempY2.length));
			
			
			if ((currentWhiteboardWidth != tempW2) || (currentWhiteboardHeight != tempH2))
			{
				currentWhiteboardWidth=parseInt(tempX1.substring(tempX1.indexOf("$") + 1, tempX1.length));
				currentWhiteboardHeight=parseInt(tempY1.substring(tempY1.indexOf("$") + 1, tempY1.length));
				XX1=parseInt(tempX1.substring(0, tempX1.indexOf("$")));
				XX2=parseInt(tempX2.substring(0, tempX2.indexOf("$")));
				YY1=parseInt(tempY1.substring(0, tempY1.indexOf("$")));
				YY2=parseInt(tempY2.substring(0, tempY2.indexOf("$")));
			}
			else
			{
				XX1=parseInt(tempX1.substring(0, tempX1.indexOf("$")));
				XX2=parseInt(tempX2.substring(0, tempX2.indexOf("$")));
				YY1=parseInt(tempY1.substring(0, tempY1.indexOf("$")));
				YY2=parseInt(tempY2.substring(0, tempY2.indexOf("$")));
			}
			var xFactor:Number;
			var yFactor:Number
			if (switchWhiteboardRedrawFlag == true)
			{
				var tempWW1:Number=parseInt(tempX1.substring(tempX1.indexOf("$") + 1, tempX1.length));
				var tempHH1:Number=parseInt(tempY1.substring(tempY1.indexOf("$") + 1, tempY1.length));
				xFactor=xf / tempWW1;
				yFactor=yf / tempHH1;
				switchWhiteboardRedrawFlag=false;
			}
			else
			{
				///////////////////////////////////////////////////
				// Earlier we were using whiteboard canvas's width and height for scaling.
				// But during first seek/drag its width and height is set as zero because of this some drawings are not shown 
				// So we now use tab navigator which contain this whiteboard canvas  for scaling.
				// Issue #339 ---START
				xFactor=tn1.width / currentWhiteboardWidth;
				yFactor=tn1.height / currentWhiteboardHeight;
					// Issue #339 ---END
			}
			
			XX1=XX1 * xFactor;
			YY1=YY1 * yFactor;
			XX2=XX2 * xFactor;
			YY2=YY2 * yFactor;
			
			////////////To clear the whiteboard according to the change in  lecture & pageno ////////////////	
			if (currentWBLectureName != WBXmlDataArrColl[i].info || currentPageNumber != WBXmlDataArrColl[i].pageno)
			{
				objSprite.graphics.clear();
				clearWBTextTool();
			}
			
			switch (WBXmlDataArrColl[i].selectedtool)
			{
				///////To draw the straight line//////
				case "st":
					if ((WBXmlDataArrColl[i + 1].selectedtool == "st") && (WBXmlDataArrColl[i].graphicnumber == WBXmlDataArrColl[i + 1].graphicnumber))
					{
						objSprite.graphics.moveTo(XX1, YY1);
						objSprite.graphics.lineStyle(WBXmlDataArrColl[i].linethickness, WBXmlDataArrColl[i].linecolor);
						objSprite.graphics.lineTo(XX2, YY2);
						
					}
					break;
				
				////////To draw the freehand///////	      
				case "fh":
					objSprite.graphics.lineStyle(WBXmlDataArrColl[i].linethickness, WBXmlDataArrColl[i].linecolor);
					objSprite.graphics.moveTo(XX1, YY1);
					if ((WBXmlDataArrColl[i + 1].selectedtool == "fh") && (WBXmlDataArrColl[i].graphicnumber == WBXmlDataArrColl[i + 1].graphicnumber))
					{
						objSprite.graphics.lineTo(XX2, YY2);
					}
					break;
				
				///////To draw the circle///////  
				case "c":
					if ((WBXmlDataArrColl[i + 1].selectedtool == "c") && (WBXmlDataArrColl[i].graphicnumber == WBXmlDataArrColl[i + 1].graphicnumber))
					{
						var c_r:Number=Math.sqrt((XX2 - XX1) * (XX2 - XX1) + (YY2 - YY1) * (YY2 - YY1));
						objSprite.graphics.lineStyle(WBXmlDataArrColl[i].linethickness, WBXmlDataArrColl[i].linecolor);
						objSprite.graphics.drawCircle(XX1, YY1, c_r);
					}
					break;
				
				///////To draw the rectangle///////             
				case "r":
					if ((WBXmlDataArrColl[i + 1].selectedtool == "r") && (WBXmlDataArrColl[i].graphicnumber == WBXmlDataArrColl[i + 1].graphicnumber))
					{
						objSprite.graphics.lineStyle(parseInt(WBXmlDataArrColl[i].linethickness), WBXmlDataArrColl[i].linecolor);
						objSprite.graphics.drawRect(XX1, YY1, (XX2 - XX1), (YY2 - YY1));
					}
					break;
				
				//////To clear the whiteboard///////                        				
				case "clr":
					if (WBXmlDataArrColl[i + 1].selectedtool == "restore")
					{
						if (can.contains(objUIComponent))
						{
							can.removeChild(objUIComponent);
						}
					}
					else
					{
						objSprite.graphics.clear();
						clearWBTextTool();
					}
					break;
				//////To restore the whiteboard///////
				case "restore":
					if (!can.contains(objUIComponent))
					{
						can.addChild(objUIComponent);
					}
					break;
				
				/////To erase the whiteboard//////
				case "e":
					objSprite.graphics.moveTo(XX1, YY1);
					objSprite.graphics.lineStyle(5, 0xffffff);
					if ((WBXmlDataArrColl[i + 1].selectedtool == "e") && (WBXmlDataArrColl[i].graphicnumber == WBXmlDataArrColl[i + 1].graphicnumber))
					{
						objSprite.graphics.lineTo(XX2, YY2);
					}
					break;
				/////To draw the text///////
				case "txt":
					try
					{
						var temp_thick:int;
						temp_thick=WBthicknessToFontMapping(parseInt(WBXmlDataArrColl[i].linethickness));
					}
					catch (err:Error){
						if(Log.isError()) log.error("Error in playbackWBLogic method"+ err.getStackTrace());
					}
					var temptextid:String=WBXmlDataArrColl[i].textdata;
					temptextid=temptextid.substring(0, temptextid.search("_"));
					if ("close" != temptextid)
					{
						var txt:Text=new Text();
						txt.x=XX1;
						txt.y=YY1;
						txt.text=WBXmlDataArrColl[i].textdata;
						txt.setStyle('fontSize', temp_thick);
						txt.setStyle('color', WBXmlDataArrColl[i].linecolor);
						can.addChild(txt);
					}
				
			}
			
			var lectinfo:String=WBXmlDataArrColl[i].info;
			/////////////////////////
			// lectinfo was null. So it was showing error: null object reference
			// Issue #5
			if (lectinfo)
			{
				var lectinfotemp:Number=parseInt(lectinfo.substring(lectinfo.indexOf("$") + 1, lectinfo.length));
				lectureNameWBobj.text="Lecture : " + lectinfo.substring(lectinfo.indexOf("$") + 1, lectinfo.length);
			}
			currentWBLectureName=WBXmlDataArrColl[i].info;
			
			currentPageNumber=WBXmlDataArrColl[i].pageno;
			pageNoWBLabelDispObj.text="Page No:" + WBXmlDataArrColl[i].pageno;
		}
	}
}

/**
 * This method is called to redraw the whiteboard when playhead slider is dragged.
 *  This is called by modules.playback.fxcomponents.controls.FXVideo.as
 *
 * @param releaseTime Describe the time at which the playhead thumb is released after dragging.
 * @return void
 */
public function WBRedrawDuringSeek(releasetime:Number):void
{
	if(Log.isDebug()) log.debug("In Whiteboard redraw, playheadTime: " + videoDisplay.playheadTime);
	/* lastWBRedrawTime describes the time at which whiteboard was redrawn. */
	lastWBRedrawTime=videoDisplay.playheadTime;
	// Clear Whiteboard
	objSprite.graphics.clear();
	
	if (WBXmlDataArrColl != null)
	{
		for (var i:int=0; i < WBXmlDataArrColl.length - 1; i++)
		{
			if (WBXmlDataArrColl[i].time <= releasetime)
			{	
				playbackWBLogic(i, 0, 0);
			}
			else
			{
				break;
			}
		}
	}
}

/**
* This method is called when switch view method is used.
* This methos is used to redraw the Whiteboard when the view is swtiched
* The objects on the whiteboard are drawn according to the playheadtime.
*
* @param limit describes the video playhead time
* @param xf describes the width of the canvas.
* @param yf describes the height of the canvas.
* @return void
*/

private function redrawWBduringResize(limit:Number, xf:Number, yf:Number):void
{
	if (WBXmlDataArrColl != null)
	{
		///////To clear the whiteboard///////
		objSprite.graphics.clear();
		clearWBTextTool();
		
		for (var i:int=0; i < WBXmlDataArrCollReplica.length - 1; i++)
		{
			if (parseInt(WBXmlDataArrCollReplica[i].time) > limit)
				break;
			///////To change the tab when whiteboard is called/////////		
			tn1.selectedChild=can;
			switchWhiteboardRedrawFlag=true;
			playbackWBLogic(i, xf, yf);
		}
	}
}

/**
* This method is used to clear the text tool of Whiteboard
*
* @return void
*/
private function clearWBTextTool():void
{
	var str:Object;
	for (var i:int=0; i < can.getChildren().length; i++)
	{
		str=can.getChildAt(i);
		var abc:String=str.valueOf();
		if (abc.search("Text") != -1)
		{
			can.removeChildAt(i);
			i--;
		}
	}
}

/**************************************** PART 5 ************************************************
 ***************************This portion handles the chat playback **************************************************/

/**
 * This method is used for handling the ResultEvent for chat
 * If the chat xml files is successfully found this method reads the whole content and places in a chatxml_data arrayCollection
 *
 * @param ResultEvent Describes the resultevent for chat.
 * @return void
 */
private function chatXMLFileSearchResultHandler(e:ResultEvent):void
{
	chatLoadCompleteFlag=1;
	SetSource();
	chatXmlDataArrColl=new ArrayCollection();
	if (e.result.Items.item is ArrayCollection)
	{
		chatXmlDataArrColl=e.result.Items.item as ArrayCollection;
	}
	else if (e.result.Items.item is ObjectProxy)
	{
		chatXmlDataArrColl=new ArrayCollection(ArrayUtil.toArray(e.result.Items.item));
	}
	else
	{
		chatXmlDataArrColl=e.result.Items.item as ArrayCollection;
		
	}
}

/**
* This method is used for handling the FaultEvent for chat
* If fault is found the method redirects to the common error display method
*
* @param FaultEvent Describes the faultevent for chat.
* @return void
*/
private function chatXMLFileSearchFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("playback::oldPlayback::PlaybackCode::chatXMLFileSearchFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	Alert.show("Error while loading Chat file\nPlease contact A-VIEW Administrator. Fault string:" + event.fault.faultString, "Server Error", 0, this, closeFileMissing);
	chatLoadCompleteFlag=-1;
	SetSource();
}


/**
*  This method is invoked when recorded chat messages are found in time sequence
*  According to the video playhead time ,the chat is appears in the chat area.
*/
private function syncChatwithVideo():void
{
	var i:int;
	var timervalue1:Number;
	CurrentWhiteboardDocumentChatSyncPointer=CurrentPlayheadtime;
	timervalue1=CurrentPlayheadtime;
	if (chatXmlDataArrColl != null)
	{
		for (i=0; i < chatXmlDataArrColl.length; i++)
		{
			if (timervalue1 == chatXmlDataArrColl[i].time)
			{
				///////To change the tab when chat is called////////
				// This is temporarily removed until chat code is working fine
				//tn.selectedChild=chat;
				chatMsg=chatXmlDataArrColl[i].message + "\r\r " + chatMsg;
			}
		}
	}
	if (chatArea)
	{
		chatArea.text="->" + chatMsg;
	}

}



/**
* This method is used to redraw the Chat when playhead slider is dragged.
* This method is called by modules.playback.fxcomponents.controls.FXVideo.as
*
*@param releaseTime Describe the time at which the playhead thumb is released after dragging.
*/

public function chatReloadDuringSeek(releaseTime:Number):void
{
	var flag:Boolean=false;
	if (chatXmlDataArrColl != null)
	{
		/////////////////////////
		// chatArea was null. So it was showing error: null object reference
		// Issue #5
		if (chatArea)
			chatArea.text="";
		chatMsg="";
		
		for (var i:int=0; i < chatXmlDataArrColl.length; i++)
		{
			if (chatXmlDataArrColl[i].time > releaseTime)
			{
				/////////////////////////
				// chatArea was null. So it was showing error: null object reference
				// Issue #5
				if (chatArea)
					chatArea.text="";
				chatMsg="";
				flag=true;
				break;
			}
			else if (chatXmlDataArrColl[i].time < releaseTime)
			{
				/////////////////////////
				// chatArea was null. So it was showing error: null object reference
				// Issue #5
				if (chatArea)
					chatArea.text="";
				chatMsg="";
				flag=false;
				break;
			}
		}
	}
	if (flag)
	{
		if (chatXmlDataArrColl != null)
		{
			/////////////////////////
			// chatArea was null. So it was showing error: null object reference
			// Issue #5
			if (chatArea)
				chatArea.text="";
			chatMsg="";
			for (var j:int=0; j < chatXmlDataArrColl.length; j++)
			{
				if (chatXmlDataArrColl[j].time < releaseTime)
				{
					chatMsg+=chatXmlDataArrColl[j].message + "\r\r ";
				}
			}
		}
	}
	if (!flag)
	{
		if (chatXmlDataArrColl != null)
		{
			/////////////////////////
			// chatArea was null. So it was showing error: null object reference
			// Issue #5
			if (chatArea)
				chatArea.text="";
			chatMsg="";
			
			for (j=0; j < chatXmlDataArrColl.length; j++)
			{
				if (chatXmlDataArrColl[j].time < releaseTime)
				{
					chatMsg+=chatXmlDataArrColl[j].message + "\r\r ";
				}
			}
		}
	}
	if (chatArea)
	{
		chatArea.text="->" + chatMsg;
	}
}


/**
* This method is used to clear the ChatArea & Whiteboard.
* This method is called by modules.playback.fxcomponents.controls.FXVideo.as
* @return void
*/
public function clearWBChatifDataisNull():void
{
	if (WBXmlDataArrColl != null)
	{
		objSprite.graphics.clear();
		clearWBTextTool();
		
	}
	
	if (chatXmlDataArrColl != null)
	{
		/////////////////////////
		// chatArea was null. So it was showing error: null object reference
		// Issue #5
		if (chatArea)
			chatArea.text="";
		chatMsg="";
	}
}


/********************************************** PART 6 ********************************************************************************************/
/******************************These methods handles the video playback and video playhead slider drag and click events*************************************************************************************************************/

/**
 * This method is used for handling the VideoEvent. This handles the video slider drag and click
 * This also invokes document, whiteboard and chat playback during the course of this event.
 * @param event Video Event
 * @return void
 */
private function videoPlayheadUpdateEventHandler(event:Object):void
{
	updateTimer();
	if(Log.isInfo()) log.info(temp + "(In Update Handler): " + videoDisplay.playheadTime);
	
	//Normal playback
	if (seekBarDragged == false)
	{
		seekBar.value=videoDisplay.playheadTime;
		
		//videoDisplay.removeEventListener(VideoEvent.PLAYHEAD_UPDATE,videoPlayheadUpdateEventHandler);
		//START----------------------------------------
		//Check if the difference between last wb redraw during seek and current playhead time greater than 1 sec
		//If yes, then invoke method WBRedrawDuringSeek()
		//else, do nothing.
		//END------------------------------------------
		if ((uint(Number(videoDisplay.playheadTime) - Number(lastWBRedrawTime))) > 1)
		{
			WBRedrawDuringSeek(Math.round(videoDisplay.playheadTime));
			
		}
		else
		{
			
		}
		//Set last wb redrawn time as current playhead time
		lastWBRedrawTime=videoDisplay.playheadTime;
		//START----------------------------------------
		//Check if the difference between last ppt loaded time during seek and current playhead time greater than 1 sec
		//If yes, then invoke method docSyncDuringSeek()
		//else, do nothing.
		//END------------------------------------------
		if ((uint(Number(videoDisplay.playheadTime) - Number(lastPPTLoadedTime))) > 1)
		{
			docSyncDuringSeek(Math.round(videoDisplay.playheadTime));
		}
		else
		{
			
		}
		//Set last ppt loaded time as current playhead time
		lastPPTLoadedTime=videoDisplay.playheadTime;
		
		syncSlidewithVideo(Math.round(videoDisplay.playheadTime));
		
		CurrentPlayheadtime=parseInt(videoDisplay.playheadTime.toString());
		if (firstTime == true)
		{
			firstTime=false;
			videoDisplay.pause();
			if (xmlLoadErrorMessage != "")
			{
				Alert.show("Some error occured for loading:" + xmlLoadErrorMessage, "Playback", 0, this, PlayVideoifXMLErrorExist);
			}
			else
			{
				PopUpManager.removePopUp(pop_toolbox);
				hbox.visible=true;
				videoDisplay.play();
			}
		}
		//To display drawings drawn at time 0, 1 or before recording was started
		else if (Math.round(videoDisplay.playheadTime) == 1)
		{
			WBRedrawDuringSeek(1);
		}
		if (CurrentPlayheadtime != CurrentWhiteboardDocumentChatSyncPointer)
		{
			//video.playheadSlider.value=Math.round(video.playheadTime);
			syncSlidewithVideo(Math.round(videoDisplay.playheadTime));
			syncWhiteboardwithVideo();
			syncChatwithVideo();
		}
			//videoDisplay.addEventListener(VideoEvent.PLAYHEAD_UPDATE,videoPlayheadUpdateEventHandler);
	}
	//While dragging seekbar (when seekBarDragged=true)
	else
	{
		seekBarDragged=false;
		WBRedrawDuringSeek(Math.round(videoDisplay.playheadTime));
		chatReloadDuringSeek(Math.round(videoDisplay.playheadTime));
		docSyncDuringSeek(Math.round(videoDisplay.playheadTime));
//				if(PlayPause==PlayPause_Pause)
//				{
//					videoDisplay.play();
//				}
	}
}

/**
 * This method is invoked when continue of the error Alert is clicked
 * This error Alert will pop up when some errors are there when loading the files, like file not found or corrupted file
 * This method continues the playing of the video
 * @return void
 */
private function PlayVideoifXMLErrorExist(eve:CloseEvent):void
{
	PopUpManager.removePopUp(pop_toolbox);
	hbox.visible=true;
	videoDisplay.play();
}

/**
* This method is used for handling video slider click event
* This method sync the document with the video slider click.
* @param MouseEvent to capture the mouse event
* @return void
*/
// TODO: Delete this method and rewrite for seekBar click event
private function VideoPlayheadClickEventHandler(event:MouseEvent):void
{
	CurrentSliderClickedPoint=Math.round(event.currentTarget.value);
	
	if (CurrentSliderClickedPoint)
	{
		/* video.playheadTime = CurrentSliderClickedPoint;
		video.playheadSlider.value = CurrentSliderClickedPoint;*/
		syncSlidewithVideo(CurrentSliderClickedPoint);
		/* video.playheadSlider.addEventListener(MouseEvent.MOUSE_UP,VideoPlayheadMouseouteventHandler); */
	}
}

/**
 * This method is invoked when mouse click happens on the seekBar
 * It invokes the mousedown event handler (stopUpdation()) first and after 200 milli second,
 * it invokes the mouseup event handler (seekVideo())
 * @return void
 */
private function seekVideoOnClick():void
{
	stopUpdationOnMouseDown();
	setTimeout(seekVideo, 200);
}

/**
 * This method is invoked when mouse down or click event happens on the seekBar
 * This method removes the eventHandler which updates the seekbar according to video PlayheadTime
 * @return void
 */
private function stopUpdationOnMouseDown():void
{
	///////////////////////////////////////////////////
	// Earlier we were internally pausing the video before loading the components while seeking.
	// This was causing some issues with the play/pause button. It was not working sometimes. 
	// So removed the LOC for doing so.
	// Issue #315 ---START
	// Issue #315 ---END
	videoDisplay.removeEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE, videoPlayheadUpdateEventHandler);
}

//This variable is used for tracking the time at seekBar change event
private var temp:String="Before seeking";

/**
 * This method is invoked when thumb release or click event happens on the seekBar
 * This resumes the video from the time which we get from the seekBar and adds the eventHandler which updates the seekbar according to video PlayheadTime
 * @return void
 */
private function seekVideo():void
{
	////////////////////////////////////////
	//Previously when the seek bar was dragged by the user to the end position 
	//the playback  used to get stuck.
	//So we added code to check the seek bar value and called the method videostop().
	
	//START----------------------------------------
	//Check if condition seek bar value equal to total time of video dispaly is true.
	//If yes, then called the method videostop()
	//END------------------------------------------
	
	//Alert.show("Thumb released.....",'',0,this);
	if (seekBar.value >= videoDisplay.totalTime)
	{
		videostop();
	}
	else if (flagVideoLoaded == true)
	{
		//videoDisplay.pause();
		if(Log.isDebug()) log.debug("Just before seeking:videoDisplay.playheadTime:" + videoDisplay.playheadTime);
		videoDisplay.playheadTime=seekBar.value;
		temp="After seeking";
		if(Log.isDebug()) log.debug(temp + ":videoDisplay.playheadTime: " + videoDisplay.playheadTime + ":seekBar.value:" + seekBar.value);
		///////////////////////////////////////////////////
		// Earlier we were internally pausing the video before loading the components while seeking.
		// This was causing some issues with the play/pause button. It was not working sometimes. 
		// So removed the LOC for doing so.
		// Issue #315 ---START
		// Issue #315 ---END
		seekBarDragged=true;
		///////////////////////////////////////////////////
		// Here, we used to play the internally paused video after the components while seeking.
		// This was causing some issues with the play/pause button. It was not working sometimes. 
		// So removed the LOC for doing so.
		// Issue #315 ---START
		// Issue #315 ---END
		videoDisplay.addEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE, videoPlayheadUpdateEventHandler);
		updateTimer();
	}
}

/**
 * This method is invoked when the video is loaded successfully to the video player
 * This calculates the total time of the video and sets the seekBar maximum value
 * This also enables the Play/Pause button and the seekBar
 * @return void
 */
private function videoLoaded(videoEvent:Object):void
{
	flagVideoLoaded=true;
	seekBar.enabled=true;
	seekBar.maximum=videoDisplay.totalTime;
	btnPlay.enabled=true;
}

/**
 * This method is invoked when the video playing is complete
 * This does the needed initialization again, for the next time playing of the lecture
 * @return void
 */
private function finishedPlaying(videoEvent:Object):void
{
	PlayPause=PlayPause_Play;
	clearWBChatifDataisNull();
	// Initialize and reload all the components of the lecture (doc, WB, chat) at time 0.
	SetToInitialStage();
}


/********************************************** PART 7 ********************************************************************************************/
/****These methods handles the clearing of playback flag and activating the LMS which is made inactive when placback is intialized*****/

/**
 * This method is invoked when A-VIEW Playback can not load the video file.
 * It is invoked from the methods 'searchVideoFileResultHandler' and 'searchVideoFileFaultHandler'.
 * This forcefully closes the A-VIEW Playback window.
 *
 * @return void
 */
private function closeFileMissing(evt:CloseEvent):void
{
	//For Web: Commented following logic.Since close() method not available for web.
	//this.close();
}

private var close_flag:Boolean=false;

/**
 * This method activates the LMS page which is made inactive when playback module is invoked
 * This executes the functions for closing the A-VIEW playback window and stoping the video
 * This function is invoked when we click the close button on the A-View playback window.
 * @return void
 */
//For Web: Changed private to public to access this variable from MainComponent.mxml file 
public function playbackWindowCloseHandler():void
{
	close_flag=true;
	if (hbox.visible == false)
	{
		if(Log.isDebug()) log.debug("Lecture is not loaded");
	}
	if (videoDisplay.source != null)
	{
		var eve:MouseEvent=new MouseEvent(MouseEvent.CLICK);
		if(Log.isInfo()) log.info("in close" + videoDisplay.source);
		videoDisplay.stop();
		videoDisplay.source="";
	}
	else
	{
		if(Log.isInfo()) log.info("In error" + videoDisplay.source);
		videoDisplay.source="";
	}
	videoCan.removeAllChildren();
	///////////////////////////
	// If the video is in full screen, the following code will close it 
	// when the user closes the Playback window.
	if (fullScreenInstance)
	{
		//For Web: Commented following logic.Since close() method not available for web.
		//fullScreenInstance.close();
	}
	//////////////////////////////////
	// Fix for Issue #237 ---STARTS
	// If the loading .swf file is being shown when the user closes the Playback window, 
	// removes the popup also before going back to the LMS module 
	if (pop_toolbox)
	{
		PopUpManager.removePopUp(pop_toolbox);
	}
	////////////////////////////////
	// We should remove the EventListeners which were added while initializing Playback window.
	// Otherwise they will be executed even if we close the playback window.
	if (searchFileService && searchFileService.hasEventListener(ResultEvent.RESULT))
	{
		searchFileService.removeEventListener(ResultEvent.RESULT, searchVideoFileResultHandler);
	}
	if (searchFileService && searchFileService.hasEventListener(FaultEvent.FAULT))
	{
		searchFileService.removeEventListener(FaultEvent.FAULT, searchVideoFileFaultHandler);
	}
	// Fix for Issue #237 ---ENDS
	// Resets the lms module to the default  
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lmsInst.killPlayback();
}







/********************************************** PART 8 ********************************************************************************************/
/**** This part handles the video player controls (i.e. play, pause, stop, seek, volume control etc...)*****/

/**
 * This method checks whether to play or pause the video
 * This is invoked when we click the play/pause button on the A-VIEW video player.
 * @return void
 */
private function videoPlayAndPause():void
{
	//Previously the condition here was checking whether video display is not playing
	//But some times,After stopping the video,if we try to play and then pause it the playing property of videodisplay
	//is not set as true because of this the play/pause button's icon remains as the same(pause icon).
	//So the condition has been changed to checking whether the icon of play/pause button is play or not
	if (PlayPause == PlayPause_Play)
	{
		if (videoDisplay.state == mx.events.VideoEvent.STOPPED)
		{
			// We should add the EventListener of type VideoEvent.PLAYHEAD_UPDATE for synchronization 
			//when the state of video dispaly is stopped.
			videoDisplay.addEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE, videoPlayheadUpdateEventHandler);
		}
		else
		{
		}
		videoDisplay.play();
		// Changes the icon of Play/Pause button to pause
		PlayPause=PlayPause_Pause;
		
		// If last event of the WB playback is clear, it removes 'objUIComponent'. 
		// So, for second time playing, it needs to be added.
		if (!can.contains(objUIComponent))
		{
			can.addChild(objUIComponent);
		}
	}
	else
	{
		videoDisplay.pause();
		// Changes the icon of Play/Pause button to Play
		PlayPause=PlayPause_Play;
	}
}

/**
 * This method stop the video if it is playing
 * This is invoked when we click the stop button on the A-VIEW video player.
 * @return void
 */
private function videostop():void
{
	videoDisplay.stop();
	// Changes the icon of Play/Pause button to Play
	PlayPause=PlayPause_Play;
	// Clears Whiteboard and Chat container 
	clearWBChatifDataisNull();
	// Initialize and reload all the components of the lecture (doc, WB, chat) at time 0.
	SetToInitialStage();
	////////////////////////////////
	// We should remove the EventListener.
	// Otherwise it will be executed even if we stop video.
	videoDisplay.removeEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE, videoPlayheadUpdateEventHandler);
}

/**
 * This method is used to call removeVolumeSlider() after 5 seconds.
 * This is invoked when mouseOut happens on 'btnVolume'.
 * @return void
 */
private function volumeMouseOut():void
{
	setTimeout(removeVolumeSlider, 5000);
}

/**
 * This method sets the visibility of volumeController to false
 * This is invoked from - mute(), change_volume().
 * @return void
 */
private function removeVolumeSlider():void
{
	volumeController.visible=false;
}

/**
 * This method changes the volume of the video according to the video slider
 * This is invoked when we change the value of volume slider.
 * @return void
 */
private function change_volume():void
{
	// Range of volume is from 0 to 1. 
	// So, to convert the value of slider, we divide the value by 100
	videoDisplay.volume=volumeController.value / 100;
	// If video was mute, then changes the icon of btn_volume after setting the volume
	if (MuteOnOff == Mute_On)
	{
		MuteOnOff=Mute_Off;
	}
	setTimeout(removeVolumeSlider, 800);
}

/**
 * This method mute or unmute the video
 * This is invoked when we click on 'btnVolume'.
 *
 * @return void
 */
private function mute():void
{
	if (MuteOnOff == Mute_Off)
	{
		previousVolume=volumeController.value;
		volumeController.value=0;
		videoDisplay.volume=0;
		// Changes the icon of 'btnVolume'
		MuteOnOff=Mute_On;
	}
	else
	{
		///////////////////////////////////////////////////
		// Earlier we were assign videoDisplay's volume as Vertical slider's value ranges from 0-100.
		// So volume is set to maximum when we click on the unmute button
		// To solve this issue we divided the previous volume value by 100.
		// Issue #690 ---START
		videoDisplay.volume=previousVolume / 100;
		// Issue #690 ---END
		volumeController.value=previousVolume;
		// Changes the icon of 'btnVolume'
		MuteOnOff=Mute_Off;
	}
	setTimeout(removeVolumeSlider, 500);
}

/**
 * This method is invoked when the mouse up happens on the seekBar
 * This formats the video time and convert it into the format minutes:seconds
 * @param int (time in seconds)
 * @return string (minutes:seconds)
 */
public function formatTime(value:int):String
{
	var result:String=(value % 60).toString();
	if (result.length == 1)
		result=Math.floor(value / 60).toString() + ":0" + result;
	else
		result=Math.floor(value / 60).toString() + ":" + result;
	return result;
}


/**
 * This method is invoked whenever the videoPlayhead is updated
 * This displays the current and total Video time
 * @return void
 */
public function updateTimer():void
{
	lblVideoTime.text=formatTime(videoDisplay.playheadTime) + " / " + formatTime(videoDisplay.totalTime);
}

/********************************************** PART 8 ENDS ********************************************************************************************/
