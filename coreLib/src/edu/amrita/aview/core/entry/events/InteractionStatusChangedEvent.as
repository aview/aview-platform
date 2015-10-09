package edu.amrita.aview.core.entry.events
{
	import flash.events.Event;
	
	/**
	 * Event class to notify when the currently logged in user's interaction status is changed.
	 * @author rameshg
	 * 
	 */
	public class InteractionStatusChangedEvent extends Event
	{
		/**
		 * Event type used to notify when the currently logged in user's interaction status is changed.
		 */
		public static const TYPE_INTERACTION_STATUS_CHANGED:String="InteractionStatusChanged";

		private var _newInteractionStatus:String;

		/**
		 * Constructor 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param newInteractionStatus:String, the new interaction status of the logged in user.
		 * 
		 */
		public function InteractionStatusChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,newInteractionStatus:String)
		{
			super(type, bubbles, cancelable);
			this.newInteractionStatus = newInteractionStatus;
		}

		/**
		 * The current interaction status of the partcipant. It can be one among 
		 * Constants.ACCEPT, Constants.HOLD, Constants.WAITING, Constants.VIEW
		 */
		public function get newInteractionStatus():String
		{
			return _newInteractionStatus;
		}

	}
}