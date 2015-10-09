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
 * File	    	: VideoSharingScript.as
 * Module		: videoSharing
 * Developer(s) : LIVIN M.MIRANDA, ANU P,SOUMYA M.D
 * Reviewer(s)	: Sivaram SK, Meena S
 * 
 * VideoSharingScript.as file inculdes the player functions for video sharing module. This script 
 * is included in VideoSharing.mxml. 
 * 
 * */

import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;

import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.events.UncaughtErrorEvent;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.system.Security;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.controls.Alert;
import mx.controls.Label;
import mx.controls.VideoDisplay;
import mx.core.FlexGlobals;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.SliderEvent;
import mx.events.VideoEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;

/**
 * Platform specific imports
 */
applicationType::desktop
{
	import air.net.URLMonitor;
	//import edu.amrita.aview.core.videoSharing.VideoSharingWindow;
	import edu.amrita.aview.videoSharing.VideoSharingWindow;
}

/**
 * Pop-out icon
 */
[Bindable]
[Embed(source="assets/images/view-fullscreen1.png")]
public var popOutIcon:Class;
/**
 * Pop-in icon
 */
[Bindable]
[Embed(source="assets/images/windows_nofullscreen.png")]
public var popInIcon:Class;
/**
 * Variable that holds the video url which is loaded.
 */
public var videoURL:String="";
/**
 * Holds information about the type of User ie PRESENTER/VIEWER.
 */
public var userRole:String;
/**
 * Holds the current video status.
 */
public var videoStatus:String="";
/**
 * Sets to true when the netConnection is lost and
 * the module retries to connect
 */
public var isConnectionLost:Boolean=false;
/**
 * The url for the last video loaded on the client side
 * before reconnection
 */
public var videoURLLoadedBeforeReconnection:String="";
/**
 * The playheadtime when netconnection is lost.
 * This is used to play the video from the last position of video
 * after a successfull reconnection
 */
public var playHeadTimeBeforeReconnection:Number=0;
/**
 * Timer used to handle video actions and playhead time.
 */
public var playHeadUpdateTimer:Timer=new Timer(200);
/**
 * Variable to detect whether video is from YouTube or aview library.
 * sets to true when presenter loads a library video
 */
public var isLibraryVideo:Boolean=false;
/**
 * VideoDisplay variable used to create the player.
 */
public var libraryVideoPlayer:VideoDisplay;
/**
 * Set to true when the videoSharing module is popped out
 */
public var isPopOut:Boolean=false;
/**
 * Used to set the Play icon for Play Button.
 */
[Embed(source="assets/images/play.png")]
[Bindable]
private var playIcon:Class;
/**
 * Used to set the Pause icon for Play Button.
 */
[Embed(source="assets/images/pause.png")]
[Bindable]
private var pauseIcon:Class;
/**
 * Used to set the Sound icon for Volume Button.
 */
[Embed(source="assets/images/sound16.png")]
[Bindable]
private var soundIcon:Class;
/**
 * Used to set the Mute icon for Volume Button.
 */
[Embed(source="assets/images/mute16.png")]
[Bindable]
private var muteIcon:Class;
/**
 * Variable to hold the total video time length.
 */
[Bindable]
private var videoDuration:Number=0;

/**
 * Variable keeps track of whether autoRepeat option is set or not
 */
private var _autoRepeat:Boolean=false;
/**
 * Control that displays messages
 */
private var alertControl:Alert;
/**
 * Variable to hold the protocol used for video.
 */
private var protocolUsed:String;
/**
 * Holds the number of users plaing video in sync with presenter video.
 */
private var playingVideoCount:Number=0;
/**
 * Holds the number of user instances in which video has Loaded.
 */
private var loadedVideoCount:uint=0;
/**
 * Holds the number of user instances in which video has Paused.
 */
private var pausedVideoCount:uint=0;
/**
 * Holds the number of user instances in which video has Stopped.
 */
private var stoppedVideoCount:uint=0;
/**
 * Variable that holds YouTube video ID.
 */
private var youTubeVideoId:String;
/**
 * Loader variable used to load Youtube.
 */
private var youTubeVideoLoader:Loader=new Loader();
/**
 * Holds Youtube video.
 */
private var youTubePlayer:Object;
/**
 * Holds domain of the url.
 */
private var youTubeURL:String;
/**
 * Sets to true when youtube player's state is ready.
 */
private var isUTubePlayerReady:Boolean=false;
private var isYoutubeErrorMessageDisplayed:Boolean=false;
/**
 * Sets to true when youtube player is restarted.
 */
private var replayStarted:Boolean=false;
/**
 * Sets to true when a loaded video is played first time on the player
 */
private var isFirstPlayOfCurrentVideo:Boolean=false;
/**
 * The variable that holds the URL for current library video selected by preseter.
 */
private var playingLibraryVideoURL:String;
/**
 * Sets to true when the current playing video ends
 */
private var isPlayingVideoEnded:Boolean=false;
/**
 * Holds the url of stopped video
 * Used to check whether the video is stopped or not.
 */
private var lastStoppedVideoURL:String="";
/**
 * Logger to log events.
 */
private var log:ILogger=Log.getLogger("aview.edu.amrita.aview.videosharing.VideoSharing");
/**
 * The audio mute state
 */
private var muteState:String=AUDIO_UNMUTE;
/**
 * Holds the timeOut call references. 
 * needs to be cleared when the function is invoked.
 */
private var seekTimeOutHandle4:uint=0;

/**
 * Holds the timeOut call reference for seek. 
 * needs to be cleared when the function is invoked.
 */
private var seekTimeOutHandle5:uint=0;
/**
 * Holds the timeOut call reference. 
 * needs to be cleared when the function is invoked.
 */
private var playTimeOutHandle5:uint=0;
/**
 * Holds the timeOut call references. 
 * needs to be cleared when the function is invoked.
 */
private var handleTimeOutHandle:uint=0;

private var idleTimeOutHandle:uint=0;

/**
 * FolderName for vod folder
 */
private static const VOD_FOLDER:String="/vod/";
/**
 * Protocol separator
 */
private static const PROTOCOL_SEP:String="://";
/**
 * Non-secure url of youtube
 */
private static const UTUBE_URL:String="http://www.youtube.com";
/**
 * Secure url of youtube.
 */
private static const UTUBE_URL_SECURE:String="https://www.youtube.com";

// The following constants are used to hold the status values for youtube player
/**
 * -1 if the player is not ready
 */
private static const UTUBE_NOTREADY:int=-1;
/**
 * 0 if the player ends video playing
 */
private static const UTUBE_ENDED:int=0;
/**
 * 1 if the player is playing video
 */
private static const UTUBE_PLAYING:int=1;
/**
 * 2 if the player is paused the video
 */
private static const UTUBE_PAUSED:int=2;
/**
 * 3 if the player is in buffering state
 */
private static const UTUBE_BUFFERING:int=3;
/**
 * 5 if the youtube video is queued.
 */
private static const UTUBE_VIDEO_CUED:int=5;

//The status of  youtube video is ends here

/**
 * Holds the mute status for audio
 */
private static const AUDIO_MUTE:String="Mute";
/**
 * Holds the unmute status for audio
 */
private static const AUDIO_UNMUTE:String="Unmute";

//The following constants are holding the libraryVideoPlayer states
/**
 * Status value while the videoplayer state is playing
 */
private static const VIDEO_PLAYING:String="playing";
/**
 * Status value while the videoplayer state is paused
 */
private static const VIDEO_PAUSED:String="paused";
/**
 * Status value while the video player state is stopped
 */
private static const VIDEO_STOPPED:String="stopped";
/**
 * Status value while the videoplayer state is buffering
  */
private static const VIDEO_BUFFERING:String="buffering";
/**
 * Status value while the videoplayer state is disconnected
 */
private static const VIDEO_DISCONNECTED:String="disconnected";
/**
 * Status value while the videoplayer state is loading
 */
private static const VIDEO_LOADING:String="loading";
/**
 * Status value while the videoplayer state is rewinding
 */
private static const VIDEO_REWINDING:String="rewinding";
/**
 * Status value while the videoplayer state is seeking
 */
private static const VIDEO_SEEKING:String="seeking";

private var isRefreshVideo:Boolean=false;

private  var syncCommandTimer:Timer=new Timer(1000);

private var isSyncCommandTimerStarted:Boolean=false;

/**
 * Platform specific variables
 */
applicationType::desktop
{
	/**
	 * The fileSelection Dialog
	 */
	private var openFile:File=new File();
	/**
	 * Variable to check whether youtube url is available
	 */
	private var youtubeURLMonitor:URLMonitor;
	/**
	 *  popup window for video sharing
	 */
	private var videoSharingWindow:VideoSharingWindow=null;
}
applicationType::web
{
	/**
	 * The fileSelection Dialog
	 */
	private var openFile:FileReference=new FileReference();	
}

//The libraryVideoPlayer status ends

//---UI handling functions start-------------------

/**
 * @public
 * This method resets the video player and related UI controls
 * This is called when user clicks video sharing option or when Presenter control is
 * acquired  by or released from the current user.
 * 
 *
 * @return void
 * 
 */
public function resetPlayerControls():void
{
	btnMuteVolume.toolTip=null;
	userRole=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole;
	//The variable to hold the latest url available in videoCommandCollaborationObject(FMS shared object)
	var newURL:String=null;
	//IF videoURL is not null ,ie if a video is playing on client side
	///the latest URL is taken from the sharedobject and if its null
	//Then stop video and clear video player
	if (videoCommandCollaborationObject != null)
		
		newURL=videoCommandCollaborationObject.getData()[Constants.URL_INFO];
	
	if (videoURL != "" && videoURL != null)
	{
		if ((newURL == "" || newURL == null) && lengthLabel.text != "")
		{
			lengthLabel.text="0:0";
			try
			{
				if (isLibraryVideo)
				{
					clearVideoPlayer();
				}
				else
				{
					if (userRole != Constants.PRESENTER_ROLE)
						youTubeVideoLoader.unloadAndStop(true);
					else
					{
						if (!isConnectionLost && videoURLLoadedBeforeReconnection == "")
							youTubeVideoLoader.unloadAndStop(true);
					}
				}
			}
			catch (e:Error)
			{
				if(Log.isError()) log.error("Error in resetPlayerControls method:"+ e.getStackTrace());
			}
		}
	}
	//IF the current user's role is presenter , then reset the url display text
	if (userRole == Constants.PRESENTER_ROLE)
	{
		if (isLibraryVideo)
		{
			txtYoutubeURL.text="Paste YouTube URL here and hit enter key";
			txtYoutubeURL.setStyle("color", '#949494');
			txtYoutubeURL.setStyle("fontStyle", 'italic');
		}
		if (videoURL != "" && videoURL != null)
		{
			if ((newURL != "" && newURL != null))
			{
				protocolUsed=getProtocol(videoURL);
				if (protocolUsed == Constants.PROTOCOL_FMS_SERVER)
				{
					if (txtYoutubeURL.text != '' && txtYoutubeURL.text == 'Paste YouTube URL here and hit enter key')
						labelFileName.text=videoURL.substring(videoURL.lastIndexOf("/")+1, videoURL.length);
				}
				else
				{
					if (txtYoutubeURL.text != '' && txtYoutubeURL.text == 'Paste YouTube URL here and hit enter key')
						labelFileName.text=videoURL;
				}
			}
			else
			{
				//IF netConnection is lost and no video was playing when netconnetion is lost
				//clear video display controls 
				if (!isConnectionLost && videoURLLoadedBeforeReconnection == "")
				{
					labelFileName.text="";
					videoURL="";
					//sets to true as when a new video will be loaded this variable should be true
					isFirstPlayOfCurrentVideo=true;
				}
			}
		}
		if (muteState == AUDIO_MUTE)
			btnMuteVolume.toolTip=AUDIO_UNMUTE;
		else
			btnMuteVolume.toolTip=AUDIO_MUTE;
		setTimeout(repositionPlayerControlButtons, 100);
	}
	else if (fileManager != null)
	{
		removeAllPopUpWndw();
		if (alertControl)
			PopUpManager.removePopUp(alertControl);
	}
	setUIcontrols();
}

/**
 * 
 * @public
 * Resets video sharing module
 * stops library video or youtube player,clear the timers and removes the player
 * 
 * @return void 
 * 
 */
public function resetVideoSharing():void
{
	if (userRole == Constants.PRESENTER_ROLE && videoStatus != Constants.VIDEO_STATE_STOP && videoURL != null && videoURL != "")
	{
		updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_STOP, hSliderSeekbar.value);
	}
	stopPlayheadUpdate();
	try
	{
		//IF youtube video is playing, reset the video player
		if (youTubePlayer != null)
		{
			youTubePlayer.stopVideo();
			youTubePlayer="";
			youTubeVideoLoader.unloadAndStop(true);
			youTubePlayer=null;
		}
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in resetVideoSharing method:"+ e.getStackTrace());
	}
	try
	{
		//IF library video is playing the video player and related controls are displayed
		//then reset the player controls
		if (isLibraryVideo || (vBoxVideoPlayer.numChildren > 0))
		{
			isLibraryVideo=false;
			lengthLabel.text="0:0";
			labelPosition.text="0:0";
			closeLibraryVideoplayer();
			videoStatus="";
			libraryVideoPlayer=null;
			hSliderSeekbar.value=0;
		}
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in resetVideoSharing method:"+ e.getStackTrace());
	}
	videoURL="";
	
	if (vBoxVideoPlayer.numChildren > 0)
		vBoxVideoPlayer.removeAllChildren();
}


/**
 * 
 * @public
 * This function is called when window resizes.
 * @return void 
 * 
 */
public function resizeYoutubeVideoPlayer():void
{
	//The width of video player that holds the player.
	var widthVBox:Number=vBoxVideoPlayer.width;
	//#bugfix for 15672
	vBoxVideoPlayer.height=this.height*.75
	try
	{
		youTubePlayer.setSize(widthVBox, (vBoxVideoPlayer.height));
		youTubePlayer.setPlaybackQuality("medium");
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in vidYoutubeResize method:"+ e.getStackTrace());
	}
}

/**
 * 
 * @public
 * Position the player control buttons
 *
 * @return void 
 *  
 */
public function repositionPlayerControlButtons():void
{
	btnStop.x=((hSliderSeekbar.x + hSliderSeekbar.width) / 2) - 20;
	btnPlay.x=btnStop.x + btnStop.width + 2;
	btnRepeat.x=btnPlay.x + btnPlay.width + 2;
	if (fileManager)
	{
		fileManager.move((fileManager.parent.width / 2 - (fileManager.width / 2)), (fileManager.parent.height / 2 - (fileManager.height / 2)));
	}
}

/**
 * 
 * @private
 * This function is called on creation complete of the module or when application resets
 * It enables/disables the ui controls for current user
 *
 * @return void 
 *  
 */
private function setUIcontrols():void
{
	if (!ClassroomContext.IS_VIDEO_SHARING_ENABLED)
	{
		//label that is displayed when the module is disabled.
		var messageLabel:Label=new Label();
		messageLabel.text=Constants.MODULE_DISABLE_MSG;
		this.addElement(messageLabel);
		messageLabel.percentWidth=100;
		messageLabel.height=50;
		messageLabel.setStyle("textAlign", "center");
		messageLabel.setStyle("fontSize", "30");
		messageLabel.setStyle("color", "white");
		messageLabel.horizontalCenter=0;
		messageLabel.verticalCenter=-20;
		btnPopOut.visible=false;
		this.enabled=false;
	}
	if(!isPopOut)
		btnPopOut.setStyle("icon", popOutIcon);
	else
		btnPopOut.setStyle("icon", popInIcon);
	//enable/disable  the  UI controls for prsesenter
	if (userRole == Constants.PRESENTER_ROLE)
	{
		labelVideoStatusInfo.visible=true;
		hBoxPresenterControlContainer.visible=true;
		btnStop.visible=true;
		btnPlay.visible=true;
		btnRepeat.visible=true;
		hSliderSeekbar.enabled=true;
		btnMuteVolume.enabled=true;
		//lblPresenterstatus.visible=false;
		if(youTubePlayer!=null && videoURL!="" && videoURL!=null)
		{
			txtYoutubeURL.text=videoURL;
			labelFileName.text="";
		}
		
	}
	//enable/disable  the  UI controls for viewer
	else
	{
		labelVideoStatusInfo.visible=false;
		hBoxPresenterControlContainer.visible=false;
		btnStop.visible=false;
		btnPlay.visible=false;
		btnRepeat.visible=false;
		hSliderSeekbar.enabled=false;
		btnMuteVolume.enabled=false;
		//lblPresenterstatus.visible=true;
		
	}
	
	//adds seekbar event listener
	if (!hSliderSeekbar.hasEventListener(SliderEvent.THUMB_PRESS))
		hSliderSeekbar.addEventListener(SliderEvent.THUMB_PRESS, handlethumbPress);
	
	if (!isLibraryVideo)
	{
		setUTubeVideoPlayButton();
	}
	if (txtYoutubeURL.text != 'Paste YouTube URL here and hit enter key' && txtYoutubeURL.text != '')
		btnYoutubeURL.enabled=true;
	else
		btnYoutubeURL.enabled=false;
}

/**
 * 
 * @private
 * The mouse click handler for youtube url entry control
 * changes the styles for the textIngput.
 * 
 * @param event of type MouseEvent
 * @return void 
 * 
 */
private function urlTextControlClickHandler(event:MouseEvent):void
{
	if (txtYoutubeURL.text != '' && txtYoutubeURL.text != 'Paste YouTube URL here and hit enter key')
	{
		txtYoutubeURL.text=txtYoutubeURL.text;
		txtYoutubeURL.setStyle("color", '#000000');
		txtYoutubeURL.setStyle("fontStyle", 'normal');
	}
	else
	{
		txtYoutubeURL.text='';
		txtYoutubeURL.setStyle("color", '#000000');
		txtYoutubeURL.setStyle("fontStyle", 'normal');
	}
}

/**
 * 
 * @protected
 * The focus event handler for the url entry control
 * 
 * @param event of type FocusEvent
 * @return void 
 *  
 */
protected function urlTextControlFocusOutHandler(event:FocusEvent):void
{
	if (txtYoutubeURL.text == '' || txtYoutubeURL.text == 'Paste YouTube URL here and hit enter key')
	{
		txtYoutubeURL.text='Paste YouTube URL here and hit enter key';
		txtYoutubeURL.setStyle("color", '#949494');
		txtYoutubeURL.setStyle("fontStyle", 'italic');
	}
	else
	{
		txtYoutubeURL.text=txtYoutubeURL.text;
		txtYoutubeURL.setStyle("color", '#000000');
		txtYoutubeURL.setStyle("fontStyle", 'normal');
	}
}

/**
 * 
 * @protected
 * The keydown event handler for the url entry control
 * 
 * @param event of type KeyboardEvent
 * @return void 
 *  
 */
protected function urlTextControlkeyDownHandler(event:KeyboardEvent):void
{
	if (event.keyCode == 13)
	{
		preloadYoutubeVideo(StringUtil.trim(txtYoutubeURL.text));
		labelFileName.text='';
	}
}

//---UI handling functions ends-------------------


/**
 * 
 * @private
 * Removes all popup components related to this module
 * 
 * @return Object 
 * 
 */
private function removeAllPopUpWndw():Object
{
	// The variable that holds the popup windows that belongs 
	//to the systemManager of videoSharingWindow
	var childList:IChildList;
	
	if (isPopOut)
	{
		applicationType::desktop{
			childList=videoSharingWindow.systemManager.popUpChildren;
		}
	}
	//#bugfix for 15596: if statement added
	if(childList!=null)
	{
		for (var i:int=childList.numChildren - 1; i > 0; i--)
		{
			//The variable that holds the current popup window
			var child:IFlexDisplayObject=childList.getChildAt(i) as IFlexDisplayObject;
			PopUpManager.removePopUp(child);
		}
	}
	
	//Fix for 	5804 - Library button is not working in document sharing module 
	//IF the filemanager is already initialized in video sharing module
	if (fileManager != null)
	{
		fileManager=null;
	}
	return null;
}

/**
 * 
 * @private
 * Does preload checking & update UI controls for  youtube video
 * This invokes the loadVideo method. This method will be invoked when
 * a string is enetered in the address text box in video module.
 * 
 * @param youtubeVideoURL of type String
 * @return void 
 * 
 */
private function preloadYoutubeVideo(youtubeVideoURL:String):void
{
	//The variable that holds the index of  starting index of http/https to identify 
	// whether the given url is valid or not
	
	var protocolIndex:int=-1;
	//checks for youtube video domain in the given video url
	protocolIndex=youtubeVideoURL.indexOf(UTUBE_URL);
	if (protocolIndex == -1)
		protocolIndex=youtubeVideoURL.indexOf(UTUBE_URL_SECURE);
	//The variable that holds the libraryvideo url which is already loaded
	var tempURI:String=null;
	//IF the given address is not starung with an http domain and a libray video is playing
	//get the library video name.
	if (protocolIndex == -1 && videoURL != "")
	{
		tempURI=videoURL.substring(videoURL.indexOf(MY_VIDEOS) + MY_VIDEOS.length+1, videoURL.length);
	}
	if (txtYoutubeURL.text == "")
	{
		labelFileName.setFocus();
		alertControl=Alert.show("Enter Video URL", "Video Module", 4, this);
	}
	//IF the video is already loaded ,then display a warning message.
	else if (videoURL != "" && ((videoURL == StringUtil.trim(youtubeVideoURL) && protocolIndex != -1) || 
		(StringUtil.trim(youtubeVideoURL) == StringUtil.trim(tempURI) && tempURI != null)))
	{
		txtYoutubeURL.text=StringUtil.trim(youtubeVideoURL);
		btnYoutubeURL.enabled=false;
		labelFileName.setFocus();
		alertControl=Alert.show("Video already loaded.", "Video Module", 4, this);
	}
	//Otherwise load the youtube video.
	else
	{
		btnYoutubeURL.enabled=false;
		videoURL=StringUtil.trim(youtubeVideoURL);
		youTubeVideoId=null;
		setPlayButton(true, false, "Video Loading");
		isUTubePlayerReady=false;
		loadVideo();
		loadedVideoCount=0;
		labelVideoStatusInfo.text="";
	}
}

/**
 * 
 * @private
 * Initiates the video loading process
 * 
 * @return void 
 *  
 */
private function initiateLoadLibraryVideo():void
{
	setPlayButton(true, false, "Video Loading");
	if(Log.isDebug()) log.debug("Inside initiateLoadLibraryVideo");
	loadVideo();
}

/**
 * 
 * @private
 * This function is used to load the video.
 *
 *
 * @return void 
 *  
 */
private function loadVideo():void
{
	if(Log.isDebug()) log.debug("Inside Load Video");
	
	//IF current user is prsenter then reset variables used during reconnection
	if (videoURLLoadedBeforeReconnection != "" && userRole == Constants.PRESENTER_ROLE)
	{
		videoURLLoadedBeforeReconnection="";
		playHeadTimeBeforeReconnection=0;
	}
	//the netconnection is lost set the videoURL
	if (isConnectionLost)
		videoURL=videoURLLoadedBeforeReconnection;
	//resets the timer,seekbar and video duration.
	timerReset();
	hSliderSeekbar.value=0;
	videoDuration=0;
	try
	{
		//IF a youtube video is playing,stop video and reset it.
		if (youTubePlayer != null)
		{
			youTubePlayer.stopVideo();
			youTubePlayer="";
			youTubeVideoLoader.unloadAndStop(true);
			youTubePlayer=null;
		}
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in loadVideo method:"+ e.getStackTrace());
	}
	try
	{
		//IF the library video player is loaded then reset it.
		if (isLibraryVideo || (vBoxVideoPlayer.numChildren > 0))
		{
			isLibraryVideo=false;
			lengthLabel.text="0:0";
			labelPosition.text="0:0";
			closeLibraryVideoplayer();
		}
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in loadVideo method:"+ e.getStackTrace());
	}
	
	if (vBoxVideoPlayer.numChildren > 0)
		vBoxVideoPlayer.removeAllChildren();
	
	btnYoutubeURL.enabled=false;
	youTubeURL=getDomainAddress(videoURL);
	//fix for issue #19402
	applicationType::web{
		if(Capabilities.version=="WIN 11,7,700,202"){
			Alert.show("To support YouTube videos in A-VIEW, kindly update your flash player.","INFO");
			btnYoutubeURL.enabled=true;
			return;
		}
	}
	//IF the requested video is a youtube video then check the availability of youtube video
	if (youTubeURL == UTUBE_URL || youTubeURL == UTUBE_URL_SECURE)
	{
		monitorYoutubeURL();
	}
	else
	{
		setPlayButton(true, false, "Video Loading");
		loadLibraryVideo();
	}
}

/**
 * 
 * @private
 * returns the protocol for the specified url
 * 
 * @param url of type String
 * @return String 
 *  
 */
private function getProtocol(url:String):String
{
	//holds the index of the protocol for requested url(http/https)
	var protocolIndex:int=-1;
	protocolIndex=url.indexOf(PROTOCOL_SEP);
	if (protocolIndex != -1 && url.length >= protocolIndex + PROTOCOL_SEP.length)
	{
		protocolUsed=url.substring(0, protocolIndex);
	}
	else
	{
		protocolUsed="";
	}
	return protocolUsed;
}

/**
 * 
 * @private
 * Loads the video files from library(fms server)
 * 
 * @return void 
 * 
 */
private function loadLibraryVideo():void
{
	updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_LOAD, 0);
	protocolUsed=getProtocol(videoURL);
	//creates and loads library video
	libraryVideoPlayer=new VideoDisplay();
	libraryVideoPlayer.bufferTime=0.2;
	libraryVideoPlayer.autoPlay=false;
	libraryVideoPlayer.percentWidth=100;
	libraryVideoPlayer.height=vBoxVideoPlayer.height;
	vBoxVideoPlayer.addChild(libraryVideoPlayer);
	isLibraryVideo=true;
	//IF the requested url starts with http/rtmp then sets the library video properties.
	if (protocolUsed == Constants.PROTOCOL_FMS_SERVER || protocolUsed == Constants.PROTOCOL_HTTP)
	{
		setLibraryVideoProperties();
	}
	//Otherwise wrong path warning will be displayed to presenter.
	//The path for library video should start with rtmp or http.
	else
	{
		txtYoutubeURL.text="";
		setPlayButton(true);
		videoURL="";
		if (userRole == Constants.PRESENTER_ROLE)
		{
			labelFileName.setFocus();
			alertControl=Alert.show("Path Not Found", "Video Module", 4, this);
		}
		return;
	}
}

/**
 * 
 * @private
 * Validates and sets the library video properties
 * 
 * @return void 
 * 
 */
private function setLibraryVideoProperties():void
{
	//IF  the video request is rtmp  
	if (protocolUsed == Constants.PROTOCOL_FMS_SERVER)
	{
		playingLibraryVideoURL=videoURL;
		//holds the extention for the library video URL
		var fileExtension:String=videoURL.substring((videoURL.length - 3), videoURL.length);
		//IF an mp4/ f4v video is playing set the url for library video with 'mp4:' markup
		//This module supports only  mp4,f4v and flv files as library videos
		if (fileExtension != "flv" && fileExtension != "FLV")
		{
			//holds starting index of the vod folder in library video file path.
			var vodIndex:int=playingLibraryVideoURL.indexOf(VOD_FOLDER);
			if (vodIndex != -1)
			{
				vodIndex+=VOD_FOLDER.length;
				//appends the 'mp4:' markup before videoname 
				playingLibraryVideoURL=playingLibraryVideoURL.substring(0, vodIndex) + "mp4:" + playingLibraryVideoURL.substring(vodIndex);
			}
			else
			{
				alertControl=Alert.show("Invalid library path", "Video Module", 4, this)
				videoURL="";
				return;
			}
		}
		//otherwise sets flv video url
		else if (fileExtension == "flv" || fileExtension == "FLV")
		{
			playingLibraryVideoURL=videoURL.substring(0, videoURL.length - 4);
		}
	}
	//IF the request is an http video request the url is taken as such
	else
	{
		playingLibraryVideoURL=videoURL;
	}
	//sets url and video monitoring parameters and displays video player  
	//---------------START---------------
	var playUrlPort:String=playingLibraryVideoURL;
	playUrlPort=playUrlPort.substring(0, playingLibraryVideoURL.indexOf(VOD_FOLDER)) + ":" + ClassroomContext.portFMS + playingLibraryVideoURL.substring(playingLibraryVideoURL.indexOf(VOD_FOLDER), playingLibraryVideoURL.length);
	playingLibraryVideoURL=playUrlPort;
	//loads the requseted video  
	libraryVideoPlayer.mx_internal::videoPlayer.load(playingLibraryVideoURL, false, -1);
	
	isFirstPlayOfCurrentVideo=true;
	videoStatus=Constants.VIDEO_STATE_LOADED;
	libraryVideoPlayer.mx_internal::videoPlayer.visible=true;
	updateVideoStatus(videoStatus);
	videoDuration=libraryVideoPlayer.totalTime;
	libraryVideoPlayer.visible=true;
	//---------------END---------------
	
	//Reconnected and current user is a viewer, a video is pending to be loaded
	if (isConnectionLost)
	{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE)
		{
			isConnectionLost=false;
			isPendingVideo=true;
		}
	}
	//IF there is a video pending to be played, and the viewer is a late coming user or reconnected ,
	//then request the playhead time from presenter
	if (isPendingVideo)
	{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE)
		{
			mediaServerConnection.netConnection.call("getPlayheadTimeForLateComingUser", null, ClassroomContext.userVO.userName);
		}
		else
		{
			//TODO: test this block
			txtYoutubeURL.text=videoURL.substring(videoURL.indexOf(MY_VIDEOS) + MY_VIDEOS.length+1, videoURL.length);
			if (!isConnectionLost)
			{
				updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_STOP, 0);
				if (Log.isInfo()) log.info("updateVideoProperties:setLibraryPlayUrl: url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_STOP + ", timer:" + 0);
			}
		}
	}
	
	setPlayButton(true);
}

//youtube video loading functions starts-----------

/**
 * 
 * @private
 * Returns the root domain address for the given URL
 * eg:- http://youtube.com
 *
 * @param url of type String
 * @return String 
 * 
 */
private function getDomainAddress(url:String):String
{
	// holds the domain name
	var domainURL:String="";
	//holds the index of "://"
	var protocolIndex:int=url.indexOf(PROTOCOL_SEP);
	//IF the url is http request and the url is not just http://
	//then get the string from 0 th index to the first '/' after 'http://'
	//returns the extracted string
	if (protocolIndex != -1 && url.length >= protocolIndex + PROTOCOL_SEP.length)
	{
		protocolIndex+=PROTOCOL_SEP.length;
		//holds the first index of "/" after the protocolIndex in url.
		var domainIndex:uint=url.indexOf("/", protocolIndex);
		if (domainIndex != -1)
		{
			domainURL=url.substring(0, domainIndex);
		}
	}
	return domainURL;
}

/**
 * 
 * @private
 * returns the videoId  from the given youtube video url.
 * eg: http://www.youtube.com/watch?v=fdGTnz-Wd20
 * video id=fdGTnz-Wd20
 * 
 * @param url of type String
 * @return String 
 * 
 */
private function getUTubeVideoId(url:String):String
{
	// holds the video id of the given youtube video
	var vidId:String="";
	if (url.indexOf("?v=") == -1)
	{
		vidId=url.substring((url.length) - 11, (url.length));
	}
	else
	{
		vidId=url.substring((url.indexOf("?v=") + 3), (url.indexOf("?v=") + 14));
	}
	return vidId;
}

/**
 * 
 * @private
 * Monitors the availability of the youtubeurl
 * The URLMonitor instance monitors availablity of an HTTP- or HTTPS-based service.
 * 
 *
 * @return void 
 * 
 */
private function monitorYoutubeURL():void
{
	//URLMonitor class is not available for web.
	applicationType::desktop
	{
		if (youTubeURL == UTUBE_URL_SECURE)
		{
			youtubeURLMonitor=new URLMonitor(new URLRequest(UTUBE_URL_SECURE));
		}
		else
		{
			youtubeURLMonitor=new URLMonitor(new URLRequest(UTUBE_URL));
		}
		youtubeURLMonitor.addEventListener(StatusEvent.STATUS, urlMonitorStatusHandler);
		youtubeURLMonitor.start();
	}
	videoURL="";
	applicationType::web{
		
		setYoutubeVideoURL();   
		loadYoutubeVideo();
	}
	
}

/**
 * 
 * @private
 * StatusHandler for youtubeURLMonitor . This method receives the status
 * from youtubeURLMonitor and initiate the loading process if
 * the youtube website is available
 *
 * @param statusEvent of type StatusEvent
 * @return void 
 * 
 */
private function urlMonitorStatusHandler(statusEvent:StatusEvent):void
{
	//URLMonitor class not available for web.
	applicationType::desktop
	{
		//IF the youtube url is avaiable
		if (youtubeURLMonitor.available)
		{
			
			setYoutubeVideoURL();
			//loads the youtube video
			loadYoutubeVideo();
			youtubeURLMonitor.removeEventListener(StatusEvent.STATUS, urlMonitorStatusHandler);
		}
		else
		{
			//IF the youtube service is not available ,the method 'lateAuthentication' will be invoked
			//after an interval of 5000 seconds.
			if (StringUtil.trim(videoCommandCollaborationObject.getData()[Constants.URL_INFO]) != "" && (videoCommandCollaborationObject.getData()[Constants.URL_INFO]) != null)
			{
				timerStop();
				videoURL="";
				youtubeURLMonitor.removeEventListener(StatusEvent.STATUS, urlMonitorStatusHandler);
				setTimeout(lateAuthentication, 5000);
			}
		}
	}
}

private function setYoutubeVideoURL():void
{
	//IF the current user is presenter gets the video url from the local variable.
	//Otherwise get the url from collaboration object for viewer
	if (userRole == Constants.PRESENTER_ROLE)
	{
		videoURL=StringUtil.trim(txtYoutubeURL.text);
		if (isConnectionLost)
			videoURL=videoURLLoadedBeforeReconnection;
	}
	else
		videoURL=StringUtil.trim(videoCommandCollaborationObject.getData()[Constants.URL_INFO]);
}
/**
 * 
 * @private
 * Invoked if the youtube service is not available when url
 * monitoring service returns the status value as false.
 *
 *
 * @return void 
 * 
 */
private function lateAuthentication():void
{
	//IF the video is playing/seeking/loading/paused state ,then invoke
	//the sync method for videoCommand collaboration object
	if ((videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_STATE_PLAY) || (videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_SEEK_PLAY) || (videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_LOAD) || (videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_SEEK_PAUSE))
	{
		videoURL="";
		onVideoCommandSync(videoCommandCollaborationObject.getData());
	}
}


/**
 * 
 * @private
 * Load youtube video
 *
 *
 * @return void  
 * 
 */
private function loadYoutubeVideo():void
{
	//IF the current user is presenter update the collaboration object 
	// with the load command and video url
	updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_LOAD, 0);
	//Retrieves the videoId 
	youTubeVideoId=getUTubeVideoId(videoURL);
	isLibraryVideo=false;
	//To avoid the secuiry issues like sandbox error
	Security.loadPolicyFile(youTubeURL + "/crossdomain.xml");
	
	//Unload the previous video if it was there
	youTubeVideoLoader.unloadAndStop(true);
	//loading a chromeless player
	//eg: -http://www.youtube.com/apiplayer?version=3
	if (youTubeURL == UTUBE_URL)
	{
		youTubeVideoLoader.load(new URLRequest(UTUBE_URL + "/apiplayer?version=3"));
	}
	else
	{
		youTubeVideoLoader.load(new URLRequest(UTUBE_URL_SECURE + "/apiplayer?version=3"));
	}
	youTubeVideoLoader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
	youTubeVideoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
	youTubeVideoLoader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleGlobalErrors);
}

/**
 * 
 * @private
 * Handling global errors
 * 
 * @param event of type Event
 * @return void  
 *
 */
private function handleGlobalErrors(event:Event):void
{
	event.preventDefault();
}

/**
 * 
 * @private
 * handling error events
 * 
 * @param errorEvent of type ErrorEvent
 * @return void  
 * 
 */
private function onError(errorEvent:ErrorEvent):void
{
	timerStop();
	if (StringUtil.trim(videoCommandCollaborationObject.getData()[Constants.URL_INFO]) != "" && (videoCommandCollaborationObject.getData()[Constants.URL_INFO]) != null)
	{
		videoURL="";
		//URLMonitor class not available for web.
		applicationType::desktop
		{
			youtubeURLMonitor.removeEventListener(StatusEvent.STATUS, urlMonitorStatusHandler);
		}
		setTimeout(lateAuthentication, 5000);
	}
}

/**
 * 
 * @private
 * This function is invoked when Youtube video loads.
 * This is the event listener for Event.INIT
 * 
 * @param event of type Event
 * @return void  
 *
 */
private function onLoaderInit(event:Event):void
{
	vBoxVideoPlayer.percentHeight=75;
	//The video player container for youtube video player
	var playerComponent:UIComponent=new UIComponent();
	vBoxVideoPlayer.addChild(playerComponent);
	
	playerComponent.addChild(youTubeVideoLoader);
	if (youTubePlayer != null)
	{
		youTubePlayer.stopVideo();
		youTubePlayer.removeEventListener("onReady", onPlayerReady);
		youTubePlayer.removeEventListener("onError", onPlayerError);
	}
	//youTubePlayer is an swfProxy object that returns a player with youtube video
	youTubePlayer=youTubeVideoLoader.content;
	//adds event listeners for youTubePlayer
	isYoutubeErrorMessageDisplayed=false;
	youTubePlayer.addEventListener("onReady", onPlayerReady);
	youTubePlayer.addEventListener("onError", onPlayerError);
}

/**
 * 
 * @private
 * This function is invoked when an error occurs while You tube video player loads.
 * 
 * @param event of type Event
 * @return void  
 *
 */
private function onPlayerError(event:Event):void
{
	if(Log.isInfo()) log.info("Player error:", Object(event).data);
	if(isYoutubeErrorMessageDisplayed)
		return;
	if(Object(event).data==150 || Object(event).data==101)
	{
		isYoutubeErrorMessageDisplayed=true;
		Alert.show("The owner of the video does not allow it to be played in embedded player");
	}
}

/**
 * 
 * @private
 * This function is invoked when You tube video is ready to play.
 * loads video for presenter and viewer.
 * 
 * @param event of type Event
 * @return void  
 * 
 */
private function onPlayerReady(event:Event):void
{
	//The width of video player container
	var widthVideoPlayer:Number=vBoxVideoPlayer.width;
	setUTubeVideoPlayButton();
	//resizes the youtube player based on the player container size
	try
	{
		youTubePlayer.setSize(widthVideoPlayer, (vBoxVideoPlayer.height));
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in onPlayerReady method::youTubePlayer.setSize:"+ e.getStackTrace());
	}
	
	isUTubePlayerReady=true;
	//IF the current user is presenter
	//load video to player and set the playheadtime
	if (userRole == Constants.PRESENTER_ROLE)
	{
		videoStatus=Constants.VIDEO_STATE_LOADING;
		try
		{
			youTubePlayer.cueVideoById(youTubeVideoId, 0);
			youTubePlayer.seekTo(0);
			youTubePlayer.setPlaybackQuality("medium");
			//IF a video is pending  in the collaboration object to play 
			if (isPendingVideo)
			{
				isPendingVideo=false;
				//IF the module is reConnected update the collaborationobject with stop command
				if (!isConnectionLost)
					updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_STOP, 0);
				if (Log.isInfo()) log.info("updateVideoProperties:onPlayerReady url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_STOP + ", timer:" + 0);
			}
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in onPlayerReady method::PresenterRole:"+ e.getStackTrace());
		}
		//updates the videostatus in the videoStatusCollaborationObject
		updateVideoStatus(videoStatus);
	}
	//Otherwise  the current user is viewer
	else
	{
		//If this method is invoked after reconnection that means a video is pending 
		//in the collaboration object which is not played 
		if (isConnectionLost)
		{
			playHeadTimeBeforeReconnection=0;
			videoURLLoadedBeforeReconnection="";
			isConnectionLost=false;
			isPendingVideo=true;
		}
		
		if (isPendingVideo)
		{
			mediaServerConnection.netConnection.call("getPlayheadTimeForLateComingUser", null, ClassroomContext.userVO.userName);
		}
		else
		{
			try
			{
				videoStatus=Constants.VIDEO_STATE_LOADING;
				//This function loads the specified video's thumbnail 
				//and prepares the player to play the video.
				//The player does not request the FLV until playVideo() or seekTo() is called.
				
				youTubePlayer.cueVideoById(youTubeVideoId, 0);
				youTubePlayer.seekTo(0);
				updateVideoStatus(videoStatus);
				youTubePlayer.setPlaybackQuality("medium");
			}
			catch (e:Error)
			{
				if(Log.isError()) log.error("Error in onPlayerReady method::!isPendingVideo:"+ e.getStackTrace());
			}
		}
	}
	
	playHeadUpdateTimer.addEventListener(TimerEvent.TIMER, playheadUpdateTimerHandler);
	youTubePlayer.addEventListener(MouseEvent.CLICK, playLoadedVideo);
	
	if (userRole != Constants.PRESENTER_ROLE)
	{
		youTubePlayer.mouseEnabled=false;
		youTubePlayer.mouseChildren=false;
		labelFileName.text=videoURL;
	}
	else
	{
		youTubePlayer.mouseEnabled=true;
		youTubePlayer.mouseChildren=true;
	}
	//IF the playHeadUpdateTimer is running restart it
	if (playHeadUpdateTimer.running)
	{
		playHeadUpdateTimer.reset();
		playHeadUpdateTimer.start();
	}
	else
		playHeadUpdateTimer.start();
}

/**
 * 
 * @private
 * Plays loaded video
 * 
 *
 * @return void  
 *
 */
private function playLoadedVideo(e:Event):void
{
	//Handle youtube player click,when we click on player it pauses/plays
	if (userRole == Constants.PRESENTER_ROLE)
	{
		if (videoStatus == Constants.VIDEO_STATE_PAUSE || videoStatus == Constants.VIDEO_STATE_STOP || videoStatus == Constants.VIDEO_STATE_LOADED)
			togglePlay(true);
		else if (videoStatus == Constants.VIDEO_STATE_PLAY)
			togglePlay(false);
	}
}
//youtube video loading functions ends-----------
//Timer & time display functions starts------------
private function startPlayheadUpdate():void
{
	if(!isLibraryVideo)
		timerStart();
	
	else 
	{
		//#bugfix for 15708
		if(!libraryVideoPlayer.hasEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE))
			libraryVideoPlayer.addEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE,onPlayheadUpdate);
		//#bugfix for 15708
		
	}
} 
private function stopPlayheadUpdate():void
{
	if(!isLibraryVideo)
		timerStop();
	else
		libraryVideoPlayer.removeEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE,onPlayheadUpdate);
}



/**
 * 
 * @public
 * starts the playHeadUpdateTimer
 *
 *
 * @return void  
 * 
 */
public function timerStart():void
{
	playHeadUpdateTimer.start();
	if (!playHeadUpdateTimer.hasEventListener(TimerEvent.TIMER))
	{
		playHeadUpdateTimer.addEventListener(TimerEvent.TIMER, playheadUpdateTimerHandler);
	}
}

/**
 * 
 * @private
 * Stops the timer and removes the event listeners
 * 
 *
 * @return void  
 *
 */
private function timerStop():void
{
	if (playHeadUpdateTimer.hasEventListener(TimerEvent.TIMER))
	{
		playHeadUpdateTimer.removeEventListener(TimerEvent.TIMER, playheadUpdateTimerHandler);
		playHeadUpdateTimer.stop();
	}
}

/**
 * 
 * @public
 * Resets the playHeadUpdateTimer and removes the event listeners
 *
 *
 * @return void  
 *
 */
public function timerReset():void
{
	
	playHeadUpdateTimer.reset();
	if (playHeadUpdateTimer.hasEventListener(TimerEvent.TIMER))
		playHeadUpdateTimer.removeEventListener(TimerEvent.TIMER, playheadUpdateTimerHandler);
}

/**
 * 
 * @public
 * This function is called to handle video playhead time..
 * 
 * @param timerEvent of type TimerEvent
 * @return void  
 * 
 */
public function playheadUpdateTimerHandler(timerEvent:TimerEvent):void
{
	if (!isLibraryVideo && videoStatus != Constants.VIDEO_STATE_LOADING && youTubePlayer != null)
	{
		videoDuration=youTubePlayer.getDuration();
	}
	updateVideoPlayhead();
}

/**
 * 
 * @private
 * Updates the seebar with playhead time 
 * @return 
 * 
 */
private function updateSeekbar():void
{
	
	//display time for youtube video
	if (!isLibraryVideo && youTubePlayer != null)
	{
		hSliderSeekbar.value=youTubePlayer.getCurrentTime();
		
	}
	//display time for library video
	else if (isLibraryVideo)
	{

			hSliderSeekbar.value=libraryVideoPlayer.playheadTime;
	}
}

/**
 * 
 * @private
 * Returns the playtime in formatted string to display in seekbar
 *
 * @param rawTimesec of type Number
 * @return String
 * 
 */
private function getFormattedTimeString(rawTimeSec:Number):String
{
	//The playheadTime in milliseconds
	var time:Number=rawTimeSec * 1000;
	//hours of current playheadtime
	var Hours:uint=time / (1000 * 60 * 60);
	//minutes of current playheadtime
	var Minutes:uint=(time % (1000 * 60 * 60)) / (1000 * 60);
	//seconds of current playheadtime
	var Seconds:uint=((time % (1000 * 60 * 60)) % (1000 * 60)) / 1000
	return Hours.toString() + ":" + Minutes.toString() + ":" + Seconds.toString();
}

/**
 * 
 * @private
 * This function updates the current video play time.
 * If the video has reached end it checks for replay
 * 
 *
 * @return void
 * 
 */
private function updateVideoPlayhead():void
{
	//holds the  seekbar  time 
	var curSliderVal:Number;
	//hold the presenter video's seek time
	var presenterVideoTime:Number;
	//holds the  difference between curSliderVal and presenterVideoTime.
	var delayTimeCalc:Number;
	//IF youtube video is playing
	//------START-------------------
	if (!isLibraryVideo && youTubePlayer != null)
	{
		//This method is to setup the youtube player status as well
		//If the video was not loaded earlier, 
		//the current player status can be checked and set the status accordingly
		if (videoStatus == Constants.VIDEO_STATE_LOADING && (youTubePlayer.getPlayerState() == UTUBE_PLAYING || youTubePlayer.getPlayerState() == UTUBE_PAUSED))
		{
			videoStatus=Constants.VIDEO_STATE_LOADED;
			//If the youtube video is loaded and presenter is not yet pressed the play button, 
			//then the video needs to get buffered
			//The buffering is done when the video is paused
			if (youTubePlayer.getPlayerState() == UTUBE_PLAYING)
			{
				setPlayButton(true);
				youTubePlayer.pauseVideo();
			}
			//update the video status
			updateVideoStatus(videoStatus);
			
		}
		//IF the youtube player is in paused state and the current user is presenter
		//the video command is play
		if (youTubePlayer.getPlayerState() == UTUBE_PAUSED && userRole == Constants.PRESENTER_ROLE && videoCommand == Constants.VIDEO_COMMAND_PLAY && btnPlay.toolTip != Constants.VIDEO_STATE_PLAY)
		{
			togglePlay(true);
		}
	}
	//------END-------------------
	//Otherwise IF library video is playing
	//-----------------START----------------------
	else if (isLibraryVideo)
	{
		if (libraryVideoPlayer.state == VIDEO_STOPPED)
		{
			setPlayButton(true);
		}
		//IF the libraryvideo player is paused and the received command
		//is pause/seek_pause update the playheadtime
		if (libraryVideoPlayer.state == VIDEO_PAUSED && (videoCommand == Constants.VIDEO_COMMAND_PAUSE || videoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE))
		{
			if (!isConnectionLost && videoURLLoadedBeforeReconnection == "")
				libraryVideoPlayer.playheadTime=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
		}
	}
	//-----------------END----------------------
	//IF current user is presenter and no video is pending to play 
	// and the video connection is lost
	if (userRole != Constants.PRESENTER_ROLE && !isPendingVideo && !isConnectionLost)
	{
		//The lastest video command received from presenter.
		var videoCommand:String=videoCommandCollaborationObject.getData()[Constants.STATUS];
		
		//IF library video is selected to play and the video player is not playing
		// and the received command is play or seek play
		if (isLibraryVideo)
		{
			if (!libraryVideoPlayer.playing && (videoCommand == Constants.VIDEO_COMMAND_PLAY || videoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY))
			{
				if (libraryVideoPlayer.state == VIDEO_STOPPED)
				{
					//video playing is not started, toggle the video play
					if (libraryVideoPlayer.playheadTime < 2)
					{
						isFirstPlayOfCurrentVideo=true;
						togglePlay(true);
					}
				}
			}
			//Otherwise if videoplayer is playing ,video command  received is pause
			//The differnce between received playheadtime and current playhead time is calculated
			//IF the difference is lessthan or equal to 0 then the videoCommandSync is invoked.
			else if (libraryVideoPlayer.playing && (videoCommand == Constants.VIDEO_COMMAND_PAUSE || videoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE))
			{
				curSliderVal=hSliderSeekbar.value;
				presenterVideoTime=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
				if (isNaN(curSliderVal))
				{
					curSliderVal=0;
					hSliderSeekbar.value=0;
				}
				delayTimeCalc=presenterVideoTime - curSliderVal;
				if (!delayTimeCalc > 0)
					onVideoCommandSync(videoCommandCollaborationObject.getData());
			}
			//OTHERWISE the current state of videoplayer is disconnected  and
			// the received command is play the video is stopped and 
			//invokes the VideoCommandSync method to play the video
			else if (libraryVideoPlayer.state == VIDEO_DISCONNECTED && (videoCommand == Constants.VIDEO_COMMAND_PLAY || videoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY))
			{
				try
				{
					if(Log.isInfo()){log.info(" Invoke clear video player.VideoCommand :"+videoCommand+" & libraryVideoPlayer.state :"+libraryVideoPlayer.state);}
					clearVideoPlayer();
				}
				catch (e:Error)
				{
					if(Log.isError()) log.error("Error in updateVideoPlayhead method:"+ e.getStackTrace());
				}
				videoURL="";
				onVideoCommandSync(videoCommandCollaborationObject.getData());
			}
		}
		else
		{
			//IF the youtube player is running
			if (youTubePlayer != null)
			{
				//IF the current player state is paused and the receive command is play
				//play the video
				if (youTubePlayer.getPlayerState() == UTUBE_PAUSED && (videoCommand == Constants.VIDEO_COMMAND_PLAY || videoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY))
				{
					togglePlay(true);
				}
				//OTHERWISE IF the player state is playing and the received command is pause
				//get the playheadtime from the collaboration object and 
				//if the current video playheadtime is not lesser than the received one
				//The videoCommand sync function will be invoked.
				
				else if (youTubePlayer.getPlayerState() == UTUBE_PLAYING && (videoCommand == Constants.VIDEO_COMMAND_PAUSE || videoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE))
				{
					
					curSliderVal=hSliderSeekbar.value;
					presenterVideoTime=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
					if (isNaN(curSliderVal))
					{
						curSliderVal=0;
						hSliderSeekbar.value=0;
					}
					delayTimeCalc=presenterVideoTime - curSliderVal;
					if (!delayTimeCalc > 0)
						onVideoCommandSync(videoCommandCollaborationObject.getData());
				}
				//OTHERWISE  if the video is playing and the video is stopped
				//stop the video
				else if (youTubePlayer.getPlayerState() == UTUBE_PLAYING && 
					videoCommand == Constants.VIDEO_COMMAND_STOP)
				{
					//The playheadtime of youTubePlayer	is set to zero
					youTubePlayer.seekTo(0, true);
					setTimeout(youTubePlayer.pauseVideo, 500);
					lastStoppedVideoURL=videoURL;
					setTimeout(stopVideoPlayer, 1600);
				}
			}
		}
	}
	updateSeekbar();
	if (isLibraryVideo )
	{
		//trace("update library video time");
		/* Convert playheadTime and totalTime from milliseconds TO seconds ,minutes and hours. */
		labelPosition.text=getFormattedTimeString(libraryVideoPlayer.playheadTime);
		if(libraryVideoPlayer.height != vBoxVideoPlayer.height)
		{
			libraryVideoPlayer.percentWidth=100;
			libraryVideoPlayer.height=vBoxVideoPlayer.height;
		}
	}
	else if(youTubePlayer!=null)
	{
		labelPosition.text=getFormattedTimeString(youTubePlayer.getCurrentTime());
	}
	
	if (videoDuration < 0)
	{
		videoDuration=0;
	}
	lengthLabel.text=getFormattedTimeString(videoDuration);
	//The difference between total duration of video and the seek time.
	var timeDiff:Number=videoDuration - hSliderSeekbar.value;
	//IF the playhead reached the end	
	// update the video status to "paused"
	//clear the video player
	//reset the playheadtime 
	//----------------------START-------------------------
	if ((timeDiff < .2 || hSliderSeekbar.value > videoDuration) && videoDuration != 0 && hSliderSeekbar.value != 0 && !replayStarted)
	{
		//The last status for current video like playing/paused/stopped etc.
		var previousState:String=videoStatus;
		//youtube video is playing
		if (!isLibraryVideo)
		{
			hSliderSeekbar.value=0;
			youTubePlayer.seekTo(0, true);
			setTimeout(youTubePlayer.pauseVideo, 500);
			videoStatus=Constants.VIDEO_STATE_PAUSE;
			//IF replay is not chosen and current user is presenter
			//or current user is not a presenter then sets the boolean variable to true
			if ((!_autoRepeat && userRole == Constants.PRESENTER_ROLE) || userRole != Constants.PRESENTER_ROLE)
				isPlayingVideoEnded=true;
			if (_autoRepeat)
				lastStoppedVideoURL="";
		}
		//Library video is playing
		else
		{
			trace("seekbar value:"+hSliderSeekbar.value+"  videoDuration:"+videoDuration);
			videoStatus=Constants.VIDEO_STATE_PAUSE;
			//commented to solve crash issue 15494
			//libraryVideoPlayer.mx_internal::videoPlayer.pause();
			hSliderSeekbar.value=0;
			libraryVideoPlayer.playheadTime=0;
			//delay is reduced from 300 sec to 200 sec (tmediff<.2)
			setTimeout(libraryVideoPlayer.mx_internal::videoPlayer.pause, 100);
			//IF replay is not chosen and current user is presenter
			//or current user is not a presenter then sets the boolean variable to true
			if ((!_autoRepeat && userRole == Constants.PRESENTER_ROLE) || userRole != Constants.PRESENTER_ROLE)
				isPlayingVideoEnded=true;
			if (_autoRepeat)
				lastStoppedVideoURL="";
		}
		//---------------------END-----------------------
		labelPosition.text="0:0:0";
		stopPlayheadUpdate();
		lastStoppedVideoURL=videoURL;
		setTimeout(stopVideoPlayer, 1600);
		//IF current user is presenter
		//If the autoRepeat is set on the presenter side , 
		//then replay the video when the playheadtime reached the end of the video
		//Otherwise set the video command to "load" and update the video status is 
		//stopped.reset the play button
		//------------------START--------------------------
		if (userRole == Constants.PRESENTER_ROLE)
		{
			if (_autoRepeat &&  
				videoStatus == Constants.VIDEO_STATE_PAUSE && 
				!replayStarted)
			{
				setTimeout(initiateReplay, 2500);
				if (!replayStarted)
				{
					replayStarted=true;
				}
			}
			else
			{
				//Setting it to Loaded state so that if new user comes at this stage ,it gets loaded.
				updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_LOAD, 0);
				if (Log.isInfo()) log.info("updateVideoProperties:videoPlayheadUpdate url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_LOAD + ", timer:" + 0);
				//If it's not auto repeat, we are setting it up for the presenter 
				//to start the video again
				videoStatus=Constants.VIDEO_STATE_STOP;
				updateVideoStatus(videoStatus);
				setPlayButton(true);
			}
		}
		//------------------------END---------------------------
	}
}

//Timer & time display functions ends------------
/**
 * 
 * @private
 * stops video player
 * Invoked when a stop command needs to be applied on video.
 *
 * @return void
 * 
 */
private function stopVideoPlayer():void
{
	//IF the lastStoppedVideoURL is current URL and the currently playing video
	//is stopped and the received video command  is to load or stop the video
	if (lastStoppedVideoURL == videoURL && (isPlayingVideoEnded || 
		(videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_LOAD 
		|| videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_STOP)))
	{
		isPlayingVideoEnded=false;
		//IF library video is chosen and video player is not in a paused or stopped
		//state ,then stop the video.
		if (isLibraryVideo)
		{
			if (libraryVideoPlayer.state != VIDEO_PAUSED && libraryVideoPlayer.state != VIDEO_STOPPED)
				stop();
		}
		else if (youTubePlayer != null)
		{
			labelPosition.text="0:0:0";
			hSliderSeekbar.value=0;
			
			if (videoStatus != Constants.VIDEO_STATE_STOP)
			{
				//update the video status
				videoStatus=Constants.VIDEO_STATE_PAUSE;
			}
			
				
				youTubePlayer.stopVideo();
		}
	}
	lastStoppedVideoURL="";
}

/**
 * 
 * @private
 * Initiates the replay function for video
 *
 *
 * @return void
 * 
 */
private function initiateReplay():void
{
	replayVideo();
	updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_REPLAY, 0);
	if (Log.isInfo()) log.info("updateVideoProperties:initiateReplay url:" + videoURL + ", command:" + 
			Constants.VIDEO_COMMAND_REPLAY + ", timer:" + 0);
	updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_PLAY, 0);
	if (Log.isInfo()) log.info("updateVideoProperties:initiateReplay url:" + videoURL + ", command:" + 
			Constants.VIDEO_COMMAND_PLAY + ", timer:" + 0);
}

/**
 * 
 * @private
 * The playbutton will be enabled/disabled based on arguments and changes the
 * icon to show play/pause function and tooltip.
 * 
 * @param play of type Boolean
 * @param enabled of type Boolean
 * @param toolTip of type String 
 * @return void
 * 
 */
private function setPlayButton(play:Boolean, enabled:Boolean=true, toolTip:String=null):void
{
	btnPlay.selected=!play;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp && 
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
	{
		btnPlay.enabled=enabled;
	}
	if (play)
	{
		btnPlay.toolTip=Constants.VIDEO_STATE_PLAY;
		btnPlay.setStyle("icon", playIcon);
	}
	else
	{
		btnPlay.toolTip=Constants.VIDEO_STATE_PAUSE;
		btnPlay.setStyle("icon", pauseIcon);
	}
	
	if (toolTip != null)
	{
		btnPlay.toolTip=toolTip;
	}
}

//Video playing functions starts----------------
/**
 * 
 * @public
 * This function toggles Play and Pause option.
 * 
 * @param play of type Boolean
 * @return void
 * 
 */
public function togglePlay(play:Boolean):void
{
	setVideoSharingActiveTab(); //ashwini: force video sharing to be active
	if(Log.isDebug()) log.debug("inside togglePlay. Play:"+play);
	clearTimeout(playTimeOutHandle5);
	//changes playbuttons icon
	setPlayButton(!play, false);
	//holds current seek time 
	var timeSecond:Number=hSliderSeekbar.value;
	//if the video is playing and the last stopped video url is not null
	//then the lastStoppedVideoURL is set to null
	if (lastStoppedVideoURL != "" && play == true)
		lastStoppedVideoURL="";
	//IF a url is given to play play/pause the video based on the 'play' variable
	//-----------------START-------------------
	if (videoURL != "")
	{
		//IF the last video command is not cleared
		//clear the variable
		if (lastvideoCommandReceived != "")
			lastvideoCommandReceived="";
		
		//IF the play button is clicked to play the video
		//plays the library video /youtube video .
		//-----------------START-------------------------
		if (play)
		{
			
			startPlayheadUpdate();
			if (isLibraryVideo)
			{
				//plays library video
				playLibraryVideo();
			}
			else
			{
				
				//plays youtube video
				playYoutubeVideo();
			}
			//if current user is presenter and video is not started(presenterPlayheadTime=0)
			if (userRole == Constants.PRESENTER_ROLE && presenterPlayheadTime == 0)
			{
				updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_PLAY, timeSecond);
				if (Log.isInfo()) log.info("updateVideoProperties:togglePlay url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_PLAY + ", timer:" + timeSecond);
				videoSharingPlayEventLog(videoURL, String(timeSecond));
			}
			//only Presenter  can change the volume
			if (userRole != Constants.PRESENTER_ROLE)
			{
				handleVolume();
			}
			if (userRole == Constants.PRESENTER_ROLE)
			{
				if (muteState == AUDIO_MUTE)
				{
					muteState=AUDIO_UNMUTE;
					toggleSound(true);
				}
				else
				{
					muteState=AUDIO_MUTE;
					toggleSound(false);
				}
			}
			
		}
		//IF user selected to pause the video
		//---------START--------------------
		else
		{
			stopPlayheadUpdate();
			//IF a library video is playing pause the library video otherwise pause the youtube video
			if (isLibraryVideo)
			{
				pauseLibraryVideo();
			}
			else
			{
				if(videoCommand==Constants.VIDEO_COMMAND_STOP)
				{
					stopYoutubeVideo();
				}
				else
				{
					if (Log.isDebug()) log.debug("Inside togglePlay. invoking pauseYoutubeVideo");
					pauseYoutubeVideo();
				}
			}
			//IF the current user is presenter update the video command in the collaboration object
			if (userRole == Constants.PRESENTER_ROLE)
			{
				updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_PAUSE, timeSecond);
				if (Log.isInfo()) log.info("updateVideoProperties:togglePlay url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_PAUSE + ", timer:" + timeSecond);
				videoSharingPauseEventLog(videoURL, String(timeSecond));
			}
		}
		//---------------------END---------------------------
		//IF the current videostatus is not loading
		//updates the video status to either play/pause and updates videoStatusCollaborationObject
		if (videoStatus != Constants.VIDEO_STATE_LOADING)
		{
			//IF video player is loaded and ready
			//set the videostatus to  based on the play parameter
			//As the youtube player is loaded from outside network its state needs to be checked.
			if ((!isLibraryVideo && youTubePlayer != null && youTubePlayer.getPlayerState() != UTUBE_NOTREADY) || isLibraryVideo)
			{
				if (!play)
				{
					videoStatus=Constants.VIDEO_STATE_PAUSE;
				}
				else
				{
					videoStatus=Constants.VIDEO_STATE_PLAY;
				}
			}
			updateVideoStatus(videoStatus);
		}
		//sets the playbutton icon to pause
		setPlayButton(!play);
	}
	//---------END-------------------
}
private function onPlayerHeadReachedEnd(event:mx.events.VideoEvent):void
{
	libraryVideoPlayer.removeEventListener(mx.events.VideoEvent.COMPLETE,onPlayerHeadReachedEnd);
	if(userRole == Constants.PRESENTER_ROLE)
	{   	
		if(_autoRepeat && videoStatus!=Constants.VIDEO_STATE_PAUSE)
		{
			setTimeout(initiateReplay,2500);
		}
		else
		{	//Setting it to Loaded state so that if new user comes at this stage ,it gets loaded.
			updateVideoProperties(videoURL,Constants.VIDEO_COMMAND_LOAD,0); 							
			if(Log.isInfo()) log.info("msgFromPrsntrVideoShare:videoPlayheadUpdate url:"+videoURL+", command:"+Constants.VIDEO_COMMAND_LOAD+", timer:"+0);	
			//If it's not auto repeat, we are setting it up for the presenter to start the video again
			videoStatus=Constants.VIDEO_STATE_STOP;
			updateVideoStatus(videoStatus);
			setPlayButton(true);							
		}
	} 
}
/**
 *
 * @private
 * Audits the "VideoSharingPause" action, when the presenter presses pause button for the video
 *
 * @param url of the video
 * @param videoTime - current video time when pause is pressed
 * @return void
 *
 */
private function videoSharingPauseEventLog(url:String, videoTime:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoSharingPause, url, videoTime, null);
}

/**
 *
 * @private
 * Audits the "VideoSharingPlay" action, when the presenter presses play button for the video
 *
 * @param url of the video
 * @param videoTime - current video time when play is pressed
 * @return void
 *
 */
private function videoSharingPlayEventLog(url:String, videoTime:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoSharingPlay, url, videoTime, null);
}

/**
 * 
 * @private
 * Plays library video.Invoked when video is properly loaded into the player.
 * This method is called from togglePlay() method
 * 
 *
 * @return void
 * 
 */
private function playLibraryVideo():void
{
	clearTimeout(idleTimeOutHandle);
	if(Log.isDebug()) log.debug("inside playLibraryVideo. player state:"+libraryVideoPlayer.state+" Outof sync:"+offSync);
	
	libraryVideoPlayer.addEventListener(mx.events.VideoEvent.COMPLETE,onPlayerHeadReachedEnd);
	//if the currently selected video is playing first time
	if (isFirstPlayOfCurrentVideo)
	{
		//IF the video gets idle for 5 minutes the player will be disconnected
		// IF the player is disconnected and the current user is presenter 
		if (libraryVideoPlayer.state == VIDEO_DISCONNECTED && userRole == Constants.PRESENTER_ROLE)
		{
			if(Log.isDebug()) log.debug("inside playLibraryVideo.player disconnected for presenter: "+playingLibraryVideoURL);
			stop();
		}
		//IF the video player is stopped
		if (libraryVideoPlayer.state == VIDEO_STOPPED)
		{ 
			if(Log.isDebug()) log.debug("inside playLibraryVideo. playing new video: "+playingLibraryVideoURL);
			//libraryVideoPlayer.mx_internal::videoPlayer.bufferTime=0;
			libraryVideoPlayer.mx_internal::videoPlayer.play(playingLibraryVideoURL, false, -1);
			libraryVideoPlayer.mx_internal::videoPlayer.visible=true;
			startPlayheadUpdate();
			isFirstPlayOfCurrentVideo=false;
			if (offSync)
			{
				if(Log.isDebug()) log.debug("inside playLibraryVideo. offsync: "+offSync);
				offSync=false;
				setTimeout(onVideoCommandSync, 600, videoCommandCollaborationObject.getData());
			}
			//IF video is pending to play as per the data on videoCommandCollaborationObject
			//The current user is a delayed viewer for the current video.Stop and clear the current video 
			//load new video after a given delay of 500 ms.
			if (isPendingVideo)
			{
				if(Log.isDebug()) log.debug("inside playLibraryVideo. pending Video: "+isPendingVideo);
				isPendingVideo=false;
				//The presenter's video command available in shared object
				var videoCommand:String=videoCommandCollaborationObject.getData()[Constants.STATUS];
				//libraryVideoPlayer.mx_internal::videoPlayer.bufferTime=0;
				//IF the received video command is stop/pause
				if (videoCommand == Constants.VIDEO_COMMAND_STOP ||
					videoCommand == Constants.VIDEO_COMMAND_PAUSE || 
					videoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE)
				{
					if(Log.isDebug()) log.debug("inside playLibraryVideo. Invoking delayedSeek for pending Video: toggle false");
					setTimeout(delayedSeek, 500, presenterPlayheadTime, false);
				}
				//OTHERWISE IF the video command is PLAY
				else if (videoCommand == Constants.VIDEO_COMMAND_PLAY || 
					videoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY)
				{
					if(Log.isDebug()) log.debug("inside playLibraryVideo. Invoking delayedSeek for pending Video: toggle true");
					setTimeout(delayedSeek, 500, presenterPlayheadTime, true);
				}
			}
		}
		//IF the video player state is not stopped
		else
		{
			if(Log.isDebug()) log.debug("inside playLibraryVideo. Playing new video. player is not in stopped state:"+ libraryVideoPlayer.state);
			stopPlayheadUpdate();
			//OTHERWISE IF the video is disconnected and the current user is viewer
			//stop and clear  the player
			//stop the playhead update timer and invike the videoCommandSync again to 
			//start the playing process again
			if (libraryVideoPlayer.state == VIDEO_DISCONNECTED && userRole != Constants.PRESENTER_ROLE)
			{
				if(Log.isDebug()) log.debug("inside playLibraryVideo. Player disconnected for viewer");
				try
				{
					if(Log.isInfo()){log.info("Invoke clearvideoplayer from playLibraryVideo");}
					clearVideoPlayer();
				}
				catch (e:Error)
				{
					if(Log.isError()) log.error("Error in playLibraryVideo method:"+ e.getStackTrace());
				}
				isFirstPlayOfCurrentVideo=true;
				stopPlayheadUpdate();
				isPendingVideo=false;
				videoURL="";
				syncTimeOutHandle1=setTimeout(onVideoCommandSync, 150, videoCommandCollaborationObject.getData());
				return;
			}
			//IF there is a new video to be played, sync the video with presenter's video and play it
			if (isPendingVideo)
			{
				if(Log.isDebug()) log.debug("inside playLibraryVideo. Invoking delaySync");
				delaySync(presenterPlayheadTime);
			}
			//In all other cases,if a video is not playing already start playing the new video
			else
			{
				if (!libraryVideoPlayer.playing && libraryVideoPlayer.state != VIDEO_PLAYING)
				{
					if(Log.isDebug()) log.debug("inside playLibraryVideo. Invoking togglePlay");
					playTimeOutHandle5=setTimeout(togglePlay, 100, true);
				}
			}
		}
	}
	//IF the current video is already loaded and played (its not palying for  the first time)
	else
	{
		if(Log.isDebug()) log.debug("inside playLibraryVideo. Playing video after pause:"+ libraryVideoPlayer.state);	
		
			if(Log.isDebug()) log.debug("inside playLibraryVideo. playing current video: "+playingLibraryVideoURL);
			libraryVideoPlayer.mx_internal::videoPlayer.play();
			libraryVideoPlayer.mx_internal::videoPlayer.visible=true;
			startPlayheadUpdate();
		
		//IF the video URL is loaded before reconnection or 
		//current playing video url is not the same as the videourl in server for presenter
		//that means reconnection occurred on presenter side
		//seek the video upto the playheadtime before reconnection and start playing the video
		if ((videoCommandCollaborationObject.getData()[Constants.URL_INFO] == videoURLLoadedBeforeReconnection 
			|| videoURL != videoCommandCollaborationObject.getData()[Constants.URL_INFO]) && 
			userRole == Constants.PRESENTER_ROLE)
		{
			if(Log.isDebug()) log.debug("inside playLibraryVideo. playing current video after reconnection. Invoking delayedSeek");
			videoURLLoadedBeforeReconnection="";
			setTimeout(delayedSeek, 500, playHeadTimeBeforeReconnection, true);
			//reset the playheadtime before reconnection to 0.
			playHeadTimeBeforeReconnection=0;
		}
	}
	
	//if (videoURL != txtYoutubeURL.text)
	//{
		//if (txtYoutubeURL.text != '' && txtYoutubeURL.text == 'Paste YouTube URL here and hit enter key')
			labelFileName.text=videoURL.substring(videoURL.lastIndexOf("/") +1, videoURL.length);
	//}
			
}


private function onPlayheadUpdate(event:mx.events.VideoEvent):void
{
	videoDuration=libraryVideoPlayer.totalTime;
	updateVideoPlayhead();
	
}



/*private function setPlayheadTime(seekPosition:Number):void
{
	libraryVideoPlayer.playheadTime=seekPosition;
	startPlayheadUpdate();	
}
*/
/**
 * 
 * @private
 * Pauses the Library video
 * Invoked from togglePlay method to pause the video
 * 
 *
 * @return void
 * 
 */
private function pauseLibraryVideo():void
{
	if(Log.isDebug()) log.debug("inside pauseLibraryVideo.playhead time:"+libraryVideoPlayer.playheadTime+" Player state:"+libraryVideoPlayer.state);
	//saves the current seek position of video
	var timeSecond:Number=hSliderSeekbar.value;
	//libraryVideoPlayer.mx_internal::videoPlayer.bufferTime=0;
	//IF the player is not disconnected or not  in loading  state and the video is not started palying
	//for presenter reset the playbutton
	// for viewer restart the proccess by invoking the video command sync method
	if (libraryVideoPlayer.state != VIDEO_DISCONNECTED && libraryVideoPlayer.state != VIDEO_LOADING)
	{
		if(Log.isDebug()) log.debug("libraryVideoPlayer.state:"+libraryVideoPlayer.state);
		
		if (libraryVideoPlayer.playheadTime <= 0 || isNaN(libraryVideoPlayer.playheadTime))
		{
			if(Log.isDebug()) log.debug("playheadtime:"+libraryVideoPlayer.playheadTime);
			if (userRole == Constants.PRESENTER_ROLE)
			{
				if(Log.isDebug()) log.debug("Playerstate for presenter:"+libraryVideoPlayer.state);
				setPlayButton(false);
				return;
			}
			else
			{
				if(Log.isDebug()) log.debug("invoking onVideoCommandSync .playhead time:"+libraryVideoPlayer.playheadTime);
				setTimeout(onVideoCommandSync, 200, videoCommandCollaborationObject.getData());
				return;
			}
		}
		//saves the current seekposition
		timeSecond=hSliderSeekbar.value;
		
		//IF the video is already started playing  save the presenter's current playheadtime for viewer
		if (userRole != Constants.PRESENTER_ROLE)
		{
			timeSecond=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
			if(Log.isDebug()) log.debug("inside pauseLibraryVideo. Received time:"+timeSecond);
			hSliderSeekbar.value=timeSecond;
		}
		//IF the current user is a viewer  save the playHeadTimeBeforeReconnection if it is greater than 0.
		//If this value is greater than 0 ,it means the pause function is called after reconnection.
		//update the seekbar to the playheadtime
		else
		{
			if (playHeadTimeBeforeReconnection != 0 && videoURLLoadedBeforeReconnection != "")
			{
				if(Log.isDebug()) log.debug("inside pauseLibraryVideo. invoked after reconnection");
				timeSecond=playHeadTimeBeforeReconnection;
				hSliderSeekbar.value=playHeadTimeBeforeReconnection;
			}
		}
		
		//pause the video 
		libraryVideoPlayer.playheadTime=timeSecond;
		libraryVideoPlayer.mx_internal::videoPlayer.pause();
		libraryVideoPlayer.mx_internal::videoPlayer.visible=true;
		
		if(Log.isDebug()) log.debug("inside pauseLibraryVideo. after invoking pause,player state:"+libraryVideoPlayer.state);
		//Bugfix for 18321 starts
		libraryVideoPlayer.idleTimeout=300000;
		idleTimeOutHandle=setTimeout(updateIdleTimeOut,250000);
		//Bugfix for 18321 ends
				
		labelPosition.text=getFormattedTimeString(timeSecond);
		
	}
	else
	{
		if(Log.isDebug()) log.debug("inside pauseLibraryVideo. player state:"+libraryVideoPlayer.state);
		//IF the current user is presenter
		if (userRole == Constants.PRESENTER_ROLE)
		{
			if(Log.isDebug()) log.debug("inside pauseLibraryVideo. for presenter:"+libraryVideoPlayer.state);
			//IF the module is reconnected pause the video player and 
			//save the playheadtime before reconnection
			if (videoURLLoadedBeforeReconnection != "")
			{
				if(Log.isDebug()) log.debug("inside pauseLibraryVideo. after reconnection:"+videoURLLoadedBeforeReconnection);
				libraryVideoPlayer.mx_internal::videoPlayer.pause();
				//if player is disabled during re-connection enable it
				libraryVideoPlayer.mx_internal::videoPlayer.visible=true;
				hSliderSeekbar.value=playHeadTimeBeforeReconnection;
			}
			else
			{ //IF the player is in  loading  state
				//pause video after a delay of 150ms.
				if(Log.isDebug()) log.debug("inside pauseLibraryVideo. videoplayer:"+libraryVideoPlayer.state);
				
				if (libraryVideoPlayer.state == VIDEO_LOADING)
				{
					//libraryVideoPlayer.mx_internal::videoPlayer.bufferTime=0;
					playTimeOutHandle5=setTimeout(togglePlay, 150, false);
					return;
				}
			}
		}
		//For the viewer restart the process
		else
		{
			if(Log.isDebug()) log.debug("Invoking onVideoCommandSync method. player state"+libraryVideoPlayer.state);
			syncTimeOutHandle1=setTimeout(onVideoCommandSync, 100, videoCommandCollaborationObject.getData());
		}
	}
	if(Log.isDebug()) log.debug("pauseLibraryVideo method ends. ");
}
//bugfix for 18321
private function updateIdleTimeOut():void
{
	clearTimeout(idleTimeOutHandle);
	if(isLibraryVideo && libraryVideoPlayer.state==VIDEO_PAUSED)
	{
		libraryVideoPlayer.idleTimeout=libraryVideoPlayer.idleTimeout-1;
		idleTimeOutHandle=setTimeout(updateIdleTimeOut,250000);
		libraryVideoPlayer.playheadTime=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
	}
	
}
//bugfix for 18321
/**
 * 
 * @private
 * Play YoutubeVideo. Invoked from togglePlay method when user clicks on play button 
 * and the player is in loaded or paused state.
 * 
 *
 * @return void
 * 
 */
private function playYoutubeVideo():void
{
	//IF the youtube video player is ready to play
	if (isUTubePlayerReady)
	{
		//IF the module is reconnected ,reset the coresponding variables. 
		if ((videoCommandCollaborationObject.getData()[Constants.URL_INFO] == videoURLLoadedBeforeReconnection || videoURL != videoCommandCollaborationObject.getData()[Constants.URL_INFO]) && userRole == Constants.PRESENTER_ROLE)
		{
			videoURLLoadedBeforeReconnection="";
			playHeadTimeBeforeReconnection=0;
		}
		//plays youtube video
		youTubePlayer.playVideo();
		//Invoking the CollaborationObject Sync
		if (offSync)
		{
			offSync=false;
			setTimeout(onVideoCommandSync, 300, videoCommandCollaborationObject.getData());
		}
	}
	//if (videoURL != txtYoutubeURL.text)
	//{
		//if (txtYoutubeURL.text != '' && txtYoutubeURL.text == 'Paste YouTube URL here and hit enter key')
			if(userRole!=Constants.PRESENTER_ROLE)
				labelFileName.text=videoURL;
	//}
}

/**
 * 
 * @private
 * Pause Youtube video 
 * 
 *
 * @return void
 * 
 */
private function pauseYoutubeVideo():void
{
	//The current seek time
	var timeSecond:Number=hSliderSeekbar.value;
	if (isUTubePlayerReady)
	{
		youTubePlayer.pauseVideo();
		timeSecond=youTubePlayer.getCurrentTime();
		if (userRole == Constants.PRESENTER_ROLE)
			youTubePlayer.seekTo(timeSecond, true);
		else
		{
			timeSecond=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
			youTubePlayer.seekTo(timeSecond, true);
		}
	}
}

private function stopYoutubeVideo():void
{
	if (isUTubePlayerReady)
	{
		youTubePlayer.seekTo(0,true);
		youTubePlayer.stopVideo();
	}
}

/**
 * 
 * @public
 * handle volume of playing video 
 * 
 *
 * @return void
 * 
 */
public function handleVolume():void
{
	//The mute/unmute option for volume bar
	var serverMuteState:String=videoCommandCollaborationObject.getData()["vol"];
	if (serverMuteState == null)
	{
		muteState=AUDIO_MUTE;
		toggleSound(false);
	}
	else
	{
		if (serverMuteState == AUDIO_UNMUTE)
		{
			muteState=AUDIO_MUTE;
			toggleSound(false);
		}
		else
		{
			muteState=AUDIO_UNMUTE;
			toggleSound(true);
		}
	}
}


/**
 * 
 * @private
 * Enables/disables the youTubePlayerButtons 
 * 
 *
 * @return void
 * 
 */
private function setUTubeVideoPlayButton():void
{
	if (!youTubePlayer)
	{
		return;
	}
	
	if (userRole == Constants.PRESENTER_ROLE)
	{
		youTubePlayer.mouseEnabled=true;
		youTubePlayer.mouseChildren=true;
	}
	else
	{
		youTubePlayer.mouseEnabled=false;
		youTubePlayer.mouseChildren=false;
	}
}

/**
 * 
 * @private
 * This function handles video replay option.
 * 
 *
 * @return void
 * 
 */
private function replayVideo():void
{
	if (Log.isDebug()) log.debug("Inside replayVideo:" + videoURL);
	videoStatus=Constants.VIDEO_STATE_PLAY;
	if (isLibraryVideo)
	{
		setTimeout(togglePlay, 300,true);
	}
	else
	{
		youTubePlayer.playVideo();
	}
}

/**
 * 
 * @public
 * This function handles video stop option.
 * 
 *
 * @return void
 * 
 */
public function stop():void
{
	
	clearTimeout(idleTimeOutHandle);
	if ((videoCommandCollaborationObject.getData()[Constants.URL_INFO] == videoURLLoadedBeforeReconnection || videoURL != videoCommandCollaborationObject.getData()[Constants.URL_INFO]) && userRole == Constants.PRESENTER_ROLE)
	{
		videoURLLoadedBeforeReconnection="";
		playHeadTimeBeforeReconnection=0;
	}
	if (videoURL != "")
	{

		if (userRole == Constants.PRESENTER_ROLE)
		{
			updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_STOP, 0);
			if (Log.isInfo()) log.info("updateVideoProperties:stop url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_STOP + ", timer:" + 0);
			videoSharingStopEventLog(videoURL, String(hSliderSeekbar.value));
		}
		
		if (isLibraryVideo)
		{
			if ((libraryVideoPlayer.state == VIDEO_DISCONNECTED || libraryVideoPlayer.state == VIDEO_BUFFERING || libraryVideoPlayer.state == VIDEO_REWINDING || libraryVideoPlayer.state == VIDEO_SEEKING || libraryVideoPlayer.state == VIDEO_LOADING))
			{
				try
				{
					clearVideoPlayer();
				}
				catch (e:Error)
				{
					if(Log.isError()) log.error("Error in stop method:"+ e.getStackTrace());
				}
				
				isLibraryVideo=false;
				if(Log.isDebug()) log.debug("Invoking loadVideo from stop method");
				loadVideo();
				return;
			}
			else
			{
				clearVideoPlayer();
			}
		}
		else
		{
			if (youTubePlayer != null)
			{
				youTubePlayer.seekTo(0, true);
			}
		}
		setPlayButton(true);
		hSliderSeekbar.value=0;
		updateVideoPlayhead();
		videoStatus=Constants.VIDEO_STATE_STOP;
		updateVideoStatus(videoStatus);
		if(isLibraryVideo)
		{
			libraryVideoPlayer.removeEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE,onPlayheadUpdate);
		}
		else
			timerReset();
		lastStoppedVideoURL=videoURL;
		setTimeout(stopVideoPlayer, 1600);
	}
}

/**
 *
 * @private
 * Audits the "VideoSharingStop" action, when the presenter presses stop button for the video
 *
 * @param url of the video
 * @param videoTime - current video time when stop is pressed
 * @return void
 *
 */
private function videoSharingStopEventLog(url:String, videoTime:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoSharingStop, url, videoTime, null);
}

/**
 * 
 * @private
 * Invoked when the prsenter clicks on the track slider control(seekbar) 
 * invokes seek methods on video and playhead.
 * 
 * @param event of type Event
 * @return void
 * 
 */
private function handleSliderClick(event:Event):void
{
	setVideoSharingActiveTab(); //ashwini
	if (hSliderSeekbar.hasEventListener(SliderEvent.THUMB_PRESS) && (userRole == Constants.PRESENTER_ROLE))
	{
		if (isLibraryVideo)
		{
			
			if (libraryVideoPlayer.state == VIDEO_SEEKING)
				return;
			libraryVideoPlayer.removeEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE,onPlayheadUpdate);
			
		}
		else
			timerStop();
		if (userRole == Constants.PRESENTER_ROLE && (videoStatus == Constants.VIDEO_STATE_PLAY || videoStatus == Constants.VIDEO_STATE_PAUSE))
		{
			handleTimeOutHandle=setTimeout(handlethumbPress, 100, null);
			if(Log.isInfo()) log.info("inside handlesliderClick");
			seekTimeOutHandle3=setTimeout(seekVideo, 250);
		}
		else
		{
			if(Log.isInfo()) log.info("inside handlesliderClick");
			seekTimeOutHandle3=setTimeout(seekVideo, 250);
		}
	}
}

/**
 * 
 * @private
 * This function is invoked on slider thumbPress.
 * 
 * @param event of type Event
 * @return void
 * 
 */
private function handlethumbPress(event:Event):void
{
	clearTimeout(handleTimeOutHandle);
	if (userRole == Constants.PRESENTER_ROLE)
	{
		if (isLibraryVideo)
		{
			if (libraryVideoPlayer.state == VIDEO_SEEKING)
				return;
			
		}
		stopPlayheadUpdate();
		hSliderSeekbar.removeEventListener(SliderEvent.THUMB_PRESS, handlethumbPress);
		hSliderSeekbar.addEventListener(SliderEvent.THUMB_RELEASE, callSeek);
		if (!isLibraryVideo)
			hBoxSeekbar.addEventListener(MouseEvent.MOUSE_OUT, removeToolTip);
	}
	
	if (videoURL != "" && (videoStatus == Constants.VIDEO_STATE_PLAY || videoStatus == Constants.VIDEO_STATE_PAUSE))
	{
		stopPlayheadUpdate();
		if (userRole == Constants.PRESENTER_ROLE)
		{
			var trackValue:Number=hSliderSeekbar.value;
			updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_SLIDERPRESS, trackValue);
			if (Log.isInfo()) log.info("updateVideoProperties:handlethumbPress url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_SLIDERPRESS + ", timer:" + trackValue);
		}
	}
}

/**
 * 
 * @private
 * Invokes seekVideo() method when a thumb_press 
 * event is occurred on seekbar.
 * 
 * @param event of type Event
 * @return void
 * 
 */
private function callSeek(event:Event):void
{
	hSliderSeekbar.removeEventListener(SliderEvent.THUMB_RELEASE,callSeek);
	seekTimeOutHandle4=setTimeout(seekVideo, 300);
}

/**
 * 
 * @private
 * 
 * removes tooltip for seekbar
 * @param event of type Event
 * @return void
 * 
 */
private function removeToolTip(event:Event):void
{
	hBoxSeekbar.removeEventListener(MouseEvent.MOUSE_OUT, removeToolTip);
	hSliderSeekbar.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
	hSliderSeekbar.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false));
}

/**
 * 
 * @private
 * This function is invoked when presenter changes the slider value
 * or when a seek command is received on viewer side
 * or when a viewer enters into videos haring module and the last command received was seek
 * 
 *
 * @return void
 * 
 */
private function seekVideo(position:Number=-1):void
{
	if(Log.isDebug()) log.debug("seekVideo: entered seekVideo time = "+new Date().toString())
	//clearing the timeout call references
	clearTimeout(seekTimeOutHandle1);
	clearTimeout(seekTimeOutHandle2);
	clearTimeout(seekTimeOutHandle3);
	clearTimeout(seekTimeOutHandle4);
	clearTimeout(seekTimeOutHandle5);
	
	//IF the current user is presenter,remove the  
	if (userRole == Constants.PRESENTER_ROLE)
	{
		hSliderSeekbar.addEventListener(SliderEvent.THUMB_PRESS, handlethumbPress);
		hSliderSeekbar.removeEventListener(SliderEvent.THUMB_RELEASE, callSeek);
	}
	
	if(Log.isDebug()) log.debug("seekVideo: videoURL = "+videoURL+" it should not be null. videoStatus = "+videoStatus+" it should be either play or pause")
	
	if (videoURL != "" && (videoStatus == Constants.VIDEO_STATE_PLAY || 
		videoStatus == Constants.VIDEO_STATE_PAUSE))
	{
		if ((isPendingVideo || videoStatus == Constants.VIDEO_STATE_LOADING) && 
			userRole != Constants.PRESENTER_ROLE)
		{
			if(Log.isDebug()) log.debug("seekVideo: isPendingVideo="+isPendingVideo+" if it is true for non presenters then invoke return. userRole= "+userRole);
			return;
		}
		//seekbar time
		var trackValue:Number=0;
		if(position==-1)
		{
			trackValue=hSliderSeekbar.value;
		}
		else
		{
			trackValue=position;
			hSliderSeekbar.value=position;
		}
		if(Log.isDebug()) log.debug("seekVideo: trackValue = "+trackValue);
		if (userRole != Constants.PRESENTER_ROLE)
		{
			if (isNaN(hSliderSeekbar.value))
			{
				trackValue=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
				hSliderSeekbar.value=videoCommandCollaborationObject.getData()[Constants.PLAY_TIME];
			}
		}
		
		
		//-------------seek function for library video Starts------------------
		
		if (isLibraryVideo)
		{
			if(Log.isDebug()) log.debug("seekVideo:  libraryVideoPlayer.state="+libraryVideoPlayer.state);
			//IF the player state is stopped  and the current user is presenter ,then toggleplay is invoked (to seek video in paused state).
			if (libraryVideoPlayer.state == VIDEO_STOPPED)
			{
				if (videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_SLIDERPRESS )
				{	
					if(userRole == Constants.PRESENTER_ROLE)
					{
						if(Log.isDebug()) log.debug("seekVideo: calling togglePlay to pause the video");
						togglePlay(false);
				
						return;
					}
					
				}
				if (userRole!=Constants.PRESENTER_ROLE)
				{				
						if(videoStatus==Constants.VIDEO_STATE_PLAY)
						{
							if(Log.isDebug()) log.debug("seekVideo: videoStatus="+videoStatus);
							libraryVideoPlayer.mx_internal::videoPlayer.play();
						}
						if(videoStatus==Constants.VIDEO_STATE_PAUSE)
						{
							if(Log.isDebug()) log.debug("seekVideo: videoStatus="+videoStatus);
							libraryVideoPlayer.mx_internal::videoPlayer.pause();
						}
					
				}
				
			}
			//IF libraryVideoPlayer is not in loading or disconnected 
			//IF libraryVideoPlayer is not in  seeking or buffering state
			//Then update the playheadtime of player which will seek the video tothe specified position
			//IF the player is in seeking or buffering state ,
			//then stop updating seekbar,set playhead time and
			//invoke startPlayheadUpdate after a delay to continue to update the seekbar.
			if(Log.isDebug()) log.debug("seekVideo: libraryVideoPlayer.state="+libraryVideoPlayer.state);
			if (libraryVideoPlayer.state != VIDEO_LOADING && 
				libraryVideoPlayer.state != VIDEO_DISCONNECTED)
			{
				if (libraryVideoPlayer.state != mx.events.VideoEvent.SEEKING && 
					libraryVideoPlayer.state != mx.events.VideoEvent.BUFFERING)
				{
					libraryVideoPlayer.playheadTime=trackValue;
					startPlayheadUpdate();				
					if(Log.isDebug()) log.debug("seekVideo: Starting playhead update");
				}
				else
				{
					if(Log.isDebug()) log.debug("seekVideo: Stoping playhead update");
				    stopPlayheadUpdate();
					if(Log.isDebug()) log.debug("Inside seek video");
					//#bugfix for 15708
					libraryVideoPlayer.playheadTime=trackValue;					
					seekTimeOutHandle5=setTimeout(startPlayheadUpdate, 100);
					//#bugfix for 15708
					if(Log.isDebug()) log.debug("seekVideo: starting playhead update after 100ms");
				}
				if(Log.isDebug()) log.debug(libraryVideoPlayer.state);
			}
			
			
		}
		else
		{
			if(Log.isDebug()) log.debug("seekVideo: Start playhead update if it is not a library video.");
			startPlayheadUpdate();
			youTubePlayer.seekTo(trackValue, true);
		}
		labelPosition.text=getFormattedTimeString(trackValue);
		if (userRole == Constants.PRESENTER_ROLE)
		{
			if(Log.isDebug()) log.debug("seekVideo: Sending seek details to viewers");
			sendSeekCommand(trackValue);
		}
		
	}
	//bugfix for 15670 starts
	//Seekbar value will be set to 0 if the seek function is invoked before it starts playing
	else
	{
		hSliderSeekbar.value=0;
	}
	//bugfix for 15670 ends
	//-------------seek function for  video Ends------------------
}

/**
 * 
 * @private
 * returns the formatted playtime
 * 
 * @param value of type Number
 * @return String
 * 
 */
private function getFormattedPlayTime(value:Number):String
{
	if (videoURL != "")
		return getFormattedTimeString(hSliderSeekbar.value);
	else
		return ("0:0:0");
}

/**
 * 
 * @private
 * This function sets the tooltip and flag
 * 
 *
 * @return void
 * 
 */
private function toggleRepeat():void
{
	setVideoSharingActiveTab();
	_autoRepeat=btnRepeat.selected;
	if (_autoRepeat)
		btnRepeat.toolTip="Turn repeat off";
	else
		btnRepeat.toolTip="Turn repeat on";
	//repeatButton.toolTip = player.autoRewind ? "Turn repeat off":"Turn repeat on";
}

/**
 * 
 * @private
 * Changes the mute button 
 * 
 * @param mute of type Boolean
 * @return void
 * 
 */
private function setMuteButton(mute:Boolean):void
{
	if (mute)
	{
		if (userRole == Constants.PRESENTER_ROLE)
			btnMuteVolume.toolTip=AUDIO_UNMUTE;
		btnMuteVolume.setStyle("icon", muteIcon);
	}
	else
	{
		if (userRole == Constants.PRESENTER_ROLE)
			btnMuteVolume.toolTip=AUDIO_MUTE;
		btnMuteVolume.setStyle("icon", soundIcon);
	}
}

/**
 * 
 * @public
 * Changing the mute option for video module
 * 
 *
 * @return void
 * 
 */
public function toggleState():void
{
	setVideoSharingActiveTab();
	if (muteState == AUDIO_UNMUTE)
		muteState=AUDIO_MUTE;
	else
		muteState=AUDIO_UNMUTE;
	toggleSound(false);
}

/**
 * 
 * @private
 * This function deals with sound handling.
 * 
 * @param muteClick of type Boolean:whether the user clicked on mute button
 * @return void
 * 
 */
private function toggleSound(muteClick:Boolean):void
{
	if (muteState == AUDIO_UNMUTE)
	{
		muteState=AUDIO_MUTE;
		setMuteButton(true);
	}
	else
	{
		muteState=AUDIO_UNMUTE;
		setMuteButton(false);
	}
	if (videoURL != "")
	{
		if (muteState == AUDIO_MUTE)
		{
			if (isLibraryVideo)
			{
				libraryVideoPlayer.volume=0;
			}
			else
			{
				if (youTubePlayer != null)
					youTubePlayer.mute();
			}
			muteState=AUDIO_MUTE;
		}
		else if (videoURL != "")
		{
			if (isLibraryVideo)
			{
				libraryVideoPlayer.volume=(hSliderVolumeBar.value / 100);
			}
			else
			{
				if (youTubePlayer != null)
				{
					youTubePlayer.unMute();
					youTubePlayer.setVolume(hSliderVolumeBar.value);
				}
			}
			muteState=AUDIO_UNMUTE;
		}
	}
	
	//Volume can be varied by each of the participants. Where as Mute/Unmute is controlled by the presenter
	if (userRole == Constants.PRESENTER_ROLE && muteClick)
	{
		videoCommandCollaborationObject.setValue("vol",muteState);	
		videoCommandCollaborationObject.send("controlVol",muteState);
	}
}

/**
 * Add comments for this function */
/**
 * 
 * @public
 * gets the autoRepeat value
 * 
 *
 * @return Boolean
 * 
 */
[Bindable]
public function get autoRepeat():Boolean
{
	return _autoRepeat;
}
/**
 * 
 * @public
 * sets the autoRepeat value
 * 
 * @param auto of type Boolean
 * @return void
 * 
 */
public function set autoRepeat(auto:Boolean):void
{
	_autoRepeat=auto;
}


/**
 * 
 * @public
 * Clear the video sharing
 * variables while the netconnection is closed/failed/rejected
 * This method also sets the Variables used after successful reconnection
 * 
 *
 * @return void
 * 
 */
public function clearVideoSharingProperties():void
{
  // #Bugfix for issues in administrator logout
	if(ClassroomContext.userVO.role==Constants.ADMIN_TYPE ||
		ClassroomContext.userVO.role==Constants.MASTER_ADMIN_TYPE)
	{
		return ;
	}
	if (videoURL != "" && videoURLLoadedBeforeReconnection == "")
	{
		isSyncAfterReconnected=false;
		isConnectionLost=true;
		videoURLLoadedBeforeReconnection=videoURL;
		playHeadTimeBeforeReconnection=hSliderSeekbar.value;
	}
	else
	{
		if (videoURLLoadedBeforeReconnection != "")
		{
			isSyncAfterReconnected=false;
			isConnectionLost=true;
		}
	}
	if (userRole != Constants.PRESENTER_ROLE)
	{
		videoURL="";
		videoStatus="";	
		isFirstPlayOfCurrentVideo=true;
		timerReset();
		if (libraryVideoPlayer) {
			libraryVideoPlayer.removeEventListener(mx.events.VideoEvent.PLAYHEAD_UPDATE,onPlayheadUpdate);
		}
		hSliderSeekbar.value=0;
		videoDuration=0;
		if(txtYoutubeURL!=null)
		{
			txtYoutubeURL.text="";
		}
		try
		{			
			labelPosition.text="0:0";
			lengthLabel.text="0:0";
			youTubeVideoLoader.unloadAndStop(true);
			if(Log.isInfo) log.info("Invoking clearVideoPlayer");
			clearVideoPlayer();
			setPlayButton(true);
			
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in clearVideoSharingProperties method:"+ e.getStackTrace());
		}
	}
	else
	{
		if (videoStatus == Constants.VIDEO_STATE_PLAY || videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_PLAY || videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_SEEK_PLAY)
			togglePlay(false);
	}
	if(isConnectionLost)
	{
		setPlayButton(false,false,"Reconnecting player");
		btnStop.enabled=false;
		btnRepeat.enabled=false;
	}
}

/**
 * 
 * @private
 * Sets the visibility of popout button
 * 
 * @param isVisible of type Boolean
 * @return void
 *
 */
private function popOutBtnVisble(isVisible:Boolean):void
{
	if (isVisible)
	{
		btnPopOut.alpha=1;
	}
	else
	{
		btnPopOut.alpha=0;
	}
}

/**
 * 
 * @public
 * Pops out the video sharing window or vice versa
 * 
 *
 * @return void
 *
 */
public function popOutVideoWindow():void
{
	//IF the popout window is closed, the consolidated view of the module will be displayed
	if (!isPopOut)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.vidbox.setStyle("backgroundColor", "#E0EFFB");
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMessageForFullScreenForMXMLComponents(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.vidbox, Constants.FULLSCREEN_MSG);
		initializeVideoSharingWindow();
		isPopOut=true;
		btnPopOut.setStyle("icon", popInIcon);
		btnPopOut.toolTip="Exit Popout";
		popOutVideoSharingEventLog();
	}
	//OTHERWISE video Sharing module will be popped out into a new window
	else
	{
		if (fileManager)
		{
			fileManager=null;
		}
		applicationType::desktop{
			if (videoSharingWindow != null){
				//close() method is not available for web.
				videoSharingWindow.close();
			}
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unSetMessageForFullScreenForMXMLComponents(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.vidbox);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initVideoShare();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.vidbox.setStyle("backgroundColor", "#ffffff");
			resizeVideoPlayer();
			btnPopOut.bottom=0;
			btnPopOut.setStyle("icon", popOutIcon);
			btnPopOut.toolTip="Pop-Out";
		}
		isPopOut=false;
		popInVideoSharingEventLog();
	}
}
/**
 *
 * @private
 * Audits the "PopInVideoSharing" action, when the user Pops in/closes the video sharing tab
 *
 * @return void
 *
 */
private function popInVideoSharingEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.popInVideoSharing, null, null, null);
}

/**
 *
 * @private
 * Audits the "PopOutVideoSharing" action, when the user Pops out the video sharing tab
 *
 * @return void
 *
 */
private function popOutVideoSharingEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.popOutVideoSharing, null, null, null);
}

/**
 * 
 * @public
 * Resizes the video player
 * 
 *
 * @return void
 * 
 */
public function resizeVideoPlayer():void
{
	if (isLibraryVideo)
	{
		this.vBoxVideoPlayer.percentHeight=75;
		this.libraryVideoPlayer.percentWidth=100; 
		//bugfix for 16672
		this.libraryVideoPlayer.percentHeight=100;
	}
	else
	{
		setTimeout(resizeYoutubeVideoPlayer, 300);
	}
}

/**
 * 
 * @public
 * actvates the video sharing popout window 
 * 
 *
 * @return void
 * 
 */
public function activatePopOutWindow():void
{
	//activate() method is not available for web.
	applicationType::desktop
	{
		videoSharingWindow.activate();
	}
}
/**
 * 
 * @public
 * Closes the video sharing window.
 * 
 *
 * @return void
 * 
 */
public function closeVideoSharingWindow():void
{
	//closed() method is not available for web.
	applicationType::desktop
	{
		if (this.videoSharingWindow != null && !this.videoSharingWindow.closed)
		{
			this.popOutVideoWindow();
		}
		else
		{
			this.isPopOut=true;
			this.popOutVideoWindow();
		}
	}
}

/**
 * 
 * @public
 * This function is invoked when multiple window is selected.
 * This creates window for Video Sharing
 * 
 *
 * @return void
 * 
 **/
public function initializeVideoSharingWindow():void
{
	applicationType::desktop
	{
		videoSharingWindow=new VideoSharingWindow();
		videoSharingWindow.open(true);
		videoSharingWindow.maximize();
		videoSharingWindow.hBoxVideo.addChild(this);
		videoSharingWindow.videoShareObject=this;
		
		this.width=videoSharingWindow.width;
		this.height=videoSharingWindow.height;
		this.resetPlayerControls();
		if (this.userRole != Constants.PRESENTER_ROLE)
		{
			this.handleVolume();
		}
		//activate() method is not available for web.
		//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isVideoShareModuleAvailable=true;	
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
			videoSharingWindow.activate();
		
	}
}

private function setVideoSharingActiveTab():void{
	// index of video sharing is 4
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveWindowInSO(4);
}

/**
 * 
 * @private
 * This method clears the library video player
 *
 *
 * @return void
 * 
 */
private function closeLibraryVideoplayer():void
{
	libraryVideoPlayer.close();
	if(Log.isInfo()){log.info("Inside closeLibraryVideoplayer: Invoke clear video player");}
	clearVideoPlayer();
	libraryVideoPlayer.source="";
}
/**
 * 
 * @private
 * Clears video player for library video
 * 
 *
 * @return void
 * 
 */
private function clearVideoPlayer():void
{
	if(Log.isInfo()){log.info("clearing video player");}
	
	libraryVideoPlayer.mx_internal::videoPlayer.stop();
	libraryVideoPlayer.mx_internal::videoPlayer.clear();
}

/**
 * 
 * @public
 * Mute the sound of video at client side for delayed user
 * 
 * @param muted of type String
 * @return void
 *
 */
public function controlVol(muted:String):void
{
	if (userRole != Constants.PRESENTER_ROLE)
	{
		if ((muteState != AUDIO_MUTE && muted == AUDIO_MUTE) || (muteState != AUDIO_UNMUTE && muted == AUDIO_UNMUTE))
			toggleSound(true);
	}
}

/**
 * 
 * @private
 * Enables the "Go" button when the video url is changed in the text control
 * 
 *
 * @return void
 * 
 */
private function ontxtUrlChange():void
{
	btnYoutubeURL.enabled=true;
}

private function onClickStop():void
{
	setVideoSharingActiveTab();
	stop();
}
private function refreshVideo():void
{
	
	if(videoCommand==Constants.VIDEO_COMMAND_PLAY )
	{	
		
		isRefreshVideo=true;
		if(userRole==Constants.PRESENTER_ROLE)
		{
			var playheadTime:Number=libraryVideoPlayer.playheadTime;
			setTimeout(seekAfterRefresh,100,playheadTime);
		}
		else
		{
			requestPresenterVideoPlayHeadTime();
		}
		stopPlayheadUpdate();	
		libraryVideoPlayer.stop();			
		libraryVideoPlayer.play();		
		
	}
	
}

	
private function seekAfterRefresh(time:Number):void
{
	libraryVideoPlayer.playheadTime=time;
	startPlayheadUpdate();
	isRefreshVideo=false;
}