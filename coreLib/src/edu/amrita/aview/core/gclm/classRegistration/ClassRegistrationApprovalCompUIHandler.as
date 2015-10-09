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
 * File			: ClassRegistrationApprovalCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This file is the script handler for ClassRegistrationApprovalComp.mxml
 * Based on the logged in user credentials this component behaves as follows:
 * Master Admin: Can view, approve class registrations for any class any institute
 * Institute Administrators: Can view, approve the class registrations belongs to their institute/child institutes.
 * Moderators: Can approve/delete all class registrations for which they are the moderators
 *
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.gclm.vo.UserVO;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

/**
 * To track if the user has clicked on the cancel button 
 */
public var hasClickedCancelButton:Boolean=true;
/**
 * To store the approval pending class registrations 
 */
[Bindable]
private var approvalPendingClassRegistrations:ArrayCollection=new ArrayCollection();
/**
 * To track if the user has performed atleast one approval action 
 */
private var hasPerformedApprovalAction:Boolean=false;
/**
 * The helper class to communicate with the server 
 */
private var classRegistrationHelper:ClassRegistrationHelper=null;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.classRegistration.ClassRegistrationApprovalCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the ClassRegistrationApprovalComp
 * This function is called from ClassRegistrationComp.mxml
 *
 * @return void
 *
 */
public function init():void
{
	classRegistrationHelper=new ClassRegistrationHelper();
	setApprovalActionPerformed(false);
	hasClickedCancelButton=true;
	resetSmartCombos();
}

/**
 *
 * @public
 * This function is the result handler for getting all approval pending class registrations
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of ResultEvent
 * @return void
 *
 */
public function getClassRegistersForApprovalResultHandler(event:ResultEvent):void
{
	clearPendingApprovals();
	//If result from server is not null,then add the result(class registration details) into 'approvalPendingClassRegistrations' arraycollection.
	if (event.result != null)
	{
		if (event.result.length > 0)
		{
			var classRegisterVO:ClassRegisterVO;
			var tmpAC:ArrayCollection=event.result as ArrayCollection;
			var tmpPendingApprovals:ArrayCollection=new ArrayCollection();
			for (var i:int=0; i < tmpAC.length; i++)
			{
				classRegisterVO=new ClassRegisterVO();
				classRegisterVO.user=new UserVO();
				classRegisterVO.aviewClass=new ClassVO();
				classRegisterVO=ObjectUtil.copy(tmpAC[i]) as ClassRegisterVO;
				classRegisterVO.isSelected=false;
				classRegisterVO.userId=tmpAC[i].user.userId;
				classRegisterVO.userName=tmpAC[i].user.userName;
				classRegisterVO.instituteName=tmpAC[i].user.instituteName;
				classRegisterVO.parentInstituteName=tmpAC[i].user.parentInstituteName;
				classRegisterVO.className=tmpAC[i].aviewClass.className;
				classRegisterVO.courseName=tmpAC[i].aviewClass.courseName;
				classRegisterVO.courseInstitute=tmpAC[i].aviewClass.instituteName;
				tmpPendingApprovals.addItem(classRegisterVO);
			}
			approvalPendingClassRegistrations=tmpPendingApprovals;
		}
		//After performing the approval action and during refresh if there is no result set to show, it should not 
		//alert the user that no data available
		else if (!hasPerformedApprovalAction)
		{
			CustomAlert.info("No data available for class registration approvals");
		}
	}
	//If result from the server is not available,then show error.
	else if (!hasPerformedApprovalAction)
	{
		CustomAlert.error("Error occured while getting class registratoin pending approvals");
	}
	setApprovalActionPerformed(false);
}

/**
 *
 * @public
 * This function is the fault handler for getting  all approval pending class registrations
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of FaultEvent
 * @return void
 *
 */
public function getClassRegistersForApprovalFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::classRegistration::ClassRegistrationApprovalCompUIHandler::getClassRegistersForApprovalFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	clearPendingApprovals();
	if (!hasPerformedApprovalAction)
	{
		CustomAlert.error("Fault occured while getting the class registration pending approvals");
	}
	setApprovalActionPerformed(false);
}

/**
 *
 * @public
 * This function is the fault handler after approving the pending requests
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of ResultEvent
 * @return void
 *
 */
public function approvePendingClassRegistrationsResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Class registrations approved successfully");
	//After performing the approval, make the flag as true
	setApprovalActionPerformed(true);
	searchPendingApprovals();
}

/**
 *
 * @private
 * This function is to set the flag when at least one approval action is performed
 * @param flag type of Boolean
 * @return void
 *
 */
private function setApprovalActionPerformed(flag:Boolean):void
{
	hasPerformedApprovalAction=flag;
}

/**
 *
 * @private
 * This function is used to reset all the search criteria
 *
 * @return void
 *
 */
private function resetSmartCombos():void
{
	cmbInstitutes.filterString="";
	cmbInstitutes.selectedItem=null;
}

/**
 *
 * @private
 * This function is to call the helper for getting the pending approvals based on the given search criteria
 *
 * @return void
 *
 */
private function searchPendingApprovals():void
{
	var instituteId:Number=0;
	//Based on the user role, call the appropriate API to get the results
	if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
	{
		if ((cmbInstitutes.text == "") || (cmbInstitutes.selectedItem == null) || (cmbInstitutes.selectedItem.instituteId == 0))
		{
			CustomAlert.info("Please select a valid institute to search for the pending class registration approval(s)");
		}
		else
		{
			classRegistrationHelper.getClassRegistersForMasterAdminApproval(cmbInstitutes.selectedItem.instituteId,getClassRegistersForApprovalResultHandler,getClassRegistersForApprovalFaultHandler);
		}
	}
	else if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		if ((cmbInstitutes.text != "") && (cmbInstitutes.selectedItem != null))
		{
			instituteId=cmbInstitutes.selectedItem.instituteId;
		}
		classRegistrationHelper.getClassRegistersForInstituteAdminApproval(instituteId, ClassroomContext.userVO.userId,getClassRegistersForApprovalResultHandler,getClassRegistersForApprovalFaultHandler);
	}
	//Code change for NIC start
	//Get the list of pending class regisration approvals for those classes to which the teacher 
	//is the moderator
	else if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		if ((cmbInstitutes.text != "") && (cmbInstitutes.selectedItem != null))
		{
			instituteId=cmbInstitutes.selectedItem.instituteId;
		}
		classRegistrationHelper.getClassRegistersForModeratorApproval(instituteId, ClassroomContext.userVO.userId,getClassRegistersForApprovalResultHandler,getClassRegistersForApprovalFaultHandler);
	}
	//Code change for NIC end
}

/**
 *
 * @private
 * This function is to listen for the keydown action for the select all check box
 * @param event type KeyboardEvent
 * @return void
 *
 */
private function selectAllPendingClassRegistrationApprovalsKeyDownHandler(event:KeyboardEvent):void
{
	if (event.keyCode == Keyboard.SPACE)
	{
		chkSelectAllPendingClassRegApprovals.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}
}

/**
 *
 * @private
 * This function is to select/deselect all the approval pending class registration
 *
 * @return void
 *
 */
private function toggleAllPendingClassRegistrationApprovalsSelection():void
{
	//Variable to denote approval pending class registration selection
	var flag:Boolean=chkSelectAllPendingClassRegApprovals.selected;
	for (var i:int = 0; i < approvalPendingClassRegistrations.length; i++)
	{
		approvalPendingClassRegistrations[i].isSelected=flag;
	}
	approvalPendingClassRegistrations.refresh();
}

/**
 *
 * @private
 * This function is to set/reset the select all combo box of class registration approval
 *
 * @return void
 *
 */
private function togglecbSelectAllPendingClassRegistrationApproval():void
{
	//Flag variable to notify the selection		
	var flag:Boolean=true;
	//To itrate all pending class registration approval
	for (var i:int=0; i < approvalPendingClassRegistrations.length; i++)
	{
		//If selection is false then set flag to false.
		if (approvalPendingClassRegistrations[i].isSelected == false)
		{
			flag=false;
			break;
		}
	}
	chkSelectAllPendingClassRegApprovals.selected=flag;
}

/**
 *
 * @private
 * This function is to confirm the selected class registration approvals
 *
 * @return void
 *
 */
private function saveClassRegistrationApprovals():void
{
	//Array to hold class registration id
	var classRegistrationIds:Array=new Array();
	//To itrate all pending class registration approval
	for (var i:int=0; i < approvalPendingClassRegistrations.length; i++)
	{
		//If class registration is selected for approval then add it to the classRegistrationIds array.
		if (approvalPendingClassRegistrations[i].isSelected)
		{
			classRegistrationIds.push(approvalPendingClassRegistrations[i].classRegisterId);
		}
	}
	//Check if atleast one class registration has been selected for approval
	if (classRegistrationIds.length != 0)
	{
		classRegistrationHelper.approvePendingClassRegistrations(classRegistrationIds, ClassroomContext.userVO.userId,approvePendingClassRegistrationsResultHandler);
	}
	else
	{
		CustomAlert.info("Please select atleast one user's class registration to be approved");
	}
}

/**
 *
 * @private
 * This function is to close the current window
 *
 * @return void
 *
 */
private function closeClassRegistrationApprovalComp():void
{
	clearPendingApprovals();
	if(Log.isDebug()) log.debug("Create class registration approval comp closed");
	PopUpManager.removePopUp(this);
}

/**
 *
 * @private
 * This function is to reset all the search criteria and results
 *
 * @return void
 *
 */
private function resetData():void
{
	cmbInstitutes.selectedItem=null;
	cmbInstitutes.filterString="";
	clearPendingApprovals();
}

/**
 *
 * @private
 * This function is to clear the pending approvals info
 *
 * @return void
 *
 */
private function clearPendingApprovals():void
{
	chkSelectAllPendingClassRegApprovals.selected=false;
	approvalPendingClassRegistrations.removeAll();
}