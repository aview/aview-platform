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
 * File			: QuestionPaperUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * QuestionPaperUIHandler acts as handler for QuestionPaper.mxml
 * 
 * QP - Question Paper
 */

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.entry.ClassroomComponent;
}
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.event.UpdateQuestionPaperVOEvent;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.questionPaper.LiveQuestionPaperPreview;
import edu.amrita.aview.core.evaluation.questionPaper.QuestionPaperInputBox;
import edu.amrita.aview.core.evaluation.questionPaper.QuestionPaperQuestions;
import edu.amrita.aview.core.evaluation.questionPaper.QuestionPaperSummary;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Tree;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;
import mx.validators.NumberValidator;
import mx.utils.ObjectUtil;

/**
 * Stores list of active question papers
 */
private var questionPapers:ArrayCollection; 

[Bindable]
/**
 * Data provider for the tree component consisting of
 * active question papers list
 */
private var questionPaperACForTree:ArrayCollection;

/**
 * Used to call methods of QuestionPaperHelper
 */
private var questionPaperHelper:QuestionPaperHelper;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionPaper.QuestionPaperUIHandler.as");

/**
 * @public
 * This function initialises
 * various parameters for UI display.
 * populate the data provider by calling of helper method.
 *
 * @return void
 */
public function initQP():void
{
	var heightForCanComponent:int ;
	var heightForQpTree:int ;
	questionPaperHelper=new QuestionPaperHelper();
	// Check if the user has logged into class room for conducting quiz
	// else display the normal question paper component
	
	if (ClassroomContext.checkIsClassRoom)
	{		
		// While displaying question paper in classroom there are many other components
		// like chat,video etc , due to this the canvas and tree component have to
		// be sized accordingly , the values are set to cater UI of different screen resolutions
		heightForCanComponent = 94 ;
		//			 Bug fix : Bug #10474
		heightForQpTree = 94 ;
		//			 Bug fix : Bug #9841 			
		// In class room the user cannot create,edit,or delete a question
		// paper , hence make those buttons invisible
				
		setAddButtonEnabled(!ClassroomContext.checkIsClassRoom) ;		
		setAddButtonVisible(!ClassroomContext.checkIsClassRoom) ;
		setDeleteButtonVisible(!ClassroomContext.checkIsClassRoom) ;
		setEditButtonVisible(!ClassroomContext.checkIsClassRoom) ;				
		
		questionPaperHelper.getAllActiveQuestionPapersForUserInLiveClass(ClassroomContext.userVO.userId,getAllActiveQuestionPapersForUserResultHandler,QuizContext.YES);
	}
	else
	{
		// When the root Question Paper is selected ,
		// we can only create new question paper .
		//Fix for Bug#16121
		setAddButtonEnabled(true) ;		
		// Set the canvas and tree component height as constant for
		// different screen resolutions .
		heightForCanComponent = 100 ;
		heightForQpTree = 95 ;
		
		questionPaperHelper.getAllActiveQuestionPapersForUserInLiveClass(ClassroomContext.userVO.userId,getAllActiveQuestionPapersForUserResultHandler);
	}
	canComponents.percentHeight=heightForCanComponent ;
	qpTree.percentHeight=heightForQpTree ;
	
	questionPaperACForTree=new ArrayCollection();
	questionPapers = new ArrayCollection();
	questionPaperACForTree.addItem({label: QuizContext.ROOT_TREE_QUESTION_PAPER, children: new ArrayCollection});
	questionPaperACForTree.refresh();
	qpTree.expandItem(questionPaperACForTree[0], true);
	// To keep focus on root of the tree component, set the index to 0
	qpTree.selectedIndex=0;
	
	// When the root Question paper is selected
	// we cannot edit or delete question papers .
	setDeleteButtonEnabled(false) ;
	setEditButtonEnabled(false) ;	
}

/**
 * @public
 * Retrieves the list of active question paper for the logged in user
 * @param result type of ArrayCollection
 * @return void
 */
public function getAllActiveQuestionPapersForUserResultHandler(event:ResultEvent):void
{
	questionPapers.removeAll() ;
	if(event.result != null)
	{	
		ArrayCollectionUtil.copyData(questionPapers , event.result as ArrayCollection) ;
		questionPaperACForTree[0].children=questionPapers
		questionPaperACForTree.refresh();
		qpTree.invalidateList();
		qpTree.expandItem(questionPaperACForTree[0], true);
		qpTree.selectedIndex=0;
		showQuestionPaperSummary();
	}	
}

/**
 * @public
 * Handles the result after a question paper is deleted
 *
 * @return void
 */
public function deleteQuestionPaperResultHandler():void
{
	questionPaperACForTree[0].children.removeItemAt(qpTree.selectedIndex - 1);
	qpTree.invalidateList();
	qpTree.selectedIndex=0;	
	//Fix for Bug #11369
	CustomAlert.info("Question paper deleted successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
	var questionPaperSummary:QuestionPaperSummary=new QuestionPaperSummary;
	questionPaperSummary.questionPapers=questionPapers
	canComponents.removeAllChildren();
	canComponents.addChild(questionPaperSummary);
	setAddButtonEnabled(true) ;	
	//Fix for Bug # 10950
	setEditButtonEnabled(false) ;
	setDeleteButtonEnabled(false) ;	
}

/**
 * @private
 * Displays the tool tip for the tree component as hovering
 * question paper name
 * @param item type of Object
 * @return String
 *
 */
private function showToolTip(item:Object):String
{
	var qpName:String = "" ;
	// Check if the item is a question paper value object
	if (item is QuestionPaperVO)
	{
		//  Check if the length of question paper name exceeds 
		// QuizContext.questionPaperNameLength 
		if (item.questionPaperName.length > QuizContext.textLengthForTree)
		{
			qpName = item.questionPaperName;
		}
	}
	return qpName;
}

/**
 * @private
 * Displays the summary of all active question papers
 *
 * @return void
 */
private function showQuestionPaperSummary():void
{
	/* Instance of QuestionPaperSummary */
	var questionPaperSummary:QuestionPaperSummary=new QuestionPaperSummary;
	
	//Fix for Bug #10898
	
	// Gets questions paper , after validation ,to show updated question paper list
	if (QuizContext.isValidated && !ClassroomContext.checkIsClassRoom)
	{
		questionPaperHelper.getAllActiveQuestionPapersForUser(ClassroomContext.userVO.userId,getAllActiveQuestionPapersForUserResultHandler);
		QuizContext.isValidated=false;
	}
	questionPaperSummary.questionPapers=questionPapers ; // instead call public function and set the array collection
	canComponents.removeAllChildren();
	canComponents.addChild(questionPaperSummary);
}

/**
 * @private
 * Used to determine the label of each node in the tree component
 * @param item type of Object
 * @return String
 *
 */
private function getLabelForTreeNode(item:Object):String
{	
	var qpName:String = "" ;
	// Get question paper name , if the passed parameter if question paper value object
	// else return the label of the object , in case of the root node
	if (item is QuestionPaperVO)
	{
		qpName = item.questionPaperName;
	}
	else if (item is Object)
	{
		qpName = item.label;
	}
	return qpName;
}

/**
 * Set the btnAdd as visible and includeInLayout 
 * @param flag type of Boolean
 * 
 */
private function setAddButtonVisible(flag:Boolean) :void{
	btnAdd.visible = flag ;
	btnAdd.includeInLayout = flag ;
}

/**
 * Set btnEdit as visible and includeInLayout 
 * @param flag type of Boolean
 * 
 */
private function setEditButtonVisible(flag:Boolean) :void
{
	btnEdit.visible = flag ;
	btnEdit.includeInLayout = flag ;
}

/**
 * Set btnDelete as visible and includeInLayout 
 * @param flag type of Boolean
 * 
 */
private function setDeleteButtonVisible(flag:Boolean) :void{
	btnDelete.visible = flag ;
	btnDelete.includeInLayout = flag ;
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
 * Handles the single click event on the tree component
 * @param event type of Event
 * @return void
 */
private function qpTreeOnClick(event:Event):void
{
	// Disable opening an editor on clicking item renderer
	qpTree.editable=false;
	
	/* Value Object */
	var tempQuestionPaperVO:QuestionPaperVO;
	
	// If the current node in tree is question paper value object
	if (event.currentTarget.selectedItem is QuestionPaperVO)
	{
		//Fix for Bug#10998
		tempQuestionPaperVO = ObjectUtil.copy(event.currentTarget.selectedItem) as QuestionPaperVO;
		// For live classroom , question paper viewing
		if (ClassroomContext.checkIsClassRoom)
		{
			/*
			* In Live classroom
			* To give question paper preview when clicking question paper from question paper list.
			*/
			setAddButtonEnabled(!ClassroomContext.checkIsClassRoom) ;
			setDeleteButtonEnabled(!ClassroomContext.checkIsClassRoom) ;
			setEditButtonEnabled(!ClassroomContext.checkIsClassRoom) ;			
			
			// Display an error if the question paper is incomplete
			if (tempQuestionPaperVO.isComplete == QuizContext.NO)
			{
				//Fix for Bug #11375
				CustomAlert.error("The selected question paper is not valid, Please validate.", "Information", null, this);
				return;
			}
			
			var qpQuestionsPreview:LiveQuestionPaperPreview=new LiveQuestionPaperPreview;
			
			canComponents.removeAllChildren();
			// setting the height and width for preview component
			qpQuestionsPreview.percentWidth=100;
			canComponents.addChild(qpQuestionsPreview);
			qpQuestionsPreview.initLiveQPPreview(tempQuestionPaperVO);
		}
		// For normal quiz mode , question paper component viewing
		else
		{
			// When the root Question paper is selected
			// we cannot edit or delete question papers .
			setAddButtonEnabled(ClassroomContext.checkIsClassRoom) ;
			setDeleteButtonEnabled(!ClassroomContext.checkIsClassRoom) ;
			setEditButtonEnabled(!ClassroomContext.checkIsClassRoom) ;			
			
			var qpQuestionsView:QuestionPaperQuestions=new QuestionPaperQuestions;
			qpQuestionsView.questionPaperVO=tempQuestionPaperVO;
			qpQuestionsView.addEventListener(UpdateQuestionPaperVOEvent.TREE_UPDATED, updatedTree);
			canComponents.removeAllChildren();
			canComponents.addChild(qpQuestionsView);
			qpQuestionsView.initQPQ();
		}
	}
	// If the current node is root node
	else
	{
		//To disable btnAdd when it is within the classroom.
		setAddButtonEnabled(!ClassroomContext.checkIsClassRoom) ;
		setDeleteButtonEnabled(ClassroomContext.checkIsClassRoom) ;
		setEditButtonEnabled(ClassroomContext.checkIsClassRoom) ;		
		showQuestionPaperSummary();
	}
}

/**
 * @private
 * Updates the tree if the 'treeUpdated' event is thrown
 * @param event type of UpdateQuestionPaperVOEvent
 * @return void
 */
private function updatedTree(event:UpdateQuestionPaperVOEvent):void
{
	if(Log.isInfo()) log.info(""+event);
	var questionPaperVO:QuestionPaperVO =event.qpVO;
	
	/* the open items of tree */
	var tempOpen:Object;
	
	/* the selected object in tree */
	var selectedObj:Object;
	
	// If qpTree has data only then update the new value
	if (qpTree != null)
	{
		tempOpen=qpTree.openItems;
		selectedObj=qpTree.selectedItem;
		if(Log.isInfo()) log.info(""+qpTree.selectedItem);
		
		// data provider of tree
		var tmp:ArrayCollection=qpTree.dataProvider as ArrayCollection;
		
		// the node children of the tree
		var tmp1:ArrayCollection=tmp.getItemAt(0).children;
		
		// index of a question paper
		var index:int;
		
		// loop index variable
		var i:int;
		// filter through the tree's dataprovider
		var qp:QuestionPaperVO = null ;
		for (i=0; i < tmp1.length; i++)
		{
			qp = tmp1[i] as QuestionPaperVO;
			
			 //to set the selected item	 as the updated item
			if (qp.questionPaperId == questionPaperVO.questionPaperId)
			{
				qp=questionPaperVO;
				index=i;
				tmp1.setItemAt(qp, i);
				break;
			}
		}
		
		qpTree.dataProvider=tmp;
		qpTree.dataProvider.refresh();
		qpTree.openItems=qpTree.dataProvider;	
		var qp1:QuestionPaperVO=tmp.getItemAt(0).children.getItemAt(index) as QuestionPaperVO;
		// this will refresh the display of tree component , without collapsing the nodes		
		qpTree.callLater(function():void
		{
			qpTree.selectedIndex=tmp.getItemAt(0).children.getItemIndex(qp1) + 1; //index you want
		});				
	}
}

/**
 * @private
 * Opens the edit dialog for the tree node
 * @param e type of Event
 * @return void
 */
private function qpTreeOnDoubleClick(e:Event):void
{
	//Fix for Bug#16954
	if (e.currentTarget.selectedItem is QuestionPaperVO)
	{
		btnEdit.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}
}

/**
 * @private
 * Pops up input box component for creating
 * a question paper
 *
 * @return void
 */
private function addQuestionPaper():void
{
	if(Log.isDebug()) log.debug("addQuestionPaper");
	var qpInputBox : QuestionPaperInputBox =QuestionPaperInputBox(PopUpManager.createPopUp(this, QuestionPaperInputBox, true));
	PopUpManager.centerPopUp(qpInputBox);		
	qpInputBox.questionPapersAC = questionPaperACForTree ;
	qpInputBox.addEventListener(EvaluationEvent.CREATE_OR_UPDATE, createQuestionPaper) ;	
}

/**
 * @private
 * Creates a new question paper
 * @param event type of EvaluationEvent
 * @return void
 */
private function createQuestionPaper(event:EvaluationEvent):void
{
	if(event.data != null)
	{
		//Fix for Bug #11369
		CustomAlert.info("Question paper created successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);
		var questionPaperVO:QuestionPaperVO = event.data as QuestionPaperVO;
		qpTree.selectedItem.children.addItem(questionPaperVO);
		qpTree.invalidateList();
		qpTree.expandItem(qpTree.selectedItem, true);
	}	
}

/**
 * @private
 * Pops up input box component for editing
 * a question paper
 *
 * @return void
 */
private function editQuestionPaper():void
{
	if(Log.isDebug()) log.debug("editQuestionPaper::myTree.selectedItem::" + qpTree.selectedItem);
	
	// Display an error if a question paper is not selected while editing
	if (qpTree.selectedIndex == 0 || qpTree.selectedItem == null)
	{
		CustomAlert.error("Please a question paper for editing.", "Error", null, this);
		return;
	}
	var questionPaperVO:QuestionPaperVO = qpTree.selectedItem as QuestionPaperVO;
	var qpInputBox:QuestionPaperInputBox =QuestionPaperInputBox(PopUpManager.createPopUp(this, QuestionPaperInputBox, true));	
	qpInputBox.questionPaperVO = questionPaperVO ;
	qpInputBox.questionPapersAC = questionPaperACForTree ;		
	PopUpManager.centerPopUp(qpInputBox);	
	qpInputBox.addEventListener(EvaluationEvent.CREATE_OR_UPDATE , updateQuestionPaper) ;
}

/**
 * @private
 * Updates an existing question paper
 * @param event type of EvaluationEvent
 * @return void
 */
private function updateQuestionPaper(event:EvaluationEvent):void
{
	if(event.data != null)
	{
		//Fix for Bug #11369
		CustomAlert.info("Question paper updated successfully.", QuizContext.ALERT_TITLE_INFORMATION, null, this);		
		showQuestionPaperSummary();
		qpTree.dataProvider.itemUpdated(qpTree.editedItemRenderer);		
		qpTree.invalidateList();
	}	
		/*
		//Fix for Bug #11264
		
		QPTree.selectedIndex = 0;
		btnAdd.enabled=true;
		btnEdit.enabled=false;
		btnDelete.enabled=false;*/	
}

/**
 * @private
 * Pops a confirmation dialog , while attempting to delete a question paper
 *
 * @return void
 */
private function onDeleteQP():void
{
	// Display a delete confirmation box ,only if selected items length is greater than 0
	if ((questionPaperACForTree[0].children.length > 0) && (qpTree.selectedItem is QuestionPaperVO))
	{
		CustomAlert.confirm("Do you want to delete this question paper?", "Confirmation", deleteQPHandler, this);
	}
}

/**
 * @private
 * Handles the delete confirmation dialog
 * @param event type of CloseEvent
 * @return void
 */
private function deleteQPHandler(event:CloseEvent):void
{
	// Call delete node , only if the user confirms the deletion
	if (event.detail == Alert.YES)
	{
		var questionPaperVO:QuestionPaperVO=qpTree.selectedItem as QuestionPaperVO;
		questionPaperHelper.deleteQuestionPaper(questionPaperVO.questionPaperId, ClassroomContext.userVO.userId,deleteQuestionPaperResultHandler);
	}
}
