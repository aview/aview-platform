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
 * File			: UpdateQuestionPaperVOEvent.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * UpdateQuestionPaperVOEvent handles the updation of tree
 *
 */
package edu.amrita.aview.core.evaluation.event {
	import edu.amrita.aview.core.evaluation.vo.QuestionPaperVO;

	import flash.events.Event;


	/**
	 * The Event Class
	 *
	 */
	public class UpdateQuestionPaperVOEvent extends Event {

		/**
		 * Event Type 'treeUpdated'
		 */
		public static const TREE_UPDATED:String="treeUpdated";

		/**
		 * Value Object of QuestionPaperVO
		 */
		public var qpVO:QuestionPaperVO;


		/**
		 *
		 * @public
		 * Function : UpdateQuestionPaperVOEvent
		 * Default Constructor. It calls the super class and set total number of questions.
		 *
		 * @param type of type String
		 * @param questionPaperVO of type QuestionPaperVO
		 *
		 */
		public function UpdateQuestionPaperVOEvent(type:String, questionPaperVO:QuestionPaperVO) {
			super(type);
			this.qpVO=questionPaperVO;
		}

		/**
		 *
		 * @override
		 * Override the inherited clone() method.
		 *
		 *
		 * @return Event
		 *
		 */
		override public function clone():Event {
			return new UpdateQuestionPaperVOEvent(type, qpVO);
		}
	}
}
