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
 * File			: LoginTypeSkin.as
 * Module		: Login
 * Developer(s)	: Meena S
 * Reviewer(s)	: Pradeesh 
 * 
 * LoginTypeSkin skin component is used to set selected and unselected state label for toggle switch.
 */
package edu.amrita.aview.common.skins.mobile
{
	/**
	 * Importing spark library
	 */
	import spark.components.ToggleSwitch;
	import spark.skins.mobile.ToggleSwitchSkin;

	/**
	 * LoginTypeSkin class for assigning value for selected/Unselected property
	 */
	public class LoginTypeSkin extends ToggleSwitchSkin
	{
		/**
		 * @public
		 *
		 * Constructor
		 * Set selected/Unselected label value
		 * Set thumb button properties
		 * 
		 */
		public function LoginTypeSkin()
		{
			super();
			selectedLabel = "Password";
			unselectedLabel = "Face Recognition";
			//To set thumb width and height.
			layoutBorderSize = 2;
			layoutThumbWidth = 80;
			layoutThumbHeight = 35;
			layoutInnerPadding = 14;
			layoutOuterPadding = 22;
		}
	}
}