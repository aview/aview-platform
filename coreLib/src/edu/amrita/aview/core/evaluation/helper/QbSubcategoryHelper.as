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
 * File			: QbSubcategoryHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.evaluation.vo.QbSubcategoryVO;

	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	/**
	 *
	 * @public
	 * QbSubcategoryHelper
	 * extends AbstractHelper
	 * QbSubcategoryHelper class is used to call the remote java methods
	 */
	public class QbSubcategoryHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var qbSubcategoryRO:RemoteObject=null;


		/**
		 *
		 * @public
		 * QbSubcategoryHelper
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QbSubcategoryHelper() {
			qbSubcategoryRO=new RemoteObject();
			qbSubcategoryRO.destination="qbsubcategoryhelper";
			qbSubcategoryRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			qbSubcategoryRO.showBusyCursor=true;

			qbSubcategoryRO.getAllActiveQbSubcategoriesSummaryForCategory.addEventListener(ResultEvent.RESULT, getAllActiveQbSubcategoriesSummaryForCategoryResultHandler);
			qbSubcategoryRO.getAllActiveQbSubcategoriesSummaryForCategory.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbSubcategoryRO.createQbSubcategory.addEventListener(ResultEvent.RESULT, createQbSubcategoryResultHandler);
			qbSubcategoryRO.createQbSubcategory.addEventListener(FaultEvent.FAULT, createQbSubcategoryFaultHandler);

			qbSubcategoryRO.updateQbSubcategory.addEventListener(ResultEvent.RESULT, updateQbSubcategoryResultHandler);
			qbSubcategoryRO.updateQbSubcategory.addEventListener(FaultEvent.FAULT, updateQbSubcategoryFaultHandler);

			qbSubcategoryRO.deleteQbSubcategory.addEventListener(ResultEvent.RESULT, deleteQbSubcategoryResultHandler);
			qbSubcategoryRO.deleteQbSubcategory.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbSubcategoryRO.getAllActiveQbSubcategoriesForUser.addEventListener(ResultEvent.RESULT, getAllActiveQbSubcategoriesForUserResultHandler);
			qbSubcategoryRO.getAllActiveQbSubcategoriesForUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 *
		 * @public
		 * getAllActiveQbSubcategoriesSummaryForCategory
		 * Calls the remote server to get all active(not deleted) sub categories in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param categoryId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQbSubcategoriesSummaryForCategory(categoryId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbSubcategoryRO.getAllActiveQbSubcategoriesSummaryForCategory(categoryId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveQbSubcategoriesSummaryForCategoryResultHandler
		 * Result Handler for getting all active(not deleted) sub categories in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQbSubcategoriesSummaryForCategoryResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * createQbSubcategory
		 * Calls the remote server to create a sub category in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param subcategoryVO type of QbSubcategoryVO
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function createQbSubcategory(subcategoryVO:QbSubcategoryVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbSubcategoryRO.createQbSubcategory(subcategoryVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * createQbSubcategoryResultHandler
		 * Result Handler for creating a sub category in Question Bank
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function createQbSubcategoryResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}


		/**
		 *
		 * @private
		 * createQbSubcategoryFaultHandler
		 * Fault Handler for creating a sub category in Question Bank
		 *
		 * @param event of fault
		 * @return void
		 *
		 */
		private function createQbSubcategoryFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @public
		 * updateQbSubcategory
		 * Calls the remote server to update a  sub category in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param subcategoryVO type of QbSubcategoryVO
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function updateQbSubcategory(subcategoryVO:QbSubcategoryVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbSubcategoryRO.updateQbSubcategory(subcategoryVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * updateQbSubcategoryResultHandler
		 * Result Handler for updating a  sub category in Question Bank
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function updateQbSubcategoryResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * updateQbSubcategoryFaultHandler
		 * Fault Handler for updating a  sub category in Question Bank
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function updateQbSubcategoryFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @public
		 * deleteQbSubcategory
		 * Calls the remote server to delete a sub category in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param subcategoryId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function deleteQbSubcategory(subcategoryId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbSubcategoryRO.deleteQbSubcategory(subcategoryId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * deleteQbSubcategoryResultHandler
		 * Result Handler for deleting a sub category in Question Bank
		 *
		 * @param event result
		 * @return void
		 *
		 */
		private function deleteQbSubcategoryResultHandler(event:ResultEvent):void {
			event.token.onResult();
		}

		/**
		 *
		 * @public
		 * getAllActiveQbSubcategoriesForUser
		 * Calls the remote server to get all active sub categories for a user in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQbSubcategoriesForUser(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbSubcategoryRO.getAllActiveQbSubcategoriesForUser(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveQbSubcategoriesForUserResultHandler
		 * Result Handler for getting all active sub categories for a user in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQbSubcategoriesForUserResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}
	}
}
