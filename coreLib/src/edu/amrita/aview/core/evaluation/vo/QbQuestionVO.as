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
 * File			: QbQuestionVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Question .
 * Stores the question
 *
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	import mx.collections.ArrayCollection;
	
	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QbQuestion")]
	public class QbQuestionVO extends Auditable {
		/**
		 * The question id : primary key
		 */
		private var _qbQuestionId:Number=0;

		/**
		 * The subcategory id
		 */
		private var _qbSubcategoryId:Number=0;

		/**
		 * The question type id
		 */
		private var _qbQuestionTypeId:Number=0;

		/**
		 * The difficulty level id
		 */
		private var _qbDifficultyLevelId:Number=0;

		/**
		 * The question text
		 */
		private var _questionText:String=null;

		/**
		 * The marks for question
		 */
		private var _marks:Number=0;

		/**
		 * The parent id
		 */
		private var _parentId:Number;

		/**
		 * The hash text for question
		 */
		private var _questionTextHash:String=null;

		/**
		 * The list of answer choices
		 */
		private var _qbAnswerChoices:ArrayCollection=null;

		/**
		 * The question bank question media files
		 */
		private var _qbQuestionMediaFiles:ArrayCollection = new ArrayCollection();
		
		//non mapped attributes
		/**
		 * The difficulty level name
		 */
		private var _qbDifficultyLevelName:String=null;

		/**
		 * The question type name
		 */
		private var _qbQuestionTypeName:String=null;

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
		 * @param qbSucategoryId the qbSucategoryId to set
		 * @return void
		 */
		public function set qbSubcategoryId(qbSubcategoryId:Number):void {
			this._qbSubcategoryId=qbSubcategoryId;
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
		 * Get the difficulty level id
		 *
		 * @return Number
		 */
		public function get qbDifficultyLevelId():Number {
			return _qbDifficultyLevelId;
		}

		/**
		 * @public
		 * Set the difficulty level id
		 * @param qbDifficultyLevelId the qbDifficultyLevelId to set
		 * @return void
		 */
		public function set qbDifficultyLevelId(qbDifficultyLevelId:Number):void {
			this._qbDifficultyLevelId=qbDifficultyLevelId;
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
		 * @param questionText the questionText to set
		 * @return void
		 */
		public function set questionText(questionText:String):void {
			this._questionText=questionText;
		}

		/**
		 * @public
		 * Get the marks
		 * @parm null
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
		 * Get the parent id
		 * @return the parentId
		 * @return Number
		 */
		public function get parentId():Number {
			return _parentId;
		}

		/**
		 * @public
		 * Set the parent id
		 * @param parentId the parentId to set
		 * @return void
		 */
		public function set parentId(parentId:Number):void {
			this._parentId=parentId;
		}

		/**
		 * @public
		 * Get the question text hash
		 *
		 * @return String
		 */
		public function get questionTextHash():String {
			return _questionTextHash;
		}

		/**
		 * @public
		 * Set the question text hash
		 * @param questionTextHash the questionTextHash to set
		 * @return void
		 */
		public function set questionTextHash(questionTextHash:String):void {
			this._questionTextHash=questionTextHash;
		}

		[Bindable]
		/**
		 * @public
		 * Get the list of answer choices
		 *
		 * @return ArrayCollection
		 */
		public function get qbAnswerChoices():ArrayCollection {
			return _qbAnswerChoices;
		}

		/**
		 * @public
		 * Set the list of answer choices
		 * @param qbAnswerChoices
		 * @return void
		 */
		public function set qbAnswerChoices(qbAnswerChoices:ArrayCollection):void {
			this._qbAnswerChoices=qbAnswerChoices;
		}

		/**
		 * @public
		 * Adds the answer choices (its a one to many relation between question and answer)
		 * @param qbAnswerChoices
		 * @return void
		 */
		public function addQbAnswerChoices(qbAnswerChoices:QbAnswerChoiceVO):void {
			if (this._qbAnswerChoices == null) {
				this._qbAnswerChoices=new ArrayCollection();
			}
			qbAnswerChoices.qbQuestion=this;
			this._qbAnswerChoices.addItem(qbAnswerChoices);
		}		
		
		/**
		 * @public
		 * Get the list of question bank question media files
		 * @return ArrayCollection
		 */
		public function get qbQuestionMediaFiles():ArrayCollection
		{
			return _qbQuestionMediaFiles;
		}

		/**
		 * @public
		 * Set the list of question bank question media files
		 * @param qbQuestionMediaFiles type of ArrayCollection
		 * @return void
		 */
		public function set qbQuestionMediaFiles(qbQuestionMediaFiles:ArrayCollection):void
		{
			_qbQuestionMediaFiles = qbQuestionMediaFiles;
		}
		
		/**
		 * @public
		 * Adds the question bank question media files
		 * @param qbQuestionMediaFile type of QbQuestionMediaFileVO
		 * @return void
		 */
		public function addQbQuestionMediaFile(qbQuestionMediaFile : QbQuestionMediaFileVO) : void
		{
			qbQuestionMediaFile.qbQuestion = this;
			this.qbQuestionMediaFiles.addItem(qbQuestionMediaFile);
		}
		
		/**
		 * @public
		 * Gets the difficulty level name
		 *
		 * @return String
		 */
		public function get qbDifficultyLevelName():String {
			return _qbDifficultyLevelName;
		}

		/**
		 * @public
		 * Sets the difficulty level name
		 * @param qbDifficultyLevelName the qbDifficultyLevelName to set
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
			return _qbQuestionTypeName;
		}

		/**
		 * @public
		 * Set the question type name
		 * @param qbQuestionTypeName the qbQuestionTypeName to set
		 * @return void
		 */
		public function set qbQuestionTypeName(qbQuestionTypeName:String):void {
			this._qbQuestionTypeName=qbQuestionTypeName;
		}

		/**
		 * @public
		 * Prints all the variables in this class
		 *
		 * @return String
		 */
		public function toString():String {
			var str:String="QbQuestion::";
			str+="qbQuestionId::" + qbQuestionId;
			str+="::qbSubcategoryId::" + qbSubcategoryId;
			str+="::qbQuestionTypeId::" + qbQuestionTypeId;
			str+="::qbDifficultyLevelId::" + qbDifficultyLevelId;
			str+="::questionText::" + questionText;
			str+="::marks::" + marks;
			str+="::questionTextHash::" + questionTextHash;
			str+="::createdByUserId::" + createdByUserId;
			str+="::createdDate::" + createdDate;
			str+="::modifiedByUserId::" + modifiedByUserId;
			str+="::modifiedDate::" + modifiedDate;
			str+="::statusId::" + statusId;
			str+="::qbAnswerChoices::" + qbAnswerChoices;
			return str;
		}
	}
}
