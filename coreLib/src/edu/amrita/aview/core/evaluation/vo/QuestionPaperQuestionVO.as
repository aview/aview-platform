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
 * File			: QuestionPaperQuestionVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Question Paper Question
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuestionPaperQuestion")]
	public class QuestionPaperQuestionVO extends Auditable {
		/**
		 * Flag for checking duplicate question in random question
		 */
		public var isDuplicate:Boolean=false;

		/**
		 * Flag for checking negative or non zero marks for a question
		 */
		public var invalidMarks:Boolean=false;

		/**
		 * Flag for checking negative or non zero value for nos. of question
		 */
		public var invalidNumQns:Boolean=false;

		/**
		 * The question text
		 */
		public var _questionText:String;

		/**
		 * The question paper question id : Primary key
		 */
		private var _questionPaperQuestionId:Number=0;

		/**
		 * The pattern type : Random or Specific
		 */
		private var _patternType:String=null;

		/**
		 * Nos. of random questions
		 */
		private var _numRandomQuestions:Number=0;

		/**
		 * The question id : for specific question
		 */
		private var _qbQuestionId:Number=0;

		/**
		 * The subcategory id
		 */
		private var _qbSubcategoryId:Number=0;

		/**
		 * The difficulty level id
		 */
		private var _qbDifficultyLevelId:Number;

		/**
		 * The question type id
		 */
		private var _qbQuestionTypeId:Number;

		/**
		 * The marks for a question
		 */
		private var _marks:Number=0;
		
		//added for UI handling - to add Random Questions - to use in the itemEditors for the datagrid.

		/**
		 * The category id
		 */
		private var _qbCategoryId:Number=0;

		/**
		 * The subcategory name
		 */
		private var _qbSubcategoryName:String;

		/**
		 * The category name
		 */
		private var _qbCategoryName:String;

		/**
		 * The difficulty level name
		 */
		private var _qbDifficultyLevelName:String;

		/**
		 * The question type name
		 */
		private var _qbQuestionTypeName:String;

		/**
		 * Value Object for QuestionPaperVO
		 */
		private var _questionPaper:QuestionPaperVO=null;

		/**
		  * @public
		  * Get the question paper value object
		  *
		  * @return QbQuestionVO
		  */
		public function get questionPaper():QuestionPaperVO {
			return _questionPaper;
		}

		/**
		 * @public
		 * Set the question paper value object
		 * @param value
		 * @return void
		 */
		public function set questionPaper(value:QuestionPaperVO):void {
			_questionPaper=value;
		}

		/**
		 * @public
		 * Get the question paper question id : primary key
		 *
		 * @return Number
		 */
		public function get questionPaperQuestionId():Number {
			return _questionPaperQuestionId;
		}

		/**
		 * @public
		 * Set the question paper question id
		 * @param questionPaperQuestionId the questionPaperQuestionId to set
		 * @return void
		 */
		public function set questionPaperQuestionId(questionPaperQuestionId:Number):void {
			this._questionPaperQuestionId=questionPaperQuestionId;
		}

		/**
		 * @public
		 * Get the pattern type
		 *
		 * @return String
		 */
		public function get patternType():String {
			return _patternType;
		}

		/**
		 * @public
		 * Set the pattern type
		 * @param patternType the patternType to set
		 * @return void
		 */
		public function set patternType(patternType:String):void {
			this._patternType=patternType;
		}

		/**
		 * @public
		 * Get the nos. of random questions
		 *
		 * @return Number
		 */
		public function get numRandomQuestions():Number {
			return _numRandomQuestions;
		}

		/**
		 * @public
		 * Set the nos. of random questions
		 * @param numRandomQuestions the numRandomQuestions to set
		 * @return void
		 */
		public function set numRandomQuestions(numRandomQuestions:Number):void {
			this._numRandomQuestions=numRandomQuestions;
		}

		/**
		 * @public
		 * Get the question id
		 *
		 * @return Number
		 */
		public function get qbQuestionId():Number {
			return _qbQuestionId;
		}

		/**
		 * @public
		 * Set the question id
		 * @param qbQuestionId the qbQuestionId to set
		 * @return void
		 */
		public function set qbQuestionId(qbQuestionId:Number):void {
			this._qbQuestionId=qbQuestionId;
		}

		/**
		 * @public
		 * Get the subcategory id
		 *
		 * @return Number
		 */
		public function get qbSubcategoryId():Number {
			return _qbSubcategoryId;
		}

		/**
		 * @public
		 * Set the subcategory id
		 * @param qbSubcategoryId the qbSubcategoryId to set
		 * @return void
		 */
		public function set qbSubcategoryId(qbSubcategoryId:Number):void {
			this._qbSubcategoryId=qbSubcategoryId;
		}

		/**
		 * @public
		 * Get the difficulty level id
		 *
		 * @return Number
		 */
		public function get qbDifficultyLevelId():Number {
			return _qbDifficultyLevelId;
		}

		/**@public
		 * Set the difficulty level id
		 * @param qbDifficultyLevelId the qbDifficultyLevelId to set
		 * @return void
		 */
		public function set qbDifficultyLevelId(qbDifficultyLevelId:Number):void {
			this._qbDifficultyLevelId=qbDifficultyLevelId;
		}

		/**
		 * @public
		 * Get the question type id
		 *
		 * @return Number
		 */
		public function get qbQuestionTypeId():Number {
			return _qbQuestionTypeId;
		}

		/**
		 * @public
		 * Set the question type id
		 * @param qbQuestionTypeId the qbQuestionTypeId to set
		 * @return void
		 */
		public function set qbQuestionTypeId(qbQuestionTypeId:Number):void {
			this._qbQuestionTypeId=qbQuestionTypeId;
		}

		/**
		 * @public
		 * Get the marks
		 *
		 * @return Number
		 */
		public function get marks():Number {
			return _marks;
		}

		/**
		 * @public
		 * Set the marks
		 * @param marks the marks to set
		 * @return void
		 */
		public function set marks(marks:Number):void {
			this._marks=marks;
		}

		/**
		 * @public
		 * Get the category id
		 *
		 * @return Number
		 */
		public function get qbCategoryId():Number {
			return this._qbCategoryId;
		}

		/**
		 * @public
		 * Set the category id
		 * @param qbCategoryId
		 * @return void
		 */
		public function set qbCategoryId(qbCategoryId:Number):void {
			this._qbCategoryId=qbCategoryId;
		}

		/**
		 * @public
		 * Get the subcategory name
		 *
		 * @return String
		 */
		public function get qbSubcategoryName():String {
			return this._qbSubcategoryName;
		}

		/**
		 * @public
		 * Set the subcategory name
		 * @param qbSubcategoryName
		 * @return void
		 */
		public function set qbSubcategoryName(qbSubcategoryName:String):void {
			this._qbSubcategoryName=qbSubcategoryName;
		}

		/**
		 * @public
		 * Get the category name
		 *
		 * @return String
		 */
		public function get qbCategoryName():String {
			return this._qbCategoryName;
		}

		/**
		 * @public
		 * Set the category name
		 * @param qbCategoryName
		 * @return void
		 */
		public function set qbCategoryName(qbCategoryName:String):void {
			this._qbCategoryName=qbCategoryName;
		}

		/**
		 * @public
		 * Get the difficulty level name
		 *
		 * @return String
		 */
		public function get qbDifficultyLevelName():String {
			return this._qbDifficultyLevelName;
		}

		/**
		 * @public
		 * Set the difficulty level name
		 * @param qbDifficultyLevelName
		 * @return void
		 */
		public function set qbDifficultyLevelName(qbDifficultyLevelName:String):void {
			this._qbDifficultyLevelName=qbDifficultyLevelName;
		}

		/**
		 * @public
		 * Get the question type name
		 *
		 * @return String
		 */
		public function get qbQuestionTypeName():String {
			return this._qbQuestionTypeName;
		}

		/**
		 * @public
		 * Set the question type name
		 * @param qbQuestionTypeName
		 * @return void
		 */
		public function set qbQuestionTypeName(qbQuestionTypeName:String):void {
			this._qbQuestionTypeName=qbQuestionTypeName;
		}

		/**
		 * @public
		 *  Print the variables in this Class
		 *
		 * @return String
		 */
		public function toString():String {
			var str:String="questionPaperQuestionId::" + questionPaperQuestionId + "::questionPaperId::" + questionPaper.questionPaperId + "::patternType::" + patternType + "::numRandomQuestions::" + numRandomQuestions + "::qbQuestionId::" + qbQuestionId + "::qbSubcategoryId::" + qbSubcategoryId + "::qbDifficultyLevelId::" + qbDifficultyLevelId + "::qbQuestionTypeId::" + qbQuestionTypeId + "::marks::" + marks + "::statusId::" + statusId + "\n";
			return str;
		}

		/**
		 * Get the question text
		 * @return String
		 *
		 */
		public function get questionText():String {
			return _questionText;
		}
		
		/**
		 * Set the question text
		 * @param value type of String
		 *
		 */
		public function set questionText(value:String):void {
			_questionText=value;
		}

	}
}
