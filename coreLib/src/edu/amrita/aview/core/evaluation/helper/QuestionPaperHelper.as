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
 * File			: QuestionPaperHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;


	/**
	 *
	 * @public
	 * QuestionPaperHelper
	 * extends AbstractHelper
	 * QuestionPaperHelper class is used to call the remote java methods
	 */
	public class QuestionPaperHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var questionPaperHelperRO:RemoteObject=null;

		/**
		 * Used to log comments to logger
		 */
		private var logger:ILogger=Log.getLogger("edu.amrita.aview.core.evaluation.helper.QuestionPaperHelper");

		/**
		 *
		 * @public
		 * QuestionPaperHelper
		 * Default Constructor
		 * Constructor
		* It initializes RemoteObject & add event handlers to it.
		 */
		public function QuestionPaperHelper() {
			questionPaperHelperRO=new RemoteObject();
			questionPaperHelperRO.destination="questionpaperhelper";
			questionPaperHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			questionPaperHelperRO.showBusyCursor=true;

			questionPaperHelperRO.getQuestionPaperComplete.addEventListener(ResultEvent.RESULT, getQuestionPaperCompleteResultHandler);
			questionPaperHelperRO.getQuestionPaperComplete.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperHelperRO.getAllActiveQuestionPapersForUser.addEventListener(ResultEvent.RESULT, getAllActiveQuestionPapersForUserResultHandler);
			questionPaperHelperRO.getAllActiveQuestionPapersForUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperHelperRO.createQuestionPaper.addEventListener(ResultEvent.RESULT, createQuestionPaperResultHandler);
			questionPaperHelperRO.createQuestionPaper.addEventListener(FaultEvent.FAULT, createQuestionPaperFaultHandler);

			questionPaperHelperRO.updateQuestionPaper.addEventListener(ResultEvent.RESULT, updateQuestionPaperResultHandler);
			questionPaperHelperRO.updateQuestionPaper.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperHelperRO.deleteQuestionPaper.addEventListener(ResultEvent.RESULT, deleteQuestionPaperResultHandler);
			questionPaperHelperRO.deleteQuestionPaper.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperHelperRO.validateQuestionPaper.addEventListener(ResultEvent.RESULT, validateQuestionPaperResultHandler);
			questionPaperHelperRO.validateQuestionPaper.addEventListener(FaultEvent.FAULT, validateQuestionPaperFaultHandler);

			questionPaperHelperRO.saveQuestionPaper.addEventListener(ResultEvent.RESULT, saveQuestionPaperResultHandler);
			questionPaperHelperRO.saveQuestionPaper.addEventListener(FaultEvent.FAULT, saveQuestionPaperFaultHandler);

			questionPaperHelperRO.getAllActiveQuestionPapers.addEventListener(ResultEvent.RESULT, getAllActiveQuestionPapersResultHandler);
			questionPaperHelperRO.getAllActiveQuestionPapers.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperHelperRO.createPollingQuestionPaper.addEventListener(ResultEvent.RESULT, createPollingQuestionPaperResultHandler);
			questionPaperHelperRO.createPollingQuestionPaper.addEventListener(FaultEvent.FAULT, createPollingQuestionPaperFaultHandler);

			questionPaperHelperRO.getQuestionPaperIfQuestionsExist.addEventListener(ResultEvent.RESULT, getQuestionPaperIfQuestionsExistResultHandler);
			questionPaperHelperRO.getQuestionPaperIfQuestionsExist.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperHelperRO.questionPaperPreview.addEventListener(ResultEvent.RESULT, questionPaperPreviewResultHandler);
			questionPaperHelperRO.questionPaperPreview.addEventListener(FaultEvent.FAULT, genericFaultHandler);

		}

		/**
		 *
		 * @public
		 * questionPaperPreview
		 * Calls the remote server to preview question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function questionPaperPreview(questionPaperId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.questionPaperPreview(questionPaperId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * questionPaperPreviewResultHandler
		 * Result Handler for previewing question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function questionPaperPreviewResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}


		/**
		 *
		 * @public
		 * getQuestionPaperComplete
		 * Calls the remote server to get all question papers which are complete
		 *
		 * @param callerComp type of Object
		 * @param questionPaperId type of Number
		 * @return void
		 *
		 */
		public function getQuestionPaperComplete(questionPaperId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.getQuestionPaperComplete(questionPaperId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getQuestionPaperCompleteResultHandler
		 * Result Handler for getting all question papers which are complete
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuestionPaperCompleteResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * getAllActiveQuestionPapersForUser
		 * Calls the remote server to get active question papers for a user
		 *
		 * @param callerComp type of Object
		 * @param userID type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQuestionPapersForUser(userID:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.getAllActiveQuestionPapersForUser(userID);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * getAllActiveQuestionPapersForUserInLiveClass
		 * Call the remote server to get active question papers for user in live class
		 *
		 * @param callerComp type of Object
		 * @param userID type of Number
		 * @param isComplete type of String
		 * @return void
		 *
		 */
		public function getAllActiveQuestionPapersForUserInLiveClass(userID:Number,onResult:Function,isComplete:String = null,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.getAllActiveQuestionPapersForUser(userID, isComplete);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveQuestionPapersForUserResultHandler
		 * Result Handler for getting active question papers for a user
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuestionPapersForUserResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @public
		 * createPollingQuestionPaper
		 * Calls the remote server to create a polling question paper
		 *
		 * @param callerComp type of Object
		 * @param pollingQuestionId type of ArrayCollection
		 * @param classId type of Number
		 * @param courseId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function createPollingQuestionPaper(pollingQuestionId:ArrayCollection, classId:Number, courseId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.createPollingQuestionPaper(pollingQuestionId, classId, courseId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * createPollingQuestionPaperResultHandler
		 * Result Handler for creating a polling question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function createPollingQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * createPollingQuestionPaperFaultHandler
		 * Fault Handler for creating a polling question paper
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function createPollingQuestionPaperFaultHandler(event:FaultEvent):void {
			//To enable start polling button
			event.token.onFault();
			//To show error message
			genericFaultHandler(event);
		}

		/**
		 *
		 * @public
		 * createQuestionPaper
		 * Calls the remote server to create a question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperVO type of QuestionPaperVO
		 * @param creatorId type of Number
		 * @return void
		 *
		 */
		public function createQuestionPaper(questionPaperVO:QuestionPaperVO, creatorId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.createQuestionPaper(questionPaperVO, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * createQuestionPaperResultHandler
		 * Result Handler for creating a question pape
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function createQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @private
		 * createQuestionPaperFaultHandler
		 * Fault Handler for creating a question pape
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function createQuestionPaperFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @public
		 * updateQuestionPaper
		 * Calls the remote server to update a question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperVO type of QuestionPaperVO
		 * @param updaterId type of Number
		 * @return void
		 *
		 */
		public function updateQuestionPaper(questionPaperVO:QuestionPaperVO, updaterId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.updateQuestionPaper(questionPaperVO, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * updateQuestionPaperResultHandler
		 * Result Handler to update a question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function updateQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult();
		}

		/**
		 *
		 * @private
		 * updateQuestionPaperFaultHandler
		 * Fault Handler for updating a question paper
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function updateQuestionPaperFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @public
		 * deleteQuestionPaper
		 * Calls the remote server to delete a question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function deleteQuestionPaper(questionPaperId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.deleteQuestionPaper(questionPaperId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * deleteQuestionPaperResultHandler
		 * Result Handler for deleting a question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function deleteQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult();
		}

		/**
		 *
		 * @public
		 * validateQuestionPaper
		 * Calls the remote server to validate a question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function validateQuestionPaper(questionPaperId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.validateQuestionPaper(questionPaperId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * validateQuestionPaperResultHandler
		 * Result Handler for validating a question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function validateQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @private
		 * validateQuestionPaperFaultHandler
		 * Fault Handler for validating a question paper
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function validateQuestionPaperFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @public
		 * saveQuestionPaper
		 * Calls the remote server to save a question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperVO type of QuestionPaperVO
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function saveQuestionPaper(questionPaperVO:QuestionPaperVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperHelperRO.saveQuestionPaper(questionPaperVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * saveQuestionPaperResultHandler
		 * Result Handler for saving a question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function saveQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @private
		 * saveQuestionPaperFaultHandler
		 * Fault Handler for saving a question paper
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function saveQuestionPaperFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @public
		 * getAllActiveQuestionPapers
		 * Calls the remote server to get active question papers
		 *
		 * @param callerComp type of Object
		 * @return void
		 *
		 */
		public function getAllActiveQuestionPapers(onResult:Function,onFault:Function = null):void {
			var token:AsyncToken=questionPaperHelperRO.getAllActiveQuestionPapers();
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveQuestionPapersResultHandler
		 * Result Handler for getting active question papers
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuestionPapersResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * getQuestionPaperIfQuestionsExist
		 * Calls the remote server to check if a question exists in a question paper
		 *
		 * @param callerComp type of Object
		 * @return void
		 *
		 */
		public function getQuestionPaperIfQuestionsExist(onResult:Function,onFault:Function = null):void {
			var token:AsyncToken=questionPaperHelperRO.getQuestionPaperIfQuestionsExist();
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getQuestionPaperIfQuestionsExistResultHandler
		 * Result Handler for checking if a question exists in a question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuestionPaperIfQuestionsExistResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * genericFaultHandler
		 *
		 * Default Fault Handler for handling the faults which are not caught
		 * by any methods specified above
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		override public function genericFaultHandler(event:FaultEvent):void {
			var faultMessage:String=getFaultMessage(event);
			if (!unHandlableExceptions(faultMessage)) {
				logger.error(faultMessage);
				CustomAlert.error(faultMessage);
			} else {
				logger.error("Unhandlable fault:" + faultMessage + ":suppressing from user");
			}
		}

		/**
		 *
		 * @public
		 * getFaultMessage
		 *	Gets the fault message for Default Fault Handler
		 * @param event of type FaultEvent
		 * @return String
		 *
		 */
		override public function getFaultMessage(event:FaultEvent):String {
			var finalMessage:String;
			if (event.fault && event.fault.faultString) {
				finalMessage="\n Fault string:" + event.fault.faultString;
			}
			return finalMessage;
		}

		/**
		 *
		 * @private
		 * unHandlableExceptions
		 * Handles the exception which are not handled by aview
		 * @param faultMessgage type of String
		 * @return Boolean
		 *
		 */
		private function unHandlableExceptions(faultMessgage:String):Boolean {
			if (faultMessgage.indexOf("The FlexClient is invalid") != -1) {
				return true;
			}
			if (faultMessgage.indexOf("Detected duplicate HTTP-based FlexSessions") != -1) {
				return true;
			}
			return false;
		}
	}
}
