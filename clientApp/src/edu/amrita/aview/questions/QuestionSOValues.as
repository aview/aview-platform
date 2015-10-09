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
 * File			: QuestionSOValues.as
 * Module		: Question
 * Developer(s)	: Ravishankar
 * Reviewer(s)	: Meena S 
 * 
 * The shared object for storing and retrieving the info for the questions
 * posted during a session. Besides the posted question text, other details -
 * viz., posted by, status of the question (answered / unanswered), vote count,
 * voted by and the unique question id are also processed here.
 * 
 */

package edu.amrita.aview.questions
{
	/**
	 * Class used to store variables and constants for Question & Answer feature.
	 */
	public class QuestionSOValues
	{
		/**
		 * Used to store the name of the viewer that posted the question
		 */
		private var _postedBy:String;
		
		/**
		 * Used to store the count of votes for the posted question
		 */
		private var _vote:int;
		
		/**
		 * Used to store the posted question
		 */
		private var _question:String;

		/**
		 * Used to store the status of the posted question
		 */
		private var _questionStatus:String;

		/**
		 * Used to store the question-id for the posted question
		 */
		private var _questionId:String;
		/**
		 * Used to store the time of the posted question
		 */
		private var _postedTime:String;
		/**
		 * Used to store the name of the viewer that voted for the selected question
		 */
		[Bindable]
		private var _votedBy:Array=new Array;
		
		/**
		 * 
		 * @public
		 * This function is used to record the id, text, 
		 * status, vote count, viewer name that voted for 
		 * the question and viewer that posted the question.
		 * 
		 * @param so of object type
		 * @return void
		 * 
		 */
		public function QuestionSOValues(so:Object=null)
		{
			if (so == null)
			{
				return;
			}
			this.questionId=so.questionId;
			this.question=so.question;
			this.postedBy=so.postedBy;
			this.vote=so.vote;
			this.votedBy=so.votedBy;
			this.questionStatus=so.questionStatus;
			this.postedTime=so.postedTime;
		}

		/**
		 * 
		 * @public
		 * This function is used to fetch the viewer's name
		 * that posted the question.
		 * 
		 * @return postedBy of string type
		 * 
		 */
		public function get postedBy():String
		{
			return _postedBy;
		}
		
		/**
		 * 
		 * @public
		 * This  function is used to record the viewer's name
		 * that posted the question. 
		 * 
		 * @param postedBy of string type
		 * @return void
		 * 
		 */
		public function set postedBy(postedBy:String):void
		{
			this._postedBy=postedBy;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to fetch the selected question text.
		 * 
		 * @return question of string type
		 * 
		 */
		public function get question():String
		{
			return _question;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to record the viewer's name
		 * that posted the question. 
		 * 
		 * @param postedBy of string type
		 * @return void
		 * 
		 */
		public function set question(question:String):void
		{
			this._question=question;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to fetch the vote count for 
		 * the posted question.
		 * 
		 * @return vote of integer type
		 * 
		 */
		public function get vote():int
		{
			return _vote;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to record the viewer's vote
		 * for a posted question. 
		 * 
		 * @param vote of integer type
		 * @return void
		 * 
		 */
		 public function set vote(vote:int):void
		{
			this._vote=vote;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to fetch the viewer's name
		 * that voted for the question.
		 * 
		 * @return votedby of type array
		 * 
		 */
		public function get votedBy():Array
		{
			return _votedBy;
		}
		
	 	/**
		 * 
		 * @public
		 * This function is used to record the viewer's name
		 * that voted in favour of the question. 
		 * 
		 * @param votedBy of type Array
		 * @return void
		 * 
		 */
		public function set votedBy(votedBy:Array):void
		{
			this._votedBy=votedBy;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to fetch the question status 
		 * of the selected question.
		 * 
		 * @return questionstatus of string type
		 * 
		 */
		public function get questionStatus():String
		{
			return _questionStatus;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to record the question
		 * status of the question. 
		 * 
		 * @param questionStatus of string type
		 * @return void
		 * 
		 */
		public function set questionStatus(questionStatus:String):void
		{
			this._questionStatus=questionStatus;
		}
		
		/**
		 * 
		 * @public
		 * This function is used to fetch the question id 
		 * for the posted question.
		 * 
		 * @return questionId of string type
		 * 
		 */
		public function get questionId():String
		{
			return _questionId;
		}
		
		/**
		 * 
		 * @public
		 * This  function is used to record the question id
		 * for the question. 
		 * 
		 * @param questionId of string type
		 * @return void
		 * 
		 */
		public function set questionId(value:String):void
		{
			_questionId=value;
		}
		/**
		 * 
		 * @public
		 * This function is used to fetch the posted time 
		 * of the posted question.
		 * 
		 * @return postedTime of string type
		 * 
		 */
		public function get postedTime():String
		{
			return _postedTime;
		}
		/**
		 * 
		 * @public
		 * This  function is used to record the posted time
		 * of the question. 
		 * 
		 * @param postedTime of string type
		 * @return void
		 * 
		 */
		public function set postedTime(value:String):void
		{
			_postedTime=value;
		}
	}
}
