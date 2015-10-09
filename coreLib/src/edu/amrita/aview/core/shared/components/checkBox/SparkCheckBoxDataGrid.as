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
 * File			: SparkCheckBoxDataGrid.as
 * Module		: common
 * Developer(s)	: VijayKumar R
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
 
/**
 * This expects SparkCheckBoxGridItemRenderer as itemRenderer for one of the columns.
 * The selection/deselection of items is by selecting/deselecting the checkbox.
 * */
package edu.amrita.aview.core.shared.components.checkBox
{
	import spark.components.DataGrid;
	import spark.events.GridEvent;
	
	/**
	 * VPCR: Add class description */
	
	public class SparkCheckBoxDataGrid extends DataGrid
	{
		/**
		 * @public
		 * constructor 
		 * 
		 */
		public function SparkCheckBoxDataGrid()
		{
			super();
		}
		/**
		 * VPCR: Add function description */
		/**
		 * @protected 
		 * @param event GridEvent
		 * 
		 */
		override protected function grid_mouseDownHandler(event:GridEvent):void
		{
			if (!(event.itemRenderer is SparkCheckBoxGridItemRenderer))
			{
				event.stopImmediatePropagation();
				return;
			}
			/*
				If any other itemRenderer with a checkbox in it used, the below code can be used instead of checking for SparkCheckBoxGridItemRenderer instance.
				The columnIndex is the index of checkbox in the grid.
			*/
			/*if (event.column.columnIndex != 0)
			{
				event.stopImmediatePropagation();
				return;
			}*/
			
			if (!event.shiftKey)
			{
				//fake all mouse interactions as if it had the Ctrl key is active (true)
				event.ctrlKey = true;
			}
			super.grid_mouseDownHandler(event);
		}
	}
}