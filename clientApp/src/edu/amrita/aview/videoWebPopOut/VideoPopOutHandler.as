import flash.events.AsyncErrorEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.StatusEvent;
import flash.external.ExternalInterface;
import flash.media.SoundTransform;
import flash.net.LocalConnection;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.SharedObject;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.ResizeEvent;

import spark.components.Button;

//Hold live video rtmp and stream path 
private var videoStreamPath:String;

//Rtmp path for netconnection object
private var rtmpPath:String;

//netStream object
public var ns:NetStream;

//netconnection object
private var nc:NetConnection;

//Flash video to display live video
private var video:flash.media.Video;

//Straem name of selected user
private var streamName:String;

//To store users video stop flag to Local Shared Object 
private var videoFlagSharedObject:SharedObject;

//Current Username
private var currentUserName:String;

//Local connection object
private var childLocalConnection:LocalConnection;

//To hold Selected viewer/Presenter audio status
private var audioStatus:String;

//To hold userType
private var userType:String;

//To hold viewer role
private var isViewer:Boolean;

//To hold user audio status
[Bindable]
private var receiveAudio:String;

//To hold video publish bandwidth
private var videoBandwidth:int;

[Bindable]
private var selectedUserFullName:String;

//To hold audio only mode
[Bindable]
private var audioOnlyMode:Boolean;

[Bindable]
[Embed(source="assets/images/videoshow.png")]
public var videoReceive_Icon:Class;

[Bindable]
[Embed(source="assets/images/videohide.png")]
public var videoNotReceive_Icon:Class;

[Bindable]
[Embed(source="assets/images/videoWall_videoFade.png")]
public var videoFade_Icon:Class;

[Bindable]
public var video_Receive:Class;

//To store users video details to Local Shared Object
private var lsoVideo:SharedObject;

//To hold video type
private var vidType:String;

//To hold video status (Play/Pause)
private var isVideoStopped:Boolean;

//To hold unique id for localConnection method
private var randomId:String;
private var signalTimeOutID:uint;

[Bindable]
[Embed(source="assets/images/videoWall_DisabledMic.png")]
public var videoWall_disabledMicIcon:Class;

[Bindable]
[Embed(source="assets/images/talk.png")]
public var videoWall_pushToTalkUnmute_Icon:Class;

[Bindable]
[Embed(source="assets/images/mute.png")]
public var videoWall_pushToTalkMute_Icon:Class;

[Bindable]
public var pushToTalk_Icon:Class;

//Fix for issue #17571
[Bindable]
[Embed(source="assets/images/video_refresh.png")]
public var video_Refresh_Icon:Class;

private function init():void
{	
	//To send loaded message to parent application
	ExternalInterface.call("sendApplicationLoadedMsg");
	//Expression pattern
	var spclChar:RegExp = /.*\?/;
	//Get the url
	var valueFromUrl:String = this.loaderInfo.url.toString();
	//Replace special charecters from url
	valueFromUrl = valueFromUrl.replace(spclChar, "");
	var parameters:Array = valueFromUrl.split("&");
	// Get the parameters that are in the Array.
	for (var i:int = 0; i < parameters.length; i++) 
	{
		vidType = parameters[0];
		randomId=parameters[1];
		videoStreamPath = parameters[2];
		if(videoStreamPath)
		{
			streamName=videoStreamPath.slice(videoStreamPath.lastIndexOf("/")+1,videoStreamPath.lastIndexOf(","));
		}
		userType = parameters[3];
		receiveAudio = parameters[4];
		selectedUserFullName = parameters[5];
		currentUserName=userType; 
	}
	
	if(vidType == "Presenter")
	{
		receivePresenterVideoDetails();
	}
	if(currentUserName=="VIEW Video")
	{
		//Removed the videoHbox, if the presenter uses View video in pop-out window.
		videoControlGroup.visible=false;
		videoControlGroup.includeInLayout=false;
		connectVideoPath();	
	} 				
	if(vidType == "Viewer")
	{
		receiveViewerVideoDetails();
	}
	this.addEventListener(ResizeEvent.RESIZE, resizeWindow);
}
//To unmute presenter audio
private function enableTalk():void
{
	ns.soundTransform = new SoundTransform(1);
	presenterAudioStatusData("unmute",streamName);
	pushToTalk_Icon = videoWall_pushToTalkUnmute_Icon;
	setupTalkMute(true,btnFreeTalk,btnMute,btnTalk);
}
//To mute presenter audio
public function disableTalk():void
{
	ns.soundTransform = new SoundTransform(0);
	presenterAudioStatusData("mute",streamName);
	pushToTalk_Icon = videoWall_pushToTalkMute_Icon;
	setupTalkMute(false,btnFreeTalk,btnMute,btnTalk);
}

//Function to connect netConnection	
private function connectVideoPath():void
{
	rtmpPath=videoStreamPath.slice(0,videoStreamPath.lastIndexOf("/"));
	nc = new NetConnection();
	nc.client =new Object();
	nc.objectEncoding = flash.net.ObjectEncoding.AMF3;
	nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
	nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
	nc.connect(rtmpPath); 
}
//To connect localConnection method to get Presenter video details from parent
private function receivePresenterVideoDetails():void
{
	try
	{
		//Connect with parent application
		childLocalConnection = new LocalConnection();
		childLocalConnection.client = this;
		childLocalConnection.addEventListener(StatusEvent.STATUS,onStatusChange);
		childLocalConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);
		childLocalConnection.connect("AVIEWPresenterVideoParent");
	}
	catch(error:ArgumentError)
	{
		trace(error.toString());
	}
}
//Status change event listner for LocalConnection
private function onStatusChange(event:StatusEvent):void
{
	switch (event.level) 
	{
		case "status":
			trace("LocalConnection connection success in popout");
			break;
		case "error":
			trace("LocalConnection connection failed in popout");
			break;
	}
}
//To connect localConnection method to get Selected viewer video details from parent
private function receiveViewerVideoDetails():void
{
	//Connect with parent application
	childLocalConnection = new LocalConnection();
	childLocalConnection.client = this;
	childLocalConnection.connect("AVIEWViewerVideoParent_"+randomId);
}
//To recieve Presenter/Selected viewer video details from parent
public function receivedStreamDetailsFromParent(videoPath:String,videoStreamName:String,userFullName:String,isAudioReceived:String,usertype:String,isAudioOnly:Boolean,publishBandwidth:int,currentUserRole:Boolean):void
{
	videoStreamPath = videoPath;
	streamName = videoStreamName;
	selectedUserFullName = userFullName;
	receiveAudio = isAudioReceived;
	userType = usertype;
	audioOnlyMode = isAudioOnly;
	videoBandwidth = publishBandwidth;
	isViewer = currentUserRole;
	if(audioOnlyMode)
	{
		//Close the pop out window.
		closeWindow();
	}
	connectVideoPath();
}
//NetStatus Event
private function onNetStatus(event:NetStatusEvent):void
{
	if (event.info.code == "NetConnection.Connect.Success") 
	{
		startVideo();
		//Fix for issue #18126
		videoControlGroup.visible=true;
		//Bug fix #7968
		if(receiveAudio == "freetalk")
		{
			ns.soundTransform = new SoundTransform(1);
			pushToTalk_Icon = videoWall_disabledMicIcon;
			setupFreeTalk(btnFreeTalk,btnMute,btnTalk);
		}
		else if(receiveAudio == "mute")
		{
			ns.soundTransform = new SoundTransform(0);
			pushToTalk_Icon = videoWall_pushToTalkMute_Icon;
			setupTalkMute(false,btnFreeTalk,btnMute,btnTalk);
		}
		else
		{
			//To unmute the video
			ns.soundTransform = new SoundTransform(1);
			pushToTalk_Icon = videoWall_pushToTalkUnmute_Icon;
			setupTalkMute(true,btnFreeTalk,btnMute,btnTalk);
		}
		ExternalInterface.call("setTitle",selectedUserFullName,userType,streamName);					
		
		lsoVideo = SharedObject.getLocal("lsoStatus"+streamName,"/"); 
		lsoVideo.data.lsoStatus = "streamPlaying";
		lsoVideo.flush(); 
		ExternalInterface.call("videoStreamHandler",streamName,userType);
		signalTimeOutID = setTimeout(getSignalStrength,100);
		//Fix for issue #8542
		if(audioOnlyMode)
		{
			//Close the pop out window.
			closeWindow();
		}
		//Fix for issue #8595,#8579 and #8578
		if(isVideoStopped)
		{
			lblVideoPause.visible = true;
			btnVideo.selected = true;
			stopVideo();
		}
	}
	else if(event.info.code == "NetConnection.Connect.Failed" ||event.info.code == "NetConnection.Connect.Rejected")
	{
		closeWindow();
	}
	else if(event.info.code == "NetStream.Play.UnpublishNotify")
	{
		if(userType == "VIEW Video")
		{
			closeWindow();
		}
		clearVideo();
		getSignalStrength();
	}
	else if(event.info.code == "NetStream.Play.PublishNotify")
	{
		startVideo();
		ExternalInterface.call("setTitle",selectedUserFullName,userType,streamName);
		signalTimeOutID = setTimeout(getSignalStrength,100);
		//Fix for issue #8595,#8579 and #8578
		if(isVideoStopped)
		{
			lblVideoPause.visible = true;
			btnVideo.selected = true;
			stopVideo();
		}
		//Fix for issue #8542
		if(audioOnlyMode)
		{
			//Close the pop out window.
			closeWindow();
		}
	}
	else if(event.info.code == "NetConnection.Connect.Closed")
	{
		clearVideo();
		//Fix for issue #8541
		ExternalInterface.call("setTitle","",userType,streamName);
	}
	else
	{
		
	}
}

//To add video stream to video dispaly
private function startVideo():void
{
	video= new flash.media.Video();
	video.clear();
	ns = new NetStream(nc);
	ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
	ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);
	ns.play(streamName);
	video.smoothing=true;
	video.attachNetStream(ns);
	video.width=vidDisplay.width;
	video.height=vidDisplay.height;
	vidDisplay.addChild(video);
	//To maintain aspect ratio
	vidDisplay.maintainAspectRatio=true;
	video_Receive=videoReceive_Icon;
	btnVideo.enabled = true;
	//Fix for issue #18086
	if(btnVideo.selected){
		stopVideo();
	}
}
//Resizing the window based on the user resize the window. 
private function resizeWindow(event:ResizeEvent):void
{
	video.width=this.width;
	video.height=this.height;
}

//Close the window
private function closeWindow():void
{
	ExternalInterface.call('exitPopOutWindow');
	try
	{
		if(childLocalConnection)
		{
			//To close local connection object, when Selected viewer/Presenter close the window.
			childLocalConnection.close();
		}
	}
	catch(error:ArgumentError)
	{
		trace(error.message.toString());
	}
	setupFreeTalk(btnFreeTalk,btnMute,btnTalk);
}
//Fix for issue #17750
//To send video status to parent window
//receivedAudioStatusFromChild is a function, which is defined in parent application.
public function presenterVideoSatusData(videoStatus:String,userName:String):void
{
	childLocalConnection.send("AVIEWPresenterPopOutChild", "receivedVideoStatusFromChild", videoStatus,userName);
}

//To play and stop the video
private function stopVideo():void
{
	if(btnVideo.selected)
	{
		ns.receiveVideo(false);
		isVideoStopped = true;
		video_Receive=videoNotReceive_Icon;
		btnVideo.toolTip="Start Viewing Video";
		//To enable the video stop notification
		lblVideoPause.visible = true;
		//Fix for issue #17750
		presenterVideoSatusData("stop",streamName);
		//To store video stop flag streamName and current username to Local Shared Object when user stops the video.
		videoFlagSharedObject=SharedObject.getLocal(streamName + "_videoData","/");
		videoFlagSharedObject.data.isVideoStopped="true";
		videoFlagSharedObject.data.streamName = streamName;
		videoFlagSharedObject.data.currentUser = currentUserName;
		videoFlagSharedObject.flush();
	}
	else
	{
		ns.receiveVideo(true);
		isVideoStopped = false;
		video_Receive=videoReceive_Icon;
		btnVideo.toolTip="Stop Viewing Video";
		//To disable the video stop notification
		lblVideoPause.visible = false;
		//Fix for issue #17750
		presenterVideoSatusData("start",streamName);
		//Clear the shared object
		videoFlagSharedObject.clear();
	}
	getSignalStrength();
}
//This method will get called from the main application if there any changes in PTT.
public function receivedAudioStatusFromParent(msg:String):void 
{
	if(userType == "VIEWER")//For Selected Viewer
	{
		audioStatus = msg;
		if(audioStatus == "mute")
		{
			//To mute the video
			ns.soundTransform = new SoundTransform(0);
		}
		else
		{
			//To unmute the video
			ns.soundTransform = new SoundTransform(1);
		}
	}
	else if(userType == "PRESENTER") //For Presenter
	{
		audioStatus = msg;
		if(audioStatus == "freetalk")
		{
			ns.soundTransform = new SoundTransform(1);
			pushToTalk_Icon = videoWall_disabledMicIcon;
			setupFreeTalk(btnFreeTalk,btnMute,btnTalk);
		}	
		else if(audioStatus == "mute")
		{
			//To mute the video
			ns.soundTransform = new SoundTransform(0);
			pushToTalk_Icon = videoWall_pushToTalkMute_Icon;
			setupTalkMute(false,btnFreeTalk,btnMute,btnTalk);
		}
		else
		{
			//To unmute the video
			ns.soundTransform = new SoundTransform(1);
			pushToTalk_Icon = videoWall_pushToTalkUnmute_Icon;
			setupTalkMute(true,btnFreeTalk,btnMute,btnTalk);
		}
	}
}
//To make visible of signal strength component
protected function controlGroupShowHandler(event:MouseEvent):void
{
	signalGroup.visible = true;
	btnVideo.visible = true;
	getSignalStrength();
	if(btnVideo.enabled==false)
	{
		imgNoSignal.visible = true;
	}
	else
	{
		imgNoSignal.visible = false;
	}
}
//To make invisible of signal strength component
protected function controlGroupHideHandler(event:MouseEvent):void
{
	getSignalStrength();
	if(btnVideo.enabled==false)
	{
		imgNoSignal.visible = true;
	}
}
//To get signal strength of user video from netstream
private function getSignalStrength():void
{
	if(signalTimeOutID)
	{
		clearTimeout(signalTimeOutID);
	}
	if(nc!=null && ns!=null)
	{
		var streamBytesPerSecond:int = (Math.round(ns.info.currentBytesPerSecond)*8)/1024;
		showSignalStrength((streamBytesPerSecond/videoBandwidth)*100);
	}
}
//To remove signal strength
public function removeSignalStrength():void
{
	lblSignalLevel1.setStyle("backgroundColor","0xFFFFFF");
	lblSignalLevel2.setStyle("backgroundColor","0xFFFFFF"); 
	lblSignalLevel3.setStyle("backgroundColor","0xFFFFFF"); 
	lblSignalLevel4.setStyle("backgroundColor","0xFFFFFF"); 
	lblSignalLevel5.setStyle("backgroundColor","0xFFFFFF"); 
}
//To show signal level based on the signal value
public function showSignalStrength(signalValue:int):void
{
	removeSignalStrength();
	if(signalValue > 20 && signalValue < 40)
	{
		lblSignalLevel1.setStyle("backgroundColor","0xFF0000");
	}
	else if(signalValue >= 40 && signalValue < 60)
	{
		lblSignalLevel1.setStyle("backgroundColor","0xFF0000");
		lblSignalLevel2.setStyle("backgroundColor","0xFF0000");
	}
	else if(signalValue >= 60 && signalValue < 80)
	{
		lblSignalLevel1.setStyle("backgroundColor","0xF97332");
		lblSignalLevel2.setStyle("backgroundColor","0xF97332");
		lblSignalLevel3.setStyle("backgroundColor","0xF97332");
	}
	else if(signalValue >= 80 && signalValue < 100)
	{
		lblSignalLevel1.setStyle("backgroundColor","0xF97332");
		lblSignalLevel2.setStyle("backgroundColor","0xF97332");
		lblSignalLevel3.setStyle("backgroundColor","0xF97332");
		lblSignalLevel4.setStyle("backgroundColor","0xF97332");
	}
	else if(signalValue >= 100)
	{
		lblSignalLevel1.setStyle("backgroundColor","0x9DF571");
		lblSignalLevel2.setStyle("backgroundColor","0x9DF571");
		lblSignalLevel3.setStyle("backgroundColor","0x9DF571");
		lblSignalLevel4.setStyle("backgroundColor","0x9DF571");
		lblSignalLevel5.setStyle("backgroundColor","0x9DF571");
	}
}
//To clear the video display
private function clearVideo():void
{
	if(vidDisplay.contains(video))
	{
		vidDisplay.removeChild(video);
	}
	vidDisplay.removeChildren();
	video.clear();
	video.attachNetStream(null);
	video_Receive=videoFade_Icon;
	btnVideo.enabled = false;
	//Fix for issue #18126
	videoControlGroup.visible=false;
}

//To send PTT status to parent window
//receivedAudioStatusFromChild is a function, which is defined in parent application.
public function presenterAudioStatusData(pttStatus:String,userName:String):void
{
	childLocalConnection.send("AVIEWPresenterPopOutChild", "receivedAudioStatusFromChild", pttStatus,userName);
}

//To set enable and visible properties of PTT buttons based on the presenter ptt state
public function setupTalkMute(talk:Boolean,btnFreeTalk:Button,btnMute:Button,btnTalk:Button):void
{
	btnFreeTalk.includeInLayout = false;
	btnFreeTalk.visible = false;
	
	btnMute.includeInLayout = !talk;
	btnMute.visible = !talk;
	btnMute.enabled = !talk;
	
	btnTalk.includeInLayout = talk;
	btnTalk.visible = talk;
	btnTalk.enabled = talk;
	
	//For all the other users, the PTT buttons should be same as presenter/moderator's view, except in disabled state
	if(isViewer)
	{
		btnMute.enabled = false;
		btnTalk.enabled = false;
	}
}
//To set enable and visible properties of PTT buttons based on the presenter ptt state
private function setupFreeTalk(btnFreeTalk:Button,btnMute:Button,btnTalk:Button):void
{
	btnFreeTalk.includeInLayout = true;
	btnFreeTalk.visible = true;
	btnFreeTalk.enabled = false;
	
	btnMute.includeInLayout = false;
	btnMute.visible = false;
	btnMute.enabled = false;
	
	btnTalk.includeInLayout = false;
	btnTalk.visible = false;
	btnTalk.enabled = false;
}
//Security error handler
private function securityErrorHandler(event:SecurityErrorEvent):void 
{
	trace("SecurityErrorEvent: " + event);
}
//Async error handler
private function asyncErrorHandler(event:AsyncErrorEvent):void 
{
	trace("AsyncErrorEvent: " + event);
}

//Fix for issue #17571
private function videoRefresh():void
{
	//Fix for issue #18198
	if(vidDisplay.contains(video))
	{
		vidDisplay.removeChild(video);
	}
	vidDisplay.removeChildren();
	video.clear();
	video.attachNetStream(null);
	startVideo();
}