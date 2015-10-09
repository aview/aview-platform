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
 * File			: onSeekChange.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * onSeekChange is a extended class of Event class.
 * This event will fire on seekbar value changing
 */

package edu.amrita.aview.core.playback.player.MediaEvents
{
	import flash.events.Event;
	/**
	* onSeekChange is a extended class of Event class.
	* This event will fire on seekbar value changing
	*/
	public class OnSeekChange extends Event
	{
		/**
		 *Constructor
		 *
		 */
		public function OnSeekChange()
		{
			super("OnSeekChange");
		}
		
		/**
		 * clone function
		 * @return  OnSeekChange class
		 *
		 */
		override public function clone():Event
		{
			return new OnSeekChange();
		}
	}
}
