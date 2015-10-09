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
 * File			: WhiteBoardActionEvent.as
 * Module		: Whiteboard
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK 
 *
 * WhiteBoardActionEvent is a custom event class for implementing whiteboard functionalities 
 * 
 */
package edu.amrita.aview.core.shared.events.mobileCustomEvents
{
	/**
	 * Importing flash library
	 */
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * WhiteBoardActionEvent class contains custom events for implementing whiteboard functionalities 
	 */
	public class WhiteBoardActionEvent extends MouseEvent
	{
		/**
		 * Static constants for whiteboard functionalities
		 */
		public static var WHITE_BOARD_ACTION : String = "whiteBoardAction";
		public static var WB_THICKNESS_CHANGE : String = "thicknessChange";
		
		/**
		 * To holds current object
		 */
		public var data:Object;
		
		/**
		 * @public
		 * 
		 * Constructor
		 * To set type and object
		 * 
		 * @param type holds type of the event
		 * @param data holds target object instance
		 * @param bubbles optional boolean value
		 * @param cancelable optional boolean value
		 */
		public function WhiteBoardActionEvent(type:String, data:Object, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		/**
		 * @public
		 * 
		 * To clone the WhiteBoardActionEvent event
		 * 
		 * @return Event as WhiteBoardActionEvent
		 */
		override public function clone():Event
		{
			return new WhiteBoardActionEvent(type, data, bubbles, cancelable);
		}
	}
}