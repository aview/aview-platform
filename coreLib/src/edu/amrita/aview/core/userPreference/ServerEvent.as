package edu.amrita.aview.core.userPreference
{
	import flash.events.Event;

	public class ServerEvent extends Event
	{
		public static const HANDLER_CALLED:String="handlerInvoked";
		
		public function ServerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
	}
}