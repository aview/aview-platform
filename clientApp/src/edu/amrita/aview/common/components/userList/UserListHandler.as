// ActionScript fileimport mx.core.FlexGlobals;
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
 * File			: UserListHandler.as
 * Module		: Common
 * Developer(s)	: Ajith
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-bindable variable Description
//VGCR:-Variable Description
//VGCR:-Function description for all description
import com.adobe.utils.StringUtil;

import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.chat.events.ChatEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.userList.CRActionButtons;
import edu.amrita.aview.common.components.userList.UserSOValue;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomComponent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
import edu.amrita.aview.core.login.boilerplate.Strings;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.UserVO;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.net.SharedObject;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.controls.List;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.ScrollEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

[Bindable]
public var userCount:int;

public var selectedUserName:String=null;


/**
 * Variable for storing index of last selected user from the userlist.
 */
public var lastRollOverIndex:int;
public var lastScrollPosition:int;

private var classRoomComp:ClassroomComponent;

public var log:ILogger=Log.getLogger("aview.common.components.UserList");

public var userlistIndex:int=-1;

private var actionButtons:CRActionButtons;

[Bindable]
public var offlineUsersArray:ArrayCollection = new ArrayCollection();

/**
 * Variable of type Array for storing online (logged into FMS) user names and icon details
 */
public var usersArray:Array=new Array({id: "", label: "", data: ""});


/**
 * Variables used for notifying Presenter / Selected Viewers' via POP out message box
 */
public var notifySelectedViewer:Boolean=false;
public var notifyPresenter:Boolean=false;
private var alert:MessageBox;

/**
 * Variable of type Array for storing sorted userlist for changing the icon of 'unmuted' user in 'push to talk' mode
 */
public var sortedPushToTalkArray:Array=new Array();

public var classMembers:ArrayCollection=null;

private var classRoomModuleRO:ModuleRO = null;

/**
 * @public 
 * @param classRoomComp of type ClassroomComponent
 * @param actionButtons of type CRActionButtons
 * 
 */
public function init(classRoomComp:ClassroomComponent,actionButtons:CRActionButtons,mro:ModuleRO):void
{
	this.classRoomComp = classRoomComp;
	this.actionButtons = actionButtons;
	this.classRoomModuleRO = mro;
	this.classRoomModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, logoutHandler);
	this.classRoomModuleRO.moduleEventMap.registerInitiator(this,ChatEvent.INITIATE_PRIVATE_CHAT);
	this.classRoomModuleRO.applicationEventMap.registerMapListener(ContactsEvent.USER_STATUS_CHANGED,changeOnlineUserStatus)
}

/**
 * @public
 * @param show of type Boolean
 * 
 */
public function showHideFilters(show:Boolean):void
{
	this.usersSort.visible = show;
	this.usersSort.includeInLayout = show;
	resetFilters();
}
private var filteredUsers:Array;

/**
 * @private 
 * @return int
 * 
 */
private function getFilterComboIndex():int
{
	var index:int=-1;
	index=comboSort.selectedIndex;
	return index;
}


/**
 *@private 
 * 
 */
private function clearComboFilters():void
{
	comboSort.selectedIndex=0;
}

/**
 * @private 
 * 
 */
private function resetFilters():void
{
	clearComboFilters();
	clearUserSearch(true);
}

/**
 * @private 
 * @return String
 * 
 */
private function getFilterSearchText():String
{
	var filterSearch:String="";
	filterSearch=(userSearch.text != Constants.USER_SEARCH_STR) ? userSearch.text : "";
	return filterSearch;
}

/**
 * @public 
 * @param roleChange of type Boolean default value false
 * 
 */
public function clearUserSearch(roleChange:Boolean=false):void
{
	if (userSearch.text == Constants.USER_SEARCH_STR || roleChange)
	{
		userSearch.text="";
		userSearch.setStyle("color", 0x060606);
	}
}

/**
 *@public 
 * 
 */
public function applyComboFilter():void
{
	var comboIndex:int=getFilterComboIndex();
	
	if (comboIndex > 0) //Not Empty and Not 'All'
	{
		filterUsersEventLog('Combo', Constants.SORT_OPTION.source[comboIndex], sortedPushToTalkArray.length);
	}
	
	for (var i:int=0; i < sortedPushToTalkArray.length; i++)
	{
		/*		changed for bug #7404 - userstatus == "accept" removed
		if(sortedPushToTalkArray[i].data.isModerator == true || sortedPushToTalkArray[i].data.userRole == "PRESENTER" || sortedPushToTalkArray[i].data.userStatus=="accept")
		*/
		if (sortedPushToTalkArray[i].data.isModerator == true || sortedPushToTalkArray[i].data.userRole == "PRESENTER")
		{
			filteredUsers.push(sortedPushToTalkArray[i].data);
		}
		else if (comboIndex == -1 || comboIndex == 0)
		{
			filteredUsers.push(sortedPushToTalkArray[i].data);
		}
		else if (comboIndex == 1)
		{
			if (sortedPushToTalkArray[i].data.userType == "TEACHER")
			{
				filteredUsers.push(sortedPushToTalkArray[i].data)
			}
		}
		else if (comboIndex == 2)
		{
			if (sortedPushToTalkArray[i].data.userStatus == Constants.WAITING)
			{
				filteredUsers.push(sortedPushToTalkArray[i].data)
			}
		}
		else if (comboIndex == 3)
		{
			if (sortedPushToTalkArray[i].data.controlStatus == Constants.PRSNTR_REQUEST)
			{
				filteredUsers.push(sortedPushToTalkArray[i].data)
			}
		}
		else if (comboIndex == 4)
		{
			if (sortedPushToTalkArray[i].data.userType == Constants.STUDENT_TYPE)
			{
				filteredUsers.push(sortedPushToTalkArray[i].data)
			}
		}
		else if (comboIndex == 5)
		{
			filteredUsers.push(sortedPushToTalkArray[i].data)
		}
	}
	
}

/**
 *
 * @private
 * Audits the "FilterUsers" action,  when the presenter/moderator filter user list by
 * choosing the user type in the dropdown or by searching for the users
 *
 * @param filterMethod - Search or Filter
 * @param filter - Search string, or dropdown value
 * @param numberUsers - Number of unfiltered users
 * @return void
 *
 */
private function filterUsersEventLog(filterMethod:String, filter:String, numberUsers:int):void
{
	AuditContext.userAction.createAction(AuditConstants.filterUsers, filterMethod, filter, numberUsers + "");
}

/**
 * @public 
 * @param e of type Event Default value null
 * 
 */
public function applyFilters(e:Event=null):void
{
	filteredUsers=new Array();
	applyComboFilter();
	applySearchFilter();
	userGrid.dataProvider=filteredUsers;
	userCount=filteredUsers.length;
	userGrid.selectedIndex=userlistIndex;
}



private var isSortBoxChecked:Boolean=true;


/**
 *@public 
 * 
 */
public function releaseAll():void
{
	var handRaised:Boolean=false;
	for (var i:int=0; i < sortedPushToTalkArray.length; i++)
	{
		
		if (sortedPushToTalkArray[i].data.userStatus == Constants.WAITING)
		{
			//		 		 if (event.detail==Alert.YES)
			handRaised=true;
			
			//			setUserStatus(sortedPushToTalkArray[i].id,Constants.HOLD);
		}
	}
	if (handRaised)
	{
		Alert.show("Remove All Handraises?", "Alert", Alert.YES | Alert.NO, this, releaseAllComplete, null, Alert.NO);
	}
	else
	{
		Alert.show("No Viewer has handraised", "Alert");
	}
}

/**
 * @private
 * Function is used for releasing all handraised users.
 * @param alertbox  of type close event
 * @return void
 */

private function releaseAllComplete(event:CloseEvent):void
{
	var handRaised:Boolean=false;
	var count:int=0;
	if (event.detail == Alert.YES)
	{
		for (var i:int=0; i < sortedPushToTalkArray.length; i++)
		{
			
			if (sortedPushToTalkArray[i].data.userStatus == Constants.WAITING)
			{
				//		 		 if (event.detail==Alert.YES)
				handRaised=true;
				
				classRoomComp.setUserStatus(sortedPushToTalkArray[i].id, Constants.HOLD);
				count++;
			}
		}
		if (!handRaised)
		{
			Alert.show("No Viewer has handraised", "Alert");
		}
		else
		{
			releaseAllHandRaisesEventLog(count);
		}
	}
	else
	{
		return;
	}
}

/**
 *
 * @private
 * Audits the "ReleaseAllHandRaises" action, when the presenter/moderator clicks on the release all handraises button
 *
 * @param numberHandRaises - current number of users who hand raised
 * @return void
 *
 */
private function releaseAllHandRaisesEventLog(numberHandRaises:int):void
{
	AuditContext.userAction.createAction(AuditConstants.releaseAllHandRaises, numberHandRaises + "", null, null);
}

/**
 *@public 
 * 
 */
public function applySearchFilter():void
{
	var searchText:String=getFilterSearchText().toLowerCase();
	searchText=StringUtil.trim(searchText);
	if (searchText != "")
	{
		filterUsersEventLog('Search', searchText, sortedPushToTalkArray.length);
		for (var i:int=0; i < filteredUsers.length; i++)
		{
			/*		changed for bug #7404 - userstatus == "accept" removed
			if(filteredUsers[i].isModerator == true || filteredUsers[i].userRole == "PRESENTER" || filteredUsers[i].userStatus=="accept")
			*/
			if (filteredUsers[i].isModerator == true || filteredUsers[i].userRole == "PRESENTER")
			{
				continue;
			}
			else
			{
				if (filteredUsers[i].(userDisplayName.toLowerCase()).indexOf(searchText) == -1)
				{
					//				if (filteredUsers[i].userDisplayName.toLowerCase().indexOf(searchText) == -1)
					if (filteredUsers[i].(instituteName.toLowerCase()).indexOf(searchText) == -1)
					{
						filteredUsers.splice(i, 1);
						i--;
					}
				}
			}
		}
	}
}
/**
 *@private 
 * 
 */
private function onClick():void
{
	if (userGrid.selectedItem)
	{
		selectedUserName=userGrid.selectedItem.id.toString();
		actionButtons.setupUserActionButtonsOnSelection();
		userlistIndex=userGrid.selectedIndex;
        if(Log.isDebug()) log.debug('userlist selected ' + userGrid.selectedItem.toString() + ' in' + userGrid.selectedIndex.toString() + ' id' + userGrid.selectedItem.id.toString());
	}
	hideMenu();
}


/**
 * @protected 
 * @param event of type ScrollEvent
 * 
 */
protected function datagrid1_scrollHandler(event:ScrollEvent):void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lastScrollPosition=userGrid.verticalScrollPosition;
}

/**
 * Variable is used for creating contextmenu for Userlist.
 * <br>Various options for context menu are ViewVideo/CloseVideo,StartInteraction/StopInteraction.</br>
 */
public var contextMenuList:List;

/**
 * @public
 * Function is used to display options for contextmenu in Userlist according to the selected user's status.
 * 
 */
public function createlist():void
{
	
	var valuesArray:ArrayList;
	//START----------------------------
	//Check if user is PRESENTER
	
	userGrid.selectedIndex=lastRollOverIndex;
	
	if (Log.isDebug()) log.debug("createlist():lstUsers.selectedIndex:" + userGrid.selectedIndex + ", userGrid.selectedItem.id:" + userGrid.selectedItem.id);
	
	selectedUserName=userGrid.selectedItem.id;
	
	hideMenu();
	
	if (ClassroomContext.userVO.userName != selectedUserName 
		&& (
			classRoomComp.getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE || 
			ClassroomContext.userVO.userName == ClassroomContext.moderatorName
		) && 
		(classRoomComp.getUserSO(userGrid.selectedItem.id).userRole != Constants.PRESENTER_ROLE) && calculateListValue())
	{
		actionButtons.setupUserActionButtonsOnSelection();
		
		/**START--------------------------------
		Check if shared objects(users_so) data of users is accept
		If yes,initialize the array and add the value accept.
		END----------------------------------
		 */
		if (classRoomComp.getUserSO(userGrid.selectedItem.id).userStatus == Constants.ACCEPT)
		{
			if (classRoomComp.getUserSO(userGrid.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER)
			{
				valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'StopInteraction'}]);
				contextMenuList.height=54;
			}
			else
			{
				valuesArray=new ArrayList([{contextName: 'StopInteraction'}]);
				contextMenuList.height=27;
			}
		}
		
		/**START--------------------------------
		//Check if shared objects(users_so) data of users is waiting
		//If yes,initialize the array and add the valus CloseVideo and StartInteraction.
		//END----------------------------------*/
		if (classRoomComp.getUserSO(userGrid.selectedItem.id).userStatus == Constants.WAITING)
		{
			/**START--------------------------------
			//Check if shared objects(users_so) data of users is view
			//If yes,initialize the array and add the values CloseVideo and StartInteraction.
			//END---------------------------------- */
			if (classRoomComp.getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE || ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
			{
				if (classRoomComp.getUserSO(userGrid.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER)
				{
					if (classRoomComp.viewVideoStatus(userGrid.selectedItem.id) == true)
					{
						valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'CloseVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=81;
					}
					else
					{
						valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'ViewVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=81;
					}
				}
				else
				{
					if (classRoomComp.viewVideoStatus(userGrid.selectedItem.id) == true)
					{
						valuesArray=new ArrayList([{contextName: 'CloseVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=54;
					}
					else
					{
						valuesArray=new ArrayList([{contextName: 'ViewVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=54;
					}
				}
			}
			else
			{
				if (classRoomComp.getUserSO(userGrid.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER)
				{
					valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'StartInteraction'}]);
					contextMenuList.height=54;
				}
				else
				{
					valuesArray=new ArrayList([{contextName: 'StartInteraction'}]);
					contextMenuList.height=27;
				}
			}
			
		}
		
		/**START--------------------------------
		//Check if shared objects(users_so) data of users is hold
		//If yes,initialize the array and add the valus ViewVideo and StartInteraction.
		//END----------------------------------*/
		if (classRoomComp.getUserSO(userGrid.selectedItem.id).userStatus == Constants.HOLD)
		{
			/**START--------------------------------
			//Check if shared objects(users_so) data of users is view
			//If yes,initialize the array and add the values CloseVideo and StartInteraction.
			//END----------------------------------*/
			if (classRoomComp.getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE || ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
			{
				if (classRoomComp.getUserSO(userGrid.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER)
				{
					if (classRoomComp.viewVideoStatus(userGrid.selectedItem.id) == true)
					{
						valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'CloseVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=81;
					}
					else
					{
						valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'ViewVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=81;
					}
				}
				else
				{
					if (classRoomComp.viewVideoStatus(userGrid.selectedItem.id) == true)
					{
						valuesArray=new ArrayList([{contextName: 'CloseVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=54;
					}
					else
					{
						valuesArray=new ArrayList([{contextName: 'ViewVideo'}, {contextName: 'StartInteraction'}]);
						contextMenuList.height=54;
					}
				}
			}
			else
			{
				if (classRoomComp.getUserSO(userGrid.selectedItem.id).avcRuntime != AVCEnvironment.BROWSER)
				{
					valuesArray=new ArrayList([{contextName: 'Private Chat'}, {contextName: 'StartInteraction'}]);
					contextMenuList.height=54;
				}
				else
				{
					valuesArray=new ArrayList([{contextName: 'StartInteraction'}]);
					contextMenuList.height=27;
				}
			}
			//contextMenuList.height=54;
		}
		contextMenuList.dataProvider=valuesArray;
		contextMenuList.visible=true;
		contextMenuList.labelField='contextName';
		userGrid.addChild(contextMenuList);
		contextMenuList.addEventListener(MouseEvent.CLICK, callMenuFunctions);
	}
	else if ((classRoomComp.getUserSO(selectedUserName).userRole == Constants.PRESENTER_ROLE || classRoomComp.getUserSO(selectedUserName).isModerator) && ClassroomContext.userVO.userName != selectedUserName && calculateListValue())
	{
		/**No Private chat feature for web.*/
		applicationType::desktop
		{
			valuesArray=new ArrayList([{contextName: 'Private Chat'}]);
			contextMenuList.height=27;
			contextMenuList.dataProvider=valuesArray;
			contextMenuList.visible=true;
			contextMenuList.labelField='contextName';
			userGrid.addChild(contextMenuList);
			contextMenuList.addEventListener(MouseEvent.CLICK, callMenuFunctions);
		}
	}
	else if (ClassroomContext.userVO.userName == selectedUserName && classRoomComp.getUserSO(selectedUserName).isModerator && ClassroomContext.currentPresenterName != ClassroomContext.moderatorName && calculateListValue())
	{
		if (classRoomComp.getUserSO(selectedUserName).userStatus == Constants.ACCEPT)
		{
			valuesArray=new ArrayList([{contextName: 'StopInteraction'}]);
			contextMenuList.height=27;
		}
		else
		{
			valuesArray=new ArrayList([{contextName: 'StartInteraction'}]);
			contextMenuList.height=27;
		}
		contextMenuList.dataProvider=valuesArray;
		contextMenuList.visible=true;
		contextMenuList.labelField='contextName';
		userGrid.addChild(contextMenuList);
		contextMenuList.addEventListener(MouseEvent.CLICK, callMenuFunctions);
	}
	else if (ClassroomContext.userVO.userName == selectedUserName && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName)
	{
		actionButtons.setupUserActionButtonsOnSelection();
	}
	
	//END------------------------------
	
}


/**
 * @public
 * Function is used to hide contextmenu from userlist.
 */
public function hideMenu():void
{
	try
	{
		if (Log.isDebug()) log.debug("hideMenu:- lastRollOverIndex:," + lastRollOverIndex.toString() + ", userGrid.selectedIndex:" + userGrid.selectedIndex.toString());
		if(contextMenuList && userGrid.contains(contextMenuList))
		{
			userGrid.removeChild(contextMenuList);
		}
	}
	catch (err:Error)
	{
		if(Log.isError()) log.error("Error in hideMenu method:"+ err.getStackTrace());
	}
}


/**
 * @private
 * Function is used for redirecting to other functions according to users selection from contextmenu.
 * @param event type MouseEvent
 * 
 */
private function callMenuFunctions(e:MouseEvent):void
{
	/**START-------------------------------
	//Check if selected option is ViewVideo
	//If yes,redirect to callViewStudent().
	//END---------------------------------*/
	if (contextMenuList.selectedItem.contextName == "ViewVideo")
		classRoomComp.callViewStudent();
	
	/**START-------------------------------
	//Check if selected option is CloseVideo
	//If yes,redirect to closeViewStudent().
	//END---------------------------------*/
	if (contextMenuList.selectedItem.contextName == "CloseVideo")
		classRoomComp.closeViewStudent();
	
	/**START-------------------------------
	//Check if selected option is StartInteraction
	//If yes,redirect to Accept().
	//END--------------------------------- */
	if (contextMenuList.selectedItem.contextName == "StartInteraction")
		classRoomComp.acceptViewer();
	
	/**START-------------------------------
	//Check if selected option is StopInteraction
	//If yes,redirect to Reject().
	//END---------------------------------*/
	if (contextMenuList.selectedItem.contextName == "StopInteraction")
		classRoomComp.rejectViewer();
	
	if (contextMenuList.selectedItem.contextName == "Private Chat")
	{
		(new UserHelper()).getUserByUserName(selectedUserName,dispatchPrivateChatEvent);
	}
	
	userGrid.removeChild(contextMenuList);
}


private function dispatchPrivateChatEvent(userVO:UserVO):void
{
	this.dispatchEvent(new ChatEvent(ChatEvent.INITIATE_PRIVATE_CHAT,userVO,null,null,null));
}

/**
 * @private
 * @return Boolean
 * 
 */
private function calculateListValue():Boolean
{
	var isValueSet:Boolean=false;
	contextMenuList=new List();
	contextMenuList.width=100;
	
	var selected_X:int =userGrid.mouseX;
	var selected_Y:int =userGrid.mouseY;
	
	var menu_Height:int =usersArray.length * 40;
	if (Log.isDebug()) 		FlexGlobals.topLevelApplication.mainApp.log.debug("selected_X " + selected_X + " selected_Y " + selected_Y + " menu_Height " + menu_Height.toString());
	if (selected_Y > (menu_Height + 40))
		return isValueSet;
	
	isValueSet=true;
	
	var max_X:int=userGrid.width - contextMenuList.width - 2;
	
	if (selected_X >= max_X)
	{
		selected_X=max_X;
	}
	if (lastRollOverIndex == 0 && selected_Y > 34)
	{
		contextMenuList.x=selected_X;
		contextMenuList.y=23;
	}
	else
	{
		contextMenuList.x=selected_X;
		if (selected_Y >= menu_Height)
		{
			contextMenuList.y=menu_Height - 10;
		}
		else
		{
			contextMenuList.y=selected_Y;
		}
	}
	
	return isValueSet;
}
/**
 * @private 
 * When the new user sync event comes in, this function is called to
 * build the latest users array and sort them based on their
 * moderator flag,usertype,role, status and control status
 * @return Array
 * 
 */
private function getLatestSortedUsersArray():Array
{
	/**Array to hold the accepted viewer's list - SVRS - Issue no 64 */
	var acceptedUsersArray:Array=new Array();
	
	/**Array to hold the handraised viewer's list - SVRS - Issue no 64 */
	var waitingTeachersArray:Array=new Array();
	
	/**Array to hold the handraised viewer's list - SVRS - Issue no 64 */
	var waitingStudentsArray:Array=new Array();
	
	/**Array to hold the hold and view viewer's list - SVRS - Isuue no 64*/
	var holdTeachersArray:Array=new Array();
	
	/**Array to hold the hold and view viewer's list - SVRS - Isuue no 64*/
	var holdStudentsArray:Array=new Array();
	
	/**Array to hold the Guest uesr list*/
	var guestStudentsArray:Array=new Array();
	
	var concatedUsersData:Array=new Array();
	
	/**Array to hold the hold and view presenter's list - SVRS - Isuue no 64 */
	var presenterUserProperty:Object;
	
	/**Array to hold the moderator User name */
	var moderatorUserProperty:Object;
	
	/**Array to hold the VIEWERS requesting PRESENTER role*/
	var presenterRequestArray:Array=new Array();
	
	/**Array to hold the total sorted user list.SVRS- Issue no 64 */
	var sortedUserData:Array=new Array();
	
	for (var uName:String in classRoomComp.usersCollaborationObject.getData())
	{
		/**Issue #85 & #21 --START 
		 * variable of type object used to hold the 'name' and 'status' of the active users.
		 * The 'List' component in the uselist uses this object to display the name and icon(refer: list_iconFunc(item:Object))*/
		var userObject:Object=new Object();
		
		/**user name */
		userObject.id=uName;
		/**display name */
		userObject.label=classRoomComp.usersCollaborationObject.getData()[uName].userDisplayName;
		userObject.userId=classRoomComp.usersCollaborationObject.getData()[uName].userId;
		/**user status */
		userObject.data=new UserSOValue(classRoomComp.usersCollaborationObject.getData()[uName]);
		
		userObject.requestTime=userObject.data.requestTime;
		
		if (classRoomComp.getUserSO(uName).isModerator == true)
		{
			moderatorUserProperty=userObject;
		}
		else if (classRoomComp.getUserSO(uName).userRole == Constants.PRESENTER_ROLE)
		{
			presenterUserProperty=userObject;
		}
		else if (classRoomComp.getUserSO(uName).userType == Constants.GUEST_TYPE)
		{
			guestStudentsArray.push(userObject);
		}
		else if (isSortBoxChecked)
		{
			if (classRoomComp.getUserSO(uName).userStatus == Constants.ACCEPT)
			{
				acceptedUsersArray.push(userObject);
			}
			else if (classRoomComp.getUserSO(uName).userStatus == Constants.WAITING)
			{
				if (classRoomComp.getUserSO(uName).userType == Constants.TEACHER_TYPE)
				{
					waitingTeachersArray.push(userObject);
				}
				else
				{
					waitingStudentsArray.push(userObject);
				}
			}
			else if (classRoomComp.getUserSO(uName).controlStatus == Constants.PRSNTR_REQUEST)
			{
				presenterRequestArray.push(userObject);
			}
			else
			{
				if (classRoomComp.getUserSO(uName).userType == Constants.TEACHER_TYPE)
				{
					holdTeachersArray.push(userObject);
				}
				else
				{
					holdStudentsArray.push(userObject);
				}
			}
		}
		else
		{
			acceptedUsersArray.push(userObject);
		}
	}
	
	if (moderatorUserProperty != null)
	{
		sortedUserData.push(moderatorUserProperty);
	}
	
	if (presenterUserProperty != null)
	{
		sortedUserData.push(presenterUserProperty);
	}
	
	guestStudentsArray.sortOn("label", Array.CASEINSENSITIVE);
	acceptedUsersArray.sortOn("label", Array.CASEINSENSITIVE);
	
	if (isSortBoxChecked)
	{
		holdTeachersArray.sortOn("label", Array.CASEINSENSITIVE);
		holdStudentsArray.sortOn("label", Array.CASEINSENSITIVE);
		presenterRequestArray.sortOn("requestTime", Array.NUMERIC);
		waitingTeachersArray.sortOn("requestTime", Array.NUMERIC);
		waitingStudentsArray.sortOn("requestTime", Array.NUMERIC);
		concatedUsersData=sortedUserData.concat(acceptedUsersArray, presenterRequestArray, waitingTeachersArray, holdTeachersArray, waitingStudentsArray, holdStudentsArray, guestStudentsArray);
	}
	else
	{
		concatedUsersData=sortedUserData.concat(acceptedUsersArray, guestStudentsArray);
	}
	return concatedUsersData; //,presenterRequestArray,waitingTeachersArray,holdTeachersArray,waitingStudentsArray,holdStudentsArray);
}

/**
 *@public 
 * 
 */
public function setUserListDataProvider():void
{
	applyFilters();
	var updateUserList:Boolean=false;
	var previousUsers_SO:Array=classRoomComp.previousUsers_SO;
	var usersCollaborationData:Object=classRoomComp.usersCollaborationObject.getData();
	if(offlineUsersList.includeInLayout && offlineUsersList.height>0)
	{
		if(previousUsers_SO==null ||previousUsers_SO.length==0||
			previousUsers_SO.length!=userGrid.dataProvider.length)
		{			
			updateUserList=true;
		}
			//TODO rewrite this part
		else if(classRoomComp.usersCollaborationObject)
		{			
			for (var uName:String in usersCollaborationData)
			{
				for(var index:int=0;index<previousUsers_SO.length;index++)
				{
					if(previousUsers_SO[index].id==uName)
					{
						updateUserList=false;
						break;
					}
					else
					{
						updateUserList=true;
					}
				}
			}
		}
		
	}
	if(updateUserList)
	{
		getClassRegisters();
	}		
}

/**
 * @public 
 * @param sort of type Boolean
 * 
 */
public function setSortingOption(sort:Boolean):void
{
	/**removed the automatic userlist sorting feature from the top of the userlist and added it to the left side of exitbutton 
	 * in the classroom_canvas for this new change there is no need for the below checking */
	isSortBoxChecked=sort;
	sortUserList();
}

/**
 * @public
 * 
 */
public function sortUserList():void
{
	sortedPushToTalkArray=getLatestSortedUsersArray();
	setUserListDataProvider();
}



/**
 *@public 
 * 
 */
public function setUserListSelection():void
{
	if (selectedUserName != null)
	{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("selectedUserName" + selectedUserName);
		var sortedUserArray:Array=getLatestSortedUsersArray()
		for (var i:int=0; i < sortedUserArray.length; i++)
		{
			if (sortedUserArray[i].id == selectedUserName)
			{
				userGrid.selectedIndex=i;
				//selectedUserName=null;
				break;
			}
		}
		applicationType::desktop{
			actionButtons.setupUserActionButtonsOnSelection();
		}
		applicationType::web{
			//For Guest Login
			if(ClassroomContext.userVO.role != Strings.GUEST_TYPE)
			{
				actionButtons.setupUserActionButtonsOnSelection();
			}
		}
	}
	else
	{
		userGrid.selectedIndex=lastRollOverIndex;
		if (Log.isDebug()) 			FlexGlobals.topLevelApplication.mainApp.log.debug("selectedUserName null")
	}
	userGrid.verticalScrollPosition=lastScrollPosition;
}


/**	
 * @public
 * 	S T A R T    O F
 * Determine the role / activity status and display the same. The role(s) identified and displayed are:
 * 		"Moderator"
 * 		"Moderator / Presenter"
 * 		"Presenter"
 * 		"Viewer"
 * 		"Viewer - Interaction"
 *  @param selectedUName of type String
 */

public function setRoleStatusDisplay(selectedUName:String):void
{
	if (selectedUName == Constants.FREETALK)
	{
		if (ClassroomContext.isModerator)
		{
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR_PRESENTER;
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR;
			}
		}
		else
		{
			if (classRoomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_PRESENTER;
			}
			else
			{
				if (classRoomComp.classroomContextObj.userRole == Constants.VIEWER_ROLE)
				{
					if (classRoomComp.getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER_INTERACTION;
					}
					else
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER;
					}
				}
			}
		}
	}
	else
	{
		var previousUsersSOState:Object=classRoomComp.getPreviousState(selectedUserName);
		
		if (ClassroomContext.userVO.userName == selectedUName)
		{
			if (classRoomComp.usersCollaborationObject.getData()[selectedUName].isModerator == true)
			{
				if (classRoomComp.getUserSO(selectedUName).userRole == Constants.PRESENTER_ROLE)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR_PRESENTER;
				}
				else
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR;
				}
			}
			else
			{
				if (classRoomComp.getUserSO(selectedUName).userRole == Constants.PRESENTER_ROLE)
				{
					if (notifyPresenter)
					{
						MessageBox.show(Constants.PRESENTER_NOTIFICATION, null, MessageBox.MB_NOTIF_OK, null, null, null, null, MessageBox.MSG_IMG_PRSNTR);
						notifyPresenter=false;
					}
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_PRESENTER;
				}
				else
				{
					if (classRoomComp.getUserSO(selectedUName).userRole == Constants.VIEWER_ROLE)
					{
						if (classRoomComp.getUserSO(selectedUName).userStatus == Constants.ACCEPT && (previousUsersSOState == null || previousUsersSOState.userStatus != Constants.ACCEPT))
						{
							if (notifySelectedViewer)
							{
								MessageBox.show(Constants.INTERACT_NOTIFICATION, null, MessageBox.MB_NOTIF_OK, null, null, null, null, MessageBox.MSG_IMG_INTRACT)
								notifySelectedViewer=false;
							}
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER_INTERACTION;
						}
						else
						{
							if (classRoomComp.getUserSO(selectedUName).userStatus == Constants.ACCEPT)
							{
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER_INTERACTION;
							}
							else
							{
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER;
							}
						}
						
					}
				}
			}
		}
	}
}

/**		E N D    O F
 * Determine the role / activity status and display the same. The role(s) identified and displayed are:
 * 		"Moderator"
 * 		"Moderator / Presenter"
 * 		"Presenter"
 * 		"Viewer"
 * 		"Viewer - Interaction"
 */


/**		S T A R T    O F
 * Update the Talk / Mute status and display. The displayed conditions are:
 * 		"Viewer - Talk"
 * 		"Viewer - Muted"
 * 		"Moderator - Muted"
 * 		"Presenter - Muted"
 * 		"Moderator / Presenter - Muted"
 */
/**
 * public 
 * @param selectedUser of type String
 * 
 */
public function setTalkMuteStatusDisplay(selectedUser:String):void
{
	var previousAudioUser:String=classRoomComp.previousAudioMute_COData;
	var uName:String=ClassroomContext.userVO.userName;
	
	if (classRoomComp.getUserSO(uName) != null)
	{
		if (classRoomComp.latestAudioMute_COData != Constants.FREETALK && previousAudioUser != Constants.FREETALK)
		{
			if (uName == selectedUser || uName == previousAudioUser || uName == ClassroomContext.currentPresenterName || uName == ClassroomContext.moderatorName)
			{
				if (uName == ClassroomContext.currentPresenterName || uName == ClassroomContext.moderatorName)
				{
					setTalkMuteAtPresenter(selectedUser, previousAudioUser);
				}
				else
				{
					setTalkMuteAtViewer(selectedUser, previousAudioUser);
				}
			}
		}
		else
		{
			if (classRoomComp.latestAudioMute_COData == Constants.FREETALK && previousAudioUser != Constants.FREETALK)
			{
				setRoleStatusDisplay(Constants.FREETALK);
			}
		}
	}
}



/**
 * @public
 * @param selectedUser of type String
 * @param previousAudioUser of type String
 * 
 */
public function setTalkMuteAtPresenter(selectedUser:String, previousAudioUser:String):void
{
	if (selectedUser != ClassroomContext.currentPresenterName && selectedUser != ClassroomContext.moderatorName)
	{
		if (ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName && ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MOD_PRSNTR_MUTED;
		}
		else
		{
			if (ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_PRESENTER_MUTED;
			}
			if (ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR_MUTED;
			}
		}
	}
	else
	{
		if (selectedUser == ClassroomContext.currentPresenterName || selectedUser == ClassroomContext.moderatorName)
		{
			if (ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName && ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR_PRESENTER;
			}
			else
			{
				if (ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_PRESENTER;
				}
				if (ClassroomContext.userVO.userName == ClassroomContext.moderatorName)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_MODERATOR;
				}
				
			}
		}
	}
}

/**
 * @public 
 * @param selectedUser of type String
 * @param previousAudioUser of type String
 * 
 */
public function setTalkMuteAtViewer(selectedUser:String, previousAudioUser:String):void
{
	var uName:String=ClassroomContext.userVO.userName;
	var previousUsersSOState:Object=classRoomComp.getPreviousState(previousAudioUser);
	var previousUserStatus:String=previousUsersSOState.userStatus;
	
	var alertTimer:Timer;
	
	alertTimer=new Timer(3000, 1);
	alertTimer.addEventListener(TimerEvent.TIMER_COMPLETE, removeMessageBox);
	
	if (classRoomComp.getUserSO(uName) != null)
	{
		if (classRoomComp.latestAudioMute_COData == Constants.FREETALK && (uName != ClassroomContext.isModerator || uName != ClassroomContext.currentPresenterName))
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER;
		}
		else
		{
			if (classRoomComp.latestAudioMute_COData != Constants.FREETALK && (uName != ClassroomContext.isModerator || uName != ClassroomContext.currentPresenterName))
			{
				if (classRoomComp.presenterReset == true)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER;
					return;
				}
				if ((selectedUser != ClassroomContext.currentPresenterName && selectedUser != ClassroomContext.isModerator))
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER_TALK;
					alert=MessageBox.show(Constants.TALK_NOTIFICATION, null, MessageBox.MB_NOTIF, null, null, null, null, MessageBox.MSG_IMG_TALK);
					alertTimer.start();
					return;
				}
				else
				{
					if (selectedUser != previousAudioUser && previousUserStatus != Constants.HOLD)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.role_status_display.text=Constants.ROLE_STATUS_DISPLAY_VIEWER_MUTED;
						alert=MessageBox.show(Constants.MUTE_NOTIFICATION, null, MessageBox.MB_NOTIF, null, null, null, null, MessageBox.MSG_IMG_MUTE);
						alertTimer.start();
						return;
					}
				}
			}
			else
			{
				if (classRoomComp.latestAudioMute_COData == Constants.FREETALK && (uName == ClassroomContext.isModerator || uName == ClassroomContext.currentPresenterName))
				{
					setRoleStatusDisplay(Constants.FREETALK);
				}
			}
		}
	}
}

/**
 * @public 
 * @param evt of type TimerEvent
 * 
 */
private function removeMessageBox(evt:TimerEvent):void
{
	PopUpManager.removePopUp(alert);
}

private function logoutHandler(event:ApplicationStatusEvent):void
{
	clearEventMap();
}

private function clearEventMap():void
{
	this.classRoomModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, logoutHandler);
	this.classRoomModuleRO.moduleEventMap.unregisterInitiator(this,ChatEvent.INITIATE_PRIVATE_CHAT);
}

/**		E N D    O F
 * Update the Talk / Mute status and display. The displayed conditions are:
 * 		"Viewer - Talk"
 * 		"Viewer - Muted"
 * 		"Moderator - Muted"
 * 		"Presenter - Muted"
 * 		"Moderator / Presenter - Muted"
 */


protected function showHideclickHandler(event:MouseEvent):void
{	
	
	// TODO Auto-generated method stub
	if (offlineUsersList.height == 0)
	{
		getClassRegisters();
		offlineUsersList.height=200;
		offlineUserExpand.play();
		offlineUserColapse.stop();
		offlineUsersList.visible=true;
		imgArrowDown.visible=true;
		imgArrowDown.includeInLayout=true;
		imgArrowUp.visible=false;
		imgArrowUp.includeInLayout=false;
	}
	else
	{
		offlineUsersList.height=0;
		offlineUserColapse.play();
		offlineUserExpand.stop();
		offlineUsersList.visible=false;
		imgArrowDown.visible=false;
		imgArrowDown.includeInLayout=false;
		imgArrowUp.visible=true;
		imgArrowUp.includeInLayout=true;
	}
}
public function getClassRegisters():void
{
	var classRegHelper:ClassRegistrationHelper = new ClassRegistrationHelper();
	classRegHelper.getClassRegistersForClass(ClassroomContext.aviewClass.classId,getClassRegistersForClassResultHandler,null);
}

public function getClassRegistersForClassResultHandler(classReg:ArrayCollection):void
{
	classMembers=classReg;
	offlineUsersArray.removeAll();
	var registeredUsersArray:ArrayCollection = classReg ;	
	for(var i:int = 0; i < registeredUsersArray.length; i++)
	{
		var userExist:Boolean=false;
		var offlineUser:Object=registeredUsersArray[i];
		if(userGrid.dataProvider!=null)
		{
			for (var index:int=0;index<userGrid.dataProvider.length;index++)
			{
				if(registeredUsersArray[i].user.userId == userGrid.dataProvider[index].userId )
				{
					userExist=true;
					break;
				}
			}
		}
		if(!userExist)
		{
			//TODO: add userstatus changehandler ?
			//offlineUser.user.userStatus=onlineUserConnection.getUserStatus(offlineUser.user.userName);
			offlineUsersArray.addItem(ObjectUtil.copy(offlineUser));
		}
	}
} 
public function changeOnlineUserStatus(event:ContactsEvent):void
{
	var data:Object=event.data ;
	for (var indexs:int=0; indexs < offlineUsersArray.length; indexs++)
	{
		var userObj:Object=offlineUsersArray.getItemAt(indexs).user;
		if(userObj.userName==data.name)
		{
			userObj.userStatus=data.userStatus;
		}
	}
	offlineUsersArray.refresh();
}
