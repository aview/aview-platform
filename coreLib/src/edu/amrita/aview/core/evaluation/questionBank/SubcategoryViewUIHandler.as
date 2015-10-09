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
 * File			: SubcategoryViewUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * This component displays detail about a specific question bank subcategory.
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.event.UpdateQBTotalQuestionsEvent;
import edu.amrita.aview.core.evaluation.helper.QbQuestionHelper;
import edu.amrita.aview.core.evaluation.questionBank.CreateQuestionBankQuestion;
import edu.amrita.aview.core.evaluation.vo.QbAnswerChoiceVO;
import edu.amrita.aview.core.evaluation.vo.QbDifficultyLevelVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionTypeVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;
import edu.amrita.aview.core.shared.components.ArrayCollectionExtended;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxRenderer;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

/**
 * Used to hold question bank subcategory.
 */
public var qbSubcategoryVO:QbSubcategoryVO;

[Bindable]
/**
 * The name of subcategory , to display as label
 */
public var subcategoryName:String = "";

[Bindable]
/**
 * List of questions for a subcategory
 */
private var questions:ArrayCollectionExtended = new ArrayCollectionExtended;

[Bindable]
/**
 * The difficulty levels
 */
private var levels:ArrayCollection = new ArrayCollection;

[Bindable]
/**
 * The question types
 */
private var questionTypes:ArrayCollection = new ArrayCollection;

/**
 * Used to call remote methods  of  QbQuestionHelper
 */
private var qbQuestionHelperRO:QbQuestionHelper;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionBank.SubcategoryViewUIHandler.as");

/**
 * @public
 * Gets all questions for a subcategory
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getAllActiveQbQuestionsForSubcategoryResultHandler(result:ArrayCollection):void
{
	var tmpQuestions:ArrayCollectionExtended = new ArrayCollectionExtended;
	if(Log.isInfo()) log.info("getAllActiveQbQuestionsForSubcategory_resultHandler::result::" + result);
	QuizContext.copyDataBySequence(tmpQuestions, new ArrayCollectionExtended(result.source)); //Avoid bindable arraycollection for sorting 
	questions = tmpQuestions;
	subcategoryName = qbSubcategoryVO.qbSubcategoryName;
	//filter the result to get only the active answers	
	// setup the filters array: in order to take effect
	//you must call refresh() on the collection
	refreshHandler() ;
}

/**
 * @public
 * Handles the result , after question/questions are deleted
 *
 * @return void
 *
 */
public function deleteQbQuestionsResultHandler():void 
{
	var oldQuestionListLength:int = 0 ;
	var newQuestionListLength:int  = 0 ;
	
	oldQuestionListLength = questions.length;
	/** Variable to hold  selected questions */ 
	var selectedQuestions:Array = dataGridForQuestions.selectedItems;
	var i:int;
	/** Variable to hold index */ 
	var index:int;

	// Remove selected questions from 'questions' arraycollection. 
	for (i = 0; i < selectedQuestions.length; i++) 
	{
		index = questions.getItemIndex(selectedQuestions[i]);
		questions.removeItemAt(index);
	}
	qbSubcategoryVO.totalQns = questions.length;
	CustomAlert.info("Successfully deleted the question(s).", QuizContext.ALERT_TITLE_INFORMATION , null, this);
	newQuestionListLength = oldQuestionListLength - questions.length ;
	this.dispatchEvent(new UpdateQBTotalQuestionsEvent(UpdateQBTotalQuestionsEvent.QB_TOTAL_QNS,newQuestionListLength)) ;
	if (questions.length == 0) 
	{
		selectCheckBoxHeader(false);
	}
}

/**
 * @private
 * Sets the initial setup : populate data providers , call remote methods
 *
 * @return void
 *
 */
private function initSubcategoryView():void 
{
	qbQuestionHelperRO = new QbQuestionHelper();	
	// Load question type from quizQuestionTypes in ClassroomContext.
	if (questionTypes != null) 
	{
		questionTypes.removeAll();
		ArrayCollectionUtil.copyData(questionTypes, ClassroomContext.quizQuestionTypes);
		var qtype:QbQuestionTypeVO = new QbQuestionTypeVO;
		qtype.qbQuestionTypeName = "---All Types---";
		qtype.qbQuestionTypeId = -1;
		questionTypes.addItemAt(qtype, 0);
	}
	// Load difficulty level from quizDifficultyLevels in ClassroomContext.
	if (levels != null) 
	{
		levels.removeAll();
		ArrayCollectionUtil.copyData(levels, ClassroomContext.quizDifficultyLevels);
		var level:QbDifficultyLevelVO = new QbDifficultyLevelVO;
		level.qbDifficultyLevelId = -1;
		level.qbDifficultyLevelName = "---All Levels---";
		levels.addItemAt(level, 0);
	}

	// Server call to get question bank questions for a category. 
	qbQuestionHelperRO.getAllActiveQbQuestionsForSubcategory(qbSubcategoryVO.qbSubcategoryId,getAllActiveQbQuestionsForSubcategoryResultHandler);
}

/**
 * @private
 * Retrieves the questions on change of level , type , question text
 *
 * @return void
 *
 */
private function refreshHandler():void 
{
	questions.filterFunctions = [filterByLevel, filterByType, filterByQtext];
	questions.refresh();
	check.selected = false;
}

/**
 * @private
 * Gets the serial nos. for grid column
 * @param oItem type of Object
 * @parm iCol type of int
 * @return String
 *
 */
private function getSerialNumber(oItem:Object, iCol:int):String 
{
	var iIndex:int = questions.getItemIndex(oItem) + 1;
	var returnString:String;
	var question:QbQuestionVO = questions.getItemAt(iIndex - 1) as QbQuestionVO;
	var tmpQuestion:QbQuestionVO = dataGridForQuestions.selectedItem as QbQuestionVO;
	returnString=String(iIndex + ". " + question.questionText) + "\n";
	// Displays the answer only if the checkbox is selected
	if (chkShowAnswers.selected) 
	{
		// Fix for Bug #14826:Start
		// Display answer only for a single row
		/*if (dataGridForQuestions.selectedItems.length == 1) 
		{
			if (question.qbQuestionId == tmpQuestion.qbQuestionId) 
			{*/
		// Fix for Bug #14826:End
				for (var i:int = 0; i < question.qbAnswerChoices.length; i++) 
				{
					var answerChoice:QbAnswerChoiceVO = question.qbAnswerChoices[i];
					// A * in front of the answer , means its the correct answer
					//PNCR: use conditional operator
					if (answerChoice.fraction == 0) 
					{
						returnString += "\n\t\t    " + answerChoice.choiceText;
					} 
					else 
					{
						returnString += "\n\t\t * " + answerChoice.choiceText;
					}
				}
			/*}
		}*/
	}
	return returnString;
}

/**
 * @private
 * Gets the difficulty level
 * @param oItem type of Object
 * @parm iCol type of int
 * @return void
 *
 */
private function getDifficultyLevel(oItem:Object, iCol:int):String 
{
	if(Log.isDebug()) log.debug("getDifficultyLevel::oItem::" + oItem);
	for (var i:int = 0; i < levels.length; i++) 
	{
		if (oItem.qbDifficultyLevelId == levels[i].qbDifficultyLevelId) 
		{
			return String(levels[i].qbDifficultyLevelName);
		}
	}
	return "";
}

/**
 * @private
 * Gets the question type
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getQuestionType(oItem:Object, iCol:int):String 
{
	if(Log.isDebug()) log.debug("getQnType::oItem::" + oItem);
	for (var i:int = 0; i < questionTypes.length; i++) 
	{
		if (oItem.qbQuestionTypeId == questionTypes[i].qbQuestionTypeId) 
		{
			return String(questionTypes[i].qbQuestionTypeName);
		}
	}
	return "";
}

/**
 * @private
 * Filter function on basis of difficulty level
 * @param item type of Object
 * @return Boolean
 *
 */
private function filterByLevel(item:Object):Boolean 
{
	if(Log.isDebug()) log.debug("filterByLevel::item.qbDifficultyLevelId::" + item.qbDifficultyLevelId);
	if (cbLevels.selectedItem == null || cbLevels.selectedItem.qbDifficultyLevelId == -1 || item.qbDifficultyLevelId == cbLevels.selectedItem.qbDifficultyLevelId) 
	{
		return true;
	}
	return false;
}

/**
 * @private
 * Filter function on basis of question type
 * @param item type of Object
 * @return Boolean
 *
 */
private function filterByType(item:Object):Boolean 
{
	if(Log.isDebug()) log.debug("filterByType::item.qbQuestionTypeId::" + item.qbQuestionTypeId);
	if (cbTypes.selectedItem == null || cbTypes.selectedItem.qbQuestionTypeId == -1 || item.qbQuestionTypeId == cbTypes.selectedItem.qbQuestionTypeId) 
	{
		return true;
	}
	return false;
}

/**
 * @private
 * Filter function on basis of question text
 * @param item type of Object
 * @return Boolean
 *
 */
private function filterByQtext(item:Object):Boolean 
{
	//Fix for Bug #11021
	if (txtSearch.text == null || item.questionText.toLowerCase().indexOf(StringUtil.trim(txtSearch.text).toLowerCase()) != -1) 
	{
		return true;
	}
	return false;
}

/**
 * @private
 * Allows to select or deselect all questions in datagrid
 *
 * @return void
 *
 */
private function toggleSelection():void 
{
	var col:CheckBoxHeaderColumn = dataGridForQuestions.columns[0];
	if (questions == null) 
	{
		return;
	}
	// If header check box is selected then set all the questions to selectedItem of 'dg' datagrid. 
	if (col.selected) 
	{
		dataGridForQuestions.selectedItems = questions.toArray();
	}
	//Fix for Bug #11367:Start
/*else
{
dg.selectedItems = [];
}*/
	//Fix for Bug #11367:End
}

/**
 * @private
 * Delegates viewing of question view component
 *
 * @return void
 *
 */
private function onCreateQuestion():void 
{
	showQuestionView(false);
}

/**
 * @private
 * Pops up the question in question bank in either edit or create mode
 * @param isEdit type of Boolean
 * @return void
 *
 */
private function showQuestionView(isEdit:Boolean):void 
{
	var i:int = 0;
	var questionView:CreateQuestionBankQuestion = CreateQuestionBankQuestion(PopUpManager.createPopUp(this, CreateQuestionBankQuestion, true));
	
	// Check if the question component should show the edit/create view
	if (isEdit) 
	{
		if(Log.isDebug()) log.debug("showQuestionView::Edit");
		var question:QbQuestionVO = dataGridForQuestions.selectedItem as QbQuestionVO;
		// added question type for each answer choice 
		for (i = 0; i < question.qbAnswerChoices.length; i++) 
		{
			var ansVO:QbAnswerChoiceVO = new QbAnswerChoiceVO;
			ansVO = question.qbAnswerChoices[i];
			ansVO.questionTypeId = question.qbQuestionTypeId;
			ansVO.questionLevelId = question.qbDifficultyLevelId;
			question.qbAnswerChoices[i] = ansVO;
		}
		questionView.qbQuestionVO = ObjectUtil.copy(question) as QbQuestionVO;
		questionView.editQuestionType();
		
		questionView.title = QuizContext.EDIT_QUESTION_LABEL;
		questionView.addEventListener(EvaluationEvent.CREATE_OR_UPDATE,updateQuestion) ;		
	} 
	else 
	{
		questionView.qbSubcategoryId = qbSubcategoryVO.qbSubcategoryId;
		questionView.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , createQuestion) ;		
	}
	PopUpManager.centerPopUp(questionView);
}

/**
 * @private
 * Handler after creating question.
 * @param event type of EvaluationEvent
 * @return void
 *
 */
private function createQuestion(event:EvaluationEvent):void 
{
	var oldQuestionListLength:int = 0 ;
	var newQuestionListLength:int  = 0 ;
	if(event.data != null)
	{
		CustomAlert.info("Question created successfully", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		oldQuestionListLength = questions.length;
		questions.addItem(event.data);
		qbSubcategoryVO.totalQns = questions.length;
		newQuestionListLength = oldQuestionListLength - questions.length;
		this.dispatchEvent(new UpdateQBTotalQuestionsEvent(UpdateQBTotalQuestionsEvent.QB_TOTAL_QNS,newQuestionListLength)) ;
		var tmpQuestions:ArrayCollectionExtended = new ArrayCollectionExtended;
		// Fix for Bug #11002
		QuizContext.copyDataBySequence(tmpQuestions, new ArrayCollectionExtended(questions.source));
		questions = tmpQuestions;	
		refreshHandler();
	}
	
	selectCheckBoxHeader(false);
}

/**
 * @private
 * Delegates calling the delete handler
 *
 * @return void
 *
 */
private function deleteQuestionbankQuestion():void 
{
	var selectedQuestions:ArrayCollection = new ArrayCollection(dataGridForQuestions.selectedItems);
	if (selectedQuestions.length == 0) 
	{
		//Fix for Bug#10942
		CustomAlert.error("Please select question(s) for deleting.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		return;
	} 
	else 
	{
		//Fix for Bug#16160
		CustomAlert.confirm("Do you want to delete this question(s)?", "Confirmation", confirmDeleteQuestionHandler, this);
	}
}

/**
 * @private
 * Handles the delete question event
 * @param event type of CloseEvent
 * @return void
 *
 */
private function confirmDeleteQuestionHandler(event:CloseEvent):void 
{
	if (event.detail == Alert.YES) 
	{
		deleteQuestions();
	}
}

/**
 * @private
 * Calls the remote method for deleting a question
 *
 * @return void
 *
 */
private function deleteQuestions():void 
{
	if(Log.isDebug()) log.debug("deleteSelectedQuestions");
	var selectedQuestions:ArrayCollection = new ArrayCollection(dataGridForQuestions.selectedItems);

	if (selectedQuestions.length == 0) 
	{
		CustomAlert.error("Please select one or more questions to delete and try again.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	qbQuestionHelperRO.deleteQbQuestions(selectedQuestions, ClassroomContext.userVO.userId,deleteQbQuestionsResultHandler);
}

/**
 * @private
 * Calls the showQuestionView method
 *
 * @return void
 *
 */
private function editQuestion():void 
{
	if (dataGridForQuestions.selectedItems.length != 1) 
	{
		CustomAlert.error("Please select one question for editing.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	showQuestionView(true);
}

/**
 * @private
 * Handler after updating question
 * @param event type of EvaluationEvent
 * @return void
 *
 */
private function updateQuestion(event:EvaluationEvent):void 
{
	if(event.data != null)
	{
		/** Variable to hold index */ 
		var index:int = dataGridForQuestions.selectedIndex;
		var qbQuestionVO:QbQuestionVO = event.data as QbQuestionVO;
		
		// Remove entry of updated question. 
		questions.removeItemAt(index);
		
		// Adding updated question into the same index. 
		questions.addItemAt(qbQuestionVO, index);
		refreshHandler();
		CustomAlert.info("Question updated successfully.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
		if(Log.isInfo()) log.info("Updated Question : \n" + qbQuestionVO.toString());
	}
}

/**
 * @protected
 * Click handler for data grid
 * @param event type of ListEvent
 * @return void
 *
 */
protected function dgItemClickHandler(event:ListEvent):void 
{
	if (event.columnIndex == 0) 
	{
		(event.itemRenderer as CheckBoxRenderer).dispatchEvent(new MouseEvent("click"));
	}
	event.stopPropagation();
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
	var col:CheckBoxHeaderColumn=dataGridForQuestions.columns[0];
	col.selected=value;
}
/**
 * 
 * @private
 * Function :searchFocusInHandler
 * FocusIn handler for txtSearch
 * @return void
 * 
 */
//Fix for Bug #11005
private function searchFocusInHandler():void
{
	txtSearch.setStyle("textAlign","left");
}
/**
 * 
 * @private
 * Function :searchFocusOutHandler
 * FocusOut handler for txtSearch
 * @return void
 * 
 */
//Fix for Bug #11005
private function searchFocusOutHandler():void
{
	questions.refresh();
	if(txtSearch.length == 0)
	{
		txtSearch.setStyle("textAlign","center");
	}
}