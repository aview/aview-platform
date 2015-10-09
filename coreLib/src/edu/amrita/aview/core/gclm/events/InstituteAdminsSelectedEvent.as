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
 * File			: InstituteAdminsSelectedEvent.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This event is generated whenever the user is done with the Institute Adminstrators selection
 *
 */
package edu.amrita.aview.core.gclm.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * The event class
	 */
	public class InstituteAdminsSelectedEvent extends Event
	{
		/* The event type */
		public static var INSTITUTE_ADMINS_SELECTED:String="instituteadminsselected";
		
		/* To store the institute admin users that needs to be passed to the event handler */
		private var _data:ArrayCollection;
		
		/**
		 *
		 * @public
		 * Constructor for this classs
		 * 
		 * @param type : The event type
		 * @param bubbles : Boolean if the event has to be bubbled
		 * @param cancelable : Boolean if the event can be cancelled
		 * @param data : The selected institute admin user info
		 * @return NA
		 *
		 ***/
		public function InstituteAdminsSelectedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:ArrayCollection=null)
		{
			super(type, bubbles, cancelable);
			_data=data;
		}
		
		/**
		 *
		 * @public
		 * Overridden function from the base class
		 *
		 * @return Event
		 *
		 ***/
		override public function clone():Event
		{
			return new InstituteAdminsSelectedEvent(type, bubbles, cancelable, data);
		}
		
		/**
		 *
		 * @public
		 * Function to get the stored data by the event handler
		 *
		 * @return the data arraycollection
		 *
		 ***/
		public function get data():ArrayCollection
		{
			return _data;
		}
	}
}
