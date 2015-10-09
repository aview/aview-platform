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
 * File			: QuizCreatedEvent.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Sinu Rachel John
 *
 * QuizCreatedEvent handles the creation of quiz
 *
 */
package edu.amrita.aview.core.evaluation.event {
	import edu.amrita.aview.core.evaluation.vo.QuizVO;

	import flash.events.Event;


	/**
	 * The Event Class
	 *
	 */
	public class QuizCreatedEvent extends Event {

		/**
		 * Event Type  'QuizCreated'
		 */
		public static var QUIZ_CREATED:String="QuizCreated";

		/**
		 * Value Object of QuizVO
		 */
		public var quiz:QuizVO;

		/**
		 *
		 * @public
		 * Function : QuizCreatedEvent
		 * Default Constructor. It calls the super class and set created quiz details.
		 *
		 * @param type of type String
		 * @param createdQuiz of type QuizVO
		 *
		 */
		public function QuizCreatedEvent(type:String, createdQuiz:QuizVO) {
			super(type);
			this.quiz=createdQuiz;
		}
	}
}
