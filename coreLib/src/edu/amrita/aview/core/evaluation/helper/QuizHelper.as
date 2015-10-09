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
 * File			: QuizHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {

	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.evaluation.vo.QuizVO;

	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	/**
	 * QuizHelper class is used to call the remote java methods
	 */
	public class QuizHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var quizHelperRO:RemoteObject=null;

		/**
		 * Used to log messages to logger
		 */
		private var logger:ILogger=Log.getLogger("edu.amrita.aview.core.evaluation.helper.QuizHelper");

		/**
		 * @public
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QuizHelper() {
			quizHelperRO=new RemoteObject();
			quizHelperRO.destination="quizhelper";
			quizHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			quizHelperRO.showBusyCursor=true;

			quizHelperRO.getQuizResultForStudent.addEventListener(ResultEvent.RESULT, getQuizResultForStudentResultHandler);
			quizHelperRO.getQuizResultForStudent.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getAllActiveQuizzesForUser.addEventListener(ResultEvent.RESULT, getAllActiveQuizzesForUserResultHandler);
			quizHelperRO.getAllActiveQuizzesForUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.createQuiz.addEventListener(ResultEvent.RESULT, createQuizResultHandler);
			quizHelperRO.createQuiz.addEventListener(FaultEvent.FAULT, createQuizFaultHandler);

			quizHelperRO.updateQuiz.addEventListener(ResultEvent.RESULT, updateQuizResultHandler);
			quizHelperRO.updateQuiz.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getAllActiveQuizzesOffLineForStudent.addEventListener(ResultEvent.RESULT, getAllActiveQuizzesOffLineForStudentResultHandler);
			quizHelperRO.getAllActiveQuizzesOffLineForStudent.addEventListener(FaultEvent.FAULT, genericFaultHandler);


			quizHelperRO.deleteQuiz.addEventListener(ResultEvent.RESULT, deleteQuizResultHandler);
			quizHelperRO.deleteQuiz.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getAllActiveQuizzesForStudent.addEventListener(ResultEvent.RESULT, getAllActiveQuizzesForStudentResultHandler);
			quizHelperRO.getAllActiveQuizzesForStudent.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getQuizResultByQuestion.addEventListener(ResultEvent.RESULT, getQuizResultByQuestionResultHandler);
			quizHelperRO.getQuizResultByQuestion.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.sendLiveQuizAsSMS.addEventListener(ResultEvent.RESULT, sendLiveQuizAsSMSResultHandler);
			quizHelperRO.sendLiveQuizAsSMS.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getQuizResultByQuestionPaper.addEventListener(ResultEvent.RESULT, getQuizResultByQuestionPaperResultHandler);
			quizHelperRO.getQuizResultByQuestionPaper.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getQuestionPaperResultForChart.addEventListener(ResultEvent.RESULT, getQuestionPaperResultForChartResultHandler);
			quizHelperRO.getQuestionPaperResultForChart.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getQuizResultByLocation.addEventListener(ResultEvent.RESULT, getQuizResultByLocationResultHandler);
			quizHelperRO.getQuizResultByLocation.addEventListener(FaultEvent.FAULT, genericFaultHandler);


			quizHelperRO.getCategoryBasedResult.addEventListener(ResultEvent.RESULT, getCategoryBasedResultHandler);
			quizHelperRO.getCategoryBasedResult.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizHelperRO.getAllActiveQuizzesForQuestionPaper.addEventListener(ResultEvent.RESULT, getAllActiveQuizzesForQuestionPaperResultHandler);
			quizHelperRO.getAllActiveQuizzesForQuestionPaper.addEventListener(FaultEvent.FAULT, getAllActiveQuizzesForQuestionPaperFaultHandler);

			quizHelperRO.getQuizById.addEventListener(ResultEvent.RESULT, getQuizByIdResultHandler);
			quizHelperRO.getQuizById.addEventListener(FaultEvent.FAULT, genericFaultHandler);

		}

		/**
		 *
		 * @public
		 * Calls the remote server to get quiz result for a student
		 * i.e the response of a student which consists of total score , correct answer , user id etc
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getQuizResultForStudent(quizId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getQuizResultForStudent(quizId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get the question paper result
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getQuizResultByQuestionPaper(quizId:Number,onResult:Function,onFault:Function= null):void {
//			var token:Async	Token=quizHelperRO.getQuestionPaperResult(quizId);
			var token:AsyncToken=quizHelperRO.getQuizResultByQuestionPaper(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get active quizzes for user
		 *
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQuizzesForUser(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getAllActiveQuizzesForUser(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to create a quiz
		 *
		 * @param callerComp type of Object
		 * @param quizVO type of QuizVO
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function createQuiz(quizVO:QuizVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.createQuiz(quizVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to update a quiz
		 *
		 * @param callerComp type of Object
		 * @param quizVO type of QuizVO
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function updateQuiz(quizVO:QuizVO, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.updateQuiz(quizVO, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get active quizzes(offline)
		 *
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQuizzesOffLineForStudent(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getAllActiveQuizzesOffLineForStudent(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to delete a quiz
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function deleteQuiz(quizId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.deleteQuiz(quizId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls remote server to get active quizzes for a student
		 *
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQuizzesForStudent(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getAllActiveQuizzesForStudent(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get the result of students for a quiz
		 * on basis of quiz question .
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getQuizResultByQuestion(quizId:Number,onResult:Function,onFault:Function= null):void {
//			var token:AsyncToken=quizHelperRO.getQuizQuestionResult(quizId);
			var token:AsyncToken=quizHelperRO.getQuizResultByQuestion(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get quiz response on basis of question paper
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getQuestionPaperResultForChart(quizId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getQuestionPaperResultForChart(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get the quiz result
		 * on basis of location i.e local or remote
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getQuizResultByLocation(quizId:Number,onResult:Function,onFault:Function= null):void {
//			var token:AsyncToken=quizHelperRO.getLocationBasedResult(quizId);
			var token:AsyncToken=quizHelperRO.getQuizResultByLocation(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get quiz result on basis of a category
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getCategoryBasedResult(quizId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getCategoryBasedResult(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote method to get active quizzes for question paper
		 *
		 * @param callerComp type of Object
		 * @param questionId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQuizzesForQuestionPaper(questionId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getAllActiveQuizzesForQuestionPaper(userId, questionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote method to get quiz details for a quiz id
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getQuizById(quizId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.getQuizById(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for getting quiz result for a student
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuizResultForStudentResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting active quizzes for user
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuizzesForUserResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for creating a quiz
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function createQuizResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Fault Handler for creating a quiz
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function createQuizFaultHandler(event:FaultEvent):void {
			event.token.onFault(event);
		}

		/**
		 *
		 * @private
		 * Result Handler for updating a quiz
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function updateQuizResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for deleting a quiz
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function deleteQuizResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting active quizzes for a student
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuizzesForStudentResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting the result of students for a quiz
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuizResultByQuestionResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * Calls the remote server to send the live quiz as SMS
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function sendLiveQuizAsSMS(quizId:Number,onFault:Function= null):void {
			var token:AsyncToken=quizHelperRO.launchQuizInstanceForMobile(quizId);
//			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for sending the live quiz as SMS
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function sendLiveQuizAsSMSResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting the question paper result
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuizResultByQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting quiz response on basis of question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuestionPaperResultForChartResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting active quizzes(offline)
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuizzesOffLineForStudentResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting the quiz result
		 * on basis of location i.e local or remote
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuizResultByLocationResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting quiz result on basis of a category
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getCategoryBasedResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting active quizzes for question paper
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuizzesForQuestionPaperResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Fault Handler for getting active quizzes for question paper
		 *
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQuizzesForQuestionPaperFaultHandler(event:FaultEvent):void {
			//To enable a button
			event.token.onFault();
			//To show error message
			genericFaultHandler(event);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting quiz details for a quiz id
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQuizByIdResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}


		/**
		 *
		 * @public
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
				if (faultMessage.search("Sorry No questions found for question paper") != -1) {
					CustomAlert.error(faultMessage.slice(faultMessage.search("Sorry No questions found for question paper")));
				}
			} else {
				logger.error("Unhandlable fault:" + faultMessage + ":suppressing from user");
			}
		}

		/**
		 *
		 * @private
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
