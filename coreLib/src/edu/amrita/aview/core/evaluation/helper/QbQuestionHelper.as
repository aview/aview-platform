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
 * File			: QbQuestionHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	:
 */
package edu.amrita.aview.core.evaluation.helper {
	import edu.amrita.aview.core.evaluation.vo.QbQuestionVO;

	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;

	/**
	 *
	 * @public
	 * QbQuestionHelper
	 * extends AbstractHelper
	 * QbQuestionHelper class is used to call the remote java methods
	 */
	public class QbQuestionHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var qbQuestionHelperRO:RemoteObject=null;


		/**
		 *
		 * @public
		 * QbQuestionHelper
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QbQuestionHelper() {
			qbQuestionHelperRO=new RemoteObject();
			qbQuestionHelperRO.destination="qbquestionhelper";
			qbQuestionHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			qbQuestionHelperRO.showBusyCursor=true;

			qbQuestionHelperRO.getAllActiveQbQuestionsForSubcategory.addEventListener(ResultEvent.RESULT, getAllActiveQbQuestionsForSubcategoryResultHandler);
			qbQuestionHelperRO.getAllActiveQbQuestionsForSubcategory.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbQuestionHelperRO.createQbQuestion.addEventListener(ResultEvent.RESULT, createQbQuestionResultHandler);
			qbQuestionHelperRO.createQbQuestion.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbQuestionHelperRO.updateQbQuestion.addEventListener(ResultEvent.RESULT, updateQbQuestionResultHandler);
			qbQuestionHelperRO.updateQbQuestion.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbQuestionHelperRO.deleteQbQuestions.addEventListener(ResultEvent.RESULT, deleteQbQuestionsResultHandler);
			qbQuestionHelperRO.deleteQbQuestions.addEventListener(FaultEvent.FAULT, deleteQbQuestionsFaultHandler);

			qbQuestionHelperRO.getQbQuestions.addEventListener(ResultEvent.RESULT, getQbQuestionsResultHandler);
			qbQuestionHelperRO.getQbQuestions.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbQuestionHelperRO.getQbQuestionsForPolling.addEventListener(ResultEvent.RESULT, getQbQuestionsForPollingResultHandler);
			qbQuestionHelperRO.getQbQuestionsForPolling.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbQuestionHelperRO.createQbQuestionForPolling.addEventListener(ResultEvent.RESULT, createQbQuestionForPollingResultHandler);
			qbQuestionHelperRO.createQbQuestionForPolling.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 *
		 * @public
		 * getAllActiveQbQuestionsForSubcategory
		 * Calls the remote server to retrieve all active questions for sub category in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param subcategoryId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQbQuestionsForSubcategory(subcategoryId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.getAllActiveQbQuestionsForSubcategory(subcategoryId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveQbQuestionsForSubcategoryResultHandler
		 * Result Handler for retrieving all active questions for sub category in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQbQuestionsForSubcategoryResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * createQbQuestion
		 * This method creates question for a subcategory in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param qbQuestionVO type of QbQuestionVO
		 * @param answers type of ArrayCollection
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function createQbQuestion(qbQuestionVO:QbQuestionVO, answers:ArrayCollection, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.createQbQuestion(qbQuestionVO, answers, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * createQbQuestionResultHandler
		 * Result Handler for creating a question in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function createQbQuestionResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * updateQbQuestion
		 * Calls the remote server to update a question for a subcategory in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param qbQuestionVO type of QbQuestionVO
		 * @param answers type of ArrayCollection
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function updateQbQuestion(qbQuestionVO:QbQuestionVO, answers:ArrayCollection, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.updateQbQuestion(qbQuestionVO, answers, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * updateQbQuestionResultHandler
		 * Result Handler for updating a question in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function updateQbQuestionResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * deleteQbQuestions
		 * Calls the remote server to delete questions for a subcategory in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param questions type of ArrayCollection
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function deleteQbQuestions(questions:ArrayCollection, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.deleteQbQuestions(questions, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * deleteQbQuestionsResultHandler
		 * Result Handler for deleting questions in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function deleteQbQuestionsResultHandler(event:ResultEvent):void {
			event.token.onResult();
		}

		/**
		 *
		 * @private
		 * deleteQbQuestionsFaultHandler
		 * Fault Handler for deleting questions in Question Bank
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function deleteQbQuestionsFaultHandler(event:FaultEvent):void {
			
			if(event.token.onFault != null)
			{
				//To enable the delete button
				event.token.onFault();
				event.token.onFault = null;
			}			
			//To show error message
			genericFaultHandler(event);
		}

		/**
		 *
		 * @public
		 * getQbQuestions
		 * Calls the remote server to retrieve questions for a subcategory in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param categoryId type of Number
		 * @param subcategoryId type of Number
		 * @param typeId type of Number
		 * @param levelId type of Number
		 * @param quesText type of String
		 * @return void
		 *
		 */
		public function getQbQuestions(categoryId:Number, subcategoryId:Number, typeId:Number, levelId:Number, quesText:String,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.getQbQuestions(categoryId, subcategoryId, typeId, levelId, quesText, ClassroomContext.userVO.userId);

			token.onResult=onResult;
			token.onFault=onFault;
		}


		/**
		 *
		 * @private
		 * getQbQuestionsResultHandler
		 * Result Handler for retrieving questions for a subcategory in Question Bank
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQbQuestionsResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @public
		 * getQbQuestionsForPolling
		 * Calls the remote server to retrieve questions of polling type for a subcategory
		 * in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getQbQuestionsForPolling(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.getQbQuestionsForPolling(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getQbQuestionsForPollingResultHandler
		 * Result Handler for retrieving questions of polling type for a subcategory
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQbQuestionsForPollingResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * createQbQuestionForPolling
		 * Calls the remote server to create question of polling type for a subcategory
		 *  in Question Bank
		 *
		 * @param callerComp type of Object
		 * @param qbQuestionVO type of QbQuestionVO
		 * @param answers type of ArrayCollection
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function createQbQuestionForPolling(qbQuestionVO:QbQuestionVO, answers:ArrayCollection, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionHelperRO.createQbQuestionForPolling(qbQuestionVO, answers, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * createQbQuestionForPollingResultHandler
		 * Result Handler for creating question of polling type for a subcategory
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function createQbQuestionForPollingResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

	}
}
