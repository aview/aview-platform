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
 * File			: AddQuestionPaperRandomQuestionsUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * AddQuestionPaperRandomQuestionsUIHandler acts as handler for AddQuestionPaperRandomQuestions.mxml
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.helper.QbQuestionHelper;
import edu.amrita.aview.core.evaluation.questionPaper.AddRandomQuestion;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;

/*
[Bindable]
/**
 * Used to display the random question in question paper question component
 
public var questionPaperVO:QuestionPaperVO = null;
*/

[Bindable]
/**
 * The object of QuestionPaperQuestionVO
 */
public var questionPaperQuestionVO:QuestionPaperQuestionVO=new QuestionPaperQuestionVO;

[Bindable]
/**
 * List of random questions
 */
private var qpRandomQuestions:ArrayCollection=new ArrayCollection;

/**
 * Used to call remote methods of QbQuestionHelper
 */
private var qbQuestionHelperRO:QbQuestionHelper;

/*
 * Used to check if the added random question is to be edited
private var isEdit:Boolean=false;
*/

/**
 * Constant for Editing Random Question title
 */
private const EDIT_RANDOM_QUESTION_TITLE : String = "Edit Random Question";

/**
 * Existing question paper questions from parent component 
 */
public var qpQuestions:ArrayCollection = null;

/**
 * The referenced question paper from parent component 
 */
public var questionPaperVO:QuestionPaperVO = null ;
/*
 * @public
 * Pops the AddRandomQuestion component for editing a question
 * Currently function not used
 * @return void
public function editRandomQuestion():void {
	var i:int;
	// At least a question has to be selected for editing
	if (dgRandomQuestions.selectedItems.length != 1) {
		CustomAlert.error("Please select one question for editing.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	randomQuestionComponent=AddRandomQuestion(PopUpManager.createPopUp(this, AddRandomQuestion, true));

	PopUpManager.centerPopUp(randomQuestionComponent);
	questionPaperQuestionVO=dgRandomQuestions.selectedItem as QuestionPaperQuestionVO;
	var tempAC:Object=randomQuestionComponent.cmbCategory.dataProvider;
	// Set the combobox for category as selected 
	if (tempAC != null) {
		for (i=0; i < tempAC.length; i++) {
			if (tempAC[i].qbCategoryId == questionPaperQuestionVO.qbCategoryId) {
				randomQuestionComponent.cmbCategory.selectedIndex=i;
				break;
			}
		}
		ClassroomContext.qpSubCategories=new ArrayCollection;
		ArrayCollectionUtil.copyData(ClassroomContext.qpSubCategories, ClassroomContext.quizSubCategories);
		ClassroomContext.qpSubCategories.filterFunction=filterByCategoryId;
		ClassroomContext.qpSubCategories.refresh();
		randomQuestionComponent.cmbSubCategory.dataProvider=ClassroomContext.qpSubCategories;
		tempAC=randomQuestionComponent.cmbSubCategory.dataProvider;

		// Set the combobox for subcategory as selected
		for (i=0; i < tempAC.length; i++) {
			if (tempAC[i].qbSubcategoryId == questionPaperQuestionVO.qbSubcategoryId) {
				randomQuestionComponent.cmbSubCategory.selectedIndex=i;
				break;
			}
		}

		tempAC=randomQuestionComponent.cmbDifficultyLevel.dataProvider;

		// Set the combobox for difficulty level as selected
		for (i=0; i < tempAC.length; i++) {
			if (tempAC[i].qbDifficultyLevelId == questionPaperQuestionVO.qbDifficultyLevelId) {
				randomQuestionComponent.cmbDifficultyLevel.selectedIndex=i;
				break;
			}
		}

		tempAC=randomQuestionComponent.cmbQuestionType.dataProvider;

		// Set the combobox for question type as selected
		for (i=0; i < tempAC.length; i++) {
			if (tempAC[i].qbQuestionTypeId == questionPaperQuestionVO.qbQuestionTypeId) {
				randomQuestionComponent.cmbQuestionType.selectedIndex=i;
				break;
			}
		}
	}

	randomQuestionComponent.txtInpNumeric.text=String(questionPaperQuestionVO.numRandomQuestions);
	randomQuestionComponent.title = EDIT_RANDOM_QUESTION_TITLE;
	randomQuestionComponent.txtInpMarks.text=String(questionPaperQuestionVO.marks);
	isEdit=true;
	randomQuestionComponent.btnSave.addEventListener(MouseEvent.CLICK, saveRandomQuestion);
}
*/

/**
 * @private
 * Sets the initial data like initialising the helper object
 *
 * @return void
 */
private function initAddQPRandomQuestions():void {
	qbQuestionHelperRO=new QbQuestionHelper();

	qpQuestions = new ArrayCollection ;
}

/*
 * @private
 * Used to remove this component
 *
 * @return void
 *
//PNCR: same function is defined in many files. Please check whether we can create a common function for that.
private function closeAddQuestionPaperRandomQuestions():void {
	ClassroomContext.qpSubCategories=null;
	PopUpManager.removePopUp(this);
}
*/

/**
 * @private
 * Pops the AddRandomQuestion component
 *
 * @return void
 *
 */
private function addRandomQuestion():void {	
	var randomQuestionComponent:AddRandomQuestion =new AddRandomQuestion();
	
	randomQuestionComponent.questionPaperVO  = ObjectUtil.copy(questionPaperVO) as QuestionPaperVO ;	
	
	ClassroomContext.qpSubCategories=new ArrayCollection;
	ArrayCollectionUtil.copyData(ClassroomContext.qpSubCategories, ClassroomContext.quizSubCategories);
	PopUpManager.addPopUp(randomQuestionComponent, this, true);
	PopUpManager.centerPopUp(randomQuestionComponent);		
	randomQuestionComponent.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , saveRandomQuestion) ;
}



/**
 * @private
 * Sets the random question into the list
 * @param event of type Event
 * @return void
 *
 */
private function saveRandomQuestion(event:EvaluationEvent):void {
	if(event.data)
	{		
		ArrayCollectionUtil.copyData(qpRandomQuestions , event.data as ArrayCollection) ;		
	}	
}


/**
 * @private
 * Deletes the random questions from the list
 *
 * @return void
 *
 */
private function deleteRandomQuestions():void {
/* Currently function not used */
	// Check if questions in datagrid are selected to be deleted
	// If no questions are selected , display an error message	
	if (dgRandomQuestions.selectedItems.length == 0) {
		CustomAlert.info("Select at least one question for deletion.", "Delete Random Question", null, this);
		return;
	}

	// Questions selected to be deleted 
	var selectedIndices:Array=dgRandomQuestions.selectedIndices;

	// Remove the selected question from the dataprovider of array collection
	for (var i:int=0; i < selectedIndices.length; i++) {
		qpRandomQuestions.removeItemAt(selectedIndices[i]);
	}

	// If there are no questions in the dataprovider for the datagrid
	// Uncheck the header column
	if (qpRandomQuestions.length == 0) {
		var col:CheckBoxHeaderColumn=dgRandomQuestions.columns[0];
		col.selected=false;
	}
}

/**
 * @private
 * Selects/deselects all questions in datagrid
 *
 * @return void
 *
 */
private function toggleSelection():void {
	var col:CheckBoxHeaderColumn=dgRandomQuestions.columns[0];
	// If the dataprovider for datagrid has no questions , do nothing
	if (qpRandomQuestions == null || qpRandomQuestions.length == 0) {
		return;
	}
	// Set the questions in the datagrid selected 
	//PNCR: use conditional operator
	if (col.selected) {
		dgRandomQuestions.selectedItems=qpRandomQuestions.toArray();
	} else {
		dgRandomQuestions.selectedItems=[];
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

protected function btnAddClickHandler(event:MouseEvent):void
{
	// Display an error if no random questions are selected to be added
	if (dgRandomQuestions.selectedItems.length == 0)
	{
		CustomAlert.error("Please select the questions to be added", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
	else
	{	
		/*   Fix for Bug #11346,#11990 :Start
		* To check duplicate entry
		* Random question with same Sub category , Difficulty Level, Question Type is not allowed
		*/
		
		/* Stores random questions selected to be added to question paper */
		var randomQuestions:ArrayCollection=new ArrayCollection(dgRandomQuestions.selectedItems);
		// Check for the values in random question for null and duplicate values
		for (var k:int=0; k < randomQuestions.length; k++)
		{
			// Set the difficulty level id to 0 , if null value found
			if (randomQuestions[k].qbDifficultyLevelId.toString() == QuizContext.NO_RESULT)
			{
				randomQuestions[k].qbDifficultyLevelId=0;
			}
			
			// Set the question type id to 0 , if null value found
			if (randomQuestions[k].qbQuestionTypeId.toString() == QuizContext.NO_RESULT)
			{
				randomQuestions[k].qbQuestionTypeId=0;
			}
			
			//Check if the newly added random questions already exists in the question paper questions
			for (var l:int=0; l < qpQuestions.length; l++)
			{
				if ((qpQuestions[l].patternType == QuizContext.PATTERN_TYPE_RANDOM) && (qpQuestions[l].qbSubcategoryId.toString() == randomQuestions[k].qbSubcategoryId.toString()) && (qpQuestions[l].qbDifficultyLevelId.toString() == randomQuestions[k].qbDifficultyLevelId.toString()) && (qpQuestions[l].qbQuestionTypeId.toString() == randomQuestions[k].qbQuestionTypeId.toString()))
				{
					CustomAlert.info("Question already exists in the question paper.", "Duplicate Question", null, this);
					randomQuestions.removeItemAt(k);
					k--;
					return;
				}
			}
		}
		// Concat the existing question paper questions and newly added random questions
		if (randomQuestions.length > 0)
		{
			qpQuestions=new ArrayCollection(qpQuestions.source.concat(randomQuestions.source));
		}
		closeAddQPRandomQuestions(qpQuestions) ;
	}
}
	
private function closeAddQPRandomQuestions(qpqList:ArrayCollection = null):void 
{
	ClassroomContext.qpSubCategories=null;
	this.dispatchEvent(new EvaluationEvent(EvaluationEvent.CREATE_OR_UPDATE,qpqList));
	PopUpManager.removePopUp(this);
}