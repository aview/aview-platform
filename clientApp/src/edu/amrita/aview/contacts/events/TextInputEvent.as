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
 * File		   : TextInputComponent.mxml
 * Module	   : contacts
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) : Bri.Radha
 *
 * This is used to pass the details of add or edit group and add meeting subject.
 *
 */
//VGCR:-Variable Description
//VGCR:-Function Description
package edu.amrita.aview.contacts.events
{
	import flash.events.Event;
	//PNCR: class description
	public class TextInputEvent extends Event
	{
		public static const VALUE_CHANGED:String = "valueChanged";
		//public static const CLOSED:String = "closed";
		
		private var _data:Object;
		
		/**
		 *
		 * @param type of type String
		 * //PNCR: description
		 * @param value of type Object
		 * @return null
		 */
		public function TextInputEvent(type:String, value:Object)
		{
			super(type, true);
			this._data=value;
		}
		
		/**
		 * @public
		 * //PNCR: description
		 * @return Object
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 * @public
		 * //PNCR: description
		 * @param value of type Object
		 * @return void
		 */
		public function set data(value:Object):void
		{
			_data=value;
		}
	}
}
