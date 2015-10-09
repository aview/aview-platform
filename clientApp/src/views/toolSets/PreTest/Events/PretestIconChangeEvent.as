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
 * File			: PretestIconChangeEvent.as
 * Module		: Pretest
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 *
 * PretestIconChangeEvent is a custom event class for changing pretest result icon.
 * 
 */
package views.toolSets.PreTest.Events
{
	/**
	 * Importing flash library
	 */
	import flash.events.Event;

	/**
	 * PretestIconChangeEvent class contains custom events for setting pretest result icon.
	 */
	public class PretestIconChangeEvent extends Event
	{
		/**
		 * Static constants for pretesting result
		 */ 
		public static var PRETEST_PASS:String = "passed";
		public static var PRETEST_FAIL:String = "failed";
		public static var PRETEST_PARTIAL:String = "partial";
		/**
		 * To holds current object
		 */
		public var data:Object;
		
		/**
		 * @public
		 *
		 * Constructor to set type of event and target object
		 *
		 * @param type holds type of the event
		 * @param data holds target object instance
		 * @param bubbles optional boolean value
		 * @param cancelable optional boolean value
		 * @return void
		 */
		public function PretestIconChangeEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.data = data;
			super(type,bubbles,cancelable);
		}
	}
}