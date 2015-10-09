////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: ToggleSwitch.as
 * Module		: common
 * Developer(s)	: Ramesh Sir
 * Reviewer(s)	: Remya T,Vishnupreethi K
 */

/**
 * VPCR: Add file description */

package edu.amrita.aview.common.components.toggleSwitch
{
	
	import spark.components.CheckBox;
	import spark.core.IDisplayText;
	/**
	 * VPCR: Add class description */
	
	public class ToggleSwitch extends CheckBox
	{
		/**
		 * for setting the skin for the selected label
		 */
		[SkinPart("false")]
		public var selectedLabelField:IDisplayText;
		/**
		 * for setting the skin for the unselected label
		 */
		[SkinPart("false")]
		public var deselectedLabelField:IDisplayText;
		/**
		 * to set the label selected status
		 */
		private var _selectedLabel:String='Yes';
		private var _deselectedLabel:String='No';
		
		/**
		 * @public
		 * constructor
		 */
		public function ToggleSwitch()
		{
			super();
		}
		
		/**
		 * @public
		 * getter function for unselecting the label
		 * @return String
		 */
		public function get deselectedLabel():String
		{
			return _deselectedLabel;
		}
		
		/**
		 * @public
		 * setter function for unselecting the label
		 * @param value type String
		 * @return void
		 */
		public function set deselectedLabel(value:String):void
		{
			_deselectedLabel=value;
			if (deselectedLabelField)
			{
				deselectedLabelField.text=deselectedLabel;
			}
		}
		
		/**
		 * @public
		 * getter function for selecting the label
		 * @return String
		 */
		public function get selectedLabel():String
		{
			return _selectedLabel;
		}
		
		/**
		 * @public
		 * setter function for selecting the label
		 * @param value type String
		 * @return void
		 */
		public function set selectedLabel(value:String):void
		{
			_selectedLabel=value;
			if (selectedLabelField)
			{
				selectedLabelField.text=selectedLabel;
			}
		}
		
		/**
		 * @protected
		 * @param partName type String
		 * @param instance type Object
		 * @return void
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == selectedLabelField)
			{
				selectedLabelField.text=selectedLabel;
			}
			if (instance == deselectedLabelField)
			{
				deselectedLabelField.text=deselectedLabel;
			}
		}
	}
}

