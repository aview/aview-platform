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
 * File			: CreateLectureCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This file is the script handler for CreateLectureComp.mxml
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.vo.LectureVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

/**
 * Used to store the aview classes 
 */
[Bindable]
public var classes:ArrayCollection=new ArrayCollection();
/**
 * To keep track if the user has clicked on cancel button 
 */
public var hasClickedCancelButton:Boolean=true;
/**
 * Used to hold the lecture vo to update 
 */
private var lecturevo:LectureVO;
/**
 * The error message to display to users if validatin fails 
 */
private var errorMsg:String="";
/**
 * The helper class to communicate to the server 
 */
private var lectureHelper:LectureHelper=null;
/**
 * The max time in 12 hour format 
 */
private const MAX_HOUR:Number=12;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.lecture.CreateLectureCompUIHandler.as");

/**
 *
 * @public
 * This function is used to set the initial data required for CreateLectureComp.
 * This function is invoked from LectureCompUIHandler.as
 * In case of create the argument has null value
 *
 * @param lecturevo : The LectureVO to edit.
 * @return void
 *
 */
public function init(lecturevo:LectureVO=null):void
{
	lectureHelper=new LectureHelper();
	hasClickedCancelButton=true;
	this.lecturevo=new LectureVO();
	if (lecturevo != null)
	{
		this.lecturevo=ObjectUtil.copy(lecturevo) as LectureVO;
		populateLectureData();
	}
	else
	{
		resetSmartCombos();
	}
}

/**
 *
 * @public
 * This function is the result handler for lecture creation
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param event : The Result Event
 * @return void
 *
 */
public function createLectureResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Lecture created successfully");
	hasClickedCancelButton=false;
	closeCreateLectureComp();
}

/**
 *
 * @public
 * This function is the fault handler for lecture creation
 * This function is made public because the LectureHelper.as will call this once it
 * gets the fault from the server
 * @param event : The Fault Event
 * @return void
 *
 */
public function createLectureFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::lecture::CreateLectureCompUIHandler::createLectureFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	//Fix for Bug#14651
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		//Fix for Bug#15045
		if(strMsg.indexOf("key 'lecture_date'",0) != -1)
		{
			CustomAlert.error("Another lecture exists for the same timings, please change the time");
		}
		else
		{
			CustomAlert.error("This lecture already exists, try another one");
		}
		//Fix for Bug # 1852 start
		btnSaveLecture.enabled=true;
			//Fix for Bug # 1852 end		
	}
	// General bug report if it is not duplicate constraint violation
	else
	{
		lectureHelper.genericFaultHandler(event);
		//Fix for Bug#15042
		closeCreateLectureComp();
	}
	hasClickedCancelButton=false;
}

/**
 *
 * @public
 * This function is the result handler for lecture update
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param event : The Result Event
 * @return void
 *
 */
public function updateLectureResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Lecture updated successfully");
	hasClickedCancelButton=false;
	closeCreateLectureComp();
}

/**
 *
 * @public
 * This function is the fault handler for lecture update
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param event : The Fault Event
 * @return void
 *
 */
public function updateLectureFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::lecture::CreateLectureCompUIHandler::updateLectureFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	//Bug fix for #5602 start
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
		//Bug fix for #5602 end
	{
		//Fix for Bug#15045
		if(strMsg.indexOf("key 'lecture_date'",0) != -1)
		{
			CustomAlert.error("Another lecture exists for the same timings, please change the time");
		}
		else
		{
			CustomAlert.error("This lecture already exists, try another one");
		}
		//Fix for Bug # 1852 start
		btnSaveLecture.enabled=true;
			//Fix for Bug # 1852 end
	}
	else
	{
		lectureHelper.genericFaultHandler(event);
		//Fix for Bug#15042
		closeCreateLectureComp();
	}
	hasClickedCancelButton=false;
}

/**
 *
 * @private
 * This function is used reset all the data that is used in this component
 *
 *
 * @return void
 *
 */
private function resetSmartCombos():void
{
	cmbClasses.filterString="";
	cmbClasses.selectedItem=null;
}

/**
 *
 * @private
 * This function is used to populate all the lecture details, for editing
 *
 *
 * @return void
 *
 */
private function populateLectureData():void
{
	setClassForLecture();
	setCourseInstitute();
	if (lecturevo.lectureName != '')
	{
		//Fix for Bug#15278
		txtInpLectureTopic.text=lecturevo.displayName;
	}
	if (lecturevo.keywords != '')
	{
		txtInpKeywordLecture.text=lecturevo.keywords;
	}
	if (lecturevo.startDate != null)
	{
		dateLecture.selectedDate=lecturevo.startDate;
	}
	setStartEndTime();
}

/**
 *
 * @private
 * This function is used to set the class for the selected lecture.
 * It iterates through the class array collection to get the class to which this lecture belongs to
 *
 *
 * @return void
 *
 */
private function setClassForLecture():void
{
	if (lecturevo.classId != 0)
	{
		for (var i:int=0; i < classes.length; i++)
		{
			if (lecturevo.classId == classes[i].classId)
			{
				cmbClasses.selectedIndex=i;
				cmbClasses.selectedItem=classes[i];
				break;
			}
		}
	}
}

/**
 *
 * @private
 * This function is used to set the start and end time for the selected lecture
 *
 *
 * @return void
 *
 */
private function setStartEndTime():void
{
	rbgStartLecture.selectedValue=getAmPmForTime(lecturevo.startTime);
	rbgEndLecture.selectedValue=getAmPmForTime(lecturevo.endTime);
	
	nsHoursStartLecture.value=getHourFromTime(lecturevo.startTime);
	nsHoursEndLecture.value=getHourFromTime(lecturevo.endTime);
	
	nsMinsStartLecture.value=lecturevo.startTime.minutes;
	nsMinsEndLecture.value=lecturevo.endTime.minutes;
}

/**
 *
 * @private
 * This function is used to get am/pm depends upon the lecture start/end time
 *
 *
 * @return result : String the value am/pm
 *
 */
private function getAmPmForTime(dateTimeOfLecture:Date):String
{
	var result:String="am";
	//If the time is greater than 12, set to pm else am 
	if (dateTimeOfLecture.hours >= MAX_HOUR)
	{
		result="pm";
	}
	return result;
}

/**
 *
 * @private
 * This function is used to get am/pm depends upon the lecture start/end time
 *
 * @param dateTimeOfLecture type of Date
 * @return result : the hour value to set
 *
 */
private function getHourFromTime(dateTimeOfLecture:Date):Number
{
	//Set the default hours
	var result:Number=dateTimeOfLecture.hours;
	//If the hour time is 0, set it to 12 as it denotes 12 midnight
	if (dateTimeOfLecture.hours == 0)
	{
		result=MAX_HOUR;
	}
	//If the value is greater than 12, get the mod value, to show the time in am/pm format
	else if (dateTimeOfLecture.hours > MAX_HOUR)
	{
		result=dateTimeOfLecture.hours % MAX_HOUR;
	}
	return result;
}

/**
 *
 * @private
 * This function is used to validate user input details before creating the lecture
 *
 *
 * @return boolean - true/false depends on the success or failure of validation
 *
 */
private function validateLectureData():Boolean
{
	var flagL:Boolean=true;
	errorMsg="Please fill the following fields: \n";
	var houStart:int;
	var houEnd:int;
	var strHrStart:String=new String;
	var strMinStart:String=new String;
	var strSecStart:String='00';
	var strMlSecStart:String='00';
	var strHrEnd:String=new String;
	var strMinEnd:String=new String;
	var strSecEnd:String='00';
	var strMlSecEnd:String='00';
	var nextDayStart:Date;
	var nextDayEnd:Date;
	
	houStart=nsHoursStartLecture.value % 12;
	houEnd=nsHoursEndLecture.value % 12;
	
	//Check if the user has selected a class for creating the lecture. Since the class drop down is a smart 
	//combo box, the validation has to make sure that the user has not given the class which does not exist
	if ((cmbClasses.text == "") || (cmbClasses.selectedItem == null) || (cmbClasses.selectedItem.classId == 0))
	{
		errorMsg+="Class Name, ";
		flagL=false;
	}
	else
	{
		lecturevo.classId=cmbClasses.selectedItem.classId;
		lecturevo.className=cmbClasses.selectedItem.className;
	}
	//Check if a name is given for the Lecture
	//Fix for Bug #10973
	if (StringUtil.trim(txtInpLectureTopic.text) == "")
	{
		errorMsg+="Lecture Name, ";
		flagL=false;
	}
	else
	{
		lecturevo.lectureName=StringUtil.trim(txtInpLectureTopic.text);
	}
	
	if (txtInpKeywordLecture.text == null)
	{
		errorMsg+="Keywords, ";
		flagL=false;
	}
	else
	{
		lecturevo.keywords=StringUtil.trim(txtInpKeywordLecture.text);
	}
	
	if (dateLecture.selectedDate == null)
	{
		errorMsg+="Start Date, ";
		flagL=false;
	}
	else
	{
		lecturevo.startDate=dateLecture.selectedDate;
	}
	//Formatting the start time
	strMinStart=nsMinsStartLecture.value.toString();
	//If the user has not chosend start time and end time, by default it takes the time for 
	//the whole day from 12:00 am till 11:59 pm
	
	//If the time is selected as pm, add 12 to the currently selected time 
	//as the time is saved in 24 hour format in the database
	if (rbgStartLecture.selectedValue == "pm")
	{
		houStart=nsHoursStartLecture.value;
		//The class start time cannot be 11:59 pm which is the end minute for any day
		if ((houStart == 11) && (strMinStart == "59"))
		{
			errorMsg+="Change class start time, ";
			flagL=false;
		}
		else if (houStart != MAX_HOUR)
		{
			houStart+=MAX_HOUR;
		}
	}
	else
	{
		// bug fix issue 677
		houStart=nsHoursStartLecture.value % MAX_HOUR;
	}
	
	houEnd=nsHoursEndLecture.value;
	strMinEnd=nsMinsEndLecture.value.toString();
	//Set the end time to 23:59 (11:59 in twelve hour format)
	if ((houEnd == 0) || ((houEnd == 12) && (strMinEnd == "0") && (rbgEndLecture.selectedValue == "pm")))
	{
		houEnd=23;
		strMinEnd="59";
	}
	//If the end time is selected as pm, add 12 to the chosen time
	else if (rbgEndLecture.selectedValue == "pm")
	{
		//Bug fix for issue #679
		if (houEnd != MAX_HOUR)
		{
			houEnd+=MAX_HOUR;
		}
	}
	//Lecture cannot end at 12 am as it denotes the start time for a given day
	else if ((houEnd == MAX_HOUR) && (rbgEndLecture.selectedValue == "am"))
	{
		errorMsg+="End time cannot be 12 am,";
		flagL=false;
	}
	
	strHrStart=houStart.toString();
	
	nextDayStart=new Date(null, null, null, strHrStart, strMinStart, strSecStart, strMlSecStart);
	
	strHrEnd=houEnd.toString();
	
	nextDayEnd=new Date(null, null, null, strHrEnd, strMinEnd, strSecEnd, strMlSecEnd);
	
	lecturevo.startTime=nextDayStart;
	if (lecturevo.startTime == null)
	{
		errorMsg+="Start Time ,"
		flagL=false;
	}
	
	lecturevo.endTime=nextDayEnd;
	
	if (lecturevo.endTime == null)
	{
		errorMsg+="End Time ,";
		flagL=false;
	}
	
	//Check if start time and end time are same
	if ((houEnd != 0) && (houStart != 0) && (houStart == houEnd) && (strMinEnd == strMinStart))
	{
		errorMsg="Start and End Time cannot be same,";
		flagL=false;
	}
	
	//Check if end time is lesser that start time. For example start time is 10 am and end time is 9 am which does not exist
	else if ((nextDayEnd.hours < nextDayStart.hours) || ((nextDayEnd.hours == nextDayStart.hours) && (nextDayEnd.minutes < nextDayStart.minutes)))
	{
		errorMsg="End time cannot be less than Start time,";
		flagL=false;
	}
	errorMsg=errorMsg.substring(0, errorMsg.lastIndexOf(","));
	return flagL;
}

/**
 *
 * @private
 * This function is used to save the lecture. Before saving the lecture the lecture details
 * are validated for proper data
 *
 *
 * @return void
 *
 */
private function saveLecture():void
{
	//Validate the data before creating the new lecture
	if (validateLectureData())
	{
		//Fix for Bug # 1852 start
		btnSaveLecture.enabled=false;
		//Fix for Bug # 1852 end
		//If the lecture id is 0, then it has to create a new lecture
		if (lecturevo.lectureId == 0)
		{
			lectureHelper.createLecture(lecturevo, ClassroomContext.userVO.userId,createLectureResultHandler ,createLectureFaultHandler);
		}
		//If the lecture id has a valid value other than 0, then its an update call
		else
		{
			lectureHelper.updateLecture(lecturevo, ClassroomContext.userVO.userId,updateLectureResultHandler,updateLectureFaultHandler);
		}
	}
	else
	{
		//Intimate the error message to the user in case of validation failure
		CustomAlert.error(errorMsg);
	}
}

// Fix for Bug # 3085 start
/**
 *
 * @private
 * This function is used to set the course and institute of a Lecture, when it is selected for edit
 *
 *
 * @return void
 *
 */
private function setCourseInstitute():void
{
	if ((cmbClasses.text != "") && (cmbClasses.selectedItem != null) && (cmbClasses.selectedItem.classId != 0))
	{
		if (cmbClasses.selectedItem.courseName != null)
		{
			txtInpCourseName.text=cmbClasses.selectedItem.courseName;
		}
		if (cmbClasses.selectedItem.instituteName != null)
		{
			txtInpInstituteName.text=cmbClasses.selectedItem.instituteName;
		}
		
	}
}

// Fix for Bug # 3085 end
/**
 *
 * @private
 * This function is called when user closes this window
 *
 *
 * @return void
 *
 */
private function closeCreateLectureComp():void
{
//	classesAC.removeAll();
	if(Log.isDebug()) log.debug("Coming inside close create lecture comp");
	PopUpManager.removePopUp(this);
}