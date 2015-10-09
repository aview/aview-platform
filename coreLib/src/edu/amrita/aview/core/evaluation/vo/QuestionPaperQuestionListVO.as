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
 * File			: QuestionPaperQuestionListVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object class for storing non transient attributes related
 * to question paper question
 */
package edu.amrita.aview.core.evaluation.vo {

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.vo.QuestionPaperQuestionListVO")]
	public class QuestionPaperQuestionListVO {
		/**
		 * The question value object
		 */
		private var _qbQuestion:QbQuestionVO;

		/**
		 * The question paper question value object
		 */
		private var _questionPaperQuestion:QuestionPaperQuestionVO;

		/**
		 * @public
		 * Get the question value object
		 *
		 * @return QbQuestionVO
		 */
		public function get qbQuestion():QbQuestionVO {
			return _qbQuestion;
		}

		/**
		 * @public
		 * Set the question value object
		 * @param qbQuestion
		 * @return void
		 */
		public function set qbQuestion(qbQuestion:QbQuestionVO):void {
			this._qbQuestion=qbQuestion;
		}

		/**
		 * @public
		 * Get the question paper question value object
		 *
		 * @return QuestionPaperQuestionVO
		 */
		public function get questionPaperQuestion():QuestionPaperQuestionVO {
			return _questionPaperQuestion;
		}

		/**
		 * @public
		 * Set the question paper question value object
		 * @param questionPaperQuestion
		 * @return void
		 */
		public function set questionPaperQuestion(questionPaperQuestion:QuestionPaperQuestionVO):void {
			this._questionPaperQuestion=questionPaperQuestion;
		}

	}
}
