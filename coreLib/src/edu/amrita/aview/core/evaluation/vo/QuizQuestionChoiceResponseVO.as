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
 * File			: QuizQuestionChoiceResponseVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for storing student response for an answer
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuizQuestionChoiceResponse")]
	public class QuizQuestionChoiceResponseVO extends Auditable {
		/**
		 * The choice response id : primary key
		 */
		private var _quizQuestionChoiceResponseId:Number=0;

		/**
		 * The quiz question id
		 */
		private var _quizQuestionId:Number=0;

		/**
		 * The quiz answer id
		 */
		private var _quizAnswerChoiceId:Number=0;

		/**
		 * The question response value object(many to one association)
		 */
		private var _quizQuestionResponse:QuizQuestionResponseVO=null;

		/**
		 * @public
		 * Set the choice response id
		 *
		 * @return Number
		 */
		public function get quizQuestionChoiceResponseId():Number {
			return _quizQuestionChoiceResponseId;
		}

		/**
		 * @public
		 * Get the choice response id
		 * @param quizQuestionChoiceResponseId the quizQuestionChoiceResponseId to set
		 * @return void
		 */
		public function set quizQuestionChoiceResponseId(quizQuestionChoiceResponseId:Number):void {
			this._quizQuestionChoiceResponseId=quizQuestionChoiceResponseId;
		}

		/**
		 * @public
		 * Get the question response
		 *
		 * @return QuizQuestionResponseVO
		 */
		public function get quizQuestionResponse():QuizQuestionResponseVO {
			return _quizQuestionResponse;
		}

		/**
		 * @public
		 * Set the question response
		 * @param quizQuestionResponseId the quizQuestionResponseId to set
		 * @return void
		 */
		public function set quizQuestionResponse(quizQuestionResponse:QuizQuestionResponseVO):void {
			this._quizQuestionResponse=quizQuestionResponse;
		}

		/**
		 * @public
		 * Get the answer id
		 *
		 * @return Number
		 */
		public function get quizAnswerChoiceId():Number {
			return _quizAnswerChoiceId;
		}

		/**
		 * @public
		 * Set the answer id
		 * @param quizAnswerChoiceId the quizAnswerChoiceId to set
		 * @return void
		 *
		 */
		public function set quizAnswerChoiceId(quizAnswerChoiceId:Number):void {
			this._quizAnswerChoiceId=quizAnswerChoiceId;
		}

		/**
		 * @public
		 * Get the quiz question id
		 *
		 * @return Number
		 */
		public function get quizQuestionId():Number {
			return _quizQuestionId;
		}

		/**
		 * @public
		 * Set the quiz question id
		 * @param value
		 * @return void
		 */
		public function set quizQuestionId(value:Number):void {
			_quizQuestionId=value;
		}


	}
}
