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
 * File			:QuizQuestionVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Quiz Question
 */
package edu.amrita.aview.core.evaluation.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	import mx.collections.ArrayCollection;
	
	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuizQuestion")]
	public class QuizQuestionVO extends Auditable
	{
		/**
		 * The quiz question id
		 */
		private var _quizQuestionId:Number=0;
		
		/**
		 * The quiz id
		 */
		private var _quizId:Number=0;
		
		/**
		 * The category id
		 */
		private var _categoryId:Number=0;
		
		/**
		 * The category name
		 */
		private var _categoryName:String=null;
		
		/**
		 * The subcategory id
		 */
		private var _subcategoryId:Number=0;
		
		/**
		 * The subcategory name
		 */
		private var _subcategoryName:String=null;
		
		/**
		 * The question type name
		 */
		private var _questionTypeName:String=null;
		
		/**
		 * The difficulty level name
		 */
		private var _difficultyLevelName:String=null;
		
		/**
		 * The question paper question id
		 */
		private var _questionPaperQuestionId:Number=0;
		
		/**
		 * The question id
		 */
		private var _qbQuestionId:Number=0;
		
		/**
		 * The hash for question text
		 */
		private var _questionTextHash:String=null;
		
		/**
		 * The question text
		 */
		private var _questionText:String=null;
		
		/**
		 * The marks
		 */
		private var _marks:Number=0;
		
		/**
		 * The quiz value object
		 */
		private var _quiz:QuizVO=null;
		
		/**
		 * The list of answers
		 */
		private var _quizAnswerChoices:ArrayCollection=null;
		
		/**
		 * The list of media files
		 */
		private var _quizQuestionMediaFiles:ArrayCollection=null;

		/**
		 * @public
		 * Get the quiz question id : primary key
		 *
		 * @return Number
		 */
		public function get quizQuestionId():Number
		{
			return _quizQuestionId;
		}
		
		/**
		 * @public
		 * Set the quiz question id
		 * @param quizQuestionId the quizQuestionId to set
		 * @return void
		 */
		public function set quizQuestionId(quizQuestionId:Number):void
		{
			this._quizQuestionId=quizQuestionId;
		}
		
		/**
		 * @public
		 * Get the quiz value object
		 *
		 * @return QuizVO
		 */
		public function get quiz():QuizVO
		{
			return _quiz;
		}
		
		/**
		 * @public
		 * Set the quiz value object( for many one association)
		 * @param quiz
		 * @return void
		 */
		public function set quiz(quiz:QuizVO):void
		{
			this._quiz=quiz;
		}
		
		/**
		 * @public
		 * Get the category id
		 *
		 * @return Number
		 */
		public function get categoryId():Number
		{
			return _categoryId;
		}
		
		/**
		 * @public
		 * Set the category id
		 * @param categoryId
		 * @return void
		 */
		public function set categoryId(categoryId:Number):void
		{
			this._categoryId=categoryId;
		}
		
		/**
		 * @public
		 * Get the category name
		 *
		 * @return String
		 */
		public function get categoryName():String
		{
			return _categoryName;
		}
		
		/**
		 * @public
		 * Set the category name
		 * @param categoryName
		 * @return void
		 */
		public function set categoryName(categoryName:String):void
		{
			this._categoryName=categoryName;
		}
		
		/**
		 * @public
		 * Get the subcategory id
		 *
		 * @return Number
		 */
		public function get subcategoryId():Number
		{
			return _subcategoryId;
		}
		
		/**
		 * @public
		 * Set the subcategory id
		 * @param subcategoryId the subcategoryId to set
		 * @return void
		 */
		public function set subcategoryId(subcategoryId:Number):void
		{
			this._subcategoryId=subcategoryId;
		}
		
		/**
		 * @public
		 * Get the subcategory name
		 *
		 * @return String
		 */
		public function get subcategoryName():String
		{
			return _subcategoryName;
		}
		
		/**
		 * @public
		 * Set the subcategory name
		 * @param subcategoryName the subcategoryName to set
		 * @return void
		 */
		public function set subcategoryName(subcategoryName:String):void
		{
			this._subcategoryName=subcategoryName;
		}
		
		/**
		 * @public
		 * Get the question type name
		 *
		 * @return String
		 */
		public function get questionTypeName():String
		{
			return _questionTypeName;
		}
		
		/**
		 * @public
		 * Set the question type name
		 * @param questionTypeName the questionTypeName to set
		 * @return void
		 */
		public function set questionTypeName(questionTypeName:String):void
		{
			this._questionTypeName=questionTypeName;
		}
		
		/**
		 * @public
		 * Get the difficulty level name
		 *
		 * @return String
		 */
		public function get difficultyLevelName():String
		{
			return _difficultyLevelName;
		}
		
		/**
		 * @public
		 * Set the difficulty level name
		 * @param difficultyLevelName the difficultyLevelName to set
		 * @return void
		 */
		public function set difficultyLevelName(difficultyLevelName:String):void
		{
			this._difficultyLevelName=difficultyLevelName;
		}
		
		/**
		 * @public
		 * Get the question paper question id
		 *
		 * @return Number
		 */
		public function get questionPaperQuestionId():Number
		{
			return _questionPaperQuestionId;
		}
		
		/**
		 * @public
		 * Set the question paper question id
		 * @param questionPaperQuestionId the questionPaperQuestionId to set
		 * @return void
		 */
		public function set questionPaperQuestionId(questionPaperQuestionId:Number):void
		{
			this._questionPaperQuestionId=questionPaperQuestionId;
		}
		
		/**
		 * @public
		 * Get the question id
		 *
		 * @return Number
		 */
		public function get qbQuestionId():Number
		{
			return _qbQuestionId;
		}
		
		/**
		 * @public
		 * Set the question id
		 * @param qbQuestionId the qbQuestionId to set
		 * @return void
		 */
		public function set qbQuestionId(qbQuestionId:Number):void
		{
			this._qbQuestionId=qbQuestionId;
		}
		
		/**
		 * @public
		 * Get the hash for question text
		 *
		 * @return String
		 */
		public function get questionTextHash():String
		{
			return _questionTextHash;
		}
		
		/**
		 * @public
		 * Set the hash for question text
		 * @param questionTextHash the questionTextHash to set
		 * @return void
		 */
		public function set questionTextHash(questionTextHash:String):void
		{
			this._questionTextHash=questionTextHash;
		}
		
		/**
		 * @public
		 * Get the question text
		 *
		 * @return String
		 */
		public function get questionText():String
		{
			return _questionText;
		}
		
		/**
		 * @public
		 * Set the question text
		 * @param questionText the questionText to set
		 * @return void
		 */
		public function set questionText(questionText:String):void
		{
			this._questionText=questionText;
		}
		
		/**
		 * @public
		 * Get the marks
		 *
		 * @return Number
		 */
		public function get marks():Number
		{
			return _marks;
		}
		
		/**
		 * @public
		 * Set the marks
		 * @param marks
		 * @return void
		 */
		public function set marks(marks:Number):void
		{
			this._marks=marks;
		}
		
		/**
		 * @public
		 * Get the list of answers
		 *
		 * @return ArrayCollection
		 */
		public function get quizAnswerChoices():ArrayCollection
		{
			return _quizAnswerChoices;
		}
		
		/**
		 * @public
		 * Set the list of answers
		 * @param quizAnswerChoices
		 * @return void
		 */
		public function set quizAnswerChoices(quizAnswerChoices:ArrayCollection):void
		{
			this._quizAnswerChoices=quizAnswerChoices;
		}
		
		/**
		 * @public
		 * Add the answers to the question
		 * @param quizAnswerChoices
		 * @return void
		 */
		public function addQuizAnswerChoices(quizAnswerChoices:QuizAnswerChoiceVO):void
		{   
			// Initialise the array collection
			if (this._quizAnswerChoices == null)
			{
				this.quizAnswerChoices=new ArrayCollection();
			}
			quizAnswerChoices.quizQuestion=this;
			this._quizAnswerChoices.addItem(quizAnswerChoices);
		}

		/**
		 * @public
		 * Get the list of quiz question media files
		 *
		 * @return ArrayCollection
		 */
		public function get quizQuestionMediaFiles():ArrayCollection
		{
			return _quizQuestionMediaFiles;
		}

		/**
		 * @public
		 * Set the list of quiz question media files
		 * @param quizQuestionMediaFiles type of ArrayCollection
		 * @return void
		 */
		public function set quizQuestionMediaFiles(quizQuestionMediaFiles:ArrayCollection):void
		{
			_quizQuestionMediaFiles = quizQuestionMediaFiles;
		}
		
		/**
		 * @public
		 * Add the media files to the question
		 * @param quizQuestionMediaFile type of QuizQuestionMediaFileVO
		 * @return void
		 */
		public function addQuizQuestionMediaFiles(quizQuestionMediaFile:QuizQuestionMediaFileVO):void
		{   
			// Initialise the array collection
			if (this._quizQuestionMediaFiles == null)
			{
				this.quizQuestionMediaFiles = new ArrayCollection();
			}
			quizQuestionMediaFile.quizQuestion=this;
			this._quizQuestionMediaFiles.addItem(quizQuestionMediaFile);
		}
	}
}