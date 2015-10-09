package edu.amrita.aview.meeting.events
{
	import edu.amrita.aview.meeting.InvitationModel;
	
	import flash.events.Event;
	applicationType::desktop{
		import flash.text.ReturnKeyLabel;
	}

	public class InvitationEvent extends Event
	{
		public static const ACCEPT:String="AcceptInvitation";
		public static const REJECT:String="RejectInvitation";
		public static const CLOSE_INVITATION:String="CloseInvitation";
		private var _data:InvitationModel=null
		public function InvitationEvent(type:String,invitation:InvitationModel=null,bubbles:Boolean=false,cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
			this._data=invitation;
		}
		public function get data():InvitationModel
		{
			return this._data;
		}
			
	}
}