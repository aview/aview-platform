package edu.amrita.aview.questions.events
{
	import edu.amrita.aview.questions.BreakDetails;
	
	import flash.events.Event;
	
	public class BreakSessionEvent extends Event
	{
		/**
		 * Event type used to notify that break session has started
		 */
		public static const BREAK_SESSION_STARTED_TYPE:String="BREAK_SESSION_STARTED_TYPE";
		/**
		 * Event type used to notify that break session has ended
		 */
		public static const BREAK_SESSION_ENDED_TYPE:String="BREAK_SESSION_ENDED_TYPE";
		/**
		 * Event used to notify to cancel the break session
		 */
		public static const CANCEL_BREAK_SESSION:String="CANCEL_BREAK_SESSION";
		
		private var _breakDetails:BreakDetails = null;		
		/**
		 * Constructor. 
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function BreakSessionEvent(type:String,breakDetails:BreakDetails=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.breakDetails = breakDetails;
		}

		public function get breakDetails():BreakDetails
		{
			return _breakDetails;
		}

		public function set breakDetails(value:BreakDetails):void
		{
			_breakDetails = value;
		}

	}
}