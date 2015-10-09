package edu.amrita.aview.core.entry
{
	/**
	 * The PartcipantData contains the data of a session participant
	 * @author rameshg
	 * 
	 */
	public class PartcipantData
	{
		public function PartcipantData()
		{
		}
		
		protected var _userName:String;
		
		protected var _displayName:String;
		
		protected var _instituteName:String;
		
		protected var _role:String;
		
		protected var _interactionStatus:String;
		
		protected var _isModerator:Boolean;
		
		/**
		 * Unique userName of the currently logged in user
		 */
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * Display name of the currently logged in user, basically the First Name+Last Name
		 */
		public function get displayName():String
		{
			return _displayName;
		}
		
		/**
		 * Name of the Institute to which the current logged in User belongs
		 */
		public function get instituteName():String
		{
			return _instituteName;
		}

		/**
		 * The current role for this partcipant. Can be either Constants.PRESENTER_ROLE or Constants.VIEWER_ROLE. 
		 * This role may change during the course of the session.
		 */
		public function get role():String
		{
			return _role;
		}

		/**
		 * The current interaction status of the partcipant. It can be one among 
		 * Constants.ACCEPT, Constants.HOLD, Constants.WAITING, Constants.VIEW
		 */
		public function get interactionStatus():String
		{
			return _interactionStatus;
		}

		/**
		 * Indicates whether this participant is the moderator of the class or not.
		 */
		public function get isModerator():Boolean
		{
			return _isModerator;
		}

	}
}