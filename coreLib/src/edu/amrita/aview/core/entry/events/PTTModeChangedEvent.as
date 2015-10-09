package edu.amrita.aview.core.entry.events
{
	import flash.events.Event;
	
	/**
	 * Event class to notify when the PushToTalk's mode is changed
	 * @author rameshg
	 * 
	 */
	public class PTTModeChangedEvent extends Event
	{
		/**
		 * Event type used for notifying when the PTT mode is changed
		 */
		public static const TYPE_PTT_MODE_CHANGE:String="PTTModeChangedEvent";
		
		private var _newPTTMode:String;

		/**
		 * Constructor
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param newPTTMode:String New Push To Talk mode. Can be one of the Constants.FREETALK or Constants.PTT
		 * 
		 */
		public function PTTModeChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, newPTTMode:String)
		{
			super(type, bubbles, cancelable);
			this._newPTTMode = newPTTMode;
		}

		/**
		 * New Push To Talk mode. Can be one of the Constants.FREETALK or Constants.PTT
		 */
		public function get newPTTMode():String
		{
			return _newPTTMode;
		}

	}
}