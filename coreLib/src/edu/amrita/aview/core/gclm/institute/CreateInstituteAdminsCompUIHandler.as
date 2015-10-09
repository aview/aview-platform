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
 * File			: CreateInstituteAdminsCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Swati, Abhirami, Sivaram SK
 *
 * This file is the script handler for CreateInstituteAdminsComp.mxml
 *
 */
import mx.core.FlexGlobals;
import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;

import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.vo.StatusVO;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.events.InstituteAdminsSelectedEvent;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.UserVO;


import mx.logging.ILogger;
import mx.logging.Log;
/**
 * Variable to hold all the admin users which comes from the institute dialog box
 */
[Bindable]
public var selectedInstituteAdminUsers:ArrayCollection=new ArrayCollection();
/**
 * Variable to set the label for SelectInstituteAdminComp
 */
[Bindable]
public var instituteAdminTitle:String="Select Admins for the Institute ";

/**
 * Variable to hold all admin users.
 */
[Bindable]
private var allAdminUsers:ArrayCollection=new ArrayCollection();
/**
 * Variable to hold the selected admin users in this dialog box while adding/editing
 */
[Bindable]
private var selectedAdminUsers:ArrayCollection=new ArrayCollection();
/**
 * The helper class to communicate to the server
 */
private var userHelper:UserHelper=new UserHelper();

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.CreateInstituteAdminsCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the CreateInstituteAdminsComp
 * This function is called from CreateInstituteCompUIHandler.as
 *
 * @return void
 *
 ***/
public function initComp():void
{
	var userIds:Array=new Array();
	selectedAdminUsers.removeAll();
	var obj:Object=new Object();
	/**
	 * Get the selected admin users if exists */
	for (var i:int=0; i < selectedInstituteAdminUsers.length; i++)
	{
		obj=new Object();
		obj.instituteAdminUserId=selectedInstituteAdminUsers[i].instituteAdminUserId;
		obj.userId=selectedInstituteAdminUsers[i].user.userId;
		obj.userName=selectedInstituteAdminUsers[i].user.userName;
		obj.instituteName=selectedInstituteAdminUsers[i].user.instituteName;
		obj.parentInstituteName=selectedInstituteAdminUsers[i].user.parentInstituteName;
		obj.createdByUserId=selectedInstituteAdminUsers[i].createdByUserId;
		obj.createdDate=selectedInstituteAdminUsers[i].createdDate;
		obj.statusId=selectedInstituteAdminUsers[i].statusId;
		obj.statusId=selectedInstituteAdminUsers[i].user.statusId;
		obj.isSelected=false;
		obj.role=selectedInstituteAdminUsers[i].user.role;
		selectedAdminUsers.addItem(obj);
		userIds.push(obj.userId);
	}
	if (userIds.length > 0)
	{
		userHelper.getUsers(userIds,getUsersResultHandler);
	}
}

/**
 *
 * @public
 * This function is the result handler for getting the users
 * This function is made public because the UserHelper.as will call this once it
 * gets the result from the server
 * @param users : The users array collection
 * @return void
 *
 ***/
public function getUsersResultHandler(users:ArrayCollection):void
{
	if (users != null)
	{
		var tmpAC:ArrayCollection=users;
		for (var i:int=0; i < selectedAdminUsers.length; i++)
		{
			for (var j:int=0; j < tmpAC.length; j++)
			{
				if (selectedAdminUsers[i].userId == tmpAC[j].userId)
				{
					selectedAdminUsers[i].instituteName=tmpAC[j].instituteName;
					selectedAdminUsers[i].parentInstituteName=tmpAC[j].parentInstituteName;
					break;
				}
			}
		}
		selectedAdminUsers.refresh();
	}
}

/**
 *
 * @private
 * This function is to check and remove an item from the allAdminUsers
 *
 * @return void
 *
 ***/
private function setSelectInfo():void
{
	var i:int=0;
	//Remove the record from allAdminUsers, if it is already available in selected
	for (var j:int=0; j < selectedAdminUsers.length; j++)
	{
		for (i=0; i < allAdminUsers.length; i++)
		{
			allAdminUsers[i].isSelected=false;
			if (selectedAdminUsers[j].userId == allAdminUsers[i].userId)
			{
				//tmp.push(i);
				allAdminUsers.removeItemAt(i);
				break;
			}
		}
	}
	allAdminUsers.refresh();
}

/**
 *
 * @public
 * This function removes all the Institute Admin details.
 *
 * @return void
 *
 ***/
private function removeInstituteAdmins():void
{
	var obj:Object;
	var i:int=0;
	var tmp:Array=new Array();
	for (i=0; i < selectedAdminUsers.length; i++)
	{
		if(Log.isDebug()) log.debug(selectedAdminUsers[i].isSelected);
		if (selectedAdminUsers[i].isSelected == true)
		{
			tmp.push(i);
			if (selectedAdminUsers[i].statusId != StatusVO.DELETED_STATUS && selectedAdminUsers[i].role == Constants.ADMIN_TYPE)
			{
				obj=ObjectUtil.copy(selectedAdminUsers[i]);
				obj.isSelected=false;
				allAdminUsers.addItem(obj);
			}
		}
	}
	for (i=0; i < tmp.length; i++)
	{		
		selectedAdminUsers.removeItemAt(tmp[i] - i);
	}
	chkSelectAllSelectedAdminUsers.selected=false;
	tmp=[];
}

/**
 *
 * @public
 * This function sets all the initial info required for the CreateInstituteComp
 * This function is called from InstituteCompUIHandler.as
 * @param institute : The institute details to update. For create this will be null
 * @return void
 *
 ***/
private function addInstituteAdmins():void
{
	var obj:Object;
	var i:int=0;
	var tmp:Array=new Array();
	for (i=0; i < allAdminUsers.length; i++)
	{		
		if (allAdminUsers[i].isSelected == true)
		{
			obj=ObjectUtil.copy(allAdminUsers[i]);
			tmp.push(i);
			obj.isSelected=false;
			selectedAdminUsers.addItem(obj);
		}
	}
	for (i=0; i < tmp.length; i++)
	{
		allAdminUsers.removeItemAt(tmp[i] - i);
	}
	chkSelectAllAdminUsers.selected=false;
	tmp=[];

}

/**
 *
 * @public
 * This function is the result handler for searching active user details
 * @param users : The active users array collection
 * @return void
 *
 ***/
public function searchActiveUsersResultHandler(users:ArrayCollection):void
{
	allAdminUsers.removeAll();
	if (users != null)
	{
		if (users.length > 0)
		{
			var tmpAC:ArrayCollection=users;
			var obj:UserVO=new UserVO();
			for (var i:int=0; i < tmpAC.length; i++)
			{
				obj=ObjectUtil.copy(tmpAC[i]) as UserVO;
				obj.isSelected=false;
				allAdminUsers.addItem(obj);
			}
			setSelectInfo();
		}
		else
		{
			CustomAlert.info("No data available for the given criteria. Please try with some other details");
		}
	}
	else
	{
		CustomAlert.error("Error occured while searching for users. Please contact administrator");
	}
}

/**
 *
 * @private
 * This function is used check and get the invalid administrators
 * whom were assigned earlier or now
 *
 * @return String the value to display
 *
 ***/
private function getInvalidAdminsString():String
{
	var deletedAdminUserNames:String="";
	var nonAdminUserNames:String="";
	var count:int=0;
	var nonAdminCount:int=0;
	//Possible scenario
	//1. The admins status can be deleted. 
	//2. The admins role is changed to non admin
	for (var i:int; i < selectedAdminUsers.length; i++)
	{
		var admin:Object=selectedAdminUsers.getItemAt(i);
		/**
		 * Check if the status is Deleted */
		if (admin.statusId == StatusVO.DELETED_STATUS)
		{
			count++;
			deletedAdminUserNames+="\n" + count + ". " + admin.userName;
		}
		//Check if the role is Adminstrator
		else if (admin.role != Constants.ADMIN_TYPE)
		{
			nonAdminCount++;
			nonAdminUserNames+="\n" + nonAdminCount + ". " + admin.userName;
		}
	}
	if (count > 0)
	{
		deletedAdminUserNames="The following " + count + " Admin" + ((count > 1) ? "s are" : " is") + " in Deleted Status. \n They will be removed from Admin list.\n" + deletedAdminUserNames;
	}
	if (nonAdminCount > 0)
	{
		nonAdminUserNames="The following " + nonAdminCount + " Admin" + ((count > 1) ? "s are" : " is") + " not having Administrator Role. \n They will be removed from Admin list.\n" + nonAdminUserNames;
	}
	return deletedAdminUserNames + ((deletedAdminUserNames.length > 0) ? "\n" : "") + nonAdminUserNames;
}

/**
 *
 * @private
 * This function is used to save the institute admin details
 * back to CreateInstituteComp
 *
 * @return void
 *
 ***/
private function saveInstituteAdminsDetails():void
{
	if(Log.isDebug()) log.debug("Coming inside save institute admins");

	//Fix for Bug Id 3041 start
	if (selectedAdminUsers.length > 0)
	{
		//Remove the invalid administrators from the institute
		var deletedAdmins:String=getInvalidAdminsString();
		if (deletedAdmins != "")
		{
			CustomAlert.info(deletedAdmins);
		}
		//intimate the CreateInstituteComp about the new selected admins
		this.dispatchEvent(new InstituteAdminsSelectedEvent(InstituteAdminsSelectedEvent.INSTITUTE_ADMINS_SELECTED, false, false, selectedAdminUsers));
		closeSaveInstituteAdminsComp();
	}
	else
	{
		CustomAlert.info("Please add administrator(s) for the institute");
	}
	//Fix for Bug Id 3041 end
}

/**
 *
 * @private
 * This function is used to select/deselect selected admin users if SelectAll check box is selected/deselected
 *
 * @return void
 *
 ***/
private function toggleSelectedAdminUsersSelection():void
{
	var flag:Boolean=chkSelectAllSelectedAdminUsers.selected;
	var i:int=0;
	for (i=0; i < selectedAdminUsers.length; i++)
	{
		selectedAdminUsers[i].isSelected=flag;
	}
	selectedAdminUsers.refresh();
}

/**
 *
 * @private
 * This function is used to select/deselect all admin users if SelectAll check box is selected/deselected
 *
 * @return void
 *
 ***/
private function toggleAllAdminUsersSelection():void
{
	var flag:Boolean=chkSelectAllAdminUsers.selected;
	var i:int=0;
	for (i=0; i < allAdminUsers.length; i++)
	{
		allAdminUsers[i].isSelected=flag;
	}
	allAdminUsers.refresh();
}

/**
 *
 * @private
 * This function is to close the CreateInstituteAdminsComp
 *
 * @return void
 *
 ***/
private function closeSaveInstituteAdminsComp():void
{
	if (allAdminUsers != null)
	{
		allAdminUsers.removeAll();
	}
	if (selectedAdminUsers != null)
	{
		selectedAdminUsers.removeAll();
	}
	if (selectedInstituteAdminUsers != null)
	{
		selectedInstituteAdminUsers.removeAll();
	}
	if(Log.isDebug()) log.debug("Removing Save Institute Admin comp");
	PopUpManager.removePopUp(this);
}

/**
 *
 * @private
 * This function is used to select/deselect Select All check box for the admin users
 *
 * @return void
 *
 ***/
private function toggleAllAdminUsersCb():void
{
	var flag:Boolean=true;
	//Check if atleast one user selection is false. If so Select All checkbox is made as unchecked
	for (var i:int=0; i < allAdminUsers.length; i++)
	{
		if (allAdminUsers[i].isSelected == false)
		{
			flag=false;
			break;
		}
	}
	chkSelectAllAdminUsers.selected=flag;
}


/**
 *
 * @private
 * This function returns true/false depends upon the mouse click area
 *
 * @return true/false
 *
 ***/
private function clickedOutside():Boolean
{
	return (dgSelectedAdminUsersList.mouseY > dgSelectedAdminUsersList.headerHeight + (selectedAdminUsers.length * dgSelectedAdminUsersList.rowHeight));
}

/**
 *
 * @private
 * This function is used to select/deselect Select All check box for the selected admin users
 *
 * @return void
 *
 ***/
private function toggleAllSelectedAdminUsersCb():void
{
	/**
	 * If user clicked outside of datagrid then clear datagrid selection */
	if (clickedOutside())
	{
		dgSelectedAdminUsersList.selectedIndex=-1;
		dgSelectedAdminUsersList.selectedItem=null;
	}
	var flag:Boolean=true;
	/**
	 * Check if atleast one user selection is false. If so Select All checkbox is made as unchecked */
	for (var i:int=0; i < selectedAdminUsers.length; i++)
	{
		if (selectedAdminUsers[i].isSelected == false)
		{
			flag=false;
			break;
		}
	}
	chkSelectAllSelectedAdminUsers.selected=flag;
}

/**
 *
 * @private
 * This function sets the row color depends upon the user status
 * @param item:the UserVO
 * @param color:the row color to set by default
 * @return row color to set
 *
 ***/
private function getRowColor(item:Object, color:uint):uint
{
	var result:uint=color;
	/**
	 * If item status is deleted then set a particular color */
	if (item.statusId == StatusVO.DELETED_STATUS || item.role != Constants.ADMIN_TYPE)
	{
		result=0xCC3333;
	}
	return result;
}

/**
 *
 * @private
 * This function searchs for all active users
 *
 * @return void
 *
 ***/
private function searchActiveUsers():void
{
	var fName:String=null;
	var lName:String=null;
	var userName:String=null;
	if (txtInpUserFirstName.text != '')
	{
		fName=txtInpUserFirstName.text;
	}
	if (txtInpUserLastName.text != '')
	{
		lName=txtInpUserLastName.text;
	}
	if (txtInpUserName.text != '')
	{
		userName=txtInpUserName.text;
	}

	if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
	{
		userHelper.searchActiveUsers(fName, lName, userName, Constants.ADMIN_TYPE, null, 0,searchActiveUsersResultHandler);
	}
	else if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		userHelper.searchActiveUsers(fName, lName, userName, Constants.ADMIN_TYPE, null, 0, searchActiveUsersResultHandler,null,ClassroomContext.userVO.userId);
	}
}

// Fix for Bug # 3091 start
/**
 *
 * @private
 * This function clears all the search criterial
 *
 * @return void
 *
 ***/
private function clearFields():void
{
	txtInpUserFirstName.text="";
	txtInpUserLastName.text="";
	txtInpUserName.text="";

	allAdminUsers.removeAll();
	chkSelectAllAdminUsers.selected=false;
}
// Fix for Bug # 3091 end
