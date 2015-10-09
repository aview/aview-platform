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
 * File			: RowColorDataGrid.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 *
 */
//MMCR:-Function description 
//VKCR:- Variable description
package edu.amrita.aview.common.components
{
	import flash.display.Sprite;
	
	import mx.controls.DataGrid;
	
	/**
	 * @public
	 * extends DataGrid
	 */
	public class RowColorDataGrid extends DataGrid
	{
		public var rowColorFunction:Function;
		
		/**
		 * @protected
		 *
		 * @param s type of Sprite
		 * @param rowIndex type of int
		 * @param y type of Number
		 * @param height type of Number
		 * @param color type of uint
		 * @param dataIndex type of int
		 * @return void
		 */
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			if (rowColorFunction != null && dataProvider != null)
			{
				var item:Object;
				if (dataIndex < dataProvider.length)
				{
					item=dataProvider[dataIndex];
				}
				if (item)
				{
					color=rowColorFunction(item, color);
				}
			}
			super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
		}
	}
}
