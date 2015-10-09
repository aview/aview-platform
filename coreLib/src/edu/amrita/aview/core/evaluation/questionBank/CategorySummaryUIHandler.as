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
 * File			: CategorySummaryUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * This component displays all the categories in the question bank
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.evaluation.QuizContext;
import edu.amrita.aview.core.shared.util.AViewStringUtil;

import mx.collections.ArrayCollection;

import spark.components.gridClasses.GridColumn;

/**
* @private
* Function : formatCreatedDate To format created date.
* @param oItem type of Object
* @param iCol type of int
* @return String

*/

private function formatCreatedDate(oItem:Object, iCol:int):String {
	return dateFormatter.format(oItem.createdDate);
}

/**
 * @private
 * Function : formatModifiedDate To format modified date.
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
*/
private function formatModifiedDate(oItem:Object, iCol:int):String {
	return dateFormatter.format(oItem.modifiedDate);
}
//Fix for Bug#14821
//If sortCompare function doesn't exists(and labelFunction exists),it causes application crash when we click on that datagrid column.
//Fix for Bug#11218
//Both issues solved by adding datafield in grid column(Serial No:)
private function initializeHandler():void
 {
	for(var i:int = 0;i < ClassroomContext.quizCategories.length;i++)
	{
		ClassroomContext.quizCategories[i].displayIndex = i+1;
	}
 }