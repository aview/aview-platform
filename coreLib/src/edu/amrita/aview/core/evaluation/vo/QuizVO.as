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
 * File			: QuizVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Quiz .
 */
package edu.amrita.aview.core.evaluation.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	import mx.collections.ArrayCollection;
	
	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.Quiz")]
	public class QuizVO extends Auditable
	{
		/**
		 * The quiz id
		 */
		private var _quizId:Number=0;
		
		/**
		 * The quiz name
		 */
		private var _quizName:String=null;
		
		/**
		 * The class id
		 */
		private var _classId:Number=0;
		
		/**
		 * The question paper id
		 */
		private var _questionPaperId:Number=0;
		
		/**
		 * The total marks
		 */
		private var _totalMarks:Number=0;
		
		/**
		 * The start date of quiz
		 */
		private var _timeOpen:Date=null;
		
		/**
		 * The end date of quiz
		 */
		private var _timeClose:Date=null;
		
		/**
		 * The time limit for quiz
		 */
		private var _durationSeconds:Number=0;
		
		/**
		 * The status of quiz : Ready ,Active , Completed
		 */
		private var _quizStatus:String=null;
		
		/**
		 * The type of quiz : Live or Online
		 */
		private var _quizType:String=null;
		
		/**
		 * The institute id
		 */
		private var _instituteId:Number=0;
		
		// Non - mapped attributes		
		
		/**
		 * The class name 
		 */
		private var _className:String=null;
		
		/**
		 * The course name 
		 */
		private var _courseName:String=null;
		
		/**
		 * The course id 
		 */
		private var _courseId:Number=0;
		
		/**
		 * The count quiz questionId
		 */
		private var _countQuizQuestionId:Number=0;
		
		/**
		 * The user name 
		 */
		private var _userName:String=null;
		
		/**
		 * The fraction 
		 */
		private var _fraction:Number=0;
		
		/**
		 * The score 
		 */
		private var _score:Number=0;
		
		/**
		 * The total Score 
		 */
		private var _totalScore:Number=0;
		
		/**
		 * The percentage 
		 */
		private var _percentage:Number=0;
		
		/**
		 * Nos. of attempted questions 
		 */
		private var _attemptedQuestions:int=0;
		
		/**
		 * The user id 
		 */
		private var _userId:Number=0;
		
		/**
		 * List of quiz questions 
		 */
		private var _quizQuestions:ArrayCollection=null;
		
		/**
		 * Count of answers 
		 */
		private var _answerChoiceCount:Number=0;
		
		/**
		 * The answer text 
		 */
		private var _choiceText:String=null;
		
		/**
		 * The answer choice id 
		 */
		private var _quizAnswerChoiceId:Number=0;
		
		/**
		 * The question id 
		 */
		private var _quizQuestionId:Number=0;
		
		/**
		 * Nos. of wrong answers 
		 */
		private var _wrongAnswerCount:Number=0;
		
		private var _questionPaperName:String = null ;
		/**
		 * Dummy variable for UI
		 * Fix for Bug#11215
		 */
		public var displayIndex:Number = 0;
		/**
		 * @public
		 * Get the user id
		 *
		 * @return Number
		 */
		public function get userId():Number
		{
			return _userId;
		}
		
		/**
		 * @public
		 * Set the user id
		 * @param value
		 * @return void
		 */
		public function set userId(value:Number):void
		{
			_userId=value;
		}
		
		/**
		 * @public
		 * Get the total score
		 *
		 * @return Number
		 */
		public function get totalScore():Number
		{
			return _totalScore;
		}
		
		/**
		 * @public
		 * Set the total score
		 * @param value
		 * @return void
		 */
		public function set totalScore(value:Number):void
		{
			_totalScore=value;
		}
		
		/**
		 * @public
		 * Get the score of a student
		 *
		 * @return Number
		 */
		public function get score():Number
		{
			return _score;
		}
		
		/**
		 * @public
		 * Set score of a student
		 * @param value
		 * @return void
		 */
		public function set score(value:Number):void
		{
			this._score=value;
		}
		/**
		 * @public
		 * Get quiz question id count
		 *
		 * @return Number
		 */
		public function get countQuizQuestionId():Number
		{
			return _countQuizQuestionId;
		}
		/**
		 * @public
		 * Set quiz question id count
		 * @param value
		 * @return void
		 */
		public function set countQuizQuestionId(value:Number):void
		{
			this._countQuizQuestionId=value;
		}
		/**
		 * @public
		 * Get the user name
		 *
		 * @return String
		 */
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * @public
		 * Set the user name
		 * @param value
		 * @return void
		 */
		public function set userName(value:String):void
		{
			this._userName=value;
		}
		/**
		 * @public
		 * Get the fraction
		 *
		 * @return Number
		 */
		public function get fraction():Number
		{
			return _fraction;
		}

		/**
		 * @public
		 * Set the fraction
		 * @param value
		 * @return void
		 */
		public function set fraction(value:Number):void
		{
			this._fraction=value;
		}
		
		/**
		 * @public
		 * Get the quiz id
		 *
		 * @return Number
		 */
		public function get quizId():Number
		{
			return _quizId;
		}
		
		/**
		 * @public
		 * Set the quiz id
		 * @param quizId
		 * @return void
		 */
		public function set quizId(quizId:Number):void
		{
			this._quizId=quizId;
		}
		
		/**
		 * @public
		 * Get the quiz name
		 *
		 * @return String
		 */
		public function get quizName():String
		{
			return _quizName;
		}
		
		/**
		 * @public
		 * Set the quiz name
		 * @param quizName
		 * @return void
		 */
		public function set quizName(quizName:String):void
		{
			this._quizName=quizName;
		}
		
		/**
		 * @public
		 * Get the class id
		 *
		 * @return Number
		 */
		public function get classId():Number
		{
			return _classId;
		}
		
		/**
		 * @public
		 * Set the class id
		 * @param classId
		 * @return void
		 */
		public function set classId(classId:Number):void
		{
			this._classId=classId;
		}
		
		/**
		 * @public
		 * Get the question paper id
		 *
		 * @return Number
		 */
		public function get questionPaperId():Number
		{
			return _questionPaperId;
		}
		
		
		/**
		 * @public
		 * Set the question paper id
		 * @param questionPaperId
		 * @return void
		 */
		public function set questionPaperId(questionPaperId:Number):void
		{
			this._questionPaperId=questionPaperId;
		}
		
		/**
		 * @public
		 * Get the total marks
		 *
		 * @return Number
		 */
		public function get totalMarks():Number
		{
			return _totalMarks;
		}
		
		/**
		 * @public
		 * Set the total marks
		 * @param totalMarks
		 * @return void
		 */
		public function set totalMarks(totalMarks:Number):void
		{
			this._totalMarks=totalMarks;
		}
		
		/**
		 * @public
		 * Get the start date
		 *
		 * @return Date
		 */
		public function get timeOpen():Date
		{
			return _timeOpen;
		}
		
		/**
		 * @public
		 * Set the start date
		 * @param timeOpen
		 * @return void
		 */
		public function set timeOpen(timeOpen:Date):void
		{
			this._timeOpen=timeOpen;
		}
		
		/**
		 * @public
		 * Get the end date
		 *
		 * @return Date
		 */
		public function get timeClose():Date
		{
			return _timeClose;
		}
		
		/**
		 * @public
		 * Set the end date
		 * @param timeClose
		 * @return void
		 */
		public function set timeClose(timeClose:Date):void
		{
			this._timeClose=timeClose;
		}
		
		/**
		 * @public
		 * Get the time limit
		 *
		 * @return Number
		 */
		public function get durationSeconds():Number
		{
			return _durationSeconds;
		}
		
		/**
		 * @public
		 * Set the time limit
		 * @param durationSeconds
		 * @return void
		 */
		public function set durationSeconds(durationSeconds:Number):void
		{
			this._durationSeconds=durationSeconds;
		}
		
		/**
		 * @public
		 * Get the quiz status
		 *
		 * @return String
		 */
		public function get quizStatus():String
		{
			return _quizStatus;
		}
		
		/**
		 * @public
		 * Set the quiz status
		 * @param quizStatus
		 * @return void
		 */
		public function set quizStatus(quizStatus:String):void
		{
			this._quizStatus=quizStatus;
		}
		
		/**
		 * @public
		 * Get the quiz type
		 *
		 * @return String
		 */
		public function get quizType():String
		{
			return _quizType;
		}
		
		/**
		 * @public
		 * Set the quiz type
		 * @param quizType
		 * @return void
		 */
		public function set quizType(quizType:String):void
		{
			this._quizType=quizType;
		}
		
		/**
		 * @public
		 * Get the quiz questions
		 *
		 * @return ArrayCollection
		 */
		public function get quizQuestions():ArrayCollection
		{
			return _quizQuestions;
		}
		
		/**
		 * @public
		 * Set the quiz questions
		 * @param quizQuestions
		 * @return void
		 */
		public function set quizQuestions(quizQuestions:ArrayCollection):void
		{
			this._quizQuestions=quizQuestions;
		}
		
		/**
		 * @public
		 * Add quiz questions to quiz ( one to many association)
		 * @param quizQuestions
		 * @return void
		 */
		public function addQuizQuestions(quizQuestions:QuizQuestionVO):void
		{			
			if (this._quizQuestions == null)
			{
				this._quizQuestions=new ArrayCollection();
			}
			quizQuestions.quiz=this;
			this._quizQuestions.addItem(quizQuestions);
		}
		
		/**
		 * @public
		 * Get the class name
		 *
		 * @return String
		 */
		public function get className():String
		{
			return _className;
		}
		
		/**
		 * @public
		 * Set the class name
		 * @param value
		 * @return void
		 */
		public function set className(value:String):void
		{
			this._className=value;
		}
		
		/**
		 * @public
		 * Get the course name
		 *
		 * @return String
		 */
		public function get courseName():String
		{
			return _courseName;
		}
		
		/**
		 * @public
		 * Set the course name
		 * @param value
		 * @return void
		 */
		public function set courseName(value:String):void
		{
			this._courseName=value;
		}
		
		/**
		 * @public
		 * Get the course id
		 *
		 * @return Number
		 */
		public function get courseId():Number
		{
			return _courseId;
		}
		
		/**
		 * @public
		 * Set the course id
		 * @param value
		 * @return void
		 */
		public function set courseId(value:Number):void
		{
			this._courseId=value;
		}
		
		/**
		 * @public
		 * Get the count of answers
		 *
		 * @return Number
		 */
		public function get answerChoiceCount():Number
		{
			return _answerChoiceCount;
		}
		
		/**
		 * @public
		 * Set the count of answers
		 * @param value
		 * @return void
		 */
		public function set answerChoiceCount(value:Number):void
		{
			_answerChoiceCount=value;
		}
		
		/**
		 * @public
		 * Get the answer text
		 *
		 * @return String
		 */
		public function get choiceText():String
		{
			return _choiceText;
		}
		
		/**
		 * @public
		 * Set the answer text
		 * @param value
		 * @return void
		 */
		public function set choiceText(value:String):void
		{
			_choiceText=value;
		}
		
		/**
		 * @public
		 * Get the answer id
		 *
		 * @return Number
		 */
		public function get quizAnswerChoiceId():Number
		{
			return _quizAnswerChoiceId;
		}
		
		/**
		 * @public
		 * Set the answer id
		 * @param value
		 * @return void
		 */
		public function set quizAnswerChoiceId(value:Number):void
		{
			_quizAnswerChoiceId=value;
		}
		
		/**
		 * @public
		 * Get the quiz question id
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
		 * @param value
		 * @return void
		 */
		public function set quizQuestionId(value:Number):void
		{
			_quizQuestionId=value;
		}
		
		/**
		 * @public
		 * Get the percentage
		 *
		 * @return Number
		 */
		public function get percentage():Number
		{
			return _percentage;
		}
		
		/**
		 * @public
		 * Set the percentage
		 * @param value
		 * @return void
		 */
		public function set percentage(value:Number):void
		{
			_percentage=value;
		}
		
		/**
		 * @public
		 * Get the attempted questions
		 *
		 * @return int
		 */
		public function get attemptedQuestions():int
		{
			return _attemptedQuestions;
		}
		
		/**
		 * @public
		 * Set the attempted questions
		 * @param value
		 * @return void
		 */
		public function set attemptedQuestions(value:int):void
		{
			_attemptedQuestions=value;
		}
		
		/**
		 * @public
		 * Get the institute id
		 *
		 * @return Number
		 */
		public function get instituteId():Number
		{
			return _instituteId;
		}
		
		/**
		 * @public
		 * Set the institute id
		 * @param value
		 * @return void
		 */
		public function set instituteId(value:Number):void
		{
			_instituteId=value;
		}
		
		/**
		 * @public
		 * Get the wrong answer count
		 *
		 * @return Number
		 */
		public function get wrongAnswerCount():Number
		{
			return _wrongAnswerCount;
		}
		
		/**
		 * @public
		 * Set the wrong answer count
		 * @param value
		 * @return void
		 */
		public function set wrongAnswerCount(value:Number):void
		{
			_wrongAnswerCount=value;
		}

		/**
		 * @public
		 * Get the question paper name
		 * @return String 
		 */
		public function get questionPaperName():String
		{
			return _questionPaperName;
		}

		/**
		 * @private
		 * Set the question paper name
		 * @param value type of String
		 * @return String
		 */
		public function set questionPaperName(value:String):void
		{
			_questionPaperName = value;
		}

	
	}
}
