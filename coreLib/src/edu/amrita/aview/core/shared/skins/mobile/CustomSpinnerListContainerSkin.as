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
 * File			: CustomSpinnerListContainerSkin.as
 * Module		: Common
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Pradeesh 
 * 
 * CustomSpinnerListContainerSkin skin component is used to set skin classes and properties for application based on the device DPI.
 */
package edu.amrita.aview.core.shared.skins.mobile
{
	import spark.skins.mobile.SpinnerListContainerSkin;
	import mx.core.DPIClassification;
	
	import spark.skins.mobile.supportClasses.MobileSkin;
	import spark.skins.mobile160.assets.SpinnerListContainerBackground;
	import spark.skins.mobile160.assets.SpinnerListContainerSelectionIndicator;
	import spark.skins.mobile160.assets.SpinnerListContainerShadow;
	import spark.skins.mobile240.assets.SpinnerListContainerBackground;
	import spark.skins.mobile240.assets.SpinnerListContainerSelectionIndicator;
	import spark.skins.mobile240.assets.SpinnerListContainerShadow;
	import spark.skins.mobile320.assets.SpinnerListContainerBackground;
	import spark.skins.mobile320.assets.SpinnerListContainerSelectionIndicator;
	import spark.skins.mobile320.assets.SpinnerListContainerShadow;
	
	/**
	 * CustomSpinnerListContainerSkin class for assigning skins for borderClass,selectionIndicatorClass and shadowClass.
	 */
	public class CustomSpinnerListContainerSkin extends SpinnerListContainerSkin
	{
		/**
		 * @public
		 *
		 * Constructor
		 * 
		 * Set skins and values for cornerRadius, borderThickness and selectionIndicatorHeight, based on the system DPI.
		 *
		 */
		public function CustomSpinnerListContainerSkin()
		{
			super();
			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					borderClass = spark.skins.mobile320.assets.SpinnerListContainerBackground;
					selectionIndicatorClass = spark.skins.mobile320.assets.SpinnerListContainerSelectionIndicator;
					shadowClass = spark.skins.mobile320.assets.SpinnerListContainerShadow;
					
					cornerRadius = 10;
					borderThickness = 0.5;
					selectionIndicatorHeight = 55; // was 120
					break;
				}
				case DPIClassification.DPI_240:
				{
					borderClass = spark.skins.mobile240.assets.SpinnerListContainerBackground;
					selectionIndicatorClass = spark.skins.mobile240.assets.SpinnerListContainerSelectionIndicator;
					shadowClass = spark.skins.mobile240.assets.SpinnerListContainerShadow;
					
					cornerRadius = 8;
					borderThickness = 0.5;
					selectionIndicatorHeight = 40; // was 90
					break;
				}
				default: // default DPI_160
				{
					borderClass = spark.skins.mobile160.assets.SpinnerListContainerBackground;
					selectionIndicatorClass = spark.skins.mobile160.assets.SpinnerListContainerSelectionIndicator;
					shadowClass = spark.skins.mobile160.assets.SpinnerListContainerShadow;
					
					cornerRadius = 3;
					borderThickness = 0.5;
					selectionIndicatorHeight = 45; // was 60
					alpha = 0.9;
					
					break;
				}
			}
		}
	}
}