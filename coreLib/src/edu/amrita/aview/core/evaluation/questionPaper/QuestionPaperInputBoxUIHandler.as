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
 * File			: QuestionPaperInputBoxUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * 	QuestionPaperInputBoxUIHandler acts as handler for QuestionPaperInputBox.mxml
 * 
 * QP - Question Paper
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.event.EvaluationEvent;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.ValidationResultEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;
import mx.validators.NumberValidator;

/**
 * Used to create and edit a question paper 
 */
public var questionPaperVO:QuestionPaperVO ;

/**
 * List of question papers , to update the parent components list of question papers 
 */
public var questionPapersAC:ArrayCollection =null ;
/**
 * Used to call methods of QuestionPaperHelper
 */
private var questionPaperHelper:QuestionPaperHelper;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionPaper.QuestionPaperInputBoxUIHandler.as");


/**
 * Title for the component when a question paper is being edited 
 */
private const EDIT_QUESTION_PAPER:String = "Edit Question Paper" ;
/**
 * @private
 * Sets the focus on text component
 *
 * @return void
 *
 */
private function onCreationCompleteQPInputBox():void {
	txtInpQuestionPaperName.setFocus();	
	questionPaperHelper=new QuestionPaperHelper();
	
	if(questionPaperVO!= null && questionPaperVO.questionPaperId > 0)
	{
		this.title= EDIT_QUESTION_PAPER;
        if(Log.isDebug()) log.debug(""+ questionPaperVO) ;
		txtInpQuestionPaperName.text=questionPaperVO.questionPaperName;
		txtInpMaxTotalMarks.text=String(questionPaperVO.maxTotalMarks);	
	}	
}

protected function onClickBtnSave(event:MouseEvent):void
{
	// Call function for editing a question paper
	if (questionPaperVO != null && questionPaperVO.questionPaperId > 0)
	{		
		editQuestionPaper() ;
	}
	// Call the function for creating a question paper
	else
	{	
		createQuestionPaper() ;		
	}
}

/**
 * @private
 * Validates various fields while creating or updating a
 * question paper
 * @param validateFor type of String
 * @return Boolean
 *
 */
private function validateQP():Boolean
{
	/* Flag for validating(error) various fields of the question paper */
	var flagQP:Boolean=true;
	
	/* New value of question paper name */
	//Fix for Bug#16835
	var newQuestionPaperName:String=StringUtil.trim(txtInpQuestionPaperName.text);
	
	/* New value of total marks */
	var marks:Number=Number(txtInpMaxTotalMarks.text);
	
	/* Instance of number validator */
	var numberValidator:NumberValidator=new NumberValidator;
	
	/* Instance of validation result event*/
	var validationResult:ValidationResultEvent=numberValidator.validate(marks);
	
	/* To hold the error message while validating */
	var errorMessage:String = "";
	
	// Display error if the question paper name has empty or null string 
	if (StringUtil.trim(newQuestionPaperName) == null || StringUtil.trim(newQuestionPaperName) == "")
	{
		errorMessage+= "Please give a new and unique name to the QuestionPaper and try again.\n";
		txtInpQuestionPaperName.setFocus();
		flagQP=false;
	}
	
	// Display error if length of question paper name is greater than 60 , its maximum limit for this field in database
	if (StringUtil.trim(newQuestionPaperName).length > QuizContext.TEXT_LENGTH)
	{
		CustomAlert.error("Question Paper name  length is greater than 60 chars. Please try again with other question paper name", "Information", null, this);
		flagQP=false;
	}
	
	// Display error if negative or zero value is entered for marks
	if ((validationResult.type == ValidationResultEvent.INVALID) || (marks <= 0))
	{
		errorMessage += "Invalid value for marks.\n";
		flagQP=false;
	}
	
	// Check if validation is done during edit of a question paper
	if (questionPaperVO != null && questionPaperVO.questionPaperId > 0)
	{
		// Check if updated question paper name and new question paper name are same
		if (questionPaperVO.questionPaperName.localeCompare(newQuestionPaperName) == 0)
		{
			// if max total marks and marks are equal , display successful question paper updation
			if (questionPaperVO.maxTotalMarks == marks)
			{				
				//Fix for Bug #11369
				CustomAlert.info("Question paper updated successfully", "Information", null, this);
				PopUpManager.removePopUp(this);				
				flagQP=false;
			}
		}
		
		// Loop index variable
		var i:int;
		// Loop through the children nodes of the tree
		for (i=0; i < questionPapersAC[0].children.length; i++)
		{			
			// Fix for Bug #10683
			// Check for same question paper name for the new and existing values
			if ((newQuestionPaperName.toLowerCase().localeCompare(questionPaperVO.questionPaperName.toLowerCase()) != 0) && (questionPapersAC[0].children[i].questionPaperName.toLowerCase().localeCompare(newQuestionPaperName.toLowerCase()) == 0) && (questionPaperVO.maxTotalMarks == marks))
			{
				CustomAlert.error("Question Paper Name already exists in institute. Please try with another question paper name", "Information", null, this);
				flagQP=false;
			}
		}
	}	
	// Fix for Bug #15629
	if(errorMessage != "")
	{
		CustomAlert.error(errorMessage, QuizContext.ALERT_TITLE_ERROR, null, this);
	}
	
	return flagQP;
}

/**
 * @private
 * Function : closeQuestionPaperInputBox Click handler for Cancel button.
 * To close this UI component.
 *
 * @return void
 */
private function closeQuestionPaperInputBox(result:Object = null):void 
{
	this.dispatchEvent(new EvaluationEvent(EvaluationEvent.CREATE_OR_UPDATE,result));
	PopUpManager.removePopUp(this);
	
}

/**
 * Handles the result on creating a question paper 
 * @param event of type ResultEvent
 * 
 */
public function createQuestionPaperResultHandler(event:ResultEvent):void
{
	if(event.result != null)
	{	
		var qp:QuestionPaperVO = event.result as QuestionPaperVO ;
		if(Log.isInfo()) log.info(""+ qp) ;
		closeQuestionPaperInputBox(qp) ;
	}
}

/**
 * Handles the fault on creating a question paper 
 * @param event of type FaultEvent
 * 
 */
public function createQuestionPaperFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("evaluation::questionPaper::QuestionPaperInputBoxUIHandler::createQuestionPaperFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	/* fault msg */
	var strMsg:String=event.fault.faultString;
	
	// Display error , if the question paper already exists
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("Question Paper Name already exists in the institute. Please try with another question paper name", "Information", null, this);
	}
		// else exit the create question paper input box component
	else
	{
		questionPaperHelper.genericFaultHandler(event);
		closeQuestionPaperInputBox() ;
	}
}

/**
 * @public
 * Handles the result after a question paper is updated
 *
 * @return void
 */
public function updateQuestionPaperResultHandler():void
{	
	closeQuestionPaperInputBox(questionPaperVO) ;
}

/**
 * Calls the remote method for creating a question paper , 
 * only after validating the question paper 
 * 
 */
private function createQuestionPaper():void
{
	if(validateQP())
	{
		questionPaperVO=new QuestionPaperVO;		
		//Fix for Bug #11507
		questionPaperVO.questionPaperName=StringUtil.trim(txtInpQuestionPaperName.text);
		
		questionPaperVO.maxTotalMarks=Number(txtInpMaxTotalMarks.text);
		questionPaperVO.currentTotalMarks=0;
		questionPaperVO.isComplete=QuizContext.NO;
		questionPaperVO.createdByUserName=ClassroomContext.userVO.userName;
		questionPaperVO.modifiedByUserName=ClassroomContext.userVO.userName;
		questionPaperHelper.createQuestionPaper(questionPaperVO, ClassroomContext.userVO.userId,createQuestionPaperResultHandler,createQuestionPaperFaultHandler);
	}
}

/**
 * After validating a question paper , it calls the remote method
 * for updating a question paper 
 * 
 */
private function editQuestionPaper():void
{
	if (validateQP())
	{				
		// max total marks for question paper
		var marks:Number=Number(txtInpMaxTotalMarks.text);		
		// Fix for Bug #11507
		questionPaperVO.questionPaperName=StringUtil.trim(txtInpQuestionPaperName.text);
		questionPaperVO.maxTotalMarks=marks;			
		
		// If total marks and max total marks are not equal
		// set the question paper as incomplete
		if (questionPaperVO.currentTotalMarks != questionPaperVO.maxTotalMarks)
		{
			questionPaperVO.isComplete=QuizContext.NO;
		}
			// else set the question paper as complete
		else
		{
			questionPaperVO.isComplete=QuizContext.YES;
		}
		questionPaperHelper.updateQuestionPaper(questionPaperVO, ClassroomContext.userVO.userId,updateQuestionPaperResultHandler);
	}
}
