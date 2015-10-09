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
 * File			: QuizQuestionResponseVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Quiz Question Response
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	import mx.collections.ArrayCollection;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuizQuestionResponse")]
	public class QuizQuestionResponseVO extends Auditable {

		/**
		 * The question response id : primary key
		 */
		private var _quizQuestionResponseId:Number=0;

		/**
		 * The quiz response id
		 */
		private var _quizResponseId:Number=0;

		/**
		 * The quiz question id
		 */
		private var _quizQuestionId:Number=0;

		/**
		 * The score of the question
		 */
		private var _score:Number=0;

		/**
		 * The quiz response value object
		 */
		private var _quizResponse:QuizResponseVO=null;

		/**
		 * The list of answers attempted by user for a question
		 */
		private var _quizQuestionChoiceResponse:ArrayCollection=null;

		// user defined variables for polling result
		/**
		 * The quiz question id for polling
		 */
		private var _quizQuestionIdPolling:int=0;

		/**
		 * The question text
		 */
		private var _questionText:String=null;

		/**
		 * The answer choice id
		 */
		private var _quizAnswerChoiceId:int=0;

		/**
		 * The answer text
		 */
		private var _choiceText:String=null;

		/**
		 * Count of correct answers for a choice id
		 */
		private var _correctCountForAnswerChoice:int=0;

		/**
		 * Count of students registered for a class
		 */
		private var _studentCountForClass:int=0;

		/**
		 * List of answer choices
		 */
		private var _quizAnswerChoices:ArrayCollection=null;

		/**
		 * The serial order of answer choices
		 */
		private var _displaySequence:int=0;

		/**
		 * @public
		 * Get the quiz question response id
		 *
		 * @return Number
		 */
		public function get quizQuestionResponseId():Number {
			return _quizQuestionResponseId;
		}

		/**
		 * @public
		 * Set the quiz question response id
		 * @param quizQuestionResponseId
		 * @return void
		 */
		public function set quizQuestionResponseId(quizQuestionResponseId:Number):void {
			this._quizQuestionResponseId=quizQuestionResponseId;
		}

		/**
		 * @public
		 * Get the quiz response value object
		 *
		 * @return QuizResponseVO
		 */
		public function get quizResponse():QuizResponseVO {
			return _quizResponse;
		}

		/**
		 * @public
		 * Set the quiz response object
		 * @param quizResponseId the quizResponse to set
		 * @return void
		 */
		public function set quizResponse(quizResponse:QuizResponseVO):void {
			this._quizResponse=quizResponse;
		}

		/**
		 * @public
		 * Add the answer responses for a question
		 * @param quizQuestionChoiceResponses
		 * @return void
		 */
		public function addQuizQuestionChoiceResponses(quizQuestionChoiceResponses:QuizQuestionChoiceResponseVO):void {			
			if (this._quizQuestionChoiceResponse == null) {
				this._quizQuestionChoiceResponse=new ArrayCollection();
			}
			quizQuestionChoiceResponses.quizQuestionResponse=this;
			this._quizQuestionChoiceResponse.addItem(quizQuestionChoiceResponses);
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
		 * @param quizQuestionId
		 * @return void
		 */
		public function set quizQuestionId(quizQuestionId:Number):void {
			this._quizQuestionId=quizQuestionId;
		}

		/**
		 * @public
		 * Get the score
		 *
		 * @return Number
		 */
		public function get score():Number {
			return _score;
		}

		/**
		 * @public
		 * Set the score
		 * @param score
		 * @return void
		 */
		public function set score(score:Number):void {
			this._score=score;
		}

		/**
		 * @public
		 * Get the question text
		 *
		 * @return String
		 */
		public function get questionText():String {
			return _questionText;
		}

		/**
		 * @public
		 * Set the question text
		 * @param value
		 * @return void
		 */
		public function set questionText(value:String):void {
			_questionText=value;
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
		 * @param value
		 * @return void
		 */
		public function set quizAnswerChoiceId(value:Number):void {
			_quizAnswerChoiceId=value;
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
		 * @param value
		 * @return void
		 */
		public function set choiceText(value:String):void {
			_choiceText=value;
		}

		/**
		 * @public
		 * Get the correct count of answers
		 *
		 * @return int
		 */
		public function get correctCountForAnswerChoice():int {
			return _correctCountForAnswerChoice;
		}

		/**
		 * @public
		 * Set the correct count of answers
		 * @param value
		 * @return void
		 */
		public function set correctCountForAnswerChoice(value:int):void {
			_correctCountForAnswerChoice=value;
		}

		/**
		 * @public
		 * Get the count of students for a class
		 *
		 * @return int
		 */
		public function get studentCountForClass():int {
			return _studentCountForClass;
		}

		/**
		 * @public
		 * Set the count of students for a class
		 * @param value
		 * @return void
		 */
		public function set studentCountForClass(value:int):void {
			_studentCountForClass=value;
		}

		/**
		 * @public
		 * Get the answers
		 *
		 * @return ArrayCollection
		 */
		public function get quizAnswerChoices():ArrayCollection {
			return _quizAnswerChoices;
		}

		/**
		 * @public
		 * Set the answers
		 * @param value
		 * @return void
		 */
		public function set quizAnswerChoices(value:ArrayCollection):void {
			_quizAnswerChoices=value;
		}

		/**
		 * @public
		 * Get the display sequence(serial alphabets)
		 *
		 * @return int
		 */
		public function get displaySequence():int {
			return _displaySequence;
		}

		/**
		 * @public
		 * Set the display sequence(serial alphabets)
		 * @param value
		 * @return void
		 */
		public function set displaySequence(value:int):void {
			_displaySequence=value;
		}


	}
}
