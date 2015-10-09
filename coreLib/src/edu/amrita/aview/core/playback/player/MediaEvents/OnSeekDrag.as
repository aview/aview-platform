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
 * File			: onSeekDrag.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * onSeekDrag is a extended class of Event class.
 * This event will fire the user draging the thumb on Seekbar
 */

package edu.amrita.aview.core.playback.player.MediaEvents
{
	import flash.events.Event;
	
	//RTCR: Give description 
	public class OnSeekDrag extends Event
	{
		/**
		 *Constructor
		 *
		 */
		public function OnSeekDrag()
		{
			super("OnSeekDrag");
		}
		
		/**
		 * clone function
		 * @return  OnSeekDrag class
		 *
		 */
		override public function clone():Event
		{
			return new OnSeekDrag();
		}
	}
}
