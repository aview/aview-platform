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
 * File			: QuizAnswerChoiceVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Answer Choice .
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	import spark.components.RadioButtonGroup;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuizAnswerChoice")]
	public class QuizAnswerChoiceVO extends Auditable {
		/**
		 * The answer choice id : primary key
		 */
		private var _quizAnswerChoiceId:Number=0;

		/**
		 * The quiz question id
		 */
		private var _quizQuestionId:Number=0;

		/**
		 * The answer text
		 */
		private var _choiceText:String=null;

		/**
		 * The hash for answer text
		 */
		private var _choiceTextHash:String=null;

		/**
		 * 0 or 1 value for wrong or correct answer respectively
		 */
		private var _fraction:Number=0;

		/**
		 * The sequence of answers(according to choice label)
		 */
		private var _displaySequence:Number=0;

		/**
		 * The serial sequence( of alphabets) for answer
		 */
		private var _choiceLabel:String=null;

		/**
		 * The quiz question value object(for mapping many to one)
		 */
		private var _quizQuestion:QuizQuestionVO=null;

		/**
		 * The response of the student , to check
		 * if a question is attempted
		 */
		private var _studentAnsFraction:Number=0;
		
		public var group:RadioButtonGroup=null;

		/**
		 * Count of an answer attempted by students
		 */
		private var _ansCount:Number=0;


		/**
		 * @public
		 * Get the answer id : primary key
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
		 */
		public function set quizAnswerChoiceId(quizAnswerChoiceId:Number):void {
			this._quizAnswerChoiceId=quizAnswerChoiceId;
		}

		/**
		 * @public
		 * Get the question
		 *
		 * @return QuizQuestionVO
		 */
		public function get quizQuestion():QuizQuestionVO {
			return _quizQuestion;
		}

		/**
		 * @public
		 * Set the question
		 * @param quizQuestion
		 * @return void
		 */
		public function set quizQuestion(quizQuestion:QuizQuestionVO):void {
			this._quizQuestion=quizQuestion;
		}

		/**
		 * @public
		 * Get the answer text
		 *
		 * @return String
		 */
		public function get choiceText():String {
			return _choiceText;
		}

		/**
		 * @public
		 * Set the answer text
		 * @param choiceText
		 * @return void
		 */
		public function set choiceText(choiceText:String):void {
			this._choiceText=choiceText;
		}

		/**
		 * @public
		 * Get the hash of answer text
		 *
		 * @return String
		 */
		public function get choiceTextHash():String {
			return _choiceTextHash;
		}

		/**
		 * @public
		 * Set the hash of answer text
		 * @param choiceTextHash
		 * @return void
		 */
		public function set choiceTextHash(choiceTextHash:String):void {
			this._choiceTextHash=choiceTextHash;
		}

		/**
		 * @public
		 * Get the fraction : 0 or 1 value ( for wrong/correct answer)
		 *
		 * @return Number
		 */
		public function get fraction():Number {
			return _fraction;
		}

		/**
		 * @public
		 * Set the fraction
		 * @param fraction
		 * @return void
		 */
		public function set fraction(fraction:Number):void {
			this._fraction=fraction;
		}

		/**
		 * @public
		 * Get the response whether student attempted a answer or not
		 *
		 * @return Number
		 */
		public function get studentAnsFraction():Number {
			return _studentAnsFraction;
		}

		/**
		 * @public
		 * Set the response whether student attempted a answer or not
		 * @param value
		 * @return void
		 */
		public function set studentAnsFraction(value:Number):void {
			_studentAnsFraction=value;
		}

		/**
		 * @public
		 * Get the count of answers
		 *
		 * @return Number
		 */
		public function get ansCount():Number {
			return _ansCount;
		}

		/**
		 * @public
		 * Set the count of answers
		 * @param value
		 * @return void
		 */
		public function set ansCount(value:Number):void {
			_ansCount=value;
		}


		/**
		 * @public
		 * Get the sequence of displaying answer
		 *
		 * @return Number
		 */
		public function get displaySequence():Number {
			return _displaySequence;
		}

		/**
		 * @public
		 * Set the sequence of displaying answer
		 * @param displaySequence
		 * @return void
		 */
		public function set displaySequence(displaySequence:Number):void {
			this._displaySequence=displaySequence;
		}

		/**
		 * @public
		 * Get the label i.e serial alphabet for sequencing answers
		 *
		 * @return String
		 */
		public function get choiceLabel():String {
			return _choiceLabel;
		}

		/**
		 * @public
		 * Set the label i.e serial alphabet for sequencing answers
		 * @param value
		 * @return void
		 */
		public function set choiceLabel(value:String):void {
			_choiceLabel=value;
		}


	}
}
