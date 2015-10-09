package edu.amrita.aview.contacts.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class UserStatusRequesterEvent extends Event
	{
		public static const UPDATE_USER_STATUS:String="UPDATE_USER_STATUS";
		
		
		
		private var _userVOs:ArrayCollection=null;
		
		public function get userVOs():ArrayCollection
		{
			return _userVOs;
		}
		public function UserStatusRequesterEvent(type:String, userVOs:ArrayCollection=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_userVOs=userVOs;
		}
	}
}