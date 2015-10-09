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
 * File			: CheckBoxHeaderColumn.as
 * Module		: Common
 * Developer(s)	: Abhirami
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
/**
 * VPCR: Add file decription */
package edu.amrita.aview.common.components.checkBox
{
	import mx.controls.dataGridClasses.DataGridColumn;
	
	[Event(name="click", type="flash.events.MouseEvent")]
	/**
	 * VPCR: Add class description */
	public class CheckBoxHeaderColumn extends DataGridColumn
	{
		/**
		 * for setting the custom checkbox header render
		 */
		public var checkBoxHeaderRenderer:CheckBoxHeaderRenderer;
		
		/**
		 * @public
		 * constructor
		 * @param columnName type String Default value Null
		 */
		public function CheckBoxHeaderColumn(columnName:String=null)
		{
			super(columnName);
		}
		
		public var selected:Boolean=false;
	
	}
}
