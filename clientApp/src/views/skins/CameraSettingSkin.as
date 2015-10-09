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
 * File			: CameraSettingSkin.as
 * Module		: Video
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	:  
 * 
 * CameraSettingSkin skin component is used to select camera for publishing video.
 */
package views.skins
{
	/**
	 * Importing toggle switch skin class
	 */
	import spark.skins.mobile.ToggleSwitchSkin;

	/**
	 * CameraSettingSkin class for assigning value for selected/Unselected property
	 */
	public class CameraSettingSkin extends ToggleSwitchSkin
	{
		/**
		 * @public
		 *
		 * Constructor
		 * Set selected/Unselected label value
		 * 
		 */
		public function CameraSettingSkin()
		{
			super();
			unselectedLabel = "Secondary";
			selectedLabel = "Primary";
		}
	}
}