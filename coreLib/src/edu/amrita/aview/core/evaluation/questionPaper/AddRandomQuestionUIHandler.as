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
 * File			: AddRandomQuestionUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 *  AddRandomQuestionUIHandler acts as handler for AddRandomQuestion.mxml
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.Evaluation;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.vo.QbCategoryVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

[Bindable]
/**
 * list of categories
 */
private var categories:ArrayCollection;

/**
 * Stores the question paper question when a qpq is edited 
 */
public var questionPaperQuestionVO:QuestionPaperQuestionVO = null;

/**
 * List of random questions 
 */
private var qpRandomQuestions:ArrayCollection ;

/**
 * The question paper referenced for adding random /editing (specific,random) 
 */
public var questionPaperVO:QuestionPaperVO = null ;

/**
 * Exisiting list of question paper questions for the selected question paper
 */
public var qpQuestions:ArrayCollection ; 
/**
 * @private
 * Sets the initial data for the component
 * @param event
 * @return void
 *
 */
private function initAddRandomQuestion(event:FlexEvent):void {
	lblCategory.setFocus();
	categories=new ArrayCollection();
	ArrayCollectionUtil.copyData(categories, ClassroomContext.quizCategories);
	
	cmbCategory.selectedIndex=-1;
	cmbSubCategory.selectedIndex=-1;
	cmbDifficultyLevel.selectedIndex=-1;
	cmbQuestionType.selectedIndex=-1;
	txtInpNumeric.text="";
	txtInpMarks.text="";	
	qpRandomQuestions = new ArrayCollection ;
	qpQuestions = new ArrayCollection ;
}

/**
 * @private
 * Handles the change event when a category is selected
 * @param event
 * @return void
 *
 */
private function changeHandler(event:Event):void {
	//Fix for Bug #11178	
	/*
	Check if the combobox for category has selected item
	If has value get subcategories for it
	else set the index as unselected (-1)
	*/
	if (cmbCategory.selectedItem != null && cmbCategory.selectedItem is QbCategoryVO) 
	{
		cmbSubCategory.selectedIndex=-1;
		getSubcategories();
	} 
	else 
	{
		cmbCategory.selectedIndex=-1;
	}
}

/**
 * @private
 * Get subcategories for the selected category
 *
 * @return void
 */
private function getSubcategories():void {
	ClassroomContext.qpSubCategories=new ArrayCollection;
	ArrayCollectionUtil.copyData(ClassroomContext.qpSubCategories, ClassroomContext.quizSubCategories);
	ClassroomContext.qpSubCategories.filterFunction=filterByCategoryId;
	ClassroomContext.qpSubCategories.refresh();
	/*Fix for Bug#15915*/
	cmbSubCategory.dataProvider = ClassroomContext.qpSubCategories;

	if (ClassroomContext.qpSubCategories.length == 0) {
		CustomAlert.info("No subcategories found for the selected category", "Subcategory- Category", null, this);
	}
}

/**
 * @private
 * Returns the category for which the subcategories have to populated
 * @param item of type Object
 * @return true or false value
 *
 */
private function filterByCategoryId(item:Object):Boolean {
	/*
		Check if the combobox for category has selected value
		and value of category in the passed object is equal to the selected value
	*/
	return (cmbCategory.selectedItem != null && cmbCategory.selectedItem.qbCategoryId == item.qbCategoryId)? true : false;
}

protected function btnSaveClickHandler(event:MouseEvent):void
{
	var i:int;
	if (validateRandomQuestion()) {
		// Check if the question to save is an existing question
		if(questionPaperQuestionVO.questionPaperQuestionId > 0)
		{
			// Loop through the question paper questions
			for (i=0; i < qpQuestions.length; i++)
			{
				// Check if the question to be saved exists in the list of question paper questions
				if (qpQuestions[i].questionPaperQuestionId == questionPaperQuestionVO.questionPaperQuestionId)
				{				
					//Fix for Bug #11319				
					
					// Check if the question already exists in the question list and set the isDuplicate datafield as true
					// Else set the isDuplicate datafield as false
					if (qpQuestions[i].qbSubcategoryId == questionPaperQuestionVO.qbSubcategoryId && qpQuestions[i].qbDifficultyLevelId == questionPaperQuestionVO.qbDifficultyLevelId && qpQuestions[i].qbQuestionTypeId == questionPaperQuestionVO.qbQuestionTypeId && qpQuestions[i].marks == questionPaperQuestionVO.marks && qpQuestions[i].numRandomQuestions == questionPaperQuestionVO.numRandomQuestions)
					{
						questionPaperQuestionVO.isDuplicate=true;
						qpQuestions[i].isDuplicate=true;
					}
					else
					{
						questionPaperQuestionVO.isDuplicate=false;
					}
					qpQuestions.setItemAt(questionPaperQuestionVO, i);
					break;
				}
				
			}				
			closeAddRandomQuestion(qpQuestions) ;
		}
			// Check if the question to save is a new question 
		else {
			questionPaperQuestionVO.questionPaper = questionPaperVO ;
			qpRandomQuestions.addItem(questionPaperQuestionVO);
			closeAddRandomQuestion(qpRandomQuestions) ;
		}
	}
}

private function closeAddRandomQuestion(qpqList:ArrayCollection = null):void{
	this.dispatchEvent(new EvaluationEvent(EvaluationEvent.CREATE_OR_UPDATE,qpqList));
	PopUpManager.removePopUp(this);
}

/**
 * @private
 * Validates the fields in AddRandomQuestion component
 *
 * @return true or false value
 *
 */
private function validateRandomQuestion():Boolean {

	// only while creating a new random question
	// initialise questionPaperQuestionVO and set the pattern type as 'Random'
	if(questionPaperQuestionVO == null)
	{
		questionPaperQuestionVO = new QuestionPaperQuestionVO ;
		questionPaperQuestionVO.patternType = QuizContext.PATTERN_TYPE_RANDOM ;
		
	}
	// If the combobox for category has a selected value , set to the VO object
	// Else display error
	if (cmbCategory.selectedIndex != -1) {
		questionPaperQuestionVO.qbCategoryId=cmbCategory.selectedItem.qbCategoryId;
		questionPaperQuestionVO.qbCategoryName=cmbCategory.selectedItem.qbCategoryName;
	} else {
		CustomAlert.error("Please select a category and try again.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return false;
	}
	questionPaperQuestionVO.qbSubcategoryId=0;
	
	// If the combobox for subcategory has a selected value , set to the VO object
	// Else display error
	if (cmbSubCategory.selectedItem != null) {
		questionPaperQuestionVO.qbSubcategoryId=cmbSubCategory.selectedItem.qbSubcategoryId;
		questionPaperQuestionVO.qbSubcategoryName=cmbSubCategory.selectedItem.qbSubcategoryName;
	} else {
		CustomAlert.error("Please select a subcategory and try again.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return false;
	}
	
	// If the combobox for difficulty level has a selected value , set to the VO object
	if (cmbDifficultyLevel.selectedItem != null) {
		questionPaperQuestionVO.qbDifficultyLevelId=cmbDifficultyLevel.selectedItem.qbDifficultyLevelId;
		questionPaperQuestionVO.qbDifficultyLevelName=cmbDifficultyLevel.selectedItem.qbDifficultyLevelName;
	}
	
	// If the combobox for question type has a selected value , set to the VO object
	if (cmbQuestionType.selectedItem != null) {
		questionPaperQuestionVO.qbQuestionTypeId=cmbQuestionType.selectedItem.qbQuestionTypeId;
		questionPaperQuestionVO.qbQuestionTypeName=cmbQuestionType.selectedItem.qbQuestionTypeName;
	}
	
	// Check if the textinput for random question has negative or no number
	// Else set the value to the VO object	
	if ((questionPaperQuestionVO.patternType == QuizContext.PATTERN_TYPE_RANDOM) && (isNaN(Number(txtInpNumeric.text)) || (Number(txtInpNumeric.text) <= 0))) {
		CustomAlert.error("Please enter number of random questions and try again.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return false;
	} 
	/* Fix for Bug#11177 */
	else if(Number(txtInpNumeric.text) > QuizContext.MAX_NO_OF_RANDOM_QUESTIONS)
	{
		CustomAlert.error("You exceeds number of random questions limit: " + QuizContext.MAX_NO_OF_RANDOM_QUESTIONS + ".", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return false;
	}
	else
	{
		questionPaperQuestionVO.numRandomQuestions=Number(txtInpNumeric.text);
	}
	
	// Check if the textinput for marks has negative or no number
	// Else set the value to the VO object
	if (isNaN(Number(txtInpMarks.text)) || (Number(txtInpMarks.text) <= 0)) {
		CustomAlert.error("Invalid value for marks.", "Validation", null, this);
		return false;
	} else {
		questionPaperQuestionVO.marks=Number(txtInpMarks.text);
	}
	/* Fix for Bug#15665,16591 */
	if((questionPaperQuestionVO.patternType == QuizContext.PATTERN_TYPE_RANDOM) && (Number(txtInpMarks.text) % Number(txtInpNumeric.text) != 0 ))
	{
		CustomAlert.error("Mark should be a multiple of No: of questions", "Validation", null, this);
		return false;
	}
	return true;
}

/**
 * @private 
 * To enable/disable some components in AddRandomQuestion component
 * @param value type of Boolean
 * 
 */
public function enableRandomQuestionComponent(value : Boolean):void
{
	cmbCategory.enabled = value;
	cmbSubCategory.enabled = value;
	cmbDifficultyLevel.enabled = value;
	cmbQuestionType.enabled = value;
	txtInpNumeric.enabled = value;
}

/**
 * Function for editing a random or specific question paper question 
 * 
 */
public function editQPQ():void{	
		/* Stores temporary category , subcategory , difficulty level ,question type etc at different parts of the code*/
		var tempAC:ArrayCollection=cmbCategory.dataProvider as ArrayCollection;
		// Only if there are categories selected for the random question
		// should we go to check other fields
		if (tempAC != null)
		{
			cmbCategory.selectedIndex=QuizContext.getItemIndexByProperty(tempAC, "qbCategoryId", String(questionPaperQuestionVO.qbCategoryId))
			
			ClassroomContext.qpSubCategories=new ArrayCollection;
			ArrayCollectionUtil.copyData(ClassroomContext.qpSubCategories, ClassroomContext.quizSubCategories);
			ClassroomContext.qpSubCategories.filterFunction=filterByCategoryId;
			ClassroomContext.qpSubCategories.refresh();
			cmbSubCategory.dataProvider=ClassroomContext.qpSubCategories;
			tempAC=cmbSubCategory.dataProvider as ArrayCollection;
			// Set the selected index of subcategory combobox
			if (tempAC != null)
			{
				cmbSubCategory.selectedIndex=QuizContext.getItemIndexByProperty(tempAC, "qbSubcategoryId", String(questionPaperQuestionVO.qbSubcategoryId));
			}
			
			tempAC=cmbDifficultyLevel.dataProvider as ArrayCollection;
			
			// Set the selected index of difficulty level combobox
			if (tempAC != null)
			{
				cmbDifficultyLevel.selectedIndex=QuizContext.getItemIndexByProperty(tempAC, "qbDifficultyLevelId", String(questionPaperQuestionVO.qbDifficultyLevelId));
			}
			
			tempAC=cmbQuestionType.dataProvider as ArrayCollection;
			
			// Set the selected index of question type combobox
			if (tempAC != null)
			{
				cmbQuestionType.selectedIndex=QuizContext.getItemIndexByProperty(tempAC, "qbQuestionTypeId", String(questionPaperQuestionVO.qbQuestionTypeId));
			}
			
		}
		
		txtInpNumeric.text=String(questionPaperQuestionVO.numRandomQuestions);
		txtInpMarks.text=String(questionPaperQuestionVO.marks);
}