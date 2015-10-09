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
 * File			: ClassroomLayoutViewHandler.as
 * Module		: Classroom
 * Developer(s)	: Salil George, Ganesan A, Jeevanantham N
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 * 
 * ClassroomLayoutViewHandler.as contains business logic for ClassroomLayout view
 */

/**
 * Importing MessageBox, MultipleUserInteractionPreference and VideoPreference components
 */

import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.user.ChangePasswordCompMobile;
import edu.amrita.aview.core.gclm.vo.UserVO;
import edu.amrita.aview.core.shared.components.mobileComponents.toolTip.MobileToolTip;
import edu.amrita.aview.core.shared.events.mobileCustomEvents.VideoSettingPreferenceEvent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SyncEvent;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.ui.Keyboard;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.ResizeEvent;
import mx.graphics.SolidColor;
import mx.managers.PopUpManager;

import spark.components.Label;
import spark.components.ViewMenu;
import spark.components.ViewMenuItem;
import spark.events.IndexChangeEvent;
import spark.primitives.Rect;

import views.ChatView;
import views.ConsolidatedView;
import views.DocumentView;
import views.Viewer3D;
import views.WhiteBoardView;
import views.components.customComboBox.MultipleUserInteractionPreference;
import views.components.customComboBox.VideoPreference;
import views.toolSets.CollaborationTools;

/**
 * This variable holds currently loaded module name
 */
[Bindable]
public var viewTitle:String=new String();

/**
 * This varibale holds user name of logged in user
 */
[Bindable]
private var selectedViewer:String;
/**
 * This varibale holds user name of selected viewer
 */
[Bindable]
private var userName:String;

/**
 * This variable holds exitMessagebox instance
 */
private var exitMessageBox:MessageBox;
/**
 * This variable holds helpMessageBox instance
 */
private var helpMessageBox:MessageBox;
//private var isActionButtonCliked:Boolean = false;
/**
 * Used to set the preference icon for Preference button.
 */
[Bindable]
[Embed(source="/views/toolSets/assets/preferance(30x30).png")]
public var preferenceIcon:Class;
/**
 * Used to set the video setting icon for Video Setting menu.
 */
[Embed(source="/views/toolSets/assets/Settings_24x24.png")]
public var videoSettingIcon:Class;
/**
 * Used to set the multiple user interaction icon for Multiple User Interaction menu.
 */
[Embed(source="/views/toolSets/assets/mui_users.png")]
public var muiIcon:Class;

private var isSliderAddedtoStage:Boolean = false;

/**
 * @private
 * 
 * To add controlbuttons to colaborationBtnsContainer
 * Add users view to viewContainer 
 * Add EventListeners
 *
 * @param event of FlexMouseEvent
 * @return void
 */
private function initClsLayout():void
{
	//Add controlbuttons to colaborationBtnsContainer
	colaborationBtnsContainer.addElement(FlexGlobals.topLevelApplication.colbTools);
	addlayoutBtnControls();
	// For future reference
/*	userName=ClassroomContext.userVO.fname + ClassroomContext.userVO.lname;
	//Set users view percent width and height
	FlexGlobals.topLevelApplication.users.percentHeight=100;
	FlexGlobals.topLevelApplication.users.percentWidth=100;
	//To intialize the whiteboard module,If document sharing module is disabled.
	//otherwise load user module
	if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
		if (!ClassroomContext.IS_DOCUMENT_SHARING_ENABLED)
		{
			loadWhiteBoardModule();
		}
		else
		{
			FlexGlobals.topLevelApplication.users.percentHeight=100;
			FlexGlobals.topLevelApplication.users.percentWidth=100;
			viewContainer.percentHeight=100;
			viewContainer.percentWidth=100;
			viewContainer.addElement(FlexGlobals.topLevelApplication.users);
			if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
				FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 5;
			}
			//Add usersList and user action buttons to users view
			FlexGlobals.topLevelApplication.users.userListGroup.addElement(FlexGlobals.topLevelApplication.mainApp.lstUsers);
			FlexGlobals.topLevelApplication.users.chatContainer.addElement(FlexGlobals.topLevelApplication.chat);
		}
	}*/
	stage.addEventListener("keyDown", handleButtons, false, 1);
	FlexGlobals.topLevelApplication.addEventListener(MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS, FlexGlobals.topLevelApplication.connectSelectedModule);
}
/**
 * @private
 * 
 * To open/close view menu
 *
 * @param event of KeyboardEvent
 * @return void
 */
private function handleButtons(event:KeyboardEvent):void
{
	//If user click on back button, prevent application that navigates to previous view
	if (event.keyCode == Keyboard.BACK)
	{
		if (FlexGlobals.topLevelApplication.viewMenuOpen)
		{
			FlexGlobals.topLevelApplication.viewMenuOpen=false;
		}
		event.preventDefault();
	}
	if (event.keyCode == Keyboard.MENU)
	{
		btnDrawer.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		event.preventDefault();
	}
}
/**
 * @private
 * 
 * To add event listeners for collaboration buttons
 *
 * @param event of FlexMouseEvent
 * @return void
 */
private function addlayoutBtnControls():void
{
	if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
		FlexGlobals.topLevelApplication.colbTools.actionBtnGrp.addEventListener(MouseEvent.CLICK, allInOneChangeView);
	}
	else{
		FlexGlobals.topLevelApplication.colbTools.tabs.addEventListener(IndexChangeEvent.CHANGE, changeView);
	}

}
/**
 * @protected
 * 
 * To display the selected module
 *
 * @param event of FlexMouseEvent
 * @return void
 */
protected function changeView(event:IndexChangeEvent = null):void
{
	//To close callout components , remove all elements from viewContainer and set percent height and width for viewContainer
	closeModulesCallout();
	FlexGlobals.topLevelApplication.selectedIndex=99;
	viewContainer.removeAllElements();
	viewContainer.percentHeight=100;
	viewContainer.percentWidth=100;
	colaborationBtnsContainer.height = 40;
	FlexGlobals.topLevelApplication.contentWidth=this.width - FlexGlobals.topLevelApplication.colbTools.width;
	FlexGlobals.topLevelApplication.contentHeight=viewContainer.height;
	switch (event.target.selectedItem.label)
	{
		//If target id is whiteboard,add whiteboard view to viewContainer
		case Constants.BTN_WHITEBOARD:
			FlexGlobals.topLevelApplication.selectedModuleIndex=1;
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadWhiteBoardModule();
			break;
		//if target id is document,add document view to viewContainer and enable all modules button except document button
		case Constants.BTN_DOCUMENT:
			FlexGlobals.topLevelApplication.selectedModuleIndex=0;
			loadDocModule();
			break;
		//If target id is user,add user view to viewContainer
		case Constants.BTN_USER:
			FlexGlobals.topLevelApplication.selectedModuleIndex=8;
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadUsersModule();
			break;
		//if target id is video,add video view to viewContainer and enable all modules button except video button
		case Constants.BTN_VIDEO:
			FlexGlobals.topLevelApplication.selectedModuleIndex=6;
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			//if video settings is ON add video view, otherwise add user view to viewContainer
			loadVideoModule();
			break;
		//if target id is threeD,add threeD view to viewContainer and enable all modules button except threeD button
		case Constants.BTN_THREED:
			FlexGlobals.topLevelApplication.selectedModuleIndex=2;
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadThreedModule();
			break;
		case Constants.BTN_DESKTOP_SHARING:
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			FlexGlobals.topLevelApplication.selectedModuleIndex=3;
			loadDesktopharingModule();
			break;
		case Constants.BTN_QUESTION:
			FlexGlobals.topLevelApplication.selectedModuleIndex=7;
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadQuestionModule();
			break;
	}
}
/**
 * @private
 * 
 * Function to load the modules in All-in-one mode
 * 
 * @param event of MouseEvent
 * @return void
 */
private function allInOneChangeView(event:MouseEvent = null):void
{
	if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
		if(FlexGlobals.topLevelApplication.selectedModuleIndex == 0){
			loadDocModule();
		}else if(FlexGlobals.topLevelApplication.selectedModuleIndex == 1){
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadWhiteBoardModule();
		}else if(FlexGlobals.topLevelApplication.selectedModuleIndex == 2){
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadThreedModule();
		}else if(FlexGlobals.topLevelApplication.selectedModuleIndex == 3){
			//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
			loadDesktopharingModule();
		}else if(FlexGlobals.topLevelApplication.selectedModuleIndex == 10){
			startPublishVideo();
		}else if(FlexGlobals.topLevelApplication.selectedModuleIndex == 6){
			loadDocModule();
		}
	}
}
/**
 * @private
 * 
 * To show Document, Chat and Userlist in consolidate view
 *
 * @param null
 * @return void
 */
private function setConsolidateModuleSize():void
{
	//Add consolidated view to viewContainer
	FlexGlobals.topLevelApplication.consolidated.percentHeight=100;
	FlexGlobals.topLevelApplication.consolidated.percentWidth=100;
	viewContainer.addElement(FlexGlobals.topLevelApplication.consolidated);
	if(FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length >= 1)
	{
		FlexGlobals.topLevelApplication.mainApp.addSelectedViewerVideoToPanel(null,true);
	}
	else{
		FlexGlobals.topLevelApplication.chat.percentHeight=100;
		FlexGlobals.topLevelApplication.chat.percentWidth=100;
		FlexGlobals.topLevelApplication.consolidated.chatContainer.addElement(FlexGlobals.topLevelApplication.chat);
		if (FlexGlobals.topLevelApplication.chat.chatToolSet)
		{
			FlexGlobals.topLevelApplication.chat.chatToolSet.includeInLayout=false;
			FlexGlobals.topLevelApplication.chat.chatToolSet.visible=false;
			FlexGlobals.topLevelApplication.chat.chatClearTool.includeInLayout=false;
			FlexGlobals.topLevelApplication.chat.chatClearTool.visible=false;
		}
	}
	if(FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && !FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)
	{
		FlexGlobals.topLevelApplication.users.percentHeight=100;
		FlexGlobals.topLevelApplication.users.percentWidth=100;
		FlexGlobals.topLevelApplication.consolidated.videoContainer.addElement(FlexGlobals.topLevelApplication.mainApp.lstUsers);
	}
	else
	{
		FlexGlobals.topLevelApplication.mainApp.startPresentersStream();
	}

	//if document module is enabled, add document view to consolidated view's documentContainer and disable document control buttons
	//Otherwise add "Document module is hidden" label to consolidated view's documentContainer
	if (ClassroomContext.IS_DOCUMENT_SHARING_ENABLED)
	{
		FlexGlobals.topLevelApplication.doc.percentHeight=100;
		FlexGlobals.topLevelApplication.doc.percentWidth=100;
		if (FlexGlobals.topLevelApplication.doc.documentTool)
		{
			FlexGlobals.topLevelApplication.doc.documentTool.includeInLayout=false;
			FlexGlobals.topLevelApplication.doc.documentTool.visible=false;
		}
		FlexGlobals.topLevelApplication.docComp.p2fCanvas.horizontalCenter=0;
		//To set visibility of documentBorder and navigationControl buttons as false and assign docCanvas width for center alignment.
		if (FlexGlobals.topLevelApplication.docComp.p2fContainer.content != null && FlexGlobals.topLevelApplication.docComp.p2fContainer.visible == true)
		{
			FlexGlobals.topLevelApplication.docComp.documentBorder.visible=false;
			FlexGlobals.topLevelApplication.docComp.navigationControl.visible = false;
			if(FlexGlobals.topLevelApplication.consolidated.documentContainer.width!=0)
			{
				FlexGlobals.topLevelApplication.consolidated.documentFillColor.visible = false;
				FlexGlobals.topLevelApplication.consolidated.documentFillColor.includeInLayout = false;
				FlexGlobals.topLevelApplication.docComp.docCanvas.width = FlexGlobals.topLevelApplication.consolidated.documentContainer.width - 10;
			}
			FlexGlobals.topLevelApplication.consolidated.documentContainer.addElement(FlexGlobals.topLevelApplication.doc);
		}
		else
		{
			//CBMS:
//			FlexGlobals.topLevelApplication.consolidated.documentFillColor.visible = true;
//			FlexGlobals.topLevelApplication.consolidated.documentFillColor.includeInLayout = true;
		}
	}
	else
	{
		FlexGlobals.topLevelApplication.consolidated.documentContainer.removeAllElements();
		var documentHidelabel:Label=new Label();
		documentHidelabel.text="Document module is hidden";
		documentHidelabel.percentHeight=100;
		documentHidelabel.percentWidth=100;
		documentHidelabel.x=this.width / 6;
		documentHidelabel.y=this.height / 2.2;
		var borderRect:Rect=new Rect();
		var solid:SolidColor=new SolidColor(0xFFFFFF, 1.0);
		borderRect.fill=solid;
		borderRect.percentWidth=100;
		borderRect.percentHeight=100;
		FlexGlobals.topLevelApplication.consolidated.documentContainer.addElement(borderRect);
		FlexGlobals.topLevelApplication.consolidated.documentContainer.addElement(documentHidelabel);
	}
}
/**
 * @private
 * 
 * To add and remove video module at runtime
 *
 * @param event of VideoSettingPreferenceEvent
 * @return void
 */
private function videoSettingChange(event:VideoSettingPreferenceEvent):void
{
	//if user "ON" the video settings, add video module to application and publishing all incoming videos.
	//Otherwise remove video module from application and stop all incoming video
	var btnVideoModule :IVisualElement;
	if (event.type == VideoSettingPreferenceEvent.VIDEO_SETTING_ON)
	{
		FlexGlobals.topLevelApplication.isVideoPrefrenceON=true;
		FlexGlobals.topLevelApplication.videoPrefrenceOnLbl = Constants.VIDEO_PREF_OFF;
		
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
			btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
			btnVideoModule.visible = true;
			btnVideoModule.includeInLayout = true;
		}else{
			FlexGlobals.topLevelApplication.isVideoTabVisible = false;
		}
		FlexGlobals.topLevelApplication.videoPreference.messageText.text=Constants.VIDEO_ON_MESSAGE;
		if(FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)
		{
			FlexGlobals.topLevelApplication.mainApp.startPresentersStream();
		}
		for (var i:int=0; i < FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.length; i++){
			FlexGlobals.topLevelApplication.mainApp.startSelectedViewersStream(FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails[i].userName);
		}
		FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails = null;
	}
	else
	{
		//To stop publishing video to server.
		if(videoStartStopIcon == stopVideoIcon){
			btnLocalVideo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		FlexGlobals.topLevelApplication.isVideoPrefrenceON=false;
		FlexGlobals.topLevelApplication.videoPrefrenceOnLbl = Constants.VIDEO_PREF_ON;
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
			btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
			btnVideoModule.visible = false;
			btnVideoModule.includeInLayout = false;
			//To change tab as per Moderator current tab
			FlexGlobals.topLevelApplication.setActiveModule(false,22);
		}
		FlexGlobals.topLevelApplication.videoPreference.messageText.text=Constants.VIDEO_OFF_MESSAGE;
		FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails=new ArrayCollection();
		//Store selectedViewer details to another array for reuse
		for (var i:int=0; i < FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length; i++){
			FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.addItemAt(FlexGlobals.topLevelApplication.mainApp.selectedViewersData[i], i);
		}
		//To chechk that user started his/her video.
		if (FlexGlobals.topLevelApplication.videoComp.videoPublishStatus)
		{
			FlexGlobals.topLevelApplication.videoComp.btnLocalVideo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			FlexGlobals.topLevelApplication.isVideoON=true;
		}
		//To stop presenter stream
		if(FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing){
			FlexGlobals.topLevelApplication.mainApp.stopPresentersStream();
		}
		//To selected viewer(s) stream
		for(var j:int=0; j<FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length; j++){
			if(FlexGlobals.topLevelApplication.mainApp.getUserSO(FlexGlobals.topLevelApplication.mainApp.selectedViewersData[j].userName).isVideoPublishing){
				FlexGlobals.topLevelApplication.mainApp.stopSelectedViewersStream(FlexGlobals.topLevelApplication.mainApp.selectedViewersData[j].userName);
			}
		}
		
		//To remove the Hand raise.
		if(btn_handrelease.visible && btn_handrelease.includeInLayout){
			onClickHandraiseRelease();
		}
		//To stop local video
		FlexGlobals.topLevelApplication.sliderDrawer.stopLocalVideo();
	}
	FlexGlobals.topLevelApplication.videoPreference.close();
	//PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.videoPreference);
	FlexGlobals.topLevelApplication.mainApp.usersSyncHandler(new SyncEvent(SyncEvent.SYNC));
}
/**
 * @private
 * 
 * To close the application
 *
 * @param event of MessageBoxEvent
 * @return void
 */
private function exitApplication(event:MessageBoxEvent):void
{
	if (event.type == MessageBoxEvent.MESSAGEBOX_YES)
	{
		FlexGlobals.topLevelApplication.exitClassRoom(Constants.MENU_CLOSE);
	}
}
/**
 * @private
 * 
 * To close the document, whiteboard and video module's callouts
 *
 * @param null
 * @return void
 */
private function closeModulesCallout():void
{
	if (FlexGlobals.topLevelApplication.wbComp)
	{
		//To close the softkeyboard
		if (FlexGlobals.topLevelApplication.wbComp.isSoftKeyboardActivate)
		{
			FlexGlobals.topLevelApplication.wbComp.textComp.txtToolArea.setFocus();
			FlexGlobals.topLevelApplication.wbComp.isSoftKeyboardActivate=false;
		}
		FlexGlobals.topLevelApplication.wbComp.closeAllOpenPannels();
		//To close the text tool when presenter changes the collaboration status, if text tool has opened.
		if (FlexGlobals.topLevelApplication.wbComp.textComp)
		{
			if (FlexGlobals.topLevelApplication.wbComp.textComp.isPopUp)
			{
				FlexGlobals.topLevelApplication.wbComp.textComp.updateMsg(true);
				FlexGlobals.topLevelApplication.wbComp.txtAreaEdit=false;
			}
		}
	}
	//To close the document info and fileManager call-out(s).
	if (FlexGlobals.topLevelApplication.docComp)
	{
		//FlexGlobals.topLevelApplication.docComp.closeInfoCallout();
		if (FlexGlobals.topLevelApplication.docComp.fileManager)
		{
			if (FlexGlobals.topLevelApplication.docComp.fileManager.isOpen)
			{
				FlexGlobals.topLevelApplication.docComp.fileManager.close();
			}
		}
		if (FlexGlobals.topLevelApplication.docTool && FlexGlobals.topLevelApplication.docTool.docMenuComp){
			if (FlexGlobals.topLevelApplication.docTool.docMenuComp.isOpen){
				FlexGlobals.topLevelApplication.docTool.docMenuComp.close();
				if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
					FlexGlobals.topLevelApplication.docTool.btnPresenterMenu.enabled=true;
				}else{
					//FlexGlobals.topLevelApplication.docTool.btnViewerMenu.enabled=true;
				}
			}
		}
	}

	//To close selected viewer call-out.
	if (FlexGlobals.topLevelApplication.videoComp.selectedViewer) 
	{
		if (FlexGlobals.topLevelApplication.videoComp.selectedViewer.isOpen)
		{
			FlexGlobals.topLevelApplication.videoComp.selectedViewer.close();
			FlexGlobals.topLevelApplication.videoComp.btnSelectViewerVideo.enabled=true;
		}
	}
	//To close local video call-out.
	if (FlexGlobals.topLevelApplication.videoComp.localVideo)
	{
		if (FlexGlobals.topLevelApplication.videoComp.localVideo.isOpen)
		{
			FlexGlobals.topLevelApplication.videoComp.localVideo.close();
			FlexGlobals.topLevelApplication.videoComp.btnLocalVideo.enabled=true;
		}
	}
	//To close video-setting call-out.
	if (FlexGlobals.topLevelApplication.videoComp.setting)
	{
		if (FlexGlobals.topLevelApplication.videoComp.setting.isOpen)
		{
			FlexGlobals.topLevelApplication.videoComp.setting.close();
		}
	}
}
/**
 * @private
 * 
 * To view whiteboard module
 *
 * @param null
 * @return void
 */
private function loadWhiteBoardModule():void
{
	viewContainer.removeAllElements();
	if(FlexGlobals.topLevelApplication.screenTypes != Constants.SCREENTYPE_ALLINONE){
		viewContainer.percentHeight=100;
		viewContainer.percentWidth=100;
		colaborationBtnsContainer.height = 40;
		
		//To enbale whiteboard tools
		if(FlexGlobals.topLevelApplication.wbView.whiteBoardToolSet != null){
			FlexGlobals.topLevelApplication.wbView.whiteBoardToolSet.enabled = true;
			FlexGlobals.topLevelApplication.wbView.whiteBoardToolSet.visible = true;
			FlexGlobals.topLevelApplication.wbView.whiteBoardToolSet.includeInLayout = true;
		}
	}
	if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
	{
		FlexGlobals.topLevelApplication.setActiveWindowInSO(1);
	}
	viewContainer.addElement(FlexGlobals.topLevelApplication.wbView);
}
private function loadDocModule():void
{
	viewContainer.removeAllElements();
	FlexGlobals.topLevelApplication.doc.percentHeight=100;
	FlexGlobals.topLevelApplication.doc.percentWidth=100;
	viewContainer.addElement(FlexGlobals.topLevelApplication.doc);
	if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
		if(!FlexGlobals.topLevelApplication.docComp.pptLoaded){
			//To change document height for individual screen
			FlexGlobals.topLevelApplication.docComp.p2fCanvas.width = (FlexGlobals.topLevelApplication.width/100)*60;
			FlexGlobals.topLevelApplication.docComp.p2fCanvas.height = (FlexGlobals.topLevelApplication.height - FlexGlobals.topLevelApplication.actionBar.height);
			FlexGlobals.topLevelApplication.docComp.onDocResize();
		}//MOBILE_ISPRING:
		/*else{
			FlexGlobals.topLevelApplication.docComp.showStageWebView();
		}*/
	}else{
		if(!FlexGlobals.topLevelApplication.docComp.pptLoaded){
			//To change document height for individual screen
			FlexGlobals.topLevelApplication.docComp.p2fCanvas.width = (FlexGlobals.topLevelApplication.width/100)*89;
			FlexGlobals.topLevelApplication.docComp.p2fCanvas.height = (FlexGlobals.topLevelApplication.height - (FlexGlobals.topLevelApplication.actionBar.height+FlexGlobals.topLevelApplication.collaborationBtnsHeight));
			FlexGlobals.topLevelApplication.docComp.onDocResize();
		}//MOBILE_ISPRING:
		/*else{
			FlexGlobals.topLevelApplication.docComp.showStageWebView();
		}*/
	}
	FlexGlobals.topLevelApplication.docComp.p2fCanvas.horizontalCenter=0;
	FlexGlobals.topLevelApplication.docComp.p2fCanvas.verticalCenter=0;
	if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
	{
		FlexGlobals.topLevelApplication.setActiveWindowInSO(0);
	}
	//set visibility of documentBorder and navigationControl as true.
	if (FlexGlobals.topLevelApplication.docComp.p2fContainer!= null && FlexGlobals.topLevelApplication.docComp.p2fContainer.content != null && FlexGlobals.topLevelApplication.docComp.p2fContainer.visible == true)
	{
		FlexGlobals.topLevelApplication.docComp.documentBorder.visible=true;
		if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			FlexGlobals.topLevelApplication.docComp.navigationControl.visible = true;
		}
	}else{
		FlexGlobals.topLevelApplication.docComp.documentBorder.visible=false;
	}
	if(!FlexGlobals.topLevelApplication.doc.isAnimatedFileInfoDisplayed)
	{
		FlexGlobals.topLevelApplication.doc.checkAnimatedFile();
	}
}
private function loadVideoModule():void{
	//if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
		viewContainer.removeAllElements();
	//}
	if (FlexGlobals.topLevelApplication.isVideoPrefrenceON)
	{
		FlexGlobals.topLevelApplication.videoComp.percentHeight=100;
		FlexGlobals.topLevelApplication.videoComp.percentWidth=100;
		viewContainer.addElement(FlexGlobals.topLevelApplication.videoComp);
		if(FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)
		{
			FlexGlobals.topLevelApplication.mainApp.startPresentersStream();
			setTimeout(FlexGlobals.topLevelApplication.videoComp.setPresenterWidth,2000,FlexGlobals.topLevelApplication.width);
		}
		//To display the CPU optimize message , when presenter selects more than one user for interaction.
		if ((FlexGlobals.topLevelApplication.isMUISelected || FlexGlobals.topLevelApplication.mainApp.isMaximumSelectedViewer) && FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length > 1)
		{
			if (!FlexGlobals.topLevelApplication.mainApp.isMessageDisplayed && FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length > 1)
			{
				setTimeout(FlexGlobals.topLevelApplication.mainApp.cpuOptimizeMessage, 1000);
			}
		}
		if(FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length >= 1)
		{
			FlexGlobals.topLevelApplication.callLater(intializeSelectedViewerVideo);
		}
	}
	else //if user changed video settings to OFF 
	{
		loadUsersModule();
	}
}
private function intializeSelectedViewerVideo():void{
	if(FlexGlobals.topLevelApplication.mainApp.studentVideo != null){
		FlexGlobals.topLevelApplication.mainApp.studentVideo.clear();
	}
	FlexGlobals.topLevelApplication.mainApp.addSelectedViewerVideoToPanel(null,true);
	FlexGlobals.topLevelApplication.videoComp.setStudentWidth(FlexGlobals.topLevelApplication.width);
}
private function loadThreedModule():void{
	viewContainer.removeAllElements();
	colaborationBtnsContainer.height = 40;
	if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
	{
		FlexGlobals.topLevelApplication.setActiveWindowInSO(2);
	}
	FlexGlobals.topLevelApplication.viewer3D.percentHeight=100;
	FlexGlobals.topLevelApplication.viewer3D.percentWidth=100;
	viewContainer.addElement(FlexGlobals.topLevelApplication.viewer3D);
	if (!FlexGlobals.topLevelApplication.viewer3DComp.viewer3DSWC.flare3DEngineInstance)
	{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			FlexGlobals.topLevelApplication.viewer3DComp.viewer3DSWC.addComponent();
		}
		else if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && !FlexGlobals.topLevelApplication.viewer3DComp.viewer3DSWC.lateUser)
		{
			FlexGlobals.topLevelApplication.viewer3DComp.viewer3DSWC.addComponent();
		}
	}
}
private function loadDesktopharingModule():void{
	//if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_ALLINONE){
		viewContainer.removeAllElements();
	//}
	FlexGlobals.topLevelApplication.sharing.percentWidth = 100;
	FlexGlobals.topLevelApplication.sharing.percentHeight = 100;
	viewContainer.addElement(FlexGlobals.topLevelApplication.sharing);
	FlexGlobals.topLevelApplication.mainApp.init_Desktop();
}
private function loadQuestionModule():void{
	FlexGlobals.topLevelApplication.questComponent.percentHeight=100;
	FlexGlobals.topLevelApplication.questComponent.percentWidth=100;
	FlexGlobals.topLevelApplication.questComponent.questionDataGrid.percentHeight = 82;
	FlexGlobals.topLevelApplication.questComponent.questionDataGrid.percentWidth = 100;
	FlexGlobals.topLevelApplication.questComponent.questionActionGroup.percentHeight = 18;
	FlexGlobals.topLevelApplication.questComponent.questionActionGroup.percentWidth = 100;
	FlexGlobals.topLevelApplication.questComponent.questionInput.percentWidth =70;
	FlexGlobals.topLevelApplication.questComponent.postQuestionButton.percentWidth = 15;
	FlexGlobals.topLevelApplication.questComponent.voteQuestionButton.percentWidth = 15;
	viewContainer.addElement(FlexGlobals.topLevelApplication.questComponent);
}
/**
 * @private
 *
 * To view userlist and enable all modules button except users button
 *
 * @param null
 * @return void
 */
private function loadUsersModule():void
{
	FlexGlobals.topLevelApplication.users.percentHeight=100;
	FlexGlobals.topLevelApplication.users.percentWidth=100;
	viewContainer.percentHeight=100;
	viewContainer.percentWidth=100;
	colaborationBtnsContainer.height = 40;
	viewContainer.addElement(FlexGlobals.topLevelApplication.users);
	FlexGlobals.topLevelApplication.users.userListGroup.addElement(FlexGlobals.topLevelApplication.mainApp.lstUsers);
	FlexGlobals.topLevelApplication.users.chatContainer.addElement(FlexGlobals.topLevelApplication.chat);
	//Set visibility of clear tool only for moderator
	if (FlexGlobals.topLevelApplication.chat.chatToolSet)
	{
		FlexGlobals.topLevelApplication.chat.chatToolSet.includeInLayout=true;
		FlexGlobals.topLevelApplication.chat.chatToolSet.visible=true;
		if (ClassroomContext.isModerator)
		{
			FlexGlobals.topLevelApplication.chat.chatClearTool.includeInLayout=true;
			FlexGlobals.topLevelApplication.chat.chatClearTool.visible=true;
		}
	}
	FlexGlobals.topLevelApplication.colbTools.btnUserModule.filters=null;
	//FlexGlobals.topLevelApplication.removeEventListener(Event.ENTER_FRAME, FlexGlobals.topLevelApplication.blinkUserTab);
	if (FlexGlobals.topLevelApplication.mainApp.lstUsers.selectedItem != null)
	{
		FlexGlobals.topLevelApplication.callLater(setSelectedIndexForUserlist);
	}
	if(FlexGlobals.topLevelApplication.chatComp!=null){
		FlexGlobals.topLevelApplication.chatComp.enableStyle();
	}
}
/**
 * @private
 *
 * To set selection for userlist
 *
 * @param null
 * @return void
 */
private function setSelectedIndexForUserlist():void
{
	if (FlexGlobals.topLevelApplication.mainApp.lstUsers.lastRollOverIndex < 0)
	{
		FlexGlobals.topLevelApplication.mainApp.lstUsers.selectedIndex=0;
	}
	else
	{
		FlexGlobals.topLevelApplication.mainApp.lstUsers.selectedIndex=FlexGlobals.topLevelApplication.mainApp.lstUsers.lastRollOverIndex;
	}
	FlexGlobals.topLevelApplication.mainApp.actionButtons.setupUserActionButtonsOnSelection();
}
/**
 * @private
 *
 * To download and view the help document
 *
 * @param event of MessageBoxEvent
 * @return void
 */
private function downloadHelpContent(event:MessageBoxEvent):void
{
	if (event.type == MessageBoxEvent.MESSAGEBOX_OK)
	{
		FlexGlobals.topLevelApplication.helpDocumentDownload();
	}
}
/**
 * @protected
 *
 * To show tool-tip
 *
 * @param event of MouseEvent
 * @return void
 */
protected function classRoomLayoutTooltipHandler(event:MouseEvent):void
{
	var docTooltip:MobileToolTip=MobileToolTip.open(event.target.toolTip.toString(), event.currentTarget as DisplayObject);
	docTooltip.handleToolTipPosition(event.currentTarget as DisplayObject);
}

private function logoutApplication(event:MouseEvent):void{
	if(event.target.label == "Logout"){
		MessageBox.show("Are you sure you want to logout","Confirmation",MessageBox.MB_YESNO, this, logoutConfirmHandler, logoutConfirmHandler, MessageBox.IC_INFO);
	}
}
private function exitAviewApplication(event:MouseEvent):void{
	if(event.target.text == "Exit session"){
		MessageBox.show("Are you sure you want to exit from this session","Confirmation",MessageBox.MB_YESNO, this, exitSessionConfirmHandler, exitSessionConfirmHandler, MessageBox.IC_INFO);
	}
}
private function changePassWordHandler(event:MouseEvent):void{
	var user:UserVO=ClassroomContext.userVO;
	if (user != null){
		FlexGlobals.topLevelApplication.mainApp.changePasswordComp=new ChangePasswordCompMobile;
		FlexGlobals.topLevelApplication.mainApp.changePasswordComp.open(this);
		FlexGlobals.topLevelApplication.mainApp.changePasswordComp.isPopUp=true;
		PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.mainApp.changePasswordComp);
		FlexGlobals.topLevelApplication.mainApp.changePasswordComp.init(user);
	}
}
private function newsHandler(event:MouseEvent):void
{
	var linkName:String = "http://aview.in/news";
	var url1:URLRequest=new URLRequest(linkName);
	navigateToURL(url1, "_blank");
}
private function aboutUsHandler(event:MouseEvent):void
{
	var linkName:String = "http://aview.in/who-we-are";
	var url1:URLRequest=new URLRequest(linkName);
	navigateToURL(url1, "_blank");
}
private function contactUsHandler(event:MouseEvent):void
{
	var linkName:String = "http://aview.in/contact-us";
	var url1:URLRequest=new URLRequest(linkName);
	navigateToURL(url1, "_blank");
}
private function aboutAviewHandler(event:MouseEvent):void
{
	var linkName:String = "http://aview.in/aview";
	var url1:URLRequest=new URLRequest(linkName);
	navigateToURL(url1, "_blank");
}
private function upComingEventsHandler(event:MouseEvent):void
{
	var linkName:String = "http://aview.in/upcoming-events";
	var url1:URLRequest=new URLRequest(linkName);
	navigateToURL(url1, "_blank");
}
private function showHelpDocument(event:MouseEvent):void{
	helpMessageBox=MessageBox.show("Click OK to download help file.You may need PDF viewer to view the help content.", "Help Information", MessageBox.MB_OKCANCEL, this, downloadHelpContent, downloadHelpContent, MessageBox.IC_INFO);
}
private function refreshAllVideos(event:MouseEvent):void{
	FlexGlobals.topLevelApplication.mainApp.refreshVideo();
}
private function performanceHandler(event:Event = null):void{
	FlexGlobals.topLevelApplication.videoPreference=new VideoPreference(videoSettingChange);
	//If user is not a selected viewer, open video setting component.
	//Otherwise shows information message
	if (!FlexGlobals.topLevelApplication.mainApp.isSelectedUser(ClassroomContext.userVO.userName)){
		if(event!= null){
			FlexGlobals.topLevelApplication.videoPreference.videoPreferenceToggleSwitch.enabled=true;
			FlexGlobals.topLevelApplication.videoPreference.open(this);
			FlexGlobals.topLevelApplication.videoPreference.width=FlexGlobals.topLevelApplication.width / 2.5;
			FlexGlobals.topLevelApplication.videoPreference.videoPreferenceToggleSwitch.selected=FlexGlobals.topLevelApplication.isVideoPrefrenceON ? true : false;
			FlexGlobals.topLevelApplication.videoPreference.messageText.text=FlexGlobals.topLevelApplication.isVideoPrefrenceON ? Constants.VIDEO_ON_MESSAGE : Constants.VIDEO_OFF_MESSAGE;
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.videoPreference);
		}
		if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
			var btnVideoModule :IVisualElement;
			if(FlexGlobals.topLevelApplication.isVideoPrefrenceON){
				btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
				btnVideoModule.visible = true;
				btnVideoModule.includeInLayout = true;
				FlexGlobals.topLevelApplication.isVideoPrefrenceON=true;
				if(event!= null){
					FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 0;
					FlexGlobals.topLevelApplication.colbTools.tabs.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
				}
			}else{
				btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
				btnVideoModule.visible = false;
				btnVideoModule.includeInLayout = false;
				FlexGlobals.topLevelApplication.isVideoPrefrenceON=false;
				//To change tab as per Moderator current tab
				FlexGlobals.topLevelApplication.setActiveModule(false,22);
			}
		}
	}else{
		MessageBox.show("You cannot turn video OFF when you are in interaction, you may stop interaction or try again later.", "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		FlexGlobals.topLevelApplication.videoPreference.videoPreferenceToggleSwitch.enabled=false;
	}
}
private function changeVideoSetting(event:Event= null):void{
	if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
		FlexGlobals.topLevelApplication.videoPreference=new VideoPreference(videoSettingChange);
		var btnVideoModule :IVisualElement;
		//If user is not a selected viewer, open video setting component.
		//Otherwise shows information message
		if (!FlexGlobals.topLevelApplication.mainApp.isSelectedUser(ClassroomContext.userVO.userName)){
			if(FlexGlobals.topLevelApplication.sliderDrawer.performanceSetting.toggleVideo.selected == true){
				btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
				btnVideoModule.visible = true;
				btnVideoModule.includeInLayout = true;
				FlexGlobals.topLevelApplication.isVideoPrefrenceON=true;
				if(event!= null){
					FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 0;
					FlexGlobals.topLevelApplication.colbTools.tabs.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
				}
				//If user has started his/her video before he/she changed video-setting status as OFF, start video once again automatically.
				/*if (FlexGlobals.topLevelApplication.isVideoON){
					if (FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE){
						FlexGlobals.topLevelApplication.videoComp.btnLocalVideo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						FlexGlobals.topLevelApplication.isVideoON=false;
					}else if (FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.userVO.userName).userRole == Constants.VIEWER_ROLE && !FlexGlobals.topLevelApplication.mainApp.isMUISelected){
						FlexGlobals.topLevelApplication.videoComp.btnLocalVideo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						FlexGlobals.topLevelApplication.isVideoON=false;
					}else{
						FlexGlobals.topLevelApplication.mainApp.isvideoPublished=true;
					}
				}*/
			}else{
				btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
				btnVideoModule.visible = false;
				btnVideoModule.includeInLayout = false;
				FlexGlobals.topLevelApplication.isVideoPrefrenceON=false;
				//To change tab as per Moderator current tab
				FlexGlobals.topLevelApplication.setActiveModule(false,22);
				FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails=new ArrayCollection();
				for (var i:int=0; i < FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length; i++){
					FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.addItemAt(FlexGlobals.topLevelApplication.mainApp.selectedViewersData[i], i);
				}
				//To chechk that user started his/her video.
				if (FlexGlobals.topLevelApplication.videoComp.videoPublishStatus){
					btnLocalVideo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					FlexGlobals.topLevelApplication.isVideoON=true;
				}
				//To remove the Hand raise.
				FlexGlobals.topLevelApplication.mainApp.actionButtons.btn_handrelease.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				FlexGlobals.topLevelApplication.sliderDrawer.performanceSetting.toggleVideo.selected = false;
				FlexGlobals.topLevelApplication.mainApp.usersSyncHandler(new SyncEvent(SyncEvent.SYNC));
			}
		}else{
			if(event != null){
				MessageBox.show("If you want to change the videosettings to OFF, Please release the interaction with presenter", "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
				FlexGlobals.topLevelApplication.videoPreference.videoPreferenceToggleSwitch.enabled=false;
			}
		}
	}
	else{
		if (FlexGlobals.topLevelApplication.sliderDrawer.performanceSetting.toggleVideo.selected == true){
			if(FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)
			{
				FlexGlobals.topLevelApplication.mainApp.startPresentersStream();
			}
			if(FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length >= 1)
			{
				FlexGlobals.topLevelApplication.mainApp.addSelectedViewerVideoToPanel(null,true);
			}
		}
		else{
			if(FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)
			{
				FlexGlobals.topLevelApplication.mainApp.stopPresentersStream();
			}
			if(FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length >= 1)
			{
				FlexGlobals.topLevelApplication.mainApp.stopSelectedViewersStream(ClassroomContext.userVO.userName);
			}
			FlexGlobals.topLevelApplication.isVideoON=true;
		}

	}
}
private function changeMuiSettingHandler(event:Event):void{
	if (FlexGlobals.topLevelApplication.silderDrawer.userSetting.toggleMui.selected){
		FlexGlobals.topLevelApplication.mainApp.changeMUIMode(true);
	}else{
		FlexGlobals.topLevelApplication.mainApp.changeMUIMode(false);
	}
}
public function changerbgScreenTypeOption(event:Event):void
{
	consolidatedContainer.removeAllElements();
	viewContainer.removeAllElements();
	if(FlexGlobals.topLevelApplication.sliderDrawer.screenType.rbAllInOne.selected)// == FlexGlobals.topLevelApplication.sliderDrawer.screenType.rbAllinOne)
	{
		//To remove stage webview
		//MOBILE_ISPRING:FlexGlobals.topLevelApplication.docComp.hideStageWebView();
		FlexGlobals.topLevelApplication.isIndividulSelected = false;
		FlexGlobals.topLevelApplication.screenTypes = Constants.SCREENTYPE_ALLINONE;
		FlexGlobals.topLevelApplication.setActiveModule(false);
		//Disble the colaboration buttons for All-in-one mode
		groupMainContainer.percentHeight = 100;
		colaborationBtnsContainer.visible = false;
		colaborationBtnsContainer.includeInLayout = false;
		consolidatedContainer.visible = true;
		consolidatedContainer.includeInLayout = true;
		consolidatedContainer.percentHeight = 100;
		consolidatedContainer.percentWidth = 30;
		viewContainer.percentHeight = 100;
		viewContainer.percentWidth = 70;
		FlexGlobals.topLevelApplication.consolidated.percentHeight=100;
		FlexGlobals.topLevelApplication.consolidated.percentWidth=100;
		consolidatedContainer.addElement(FlexGlobals.topLevelApplication.consolidated);
		if(FlexGlobals.topLevelApplication.isVideoPrefrenceON && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName)!= null && FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing)
		{
			if(FlexGlobals.topLevelApplication.mainApp.isPresenterAdded == false){
				FlexGlobals.topLevelApplication.mainApp.isPresenterAdded = true
				var presenterObj:Object = new Object();
				FlexGlobals.topLevelApplication.consolidated.presenterTitle = Constants.PRESENTER_VIDEO_TITLE+ FlexGlobals.topLevelApplication.mainApp.getUserSO(ClassroomContext.currentPresenterName).userDisplayName;
				presenterObj.contextName = FlexGlobals.topLevelApplication.consolidated.presenterTitle+"(Video)";
				FlexGlobals.topLevelApplication.consolidated.presenterValuesArray.addItem(presenterObj);
				FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.selectedIndex = 1;
				FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
			}
		}
		else{
			FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.selectedIndex = 0;
			FlexGlobals.topLevelApplication.consolidated.dropdownPresenter.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
		}		
		//Selected Viewer
		if(FlexGlobals.topLevelApplication.isVideoPrefrenceON && FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length >= 1)
		{
			if( FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType !=null &&  FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.visible == true){
				userName =  FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.selectedItem.userName;
			}else{
				userName =  FlexGlobals.topLevelApplication.mainApp.currentSelectedViewer;
			}
			for(var i:int = 0; i < FlexGlobals.topLevelApplication.consolidated.allinoneItemsData.length;i++){
				if(userName == FlexGlobals.topLevelApplication.consolidated.allinoneItemsData[i].contextName)
				{
					FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = i;
					FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
				}
			}
		}
		else{
			FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = 0;
			FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
		}
		FlexGlobals.topLevelApplication.sliderDrawer.checkFollowPresenter.enabled = false;
		FlexGlobals.topLevelApplication.isAllowPresenter = true;
		FlexGlobals.topLevelApplication.sliderDrawer.isFollowPresenterSelected = FlexGlobals.topLevelApplication.isAllowPresenter;
	}
	else{
		FlexGlobals.topLevelApplication.colbTools.tabs.addEventListener(IndexChangeEvent.CHANGE, changeView);
		FlexGlobals.topLevelApplication.screenTypes = Constants.SCREENTYPE_INDIVIDUAL;
		colaborationBtnsContainer.visible = true;
		colaborationBtnsContainer.includeInLayout = true;
		consolidatedContainer.visible = false;
		consolidatedContainer.includeInLayout = false;
		colaborationBtnsContainer.height = 40;
		groupMainContainer.height = FlexGlobals.topLevelApplication.height - (titleContentBox.height+colaborationBtnsContainer.height);
		viewContainer.percentHeight = 100;
		viewContainer.percentWidth = 100;
		FlexGlobals.topLevelApplication.collaborationBtnsHeight = colaborationBtnsContainer.height;
		if(FlexGlobals.topLevelApplication.isIndividulSelected == false){
			FlexGlobals.topLevelApplication.isIndividulSelected = true;
		}
		if(!FlexGlobals.topLevelApplication.isVideoTabVisible){
			var btnVideoModule :IVisualElement;
			btnVideoModule = FlexGlobals.topLevelApplication.colbTools.tabs.dataGroup.getElementAt(0);
			btnVideoModule.visible = true;
			btnVideoModule.includeInLayout = true;
			FlexGlobals.topLevelApplication.isVideoTabVisible = true;
		}
		if(FlexGlobals.topLevelApplication.isVideoPrefrenceON && FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length >= 1)
		{
			if( FlexGlobals.topLevelApplication.consolidated.dropdownViewer !=null &&  FlexGlobals.topLevelApplication.consolidated.dropdownViewer == true){
				selectedViewer = FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedItem.contextName;
			}else{
				selectedViewer =  FlexGlobals.topLevelApplication.mainApp.currentSelectedViewer;
			}
			if(FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType!=null){
				for(var i:int = 0; i < FlexGlobals.topLevelApplication.mainApp.selectedViewersData.length;i++){
					if(selectedViewer == FlexGlobals.topLevelApplication.mainApp.selectedViewersData[i].userName)
					{
						FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.selectedIndex = i;
						FlexGlobals.topLevelApplication.videoComp.dropdownSelectedViewerType.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
					}
				}
			}
		}
		/*else{
			FlexGlobals.topLevelApplication.consolidated.dropdownViewer.selectedIndex = 0;
			FlexGlobals.topLevelApplication.consolidated.dropdownViewer.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
		}*/
		FlexGlobals.topLevelApplication.sliderDrawer.checkFollowPresenter.enabled = true;
		//To change the tab
		setIndividualScreenSelectedIndex(FlexGlobals.topLevelApplication.selectedModuleIndex);
		//To remove video, if video setting is disabled by the user
		if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON){
			performanceHandler();
		}
		FlexGlobals.topLevelApplication.setActiveModule(false,22);
	}
	FlexGlobals.topLevelApplication.resizeModules();
	if(FlexGlobals.topLevelApplication.selectedModuleIndex == 2){
		FlexGlobals.topLevelApplication.viewer3DComp.resizeViewerThreeObject();
	}
}
private function changeFollowPresenter(event:MouseEvent):void{
	if(FlexGlobals.topLevelApplication.slider.isShowing){
		FlexGlobals.topLevelApplication.slider.animate(false);
	}
	if(FlexGlobals.topLevelApplication.sliderDrawer.isFollowPresenterSelected){
		FlexGlobals.topLevelApplication.sliderDrawer.isFollowPresenterSelected = false;
		FlexGlobals.topLevelApplication.sliderDrawer.followPrenterEnabledDisabledIcon = FlexGlobals.topLevelApplication.sliderDrawer.unFollowPresenterIcon;
		FlexGlobals.topLevelApplication.isAllowPresenter = false;
	}else{
		FlexGlobals.topLevelApplication.sliderDrawer.isFollowPresenterSelected = true;
		FlexGlobals.topLevelApplication.sliderDrawer.followPrenterEnabledDisabledIcon = FlexGlobals.topLevelApplication.sliderDrawer.followPresenterIcon;
		FlexGlobals.topLevelApplication.isAllowPresenter = true;
		setIndividualScreenSelectedIndex(FlexGlobals.topLevelApplication.selectedModuleIndex);
	}
}
private function setIndividualScreenSelectedIndex(value:int):void{
	if(value == 0){
		FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 1;
	}else if(value == 1){
		FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 2;
	}else if(value == 2){
		FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 4;
	}else if(value == 3){
		FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 3;
	}else{
		FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 0;
	}
	FlexGlobals.topLevelApplication.colbTools.tabs.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
}
/**
 * @private
 *
 * Exit session confirmation handler
 *
 * @param event of MessageBoxEvent
 * @return void
 */
protected function exitSessionConfirmHandler(event:MessageBoxEvent):void{
	if(event.type == MessageBoxEvent.MESSAGEBOX_YES){
		cleanClassRoomContainer();
		FlexGlobals.topLevelApplication.exitClassRoom(Constants.MENU_EXIT_SESSION);
	}
}
/**
 * @private
 *
 * Logout confirmation handler
 *
 * @param event of MessageBoxEvent
 * @return void
 */
protected function logoutConfirmHandler(event:MessageBoxEvent):void{
	if(event.type == MessageBoxEvent.MESSAGEBOX_YES){
		cleanClassRoomContainer();
		FlexGlobals.topLevelApplication.exitClassRoom(Constants.MENU_LOGOUT);
	}
}

private function cleanClassRoomContainer():void{
	if(FlexGlobals.topLevelApplication.slider!= null){
		if(FlexGlobals.topLevelApplication.slider.isShowing){
			FlexGlobals.topLevelApplication.slider.animate(false);
		}
		FlexGlobals.topLevelApplication.slider.removeAllElements();
		FlexGlobals.topLevelApplication.slider = null;
	}
	FlexGlobals.topLevelApplication.isExitClassRoom = true;
	viewContainer.removeAllElements();
	colaborationBtnsContainer.removeAllElements();
	stage.removeEventListener("keyDown", handleButtons, false);
}