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
 * File			: CreateQuizComponentUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * Acts as handler for CreateQuizComponent.mxml
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.shared.vo.StatusVO;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.QuizCreatedEvent;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.vo.QuizVO;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.helper.CourseHelper;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.formatters.DateFormatter;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

import spark.collections.Sort;
import spark.collections.SortField;

/**
 * Flag used to check if question paper has to be set in live classroom ,
 * since user cannot select a question paper
 */
public var flagMainPage:Boolean=false;

/**
 * List of courses
 */
[Bindable]
private var dbCourse:ArrayCollection;

/**
 * List of classes
 */
[Bindable]
private var dbClass:ArrayCollection;

/**
 * List of question papers
 */
[Bindable]
private var dbQuestionPaper:ArrayCollection;

//Fix for Bug #10691
// server date and time to append it with quiz name
/**
 * Use to store server date and time
 */
[Bindable]
private var serverDateTime:String=null;

/**
 * The Value Object variable used while editing a quiz
 */
[Bindable]
private var quizVOForEdit:QuizVO;

/**
 * Used as loop variable to go through a list of classes
 */
private var classLoopVar:int=0;

/**
 * The Value Object variable used while validating the quiz fields
 */
private var quizVO:QuizVO;

/**
 * The QuizHelper object
 */
private var quizHelperRO:QuizHelper;

/**
 * The QuestionPaperHelper object 
 */
private var questionPaperHelperRO:QuestionPaperHelper;

/**
 * The CourseHelper object 
 */
private var courseHelperRO:CourseHelper;

/**
 * The ClassHelper object 
 */
private var classHelperRO:ClassHelper;

/**
 * Stores the validation error mesage
 */
private var errorMsg:String;

/**
 * Stores the class id , used while editing a quiz
 */
private var classId:int;

/**
 * List of status : Active and Closed
 */
private var statusIds:Array=new Array();

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quiz.CreateQuizComponentUIHandler.as");

/**
 * @public
 * initApp() is the first method called on initialising CreateQuizComponent.mxml
 * It initialises various variables and calls the remote methods 
 * @param quizVO type of QuizVO
 * @return void
 *
 */
public function initApp(quizVO:QuizVO):void {
	httpGetServerDate.send();
	statusIds=new Array();
	statusIds.push(StatusVO.ACTIVE_STATUS);
	statusIds.push(StatusVO.CLOSED_STATUS);
	quizVOForEdit=ObjectUtil.copy(quizVO) as QuizVO;
	dbCourse=new ArrayCollection();
	dbClass=new ArrayCollection();
	dbQuestionPaper=new ArrayCollection();
	quizVO=new QuizVO();
	quizHelperRO=new QuizHelper();
	questionPaperHelperRO=new QuestionPaperHelper();
	courseHelperRO=new CourseHelper();
	classHelperRO=new ClassHelper();
	if (ClassroomContext.checkIsClassRoom) {
		clearFields();
		questionPaperHelperRO.getAllActiveQuestionPapersForUser(ClassroomContext.userVO.userId,getAllActiveQuestionPapersForUserResultHandler);
		btnCreateQuiz.addEventListener(MouseEvent.CLICK, createQuiz);
	} else {
		courseHelperRO.getActiveCoursesForUser(ClassroomContext.userVO.userId,getActiveCoursesResultHandler);
	}
}

/**
 * @public
 * Gets the list of active courses
 * @param result type of ArrayCollection
 * @return void
 */
public function getActiveCoursesResultHandler(result:ArrayCollection):void {
	if(Log.isInfo()) log.info("getActiveCoursesResultHandler :: " + result);
	if (result != null) {
		ArrayCollectionUtil.copyData(dbCourse, result);
		GCLMContext.sortSmartComboDataProvider(dbCourse, "courseName");
		questionPaperHelperRO.getAllActiveQuestionPapersForUser(ClassroomContext.userVO.userId,getAllActiveQuestionPapersForUserResultHandler);
	}
}

/**
 * @public
 * Gets list of active classes for a course
 * @param result type of ArrayCollection
 * @return void
 */
public function searchClassResultHandler(result:ArrayCollection):void {
	if (result != null) {
		dbClass.removeAll();
		/*To solve UI issue of selecting class in combo box,when editing a quiz happens.*/
		ArrayCollectionUtil.copyData(dbClass,result);
		for (classLoopVar=0; classLoopVar < result.length; classLoopVar++) {
			/*dbClass.addItem(result[classLoopVar]);*/
			if (classId == dbClass[classLoopVar].classId) {
				cmbClasses.selectedIndex=classLoopVar;
				break;
			}
		}
	}
}

/**
 * @public
 * Gets list of active classes , when not in live classroom
 * @param result type of ArrayCollection
 * @return void
 */
public function getActiveClassesResultHandler(result:ArrayCollection):void {
	if(Log.isInfo()) log.info("getActiveClassesResultHandler :: " + result);
	if (result != null) {
		dbClass.removeAll();
		dbClass=result;
		GCLMContext.sortSmartComboDataProvider(dbClass, "className");
		if (quizVOForEdit != null) {
			populateQuizData(quizVOForEdit);
		}
	}
}

/**
 * @public
 * Gets list of active question papers
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQuestionPapersForUserResultHandler(event : ResultEvent):void
{
	var result:ArrayCollection = event.result as ArrayCollection;
	if(Log.isInfo()) log.info("getQuestionPaperIfQuestionsExist :: " + result);
	var i:int;
	if (result != null) 
	{
		GCLMContext.sortSmartComboDataProvider(result, "questionPaperName")
		var sort:Sort=new Sort;
		var sortByQuestionPaperName:SortField=new SortField('questionPaperName', false, null);
		sort.fields=[sortByQuestionPaperName];
		dbQuestionPaper=result;
		dbQuestionPaper.sort=sort;
		dbQuestionPaper.refresh();

		// Sets question paper , class and course in classroom , since their respective combo boxes are disabled
		if (flagMainPage)
		{
			for (i=0; i < dbQuestionPaper.length; i++)
			{
				if (ClassroomContext.questionPaperId == dbQuestionPaper[i].questionPaperId)
				{
					cmbQuestionPapers.selectedIndex=i;
				}
			}
			var qN:String=cmbQuestionPapers.selectedItem.questionPaperName;
			if (serverDateTime != null)
			{
				txtInpQuizName.text=qN + ' - ' + serverDateTime;

			} else
			{
				var dateTime:String=currentDateTime();
				txtInpQuizName.text=qN + ' - ' + dateTime;
			}
			dbClass.removeAll();
			dbClass.addItem(ClassroomContext.aviewClass);

			for (i=0; i < dbClass.length; i++)
			{
				if (ClassroomContext.aviewClass.className == dbClass.getItemAt(i).className)
				{
					cmbClasses.selectedIndex=i;
				}
			}

			dbCourse.removeAll();
			dbCourse.addItem(ClassroomContext.course);

			for (i=0; i < dbCourse.length; i++)
			{
				if (ClassroomContext.course.courseName == dbCourse.getItemAt(i).courseName)
				{
					cmbCourses.selectedIndex=i;
				}
			}
			var currentDate:Date = new Date();
			startHour.value = currentDate.hours;
			startMinutes.value = currentDate.minutes;
			endHour.value = currentDate.hours;
			endMinutes.value = currentDate.minutes;
		}

		else
		{
			classHelperRO.getClassByUserId(ClassroomContext.userVO.userId,getActiveClassesResultHandler);
		}
	}
}

/**
 * @public
 * Result handler after creating a quiz
 * @param result type of QuizVO
 * @return void
 */
public function createQuizResultHandler(result:QuizVO):void {
	//Fix for Bug #10941
	btnCreateQuiz.enabled=true;
	if (result != null) {
		//Fix for Bug #11541
		CustomAlert.info("Quiz started successfully", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		PopUpManager.removePopUp(this);
		var lastCreatedQuizVO:QuizVO=result;
		/*call the FMS code for starting the live quiz*/
		quizHelperRO.sendLiveQuizAsSMS(lastCreatedQuizVO.quizId);
		this.dispatchEvent(new QuizCreatedEvent(QuizCreatedEvent.QUIZ_CREATED, result));
		var isQuiz:Boolean=true; //To notify that a quiz is starting
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("startLiveQuizServer", null, lastCreatedQuizVO.quizId, isQuiz);
	}
}

/**
 * @public
 * The fault handler , if exception is thrown while creating a quiz
 * @param event type of FaultEvent
 * @return void
 */
public function createQuizFaultHandler(event:FaultEvent):void 
{
	if(Log.isError()) log.error("evaluation::quiz::CreateQuizComponentUIHandler::createQuizFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	//Fix for Bug #10941
	btnCreateQuiz.enabled=true;
	var strMsg:String=event.fault.faultString;
	if (strMsg.indexOf("Duplicate entry", 0) != -1) {
		CustomAlert.error("The given quiz name already exists. Please try with a different quiz name", "Error", null, this);
	} else {
		quizHelperRO.genericFaultHandler(event);
		PopUpManager.removePopUp(this);
	}
}

/**
 * @public
 * Handles the creating a quiz , after validating a question paper
 * @param event type of ResultEvent
 * @return void
 */
public function validateQuestionPaperResultHandler(event:ResultEvent):void {
	if(Log.isInfo()) log.info("getQuestionPaperComplete_resultHandler::event.result::" + event.result);
	quizHelperRO.createQuiz(quizVO, ClassroomContext.userVO.userId,createQuizResultHandler,createQuizFaultHandler);
}

/**
 * @public
 *
 * Handles the exception thrown , if validation for a question paper fails
 * @param event type of FaultEvent
 * @return void
 */
public function validateQuestionPaperFaultHandler(event:FaultEvent):void 
{
	if(Log.isError()) log.error("evaluation::quiz::CreateQuizComponentUIHandler::validateQuestionPaperFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	//Fix for Bug #10941
	btnCreateQuiz.enabled=true;
	var faultMessage:String=event.fault.faultString;
	if (faultMessage.indexOf("Current total marks is not equal", 0) != -1) {
		//Fix for Bug #11375
		CustomAlert.error("Current total marks is not equal to Max. total marks", "Information", null, this);
	} else if (faultMessage.indexOf("Question paper name can not", 0) != -1) {
		//Fix for Bug #11375
		CustomAlert.error("Question paper name can not be blank", "Information", null, this);
	} else if (faultMessage.indexOf("Invalid integer value for Max", 0) != -1) {
		//Fix for Bug #11375
		CustomAlert.error("Invalid integer value for Max. total marks.", "Information", null, this);
	} else if (faultMessage.indexOf("Specific and Random questions cannot be same", 0) != -1) {
		//Fix for Bug #11375
		CustomAlert.error("Sorry, not enough questions in database. ", "Information", null, this);
	} else if (faultMessage.indexOf("Sorry, Sufficient questions are not available in the question bank to generate Random Questions.", 0) != -1) {
		//Fix for Bug #11375
		CustomAlert.error("Sorry, Sufficient questions are not available in the question bank to generate Random Questions.", "Information", null, this);
	}

}

/**
 * @private
 * Populates the quiz data , while editing a quiz
 * @param obj type of QuizVO
 * @return void
 */
private function populateQuizData(obj:QuizVO):void
{
	var i:int;
	txtInpQuizName.text=obj.quizName;
	txtInpDuration.text=String(obj.durationSeconds);
	classId=obj.classId;
	for (i=0; i < dbCourse.length; i++) {
		if (obj.courseId == dbCourse.getItemAt(i).courseId) {
			cmbCourses.selectedIndex=i;
			classHelperRO.searchClass(0, obj.courseId, null, statusIds,searchClassResultHandler);
			break;
		}
	}
	for (i=0; i < dbQuestionPaper.length; i++) {
		if (obj.questionPaperId == dbQuestionPaper.getItemAt(i).questionPaperId) {
			cmbQuestionPapers.selectedIndex=i;
			break;
		}
	}

	dateStartDate.selectedDate=obj.timeOpen;
	startHour.value = obj.timeOpen.hours;
	startMinutes.value = obj.timeOpen.minutes;
	dateEndDate.selectedDate=obj.timeClose;
	endHour.value = obj.timeClose.hours;
	endMinutes.value = obj.timeClose.minutes;
}

/**
 * @private
 * Resets all the UI fields(disable some components) , in live classroom
 *
 * @return void
 */
private function clearFields():void {
	dbCourse.removeAll();
	dbClass.removeAll();
	cmbClasses.enabled=false;
	cmbCourses.enabled=false;
	cmbQuestionPapers.enabled=false;
	cmbClasses.selectedIndex=0;
	cmbCourses.selectedIndex=0;
	dateStartDate.selectedDate=new Date;
	dateEndDate.selectedDate=new Date;
	dateStartDate.enabled=false;
	dateEndDate.enabled=false;
	startHour.enabled = false;
	startMinutes.enabled = false;
	endHour.enabled = false;
	endMinutes.enabled = false;
	//Fix for Bug#15153
	txtInpDuration.text = "0";
	txtInpDuration.enabled = false;
}

/**
 * @private
 * Removes the pop up component
 *
 * @return void
 *
 */
private function closeCreateQuizComponent():void {
	PopUpManager.removePopUp(this);
}

/**
 * @private
 *
 * Gets classes for a course
 *
 * @return void
 *
 */
private function loadClassForCourse():void {
	if (cmbCourses.selectedItem != null) {
		classHelperRO.searchClass(0, cmbCourses.selectedItem.courseId, null, statusIds,searchClassResultHandler);
	}
}

/**
 * @private
 * Get current date and time in live classroom if server date time is null
 *
 * @return String
 *
 */
private function currentDateTime():String {
	//Please use only lowerCamelCase for variables.
	var CurrentDateTime:Date=new Date();
	var CurrentDF:DateFormatter=new DateFormatter();
	//Fix for Bug #10905
	CurrentDF.formatString="DD MMM YYYY-LL:NN:SS A"
	var DateTimeString:String=CurrentDF.format(CurrentDateTime);
	return DateTimeString;
}

/**
 * @private
 * Set the range for end date , as the selected start date
 *
 * @return void
 */
private function setEndDateRange():void {
	dateEndDate.text="";
	if(Log.isDebug()) log.debug(""+dateStartDate.selectedDate.date);
	var dt:Date=new Date();
	if(Log.isDebug()) log.debug(""+dt.date);
	if (dateStartDate.selectedDate.date != dt.date) {
		dt.setTime(dateStartDate.selectedDate.getTime());
	}
	if(Log.isDebug()) log.debug(""+dt);
	dateEndDate.selectableRange={rangeStart: dt};
	dateEndDate.enabled=true;
}

/**
 * @private
 * Handles the click event of quiz button
 * @param event type of MouseEvent
 * @return void
 *
 */
private function createQuiz(event:MouseEvent):void {
	//Fix for Bug #10666
	btnCreateQuiz.enabled=false;
	if (checkFieldsQz()) {
		questionPaperHelperRO.validateQuestionPaper(quizVO.questionPaperId, ClassroomContext.userVO.userId,validateQuestionPaperResultHandler,validateQuestionPaperFaultHandler);
	}

	else {
		//Fix for Bug #10666
		btnCreateQuiz.enabled=true;
		//Fix for Bug #11677
		CustomAlert.info(errorMsg, QuizContext.ALERT_TITLE_INFORMATION, null, this);
	}

}

/**
 * @private
 * Validates all mandatory field before creating a quiz
 *
 * @return boolean
 *
 */
private function checkFieldsQz():Boolean {
	var flagQz:Boolean=true;
	errorMsg="Please enter the following fields \n";
	quizVO=new QuizVO;
	quizVO.totalMarks=cmbQuestionPapers.selectedItem.currentTotalMarks;
	quizVO.quizStatus=QuizContext.READY_QUIZ_STATUS;

	if (ClassroomContext.checkIsClassRoom) {
		quizVO.quizType=QuizContext.LIVE_QUIZ_TYPE;
	} else {
		quizVO.quizType=QuizContext.ONLINE_QUIZ_TYPE;
	}

	quizVO.quizName=StringUtil.trim(txtInpQuizName.text);

	if (quizVO.quizName == QuizContext.EMPTY_STRING) {
		errorMsg+=" Quiz name,";
		flagQz=false;
	}

	if (dateStartDate.selectedDate != null) {
		quizVO.timeOpen=dateStartDate.selectedDate;
	}

	if (quizVO.timeOpen == null) {
		errorMsg+=" Time open,";
		flagQz=false;
	}

	if (dateEndDate.selectedDate != null) {
		quizVO.timeClose=dateEndDate.selectedDate;
	}

	if (quizVO.timeClose == null) {
		errorMsg+=" Time close,";
		flagQz=false;
	}

	if (quizVO.timeOpen > quizVO.timeClose) {
		errorMsg+="Quiz start date is greater than end date";
		flagQz=false;
	}

	/* Bug fix :  Bug #9542 */
	if ((cmbCourses.textInput.text == QuizContext.EMPTY_STRING) || (cmbCourses.selectedItem == null) || (cmbCourses.selectedItem.courseId == 0)) {
		errorMsg+="Course name,";
		flagQz=false;
	} else {
		quizVO.courseId=Number(cmbCourses.selectedItem.courseId);
	}
	if ((cmbClasses.textInput.text == QuizContext.EMPTY_STRING) || (cmbClasses.selectedItem == null) || (cmbClasses.selectedItem.classId == 0)) {
		errorMsg+=" Class name,";
		flagQz=false;
	} else {
		quizVO.classId=Number(cmbClasses.selectedItem.classId);
	}

	if ((cmbQuestionPapers.textInput.text == QuizContext.EMPTY_STRING) || (cmbQuestionPapers.selectedItem == null) || (cmbQuestionPapers.selectedItem.questionPaperId == 0)) {
		errorMsg+=" Question paper name,";
		flagQz=false;
	} else {
		quizVO.questionPaperId=cmbQuestionPapers.selectedItem.questionPaperId;
	}

	/* Trims the error message , so as not to contain comma at the end of the string*/
	errorMsg=errorMsg.substring(0, errorMsg.lastIndexOf(","));

	return flagQz;
}

/**
 * @protected
 * Gets the server's date and time
 * @param event type of ResultEvent
 * @return void
 */
protected function getServerDateResultHandler(event:ResultEvent):void {
	if(Log.isInfo()) log.info("Server date and time is : " + event.result.toString());
	//Fix for Bug #10905
	var res:String=event.result.toString();
	if (res.length > 0) {
		serverDateTime=res;
	}
}

/**
 * @protected
 * Handles exception thrown while getting server's date and time
 * @param event type of FaultEvent
 * @return void
 */
protected function getServerDateFaultHandler(event:FaultEvent):void 
{
	if(Log.isError()) log.error("evaluation::quiz::CreateQuizComponentUIHandler::getServerDateFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
}
