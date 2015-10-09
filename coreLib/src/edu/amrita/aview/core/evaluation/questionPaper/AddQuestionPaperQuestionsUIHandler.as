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
 * File			: AddQuestionPaperQuestionsUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 *
 * 	AddQuestionPaperQuestionsUIHandler is handler for AddQuestionPaperQuestions.mxml
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.helper.QbQuestionHelper;
import edu.amrita.aview.core.evaluation.questionPaper.ViewQuestions;
import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperQuestionVO;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;
import edu.amrita.aview.core.gclm.GCLMContext;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.ListEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

[Bindable]
/**
 * list of specific questions
 */
private var qpSpecificQuestions:ArrayCollection=new ArrayCollection;

[Bindable]
/**
 * list of categories
 */
private var categories:ArrayCollection=new ArrayCollection;

[Bindable]
/**
 * list of subcategories
 */
private var subCategories:ArrayCollection=new ArrayCollection;

[Bindable]
/**
 * list of difficulty levels
 */
private var levels:ArrayCollection=new ArrayCollection;

[Bindable]
/**
 * list of question types
 */
private var questionTypes:ArrayCollection=new ArrayCollection;

/**
 *  helper object , for using remote methods
 */
private var qbQuestionHelperRO:QbQuestionHelper;

/**
 * used to view a specific question with its answer choices
 */
private var viewQuestion:ViewQuestions;

/**
 * List of question paper questions from the parent component i.e QuestionPaperQuestion.mxml 
 */
public var qpqList:ArrayCollection = null ;

/**
 * The referenced question paper from parent component 
 */
public var questionPaperVO:QuestionPaperVO = null ;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionPaper.AddQuestionPaperQuestionsUIHandler.as");

/**
 * @public
 * Gets the list of specific question as per the search criteria
 * @param result type of ArrayCollection
 * @return void
 */
public function getQbQuestionsResultHandler(event:ResultEvent):void {
	//Fix for Bug#15241
	// Empty qpSpecificQuestions , if no result is returned , else assign result to it	
	qpSpecificQuestions.removeAll();
	//Fix for Bug#18819
	if(event.result != null && event.result.length > 0)
	{
		var result:ArrayCollection = event.result as ArrayCollection ;
		if(Log.isInfo()) log.info("getQbQuestions_resultHandler::event.result::" + result.length);
		ArrayCollectionUtil.copyData(qpSpecificQuestions , result) ;		
	}
	else {
		CustomAlert.error("No Questions found", QuizContext.ALERT_TITLE_INFORMATION, null, this);		
	}
}

/**
 * @private
 * Sets the initial data like populating array collections , calling remote methods etc .
 *
 * @return void
 */
private function initAddQPQ():void {
	qbQuestionHelperRO=new QbQuestionHelper();
	cbCategories.setFocus();
	categories.removeAll();
	subCategories.removeAll();
	levels.removeAll();
	questionTypes.removeAll();

	ArrayCollectionUtil.copyData(categories, ClassroomContext.quizCategories);
	GCLMContext.sortSmartComboDataProvider(categories, "qbCategoryName");
	ArrayCollectionUtil.copyData(subCategories, ClassroomContext.quizSubCategories);
	GCLMContext.sortSmartComboDataProvider(subCategories, "qbSubcategoryName");
	ArrayCollectionUtil.copyData(levels, ClassroomContext.quizDifficultyLevels);
	ArrayCollectionUtil.copyData(questionTypes, ClassroomContext.quizQuestionTypes);
	
	qpqList = new ArrayCollection ; 
}

/**
 * @private
 * Used to search questions on basis of search criteria
 *
 * @return void
 */
private function getQbQuestions():void {
	// check box header column in datagrid
	var col:CheckBoxHeaderColumn=dgSpecificQuestions.columns[0];
	col.selected=false;
	// category id
	var categoryId:Number;

	// subcategory id
	var subcategoryId:Number;

	// difficulty level id
	var levelId:Number;

	// question type id
	var typeId:Number;

	// question text
	var quesText:String;

	categoryId=(cbCategories.selectedItem == null ? 0 : cbCategories.selectedItem.qbCategoryId);
	subcategoryId=(cbSubcategories.selectedItem == null ? 0 : cbSubcategories.selectedItem.qbSubcategoryId);
	levelId=(cbLevels.selectedItem == null ? 0 : cbLevels.selectedItem.qbDifficultyLevelId);
	typeId=(cbTypes.selectedItem == null ? 0 : cbTypes.selectedItem.qbQuestionTypeId);
	quesText=(StringUtil.trim(txtInpSearchString.text) == null || StringUtil.trim(txtInpSearchString.text) == QuizContext.EMPTY_STRING) ? null : StringUtil.trim(txtInpSearchString.text);

	qbQuestionHelperRO.getQbQuestions(categoryId, subcategoryId, typeId, levelId, quesText,getQbQuestionsResultHandler);

}

/**
 * @private
 * Used to reset all components
 *
 * @return void
 *
 */
private function resetAllComponents():void 
{
	//Fix for Bug#16354
	cbCategories.selectedIndex=-1;
	cbSubcategories.selectedIndex=-1;
//	cbLevels.selectedItem = null;
	cbLevels.selectedIndex = -1;
//	cbTypes.selectedItem = null;	
	cbTypes.selectedIndex = -1;	
	txtInpSearchString.text="";
	
	categories.refresh();
	subCategories=new ArrayCollection();
	ArrayCollectionUtil.copyData(subCategories, ClassroomContext.quizSubCategories);
	GCLMContext.sortSmartComboDataProvider(subCategories, "qbSubcategoryName");
	subCategories.refresh();
	cbSubcategories.dataProvider=subCategories;

	dgSpecificQuestions.dataProvider.removeAll();
	qpSpecificQuestions.refresh();
	dgSpecificQuestions.toolTip="";
}

/**
 * @private
 * Used to view question and answer choices
 * @param event of type MouseEvent
 * @return void
 *
 */
private function dgSpecificQnsDoubleClickHandler(event:MouseEvent):void {
	//  Show the question bank question  only if the datagrid's data provider has' data'
	// as its property and the 'data' property is of type 'QbQuestionVO'
	if (event.target.hasOwnProperty("data") && event.target.data is QbQuestionVO) {
		/* //Fix for Bug #11282 :Start
		if(dgSpecificQns.selectedItems.length <= 1)
		{
		if(dgSpecificQns.selectedIndex !=-1 && dgSpecificQns.selectedItem == event.target.data)
		{
		//Fix for Bug #11282 :End*/
		viewQuestion=ViewQuestions(PopUpManager.createPopUp(this, ViewQuestions, true));
		viewQuestion.qbQuestion=event.target.data as QbQuestionVO;
		PopUpManager.centerPopUp(viewQuestion);
		/* //Fix for Bug #11282 :Start
		}
		else
		{
		CustomAlert.info("Select a question for preview.", "View Question",null,this);
		}
		}
		else
		{
		CustomAlert.info("Select only one  question for preview.", "View Question",null,this);
		}
		//Fix for Bug #11282 :End */
	}

}

/**
 * @private
 * Used to select/deselect questions in datagrid
 *
 * @return void
 *
 */
private function toggleSelectionQpSpecificQuestions():void {
	// Header column for checkbox datagrid 
	var col:CheckBoxHeaderColumn=dgSpecificQuestions.columns[0];

	// Donot allow toggling , if the dataprovider is empty
	if (qpSpecificQuestions == null) {
		return;
	}

	// Add the selected questions to list , if the header column is selected
	// PNCR: conditional operator
	if (col.selected) {
		dgSpecificQuestions.selectedItems=qpSpecificQuestions.toArray();
	} else {
		dgSpecificQuestions.selectedItems=[];
	}
}

/**
 * @private
 * Used to check if a certain category is present in the list
 * @param item of type Object
 * @return true or false value
 */
private function filterByCategoryId(item:Object):Boolean {
	/* Flag for filtering objects for a category id*/
	var returnVal:Boolean=false;

	/* Return true , if the category id to be searched is found */
	if ((cbCategories.selectedItem != null && cbCategories.selectedItem.qbCategoryId == item.qbCategoryId) || 
		 (item.qbSubcategoryId == -1))
		//(questionPaperQuestionVO.qbCategoryId == item.qbCategoryId) ||
	{
		returnVal=true;
	}
	
	return returnVal;
}

/**
 * @private
 * Retrieve sub categories for a category
 *
 * @return void
 *
 */
private function getSubcategories():void {
	subCategories.filterFunction=filterByCategoryId;
	subCategories.refresh();

	/*
	If no subcategory is found , show an alert and set the index
	of subcategory combox as -1
	*/
	if (subCategories.length == 0) {
		CustomAlert.info("No subcategories found for the selected category", "Subcategory- Category", null, this);
		cbSubcategories.selectedIndex=-1;
	}
}

/**
 * @private
 * Used to get the difficulty level
 * @param oItem Object
 * @param iCol int
 * @return name of difficulty level
 *
 */

private function getDifficultyLevel(oItem:Object, iCol:int):String {
	for (var i:int=0; i < levels.length; i++) {
		// Returns the difficulty level name for datagrid column
		if (oItem.qbDifficultyLevelId == levels[i].qbDifficultyLevelId) {
			return String(levels[i].qbDifficultyLevelName);
		}
	}
	return QuizContext.EMPTY_STRING;
}

/**
 * @private
 * Used to get categories
 * @param oItem Object
 * @param iCol int
 * @return category name
 *
 */
private function getCategory(oItem:Object, iCol:int):String {
	/* category id */
	var qbCategoryId:int;

	for (var i:int=0; i < subCategories.length; i++) {
		// Get the category id , for the corresponding subcategories
		if (oItem.qbSubcategoryId == subCategories[i].qbSubcategoryId) {
			qbCategoryId=subCategories[i].qbCategoryId;
			break;
		}
	}

	for (i=0; i < categories.length; i++) {
		// Get the category name for the categories
		if (qbCategoryId == categories[i].qbCategoryId) {
			return categories[i].qbCategoryName;
		}
	}
	return QuizContext.EMPTY_STRING;
}

/**
 * @private
 * Used to get question types
 * @param oItem Object
 * @param iCol int
 * @return question type name
 *
 */
private function getQuestionType(oItem:Object, iCol:int):String {
	for (var i:int=0; i < questionTypes.length; i++) {
		// Get the question type name for the question type id
		if (oItem.qbQuestionTypeId == questionTypes[i].qbQuestionTypeId) {
			return questionTypes[i].qbQuestionTypeName;
		}
	}
	return QuizContext.EMPTY_STRING;
}

/**
 * @private
 * Used to get subcategories
 * @param oItem Object
 * @param iCol int
 * @return subcategory name
 *
 */
private function getSubcategory(oItem:Object, iCol:int):String {
	for (var i:int=0; i < subCategories.length; i++) {
		// Get the subcategory name for subcategory id
		if (oItem.qbSubcategoryId == subCategories[i].qbSubcategoryId) {
			return subCategories[i].qbSubcategoryName;
		}
	}
	return QuizContext.EMPTY_STRING;
}

/**
 * @protected
 * Used to display tool tip mouse roll overs the datagrid
 * @param event ListEvent
 * @return void
 *
 */
// Fix for Bug #11946 :Start
protected function addToolTip(event:ListEvent):void {
	dgSpecificQuestions.toolTip="Double click a row to view Question & Answers";
}

/**
 * @protected
 * Used to remove the tool tip , once the mouse rolls out
 * @param event ListEvent
 * @return void
 *
 */
protected function removeToolTip(event:ListEvent):void {
	dgSpecificQuestions.toolTip="";
}
// Fix for Bug #11946: End

/**
 * Event Listener when Save button is clicked 
 * @param event type of MouseEvent
 * 
 */
private function onClickBtnAdd(event:MouseEvent) :void
{
	/* Fix for Bug#15876
		//ArrayCollectionUtil.copyData(subCategories, ClassroomContext.quizSubCategories);
	*/
	// Do nothing , if questions are not selected to be added	
	if (dgSpecificQuestions.selectedItems == null)
	{
		return;
	}
	
	// Display an error , if no question is selected for adding to a question paper
	if (dgSpecificQuestions.selectedItems.length == 0)
	{
		CustomAlert.error("Please select the questions to be added", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		return;
	}
		// else add the questions to the list
	else
	{
		var i:int;
		var selectedItems:Array = dgSpecificQuestions.selectedItems;
		var qpQuestion:QuestionPaperQuestionVO= null;
		var qid:int = 0;
		var index:int  = 0;
		var subcategory:QbSubcategoryVO = null ;
		var qbQuestion:QbQuestionVO = null ;
		for (i=0; i < selectedItems.length; i++)
		{
			qid =selectedItems[i].qbQuestionId;
			// Check if the question to be added already exists in the question paper questions
			
			if ((QuizContext.getItemIndexByProperty(qpqList, "qbQuestionId", String(qid))) == -1)
			{			
				qpQuestion = new QuestionPaperQuestionVO ;
				qpQuestion.questionPaper=questionPaperVO;
				qpQuestion.qbQuestionId=selectedItems[i].qbQuestionId;
				qpQuestion.patternType=QuizContext.PATTERN_TYPE_SPECIFIC;
				qpQuestion.questionText=selectedItems[i].questionText;
				qpQuestion.qbDifficultyLevelId = selectedItems[i].qbDifficultyLevelId ;
				qpQuestion.qbDifficultyLevelName=selectedItems[i].qbDifficultyLevelName;
				qpQuestion.qbQuestionTypeId = selectedItems[i].qbQuestionTypeId ;
				qpQuestion.qbQuestionTypeName=selectedItems[i].qbQuestionTypeName;
				qpQuestion.marks=selectedItems[i].marks;
				
				index =QuizContext.getItemIndexByProperty(subCategories, "qbSubcategoryId", String(selectedItems[i].qbSubcategoryId));
				subcategory = subCategories.getItemAt(index) as QbSubcategoryVO;
				qpQuestion.qbSubcategoryId=subcategory.qbSubcategoryId;
				qpQuestion.qbSubcategoryName=subcategory.qbSubcategoryName;
				qpQuestion.qbCategoryId=subcategory.qbCategoryId;
				qpQuestion.qbCategoryName=subcategory.qbCategoryName;
				qpSpecificQuestions.addItem(selectedItems[i]);
				qpqList.addItem(qpQuestion);							
			}
			
			//Fix for Bug #11042
			/*else
			{	
				//Fix for Bug #11459
				CustomAlert.info("Question already exists in the question paper.", QuizContext.ALERT_TITLE_INFORMATION, null, this);				
				return ;
			}*/
		}
		closeAddQPQ(qpqList) ;
	}
}

/**
 * Dispatches the event to parent component on closing this component 
 * @param qpqList type of ArrayCollection
 * 
 */
private function closeAddQPQ(qpqList :ArrayCollection = null) :void
{
	this.dispatchEvent(new EvaluationEvent(EvaluationEvent.CREATE_OR_UPDATE,qpqList));
	PopUpManager.removePopUp(this);
}