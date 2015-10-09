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
 * File			: AViewStringUtil.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.common.util
{
	import mx.utils.ObjectUtil;
	//VGCR:-Class Description
	//VGCR:-Function Description for all functions
	public class AViewStringUtil
	{
		/**
		 *@public 
		 * Constructor
		 */
		public function AViewStringUtil()
		{
		}
		
		// AKCR: Please add more description to this helper function
		/**
		 * @private 
		 * @param obj1 of type Object
		 * @param field of type String
		 * @return String
		 * 
		 */
		private static function getFieldValue(obj1:Object, field:String):String
		{
			var fieldArray:Array=field.split(".");
			var value:Object=obj1;
			for (var token:String in fieldArray)
			{
				value=value[fieldArray[token]];
			}
			return value as String;
		}
		
		/**
		 * @public 
		 * @param field of type String
		 * @return Function
		 * 
		 */
		public static function caselessSortForField(field:String):Function
		{
			return function(obj1:Object, obj2:Object):int
			{
				if (field.indexOf(".") != 0)
				{
					return ObjectUtil.stringCompare(getFieldValue(obj1, field), getFieldValue(obj2, field), true);
				}
				else
				{
					return ObjectUtil.stringCompare(obj1[field], obj2[field], true);
				}
			}
		}
	}
}
