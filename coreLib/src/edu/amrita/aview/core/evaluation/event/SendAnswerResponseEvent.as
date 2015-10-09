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
 * File			: SendAnswerResponseEvent.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * SendAnswerResponseEvent handles the response sent
 * by the user , on attending a quiz
 */

package edu.amrita.aview.core.evaluation.event {
	import edu.amrita.aview.core.evaluation.vo.QuizAnswerChoiceVO;

	import flash.events.Event;

	/**
	 *  The Event Class
	 *
	 */
	public class SendAnswerResponseEvent extends Event {

		/**
		 * Event Type 'radioButtonChange'
		 */
		public static const RADIO_BUTTON_CHANGED:String="radioButtonClick";

		/**
		 * Event Type 'chkButtonChange'
		 */
		public static const CHK_BUTTON_CHANGED:String="checkBoxClick";

		/**
		 * Value Object of QuizAnswerChoiceVO
		 */
		public var quizAnswerChoiceVO:QuizAnswerChoiceVO;

		/**
		 *
		 * @public
		 * Function : SendAnswerResponseEvent
		 * Default Constructor. It calls the super class and set quiz answer choice details.
		 *
		 * @param type of type String
		 * @param qzAnsVO of type QuizAnswerChoiceVO
		 *
		 */
		public function SendAnswerResponseEvent(type:String, qzAnsVO:QuizAnswerChoiceVO) {
			super(type);
			this.quizAnswerChoiceVO=qzAnsVO;
		}

		/**
		 *
		 * @override
		 * Override the inherited clone() method.
		 *
		 *
		 * @return event
		 *
		 */
		override public function clone():Event {
			return new SendAnswerResponseEvent(type, quizAnswerChoiceVO);
		}
	}
}
