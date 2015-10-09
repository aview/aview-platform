package edu.amrita.aview.meeting
{
	[Bindable]
	public class InvitationModel
	{
		public var userId:Number=0;
		public var lectureId:Number = 0;
		public var classRegistrationId:Number=0;
		public var meetingName:String="";
		public var moderatorName:String="";
		public var userName:String="";
	
		public function InvitationModel()
		{
		}
	}
}