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
 * File			: QuestionbankHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * This is a script for item editor in 'questionBankTree' Tree component, which is in 'QuestionBank.mxml'.
 */
import edu.amrita.aview.core.evaluation.vo.QbCategoryVO;
import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;
import edu.amrita.aview.core.entry.ClassroomContext;

import mx.logging.ILogger;
import mx.logging.Log;

/**
 * For debug log
 */
private var logger:ILogger=Log.getLogger("aview.modules.evaluation.questionBank.ItemEditorForQuestionBankTree.as");

/**
 * @private
 * To get text value for 'newQBName' TextInput in item editor.
 * @param item type of Object
 * @return String
 *
 */
private function getNodes(item:Object):String 
{
if(Log.isDebug())
	logger.debug("setNodes::item::" + item);
	//PNCR: Use switch instead of if-else, its more readable and has better performance
	if (item is QbCategoryVO) {
		return item.qbCategoryName;
	} else if (item is QbSubcategoryVO) {
		return item.qbSubcategoryName;
	} else if (item is Object) {
		return item.label;
	}
	return "";
}
