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
 * File		    : QuizResultUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Radha, Swati,Abhirami,Sethu subramanian N, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * QuizResultUIHandler acts as handler for QuizResult.mxml
 */

import edu.amrita.aview.core.shared.components.ArrayCollectionExtended;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.helper.QuizHelper;
import edu.amrita.aview.core.evaluation.quiz.CreateQuizComponent;
import edu.amrita.aview.core.evaluation.quiz.QuizResultViewerComponent;
import edu.amrita.aview.core.evaluation.quiz.QuizSummary;
import edu.amrita.aview.core.evaluation.quizResponse.StudentViewQuizResponse;
import edu.amrita.aview.core.evaluation.vo.QuizVO;
import edu.amrita.aview.core.gclm.GCLMContext;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

/**
 * Holds the error message on validation checking
 */
private var errorMsg:String;

/**
 * The component for creating/editing a quiz
 */
private var inputBox:CreateQuizComponent;

/**
 * The QuestionPaperHelper object 
 */
private var questionPaperHelperRO:QuestionPaperHelper;

/**
 * The QuizHelper object 
 *  
 */
private var quizHelper:QuizHelper;

/**
 * The Value Object variable 
 */
private var quizVO:QuizVO;

/**
 * List of active quizzes
 */
[Bindable]
private var quizzes:ArrayCollectionExtended;

/**
 * Data provider for tree
 */
[Bindable]
private var treeDataProvider:ArrayCollection;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quiz.QuizResultUIHandler.as");

/**
 * @public
 * initApp is the first function to be called on the initialising of QuizResult.mxml .
 * It initialises the helper objects , calls the remote object for populating the tree with list of quizzes 
 * 
 * @param quizVO type of QuizVO
 * @return void
 */
public function initApp(tempQuizVO:QuizVO=null):void
{
	quizVO =new QuizVO();
	quizzes=new ArrayCollectionExtended();
	quizHelper=new QuizHelper();
	treeDataProvider=new ArrayCollection;
	treeDataProvider.addItem({label: QuizContext.ROOT_TREE_QUIZ, children: new ArrayCollection});
	/**
	 * If user is teacher then call server to get active quizzes created by the teacher .
	 * Else user is student call server to get all active quizzes attended by the student. */
	if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		quizHelper.getAllActiveQuizzesForUser(ClassroomContext.userVO.userId,getAllActiveQuizzesForUserResultHandler);
		//To disable offline quiz in AVC 4.0
		btnAdd.enabled=false;
		btnDelete.enabled=false;
		btnEdit.enabled=false;
		
	}
	else if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE)
	{
		btnAdd.enabled=false;
		btnDelete.enabled=false;
		btnEdit.enabled=false;
		quizHelper.getAllActiveQuizzesForStudent(ClassroomContext.userVO.userId,getAllActiveQuizzesForStudentResultHandler);
	}
}

/**
 * @public
 * Gets all active quizzes for a student user
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQuizzesForStudentResultHandler(result:ArrayCollection):void
{
	if(Log.isInfo()) log.info("getAllActiveQuizzesForStudentResultHandler");
	quizzes=new ArrayCollectionExtended(result.source);
	// sort the quizzes alphabetically
	GCLMContext.sortSmartComboDataProvider(quizzes, 'quizName');
	treeDataProvider[0].children=quizzes;
	treeDataProvider.refresh();
	qzTree.invalidateList();
	qzTree.expandItem(treeDataProvider[0], true);
	qzTree.selectedIndex=0;
	showQuizSummary();
}

/**
 * @public
 *
 * Gets active quizzes for a user
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQuizzesForUserResultHandler(result:ArrayCollection):void
{
	if(Log.isInfo()) log.info("getAllActiveQuizzesForUserResultHandler");
	
	inputBox=new CreateQuizComponent();
	//inputBox.initApp(null);
	quizzes=new ArrayCollectionExtended(result.source);
	/* Round the marks of all quizzes. */
	for (var i:int=0; i < quizzes.length; i++)
	{
		quizzes[i].totalMarks=(Math.round(quizzes[i].totalMarks * 100) / 100);
	}
	GCLMContext.sortSmartComboDataProvider(quizzes, "quizName");
	treeDataProvider[0].children=quizzes;
	treeDataProvider.refresh();
	qzTree.invalidateList();
	qzTree.expandItem(treeDataProvider[0], true);
	qzTree.selectedIndex=0;
	showQuizSummary();
}

/**
 * @public
 * Handles the result returned after creating a quiz
 * @param result type of QuizVO
 * @return void
 */
public function createQuizResultHandler(result:QuizVO):void
{
	if(Log.isInfo()) log.info("createQuizResultHandler");
	
	CustomAlert.info("Quiz Start successfully", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	quizVO=result;
	qzTree.selectedItem.children.addItem(quizVO);
	qzTree.invalidateList();
	qzTree.expandItem(qzTree.selectedItem, true);
	showQuizSummary();
	PopUpManager.removePopUp(inputBox);
}

/**
 * @public
 * Handles the exception thrown while creating a quiz
 * @param event type of FaultEvent
 * @return void
 */
public function createQuizFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::quiz::QuizResultUIHandler::createQuizFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/* String to hold the fault string*/
	var strMsg:String=event.fault.faultString;
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given quiz name already exists. Please try with a different quiz name", "Error", null, this);
	}
	else
	{
		quizHelper.genericFaultHandler(event);
		PopUpManager.removePopUp(inputBox);
	}
}


/**
 * @public
 * Handles the result after updating a quiz
 * @param result type of QuizVO
 * @return void
 */
public function updateQuizResultHandler(result:QuizVO):void
{
	if(Log.isInfo()) log.info("updateQuizResultHandler");
	CustomAlert.info("Quiz updated successfully.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	if(Log.isInfo()) log.info("inputBox::" + inputBox);
	/* If inputBox component exist,then remove it. */
	if (inputBox != null)
	{
		PopUpManager.removePopUp(inputBox);
	}
}

/**
 * @public
 *
 * Handles the result on deleting a quiz
 * @param event type of ResultEvent
 * @return void
 */
public function deleteQuizResultHandler(event:ResultEvent):void
{
	CustomAlert.info("Quiz deleted successfully", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	treeDataProvider[0].children.removeItemAt(qzTree.selectedIndex - 1);
	qzTree.invalidateList();
	qzTree.selectedIndex=0;
	qzTree.invalidateList();
	if(Log.isInfo()) log.info("inputBox::" + inputBox);
	/* If inputBox component exist,then remove it. */
	if (inputBox != null)
	{
		PopUpManager.removePopUp(inputBox);
	}
	showQuizSummary();
}

/**
 * @public
 * Delegates calling remote method for creating quiz
 * @param event type of ResultEvent
 * @return void
 */
public function validateQuestionPaperResultHandler(event:ResultEvent):void
{
	if(Log.isInfo()) log.info("getQuestionPaperComplete_resultHandler::event.result::" + event.result);
	quizHelper.createQuiz(quizVO, ClassroomContext.userVO.userId,createQuizResultHandler,createQuizFaultHandler);
}

/**
 * @public
 * Handles the exception thrown while validating a question paper
 * @param event type of FaultEvent
 * @return void
 */
public function validateQuestionPaperFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::quiz::QuizResultUIHandler::validateQuestionPaperFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/* Variable to hold fault string message */
	var faultMessage:String=event.fault.faultString;
	/**
	 * Checking fault string message and showing appropriate error message.
	 */
	if (faultMessage.indexOf("Current total marks is not equal", 0) != -1)
	{
		CustomAlert.error("Current total marks is not equal to Max. total marks", "Validation", null, this);
	}
	else if (faultMessage.indexOf("Question paper name can not", 0) != -1)
	{
		CustomAlert.error("Question paper name can not be blank", "Validation", null, this);
	}
	else if (faultMessage.indexOf("Invalid integer value for Max", 0) != -1)
	{
		CustomAlert.error("Invalid integer value for Max. total marks.", "Validation", null, this);
	}
	else if (faultMessage.indexOf("Specific and Random questions cannot be same", 0) != -1)
	{
		CustomAlert.error("Sorry, not enough questions in database.", "Validation", null, this);
	}
	else if (faultMessage.indexOf("Sorry, not enough questions in database.", 0) != -1)
	{
		CustomAlert.error("Sorry, not enough questions in database.", "Validation", null, this);
	}
}

/**
 * @private
 * Loads the quiz component for creating a quiz
 *
 * @return void
 *
 */
private function createQuiz():void
{
	inputBox=CreateQuizComponent(PopUpManager.createPopUp(this, CreateQuizComponent, true));
	inputBox.txtInpQuizName.setFocus();
	inputBox.initApp(null);
	PopUpManager.centerPopUp(inputBox);
	inputBox.btnCreateQuiz.addEventListener(MouseEvent.CLICK, createQuizValidation);
}

/**
 * @private
 * Validates all mandatory fields before a quiz is created or updated
 *
 * @return boolean
 *
 */
private function checkFieldsQz():Boolean
{
	/* Flag to notify, if error exists. */
	var flagErrorChecker:Boolean=true;
	errorMsg="Please enter the following fields \n";
	quizVO.quizStatus=QuizContext.READY_QUIZ_STATUS;
	
	 //  Setting quiz type.
    // If user is in the classroom then set quiz type as live else set quiz type as online.
	quizVO.quizType = (ClassroomContext.checkIsClassRoom) ? QuizContext.LIVE_QUIZ_TYPE : QuizContext.ONLINE_QUIZ_TYPE;
	
	quizVO.quizName=StringUtil.trim(inputBox.txtInpQuizName.text);
	// Validating user input values and setting appropriate error message.
	// Checking whether quiz name is empty or not.
	if (quizVO.quizName == QuizContext.EMPTY_STRING)
	{
		errorMsg += " Quiz name,";
		flagErrorChecker = false;
	}
	
	// Checking whether start date is null or not.
	if (inputBox.dateStartDate.selectedDate != null)
	{
		quizVO.timeOpen=inputBox.dateStartDate.selectedDate;
		quizVO.timeOpen.hours = inputBox.startHour.value;
		quizVO.timeOpen.minutes = inputBox.startMinutes.value;
		if(quizVO.timeOpen.time < new Date().time)
		{
			errorMsg += " Start time is smaller than current time,";
			flagErrorChecker = false;
		}
	}
	
	// Checking whether opening time(start date) is null or not.
	if (quizVO.timeOpen == null)
	{
		errorMsg += " Time open,";
		flagErrorChecker = false;
	}
	
	// Checking whether end date is null or not.
	if (inputBox.dateEndDate.selectedDate != null)
	{
		quizVO.timeClose=inputBox.dateEndDate.selectedDate;
		quizVO.timeClose.hours = inputBox.endHour.value;
		quizVO.timeClose.minutes = inputBox.endMinutes.value;
		if(quizVO.timeClose.time < new Date().time)
		{
			errorMsg += " End time is smaller than current time,";
			flagErrorChecker = false;
		}
	}
	
	// Checking whether closing time(end date) is null or not.
	if (quizVO.timeClose == null)
	{
		errorMsg += " Time close,";
		flagErrorChecker = false;
	}
	
	// Checking whether opening time(start date) is greater than closing time(end date)
	if (quizVO.timeOpen > quizVO.timeClose)
	{
		errorMsg += "Quiz start date is greater than end date,";
		flagErrorChecker = false;
	}
	//Quiz duration temporary disabled.
	quizVO.durationSeconds=Number(StringUtil.trim(inputBox.txtInpDuration.text));
	
	// Checking whether duration is less than or equal to zero.
	if (quizVO.durationSeconds <= 0)
	{
		errorMsg += " Duration,";
		flagErrorChecker = false;
	}
	// Bug fix :  Bug #9542 
	// Checking whether Course selected is correct or not.
	if ((inputBox.cmbCourses.textInput.text == QuizContext.EMPTY_STRING) || (inputBox.cmbCourses.selectedItem == null) || (inputBox.cmbCourses.selectedItem.courseId == 0))
	{
		errorMsg += "Course name,";
		flagErrorChecker = false;
	}
	else
	{
		quizVO.courseId=Number(inputBox.cmbCourses.selectedItem.courseId)
	}
	
	/* Checking whether Class selected is correct or not. */
	if ((inputBox.cmbClasses.textInput.text == QuizContext.EMPTY_STRING) || (inputBox.cmbClasses.selectedItem == null) || (inputBox.cmbClasses.selectedItem.classId == 0))
	{
		errorMsg += " Class name,";
		flagErrorChecker = false;
	}
	else
	{
		quizVO.classId=Number(inputBox.cmbClasses.selectedItem.classId);
	}
	
	/* Checking whether question paper selected is correct or not. */
	if ((inputBox.cmbQuestionPapers.textInput.text == QuizContext.EMPTY_STRING) || (inputBox.cmbQuestionPapers.selectedItem == null) || (inputBox.cmbQuestionPapers.selectedItem.questionPaperId == 0))
	{
		errorMsg += " Question paper name,";
		flagErrorChecker = false;
	}
	else
	{
		quizVO.totalMarks=inputBox.cmbQuestionPapers.selectedItem.currentTotalMarks;
		quizVO.questionPaperId=inputBox.cmbQuestionPapers.selectedItem.questionPaperId;
	}
	
	errorMsg=errorMsg.substring(0, errorMsg.lastIndexOf(","));
	
	return flagErrorChecker;
}

/**
 * @private
 * Validates a question paper before , quiz is created
 * @param event type of MouseEvent
 * @return void
 *
 */
private function createQuizValidation(event:MouseEvent):void
{
	// If user input validation is success,then go for server side question paper validation.Else show error.
	if (checkFieldsQz())
	{
		questionPaperHelperRO=new QuestionPaperHelper();
		questionPaperHelperRO.validateQuestionPaper(quizVO.questionPaperId, ClassroomContext.userVO.userId,validateQuestionPaperResultHandler,validateQuestionPaperFaultHandler);
	}	
	else
	{
		CustomAlert.error(errorMsg, "Error", null, this);
	}
}

/**
 * @private
 * Handles the click event of btnDelete and calls the confirm handler
 *
 * @return void
 *
 */
private function deleteQuiz():void
{
	if(Log.isDebug()) log.debug("editQuiz::myTree.selectedItem::" + qzTree.selectedItem);
	/**
	 * If user doesn't select an item from tree then show error.
	 * Else show the delete conformation message. */
	if (qzTree.selectedIndex == 0 || qzTree.selectedItem == null)
	{
		CustomAlert.error("Please select a quiz for Delete.", "Error", null, this);
		return;
	}
	else
	{
		CustomAlert.confirm("Do you want to delete this Quiz Result?", "Confirmation", delQuizHandler, this);
	}
	btnAdd.enabled=false;
	btnDelete.enabled=false;
	btnEdit.enabled=false;
}

/**
 * @private
 * Call the deleteNode() or set enable/disable of buttons 
 * @param event type of CloseEvent
 * @return void
 *
 */
private function delQuizHandler(event:CloseEvent):void
{
	// If user select yes on conformation alert box then delete that node .
	if (event.detail == Alert.YES)
	{
		deleteNode();
	}
	else
	{
		btnAdd.enabled=false;
		btnDelete.enabled=true;
		// Fixed Bug #9523 Start
		btnEdit.enabled=true;
		// Fixed Bug #9523 End
	}
}

/**
 * @private
 * Deletes a selected quiz by calling the remote method
 *
 * @return void
 */
private function deleteNode():void
{
	// If user selected item is QuizVO then call server function to delete that quiz.
	if (qzTree.selectedItem is QuizVO)
	{
		var quizInstVO:QuizVO=qzTree.selectedItem as QuizVO;
		quizHelper.deleteQuiz(quizInstVO.quizId, ClassroomContext.userVO.userId,deleteQuizResultHandler);
	}
}

/**
 * @private
 * Loads the quiz component for editing a quiz
 *
 * @return void
 */
private function editQuiz():void
{
	if(Log.isDebug()) log.debug("editQuiz::myTree.selectedItem::" + qzTree.selectedItem);
	// If user doesn't select a quiz then show error.
	if (qzTree.selectedIndex == 0 || qzTree.selectedItem == null)
	{
		CustomAlert.error("Please select a quiz for editing.", "Error", null, this);
		return;
	}
	quizVO=qzTree.selectedItem as QuizVO;
	if(quizVO.timeOpen.time < new Date().time)
	{
		CustomAlert.info("Cannot edit an on going quiz");	
		return;
	}
	if (inputBox != null)
	{
		inputBox=CreateQuizComponent(PopUpManager.createPopUp(this, CreateQuizComponent, true));
		inputBox.title="Edit Quiz";
		inputBox.initApp(quizVO);
		inputBox.btnCreateQuiz.addEventListener("click", updateQuiz);
		PopUpManager.centerPopUp(inputBox);
	}

}

/**
 * @private
 * getNodes method is a label function for the tree component
 * Gets the quiz names to be displayed in the tree component
 * @param item type of Object
 * @return String
 */
private function getNodes(item:Object):String
{
	// If user selected item is QuizVO then return quiz name else return label.
	if (item is QuizVO)
	{
		return item.quizName;
	}
	else if (item is Object)
	{
		return item.label;
	}
	return QuizContext.EMPTY_STRING;
}

/**
 * @private
 * Handles the click event of the tree component 
 * If the root node is selected - Quiz Summary is displayed
 * If the child node is selected - Quiz component is displayed
 * 
 * @param event type of Event
 * @return void
 */
private function qzTreeOnClick(event:Event):void
{
	qzTree.editable=false;
	// Checking whether selected item is of type 'QuizVO'.
	if (event.currentTarget.selectedItem is QuizVO)
	{
		// Variable to hold user selected quiz details.
		var quiz:QuizVO=event.currentTarget.selectedItem as QuizVO;
		//Fix for Bug #11534
		// Variable to hold quiz creator's user id.
		var quizOwner:Number=quiz.createdByUserId;
		
		// Checking whether login user is the owner(teacher) of the selected quiz.
		if (quizOwner == ClassroomContext.userVO.userId)
		{
			btnAdd.enabled=false;
			btnDelete.enabled=true;
			btnEdit.enabled=true;
			var quizview:QuizResultViewerComponent=new QuizResultViewerComponent;
			quizview.quizId=quiz.quizId;
			quizview.quizVO=quiz;
			canContent.removeAllChildren();
			canContent.addChild(quizview);
		}
		else
		{
			var studentResultView:StudentViewQuizResponse=new StudentViewQuizResponse;
			studentResultView.quizVO=quiz;
			canContent.removeAllChildren();
			canContent.addChild(studentResultView);
		}
	}
	else
	{
		// If login user's role is TEACHER then enable/disable button.
		// Show quiz summary
		if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
		{
			//To disable offline quiz in AVC 4.0
			btnAdd.enabled=false;
			btnDelete.enabled=false;
			btnEdit.enabled=false;
		}
		showQuizSummary();
		
	}
}

/**
 * @private
 * Handles the double click on tree component by calling the method to edit a quiz
 * @param e type of Event
 * @return void
 */
private function qzTreeOnDoubleClick(e:Event):void
{
	btnEdit.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
}

/**
 * @private
 * Displays the quiz summary on clicking of the root node of the tree component
 *
 * @return void
 */
private function showQuizSummary():void
{
	// Variable to hold quiz summary.
	var quizSummary:QuizSummary=new QuizSummary();
	quizSummary.quizzes=new ArrayCollectionExtended(quizzes.source);
	canContent.removeAllChildren();
	canContent.addChild(quizSummary);
	quizSummary.init();
		
	// Checking if quizzes arraycollection is null or not. If not then refresh it.
	if (quizSummary.quizzes != null)
	{
		quizSummary.quizzes.refresh();
	}
}

/**
 * @private
 * Displays the tool tip for the children nodes in tree component
 * whose length is greater than 15
 * @param item type of Object
 * @return String
 *
 */
private function showToolTip(item:Object):String
{
	// If parameter is QuizVO then return quiz name.
	if (item is QuizVO)
	{
		if (item.quizName.length > QuizContext.textLengthForTree)
		{
			return item.quizName;
		}
	}
	return QuizContext.EMPTY_STRING;
}

/**
 * @private
 * Calls the remote method on editing of a quiz
 * @param event type of Event
 * @return void
 */
private function updateQuiz(event:Event):void
{
	if(quizVO.timeOpen.time < new Date().time)
	{
		CustomAlert.info("Cannot edit an on going quiz");	
		return;
	}
	// If user input validation is success,then call server function to update quiz.Else show error.
	if (checkFieldsQz())
	{
		quizVO.quizId=QuizVO(qzTree.selectedItem).quizId;
		quizHelper.updateQuiz(quizVO, ClassroomContext.userVO.userId,updateQuizResultHandler);
	}
	else
	{
		CustomAlert.error(errorMsg, "Error", null, this);
	}
}
