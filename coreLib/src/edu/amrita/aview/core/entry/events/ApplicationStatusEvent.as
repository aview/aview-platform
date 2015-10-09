package edu.amrita.aview.core.entry.events
{
	import flash.events.Event;
	
	/**
	 * 
	 * @author Jayahari
	 * Event class used to for Application status notification such as Login/Logout etc 
	 */
	public class ApplicationStatusEvent extends Event
	{
		/**
		 * Event type used when the Application is closing, so that appropriate resource cleanup can be done
		 */
		public static const TYPE_APPLICATION_CLOSE:String="applicationClose";
		/**
		 * Event type used when a user logs out, so that appropriate resource cleanup can be done
		 */
		public static const TYPE_APPLICATION_LOGOUT:String="applicationLogout";
		
		/**
		 * Constructor. 
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function ApplicationStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
