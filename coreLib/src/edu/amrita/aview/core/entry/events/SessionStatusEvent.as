package edu.amrita.aview.core.entry.events
{
	import edu.amrita.aview.core.entry.SessionData;
	
	import flash.events.Event;
	
	/**
	 * 
	 * @author Ramesh
	 * Event class used to communicate Session life cycle events such as Session entry and Session exit
	 * 
	 */
	public class SessionStatusEvent extends Event
	{
		/**
		 * Event type, used to notify the entry into a session 
		 */
		public static const TYPE_SESSION_ENTRY:String="sessionEntry";
		/**
		 * Event type, used to notify the exit from a session
		 */
		public static const TYPE_SESSION_EXIT:String="sessionExit";
		
		private var _sessionRO:SessionData;

		/**
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param sessionRO: SessionRO object which contains the details of the session and user's latest role etc
		 * 
		 */
		public function SessionStatusEvent(type:String,sessionRO:SessionData, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._sessionRO = sessionRO;
		}

		/**
		 * SessionRO object which contains the details of the session and user's latest role etc
		 * @returns SessionRO
		 * 
		 */
		public function get sessionRO():SessionData
		{
			return _sessionRO;
		}

	}
}