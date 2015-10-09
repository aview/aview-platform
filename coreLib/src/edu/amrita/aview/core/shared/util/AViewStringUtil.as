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
package edu.amrita.aview.core.shared.util
{
	import mx.utils.ObjectUtil;
	
	import spark.components.gridClasses.GridColumn;

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
			// Fix for Bug #14855,#14837,#14854,#14836,#14853,#14832,#14851,#14830 start
			return function(obj1:Object, obj2:Object,gc:GridColumn = null):int
			{			
				var dataFieldToCompare : String = null;
				if(gc == null)
				{
					dataFieldToCompare = field;
				}
				else
				{
					dataFieldToCompare = gc.dataField;
				}
				// Fix for Bug #14855,#14837,#14854,#14836,#14853,#14832,#14851,#14830 end
				if (dataFieldToCompare.indexOf(".") != 0)
				{
					return ObjectUtil.stringCompare(getFieldValue(obj1, dataFieldToCompare), getFieldValue(obj2, dataFieldToCompare), true);
				}
				else
				{
					return ObjectUtil.stringCompare(obj1[dataFieldToCompare], obj2[dataFieldToCompare], true);
				}
			}
		}
			
	}
}
