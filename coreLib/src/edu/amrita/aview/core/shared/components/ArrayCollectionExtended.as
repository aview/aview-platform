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
 * File			: ArrayCollectionExtended.as
 * Module		: Common
 * Developer(s)	: Bri.Radha 
 * Reviewer(s)	:Monisha Mohanan,Veena Gopal K.V
 */


package edu.amrita.aview.core.shared.components
{
	
	import mx.collections.ArrayCollection;
	
	/**
	 * @public
	 * extends ArrayCollection
	 */
	public class ArrayCollectionExtended extends ArrayCollection
	{
		//VGCR:Add description for variable
		private var _filterFunctions:Array;
		
		/**
		 * @public
		 * constructor
		 * @param source type Array default Null
		 */
		public function ArrayCollectionExtended(source:Array=null)
		{
			super(source);
		}
		
		/**
		 * @public
		 * setter function for filtering the data
		 * @param filtersArray type of Array
		 * @return void
		 *
		 */
		public function set filterFunctions(filtersArray:Array):void
		{
			_filterFunctions=filtersArray;
			this.filterFunction=complexFilter;
		}
		
		/**
		 *
		 * @public
		 * getter function for filtering the data
		 *
		 * @return Array
		
		 */
		public function get filterFunctions():Array
		{
			return _filterFunctions;
		}
		
		/**
		 * @protected
		 * function for filtering the data
		 * @param item type of Object
		 * @return Boolean
		 */
		protected function complexFilter(item:Object):Boolean
		{
			var filterFlag:Boolean=true;
			var filter:Function;
			for each (filter in filterFunctions)
			{
				filterFlag=filter(item);
				if (!filterFlag)
					break;
			}
			
			return filterFlag;
		}
	}
}
