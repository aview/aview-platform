package edu.amrita.aview.core.entry.events
{
	import flash.events.Event;
	
	/**
	 * Event class used by the module notify when the module's window properties are changed.
	 * @author Ramesh
	 * 
	 */
	public class ModuleWindowEvent extends Event
	{
		/**
		 * Event used by the Module to notify the Core 
		 * when the user clicks a popped out module window to activate it.
		 */
		public static const TYPE_POPOUT_ACTIVATED:String="popoutActivated";
		
		/**
		 * Event used by the Module to notify the Core 
		 * when the popout gets closed/deactivated
		 */
		public static const TYPE_POPOUT_DEACTIVATED:String="popoutDeActivated";
		
		/**
		 * Event used by the Module to notify the Core 
		 * when the popout is put in full screen
		 */
		public static const TYPE_POPOUT_FULLSCREEN:String="popOutFullScreen";
		
		/**
		 * Event used by the Module to notify the Core 
		 * when the fullscreen is closed
		 */
		public static const TYPE_POPOUT_FULLSCREEN_CLOSED:String="popOutFullScreenClosed";
		
		private var _moduleName:String;

		/**
		 * Constructor
		 * 
		 * @param type: Event type, could be one of the TYPE_POPOUT_ACTIVATED, TYPE_POPOUT_DEACTIVATED,
		 * TYPE_POPOUT_FULLSCREEN, and TYPE_POPOUT_FULLSCREEN_CLOSED
		 * These events are thrown by the module and handled by core.
		 * 
		 * @param bubbles
		 * @param cancelable
		 * @param moduleName: Name of the module which is concerned with this window event
		 * 
		 */
		public function ModuleWindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,moduleName:String)
		{
			super(type, bubbles, cancelable);
			this.moduleName = moduleName;
		}

		/**
		 * 
		 * @return moduleName: Name of the module which is concerned with this focus event
		 * 
		 */
		public function get moduleName():String
		{
			return _moduleName;
		}

	}
}