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
 * File			: QuizResponseVO.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Narayanasamy S
 *
 * Value Object Class for Quiz Response
 */
package edu.amrita.aview.core.evaluation.vo {
	import edu.amrita.aview.core.shared.vo.Auditable;

	import mx.collections.ArrayCollection;

	/** 
	 * The remote java class file which is mapped with this VO class
	 */
	[RemoteClass(alias="edu.amrita.aview.evaluation.entities.QuizResponse")]
	public class QuizResponseVO extends Auditable {
		/**
		 * The quiz response id : primary key
		 */
		private var _quizResponseId:Number=0;

		/**
		 * The user id
		 */
		private var _userId:Number=0;

		/**
		 * The quiz id
		 */
		private var _quizId:Number=0;

		/**
		 * The total score
		 */
		private var _totalScore:Number=0;

		/**
		 * The start date
		 */
		private var _timeStart:Date=null;

		/**
		 * The end date
		 */
		private var _timeEnd:Date=null;

		/**
		 * The response type : PC or Mobile
		 */
		private var _quizResponseType:String=null;

		/**
		 * The list of questions for the quiz response
		 */
		private var _quizQuestionResponse:ArrayCollection=null;

		/**
		 * @public
		 * Get the quiz response id : primary key
		 *
		 * @return Number
		 */
		public function get quizResponseId():Number {
			return _quizResponseId;
		}

		/**
		 * @public
		 * Set the quiz response id
		 * @param quizResponseId
		 * @return void
		 */
		public function set quizResponseId(quizResponseId:Number):void {
			this._quizResponseId=quizResponseId;
		}

		/**
		 * @public
		 * Get the user id
		 *
		 * @return Number
		 */
		public function get userId():Number {
			return _userId;
		}

		/**
		 * @public
		 * Set the user id
		 * @param userId
		 * @return void
		 */
		public function set userId(userId:Number):void {
			this._userId=userId;
		}

		/**
		 * @public
		 * Get the quiz id
		 *
		 * @return Number
		 */
		public function get quizId():Number {
			return _quizId;
		}

		/**
		 * @public
		 * Set the quiz id
		 * @param quizId
		 * @return void
		 */
		public function set quizId(quizId:Number):void {
			this._quizId=quizId;
		}

		/**
		 * @public
		 * Get the total score for a quiz
		 *
		 * @return Number
		 */
		public function get totalScore():Number {
			return _totalScore;
		}

		/**
		 * @public
		 * Set the total score for a quiz
		 * @param totalScore
		 * @return void
		 */
		public function set totalScore(totalScore:Number):void {
			this._totalScore=totalScore;
		}

		/**
		 * @public
		 * Get the start date of the quiz
		 *
		 * @return Date
		 */
		public function get timeStart():Date {
			return _timeStart;
		}

		/**
		 * @public
		 * Set the start date of the quiz
		 * @param timeStart
		 * @return void
		 */
		public function set timeStart(timeStart:Date):void {
			this._timeStart=timeStart;
		}

		/**
		 * @public
		 * Get the end date of the quiz
		 *
		 * @return Date
		 */
		public function get timeEnd():Date {
			return _timeEnd;
		}

		/**
		 * @public
		 * Set the end date of the quiz
		 * @param timeEnd the timeEnd to set
		 * @return void
		 */
		public function set timeEnd(timeEnd:Date):void {
			this._timeEnd=timeEnd;
		}

		/**
		 * @public
		 * Get the response type : PC or Mobile
		 *
		 * @return String
		 */
		public function get quizResponseType():String {
			return _quizResponseType;
		}

		/**
		 * @public
		 *  Set the response type
		 * @param quizResponseType the quizResponseType to set
		 * @return void
		 */
		public function set quizResponseType(quizResponseType:String):void {
			this._quizResponseType=quizResponseType;
		}

		/**
		 * @public
		 * Get the questions
		 *
		 * @return ArrayCollection
		 */
		public function get quizQuestionResponse():ArrayCollection {
			return _quizQuestionResponse;
		}

		/**
		 * @public
		 * Set the questions
		 * @param quizResponseId the quizResponseId to set
		 * @return void
		 */
		public function set quizQuestionResponse(quizQuestionResponse:ArrayCollection):void {
			this._quizQuestionResponse=quizQuestionResponse;
		}

		/**
		 * @public
		 * Add the question response (one to many associations)
		 * @param quizQuestionResponses
		 * @return void
		 */
		public function addQuizQuestionResponses(quizQuestionResponses:QuizQuestionResponseVO):void {			
			if (this._quizQuestionResponse == null) {
				this._quizQuestionResponse=new ArrayCollection();
			}
			quizQuestionResponses.quizResponse=this;
			this._quizQuestionResponse.addItem(quizQuestionResponses);
		}
	}
}
