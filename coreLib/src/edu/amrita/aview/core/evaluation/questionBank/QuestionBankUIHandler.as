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
 * File			: QuestionBankUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * This component displays all the Question bank category, subcategory consisting of question - answer .
 * It provides functionalities like create,edit,delete Question bank category and subcategory.
 * The questions and answers are created in a subcategory .
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.event.UpdateQBTotalQuestionsEvent;
import edu.amrita.aview.core.evaluation.helper.QbCategoryHelper;
import edu.amrita.aview.core.evaluation.helper.QbSubcategoryHelper;
import edu.amrita.aview.core.evaluation.questionBank.CategorySummary;
import edu.amrita.aview.core.evaluation.questionBank.CategoryView;
import edu.amrita.aview.core.evaluation.questionBank.InputBox;
import edu.amrita.aview.core.evaluation.questionBank.SubcategoryView;
import edu.amrita.aview.core.evaluation.vo.QbCategoryVO;
import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.TreeEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;

[Bindable]
/**
 * To hold question bank details.
 * Dataprovider of 'questionBankTree'.*/
private var questionBankData:ArrayCollection;

/**
 * To hold selected question bank category.
 */
private var selectedQbCategoryItem:QbCategoryVO;

/**
 * The Value Object variable of QbSubcategoryVO
 */
private var qbSubcategoryVO:QbSubcategoryVO;

/**
 * The QbCategoryHelper object
 */
private var qbCategoryHelper:QbCategoryHelper;

/**
 * The QbSubcategoryHelper object
 */
private var qbSubcategoryHelper:QbSubcategoryHelper;

/**
 * Object to refer 'InputBox' component.
 */
private var inputBox:InputBox;

/**
 * Object to refer 'SubcategoryView' component.
 */
private var subcategoryView:SubcategoryView;
/**
 * Object to refer 'CategoryView' component.
 */
private var categoryView:CategoryView;
/**
 * Constant for Create Subcategory window title.
 */
private const CREATE_SUBCATEGORY_LABEL:String = "Create Subcategory";
/**
 * Constant for Subcategory Name label.
 */
private const SUBCATEGORY_NAME:String = "Subcategory Name  :";
/**
 * Constant fr Edit Subcategory window title.
 */
private const EDIT_SUBCATEGORY_LABEL:String = "Edit Subcategory";
/**
 * Constant for Edit category window title.
 */
private const EDIT_CATEGORY_LABEL:String = "Edit Category";

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionBank.QuestionBankUIHandler.as");

/**
 * @public
 * Handles result after deleting question bank Category.
 *
 * @return void
 *
 */
public function deleteQbCategoryResultHandler():void
{
	var i:int;
	// Loop through the data provider of tree component
	//  and remove the deleted category .
	for (i = 0; i < questionBankData[0].children.length; i++)
	{
		if (questionBankData[0].children[i] == questionBankTree.selectedItem)
		{
			questionBankData[0].children.removeItemAt(i);
			break;
		}
	}

	questionBankTree.invalidateList();
	questionBankTree.selectedIndex = 0;
	btnAdd.enabled = true;
	btnDelete.enabled = false;
	btnEdit.enabled = false;
	questionBankTree.expandItem(questionBankData[0], false);
	showCategorySummary();
	qbSubcategoryHelper.getAllActiveQbSubcategoriesForUser(ClassroomContext.userVO.userId,getAllActiveQbSubcategoriesForUserResultHandler);
	CustomAlert.info("Category deleted successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
}

/**
 * @public
 * Handles result of all active question bank subcategories.
 * @param result type of ArrayCollection
 * @return void
 *
 */
public function getAllActiveQbSubcategoriesForUserResultHandler(result:ArrayCollection):void
{
	//ClassroomContext.quizSubCategories=result;
	//Fix for Bug #11518
	ClassroomContext.quizSubCategories.removeAll();
	ArrayCollectionUtil.copyData(ClassroomContext.quizSubCategories, result);
}

/**
 * @public
 * Handles result of all active question bank subcategories for category.
 * @param result type of ArrayCollection
 * @return void 
 */
public function getAllActiveQbSubcategoriesSummaryForCategoryResultHandler(result:ArrayCollection):void
{
	if(Log.isInfo())
		log.info("getAllActiveQbSubcategoriesSummaryForCategory_resultHandler::result::" + result);
	//Setting result(subcategories) as children in selectedQbCategoryItem.
	selectedQbCategoryItem.children = result;
	questionBankTree.invalidateList();
	showCategoryView(result);
}

/**
 * @public
 * Handles result after deleting question bank subcategory.
 *
 * @return void
 *
 */
public function deleteQbSubcategoryResultHandler():void
{
	/* Temporary variable to hold category details. */
	var tempCat:QbCategoryVO = null;

	// To remove deleted subcategories from 'questionBankData' arraycollection.	 
	for (var i:int = 0; i < questionBankData[0].children.length; i++)
	{
		if (questionBankData[0].children[i].children.contains(questionBankTree.selectedItem))
		{
			tempCat = questionBankData[0].children[i];
			var index:int = questionBankData[0].children[i].children.getItemIndex(questionBankTree.selectedItem);
			questionBankData[0].children[i].children.removeItemAt(index);
			break;
		}
	}

	/**
	 * To remove deleted subcategories from 'quizSubCategories' arraycollection in 'ClassroomContext' component.
	 * */
	for (i = 0; i < ClassroomContext.quizSubCategories.length; i++)
	{
		if (ClassroomContext.quizSubCategories[i].qbSubcategoryId == qbSubcategoryVO.qbSubcategoryId)
		{
			ClassroomContext.quizSubCategories.removeItemAt(i);
			break;
		}
	}

	questionBankTree.invalidateList();
	questionBankTree.selectedItem = tempCat;
	questionBankTree.validateNow();
	//QBTree.selectedIndex = 0; 
	questionBankTree.expandItem(questionBankData[0], true);
	showCategoryView(tempCat.children);
	btnAdd.enabled = true;
	CustomAlert.info("Subcategory deleted successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);

}

/**
 * @private
 * Click handler for 'btnDelete' button.
 *
 * @return void
 *
 */
private function deleteQuestionbank():void
{
	//To give conformation message to delete category/subcategory.
	//Checking whether selected item is category or subcategory and giving appropriate message.	
	if (questionBankTree.selectedItem is QbCategoryVO)
	{
		CustomAlert.confirm("Do you want to delete this Category?", "Confirmation", confirmDeleteQuestionbank);
	}
	else if (questionBankTree.selectedItem is QbSubcategoryVO)
	{
		CustomAlert.confirm("Do you want to delete this Subcategory?", "Confirmation", confirmDeleteQuestionbank);
	}

}

/**
 * @private
 * Conformation function for deleting question bank.
 * @param event type of CloseEvent
 * @return void
 *
 */
private function confirmDeleteQuestionbank(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		deleteNode();
	}
}

/**
 * @private
 * initQuestionBank() is the first function to be called on the initialise of QuestionBank.mxml
 *  - It initialises the helper class variables 
 *  - Sets the data for tree's dataprovider
 *  - Enable/Disable buttons
 *  - Call the category summary to be displayed
 *
 * @return void
 *
 */
private function initQuestionBank():void
{
	qbCategoryHelper = new QbCategoryHelper();
	qbSubcategoryHelper = new QbSubcategoryHelper();
	questionBankData = new ArrayCollection;
	// for displaying branch of tree ,the property 'children' 
	questionBankData.addItem({label: QuizContext.ROOT_TREE_QUESTIONBANK, children: new ArrayCollection});
	questionBankData[0].children = ClassroomContext.quizCategories;	
	
	//No effect on GUI
	/*questionBankData.refresh();
	questionBankTree.invalidateList();
	questionBankTree.expandItem(questionBankData[0], true);
	questionBankTree.selectedIndex=0; */
	
	setAddButtonEnabled(true) ;
	setDeleteButtonEnabled(false) ;
	setEditButtonEnabled(false) ;	

	showCategorySummary();
}

/**
 * Sets the btnAdd as enabled or disabled 
 * @param flag type of Boolean
 * 
 */
private function setAddButtonEnabled(flag:Boolean) :void{
	btnAdd.enabled = flag ;
}

/**
 * Sets the btnDelete as enabled or disabled
 * @param flag type of Boolean
 * 
 */
private function setDeleteButtonEnabled(flag:Boolean) :void{
	btnDelete.enabled = flag ;
}

/**
 * Sets the btnEdit as enabled or disabled 
 * @param flag type of Boolean
 * 
 */
private function setEditButtonEnabled(flag:Boolean) :void{
	btnEdit.enabled = flag ;
}

/**
 * @private
 * Handler for CreationComplete event of 'questionBankTree' tree component.
 *
 * @return void
 *
 */
// Fix for Bug #10635
private function treeCreationComplete():void
{
	questionBankTree.expandItem(questionBankData.getItemAt(0), true);
	questionBankTree.selectedIndex = 0;
}

/**
 * @private
 * To display category summary.
 *
 * @return void
 *
 */
private function showCategorySummary():void
{
	var categorySummary:CategorySummary = new CategorySummary;
	cnvContent.removeAllElements();
	cnvContent.addElement(categorySummary);
}

/**
 * @private
 * 'dataTipFunction' handler of 'questionBankTree' tree component.
 * @param item type of Object
 * @return String
 *
 */
private function showToolTip(item:Object):String
{
	// To show tooltip if category/subcategory name's length is greater than 15.
	//Checking whether selected item is category/subcategory and giving appropriate value to show tooltip.	
	if (item is QbCategoryVO)
	{
		if (item.qbCategoryName.length > QuizContext.textLengthForTree)
		{
			return item.qbCategoryName;
		}
	}
	else if (item is QbSubcategoryVO)
	{
		if (item.qbSubcategoryName.length > 15)
		{
			return item.qbSubcategoryName;
		}
	}
	return "";
}

/**
 * @private
 * Label function of 'questionBankTree' which returns the name corresponding to the parameter it recieves.
 * @param item type of Object
 * @return String
 *
 */
private function getNodes(item:Object):String
{	
	if(Log.isDebug())
		log.debug("setNodes::item::" + item);
	// Check whether item is category/subcategory and giving appropriate value to return.
	if (item is QbCategoryVO)
	{
		return item.qbCategoryName;
	}
	else if (item is QbSubcategoryVO)
	{
		return item.qbSubcategoryName;
	}
	else if (item is Object)
	{
		return item.label;
	}
	return "";
}

/**
 * @private
 * Handler for 'itemOpen' event of 'questionBankTree' tree i.e Expanding the child node (a category)
 * @param event type of TreeEvent
 * @return void
 *
 */
private function expandNode(event:TreeEvent):void
{
	// Check if the item to be opened is of type QbCategoryVO and selectedIndex is not  -1
	if (event.item is QbCategoryVO && event.target.selectedIndex != -1)
	{
		/** The Value Object of QbCategoryVO */		
		var category:QbCategoryVO = event.item as QbCategoryVO;
		
		// Enabling Add/edit/delete button
		setAddButtonEnabled(true) ;
		setDeleteButtonEnabled(true) ;
		setEditButtonEnabled(true) ;
		
		if(Log.isInfo())
			log.info("expandNode::event.item.qbCategoryId::" + event.item.qbCategoryId);
		if(Log.isInfo())
			log.info("expandNode::category.children.length::" + category.children.length);
		
		// If there is no subcategories,then show the summary , else show subcategory details 		
		if (category.children.length == 0)
		{
			qbSubcategoryHelper.getAllActiveQbSubcategoriesSummaryForCategory(event.item.qbCategoryId,getAllActiveQbSubcategoriesSummaryForCategoryResultHandler);
		}
		else
		{
			showCategoryView(category.children);
		}
	}
	questionBankTree.selectedItem = event.item;
	selectedQbCategoryItem = event.item as QbCategoryVO;
	questionBankTreeClickHandler(event);
}

/**
 * @private
 * Handler for 'itemClick' event of 'questionBankTree' tree.
 * Any of the nodes in tree are clicked either root , category or subcategory 
 * @param event type of Event
 * @return void
 *
 */
private function questionBankTreeClickHandler(event:Event):void
{
	questionBankTree.editable = false;
	if (event.currentTarget.selectedItem is QbCategoryVO)
	{		
		// Enabling Add,edit,delete button
		setAddButtonEnabled(true) ;
		setDeleteButtonEnabled(true) ;
		setEditButtonEnabled(true) ;
	
		// variable to hold selected category
		var category:QbCategoryVO = event.currentTarget.selectedItem as QbCategoryVO;
		selectedQbCategoryItem = category;
	
		// If there is no subcategories,then show the summary,else show subcategory details
		if (category.children == null || category.children.length <= 0)
		{
			qbSubcategoryHelper.getAllActiveQbSubcategoriesSummaryForCategory(category.qbCategoryId,getAllActiveQbSubcategoriesSummaryForCategoryResultHandler);
		}
		else
		{
			showCategoryView(category.children);
		}
	}
	else if (event.currentTarget.selectedItem is QbSubcategoryVO)
	{	
		// Disable add button and enable edit,delete button
		setAddButtonEnabled(false) ;
		setDeleteButtonEnabled(true) ;
		setEditButtonEnabled(true) ;

		/** variable to hold selected subcategory */		
		var qbSubcategoryVO:QbSubcategoryVO = event.currentTarget.selectedItem as QbSubcategoryVO;
		cnvContent.removeAllChildren();
		subcategoryView = new SubcategoryView();
		subcategoryView.qbSubcategoryVO = qbSubcategoryVO;			
		subcategoryView.addEventListener(UpdateQBTotalQuestionsEvent.QB_TOTAL_QNS,updateTotalQuestions) ;
		// Load subcategory to the canvas
		cnvContent.addChild(subcategoryView);
	}
	else if (event.currentTarget.selectedItem is Object)
	{
		// Enable add button and Disable edit,delete button
		setAddButtonEnabled(true) ;
		setDeleteButtonEnabled(false) ;
		setEditButtonEnabled(false) ;
		// To load all the categories to 'questionBankData'
		questionBankData[0].children = ClassroomContext.quizCategories;
		questionBankData.refresh();
		questionBankTree.invalidateList();
		questionBankTree.expandItem(questionBankData[0], true);
		questionBankTree.selectedIndex = 0;
		// Show category summary
		showCategorySummary();
	}	
}

/**
 * @private
 * Handler for 'itemDoubleClick' event of 'questionBankTree' tree.
 * @param e type of Event
 * @return void
 *
 */
private function questionBankTreeDoubleClickHandler(e:Event):void
{
	btnEdit.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	
}

/**
 * @private
 * To display details of a question bank category.
 * @param subcategories type of ArrayCollection
 * @return void
 *
 */
private function showCategoryView(subcategories:ArrayCollection):void
{
	if(Log.isDebug())
		log.debug(""+selectedQbCategoryItem);
	if(categoryView == null)
	{
		categoryView = new CategoryView;
	}
	categoryView.subCategories = subcategories;
	categoryView.categoryVO = selectedQbCategoryItem;
	cnvContent.removeAllElements();
	cnvContent.addElement(categoryView);
}

/**
 * @private
 * Handler for'click' event of 'btnAdd' button.
 * To add new node ie,category/subcategory.
 *
 * @return void
 *
 */
private function addNewNode():void
{
	if(Log.isDebug())
		log.debug("addNode::selectedItem::" + questionBankTree.selectedItem);	
	// Create a popup of 'InputBox'
	inputBox = InputBox(PopUpManager.createPopUp(this, InputBox, true));
	PopUpManager.centerPopUp(inputBox);

	 // If selected item is category then set 'inputBox' window to add new subcategory.
	//Else set 'inputBox' window to add new category 
	if (questionBankTree.selectedItem is QbCategoryVO)
	{
		inputBox.title = CREATE_SUBCATEGORY_LABEL;
		//Fix for Bug#18080
		inputBox.labelMessage.text = SUBCATEGORY_NAME;
		inputBox.isCategory = false;
		inputBox.categoryId = questionBankTree.selectedItem.qbCategoryId;
		inputBox.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , createSubcategory) ;		
	}
	else
	{
		inputBox.isCategory = true;
		inputBox.addEventListener(EvaluationEvent.CREATE_OR_UPDATE,createCategory) ;		
	}
}

/**
 * @private
 * Handler for'click' event of 'btnEdit' button.
 *
 * @return void
 *
 */
private function editNode():void
{
	if (questionBankTree.selectedIndex == 0 || questionBankTree.selectedItem == null)
	{
		CustomAlert.error("Please select a Category for editing.", QuizContext.ALERT_TITLE_ERROR, null, this);
		return;
	}
	else
	{
		if(Log.isDebug())
			log.debug("editNode::Tree selectedItem::" + questionBankTree.selectedItem);
		inputBox = InputBox(PopUpManager.createPopUp(this, InputBox, true));
		inputBox.questionBankData = this.questionBankData;
		if (questionBankTree.selectedItem is QbSubcategoryVO)
		{
			inputBox.title = EDIT_SUBCATEGORY_LABEL;
			qbSubcategoryVO = questionBankTree.selectedItem as QbSubcategoryVO;
			inputBox.txtQBName.text = qbSubcategoryVO.qbSubcategoryName;
			inputBox.isCategory = false;
			inputBox.categoryId = questionBankTree.selectedItem.qbCategoryId;
			inputBox.qbSubcategoryVO = qbSubcategoryVO;
			inputBox.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , updateQBSubCategory);
//			inputBox.btnSave.addEventListener("click", updateQBSubCategory);
		}
		else
		{
			inputBox.title = EDIT_CATEGORY_LABEL;			
			inputBox.isCategory = true;
			var qbCategoryVO:QbCategoryVO = questionBankTree.selectedItem as QbCategoryVO;
			inputBox.txtQBName.text = qbCategoryVO.qbCategoryName;
			inputBox.qbCategoryVO = qbCategoryVO;
			inputBox.addEventListener(EvaluationEvent.CREATE_OR_UPDATE, updateQBCategory);
//			inputBox.btnSave.addEventListener("click", updateQBCategory);
		}
		PopUpManager.centerPopUp(inputBox);
	}
}

/**
 * @private
 * To create a question bank category.
 * @param event type of Event
 * @return void
 *
 */
private function createCategory(event:EvaluationEvent):void
{
	if(event.data != null)
	{
		//Fix for Bug #11462
		CustomAlert.info("Category created successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		var newQbCategoryVO:QbCategoryVO = event.data as QbCategoryVO;
		// add the newly created category to the tree
		questionBankTree.selectedItem.children.addItem(newQbCategoryVO);
		questionBankTree.invalidateList();
		// doing nothing in the gui .. 
		questionBankTree.expandItem(questionBankTree.selectedItem, true);
	}
	inputBox = null;
}

/**
 * @private
 * To create question bank sub category.
 * @param event type of EvaluationEvent
 * @return void
 *
 */
private function createSubcategory(event:EvaluationEvent):void
{
	if(event.data != null)
	{
		//Fix for Bug #11462
		CustomAlert.info("Subcategory created successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		var newQbSubcategoryVO:QbSubcategoryVO = event.data as QbSubcategoryVO;
		questionBankTree.selectedItem.children.addItem(newQbSubcategoryVO);
		questionBankTree.invalidateList();
		questionBankTree.expandItem(questionBankTree.selectedItem, true);
	}
	inputBox = null;
}


/**
 * @private
 * To update question bank category.
 * @param event type of Event
 * @return void
 *
 */
private function updateQBCategory(event:EvaluationEvent):void
{
	if(event.data != null)
	{
		CustomAlert.info("Category updated successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		questionBankTree.editable = false;
		for(var i:int = 0;i<questionBankData[0].children.length;i++)
		{
			if(questionBankTree.selectedItem == questionBankData[0].children[i])
			{
				//Fix for Bug#15238 :Start
				if(questionBankTree.isItemOpen(questionBankData[0].children[i]))
				{
					questionBankTree.expandItem(questionBankData[0].children[i],false);
					questionBankTree.expandItem(questionBankData[0].children[i],true);
				}
				else
				{
					questionBankTree.expandItem(questionBankData[0].children[i],true);
					questionBankTree.expandItem(questionBankData[0].children[i],false);
				}				
				//questionBankData[0].children[i] = event.data;
				//Fix for Bug#15238 :End
				return;
			}
		}
	}
	inputBox = null;

}

/**
 * @private
 * To update question bank subcategory.
 * @param event type of Event
 * @return void
 *
 */
private function updateQBSubCategory(event:EvaluationEvent):void
{
	if(event.data != null)
	{
		CustomAlert.info("Subcategory updated successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		subcategoryView.subcategoryName = event.data.qbSubcategoryName;
		questionBankTree.editable = false;
	}
	// The following statements update the tree's dataprovider ,not all of them have to be used .
	questionBankTree.destroyItemEditor();
	//questionBankTree.dataProvider.itemUpdated(questionBankTree.editedItemRenderer);
	questionBankTree.invalidateList();	
	inputBox = null;
}

/**
 * @private
 * To delete question bank category/sub category.
 *
 * @return void
 *
 */
private function deleteNode():void
{
	// Check if the node selected in tree is of type QbCategoryVO or QbSubcategoryVO
	if (questionBankTree.selectedItem is QbCategoryVO)
	{
		qbCategoryHelper.deleteQbCategory(QbCategoryVO(questionBankTree.selectedItem).qbCategoryId, ClassroomContext.userVO.userId,deleteQbCategoryResultHandler);
	}
	else if (questionBankTree.selectedItem is QbSubcategoryVO)
	{
		qbSubcategoryVO = questionBankTree.selectedItem as QbSubcategoryVO;
		qbSubcategoryHelper.deleteQbSubcategory(qbSubcategoryVO.qbSubcategoryId, ClassroomContext.userVO.userId,deleteQbSubcategoryResultHandler);
	}
}
public function updateTotalQuestions(qbTotalQns:UpdateQBTotalQuestionsEvent):void
{
	categoryView.categoryVO.totalQuestions -= qbTotalQns.totalQns ;
}