/**
 * This component has taken from the following link
 * http://www.adobe.com/cfusion/exchange/index.cfm?event=extensionDetail&extid=1800523
 *
 */

/**
 *
 * File			: RatingEvent.as
 * Module		: common
 * Developer(s)	: Vijayakumar
 * Reviewer(s)	: Remya T,Vishnupreethi K
 */


package edu.amrita.aview.core.shared.components.starRating.events
{
	import edu.amrita.aview.core.shared.components.starRating.StarRating;
	
	import flash.events.Event;
	
	/**
	 * VPCR: Add class description */
	
		public class RatingEvent extends Event
	{
		/** 
		 * VPCR: Add variable description */
		
		private var _rate:StarRating;
		
		public static const RATE_CHANGE:String="rateChange";
		/**
		 * @public
		 * constructor
		 * @param type of Type String
		 * @param rateObj of Type StarRating
		 * @param bubbles of Type Boolean Default value False
		 * @param cancelable of Type Boolean Default value False
		 */
		public function RatingEvent(type:String, rateObj:StarRating, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._rate=rateObj;
		}
		
		/**
		 * @public
		 * @return Event
		 */
		override public function clone():Event
		{
			return new RatingEvent(RATE_CHANGE, _rate);
		}
		
		/**
		 * @public
		 * @return StarRating
		 */
		public function get rateObject():StarRating
		{
			return this._rate;
		}
	}
}
