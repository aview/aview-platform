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
 * File			: InstituteApprovalCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Swati, Abhirami, Sivaram Sk
 *
 * This file is the script handler for InstituteApprovalComp.mxml
 *
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.vo.InstituteVO;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

/**
 * To keep track if the user has clicked on Cancel button
 */
public var hasPerformedApprovalAction:Boolean=false;

[Bindable]
private var approvalPendingInstitutes:ArrayCollection=new ArrayCollection();
/**
 * The array of institute ids which are pending for approval
 */
private var approvalPendingInstitutesIds:Array;
/**
 * The helper class to communicate to the server
 */
private var instituteHelper:InstituteHelper;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.InstituteApprovalCompUIHandler.as");
/**
 *
 * @public
 * This function sets all the initial data required by Institute Approval Comp
 * This function is called from InstituteComp.mxml
 *
 * @return void
 *
 ***/
public function init():void
{
	instituteHelper=new InstituteHelper();
	setApprovalActionPerformed(false);
}

/**
 *
 * @public
 * This function is the result handler for getting all the approval pending institutes
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param institutes the arraycollection of InstituteVO
 * @return void
 *
 ***/
public function searchPendingApprovalInstitutesResultHandler(institutes:ArrayCollection):void
{
	var tmpAC:ArrayCollection=new ArrayCollection();
	//Check if there are no institutes pending for approval
	if (institutes != null)
	{
		clearPendingApprovals();
		if (institutes.length > 0)
		{
			var obj:InstituteVO;
			for (var i:int=0; i < institutes.length; i++)
			{
				obj=new InstituteVO();
				obj=ObjectUtil.copy(institutes[i]) as InstituteVO;
				obj.instituteCategory=GCLMContext.instituteCategoriesMap[obj.instituteCategoryId]
				obj.isSelected=false;
				tmpAC.addItem(obj);
			}
			approvalPendingInstitutes=tmpAC;
		}
		else if (!hasPerformedApprovalAction)
		{
			CustomAlert.info("No pending Institutes are available for approval");
		}
	}
	else if (!hasPerformedApprovalAction)
	{
		CustomAlert.info("No data found for the given criteria");
	}
}

/**
 *
 * @public
 * This function is the fault handler for getting all the approval pending institutes
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : the FaultEvent
 * @return void
 *
 ***/
public function searchPendingApprovalInstitutesFaultHandler(event:FaultEvent):void
{
	clearPendingApprovals();
	setApprovalActionPerformed(false);
	instituteHelper.genericFaultHandler(event);
}

/**
 *
 * @public
 * This function is the result handler after deleting the approval pending institutes
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : the ResultEvent
 * @return void
 *
 ***/
public function deleteApprovalPendingInstitutesResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Institute(s) deleted successfully");
	setApprovalActionPerformed(true);
	searchPendingApprovals();
}

/**
 *
 * @public
 * This function is the result handler for approving the institutes
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : the ResultEvent
 * @return void
 *
 ***/
public function approvePendingInstitutesResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Institute(s) approved successfully");
	setApprovalActionPerformed(true);
	searchPendingApprovals();
}

/**
 *
 * @public
 * This function is the fault handler for approving the institutes
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : the FaultEvent
 * @return void
 *
 ***/
public function approvePendingInstitutesFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::institute::InstituteApprovalCompUIHandler::approvePendingInstitutesFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	CustomAlert.error("Fault occured while approving Institutes. Please contact administrator");
}

/**
 *
 * @private
 * This function sets whether the approval action has been performed or not
 * @param flag : The boolean value to set
 * @return void
 *
 ***/
private function setApprovalActionPerformed(flag:Boolean):void
{
	hasPerformedApprovalAction=flag;
}

/**
 *
 * @private
 * This function is to search all the approval pending institutes
 *
 * @return void
 *
 ***/
private function searchPendingApprovals():void
{
	var searchStr:String="";
	if (txtInpInstitute.text != "")
	{
		searchStr=txtInpInstitute.text;
	}
	instituteHelper.searchPendingApprovalInstitutes(searchStr,searchPendingApprovalInstitutesResultHandler,searchPendingApprovalInstitutesFaultHandler);
}

/**
 *
 * @private
 * This function is to select/deselect all the approval pending institutes
 *
 * @return void
 *
 ***/
private function toggleAllPendingInstitutesSelection():void
{
	var flag:Boolean=chkSelectAllPendingInstitutes.selected;
	var i:int=0;
	for (i=0; i < approvalPendingInstitutes.length; i++)
	{
		approvalPendingInstitutes[i].isSelected=flag;
	}
	approvalPendingInstitutes.refresh();
}

/**
 *
 * @private
 * This function is to set/reset the select all combo box of institute approval
 *
 * @return void
 *
 ***/
private function toggleCheckSelectAllPendingInstitutes():void
{
	var flag:Boolean=true;
	//Check if all the institute has been selected for approval. 
	//If atleast one institute is not selected for approval then uncheck the Select All check box
	for (var i:int=0; i < approvalPendingInstitutes.length; i++)
	{
		if (approvalPendingInstitutes[i].isSelected == false)
		{
			flag=false;
			break;
		}
	}
	chkSelectAllPendingInstitutes.selected=flag;
}

/**
 *
 * @private
 * This function is to save all the institute approvals
 *
 * @return void
 *
 ***/
private function saveInstituteApprovals():void
{
	var instituteIds:Array=new Array();
	//Get the selected institute institute ids for changing the status to approved 
	for (var i:int=0; i < approvalPendingInstitutes.length; i++)
	{
		if (approvalPendingInstitutes[i].isSelected)
		{
			instituteIds.push(approvalPendingInstitutes[i].instituteId);
		}
	}
	if (instituteIds.length == 0)
	{
		CustomAlert.info("Please select atleast one Institute to approve");
	}
	else
	{
		instituteHelper.approvePendingInstitutes(instituteIds, ClassroomContext.userVO.userId,approvePendingInstitutesResultHandler,approvePendingInstitutesFaultHandler);
	}
}

/**
 *
 * @private
 * This function is to prepare for deletion of the institutes pending for approval and get a confirmation from
 * user before deleting
 *
 * @return void
 *
 ***/
private function prepareForDeletion():void
{
	approvalPendingInstitutesIds=new Array();
	for (var i:int=0; i < approvalPendingInstitutes.length; i++)
	{
		if (approvalPendingInstitutes[i].isSelected)
		{
			approvalPendingInstitutesIds.push(approvalPendingInstitutes[i].instituteId);
		}
	}
	//Select atleast one institute for deleting
	if (approvalPendingInstitutesIds.length == 0)
	{
		CustomAlert.info("Please select atleast one Institute to delete");
	}
	else
	{
		CustomAlert.confirm("Are you sure you want to delete the selected Institute?", "Confirmation", confirmDeleteInstitute)

	}
}

/**
 *
 * @private
 * This function is to confirm the deletion of institutes before approving
 * @param event : the CloseEvent which has Yes/No to delete or not
 * @return void
 *
 ***/
private function confirmDeleteInstitute(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		instituteHelper.deleteApprovalPendingInstitutes(approvalPendingInstitutesIds, ClassroomContext.userVO.userId,deleteApprovalPendingInstitutesResultHandler);
	}
}

/**
 *
 * @private
 * This function is to close the InstituteApprovalComp
 *
 * @return void
 *
 ***/
private function closeInstituteApprovalComp():void
{
	clearPendingApprovals();
	if(Log.isDebug()) log.debug("Approve Institute comp closed");
	PopUpManager.removePopUp(this);
}

/**
 *
 * @private
 * This function is to reset all the data
 *
 * @return void
 *
 ***/
private function resetData():void
{
	txtInpInstitute.text="";
	clearPendingApprovals();
}

/**
 *
 * @private
 * This function is to clear the data provider that has the approval pending institute list
 *
 * @return void
 *
 ***/
private function clearPendingApprovals():void
{
	approvalPendingInstitutes.removeAll();
	chkSelectAllPendingInstitutes.selected=false;
}
