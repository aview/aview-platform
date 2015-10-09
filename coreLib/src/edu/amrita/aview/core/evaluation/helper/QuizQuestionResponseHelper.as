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
 * File			: QuizQuestionResponseHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	/**
	 *
	 * @public
	 * QuizQuestionResponseHelper
	 * extends AbstractHelper
	 * QuizQuestionResponseHelper class is used to call the remote java methods
	 */
	public class QuizQuestionResponseHelper extends AbstractHelper {

		/**
		 * Remote Object to call quizquestionresponsehelper.
		 */
		private var quizQuestionResponseRO:RemoteObject=null;

		/**
		 *
		 * @public
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QuizQuestionResponseHelper() {
			quizQuestionResponseRO=new RemoteObject();
			quizQuestionResponseRO.destination="quizquestionresponsehelper";
			quizQuestionResponseRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			quizQuestionResponseRO.showBusyCursor=true;

			quizQuestionResponseRO.getStudentAnswerSheet.addEventListener(ResultEvent.RESULT, getStudentAnswerSheetResultHandler);
			quizQuestionResponseRO.getStudentAnswerSheet.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizQuestionResponseRO.getResultForPollingQuiz.addEventListener(ResultEvent.RESULT, getResultForPollingQuizResultHandler);
			quizQuestionResponseRO.getResultForPollingQuiz.addEventListener(FaultEvent.FAULT, getResultForPollingQuizFaultHandler);
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get answer sheet(quiz response) for a student
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @param userName type of String
		 * @return void
		 *
		 */
		public function getStudentAnswerSheet(quizId:Number, userName:String,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizQuestionResponseRO.getStudentAnswerSheet(quizId, userName);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get response of polling quiz
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @param qbQuestionId type of Number
		 * @return void
		 *
		 */
		//Fix for Bug #19388
		public function getResultForPollingQuiz(quizQuestionId:Number, qbQuestionId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizQuestionResponseRO.getResultForPollingQuiz(quizQuestionId, qbQuestionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @public
		 * Result Handler for getting answer sheet(quiz response) for a student
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		public function getStudentAnswerSheetResultHandler(event:ResultEvent):void {
			event.token.onResult(event);
		}

		/**
		 *
		 * @private
		 * Result Handler for getting response of polling quiz
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getResultForPollingQuizResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @private
		 * Fault Handler for getting response of polling quiz
		 * @param event of type FaultEvent
		 * @return void
		 *
		 */
		private function getResultForPollingQuizFaultHandler(event:FaultEvent):void {
			event.token.onFault();
			genericFaultHandler(event);
		}
	}
}
