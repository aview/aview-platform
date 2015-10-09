// ActionScript file
import edu.amrita.aview.core.video.LocalVideo;

import mx.core.FlexGlobals;

public var localHandler:LocalVideo;

[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoPublish.jpg")]
public var videoON:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoStop.jpg")]
public var videoOFF:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoMic.jpg")]
public var audioON:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoMicMute.jpg")]
public var audioOFF:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoAudioPublish.jpg")]
public var videoAudioON:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/video/assets/images/localVideoAudioStop.jpg")]
public var videoAudioOFF:Class;


[Bindable]
public var audioStatus:Class = audioON;
[Bindable]
public var videoStatus:Class = videoON;
[Bindable]
public var audioVideoStatus:Class = audioVideoStatus;

[Bindable]
public var audioStatusTooltip:String='Mute Audio';
[Bindable]
public var videoStatusTooltip:String='Hide Video';
[Bindable]
public var audioVideoStatusTooltip:String='Stop Video and Audio';


public function removeFullscreen():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.video.width=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.localVideoDisplay.width;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.video.height=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.localVideoDisplay.height;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.localVideoDisplay.addChild(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.video);
	//close() method not available for web
	applicationType::desktop	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.localVideoFullScreenComp.nativeWindow.close();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.isFullScreen=false;
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.visible=true;
}

private function resizeVideo():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.video.width=localVideoDisplay.width;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.video.height=localVideoDisplay.height;
}

public function hideTheVideo():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.hideTheVideo();
}

public function muteTheAudio():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.muteTheAudio();
}
public function stopLocalAudioVideo():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.stopLocalAudioVideo();
}

