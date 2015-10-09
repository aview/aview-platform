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
 * File			: preTestHandler.as
 * Module		: Pretest
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 * 
 * preTestHandler.as contains business logic for Pretest module
 */


/**
 * Importing flash library
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;

import flash.display.GradientType;
import flash.events.ActivityEvent;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.SampleDataEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundCodec;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.media.scanHardware;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.ByteArray;

import mx.collections.ArrayList;
import mx.events.FlexEvent;

import spark.components.VideoDisplay;
import spark.filters.GlowFilter;

import views.toolSets.PreTest.Events.PretestIconChangeEvent;
import views.toolSets.PreTest.PreTestConstants;

/**
 * Video variables holds camear and video display object
 */
private var camObj:Camera;
private var video:Video;
private var vidDisplay:VideoDisplay;
[Bindable]
private var videoDeveice:ArrayList = new ArrayList(Camera.names);

/**
 * Speaker variables holds netconnection object
 */
private var isAudioPlayBtnClilcked:Boolean = false;
public var ncAudioPlaying:NetConnection;
private var fmsURL:String = "";
public var ncPrechecking:NetConnection;
private var nsAudioPlaying:NetStream;
private var connectionCheck:int=0;
private var isSpeakerTestPassed:Boolean = false;
/**
 * Microphone variables to hold microphone names, sound data and recorded audio
 */
private var recordedData:ByteArray;
private var micObj:Microphone;
private var soundData:Sound;
private var isRecordAudioBtnClicked:Boolean = false;
private var isPlayRecordBtnClicked:Boolean = false;
[Bindable]
private var audioDeveice:ArrayList = new ArrayList(Microphone.names);
private var glowFltr:spark.filters.GlowFilter;

/**
 * @private
 *
 * To get the audio from microphone and record the audio.
 *
 * @param event of MouseEvent
 * @return void
 */
private function recordAudio(event:MouseEvent):void
{
	//If user clicks on stop record button, stop to recoed audio
	//Otherwise recorde the audio
	if(!isRecordAudioBtnClicked)
	{
		isRecordAudioBtnClicked = true;
		event.target.label = "Stop Recording";
		recordedData = new ByteArray();
		micObj = Microphone.getMicrophone( audioDrivers.selectedIndex );
		micObj.codec = SoundCodec.NELLYMOSER;
		micObj.setUseEchoSuppression(true);
		micObj.rate=44;
		micObj.encodeQuality=10;
		micObj.setSilenceLevel(0);
		micObj.gain = 50;
		micObj.addEventListener(SampleDataEvent.SAMPLE_DATA, getMicAudio);
		micObj.addEventListener(ActivityEvent.ACTIVITY, micActivityEventHandler);
		micObj.dispatchEvent(new ActivityEvent(ActivityEvent.ACTIVITY));
		btnPlayRecAudio.enabled = false;
		micLevelCanvas.visible = true;
		btnNext.enabled = false;
		btnPrev.enabled = false;
	}
	else
	{
		isRecordAudioBtnClicked =false;
		event.target.label = "Record Audio";
		btnPlayRecAudio.enabled = true;
		micLevelCanvas.visible = false;
		micObj.removeEventListener(SampleDataEvent.SAMPLE_DATA, getMicAudio);
		micObj.removeEventListener(ActivityEvent.ACTIVITY, micActivityEventHandler);
		this.removeEventListener(Event.ENTER_FRAME, micEnterFrameEventHandler);
	} 
	
}
/**
 * @private
 *
 * To convert audio data to bytearray 
 *
 * @param event of SampleDataEvent
 * @return void
 */
private function getMicAudio(event:SampleDataEvent): void
{
	recordedData.writeBytes(event.data);
} 
/**
 * @private
 *
 * Event listener for mic activity level
 *
 * @param event of ActivityEvent
 * @return void
 */
private function micActivityEventHandler(event:ActivityEvent):void
{
	this.addEventListener(Event.ENTER_FRAME, micEnterFrameEventHandler);
}
/**
 * @private
 *
 * Event listener to display the mic activity level
 *
 * @param event of Event
 * @return void
 */
private function micEnterFrameEventHandler(event:Event):void
{ 
	micLevelCanvas.graphics.clear();
	micLevelCanvas.graphics.lineStyle(2,0xB0171F);
	micLevelCanvas.graphics.lineGradientStyle(GradientType.LINEAR,[0x00AAB1,0xDCDCDC],[1,1],[0,255]);
	micLevelCanvas.graphics.beginGradientFill(GradientType.LINEAR,[0x00F5FF,0xFFFFFF],[1,1],[0,255]);
	micLevelCanvas.graphics.drawRect(0, 0, (micObj.activityLevel * 3),micLevelCanvas.height);
	micLevelCanvas.graphics.endFill();
}
/**
 * @private
 *
 * To play back the recorded audio
 *
 * @param event of MouseEvent
 * @return void
 */
private function playBackAudio(event:MouseEvent):void
{
	//If user clicks on stop playback button, stop the playback audio
	//Otherwise play the recorded audio
	if(!isPlayRecordBtnClicked)
	{
		isPlayRecordBtnClicked = true;
		event.target.label = "Stop Playing";
		//Set byte array position
		recordedData.position = 0;
		soundData = new Sound();
		soundData.addEventListener(SampleDataEvent.SAMPLE_DATA, playRecordedAudio);
		var channel:SoundChannel;
		channel = soundData.play();
		channel.addEventListener(Event.SOUND_COMPLETE, stopPlayback);
		micLevelCanvas.visible = false;
		this.addEventListener(Event.ENTER_FRAME,addGlowEffectToMicroPhone);
	}
	else
	{
		stopPlayback(new Event(Event.SOUND_COMPLETE));
	} 
}
/**
 * @private
 *
 * To add glow effect to the play back button for indication
 *
 * @param event of Event
 * @return void
 */
private function addGlowEffectToMicroPhone(event:Event):void
{
	if(btnPlayRecAudio.filters.length == 0)
	{
		glowFltr = new GlowFilter(0x00F5FF,1,25,25);
		btnPlayRecAudio.filters=[glowFltr];
	}
	else
	{
		btnPlayRecAudio.filters =null;
	}
}
/**
 * @private
 *
 * To get the recorded audio data to play
 *
 * @param event of SampleDataEvent
 * @return void
 */
private function playRecordedAudio(event:SampleDataEvent): void
{
	if (!recordedData.bytesAvailable > 0)
	{
		return;
	}
	else
	{
		var length:int = 8192;
		for (var i:int = 0; i < length; i++)
		{
			var sample:Number = 0;
			if (recordedData.bytesAvailable > 0)
			{
				sample = recordedData.readFloat();
			}
			event.data.writeFloat(sample);
			event.data.writeFloat(sample);
		}
	}
	
}
/**
 * @private
 *
 * To stop the play back audio
 *
 * @param event of Event
 * @return void
 */
private function stopPlayback(event:Event): void	
{
	btnPlayRecAudio.label="Play Recording";
	isPlayRecordBtnClicked = false;
	btnPlayRecAudio.enabled=false;
	micLevelCanvas.visible = false;
	//Set null to remove glow filter
	btnPlayRecAudio.filters =null;
	btnNext.enabled = true;
	btnPrev.enabled = true;
	this.removeEventListener(Event.ENTER_FRAME,addGlowEffectToMicroPhone);
}
/**
 * @private
 *
 * To create video object and add it into videoDisplay
 *
 * @param event of Event
 * @return void
 */
private function videoDriverChangeHandler(event:Event):void
{
	//To remove elements from group
	videoContainer.removeAllElements();
	var camNames:Object = Camera.names;
	camObj=Camera.getCamera(videoDrivers.selectedIndex.toString());
	if(camObj)
	{
		vidDisplay = new VideoDisplay();
		vidDisplay.width = videoContainer.width;
		vidDisplay.height = videoContainer.height;
		
		//Set video drivers mode and quality
		camObj.setMode(vidDisplay.width*2,vidDisplay.height*2,15); 
		camObj.setQuality(0,100);
		
		//Set video object parameters
		video = new Video();
		video.clear();
		video.width = videoContainer.width;
		video.height = videoContainer.height; 
		video.attachCamera(camObj);
		
		//Add video to videoDisplay
		vidDisplay.addChild(video);
		//Add videoDisplay to group
		videoContainer.addElement(vidDisplay);
		//To create outer border for video
		createVideoBorder();
	} 
}
/**
 * @private
 *
 * To create border for video container
 *
 * @param null
 * @return void
 */
private function createVideoBorder():void
{
	videoContainer.graphics.clear();
	videoContainer.graphics.beginFill(0x000000, 5);
	videoContainer.graphics.lineStyle(2,0xFFFFFF);
	videoContainer.graphics.drawRect(0, 0, videoContainer.width,videoContainer.height);
	videoContainer.graphics.endFill();
	
}
/**
 * @private
 *
 * To play the audio to check speaker
 *
 * @param event of MouseEvent
 * @return void
 */
private function playAudio(event:MouseEvent):void
{
	//if user clicks on stop audio button, stop the audio
	//Otherwise play the audio stream
	if(!isAudioPlayBtnClilcked)
	{
		nsAudioPlaying=new NetStream(ncAudioPlaying);
		nsAudioPlaying.client = new Object();
		nsAudioPlaying.client.onMetaData = function (info:Object):void 
		{
			trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
		}
		nsAudioPlaying.addEventListener(NetStatusEvent.NET_STATUS,precheckingNetStatusHandler);
		nsAudioPlaying.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
		nsAudioPlaying.play(PreTestConstants.AUDIO_TAG);
		var soundTrans:SoundTransform = new SoundTransform(1);
		nsAudioPlaying.soundTransform = soundTrans;
		
		event.target.label = PreTestConstants.STOP_AUDIO;
		isAudioPlayBtnClilcked = true;
		btnNext.enabled = false;
		isSpeakerTestPassed = true;
	}
	else
	{
		stopAudio();
	} 
}
/**
 * @private
 *
 * To add glow effect while palying the netStream 
 *
 * @param event of EnterFrame Event
 * @return void
 */
private function addGlowEffectToSpeakerModule(event:Event):void
{
	if(btnPlayAudio.filters.length == 0)
	{
		glowFltr = new GlowFilter(0x00F5FF,1,25,25);
		btnPlayAudio.filters=[glowFltr];
	}
	else
	{
		btnPlayAudio.filters =null;
	}
}
/**
 * @private
 *
 * To stop the netstream audio
 *
 * @param null
 * @return void
 */
private function stopAudio():void
{
	nsAudioPlaying.close();
	nsAudioPlaying = null;
	btnPlayAudio.filters = null;
	isAudioPlayBtnClilcked =false;
	btnPlayAudio.label = PreTestConstants.PLAY_AUDIO;
	btnNext.enabled = true;
	this.removeEventListener(Event.ENTER_FRAME,addGlowEffectToSpeakerModule);
}
/**
 * @private
 *
 * Intializing netconnection and set camera length
 *
 * @param event of FlexEvent
 * @return void
 */
private function initPreTesting(event:FlexEvent):void
{
	ncAudioPlaying=new NetConnection();
	ncAudioPlaying.client = new Object();
	ncAudioPlaying.addEventListener(NetStatusEvent.NET_STATUS,precheckingNetStatusHandler);
	ncAudioPlaying.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
	ncAudioPlaying.connect(ClassroomContext.protocolFMS+"://"+ClassroomContext.FMS_USER+":"+ ClassroomContext.portFMS+"/"+Constants.PRETESTING_SERVER_MODULE_NAME);
	
	var camNames:Object = Camera.names;
	//if number of video driver is one, set anme it as front camera
	//Otherwise set both front and back camera
	if(camNames.length == 1)
	{
		videoDeveice = new ArrayList([{name:PreTestConstants.FRONT_CAMERA,index:0}]);
	}
	else if(camNames.length == 2)
	{
		videoDeveice = new ArrayList([{name:PreTestConstants.BACK_CAMERA,index:0},{name:PreTestConstants.FRONT_CAMERA,index:1}]);
	}
}
/**
 * @private
 *
 * Netstatus event Handler
 *
 * @param event of NetStatusEvent
 * @return void
 */
private function precheckingNetStatusHandler(event:NetStatusEvent):void
{
	switch(event.info.code)
	{
		//If connection is success, to connect with pretesting moules in FMS only at first time
		case "NetConnection.Connect.Success":
			if(connectionCheck==0)
			{
				connectionCheck++;
				secondNetConnection();		
			}
			else if(connectionCheck==1)
			{
				connectionCheck++;
			}
			break;
		//If netstatus is "NetStream.Play.Start" , add glow effect to play button
		case "NetStream.Play.Start":
			//To add glow effect while palying the audio 
			this.addEventListener(Event.ENTER_FRAME,addGlowEffectToSpeakerModule);
			break;
		//If netstatus is "NetStream.Play.Stop" , to stop the audio
		case "NetStream.Play.Stop":
			stopAudio();
			break;
		
	}
}
/**
 * @private
 *
 * To establish connection with FMS
 *
 * @param null
 * @return void
 */
private function secondNetConnection():void
{
	fmsURL = ClassroomContext.FMS_USER+":"+ ClassroomContext.portFMS;
	
	ncPrechecking=new NetConnection();
	ncPrechecking.client = new Object();
	ncPrechecking.addEventListener(NetStatusEvent.NET_STATUS,precheckingNetStatusHandler);
	ncPrechecking.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
	ncPrechecking.connect(ClassroomContext.protocolFMS+"://"+fmsURL+"/"+Constants.PRETESTING_SERVER_MODULE_NAME+"/"+ClassroomContext.aviewClass.className+"_"+ClassroomContext.aviewClass.classId);
}
/**
 * @private
 *
 * AsyncErrorEvent handler
 *
 * @param event of AsyncErrorEvent
 * @return void
 */
private function asyncError(event:AsyncErrorEvent):void
{
	trace(event.toString());
}
/**
 * @private
 *
 * To change the icon of pretest button based on the result
 *
 * @param event of MouseEvent
 * @return void
 */
private function btnFinishClickHandler(event:MouseEvent):void
{
	if(nsAudioPlaying)
	{
		stopAudio();
	}
	if(isSpeakerTestPassed && micObj && camObj)
	{
		this.dispatchEvent(new PretestIconChangeEvent(PretestIconChangeEvent.PRETEST_PASS));
	}
	else
	{
		this.dispatchEvent(new PretestIconChangeEvent(PretestIconChangeEvent.PRETEST_FAIL));
	}
}
/**
 * @private
 *
 * To check the result
 *
 * @param null
 * @return void
 */
private function goToResult():void
{
	lblSpaekerResult.text = isSpeakerTestPassed?PreTestConstants.SPEAKER_PASS_MSG:PreTestConstants.SPEAKER_FAIL_MSG;
	lblMicroPhoneResult.text = micObj?PreTestConstants.MICROPHONE_PASS_MSG:PreTestConstants.MICROPHONE_FAIL_MSG;
	lblVideoResult.text = camObj?PreTestConstants.VIDEO_PASS_MSG:PreTestConstants.VIDEO_FAIL_MSG;
}