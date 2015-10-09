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
 * File			: CustomComboBox.as
 * Module		: Common
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 * for customizing the combobox
 */
//MMCR:-Function description for all function
//VGCR:-Variable description
package edu.amrita.aview.common.components
{
	import mx.controls.ComboBox;
	
	/**
	 *
	 * @public
	 * extends ComboBox
	 */
	public class CustomComboBox extends ComboBox
	{
		/**
		 *
		 * @public
		 * constructor
		 */
		public function CustomComboBox()
		{
			super();
		}
		
		public var dataField:String="data";
		
		private var _dataProvider:Object;
		private var dataProviderChanged:Boolean=false;
		
		/**
		 *
		 * @public
		 *
		 * @param value of type Object
		 * @return void
		 */
		
		override public function set dataProvider(value:Object):void
		{
			_dataProvider=value;
			dataProviderChanged=true;
			invalidateProperties();
		}
		
		private var _value:Object;
		private var valueChanged:Boolean=false;
		
		/**
		 *
		 * @public
		 * to set the values to the combobox while editing
		 * @param val of type Object
		 * @return void
		 */
		public function set value(val:Object):void
		{
			_value=val;
			valueChanged=true;
			invalidateProperties();
		}
		
		/**
		 *
		 * @public
		 *
		 *
		 * @return Object
		 */
		[Bindable("change")]
		[Bindable("valueCommit")]
		[Inspectable(defaultValue="0", category="General", verbose="1")]
		override public function get value():Object
		{
			var item:Object=selectedItem;
			if (item == null || typeof(item) != "object")
				return item;
			return item[dataField] ? item[dataField] : item.label;
		}
		
		/**
		 *
		 * @private
		 *
		 * @param val of type Object
		 * @return void
		 */
		private function applyValue(val:Object):void
		{
			if ((val != null) && (dataProvider != null) && (dataProvider.length > 0) && (dataProvider[0] != null))
			{
				for (var i:int=0; i < dataProvider.length; i++)
				{
					if (val == dataProvider[i][dataField] || val == dataProvider[i][labelField])
					{
						selectedIndex=i;
						return;
					}
				}
			}
			
			selectedIndex=-1;
		}
		
		/**
		 *
		 * @protected
		 *
		 *
		 * @return void
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dataProviderChanged)
			{
				super.dataProvider=_dataProvider;
				dataProviderChanged=false;
				
				if (_value)
					applyValue(_value);
			}
			
			if (valueChanged)
			{
				applyValue(_value);
				valueChanged=false;
			}
		}
	
	}
}
