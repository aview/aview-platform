package edu.amrita.aview.contacts.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	public class UserStatusProviderEvent extends Event
	{
		public static const USER_STATUS_CHANGE:String="userStatusChange";

		private var _userStatusReceiver:Function
		public function UserStatusProviderEvent(type:String,statusReceiver:Function,bubbles:Boolean=false,cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
			this._userStatusReceiver=statusReceiver;
		}
		public function get userStatusReceiver():Function
		{
			return _userStatusReceiver;
		}
		
		
	}
}