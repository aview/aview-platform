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
 * File			: CreateCourseCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This Action Script handler for CreateCourseCompUIHandler.mxml
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.CourseHelper;
import edu.amrita.aview.core.gclm.vo.CourseVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

/**
 * To keep track if the cancel button has been clicked 
 */
public var hasClickedCancelButton:Boolean;
/**
 * To store the course vo for add/update 
 */
private var course:CourseVO;
/**
 * To store the error message that occurs during validation 
 */
private var errorMessage:String="";
/**
 * The helper class to communicate with the server 
 */
private var courseHelper:CourseHelper=null;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.course.CreateCourseCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the CreateCourseComp
 * This function is called from CourseCompUIHandler.as
 * @param course the courseVO
 * @return void
 *
 */
public function init(course:CourseVO=null):void
{
	courseHelper=new CourseHelper();
	hasClickedCancelButton=true;
	this.course=new CourseVO();
	//Check if the course is null. If null it is a create action else update
	if (course != null)
	{
		this.course=ObjectUtil.copy(course) as CourseVO;
		populateData();
	}
	else
	{
		resetSmartCombos();
	}
}

/**
 *
 * @public
 * This function is the result handler for adding a new course
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param event The Result event
 * @return void
 *
 */
public function createCourseResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Course created successfully");
	closeCreateCourseComp();
}

/**
 *
 * @public
 * This function is the fault handler for adding a new course
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param event The Fault event
 * @return void
 *
 */
public function createCourseFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::course::CreateCourseCompUIHandler::createCourseFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	//Checking the fault message to see if the fauly is due to duplicate entry
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given course name or course code already exists. Please try again.");
		//Fix for Bug # 1852 start
		saveCourseButton.enabled=true;
			//Fix for Bug # 1852 end
	} // General bug report if it is not duplicate constraint violation	
	else
	{
		courseHelper.genericFaultHandler(event);
		closeCreateCourseComp();
	}
}

/**
 *
 * @public
 * This function is the result handler for updating an existing course
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param event The Result event
 * @return void
 *
 */
public function updateCourseResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Course updated successfully");
	closeCreateCourseComp();
}

/**
 *
 * @public
 * This function is the fault handler for adding a new course
 * This function is made public because the CourseHelper.as will call this once it
 * gets the result from the server
 * @param event The Fault event
 * @return void
 *
 */
public function updateCourseFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::course::CreateCourseCompUIHandler::updateCourseFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	//Check the error is due to duplication in the course name
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given course name or course code already exists. Please try again.");
		//Fix for Bug # 1852 start
		saveCourseButton.enabled=true;
			//Fix for Bug # 1852 end
	} // General bug report if it is not duplicate constraint violation
	else
	{
		courseHelper.genericFaultHandler(event);
		closeCreateCourseComp();
	}
}

/**
 *
 * @private
 * This function is to reset the search criteria for institutes
 *
 * @return void
 *
 */
private function resetSmartCombos():void
{
	cmbInstitute.filterString="";
	cmbInstitute.selectedItem=null;
}

/**
 *
 * @private
 * This function is to populate course data for update
 *
 * @return void
 *
 */
private function populateData():void
{
	//Check for null value
	if (course.courseName != null)
	{
		courseNameText.text=course.courseName;
	}
	//Check for null value
	if (course.courseCode != null)
	{
		courseCodeText.text=course.courseCode;
	}
	
	if (course.instituteId != 0)
	{
		//Iterating through the institute array collection to set the appropriate institute
		//as the selected 
		for (var i:int=0; i < GCLMContext.allInstitutesAC.length; i++)
		{
			if (course.instituteId == GCLMContext.allInstitutesAC[i].instituteId)
			{
				cmbInstitute.selectedIndex=i;
				cmbInstitute.selectedItem=GCLMContext.allInstitutesAC[i];
				break;
			}
		}
	}
}

/**
 *
 * @private
 * This function is to create a new course.
 *
 * @return void
 *
 */
private function createCourse():void
{
	hasClickedCancelButton=false;
	//Check for validation of input data before saving
	if (validateSaveCourseDetails())
	{
		//Fix for Bug # 1852 start
		saveCourseButton.enabled=false;
		//Fix for Bug # 1852 end
		//Fix for Bug # 10963
		course.courseName=StringUtil.trim(courseNameText.text);
		course.courseCode=StringUtil.trim(courseCodeText.text);
		course.instituteId=cmbInstitute.selectedItem.instituteId;
		//If course id is 0, its a create action else update
		if (course.courseId == 0)
		{
			courseHelper.createCourse(course, ClassroomContext.userVO.userId,createCourseResultHandler , createCourseFaultHandler);
		}
		else
		{
			courseHelper.updateCourse(course, ClassroomContext.userVO.userId,updateCourseResultHandler , updateCourseFaultHandler);
		}
	}
	else
	{
		CustomAlert.error(errorMessage);
	}
}

/**
 *
 * @private
 * This function is to validate the course details before create/update
 *
 * @return boolean
 *
 */
private function validateSaveCourseDetails():Boolean
{
	var result:Boolean=true;
	errorMessage="Please fill the following mandatory fields ";
	//Check for blank value
	//Fix for Bug # 10963
	if (StringUtil.trim(courseNameText.text) == '')
	{
		errorMessage+="Course Name, ";
		result=false;
	}
	//Check for blank value
	//Fix for Bug # 10963
	if (StringUtil.trim(courseCodeText.text) == '')
	{
		errorMessage+="Course Code, ";
		result=false;
	}
	//Check for null value
	if ((cmbInstitute.selectedItem == null) || (cmbInstitute.selectedItem.instituteId == 0))
	{
		errorMessage+="Institute Name, ";
		result=false;
	}	
	errorMessage=errorMessage.substring(0, errorMessage.lastIndexOf(","));
	return result;
}


/**
 *
 * @private
 * This function is to close CreateCourseComp window
 *
 * @return void
 *
 */
private function closeCreateCourseComp():void
{
//	institutesAC.removeAll();
	if(Log.isDebug()) log.debug("Closing create course comp");
	PopUpManager.removePopUp(this);
}