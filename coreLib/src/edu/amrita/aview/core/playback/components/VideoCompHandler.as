////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
//RTCR: Avoid 'this' from description and use component name instead of 'this'.Also give proper description
/**
 *
 * File			: VideoCompHandler.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)	: Remya T
 *
 * This is old play back video component.This file not used in new MUI play back
 *
 */
import edu.amrita.aview.core.playback.VideoPlayer;

import mx.core.mx_internal;
import mx.events.FlexEvent;

//RTCR: Give description for all variables
public var videoPlayer:VideoPlayer=new VideoPlayer();
private var previousWidth:Number=0;
[Bindable]
private var resizeCount:Number=0;
[Bindable]
private var vidWidth:Number=0;
[Bindable]
private var vidHeight:Number=0;

//Playback Icons
[Bindable]
[Embed(source="../assets/images/volumeCntrl.png")]
public var playBack_unclicked:Class;
[Bindable]
[Embed(source="../assets/images/volumMute.png")]
public var playBack_clicked:Class;
[Bindable]
public var playBackIcon:Class=playBack_unclicked;

//RTCR: Follow the rules to add description for all the functions in this file.
private function resolution():void{
	var tempWidth:Number;
	
	vidHeight=VideoContiner.height;
	tempWidth=(vidHeight / 3) * 4;
	if (tempWidth >= VideoContiner.width){
		vidWidth=VideoContiner.width;
		vidHeight=(vidWidth / 4) * 3;
	}
	else{
		vidWidth=tempWidth;
	}
}

public function onVidResize():void{
	resolution();
	videoDisp.height=vidHeight;
	videoDisp.width=vidWidth;
	addSpace.width=(VideoContiner.width / 2) - (videoDisp.width / 2);
	muteButton.y=volumeBox.y + 5;
}


protected function titlewindow1_creationCompleteHandler(event:FlexEvent):void{
	mx_internal::closeButton.height=mx_internal::closeButton.width=18;

}
