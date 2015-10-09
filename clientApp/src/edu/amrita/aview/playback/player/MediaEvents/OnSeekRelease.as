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
 * File			: onSeekRelease.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * onSeekRelease is a extended class of Event class.
 * This event will fire the user release the thumb on Seekbar
 */

package edu.amrita.aview.playback.player.MediaEvents
{
	import flash.events.Event;
	
	//RTCR: Give description 
	public class OnSeekRelease extends Event
	{
		
		/**
		 * Value of seek bar after release the thumb on seekbar
		 */
		public var _currentSeekPos:Number;
		
		/**
		 * Get the value of seekbar after release
		 * @return  Number
		 *
		 */
		public function get currentSeekPos():Number
		{
			return _currentSeekPos;
		}
		
		/**
		 * Constructor
		 * @param value of Number
		 *
		 */
		public function OnSeekRelease(value:Number)
		{
			super("OnSeekRelease");
			_currentSeekPos=value;
		}
		
		/**
		 * clone function
		 * @return OnSeekRelease Class
		 *
		 */
		override public function clone():Event
		{
			return new OnSeekRelease(currentSeekPos);
		}
	}
}
