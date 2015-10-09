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
 * File			: CustomLabel.as
 * Module		: Common
 * Developer(s)	: Ravi Sankar 
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 *
 */
//MMCR:-Function description 

package edu.amrita.aview.common.components
{
	import mx.controls.Label;
	
	/**
	 * @public
	 * extends Label
	 */
	public class CustomLabel extends Label
	{
		/**
		 * @public
		 *
		 * @param data type of Object
		 * @return void
		 */
		override public function set data(data:Object):void
		{
			super.data=data.vote;
			// AKCR: please use the conditional operator here
			if (data.questionStatus == "ANSWERED")
			{
				setStyle("color", 0x008E00);
			}
			else
			{
				setStyle("color", 0x000000);
			}
		}
	}
}
