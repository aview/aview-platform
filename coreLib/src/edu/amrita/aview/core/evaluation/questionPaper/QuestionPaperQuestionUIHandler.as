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
 * File			: QuestionPaperQuestionUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * QuestionPaperQuestionUIHandler acts as handler for QuestionPaperQuestion.mxml
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.event.UpdateQuestionPaperVOEvent;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperQuestionHelper;
import edu.amrita.aview.core.evaluation.questionPaper.AddQuestionPaperQuestions;
import edu.amrita.aview.core.evaluation.questionPaper.AddQuestionPaperRandomQuestions;
import edu.amrita.aview.core.evaluation.questionPaper.AddRandomQuestion;
import edu.amrita.aview.core.evaluation.questionPaper.QuestionPaperPreview;
import edu.amrita.aview.core.evaluation.vo.QbDifficultyLevelVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionTypeVO;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxDataGrid;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.DataGridEvent;
import mx.events.DataGridEventReason;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;
import mx.validators.NumberValidator;

import spark.components.TextInput;

[Bindable]
/**
 * 	Used to store details of question paper
 */
public var questionPaperVO:QuestionPaperVO=new QuestionPaperVO;

[Bindable]
/**
 * Stores all active question paper questions for a question paper
 */
private var qpQuestions:ArrayCollection=new ArrayCollection;

[Bindable]
/**
 * 	Used to store details of question paper question
 */
private var questionPaperQuestionVO:QuestionPaperQuestionVO;

[Bindable]
/**
 * Stores all subcategories , displayed in the datagrid .
 */
private var subCategories:ArrayCollection=new ArrayCollection;

[Bindable]
/**
 *	Stores all difficulty levels , displayed in the datagrid .
 */
private var levels:ArrayCollection;

[Bindable]
/**
 *	Stores all question types, displayed in the datagrid .
 */
private var questionTypes:ArrayCollection;

[Bindable]
/**
 *  Stores total nos. of random questions in a question paper
 */
private var randomQuestionCount:int;

[Bindable]
/**
 *	Stores total nos. of specific questions in a question paper
 */
private var specificQuestionCount:int;

[Bindable]
/**
 *	Stores total marks for a question paper
 */
private var totalMark:Number=0.0;

/**
 *	Used to call remote methods of QuestionPaperHelper
 */
private var questionPaperHelper:QuestionPaperHelper=new QuestionPaperHelper();

/**
 *	Used to call remote methods of QuestionPaperQuestionHelper
 */
private var questionPaperQuestionHelper:QuestionPaperQuestionHelper=new QuestionPaperQuestionHelper();

/**
 *	Used to store the questions that are deleted to avoid duplicate
 * question to be added before the question paper is saved
 */
private var removedQuestions:ArrayCollection=new ArrayCollection;

/**
 * Used to check if a question paper is validated or not
 */
private var flagForValidate:Boolean=false;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionPaper.QuestionPaperQuestionUIHandler.as");

/**
 * Constant for default value of question bank difficulty level name 
 */
private const DEFAULT_DIFFICULTY_LEVEL_NAME : String = "---Any Level---";
/**
 * Constant for default value of question bank Question type name 
 */
private const DEFAULT_QUESTION_TYPE_NAME : String = "---Any Type---";
/**
 * Constant for Invalid string error message 
 */
private const INVALID_STRING_ERROR_MESSAGE : String = "Enter a valid string";
/**
 * Constant for Editing Random Question title
 */
private const EDIT_RANDOM_QUESTION_TITLE : String = "Edit Random Question";
/**
 * Constant for Editing Specific Question title
 */
private const EDIT_SPECIFIC_QUESTION_TITLE : String = "Edit Specific Question";

/**
 * Sets the title for the component while creating a specific question paper question 
 */
private const CREATE_QUESTION_TITLE:String = "Add Questions to Question Paper - " ;
/**
 * @public
 * This function is used to set the initial data's for this component
 *
 * @return void
 */
public function initQPQ():void
{
	QuizContext.isValidated=false;
	questionPaperHelper=new QuestionPaperHelper();
	questionPaperQuestionHelper=new QuestionPaperQuestionHelper();
	if(Log.isDebug()) log.debug("QuestionPaperQuestions::init::");
	subCategories=new ArrayCollection;
	levels=new ArrayCollection;
	questionTypes=new ArrayCollection
	subCategories.removeAll();
	levels.removeAll();
	questionTypes.removeAll();
	ArrayCollectionUtil.copyData(subCategories, ClassroomContext.quizSubCategories);
	ArrayCollectionUtil.copyData(levels, ClassroomContext.quizDifficultyLevels);
	ArrayCollectionUtil.copyData(questionTypes, ClassroomContext.quizQuestionTypes);
	
	// Set the first entry in level array collection as '---Any Level---'
	if (QuizContext.getItemIndexByProperty(levels, "qbDifficultyLevelId", String(0)) == -1)
	{
		var level:QbDifficultyLevelVO=new QbDifficultyLevelVO;
		level.qbDifficultyLevelId=0;
		level.qbDifficultyLevelName = DEFAULT_DIFFICULTY_LEVEL_NAME;
		levels.addItemAt(level, 0);
	}
	// Set the first entry in type array collection as '---Any Type---'
	if (QuizContext.getItemIndexByProperty(questionTypes, "qbQuestionTypeId", String(0)) == -1)
	{
		var qtype:QbQuestionTypeVO=new QbQuestionTypeVO;
		qtype.qbQuestionTypeName=DEFAULT_QUESTION_TYPE_NAME;
		qtype.qbQuestionTypeId=0;
		questionTypes.addItemAt(qtype, 0);
	}
	
	ClassroomContext.questionPaperId=questionPaperVO.questionPaperId;
	questionPaperQuestionHelper.getAllActiveQuestionPaperQuestionsForQP(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,getAllActiveQuestionPaperQuestionsForQPResultHandler);
}

/**
 * @public
 * The result handler for deleting question paper questions
 *
 * @return void
 */
public function deleteQpqQuestionsResultHandler():void
{
	// selected questions array
	var selectedQuestions:Array=dgQPQuestions.selectedItems;
	
	// Loop variable
	var i:int;
	
	// Index of question
	var idx:int;	
	// Loop through the questions to be deleted 
	// Remove it from the list , and update the marks and nos.of questions
	for (i=0; i < selectedQuestions.length; i++)
	{
		idx=qpQuestions.getItemIndex(selectedQuestions[i]);
		qpQuestions.removeItemAt(idx);
	}
	calculateTotalQuestionsAndMarks();
	//Fix for Bug #19654
	if(questionPaperVO.isComplete==QuizContext.YES)
	{
		questionPaperVO.isComplete=QuizContext.NO;
	}
	//Fix for Bug #11369
	CustomAlert.info("Question Paper question(s) Deleted successfully", QuizContext.ALERT_TITLE_INFORMATION, null, this);
	//Fix for Bug#16096,16097,16101
	if(Log.isInfo()) log.info("deleteQuestions::removedQuestions.length::" + selectedQuestions.length);
	dgQPQuestions.selectedIndex=-1;
	
	// Uncheck the header column ,if there are no questions in datagrid
	if (qpQuestions.length == 0)
	{
		var col:CheckBoxHeaderColumn=dgQPQuestions.columns[0];
		col.selected=false;
	}
}
//Fix for Bug#16176,16177
public function deleteQpqQuestionsFaultHandler(event:FaultEvent):void
{
	if (event.fault.rootCause && event.fault.rootCause.hasOwnProperty("message") && event.fault.rootCause.message)
	{
		CustomAlert.info(event.fault.rootCause.message);
	}
	else
	{
		CustomAlert.info(event.fault.faultString);
	}
}

/**
 * @public
 * The result handler for validate function
 * @param event type of ResultEvent
 * @return void
 */
public function validateQuestionPaperResultHandler(event:ResultEvent):void
{
	if(event.result != null)
	{	
		QuizContext.isValidated= event.result as Boolean ;
		CustomAlert.info("Validation Success.", "Validate question paper", validateVisibleHandler, this);
		questionPaperQuestionHelper.getAllActiveQuestionPaperQuestionsForQP(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,getAllActiveQuestionPaperQuestionsForQPResultHandler);
	}
}

/**
 * @public
 * The fault handler for validation
 * @param event type of FaultEvent
 * @return void
 */
public function validateQuestionPaperFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionPaper::QuestionPaperQuestionUIHandler::validateQuestionPaperFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	// Fault message 
	var faultMessage:String=event.fault.faultString;
	
	//PNCR: use Switch case instead of nested if.
	// Display the error if current total marks is not equal to max. total marks
	if ((faultMessage.indexOf("Current total marks is not equal", 0)) != -1)
	{
		//Fix for Bug #11375
		CustomAlert.error("Current total marks is not equal to Max. total marks", "Information", validateVisibleHandler, this);
	}
	
	// Display error if question paper name is null
	else if ((faultMessage.indexOf("Question paper name can not", 0)) != -1)
	{
		//Fix for Bug #11375
		CustomAlert.error("Question paper name can not be blank", "Information", validateVisibleHandler, this);
	}
	
	// Display error if negative or zero value is found for max total marks
	else if ((faultMessage.indexOf("Invalid integer value for Max", 0)) != -1)
	{
		//Fix for Bug #11375
		CustomAlert.error("Invalid integer value for Max. total marks.", "Information", validateVisibleHandler, this);
	}
	
	// Display error if specific and random questions are same
	else if ((faultMessage.indexOf("Specific and Random questions cannot be same", 0)) != -1)
	{
		//Fix for Bug #11375
		CustomAlert.error("Sorry, not enough questions in database. ", "Information", validateVisibleHandler, this);
	}
	
	// Display error if enough questions are not there in database for random type question
	else if ((faultMessage.indexOf("Sorry, Sufficient questions are not available in the question bank to generate Random Questions.", 0)) != -1)
	{
		//Fix for Bug #11375
		CustomAlert.error("Sorry, Sufficient questions are not available in the question bank to generate Random Questions.", "Information", validateVisibleHandler, this);
	}
	// Update the question paper list for display
	else
	{		
		questionPaperQuestionHelper.getAllActiveQuestionPaperQuestionsForQP(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,getAllActiveQuestionPaperQuestionsForQPResultHandler);
		
	}
}

/**
 * @public
 * The result handler for getAllActiveQuestionPaperQuestionsForQP method
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQuestionPaperQuestionsForQPResultHandler(event:ResultEvent):void
{
	if(event.result != null)
	{
		var result:ArrayCollection = event.result as ArrayCollection ;
		if(Log.isInfo()) log.info("getAllActiveQuestionPaperQuestions_resultHandler:: result::" + result);		
		
		specificQuestionCount=0;
		randomQuestionCount=0;
		totalMark=0.0;
		qpQuestions=result;
		txtInpMaxMarks.text=(questionPaperVO.maxTotalMarks).toString();
		totalMark=questionPaperVO.currentTotalMarks;
		calculateTotalQuestionsAndMarks();
	}
}

/**
 * @public
 * The fault handler for save question paper method
 * @param event type of FaultEvent
 * @return void
 *
 */
public function saveQuestionPaperFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionPaper::QuestionPaperQuestionUIHandler::saveQuestionPaperFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	// The fault message
	var faultMessage:String=event.fault.faultString;
	
	// Display error , if constraint fails for any field in the database
	if ((faultMessage.indexOf("CONSTRAINT `qz_ques_qp_ques_id`", 0)) != -1)
	{
		CustomAlert.error("Please add some other question , this question is already added to quiz", "SaveQuestionPaper", validateVisibleHandler, this);
	}
	
	// Display error if a duplicate entry is found
	else if ((faultMessage.indexOf("Duplicate entry", 0)) != -1)
	{
		//Fix for Bug #11459
		CustomAlert.error("Question already exists in the question paper.", QuizContext.ALERT_TITLE_INFORMATION, validateVisibleHandler, this);
	}
	
	// Display error , for any other unhandled error
	else
	{
		CustomAlert.error(faultMessage, "Error", null, this);
	}
	questionPaperQuestionHelper.getAllActiveQuestionPaperQuestionsForQP(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,getAllActiveQuestionPaperQuestionsForQPResultHandler);
}

/**
* @public
* The result handler for saving question paper
* @param event type of ResultEvent
* @return void
 */
public function saveQuestionPaperResultHandler(event:ResultEvent):void
{
	if(event.result == null)
	{
		CustomAlert.error("Failed to update question paper.", "UpdateQuestionPaper", null, this);
	}
	else
	{
		// Stores question paper questions temporarily
		var tempAC:ArrayCollection;
		
		// Temporary Value Object
		var tempQpq:QuestionPaperQuestionVO;
		
		// Header column 
		var col:CheckBoxHeaderColumn;
		//Fix for Bug#16096,16097,16101
		//removedQuestions.source=new Array();			
		questionPaperVO=event.result as QuestionPaperVO;
		this.dispatchEvent(new UpdateQuestionPaperVOEvent(UpdateQuestionPaperVOEvent.TREE_UPDATED, questionPaperVO));
		tempAC=questionPaperVO.questionPaperQuestions;
		qpQuestions.source=new Array();
		col=dgQPQuestions.columns[0];
		col.selected=false;
		for (var i:int=0; i < tempAC.length; i++)
		{
			tempQpq=tempAC[i];
			qpQuestions.addItem(tempQpq);
		}
		
		if (flagForValidate)
		{			
			flagForValidate=false;
			questionPaperHelper.validateQuestionPaper(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,validateQuestionPaperResultHandler,validateQuestionPaperFaultHandler);	
		}
		else
		{
			CustomAlert.info("Question paper updated successfully.",QuizContext.ALERT_TITLE_INFORMATION , saveVisibleHandler, this);
			txtInpQuestionPaperName.text=questionPaperVO.questionPaperName;
			txtInpMaxMarks.text=String(questionPaperVO.maxTotalMarks);						
		}
		
	}
}
/*
 * @public
 * The result handler for saving question paper
 * @param event type of ResultEvent
 * @return void
public function saveQuestionPaperResultHandler(event:ResultEvent):void
{	
	// Stores question paper questions temporarily
	var tempAC:ArrayCollection;
	
	// Temporary Value Object
	var tempQpq:QuestionPaperQuestionVO;
	
	// Header column 
	var col:CheckBoxHeaderColumn;
	// Validate the saved question paper
	if (flagForValidate)
	{
		// Loop variable
		var i:int;
		flagForValidate=false;
		// Display error , if the question paper failed to be saved
		// Else validate the paper
		if (event.result == null)
		{
			CustomAlert.error("Failed to update question paper.", "UpdateQuestionPaper", null, this);
		}
		else
		{
			removedQuestions.source=new Array();			
			questionPaperVO=event.result as QuestionPaperVO;
			this.dispatchEvent(new UpdateQuestionPaperVOEvent(UpdateQuestionPaperVOEvent.TREE_UPDATED, questionPaperVO));
			tempAC=questionPaperVO.questionPaperQuestions;
			qpQuestions.source=new Array();
			col=dgQPQuestions.columns[0];
			col.selected=false;
			for (i=0; i < tempAC.length; i++)
			{
				tempQpq=tempAC[i];
				qpQuestions.addItem(tempQpq);
			}
			questionPaperHelper.validateQuestionPaper(this, questionPaperVO.questionPaperId, ClassroomContext.userVO.userId);
			return;
		}
	}
	// Display the result after saving,validating the question paper
	else
	{
		QuizContext.isValidated=true;
		// If no result is returned , display saving question paper failed
		// Else display the successfully saved the question paper
		if (event.result == null)
		{
			CustomAlert.error("Failed to update question paper.", "UpdateQuestionPaper", null, this);
		}
		else
		{
			CustomAlert.info("Question paper updated successfully.",QuizContext.ALERT_TITLE_INFORMATION , saveVisibleHandler, this);
			
			questionPaperVO=event.result as QuestionPaperVO;
			this.dispatchEvent(new UpdateQuestionPaperVOEvent(UpdateQuestionPaperVOEvent.TREE_UPDATED, questionPaperVO));
			tempAC=questionPaperVO.questionPaperQuestions;
			qpQuestions.source=new Array();
			col=dgQPQuestions.columns[0];
			col.selected=false;
			// Populate the question paper questions , freshly after updating the question paper
			for (i=0; i < tempAC.length; i++)
			{
				tempQpq=tempAC[i];
				qpQuestions.addItem(tempQpq);
			}
			txtInpQuestionPaperName.text=questionPaperVO.questionPaperName;
			txtInpMaxMarks.text=String(questionPaperVO.maxTotalMarks);
						
			removedQuestions=new ArrayCollection;
		}
		
	}

}
*/


/**
 * @private
 * Used to toggle between selecting/deselecting all questions in the datagrid
 *
 * @return void
 */
private function toggleSelection():void
{
	/* Instance of checkbox header column */
	var col:CheckBoxHeaderColumn=dgQPQuestions.columns[0];
	// Do nothing , if there are no questions in the datagrid
	if (qpQuestions == null)
	{
		return;
	}
	// Show the questions as selected as per the dataprovider of datagrid
	if (col.selected)
	{
		dgQPQuestions.selectedItems=qpQuestions.toArray();
	}
	//  No effect , if no questions have been selected
	else
	{
		dgQPQuestions.selectedItems=[];
	}
}

/**
 * @private
 * Used to update the question paper name
 *
 * @return void
 */
private function updateQPName():void
{
	// Remove the unwanted space, empty strings in the question paper name
	if (StringUtil.trim(txtInpQuestionPaperName.text) == null || StringUtil.trim(txtInpQuestionPaperName.text) == QuizContext.EMPTY_STRING)
	{
		txtInpQuestionPaperName.text=questionPaperVO.questionPaperName;
		return;
	}
	questionPaperVO.questionPaperName=StringUtil.trim(txtInpQuestionPaperName.text);
	questionPaperVO.modifiedByUserId=ClassroomContext.userVO.userId;	
}

/**
 * @private
 * Used to update the max marks
 *
 * @return void
 *
 */
private function updateMaxMarks():void
{
	/* Marks for the question paper */
	var marks:Number=Number(txtInpMaxMarks.text);
	
	/* Validates numbers */
	var v:NumberValidator=new NumberValidator;
	
	/* Stores the result of validating marks */
	var vResultForMarks:ValidationResultEvent=v.validate(marks);
	var newValue:String;
	var i:int;
	newValue=txtInpQuestionPaperName.text;
	// Check if the validation has resulted in invalid value for marks or negative value for marks
	// Display the appropriate error for it
	if ((vResultForMarks.type == ValidationResultEvent.INVALID) || (marks <= 0))
	{
		CustomAlert.error("Invalid value for marks.", "Validation", null, this);
		txtInpMaxMarks.text=String(questionPaperVO.maxTotalMarks);
		return;
	}
	questionPaperVO.maxTotalMarks=Number(txtInpMaxMarks.text);
	questionPaperVO.modifiedByUserId=ClassroomContext.userVO.userId;	
}

/**
 * @private
 * This function retrieves the number of random questions
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getNumRandomQuestions(oItem:Object, iCol:int):String
{
	// Return the nos of random question , if the pattern type is 'Random'
	if (oItem.patternType == QuizContext.PATTERN_TYPE_RANDOM)
	{
		return String(oItem.numRandomQuestions);
	}
	return QuizContext.NO_RESULT;
}

/**
 * @private
 * This function retreives the question text
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getQuestionText(oItem:Object, iCol:int):String
{
	if(Log.isInfo()) log.info("getQuestionText::oItem.qbQuestionId::" + oItem.qbQuestionId);
	
	// Index of the question
	var index:int=QuizContext.getItemIndexByProperty(qpQuestions, "qbQuestionId", oItem.qbQuestionId);

	// If the index of the question is found , return its question text
	if (index != -1)
	{
		return qpQuestions[index].questionText;
	}
	
	return QuizContext.EMPTY_STRING;
}

/**
 * @private
 * This function retrieves the category name
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getCategoryName(oItem:Object, iCol:int):String
{
	// Category id
	var qbCategoryId:int;
	qbCategoryId=oItem.qbCategoryId;
	
	// Check for the category id on oItem , and return its category name
	for (var i:int=0; i < ClassroomContext.quizCategories.length; i++)
	{
		if (qbCategoryId == ClassroomContext.quizCategories[i].qbCategoryId)
		{
			oItem.qbCategoryName=ClassroomContext.quizCategories[i].qbCategoryName;
			oItem.qbCategoryId=ClassroomContext.quizCategories[i].qbCategoryId;
			break;
		}
	}
	
	return oItem.qbCategoryName;
}

/**
 * @private
 * This function retreives the subcategory name
 * @param oItem type of Object
 * @param iCol int
 * @return String
 *
 */
private function getSubcategoryName(oItem:Object, iCol:int):String
{
	// subcategory id 
	var qbSubcategoryId:int;
	qbSubcategoryId=oItem.qbSubcategoryId;
	// Return the subcategory name , for the respective subcategory id
	for (var i:int=0; i < subCategories.length; i++)
	{
		if (qbSubcategoryId == subCategories[i].qbSubcategoryId)
		{
			oItem.qbSubcategoryName=subCategories[i].qbSubcategoryName;
			oItem.qbSubcategoryId=subCategories[i].qbSubcategoryId;
			break;
		}
	}
	
	return oItem.qbSubcategoryName;
}

/**
 * @private
 * This retrieves the difficulty level name
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getDifficultyLevel(oItem:Object, iCol:int):String
{
	
	var qbDifficultyLevelId:int;
	qbDifficultyLevelId=oItem.qbDifficultyLevelId;
	// Return the difficulty level name , for the respective difficulty level id
	for (var i:int=0; i < levels.length; i++)
	{
		if (qbDifficultyLevelId == levels[i].qbDifficultyLevelId)
		{
			oItem.qbDifficultyLevelName=levels[i].qbDifficultyLevelName;
			oItem.qbDifficultyLevelId=levels[i].qbDifficultyLevelId;
			break;
		}
	}
	
	return oItem.qbDifficultyLevelName;
}

/**
 * @private
 * Retreives the question type name
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getQuestionType(oItem:Object, iCol:int):String
{
	// question type id
	var qbQuestionTypeId:int;
	qbQuestionTypeId=oItem.qbQuestionTypeId;
	// Return the question type name , for the respective question type id
	for (var i:int=0; i < questionTypes.length; i++)
	{
		if (qbQuestionTypeId == questionTypes[i].qbQuestionTypeId)
		{
			oItem.qbQuestionTypeName=questionTypes[i].qbQuestionTypeName;
			oItem.qbQuestionTypeId=questionTypes[i].qbQuestionTypeId;
			break;
		}
	}
	
	return oItem.qbQuestionTypeName;
}

/**
 * @private
 * Draws the row color for the row in datagrid that has invalid data
 * @param item type of Object
 * @param rowIndex type of int
 * @param dataIndex type of int
 * @param color type of uint
 * @return uint
 *
 */

private function calculateRowColor(item:Object, rowIndex:int, dataIndex:int, color:uint):uint
{
	// Return the color for the row which has specific pattern type
	if (item.patternType == QuizContext.PATTERN_TYPE_SPECIFIC)
	{
		return color;
	}
	
	// Returns red color for invalid nos. of questions and marks
	if (item.invalidNumQns || item.invalidMarks)
	{
		return 0xff0000;
	}
	
	//Returns blue color for a duplicate data
	else if (item.isDuplicate)
	{
		return 0x0000ff;
	}
	else
	{
		return color;
	}
}

/**
 * @private
 * Pops the component for creating specific question
 *
 * @return void
 */
private function addQPQuestions():void
{
	var addQPQuestionsnView:AddQuestionPaperQuestions;
	addQPQuestionsnView=AddQuestionPaperQuestions(PopUpManager.createPopUp(this, AddQuestionPaperQuestions, true));	
	ArrayCollectionUtil.copyData(addQPQuestionsnView.qpqList , qpQuestions) ;
	addQPQuestionsnView.questionPaperVO = ObjectUtil.copy(questionPaperVO) as QuestionPaperVO ;
	addQPQuestionsnView.title = CREATE_QUESTION_TITLE +questionPaperVO.questionPaperName ;
	addQPQuestionsnView.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , addQuestions) ;	
	PopUpManager.centerPopUp(addQPQuestionsnView);
}

/**
 * @private
 * Pops the component for creating a new random question
 *
 * @return void
 */
private function addQPRandomQuestions():void
{
	var addQpRandomQuestionView:AddQuestionPaperRandomQuestions;
	addQpRandomQuestionView=AddQuestionPaperRandomQuestions(PopUpManager.createPopUp(this, AddQuestionPaperRandomQuestions, true));	
	ArrayCollectionUtil.copyData(addQpRandomQuestionView.qpQuestions , qpQuestions) ;
	addQpRandomQuestionView.questionPaperVO = ObjectUtil.copy(questionPaperVO) as QuestionPaperVO ;
	addQpRandomQuestionView.title = CREATE_QUESTION_TITLE +questionPaperVO.questionPaperName ;
	addQpRandomQuestionView.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , addRandomQuestions) ;
	PopUpManager.centerPopUp(addQpRandomQuestionView);
}

/**
 * @private
 * Handles creating new specific question :
 * No questions selected for saving
 * Avoid creating duplicate question
 * @param event type of EvaluationEvent
 * @return void
 */
private function addQuestions(event:EvaluationEvent):void
{
	if(event.data)
	{
		var tempAC:ArrayCollection = new ArrayCollection ;
		var qpqVO:QuestionPaperQuestionVO ;
		ArrayCollectionUtil.copyData(tempAC ,event.data as ArrayCollection) ;
		dgQPQuestions.invalidateList();
		for(var i:int = 0 ; i < tempAC.length ; i++)
		{
			qpqVO = tempAC[i] as QuestionPaperQuestionVO ;	
			totalMark += qpqVO.marks;			
		}			
		qpQuestions.removeAll() ; 
		ArrayCollectionUtil.copyData(qpQuestions , tempAC) ;
	}
	calculateTotalQuestionsAndMarks();		
	//Fix for Bug#16096,16097,16101
   //checkRandomQuestions();
}

/**
 * @private
 * Handle creating a random question
 * No question is selected
 * Avoid adding duplicate question
 * @param event type of EvaluationEvent
 * @return void
 */
private function addRandomQuestions(event:EvaluationEvent):void
{
	if(event.data)
	{
		var tempAC:ArrayCollection = new ArrayCollection ;
		var qpqVO:QuestionPaperQuestionVO ;
		ArrayCollectionUtil.copyData(tempAC ,event.data as ArrayCollection) ;
		dgQPQuestions.invalidateList();	
		qpQuestions.removeAll() ; 
		ArrayCollectionUtil.copyData(qpQuestions , tempAC) ;
	}
		//Fix for Bug #11346,#11990 :End
		calculateTotalQuestionsAndMarks();				
		//Fix for Bug#16096,16097,16101
		//checkRandomQuestions();
}

/**
 * @private
 * Check for newly random questions and the deleted random questions
 * and remove the questions which are same , and allow the question to add
 * only after saving question paper  , to avoid constraint violation exception
 *
 * @return void
 */
private function checkRandomQuestions():void
{
	// Check the random questions , only if length is not equal to zero
	if (removedQuestions.length != 0)
	{
		// Check between removed and newly added question
		for (var i:int=0; i < qpQuestions.length; i++)
		{
			for (var j:int=0; j < removedQuestions.length; j++)
			{
				if (qpQuestions[i].qbQuestionId == removedQuestions[j].qbQuestionId)
				{
					//Fix for Bug #11459
					CustomAlert.error("Question already exists in the question paper,before adding new question save the question Paper.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
					qpQuestions.removeItemAt(i);
					break;
				}
			}
		}
	}

}

/**
 * @private
 * The click handler for edit button
 *
 * @return void
 */
private function editQPQuestion():void
{
	// Display an error , if no question is selected for editing
	if (dgQPQuestions.selectedItems.length != 1)
	{
		CustomAlert.error("Please select one question for editing.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		dgQPQuestions.selectedIndex=-1;
		
		/* Instance of checkbox header column */
		var col:CheckBoxHeaderColumn=dgQPQuestions.columns[0];
		col.selected=false;
		dgQPQuestions.invalidateList();
		return;
	}
	
	var addRandomQuestionObj:AddRandomQuestion ;
	questionPaperQuestionVO=dgQPQuestions.selectedItem as QuestionPaperQuestionVO;
	questionPaperQuestionVO.questionPaper = questionPaperVO ;
	// For editing a question , it must be saved first ,so that it has saved value for that 
	// question paper question id
	if (questionPaperQuestionVO.questionPaperQuestionId > 0)
	{
		addRandomQuestionObj=AddRandomQuestion(PopUpManager.createPopUp(this, AddRandomQuestion, true));
		
		PopUpManager.centerPopUp(addRandomQuestionObj);		
		
		// Call the edit method by setting randomOrSpecific as 'Specific'
		if (dgQPQuestions.selectedItem.patternType == QuizContext.PATTERN_TYPE_SPECIFIC)
		{
			addRandomQuestionObj.title = EDIT_SPECIFIC_QUESTION_TITLE;
			addRandomQuestionObj.enableRandomQuestionComponent(false);
			questionPaperQuestionVO.patternType = QuizContext.PATTERN_TYPE_SPECIFIC ;
		}
		// Call the edit method by setting randomOrSpecific as 'Random'
		else
		{
			addRandomQuestionObj.title = EDIT_RANDOM_QUESTION_TITLE;
			addRandomQuestionObj.enableRandomQuestionComponent(true);
			questionPaperQuestionVO.patternType = QuizContext.PATTERN_TYPE_RANDOM ;
		}
		
		addRandomQuestionObj.questionPaperQuestionVO = ObjectUtil.copy(questionPaperQuestionVO) as QuestionPaperQuestionVO ;
		addRandomQuestionObj.editQPQ() ;	
		ArrayCollectionUtil.copyData(addRandomQuestionObj.qpQuestions , qpQuestions) ;
		addRandomQuestionObj.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , saveRandomQuestion) ;		
	}
	else
	{
		CustomAlert.info("Please save the question paper before editing");
		return;
	}
	
}

/*
 * @private
 * Delegates the call to appropriate function as per random or specific
 * question selected
 * @return void
 
private function editQPQ():void
{	
	 var addRandomQuestionObj:AddRandomQuestion ;
	questionPaperQuestionVO=dgQPQuestions.selectedItem as QuestionPaperQuestionVO;
	questionPaperQuestionVO.questionPaper = questionPaperVO ;
	// For editing a question , it must be saved first ,so that it has saved value for that 
	// question paper question id
	if (questionPaperQuestionVO.questionPaperQuestionId > 0)
	{
		addRandomQuestionObj=AddRandomQuestion(PopUpManager.createPopUp(this, AddRandomQuestion, true));
		
		PopUpManager.centerPopUp(addRandomQuestionObj);		
		// For random question all the fields are enabled
		if (randomOrSpecific.indexOf(QuizContext.PATTERN_TYPE_SPECIFIC) == -1) // if its not specific question
		{
			addRandomQuestionObj.title = EDIT_RANDOM_QUESTION_TITLE;
			addRandomQuestionObj.enableRandomQuestionComponent(true);
			questionPaperQuestionVO.patternType = QuizContext.PATTERN_TYPE_RANDOM ;
		}
		// For specific question only the mark field is enabled
		else
		{
			addRandomQuestionObj.title = EDIT_SPECIFIC_QUESTION_TITLE;
			addRandomQuestionObj.enableRandomQuestionComponent(false);
			questionPaperQuestionVO.patternType = QuizContext.PATTERN_TYPE_SPECIFIC ;
		}
		addRandomQuestionObj.questionPaperQuestionVO = ObjectUtil.copy(questionPaperQuestionVO) as QuestionPaperQuestionVO ;
		addRandomQuestionObj.editQPQ() ;	
		ArrayCollectionUtil.copyData(addRandomQuestionObj.qpQuestions , qpQuestions) ;
		addRandomQuestionObj.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , saveRandomQuestion) ;		
	}
	else
	{
		CustomAlert.info("Please save the question paper before editing");
		return;
	}
}
*/

/**
 * @private
 * Adds the random questions to the question paper vo object , before saving the question paper
 * @param event type of Event
 * @return void
 *
 */
private function saveRandomQuestion(event:EvaluationEvent):void
{
	if(event.data)
	{	
		dgQPQuestions.invalidateList();	
		qpQuestions.removeAll() ; 
		ArrayCollectionUtil.copyData(qpQuestions , event.data as ArrayCollection) ;
		//Fix for Bug#16831
		CustomAlert.info("Question updated successfully");
	}	
}



/**
 * @private
 * Used to filter the categories to search for a given category
 * @param item type of Object
 * @return Boolean
 *
 */
private function filterByCategoryId(item:Object):Boolean
{
	// Return true , if the category searched for is found
	if (questionPaperQuestionVO.qbCategoryId == item.qbCategoryId)
	{
		return true;
	}
	if (item.qbSubcategoryId == -1)
	{
		return true;
	}
	return false;
}

/**
 * @private
 * Calls the handler for deleting question paper question
 *
 * @return void
 */
private function deleteQPQuestion():void
{
	/* selected question paper questions */
	var selectedQuestions:ArrayCollection=new ArrayCollection(dgQPQuestions.selectedItems);
	
	// Display an alert , if no question is selected for deleting
	if (selectedQuestions.length == 0)
	{		
		//Fix for Bug #11369
		CustomAlert.info("Please select question(s) for deleting.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	// Else call the handler for deleting questions
	CustomAlert.confirm("Do you want to delete this question(s)?", "Confirmation", delQuestionHandler, this);
}

/**
 * @private
 * Handler that adds the deleted questions to the list
 * @param event type of CloseEvent
 * @return void
 */
private function delQuestionHandler(event:CloseEvent):void
{
	// User confirms deleting questions
	if (event.detail == Alert.YES)
	{		
			/* selected question paper questions*/
			var selectedQuestions:ArrayCollection=new ArrayCollection(dgQPQuestions.selectedItems);	
			if(Log.isInfo()) log.info("deleteQuestions::dg.selectedItems.length::" + dgQPQuestions.selectedItems.length);
		
			// Loop through the questions that are selected to be deleted
			
			for (var i:int=0; i < selectedQuestions.length; i++)
			{
				var question:QuestionPaperQuestionVO=selectedQuestions[i] as QuestionPaperQuestionVO;				
				
				// Add questions to removedQuestions list , only if id is non zero
				//Fix for Bug#16096,16097,16101:Start
				/*if (question.questionPaperQuestionId != 0)
				{
					if (removedQuestions == null)
					{
						removedQuestions=new ArrayCollection;
					}
					removedQuestions.addItem(question);
					
				}*/
				//Fix for Bug#16096,16097,16101:End
			}
			calculateTotalQuestionsAndMarks();
			//Fix for Bug#16176,16177
			questionPaperQuestionHelper.deleteQpqQuestions(selectedQuestions, ClassroomContext.userVO.userId,deleteQpqQuestionsResultHandler,deleteQpqQuestionsFaultHandler);		
	}
}

/**
 * @private
 * Calculate total questions and marks for specific and random
 *
 * @return void
 */
private function calculateTotalQuestionsAndMarks():void
{
	/* Total marks */
	var runningTotal:Number=0.0;
	specificQuestionCount=0;
	randomQuestionCount=0;
	
	// Loop through the list of questions
	for (var i:int=0; i < qpQuestions.length; i++)
	{
		if(Log.isDebug()) log.debug("calculateTotal::qpQuestions[i]::" + qpQuestions[i]);
		// Calculate the total marks and nos. of questions for 'Specific' pattern type
		if (qpQuestions[i].patternType == QuizContext.PATTERN_TYPE_SPECIFIC)
		{
			runningTotal+=qpQuestions[i].marks;
			specificQuestionCount++;
		}
		// Calculate the total marks and nos. of questions for 'Random' pattern type
		else if (qpQuestions[i].patternType == QuizContext.PATTERN_TYPE_RANDOM)
		{
			runningTotal+=qpQuestions[i].marks;
			randomQuestionCount=randomQuestionCount + qpQuestions[i].numRandomQuestions;
		}
	}
	lblNumberOfRandomQuestions.text=String(randomQuestionCount);
	lblNumberOfSpecficQuestions.text=String(specificQuestionCount);
	lblTotalQuestions.text=String(randomQuestionCount + specificQuestionCount);
	if(Log.isDebug()) log.debug("calculateTotal::runningTotal::" + runningTotal);
	questionPaperVO.currentTotalMarks=runningTotal;
	questionPaperVO.totalQns = randomQuestionCount + specificQuestionCount;
	totalMark=runningTotal;
}

/**
 * @private
 * Delegates the save question paper function
 *
 * @return void
 */
private function validateQuestionPaper():void
{	
	//Fix for Bug #11319
	setValidateButtonEnabled(false);
	flagForValidate=true;
	saveQuestionPaper();
}

/**
 * @private
 * The close handler for successful validation
 * @param event type of CloseEvent
 * @return void
 */
private function validateVisibleHandler(event:CloseEvent):void
{	
	//Fix for Bug #11319
	setValidateButtonEnabled(true);
	setSaveButtonEnabled(true);
}

/**
 * @private
 * Sets whether the question paper is complete or not , calculates the total questions and marks
 *
 * @return void
 */
private function saveQuestionPaper():void
{
	//Fix for Bug #11319
	setSaveButtonEnabled(false);
	
	// Remove all questions from question paper , before saving the edited/new questions
	if (questionPaperVO.questionPaperQuestions != null)
	{
		questionPaperVO.questionPaperQuestions.removeAll();
	}

	// Loop through the list of questions to find duplicate random questions
	for (var i:int=0; i < qpQuestions.length; i++)
	{
		if ((qpQuestions[i].patternType == QuizContext.PATTERN_TYPE_RANDOM) && (qpQuestions[i].isDuplicate))
		{
			CustomAlert.error("Failed to save question paper.\nRemove duplicate random question specification and try again.", "SaveQuestionPaper", null, this);			
			//Fix for Bug #11319
			setSaveButtonEnabled(true);
			setValidateButtonEnabled(true);
			return;
		}
		questionPaperVO.addQuestionPaperQuestion(qpQuestions[i]);
	}
	
	// If maxTotalMarks is equal to currentTotalMarks , set the question paper as 'complete'
	questionPaperVO.isComplete = (questionPaperVO.maxTotalMarks == questionPaperVO.currentTotalMarks) ? QuizContext.YES : QuizContext.NO;
	calculateTotalQuestionsAndMarks();
	questionPaperHelper.saveQuestionPaper(questionPaperVO, ClassroomContext.userVO.userId,saveQuestionPaperResultHandler,saveQuestionPaperFaultHandler);
}

/**
 * @private
 * Pops the preview question paper component
 *
 * @return void
 */
private function previewQuestionPaper():void
{
	// Display an error if the question paper is incomplete , before showing the preview
	if (questionPaperVO.isComplete == QuizContext.NO)
	{
		//Fix for Bug #11375
		CustomAlert.error("The selected question paper is not valid, Please validate.", "Information", null, this);
		return;
	}
	var questionPaperPreview:QuestionPaperPreview =QuestionPaperPreview(PopUpManager.createPopUp(this, QuestionPaperPreview, true));
	questionPaperPreview.questionPaperVO=questionPaperVO;
	questionPaperPreview.width=700;
	questionPaperPreview.height=600;
	PopUpManager.centerPopUp(questionPaperPreview);
}




/**
 * @private
 * Sets the enabled property true for save button
 * @param event type of CloseEvent
 * @return void
 */
private function saveVisibleHandler(event:CloseEvent):void
{	
	//Fix for Bug #11319
	setSaveButtonEnabled(true);
}

/**
 * @private
 * It enables or disables the save button
 * @param flag type of Boolean
 * @return void
 *
 */
private function setSaveButtonEnabled(flag:Boolean):void
{
	btnSave.enabled=flag;
}

/**
 * @private
 * It enables or disables the validate button
 * @param flag type of Boolean
 * @return void
 */
private function setValidateButtonEnabled(flag:Boolean):void
{
	btnValidate.enabled=flag;
}

/**
 * @private
 * Used to get the column number for datagrid
 * @param oItem type of Object
 * @param iCol type of Number
 * @return String
 * 
 */
private function getSerialNo(oItem:Object, iCol:Number):String
{
	var iIndex:int=qpQuestions.getItemIndex(oItem) + 1;
	return String(iIndex);
}
