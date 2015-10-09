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
 * File			: ColorCells.as
 * Module		: Common
 * Developer(s)	: Ravi Sankar 
 * Reviewer(s)	:Monisha Mohanan,Veena Gopal K.V

 */


package edu.amrita.aview.common.components
{
	import mx.controls.Text;
	
	/**
	 *
	 * @public
	 * extends Text
	 */
	public class ColorCells extends Text
	{
		/**
		 *
		 * @public
		 * constructor
		 *
		 */
		public function ColorCells()
		{
			super();
		}
		//VGCR:- Description For variables
		public var controlField:String="";
		public var controlVaule:String="";
		public var skippedValue:String="";
		public var defaultColor:uint=0;
		public var customColor:uint=0;
		public var skippedColor:uint=0;
		
		/**
		 *
		 * @public
		 * for assigning the data
		 * @param value of type Object
		 * @return void
		 *
		 */
		override public function set data(value:Object):void
		{
			if (value != null)
			{

				super.data=value;
				if (value[controlField] == controlVaule)
				{
					setStyle("color", customColor);
				}
				else if (value[controlField] == skippedValue)
				{
					setStyle("color", skippedColor);
				}
				else
				{
					setStyle("color", defaultColor);
				}
			}
		}
	}
}
