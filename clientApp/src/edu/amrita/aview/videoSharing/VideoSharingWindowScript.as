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
 * File	    	: VideoSharingWindowScript.as
 * Module		: videoSharing
 * Developer(s) : LIVIN M.MIRANDA,SOUMYA M.D
 * Reviewer(s)	: Sivaram SK, Meena S
 * 
 *  Script File for VideoSharingWindow.mxml.This file includes the initialization ,resizing and 
 *   closing method for VideoSharingWindow.
 * */


applicationType::DesktopWeb{
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.videoSharing.VideoSharing;

import flash.utils.setTimeout;

import mx.core.FlexGlobals;


/**Platform specific imports*/
applicationType::desktop
{
	//AIREvent is not available for web
	import mx.events.AIREvent;
	//Window is not available for web
	import spark.components.Window;
}
/**
 * Image for Pop-In icon
 *  
 * */
[Bindable]
[Embed(source="assets/images/windows_nofullscreen.png")]
public var popInIcon:Class;

/**
 * @public
 * Instance of VideoSharing component that actually holds the video player. 
 *
 * @return void
 */
public var videoShareObject:VideoSharing=null;

/**
 * @private
 * sets the exit pop out button.Invoked when the video sharing window is enabled.
 *
 * @return void
 */
private function initWindow():void
{
	
	//title property is not available for web
	applicationType::desktop
	{
		this.title="Video Sharing (A-VIEW - " + ClassroomContext.aviewClass.className + ")";
	}
	this.videoShareObject.btnPopOut.visible=false;
	this.videoShareObject.btnPopOut.bottom=30;
	this.videoShareObject.isPopOut=true;
	this.videoShareObject.btnPopOut.visible=true;
	this.videoShareObject.btnPopOut.toolTip="Exit Popout";
	this.videoShareObject.btnPopOut.setStyle("icon", popInIcon);
}

/**
 * @private
 * resizing the video player which depends on the window size and video player
 * @return void
 */
private function resizePlayer():void
{
	if (videoShareObject == null)
		return;
	videoShareObject.width=this.width;
	videoShareObject.height=this.height;
	videoShareObject.vBoxVideoPlayer.height=videoShareObject.height / 100 * 75;
	//resize Library video player
	if (videoShareObject.isLibraryVideo)
	{
		videoShareObject.vBoxVideoPlayer.height=videoShareObject.height / 100 * 75;
		videoShareObject.libraryVideoPlayer.percentWidth=100;
		videoShareObject.libraryVideoPlayer.height=videoShareObject.height / 100 * 75;
	}
	if (videoShareObject.videoURL != "")
	{
		if (videoShareObject.vBoxVideoPlayer.numChildren != 0)
		{
			//resize youtubde video player
			//youtube video player needs to be loaded from the youtube network.
			// So a delay is applied before resizing video player.
			if (!videoShareObject.isLibraryVideo)
			{
				setTimeout(videoShareObject.resizeYoutubeVideoPlayer, 300);
			}
			else if (videoShareObject.isLibraryVideo)
			{
				videoShareObject.libraryVideoPlayer.percentWidth=100;
				videoShareObject.libraryVideoPlayer.height=videoShareObject.vBoxVideoPlayer.height;
			}
		}
	}
	//If the fullscreen video is enabled withot 
	//loading youtube video or library video
	if (videoShareObject.videoURL != "" && videoShareObject.vBoxVideoPlayer.numChildren == 0 && !videoShareObject.isLibraryVideo)
	{
		videoShareObject.vBoxVideoPlayer.height=videoShareObject.height / 100 * 75;
	}
	setTimeout(videoShareObject.repositionPlayerControlButtons, 100);
}

/**
 *@public
 *@param event mWwindowActivateHandler for desktop
 *@return void
 */
applicationType::desktop
{
	public function mWwindowActivateHandler(event:AIREvent):void
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multipleWindowActivateHandler("videoShareMW");
	}
}

/**
 * @public
 * Invoked when the pop-out window is closed
 *
 * @return void
 */
public function closeVideoSharingWindow():void
{
	    //for desktop application
		applicationType::desktop
		{
			if (!this.closed)
			{
				videoShareObject.popOutVideoWindow();
			}
			else
			{
				videoShareObject.isPopOut=true;
				videoShareObject.popOutVideoWindow();
			}
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.vidShareIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.vidShare_unclicked;
}
}