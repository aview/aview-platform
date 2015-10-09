package edu.amrita.aview.core.entry
{
	import mx.collections.ArrayList;

	/**
	 * Updatable class of the SessionData class
	 * Also contains some additional core attributes
	 * @author rameshg
	 * 
	 */
	public class SessionDataCore extends SessionData
	{
		public function SessionDataCore()
		{
			super();
		}
		public function set interactingPartcipants(value:ArrayList):void
		{
			_interactingPartcipants = value;
		}

		public function set viewedPartcipants(value:ArrayList):void
		{
			_viewedPartcipants = value;
		}

		public function set role(value:String):void
		{
			_role = value;
		}
		
		public function set interactionStatus(value:String):void
		{
			_interactionStatus = value;
		}
		
		public function set courseInstituteName(value:String):void
		{
			_courseInstituteName = value;
		}
		
		public function set courseName(value:String):void
		{
			_courseName = value;
		}
		
		public function set className(value:String):void
		{
			_className = value;
		}
		
		public function set lectureName(value:String):void
		{
			_lectureName = value;
		}
		
		public function set moderator(value:PartcipantData):void
		{
			_moderator = value;
		}
		
		public function set presenter(value:PartcipantData):void
		{
			_presenter = value;
		}

		/**
		 * @private
		 */
		public function set pttMode(value:String):void
		{
			_pttMode = value;
		}

		/**
		 * @private
		 */
		public function set talkingParticipant(value:PartcipantData):void
		{
			_talkingParticipant = value;
		}

		
	}
}