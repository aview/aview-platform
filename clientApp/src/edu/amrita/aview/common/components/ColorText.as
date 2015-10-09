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
 * File			: ColorText.as
 * Module		: Common
 * Developer(s)	: Ravi Sankar 
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 */
//MMCR:-Function description 
//VGCR:-Class description
package edu.amrita.aview.common.components
{
	import mx.controls.Text;
	
	/**
	 *
	 * @public
	 * extends Text
	 */
	public class ColorText extends Text
	{
		public function ColorText()
		{
			super();
		}
		//VGCR:-variable description
		public var controlVaule:Number=0;
		public var defaultColor:uint=0;
		public var customColor:uint=0;
		
		/**
		 *
		 * @public
		 *
		 *
		 * @return void
		 */
		override public function invalidateDisplayList():void
		{
			// AKCR: the following can be simplified, for e.g
//AKCR:			setStyle("color",  (controlVaule == 1) ? customColor : defaultColor);
			if (controlVaule == 1)
			{
				setStyle("color", customColor);
			}
			else
			{
				setStyle("color", defaultColor);
			}
			super.invalidateDisplayList();
		}
	}
}
