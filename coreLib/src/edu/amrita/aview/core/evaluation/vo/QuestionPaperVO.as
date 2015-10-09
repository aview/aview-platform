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
 * File			: QuestionPaperVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object class for question paper .
 *
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	import mx.collections.ArrayCollection;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuestionPaper")]
	public class QuestionPaperVO extends Auditable {
		/**
		 * The question paper id
		 */
		private var _questionPaperId:Number=0;

		/**
		 * The question paper name
		 */
		private var _questionPaperName:String=null;

		/**
		 * The current total marks
		 */
		private var _currentTotalMarks:Number=0.0;

		/**
		 * The max total marks
		 */
		private var _maxTotalMarks:Number=0.0;

		/**
		 * Stores if a question paper is complete or not
		 */
		private var _isComplete:String="N";

		/**
		 * The user name who created the question paper
		 */
		public var createdByUserName:String=null;

		/**
		 * The user name who modified the question paper
		 */
		public var modifiedByUserName:String=null;

		/**
		 * The total nos. of questions
		 */
		public var totalQns:Number=0;

		/**
		 * The institute id
		 */
		private var _instituteId:Number=0;

		/**
		 * The question paper questions list (used for one to many relation)
		 */
		private var _questionPaperQuestions:ArrayCollection=null;

		/**
		 * @public
		 * Get the question paper id : primary key
		 *
		 * @return Number
		 */
		public function get questionPaperId():Number {
			return _questionPaperId;
		}
		
		/**
		 * Dummy variable for UI
		 * Fix for Bug#11216
		 */
		 public var displayIndex:Number=0;

		/**
		 * @public
		 * Set the question paper id
		 * @param questionPaperId
		 * @return void
		 */
		public function set questionPaperId(questionPaperId:Number):void {
			this._questionPaperId=questionPaperId;
		}

		/**
		 * @public
		 * Get the question paper name
		 *
		 * @return String
		 */
		public function get questionPaperName():String {
			return _questionPaperName;
		}

		/**
		 * @public
		 * Set the question paper name
		 * @param questionPaperName
		 * @return void
		 */
		public function set questionPaperName(questionPaperName:String):void {
			this._questionPaperName=questionPaperName;
		}

		/**
		 * @public
		 * Get the current total marks
		 *
		 * @return Number
		 */
		public function get currentTotalMarks():Number {
			return _currentTotalMarks;
		}

		/**
		 * @public
		 * Set the current total marks
		 * @param currentTotalMarks
		 * @return void
		 */
		public function set currentTotalMarks(currentTotalMarks:Number):void {
			this._currentTotalMarks=currentTotalMarks;
		}

		/**
		 * @public
		 * Get the max total marks
		 *
		 * @return Number
		 */
		public function get maxTotalMarks():Number {
			return _maxTotalMarks;
		}

		/**
		 * @public
		 * Set the max total marks
		 * @param maxTotalMarks
		 * @return void
		 */
		public function set maxTotalMarks(maxTotalMarks:Number):void {
			this._maxTotalMarks=maxTotalMarks;
		}

		/**
		 * @public
		 * Get if a question paper is complete or not
		 *
		 * @return String
		 */
		public function get isComplete():String {
			return _isComplete;
		}

		/**
		 * @public
		 * Set if the question paper is complete or not
		 * @param isComplete
		 * @return void
		 */
		public function set isComplete(isComplete:String):void {
			this._isComplete=isComplete;
		}

		/**
		 * @public
		 * Get the list of question paper questions
		 *
		 * @return ArrayCollection
		 */
		public function get questionPaperQuestions():ArrayCollection {
			return this._questionPaperQuestions;
		}

		/**
		 * @public
		 * Set the list of question paper questions
		 * @param value
		 * @return void
		 */
		public function set questionPaperQuestions(value:ArrayCollection):void {
			this._questionPaperQuestions=value;
		}

		/**
		 * @public
		 * Adds question paper questions to a question paper
		 * @param questionPaperQuestion
		 * @return void
		 */
		public function addQuestionPaperQuestion(questionPaperQuestion:QuestionPaperQuestionVO):void {			
			if (this._questionPaperQuestions == null) {
				this._questionPaperQuestions=new ArrayCollection();
			}
			questionPaperQuestion.questionPaper=this;
			this._questionPaperQuestions.addItem(questionPaperQuestion);
		}

		/**
		 * @public
		 * Get the institute id
		 *
		 * @return Number
		 */
		public function get instituteId():Number {
			return _instituteId;
		}

		/**
		 * @public
		 * Set the institute id
		 * @param value
		 * @return void
		 */
		public function set instituteId(value:Number):void {
			_instituteId=value;
		}



	}
}
