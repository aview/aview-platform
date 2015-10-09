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
 * File			: CategoryViewUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S, Sivaram SK
 *
 * CategoryViewUIHandler acts as handler for CategoryView.mxml
 */
import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;

import edu.amrita.aview.core.shared.util.AViewStringUtil;
import edu.amrita.aview.core.evaluation.vo.QbCategoryVO;
/**
 * set by the calling code segment */
[Bindable]
public var subCategories:ArrayCollection;
/**
 * set by the calling code segment */
[Bindable]
public var categoryVO:QbCategoryVO;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.questionBank.CategoryViewUIHandler.as");

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
 * Function : formatModifiedDate To format modified date
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
*/
private function formatModifiedDate(oItem:Object, iCol:int):String {
	if(Log.isDebug()) log.debug("formatDate::iCol::" + iCol);
	return dateFormatter.format(oItem.modifiedDate);
}
