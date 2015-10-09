import edu.amrita.aview.core.video.ButtonContainer;
import edu.amrita.aview.core.video.VideoTileEvent;

import mx.controls.Alert;
import mx.controls.VideoDisplay;
import mx.core.UIComponent;
import mx.core.UITextField;

import spark.components.VideoDisplay;

applicationType::DesktopWeb{
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.Constants;

/**Platform specific imports*/
applicationType::desktop
{
	import edu.amrita.aview.core.video.VideoWallPopOut;
}

import flash.utils.clearTimeout;

import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;
import flash.utils.setTimeout;
import edu.amrita.aview.core.video.VideoStreamDisplay;
import flash.geom.Rectangle;
import flash.display.DisplayObject;
import flash.events.FullScreenEvent;
import flash.display.StageDisplayState;
import flash.system.ApplicationDomain;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import mx.logging.Log;
import mx.logging.ILogger;

[Bindable]
[Embed(source="assets/images/pop-out.png")]
public var popoutIcon:Class;
[Bindable]
[Embed(source="assets/images/pop-in.png")]
public var popinIcon:Class;
[Bindable]
[Embed(source="assets/images/fulll-screen.png")]
public var fullScreenIcon:Class;
[Bindable]
[Embed(source="assets/images/exitFull-Screen.png")]
public var exitFullScreenIcon:Class;

[Bindable]
[Embed(source="assets/images/showarrow.png")]
public var showIcon:Class;
[Bindable]
[Embed(source="assets/images/hidearrow.png")]
public var hideIcon:Class;

//Video item size
public var videoItemWidth:Number=178;
public var videoItemHeight:Number=101;

private const big1VideoItemWidth:Number=258;
private const big1VideoItemHeight:Number=146;

private const big2VideoItemWidth:Number=226;
private const big2VideoItemHeight:Number=128;

private const medium1VideoItemWidth:Number=210;
private const medium1VideoItemHeight:Number=119;

private const medium2VideoItemWidth:Number=194;
private const medium2VideoItemHeight:Number=110;

private const small1VideoItemWidth:Number=178;
private const small1VideoItemHeight:Number=101;

private const small2VideoItemWidth:Number=146;
private const small2VideoItemHeight:Number=83;

public var videoDisplayCount:int=0;

//For outer container re-size
private var appResizeInitiated:Boolean;
private var videoTileSizeChanged:Boolean=false;
private var alreadyInAlignedLayout:Boolean=false;
public var isPopOutClosed:Boolean=false;
private var containerResizeTimeOutID:uint;

public var fullScreen:Boolean=false;
[Bindable]
private var fullScreenStatus:Boolean=false;
private var beforeFullScreenInfo:Object;
private var origvideox:Number=0;
private var origvideoy:Number=0;
private var origvideowidth:Number=0;
private var origvideoheight:Number=0;

[Bindable]
private var orgWidth:int=0;
[Bindable]
private var orgHeight:int=0;
private static var _screenClass:Class;
private static var checkedForScreenClass:Boolean;
public var isPopOut:Boolean=false;
private var isInitialize:Boolean = false;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.video.VideoWallHandler.as");

/**Platform specific variables*/
applicationType::desktop
{
	public var videoWallWindow:VideoWallPopOut;
}

// Interface implementation

private var parentComponent:UIComponent;
private var btnContainer:ButtonContainer;
public function setFullScreenVideo():Boolean
{
		bigScreenDisplay.videowallFullScreenStatus=true;
		//stores the orginal width and height 
		orgHeight=this.height;
		orgWidth=this.width;
		fullScreenStatus=true;
		bigScreenDisplay.resizabletitlewindow1_resizeHandler();

		if (!this.systemManager.getTopLevelRoot())
			return false;
		var screenBounds:Rectangle=getScreenBounds();
		fullScreen=true;
		beforeFullScreenInfo={parent: this.parent, x: this.x, y: this.y, explicitWidth: this.explicitWidth, explicitHeight: this.explicitHeight, percentWidth: this.percentWidth, percentHeight: this.percentHeight, isPopUp: this.isPopUp};
		
		if (!this.isPopUp)
		{
			if (parent is IVisualElementContainer)
			{
				var ivec:IVisualElementContainer=IVisualElementContainer(parent);
				beforeFullScreenInfo.childIndex=ivec.getElementIndex(this);
				ivec.removeElement(this);
			}
			else
			{
				beforeFullScreenInfo.childIndex=parent.getChildIndex(this);
				parent.removeChild(this);
			}
			PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject, false, null, this.moduleFactory);
		}
		this.setLayoutBoundsSize(screenBounds.width, screenBounds.height, true);
		this.explicitWidth=this.width;
		this.explicitHeight=this.height;
		this.setLayoutBoundsPosition(0, 0, true);
		this.validateNow();
		this.systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
		this.systemManager.stage.displayState=StageDisplayState.FULL_SCREEN;
	
	return true;
}
public function closeFullScreenVideo():Boolean
{
	/*applicationType::web
	{
		popOutBtn.visible=false;
		popOutBtn.includeInLayout=false;
		//Changed hbox width to avoid expand/collapse button position issue
		btnControls.width=62;
	}
	applicationType::desktop
	{
		popOutBtn.visible=true;
		popOutBtn.includeInLayout=true;
		btnControls.width=84;
	}*/
	bigScreenDisplay.videowallFullScreenStatus=false;
	this.systemManager.stage.displayState=StageDisplayState.NORMAL;
	return true;
}
//parent can be either regular container or popout container
public function initializeComponent(parent:UIComponent, controlBar:ButtonContainer):void
{
	parentComponent = parent;
	btnContainer = controlBar;
	parentComponent.addChild(this);
	this.addElement(btnContainer);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex=6;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveWindowInSO(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.tabButttonChange();
}
//Fix for issue #17990
applicationType::web{
	public function resizeBaseContainer():void{
		//Fix for issue #20171
		if(parentComponent.width >0 &&  parentComponent.height > 0){
			this.width=parentComponent.width;
			this.height=parentComponent.height;
		}
	}
}
applicationType::desktop
{
	public function initializePopOutComponent(parent:UIComponent, controlBar:ButtonContainer, popOutComponent:VideoWallPopOut):void
	{
		parentComponent = parent;
		btnContainer = controlBar;
		this.addElement(btnContainer);
		popOutComponent.setLayout(this);
		
	}
	//parent can be either regular container or popout container
	public function setPopOutLayout(newParent:VideoWallPopOut):void
	{
		parentComponent.removeChild(this);
		newParent.setLayout(this);
	}
}

public function setParentLayout():void
{
	parentComponent.addChild(this);
}

public function removeVideoDisplay (userName:String):void
{
	var removedTile:VideoStreamDisplay=removeVideoTile(userName);
	var mainDisplay:VideoStreamDisplay=getMainVideoDisplay();
	if (removedTile != null)
	{
		if (mainDisplay != null && removedTile.userName == mainDisplay.userName)
		{
			getMainVideoDisplay().clearDisplay();
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName) && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomExited){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setSelectedVideoInVideoWall(ClassroomContext.userVO.userName, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresenterStreamName());
			}
				//if a viewer selects a video to bigscreen which is not selected by presenter
			else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject.getData()["selectedUser"] != removedTile.userName)
			{
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject.getData()["selectedUser"] != null){
					changeMainVideoInVideoWall(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject.getData()["selectedUser"], FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject.getData()["selectedStreamName"]);
				}
				else
				{
					changeMainVideoInVideoWall(ClassroomContext.currentPresenterName, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresenterStreamName());
				}
				
			}
		}
		removedTile=null;
	}
	
}
public function addPresenterDisplay (presenterDisplay:VideoStreamDisplay):void
{
	if(ClassroomContext.currentPresenterName==ClassroomContext.userVO.userName)
	{
		
		presenterDisplay.resizeFactorTitleWindow=presenterDisplay.RESIZE_FACTOR_SW;	
		presenterDisplay.resizeFactor=presenterDisplay.RESIZE_FACTOR_SW;
		var selectedUser:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject.getData()["selectedUser"];
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection!=null && (selectedUser==null ||FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(selectedUser)==null || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(selectedUser).userStatus==Constants.HOLD))
		{
			presenterDisplay.labelBigScreenNotification.visible=true;
			presenterDisplay.LabelHideAudioVideo.visible=false;
			//setSelectedVideoInVideoWall(ClassroomContext.userVO.userName, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresenterStreamName());
		}
		presenterDisplay.width=videoItemWidth;
		presenterDisplay.height=videoItemHeight;
		presenterDisplay.setFullScreenToolTip();
		presenterDisplay.addEventListener(MouseEvent.CLICK,onClickVideoTile);
		
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changePTTButtonStatus(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher,ClassroomContext.currentPresenterName);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.startPresentersStream();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoConnection = getPresenterVideoStreamDisplay().videoConnection;
	
	}
	else
	{
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.isFullScreenPresent && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selUser != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.id)
		{
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.visible == true){
				var vidDisplay:VideoStreamDisplay=null;
				vidDisplay=getMainVideoDisplay();
				vidDisplay.LabelHideAudioVideo.text = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.text;
				vidDisplay.LabelHideAudioVideo.visible = true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.text = "";
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.visible = false;
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.isVideoReset = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.closeFullScreen();	
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.isFullScreenPresent = false;	
		}
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.id = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresenterStreamName();
	addVideoTile(presenterDisplay,1);
	
}
public function addViewerDisplay (viewerStreamDisplay:VideoStreamDisplay):void
{
	addVideoTile(viewerStreamDisplay);
	viewerStreamDisplay.addEventListener(MouseEvent.CLICK,onClickVideoTile);
	viewerStreamDisplay.width=videoItemWidth;
	viewerStreamDisplay.setFullScreenToolTip();
	
}
public function closeLayout(bool:Boolean):void
{
	if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		return;
	removePresenterDisplay();
	for (var i:int=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerDisplays.length; i++)
	{
		removeViewerDisplay(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerDisplays[i]);
	}
	this.removeElement(btnContainer);
	if(fullScreen)
		closeFullScreenVideo();
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE && !bool)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setSelectedVideoInVideoWall(null, null);
}

public function getPresenterVideoStreamDisplay():VideoStreamDisplay
{
	var presenterDisplay:VideoStreamDisplay=null;
	if (getMainVideoDisplay()){
		var mainTile:VideoStreamDisplay=getMainVideoDisplay();
		//if main tile has presenter video or main tile doesn't have video or the user selected to main tile is not an accepted viewer
		//then presenter video should be displayed on main tile.
		if (mainTile.userName == ClassroomContext.currentPresenterName || mainTile.userName == null || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(mainTile.userName) == null || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(mainTile.userName) != null && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(mainTile.userName).userStatus == Constants.HOLD)){
			if (mainTile.userName == null){
				//mainTile.getUserSOStatus=getUserSO;
			}
			presenterDisplay=mainTile;
		}
		else{
			presenterDisplay=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher;
		}
	}
	else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher){
		presenterDisplay=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher;
	}
	return presenterDisplay;
}
public function getViewerVideoStreamDisplay(viewerDisplay:VideoStreamDisplay):VideoStreamDisplay
{
	var mainVideoTile:VideoStreamDisplay=getMainVideoDisplay();
	if (mainVideoTile != null && mainVideoTile.userName == viewerDisplay.userName)
	{
		viewerDisplay.iconSet(viewerDisplay.videoReceive_Icon);
		viewerDisplay=mainVideoTile;
	}
	else
		viewerDisplay.width=videoItemWidth;
	return viewerDisplay;
}

public function resizeVideoStreamDisplay():void
{
	calculateVideoItemSize();
}

public function onClickVideoTile(event:MouseEvent):void{
	if (event.target is mx.controls.VideoDisplay || (event.target is UITextField && (event.target.text == "A-VIEW" || event.target.text == "?") && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO((event.currentTarget as VideoStreamDisplay).userName).isVideoPublishing))
	{
		var selectedDisplay:VideoStreamDisplay=event.currentTarget as VideoStreamDisplay;
		if(selectedDisplay.isAudOnly == true){
			return;
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setSelectedVideoInVideoWall(selectedDisplay.userName, selectedDisplay.id);
			//if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"] != 6){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveWindowInSO(6);
		}
		
	}
}

public function removePresenterDisplay():void
{
	var vidDisplay:VideoStreamDisplay=null;
	vidDisplay=getMainVideoDisplay();
	if (vidDisplay != null && vidDisplay.userName == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.userName)
	{
		//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.text == "";
		var pn1Teacher:String = vidDisplay.LabelHideAudioVideo.text;
		if(vidDisplay.LabelHideAudioVideo.visible == true){
			vidDisplay.LabelHideAudioVideo.visible = false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.text = pn1Teacher;
			pn1Teacher = "";
			vidDisplay.LabelHideAudioVideo.text = "";
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.LabelHideAudioVideo.visible = true;
		}
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelBigScreenNotification.visible=false;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			if (vidDisplay.isFullScreenPresent){
				vidDisplay.isVideoReset=false;
				applicationType::desktop{
					vidDisplay.videoFullScreenComp.removeEventListener(Event.CLOSE, vidDisplay.fullscreenClose);
				}
				vidDisplay.closeFullScreen();
			}
		}
		else{
			if (vidDisplay.isFullScreenPresent){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher, vidDisplay);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.userName=ClassroomContext.currentPresenterName;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.id = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresenterStreamName();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoConnection = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresentersVideoConnection(ClassroomContext.subscriber_bandwidthQualityIndex);
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.video_Receive=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoReceive_Icon;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.btn_studentVideoreceive.setStyle('icon', FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoReceive_Icon);
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.isVideoPaused=false;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.attachVideo(vidDisplay.removeVideo(), vidDisplay.videoConnection, vidDisplay.id, vidDisplay.isVideoPaused);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changePTTButtonStatus(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher, ClassroomContext.currentPresenterName);
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.addEventListener(MouseEvent.ROLL_OVER, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox_mouseOverHandler);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.addEventListener(MouseEvent.ROLL_OUT, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.vidDispObj_mouseOutHandler);
		}
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.width=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.spacerBelowPresenterVideo.width;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.height=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.width * .5625 + 5;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.setFullScreenToolTip();
		vidDisplay.userName = null;
		
	}
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.hasEventListener(MouseEvent.CLICK))
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.removeEventListener(MouseEvent.CLICK,onClickVideoTile);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.vidDispObj.doubleClickEnabled = true;
	removeVideoTile(null,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher);
}

public function removeViewerDisplay(videoDisplay:VideoStreamDisplay):void
{
	var vidDisplay:VideoStreamDisplay=null;
	vidDisplay=getMainVideoDisplay();
	if (vidDisplay != null && vidDisplay.userName == videoDisplay.userName){
		videoDisplay.labelBigScreenNotification.visible=false;
		//videoDisplay.LabelHideAudioVideo.text == "";
		var videoplay:String = vidDisplay.LabelHideAudioVideo.text;
		if(vidDisplay.LabelHideAudioVideo.visible == true){
			vidDisplay.LabelHideAudioVideo.visible = false;
			videoDisplay.LabelHideAudioVideo.text = videoplay;
			videoplay = "";
			vidDisplay.LabelHideAudioVideo.text = "";
			videoDisplay.LabelHideAudioVideo.visible = true;
		}
		
		applicationType::desktop{
			if (!vidDisplay.isFullScreenPresent)
			{
				videoDisplay.attachVideo(vidDisplay.removeVideo(), vidDisplay.videoConnection, vidDisplay.id, vidDisplay.isVideoPaused);
				vidDisplay.isVideoPaused = false;
			}
			else{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(videoDisplay, vidDisplay);
			}
		}
		applicationType::web{
			//Fix for issues #13707 and #19924;
			if(!vidDisplay.isFullScreenPresent || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen == false){
				videoDisplay.attachVideo(vidDisplay.removeVideo(),vidDisplay.videoConnection,vidDisplay.id, vidDisplay.isVideoPaused);
				//Fix for issue #19924
				vidDisplay.isVideoPaused = false;
			}
			else{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(videoDisplay, vidDisplay);
			}
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(videoDisplay.userName).isVideoPublishing && !videoDisplay.isVideoPaused && !videoDisplay.isFullScreenPresent){
			videoDisplay.videoBox.addEventListener(MouseEvent.ROLL_OVER, videoDisplay.videoBox_mouseOverHandler);
			videoDisplay.videoBox.addEventListener(MouseEvent.ROLL_OUT, videoDisplay.vidDispObj_mouseOutHandler);
		}
		if (videoDisplay.isVideoPaused && !vidDisplay.labelVideoToggleNotification.visible){
			videoDisplay.video_Receive=videoDisplay.videoNotReceive_Icon;
			videoDisplay.startStopVideo();
		}
		vidDisplay.userName = null;
		vidDisplay.id = null;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changePTTButtonStatus(videoDisplay, videoDisplay.userName);
	}
	if(videoDisplay.hasEventListener(MouseEvent.CLICK))
		videoDisplay.removeEventListener(MouseEvent.CLICK,onClickVideoTile);
	videoDisplay.vidDispObj.doubleClickEnabled = true;
	removeVideoTile(null,videoDisplay);
}

public function onVideoAdded(event:VideoTileEvent):void
{
	var videoTile:VideoStreamDisplay=(event.target as VideoStreamDisplay);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMainVideoDisplayParams(getMainDisplay(), videoTile.title, videoTile.userName, videoTile.id, videoTile.removeVideo(), videoTile.videoConnection, videoTile.isVideoPaused);
	videoTile.removeEventListener(VideoTileEvent.VIDEOADDED, onVideoAdded);
	
}
public function changeMainVideoInVideoWall(newUserName:String, streamName:String):void{
	var vidDisplay:VideoStreamDisplay=null;
	vidDisplay=getMainVideoDisplay();
	/*if (userTimeOut)
		clearTimeout(userTimeOut);*/
	//if videowall is not present or the selected user is already present in the main tile return from the function
	if (getMainVideoDisplay() != null && getMainVideoDisplay().userName == newUserName)
	{
		if(newUserName == ClassroomContext.currentPresenterName && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).isVideoPublishing == false)
		{
			getMainVideoDisplay().title="Presenter";
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelAudioOnlyNotification.visible=false;
			if (getMainVideoDisplay().isFullScreenPresent)
			{
				getMainVideoDisplay().labelFullScreen.visible=true;
				//title property is not available for web
				applicationType::desktop
				{
					getMainVideoDisplay().videoFullScreenComp.title="Presenter (A-VIEW Classroom)";
				}
			}
		}
		else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).isVideoPublishing == true){
			vidDisplay.LabelHideAudioVideo.text = "";
			vidDisplay.LabelHideAudioVideo.visible = false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.showViewVideo(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).isAudioOnlyMode,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).isVideoHide,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).isAudioMute,vidDisplay);
			applicationType::desktop{
				if(vidDisplay.videoFullScreenComp!=null){
					vidDisplay.videoFullScreenComp.LabelHideAudioVideo.text = vidDisplay.LabelHideAudioVideo.text;
					vidDisplay.videoFullScreenComp.LabelHideAudioVideo.visible = true;
				}
			}
		}
		return;
	}
	else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName) == null){
		if (newUserName == ""){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelBigScreenNotification.visible=true;
		}
		/*clearTimeout(userTimeOut);
		userTimeOut=setTimeout(changeMainVideoInVideoWall, 200, newUserName, streamName);*/
		return;
	}
		
	var oldSelectedUser:String=null;
	//get Bigscreen and get the last selected userName
	var videoDisplay:VideoStreamDisplay=getMainVideoDisplay();
	//objVideoWall.getMainVideoDisplay().btnClose.visible=false;
	getMainVideoDisplay().isVideoReset=true;
	oldSelectedUser=videoDisplay.userName;
	
	//get current selected video Display
	var selectedDisplay:VideoStreamDisplay=null;
	selectedDisplay=getSelectedVideoDisplay(newUserName, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher);
	if (selectedDisplay == null && oldSelectedUser != null && oldSelectedUser == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.userName){
		copyMainVideoToTile(oldSelectedUser, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher);
	}
	for (var index:int=0; index < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerDisplays.length; index++){
		var currentDisplay:VideoStreamDisplay=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedViewerDisplays[index] as VideoStreamDisplay;
		if (selectedDisplay == null)
			selectedDisplay=getSelectedVideoDisplay(newUserName, currentDisplay);
		if (oldSelectedUser != null && oldSelectedUser == currentDisplay.userName)
			copyMainVideoToTile(oldSelectedUser, currentDisplay);
	}
	if (oldSelectedUser == null && currentDisplay && currentDisplay.name == "pnlTeacher" && newUserName != ClassroomContext.currentPresenterName){
		currentDisplay.labelBigScreenNotification.visible=false;
	}
	/*if(videoDisplay.userName!=newUserName){
	videoDisplay.isVideoReset = false;
	videoDisplay.closeFullScreen();
	}*/
	var mainVideoDisplay:VideoStreamDisplay=getMainVideoDisplay();
	mainVideoDisplay.setBigScreen();
	mainVideoDisplay.resetLabels();
	mainVideoDisplay.btn_studentVideoreceive.setStyle('icon', mainVideoDisplay.videoReceive_Icon);
	if (selectedDisplay != null){
		var video:Video=selectedDisplay.removeVideo();
		if (ClassroomContext.isModerator){
			if (selectedDisplay.btnRecordIndicator.visible){
				mainVideoDisplay.btnRecordIndicator.visible=true;
				mainVideoDisplay.btnRecordIndicator.includeInLayout=true;
				applicationType::desktop{
					if (mainVideoDisplay.isFullScreenPresent && mainVideoDisplay.videoFullScreenComp){
						mainVideoDisplay.videoFullScreenComp.btnRecordIndicator.visible=true;
						mainVideoDisplay.videoFullScreenComp.btnRecordIndicator.includeInLayout=true;
					}
				}
			}
			else{
				mainVideoDisplay.btnRecordIndicator.visible=false;
				mainVideoDisplay.btnRecordIndicator.includeInLayout=false;
				applicationType::desktop{
					if (mainVideoDisplay.isFullScreenPresent && mainVideoDisplay.videoFullScreenComp){
						mainVideoDisplay.videoFullScreenComp.btnRecordIndicator.visible=false;
						mainVideoDisplay.videoFullScreenComp.btnRecordIndicator.includeInLayout=false;
					}
				}
			}
		}
		if (video == null){
			if(!selectedDisplay.isFullScreenVideo && isInitialize)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMainVideoDisplayParams(mainVideoDisplay, selectedDisplay.title, newUserName, streamName, selectedDisplay.video, selectedDisplay.videoConnection, selectedDisplay.isVideoPaused);
				selectedDisplay.labelVideoToggleNotification.visible=false;
				//Fix for issue #17969
				applicationType::web{
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){				
						mainVideoDisplay.labelFullScreen.visible= true;
					}
				}
			}
			else
			{
			var displayName:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).userDisplayName;
			selectedDisplay.setProperties(selectedDisplay.title, newUserName, false, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).videoHeight, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).videoWidth);
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).isVideoPublishing == true){
				selectedDisplay.isVideoNotCopiedToMainTile=true;
				applicationType::desktop{
					if (selectedDisplay.isFullScreenPresent){
						selectedDisplay.labelFullScreen.visible=false;
						selectedDisplay.labelVideoToggleNotification.visible=false;
						mainVideoDisplay.isVideoReset=true;
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMainVideoDisplayParams(mainVideoDisplay, selectedDisplay.title, newUserName, streamName, video, selectedDisplay.videoConnection, selectedDisplay.isVideoPaused);
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(mainVideoDisplay, selectedDisplay);
						selectedDisplay.isVideoPaused=false;
					}
					else{
						selectedDisplay.addEventListener(VideoTileEvent.VIDEOADDED, onVideoAdded);
					
					}
				}
				applicationType::web{
					//To check whether presenter video in fullscreen
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).userRole == Constants.PRESENTER_ROLE && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
						selectedDisplay.labelFullScreen.visible = false;
						selectedDisplay.labelVideoToggleNotification.visible = false;
						mainVideoDisplay.isVideoReset = true;
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMainVideoDisplayParams(mainVideoDisplay,selectedDisplay.title,newUserName,streamName,video,selectedDisplay.videoConnection,selectedDisplay.isVideoPaused);
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(mainVideoDisplay, selectedDisplay);
						selectedDisplay.isVideoPaused = false;
					}
					else{
						selectedDisplay.addEventListener(VideoTileEvent.VIDEOADDED,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.onVideoAdded);
					}
				}
				
			}
			else{
				if (selectedDisplay.isFullScreenPresent){
					selectedDisplay.labelFullScreen.visible=false;
					selectedDisplay.labelVideoToggleNotification.visible=false;
					mainVideoDisplay.isVideoReset=true;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(mainVideoDisplay, selectedDisplay);
				}
				mainVideoDisplay.setProperties(selectedDisplay.title, newUserName, false, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).videoHeight, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(newUserName).videoWidth);
				mainVideoDisplay.isCopyVideo=false;
				mainVideoDisplay.videoConnection=selectedDisplay.videoConnection;
				mainVideoDisplay.id=selectedDisplay.id;
				mainVideoDisplay.getUserSOStatus=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO;
				if (mainVideoDisplay.isFullScreenPresent){
					mainVideoDisplay.labelFullScreen.visible=true;
					//title property is not available for web
					applicationType::desktop{
						mainVideoDisplay.videoFullScreenComp.title=selectedDisplay.title + " (A-VIEW Classroom)";
					}
				}
			}
			}
		}
		else{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMainVideoDisplayParams(mainVideoDisplay, selectedDisplay.title, newUserName, streamName, video, selectedDisplay.videoConnection, selectedDisplay.isVideoPaused);
			//selectedDisplay.labelVideoToggleNotification.visible=false;
			//mainVideoDisplay.LabelHideAudioVideo.text = "";
			var mainDisplay:String = selectedDisplay.LabelHideAudioVideo.text;
			if(selectedDisplay.LabelHideAudioVideo.visible == true){
				selectedDisplay.LabelHideAudioVideo.visible = false;
				mainVideoDisplay.LabelHideAudioVideo.text = selectedDisplay.LabelHideAudioVideo.text;
				mainDisplay = "";
				selectedDisplay.LabelHideAudioVideo.text = "";
				mainVideoDisplay.LabelHideAudioVideo.visible = true;
			}
			
			if (mainVideoDisplay != null && selectedDisplay != null && selectedDisplay.isFullScreenPresent){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(mainVideoDisplay, selectedDisplay);
				selectedDisplay.labelFullScreen.visible=false;
			}
		}
	}
	else{
		mainVideoDisplay.videoBox.doubleClickEnabled=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.resetAudioActivity();
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.hasEventListener(MouseEvent.ROLL_OVER)){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.removeEventListener(MouseEvent.ROLL_OVER, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox_mouseOverHandler);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.removeEventListener(MouseEvent.ROLL_OUT, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.vidDispObj_mouseOutHandler);
			
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher && newUserName == ClassroomContext.currentPresenterName){
			mainVideoDisplay.title="Presenter";
			mainVideoDisplay.userName=newUserName;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.userName=newUserName;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelBigScreenNotification.visible=true;
		}
		if (mainVideoDisplay.isFullScreenPresent){
			mainVideoDisplay.labelFullScreen.visible=true;
			//title property is not available for web
			applicationType::desktop{
				mainVideoDisplay.videoFullScreenComp.title="Presenter (A-VIEW Classroom)";
			}
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.isFullScreenPresent && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.userName == ClassroomContext.currentPresenterName){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelFullScreen.visible=false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelVideoToggleNotification.visible=false;
			mainVideoDisplay.isVideoReset=true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.maintainFullScreenVideo(mainVideoDisplay, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher);
		}
	}
	//}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.bigScreenStreamName = getMainVideoDisplay().id;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.bigScreenName = getMainVideoDisplay().userName;
}

public function getSelectedVideoDisplay(newUserName:String, currentDisplay:VideoStreamDisplay):VideoStreamDisplay{
	var selectedDisplay:VideoStreamDisplay=null;
	if (currentDisplay.userName == newUserName){
		//remove the video controlbuttons and event lis teners from the selected video panel 
		selectedDisplay=currentDisplay;
		currentDisplay.labelBigScreenNotification.visible=true;
		currentDisplay.labelAudioOnlyNotification.visible=false;
		//Fix for issue #19903
		applicationType::web{
			currentDisplay.labelFullScreen.visible=false;
		}
		currentDisplay.videoBox.toolTip="";
		currentDisplay.videoBox.removeEventListener(MouseEvent.ROLL_OVER, currentDisplay.videoBox_mouseOverHandler);
		currentDisplay.videoBox.removeEventListener(MouseEvent.ROLL_OUT, currentDisplay.vidDispObj_mouseOutHandler);
		currentDisplay.hboxControlButtons.visible=false;
		currentDisplay.menuBtn.visible=false;
		currentDisplay.hboxControlButtonsForSmallWindow.visible=false;
		currentDisplay.video_Receive=currentDisplay.videoReceive_Icon;
		currentDisplay.btn_studentVideoreceive.setStyle('icon', currentDisplay.videoReceive_Icon);
		currentDisplay.resetAudioActivity();
		currentDisplay.showhideCloseButton(false);
	}
	
	return selectedDisplay;
	
}

public function copyMainVideoToTile(oldSelectedUser:String, currentDisplay:VideoStreamDisplay):void{
	
	if (currentDisplay.videoConnection == null){
		//PNCR: check both if condition in a single line with AND
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(currentDisplay.userName) != null){
			if (Constants.PRESENTER_ROLE == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(currentDisplay.userName).userRole){
				currentDisplay.videoConnection=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getPresentersVideoConnection(ClassroomContext.subscriber_bandwidthQualityIndex);
			}
			else{
				currentDisplay.videoConnection=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getViewersVideoConnection();
			}
		}
	}
	var videoDisplay:VideoStreamDisplay=getMainVideoDisplay()
	//remove existing video from bigscreen and add it to the corresponding video panel.
	currentDisplay.attachVideo(videoDisplay.video, currentDisplay.videoConnection, currentDisplay.id, videoDisplay.isVideoPaused);
	currentDisplay.labelBigScreenNotification.visible=false;
	currentDisplay.showhideCloseButton(false);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changePTTButtonStatus(currentDisplay, currentDisplay.userName);
	currentDisplay.LabelHideAudioVideo.text = "";
	if(videoDisplay.LabelHideAudioVideo.visible == true){
		videoDisplay.LabelHideAudioVideo.visible = false;
		currentDisplay.LabelHideAudioVideo.text = videoDisplay.LabelHideAudioVideo.text;
		videoDisplay.LabelHideAudioVideo.text = "";
		currentDisplay.LabelHideAudioVideo.visible = true;
	}

	applicationType::web{
		//To remove fullscreen label from bigscreen and add fullscreen label to small presenter screen, if presenter video is in popout and Moderator switches selected viewer video to bigscreen
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(currentDisplay.userName)!=null){
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(currentDisplay.userName).userRole == Constants.PRESENTER_ROLE && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
				if(currentDisplay.name == "pnlTeacher"){
					currentDisplay.labelFullScreen.visible = true;
					currentDisplay.isFullScreenPresent = true;
					currentDisplay.videoBox.removeEventListener(MouseEvent.ROLL_OVER,currentDisplay.videoBox_mouseOverHandler);
					currentDisplay.videoBox.removeEventListener(MouseEvent.ROLL_OUT, currentDisplay.vidDispObj_mouseOutHandler);
				}
				else{
					currentDisplay.labelFullScreen.visible = false;
					currentDisplay.isFullScreenPresent = false;
				}
			}
			else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(currentDisplay.userName).userRole == Constants.VIEWER_ROLE && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPresenterVideoInFullscreen){
				if(currentDisplay.name == "pnlTeacher"){
					currentDisplay.labelBigScreenNotification.visible = true;
					currentDisplay.videoBox.removeEventListener(MouseEvent.ROLL_OVER,currentDisplay.videoBox_mouseOverHandler);
					currentDisplay.videoBox.removeEventListener(MouseEvent.ROLL_OUT, currentDisplay.vidDispObj_mouseOutHandler);
				}
			}
		}
	}
}

public function removeOldPresenterFromBigScreenInVideoWall(oldPresenter:String, newPresenter:String):void{
	var vidDisplay:VideoStreamDisplay=getMainVideoDisplay();
	if (vidDisplay != null && vidDisplay.userName == oldPresenter){
		vidDisplay.clearDisplay();
	}
	if (getMainVideoDisplay().userName == newPresenter) {
		clearPresenterVideoPanelinVideoWall(newPresenter);
	}
}	

private function clearPresenterVideoPanelinVideoWall(selectedUser:String):void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.removeVideo();
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.labelBigScreenNotification.visible=true;
	//classroomComponentSgl.pnlTeacher.btnClose.visible=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.removeEventListener(MouseEvent.ROLL_OVER, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox_mouseOverHandler);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.videoBox.removeEventListener(MouseEvent.ROLL_OUT, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.vidDispObj_mouseOutHandler);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.hboxControlButtons.visible=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.menuBtn.visible=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pnlTeacher.hboxControlButtonsForSmallWindow.visible=false;
}

public function getMainDisplay():VideoStreamDisplay
{
	return getMainVideoDisplay()
}
/////////////////////////////

private function initializeBigscreenData():void
{
	isInitialize = true;
}
protected function init():void
{
	containerResizeTimeOutID=setTimeout(calculateVideoItemSize, 100);
	this.addEventListener(ResizeEvent.RESIZE, app_resizeHandler);
	bigScreenDisplay.setBigScreen();
	setTimeout(initializeBigscreenData, 3000);
	applicationType::web{
		btnControls.width = 62;
		colapse.widthFrom = 62;
		expand.widthTo = 62;
	}
}
//////////////////////////////////////Resize methods //////////////////////////////	

protected function app_resizeHandler(event:ResizeEvent):void
{
	if (!appResizeInitiated)
	{
		appResizeInitiated=true;
		//This is to optimize resizing logic when user uses drag to resize window
		containerResizeTimeOutID=setTimeout(calculateVideoItemSize, 100);
	}
}

public function calculateVideoItemSize():void
{
	if (containerResizeTimeOutID)
	{
		clearTimeout(containerResizeTimeOutID);
	}
	//To avoid executing of below logic if size of the outer container is not properly set, especially during initialization.
	if (this.height <= 200)
	{
		appResizeInitiated=false; //To resize if app is restored from minimized state
		return;
	}
	var smallVideoTileCount:int=baseContainer.numElements - 1; //We don't need to consider big video
	var alignedLayout:Boolean;
	
	//In dual monitor XP machines, while using small monitor, the size of fullscreen app was set as the size of big monitor.
	//So added the below 3 lines of code.
	if (this.stage != null && this.stage.displayState == StageDisplayState.FULL_SCREEN)
	{
		this.width=this.stage.stageWidth;
		this.height=this.stage.stageHeight;
	}
	
	if ((this.width / this.height) >= 1.45) //Widescreen
	{
		if (big1VideoItemHeight * 4 <= this.height)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, 0);
		}
		else if (big2VideoItemHeight * 4 <= this.height)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, big1VideoItemWidth);
		}
		else if (medium1VideoItemHeight * 4 <= this.height)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, big2VideoItemWidth);
		}
		else if (medium2VideoItemHeight * 4 <= this.height)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, medium1VideoItemWidth);
		}
		else
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, medium2VideoItemWidth);
		}
		if ((smallVideoTileCount == Math.floor(this.height / videoItemHeight + 1)) && (videoItemWidth != small2VideoItemWidth))
		{
			while ((smallVideoTileCount > Math.floor(this.height / videoItemHeight)) && (videoItemWidth != small2VideoItemWidth))
			{
				chooseNextBiggerVideoItemSize(smallVideoTileCount, videoItemWidth);
			}
		}
		if (smallVideoTileCount > Math.floor(this.height / videoItemHeight)) //maxVerticalLimit
		{
			alignedLayout=true;
		}
	}
	else //Square screen
	{
		if (big1VideoItemWidth * 4 <= this.width)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, 0);
		}
		else if (big2VideoItemWidth * 4 <= this.width)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, big1VideoItemWidth);
		}
		else if (medium1VideoItemWidth * 4 <= this.width)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, big2VideoItemWidth);
		}
		else if (medium2VideoItemWidth * 4 <= this.width)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, medium1VideoItemWidth);
		}
		else if (small1VideoItemWidth * 4 <= this.width)
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, medium2VideoItemWidth);
		}
		else
		{
			chooseNextBiggerVideoItemSize(smallVideoTileCount, small1VideoItemWidth);
		}
		if ((smallVideoTileCount == Math.floor(this.width / videoItemWidth + 1)) && (videoItemWidth != small2VideoItemWidth))
		{
			while ((smallVideoTileCount > Math.floor(this.width / videoItemWidth)) && (videoItemWidth != small2VideoItemWidth))
			{
				chooseNextBiggerVideoItemSize(smallVideoTileCount, videoItemWidth);
			}
		}
		if (smallVideoTileCount > Math.floor(this.width / videoItemWidth)) //maxHorizontalLimit
		{
			alignedLayout=true;
		}
	}
	if (alignedLayout)
	{
		setBaseContainerSize();
	}
	else
	{
		baseContainer.width=this.width;
		baseContainer.height=this.height;
		alreadyInAlignedLayout=false;
		rePositionElements();
		appResizeInitiated=false;
	}
}

private function chooseNextBiggerVideoItemSize(smallVideoTileCount:int, currentWidth:Number):void
{
	switch (currentWidth)
	{
		//Initial case, checking for biggest size
		case 0:
		{
			if (smallVideoTileCount <= Math.floor(this.width / big1VideoItemWidth) + Math.floor(this.height / big1VideoItemHeight) - 1)
			{
				setVideoItemSize(big1VideoItemWidth, big1VideoItemHeight);
			}
			else
			{
				chooseNextBiggerVideoItemSize(smallVideoTileCount, big1VideoItemWidth);
			}
			break;
		}
		case big1VideoItemWidth:
		{
			if (smallVideoTileCount <= Math.floor(this.width / big2VideoItemWidth) + Math.floor(this.height / big2VideoItemHeight) - 1)
			{
				setVideoItemSize(big2VideoItemWidth, big2VideoItemHeight);
			}
			else
			{
				chooseNextBiggerVideoItemSize(smallVideoTileCount, big2VideoItemWidth);
			}
			break;
		}
		case big2VideoItemWidth:
		{
			if (smallVideoTileCount <= Math.floor(this.width / medium1VideoItemWidth) + Math.floor(this.height / medium1VideoItemHeight) - 1)
			{
				setVideoItemSize(medium1VideoItemWidth, medium1VideoItemHeight);
			}
			else
			{
				chooseNextBiggerVideoItemSize(smallVideoTileCount, medium1VideoItemWidth);
			}
			break;
		}
		case medium1VideoItemWidth:
		{
			if (smallVideoTileCount <= Math.floor(this.width / medium2VideoItemWidth) + Math.floor(this.height / medium2VideoItemHeight) - 1)
			{
				setVideoItemSize(medium2VideoItemWidth, medium2VideoItemHeight);
			}
			else
			{
				chooseNextBiggerVideoItemSize(smallVideoTileCount, medium2VideoItemWidth);
			}
			break;
		}
		case medium2VideoItemWidth:
		{
			if (smallVideoTileCount <= Math.floor(this.width / small1VideoItemWidth) + Math.floor(this.height / small1VideoItemHeight) - 1)
			{
				setVideoItemSize(small1VideoItemWidth, small1VideoItemHeight);
			}
			else
			{
				//Max small size
				setVideoItemSize(small2VideoItemWidth, small2VideoItemHeight);
			}
			break;
		}
		default:
		{
			//Max small size
			setVideoItemSize(small2VideoItemWidth, small2VideoItemHeight);
			break;
		}
	}
}

private function setVideoItemSize(width:Number, height:Number):void
{
	if (videoItemWidth != width)
	{
		videoItemWidth=width;
		videoItemHeight=height;
		videoTileSizeChanged=true;
	}
	else
	{
		videoTileSizeChanged=false;
	}
}

protected function setBaseContainerSize():void
{
	var prevWidth:Number=baseContainer.width;
	var prevHeight:Number=baseContainer.height;
	
	var widthSet:Boolean;
	var heightSet:Boolean;
	
	for (var i:int=0; (i * videoItemWidth < this.width) || (i * videoItemHeight < this.height); i++)
	{
		if (this.width < (i * videoItemWidth))
		{
			widthSet=true;
		}
		else
		{
			prevWidth=i * videoItemWidth;
		}
		if (this.height < (i * videoItemHeight))
		{
			heightSet=true;
		}
		else
		{
			prevHeight=i * videoItemHeight;
		}
		
		if (widthSet && heightSet)
		{
			break;
		}
	}
	
	baseContainer.width=prevWidth;
	baseContainer.height=prevHeight;
	
	rePositionElements();
	appResizeInitiated=false;
	alreadyInAlignedLayout=true;
}

private function rePositionElements():void
{
	var videoDisplayCount:int=baseContainer.numElements;
	var maxHorizontalLimit:int=baseContainer.width / videoItemWidth;
	var maxVerticalLimit:int=baseContainer.height / videoItemHeight;
	var index:int;
	
	// Wide screen
	if ((baseContainer.width / baseContainer.height) >= 1.45)
	{
		if (videoDisplayCount - 1 <= maxVerticalLimit)
		{
			resizeBigElement(baseContainer.width - videoItemWidth, baseContainer.height);
			for (index=1; index < videoDisplayCount; index++)
			{
				rePositionElement(baseContainer.getElementAt(index), baseContainer.getElementAt(0).width, ((baseContainer.height - (videoItemHeight * (videoDisplayCount - 1))) / 2) + (videoItemHeight * (index - 1)));
			}
		}
		else
		{
			if ((videoDisplayCount - maxVerticalLimit) <= maxHorizontalLimit)
			{
				resizeBigElement(baseContainer.width - videoItemWidth, baseContainer.height - videoItemHeight);
				for (index=1; index <= maxVerticalLimit - 1; index++)
				{
					rePositionElement(baseContainer.getElementAt(index), baseContainer.getElementAt(0).width, (index - 1) * videoItemHeight);
				}
				for (index=maxVerticalLimit; index < videoDisplayCount; index++)
				{
					if (videoDisplayCount < maxVerticalLimit + maxHorizontalLimit)
					{
						rePositionElement(baseContainer.getElementAt(index), (((baseContainer.width - (videoItemWidth * (videoDisplayCount - maxVerticalLimit + 1))) / 2) + (videoItemWidth * (videoDisplayCount - maxVerticalLimit - 1 - (index - maxVerticalLimit)))), baseContainer.getElementAt(0).height);
					}
					else // if max limit (L-shape)
					{
						rePositionElement(baseContainer.getElementAt(index), (((baseContainer.width - (videoItemWidth * (videoDisplayCount - maxVerticalLimit))) / 2) + (videoItemWidth * (videoDisplayCount - maxVerticalLimit - 1 - (index - maxVerticalLimit)))), baseContainer.getElementAt(0).height);
					}
				}
			}
			else
			{
				//Alert.show("Max limit reached");
			}
		}
	}
	// Square screen
	else
	{
		if (videoDisplayCount - 1 <= maxHorizontalLimit)
		{
			applicationType::desktop{
				resizeBigElement(baseContainer.width, baseContainer.height - videoItemHeight);
			}
			//Fix for issue #18391
			applicationType::web{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.isFullScreen){
					resizeBigElement(baseContainer.width, baseContainer.height - videoItemHeight - 50);
				}
				else{
					resizeBigElement(baseContainer.width, baseContainer.height - videoItemHeight);
				}
			}
			for (index=1; index < videoDisplayCount; index++)
			{
				rePositionElement(baseContainer.getElementAt(index), ((baseContainer.width - (videoItemWidth * (videoDisplayCount - 1))) / 2) + (videoItemWidth * (index - 1)), baseContainer.getElementAt(0).height);
			}
		}
		else
		{
			if ((videoDisplayCount - maxHorizontalLimit) <= maxVerticalLimit)
			{
				resizeBigElement(baseContainer.width - videoItemWidth, baseContainer.height - videoItemHeight);
				for (index=1; index <= maxHorizontalLimit - 1; index++)
				{
					rePositionElement(baseContainer.getElementAt(index), (index - 1) * videoItemWidth, baseContainer.getElementAt(0).height);
				}
				for (index=maxHorizontalLimit; index < videoDisplayCount; index++)
				{
					if (videoDisplayCount < maxVerticalLimit + maxHorizontalLimit)
					{
						rePositionElement(baseContainer.getElementAt(index), baseContainer.getElementAt(0).width, (((baseContainer.height - (videoItemHeight * (videoDisplayCount - maxHorizontalLimit + 1))) / 2) + (videoItemHeight * (videoDisplayCount - maxHorizontalLimit - 1 - (index - maxHorizontalLimit)))));
					}
					else // if max limit (L-shape)
					{
						rePositionElement(baseContainer.getElementAt(index), baseContainer.getElementAt(0).width, (((baseContainer.height - (videoItemHeight * (videoDisplayCount - maxHorizontalLimit))) / 2) + (videoItemHeight * (videoDisplayCount - maxHorizontalLimit - 1 - (index - maxHorizontalLimit)))));
					}
				}
			}
			else
			{
				//Alert.show("Maximum limit reached");
			}
		}
	}
	reSizeSmallVideoTiles();
}

private function reSizeSmallVideoTiles():void
{
	var videoDisplayCount:int=baseContainer.numElements;
	
	for (var i:int=1; i < videoDisplayCount; i++)
	{
		reSizeSmallVideoTile(baseContainer.getElementAt(i));
	}
}

private function reSizeSmallVideoTile(element:IVisualElement):void
{
	element.width=videoItemWidth;
}

private function rePositionElement(element:IVisualElement, x:int, y:int):void
{
	element.x=x;
	element.y=y;
}

private function resizeBigElement(width:int, height:int):void
{
	if (baseContainer.numElements > 0)
	{
		baseContainer.getElementAt(0).width=width;
		baseContainer.getElementAt(0).height=height;
		baseContainer.getElementAt(0).x = 0;
		baseContainer.getElementAt(0).y = 0;
	}
}

///////////////////////Video display related///////////////

public function getMainVideoDisplay():VideoStreamDisplay
{
	if (baseContainer.numElements == 0)
	{
		return null;
	}
	else
	{
		return baseContainer.getElementAt(0) as VideoStreamDisplay;
	}
}

public function hasVideoTile(tile:VideoStreamDisplay):Boolean
{
	if (baseContainer.contentGroup.containsElement(tile))
	{
		return true;
	}
	return false;
}

public function addVideoTile(tile:VideoStreamDisplay, index:int=-1):void
{
	if (index > -1)
	{
		baseContainer.addElementAt(tile, index);
	}
	else
	{
		baseContainer.addElement(tile);
	}
	tile.isEmbeddedVideoInVideoWall=true;
	tile.vidDispObj.doubleClickEnabled=false;
	containerResizeTimeOutID=setTimeout(calculateVideoItemSize, 100);
}

public function removeVideoTile(userName:String, component:VideoStreamDisplay=null):VideoStreamDisplay
{
	var removedTile:VideoStreamDisplay=null;
	//if pnlTeacher
	if (component)
	{
		removedTile=baseContainer.removeElement(component) as VideoStreamDisplay;
		removedTile.isEmbeddedVideoInVideoWall=false;
	}
	else
	{
		for (var i:int=1; i < baseContainer.numElements; i++)
		{
			var currentTile:VideoStreamDisplay=baseContainer.getElementAt(i) as VideoStreamDisplay;
			if (currentTile.userName == userName && currentTile.name != "pnlTeacher")
			{
				removedTile=baseContainer.removeElementAt(i) as VideoStreamDisplay;
				removedTile.isEmbeddedVideoInVideoWall=false;
				break;
			}
		}
	}
	calculateVideoItemSize();
	return removedTile;
}

public function popOutButtonVisibility():void
{
	applicationType::desktop{
		videoWallWindow.isMeetingLayout = false;
	}
	isPopOut=true;	
	btnFullScreen.visible=false;
	btnFullScreen.includeInLayout=false;
	btnShow.visible=false;
	btnShow.includeInLayout=false;	
	btnClose.visible=false;	
	btnClose.includeInLayout=false;	
	btnControls.width=28;
	popOutBtn.toolTip="Pop-In";
	popOutBtn.setStyle("icon",popinIcon);
	
}


////////////////////////////// Pop-out/////////////////////

public function popOutVideoWallWindow():void
{
	applicationType::desktop{
		if (fullScreenStatus == true){
			fullScreenSelected();
		}
		if (!isPopOut){
			videoWallWindow=new VideoWallPopOut();
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewerVideoWallBox && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewerVideoWallBox.contains((this)))
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewerVideoWallBox.removeChild(this);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMessageForFullScreenForVideo(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewerVideoWallBox, Constants.FULLSCREEN_MSG);
			videoWallWindow.vidWallComp=this;
			videoWallWindow.open(true);
			videoWallWindow.maximize();
			isPopOut=true;
			AuditContext.userAction.videoWallPopOutEventLog();
			btnFullScreen.visible=false;
			btnFullScreen.includeInLayout=false;
			btnShow.visible=false;
			btnShow.includeInLayout=false;
			btnClose.visible=false;
			btnClose.includeInLayout=false;
			btnControls.width=28;
			popOutBtn.toolTip="Pop-In";
		}
		else
		{
			if (videoWallWindow){
				if (!isPopOutClosed){
					videoWallWindow.close();
				}
				/*btnFullScreen.visible=true;
				btnFullScreen.includeInLayout=true;
				btnShow.visible=true;
				btnShow.includeInLayout=true;
				btnClose.visible=true;
				btnClose.includeInLayout=true;*/
				applicationType::desktop{
					btnControls.width=84;
				}
				applicationType::web{
					btnControls.width=62;
				}
			}
			else
				return;
		
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unSetMessageForFullScreenForVideo(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewerVideoWallBox);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewerVideoWallBox.addChild(this);
			}
			isPopOut=false;
			popOutBtn.setStyle('icon', popoutIcon);
			popOutBtn.toolTip="Pop Out";
			AuditContext.userAction.videoWallPopInEventLog();
			isPopOutClosed=false;
		}
	}
}

//////////////////////////// Pop-out ends/////////////////////

//////////////////////////// Full screen starts/////////////////////
public function closeFullScreen():void
{
	if (fullScreen)
	{
		fullScreenSelected();
		//Fix for issue #10733.No pop out feature for web
		applicationType::web
		{
			popOutBtn.visible=false;
			popOutBtn.includeInLayout=false;
		}
		applicationType::desktop
		{
			popOutBtn.visible=true;
			popOutBtn.includeInLayout=true;
		}
		/*btnShow.visible=true;
		btnShow.includeInLayout=true;*/
	}
}

public function fullScreenSelected():void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multipleWindowActivateHandler("videoWallMW");
	if (isPopOut == true)
		popOutVideoWallWindow();
	if (fullScreenStatus == false)
	{
		bigScreenDisplay.videowallFullScreenStatus=true;
		//stores the orginal width and height 
		orgHeight=this.height;
		orgWidth=this.width;
		fullScreenStatus=true;
		btnFullScreen.setStyle('icon', exitFullScreenIcon);
		btnFullScreen.toolTip="Exit full screen";
		bigScreenDisplay.resizabletitlewindow1_resizeHandler();
		
	}
	if (!fullScreen)
	{
		if (!this.systemManager.getTopLevelRoot())
			return;
		var screenBounds:Rectangle=getScreenBounds();
		fullScreen=true;
		beforeFullScreenInfo={parent: this.parent, x: this.x, y: this.y, explicitWidth: this.explicitWidth, explicitHeight: this.explicitHeight, percentWidth: this.percentWidth, percentHeight: this.percentHeight, isPopUp: this.isPopUp};
		
		if (!this.isPopUp)
		{
			if (parent is IVisualElementContainer)
			{
				var ivec:IVisualElementContainer=IVisualElementContainer(parent);
				beforeFullScreenInfo.childIndex=ivec.getElementIndex(this);
				ivec.removeElement(this);
			}
			else
			{
				beforeFullScreenInfo.childIndex=parent.getChildIndex(this);
				parent.removeChild(this);
			}
			PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject, false, null, this.moduleFactory);
		}
		this.setLayoutBoundsSize(screenBounds.width, screenBounds.height, true);
		this.explicitWidth=this.width;
		this.explicitHeight=this.height;
		this.setLayoutBoundsPosition(0, 0, true);
		this.validateNow();
		this.systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
		this.systemManager.stage.displayState=StageDisplayState.FULL_SCREEN;
		popOutBtn.visible=false;
		popOutBtn.includeInLayout=false;
		btnShow.visible=false;
		btnClose.visible=false;
		btnClose.includeInLayout=false;
		btnFullScreen.visible=true;
		btnFullScreen.includeInLayout=true;
		btnControls.width=28;
	}
	else
	{
		//Fix for issue #10733.No pop out feature for web
		applicationType::web
		{
			popOutBtn.visible=false;
			popOutBtn.includeInLayout=false;
			//Changed hbox width to avoid expand/collapse button position issue
			btnControls.width=62;
		}
		applicationType::desktop
		{
			popOutBtn.visible=true;
			popOutBtn.includeInLayout=true;
			btnControls.width=84;
		}
		//btnShow.visible=true;
		btnClose.visible=true;
		btnClose.includeInLayout=true;
		//btnShow.includeInLayout=true;
		bigScreenDisplay.videowallFullScreenStatus=false;
		this.systemManager.stage.displayState=StageDisplayState.NORMAL;
	}
}

private static function get screenClass():Class
{
	if (!checkedForScreenClass)
	{
		checkedForScreenClass=true;
		
		if (ApplicationDomain.currentDomain.hasDefinition("flash.display::Screen"))
		{
			_screenClass=Class(ApplicationDomain.currentDomain.getDefinition("flash.display::Screen"));
		}
	}
	return _screenClass;
}

private function getScreenBounds():Rectangle
{
	var resultRect:Rectangle=new Rectangle(0, 0, this.stage.fullScreenWidth, this.stage.fullScreenHeight);
	if (screenClass)
	{
		try
		{
			var nativeWindowBounds:Rectangle=this.stage["nativeWindow"]["bounds"];
			var currentScreen:Object=screenClass["getScreensForRectangle"](nativeWindowBounds)[0];
			resultRect=currentScreen["bounds"];
		}
		catch (e:Error) {
			if(Log.isError()) log.error("Error in getScreenBounds method :"+ e.getStackTrace());
		}
	}
	return resultRect;
}

private function fullScreenEventHandler(event:FullScreenEvent):void
{
	if (event.fullScreen)
		return;
	fullScreen=false;
	this.systemManager.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
	
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changeFullscreenBtnStatus();
	this.x=beforeFullScreenInfo.x;
	this.y=beforeFullScreenInfo.y;
	this.width=orgWidth;
	this.height=orgHeight;
	if (this.explicitWidth > 0)
	{
		this.explicitWidth=beforeFullScreenInfo.explicitWidth;
		this.explicitHeight=beforeFullScreenInfo.explicitHeight;
	}
	else
	{
		this.explicitWidth=orgWidth;
		this.explicitHeight=orgHeight;
	}
	
	
	if (!beforeFullScreenInfo.isPopUp)
	{
		PopUpManager.removePopUp(this);
		if (beforeFullScreenInfo.parent is IVisualElementContainer)
			beforeFullScreenInfo.parent.addElementAt(this, beforeFullScreenInfo.childIndex);
		else
			beforeFullScreenInfo.parent.addChildAt(this, beforeFullScreenInfo.childIndex);
	}
	
	this.systemManager.stage.scaleMode=StageScaleMode.NO_SCALE;
	this.percentWidth=beforeFullScreenInfo.percentWidth;
	this.percentHeight=beforeFullScreenInfo.percentHeight;
	beforeFullScreenInfo=null;
	this.invalidateSize();
	this.invalidateDisplayList();
	
	if (fullScreenStatus == true)
	{
		btnFullScreen.setStyle('icon', fullScreenIcon);
		btnFullScreen.toolTip="Full screen";
		this.systemManager.stage.displayState=StageDisplayState.NORMAL;
		//Fix for issue #10733.No pop out feature for web
		/*applicationType::web
		{
			popOutBtn.visible=false;
			popOutBtn.includeInLayout=false;
			//Changed hbox width to avoid expand/collapse button position issue
			btnControls.width=62;
		}
		applicationType::desktop
		{
			popOutBtn.visible=true;
			popOutBtn.includeInLayout=true;
			btnControls.width=84;
		}*/
		/*fullScreenStatus=false;
		btnClose.visible=true;
		btnClose.includeInLayout=true;
		btnShow.visible=true;*/
	}
}

//////////////////////////// Full screen ends/////////////////////

protected function showHide_clickHandler(event:MouseEvent):void
{
	if (btnControls.width == 10)
	{
		btnShow.source=hideIcon;
		btnShow.toolTip="Hide";
		//Changed hbox width to avoid expand/collapse button position issue
		applicationType::web
		{
			btnControls.width=62;
		}
		applicationType::desktop
		{
			btnControls.width=84;
		}
		expand.play();
		colapse.stop();
		hboxControl.visible=true;
	}
	else
	{
		btnControls.width=10;
		btnShow.source=showIcon;
		btnShow.toolTip="Show";
		hboxControl.visible=false;
		//hboxControl.enabled=false;
		colapse.play();
		expand.stop();
		
		
	}
}


protected function close_clickHandler(event:MouseEvent):void
{
	if(ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName)
	{
		var isSameLayout:Boolean = false;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallCollaborationObject.getData()["videoWallLayout"] == Constants.SIMPLE_LAYOUT)
		{
			isSameLayout = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setVideoWallLayout(null);
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setVideoWallLayout(Constants.SIMPLE_LAYOUT);
		if(isSameLayout)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setVideoWallSharedObjectData("prevVideoWallLayout", Constants.PRESENTER_LAYOUT);
		}
	}
	else 
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.toggleVideoWall(); 

}
}