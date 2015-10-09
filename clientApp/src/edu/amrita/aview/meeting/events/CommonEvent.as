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
 * File			: CommonEvent.as
 * Module		: meeting
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	:
 *
 *
 */
package edu.amrita.aview.meeting.events
{
	import flash.events.Event;
	
	public class CommonEvent extends Event
	{
		
		public static const SELECTED:String="selected";
		public static const DELETE:String="delete";
		public static const EDIT:String="changed";
		public static const REFRESH:String="refresh";
		/**
		 * Variable to store the data as object 
		 */
		private var _data:Object;
		
		
		/**
		 * @public
		 * @param type of type String
		 * @param data of type Object
		 * @return null
		 *
		 */
		public function CommonEvent(type:String, data:Object)
		{
			super(type, false, false);
			this._data=data;
		}
		
		/**
		 * @public
		 *
		 * @return Object
		 *
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 * @public
		 * @param value of type Object
		 * @return void
		 *
		 */
		public function set data(value:Object):void
		{
			_data=value;
		}
	
	}
}
