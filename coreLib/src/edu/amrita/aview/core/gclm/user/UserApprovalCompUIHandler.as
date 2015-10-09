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
 * File			: UserApprovalCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.UserVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

/**
 *  To track if the user has clicked on cancel button 
 */
public var hasClickedCancelButton:Boolean=true;
/**
 *  To hold the list of pending users for registration 
 */
[Bindable]
private var pendingUsersAC:ArrayCollection=new ArrayCollection();

/**
 *  To track if the user has performed atleast one approval action 
 */
private var isApprovalActionPerformed:Boolean=false;

/**
 *  The helper class to communicate to server 
 */
private var userHelper:UserHelper=null;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.user.UserApprovalCompUIHandler.as");

/**
 * @public
 * This function sets all the initial info that is required for the User Approval comp.
 * This function is called from UserComp.mxml
 *
 * @return void
 */
public function init():void
{
	userHelper=new UserHelper();
	hasClickedCancelButton=true;
	setApprovalActionPerformed(false);
	resetSmartCombos();
}

/**
 * @public
 * This function is the result handler for the pending approval user search
 * @param users type of ArrayCollection
 * @return void
 */
public function searchPendingUsersResultHandler(users:ArrayCollection):void
{
	//Check for null value from the result handler
	if (users != null)
	{
		clearPendingApprovals();
		//Check for empty value in the result handler
		if (users.length > 0)
		{
			var tmpAC:ArrayCollection=users;
			var obj:UserVO;
			for (var i:int=0; i < tmpAC.length; i++)
			{
				obj=new UserVO();
				obj=ObjectUtil.copy(tmpAC[i]) as UserVO;
				obj.isSelected=false;
				pendingUsersAC.addItem(obj);
			}
			pendingUsersAC.refresh();
		}
		//Check if previously approval action has been performed. If so, 
		//after refreshing, if there is no other users for approval display the message
		//accordingly
		else if (!isApprovalActionPerformed)
		{
			CustomAlert.info("No pending users are available");
		}
	}
	//Check if previously approval action has been performed. If so, 
	//after refreshing, if there is no other users for approval display the message
	//accordingly
	else if (!isApprovalActionPerformed)
	{
		CustomAlert.info("No data found for the given criteria");
	}
	setApprovalActionPerformed(false);
}

/**
 * @public
 * This function is the fault handler for the search users for pending approval
 * @param event type of FaultEvent
 * @return void
 */
public function searchPendingUsersFaultHandler(event:FaultEvent):void
{
	clearPendingApprovals();
	setApprovalActionPerformed(false);
	userHelper.genericFaultHandler(event);
}

/**
 * @public
 * The result handler of the pending approval
 * @param event type of ResultEvent
 * @return void
 */
public function approvePendingUsersResultHandler(event:ResultEvent):void
{
	CustomAlert.info("User(s) approved successfully");
	hasClickedCancelButton=false;
	setApprovalActionPerformed(true);
	searchPendingApprovals();
}

/**
 * @public
 * This function is the fault handler after calling the pending approval
 * @param event type of FaultEvent
 * @return void
 */
public function approvePendingUsersFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::user::UserApprovalCompUIHandler::approvePendingUsersFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	hasClickedCancelButton=false;
	CustomAlert.error("Fault occured while activating users. Please contact administrator");
}
/**
 * @private
 * This function resets all the search criteria information
 *
 * @return void
 */
private function resetSmartCombos():void
{
	edtCmbInstitutes.filterString="";
	edtCmbInstitutes.selectedItem=null;
}

/**
 * @private
 * This function sets to true, if atleast one approval action is performed
 * @param flag type of Boolean
 * @return void
 */
private function setApprovalActionPerformed(flag:Boolean):void
{
	isApprovalActionPerformed=flag;
}

/**
 * @private
 * This function is to search for the pending 
 * approval users based on the given search criteria if any
 *
 * @return void
 */
private function searchPendingApprovals():void
{
	var firstName:String=null;
	var lastName:String=null;
	var userName:String=null;
	var role:String=null;
	var location:String=null;
	var instituteId:Number=0;
	//Check for null and empty values
	if ((edtCmbInstitutes.text != "") && (edtCmbInstitutes.selectedItem != null) && (edtCmbInstitutes.selectedItem.instituteId != 0))
	{
		instituteId=edtCmbInstitutes.selectedItem.instituteId;
	}
	else if (edtCmbInstitutes.text != "")
	{
		CustomAlert.info("Please search with a valid Institute");
		return;
	}
	//Check for null value
	if (txtInpUserName.text != '')
	{
		userName=txtInpUserName.text;
	}
	//Check for the user role and call the appropriate API with their respective parameters
	if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
	{
		userHelper.searchPendingUsers(firstName, lastName, userName, role, location, instituteId,searchPendingUsersResultHandler,searchPendingUsersFaultHandler);
	}
	else if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		userHelper.searchPendingUsers( firstName, lastName, userName, role, location, instituteId, searchPendingUsersResultHandler,searchPendingUsersFaultHandler,ClassroomContext.userVO.userId);
	}
}

/**
 * @private
 * This function is to select/deselect 
 * each of the pending users, depends upon
 * selecting the Select All radio button
 *
 * @return void
 */
private function toggleAllPendingUsersSelection():void
{
	var flag:Boolean=cbSelectAllPendingUsers.selected;
	var i:int=0;
	//If select all check box is selected, then make all the pending users 
	//as selected
	for (i=0; i < pendingUsersAC.length; i++)
	{
		pendingUsersAC[i].isSelected=flag;
	}
	pendingUsersAC.refresh();
}

/**
 * @private
 * This function is to select/deselect Select 
 * All radio button, If any of the selected user in
 * group is deselected, then Select All is also deselected
 *
 * @return void
 */
private function togglecbSelectAllPendingUsers():void
{
	var flag:Boolean=true;
	for (var i:int=0; i < pendingUsersAC.length; i++)
	{
		//In case of select all, if any one user name is un selected
		//then make the select all check box un selected
		if (pendingUsersAC[i].isSelected == false)
		{
			flag=false;
			break;
		}
	}
	cbSelectAllPendingUsers.selected=flag;
}

/**
 * @private
 * This function is to confirm all the pending user approvals
 *
 * @return void
 */
private function saveUserApprovals():void
{
	var userIds:Array=new Array();
	//Iterate the list of pending users list to get the list of users who have
	//been selected for approval
	for (var i:int=0; i < pendingUsersAC.length; i++)
	{
		//Check for the selected status. If selected, add the user for approval
		if (pendingUsersAC[i].isSelected)
		{
			userIds.push(pendingUsersAC[i].userId);
		}
	}
	//If the selected users for approval length is 0, then alert the user 
	if (userIds.length == 0)
	{
		CustomAlert.info("Please select atleast one user to approve");
	}
	else
	{
		userHelper.approvePendingUsers(userIds, ClassroomContext.userVO.userId,approvePendingUsersResultHandler);
	}
}

/**
 * @private
 * This function is called when the user clicks 
 * to close the user approval comp window
 *
 * @return void
 */
private function closeUserApprovalComp():void
{
//	institutesAC.removeAll();
	clearPendingApprovals();
	if(Log.isDebug()) log.debug("Create user comp closed");
	PopUpManager.removePopUp(this);
}

/**
 * @private
 * This function is to reset all the search data
 *
 * @return void
 */
private function resetData():void
{
	txtInpUserName.text="";
	edtCmbInstitutes.selectedItem=null;
	edtCmbInstitutes.filterString="";
	clearPendingApprovals();
}

/**
 * @private
 * This function is clear all the pending user approvals if any
 *
 * @return void
 */
private function clearPendingApprovals():void
{
	pendingUsersAC.removeAll();
	cbSelectAllPendingUsers.selected=false;
}