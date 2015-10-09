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
 * File			: CourseCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This Action Script handler for CourseComp.mxml
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.course.CreateCourseComp;
import edu.amrita.aview.core.gclm.vo.CourseVO;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.helper.CourseHelper;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
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

/**
 *  The icon classes 
 */
[Bindable]
[Embed(source="../assets/images/create.png")]
private var createIconEnabled:Class;
[Bindable]
[Embed(source="../assets/images/delete.png")]
private var deleteIconEnabled:Class;
[Bindable]
[Embed(source="../assets/images/edit.png")]
private var updateIconEnabled:Class;
[Bindable]
private var createIcon:Class;
[Bindable]
private var deleteIcon:Class;
[Bindable]
private var updateIcon:Class;
/**
 * To store the courses 
 */
[Bindable]
private var activeCourses:ArrayCollection=new ArrayCollection();
/**
 * To store the institute id 
 */
private var instituteId:Number=0;
/**
 * The helper classes to communicate with the server 
 */
private var instituteHelper:InstituteHelper=null;
private var classHelper:ClassHelper=null;
private var courseHelper:CourseHelper;
/**
 * To keep track if the cancel button has been clicked by the user 
 */
public var hasClickedSearchButton:Boolean=false;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.course.CourseCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the ClassRegistrationApprovalComp
 * This function is called from ClassRegistrationComp.mxml
 *
 * @return void
 *
 */
public function initApp():void
{
	instituteHelper=new InstituteHelper();
	classHelper=new ClassHelper();
	courseHelper=new CourseHelper();
	reset();
	setIcons();
	//Check if the logged in user role is Teacher/Student, then disable all the action buttons
	//Fix for bug # 19529 start
	if ((ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || 
		(ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || 
	    (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
		//Fix for bug # 19529 end	
	{
		disableAllActionButtions();
		// Fix Bug for #14700 .. commented the function call below
	//	getActiveCoursesForCurrentUser();
	}
	//Incase of Institute Admins, we need to cache the institutes here
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		getInstitutes();
	}
	else
	{
		GCLMContext.allInstitutesAC.filterFunction=null;
		GCLMContext.allInstitutesAC.refresh();
	}
	//resetSearchItems();
	resetSearchFlag();
	getCourseOfferingInstitutes();
}

/**
 *
 * @public
 * This function is the result handler for getting active courses
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param coursesResult The CourseVO arraycollection
 * @return void
 *
 */
public function getActiveCoursesResultHandler(coursesResult:ArrayCollection):void
{
	clearCourses();
	if (coursesResult != null)
	{
		if (coursesResult.length > 0)
		{
			activeCourses=coursesResult;
			// Fix for Bug #14851,#14830
			//activeCourses.refresh();
		}
	}
}

/**
 *
 * @public
 * This function is the result handler for getting all Institutes that offers atleast one course
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param institutes The InstituteVO arraycollection
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
	//If a previous search has happened perform a refresh
	if (!hasClickedSearchButton)
	{
		resetSearchItems();
	}
	else
	{
		setInstitute();
	}
}

/**
 *
 * @public
 * This function is the result handler for getting course details by the given Id
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param courseVO The courseVO
 * @return void
 *
 */
public function getCourseByIdResultHandler(courseVO:CourseVO):void
{
	var editCourse:CreateCourseComp=new CreateCourseComp();
	editCourse.title="Edit Course";
	PopUpManager.addPopUp(editCourse, this, true, null);
	PopUpManager.centerPopUp(editCourse);
	editCourse.addEventListener(FlexEvent.REMOVE, getCoursesInstitutesOnUpdate);
	editCourse.init(courseVO);
}

/**
 *
 * @public
 * This function is the result handler for getting all institute
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param institutes The InstituteVO arraycollection
 * @return void
 *
 */
public function getAllInstitutesResultHandler(institutes:ArrayCollection):void
{
	if (institutes != null)
	{
		GCLMContext.sortSmartComboDataProvider(institutes, "instituteName");
		GCLMContext.allInstitutesAC=institutes;
		if(Log.isInfo()) log.info("getAllInstitutesResultHandler After array collection:" + new Date());
	}
	else
	{
		CustomAlert.error("Error occured while getting the institutes");
	}
}

/**
 *
 * @public
 * This function is the result handler for getting the class registration count for the selected course
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param classCount type of Number
 * @return void
 *
 */
public function getClassCountResultHandler(classCount:Number):void
{
	var confirmMessage:String="";
	if (classCount > 0)
	{
		confirmMessage="Deleting the course will delete the classes under this Course.Are you sure you want to delete the selected course?";
	}
	else
	{
		confirmMessage="Are you sure you want to delete the selected course?";
	}
	CustomAlert.confirm(confirmMessage, "Confirmation", confirmDeleteCourse)
}

/**
 *
 * @public
 * This function is the result handler for deleting the course
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param event The Result Event
 * @return void
 *
 */
public function deleteCourseResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Course deleted successfully");
	//Check if the result has some valid info
	if (activeCourses.length > 1)
	{
		getAllCourses();
	}
	else
	{
		clearCourses();
	}
}

/**
 *
 * @public
 * This function is the result handler for searching the course
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param courses the CourseVO arraycollection
 * @return void
 *
 */
public function searchCourseResultHandler(courses:ArrayCollection):void
{
	clearCourses();
	//Check if the search has some valid results 
	if (courses != null)
	{
		if (courses.length > 0)
		{
			activeCourses=courses;
			activeCourses.refresh();
		}
		else
		{
			CustomAlert.info("No course(s) found for the given search criteria");
		}
	}
}

/**
 *
 * @private
 * This function is used to set icons for the control buttons
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
 * This function is to reset the search button flag
 *
 * @return void
 *
 */
private function resetSearchFlag():void
{
	hasClickedSearchButton=false;
}

/**
 *
 * @private
 * This function is to reset all the data providers
 *
 * @return void
 *
 */
private function reset():void
{
	clearDataProviders();
}

/**
 *
 * @private
 * This function is to reset the search items
 *
 * @return void
 *
 */
private function resetSearchItems():void
{
	resetInstituteFilterBox();
	courseNameText.text="";
	courseCodeText.text="";
}

/**
 *
 * @private
 * This function is to reset institute filter box
 *
 * @return void
 *
 */
private function resetInstituteFilterBox():void
{
	cmbInstitute.selectedItem=null;
	cmbInstitute.text="";
	cmbInstitute.filterString="";
}

/**
 *
 * @private
 * This function is to clear courses data provider
 *
 * @return void
 *
 */
private function clearDataProviders():void
{
	clearCourses();
	GCLMContext.allCourseOfferingInstitutesAC.removeAll();
	GCLMContext.allCourseOfferingInstitutesAC=new ArrayCollection();
}

/**
 *
 * @private
 * This function is to disable all action buttons
 *
 * @return void
 *
 */
private function disableAllActionButtions():void
{
	createCourseButton.visible=false;
	editCourseButton.visible=false;
	deleteCourseButton.visible=false;
	courseCodeLabel.visible=false;
	courseNameLabel.visible=false;
	courseCodeText.visible=false;
	courseNameText.visible=false;
}

/**
 *
 * @private
 * This function is to get all institutes based on the user role
 *
 * @return void
 *
 */
private function getInstitutes():void
{
	//Get the institute details based on the user role
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		instituteHelper.getAllInstitutesForAdmin(ClassroomContext.userVO.userId,getAllInstitutesResultHandler);
	}
	else
	{
		instituteHelper.getAllInstitutes(getAllInstitutesResultHandler);
	}
}

/**
 *
 * @private
 * This function is to get Institutes that offers atleast one institute
 *
 * @return void
 *
 */
private function getCourseOfferingInstitutes():void
{
	//Get the courses offered based on admin/master admin role
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
 * This function is to get all courses based on the user credentials
 *
 * @return void
 *
 */
private function getAllCourses():void
{
	// Fix for Bug #3117 start
	//API calling with different parameters based on the user type
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		courseHelper.searchCourse(courseNameText.text, courseCodeText.text, instituteId, searchCourseResultHandler ,ClassroomContext.userVO.userId);
	}
	else
	{
		courseHelper.searchCourse(courseNameText.text, courseCodeText.text, instituteId,searchCourseResultHandler);
	}
	// Fix for Bug #3117 end
}

/**
 *
 * @private
 * This function is to get active courses for this user
 *
 * @return void
 *
 */
private function getActiveCoursesForCurrentUser():void
{
	courseHelper.getActiveCoursesForUser(ClassroomContext.userVO.userId,getActiveCoursesResultHandler);
}

/**
 *
 * @private
 * This function is to set the institute info while populating the data
 *
 * @return void
 *
 */
private function setInstitute():void
{
	if (instituteId != 0)
	{
		for (var i:int=0; i < GCLMContext.allCourseOfferingInstitutesAC.length; i++)
		{
			if (GCLMContext.allCourseOfferingInstitutesAC[i].instituteId == instituteId)
			{
				break;
			}
		}
		cmbInstitute.selectedItem=GCLMContext.allCourseOfferingInstitutesAC[i];
			//cmbInstitute.text = AdminContext.allCourseOfferingInstitutesAC[i].instituteName;
	}
	else
	{
		resetInstituteFilterBox();
	}
}

/**
 *
 * @private
 * This function is to call CreateCourseComp for creating a new course
 *
 * @return void
 *
 */
private function createCourse():void
{
	createCourseButton.enabled=false;
	var createCourse:CreateCourseComp=new CreateCourseComp();
	createCourse.title="Create Course";
	PopUpManager.addPopUp(createCourse, this, true, null);
	PopUpManager.centerPopUp(createCourse);
	createCourse.addEventListener(FlexEvent.REMOVE, getCoursesInstitutesOnUpdate);
	createCourse.init();
}

/**
 *
 * @private
 * This function is get the updated course details after performing create/update/delete of existing course
 *
 * @return void
 *
 */
private function getCoursesInstitutesOnUpdate(event:FlexEvent):void
{
	createCourseButton.enabled=true;
	editCourseButton.enabled=true;
	if (!event.target.hasClickedCancelButton)
	{
		// Fix for Bug #6224 start
		getCourseOfferingInstitutes();
		// Fix for Bug #6224 end
		if (hasClickedSearchButton)
		{
			getAllCourses();
		}
	}
}

/**
 *
 * @private
 * This function is to call CreateCourseComp for editing the selected course
 *
 * @return void
 *
 */
private function editCourse():void
{
	if (dgCourses.selectedItem != null)
	{
		editCourseButton.enabled=false;
		getCourseByIdAndLaunchUpdateCourse(dgCourses.selectedItem.courseId)
		
	}
	else
	{
		CustomAlert.info("Please select a course from the list to edit");
	}

}

/**
 *
 * @private
 * This function is to get the course by id for updating
 *
 * @return void
 *
 */
private function getCourseByIdAndLaunchUpdateCourse(courseId:Number):void
{
	courseHelper.courseById(courseId,getCourseByIdResultHandler);
}

/**
 *
 * @private
 * This function is to get confirmation from user for deleting the course
 *
 * @return void
 *
 */
private function prepareForDeleteCourse():void
{
	//Select atleast one couse from the list
	if (dgCourses.selectedItem == null)
	{
		CustomAlert.info("Please select a course from the list");
	}
	else
	{
		//check if the course has classes and registered users before deleting
		classHelper.getClassCount(dgCourses.selectedItem.courseId,getClassCountResultHandler);
	}
}

/**
 *
 * @private
 * This function is to get delete the course if the user confirms the deletion
 *
 * @return void
 *
 */
private function confirmDeleteCourse(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		var courseId:int=dgCourses.selectedItem.courseId;
		courseHelper.deleteCourse(courseId, ClassroomContext.userVO.userId,deleteCourseResultHandler);
	}
}

/**
 *
 * @private
 * This function is to search for courses based on the given search criteria
 *
 * @return void
 *
 */
private function searchCourses():void
{
	hasClickedSearchButton=true;
	instituteId=0;
	
	if ((cmbInstitute.text != "") && (cmbInstitute.selectedItem != null) && (cmbInstitute.selectedItem.instituteId != 0))
	{
		instituteId=cmbInstitute.selectedItem.instituteId;
	}
	else if (cmbInstitute.text != "")
	{
		CustomAlert.info("Please search with a valid Institute");
		return;
	}
	getAllCourses();
}

/**
 *
 * @private
 * This function is to clear the search results
 *
 * @return void
 *
 */
private function clearSearch():void
{
	resetSearchItems();
	resetSearchFlag();
	clearCourses();
}

/**
 *
 * @private
 * This function is to clear the courses data provider
 *
 * @return void
 *
 */
private function clearCourses():void
{	
	// Fix for Bug #14851,#14830
	activeCourses.source = [] ;	
}
