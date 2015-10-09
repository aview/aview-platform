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
 * File			: AdminConsoleHandler.as
 * Module		: SessionAdmin
 * Developer(s) : Salil George, Ramesh Guntha
 * Reviewer(s)	: Remya T
 *
 * The AdminConsole allows the administrator to monitor the logged in A-VIEW users in a particular
 * server. As more clients are connected to A-VIEW, the possibility of system failure increases.To
 * maintain the system working properly the administrator needs to monitor the logged in users and
 * their details.This system will monitor the client properties like camera used, microphone used,
 * logged in class, client bandwidth usage, and other client system properties which will inform
 * administrator about the fault in the some client settings.
 *
 */

/**Platform specific imports*/
applicationType::desktop{
	//ReturnKeyLabel not available for web
	import flash.text.ReturnKeyLabel;
}
import com.adobe.utils.StringUtil;

import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.vo.ClassServerVO;
import edu.amrita.aview.core.sessionAdmin.AdminMessage;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.List;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.DataGridEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.logging.Log;
import mx.logging.ILogger;
import spark.components.DataGrid;
import edu.amrita.aview.core.entry.AVCEnvironment;


/**
 * Used for start record icon
 */
[Bindable]
[Embed(source="/edu/amrita/aview/core/sessionAdmin/assets/images/startRecord.png")]
public var startRecordIcon:Class;

/**
 * Used for stop record icon
 */
[Bindable]
[Embed(source="/edu/amrita/aview/core/sessionAdmin/assets/images/stopRecord.png")]
public var stopRecordIcon:Class;

/**
 * Used for deciding to show stop record icon or start record icon
 */
[Bindable]
public var recordIcon:Class;

/**
 * The bindable array holds the logged user data from the server which is pushed in through the Sync method.
 */
[Bindable]
public var loggedInUserDetails:ArrayCollection;

/**
 * Holds the administrator functions labels like Remove User when right clicked on a particular user
 */
private var adminActionsMenuItems:Array=new Array("Remove User", "Send Message");

/**
 * The variable holds admin funtionality option like Remove User.
 */
private var adminActionsMenu:List;

/**
 * The variable lists the selected user details.
 */
private var currentUserDetailsList:List;

/**
 * Instance of AdminMessage Component
 */
private var adminMessageInst:AdminMessage;

/**
 * Used to hold the whether left or right mouse button clicked(RIGHT/LEFT/NONE)
 */
private var clickType:String="";
/**
 * Used to hold the last selected user's id
 */
private var lastSelectedUserId:String="";
/**
 * Used to hold the last selected index
 */
private var lastSelectedIndex:int=-1;
/**
 * Used to hold the last mouse y position
 */
private var lastMouseY:int=-1;
/**
 * Used to hold the last mouse x position
 */
private var lastMouseX:int=-1;
/**
 * Used to hold the last rollover index
 */
private var lastRollOverIndex:int=-1;
/**
 * Used to set the row height
 */
private const ROW_HEIGHT:int=37;
/**
 * Used to set the header height
 */
private const HEADER_HEIGHT:int=24;
/**
 * Constant holds the string LEFT
 */
private const LEFT:String="LEFT";
/**
 * Constant holds the string RIGHT
 */
private const RIGHT:String="RIGHT";
/**
 * Constant holds the string NONE
 */
private const NONE:String="NONE";

/**
 * Used to hold the timer for record button enable
 */
private var timerRecord:Timer;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.sessionAdmin.AdminConsoleHandler.as");

/**
 @public
 *
 * This method is called from adminConsoleSyncHandler(called whenever admin console shared object get updated) 
 * To keep the selection while updated client list are appear 
 *
 * @return void
 */
public function keepTheSelections():void
{
	if (lastSelectedUserId != "")
	{
		removeCurrentLists();
		var index:int=getIndexFromUserName(lastSelectedUserId);
		if (index != -1)
		{
			userListDataGrid.selectedIndex=index;
			var newMouseY:int=-1;
			newMouseY=lastMouseY + (index - lastSelectedIndex) * ROW_HEIGHT;
			if (clickType == LEFT)
			{
				showUserDetailsList(lastMouseX, newMouseY);
			}
			else if (clickType == RIGHT)
			{
				showContextMenu(lastMouseX, newMouseY);
			}
		}
	}
}
/**
 @public
 *
 * This method is called from keepTheSelections
 * To get the index of the username 
 * @param userName type of String
 * @return int
 */
private function getIndexFromUserName(userName:String):int
{
	for (var i:int=0; i < userListDataGrid.dataProvider.length; i++)
	{
		if (userListDataGrid.dataProvider[i].UserName == userName)
		{
			return i;
		}
	}
	return -1;
}

/**
 *
 * @public
 *
 * This method is called from adminConsoleSyncHandler in Users.as
 * This Method provides logged in user details.
 *
 * @param userDetails of type array
 * @return void
 *
 */
public function userDetails(userDetails:Array):void{
	loggedInUserDetails=new ArrayCollection(userDetails);
	if (txtUserIdFilter.text != Constants.USERID_SEARCH_STR)
		userIdFilter();
	if (txtInstituteFilter.text != Constants.INSTITUTE_SEARCH_STR)
		instituteNameFilter();
	if (txtUserNameFilter.text != Constants.USERNAME_SEARCH_STR)
		userNameFilter();
}

/**
 *
 * @private
 * This method is used to handle the mouse left click and right click on the user record.
 * On Right click, the context sensitive menu appears, containing SendMessage and Remove user commands
 * On Left click, the user's details are shown as tool tip
 *
 * @param event type of MouseEvent.
 * @return void.
 *
 */
private function handleTheMouseClickOnUserList(event:MouseEvent):void{
	var userCount:int=loggedInUserDetails.length;
	var userListHeight:int;
	
	userListDataGrid.selectedIndex=lastRollOverIndex;
	
	if ((userListDataGrid.selectedIndex + 1) > 0 && userListDataGrid.selectedIndex <= userListDataGrid.dataProvider.length){
		userListHeight=HEADER_HEIGHT + userCount * ROW_HEIGHT;
		var selectedX:int=userListDataGrid.mouseX;
		if (selectedX > 685) selectedX=685;
		
		var selectedY:int=userListDataGrid.mouseY;
		
		//Clicked on the header and hence sorted
		if (selectedY < HEADER_HEIGHT){
			selectedX=lastMouseX;
			//Sorted, hence move it up or down in the same X axis
			if (lastSelectedIndex != userListDataGrid.selectedIndex){
				selectedY=lastMouseY + (userListDataGrid.selectedIndex - lastSelectedIndex) * ROW_HEIGHT;
				lastMouseY=selectedY;
			}
			else selectedY=lastMouseY; //If the selected index did not change, then stay put
		}
		else if (userListDataGrid.mouseY > userListHeight) {//Clicked below the last row with data, remove it
			selectedX=-1;
			selectedY=-1;
		}
		else{
			//If the right click happens, the selectedIndex does not change. So if it's right clicked out side the selection, then we should not move the Y & (X for clarity)
			//Otherwise, list would highlight one row and menu would come on another row, confusing the hell out of the admin
			if (event.type == MouseEvent.RIGHT_CLICK){
				if (selectedY < (userListDataGrid.selectedIndex * ROW_HEIGHT + HEADER_HEIGHT) || selectedY > ((userListDataGrid.selectedIndex + 1) * ROW_HEIGHT + HEADER_HEIGHT)){
					selectedY=lastMouseY;
					selectedX=lastMouseX;
				}
				else{
					lastMouseY=selectedY;
					lastMouseX=selectedX;
				}
			}
			else{
				lastMouseY=selectedY;
				lastMouseX=selectedX;
			}
		}
		
		removeCurrentLists();
		if (selectedY > -1){
			if (event.type == MouseEvent.CLICK){
				clickType=LEFT;
				showUserDetailsList(selectedX, selectedY);
			}
			else{
				clickType=RIGHT;
				showContextMenu(selectedX, selectedY);
			}
			lastSelectedUserId=userListDataGrid.selectedItem.UserName;
			lastSelectedIndex=userListDataGrid.selectedIndex;
		}
		else{
			lastSelectedUserId="";
			clickType=NONE;
			lastSelectedIndex=-1;
			lastMouseY=-1;
			lastMouseX=-1;
		}
	}
	event.stopPropagation();
}

/**
 *
 * @private
 * This method is to remove the context menu or user details tooltip,
 * called when the list refreshes, or user clicks in another row etc
 *
 *
 * @return void.
 *
 */

private function removeCurrentLists():void{
	try{
		userListDataGrid.removeChild(currentUserDetailsList);
	}
	catch (err:Error){
		if(Log.isError()) log.error("Error in removeCurrentLists method::currentUserDetailsList:"+ err.getStackTrace());
	}
	try{
		userListDataGrid.removeChild(adminActionsMenu);
	}
	catch (err:Error){
		if(Log.isError()) log.error("Error in removeCurrentLists method::adminActionsMenu:"+ err.getStackTrace());
	}
}

/**
 *
 * @private
 * This method is used to create the tooltip on mouse click
 *
 * @param selectedX type of int
 * @param selectedY type of int
 * @return void.
 *
 */
private function showUserDetailsList(selectedX:int, selectedY:int):void{
	currentUserDetailsList=new List();
	currentUserDetailsList.width=242;
	currentUserDetailsList.height=325;
	var userDetails:Array=new Array();
	userDetails.push("User Name : " + userListDataGrid.selectedItem.userName, "Institute Name : " + userListDataGrid.selectedItem.instituteName, "Course Name : " + userListDataGrid.selectedItem.courseName, "Login Time :" + userListDataGrid.selectedItem.loginTime, "OS Used : " + userListDataGrid.selectedItem.operatingSystem, "PlayerVersion : " + userListDataGrid.selectedItem.playerVersion, "ScreenResolution : " + userListDataGrid.selectedItem.screenResolution, "Pixel Aspect Ratio : " + userListDataGrid.selectedItem.pixelAspectRatio, "Camera : " + userListDataGrid.selectedItem.camera, "Microphone : " + userListDataGrid.selectedItem.microphone, "IPAddress : " + userListDataGrid.selectedItem.ipAddress, "NetworkConnectionType : " + userListDataGrid.selectedItem.networkConnectionType, "A-VIEW VERSION : " + userListDataGrid.selectedItem.AVIEW_VERSION);
	currentUserDetailsList.dataProvider=userDetails;
	userListDataGrid.addChild(currentUserDetailsList);
	currentUserDetailsList.move(selectedX, selectedY);
	currentUserDetailsList.horizontalScrollPolicy="on";
	currentUserDetailsList.addEventListener(MouseEvent.CLICK, doNothing);
}

/**
 *
 * @private
 * Click handler of the user details tooltip.
 * Does nothing and prevents the click event from bubbling up the display list
 *
 * @param event of type MouseEvent.
 * @return void.
 *
 */
private function doNothing(event:MouseEvent):void{
	event.stopImmediatePropagation();
}

/**
 *
 * @private
 * This method shows the context menu on mouse click
 *
 * @param selectedX type of int
 * @param selectedY type of int
 * @return void.
 *
 */
private function showContextMenu(selectedX:int, selectedY:int):void{
	var event:KeyboardEvent;
	adminActionsMenu=new List();
	adminActionsMenu.move(selectedX, selectedY);
	adminActionsMenu.width=100;
	adminActionsMenu.height=60;
	adminActionsMenu.dataProvider=adminActionsMenuItems;
    adminActionsMenu.addEventListener(MouseEvent.CLICK, contextMenuClickHandler);
	userListDataGrid.addChild(adminActionsMenu);
	adminActionsMenu.setFocus();
	//Fix for bug # 20042 
	adminActionsMenu.selectedIndex=0;
	adminActionsMenu.addEventListener(KeyboardEvent.KEY_DOWN, adminFunctionListKeyEventHandler);
	
	if (currentUserDetailsList) currentUserDetailsList.move(userListDataGrid.mouseX, userListDataGrid.mouseY);
}

/**
 *
 * @private
 * This is called when any option in the Right clicked menu is selected.
 * This method handles the click event in the Optionlist.
 *
 * @param event type of MouseEvent
 * @return void.
 *
 */
private function contextMenuClickHandler(event:MouseEvent):void{
	var listno:Number=adminActionsMenu.selectedIndex + 1;
	userListDataGrid.visible=false;
	switch (listno){
		case 1:
			userListDataGrid.visible=true;
			Alert.show("The user '" + userListDataGrid.selectedItem.displayName + "' will not be allowed to attend the current session hereafter, are you sure you want to remove the user from the current session?", "Warning", Alert.YES | Alert.NO, this, removeUser, null, Alert.NO);
			break;
		case 2:
			userListDataGrid.visible=true;
			adminMsg();
			break;
	}
	event.stopImmediatePropagation();
}

/**
 *
 * @private
 * This is called when any option in the Right clicked menu is selected.
 * This method handles the keyboard up/down in the Optionlist.
 *
 * @param event of type KeyboardEvent.
 * @return void.
 *
 */
private function adminFunctionListKeyEventHandler(event:KeyboardEvent):void{
	if (event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.SPACE) event.target.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
}

/**
 *
 * @private
 * This is used for remove the user by calling the serverside function.
 * This function is called when the admin clicks on the context menu "Remove User"
 *
 * @param event of type CloseEvent
 * @return void.
 *
 */

private function removeUser(event:CloseEvent):void{
	if (event.detail == Alert.YES)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("restrictUser", null, userListDataGrid.selectedItem.userName);
	}
	removeCurrentLists();
}

/**
 *
 * @private
 * This method is called from AdminFunctionListClickHandler, when user selects sendmessage option.
 *
 *
 * @return void.
 *
 */
private function adminMsg():void{
	if (adminMessageInst) return;
	
	adminMessageInst=new AdminMessage;
	adminMessageInst.setSelectedUserName(userListDataGrid.selectedItem.userName);
	adminMessageInst.title=userListDataGrid.selectedItem.displayName;
	
	PopUpManager.addPopUp(adminMessageInst, this, false, null);
	adminMessageInst.addEventListener(FlexEvent.REMOVE, closeMessagePopup);
	PopUpManager.centerPopUp(adminMessageInst);
}


/**
 *
 * @private
 * This method is used close the admin message popup.
 *
 * @param event of type Event.
 * @return void.
 *
 */
private function closeMessagePopup(event:Event):void{
	adminMessageInst=null;
	removeCurrentLists();
}

/**
 *
 * @private
 * This method is used for display the user detail based on the userID filter search.
 * Called when entering the text changed in txtUserIdFilter
 *
 *
 * @return void.
 *
 */
private function userIdFilter():void{
	loggedInUserDetails.filterFunction=filterUserId;
	loggedInUserDetails.refresh();
}

/**
 *
 * @private
 * This method used to check whether userId exists or not
 * Called by userIdFilter method
 *
 * @param item of type Object.
 * @return Boolean.
 *
 */

private function filterUserId(item:Object):Boolean{
	var searchName:String=txtUserIdFilter.text.toLowerCase();
	// Fix for bug # 20038
	var usrName:String=(item.userName as String).toLowerCase();
	return usrName.indexOf(searchName) > -1;
}

/**
 *
 * @public
 * This method used to clear if the default text in txtUserIdFilter
 * Called when focusing getting on the txtUserIdFilter
 *
 *
 * @return void.
 *
 */
public function clearUserIdSearchFilter():void{
	var userNameFilter:String;
	userNameFilter=txtUserIdFilter.text;
	
	if (userNameFilter == Constants.USERID_SEARCH_STR){
		txtUserIdFilter.text="";
		txtUserIdFilter.setStyle("color", 0x060606);
	}
	else{
		if (StringUtil.trim(userNameFilter) == null || StringUtil.trim(userNameFilter) == "") txtUserIdFilter.setFocus();
		else txtUserIdFilter.text=StringUtil.trim(userNameFilter);
	}
}

/**
 *
 * @private
 * This method is used for display the user details based on the txtUserNameFilter search.
 * called when entering the text changed in txtUserNameFilter
 *
 *
 * @return void.
 *
 */
private function userNameFilter():void{
	loggedInUserDetails.filterFunction=filterUserName;
	loggedInUserDetails.refresh();
}

/**
 *
 * @private
 * This method used to check whether userName exist or not
 * Called by userIdFilter method
 *
 * @param item of type Object.
 * @return Boolean.
 *
 */
private function filterUserName(item:Object):Boolean{
	var searchName:String=txtUserNameFilter.text.toLowerCase();
	var usrName:String=(item.displayName as String).toLowerCase();
	return usrName.indexOf(searchName) > -1;
}

/**
 *
 * @public
 * This method used to clear if the default text in txtUserNameFilter
 * Called when focusing getting on the txtUserNameFilter
 *
 *
 * @return void.
 *
 */
public function clearUserNameSearchFilter():void{
	var userNameFilter:String;
	userNameFilter=txtUserNameFilter.text;
	
	if (userNameFilter == Constants.USERNAME_SEARCH_STR){
		txtUserNameFilter.text="";
		txtUserNameFilter.setStyle("color", 0x060606);
	}
	else{
		if (StringUtil.trim(userNameFilter) == null || StringUtil.trim(userNameFilter) == "") txtUserNameFilter.setFocus();
		else txtUserNameFilter.text=StringUtil.trim(userNameFilter);
	}
}

/**
 *
 * @private
 * This method is used for display the user detail based on the txtInstituteFilter search.
 * called when entering the text changed in txtInstituteFilter
 *
 *
 * @return void.
 *
 */
private function instituteNameFilter():void{
	if(loggedInUserDetails != null)
	{
		loggedInUserDetails.filterFunction=filterInstituteName;
		loggedInUserDetails.refresh();
	}
}

/**
 *
 * @private
 * This method used to check whether institute name exist or not
 * Called by instituteNameFilter method
 *
 * @param item of type Object.
 * @return Boolean.
 *
 */
private function filterInstituteName(item:Object):Boolean{
	var searchName:String=txtInstituteFilter.text.toLowerCase();
	var instName:String=(item.instituteName as String).toLowerCase();
	return instName.indexOf(searchName) > -1;
}

/**
 *
 * @public
 * This method used to clear if the default text in txtInstituteFilter
 * Called when focusing getting on the txtInstituteFilter
 *
 *
 * @return void.
 *
 */
public function clearInstituteNameSearchFilter():void{
	var instNameFilter:String;
	instNameFilter=txtInstituteFilter.text;
	
	if (instNameFilter == Constants.INSTITUTE_SEARCH_STR){
		txtInstituteFilter.text="";
		txtInstituteFilter.setStyle("color", 0x060606);
	}
	else{
		if (StringUtil.trim(instNameFilter) == null || StringUtil.trim(instNameFilter) == "") txtInstituteFilter.setFocus();
		else txtInstituteFilter.text=StringUtil.trim(instNameFilter);
	}
}

/**
 *
 * @private
 * This method used to enable the record button
 * Called by recordSession method
 *
 * @param event of type TimerEvent.
 * @return void.
 *
 */

private function buttonStatus(event:TimerEvent):void{
	btnRecord.enabled=true;
}

/**
 *
 * @private
 * This method used to check whether recording is possible if yes record other wise inform the user with appropriate messsage
 * Called when btnRecord clicked
 *
 *
 * @return void.
 *
 */
private function recordSession():void
{
	var i : int = 0;
	if (ClassroomContext.moderatorName != "")
	{
		for (i = 0; i < ClassroomContext.aviewClass.classServers.length; i++)
		{
			var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClass.classServers.getItemAt(i));
			if (classServer.serverTypeName == Constants.FMS_PRESENTER)
			{
				if ((classServer.server.serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || classServer.server.serverCategory == Constants.SERVER_CATEGORY_RED5_LIN) && ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264)
				{
					Alert.show("Recording is not possible as RED5 server & High definition codec is used for the class.", "RECORDING");
					return;
				}
			}
		}
		timerRecord=new Timer(1000, 1);
		timerRecord.addEventListener(TimerEvent.TIMER_COMPLETE, buttonStatus);
		timerRecord.start();
		btnRecord.enabled=false;
		var objRecordDetails:Object=new Object();
		objRecordDetails.userName=ClassroomContext.userVO.userName;
		//Fix for issues #19664 and #19666
		for(i = 0; i<loggedInUserDetails.length; i++)
		{
			if(loggedInUserDetails[i].userName && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(loggedInUserDetails[i].userName))
			{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(loggedInUserDetails[i].userName).isModerator == true && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(loggedInUserDetails[i].userName).avcRuntime == AVCEnvironment.BROWSER)
				{
					Alert.show("Moderator has logged into A-VIEW using A-VIEW web version, which doesn't have Recording feature. To start recording, kindly ask the moderator to log into desktop version.","Recording not available for web users");
					return;
				}
			}
		}
		if (recordIcon == startRecordIcon)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("initiateRecordofModerator", null, "start", ClassroomContext.moderatorName);
		}
		else if (recordIcon == stopRecordIcon) 
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("initiateRecordofModerator", null, "stop", ClassroomContext.moderatorName);
		}
	}
	else 
	{
		Alert.show("Moderator has not entered into the class, Recording cannot be started", "INFO");
	}
}
private function adminconsoleCreationComplete():void
{
	//Fix for Bug#18497
	trace(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pttBox);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pttBox.includeInLayout = true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pttBox.visible = true;
	btnHolder.addChildAt(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pttBox,1);
}
