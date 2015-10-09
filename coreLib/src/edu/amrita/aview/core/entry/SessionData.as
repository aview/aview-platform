package edu.amrita.aview.core.entry
{
	import mx.collections.ArrayList;

	/**
	 * The class contains the essential details of the currently logged in user
	 * @author rameshg
	 * 
	 */
	public class SessionData
	{
		public function SessionData()
		{
		}
		
		protected var _role:String;
		
		protected var _interactionStatus:String;
		
		protected var _courseInstituteName:String;
		
		protected var _courseName:String;
		
		protected var _className:String;
		
		protected var _lectureName:String;
		
		protected var _moderator:PartcipantData;
		
		protected var _presenter:PartcipantData;
		
		protected var _interactingPartcipants:ArrayList;
		
		protected var _viewedPartcipants:ArrayList;
		
		protected var _pttMode:String;
		
		protected var _talkingParticipant:PartcipantData;
		
		
		/**
		 * Contains the list of PartcipantData objects which are in the Constants.ACCEPT interaction status
		 * These users audio/video is broadcasted to all the session participants
		 */
		public function get interactingPartcipants():ArrayList
		{
			return _interactingPartcipants;
		}
		
		/**
		 * Contains the list of PartcipantData objects which are in the Constants.VIEW interaction status
		 * These users video is viewed by both the Presenter and Moderator
		 */
		public function get viewedPartcipants():ArrayList
		{
			return _viewedPartcipants;
		}
		
		/**
		 * Push To Talk mode. Can be one of the Constants.FREETALK or Constants.PTT 
		 */
		public function get pttMode():String
		{
			return _pttMode;
		}
		
		/**
		 * Currently talking participant's PartcipantData object. Applicable only when the pttMode is in Constants.PTT
		 */
		public function get talkingParticipant():PartcipantData
		{
			return _talkingParticipant;
		}
		

		/**
		 * The current role for the logged in user. Can be either Constants.PRESENTER_ROLE or Constants.VIEWER_ROLE. 
		 * This role may change during the course of the session.
		 */
		public function get role():String
		{
			return _role;
		}

		/**
		 * Name of Institute which is offering/created the course
		 */
		public function get courseInstituteName():String
		{
			return _courseInstituteName;
		}

		/**
		 * Name of the Course (Used only for Classes, not for Meetings)
		 */
		public function get courseName():String
		{
			return _courseName;
		}

		/**
		 * Name of the Classroom or Meetingroom
		 */
		public function get className():String
		{
			return _className;
		}

		/**
		 * Name of the lecture/session
		 */
		public function get lectureName():String
		{
			return _lectureName;
		}

		/**
		 * The current interaction status of the logged in user. It can be one among 
		 * Constants.ACCEPT, Constants.HOLD, Constants.WAITING, Constants.VIEW
		 */
		public function get interactionStatus():String
		{
			return _interactionStatus;
		}

		/**
		 * The moderator of the Classroom or Meetingroom
		 */
		public function get moderator():PartcipantData
		{
			return _moderator;
		}

		/**
		 * The current presentor of the class or meeting
		 */
		public function get presenter():PartcipantData
		{
			return _presenter;
		}

	}
}