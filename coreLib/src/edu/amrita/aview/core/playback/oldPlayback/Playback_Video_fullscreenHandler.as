// ActionScript file
import edu.amrita.aview.core.playback.oldPlayback.Aview_Playback;

import flash.display.StageDisplayState;
import flash.events.Event;

import mx.events.ResizeEvent;

public var playbackInstance:Aview_Playback;

/**
 * This method initializes the component.
 * This is invoked at the creation complete of the component.
 * This makes the component FULLSCREEN and adds an eventListener
 * to listen the Resize Event.
 *
 *
 * @return void
 */
private function init():void
{
	this.stage.displayState=StageDisplayState.FULL_SCREEN;
	this.addEventListener(Event.RESIZE, checkForNormalMode);
	
	setSize("fullscreen");
}

/**
 * This method is used for handling the ESC key on fullscreen mode.
 * When user presses the ESC key, resize event happens,
 * which will invoke the method 'normalScreen'.
 *
 *
 * @return void
 */
private function checkForNormalMode(event:ResizeEvent):void
{
	if (this.stage.displayState == StageDisplayState.NORMAL)
	{
		this.removeEventListener(Event.RESIZE, checkForNormalMode);
		normalScreen();
	}
}

/**
 * This method is used for closing the window of teacher video.
 * This also loads the teacher video to the normal playback window.
 *
 *
 * @return void
 */
public function normalScreen():void
{
	if (videoFullScreenLoader.numChildren > 0)
	{
		setSize("normal");
		
		playbackInstance.videoPanel.doubleClickEnabled=true;
		playbackInstance.videoPanel.addChild(videoFullScreenLoader.getChildByName("videoContainer"));
	}
	//For Web: Commented following logic.Since close() method not available for web.
	//this.close();
}

/**
 * This method is used for setting size of the components while switching to different modes.
 * This is invoked from methods 'init()' and 'normalScreen()'.
 *
 * @param mode - to know the current mode. Possible values are "fullscreen" and "normal".
 * @return void
 */
private function setSize(mode:String):void
{
	if (mode == "fullscreen")
	{
		playbackInstance.videoDisplay.width=playbackInstance.videoContainer.width;
		playbackInstance.videoDisplay.height=playbackInstance.videoContainer.height * 0.96;
		playbackInstance.seekBar.width=playbackInstance.videoControlBar.width * 0.82;
	}
	//if normal mode
	else
	{
		playbackInstance.videoDisplay.percentWidth=100;
		playbackInstance.videoDisplay.percentHeight=87.5;
		playbackInstance.seekBar.width=95;
	}
}
