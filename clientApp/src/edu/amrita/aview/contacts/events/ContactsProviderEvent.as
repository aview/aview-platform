package edu.amrita.aview.contacts.events
{
	import flash.events.Event;
	
	public class ContactsProviderEvent extends Event
	{
		public static const REFRESH_CONTACTS:String="RefreshContacts";
		
		

		private var _callbackFunction:Function=null;
		
		public function ContactsProviderEvent(type:String, callbackFunction:Function=null,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_callbackFunction=callbackFunction;
		}
		public function get callbackFunction():Function
		{
			return _callbackFunction;
		}
	}
}