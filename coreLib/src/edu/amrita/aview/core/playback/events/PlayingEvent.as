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
 * File			: PlayingEvent.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * PlayingEvent is a extended class of Event class.
 * This class may contain information about playing status of session
 *
 */
package edu.amrita.aview.core.playback.events{
	import flash.events.Event;
	/**
		* PlayingEvent is a extended class of Event class.
		* This class may contain information about playing status of session
		*/
	public class PlayingEvent extends Event{
		/**
		 * Constructor
		 * @param type of type String
		 * @param bubbles of type Boolean
		 * @param cancelable of type Boolean
		 *
		 */
		public function PlayingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}
