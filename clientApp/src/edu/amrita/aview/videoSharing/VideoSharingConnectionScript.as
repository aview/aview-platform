////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * File	    	: VideoSharingConnectionScript.as
 * Module		: videoSharing
 * Developer(s) : LIVIN M.MIRANDA, ANU P,SOUMYA M.D
 * Reviewer(s)	: Sivaram SK, Meena S
 * 
 * This File inculdes the connection script and collaboration code for video sharing module. This script 
 * is included in VideoSharing.mxml.
 * */

import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;

import flash.events.TimerEvent;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.VideoEvent;
import mx.logging.Log;
import mx.utils.StringUtil;
import mx.utils.UIDUtil;

/**
 * Netconnection varible for connecting to FMS Server.
 */
public var mediaServerConnection:MediaServerConnection;
/**
 * Shared object of video sharing to maintain the synchronization  between all the users.
 */
public var videoCommandCollaborationObject:CollaborationObject;
/**
 * CollaborationObject to provide the status of video on each client.
 * This is used to display the  statitics of videosharing on presenter screen
 */
public var videoStatusCollaborationObject:CollaborationObject;

/**
 * set to true when a video is set to be played
 * after sometime
 */
public var isPendingVideo:Boolean=false;

/**
 * The playtime for video on presenter side
 * This is used when a client is not in
 * sync with the presenter video command
 */
public var presenterPlayheadTime:Number=0;

/**
 * Set to true when video loaded on client is not in sync with
 * video commands set by presenter
 */
public var offSync:Boolean=false;

/**
 * The constant that refers to the videoCommandsharedobject.
 * This is passedto the collaboration service to create a collaboration object.
 */
public static const VIDEO_COMMAND_ID:String="VideoCommand";

/**
 * The constant that refers to the video status info shared object.
 */
public static const VIDEO_STATUS_ID:String="VideoStatus";
/**
 *set to true when the video sharing module is reconnected
 */
private var isSyncAfterReconnected:Boolean=false;

/**
 * set to true when a tryPause method is set to be invoked
 * after a delay.
 */
private var isSetTryPause:Boolean=false;

/**
 * set to false when loadVideo method is set to be invoked after a delay.
 * (ie.loading video for latecoming user is set to be invoked).
 * 
 */
private var delayLoadLogin:Boolean=true;

/**
 * The videoCommand that used to control video
 * its set by the sharedObject
 */
private var videoCommand:String="";


private var oldMuteState:String=null;
/**
 *Timeout refernce for seek function 
 */
private var seekTimeOutHandle1:uint=0;
/**
 *Timeout refernce for seek function 
 */
private var seekTimeOutHandle2:uint=0;
/**
 *Timeout refernce for seek function 
 */
private var seekTimeOutHandle3:uint=0;
/**
 *Timeout refernce for sync function 
 */
//PNCR: since there is only one syncTimeOutHandle. Please remove the number 1
private var syncTimeOutHandle1:uint=0;

/**
 * Variable that holds the last video command
 * used to check whether video has loaded and played.
 */
private var lastvideoCommandReceived:String="";


/**
 * @private
 * initializing video sharing module
 * If the selected module in the live session is 4 (which is index of video sharing) then activate
 * video sharing module for current user.
 *
 * @return void
 */
private function initVideoShare():void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveModule(true);
}

/**
 * @public
 * sets the netConnection and initializes Collaboration Objects
 * @param netConnection
 * @return void
 */
public function setConnection(mediaServerConnection:MediaServerConnection):void
{
	this.mediaServerConnection=mediaServerConnection;
	connectCollaborationObjects();
	//IF the netConnection is lost during a libraryvideo is playing(after a successful reconnection)
	//Stop the videoplayer and reset the related parameters
	if ((isConnectionLost || videoURLLoadedBeforeReconnection == "") && isLibraryVideo)
	{
		try
		{
			isLibraryVideo=false;
			closeLibraryVideoplayer();
			videoURLLoadedBeforeReconnection="";
			playHeadTimeBeforeReconnection=0;
			labelFileName.text="";
			isConnectionLost=false;
			hSliderSeekbar.value=0;
			labelPosition.text="0:0";
			lengthLabel.text="0:0";
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in setConnection method :"+ e.getStackTrace());
		}
	}

}

/**
 * @public
 * This function is invoked  from server to know the current play time.
 * This function sends the current playheadTime of presenter video time to server.
 * @param clientName
 * @return void
 * */

public function getPlayheadTime(viewerName:String):void
{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
	{
		if (viewerName != null && viewerName != "")
		{
			//The current seek time in seebar.
			var sliderTime:Number=hSliderSeekbar.value;
			mediaServerConnection.netConnection.call("sendPlayheadTimeToUser", null, sliderTime, viewerName);
		}
	}
}

/**
 * @private
 * Initialize the videoloading process for latecoming users
 *
 * @return void
 */
private function initializeDelayedVideoLoading():void
{
	isUTubePlayerReady=false;
	isPendingVideo=true;
	loadVideo();
}



//--------Collaboration object creation and updation script STARTS---------
/**
 *  @public
 *  This method initiates the connection to collaboration objects for video sharing
 *  and get the references to those objects
 *  sets the sync funtions for both collaboration objects.
 *  @param null
 *  @return void
 */
public function connectCollaborationObjects():void
{
	//connects to collaboration api
	videoCommandCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject(VIDEO_COMMAND_ID);
	videoStatusCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject(VIDEO_STATUS_ID);
	
	
	if (videoCommandCollaborationObject)
	{
		//sets the synchandler for videoCommandCollaboration object 
		videoCommandCollaborationObject.setOnSync(onVideoCommandSync);
        videoCommandCollaborationObject.setOnSend("controlVol",controlVol);
		//if the current user is presenter and this method is not invoked after a sucessful reconnection						
		if (userRole == Constants.PRESENTER_ROLE && (!isConnectionLost) && videoURLLoadedBeforeReconnection == "")
		{
			//set the url variable to null
			videoURL="";
		}
	}
	if (videoStatusCollaborationObject)
	{
		//sets the synchandler for videoStatusCollaborationObject 
		videoStatusCollaborationObject.setOnSync(onVideoStatusSync);
	}
}

/**
 * @private
 * This method updates the seek command to the collaboration object from presenterside.
 * @param playheadTime
 * @return void
 */
private function sendSeekCommand(playheadTime:uint):void
{
	if (videoStatus == Constants.VIDEO_STATE_PLAY)
	{
		updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_SEEK_PLAY, hSliderSeekbar.value);
		if (Log.isInfo()) log.info("updateVideoProperties:seekSlider url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_SEEK_PLAY + ", timer:" + playheadTime);
		videoSharingSeekEventLog(videoURL, String(hSliderSeekbar.value), Constants.VIDEO_STATE_PLAY);
	}
	else
	{
		updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_SEEK_PAUSE, hSliderSeekbar.value);
		if (Log.isInfo()) log.info("updateVideoProperties:seekSlider url:" + videoURL + ", command:" + Constants.VIDEO_COMMAND_SEEK_PAUSE + ", timer:" + playheadTime);
		videoSharingSeekEventLog(videoURL, String(hSliderSeekbar.value), Constants.VIDEO_STATE_PAUSE);
	}
}

/**
 *
 * @private
 * Audits the "VideoSharingSeek" action, when the presenter drags the progress bar drops it
 *
 * @param url of the video
 * @param videoTime - current video time seek bar is released
 * @param currentState - current playing state of the video (Play, Pause or Stop) while the seeking is done
 * @return void
 *
 */
private function videoSharingSeekEventLog(url:String, videoTime:String, currentState:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoSharingSeek, url, videoTime, currentState);
}

/**
 * @private
 * updates the videoCommandCollaborationObject
 * @param videoURL
 * @param videoCommand
 * @param timeSecond
 * @return void
 */
private function updateVideoProperties(videoURL:String, videoCommand:String, timeSecond:Number):void
{
	if(Log.isDebug()) log.debug("inside updateVideoProperties:command:"+videoCommand);
	if (userRole == Constants.PRESENTER_ROLE && !isConnectionLost)
	{
		videoCommandCollaborationObject.lock();
		videoCommandCollaborationObject.setValue("urlinfo", videoURL);
		videoCommandCollaborationObject.setValue("videocommand", videoCommand);
		videoCommandCollaborationObject.setValue("playTime", timeSecond);
		videoCommandCollaborationObject.unlock();
		videoSharingLoadEventLog(videoURL, (youTubeURL == UTUBE_URL || youTubeURL == UTUBE_URL_SECURE) ? youTubeURL : "Library");
	}
}

/**
 *
 * @private
 * Audits the "VideoSharingLoad" action, when the presenter is loading video for sharing
 *
 * @param url of the video
 * @param location - Library or Youtube
 * @return void
 *
 */
private function videoSharingLoadEventLog(url:String, location:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoSharingLoad, url, location, null);
}

/**
 * @private
 * @param videoStatus
 * update the videoStatus in videoStatusCollaborationObject which will invoke onVideoStatusSync in all
 * connected clients.
 * @return void
 */
private function updateVideoStatus(videoStatus:String):void
{
	videoStatusCollaborationObject.lock();
	videoStatusCollaborationObject.setValue(ClassroomContext.userVO.userName, videoStatus);
	videoStatusCollaborationObject.unlock();

}


//--------Collaboration object creation and updation script ENDS---------

//The functions for displaying video for latecoming users starts----
/**
 * @public
 * This function is called from fms when the user requests for the current player time of presenter.
 * This  is required  when a viewer enters into videosharing
 *  after the presenter has started playing video.
 *
 * @param playheadTime
 * @param requestedUserName The username who requseted the playheadtime to presenter
 * @return void
 */
public function playVideoForLateComingUser(playheadTime:Number, requestedUserName:String):void
{
	if(isRefreshVideo)
	{
		seekAfterRefresh(playheadTime);
		return;
	}
	//IF video is started playing or the  current video is stopped playing on the presenter side and 
	//its not started on viewer side the following block will be executed
	if (playheadTime > 0 || (playheadTime == 0 && videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_STOP))
	{
		//IF a video is pending to play for the current user
		// and  the current user is a latecoming viewer or the module is reconnected 
		//then  play the video in sync with the presenter video
		if ((userRole != Constants.PRESENTER_ROLE || isConnectionLost) && ClassroomContext.userVO.userName == requestedUserName && isPendingVideo)
		{
			
			//IF the current video is a youtube video play it  from the current playheadtime.
			if (!isLibraryVideo)
			{
				try
				{
					videoStatus=Constants.VIDEO_STATE_LOADING;
					//load youtube video and seeks the video  upto the playheadtime
					youTubePlayer.cueVideoById(youTubeVideoId, playheadTime);
					youTubePlayer.playVideo();
					youTubePlayer.setPlaybackQuality("medium");
					updateVideoStatus(videoStatus);
					hSliderSeekbar.value=playheadTime;
					isPendingVideo=false;
					delaySync(playheadTime);
					presenterPlayheadTime=0;
				}
				catch (e:Error)
				{
					if(Log.isError()) log.error("Error in playVideoForLateComingUser method :"+ e.getStackTrace());
				}
			}
			//OTHERWISE  IF a library video is loaded ,seek the video upto playhead time and play the video
			else
			{
				if (videoStatus == Constants.VIDEO_STATE_LOADED)
				{
					setTimeout(delaySync, 800, playheadTime);
					
				}
			}
			//starts the playHeadUpdateTimer to update the seek bar and time display
		      startPlayheadUpdate();
			//variable for enabling or disabling sound for shared video on userside
			var muteCheck:String=videoCommandCollaborationObject.getData()["vol"];
			if (muteCheck == AUDIO_MUTE)
				setTimeout(controlVol, 250, AUDIO_MUTE);
			
		}
	}
	//OTHERWISE IF the current user is a viewer get the current playheadtime from the presenter
	else
	{
		isPendingVideo=true;
		requestPresenterVideoPlayHeadTime();
		return;
	}
}

private function requestPresenterVideoPlayHeadTime():void
{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE)
	{
		mediaServerConnection.netConnection.call("getPlayheadTimeForLateComingUser", null, ClassroomContext.userVO.userName);
	}
}
/**
 * @private
 * Seeks the video upto the presenter's playheadtime
 * This method is invoked when user is not sync with video play commands
 * set by the presenter node
 * This video is invoked only when a library video is playing
 * (eg: presenter node: video is seeked
 *  viewer node:video is loaded,then the delaySeek
 *  will be set to be invoked after some time)
 *
 * @param playheadTime
 * @param toggle
 * @return void
 */
private function delayedSeek(playheadTime:Number, toggle:Boolean):void
{
	//IF a video is playing/paused on presenter side and the viewer side the video is not in sync with
	//presenter video 
	//seek upto the playheadtime and pause the video if it is in the paused state
	//seek upto the playheadtime and play the video if its in playing state
	//If the video player is on buffering state or loading state invoke this method after some time.
	
	if (!isPendingVideo)
	{
		if (presenterPlayheadTime > 0 && presenterPlayheadTime != playheadTime)
			playheadTime=presenterPlayheadTime;
		presenterPlayheadTime=0;
		if (!toggle)
		{
			libraryVideoPlayer.playheadTime=playheadTime;
			setTimeout(togglePlay, 300, false);
			hSliderSeekbar.value=playheadTime;
		}
		else
		{
			if (libraryVideoPlayer.state == VIDEO_BUFFERING || libraryVideoPlayer.state == VIDEO_LOADING)
			{
				setTimeout(resetDelaySeek, 600, playheadTime);
			}
			else
			{
				timerStop();
				libraryVideoPlayer.playheadTime=playheadTime;
				hSliderSeekbar.value=playheadTime;
				if(Log.isDebug()) log.debug("delayed seek");
				seekTimeOutHandle1=setTimeout(seekVideo, 250,playheadTime);
			}
		}
	}
}

/**
 * @private
 * resets the delaySeek method call.
 * @param playheadTime
 * @return void
 */
private function resetDelaySeek(playheadTime:Number):void
{
	stopPlayheadUpdate();
	libraryVideoPlayer.playheadTime=playheadTime;
	hSliderSeekbar.value=playheadTime;
	if(Log.isDebug()) log.debug("inside resetDelaySeek");
	seekTimeOutHandle2=setTimeout(seekVideo, 250,playheadTime);
}

/**
 * @private
 * Invoked when a viewer enters to the video module after the video is started playing
 * This method is used to sync the video  on viewer node with the presenter node video
 *
 * @param sliderTim
 * @return void
 */
private function delaySync(sliderTim:Number):void
{
	//The lastest video command received from presenter.
	var videoCommand:String=videoCommandCollaborationObject.getData()[Constants.STATUS];
	//IF a library video is started playing or a video is loaded to play
	if (videoStatus == Constants.VIDEO_STATE_LOADED || (isLibraryVideo && videoStatus == Constants.VIDEO_STATE_PLAY))
	{
		//IF video is either started playing or the video is seeked to a point
		if (videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_PLAY || videoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY)
		{
			isFirstPlayOfCurrentVideo=true;
			presenterPlayheadTime=sliderTim;
			
			if (sliderTim > 0 && isLibraryVideo)
			{
				//play the video after 300 ms delay
				setTimeout(togglePlay, 300, true);
			}
			else
				//play the video after 250 ms delay
				setTimeout(togglePlay, 250, true);
			
			if (isConnectionLost)
				isConnectionLost=false;
			
		}
		//OTHERWISE IF the video status  is paused or stopped (as per the status in collabration object)
		//or if the module is reconnected for a presenter
		//stop the video if it is a youtube video
		else if (videoCommand == Constants.VIDEO_COMMAND_PAUSE || videoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE || 
			videoCommand == Constants.VIDEO_COMMAND_STOP || 
			(isPendingVideo && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE
				&& isConnectionLost))
		{
			
			if (!isLibraryVideo)
				togglePlay(false);
			else
			{
				presenterPlayheadTime=sliderTim;
				isFirstPlayOfCurrentVideo=true;
				//IF the video  is started playing  or the video staus is stopped on collaboration object and
				// IF the video is not started at viewer end then play the video. 
				if (sliderTim > 0 || (sliderTim == 0 && videoCommandCollaborationObject.getData()[Constants.STATUS] == Constants.VIDEO_COMMAND_STOP))
				{
					setTimeout(togglePlay, 300, true);
				}
				if (isConnectionLost)
					isConnectionLost=false;
			}
		}
		
	}
	//IF the video is not loaded/playing/paused /stopped on 
	//presenter side then invoke this method after 100 ms.
	else
	{
		setTimeout(delaySync, 100, sliderTim);
	}
}



//Sync functions for collaboration obect starts------------
/**
 * @public
 * This function is called when videocommand is set from the presenter node. *
 *  @param videoCollaborationData The sharded object data
 *  @return void
 * */
public function onVideoCommandSync(videoCollaborationData:Object):void
{
	if(Log.isDebug()) log.debug("inside onVideoCommandSync---------------START------------------");
	
	clearTimeout(syncTimeOutHandle1);
	if (!ClassroomContext.IS_VIDEO_SHARING_ENABLED|| videoCollaborationData==null)
		return;
	//the seekbar time 
	var curSliderVal:Number;
	//The time difference between the presenter's playhead tume and current seekbar time.
	var delayTimeCalc:Number;
	//holds the delay in milliseconds
	var timeCalc:Number;
	//The latest availble video url shared by presenter via collaboration object
	var newURL:String=null;
	
	newURL=StringUtil.trim(videoCollaborationData[Constants.URL_INFO]);
	
	//IF the currently playing video is not same as the one in collaborationobject
	//reset the last video url 
	//update the lastvideoCommandReceived variable
	if (videoURL != newURL)
	{
		lastStoppedVideoURL="";
		lastvideoCommandReceived=videoCollaborationData[Constants.STATUS];
	}
	else if (lastvideoCommandReceived == Constants.VIDEO_COMMAND_LOAD && videoStatus != Constants.VIDEO_STATE_LOADED)
		//update the lastvideoCommandReceived variable
		lastvideoCommandReceived=Constants.VIDEO_COMMAND_LOAD;
	else
		//update the lastvideoCommandReceived variable
		lastvideoCommandReceived="";
	
	videoCommand=videoCollaborationData[Constants.STATUS];
	//gets the current playheadtime for presenter video
	var presenterVideoTime:Number=videoCollaborationData[Constants.PLAY_TIME];
	userRole=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole;
	
	if (Log.isInfo()) log.info("onSync: currentURL:" + videoURL + ", newURL:" + newURL + ", command:" + videoCommand + ", presenterVideoTime:" + presenterVideoTime);
	//IF reconnected and the module is not in sync with presenter
	if (isConnectionLost && this.mediaServerConnection && !isSyncAfterReconnected)
	{
		videoURL=videoURLLoadedBeforeReconnection;
		isSyncAfterReconnected=true;
		//IF the current user is Presenter
		if (userRole == Constants.PRESENTER_ROLE)
		{
			//reset isConnectionLost variable			
			isConnectionLost=false;
			//IF the video is paused now
			if (videoStatus != Constants.VIDEO_STATE_PAUSE)
			{ //IF current video is library video close the library video player
				//and restart the video loading process (as the module is reconnected)
				if (isLibraryVideo)
				{
					isFirstPlayOfCurrentVideo=true;
					closeLibraryVideoplayer();
					labelFileName.text=videoURL.substring(videoURL.lastIndexOf("/")+1, videoURL.length);
					setLibraryVideoProperties();
					
				}
			}
			//OTHERWISE seek to the last playheadtime &
			//start playing the video after resetting the source to player
			else
			{
				timerStop();
				sendSeekCommand(playHeadTimeBeforeReconnection);
				if (isLibraryVideo)
				{
					libraryVideoPlayer.source=playingLibraryVideoURL;
					hSliderSeekbar.value=playHeadTimeBeforeReconnection;
					isFirstPlayOfCurrentVideo=false;
				}
				else
				{
					youTubePlayer.cueVideoById(youTubeVideoId, playHeadTimeBeforeReconnection);
					youTubePlayer.setPlaybackQuality("medium");
					hSliderSeekbar.value=playHeadTimeBeforeReconnection;
				}
			}
			setPlayButton(true);
			btnStop.enabled=true;
			btnRepeat.enabled=true;
			isConnectionLost=false;
			return;
		}
		//IF the current user is not presenter and a new video is available
		//IF the user is a late coming viewer and the received command is "load"
		//then,load Video after 500 ms
		//OTHERWISE if the received command is play,pause or seek ,then load the video after 1000ms
		//---------START--------------------------
		if (userRole != Constants.PRESENTER_ROLE)
		{
			if (videoURLLoadedBeforeReconnection !== newURL)
			{
				isConnectionLost=false;
				playHeadTimeBeforeReconnection=0;
				videoURLLoadedBeforeReconnection="";
				videoURL=newURL;
				initVideoShare();
				if (videoCommand != Constants.VIDEO_COMMAND_LOAD)
				{
					if (!isPendingVideo || videoURL != StringUtil.trim(videoCollaborationData[Constants.URL_INFO]))
					{
						isPendingVideo=true;
						//Setting delay becausethe player won't be ready  for late login users
						//and it will take some time to complete initVideoShare();	
						setTimeout(initializeDelayedVideoLoading, 1000);
					}
					
					return;
				}
				else
				{
					if (delayLoadLogin)
					{
						delayLoadLogin=false;
						setTimeout(loadVideo, 500);
					}
					else
					{
						loadVideo();
					}
					return;
				}
			}
			
		}
		//----------------------------END----------------
		try
		{
			//clear both library video player or youtube video player
			if (!isLibraryVideo)
			{
				youTubeVideoLoader.unloadAndStop(true);
			}
			else
			{
				if(Log.isError()) log.error("Invoking clearVideoPlayer");
				clearVideoPlayer();
			}
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in onVideoCommandSync method:"+ e.getStackTrace());
		}
		if(Log.isDebug()) log.debug("Invoking load video");
		setTimeout(loadVideo, 3000);
		return;
	}
	// IF no new url is available clear the corresponding video player
	//---------------------------START-----------------
	if (newURL == null || newURL == "")
	{
		try
		{
			if (youTubePlayer != null)
			{
				if ((!isConnectionLost && videoURLLoadedBeforeReconnection == "" && 
					userRole == Constants.PRESENTER_ROLE) ||
					userRole != Constants.PRESENTER_ROLE)
				{
					videoURL="";
					labelFileName.text="";
					youTubeVideoLoader.unloadAndStop(true);
				}
			}
			else if (libraryVideoPlayer != null)
			{
				if (userRole != Constants.PRESENTER_ROLE)
				{
					videoURL="";
					labelFileName.text="";
					libraryVideoPlayer.stop();
				}
				
			}
			
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in onVideoCommandSync method:"+ e.getStackTrace());
		}
		return;
	}
	//---------------------------END------------------------------
	// IF the video is loaded  for presenter and started playing/paused/seeked/stopped the video.
	//and the viewer is entered into the module then the initVideoShare() method will take some time to laod the
	//module and thus loadVideo method will be invoked after a delay
	//------------------------START-------------------------------
	if (videoURL == "" && newURL != "" && videoCommand != Constants.VIDEO_COMMAND_LOAD && (userRole != null && userRole != Constants.PRESENTER_ROLE))
	{
		initVideoShare();
		videoURL=newURL;
		//IF the video command is to stop ,then load the video after 500ms
		if (videoCommand == Constants.VIDEO_COMMAND_STOP && videoURL != newURL && delayLoadLogin)
		{
			videoURL=newURL;
			delayLoadLogin=false;
			//If late login then it will take some time to do initVideoShare();
			setTimeout(loadVideo, 500);
			
			return;
		}
		//Setting delay becausethe player won't be ready  for late login users
		//and it will take some time to complete initVideoShare();	
		if (!isPendingVideo || videoURL != StringUtil.trim(videoCollaborationData[Constants.URL_INFO]))
		{
			isPendingVideo=true;
			//IF the video command is play/pause/seek ,then load the video after 1000ms
 			setTimeout(initializeDelayedVideoLoading, 1000);
		}
		return;
	}
	//------------------------END-------------------------------
	//updates the video commands in viewer side
	if (userRole != null && userRole != "" && userRole != Constants.PRESENTER_ROLE && videoCommand != null )
	{
		if(oldMuteState==null ||(oldMuteState!=null && oldMuteState==videoCollaborationData['vol']))
		{
			updateVideoCommandForViewer(videoCollaborationData);
		}    
	}
	oldMuteState=videoCollaborationData['vol'];
	if(Log.isDebug()) log.debug("inside  onVideoCommandSync---------------END------------------");
}

/**
 * @public
 * This method is invoked when the status of video is changed on each client
 * @param videoStausData  :Current video status of all users
 * @return void
 * */
public function onVideoStatusSync(videoStausData:Object):void
{	

	//Shared object is not yet initialized
	if(videoStatusCollaborationObject==null)
	{
		return;
	}
	//This method is invoked with null as parameter from Users.as when a change in no:of online users occurs
	//so the videoStausData is again retrieved from videoStatusCollaborationObject
	videoStausData=videoStatusCollaborationObject.getData();
	
	//Shared object is not yet initialized
	if (videoStausData == null)
	{
		return;
	}
	
	playingVideoCount=0;
	loadedVideoCount=0;
	pausedVideoCount=0;
	stoppedVideoCount=0;
	//The latest video URL available in collaboration object.
	var newURL:String=StringUtil.trim(videoCommandCollaborationObject.getData()[Constants.URL_INFO]);
	if (newURL != "" && newURL != null)
	{
		if (userRole == Constants.PRESENTER_ROLE && videoURL == "" && videoURLLoadedBeforeReconnection == "")
		{
			videoURL="nil";
			//Setting to nil so that when one more moderator login nodes reset.			
			updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_LOAD, 0);
			videoURL="";
			updateVideoProperties(videoURL, Constants.VIDEO_COMMAND_LOAD, 0);
		}
		//updating the video sharing statitics for presenter
		for (var uName:String in videoStausData)
		{
			//The staus available in collaboration object .
			var syncStatus:String=videoStausData[uName];
			if (syncStatus == Constants.VIDEO_STATE_PLAY)
			{
				playingVideoCount++;
			}
			else if (syncStatus == Constants.VIDEO_STATE_STOP)
			{
				stoppedVideoCount++;
			}
			else if (syncStatus == Constants.VIDEO_STATE_PAUSE)
			{
				pausedVideoCount++;
			}
			else if (syncStatus == Constants.VIDEO_STATE_LOADED)
			{
				loadedVideoCount++;
			}
			
		}
	}
		labelVideoStatusInfo.text="Number of Users: " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.numUsers.toString() + "  ;  Current Status: Playing: " + playingVideoCount.toString() + ", Paused: " + pausedVideoCount.toString() + ", Stopped: " + stoppedVideoCount.toString() + ", Loaded: " + loadedVideoCount.toString();
}

/**
 * @private
 * updates the videosharing module for viewer based on the latest command received
 * from the presenter.
 * @param videoCollaborationData
 * @return void
 */
private function updateVideoCommandForViewer(videoCollaborationData:Object):void  
{
	
	//the seekbar time 
	var curSliderVal:Number=0;
	//The time difference between the presenter's playhead tume and current seekbar time.
	var delayTimeCalc:Number=0;
	//holds the delay in milliseconds
	var timeDelayInms:Number=0;
	//Holds the playheadtime of presenter.
	var presenterVideoTime:Number=videoCollaborationData[Constants.PLAY_TIME];
	//The new url that is available in shared object.
	var newURL:String=StringUtil.trim(videoCollaborationData[Constants.URL_INFO]);
	//The video controlling command that received
	var newVideoCommand:String=videoCollaborationData[Constants.STATUS];
	if(Log.isDebug()) log.debug("inside updateVideoCommandForViewer:Videocommand:"+newVideoCommand+" video status:"+videoStatus);
	
	
	//IF the moderator is exited from video module
	//Then no needt to set the selected module as video module
	//Bug fix: #4557
	if (newVideoCommand != Constants.VIDEO_COMMAND_STOP)
	{
		initVideoShare();
	}
	if (newVideoCommand == Constants.VIDEO_COMMAND_LOAD)
	{
		
		if(Log.isDebug()) log.debug("load video");
		if (videoURL == newURL && videoStatus == Constants.VIDEO_STATE_PLAY)
		{ //For handling the case when viewer video has not finished 
			//presenter side has finished and he clicks play again.
			videoStatus=Constants.VIDEO_STATE_STOP;
			updateVideoStatus(Constants.VIDEO_STATE_LOADED);
			return;
		}
		//If the url did not change do not process
		//Bug fix:#4564
		if (videoURL != newURL)
		{
			
			videoURL=newURL;
			//If late login and video still in load state 
			//then it will take some time to do initVideoShare();
			if (delayLoadLogin)
			{
				delayLoadLogin=false;
				setTimeout(loadVideo, 500);
			}
			//If not latecoming user load video
			else
			{
				loadVideo();
			}
		}
		
	}
	//IF the video command is not to load a video and the last command was to load a video and 
	// the video is not loaded invoke onVideoCommandSync after 100ms
	else if (lastvideoCommandReceived == Constants.VIDEO_COMMAND_LOAD && videoStatus != Constants.VIDEO_STATE_LOADED)
	{
		if(Log.isDebug()) log.debug("Invoke  onVideoCommandSync after 100 sec");
		syncTimeOutHandle1= setTimeout(onVideoCommandSync, 100, null);
		return;
	}
	else if (newVideoCommand == Constants.VIDEO_COMMAND_PLAY)
	{
		if(Log.isDebug()) log.debug("play video");
		
		//Play if the current status is not play
		if (videoStatus != Constants.VIDEO_STATE_PLAY)
		{
			if (lastStoppedVideoURL != "")
			{
				lastStoppedVideoURL="";
			}
			hSliderSeekbar.value=presenterVideoTime;
			togglePlay(true);
		}
	}
	//OTHERWISE  IF the  current video command is to seek the video or to pause or to replay
	// and the video is already loaded then play the video from the new position
	else if (videoStatus == Constants.VIDEO_STATE_LOADED && 
		(newVideoCommand == Constants.VIDEO_COMMAND_SLIDERPRESS || 
		newVideoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE ||
		newVideoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY ||
		newVideoCommand == Constants.VIDEO_COMMAND_PAUSE || 
		newVideoCommand == Constants.VIDEO_COMMAND_REPLAY))
	{
		if(Log.isDebug()) log.debug("Invoking togglePlay Videocommand:"+newVideoCommand+"video status:"+videoStatus);
		
		if (lastStoppedVideoURL != "")
		{
			lastStoppedVideoURL="";
		}
		setTimeout(togglePlay, 300, true);
		offSync=true;
		return;
	}
	//OTHERWISE IF video is paused and video status is not loaded
	//ie video status is playing/paused
	//IF the current viewer video is in sync with presenter then pause video.
	//OTHERWISE seek the video to the current presenter playheadtime and restart playing 
	//------------START------------------
	else if (newVideoCommand == Constants.VIDEO_COMMAND_PAUSE)
	{
		curSliderVal=hSliderSeekbar.value;
		if (isNaN(curSliderVal))
		{
			curSliderVal=0;
			hSliderSeekbar.value=0;
		}
		delayTimeCalc=presenterVideoTime - curSliderVal;
		if(Log.isDebug()) log.debug("delay:"+delayTimeCalc);
		
		/*if (delayTimeCalc > 0)
		{
			timeDelayInms=delayTimeCalc * 1000;
			if(Log.isDebug()) log.debug("Pause video after:"+timeDelayInms+"try pause:"+isSetTryPause);
			if (!isSetTryPause)
			{
				
				isSetTryPause=true;
				if(Log.isDebug()) log.debug("Invoking trypause:"+isSetTryPause);
				setTimeout(tryPause, timeDelayInms);
			}
		}*/
		/*if(delayTimeCalc>0)
		{
			stopPlayheadUpdate();
			hSliderSeekbar.value=presenterVideoTime;
			if(Log.isDebug()) log.debug("delay btw presenter video and viewer video is greater than zero.Invoking pauseLibraryVideo");
			pauseLibraryVideo();
			seekVideo()
			if(Log.isDebug()) log.debug("Invoking toggleplay after 250 ms");
			setTimeout(togglePlay, 250, false);
		}*/
		if (delayTimeCalc == 0)
		{
			if(Log.isDebug()) log.debug("Invoking toggleplay");
			togglePlay(false);
		}
		else 
		{
			stopPlayheadUpdate();
			hSliderSeekbar.value=presenterVideoTime;
			if(Log.isDebug()) log.debug("Invoking togglePlay from synchandler");
			
			
			if(isLibraryVideo)
			{
				libraryVideoPlayer.pause();
				idleTimeOutHandle=setTimeout(updateIdleTimeOut,250000);
				if(libraryVideoPlayer.state==VIDEO_SEEKING )
					libraryVideoPlayer.addEventListener(mx.events.VideoEvent.STATE_CHANGE,onPlayerStateChange);
				
			}
			else
			{
				pauseYoutubeVideo();
				
			}
			videoStatus=Constants.VIDEO_STATE_PAUSE;
			updateVideoStatus(videoStatus);
			seekVideo();
			setPlayButton(true);
		}
		
	}
	//------------End------------------
	
	else if (newVideoCommand == Constants.VIDEO_COMMAND_STOP)
	{
		if(Log.isDebug()) log.debug(" Stop video");
		delayLoadLogin=false;
		//stop video
		stop();
	}
	else if (newVideoCommand == Constants.VIDEO_COMMAND_REPLAY)
	{
		if(Log.isDebug()) log.debug(" replay video");
		
		curSliderVal=hSliderSeekbar.value;
		if (isNaN(curSliderVal))
		{
			curSliderVal=0;
			hSliderSeekbar.value=0;
		}
		//If video has not reached its end then set delay for trying replay again
		if (curSliderVal > 0)
		{
			delayTimeCalc=hSliderSeekbar.maximum - curSliderVal;
			timeDelayInms=delayTimeCalc * 1000;
			if (delayTimeCalc > 0)
				setTimeout(tryReplay, timeDelayInms);
			else
				setTimeout(tryReplay, 300);
		}
		//OTHERWISE  play the video once again
		else
		{
			if (lastStoppedVideoURL != "")
			{
				lastStoppedVideoURL="";
			}
			replayVideo();
		}
	}
	//IF the presenter changed the seekposition while playing the video
	//and if on viewer side the video is not loaded then update the playhead time
	//update the presenter slider time and change the seek position
	else if (newVideoCommand == Constants.VIDEO_COMMAND_SEEK_PLAY)
	{
		if(Log.isDebug()) log.debug(" seek play video"+" isPendingVideo:"+isPendingVideo+" videoStatus:"+videoStatus+" presenterPlayheadTime"+presenterPlayheadTime);
		if (isPendingVideo || videoStatus == Constants.VIDEO_STATE_LOADING || presenterPlayheadTime > 0)
		{
			presenterPlayheadTime=videoCollaborationData[Constants.PLAY_TIME];
			startPlayheadUpdate();
			return;
		}
		else
		{
			//varible to hold the shared object value for 'vol' to apply mute/unmute option to the video
			var serverMuteState:String=videoCollaborationData["vol"];
			if (serverMuteState == null || (muteState == AUDIO_MUTE && serverMuteState == AUDIO_MUTE) || (muteState == AUDIO_UNMUTE && serverMuteState == AUDIO_UNMUTE))
			{
				hSliderSeekbar.value=presenterVideoTime;				
				seekVideo();
			}
		}
		
	}
	//If presenter updated the playheadtime and the video is paused
	else if (newVideoCommand == Constants.VIDEO_COMMAND_SEEK_PAUSE)
	{
		
		if(Log.isDebug()) log.debug(" seek pause video"+" isPendingVideo:"+isPendingVideo+" videoStatus:"+videoStatus+" presenterPlayheadTime"+presenterPlayheadTime);
		//IF the selected video is loading then initialize the playheadtimer
		//OTHERWISE update the seek position and stop video playing
		if (isPendingVideo || videoStatus == Constants.VIDEO_STATE_LOADING || presenterPlayheadTime > 0)
		{
			startPlayheadUpdate();
			return;
		}
		else
		{
			stopPlayheadUpdate();
			hSliderSeekbar.value=presenterVideoTime;						
			
			if(isLibraryVideo)
			{
				libraryVideoPlayer.mx_internal::videoPlayer.pause();
				idleTimeOutHandle=setTimeout(updateIdleTimeOut,250000);
				if(libraryVideoPlayer.state==VIDEO_SEEKING )
					libraryVideoPlayer.addEventListener(mx.events.VideoEvent.STATE_CHANGE,onPlayerStateChange);
			}
			else
			{
				pauseYoutubeVideo();
				
			}
			videoStatus=Constants.VIDEO_STATE_PAUSE;
			updateVideoStatus(videoStatus);
			seekVideo();
			setPlayButton(true);
		}
	}
	//IF the viewer received a sliderpress command before loading the video,do nothing
	//otherwise stop the playhead update timer
	else if (newVideoCommand == Constants.VIDEO_COMMAND_SLIDERPRESS)
	{
		if(Log.isDebug()) log.debug(" SLIDERPRESS ");
		if (isPendingVideo || videoStatus == Constants.VIDEO_STATE_LOADING || presenterPlayheadTime > 0)
			return;
		else
			timerStop();
	}

}

private function onPlayerStateChange(event:mx.events.VideoEvent):void
{
	libraryVideoPlayer.removeEventListener(mx.events.VideoEvent.STATE_CHANGE,onPlayerStateChange);
	libraryVideoPlayer.pause();
}

/**
 * @private
 * This function is called when sync changes and user side has not reached the playhead time to Pause.
 * This function is called after executing the delay.
 *
 * @return void
 */
private function tryPause():void
{
	
	isSetTryPause=false;
	//Holds the current status of playing video.
	var currstat:String=videoCommandCollaborationObject.getData()[Constants.STATUS];
	if(Log.isDebug()) log.debug("Inside tryPause.Current video status:"+currstat);
	if (currstat == Constants.VIDEO_STATE_PAUSE)
	{
		togglePlay(false);
	}
	
}

/**
 * @private
 * This function is invoked when replay option has been set
 * and in viewer side the playing video is not ended.
 *
 * @return void
 */
private function tryReplay():void
{
	//IF the timer doesn't have an event listener,the playing video is ended
	//start replaying video
	//if (!playHeadUpdateTimer.hasEventListener(TimerEvent.TIMER))
	//{
		lastStoppedVideoURL="";
		replayVideo();
	//}
	//ELSE
	//try replay after sometime
	//else
		//setTimeout(tryReplay, 300);
}

