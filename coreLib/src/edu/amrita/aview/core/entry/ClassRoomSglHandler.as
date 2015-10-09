// ActionScript file
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.entry.itemrenderers.CustomToolTip;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.events.EffectEvent;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;

private var leftPannelWidth:Number;
private var rightPannelWidth:Number;
//Fix for issue #17054
applicationType::web{
	//Variables related to fullscreen logic 
	[Bindable]
	public var isFullScreen:Boolean=false;
	[Bindable]
	private var fullScreenStatus:Boolean=false;
	private var beforeFullScreenInfo:Object;
	[Bindable]
	private var orgWidth:int=0;
	[Bindable]
	private var orgHeight:int=0;
	private var parentHeight:Number;
	private var parentWidth:Number;
	private static var _screenClass:Class;
	private static var checkedForScreenClass:Boolean;	
	[Bindable]
	[Embed(source="assets/images/exitFull-Screen.png")]
	public var closeFullScreenIcon:Class;
}

[Bindable]
[Embed(source="assets/images/fulll-screen.png")]
public var openFullScreenIcon:Class;

[Bindable]
public var interactionCountStatus:Boolean = true;

[Bindable]
public var userIconStatus:Boolean = false;
[Bindable]
public var questionCount:int = 0;

[Bindable]
public var questionList:ArrayCollection = new ArrayCollection();

[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/tab_active.jpg")]
public var activeTab:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/core/entry/assets/images/tab_bg.jpg")]
public var inactiveTab:Class;	


public function hideLeftPannel_clickHandler(event:MouseEvent):void {
	if (controlvidbox.width == 0)
		leftPanelExpand_clickHandler(event);
	else {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.enabled=false;
		leftPannelWidth=controlvidbox.width;
		rightPannelWidth=canvas3.width;
		controlvidboxHide.widthFrom=leftPannelWidth;
		controlvidboxHide.widthTo=0;
		controlvidboxHide.play()

		canvas3.percentWidth=100;
		controlvidbox.percentHeight=100;
		hidePanelEventLog();
	}
}

/**
 *
 * @private
 * Audits the "HidePanel" action, when the user hides the left panel containing the userlist/chat etc.
 *
 * @return void
 *
 */
private function hidePanelEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.hidePanel, null, null, null);
}

//RGCR: Instead of referring to FlexGlobals.topLevelApplication.mainApp.mainContainerComp using FlexGlobals, you can pass in mainContainerComp as parameter to this comp
//and then refer to this. That way ClassRoomSgl would become more flexible.

protected function controlvidboxHide_effectEndHandler(event:EffectEvent):void {
	canvas3.percentWidth=100;
	if (controlvidbox.width == 0) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.setStyle('imageSkin', FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unHideVideoPannel);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.toolTip="Show Panel";
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.enabled=true;
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.left=controlvidbox.width;
	if (controlvidbox.width > 0) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.setStyle('imageSkin', FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.hideVideoPannel);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.left-=8;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.toolTip="Hide Panel";
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.wbComp.onShowPanel();
	}
	controlvidbox.percentHeight=100;
}

protected function leftPanelExpand_clickHandler(event:MouseEvent):void {

	controlvidboxHide.widthFrom=0
	controlvidboxHide.widthTo=leftPannelWidth;
	controlvidboxHide.play()
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.enabled=false;
	showPanelEventLog();
}

/**
 *
 * @private
 * Audits the "ShowPanel" action, when the user unhides/shwos the left panel containing the userlist/chat etc.
 *
 * @return void
 *
 */
private function showPanelEventLog():void
{
	AuditContext.userAction.createAction(AuditConstants.showPanel, null, null, null);
}

public function hideSettings():void {
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.settingsList.visible=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.settingsList.height=0;
}

protected function controlvidbox_resizeHandler(event:ResizeEvent):void {
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		return;
	if (controlvidbox.width == 0)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.left=0;
	else {
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.VIEWER_ROLE && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout == Constants.SIMPLE_LAYOUT) {
			var factor:uint=controlvidbox.width / 16;
			pnlTeacher.resizeFactorTitleWindow=factor;
			pnlTeacher.resizeFactor=factor;
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.btnResize.left=controlvidbox.width - 10;
	}

}

public function youtubeLiveButtonMouseOver():void {
	if (Conso_YoutubeLive.enabled) {
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isYoutubeLiveStarted == false)
			Conso_YoutubeLive.toolTip="Start YoutubeLive";
		else
			Conso_YoutubeLive.toolTip="Stop YoutubeLive";
	} else {
		Conso_YoutubeLive.toolTip="YoutubeLive available only for Windows7.";
	}
}

protected function leftSideUIComponentsInitializeHandler():void {
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initCamList();
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		return;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout == Constants.SIMPLE_LAYOUT) {
		pnlTeacher.percentWidth=100;
	}
}

private function getBackground(value:int):void
{
	if (value==0)
	{
		userListTab.setStyle('backgroundImage',activeTab);
		chatTab.setStyle('backgroundImage',inactiveTab);
		viewerTab.setStyle('backgroundImage',inactiveTab);
		questionTab.setStyle('backgroundImage',inactiveTab);
		userTabTxt.setStyle('color','#FFFFFF');
		chatTabTxt.setStyle('color','#727273');
		viewerTabTxt.setStyle('color','#727273');
		questionTabTxt.setStyle('color','#727273');
	}
	else if (value==1)
	{
		userListTab.setStyle('backgroundImage',inactiveTab);
		chatTab.setStyle('backgroundImage',activeTab);
		viewerTab.setStyle('backgroundImage',inactiveTab);
		questionTab.setStyle('backgroundImage',inactiveTab);
		
		userTabTxt.setStyle('color','#727273');
		chatTabTxt.setStyle('color','#FFFFFF');
		viewerTabTxt.setStyle('color','#727273');
		questionTabTxt.setStyle('color','#727273');
	}
	else if (value==2)
	{
		userListTab.setStyle('backgroundImage',inactiveTab);
		chatTab.setStyle('backgroundImage',inactiveTab);
		viewerTab.setStyle('backgroundImage',activeTab);
		questionTab.setStyle('backgroundImage',inactiveTab);
		
		userTabTxt.setStyle('color','#727273');
		chatTabTxt.setStyle('color','#727273');
		viewerTabTxt.setStyle('color','#FFFFFF');
		questionTabTxt.setStyle('color','#727273');
	}
	else if (value==3)
	{
		userListTab.setStyle('backgroundImage',inactiveTab);
		chatTab.setStyle('backgroundImage',inactiveTab);
		viewerTab.setStyle('backgroundImage',inactiveTab);
		questionTab.setStyle('backgroundImage',activeTab);
		
		userTabTxt.setStyle('color','#727273');
		viewerTabTxt.setStyle('color','#727273');
		chatTabTxt.setStyle('color','#727273');
		questionTabTxt.setStyle('color','#FFFFFF');
	}
}




protected function tabIndexChangeHandler():void {
	//return;
	if (leftPanelTabNav.selectedIndex == 2) {
		/* if(tab2.selectedIndex==6)
		tab2.selectedIndex=0; */
		/* tab1.selectedIndex=2;
		if(viewerVideoWallBox.getChildren().length>0)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.toggleVideoWall();   */
	}

}
	//Fix for issue #17054
	public function fullScreenSelected():void
	{
		applicationType::web{
			if (fullScreenStatus == false)
			{
				//stores the orginal width and height 
				orgHeight=this.height;
				orgWidth=this.width;
				fullScreenStatus=true;
				//Fix for issue #19270 and #19618
				btnContentFullScreen.toolTip="Exit Content full screen";
				btnContentFullScreen.setStyle("icon",closeFullScreenIcon);					
			}
			if (!isFullScreen)
			{
				if (!this.systemManager.getTopLevelRoot())
					return;
				var screenBounds:Rectangle=getScreenBounds();
				isFullScreen=true;
				var evt:MouseEvent;
				hideLeftPannel_clickHandler(evt);
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
					PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject, false, null,moduleFactory);
				}
				this.setLayoutBoundsSize(stage.fullScreenWidth, stage.fullScreenHeight, true);
				this.explicitWidth=this.width;
				this.explicitHeight=this.height;
				this.width = stage.fullScreenWidth;
				this.height = stage.fullScreenHeight;
				this.setLayoutBoundsPosition(0, 0, true);
				this.validateNow();
				this.systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
				this.systemManager.stage.displayState=StageDisplayState.FULL_SCREEN;
				//Fix for issue #19270
				btnContentFullScreen.visible=true;
				btnContentFullScreen.includeInLayout=true;
				btnContentFullScreen.setStyle("icon",closeFullScreenIcon);
				//Fix for issue #19618
				btnContentFullScreen.toolTip="Exit Content full screen";
				controlvidbox.visible = false;
				controlvidbox.includeInLayout = false;
				hGrpRightTopSgl.right = 0;
				tab2.right =0;
				//Fix for issue #19270
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.VIEWER_ROLE){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.player.btnFullScreen.visible = false;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.player.btnFullScreen.includeInLayout = false;
				}
				//Fix for issues #19175,#18456 and #18390
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.mainBox.visible = false;
				FlexGlobals.topLevelApplication.mainApp.bottomContainer.visible = false;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.btnShowHide.visible = false;
			}
			else
			{
				this.systemManager.stage.displayState=StageDisplayState.NORMAL;
			}
		}
	}

//Fix for issue #17054
applicationType::web{
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
				
			}
		}
		return resultRect;
	}
	
	private function fullScreenEventHandler(event:FullScreenEvent):void
	{
		if (event.fullScreen)
			return;
		isFullScreen=false;
		this.systemManager.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
		
		this.x=beforeFullScreenInfo.x;
		this.y=beforeFullScreenInfo.y;
		this.explicitWidth=beforeFullScreenInfo.explicitWidth;
		this.explicitHeight=beforeFullScreenInfo.explicitHeight;
		this.percentWidth=beforeFullScreenInfo.percentWidth;
		this.percentHeight=beforeFullScreenInfo.percentHeight;
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
		
		this.invalidateSize();
		this.invalidateDisplayList();
		//Fix for issue #19270
		btnContentFullScreen.setStyle("icon",openFullScreenIcon);
		//Fix for issue #19618
		btnContentFullScreen.toolTip="Content full screen"; 
		if (fullScreenStatus == true)
		{
			controlvidbox.visible = true;
			controlvidbox.includeInLayout = true;
			hGrpRightTopSgl.right = 5;
			var evt:MouseEvent;
			hideLeftPannel_clickHandler(evt);
			this.systemManager.stage.displayState=StageDisplayState.NORMAL;
		}
		//Fix for issue #19270
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.VIEWER_ROLE){
			//Fix for issue #18137
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.player.btnFullScreen.visible = false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.player.btnFullScreen.includeInLayout = false;
		}
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.objVideoWall){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.objVideoWall.calculateVideoItemSize();
		}
		//Fix for issue #18699 and #18772
		if( FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.isFullScreen){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.localVideoFullScreen();
		}
		//Fix for issues #19175,#18456 and #18390
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.mainBox.visible = true;
		FlexGlobals.topLevelApplication.mainApp.bottomContainer.visible = true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.btnShowHide.visible = true;
	}
}