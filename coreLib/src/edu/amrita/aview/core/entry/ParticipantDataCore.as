package edu.amrita.aview.core.entry
{
	/**
	 * Updatable class of the ParticipantData class
	 * @author rameshg
	 * 
	 */
	public class ParticipantDataCore extends PartcipantData
	{
		public function ParticipantDataCore()
		{
			super();
		}
		
		public function set userName(value:String):void
		{
			_userName = value;
		}
		
		public function set displayName(value:String):void
		{
			_displayName = value;
		}
		
		public function set instituteName(value:String):void
		{
			_instituteName = value;
		}
		
		public function set role(value:String):void
		{
			_role = value;
		}
		
		public function set interactionStatus(value:String):void
		{
			_interactionStatus = value;
		}
		
		public function set isModerator(value:Boolean):void
		{
			_isModerator = value;
		}
	}
}