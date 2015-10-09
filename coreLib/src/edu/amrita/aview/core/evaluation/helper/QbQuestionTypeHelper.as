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
 * File			: QbQuestionTypeHelper.as
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
	import mx.rpc.remoting.RemoteObject;

	/**
	 *
	 * @public
	 * QbQuestionTypeHelper
	 * extends AbstractHelper
	 * QbQuestionTypeHelper class is used to call the remote java methods
	 */
	public class QbQuestionTypeHelper extends AbstractHelper {

		/**
		 * Remote Object
		 */
		private var qbQuestionTypeHelperRO:RemoteObject=null;


		/**
		 *
		 * @public
		 * QbQuestionTypeHelper
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QbQuestionTypeHelper() {
			super();
			qbQuestionTypeHelperRO=new RemoteObject();
			qbQuestionTypeHelperRO.destination="qbquestiontypehelper";
			qbQuestionTypeHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			qbQuestionTypeHelperRO.showBusyCursor=true;

			qbQuestionTypeHelperRO.getAllActiveQbQuestionTypes.addEventListener(ResultEvent.RESULT, getAllActiveQbQuestionTypesResultHandler);
			qbQuestionTypeHelperRO.getAllActiveQbQuestionTypes.addEventListener(FaultEvent.FAULT, genericFaultHandler);

			qbQuestionTypeHelperRO.getQbQuestionTypeByName.addEventListener(ResultEvent.RESULT, getQbQuestionTypeByNameResultHandler);
			qbQuestionTypeHelperRO.getQbQuestionTypeByName.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 *
		 * @public
		 * getAllActiveQbQuestionTypes
		 * Calls the remote server to get all active question types for a question
		 *
		 * @param callerComp type of Object
		 * @return void
		 *
		 */
		public function getAllActiveQbQuestionTypes(onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionTypeHelperRO.getAllActiveQbQuestionTypes();
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveQbQuestionTypesResultHandler
		 * Result Handler for getting all active question types for a question
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getAllActiveQbQuestionTypesResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}

		/**
		 *
		 * @public
		 * getQbQuestionTypeByName
		 * Calls the remote server to get question type details for a given question type name
		 *
		 * @param callerComp type of Object
		 * @param questionTypeName type of String
		 * @return void
		 *
		 */
		public function getQbQuestionTypeByName(questionTypeName:String,onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbQuestionTypeHelperRO.getQbQuestionTypeByName(questionTypeName);
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getQbQuestionTypeByNameResultHandler
		 * Result Handler for getting question type details for a given question type name
		 *
		 * @param event of type ResultEvent
		 * @return void
		 *
		 */
		private function getQbQuestionTypeByNameResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}
	}
}
