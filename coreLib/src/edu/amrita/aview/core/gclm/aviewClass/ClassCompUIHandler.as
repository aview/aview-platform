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
 * File			: ClassCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This Action Script handler for ClassComp. AVIEW Class creation
 * depends on course creation. Each aview class corresponds to a course.
 * Based on the logged in user credentials this component behaves as follows:
 * Master Admin: Can view all classes, Create, edit and Delete of classes for any course any institute
 * Institute Administrators: Can view all the classes belongs to their institute/child institutes.
 * Create, Edit and Delete of classes are also possible within their institute boundary
 * Presenter and Viewer: Can view only those classes for which they have been registered.
 * Moderator: Moderator can edit class details.
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.aviewClass.CreateClassComp;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.CourseHelper;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.AViewDateUtil;
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
 * This constant variable is used to display the week 
 * days in the create class window, to choose the 
 * week days on which the class has to be scheduled 
 */
private const WEEK_DAYS_TO_DISPLAY:Array=["M", "Tu", "W", "Th", "F", "Sa", "Su"];

/**
 * Icon for create class  
 */
[Bindable]
private var iconClassCreate:Class;
/**
 * Icon for delete class  
 */
[Bindable]
private var iconClassDelete:Class;
/**
 * Icon for update class  
 */
[Bindable]
private var iconClassUpdate:Class;

/**
 * Variables for icon class.  
 */
[Bindable]
[Embed(source="../assets/images/dis_delete.png")]
private var imgDeleteIconDisabled:Class;

[Bindable]
[Embed(source="../assets/images/dis_edit.png")]
private var imgUpdateIconDisabled:Class;

[Bindable]
[Embed(source="../assets/images/create.png")]
private var imgCreateIconEnabled:Class;

[Bindable]
[Embed(source="../assets/images/delete.png")]
private var imgDeleteIconEnabled:Class;

[Bindable]
[Embed(source="../assets/images/edit.png")]
private var imgUpdateIconEnabled:Class;
/**
 *  variable for active courses 
 */
[Bindable]
private var acActiveCourses:ArrayCollection=new ArrayCollection();
/**
 * variable for aview classes  
 */
[Bindable]
private var acAviewClasses:ArrayCollection=new ArrayCollection();

/**
 * The following variables are the instances 
 * of various helper classes to call the 
 * server side APIs using remote objects 
 */
private var classHelper:ClassHelper=null;
private var courseHelper:CourseHelper=null;
private var instituteHelper:InstituteHelper=null;
private var lectureHelper:LectureHelper=null;
private var classRegistrationHelper:ClassRegistrationHelper=null;

/**
 * This boolean is to keep track of the click 
 * action on the search button which is required 
 * when the ddata gets refreshed 
 */
private var hasClickedSearchButton:Boolean=false;

/**
 * To hold the number of lectures for a class 
 */
private var lectureCountForClass:int=0;

/**
 * To hold the number of class registrations for a class 
 */
private var registrationCountForClass:int=0;
/**
 * Code change for NIC start
 * To check if the user is the moderator for the selected class 
 */
private var isModerator:String="Y";

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.aviewClass.ClassCompUIHandler.as");

//Code change for NIC end
/**
 * @public
 * This is the very first function that is called whenever the component gets invoked.
 * This function cleans up all the previous data if any and gets all the required
 * initial info required for the class component
 * 
 * @params Null
 * @return void
 *
 */
public function initClassComp():void
{
	instituteHelper=new InstituteHelper();
	classHelper=new ClassHelper();
	courseHelper=new CourseHelper();
	lectureHelper=new LectureHelper();
	classRegistrationHelper=new ClassRegistrationHelper();
	resetInitialData();
	setIcons();
	//Code change for NIC start
	//Set the update button visible to the teacher.
	//Fix for bug # 19529 start
	if ( (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) ||
		 (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
	//Fix for bug # 19529 end	
	{
		// Fix Bug for #14700 .. commented the function call below
	//	getClassByUserId();
		// NPCR : Error in the word Button of the function call.
		disableAllActionButtions();
		setUpdateClassButtonVisible(false);
	}
	else if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		// Fix Bug for #14700 .. commented the function call below
	//	getClassByUserId();
		disableAllActionButtions();
		setUpdateClassButtonVisible(true);
		setUpdateClassButtonEnabled(false);
	}
	//Code change for NIC end
	getCourses();
	getCourseOfferingInstitutes();
}
//Code change for NIC start
/**
 *
 * @public
 * This function is the result handler to search if the  given user is a moderator for the class
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * 
 * @param classRegVO type of ArrayCollection
 * @return void
 *
 */
public function searchForClassRegisterResultHandler(classRegVO:ArrayCollection):void
{
	if ((classRegVO != null) && (classRegVO.length > 0))
	{
		setUpdateClassButtonEnabled(true);
	}
	else
	{
		setUpdateClassButtonEnabled(false);
	}
}

//Code change for NIC end
/**
 *
 * @public
 * This function is the result handler for getting all the institutes that offer atleast one course
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * 
 * @param classRegVO type of ArrayCollection
 * @return void
 *
 */
public function getAllCourseOfferingInstitutesResultHandler(institutes:ArrayCollection):void
{
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
 * Handles result after getting lecture count from server.
 * @param count type of number
 * @return void
 * 
 */
public function getLectureCountResultHandler(count:Number):void
{
	lectureCountForClass=count;
	classRegistrationHelper.getClassRegistrationCount(dgClasses.selectedItem.classId,getClassRegistrationCountResultHandler);
}
/**
 * 
 * @public 
 * Handles result after getting class registration count from server.
 * @param count type of number
 * @return void
 * 
 */
public function getClassRegistrationCountResultHandler(count:Number):void
{
	registrationCountForClass=count;
	var warningMsgBeforeDelete:String="";
	//Check if number of lecture in a class is greater than zero and number of registration in a class is greater than zero,then set appropriate message.
	if (lectureCountForClass > 0 && registrationCountForClass > 0)
	{
		warningMsgBeforeDelete="Deleting the Class will delete the Lectures and Classes registered.Are you sure you want to delete the selected Class?";
	}
	//Check if number of lecture in a class is greater than zero,then set appropriate message.
	else if (lectureCountForClass > 0)
	{
		warningMsgBeforeDelete="Deleting the Class will delete the Lectures registered.Are you sure you want to delete the selected Class?";
	}
	//Check if number of registration in a class is greater than zero,then set appropriate message.
	else if (registrationCountForClass > 0)
	{
		warningMsgBeforeDelete="Deleting the Class will delete the Classes registered.Are you sure you want to delete the selected Class?"
	}
	else
	{
		warningMsgBeforeDelete="Are you sure you want to delete the selected class?";
	}
	CustomAlert.confirm(warningMsgBeforeDelete, "Confirmation", confirmDeleteClass);
}
/**
 * 
 * @public 
 * Handles result after getting class from server.
 * @param classVO type of ClassVO
 * @return void
 * 
 */
public function getClassByIDResultHandler(classVO:ClassVO):void
{
	var editClassComp:CreateClassComp=new CreateClassComp();
	PopUpManager.addPopUp(editClassComp, this, true, null);
	PopUpManager.centerPopUp(editClassComp);
	editClassComp.addEventListener(FlexEvent.REMOVE, getClassesOnUpdate);
	editClassComp.title="Edit Class";
	editClassComp.activeCourses=acActiveCourses;
	editClassComp.init(classVO);
}

/**
 * 
 * @public  
 * Handles result after closing class registration.
 * @param event of result
 * @return void
 * 
 */
public function closeClassForRegistrationResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Class closed for registration successfully");
	searchClass();
}
/**
 * 
 * @public  
 * Handles result after activating class for registration.
 * @param event of result
 * @return void 
 * 
 */
public function activateClassForRegistrationResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Class activated for registration successfully");
	searchClass();
}
/**
 * @public
 * Handles result after deleting class.
 * @param event of result
 * @return void
 */
public function deleteClassResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Class deleted successfully");
	//If class exist then search class.
	//Else clear all classes.
	if (acAviewClasses.length > 1)
	{
		searchClass();
	}
	else
	{
		clearClasses();
	}
}
/**
 * 
 * @public  
 * Handles result after searching class.
 * @param aviewClasses type of ArrayCollection
 * @return void 
 */
public function searchClassResultHandler(aviewClasses:ArrayCollection):void
{
	clearClasses();
	//If search result is not null then set week days and add it to 'acAviewClasses' arraycollection.
	if (aviewClasses != null)
	{
		if (aviewClasses.length > 0)
		{
			var tmpAC:ArrayCollection=new ArrayCollection();
			var classVO:ClassVO;
			for (var i:int=0; i < aviewClasses.length; i++)
			{
				classVO=aviewClasses[i] as ClassVO;
				setWeekDays(classVO);
				tmpAC.addItem(classVO);
			}
			acAviewClasses=tmpAC;
			acAviewClasses.refresh();
		}
		else
		{
			CustomAlert.info("No class(es) found for the given search criteria");
		}
	}
	else
	{
		CustomAlert.info("Error occured while searching for a class");
	}
}
/**
 * 
 * @public
 *  Handles result after getting active class.
 * @param classes type of ArrayCollection
 * @return void 
 */
public function getActiveClassesResultHandler(classes:ArrayCollection):void
{
	clearClasses();
	//If result from the server(classes) is not null, then set week days and add it to 'acAviewClasses' arraycollection.
	if ((classes != null) && (classes.length > 0))
	{
		//Temporary arraycollection for storing class details.
		var tmpAC:ArrayCollection=new ArrayCollection();
		//Variable to store class details.
		var classVO:ClassVO;
		for (var i:int=0; i < classes.length; i++)
		{
			classVO=classes[i] as ClassVO;
			setWeekDays(classVO);
			tmpAC.addItem(classVO);
		}
		acAviewClasses=tmpAC;
		acAviewClasses.refresh();
	}
}
/**
 * 
 * @public 
 * Handles result after getting active courses.
 * @param courses type of Array Collection 
 * @return void
 */
public function getActiveCoursesResultHandler(courses:ArrayCollection):void
{
	//If result from the server(courses) is not null,then sort it and assign result to 'acActiveCourses' arraycollection.
	if (courses != null)
	{
		if (courses.length > 0)
		{
			//ArrayCollectionUtil.copyData(coursesAC, courses);
			GCLMContext.sortSmartComboDataProvider(courses, "courseName");
			acActiveCourses=courses;
		}
		else
		{
			CustomAlert.info("No courses found");
		}
	}
	else
	{
		CustomAlert.info("Error occured while searching for course")
	}
	resetSearchItems();
}
/**
 * @private
 * This function enables/disables the class activation button based on the
 * status of the class
 *
 * @params Null
 * @return void
 */
private function toggleClassActivationButton():void
{
	//Check if any item is selected. If nothing is selected do nothing
	if (dgClasses.selectedItem != null)
	{
		//If the selected class is closed for registration, give the option for 
		//opening the class for registration
		//NPCR: Can use conditional operator instead of if else
		if (dgClasses.selectedItem.statusId == StatusVO.CLOSED_STATUS)
		{
			setClassActivationButtons(true);
		}
		else
		{
			setClassActivationButtons(false);
		}
		//Code change for NIC start
		//The moderator of the class should be able to edit the class.
		if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
		{
			setClassEditForModerator();
		}
			//Code change for NIC end
	}
}
//Code change for NIC start
/**
 *
 * @private
 * This function is to hide the edit button if the user is a student
 * 
 * @param flag type of boolean to set
 * @return void
 *
 */
private function setUpdateClassButtonVisible(flag:Boolean):void
{
	btnClassUpdate.visible=flag;
	//Set the position of the update button, if the create button is not visible to the user
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		btnClassUpdate.left=btnCreateClass.left;
		btnClassUpdate.bottom=btnCreateClass.bottom;
	}
}

/**
 *
 * @private
 * This function is to enable the edit button, 
 * if the user is the moderator for the class
 * 
 * @param flag type of boolean to set
 * @return void
 *
 */
private function setUpdateClassButtonEnabled(flag:Boolean):void
{
	btnClassUpdate.enabled=flag;
}

/**
 *
 * @private
 * This function is to check if the user is the moderator for the selected class
 * 
 *
 * @return void
 *
 */
private function setClassEditForModerator():void
{
	var classvo:ClassVO=dgClasses.selectedItem as ClassVO;
	classRegistrationHelper.searchForClassRegisterForUser(ClassroomContext.userVO.userId, classvo.classId, isModerator, 0, 0,searchForClassRegisterResultHandler);
}

//Code change for NIC end
/**
 *
 * @private
 * This function is set the class status closed to active
 * 
 * @param flag type of Boolean to set
 * @return void
 *
 */
private function setClassActivationButtons(flag:Boolean):void
{
	btnOpenClassForRegistration.enabled=flag;
	btnCloseClassForRegistration.enabled=!flag;
}

/**
 *
 * @private
 * This function is to get all the institutes that offers atleast one course
 * 
 *
 * @return void
 *
 ***/
private function getCourseOfferingInstitutes():void
{
	//If user role is admin call a server function.
	//Else call another function.
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
 * This function is to set icons for the control buttons
 * 
 *
 * @return void
 *
 */
private function setIcons():void
{
	iconClassCreate=imgCreateIconEnabled;
	iconClassUpdate=imgUpdateIconEnabled;
	iconClassDelete=imgDeleteIconEnabled;
}

/**
 *
 * @private
 * This function is to reset all the initial data
 * 
 *
 * @return void
 *
 */
private function resetInitialData():void
{
	clearDataProviders();
}

/**
 *
 * @private
 * This function is to reset all the search criteria
 * 
 *
 * @return void
 *
 */
private function resetSearchItems():void
{
	txtInpClassName.text="";
	cmbInstitutes.selectedItem=null;
	cmbInstitutes.filterString="";
	cmbCourses.selectedItem=null;
	cmbCourses.filterString="";
	hasClickedSearchButton=false;
	//Fix for Bug#14917
	cmbCourses.text = "";
	cmbInstitutes.text = "";
}
/**
 * 
 * @private 
 * Clearing class and course dataproviders.
 *
 * @return void 
 */
private function clearDataProviders():void
{
	clearClasses();
	acActiveCourses.removeAll();
}
/**
 * @private
 * Clearing classes.
 *
 * @return void 
 */
private function clearClasses():void
{
	acAviewClasses.removeAll();
	//Code change for NIC start
	//Disable the update button when a new search is applied
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		setUpdateClassButtonEnabled(false);
	}
	//Code change for NIC end
}
/**
 * @private
 * Disabling all functional buttons.
 *
 * @return void 
 */
//NPCR: Error in the word Button of the function
private function disableAllActionButtions():void
{
	btnCreateClass.visible=false;
	btnClassDelete.visible=false;
	btnCloseClassForRegistration.visible=false;
	btnOpenClassForRegistration.visible=false;
}
/**
 * @private
 * To get active courses from server according to the user role
 *
 * @return void 
 */
private function getCourses():void
{
	//If user role is admin call a server function.
	//Else call another function.
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		courseHelper.getActiveCoursesByAdmin(ClassroomContext.userVO.userId,getActiveCoursesResultHandler);
	}
	else
	{
		courseHelper.getActiveCourses(getActiveCoursesResultHandler);
	}
}
/**
 * @private
 * Confirmation function for closing class registration. 
 * @param event of close
 * @return void
 */
private function confirmCloseClassForRegistration(event:CloseEvent):void
{
	//If user confirms,then call server function to close class registration. 
	if (event.detail == Alert.YES)
	{
		classHelper.closeClassForRegistration(dgClasses.selectedItem.classId, ClassroomContext.userVO.userId,closeClassForRegistrationResultHandler);
	}
}

/**
 * @private 
 * Confirmation function for deleting class. 
 * @param e type of close default null
 * @return void
 */
private function confirmDeleteClass(e:CloseEvent=null):void
{
	//If user confirms,then call server function to delete class. 
	if ((e == null) || (e.detail == Alert.YES))
	{
		classHelper.deleteClass(dgClasses.selectedItem.classId, ClassroomContext.userVO.userId,deleteClassResultHandler);
	}
}
/**
 * @private 
 * Clearing all search input's.
 *
 * @return void 
 */
private function clearSearch():void
{
	resetSearchItems();
	clearClasses();
}
/**
 * @private 
 * To create class.
 *
 * @return void 
 */
private function createClass():void
{
	btnCreateClass.enabled=false;
	var createClassComp:CreateClassComp=new CreateClassComp();
	PopUpManager.addPopUp(createClassComp, this, true, null);
	PopUpManager.centerPopUp(createClassComp);
	createClassComp.addEventListener(FlexEvent.REMOVE, getClassesOnUpdate);
	createClassComp.title="Create Class";
	createClassComp.activeCourses=acActiveCourses;
	createClassComp.init();
}
/**
 * @private 
 * To edit class.
 *
 * @return void 
 */
private function editClass():void
{
	//If user select an item from classes datagrid.
	//Else show error message.
	if (dgClasses.selectedItem != null)
	{
		setUpdateClassButtonEnabled(false);
		getClassByIdAndLaunchUpdateClass(dgClasses.selectedItem.classId);
	}
	else
	{
		CustomAlert.info("Please select a class to edit");
	}
}
/**
 * @private 
 * To get class details from server for a particular user id.
 *
 * @return void 
 */
private function getClassByUserId():void
{
	classHelper.getClassByUserId(ClassroomContext.userVO.userId,getActiveClassesResultHandler);
}

/**
 * @private 
 * To get class details from server for a particular class id.
 * @param classId type of Number
 * @return void 
 */
private function getClassByIdAndLaunchUpdateClass(classId:Number):void
{
	classHelper.getClassByID(classId,getClassByIDResultHandler);
}
/**
 * @private  
 * To update all class details after creating/editing a class 
 * @param event of Flex
 * @return void
 */
private function getClassesOnUpdate(event:FlexEvent):void
{
	btnCreateClass.enabled=true;
	//If user role is admin call a function to edit class for moderator.
	//Else set update button enabled.
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		//Fix for Bug # 10049 start
		setClassEditForModerator();
		//Fix for Bug # 10049 end
	}
	else
	{
		setUpdateClassButtonEnabled(true);
	}
	//If the user has performed a search before create/edit, and if the user has not clicked 
	//on the cancel button in the create/edit window, then do the search again
	
	//Fix for Bug #15009
	if(!event.target.hasClickedCancelButton)
	{
		if(hasClickedSearchButton)
		{
			searchClass();
		}
		//Fix for Bug #15243 Commented the condition
		/*//Fix for Bug #14633,#14878
		else
		{
			getClassByUserId();
		}*/
	}
}
/**
 * @private 
 * To delete a class.
 *
 * @return void 
 */
private function deleteClass():void
{
	//If user doesn't select an item from classes datagrid,then show error message.
	//Else call server function to get lecture count.
	if (dgClasses.selectedItem == null)
	{
		CustomAlert.info("Please select a class from the List");
	}
	else
	{
		//CustomAlert.confirm("Are you sure you want to delete the selected class?", "Confirmation", confirmDeleteClass);
		lectureCountForClass=0;
		registrationCountForClass=0;
		lectureHelper.getLectureCount(dgClasses.selectedItem.classId,getLectureCountResultHandler);
	}

}
/**
 * @private 
 * To close class registration.
 *
 * @return void 
 */
private function closeClassForRegistration():void
{
	//If user doesn't select an item from classes datagrid,then show error message.
	//Else show confirmation message.
	if (dgClasses.selectedItem == null)
	{
		CustomAlert.info("Please select a class from the List");
	}
	else
	{
		CustomAlert.confirm("Are you sure you want to close the registration for the selected class?", "Confirmation", confirmCloseClassForRegistration);
	}
}
/**
 * @private 
 * To activate class for registration.
 *
 * @return void 
 */
private function activateClassForRegistration():void
{
	//If user doesn't select an item from classes datagrid,then show error message.
	//Else call server function.
	if (dgClasses.selectedItem == null)
	{
		CustomAlert.info("Please select a class from the List");
	}
	else
	{
		classHelper.activateClassForRegistration(dgClasses.selectedItem.classId, ClassroomContext.userVO.userId,activateClassForRegistrationResultHandler);
	}
}

/**
 * @private 
 * To search class
 *
 * @return void 
 */
private function searchClass():void
{
	//Institute id for searching
	var searchInstituteId:Number=0;
	//Course id for searching
	var searchCourseid:Number=0;
	//Class name for searching
	var searchClassname:String=null;
	
	//Validating user input values
	//If user input values are correct then set it
	//Else show error message.
	if ((cmbCourses.text != "") && (cmbCourses.selectedItem != null) && (cmbCourses.selectedItem.courseId != 0))
	{
		searchCourseid=cmbCourses.selectedItem.courseId;
	}
	else if (cmbCourses.text != "")
	{
		//Fix for Bug#14917
		CustomAlert.info("No results found for the given search criteria.","Information",alertCloseHandlerForComboBox);
		return;
	}
	if (txtInpClassName.text != '')
	{
		searchClassname=txtInpClassName.text;
	}
	
	if ((cmbInstitutes.text != "") && (cmbInstitutes.selectedItem != null) && (cmbInstitutes.selectedItem.instituteId != 0))
	{
		searchInstituteId=cmbInstitutes.selectedItem.instituteId;
	}
	else if (cmbInstitutes.text != "")
	{
		//Fix for Bug#14917
		CustomAlert.info("No results found for the given search criteria.","Information",alertCloseHandlerForComboBox);
		return;
	}
	
	hasClickedSearchButton=true;
	var statusIds:Array=new Array();
	statusIds.push(StatusVO.ACTIVE_STATUS);
	statusIds.push(StatusVO.CLOSED_STATUS);
	// Fix for Bug #3117 start
	
	//If user role is admin call a server function to search class with his user id..
	//Else call searchclass function without user id.
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		classHelper.searchClass(searchInstituteId, searchCourseid, searchClassname, statusIds, searchClassResultHandler,ClassroomContext.userVO.userId);
	}
	else
	{
		classHelper.searchClass(searchInstituteId, searchCourseid, searchClassname, statusIds,searchClassResultHandler);
	}
	// Fix for Bug #3117 end
}

/**
 * 
 * @private
 * This function is used to set the week days 
 * during when the aview classes have been scheduled
 * item - the new object which is inserted into the class data grid's data provider
 * 
 * @params aviewClass type of ClassVO
 * @return void
 *
 */
private function setWeekDays(aviewClass:ClassVO):void
{
	var weekDaysName:String="";
	//If week days in the class is not null then set week days name.
	if (aviewClass.weekDays != null)
	{
		for (var l:int=0; l < aviewClass.weekDays.length; l++)
		{
			if (aviewClass.weekDays.charAt(l) == "Y")
			{
				weekDaysName+=WEEK_DAYS_TO_DISPLAY[l] + ", ";
			}
		}
		weekDaysName=weekDaysName.substr(0, weekDaysName.lastIndexOf(", "));
		aviewClass.weekDaysName=ObjectUtil.copy(weekDaysName) as String;
	}
}
/**
 * @private
 * To sort start date.  
 * @param itemA type of Object
 * @param itemB type of Object
 * @return int
 */
private function sortStartDate(itemA:Object, itemB:Object):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.startDate, itemB.startDate);
}
/**
 * @private
 * To sort end date.
 * @param itemA type of Object
 * @param itemB type of Object
 * @return int
 * 
 */
private function sortEndDate(itemA:Object, itemB:Object):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.endDate, itemB.endDate);
}
/**
 * @private 
 * To sort start time. 
 * @param itemA type of Object
 * @param itemB type of Object
 * @return int
 */
private function sortStartTime(itemA:Object, itemB:Object):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.startTime, itemB.startTime);
}
/**
 * @private  
 * To sort end time. 
 * @param itemA type of Object
 * @param itemB type of Object 
 * @return int
 */
private function sortEndTime(itemA:Object, itemB:Object):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.endTime, itemB.endTime);
}

/**
 * 
 * @private 
 * This function is called whenever a new item is 
 * inserted to the class array collection.
 * Depends upon the status of the class 
 * (active, close, etc., ) it changes the color of
 * the row column. Here all the classes that are 
 * closed for registration is shown in a different color
 * 
 * @param item type of Object - the new object which is inserted into the class data grid's data provider
 * @param color type of uint  - the row color to set
 */
private function getRowColor(item:Object, color:uint):uint
{
	var result:uint=color;
	if(Log.isDebug()) log.debug("Status ids are : " + item.statusId + ":" + StatusVO.CLOSED_STATUS);
	//If the status of the AView class is closed for registration show that row
	//with a different color
	if (item.statusId == StatusVO.CLOSED_STATUS)
	{
		result=GCLMContext.REGISTRATION_CLOSED_CLASS_STATUS_ROW_COLOR;
	}
	return result;
}
//Fix for Bug#14917 :Start
private function comboBoxChangeHandler(e:Event):void
{
	var tempValue:String = e.currentTarget.filterString;
	switch(e.currentTarget)
	{
		case cmbCourses :
			if(cmbCourses.selectedItem == null)
			{
				cmbCourses.text = tempValue;
			}
			break;
		case cmbInstitutes : 
			if(cmbInstitutes.selectedItem == null)
			{
				cmbInstitutes.text = tempValue;
			}
			break;
	}
}
private function alertCloseHandlerForComboBox(ev:CloseEvent):void
{ 
	if(cmbCourses.selectedIndex < 0 )
		cmbCourses.text = "";	
	if(cmbInstitutes.selectedIndex < 0 )
		cmbInstitutes.text = "";	
}
//Fix for Bug#14917 :End