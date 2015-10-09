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
 * File			: AudioSettingSkin.as
 * Module		: Video
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	:  
 * 
 * AudioSettingSkin skin component is used to select camera for publishing video.
 */
package views.skins
{
	/**
	 * Importing toggle switch skin class
	 */
	import spark.skins.mobile.ToggleSwitchSkin;

	/**
	 * AudioSettingSkin class for assigning value for selected/Unselected property
	 */
	public class AudioSettingSkin extends ToggleSwitchSkin
	{
		/**
		 * @public
		 *
		 * Constructor
		 * Set selected/Unselected label value
		 * 
		 */
		public function AudioSettingSkin()
		{
			super();
			unselectedLabel = "Back";
			selectedLabel = "Front";
		}
	}
}