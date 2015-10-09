////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////


/**
 *
 * File			: PollingUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Abhirami,Mathiyalakan,Swati
 * Reviewer(s)	: Sinu Rachel John
 *
 * PollingUIHandler.as file is the script handler for Polling.mxml
 * This file contains all the functionalities for polling.
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.helper.QbQuestionHelper;
import edu.amrita.aview.core.evaluation.helper.QbQuestionTypeHelper;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.helper.QuizQuestionResponseHelper;
import edu.amrita.aview.core.evaluation.polling.PollingResult;
import edu.amrita.aview.core.evaluation.questionBank.CreateQuestionBankQuestion;
import edu.amrita.aview.core.evaluation.vo.QbAnswerChoiceVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionTypeVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuizVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxRenderer;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.formatters.DateFormatter;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.utils.ObjectUtil;

/**
 * Variable to hold custom alert
 */
private var alertWindow:Alert;
/**
 * Instance of polling result component
 */
private var pollResult:PollingResult;
/**
 * Instance of Question Bank Question component
 */
private var questionBankQuestionView:CreateQuestionBankQuestion;

/**
 * Arraycollection varaible to store polling questions details
 */
[Bindable]
private var pollingQuestions:ArrayCollection=new ArrayCollection;

/**
 * Variable to store quiz id
 */
private var quizId:Number;
/**
 * Variable to store quizQuestionId 
 */
private var quizQuestionId:Number;
/**
 * Question bank question helper class instance
 */
private var qbQuestionHelper:QbQuestionHelper;
/**
 * Question paper helper class instance
 */
private var questionPaperHelper:QuestionPaperHelper;
/**
 * Quiz question response helper class instance
 */
private var quizQuestionResponseHelper:QuizQuestionResponseHelper;
/**
 * Question bank question type helper class instance
 */
private var qbQuestionTypeHelperRO:QbQuestionTypeHelper;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.PollingUIHandler.as");

/**
 *
 * @public
 * Function :initApp
 * Initialization function which calls server function to retrieve data.
 *
 *
 * @return void
 *
 */
private function initializePolling():void 
{
	//setContextMenu("Start Polling");
	qbQuestionHelper = new QbQuestionHelper();
	questionPaperHelper = new QuestionPaperHelper();
	quizQuestionResponseHelper = new QuizQuestionResponseHelper();
	qbQuestionTypeHelperRO = new QbQuestionTypeHelper();
	qbQuestionTypeHelperRO.getQbQuestionTypeByName(QuizContext.POLLING,getQbQuestionTypeByNameResultHandler);
	qbQuestionHelper.getQbQuestionsForPolling(ClassroomContext.userVO.userId,getQbQuestionsForPollingResultHandler);
	selectCheckBoxHeader(false);
}

/**
 *
 * @public
 * Function :clickPollingQuiz
 * Click handler of polling button in ClassRoomSgl.mxml.
 * This functionality is only available for a presenter of class.
 *
 * @return void
 *
 */
public function clickPollingQuiz():void 
{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) 
	{
		//PNCR: since it a 3D checking this has to a function in 3D module
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.clickPolling();
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC) 
		{
			FlexGlobals.topLevelApplication.mainApp.stage.frameRate = 7;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initviewer3D_flag = 1;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeComponent();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded = false;
		}

		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl) 
		{
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pollingWnd.getChildren().length > 0) {
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pollingWnd.removeChild(this);
			}
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout != Constants.SIMPLE_LAYOUT) 
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnShowViewersWall.enabled = true;
			}
			//PNCR: since the below true/false setting is used in many modules. Create a common function with arguments.
			ClassroomContext.checkIsClassRoom = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Whiteboard.enabled = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Doc.enabled = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_vidsharing.enabled = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_LiveQuiz.enabled = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.evaluationFlag = false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_PollingQuiz.enabled = false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_2DViewer.enabled = true;
			//Fix for issue #15557
			applicationType::DesktopWeb {
				// Enable Deskop sharing button
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnDesktopSharing.enabled = true;
			}
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pollingWnd.numChildren == 0) 
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pollingWnd.addChild(this);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.getChildIndex(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.pollingWnd);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pollingFlag = true;
				initializePolling();
			}
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.contextMenuList) 
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.hideContextMenuList();
		}
	}
	//Fix for Bug#17799
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("remove");
}

/**
 *
 * @public
 * Function :getQbQuestionTypeByNameResultHandler
 * Result handler for getQbQuestionTypeByName.
 *
 * @param event type of QbQuestionTypeVO
 * @return void
 *
 */
public function getQbQuestionTypeByNameResultHandler(event:QbQuestionTypeVO):void 
{
	QuizContext.pollingQuestionTypeId = event.qbQuestionTypeId;
}

/**
 *
 * @public
 * Function :getQbQuestionsForPollingResultHandler
 * Result handler for getQbQuestionsForPolling.
 *
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getQbQuestionsForPollingResultHandler(result:ArrayCollection):void 
{
	//Copying to a local variable and assign it to the bindable variable for performance optimization
	var tmpQuestions:ArrayCollection = new ArrayCollection();
	QuizContext.copyDataBySequence(tmpQuestions, result);
	pollingQuestions = tmpQuestions;
}

/**
 *
 * @public
 * Function :createPollingQuestionPaperResultHandler
 * Result handler for 'createPollingQuestionPaper'.
 *
 * @param event type of QuizVO
 * @return void
 *
 */
public function createPollingQuestionPaperResultHandler(result:QuizVO):void 
{
	//Fix for Bug #10895
	setStartPollingButtonEnabled(true);
	quizId = result.quizId;
	var isQuiz:Boolean = false; // To notify that a polling is starting
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("startLiveQuizServer", null, quizId, isQuiz);
	alertWindow=CustomAlert.info("Polling started successfully", QuizContext.ALERT_TITLE_INFORMATION, null, this);
	dgForPollingQuestions.selectedItems = [];
}

/**
 *
 * @public
 * Function :createPollingQuestionPaperFaultHandler
 * Fault handler for createPollingQuestionPaper
 *
 *
 * @return void
 *
 */
public function createPollingQuestionPaperFaultHandler():void 
{
	setStartPollingButtonEnabled(true);
}

/**
 *
 * @public
 * Function :deleteQbQuestionsResultHandler
 * Result handler for 'deleteQbQuestions'.
 *
 * @return void
 *
 */
public function deleteQbQuestionsResultHandler():void 
{
	//Fix for Bug #10895
	setDeleteButtonEnabled(true);
	var selectedQuestions:Array=dgForPollingQuestions.selectedItems;
	var i:int;
	var idx:int;

	for (i=0; i < selectedQuestions.length; i++) 
	{
		idx=pollingQuestions.getItemIndex(selectedQuestions[i]);
		pollingQuestions.removeItemAt(idx);
	}
	if (pollingQuestions.length == 0) 
	{
		selectCheckBoxHeader(false);
	}
	alertWindow=CustomAlert.info("Successfully deleted the question(s).", QuizContext.ALERT_TITLE_INFORMATION, null, this);
}

/**
 *
 * @public
 * Function :deleteQbQuestionsFaultHandler
 * Fault handler for 'deleteQbQuestions'.
 *
 *
 * @return void
 *
 */
//Fix for Bug#14915
public function deleteQbQuestionsFaultHandler():void 
{
	//Fix for Bug #10895
	setDeleteButtonEnabled(true);
}

/**
 *
 * @public
 * Function :getResultForPollingQuizResultHandler
 * Result handler for getResultForPollingQuiz.
 *
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getResultForPollingQuizResultHandler(result:ArrayCollection):void 
{
	//This functionality is done here (parent component), because if there is no result available for the polling,
	//we do not need to popup the child component.
	//Fix for Bug #10895
	setResultButtonEnabled(true);
	var i:int;
    if(Log.isInfo()) log.info(""+result);
	var tmpQuestions:ArrayCollection=new ArrayCollection();
	if (result.length > 0) 
	{
		QuizContext.copyDataByQuizSequence(tmpQuestions, result);
		PopUpManager.removePopUp(pollResult);
		pollResult=PollingResult(PopUpManager.createPopUp(this, PollingResult, true));
		//Fix for Bug #11041
		pollResult.quizId=this.quizId;
		pollResult.qbQuestionId=dgForPollingQuestions.selectedItem.qbQuestionId;
		pollResult.pollingResultAC=tmpQuestions;
		PopUpManager.centerPopUp(pollResult);
	} 
	else 
	{
		alertWindow=CustomAlert.info("No result available",QuizContext.ALERT_TITLE_INFORMATION, null, this);
	}
}

/**
 *
 * @public
 * Function :getResultForPollingQuizFaultHandler
 * Fault handler for 'getResultForPollingQuiz'.
 *
 *
 * @return void
 *
 */
public function getResultForPollingQuizFaultHandler():void 
{
	setResultButtonEnabled(true);
}


/**
 *
 * @private
 * Function :toggleSelection
 * Click handler for check box .
 *
 *
 * @return void
 *
 */
private function toggleSelection():void 
{
	var col:CheckBoxHeaderColumn=dgForPollingQuestions.columns[0];
	if (pollingQuestions == null) 
	{
		return;
	}
	//PNCR: use conditional operator
	if (col.selected) {
		dgForPollingQuestions.selectedItems=pollingQuestions.toArray();
	} 
	else 
	{
		dgForPollingQuestions.selectedItems=[];
	}
}

/**
 *
 * @private
 * Function :addPollingQuestions
 * Click handler for 'sendPolling' button.
 * It starts the polling.
 *
 *
 * @return void
 *
 */
private function startPolling():void 
{
	//Fix for Bug #10895
	setStartPollingButtonEnabled(false);
	// ArrayCollection to store polling questions.
	var pollingQuestion:ArrayCollection=new ArrayCollection;
	if ((dgForPollingQuestions.selectedItems == null) || (dgForPollingQuestions.selectedItems.length == 0)) 
	{
		//Fix for Bug #10895
		setStartPollingButtonEnabled(true);
		alertWindow=CustomAlert.info("Please select a question to start polling.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	if ((dgForPollingQuestions.selectedItems.length == 1)) 
	{
		var selectedItems:Array=dgForPollingQuestions.selectedItems;
		if(Log.isDebug()) log.debug("StartPolling::dgForPollingQuestions.selectedItems.length::" + dgForPollingQuestions.selectedItems.length);
		for (var i:int=0; i < selectedItems.length; i++) 
		{
			var question:QbQuestionVO=selectedItems[i] as QbQuestionVO;
			if (question.qbQuestionId != 0) 
			{
				var qbq:QbQuestionVO=new QbQuestionVO();
				qbq.qbQuestionId=question.qbQuestionId;
				qbq.qbSubcategoryId=question.qbSubcategoryId;
				qbq.marks=question.marks;
				pollingQuestion.addItem(qbq);
				if(Log.isDebug()) log.debug("StartPolling::question.qbQuestionId::" + question.qbQuestionId);
			}
		}
		questionPaperHelper.createPollingQuestionPaper(pollingQuestion, ClassroomContext.aviewClass.classId, ClassroomContext.aviewClass.courseId, ClassroomContext.userVO.userId,createPollingQuestionPaperResultHandler,createPollingQuestionPaperFaultHandler);
	} 
	else 
	{
		//Fix for Bug #10895
		setStartPollingButtonEnabled(true);
		alertWindow=CustomAlert.info("Please select only one question to start polling.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
}

/**
 *
 * @private
 * Function :createQuestionForPolling
 * Click handler for 'createQuestion' button.
 * It popup a window to create polling question.
 *
 *
 * @return void
 *
 */
private function createQuestionForPolling():void 
{
	//Fix for Bug #10895
	setCreateButtonEnabled(false);
	questionBankQuestionView=CreateQuestionBankQuestion(PopUpManager.createPopUp(this, CreateQuestionBankQuestion, true));
	PopUpManager.centerPopUp(questionBankQuestionView);
	questionBankQuestionView.isPolling=true;

	questionBankQuestionView.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , createQuestionBankQuestionEventComplete);
}

/**
 *
 * @private
 * Function :editQuestionPolling
 * Click handler for'editQuestion' button.
 * It popup a window to edit polling question.
 *
 *
 * @return void
 *
 */
private function editQuestionPolling():void 
{
	//Fix for Bug #10895
	setEditButtonEnabled(false);
	if (dgForPollingQuestions.selectedItems.length != 1) 
	{
		//Fix for Bug #10895
		setEditButtonEnabled(true);
		//Fix for Bug #16154
		alertWindow=CustomAlert.info("Please select one question for editing.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		dgForPollingQuestions.selectedIndex=-1;
		selectCheckBoxHeader(false);
		dgForPollingQuestions.invalidateList();
		return;
	}
	
	var i:int=0;
	questionBankQuestionView=CreateQuestionBankQuestion(PopUpManager.createPopUp(this, CreateQuestionBankQuestion, true));
	PopUpManager.centerPopUp(questionBankQuestionView);
	questionBankQuestionView.isPolling=true;
	if(Log.isDebug()) log.debug("showQuestionView::Edit");
	var question:QbQuestionVO=dgForPollingQuestions.selectedItem as QbQuestionVO;
	// added question type for each answer choice
	var ansVO:QbAnswerChoiceVO=null;
	for (i=0; i < question.qbAnswerChoices.length; i++) 
	{
		ansVO = new QbAnswerChoiceVO;
		ansVO=question.qbAnswerChoices[i];
		ansVO.questionTypeId=QuizContext.pollingQuestionTypeId;
		ansVO.questionLevelId=question.qbDifficultyLevelId;
		question.qbAnswerChoices[i]=ansVO;
	}
	// Fix for Bug #5461
	var tmpArraySrc:ArrayCollection = new ArrayCollection();
	var tmpArrayDest:ArrayCollection = new ArrayCollection();
	tmpArraySrc.addItem(question);
	QuizContext.copyDataBySequence(tmpArrayDest,tmpArraySrc);
	questionBankQuestionView.qbQuestionVO=ObjectUtil.copy(tmpArrayDest[0]) as QbQuestionVO;
	questionBankQuestionView.editQuestionType();
	
	questionBankQuestionView.title=QuizContext.EDIT_QUESTION_LABEL;
	questionBankQuestionView.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , updateQuestionBankQuestionEventComplete);
}

/**
 *
 * @private
 * Function :deleteQuestionPolling
 * Click handler for 'DeleteQuestion' button.
 * It confirm with the user whether to delete the polling question.
 *
 *
 * @return void
 *
 */
private function deleteQuestionPolling():void 
{
	//Fix for Bug #10895
	setDeleteButtonEnabled(false);
	var selectedQuestions:ArrayCollection=new ArrayCollection(dgForPollingQuestions.selectedItems);
	if (selectedQuestions.length == 0) 
	{
		alertWindow=CustomAlert.info("Please select question(s) for deleting.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		//Fix for Bug #10895
		setDeleteButtonEnabled(true);
		return;
	} 
	else 
	{
		//Fix for Bug #16155
		alertWindow=CustomAlert.confirm("Do you want to delete this question(s)?", "Confirmation", confirmDeleteQuestionHandler, this);
	}
}

/**
 *
 * @private
 * Function :delQuestionHandler
 * Handler for alert confirmation to delete polling question.
 *
 * @param event type of CloseEvent
 * @return void
 *
 */
private function confirmDeleteQuestionHandler(event:CloseEvent):void 
{
	if (event.detail == Alert.YES) 
	{
		var selectedQuestions:ArrayCollection=new ArrayCollection(dgForPollingQuestions.selectedItems);
		if (selectedQuestions.length == 0) 
		{
			alertWindow=CustomAlert.error("Please select one or more questions to delete and try again.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
			//Fix for Bug #10895
			setDeleteButtonEnabled(true);
			return;
		}
		qbQuestionHelper.deleteQbQuestions(selectedQuestions, ClassroomContext.userVO.userId,deleteQbQuestionsResultHandler,deleteQbQuestionsFaultHandler);
	} 
	else if (event.detail == Alert.NO) 
	{
		//Fix for Bug #10895
		setDeleteButtonEnabled(true);
		dgForPollingQuestions.selectedIndex=-1;
		selectCheckBoxHeader(false);
		dgForPollingQuestions.invalidateList();
		return;
	}
}

/**
 *
 * @private
 * Function :getSlNo
 * Label function to get the index number.
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getSlNo(oItem:Object, iCol:int):String 
{
	var iIndex:int=pollingQuestions.getItemIndex(oItem) + 1;
	return String(iIndex);
}

/**
 *
 * @private
 * Function :showResult
 * Click handler for 'result' button.
 * It call server function to get result of polling.
 *
 *
 * @return void
 *
 */
private function showResult():void 
{
	//Fix for Bug #10895
	setResultButtonEnabled(false);
	if (dgForPollingQuestions.selectedItems.length != 1) 
	{
		dgForPollingQuestions.selectedIndex=-1;
		selectCheckBoxHeader(false);
		dgForPollingQuestions.invalidateList();

		//Fix for Bug #10895
		setResultButtonEnabled(true);
		//Fix for Bug #11356
		alertWindow=CustomAlert.info("Please select one question to view result.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	} 
		//Server call is done on this parent component because if there is no result available for the polling,
		//we do not need to popup the child component.
		//Fix for Bug #19388,19832
		quizQuestionResponseHelper.getResultForPollingQuiz(quizQuestionId, dgForPollingQuestions.selectedItem.qbQuestionId,getResultForPollingQuizResultHandler,getResultForPollingQuizFaultHandler)
}

/**
 *
 * @private
 * Function :formatCreatedDate
 * To format created date.
 *
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function formatCreatedDate(oItem:Object, iCol:int):String 
{
	var dateFormatter:DateFormatter = new DateFormatter();
	dateFormatter.formatString = "DD MMM YYYY K:N:S A";
	return dateFormatter.format(oItem.createdDate);
}

/**
 *
 * @private
 * Function :setCreateButtonEnabled
 * To enable/disable 'Create Question' button
 *
 * @param flag type of Boolean
 * @return void
 *
 */
private function setCreateButtonEnabled(flag:Boolean):void 
{
	btnCreateQuestion.enabled=flag;
}

/**
 *
 * @private
 * Function :setEditButtonEnabled
 * To enable/disable 'Edit Question' button
 *
 * @param flag type of Boolean
 * @return void
 *
 */
private function setEditButtonEnabled(flag:Boolean):void 
{
	btnEditQuestion.enabled=flag;
}

/**
 *
 * @private
 * Function :setDeleteButtonEnabled
 * To enable/disable 'Delete Question' button
 *
 * @param flag type of Boolean
 * @return void
 *
 */
private function setDeleteButtonEnabled(flag:Boolean):void 
{
	btnDeleteQuestion.enabled=flag;
}

/**
 *
 * @private
 * Function :setStartPollingButtonEnabled
 * To enable/disable 'Start Polling' button.
 *
 * @param flag type of Boolean
 * @return void
 *
 */
private function setStartPollingButtonEnabled(flag:Boolean):void 
{
	btnSendPolling.enabled=flag;
}

/**
 *
 * @private
 * Function :setResultButtonEnabled
 * To enable/disable 'View Result' button
 *
 * @param flag type of Boolean
 * @return void
 *
 */
private function setResultButtonEnabled(flag:Boolean):void 
{
	btnResult.enabled=flag;
}
/**
 * 
 * @private
 * Function :selectCheckBoxHeader
 * To check/uncheck all the check box in checBoxDataGrid
 * @param value type of Boolean
 * @return void
 * 
 */
private function selectCheckBoxHeader(value:Boolean):void
{
	var col:CheckBoxHeaderColumn=dgForPollingQuestions.columns[0];
	col.selected=value;
}
/**
 * 
 * @private
 * Function :sortAnswerChoiceBySequence
 * To sort qbQuestion answer choice after creating a polling question
 * @param qbQuestion type of QbQuestionVO
 * @return void
 * 
 */
private function sortAnswerChoiceBySequence(qbQuestion:QbQuestionVO):void
{
	var sourceAnswerChoice:ArrayCollection = new ArrayCollection();
	var destinationAnswerChoice:ArrayCollection = new ArrayCollection();
	sourceAnswerChoice.addItem(qbQuestion);
	QuizContext.copyDataBySequence(destinationAnswerChoice,sourceAnswerChoice);
	qbQuestion = destinationAnswerChoice.getItemAt(0) as QbQuestionVO;
}

/**
 *
 * @private
 * Function : createQuestionBankQuestionEventComplete
 * Handler after creating polling question.
 *
 * @param event type of EvaluationEvent
 * @return void
 *
 */
private function createQuestionBankQuestionEventComplete(event:EvaluationEvent):void 
{
	//Fix for Bug #10895
	setCreateButtonEnabled(true);
	// If event.data is not null,it means user clicked on save button.Then add new question to the datagrid
	// Else user clicked on cancel button(in CreateQuestionBankQuestion)
	if(event.data != null)
	{
		var qbQuestion:QbQuestionVO = event.data as QbQuestionVO;
		alertWindow=CustomAlert.info("Question created successfully", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		
		sortAnswerChoiceBySequence(qbQuestion);
		pollingQuestions.addItem(qbQuestion);
	}
	
	questionBankQuestionView = null;
	selectCheckBoxHeader(false);
}
/**
 *
 * @private
 * Function : updateQuestionBankQuestionEventComplete
 * Handler after updating polling question.
 *
 * @param event type of EvaluationEvent
 * @return void
 *
 */
private function updateQuestionBankQuestionEventComplete(event:EvaluationEvent):void 
{
	//Fix for Bug #10895
	setEditButtonEnabled(true);
	// If event.data is not null,it means user clicked on save button.Then add updated question to the datagrid
	// Else user clicked on cancel button(in CreateQuestionBankQuestion)
	if(event.data != null)
	{
		var qbQuestionvo:QbQuestionVO = new QbQuestionVO();
		qbQuestionvo = event.data as QbQuestionVO;
		if(Log.isInfo()) log.info("Updated Question : \n" + qbQuestionvo.toString());
		
		var index:int = dgForPollingQuestions.selectedIndex;
		pollingQuestions.removeItemAt(index);
		pollingQuestions.addItemAt(qbQuestionvo, index);
		pollingQuestions.refresh();
		
		alertWindow = CustomAlert.info("Question updated successfully.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	}
	
	questionBankQuestionView = null;	
	selectCheckBoxHeader(false);
}

public function closeAllChildWindow() : void
{
	closeQuestionBankQuestionView();
	closePollingResult();
	closeAlertWindow();
}
private function closeQuestionBankQuestionView() : void
{
	if(questionBankQuestionView != null)
	{
		questionBankQuestionView.closeAlertWindow();
		PopUpManager.removePopUp(questionBankQuestionView);
	}	
}
private function closePollingResult() : void
{
	if(pollResult != null)
	{
		PopUpManager.removePopUp(pollResult);
	}	
}
private function closeAlertWindow() : void
{
	if(alertWindow != null)
	{
		PopUpManager.removePopUp(alertWindow);
	}	
}
//Fix for Bug#8865
protected function dgItemClickHandler(event:ListEvent):void 
{
	if (event.columnIndex == 0) 
	{
		(event.itemRenderer as CheckBoxRenderer).dispatchEvent(new MouseEvent("click"));
	}
	event.stopPropagation();
}