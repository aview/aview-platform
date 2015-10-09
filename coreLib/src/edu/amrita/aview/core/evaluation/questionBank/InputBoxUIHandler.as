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
 * File			: InputBoxUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * InputBoxUIHandler acts as handler for InputBox.mxml
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.helper.QbCategoryHelper;
import edu.amrita.aview.core.evaluation.helper.QbSubcategoryHelper;
import edu.amrita.aview.core.evaluation.vo.QbCategoryVO;
import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.ListEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.utils.StringUtil;

/**
 * Variable to check whether category or subcategory
 */
public var isCategory : Boolean = true;

/**
 * Variable to check whether category or subcategory
 */
public var questionBankData : ArrayCollection = null;

/**
 * Variable to check whether category or subcategory
 */
public var categoryId : Number = 0;

/**
 * The Value Object variable of QbSubcategoryVO
 */
public var qbSubcategoryVO : QbSubcategoryVO = null;

/**
 * The Value Object variable of QbCategoryVO
 */
public var qbCategoryVO:QbCategoryVO = null;

/**
 * The QbSubcategoryHelper object
 */
private var qbSubcategoryHelper : QbSubcategoryHelper;

/**
 * The QbCategoryHelper object
 */
private var qbCategoryHelper:QbCategoryHelper;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.questionBank.InputBoxUIHandler.as");
/**
 * @public
 * Function : createQbCategoryResultHandler
 * Handles result after creating question bank Category.
 * @param result type of QbCategoryVO
 * @return void
 *
 */
public function createQbCategoryResultHandler(result:QbCategoryVO):void
{
	if(Log.isInfo()) log.info("createQbCategory_resultHandler::result::" + result);
	closeInputBoxWindow(result);
}

/**
 * @public
 * Function : createQbCategoryFaultHandler
 * Handles fault after creating question bank Category.
 * @param event type of FaultEvent
 * @return void
 *
 */
public function createQbCategoryFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionBank::InputBoxUIHandler::createQbCategoryFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/**  Holds the fault string*/
	var strMsg:String=event.fault.faultString;
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Category Name already exists in the institute. Please try with another category name", QuizContext.ALERT_TITLE_ERROR, null, this);
		//Fix for Bug#16735
		qbCategoryVO =null;
	}
	else if (strMsg.indexOf("Please enter a different category name") != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Polling cannot be a category name . Please try with another category name", QuizContext.ALERT_TITLE_ERROR, null, this);
		//Fix for Bug#16735
		qbCategoryVO =null;
	}
	else
	{
		qbCategoryHelper.genericFaultHandler(event);
		closeInputBoxWindow();
	}
}

/**
 * @public
 * Function : createQbSubcategoryResultHandler
 * Handles result after creating question bank subcategory.
 * @param result type of QbSubcategoryVO
 * @return void
 *
 */
public function createQbSubcategoryResultHandler(result:QbSubcategoryVO):void
{
	if(Log.isInfo()) log.info("createQbSubcategory_resultHandler::result::" + result);
	var newQbSubcategoryVO:QbSubcategoryVO = result;
	ClassroomContext.quizSubCategories.addItem(newQbSubcategoryVO);
	closeInputBoxWindow(result);
}

/**
 * @public
 * Function : createQbSubcategoryFaultHandler
 * Handles fault after creating question bank subcategory.
 * @param event type of FaultEvent
 * @return void
 *
 */
public function createQbSubcategoryFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionBank::InputBoxUIHandler::createQbSubcategoryFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/* To hold fault string message */
	var strMsg:String = event.fault.faultString;
	
	//Checking fault string message and showing appropriate error message.	 
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		enableDisableCreateButton(true);
		// Fix for bug #19946
		qbSubcategoryVO = null;
		CustomAlert.error("SubCategory Name already exists in the institute. Please try with another subcategory name", QuizContext.ALERT_TITLE_ERROR, null, this);
	}
	else if (strMsg.indexOf("Please enter a different sub category name") != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Polling cannot be a subcategory name . Please try with another subcategory name", QuizContext.ALERT_TITLE_ERROR, null, this);
	}
	else
	{
		qbSubcategoryHelper.genericFaultHandler(event);
		closeInputBoxWindow();
	}
}

/**
 * @public
 * Function : updateQbCategoryResultHandler
 * Handles result after updating question bank Category.
 * @param result type of QbCategoryVO
 * @return void
 *
 */
public function updateQbCategoryResultHandler(result:QbCategoryVO):void
{
	if(Log.isInfo()) log.info("updateQbCategory_resultHandler::result::" + result);
	closeInputBoxWindow(result);					
}

/**
 * @public
 * Function : updateQbCategoryFaultHandler
 * Handles fault after updating question bank Category.
 * @param event type of FaultEvent
 * @return void
 *
 */
public function updateQbCategoryFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionBank::InputBoxUIHandler::updateQbCategoryFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/* To hold fault string message */
	var strMsg:String=event.fault.faultString;
	
	// Checking fault string message and showing appropriate error message.	 
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Category Name already exists in the institute. Please try with another category name", QuizContext.ALERT_TITLE_ERROR, null, this);
		disableEditing(new ListEvent("d"));
	}
	else if (strMsg.indexOf("Please enter a different category name") != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Polling cannot be a category name . Please try with another category name", QuizContext.ALERT_TITLE_ERROR, null, this);
	}
	else
	{
		qbSubcategoryHelper.genericFaultHandler(event);
		closeInputBoxWindow();
	}
}

/**
 * @public
 * Function : updateQbSubcategoryResultHandler
 * Handles result after updating question bank subcategory.
 * @param result type of QbSubcategoryVO
 * @return void
 *
 */
public function updateQbSubcategoryResultHandler(result:QbSubcategoryVO):void
{
	//update the array collection
	for (var i:int=0; i < ClassroomContext.quizSubCategories.length; i++)
	{
		if (ClassroomContext.quizSubCategories.getItemAt(i).qbCategoryId == result.qbCategoryId)
		{
			ClassroomContext.quizSubCategories.removeItemAt(i);
			ClassroomContext.quizSubCategories.addItemAt(result, i);
			break;
		}
	}
	closeInputBoxWindow(result);
}

/**
 * @public
 * Function : updateQbSubcategoryFaultHandler
 * Handles fault after updating question bank subcategory.
 * @param event type of FaultEvent
 * @return void
 *
 */
public function updateQbSubcategoryFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionBank::InputBoxUIHandler::updateQbSubcategoryFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/* To hold fault string message */
	var strMsg:String=event.fault.faultString;
	
	// Checking fault string message and showing appropriate error message.	
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Category Name already exists in the institute. Please try with another category name", QuizContext.ALERT_TITLE_ERROR, null, this);
	}
	else if (strMsg.indexOf("Please enter a different sub category name") != -1)
	{
		enableDisableCreateButton(true);
		CustomAlert.error("Polling cannot be a subcategory name . Please try with another subcategory name", QuizContext.ALERT_TITLE_ERROR, null, this);
	}
	else
	{
		qbSubcategoryHelper.genericFaultHandler(event);
		closeInputBoxWindow();
	}
}

/**
 * @private
 * Function : closeInputBoxWindow Click handler for Cancel button.
 * To close this UI component.
 *
 * @return void
 */
private function closeInputBoxWindow(result:Object = null):void 
{
	this.dispatchEvent(new EvaluationEvent(EvaluationEvent.CREATE_OR_UPDATE,result));
	PopUpManager.removePopUp(this);
	
}

/**
 * @private
 * Function : onCreationComplete Handler for CreationComplete event
 *
 * @return void
*/
private function onCreationComplete():void 
{
	if(!isCategory)
	{
		labelMessage.text = "Subcategory Name:";
	}
	txtQBName.setFocus();
	qbCategoryHelper=new QbCategoryHelper();
	qbSubcategoryHelper=new QbSubcategoryHelper();
}

/**
 * @private
 * Function : saveButtonClickHandler
 * Save button click handler
 *
 * @param event type of MouseEvent
 * @return void
 */
private function saveButtonClickHandler(event:MouseEvent):void
{
	if(isCategory)
	{
		createOrUpdateCategory();
	}
	else
	{
		createOrUpdateSubcategory();
	}
}

/**
 * @private
 * Function : createOrUpdateCategory
 * To create or update a question bank category.
 * @param event type of Event
 * @return void
 *
 */
private function createOrUpdateCategory():void
{
	enableDisableCreateButton(false);
	/**
	 * To hold new category name
	 */
	var newCategoryName:String = txtQBName.text;
	
	//Creating Category
	if(qbCategoryVO == null)
	{
		// Check if the category name is null or empty
		if (StringUtil.trim(newCategoryName) == null || StringUtil.trim(newCategoryName) == "")
		{
			//Fix for Bug#9525
			txtQBName.setFocus();
			CustomAlert.error("Please give a new and unique name to the category and try again.", QuizContext.ALERT_TITLE_ERROR, null, this);
			enableDisableCreateButton(true);
			return;
		}
		qbCategoryVO=new QbCategoryVO;
		qbCategoryVO.qbCategoryName=StringUtil.trim(txtQBName.text);
		qbCategoryVO.createdByUserName=ClassroomContext.userVO.userName;
		qbCategoryVO.modifiedByUserName=ClassroomContext.userVO.userName;
		qbCategoryVO.totalQuestions=0;
		qbCategoryHelper.createQbCategory(qbCategoryVO, ClassroomContext.userVO.userId,createQbCategoryResultHandler,createQbCategoryFaultHandler);
	}
	//Editing Category
	else
	{
		/**
		 * To hold old category name ie,name before editing
		 */	
		var oldCatName:String = qbCategoryVO.qbCategoryName;
		var i:int;
		
		// Validating user input value	
		if (StringUtil.trim(newCategoryName) == null || StringUtil.trim(newCategoryName) == "")
		{
			enableDisableCreateButton(true);
			qbCategoryVO.qbCategoryName = oldCatName;
			CustomAlert.error("Please give a new and unique name to the Category and try again.", QuizContext.ALERT_TITLE_ERROR, null, this);		
			return;
			
		}
		
		// If old category name and new name is same
		if (StringUtil.trim(oldCatName).localeCompare(StringUtil.trim(newCategoryName)) == 0)
		{
			qbCategoryVO.qbCategoryName = oldCatName;
			CustomAlert.info("Category updated successfully.", QuizContext.ALERT_TITLE_INFORMATION , null, this);
			closeInputBoxWindow();
			return;
		}
		
		// Check if new category name already exist in question bank
		for (i=0; i < questionBankData[0].children.length; i++)
		{
			// Fix for Bug #10681
			if ((StringUtil.trim(newCategoryName).toLowerCase().localeCompare(StringUtil.trim(oldCatName).toLowerCase()) != 0) && questionBankData[0].children[i].qbCategoryName.toLowerCase().localeCompare(StringUtil.trim(newCategoryName).toLowerCase()) == 0)
			{
				// Fix for Bug #16853
				enableDisableCreateButton(true);
				CustomAlert.error("Category Name already exists in institute. Please try with another category name", QuizContext.ALERT_TITLE_ERROR, null, this);
				return;
			}
		}
		
		// Set value to qbCategoryVO
		qbCategoryVO.qbCategoryName = StringUtil.trim(txtQBName.text);
		
		// Server call to update question bank category 
		qbCategoryHelper.updateQbCategory(qbCategoryVO, ClassroomContext.userVO.userId,updateQbCategoryResultHandler,updateQbCategoryFaultHandler);
	}
}

/**
 * @private
 * Function : createOrUpdateSubcategory
 * To create or update question bank sub category.
 * @param event type of Event
 * @return void
 *
 */
private function createOrUpdateSubcategory():void
{
	//Creating SubCategory
	if(qbSubcategoryVO == null)
	{
		enableDisableCreateButton(false);
		var newSubCategoryName:String = txtQBName.text;
		// Check if subcategory name is null or empty
		if (StringUtil.trim(newSubCategoryName) == null || StringUtil.trim(newSubCategoryName) == "")
		{
			CustomAlert.error("Please give a new and unique name to the SubCategory and try again.", QuizContext.ALERT_TITLE_ERROR, null, this);
			txtQBName.setFocus();
			enableDisableCreateButton(true);
			return;
		}
		qbSubcategoryVO = new QbSubcategoryVO;
		qbSubcategoryVO.qbSubcategoryName = StringUtil.trim(txtQBName.text);
		qbSubcategoryVO.qbCategoryId = categoryId;
		qbSubcategoryVO.createdByUserName = ClassroomContext.userVO.userName;
		qbSubcategoryVO.modifiedByUserName = ClassroomContext.userVO.userName;
		qbSubcategoryHelper.createQbSubcategory(qbSubcategoryVO, ClassroomContext.userVO.userId,createQbSubcategoryResultHandler,createQbSubcategoryFaultHandler);
	}
	//Editing SubCategory
	else
	{
		enableDisableCreateButton(false);
		
		// To hold old subcategory name ie,name before editing
		
		var oldSubCatName:String = qbSubcategoryVO.qbSubcategoryName;
		var i:int, j:int;
		//  To hold new subcategory name
		
		var newName:String = txtQBName.text;
		
		// Validating user input value
		if (StringUtil.trim(newName) == null || StringUtil.trim(newName) == "")
		{
			enableDisableCreateButton(true);
			qbSubcategoryVO.qbSubcategoryName = oldSubCatName;
			CustomAlert.error("Please give a new and unique name to the SubCategory and try again.", QuizContext.ALERT_TITLE_ERROR, null, this);
			return;
		}
		// If old subcategory name and new name is same
		if (StringUtil.trim(oldSubCatName).localeCompare(StringUtil.trim(newName)) == 0)
		{
			qbSubcategoryVO.qbSubcategoryName = oldSubCatName;
			CustomAlert.info("SubCategory updated successfully", QuizContext.ALERT_TITLE_INFORMATION , null, this);
			closeInputBoxWindow();
			return;
		}
		// Check if new subcategory name already exist in same category
		for (i = 0; i < questionBankData[0].children.length; i++)
		{
			if (questionBankData[0].children[i].qbCategoryId == categoryId)
			{
				for (j = 0; j < questionBankData[0].children[i].children.length; j++)
				{
					// Fix for Bug #10682
					if ((StringUtil.trim(newName).toLowerCase().localeCompare(StringUtil.trim(oldSubCatName).toLowerCase()) != 0) && questionBankData[0].children[i].children[j].qbSubcategoryName.toLowerCase().localeCompare(StringUtil.trim(newName).toLowerCase()) == 0)
					{
						enableDisableCreateButton(true);
						CustomAlert.error("SubCategory Name already exists in the institute. Please try with another subcategory name", QuizContext.ALERT_TITLE_ERROR, null, this);
						return;
					}
				}
			}
		}
		qbSubcategoryVO.qbSubcategoryName = txtQBName.text;
		qbSubcategoryVO.modifiedDate = new Date;
		
		// Server call to update question bank subcategory
		qbSubcategoryHelper.updateQbSubcategory(qbSubcategoryVO, ClassroomContext.userVO.userId,updateQbSubcategoryResultHandler,updateQbSubcategoryFaultHandler);		
	}
}


/**
 * @private
 * Function : disableEditing
 * To disable editing
 * @param event type of ListEvent
 * @return void
 *
 */
private function disableEditing(event:ListEvent):void
{
	// prevent editing of row , which was detected as duplicate data
	if (event.rowIndex == 0)
	{
		event.preventDefault();
	}
}
/**
 * @private
 * Function : enableDisableCreateButton
 * To enable/disable save button.
 * 
 * @param flag type of Boolean
 * @return void
 *
 */
private function enableDisableCreateButton(flag:Boolean):void
{
	btnSave.enabled=flag;
}