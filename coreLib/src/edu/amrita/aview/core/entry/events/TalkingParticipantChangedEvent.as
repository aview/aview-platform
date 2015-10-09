package edu.amrita.aview.core.entry.events
{
	import edu.amrita.aview.core.entry.PartcipantData;
	
	import flash.events.Event;
	
	/**
	 * Event class used to notify when the Talking participant is changed.
	 * This even is applicable only in PushToTalk mode. This event is not applicable during FreeTalk mode (default mode)
	 * @author rameshg
	 * 
	 */
	public class TalkingParticipantChangedEvent extends Event
	{
		/**
		 * Event type used for notifying when the talking participant is changed.
		 */
		public static const TYPE_PTT_MODE_CHANGE:String="PTTModeChangedEvent";
		
		private var _talkingParticipant:PartcipantData

		/**
		 * Constructor
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param talkingParticipant:PartcipantData Currently talking participant's PartcipantData object
		 * 
		 */
		public function TalkingParticipantChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, talkingParticipant:PartcipantData)
		{
			super(type, bubbles, cancelable);
			this._talkingParticipant = talkingParticipant;
		}

		/**
		 * Currently talking participant's PartcipantData object
		 */
		public function get talkingParticipant():PartcipantData
		{
			return _talkingParticipant;
		}

	}
}