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
 * File			: onSeekPress.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * onSeekPress is a extended class of Event class.
 * This event will fire the user press the thumb on Seekbar
 */

package edu.amrita.aview.core.playback.player.MediaEvents
{
	import flash.events.Event;
	
	//RTCR: Give description 
	public class OnSeekPress extends Event
	{
		/**
		 *Constructor
		 *
		 */
		public function OnSeekPress()
		{
			super("OnSeekPress");
		}
		
		/**
		 * clone function
		 * @return  OnSeekPress class
		 *
		 */
		override public function clone():Event
		{
			return new OnSeekPress();
		}
	}
}
