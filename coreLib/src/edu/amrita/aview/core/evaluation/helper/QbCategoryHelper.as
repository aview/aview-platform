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
 * File			: QbCategoryHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.evaluation.vo.QbCategoryVO;

	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	/**
	 * QbCategoryHelper class is used to call the remote java methods
	 **/
	public class QbCategoryHelper extends AbstractHelper {

		/**
		 * Remote Object to call qbcategoryhelper.
		 */
		private var qbCategoryRO:RemoteObject=null;

		/**
		 *
		 * @public
		 * QbCategoryHelper
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QbCategoryHelper() {
			qbCategoryRO=new RemoteObject();
			qbCategoryRO.destination="qbcategoryhelper";
			qbCategoryRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			qbCategoryRO.showBusyCursor=true;

			qbCategoryRO.getAllActiveQbCategoriesForUser.addEventListener(ResultEvent.RESULT, getAllActiveQbCategoriesForUserResultHandler);
			qbCategoryRO.getAllActiveQbCategoriesForUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbCategoryRO.createQbCategory.addEventListener(ResultEvent.RESULT, createQbCategoryResultHandler);
			qbCategoryRO.createQbCategory.addEventListener(FaultEvent.FAULT, createQbCategoryFaultHandler);

			qbCategoryRO.updateQbCategory.addEventListener(ResultEvent.RESULT, updateQbCategoryResultHandler);
			qbCategoryRO.updateQbCategory.addEventListener(FaultEvent.FAULT, updateQbCategoryFaultHandler);

			qbCategoryRO.deleteQbCategory.addEventListener(ResultEvent.RESULT, deleteQbCategoryResultHandler);
			qbCategoryRO.deleteQbCategory.addEventListener(FaultEvent.FAULT, genericFaultHandler);


		}

		/**
		 *
		 * @private
		 * getAllActiveQbCategoriesForUserResultHandler
		 * Result Handler for getting all active(not deleted) categories for user in Question Bank
		 * @param event of type ResultEvent
		 * @return void
		 *
		 ***/
		private function getAllActiveQbCategoriesForUserResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * createQbCategoryResultHandler
		 * Result Handler for creating a category in Question Bank
		 * @param event of type ResultEvent
		 * @return void
		 *
		 ***/
		private function createQbCategoryResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * createQbCategoryFaultHandler
		 * Fault Handler for creating a category in Question Bank
		 * @param event of type FaultEvent
		 * @return void
		 *
		 ***/
		private function createQbCategoryFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @private
		 * updateQbCategoryResultHandler
		 * Result Handler for updating a category in Question Bank
		 * @param event of type ResultEvent
		 * @return void
		 *
		 ***/
		private function updateQbCategoryResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * updateQbCategoryFaultHandler
		 * Fault Handler for updating a category in Question Bank
		 * @param event of type FaultEvent
		 * @return void
		 *
		 ***/
		private function updateQbCategoryFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @private
		 * deleteQbCategoryResultHandler
		 * Result Handler for deleting a category in Question Bank
		 * @param event of type ResultEvent
		 * @return void
		 *
		 ***/
		private function deleteQbCategoryResultHandler(event:ResultEvent):void {
			event.token.onResult();
		}

		/**
		 *
		 * @public
		 * getAllActiveQbCategoriesForUser
		 * Calls the remote server to retrieve all active(not deleted) categories for user in Question Bank
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 ***/
		public function getAllActiveQbCategoriesForUser(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbCategoryRO.getAllActiveQbCategoriesForUser(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}


		/**
		 *
		 * @public
		 * createQbCategory
		 * Calls the remote server to create a category in Question Bank
		 * @param callerComp type of Object
		 * @param qbCategoryVO type of QbCategoryVO
		 * @param userId type of Number
		 * @return void
		 *
		 ***/
		public function createQbCategory(qbCategoryVO:QbCategoryVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbCategoryRO.createQbCategory(qbCategoryVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}


		/**
		 *
		 * @public
		 * updateQbCategory
		 * Calls the remote server to update a category in Question Bank
		 * @param callerComp type of Object
		 * @param qbCategoryVO type of QbCategoryVO
		 * @param userId type of Number
		 * @return void
		 *
		 ***/
		public function updateQbCategory(qbCategoryVO:QbCategoryVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbCategoryRO.updateQbCategory(qbCategoryVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * deleteQbCategory
		 * Calls the remote server to delete a category in Question Bank
		 * @param callerComp type of Object
		 * @param qbCategoryId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 ***/
		public function deleteQbCategory(qbCategoryId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbCategoryRO.deleteQbCategory(qbCategoryId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
	}
}
