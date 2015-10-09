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
 * File			: UserCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 *
 *
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.user.ChangePasswordComp;
import edu.amrita.aview.core.gclm.user.CreateUserComp;
import edu.amrita.aview.core.gclm.user.UserApprovalComp;
import edu.amrita.aview.core.gclm.vo.UserVO;
import edu.amrita.aview.core.login.MainApp;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.AViewStringUtil;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.core.FlexGlobals;
import mx.core.FlexTextField;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import objectResolver.EntryFac;

/**
 *  Class variables to hold the icon images 
 */
[Bindable]
[Embed(source="../assets/images/create.png")]
private var createIconEnabled:Class;
[Bindable]
private var CreateIcon:Class;
[Bindable]
[Embed(source="../assets/images/delete.png")]
private var deleteIconEnabled:Class;
[Bindable]
private var DeleteIcon:Class;
[Bindable]
[Embed(source="../assets/images/edit.png")]
private var updateIconEnabled:Class;
[Bindable]
private var UpdateIcon:Class;
[Bindable]
private var hasEditPermission:Boolean=true;
[Bindable]
private var users:ArrayCollection=new ArrayCollection();
//Fix for Bug #19548 :Added Monitor role.
[Bindable]
private var userRole:Array=new Array("ALL", "STUDENT", "TEACHER", "ADMINISTRATOR","MONITOR");

/**
 * To hold the search string of the role name. Used to filter the registered users based on role
 */ 
private var roleSearch:String=null;
/**
 * To hold the search string of the user name. Used to filter the registered users based on username
 */
private var usernameSearch:String=null;
/**
 * To hold the search string of the fname. Used to filter the registered users based on users' first name
 */ 
private var fnameSearch:String=null;
/**
 * To hold the search string of the user city. Used to filter the registered users based on users' city
 */
private var userCitySearch:String=null;
/**
 * To hold the search string of the user last name. Used to filter the registered users based on users' last name
 */
private var lnameSearch:String=null;
/**
 * The selected instititute id from which the users needs to be searched
 */
private var selectedInstituteId:Number=0;
/**
 * To check if the search button is clicked. This is required when any update/create happens 
 * in the new window, and the search result needs the updated info
 */
private var hasClickedSearchButton:Boolean=false;

/**
 * The helper classes for communicating to the server
 */
private var userHelper:UserHelper=null;
private var classRegistrationHelper:ClassRegistrationHelper=null;
public var entryFac:EntryFac = new EntryFac;
[Bindable]
public var faceRegisteration;
/**
 * @public
 * This function sets all the initial info that is required for the User comp.
 * This function is called from Administration.mxml
 *
 * @return void
 */
public function initApp():void
{
	userHelper=new UserHelper();
	classRegistrationHelper=new ClassRegistrationHelper();
	reset();
	setIcons();
	//Check the logged in user privilege. accordingly enable the action buttons
	// Fix for Bug #19529 start
	// Fix for Bug #19717 start 
	if ( (ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || 
		 (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) ||
		 (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
		// Fix for Bug #19529 end
		// Fix for Bug #19717 end
	{
		disableAllActionButtions();
		disableSearchFilters();
		getActiveUsers();
	}
	else
	{
		GCLMContext.allInstitutesAC.filterFunction=null;
		GCLMContext.allInstitutesAC.refresh();
	}
}

/**
 * @public
 * This function is the result handler for the search criteria
 * @param tmpUsers type of ArrayCollection
 * @return void
 */
public function searchActiveUsersResultHandler(tmpUsers:ArrayCollection):void
{
	clearUsers();
	//If the result is null, do nothing else update the window with the result
	if (tmpUsers != null)
	{
		if (tmpUsers.length == 0)
		{
			CustomAlert.info("No Users found for the given search criteria");
		}		
		else
		{
			users=tmpUsers;
		}
	}
}

/**
 * @public
 * This function is the result handler for fecthing the user details
 * @param userVo type of UserVO
 * @return void
 */
public function getUserResultHandlerForUpdate(userVo:UserVO):void
{
	var editUserComp:CreateUserComp=new CreateUserComp();
	PopUpManager.addPopUp(editUserComp, this, true, null);
	PopUpManager.centerPopUp(editUserComp);
	editUserComp.title="Edit User";
	editUserComp.addEventListener(FlexEvent.REMOVE, getActiveUsersOnUpdate);
	editUserComp.init(userVo);
}

/**
 * @public
 * The result handler for the delete user
 * @param event type of ResultEvent
 * @return void
 */
public function deleteUserResultHandler(event:ResultEvent):void
{
	CustomAlert.info("User deleted successfully");
	//If any previos search has been performed, try a new search as the deleted user info has to be removed from
	//the screen
	if (users.length > 1)
	{
		getActiveUsers();
	}
	else
	{
		clearUsers();
	}
}

/**
 * @public
 * This function is the result handler for 
 * checking if the user has registered for any classes.
 * This checking is done before deleting the user.
 * @param count type of Number
 * @return void
 */
public function getUserClassRegistrationCountResultHandler(count:Number):void
{
	//Check if the users who have been marked for deletion is registered for any class.
	//If so, get confirmation from the admin to proceed with the deletion
	if (count > 0)
	{
		CustomAlert.confirm("Deleting the user will delete the classes registered for that user.Are you sure you want to delete the selected user?", "Confirmation", confirmDeleteUser);
	}
	else
	{
		CustomAlert.confirm("Are you sure you want to delete the selected user?", "Confirmation", confirmDeleteUser);
		;
	}
}

/**
 * @private
 * This function set the required icons for the control buttons
 *
 * @return void
 */
private function setIcons():void
{
	CreateIcon=createIconEnabled;
	UpdateIcon=updateIconEnabled;
	DeleteIcon=deleteIconEnabled;
}

/**
 * @private
 * This function resets all the initial data and search results if any
 *
 * @return void
 */
private function reset():void
{
	clearUsers();
	resetSearchItems();
}

/**
 * @private
 * This function resets all the search data entered by the user
 *
 * @return void
 */
private function resetSearchItems():void
{
	hasClickedSearchButton=false;
	edtCmbInstitute.selectedItem=null;
	edtCmbInstitute.filterString="";
	txtInpSearchCity.text="";
	txtInpSearchUserName.text="";
	txtInpSearchLastName.text="";
	txtInpSearchFirstName.text="";
	cmbSearchRole.selectedIndex=0;
	hasEditPermission=true;
	resetSearchVariables();
}

/**
 * @private
 * This function resets all the search criteria 
 * that was entered by the user
 *
 * @return void
 */
private function resetSearchVariables():void
{
	usernameSearch=null;
	roleSearch=null;
	fnameSearch=null;
	userCitySearch=null;
	lnameSearch=null;
	selectedInstituteId=0;
}

/**
 * @private
 * This function clears all the user info that 
 * is fetched as a result of search criteria
 *
 * @return void
 */
private function clearUsers():void
{
	//Fix for Bug # 3093 start
	// Fix for Bug #14854,#14836
	users.source = [] ;	
	//Fix for Bug # 3093 end
}

/**
 * @private
 * This function disables all the control 
 * buttons. Some actions are permissible
 * only for admins and master admins. 
 * For other users these controls are disabled
 *
 * @return void
 */
private function disableAllActionButtions():void
{
	btnCreate.visible=false;
	btnDelete.visible=false;
	btnApprove.visible=false;
	btnUserEdit.bottom="3";
	btnUserEdit.left="165";
	hasClickedSearchButton=true;
}

/**
 * @private
 * This function disables all the search 
 * criteria controls. As for non administrators
 * they can view only their info
 *
 * @return void
 */
private function disableSearchFilters():void
{
	lblUserName.visible=false;
	txtInpSearchUserName.visible=false;
	lblFirstName.visible=false;
	txtInpSearchFirstName.visible=false;
	lblLastName.visible=false;
	txtInpSearchLastName.visible=false;
	lblUserType.visible=false;
	cmbSearchRole.visible=false;
	lblCity.visible=false;
	txtInpSearchCity.visible=false;
	lblInstituteName.visible=false;
	edtCmbInstitute.visible=false;
	btnSearch.visible=false;
	btnReset.visible=false;
}

/**
 * @private
 * This function enables the edit option by 
 * default if the logged user is not master admin/institute admin
 *
 * @return void
 */
private function setEditUserPermission():void
{
	if (ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE)
	{
		if ((dgUsers.selectedItem != null) && (dgUsers.selectedItem.userId != ClassroomContext.userVO.userId) && (dgUsers.selectedItem.role == Constants.ADMIN_TYPE))
		{
			hasEditPermission=false;
		}
		else
		{
			hasEditPermission=true;
		}
	}
}

/**
 * @private
 * This function is used to invoke the create 
 * user component to create a new user
 *
 * @return void
 */
private function createUser():void
{
	btnCreate.enabled=false;
	var createUserComp:CreateUserComp=new CreateUserComp();
	PopUpManager.addPopUp(createUserComp, this, true, null);
	PopUpManager.centerPopUp(createUserComp);
	createUserComp.addEventListener(FlexEvent.REMOVE, getActiveUsersOnUpdate);
	createUserComp.title="Create User";
	createUserComp.init();

}

/**
 * @private
 * This function is used to invoke the create user component to edit an existing user details
 *
 * @return void
 */
private function editUser():void
{
	var userId:Number=0;
	// In case of non adminstrators, only their user details are displayed. So even if the item is not selected
	// in the data grid, it will edit the same user details
	if ((ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
	{
		userId=users[0].userId;
	}
	else if (dgUsers.selectedItem != null)
	{
		userId=dgUsers.selectedItem.userId;
	}
	else
	{
		CustomAlert.info("Please select a user from the list");
		return;
	}
	btnUserEdit.enabled=false;
	getUserIdAndLaunchUpdateUser(userId);
}

/**
 * @private
 * This function is used to get the user details for update
 * @param userId type of Number
 * @return void
 */
private function getUserIdAndLaunchUpdateUser(userId:Number):void
{
	userHelper.getUser(userId, getUserResultHandlerForUpdate);	
}


/**
 * @private
 * This function is to delete the selected 
 * user by master admin/institute admins
 *
 * @return void
 */
private function deleteUser():void
{
	//Check if user has been selected for deletion
	if (dgUsers.selectedIndex == -1)
	{
		CustomAlert.info("Please select a user from the list to delete");
	}
	//To prevent user from deleting his/her own account
	else if (dgUsers.selectedItem.userId == ClassroomContext.userVO.userId)
	{
		CustomAlert.info("You cannot delete your own account");
	}
	//Getting the confirmation from the user before deleting
	else
	{
		//Check if the user has registered for any class before deleting
		classRegistrationHelper.getUserClassRegistrationCount(dgUsers.selectedItem.userId,getUserClassRegistrationCountResultHandler);
	}
}

/**
 * @private
 * This function is invoke User Approve 
 * Comp by the master admin/institute admins
 *
 * @return void
 */
private function approveUsers():void
{
	btnApprove.enabled=false;
	var usersApprovalComp:UserApprovalComp=new UserApprovalComp();
	PopUpManager.addPopUp(usersApprovalComp, this, true, null);
	PopUpManager.centerPopUp(usersApprovalComp);
	usersApprovalComp.addEventListener(FlexEvent.REMOVE, getActiveUsersOnUpdate);
	usersApprovalComp.init();
}

/**
 * @private
 * This function is used to change the password for the selected user
 *
 * @return void
 */
private function changePassword():void
{
	var user:UserVO=dgUsers.selectedItem as UserVO;
	//In case of non administrators, select the first row by default
	if ((ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
	{
		user=users[0];
	}
	if (user != null)
	{
		btnChangePassword.enabled=false;
		var changePassowrdComp:ChangePasswordComp=new ChangePasswordComp();
		// Fix for Bug #6170 start
		//PopUpManager.addPopUp(changePassowrdComp, this);
		PopUpManager.addPopUp(changePassowrdComp, this, true, null);
		// Fix for Bug #6170 end
		PopUpManager.centerPopUp(changePassowrdComp);
		changePassowrdComp.addEventListener(FlexEvent.REMOVE, getActiveUsersOnUpdate);
		changePassowrdComp.init(user);
	}
	else
	{
		CustomAlert.info("Please select a user from the list to change the password");
	}
}


/**
 * @private
 * This function is to call the delete user once 
 * the user confirms the delete action
 * @param event type of CloseEvent
 * @return void
 */
private function confirmDeleteUser(event:CloseEvent):void
{
	//If the event is null, the user has not registered for any class
	if (event.detail == Alert.YES)
	{
		var userId:int;
		userId=dgUsers.selectedItem.userId;
		userHelper.deleteUser(userId, ClassroomContext.userVO.userId,deleteUserResultHandler);
	}
}

/**
 * @private
 * This function is to get the updated user info 
 * to display in the user comp. This is usually
 * required when a search is performed on certain 
 * criteria, and an edit/delete/create action happens.
 * The data might have been changed because of that 
 * action which has to be reflected in the user comp ui.
 * @param event type of FlexEvent
 * @return void
 */
private function getActiveUsersOnUpdate(event:FlexEvent):void
{
	btnCreate.enabled=true;
	btnUserEdit.enabled=true;
	btnApprove.enabled=true;
	btnChangePassword.enabled=true;
	if ((!event.target.hasClickedCancelButton) && (hasClickedSearchButton))
	{
		getActiveUsers();
	}
}


/**
 * @private
 * This function is to search for available users 
 * based on the search criteria as entered by the user
 * The search criteria could be based on Institute, 
 * First name, last name, user name, user role etc.,
 *
 * @return void
 */
private function searchActiveUsers():void
{
	resetSearchVariables();
	if (txtInpSearchUserName.text != "")
	{
		usernameSearch=txtInpSearchUserName.text;
	}
	if (cmbSearchRole.selectedItem != 'ALL')
	{
		roleSearch=cmbSearchRole.selectedItem.toString();
	}
	if (txtInpSearchFirstName.text != "")
	{
		fnameSearch=txtInpSearchFirstName.text;
	}
	if (txtInpSearchLastName.text != "")
	{
		lnameSearch=txtInpSearchLastName.text;
	}
	if ((edtCmbInstitute.text != "") && (edtCmbInstitute.selectedItem != null) && (edtCmbInstitute.selectedItem.instituteId != 0))
	{
		selectedInstituteId=edtCmbInstitute.selectedItem.instituteId;
	}
	else if (edtCmbInstitute.text != "")
	{
		CustomAlert.info("Please search with a valid Institute");
		return;
	}
	if (txtInpSearchCity.text != "")
	{
		userCitySearch=txtInpSearchCity.text;
	}
	hasClickedSearchButton=true;
	getActiveUsers();
}


/**
 * @private
 * This function calls the server for searching 
 * the user details with the given criteria
 *
 * @return void
 */
private function getActiveUsers():void
{
	//Fix for Bug # 3093 start
	//Check the user privilege and accordingly call the API to search the users based on 
	//given criteria
	if ((ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) && (hasClickedSearchButton))
	{
		userHelper.searchActiveUsers(fnameSearch, lnameSearch, usernameSearch, roleSearch, 
			userCitySearch, selectedInstituteId,searchActiveUsersResultHandler);
	}
	else if ((ClassroomContext.userVO.role == Constants.ADMIN_TYPE) && (hasClickedSearchButton))
	{
		userHelper.searchActiveUsers(fnameSearch, lnameSearch, usernameSearch, roleSearch, 
			userCitySearch, selectedInstituteId, searchActiveUsersResultHandler,null,ClassroomContext.userVO.userId);
	}
	//Fix for Bug # 3093 end
	else
	{
		// Fix for Bug #14634 , #14631 -- Added result handler for the remote call
		userHelper.getUserByUserName(ClassroomContext.userVO.userName,getUserByUserNameResultHandler);
	}
}

/**
 * @private
 * This function is to clear all the search results
 *
 * @return void
 */
private function clearValues():void
{
	resetSearchItems();
	clearUsers();
}

/**
 * @public
 *  This is result handler for  getUserByUserName function 
 * @param userVO of type UserVO
 * 
 */
// Fix for Bug #14634 , #14631 -- Added the result handler
public function getUserByUserNameResultHandler(userVO:UserVO):void {
	if (userVO != null) {
		users.source = [] ;
		users.addItem(userVO ); 	
		// Fix for Bug #11366 :Start
		ClassroomContext.userVO.fname = userVO.fname;
		ClassroomContext.userVO.lname = userVO.lname;
		ClassroomContext.setWelcomeMessage()
		// Fix for Bug #11366 :End
	}
}	

private function showFaceRegistrationModule():void
{
	faceRegisteration= entryFac.faceRegistrationForm();
	faceRegisteration.userID=ClassroomContext.userVO.userId;
	faceRegisteration.serverIP=MainApp.BIOMETRIC_SERVER;
	PopUpManager.addPopUp(faceRegisteration,FlexGlobals.topLevelApplication as DisplayObject,true);
	PopUpManager.centerPopUp(faceRegisteration);
}
private function closePopup(evt:MouseEvent):void
{
	PopUpManager.removePopUp(this);
}