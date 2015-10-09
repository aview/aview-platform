////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
//RTCR: Mention the use of this component
/**
 *
 * File			: PlayCompletedEvent.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * PlayCompletedEvent is a extended class of Event class.
 *
 */

package edu.amrita.aview.core.playback.events{
	import flash.events.Event;
	/**
	 * PlayCompletedEvent is a extended class of Event class.
	 * User can dispatch PlayCompletedEvent after the playback will finish
	 * @author haridasanpc
	 * 
	 */	
	public class PlayCompletedEvent extends Event{
		
		/**
		 * Constructor
		 * @param type of type String
		 * @param bubbles of type Boolean
		 * @param cancelable of type Boolean
		 *
		 */
		public function PlayCompletedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}
