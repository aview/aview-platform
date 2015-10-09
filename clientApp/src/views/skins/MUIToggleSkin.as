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
 * File			: MUIToggleSkin.as
 * Module		: Video
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Pradeesh 
 * 
 * MUIToggleSkin skin component is used to set selected/unselected state label for toggle switch.
 */
package views.skins
{
	/**
	 * Importing toggle switch skin class
	 */
	import spark.skins.mobile.ToggleSwitchSkin;

	/**
	 * MUIToggleSkin class for assigning value for selected/Unselected property
	 */
	public class MUIToggleSkin extends ToggleSwitchSkin
	{
		/**
		 * @public
		 *
		 * Constructor
		 * Set selected/Unselected label value
		 * 
		 */
		public function MUIToggleSkin()
		{
			super();
			selectedLabel = "MUI On";
			unselectedLabel = "MUI Off";
		}
	}
}