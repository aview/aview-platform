///////////////////////////////////////////////////////////////////////////////
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
 * File			: DesktopViewerHandler.as
 * Module		: DesktopSharing
 * Developer(s)	: Ajith Kumar R,Remya T
 * Reviewer(s)	: Meena S
 *
 *DesktopPlayerHandler.as is used to handle functionalities related to DesktopPlayer custom component.
 *
 */

applicationType::desktop{
	import edu.amrita.aview.core.desktopSharing.DesktopPlayer;
}
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import flash.xml.XMLNode;
import flash.xml.XMLNodeType;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.IVisualElementContainer;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

import utils.FFTalkEvent;
import edu.amrita.aview.core.shared.components.mobileComponents.toolTip.MobileToolTip;
import edu.amrita.aview.core.shared.components.mobileComponents.FullScreenLabel;

/**
 * Sprite variable for creating full-screen confirmation window.
 */
private var fullScreenConfirmWindow:Sprite;
/**
 * Sprite variable for creating background of full-screen confirmation window.
 */
private var fullScreenConfirmBackground:Sprite;
/**
 * Variable for storing the status of desktopplayer window,whether it is created or not.
 */
public var isDesktopPlayerCreated:Boolean=false;
/**
 * Variable for storing the timeout id of HTML loader.
 */
public var loadTimeoutId:uint;
/**
 * Variable for storing the timeout id of refreshing HTML loader.
 */
public var refreshTimeoutId:uint;
/**
 *Variable for storing the close status of DesktopPlayer window.
 */
public var isDesktopPlayerWindowClosedManually:Boolean=false;
//Fix for issue #15318
private var isHideButtonControls:Boolean = true;
/**
 *Variable for storing the image for fullscreen button.
 */
[Bindable]
[Embed(source="./assets/images/fullScreen.png")]
private var fullScreen_Icon:Class;
/**
 *Variable for storing the image for exit fullscreen button.
 */
[Bindable]
[Embed(source="./assets/images/exitFullScreen.png")]
private var exitFullScreen_Icon:Class;
/**
 *Variable for storing the icon image for fullscreen button.
 */
[Bindable]
private var fullScreenIcon:Class = fullScreen_Icon;
/**
 *Variable for storing the image for panscreen button.
 */
[Bindable]
[Embed(source="./assets/images/panScreen.png")]
private var panScreen_Icon:Class;
/**
 *Variable for storing the image for exit panscreen button.
 */
[Bindable]
[Embed(source="./assets/images/exitPanScreen.png")]
private var exitPanScreen_Icon:Class;
/**
 *Variable for storing the icon image for panscreen button.
 */
[Bindable]
private var panScreenIcon:Class = panScreen_Icon;
/**
 *Variable for storing the image for refresh button.
 */
[Bindable]
[Embed(source="./assets/images/Refresh.png")]
public var refresh:Class;
/**
 *Variable for storing the icon image for refresh button.
 */
[Bindable]
public var refreshIcon:Class=refresh;
//Fix for issue #15318
/**
 *Variable for storing the image for pop-out button.
 */
[Bindable]
[Embed(source="./assets/images/pop-out.png")]
public var popoutIcon:Class;
/**
 *Variable for storing the image for pop-in button.
 */
[Bindable]
[Embed(source="./assets/images/pop-in.png")]
public var popinIcon:Class;
/**
 *Variable for storing the image for show arrow button.
 */
[Bindable]
[Embed(source="./assets/images/showarrow.png")]
public var showIcon:Class;
/**
 *Variable for storing the image for hide arrow button
 */
[Bindable]
[Embed(source="./assets/images/hidearrow.png")]
public var hideIcon:Class;


/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.desktopSharing.DesktopPlayerHandler.as");

/**
 * To check whether desktop sharing window is full screen or not
 * false means not fullscreen
 * @default false
 */
public var isPopOut:Boolean=false;
//For Full screen window
applicationType::desktop{
	public var desktopSharingWindow:DesktopPlayer;
}
//normal height of SMLPlayer
private var normalHeight:Number=0;
//streamName of sharedscreen the username of sharing user
[Bindable]
public var streamName:String="";
//url to access the media server instance
private var serverUrl:String="";
//set to true if user is following the mouse pointer of sharing user
private var isServerPan:Boolean=false;
//set to true if the video is in fullscreen
public var isFullScreen:Boolean=false;

public var fitFiltered:int=0;
//domain name/ip address of the streamin server
[Bindable]
public var host:String="";

[Bindable]
public var port:String="";

[Bindable]
public var instanceName:String="";
//player for displaying the video
public var screenPlayer:SMLPlayer;
//This variable is used to set Screen player width whenever screen player height is changed.
public var heightChangeWatcher:ChangeWatcher=null;
private var beforeFullScreenInfo:Object;
private static var _screenClass:Class;
// parameters for fullscreenvideo			
private static var checkedForScreenClass:Boolean;
//width of the player when user chooses panscreen option
private var panningWidth:Number=0;
//height of the player when user chooses panscreen option
private var panningHeight:Number=0;
/**
 * This function is used to set screen player size.
 * @param null
 * @return void
 */
public function calculatePlayerSize():void
{
	if(isPopOut){
		//Fix for issues #15296 and #15522
		applicationType::desktop{
			normalHeight = desktopSharingWindow.height - 63;
		}
	}
	else{
		applicationType::desktop {
			//Fix for issue#15501
			normalHeight=scrlgroup.height - 5;
		}
		applicationType::mobile{
			normalHeight= FlexGlobals.topLevelApplication.sharing.height-5;
		}
	}
	//To set the position soon after the component is created, for late Viewer
	setPlayerPositionAndSize(normalHeight);
}

/**
 * Function used to create the configuration for playing the netstream in player.
 * @param null
 * @return string
 */
private function createConfiguration():String
{
	var screenShareObj:ScreenSharing=new ScreenSharing();
	fitFiltered=1;
	//Removed instanceName in serverUrl as it was in the desktop version
	serverUrl="rtmp://" + host + ":" + port + "/desktopsharing_module";
	
	//creates the configuration for playing netstream in player
	var xml:XMLNode=new XMLNode(XMLNodeType.ELEMENT_NODE, "params");
	//rtmp connection string
	xml.attributes.rtmp=serverUrl;
	if(ClassroomContext.aviewClass.classType=="Meeting")
	{
		streamName = "myScreen_"+ClassroomContext.lecture.lectureId;
	}
	else
	{
		streamName = "myScreen_"+ClassroomContext.aviewClass.className;
	}
	//rtmp streamName
	xml.attributes.stream=streamName;
	//smoothing
	xml.attributes.smoothing=true;
	//TODO: need not be there,not sure what it is
	xml.attributes.verification="sampleVerification";
	//add the configuration to xmlnode <config>
	var configxml:XMLNode=new XMLNode(XMLNodeType.ELEMENT_NODE, "config");
	configxml.appendChild(xml);
	//returns the xml string of the configurationn
	return configxml.toString();
}

/**
 * This function is used to set the position and width of SMLPlayer
 * @param height of type Number
 * @return void
 */
public function setPlayerPositionAndSize(height:Number):void
{
	if (screenPlayer != null && isFullScreen == false)
	{
		screenPlayer.height=height;
		//Fix for issue#15501
		screenPlayer.width=scrlgroup.width - 30;
		applicationType::desktop{
				//Fix for issue #15296
				if(isPopOut){
				//Fix for issue #15836
					screenPlayer.x=(desktopSharingWindow.width-screenPlayer.width)/2;
					screenPlayer.y=0;
					//Fix for issue#15501
					screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
					return;
				}
			}
			//Fix for issue#15501
			if(scrlgroup != null){
				screenPlayer.x=(scrlgroup.width - screenPlayer.width) / 2;
			}
		
		screenPlayer.y=0;
		applicationType::DesktopMobile{
			//Fix for issue#15501
			screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
		}
	}
}

/**
 * Function used to displays the player component
 * Invoked from viewDesktop method of ShareDesktop
 * @param playerWidth of type Number
 * @param playerHeight of type Number
 * @return null
 */
public function displayPlayer(playerWidth:Number, playerHeight:Number):void
{
	if (screenPlayer == null)
	{
		//Fix for issue #11717 and Fix for issue #15904
		screenPlayer=new SMLPlayer(enableControlButtons,hideLoadingLabel);
		heightChangeWatcher=BindingUtils.bindSetter(setWidth, screenPlayer, "height");
	}
	if (!scrlgroup.containsElement(screenPlayer))
	{
		//To set the position when Presenter streams the desktop, for all Viewers
		calculatePlayerSize();
		scrlgroup.addElement(screenPlayer);
		screenPlayer.addEventListener(FFTalkEvent.TALK_TO_FLEX, onPlayerTalk);
	}
	applicationType::DesktopMobile{
		//saves the size of the width and height of actual video 
		// its used when panning is selected
		panningHeight=playerHeight;
		panningWidth=playerWidth;
	}
	//Fix for issue #18067
	if(isServerPan){	
		setTimeout(screenPlayer.toggleServerPan,100);
	}
	//Fix for issue #15565
	if(isFullScreen){
		screenPlayer.width=this.explicitWidth - 10;
		applicationType::desktop{
			screenPlayer.height=this.explicitHeight - 40;
			//set the size of the container
			screenPlayer.processContainerInfo(this.explicitWidth + "_" + (this.explicitHeight - 30) + "_0_30");
		}
		applicationType::mobile{
			screenPlayer.height=this.explicitHeight;
			//set the size of the container
			screenPlayer.processContainerInfo(this.explicitWidth + "_" + this.explicitHeight + "_0_0");
		}
	}
	applicationType::desktop{
		//Fix for issue #18249
		if (isPopOut){
			desktopSharingWindow.alwaysInFront = true;
			desktopSharingWindow.open(true);
		}
	}
	screenPlayer.setConfiguration(createConfiguration());
}

/**
 * This function is used to enable control buttons after a specifed interval.
 * @param event of type ScreenShareEvent
 * @return void
 */
public function enableControlButtons(event:ScreenShareEvent):void
{
	applicationType::mobile{
		if(!lblSharingMessage.visible){
			lblLoadingMessage.visible = true;
			btnPanScreen.enabled=true;
			btnFullScreen.enabled=true;
			scrlgroup.visible=true;
		}else{
			btnPanScreen.enabled=false;
			btnFullScreen.enabled=false;
		}
	}
	applicationType::desktop{
		if(!lblSharingMessage.visible){
			//Fix for issue #15843
			lblLoadingMessage.visible = true;
			//Fix for issues #20094 & #20220
			enableIcons(true);
			scrlgroup.visible=true;
		}else{
			enableIcons(false);
		}
	}
}
//Fix for issue #15904
public function hideLoadingLabel(event:ScreenShareEvent):void{
	lblLoadingMessage.visible = false;
	//Fix for issue #15839 & #19437
	if(isServerPan && screenPlayer){
		setTimeout(screenPlayer.toggleServerPan,100);
	}
	applicationType::desktop{
		//Fix for issue #20096
		if(!lblSharingMessage.visible){
			lblLoadingMessage.visible = true;
			enableIcons(true);
		}else{
			enableIcons(false);
		}
	}
	applicationType::mobile{
		if(!lblSharingMessage.visible){
			lblLoadingMessage.visible = true;
			btnPanScreen.enabled=true;
			btnFullScreen.enabled=true;
		}else{
			btnPanScreen.enabled=false;
			btnFullScreen.enabled=false;
		}
	}
}

/**
 * If ChangeWatcher instance is successfully created, this function is invoked.
 * This function is used to  set screen player width and height.Also set video width and height.
 * @param height of type Number
 * @return void
 */
private function setWidth(height:Number):void
{
	applicationType::mobile{
		if (!isFullScreen)
		{
			if (this.width >= height * 1.3333)
			{
				screenPlayer.width=(height * 1.3333) - 3;
			}
			else
			{
				if (height > this.height)
				{
					screenPlayer.height=this.height - hboxControl.height;
				}
				else
				{
					screenPlayer.height=(this.width * 0.75) - 3;
				}
			}
			if(screenPlayer.width<0){
				if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
					screenPlayer.width = (FlexGlobals.topLevelApplication.width/100)*69;
				}else{
					screenPlayer.width = (FlexGlobals.topLevelApplication.width/100)*89;
				}
			}
			screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
		}
	}
}

/**
 * Event listener for SMLPLayer's FFTalkEvent.TALK_TO_FLEX event
 * @param event of type FFTalkEvent
 * @return void
 * */
private function onPlayerTalk(event:FFTalkEvent):void
{
	if (event.said == "getVidInfo")
	{
		if (screenPlayer)
		{
			//passes the container information .
			// based on these measures the player re-adjusts the size of video
			screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_10");
		}
	}
}

/**
 * Function used to removes the player component.
 * Invoked from viewDesktop method of ShareDesktop
 * @param null
 * @return void
 */
public function removePlayer():void
{
	if (screenPlayer)
	{
		//invoking dispose() method which releases the resources in player
		screenPlayer.dispose();
		//removes player
		scrlgroup.removeElement(screenPlayer);
		//set screenPlayer instance to null
		screenPlayer=null;
	}
	applicationType::desktop{
		//change the UI
		//Fix for issue #15664
		enableIcons(false);
		if(scrlgroup != null)
			scrlgroup.visible=false;
	}
	
	applicationType::mobile{
		if(btnPanScreen!= null){
			btnPanScreen.enabled=false;
			btnFullScreen.enabled=false;
		}
		if(scrlgroup != null){
			scrlgroup.visible=false;
		}
	}
}

/**
 * @public
 * Function used for adding all event handlers on creation complete of DesktopPlayer component.
 *
 *
 * @return void
 */
public function initDesktopPlayer():void{
	this.addEventListener(Event.CLOSING, closeDesktopViewer);
	//Fix for issue #15300
	isDesktopPlayerCreated = true;
	//Fix for issue #15664
	enableIcons(false);
	applicationType::desktop{
		//Fix for issue #15318
		btnHideShow.source = hideIcon;
		btnHideShow.toolTip="Hide";
		hgControls.width = 106;
		expand.widthTo = 106;
		colapse.widthFrom = 106;
	}
	scrlgroup.visible=false;
	calculatePlayerSize();
	host =ClassroomContext.DESKTOP_SHARING_SERVER;
	port = Constants.FMS_SERVER_PORT.toString();
	lblSharingMessage.visible= true;
}
//Fix for issue #15664
private function enableIcons(bool:Boolean):void
{
	applicationType::desktop{
		if(btnRefresh != null)
		{
			//Fix for issue #5894
			btnRefresh.setFocus();
			btnPopout.enabled=bool;
			btnFullScreen.enabled=bool;
//			btnRefresh.enabled=bool;
			btnPanScreen.enabled=bool;
		}
	}
	applicationType::mobile{
		btnPanScreen.enabled=bool;
		btnFullScreen.enabled=bool;
	}
}

/**
 * @public
 * Function used for making the DesktopPlayer window to fullscreen and back to normal.
 *
 *
 * @return void
 */
public function toggleFullScreen():void{
	try{
		switch (this.stage.displayState){
			case StageDisplayState.FULL_SCREEN:
				// If already in full screen mode, switch to normal mode. 
				this.stage.displayState=StageDisplayState.NORMAL;
				break;
			default:
				// If not in full screen mode, switch to full screen mode. 
				this.stage.displayState=StageDisplayState.FULL_SCREEN;
				break;
		}
	}
	catch (err:SecurityError){
		if(Log.isError()) log.error("Error in toggleFullScreen method:"+ err.getStackTrace());
	}
}

/**
 * @public
 * Function used for handling the window close event of DesktopPlayer window component.
 *
 * @param event of type Event
 * @return void
 */
//Fix for issue #15417
public function closeDesktopViewer(event:Event = null):void{
	try{
		//Change the desktopplayer button's icon & unhide the player window
		if (isDesktopPlayerCreated == true){
			isDesktopPlayerWindowClosedManually=true;
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.show_Desktop_IconClass_Multi=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.show_DesktopUnselect;
		event.preventDefault();
	}
	catch (err:Error){
		if(Log.isError()) log.error("Error in closeDesktopViewer method:"+ err.getStackTrace());
	}
	if(isPopOut){
		applicationType::desktop{
			desktopSharingWindow.close();
			//Fix for #20126
			isPopOut = false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp.changeView(true);
		}
	}
}

/**
 * @private
 * Function used for loading SMLPlayer (for viewing desktop stream) from the content server.
 *
 * @return void
 */
private function refreshDesktopPlayer():void{
	if(screenPlayer)
	{
		//Fix for #19437
		enableIcons(false);
		//Fix for issue #16278
		if (screenPlayer)
		{
			//invoking dispose() method which releases the resources in player
			screenPlayer.dispose();
			//removes player
			scrlgroup.removeElement(screenPlayer);
			//set screenPlayer instance to null
			screenPlayer=null;
		}
		displayPlayer(1273, 1017);
		if (isFullScreen && screenPlayer)
		{
			applicationType::desktop{
				screenPlayer.width=this.explicitWidth - 10;
				screenPlayer.height=this.explicitHeight - 40;
				//set the size of the container
				screenPlayer.processContainerInfo(this.explicitWidth + "_" + (this.explicitHeight - 30) + "_0_30");
			}
			applicationType::mobile{
				screenPlayer.width=this.explicitWidth - 10;
				screenPlayer.height=this.explicitHeight;
				//set the size of the container
				screenPlayer.processContainerInfo(this.explicitWidth + "_" + this.explicitHeight + "_0_0");
			}
		}
		//Fix for issues #16108 and #16110
		if(!lblSharingMessage.visible){
			scrlgroup.visible=true;
		}
	}
}
//Fix for issue #15318
private function showHide_clickHandler():void
{
	applicationType::desktop{
		if(isHideButtonControls)
		{
			isHideButtonControls = false;
			hgControls.width = 10;
			btnHideShow.source = showIcon;
			btnHideShow.toolTip="Show";
			hboxControl.visible=false;
			colapse.play();
			expand.stop(); 
		}
		else
		{
			btnHideShow.source = hideIcon;
			btnHideShow.toolTip="Hide";
			hgControls.width = 106;
			expand.play();
			colapse.stop(); 
			hboxControl.visible=true;
			isHideButtonControls = true;
		}
	}
}

/**
 * @public
 * Function used to make full screen view of desktop viewer
 *
 * @return void
 */
public function popOutDesktopSharingWindow():void{
	applicationType::desktop{
		if (!isPopOut){
			//Fix for #20126
			if(ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName){
				btnPopout.setStyle("icon", popoutIcon);
				btnPopout.toolTip="Pop-out";
				hgControls.width=106;
				setPopOutButtonVisibility(true);
				enableIcons(false);
			}
			else
			{
			//Fix for issue #19179 & #15662
			screenPlayer.setConfiguration(createConfiguration());
			desktopSharingWindow=new DesktopPlayer();
			desktopSharingWindow.desktopPlayerComp=this;
			desktopSharingWindow.width = 920;
			desktopSharingWindow.height = 710;
			//Fix for issue#15501
			setPlayerPositionAndSize(scrlgroup.height);
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.desktopSharingBox && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp.contains((this))){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp.removeElement(this);
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp, Constants.FULLSCREEN_MSG);
			isPopOut=true;
			desktopSharingWindow.open(true);
			desktopSharingWindow.maximize();
			//Fix for issue #15318
			btnPopout.setStyle("icon", popinIcon);
			btnPopout.toolTip="Pop-in";
			//Fix for issue #16306
			hgControls.width=70;
			setPopOutButtonVisibility(false);
			}
		}
		else{
			//Fix for issue #19179, #15662 & #20143
			screenPlayer.setConfiguration(createConfiguration());
			//Fix for issues #15386, #15417,#15418, #15541 & #15662
			if(ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName){
				//Fix for #20126
				desktopSharingWindow.close();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp.changeView(true);
			}
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unSetMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp);
			}
			//Fix for issues #15386, #15417,#15418 and #15541
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.desktopSharingBox && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp.contains((this))){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp.addElement(this);
			}
			desktopSharingWindow.close();
			isPopOut=false;
			//Fix for issue #15318
			btnPopout.setStyle("icon", popoutIcon);
			btnPopout.toolTip="Pop-out";
			hgControls.width=106;
			setPopOutButtonVisibility(true);
		}
	}
}
//Fix for issue #15318
public function setPopOutButtonVisibility(bool:Boolean):void
{
	applicationType::desktop{
		btnFullScreen.visible=bool;
		btnFullScreen.includeInLayout=bool;
		btnHideShow.visible=bool;
		btnHideShow.includeInLayout=bool;
	}
}

/**
 * Retrieves the bounds of the stage for fullscreen
 * @param null
 * @return Rectangle
 */
private function getScreenBounds():Rectangle
{
	var resultRect:Rectangle=new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
	//Fixed for issue #17508
	/*if (screenClass)
	{
		try
		{
			applicationType::desktop{
				var nativeWindowBounds:Rectangle=stage["nativeWindow"]["bounds"];
				var currentScreen:Object=screenClass["getScreensForRectangle"](nativeWindowBounds)[0];
				resultRect=currentScreen["bounds"];
			}
		}
		catch (e:Error)
		{
		}
	}*/
	return resultRect;
}

/**
 * Event handler for click event of btnFullScreen
 * @param event of type MouseEvent
 * @return void
 */
protected function createFullScreen():void
{
	//IF the desktop video is not in fullscreen
	if (!isFullScreen)
	{
		if (!systemManager.getTopLevelRoot())
		{
			return;
		}
		//gets screenbounds
		var screenBounds:Rectangle=getScreenBounds();
		
		//saves current width and height of the player
		beforeFullScreenInfo={parent: this.parent, x: this.x, y: this.y, explicitWidth: this.explicitWidth, explicitHeight: this.explicitHeight, percentWidth: this.percentWidth, percentHeight: this.percentHeight, isPopUp: this.isPopUp};
		//if this component is not popped up 
		if (!isPopUp)
		{
			//if this component is added to the instance of a class which 
			//implements IVisualElementContainer (flex 4 container)
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
			PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject, false, null, moduleFactory);
		}
		
		setLayoutBoundsSize(screenBounds.width, screenBounds.height, true);
		isFullScreen=true;
		this.explicitWidth=width;
		this.explicitHeight=height;
		if (screenPlayer && !isServerPan)
		{
			//set the size of the container
			applicationType::desktop{
					screenPlayer.processContainerInfo(this.explicitWidth + "_" + (this.explicitHeight - 30) + "_0_30");
			}
			applicationType::mobile{
				screenPlayer.processContainerInfo(this.explicitWidth + "_" + this.explicitHeight + "_0_0");
			}
		}
		else //User is using panning to the sharing user's mouse
		{
			//set the size of the container
			screenPlayer.processContainerInfo(this.explicitWidth + "_" + (this.explicitHeight - 30) + "_0_0");
		}
		applicationType::desktop{
			btnFullScreen.toolTip="Exit full screen";
		}
		fullScreenIcon =  exitFullScreen_Icon;
		setLayoutBoundsPosition(0, 0, true);
		this.validateNow();
		
		systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
		//change the stage display state to fullscreen
		systemManager.stage.displayState=StageDisplayState.FULL_SCREEN;
		//Set x and y position of SMLPlayer
		applicationType::desktop{
			screenPlayer.x=0;
			screenPlayer.y=0;
		}
		applicationType::mobile{
			if(scrlgroup != null){
				screenPlayer.width=scrlgroup.width - 30;
				screenPlayer.x=(scrlgroup.width - screenPlayer.width) / 2;
				screenPlayer.y=(scrlgroup.height - screenPlayer.height) / 2;
				screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
			}
		}
		//Fix for issue #15318
		setFullScreenButtonVisibility(false);
		applicationType::desktop{
			//Fix for issue #16307
			hgControls.width=70;
		}
	}
	else
	{
		this.stage.displayState=StageDisplayState.NORMAL;
		applicationType::mobile{
			if(FlexGlobals.topLevelApplication.slider!=null && FlexGlobals.topLevelApplication.isDrawerCompleted){
				FlexGlobals.topLevelApplication.slider.animate(false);
				FlexGlobals.topLevelApplication.sliderDrawer.stopLocalVideo();
			}
		}
	}
}
//Fix for issue #15318
private function setFullScreenButtonVisibility(bool:Boolean):void
{
	applicationType::desktop{
		//Fix for issue #5415
		btnFullScreen.setFocus();
		btnPopout.visible=bool;
		btnPopout.includeInLayout=bool;
		btnHideShow.visible=bool;
		btnHideShow.includeInLayout=bool;
	}
}

/**
 * Retrieves the definition of flash.display::Screen
 * This function is used for fullscreen video
 * @param null
 * @return Class
 */
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

/**
 * Event Listener for fullscreenvideo
 * @param event of type FullScreenEvent
 * @return void
 */
private function fullScreenEventHandler(event:FullScreenEvent):void
{
	if (event.fullScreen)
	{
		return;
	}
	//else if in normal mode
	isFullScreen=false;
	systemManager.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
	//applies the measures of the component before making this component fullscreen
	this.x=beforeFullScreenInfo.x;
	this.y=beforeFullScreenInfo.y;
	this.explicitWidth=beforeFullScreenInfo.explicitWidth;
	this.explicitHeight=beforeFullScreenInfo.explicitHeight;
	this.percentWidth=beforeFullScreenInfo.percentWidth;
	this.percentHeight=beforeFullScreenInfo.percentHeight;
	//Set tooltip and icon for btnFullScreen 
	applicationType::DesktopMobile{
		btnFullScreen.toolTip="View full screen";
		//set the icon to fullscreen
		fullScreenIcon = fullScreen_Icon;
	}
	//remove this object from popup and adds back to the last parent
	if (!beforeFullScreenInfo.isPopUp)
	{
		PopUpManager.removePopUp(this);
		
		if (beforeFullScreenInfo.parent is IVisualElementContainer)
			beforeFullScreenInfo.parent.addElementAt(this, beforeFullScreenInfo.childIndex);
		else
			beforeFullScreenInfo.parent.addChildAt(this, beforeFullScreenInfo.childIndex);
	}
	//resets beforeFullScreenInfo
	beforeFullScreenInfo=null;
	FlexGlobals.topLevelApplication.stage.scaleMode=StageScaleMode.NO_SCALE;
	//if shared screen is playing and the user is not using panning to the sharing user's mouse
	//Fix for issue #15565
	if (screenPlayer){
		if(!isServerPan){
			//change the size of player and video
			screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_5_10");
		}
		else //if shared screen is playing and the user is using panning to the sharing user's mouse
		{
			//change the size of player and video
			screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
		}
	}
	//Set screen player position
	calculatePlayerSize();
	//Fix for issue #15423
	setFullScreenButtonVisibility(true);
	applicationType::desktop{
		hgControls.width=106;
	}
	invalidateSize();
	invalidateDisplayList();
	
}
applicationType::DesktopMobile{
	/**
	 * Event handler for click event of btnPanning
	 * @param event of type MouseEvent
	 * @return void
	 */
	protected function btnPanning_clickHandler(event:MouseEvent=null):void
	{
		//toggles the server panning of the stream thats getting played				
		if (!isServerPan)
		{
			isServerPan=true;
			//Fix for issue #15842
			btnPanScreen.toolTip="Exit pan screen";
			//Fix for issue #15838
			panScreenIcon =  exitPanScreen_Icon;
		}
		else
		{
			isServerPan=false;
			//Fix for issue #15842
			btnPanScreen.toolTip="Pan Screen";
			//Fix for issue #15838
			panScreenIcon =  panScreen_Icon;
			if (!isFullScreen)
			{
				//changing the size of player to its original width and height
				screenPlayer.height=normalHeight;
				applicationType::mobile{
					setTimeout(setScreenPlayerPosition,300);
				}
			}
			else
			{
				//changing the size of player to fullscreensize
				screenPlayer.height=this.explicitHeight - 40;
				//Fix for issue #15840
				applicationType::desktop{
					screenPlayer.width = this.explicitWidth -10;
					//changing the size of video to fullscreensize
					screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
				}
				applicationType::mobile{
					//screenPlayer.width = this.width;
					//screenPlayer.width=scrlgroup.width+30;
					//changing the size of video to fullscreensize'
					//screenPlayer.processContainerInfo(screenPlayer.width + "_" + this.explicitHeight + "_0_0");
					//screenPlayer.processContainerInfo(this.explicitWidth + "_" + this.explicitHeight + "_0_30");
					screenPlayer.height=normalHeight;
					screenPlayer.width = this.explicitWidth+100;
					screenPlayer.processContainerInfo(screenPlayer.width + "_" + screenPlayer.height + "_0_0");
				}
				
			}
		}
		screenPlayer.toggleServerPan();
	}
	/**
	 * @protected
	 *
	 * To show tool-tip
	 *
	 * @param event of MouseEvent
	 * @return void
	 */
	private function toolTipHandler(event:MouseEvent):void
	{
		var toolTip:MobileToolTip=MobileToolTip.open(event.target.toolTip.toString(), event.currentTarget as DisplayObject);
		toolTip.handleToolTipPosition(event.currentTarget as DisplayObject);
	}
}