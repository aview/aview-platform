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
 * File			: QuestionPaperSummaryUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * QuestionPaperSummaryUIHandler acts as handler for QuestionPaperSummary.mxml
 */


import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper;
import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.util.AViewStringUtil;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.components.gridClasses.GridColumn;

/**
 * List of question papers
 */
[Bindable]
public var questionPapers:ArrayCollection=new ArrayCollection;

/**
 * @private
 * Used to format date as "DD MMM YYYY H:N:S"
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function formatCreatedDate(oItem:Object, iCol:int):String
{
	return dateFormatter.format(oItem.createdDate);
}

/**
 * @private
 * Used to format date as "DD MMM YYYY H:N:S"
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 */
private function formatModifiedDate(oItem:Object, iCol:int):String
{
	return dateFormatter.format(oItem.modifiedDate);
}

/**
 * @private
 * Used to get the status of a question paper
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function getStatus(oItem:Object, iCol:int):String
{
	var status:String = null ;
	/* Value Object */
	var questionPaper:QuestionPaperVO=oItem as QuestionPaperVO;
	// Return 'Complete' if the question paper is complete
	if (questionPaper.isComplete == QuizContext.YES)
	{
		status = QuizContext.QUESTION_PAPER_COMPLETE_STATUS ;
	}
	// Return 'Incomplete' if the question paper is incomplete
	else if (questionPaper.isComplete == QuizContext.NO)
	{
		status = QuizContext.QUESTION_PAPER_INCOMPLETE_STATUS ;		
	}
	return status ;
}
//Fix for Bug#14821
//If sortCompare function doesn't exists(and labelFunction exists),it causes application crash when we click on that datagrid column.
//Fix for Bug#11216
//Both issues solved by adding datafield in grid column(Serial No:)
private function creationCompleteHandler():void
 {
	for(var i:int = 0;i < questionPapers.length;i++)
	{
		questionPapers[i].displayIndex = i+1;
	}
	questionPapers.refresh();
 }