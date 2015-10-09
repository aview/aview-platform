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
 * File			: onMediaControlerEvent.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * onMediaControlerEvent is a extended class of Event class.
 * This event will fire which operation have been made on Player controler
 */

package edu.amrita.aview.playback.player.MediaEvents
{
	import flash.events.Event;
	
	
	/**
	 * onMediaControlerEvent is a extended class of Event class.
     * This event will fire which operation have been made on Player controler 
	 * @author haridasanpc
	 * 
	 */
	public class onMediaControlerEvent extends Event
	{
		/**
		 * Indicate the operation on Player control
		 */
		public var _operation:String;
		
		/**
		 * Get the operation on Player control
		 * @return String
		 *
		 */
		public function get operation():String
		{
			return _operation;
		}
		
		/**
		 * Set the Operation on Player control
		 * @param opr of String
		 *
		 */
		public function onMediaControlerEvent(opr:String)
		{
			super("onMediaControlerEvent");
			_operation=opr;
		}
		
		/**
		 * clone function
		 * @return onMediaControlerEvent
		 *
		 */
		override public function clone():Event
		{
			return new onMediaControlerEvent(operation);
		}
	}
}
