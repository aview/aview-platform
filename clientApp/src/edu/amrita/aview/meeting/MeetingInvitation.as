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
 *
 * File		   : InvitationMessage.mxml
 * Module	   : meeting
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) :
 *
 * Contains the details about meeting.
 * contains title,meeting name,moderatorname,username,userid and lectureid.
 *
 */
package edu.amrita.aview.meeting
{
	
	public class MeetingInvitation
	{
		private var _title:String="";
		private var _userId:Number=0;
		private var _lectureId:Number=0;
		private var _meetingName:String="";
		private var _moderatorName:String="";
		private var _userName:String="";
		
		public function MeetingInvitation()
		{
		}
		
		/**
		 * @public
		 *
		 * @return Number
		 *
		 */
		public function get lectureId():Number
		{
			return _lectureId;
		}
		
		/**
		 * @public
		 * @param value of type Number
		 * @return void
		 *
		 */
		public function set lectureId(value:Number):void
		{
			_lectureId=value;
		}
		
		/**
		 * @public
		 *
		 * @return String
		 *
		 */
		public function get moderatorName():String
		{
			return _moderatorName;
		}
		
		/**
		 * @public
		 * @param value of type String
		 * @return void
		 *
		 */
		public function set moderatorName(value:String):void
		{
			_moderatorName=value;
		}
		
		/**
		 * @public
		 * @param value of type String
		 * @return void
		 *
		 */
		public function set title(value:String):void
		{
			_title=value;
		}
		
		/**
		 * @public
		 *
		 * @return String
		 *
		 */
		public function get title():String
		{
			return _title;
		}
		
		/**
		 * @public
		 * @param value of type String
		 * @return void
		 *
		 */
		public function set meetingName(value:String):void
		{
			_meetingName=value;
		}
		
		/**
		 * @public
		 *
		 * @return String
		 *
		 */
		public function get meetingName():String
		{
			return _meetingName;
		}
		
		/**
		 * @public
		 * to clear the values.
		 *
		 * @return void
		 *
		 */
		public function clearInvitation():void
		{
			_title="";
			_userId=0;
			_meetingName="";
		}
		
		/**
		 * @public
		 *
		 * @return Number
		 *
		 */
		public function get userId():Number
		{
			return _userId;
		}
		
		/**
		 * @public
		 * @param value of type Number
		 * @return void
		 *
		 */
		public function set userId(value:Number):void
		{
			_userId=value;
		}
		
		/**
		 * @public
		 *
		 * @return String
		 *
		 */
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * @public
		 * @param value of type String
		 * @return void
		 *
		 */
		public function set userName(value:String):void
		{
			_userName=value;
		}
	}
}
