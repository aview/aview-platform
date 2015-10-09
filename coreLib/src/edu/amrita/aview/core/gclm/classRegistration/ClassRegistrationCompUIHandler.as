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
 * File			: ClassRegistrationCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This Action Script handler for ClassRegistrationComp.
 * Based on the logged in user credentials this component behaves as follows:
 * Master Admin: Can view, approve Create, edit and Delete of class registrations for any class any institute
 * Institute Administrators: Can view, approve the class registrations belongs to their institute/child institutes.
 * Create, Edit and Delete of class registrations are also possible within their institute boundary
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.classRegistration.ClassRegistrationApprovalComp;
import edu.amrita.aview.core.gclm.classRegistration.CreateClassRegistrationComp;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.CourseHelper;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.gclm.vo.UserVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.vo.StatusVO;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

/**
 *  The icon class for create
 */
[Bindable]
[Embed(source="../assets/images/create.png")]
private var createIconEnabled:Class;

/**
 *  The icon class for delete
 */
[Bindable]
[Embed(source="../assets/images/delete.png")]
private var deleteIconEnabled:Class;

/**
 *  The icon class for update
 */
[Bindable]
[Embed(source="../assets/images/edit.png")]
private var updateIconEnabled:Class;

/**
 *  The icon class for create
 */
[Bindable]
private var createIcon:Class;

/**
 *  The icon class for delete
 */
[Bindable]
private var deleteIcon:Class;

/**
 *  The icon class for update
 */
[Bindable]
private var updateIcon:Class;
/**
 * To use in the search criteria to perform search based on Moderator or not  
 */
[Bindable]
private var moderatorArr:Array=new Array('ALL', 'Y', 'N');
/**
 *  To store the class registration search result 
 */
[Bindable]
private var classRegistrationsAC:ArrayCollection=new ArrayCollection();
/**
 * To store all the active/closed aview classes 
 */
[Bindable]
private var classes:ArrayCollection=new ArrayCollection();
/**
 * To store all the active courses 
 */
[Bindable]
private var courses:ArrayCollection=new ArrayCollection();
/**
 * To keep track if the search button has been clicked 
 */
private var hasClickedSearchButton:Boolean=false;
/**
 * The helper classes to communicate with the server 
 */
private var classHelper:ClassHelper=null;
private var classRegistrationHelper:ClassRegistrationHelper=null;
private var courseHelper:CourseHelper=null;
private var instituteHelper:InstituteHelper=null;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.classRegistration.ClassRegistrationCompUIHandler.as");

/**
 * Code change for NIC start
 * To check if the logged in user is a moderator or not 
 */
private var isModerator:String="Y";
//Code change for NIC end

/**
 *
 * @public
 * This function sets all the initial info required for the ClassRegistrationComp
 * This function is called from Administration.mxml
 *
 * @return void
 *
 */
public function initApp():void
{
	instituteHelper=new InstituteHelper();
	classHelper=new ClassHelper();
	courseHelper=new CourseHelper();
	classRegistrationHelper=new ClassRegistrationHelper();
	
	reset();
	setIcons();
	
	// Code change for NIC start
	// Approve button is visible to teachers as well
	// Fix for Bug #19529 start
	if ( (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) ||
		 (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
	
	// Fix for Bug #19529 end	
	{
		disableAllActionButtions();
		setVisibleApproveButton(false);
		// Fix for Bug # 3120 start
		setUser();
			// Fix for Bug # 3120 end
	}
	//The moderator has the option to approve the class registration if they are the moderators
	else if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		disableAllActionButtions();
		setVisibleApproveButton(true);
	}
	// Code change for NIC end
	getClasses();
	getCourses();
	getCourseOfferingInstitutes();
}

/**
 *
 * @public
 * This function is the result handler for getting all institutes which offers various courses
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param institutes type of ArrayCollection
 * @return void
 *
 */
public function getAllCourseOfferingInstitutesResultHandler(institutes:ArrayCollection):void
{
	//If result from server is not null then add the result to an arraycollection.
	//Else show error mesage.
	if (institutes != null)
	{
		GCLMContext.sortSmartComboDataProvider(institutes, "instituteName");
		GCLMContext.allCourseOfferingInstitutesAC=institutes;
		if(Log.isInfo()) log.info("getAllCourseOfferingInstitutesResultHandler After array collection:" + new Date());
	}
	else
	{
		CustomAlert.error("Error occured while getting the institutes");
	}
	resetSearchItems();
}

/**
 *
 * @public
 * This function is the result handler for getting the class registration details for the given id
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param classRegisterVO type of ClassRegisterVO
 * @return void
 *
 */
public function getClassRegisterByIdResultHandler(classRegisterVO:ClassRegisterVO):void
{
	var editClassRegComp:CreateClassRegistrationComp=new CreateClassRegistrationComp();
	editClassRegComp.title="Edit Class Registration";
	editClassRegComp.addEventListener(FlexEvent.REMOVE, getUpdatedClassRegistrations);
	PopUpManager.addPopUp(editClassRegComp, this, true, null);
	PopUpManager.centerPopUp(editClassRegComp);
	editClassRegComp.classesAC=classes;
	editClassRegComp.init(classRegisterVO);
}

/**
 *
 * @public
 * This function is the result handler for searching the class registrations based on the given criteria
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param classRegisters type of ArrayCollection
 * @return void
 *
 */
public function searchForClassRegisterResultHandler(classRegisters:ArrayCollection):void
{
	clearClassRegistrations();
	hasClickedSearchButton=true;
	//If result from server is not null then add the result to 'classRegistrationsAC' arraycollection.
	//Else show error mesage.
	if (classRegisters != null)
	{
		if (classRegisters.length > 0)
		{
			var classRegisterVO:ClassRegisterVO;
			var tmpAC:ArrayCollection=classRegisters;
			var tempclassRegistrationsAC:ArrayCollection=new ArrayCollection();
			for (var i:int=0; i < tmpAC.length; i++)
			{
				classRegisterVO=new ClassRegisterVO();
				classRegisterVO.user=new UserVO();
				classRegisterVO.aviewClass=new ClassVO();
				classRegisterVO=ObjectUtil.copy(tmpAC[i]) as ClassRegisterVO;
				classRegisterVO.userName=tmpAC[i].user.userName;
				classRegisterVO.className=tmpAC[i].aviewClass.className;
				classRegisterVO.instituteName=tmpAC[i].aviewClass.instituteName;
				classRegisterVO.courseName=tmpAC[i].aviewClass.courseName;
				classRegisterVO.firstName=tmpAC[i].user.fname;
				classRegisterVO.lastName=tmpAC[i].user.lname;
				classRegisterVO.statusName=GCLMContext.statusesHash[tmpAC[i].statusId];
				tempclassRegistrationsAC.addItem(classRegisterVO);
			}
			classRegistrationsAC=tempclassRegistrationsAC;
		}
		else
		{
			//Fix for Bug#15109
			CustomAlert.info("No Class registration found for the given search criteria");
		}
	}
	else
	{
		CustomAlert.info("Error occured while fetching the class registration");
	}
}

/**
 *
 * @public
 * This function is the result handler for getting the aview classes
 * This function is made public because the ClassHelper.as will call this once it
 * gets the result from the server
 * @param classesResult type of ArrayCollection
 * @return void
 *
 */
public function getActiveClassesResultHandler(classesResult:ArrayCollection):void
{
	//If result from server is not null then add the result to 'classes' arraycollection.
	//Else show error mesage.
	if (classesResult != null)
	{
		if (classesResult.length > 0)
		{
			GCLMContext.sortSmartComboDataProvider(classesResult, "className");
			classes=classesResult;
				//			ArrayCollectionUtil.copyData(classesAC, classes);
		}
		else
		{
			CustomAlert.info("No classes are available");
		}
	}
	resetSearchItems();
}

/**
 *
 * @public
 * This function is the result handler for getting the courses
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param coursesResult type of ArrayCollection
 * @return void
 *
 */
public function getActiveCoursesResultHandler(coursesResult:ArrayCollection):void
{
	//If result from server is not null then add the result to 'courses' arraycollection.
	//Else show error mesage.
	if (coursesResult != null)
	{
		if (coursesResult.length > 0)
		{
			GCLMContext.sortSmartComboDataProvider(coursesResult, "courseName");
			courses=coursesResult;
		}
		else
		{
			CustomAlert.info("No courses are available");
		}
	}
	resetSearchItems();
}

/**
 *
 * @public
 * This function is the result handler for deleting the class registration
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of ResultEvent
 * @return void
 *
 */
public function deleteClassRegisterResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Class Registration deleted successfully");
	//Perform the search again if the previous search has more than one result set 
	if (classRegistrationsAC.length > 1)
	{
		searchClassRegistration();
	}
	else
	{
		clearClassRegistrations();
	}
}

/**
 *
 * @private
 * This function is to get all the institutes that offers atleast one course.
 * The institute result depends on the user role
 *
 * @return void
 *
 */
private function getCourseOfferingInstitutes():void
{
	//Comment the if else condition
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		instituteHelper.getAllCourseOfferingInstitutesForAdmin(ClassroomContext.userVO.userId,getAllCourseOfferingInstitutesResultHandler);
	}
	else
	{
		instituteHelper.getAllCourseOfferingInstitutes(getAllCourseOfferingInstitutesResultHandler);
	}
}

/**
 *
 * @private
 * This function is to set the icons for different control buttons
 *
 * @return void
 *
 */
private function setIcons():void
{
	createIcon=createIconEnabled;
	updateIcon=updateIconEnabled;
	deleteIcon=deleteIconEnabled;
}

/**
 *
 * @private
 * This function is to rest the search results
 *
 * @return void
 *
 */
private function reset():void
{
	clearDataProviders();
//	resetSearchItems();
}

/**
 *
 * @private
 * This function is to clear the search criteria
 *
 * @return void
 *
 */
private function resetSearchItems():void
{
	hasClickedSearchButton=false;
	txtInpUserFirstName.text="";
	txtInpUserLastName.text="";
	txtInpUserName.text="";
	cmbModerator.selectedIndex=0;
	hasClickedSearchButton=false;
	cmbClassName.selectedItem=null;
	cmbClassName.filterString="";
	cmbCourseName.selectedItem=null;
	cmbCourseName.filterString="";
	cmbInstituteName.selectedItem=null;
	cmbInstituteName.filterString="";
	//Fix for Bug#14951
	cmbClassName.text = "";
	cmbCourseName.text = "";
	cmbInstituteName.text = "";

}

/**
 *
 * @private
 * This function is to actually clear all the data providers
 *
 * @return void
 *
 */
private function clearDataProviders():void
{
	clearClassRegistrations();
	classes.removeAll();
	classes=new ArrayCollection();
	courses.removeAll();
	courses=new ArrayCollection();
}

/**
 *
 * @private
 * This function is to clear the class registration search result
 *
 * @return void
 *
 */
private function clearClassRegistrations():void
{
	// Fix for Bug #14855,#14837
	classRegistrationsAC.source = [] ;	
}

/**
 *
 * @private
 * This function is to disable all the action buttons depends on the user credentials
 *
 * @return void
 *
 */
//NPCR : Buttons has been mispelled in function disableAllActionButtons
private function disableAllActionButtions():void
{
	txtInpUserName.visible=false;
	txtInpUserFirstName.visible=false;
	txtInpUserLastName.visible=false;
	
	lblUserFirstName.visible=false;
	lblUserLastName.visible=false;
	lblUserName.visible=false;
	lblModerator.visible=false;
	
	btnDelete.visible=false;
	
	//Now viewers can also edit the modules in the class registration
	//btnEditClassReg.visible = false;
	cmbModerator.visible=false;
}

/**
 *
 * @private
 * This function is to set the user details in case of Students, since they cannot see other user details
 *
 * @return void
 *
 */
private function setUser():void
{
	txtInpUserName.text=ClassroomContext.userVO.userName;
	txtInpUserFirstName.text=ClassroomContext.userVO.fname;
	txtInpUserLastName.text=ClassroomContext.userVO.lname;
}

/**
 *
 * @private
 * This function is to get all the classes based on the user credentials
 *
 * @return void
 *
 */
private function getClasses():void
{
	//If login user's role is admin,then call server function to get classes for admin.
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		classHelper.getActiveClassesByAdmin(ClassroomContext.userVO.userId,getActiveClassesResultHandler);
	}
	//To get active classes
	else
	{
		classHelper.getActiveClasses(getActiveClassesResultHandler);
	}
}

/**
 *
 * @private
 * This function is to get all the courses based on the user credentials
 *
 * @return void
 *
 */
private function getCourses():void
{
	//If login user's role is admin,then call server function to get courses for admin.
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		courseHelper.getActiveCoursesByAdmin(ClassroomContext.userVO.userId,getActiveCoursesResultHandler);
	}
	//To get active courses
	else
	{
		courseHelper.getActiveCourses(getActiveCoursesResultHandler);
	}
}

/**
 *
 * @private
 * This function is to invoke the ClassRegistrationApprovalComp
 *
 * @return void
 *
 */
private function createClassRegistrationApproval():void
{
	btnApproveClassReg.enabled=false;
	var approveClassRegComp:ClassRegistrationApprovalComp=new ClassRegistrationApprovalComp();
	approveClassRegComp.addEventListener(FlexEvent.REMOVE, getUpdatedClassRegistrations);
	//approveClassRegComp.classesAC = ObjectUtil.copy(classesAC) as ArrayCollection;
	PopUpManager.addPopUp(approveClassRegComp, this, true, null);
	PopUpManager.centerPopUp(approveClassRegComp);
	approveClassRegComp.init();
}

/**
 *
 * @private
 * This function is to invoke the CreateClassRegistration for creating a new class registration
 *
 * @return void
 *
 */
private function createClassRegistration():void
{
	btnCreate.enabled=false;
	var createClassRegComp:CreateClassRegistrationComp=new CreateClassRegistrationComp();
	createClassRegComp.title="Create Class Registration";
	createClassRegComp.isUserRegistration=true;
	createClassRegComp.addEventListener(FlexEvent.REMOVE, getUpdatedClassRegistrations);
	PopUpManager.addPopUp(createClassRegComp, this, true, null);
	PopUpManager.centerPopUp(createClassRegComp);
	hideClosedClassForRegistration(createClassRegComp);
	createClassRegComp.init();
}

/**
 *
 * @private
 * This function is to get the class registrations after performing actions like add/update/delete/approve
 * @param event type of FlexEvent
 * @return void
 *
 */
private function getUpdatedClassRegistrations(event:FlexEvent):void
{
	btnCreate.enabled=true;
	btnEditClassReg.enabled=true;
	btnApproveClassReg.enabled=true;
	//Check if the cancel button is not clicked in the create class registration window 
	//and a previous search has taken place. If so, perform the search again to get 
	//the latest result
	if ((!event.target.hasClickedCancelButton) && (hasClickedSearchButton))
	{
		searchClassRegistration();
	}
}

/**
 *
 * @private
 * This function is to invoke the CreateClassRegistration for editing the selected class registration
 *
 * @return void
 *
 */
private function editClassRegistration():void
{
	//Check if the user has not selected any item for editing
	if (dgClassRegistrations.selectedItem == null)
	{
		CustomAlert.info("Please Select any User from the List");
	}
	else
	{
		btnEditClassReg.enabled=false;
		getClassRegistrationByIdAndLaunchUpdateClassRegistration(dgClassRegistrations.selectedItem.classRegisterId);
	}
}

/**
 *
 * @private
 * This function is to get the class registration details which the user has selected for edit
 * @param classRegistrationId type of Number
 * @return void
 *
 */
private function getClassRegistrationByIdAndLaunchUpdateClassRegistration(classRegistrationId:Number):void
{
	classRegistrationHelper.getClassRegistrationById(classRegistrationId,getClassRegisterByIdResultHandler) ;
}

/**
 *
 * @private
 * This function is to get confirmation from the user before deleting the class registration
 *
 * @return void
 *
 */
private function deleteClassRegistration():void
{
	//Select one class registration entry to delete
	//Check if the user has not selected any item for editing
	if (dgClassRegistrations.selectedItem == null)
	{
		CustomAlert.info("Please Select any Entry from the List");
	}
	else
	{
		CustomAlert.confirm("Are you sure you want to delete the selected entry?", "Confirmation", confirmDeleteClassRegistration);
	}
}

/**
 *
 * @private
 * This function actually deletes the selected class registration
 * @param event type of CloseEvent
 * @return void
 *
 */
private function confirmDeleteClassRegistration(event:CloseEvent):void
{
	//Check if the user has confirmed the delete class registration option
	if (event.detail == Alert.YES)
	{
		classRegistrationHelper.deleteClassRegister(dgClassRegistrations.selectedItem.classRegisterId,deleteClassRegisterResultHandler);
	}
}

/**
 *
 * @private
 * This function is to search the class registration based on the given search criteria
 *
 * @return void
 *
 */
private function searchClassRegistration():void
{
	//Variable to hold user name to be searched
	var searchUserName:String=txtInpUserName.text;
	//Variable to hold first name to be searched
	var searchFirstName:String=txtInpUserFirstName.text;
	//Variable to hold last name to be searched
	var searchLastName:String=txtInpUserLastName.text;
	//Variable to hold moderator to be searched
	var searchModerator:String=null;
	//Variable to hold class id to be searched
	var searchClassId:Number=0;
	//Variable to hold course id to be searched
	var searchCourseId:Number=0;
	//Variable to hold institute id to be searched
	var searchInstituteId:Number=0;
	//Check if the user has input a valid class name
	if ((cmbClassName.text != "") && (cmbClassName.selectedItem != null) && (cmbClassName.selectedItem.classId != 0))
	{
		searchClassId=cmbClassName.selectedItem.classId;
	}
	else if (cmbClassName.text != "")
	{
		//Fix for Bug#14951
		CustomAlert.info("No results found for the given search criteria.","Information",alertCloseHandlerForComboBox);
		return;
	}
	//Check if the user has input a valid course name
	if ((cmbCourseName.text != "") && (cmbCourseName.selectedItem != null) && (cmbCourseName.selectedItem.courseId != 0))
	{
		searchCourseId=cmbCourseName.selectedItem.courseId;
	}
	else if (cmbCourseName.text != "")
	{
		//Fix for Bug#14951
		CustomAlert.info("No results found for the given search criteria.","Information",alertCloseHandlerForComboBox);
		return;
	}
	//Check if the user has input a valid Institute name
	if ((cmbInstituteName.text != "") && (cmbInstituteName.selectedItem != null) && (cmbInstituteName.selectedItem.instituteId != 0))
	{
		searchInstituteId=cmbInstituteName.selectedItem.instituteId;
	}
	else if (cmbInstituteName.text != "")
	{
		//Fix for Bug#14951
		CustomAlert.info("No results found for the given search criteria.","Information",alertCloseHandlerForComboBox);
		return;
	}
	//Check if the user is searching for reistrations who have moderator role
	if (cmbModerator.selectedIndex != 0)
	{
		searchModerator=cmbModerator.selectedItem.toString();
	}
	
	// Fix for Bug #3117, 19602 start
	//Depends upon the user role type, call the appropriate search API
	//API call if the user role is Teacher/Student
	if ( (ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || 
		 (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) ||
		 (ClassroomContext.userVO.role == Constants.MONITOR_TYPE) )
	{
		classRegistrationHelper.searchForClassRegisterForUser(ClassroomContext.userVO.userId, searchClassId, searchModerator, searchCourseId, searchInstituteId,searchForClassRegisterResultHandler);
	}
	//Fix for Bug #3117, 19602 end
	//
	//API call if the user role is Inst administrator
	else if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		//Fix for Bug#15350
		if(searchUserName == "" && searchFirstName == "" && searchLastName == "" && cmbClassName.text == "" && cmbCourseName.text == "" && cmbInstituteName.text =="")
		{
			CustomAlert.info("Please enter any search criteria.");
			return;
		}
		classRegistrationHelper.searchForClassRegister(searchUserName, searchFirstName, searchLastName, searchClassId, searchModerator, searchCourseId, searchInstituteId,searchForClassRegisterResultHandler, ClassroomContext.userVO.userId);
	}
	//API call if the user role is Master admin
	//Fix for Bug #3117, 19602 start
	else if(ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
	//Fix for Bug #3117, 19602 end
	{
		//Fix for Bug#15350
		if(searchUserName == "" && searchFirstName == "" && searchLastName == "" && cmbClassName.text == "" && cmbCourseName.text == "" && cmbInstituteName.text =="")
		{
			CustomAlert.info("Please enter any search criteria.");
			return;
		}
		classRegistrationHelper.searchForClassRegister(searchUserName, searchFirstName, searchLastName, searchClassId, searchModerator, searchCourseId, searchInstituteId,searchForClassRegisterResultHandler);
	}
	// Fix for Bug #3117 end
}

/**
 *
 * @private
 * This function is to clear all the fields in the ClassRegistrationComp
 *
 * @return void
 *
 */
private function clearFields():void
{
	clearClassRegistrations();
	resetSearchItems();
	//Depends upon the user role type, set the user details by default
	// Fix for Bug #19717 start 
	if ((ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
	// Fix for Bug #19717 end 
	{
		setUser();
	}
}

/**
 *
 * @private
 * This function is to hide the classes that are closed for new registration before opening the CreateClassRegistrationComp
 * @param classRegComp type of CreateClassRegistrationComp
 * @return void
 *
 ***/
private function hideClosedClassForRegistration(classRegComp:CreateClassRegistrationComp):void
{
	var tmpClassesAC:ArrayCollection=new ArrayCollection();
	//Check the status of each of the class. If the status is other than active, then do not add
	for (var i:int=0; i < classes.length; i++)
	{
		if (classes[i].statusId == StatusVO.ACTIVE_STATUS)
		{
			tmpClassesAC.addItem(ObjectUtil.copy(classes[i]) as ClassVO);
		}
	}
	classRegComp.classesAC=tmpClassesAC;
}

//Code change for NIC start
/**
 *
 * @private
 * This function is to make Approve button visible/invisible for teachers
 * @param flag type of Boolean
 * @return void
 *
 */
private function setVisibleApproveButton(flag:Boolean):void
{
	btnApproveClassReg.visible=flag;
}
//Code change for NIC end
//Fix for Bug#14951 :Start
private function comboBoxChangeHandler(e:Event):void
{
	var tempValue:String = e.currentTarget.filterString;
	switch(e.currentTarget)
	{
		case cmbClassName :
			if(cmbClassName.selectedItem == null)
			{
				cmbClassName.text = tempValue;
			}
			break;
		case cmbCourseName : 
			if(cmbCourseName.selectedItem == null)
			{
				cmbCourseName.text = tempValue;
			}
			break;
		case cmbInstituteName :
			if(cmbInstituteName.selectedItem == null)
			{
				cmbInstituteName.text = tempValue;
			}
			break;
	}
}
private function alertCloseHandlerForComboBox(ev:CloseEvent):void
{ 
	if(cmbClassName.selectedIndex < 0 )
		cmbClassName.text = "";	
	if(cmbCourseName.selectedIndex < 0 )
		cmbCourseName.text = "";	
	if(cmbInstituteName.selectedIndex < 0 )
		cmbInstituteName.text = "";	
}
//Fix for Bug#14951 :End