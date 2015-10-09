package edu.amrita.aview.core.entry.events
{
	import edu.amrita.aview.core.entry.PartcipantData;
	
	import flash.events.Event;
	
	/**
	 * Event class to notify when any participant's interaction is either started or ended 
	 * @author rameshg
	 * 
	 */
	public class ParticipantInteractionEvent extends Event
	{
		/**
		 * Event type used to notify when the participant's interaction started.
		 */
		public static const TYPE_PARTCIPANT_INERACTION_STARTED:String="InteractionStarted";
		
		/**
		 * Event type used to notify when the participant's interaction ended.
		 */
		public static const TYPE_PARTCIPANT_INERACTION_ENDED:String="InteractionEnded";
		
		private var _participant:PartcipantData;

		/**
		 * Constructor 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param participant:PartcipantData The participant who's interaction is either started or ended.
		 * 
		 */
		public function ParticipantInteractionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,participant:PartcipantData)
		{
			super(type, bubbles, cancelable);
			this._participant = participant;
		}

		/**
		 * The participant who's interaction is either started or ended.
		 * @return  PartcipantData
		 * 
		 */
		public function get participant():PartcipantData
		{
			return _participant;
		}

	}
}