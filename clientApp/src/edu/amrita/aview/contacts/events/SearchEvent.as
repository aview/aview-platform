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
 * File			: SearchEvent.as
 * Module		: contacts
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-Constant Description
//VGCR:-Variable Description
package edu.amrita.aview.contacts.events
{
	import flash.events.Event;
	
	/**
	 * //PNCR: class description
	 */
	public class SearchEvent extends Event
	{
		public static const SEARCH_EVENT:String = "searchEvent";
		public static const USERS_SELECTED:String = "usersSelected";
		
		private var _data:Object = null;
		
		/**
		 * @public 
		 * //PNCR: description
		 * @param type of type String
		 * @param data of type Object
		 * 
		 */
		public function SearchEvent(type:String, data:Object=null)
		{
			super(type);
			this._data = data;
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
	}
}