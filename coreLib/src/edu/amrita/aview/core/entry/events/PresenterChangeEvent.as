package edu.amrita.aview.core.entry.events
{
	import edu.amrita.aview.core.entry.PartcipantData;
	
	import flash.events.Event;
	
	/**
	 * Event class used to notify all the module when the the presenter for the session is changed.
	 * @author rameshg
	 * 
	 */
	public class PresenterChangeEvent extends Event
	{
		/**
		 * Event to notify all the modules when the presenter is changed
		 */
		public static const TYPE_PRESENTER_CHANGE:String="presenterChange";
		
		private var _newPresenter:PartcipantData

		/**
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param newPresenter:PartcipantData: The deails of the new presenter user
		 */
		public function PresenterChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,newPresenter:PartcipantData)
		{
			super(type, bubbles, cancelable);
			this._newPresenter = newPresenter;
		}

		/**
		 * @return newPresenter:PartcipantData: The deails of the new presenter user
		 */
		public function get newPresenter():PartcipantData
		{
			return _newPresenter;
		}

	}
}