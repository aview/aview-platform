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
 * File			: QuestionPaperQuestionHelper.as
 * Module		: Evaluation
 * Developer(s)	: Radha , Swati , Sethu , Mathi , Abhirami
 * Reviewer(s)	: Sinu Rachel John
 */
package edu.amrita.aview.core.evaluation.helper {
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.evaluation.vo.QuestionPaperQuestionListVO;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	/**
	 *
	 * @public
	 * QuestionPaperQuestionHelper
	 * extends AbstractHelper
	 * QuestionPaperQuestionHelper class is used to call the remote java methods
	 */
	public class QuestionPaperQuestionHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var questionPaperQuestionRO:RemoteObject=null;


		/**
		 *
		 * @public
		 * QuestionPaperQuestionHelper
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QuestionPaperQuestionHelper() {
			questionPaperQuestionRO=new RemoteObject();
			questionPaperQuestionRO.destination="questionpaperquestionhelper";
			questionPaperQuestionRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			questionPaperQuestionRO.showBusyCursor=true;

			questionPaperQuestionRO.getAllActiveSpecificQuestionsForQuestionPaper.addEventListener(ResultEvent.RESULT, getAllActiveSpecificQuestionsForQuestionPaperResultHandler);
			questionPaperQuestionRO.getAllActiveSpecificQuestionsForQuestionPaper.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			questionPaperQuestionRO.getAllActiveQuestionPaperQuestionsForQP.addEventListener(ResultEvent.RESULT, getAllActiveQuestionPaperQuestionsForQPResultHandler);
			questionPaperQuestionRO.getAllActiveQuestionPaperQuestionsForQP.addEventListener(FaultEvent.FAULT, genericFaultHandler);


			questionPaperQuestionRO.deleteQpqQuestions.addEventListener(ResultEvent.RESULT, deleteQpqQuestionsResultHandler);
			//Fix for Bug#16176,16177
			questionPaperQuestionRO.deleteQpqQuestions.addEventListener(FaultEvent.FAULT, deleteQpqQuestionsFaultHandler);

		}

		/**
		 *
		 * @public
		 * Calls the remote server to get specific questions
		 *
		 * @param callerComp type of Object
		 * @return void
		 *
		 */
		public function getAllActiveSpecificQuestionsForQuestionPaper(onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperQuestionRO.getAllActiveSpecificQuestionsForQuestionPaper(ClassroomContext.questionPaperId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for getting specific questions
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function getAllActiveSpecificQuestionsForQuestionPaperResultHandler(event:ResultEvent):void {
			var questionPaperQuestions:ArrayCollection=new ArrayCollection();
			var questionPaperQuestionsList:ArrayList=new ArrayList();
			var tempObj:Object=event.result;
			var i:int;
			for (i=0; i < event.result.length; i++) {
				questionPaperQuestions.addItem(QuestionPaperQuestionListVO(tempObj[i]));
				questionPaperQuestionsList.addItem(QuestionPaperQuestionListVO(tempObj[i]));
			}
			ClassroomContext.quizQuestionPaperQuestions=questionPaperQuestions;
			event.token.onResult(questionPaperQuestionsList);
		}

		/**
		 *
		 * @public
		 * Calls the remote server to get question paper questions for a question paper
		 *
		 * @param callerComp type of Object
		 * @param questionPaperId type of Number
		 * @param userId type of Number
		 * @return void
		 *
		 */
		public function getAllActiveQuestionPaperQuestionsForQP(questionPaperId:Number, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperQuestionRO.getAllActiveQuestionPaperQuestionsForQP(questionPaperId, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for getting question paper questions for a question paper
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function getAllActiveQuestionPaperQuestionsForQPResultHandler(event:ResultEvent):void {
			event.token.onResult(event);

		}

		/**
		 *
		 * @public
		 * Calls the remote server to delete question paper questions
		 *
		 * @param callerComp type of Object
		 * @param questions type of ArrayCollection
		 * @param userId type of Number
		 * @return void
		 *
		 */

		public function deleteQpqQuestions(questions:ArrayCollection, userId:Number,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=questionPaperQuestionRO.deleteQpqQuestions(questions, userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * Result Handler for deleting question paper questions
		 *
		 * @param event of result
		 * @return void
		 *
		 */
		private function deleteQpqQuestionsResultHandler(event:ResultEvent):void {
			event.token.onResult();

		}
		//Fix for Bug#16176,16177
		private function deleteQpqQuestionsFaultHandler(event:FaultEvent):void 
		{
			event.token.onFault(event);
		}

	}
}
