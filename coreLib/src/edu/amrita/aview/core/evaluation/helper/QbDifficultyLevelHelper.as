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
 * File			: QbDifficultyLevelHelper.as
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
	 * @public
	 * QbDifficultyLevelHelper
	 * extends AbstractHelper
	 * QbDifficultyLevelHelper class is used to call the remote java methods
	 ***/
	public class QbDifficultyLevelHelper extends AbstractHelper {

		/**
		 * Remote Object to call qbdifficultylevelhelper.
		 */
		private var qbDifficultyLevelHelperRO:RemoteObject=null;

		/**
		 * @public
		 * QbDifficultyLevelHelper
		 * Default Constructor
		 * Constructor
		 * It initializes RemoteObject & add event handlers to it.
		 */
		public function QbDifficultyLevelHelper() {
			super();
			qbDifficultyLevelHelperRO=new RemoteObject();
			qbDifficultyLevelHelperRO.destination="qbdifficultylevelhelper";
			qbDifficultyLevelHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			qbDifficultyLevelHelperRO.showBusyCursor=true;

			qbDifficultyLevelHelperRO.getAllActiveDifficultyLevels.addEventListener(ResultEvent.RESULT, getAllActiveDifficultyLevelsResultHandler);
			qbDifficultyLevelHelperRO.getAllActiveDifficultyLevels.addEventListener(FaultEvent.FAULT, genericFaultHandler);

		}

		/**
		 *
		 * @public
		 * getAllActiveDifficultyLevels
		 * Calls the remote server to retreive all active difficulty levels for a question
		 * @param callerComp type of Object
		 * @return void
		 *
		 ***/
		public function getAllActiveDifficultyLevels(onResult:Function,onFault:Function= null):void {
			var token:AsyncToken=qbDifficultyLevelHelperRO.getAllActiveDifficultyLevels();
			token.onResult=onResult;
			token.onFault=onFault;
		}

		/**
		 *
		 * @private
		 * getAllActiveDifficultyLevelsResultHandler
		 * Result Handler for retreiving all active difficulty levels for a question
		 * @param event of type ResultEvent
		 * @return void
		 *
		 ***/
		private function getAllActiveDifficultyLevelsResultHandler(event:ResultEvent):void {
			event.token.onResult(event.result);
		}
	}
}
