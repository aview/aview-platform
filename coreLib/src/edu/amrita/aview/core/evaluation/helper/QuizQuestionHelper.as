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
 * File			: QuizQuestionHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {

	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;

	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	import spark.modules.*;

	/**
	 *
	 * @public
	 * QuizQuestionHelper
	 * extends AbstractHelper
	 * QuizQuestionHelper class is used to call the remote java methods
	 */
	public class QuizQuestionHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var quizQuestionHelperRO:RemoteObject=null;

		/**
		 *
		 * @public
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QuizQuestionHelper() {
			quizQuestionHelperRO=new RemoteObject();
			quizQuestionHelperRO.destination="quizquestionhelper";
			quizQuestionHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			quizQuestionHelperRO.showBusyCursor=true;


			quizQuestionHelperRO.getQuizQuestionsForQuiz.addEventListener(ResultEvent.RESULT, getQuizQuestionsForQuizResultHandler);
			quizQuestionHelperRO.getQuizQuestionsForQuiz.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			quizQuestionHelperRO.getPollingQuizForStudent.addEventListener(ResultEvent.RESULT, getPollingQuizForStudentResultHandler);
			quizQuestionHelperRO.getPollingQuizForStudent.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get quiz questions for quiz
		 *
		 * @param callerComp type of Object
		 * @param quizId type of Number
		 * @return void
		 *
		 */
		public function getQuizQuestionsForQuiz(quizId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizQuestionHelperRO.getQuizQuestionsForQuiz(quizId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for getting quiz questions for quiz
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function getQuizQuestionsForQuizResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get polling quiz
		 *
		 * @param callerComp type of Object
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getPollingQuizForStudent(userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizQuestionHelperRO.getPollingQuizForStudent(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for getting polling quiz
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function getPollingQuizForStudentResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

	}
}
