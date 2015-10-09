package edu.amrita.aview.contacts.events
{
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import flash.events.Event;
	
	public class ContactsTransferEvent extends Event
	{
		public static const SELECT_GROUP:String="selectgroup";
		public static const SEND_GROUP:String="sendgroup";
		public static const ACCEPT_GROUP:String="acceptgroup";
		public static const REJECT_GROUP:String="rejectgroup";
		public static const REFRESH_SHARED_GROUPS:String="refreshsharedgroups";
		private var _selectedGroup:GroupVO=null;
		public function ContactsTransferEvent(type:String,selectedGroup:GroupVO=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_selectedGroup=selectedGroup;
		}

		public function get selectedGroup():GroupVO
		{
			return _selectedGroup;
		}

	}
}