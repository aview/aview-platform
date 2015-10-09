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
 * File			: QuizResponseHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {

	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.evaluation.vo.QuizResponseVO;

	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	/**
	 *
	 * @public
	 * QuizResponseHelper
	 * extends AbstractHelper
	 * QuizResponseHelper class is used to call the remote java methods
	 */
	public class QuizResponseHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var quizResponseRO:RemoteObject=null;


		/**
		 *
		 * @public
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QuizResponseHelper() {
			quizResponseRO=new RemoteObject();
			quizResponseRO.destination="quizresponsehelper";
			quizResponseRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			quizResponseRO.showBusyCursor=true;

			quizResponseRO.createQuizResponse.addEventListener(ResultEvent.RESULT, createQuizResponseResultHandler);
			quizResponseRO.createQuizResponse.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 *
		 * @public
		 * Calls the remote server to create a quiz response
		 *
		 * @param callerComp type of Object
		 * @param quizResponseVo type of QuizResponseVO
		 * @param quizQuestionIdArr type of Array
		 * @param quizAnswerChoiceIdArr type of Array
		 * @param creatorId type of Number
		 * @return void
		 *
		 */
		public function createQuizResponse(quizResponseVo:QuizResponseVO, quizQuestionIdArr:Array, quizAnswerChoiceIdArr:Array, creatorId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=quizResponseRO.createQuizResponse(quizResponseVo, quizQuestionIdArr, quizAnswerChoiceIdArr, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 * @private
		 * Result Handler for creating a quiz response
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function createQuizResponseResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

	}
}
