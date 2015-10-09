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
 *
 * File			: PlayerControlHandler.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 *  Reviewer(s)	: Remya T
 *
 * PlayerControlHandler class is used to set or get the value of various objects which are used in PlayerControl Class
 */
import edu.amrita.aview.playback.player.MediaEvents.*;

import flash.events.Event;
import flash.events.MouseEvent;

import spark.events.TrackBaseEvent;

/**
 * Value for Central timer.
 */
[Bindable]
private var _centeralTime:String;
/**
 * Boolean for check  whether the controller need play button or not
 */
[Bindable]
public var _isPlay:Boolean;
/**
 * Boolean for to check  whether the controller need mute state or not
 */
[Bindable]
public var _isMute:Boolean;
/**
 * Boolean for to check  whether the controller need  seek bar or not
 */
[Bindable]
private var _isSeekBar:Boolean;
/**
 * Value for seek bar
 */
[Bindable]
private var _seekBarValue:Number;
/**
 * Icon class for Play button
 */
[Bindable]
[Embed("../assets/images/Play.png")]
private var playIcon:Class;
/**
 * Icon class for pause button
 */
[Bindable]
[Embed("../assets/images/pause.png")]
private var pauseIcon:Class;
/**
 * Icon class for stop button
 */
[Bindable]
[Embed("../assets/images/Stop.png")]
private var stopIcon:Class;
/**
 * Icon class for fullscreen button
 */
[Bindable]
[Embed("../assets/images/full screen.png")]
private var fscreenIcon:Class;
/**
 * Icon class for volume control
 */
[Bindable]
[Embed("../assets/images/speaker_on.png")]
private var volumeIcon:Class;
/**
 * Icon class for mute button
 */
[Bindable]
[Embed("../assets/images/mute.png")]
private var muteIcon:Class;

[Inspectable(defaultValue="00:00:00", enumeration="00:00:00")]
/**
 * Set the _centeralTime value
 * @param Time of  type String
 *
 */
public function set centeralTime(Time:String):void{
	_centeralTime=Time;
}

/**
 * Get the _centeralTime value
 * @return of  String
 *
 */
public function get centeralTime():String{
	return _centeralTime;
}


[Inspectable(defaultValue="false", enumeration="true,false")]
/**
 * Set the seekbar visibility
 * @param value of type Boolean
 *
 */
public function set isSeekBar(value:Boolean):void{
	_isSeekBar=value;
	
}


/**
 * Get  the seekbar visibility
 * @return  Boolean
 *
 */
public function get isSeekBar():Boolean{
	return _isSeekBar;
}

/**
 * Get the value of seekbar
 * @return Number
 */

public function get seekBarValue():Number{
	return _seekBarValue;
}

/**
 * Set the value of seekbar
 * @param value of type Number
 *
 */
public function set seekBarValue(value:Number):void{
	_seekBarValue=value;
}

/**
 * Get the play button  visibility
 * @return  Boolean
 *
 */
public function get isPlay():Boolean{
	return _isPlay;
}

//RTCR: Add @return to comment
/**
 * Set the play button  visibility
 * @param value of type Boolean
 *
 */
public function set isPlay(value:Boolean):void{
	_isPlay=value;
	if (!btnPlay)
		return;
	if (isPlay){
		btnPlay.setStyle("icon", pauseIcon);
	}
	else{
		btnPlay.setStyle("icon", playIcon);
	}
}

//RTCR: Add @param to comment
/**
 * Get the mute button  visibility
 * @return  Boolean
 *
 */
public function get isMute():Boolean{
	return _isMute;
}

//RTCR: Add @return to comment
/**
 * Set the mute  button  visibility
 * @param value of type Boolean
 *
 */
public function set isMute(value:Boolean):void{
	_isMute=value;
	if (!btnMute)
		return;
	if (isMute){
		btnMute.setStyle("icon", muteIcon);
	}
	else{
		btnMute.setStyle("icon", volumeIcon);
	}
}

/**
 * @protected
 * This function invoke while the user draging the thumb of seek bar
 *
 * @param event of type TrackBaseEvent
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function seekbar_thumbDragHandler(event:TrackBaseEvent):void{
	// TODO Auto-generated method stub
	
}

/**
 * @protected
 * This function invoke while the user press the thumb of seek bar
 *
 * @param event of type TrackBaseEvent
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function seekbar_thumbPressHandler(event:TrackBaseEvent):void{
	// TODO Auto-generated method stub
	
}

/**
 * @protected
 * This function invoke while the user change the value of seek bar
 *
 * @param event of type Event
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function seekbar_changeHandler(event:Event):void{
	// TODO Auto-generated method stub
	
}

/**
 * @protected
 * This function invoke while the user release the thumb of seek bar
 *
 * @param event of type TrackBaseEvent
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function seekbar_thumbReleaseHandler(event:TrackBaseEvent):void{
	// TODO Auto-generated method stub
	this.dispatchEvent(new OnSeekRelease(event.currentTarget.value));
	
}

/**
 * @protected
 * This function invoke while the user click on play Button
 *
 * @param event of type MouseEvent
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function play_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	if (isPlay){
		this.dispatchEvent(new onMediaControlerEvent("Pause"));
		isPlay=false;
	}
	else{
		this.dispatchEvent(new onMediaControlerEvent("Play"));
		isPlay=true;
	}
}

/**
 * @protected
 * This function invoke while the user click on mute Button
 *
 * @param event of type MouseEvent
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function mute_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	if (!isMute){
		isMute=true;
		this.dispatchEvent(new OnVolumeChangedEvent(0));
	}
	else{
		isMute=false;
		this.dispatchEvent(new OnVolumeChangedEvent(volume.value));
	}
}

/**
 * @protected
 * This function invoke while the user change values on volume control bar
 *
 * @param event of type Event
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function volume_changeHandler(event:Event):void{
	// TODO Auto-generated method stub
	isMute=false;
	this.dispatchEvent(new OnVolumeChangedEvent(event.currentTarget.value));
}

/**
 * @protected
 * This function invoke while the user click on stop Button
 *
 * @param event of type MouseEvent
 * @return void
 */
//RTCR: Change function name(Avoid underscore)
protected function stop_clickHandler(event:MouseEvent):void{
	// TODO Auto-generated method stub
	this.dispatchEvent(new onMediaControlerEvent("Stop"));
}
