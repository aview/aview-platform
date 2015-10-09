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
 * File			: InstituteCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Swati, Abhirami, Sivaram SK
 *
 * This file is the script handler for InstituteComp.mxml
 *
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.institute.InstituteApprovalComp;
import edu.amrita.aview.core.gclm.institute.CreateInstituteComp;
import edu.amrita.aview.core.gclm.vo.InstituteVO;
import edu.amrita.aview.core.shared.vo.StatusVO;
import edu.amrita.aview.core.gclm.helper.CourseHelper;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ClassroomContext;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
/** The icon classes */
[Bindable]
[Embed(source="../assets/images/create.png")]
private var createIconEnabled:Class;

[Bindable]
[Embed(source="../assets/images/edit.png")]
private var updateIconEnabled:Class;

[Bindable]
[Embed(source="../assets/images/delete.png")]
private var deleteIconEnabled:Class;

[Bindable]
private var createIcon:Class;

[Bindable]
private var deleteIcon:Class;

[Bindable]
private var updateIcon:Class;
/**
 * The array collection to store all the parent institute
 */
private var parentInstitutes:ArrayCollection=new ArrayCollection();
/**
 * The helper class objects to communicate with the server
 */
private var instituteHelper:InstituteHelper=null;
private var courseHelper:CourseHelper=null;
private var userHelper:UserHelper=null;
/**
 * The create institute component object
 */
private var createInstituteComp:CreateInstituteComp=null;
/**
 * The user count of an institute
 */
private var userCount:int=0;
/**
 * The course count of an institute
 */
private var courseCount:int=0;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.InstituteCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the Institute Comp
 * This function is called from Administration.mxml
 *
 * @return void
 *
 ***/
public function initComp():void
{
	instituteHelper=new InstituteHelper();
	courseHelper=new CourseHelper();
	userHelper=new UserHelper();
	resetSearchItems();
	setIcons();
	getInstitutesEssentialDetails();
}

/**
 *
 * @public
 * This function is the result handler for getting all the institute and its essential details
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param institutes the arraycollection of InstituteVO
 * @return void
 *
 ***/
public function getAllInstitutesEssentialDetailsResultHandler(institutes:ArrayCollection):void
{
	clearDataProviders();
	var i:int=0;
	if (institutes != null)
	{
		GCLMContext.sortSmartComboDataProvider(institutes, "instituteName");

		var tempAllInstAC:ArrayCollection=new ArrayCollection();
		var tempParentInstAC:ArrayCollection=new ArrayCollection();

		var obj:InstituteVO;
		for (i=0; i < institutes.length; i++)
		{
			obj=institutes[i] as InstituteVO;
			obj.instituteCategory=GCLMContext.instituteCategoriesMap[obj.instituteCategoryId]
			//If the parent institute is null, then this insitute itself is a parent institute 
			if (obj.parentInstituteName == null)
			{
				tempParentInstAC.addItem(obj);
			}
			tempAllInstAC.addItem(obj);
		}
		GCLMContext.allInstitutesAC=tempAllInstAC;
		parentInstitutes=tempParentInstAC;
	}
	else
	{
		if(Log.isInfo()) log.info("Error in getting the institute details");
	}
	if(Log.isInfo()) log.info("getAllInstitutesEssentialDetailsResultHandler After array collection:");
}

/**
 *
 * @public
 * This function is the result handler for deleting an Institute
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event The Result Event
 * @return void
 *
 ***/
public function deleteInstituteResultHandler(event:ResultEvent):void
{
	butDeleteInstitute.enabled=true;
	var selectedInst:InstituteVO=dgAllInstitutes.selectedItem as InstituteVO;
	if (selectedInst != null)
	{
		updateInstituesArray(selectedInst, GCLMContext.allInstitutesAC.source, true);
		updateParentInstituesArray();
	}
	GCLMContext.allInstitutesAC.refresh();
	CustomAlert.info("Institute deleted successfully");
}


/**
 *
 * @public
 * This function is the result handler for getting the institute details for update
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param institutevo : The InstituteVO object
 * @return void
 *
 ***/
public function getInstituteByIdResultHandler(institutevo:InstituteVO):void
{
	createInstituteComp=new CreateInstituteComp();
	createInstituteComp.title="Edit Institute";
	createInstituteComp.addEventListener(FlexEvent.REMOVE, updateInstitutesOnEdit);
	PopUpManager.addPopUp(createInstituteComp, this, true, null);
	PopUpManager.centerPopUp(createInstituteComp);
	createInstituteComp.parentInstitutes=parentInstitutes;
	createInstituteComp.init(institutevo);
}

/**
 *
 * @public
 * This function is the result handler for getting count of users belong to an institute
 * This function is made public because the UserHelper.as will call this once it
 * gets the result from the server
 * @param count : The number of users belonging to an institute
 * @return void
 *
 ***/
public function getUserCountResultHandler(count:Number):void
{
	userCount=count;
	//After getting the user count get the course count as well
	courseHelper.getCourseCount(dgAllInstitutes.selectedItem.instituteId,getCourseCountResultHandler);
}

/**
 *
 * @public
 * This function is the result handler for getting count of courses of an institute
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param count : The number of courses belonging to an institute
 * @return void
 *
 ***/
public function getCourseCountResultHandler(count:Number):void
{
	courseCount=count;
	preConfirmDeleteInstitute();
}

/**
 *
 * @private
 * This function is used to get confimration from the user before detleting an Insitute.
 *
 * @return void
 *
 ***/
private function preConfirmDeleteInstitute():void
{
	var warningMessage:String="";
	//If the institute has both users and courses registered
	if (userCount > 0 && courseCount > 0)
	{
		warningMessage="Deleting the institute will delete the Courses and Users registered for the institute.Are you sure you want to delete the selected institue?";
	}
	//If the institute has only user registered
	else if (userCount > 0)
	{
		warningMessage="Deleting the institute will delete the Users registered for the institute.Are you sure you want to delete the selected institue?";
	}
	//If the institute has only courses 
	else if (courseCount > 0)
	{
		warningMessage="Deleting the institute will delete the Courses registered for the institute.Are you sure you want to delete the selected institue?";
	}
	else
	{
		warningMessage="Are you sure you want to delete the selected institue?";
	}
	CustomAlert.confirm(warningMessage, "Confirmation", confirmDeleteInstitute);
}

/**
 *
 * @private
 * This function disables all the control buttons, if the logged in user is not a master admin
 *
 * @return void
 *
 ***/
//NPCR : unused function
private function resetActionButtons():void
{
	//This function is currently not used. However, this is required in the future if Institute Administrators
	//are given privilege to view the Institute Comp
	/*if (ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE)
	{
		disableAllActionButtions();
	}
	else
	{
		toggleActionButtons(true);
	}*/
}

/**
 *
 * @private
 * This function is to set the Icons for all the control buttons
 *
 * @return void
 *
 ***/
private function setIcons():void
{
	createIcon=createIconEnabled;
	updateIcon=updateIconEnabled;
	deleteIcon=deleteIconEnabled;
}

/**
 *
 * @private
 * This function is the client side filtering of institutes based on the user input search criteria
 *
 * @return void
 *
 ***/
private function filterInstitutesArrayCollection(item:Object):Boolean
{
	var searchInst:String=txtInpInstituteName.text.toLowerCase();
	var searchType:String=txtInpType.text.toLowerCase();
	var searchCategory:String=txtInpCategory.text.toLowerCase();
	var searchCity:String=txtInpCity.text.toLowerCase();
	var searchParentInst:String=txtInpParentInstitute.text.toLowerCase();

	var instName:String=null;
	var type:String=null;
	var category:String=null;
	var city:String=null;
	var parentInst:String=null;

	var match:Boolean=true;

	if (searchInst.length > 0)
	{
		instName=(item.instituteName as String).toLowerCase();
		match=(instName.indexOf(searchInst) > -1);
	}
	if (match && searchType.length > 0)
	{
		if (item.instituteType != null)
		{
			type=(item.instituteType as String).toLowerCase();
			match=(type.indexOf(searchType) > -1);
		}
		else
		{
			match=false;
		}
	}
	if (match && searchCategory.length > 0)
	{
		if (item.instituteCategory != null)
		{
			category=(item.instituteCategory as String).toLowerCase();
			match=(category.indexOf(searchCategory) > -1);
		}
		else
		{
			match=false;
		}
	}
	if (match && searchCity.length > 0)
	{
		if (item.city != null)
		{
			city=(item.city as String).toLowerCase();
			match=(city.indexOf(searchCity) > -1);
		}
		else
		{
			match=false;
		}
	}
	if (match && searchParentInst.length > 0)
	{
		if (item.parentInstituteName != null)
		{
			parentInst=(item.parentInstituteName as String).toLowerCase();
			match=(parentInst.indexOf(searchParentInst) > -1);
		}
		else
		{
			match=false;
		}
	}
	return match;
}

/**
 *
 * @private
 * This function is the assign the filter function for the institutes array collection
 *
 * @return void
 *
 ***/
private function filterResults():void
{
	GCLMContext.allInstitutesAC.filterFunction=filterInstitutesArrayCollection;
	GCLMContext.allInstitutesAC.refresh();
}

/**
 *
 * @private
 * This function is to reset the search criteria
 *
 * @return void
 *
 ***/
private function resetSearchItems():void
{
	txtInpInstituteName.text='';
	txtInpType.text='';
	txtInpCategory.text='';
	txtInpCity.text='';
	txtInpParentInstitute.text='';
}

/**
 *
 * @private
 * This function is to clear all the data providers which has the search results
 *
 * @return void
 *
 ***/
private function clearDataProviders():void
{
	parentInstitutes.removeAll();
	parentInstitutes=new ArrayCollection();
	//parentInstitutesCB.dataProvider = parentInstitutesAC; 
	GCLMContext.allInstitutesAC.removeAll();
	GCLMContext.allInstitutesAC=new ArrayCollection();
}

/**
 *
 * @private
 * This function is to clear all the search results
 *
 * @return void
 *
 ***/
private function clearSearch():void
{
	resetSearchItems();
	filterResults();
	//resetActionButtons();
}

//  Fix for Bug #14554 : Commented the unwanted function
/**
 *
 * @private
 * This function is to clear the search criteria for the client side filtering of existing institute details
 *
 * @return void
 *
 **
private function clearSearchCriteria():void
{
	txtInpInstituteSearch.text="";
	txtInpCitySearch.text="";
	txtInpParentInstituteSearch.text="";
}
*/


/**
 *
 * @private
 * This function is called when the create institute button is clicked.
 * This opens the CreateInstituteComp window for creating a new institute
 *
 * @return void
 *
 ***/
private function createInstitute():void
{
	butCreateInstitute.enabled=false;
	createInstituteComp=new CreateInstituteComp();
	createInstituteComp.title="Create Institute";
	createInstituteComp.addEventListener(FlexEvent.REMOVE, updateInstitutesOnCreate);
	PopUpManager.addPopUp(createInstituteComp, this, true, null);
	PopUpManager.centerPopUp(createInstituteComp);
	createInstituteComp.parentInstitutes=parentInstitutes;
	createInstituteComp.init();
}

/**
 *
 * @private
 * This function is called when an Insitute is clicked for editing
 * This opens the CreateInstituteComp window for editing the Institute details
 *
 * @return void
 *
 ***/
private function editInstitute():void
{
	if (dgAllInstitutes.selectedItem != null)
	{
		//Disable the edit button to avoid double clicking
		butEditInstitute.enabled=false;
		//Get the selected institute details from the server before editing
		getInstituteByIdAndLaunchUpdateInstitute(dgAllInstitutes.selectedItem.instituteId);
	}
	else
	{
		CustomAlert.info("Please select an institute to edit");
	}
}

/**
 *
 * @private
 * This function is called when an Insitute is cretated/edited/deleted
 * This is to refresh the client side institute array
 *
 * @return void
 *
 ***/
private function updateInstituesArray(newInstituteVO:InstituteVO, instituteArray:Array, isDelete:Boolean):void
{
	var instituteVO:InstituteVO;
	for (var i:int=0; i < instituteArray.length; i++)
	{
		instituteVO=instituteArray[i] as InstituteVO;

		if (instituteVO.instituteId == newInstituteVO.instituteId)
		{
			if (isDelete)
			{
				instituteArray.splice(i, 1);
			}
			else
			{
				newInstituteVO.instituteCategory=GCLMContext.instituteCategoriesMap[newInstituteVO.instituteCategoryId];
				instituteArray.splice(i, 1, newInstituteVO);
			}
		}
		else if (instituteVO.parentInstituteId == newInstituteVO.instituteId)
		{
			instituteVO.parentInstituteName=newInstituteVO.instituteName;
		}
	}
}

/**
 *
 * @private
 * This function is called when an Insitute is cretated/edited/deleted
 * This is to refresh the client side parent institutes array
 *
 * @return void
 *
 ***/
private function updateParentInstituesArray():void
{
	var instituteVO:InstituteVO;
	var tempParentInstAC:ArrayCollection=new ArrayCollection();
	for (var i:int=0; i < GCLMContext.allInstitutesAC.source.length; i++)
	{
		instituteVO=GCLMContext.allInstitutesAC.source[i] as InstituteVO;
		if (instituteVO.parentInstituteName == null)
		{
			tempParentInstAC.addItem(instituteVO);
		}
	}
	parentInstitutes.removeAll();
	parentInstitutes=tempParentInstAC;
}

/**
 *
 * @private
 * This function is to update the institute details after performing the edit
 * This function internally calls updateInstituesArray and updateParentInstituesArray
 * @param event : The Flex event which has the info if the user has 
 * cancelled the previous action
 * @return void
 *
 ***/
private function updateInstitutesOnEdit(event:FlexEvent):void
{
	butEditInstitute.enabled=true;
	//If user clicked on button other than cancel button
	if (!event.target.hasClickedCancelButton)
	{
		//If new value for institute exist then update data.
		if (createInstituteComp.newInstituteVO != null)
		{
			createInstituteComp.newInstituteVO.instituteCategory=GCLMContext.instituteCategoriesMap[createInstituteComp.newInstituteVO.instituteCategoryId];
			updateInstituesArray(createInstituteComp.newInstituteVO, GCLMContext.allInstitutesAC.source, false);
			updateParentInstituesArray();
		}
	}
	createInstituteComp=null;
	GCLMContext.allInstitutesAC.refresh();
}

/**
 *
 * @private
 * This function is to update the institute details after creating a new institute
 * This function internally calls updateParentInstituesArray
 * @param event : The Flex event which has the info if the user has cancelled the previous action
 * @return void
 *
 ***/
private function updateInstitutesOnCreate(event:FlexEvent):void
{
	butCreateInstitute.enabled=true;
	//If the user has clicked on the cancel button in the create institute comp window, then do nothing
	//otherwise refresh the current window with the updated data
	if (!event.target.hasClickedCancelButton)
	{
		if (createInstituteComp.newInstituteVO != null)
		{
			createInstituteComp.newInstituteVO.instituteCategory=GCLMContext.instituteCategoriesMap[createInstituteComp.newInstituteVO.instituteCategoryId];
			GCLMContext.allInstitutesAC.addItem(createInstituteComp.newInstituteVO);
			updateParentInstituesArray();
		}
	}
	createInstituteComp=null;
}

/**
 *
 * @private
 * This function is to update the institute details after creating a new institute
 * This function internally calls updateParentInstituesArray
 *
 * @return void
 *
 ***/
private function getInstitutesEssentialDetails():void
{
	if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
	{
		instituteHelper.getAllInstitutesEssentialDetails(getAllInstitutesEssentialDetailsResultHandler);
	}
	else if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		instituteHelper.getAllInstitutesEssentialDetailsForAdmin(ClassroomContext.userVO.userId,getAllInstitutesEssentialDetailsResultHandler);
	}
}

/**
 *
 * @private
 * This function is to get the institute details before performing an update
 * @param instituteId : The institute id for which the details need to be fetched
 * @return void
 *
 ***/
private function getInstituteByIdAndLaunchUpdateInstitute(instituteId:Number):void
{
	instituteHelper.getInstituteById(instituteId,getInstituteByIdResultHandler);
}
/**
 * @private
 * This function is to check if the institute is a parent institute
 * @param instituteId : The institute id
 * @return Boolean
 *
 ***/
private function isParentInstitute(instituteId:Number):Boolean
{
	var isParent:Boolean=false;
	for (var i:int=0; i < GCLMContext.allInstitutesAC.source.length; i++)
	{
		//Check if the institute id is available as parent institute for any other institute.
		//If so break from the loop.
		if (instituteId == GCLMContext.allInstitutesAC.source[i].parentInstituteId)
		{
			isParent=true;
			break;
		}
	}
	return isParent;
}

/**
 *
 * @private
 * This function is to check if the institute has child institutes (or) users/courses before deleting
 *
 * @return void
 *
 ***/
private function prepareForDelete():void
{
	if (dgAllInstitutes.selectedItem != null)
	{
		butDeleteInstitute.enabled=false;
		var selectedInst:InstituteVO=dgAllInstitutes.selectedItem as InstituteVO;
		//Check if the institute has associated child institutes. If so, alert the user
		if (isParentInstitute(selectedInst.instituteId))
		{
			CustomAlert.info("This institute has child institutes. Please unassociate child institutes before deleting the Parent institute.");
			butDeleteInstitute.enabled=true;
			return;
		}
		else
		{
			userCount=0;
			courseCount=0;
			//Check for the uesrs and courses belonging to the selected institute
			userHelper.getUserCount(dgAllInstitutes.selectedItem.instituteId,getUserCountResultHandler);
		}
	}
	else
	{
		CustomAlert.info("Please select an institute to delete");
	}
}

/**
 *
 * @private
 * This function is to confirm the deletion of an nstitute in the server
 * @param event : The CloseEvent which has Yes/No for deciding whether to delete or not
 * @return void
 *
 ***/
private function confirmDeleteInstitute(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		var selectedInst:InstituteVO=dgAllInstitutes.selectedItem as InstituteVO;
		instituteHelper.deleteInstitute(selectedInst.instituteId, ClassroomContext.userVO.userId,deleteInstituteResultHandler);
	}
	//If the user declines the delete confirmation enable the delete button
	else
	{
		butDeleteInstitute.enabled=true;
	}
}

/**
 *
 * @private
 * This function is to approve the institute if it was created by the user as part of user registration
 * The users can create institute if their institute is not listed during registration
 *
 * @return void
 *
 ***/
private function approveInstitute():void
{
	butApproveInstitute.enabled=false;
	var approveInstitute:InstituteApprovalComp=new InstituteApprovalComp();
	approveInstitute.addEventListener(FlexEvent.REMOVE, updateInstitutesOnApproval);
	PopUpManager.addPopUp(approveInstitute, this, true, null);
	PopUpManager.centerPopUp(approveInstitute);
	approveInstitute.init();
}

/**
 *
 * @private
 * This function is to update the institute list after the approval is performed by the master admin
 * @param event : The FlexEvent which has the info, if the user has cancelled the previous action
 * @return void
 *
 ***/
private function updateInstitutesOnApproval(event:FlexEvent):void
{
	butApproveInstitute.enabled=true;
	if (event.target.hasPerformedApprovalAction)
	{
		getInstitutesEssentialDetails();
	}
}

