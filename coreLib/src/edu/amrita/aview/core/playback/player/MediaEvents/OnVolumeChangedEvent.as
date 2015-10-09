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
 * File			: OnVolumeChangedEvent.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * OnVolumeChangedEvent is a extended class of Event class.
 * This event will fire the user change the value of volume control bar
 */
package edu.amrita.aview.core.playback.player.MediaEvents
{
	import flash.events.Event;
	
	public class OnVolumeChangedEvent extends Event
	{
		/**
		 * Value of volume control bar after changing the volume control
		 */
		private var _currentVolume:Number;
		
		/**
		 * Get the value of volume control
		 * @return
		 *
		 */
		public function get currentVolume():Number
		{
			return _currentVolume;
		}
		
		/**
		 * Constructor
		 * @param value of type Number
		 *
		 */
		public function OnVolumeChangedEvent(value:Number)
		{
			super("OnVolumeChangedEvent");
			_currentVolume=value;
		}
		
		/**
		 * Clone function
		 * @return  OnVolumeChangedEvent class
		 *
		 */
		override public function clone():Event
		{
			return new OnVolumeChangedEvent(currentVolume);
		}
	}
}
