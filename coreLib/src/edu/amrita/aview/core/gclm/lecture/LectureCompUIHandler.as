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
 * File			: LectureCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This file is the script handler for LectureComp.mxml
 *
 */

import edu.amrita.aview.core.common.util.PDFUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.AnalyticsHelper;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.lecture.CreateLectureComp;
import edu.amrita.aview.core.gclm.lecture.LectureComp;
import edu.amrita.aview.core.gclm.vo.LectureVO;
import edu.amrita.aview.core.shared.audit.helper.AuditLectureHelper;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.AViewDateUtil;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.vo.AViewResponseVO;
import edu.amrita.aview.core.whiteboard._textArea;
import edu.amrita.aview.core.whiteboard.saveconfirm_wb;

import flash.display.Loader;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.text.ReturnKeyLabel;
import flash.utils.Timer;

import flashx.textLayout.elements.TabElement;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.controls.List;
import mx.core.FlexLoader;
import mx.core.UITextField;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.formatters.DateFormatter;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.purepdf.elements.IElement;
import org.purepdf.elements.Paragraph;
import org.purepdf.pdf.PdfDocument;
import org.purepdf.pdf.PdfPCell;
import org.purepdf.pdf.PdfPTable;

/**
 * All icons classes
 */
[Bindable]
public var createIcon:Class;

[Bindable]
[Embed(source="../assets/images/delete.png")]
public var deleteIconEnabled:Class;
[Bindable]
public var deleteIcon:Class;

[Bindable]
[Embed(source="../assets/images/edit.png")]
public var updateIconEnabled:Class;
[Bindable]
public var updateIcon:Class;

[Bindable]
[Embed(source="../assets/images/create.png")]
private var createIconEnabled:Class;
/**
 * The array collection to hold the lecture details that is fetched from the server 
 */
[Bindable]
private var lectures:ArrayCollection=new ArrayCollection();
/**
 * The array collection to hold the class details that is fetched from the server 
 */
[Bindable]
private var aviewClasses:ArrayCollection=new ArrayCollection();
/**
 * To track if the search button is clicked by the user 
 */
private var hasClickedSearchButton:Boolean=false;
/**
 * The helper class objects to communicate with the server 
 */
private var classHelper:ClassHelper=null;
private var lectureHelper:LectureHelper=null;
private var instituteHelper:InstituteHelper=null;
private var analyticsHelper:AnalyticsHelper=new AnalyticsHelper;
/**
 * Code change for NIC start
 * The helper class objects to communicate with the server
 */
private var classRegisterHelper:ClassRegistrationHelper=null;
private var isModerator:String="Y";
/**
 * To track if a different class is chosen from the class drop down 
 */
private var hasClassSelectionChanged:Boolean=true;
/**
 * Code change for NIC end
 * The lecture vo object
 */
private var lectureVO:LectureVO;
/**
 * The error message to display, while creating/editing lecture details 
 */
private var errorMsg:String="";
/**
 * To keep track of the selected class id from the class drop down 
 */
private var classId:Number=0;

private var lectureId:Number=0;

private var adminId:Number=0;
/**
 * Maximum hour in case of 12 hour format 
 */
private const MAX_HOUR:int=12;
/**
 * Maximum value for a minute 
 */
private const MAX_MIN:int=59;

private var pdfUtil : PDFUtil;

/**
 *
 * @public
 * This function sets all the initial info required for the Lecture Comp
 * This function is called from Administration.mxml
 *
 * @return void
 *
 */
public function initApp():void
{
	classHelper=new ClassHelper();
	lectureHelper=new LectureHelper();
	classRegisterHelper=new ClassRegistrationHelper();
	
	reset();
	setIcons();
	//Code change for NIC start
	//The Moderator can edit the lecture details
	//Based on the logged in user role, give the necessary privileges
	//Fix for bug # 19529 start
	if ( (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) ||
		(ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
	{
		disableAllActionButtions();
		setUpdateLectureButtonVisible(false);
	}
	//Fix for bug # 19529 end
	else if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		disableAllActionButtions();
		setUpdateLectureButtonVisible(true);
		setUpdateLectureButtonEnabled(false);
		dgLectures.addEventListener(MouseEvent.CLICK, setLectureEditPermissionForModerator);
	}
	//Code change for NIC end
	getAllClasses();
}

/**
 *
 * @public
 * This function is the result handler for getting the lecture details based on the selected class
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param tmpLectures type of arraycollection
 * @return void
 *
 */
public function getLecturesForClassResultHandler(tmpLectures:ArrayCollection):void
{
	//Before updating the screen, first clear off the existing info
	clearLectures();
	if (tmpLectures != null)
	{
		//Check if the result is not empty
		if (tmpLectures.length > 0)
		{
			lectures=tmpLectures;
		}
		// If no lecture detail is found, alert the user
		else
		{
			CustomAlert.info("No lectures found for the given criteria");
		}
	}
}

/**
 *
 * @public
 * This function is the result handler for deleting the selected Lecture
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param event the result event
 * @return void
 *
 */
public function deleteLectureResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Lecture deleted successfully");
	//Once the lecture is deleted, if any previous search has been performed, once again
	//perform the search to get the latest details
	if (lectures.length > 1)
	{
		searchLectures();
	}
	//If the previous result has only one lecture entry which the user has deleted. Now the 
	//screen has to show nothing
	else
	{
		clearLectures();
	}
}
/**
 *
 * @public
 * This function is the fault handler for deleting the selected Lecture
 * This function is made public because the LectureHelper.as will call this once it
 * gets the error from the server
 * @param event the fault event
 * @return void
 *
 */
/*Fix for Bug#9076,Bug#10986*/
public function deleteLectureFaultHandler(event:FaultEvent):void
{
	if(event.fault.faultString.indexOf("foreign key constraint fails") != 0)
	{
		CustomAlert.error("Cannot delete a lecture which has been already used");
	}
	else
	{
		CustomAlert.error(event.fault.faultString);
	}
}

/**
 *
 * @public
 * This function is the result handler for deleting the recording for a lecture
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param event the result event
 * @return void
 *
 */
public function deleteLectureRecordingResultHandler(event:ResultEvent):void
{
	var response:AViewResponseVO=event.result as AViewResponseVO;
	//Check for response value to display it accordingly
	if (response.responseId == AViewResponseVO.REQUEST_SUCCESS)
	{
		CustomAlert.info(response.responseMessage);
	}
	else
	{
		CustomAlert.error(response.responseMessage);
	}
}

/**
 *
 * @public
 * This function is the result handler for getting the class details
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param classes type of ArrayCollection
 * @return void
 *
 */
public function getActiveClassesResultHandler(classes:ArrayCollection):void
{
	//Check if the result is not null
	if (classes != null)
	{
		GCLMContext.sortSmartComboDataProvider(classes, "className");
		aviewClasses=classes;
	}
	resetSearchItems();
}

//Code change for NIC start
/**
 *
 * @public
 * This function is the result handler for checking if the user is the moderator for the given lecture
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param classRegVO type of ArrayCollection
 * @return void
 *
 */
public function searchForClassRegisterResultHandler(classRegVO:ArrayCollection):void
{
	//Check if the result is not null
	if ((classRegVO != null) && (classRegVO.length > 0))
	{
		setUpdateLectureButtonEnabled(true);
	}
	else
	{
		setUpdateLectureButtonEnabled(false);
	}
}

/**
 *
 * @public
 * This function is the result handler for getting a lecture details for editing
 * This function is made public because the LectureHelper.as will call this once it
 * gets the result from the server
 * @param lectureVO type of LectureVO
 * @return void
 *
 */
public function getLecturebyIdResultHandler(lectureVO:LectureVO):void
{
	var editLectureComp:CreateLectureComp=new CreateLectureComp();
	PopUpManager.addPopUp(editLectureComp, this, true, null);
	PopUpManager.centerPopUp(editLectureComp);
	editLectureComp.addEventListener(FlexEvent.REMOVE, getLecturesOnUpdate);
	editLectureComp.title="Edit Lecture";
	editLectureComp.classes=aviewClasses;
	editLectureComp.init(lectureVO);
}
//Code change for NIC end

/**
 *
 * @private
 * This  function set the required icons for the control buttons
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
 * This function resets all the data that was initialized in the previous calls
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
 * This function resets the search item information
 *
 * @return void
 *
 */
private function resetSearchItems():void
{
	//Code change for NIC start
	hasClassSelectionChanged=true;
	//Enable update lecture button in case if the logged in uesr is a teacher
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		setUpdateLectureButtonEnabled(false);
	}
	//Code change for NIC end
	hasClickedSearchButton=false;
	cmbClasses.selectedItem=null;
	cmbClasses.filterString="";
}

/**
 *
 * @private
 * This function clears all the data provoiders which has lecture and class details
 *
 * @return void
 *
 */
private function clearDataProviders():void
{
	clearLectures();
	aviewClasses.removeAll();
	aviewClasses=new ArrayCollection();
}

/**
 *
 * @private
 * This function clears the lecture information that is acquired by the previous search
 *
 * @return void
 *
 */
private function clearLectures():void
{
	// Fix for Bug #14853,#14832
	lectures.source = [] ;
}

/**
 *
 * @private
 * This function disables all the action buttons based on the logged in user credentials
 *
 * @return void
 *
 */
private function disableAllActionButtions():void
{
	btnCreate.visible=false;
	btnDelete.visible=false;
	btnDeleteRecording.visible=false;
}

/**
 *
 * @private
 * This function makes call to server to get all the class information
 *
 * @return void
 *
 */
private function getAllClasses():void
{
	// Teachers/Students can see only those classes for which they have registered 
	if ((ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.TEACHER_TYPE))
	{
		classHelper.getClassByUserId(ClassroomContext.userVO.userId,getActiveClassesResultHandler);
	}
	// Administrators can see all the classes that are limited to their institutes/child institutes
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE)
	{
		classHelper.getActiveClassesByAdmin(ClassroomContext.userVO.userId,getActiveClassesResultHandler);
	}
	//Master admin can see all the class details
	if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
	{
		classHelper.getActiveClasses(getActiveClassesResultHandler);
	}
}

/**
 *
 * @private
 * This function is to validate if the user has entered correct value for hours field which is a numeric stepper
 * @param event of Focus event
 * @return void
 *
 */
private function validateStepperHours(event:FocusEvent):void
{
	if (event.target is UITextField)
	{
		var valueToCheckStr:String=UITextField(event.target).text;
		var valueToCheck:Number=Number(valueToCheckStr);
		// Check if the value is greated than 12, as hour is limited to 12 (in 12 hour format)
		if (valueToCheck > MAX_HOUR)
		{
			CustomAlert.error("Hour value is more than " + MAX_HOUR);
		}
	}
	else
	{
		// catches NumericStepper change-event, do nothing, because value is set to 10 already
	}
}

/**
 *
 * @private
 * This function is to validate if the user has entered correct value for minute field which is a numeric stepper
 * @param event of Focus event
 * @return void
 *
 */
private function validateStepperMins(event:FocusEvent):void
{
	if (event.target is UITextField)
	{
		var valueToCheckStr:String=UITextField(event.target).text;
		var valueToCheck:Number=Number(valueToCheckStr);
		// Check if the value is greated than 59
		if (valueToCheck > MAX_MIN)
		{
			CustomAlert.error("Minute value is more than " + MAX_MIN);
		}
	}
	else
	{
		// catches NumericStepper change-event, do nothing, because value is set to 10 already
	}
}

/**
 *
 * @private
 * This function is to invoke CreateLectureComp. The component to create new lecture
 *
 * @return void
 *
 */
private function createLecture():void
{
	btnCreate.enabled=false;
	var createLectureComp:CreateLectureComp=new CreateLectureComp();
	PopUpManager.addPopUp(createLectureComp, this, true, null);
	PopUpManager.centerPopUp(createLectureComp);
	createLectureComp.addEventListener(FlexEvent.REMOVE, getLecturesOnUpdate);
	createLectureComp.title="Create Lecture";
	createLectureComp.classes=aviewClasses;
	createLectureComp.init();
}

/**
 *
 * @private
 * This function is to refresh the lecture details that is being shown in the LectureComp.
 * This function is called when ever create/edit/delete action is performed
 * @param event of Flexevent
 * @return void
 *
 */
private function getLecturesOnUpdate(event:FlexEvent):void
{
	btnCreate.enabled=true;
	setUpdateLectureButtonEnabled(true);
	//Check if the cancel button is not clicked and the user has already performed
	//a search action. In that case, do a search again to get the latest data
	if ((!event.target.hasClickedCancelButton) && (hasClickedSearchButton))
	{
		searchLectures();
	}
}

/**
 *
 * @private
 * This function is to invoke CreateLectureComp. The component to create edit existing lecture
 *
 * @return void
 *
 */
private function editLecture():void
{
	// Check if the user has selected a lecture to edit
	if (dgLectures.selectedItem == null)
	{
		CustomAlert.info("Please select a lecture from the list");
	}
	else
	{
		// disable the update button, to prevent double clicking
		setUpdateLectureButtonEnabled(false);
		//Before updating the lecture, get the latest info from the server
		getLectureByIdAndUpdate(dgLectures.selectedItem.lectureId);
	}
}

/**
 *
 * @private
 * This function gets the lecture details for a given lecture id, which the user wishes to edit
 * @param lectureId - the lecture id of the lecture which the user has selected to edit
 * @return void
 *
 */
private function getLectureByIdAndUpdate(lectureId:Number):void
{
	lectureHelper.getLecturebyId(lectureId,getLecturebyIdResultHandler);
}


/**
 *
 * @private
 * This function is called when the user has selected a lecture for deletion
 * Before deleting the lecture entry, checking is done, if that lecture is an ongoing one
 *
 * @return void
 *
 */
private function deleteLecture():void
{
	// Check if the user has selected a Lecture to delete
	if (dgLectures.selectedItem == null)
	{
		CustomAlert.info("Please select a lecture from the list");
	}
	else
	{
		var lecture:LectureVO=dgLectures.selectedItem as LectureVO;
		if (lecture != null)
		{
			//Check if its an ongoing lecture. If so, alert the user that the Lecture cannot be deleted
			if (onGoingLecture(lecture))
			{
				CustomAlert.error("Cannot delete a class which has been scheduled for now");
			}
			//Confirmation from the user before proceeding to delete
			else
			{
				CustomAlert.confirm("Are you sure you want to delete the selected lecture?", "Confirmation", confirmDeleteLecture);
			}
		}
	}
}

/**
 *
 * @private
 * This function is to delete the recording for the selected lecture
 *
 * @return void
 *
 */
private function deleteRecording():void
{
	//Check if the user has selected a Lecture for which the recording has to be deleted
	if (dgLectures.selectedItem == null)
	{
		CustomAlert.info("Please select a lecture from the list");
	}
	else
	{
		var lecture:LectureVO=dgLectures.selectedItem as LectureVO;
		if (lecture != null)
		{
			//Before deleting the recording, check if it has been recorded (or) the recording is deleted already
			if (!isRecorded(lecture))
			{
				CustomAlert.error("Lecture is not recorded or Recording is already deleted.");
			}
			//If the recording is still available, get confirmation from the user before doing the actual delete
			else
			{
				CustomAlert.confirm("Are you sure you want to delete the selected lecture's recording?", "Confirmation", confirmDeleteRecording);
			}
		}
	}
}

/**
 *
 * @private
 * This function is to check if the selected lecture has been recorded
 * @param lecture of LectureVO
 * @return void
 *
 */
private function isRecorded(lecture:LectureVO):Boolean
{
	if (lecture.recordedContentFilePath != null || lecture.recordedContentUrl != null || lecture.recordedPresenterVideoUrl != null || lecture.recordedVideoFilePath != null || lecture.recordedViewerVideoUrl != null)
	{
		return true;
	}
	return false;
}

/**
 *
 * @private
 * This function is to check if the selected lecture to delete is an ongoing lecture
 * @param lecture - the lecture object
 * @return void
 *
 */
private function onGoingLecture(lecture:LectureVO):Boolean
{
	var result:Boolean=false;
	//Check if the value is not null
	if (lecture != null)
	{
		var today:Date=new Date();
		//set the return value to true, if the lecture date is the current date
		if ((today.date == lecture.startDate.date) && (today.month == lecture.startDate.month) && (today.fullYear == lecture.startDate.fullYear) && ((today.hours >= lecture.startTime.hours) || (today.minutes >= lecture.startTime.minutes)) && ((today.hours <= lecture.endTime.hours) || (today.minutes <= lecture.endTime.minutes)))
		{
			result=true;
		}
	}
	return result;
}

/**
 *
 * @private
 * This function is to actually delete the lecture based on the user confirmation
 * @param event of Close event which has the confirmation details
 * @return void
 *
 */
private function confirmDeleteLecture(event:CloseEvent):void
{
	// If the user has confirmed for deletion, call the deleteLecture
	if (event.detail == Alert.YES)
	{
		/*Fix for Bug#9076,Bug#10986 : Fault handler added*/
		lectureHelper.deleteLecture(dgLectures.selectedItem.lectureId,deleteLectureResultHandler,deleteLectureFaultHandler);
	}
}

/**
 *
 * @private
 * This function is to actually delete the recording of the lecture based on the user confirmation
 * @param event of Close event which has the confirmation details
 * @return void
 *
 */
private function confirmDeleteRecording(event:CloseEvent):void
{
	// If the user has confirmed for deletion, delete the recording details of the lecture
	if (event.detail == Alert.YES)
	{
		lectureHelper.deleteLectureRecording(dgLectures.selectedItem.lectureId,deleteLectureRecordingResultHandler);
	}
}

/**
 *
 * @private
 * This function is to search for Lecture by the given criteria
 * The scope of the search depends upon the user credentials
 *
 * @return void
 *
 */
private function searchLectures():void
{
	//Bug #1344 : Issue with Reset button under Setup -> Lecture
	//resetLecture.enabled = false;
	hasClickedSearchButton=true;
	classId=0;
	
	//Code change for NIC start
	hasClassSelectionChanged=true;
	//Check for user role, and do the action accordingly
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		setUpdateLectureButtonEnabled(false);
	}
	//Code change for NIC end
	//Check for not null and blank value
	if ((cmbClasses.text != "") && (cmbClasses.selectedItem != null) && (cmbClasses.selectedItem.classId != 0))
	{
		classId=cmbClasses.selectedItem.classId;
		getAllLectures();
	}
	else if (cmbClasses.text != "")
	{
		CustomAlert.info("Please search with a valid Class");
		return;
	}
	//Unlike other screens, we should not allow user to search lectures for all classes. User must select a class.
	//This is done for better performance
	else
	{
		CustomAlert.info("A Class must be selected to see the Lectures");
		return;
	}
}

/**
 *
 * @private
 * This function performs the actual call to the server for getting the lecture details for the selected class
 *
 * @return void
 *
 */
private function getAllLectures():void
{
	lectureHelper.getLecturesForClass(classId,getLecturesForClassResultHandler);
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
	clearLectures();
}

/**
 *
 * @private
 * This function is to sort the lecture details displayed based on the start date
 * @param itemA type of Object
 * @param itemB type of Object
 * @return int
 *
 */
//Fix for Bug#14832
private function sortStartDate(itemA:Object, itemB:Object, itemC:Object = null):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.startDate, itemB.startDate);
}

/**
 *
 * @private
 * This function is to sort the lecture details displayed based on the start time
 * @param itemA type of Object
 * @param itemB type of Object
 * @return int
 *
 */
//Fix for Bug#14832
private function sortStartTime(itemA:Object, itemB:Object, itemC:Object = null):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.startTime, itemB.startTime);
}

/**
 *
 * @private
 * This function is to sort the lecture details displayed based on the end time
 * @param itemA type of Object
 * @param itemB type of Object
 * @return int
 *
 */
//Fix for Bug#14832
private function sortEndTime(itemA:Object, itemB:Object, itemC:Object = null):int
{
	return AViewDateUtil.date_sortCompareFunc(itemA.endTime, itemB.endTime);
}

//Code change for NIC start
/**
 *
 * @private
 * This function is to make visible/invisible the update lecture button in case if the
 * user is Moderator. For students this button is always disabled. For administrators this
 * button is alway enabled
 * @param flag type of Boolean
 * @return void
 *
 */
//Hide the edit button if the user is a student. else un hide.
private function setUpdateLectureButtonVisible(flag:Boolean):void
{
	btnUpdate.visible=flag;
	//Set the position of the update button, if the create button is not visible to the user
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		btnUpdate.left=btnCreate.left;
		btnUpdate.bottom=btnCreate.bottom;
	}
}

/**
 *
 * @private
 * This function is to make enable/disable the update lecture button in case if the
 * user is Teacher. For students this button is always disabled. For administrators this
 * button is alway enabled
 * @param flag type of Boolean
 * @return void
 *
 */
private function setUpdateLectureButtonEnabled(flag:Boolean):void
{
	btnUpdate.enabled=flag;
}

/**
 *
 * @private
 * This function is to set the edit lecture permission if the user is the Moderator for that lecture
 * This function is not applicable for Master admin/Institute admins
 * @param event type of MouseEvent
 * @return void
 *
 */
private function setLectureEditPermissionForModerator(event:MouseEvent):void
{
	//We need to check if the user is moderator for a class only once.
	//Check if the user is the moderator only when the user has changed the class name.
	if ((hasClassSelectionChanged) && (dgLectures.selectedItem != null))
	{
		hasClassSelectionChanged=false;
		var lecturevo:LectureVO=dgLectures.selectedItem as LectureVO;
		classRegisterHelper.searchForClassRegisterForUser(ClassroomContext.userVO.userId, lecturevo.classId, isModerator, 0, 0,searchForClassRegisterResultHandler);
	}
}
//Fix for Bug#20297,20288:Start
public function checkIfClassIsConducted():void
{
	lectureId = dgLectures.selectedItem.lectureId;
	var auditLectureHelper:AuditLectureHelper = new AuditLectureHelper;
	auditLectureHelper.getAuditLectureByLectureId(lectureId,getAuditLectureByLectureIdResultHandler);
}

//Function to generate report
private function getAuditLectureByLectureIdResultHandler(result:Boolean):void
{
	if(result)
	{
		generateReport()
	}
	else
	{
		CustomAlert.info("Lecture not conducted");
	}
}
public function generateReport():void
{
	// Check if the user has selected a lecture to edit
	/*if (dgLectures.selectedItem == null)
	{
		CustomAlert.info("Please select a lecture from the list");
	}
	else
	{*/
		adminId = ClassroomContext.userVO.userId;
		analyticsHelper.getUserAndLectureDetailsForLecture(lectureId,getUserAndLectureDetailsForLectureResultHandler);
	/*}*/
}
//Fix for Bug#20297,20288:End
public function getUserAndLectureDetailsForLectureResultHandler(tmpLectures:ArrayCollection):void
{
//	var attendedUserArray:ArrayList = new ArrayList();
//	var registeredUserArray:ArrayList=new ArrayList();
	var registeredUserObject:Object = new Object();
	var attendeduserObject:Object = new Object();
	var lectureContentArray:Array = new Array();
	var userContenetArray:Array = new Array();
	var peopleCountContentArray:Array = new Array();
//	var unAttendedUserCount:Object = null;
	var attendedUserList:Object = null;
	var registeredUserList:Object = null;
	var regUserCount:Object = null;
	var lectureValues:Array = null;
	var userValues:Array = null;
	var peopleCountValues:Array = null;
	var lectureColumnCount:Number = 0;
	var lectureTableWidth:Vector.<Number> = null;
	var userColumnCount:Number = 0;
	var userTableWidth:Vector.<Number> = null;
	var peopleCountColumnCount:Number = 0;
	var peopleCountTableWidth:Vector.<Number> = null;
	var attendedUserCount:int = 0;
	var serialNumber:Number = 0;
	var firstName:String = "";
	var lastName:String ="";
	var userName:String ="";
	var isAttended:String = "";
	var instituteName:String = "";
	var attendedUserName:Object = null;
	var registeredUserName:String = "";
	
	attendedUserList = tmpLectures[0];
	regUserCount = tmpLectures[1];
	registeredUserList = tmpLectures[2];
	var professorName:String = tmpLectures[3];
	var peopleCountDetails:Object = tmpLectures[4];
	
	var  lectName:String = dgLectures.selectedItem.displayName;
	var  lectureId:String = dgLectures.selectedItem.lectureId;
	var  className:String = dgLectures.selectedItem.className;
	
		
	var  startDate:String = dgLectures.selectedItem.startDate;
	startDate = dateToFormatt(startDate);
	var startTime:String = dgLectures.selectedItem.startTime;
	startTime = timeFormatter(startTime);
	var EndTime:String = dgLectures.selectedItem.endTime;
	EndTime = timeFormatter(EndTime);
	// Fix for bug # 20285
	var lectTableName:String = "Session Attendance Summary";
	
	lectureColumnCount = 4;
	var lecureColumnHeader:Array = new Array("Lecture Name","Date","Start Time","End Time");
	lectureTableWidth = Vector.<Number>([40,35,35,35]);
	lectureContentArray.push(lecureColumnHeader);
	var sessionSubHeader:Array=new Array("Class Name : "+className,"Professor Name : "+professorName);
	
	lectureValues = new Array(lectName,startDate,startTime,EndTime);
	lectureContentArray.push(lectureValues);
	var userTableName: String = "Lecture Summary";
	if(registeredUserList)
	{
		// Fix for bug # 20285
		var userColumnHeader:Array = new Array("Student Name","Institute Name","Attendance");
		userContenetArray.push(userColumnHeader);
		userColumnCount = 3;
		userTableWidth = Vector.<Number>([40,55,45]);
		for(var k:int=0;k<registeredUserList.length;k++)
		{
			registeredUserObject = registeredUserList[k];
			instituteName = registeredUserObject.instituteName;
			firstName = registeredUserObject.fname;
			lastName = registeredUserObject.lname;
			registeredUserName =registeredUserObject.userName;
			userName = firstName + " " + lastName;
			//Fix for Bug #20294
			isAttended = "No";
			if(attendedUserList)
			{
				for(var j:int = 0;j<attendedUserList.length;j++)
				{
					attendeduserObject = attendedUserList[j];
					attendedUserName = attendeduserObject.userName;
					if(attendedUserName == registeredUserName)
					{
						attendedUserCount++;
						isAttended="Yes";
						//Fix for Bug #20294
						break;
					}
				}
			}
			userValues = new Array(userName,instituteName,isAttended);
			userContenetArray.push(userValues);
		}	
	}
	else
	{
		userColumnCount = 1;
		userContenetArray.push("User Not registered for this correponding lecture");
	}
	var lectureSubHeader:Array = new Array(lectName+" : "+startDate,"Total Registered : "+regUserCount,"Attended Count : "+attendedUserCount);
	//Fix for issue #20304 start
	/*var currentDate:Date = new Date();
    var dateString:String = dateToFormatt(currentDate.toString()) + timeFormatter(currentDate.toString());*/
	//Fix for issue #20304 end
	//Fix for issue #20296
	pdfUtil = new PDFUtil();
	pdfUtil.createPDF(lectName+"_"+startDate);
	pdfUtil.createTable(lectureContentArray, lectTableName, sessionSubHeader,lectureTableWidth, lectureColumnCount);
	pdfUtil.createTable(userContenetArray, userTableName,lectureSubHeader, userTableWidth, userColumnCount);
	
	pdfUtil.addmainHeading("People Count Summary");
	pdfUtil.addsubHeading(lectName+" : "+startDate)
	pdfUtil.addsubHeading("Registered Users : "+regUserCount);
	peopleCountColumnCount = 3;
	if(peopleCountDetails)
	{
		var pplCountObject:Object = null;
		var peopleCountColumnHeader:Array=null;
		var time:String = "";
		var peopleCountSubHeader:Array = null;
		var pplCountValues:Object = null;
		for(var pp:int=0;pp<peopleCountDetails.length;pp++)
		{
			pplCountObject = peopleCountDetails[pp];
			if(pplCountObject!=null)
			{
				serialNumber = 1;
				peopleCountColumnHeader = new Array("Sl No","Student Node Name","People Count");
				peopleCountTableWidth = Vector.<Number>([ 20, 42, 20 ]);
				peopleCountContentArray.push(peopleCountColumnHeader);
				time = pplCountObject[0];
				peopleCountSubHeader = new Array("Time : "+timeFormatter(time));
				pplCountValues = pplCountObject[1];
				for(var r:int=0;r<pplCountValues.length;r++)
				{
					peopleCountValues = new Array(serialNumber++,pplCountValues[r][0],pplCountValues[r][1]);
					peopleCountContentArray.push(peopleCountValues);
				}
				pdfUtil.createTable(peopleCountContentArray, null,peopleCountSubHeader, peopleCountTableWidth, peopleCountColumnCount);
			}
		}
	}
	else
	{
		pdfUtil.addContent("People Count details not available");
	}
	//Fix for issue #20296
	applicationType::desktop{
		pdfUtil.save();
	}
	applicationType::web{
		Alert.show("Are you sure you want to download the lecture report?","Confirmation", Alert.YES|Alert.NO,null,downloadConfirmationHandler);
	}
}
//Fix for issue #20296
applicationType::web{
	private function downloadConfirmationHandler(event:CloseEvent):void{
		if(event.detail == Alert.YES){
			pdfUtil.save();
		}
	}
}
var dateFormatter:DateFormatter = new DateFormatter();
public function dateToFormatt(dateToFormat:String):String
{
	if(dateToFormat!=null)
	{
		
		dateFormatter.formatString = "DD-MMM-YYYY";
		var formattedDate:String=dateFormatter.format(dateToFormat);
		
	}
	return formattedDate;
}
public function timeFormatter(timeToFormat:String):String
{
	if(timeToFormat!=null)
	{
		dateFormatter.formatString = "LL.NN A";
		var formattedTime:String=dateFormatter.format(timeToFormat);
		return formattedTime;
	}
	return formattedTime;
}
	

//Code change for NIC end
