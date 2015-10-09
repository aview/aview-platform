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
 * File			: ArrayCollectionUtil.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 * 
 */
package edu.amrita.aview.core.shared.util
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.utils.ObjectUtil;

	//VGCR:-Class Description
	//VGCR:-Function Description
	//VGCR:-Function description for function
	public class ArrayCollectionUtil
	{
		/**
		 *@public
		 *Constructor 
		 * 
		 */
		public function ArrayCollectionUtil()
		{
		
		}
		
		/**
		 * @public 
		 * @param dest of type ArrayCollection
		 * @param src of type ArrayCollection
		 * 
		 */
		public static function copyData(dest:ArrayCollection, src:ArrayCollection):void
		{
			if ((src == null) || (dest == null))
			{
				return;
			}
			else
			{
				var obj:Object=null;
				for (var i:int=0; i < src.length; i++)
				{
					obj=new Object();
					obj=ObjectUtil.copy(src[i]) as Object;
					dest.addItem(obj);
				}
			}
		}
		public static function sortData(dataProvider:ArrayCollection,dataField:String,numericSort:Boolean = false,isCaseInsensitive:Boolean = false):void
		{
			var dataSortField:SortField = new SortField();
			dataSortField.name = dataField;
			dataSortField.numeric = numericSort;
			dataSortField.caseInsensitive = isCaseInsensitive;
			/* Create the Sort object and add the SortField object created earlier to the array of fields to sort on. */
			var numericDataSort:Sort= new Sort();
			numericDataSort.fields = [dataSortField];
			/* Set the ArrayCollection object's sort property to our custom sort, and refresh the ArrayCollection. */
			dataProvider.sort = numericDataSort;
			dataProvider.refresh();
		}
	
	}
}
