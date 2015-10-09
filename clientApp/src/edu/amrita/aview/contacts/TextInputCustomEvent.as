////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 *
 * File		   : TextInputCustomEvent.as
 * Module	   : contacts
 * Developer(s): Bri.Radha
 * Reviewer(s) : Veena Gopal K.V
 */
package edu.amrita.aview.contacts
{
	import flash.events.Event;
	
	/**
	 * 
	 * @public
	 * extends Event
	 * //PNCR: class description
	 */
	public class TextInputCustomEvent extends Event
	{
		private var _value:Object;
		
		/**
		 * @public
		 * Constructor
		 * @param type of type String
		 * @param value of type Object
		 */
		public function TextInputCustomEvent(type:String, value:Object)
		{
			super(type, false, false);
			this._value=value;
		}
		
		/**
		 * @public
		 * get function for data
		 * @return Object
		 *
		 */
		public function get data():Object
		{
			return _value;
		}
		
		/**
		 * @public
		 * set function for data
		 * @param value of type Object
		 * @return void
		 */
		public function set data(value:Object):void
		{
			_value=value;
		}
	
	}
}
