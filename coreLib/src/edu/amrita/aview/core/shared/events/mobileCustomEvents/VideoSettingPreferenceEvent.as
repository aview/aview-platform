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
 * File			: VideoSettingPreferenceEvent.as
 * Module		: Video
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK 
 *
 * VideoSettingPreferenceEvent is a custom event class for adding/removing video module 
 * 
 */
package edu.amrita.aview.core.shared.events.mobileCustomEvents
{
	/**
	 * Importing flash library
	 */
	import flash.events.Event;

	/**
	 * VideoSettingPreferenceEvent class contains custom events to enable and disable video module at run time.
	 */
	public class VideoSettingPreferenceEvent extends Event
	{
		/**
		 * Static constants for video functionalities
		 */
		public static var VIDEO_SETTING_ON:String = "video_setting_on";
		public static var VIDEO_SETTING_OFF:String = "video_setting_off";
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
		public function VideoSettingPreferenceEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.data = data;
			super(type,bubbles,cancelable);
		}
	}
}