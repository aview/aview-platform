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
 * File			: QbAnswerChoiceVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object class for QbAnswerChoice .
 * Stores details of a answer choice for a question
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	/**
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbAnswerChoice")]
	public class QbAnswerChoiceVO extends Auditable {
		/**
		 * The question type
		 */
		public var questionTypeId:Number=0;

		/**
		 * The difficulty level
		 */
		public var questionLevelId:Number=0;

		/**
		 * The primary key : id
		 */
		private var _qbAnswerChoiceId:Number=0;

		/**
		 * The text of answer
		 */
		private var _choiceText:String=null;

		/**
		 * 0 or 1 value representing wrong or
		 * correct answer respectively
		 */
		private var _fraction:Number=0;

		/**
		 *  The hash value of answer
		 */
		private var _choiceTextHash:String=null;

		/**
		 * The sequence of answers
		 */
		private var _displaySequence:Number=0;

		/**
		 * The question VO
		 */
		private var _qbQuestion:QbQuestionVO=null;

		/**
		 * @public
		 * Get the answer id
		 *
		 * @return number
		 */
		public function get qbAnswerChoiceId():Number {
			return _qbAnswerChoiceId;
		}

		/**
		 * @public
		 * Set the answer id
		 * @param qbAnswerChoiceId the qbAnswerChoiceId to set
		 * @return void
		 */
		public function set qbAnswerChoiceId(qbAnswerChoiceId:Number):void {
			this._qbAnswerChoiceId=qbAnswerChoiceId;
		}

		/**
		 * @public
		 * Get the question
		 *
		 * @return QbQuestionVO
		 */
		public function get qbQuestion():QbQuestionVO {
			return _qbQuestion;
		}

		/**
		 * @public
		 * Set the question
		 * @param qbQuestion the qbQuestion to set
		 * @return void
		 */
		public function set qbQuestion(qbQuestion:QbQuestionVO):void {
			this._qbQuestion=qbQuestion;
		}

		/**
		 * @public
		 * Get the answer text
		 *
		 * @return String
		 *
		 */
		public function get choiceText():String {
			return _choiceText;
		}

		/**
		 * @public
		 * Set the answer text
		 * @param choiceText the choiceText to set
		 * @return void
		 */
		public function set choiceText(choiceText:String):void {
			this._choiceText=choiceText;
		}

		/**
		 * @public
		 * Get the fraction : 0 or 1
		 *
		 * @return Number
		 *
		 */
		public function get fraction():Number {
			return _fraction;
		}

		/**
		 * @public
		 * Set the fraction
		 * @param fraction the fraction to set
		 * @return void
		 */
		public function set fraction(fraction:Number):void {
			this._fraction=fraction;
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
		 * @param choiceTextHash the choiceTextHash to set
		 * @return void
		 */
		public function set choiceTextHash(choiceTextHash:String):void {
			this._choiceTextHash=choiceTextHash;
		}

		/**
		 * @public
		 * Get the sequence of answer text
		 *
		 * @return Number
		 */
		public function get displaySequence():Number {
			return _displaySequence;
		}

		/**
		 * @public
		 * Set the sequence of answer text
		 * @param displaySequence the displaySequence to set
		 * @return void
		 */
		public function set displaySequence(displaySequence:Number):void {
			this._displaySequence=displaySequence;
		}
	}
}
