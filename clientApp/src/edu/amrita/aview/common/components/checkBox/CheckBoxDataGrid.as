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
 * File			: CheckBoxDataGrid.as
 * Module		: common
 * Developer(s)	: Abhirami
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.common.components.checkBox
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IListItemRenderer;
	
	/**
	 * @public
	 * DataGrid that uses checkboxes for multiple selection
	 */
	
	public class CheckBoxDataGrid extends DataGrid
	{
		/**
		 * @public
		 * @param text type string
		 * @param dataField type string
		 * @param i type integer
		 * @return BaseListData
		 */
		
		public function createListData(text:String, dataField:String, i:int):BaseListData
		{
			return new DataGridListData(text, dataField, i, null, this, -1);
		}
		
		/**
		 * @protected
		 * @param item type IlistItemRenderer
		 * @param shiftKey type Boolean
		 * @param ctrlKey type Boolean
		 * @param transition type Boolean Default value True
		 * @return Boolean
		 */
		
		override protected function selectItem(item:IListItemRenderer, shiftKey:Boolean, ctrlKey:Boolean, transition:Boolean=true):Boolean
		{
			// only run selection code if a checkbox was hit and always
			// pretend we're using ctrl selection
			if (item is CheckBox)
				return super.selectItem(item, false, true, transition);
			return false;
		}
		
		/**
		 * @protected
		 * whenever we draw the renderer, make sure we re-eval the checked state
		 * @param item type IListItemRenderer
		 * @param selected type Boolean default value false
		 * @param highlighted type Boolean default value false
		 * @param caret type Boolean default value false
		 * @param transition type Boolean default value false
		 * @return void
		 */
		
		override protected function drawItem(item:IListItemRenderer, selected:Boolean=false, highlighted:Boolean=false, caret:Boolean=false, transition:Boolean=false):void
		{
			
			if (item != null)
			{
				CheckBox(item).invalidateProperties();
				super.drawItem(item, selected, highlighted, caret, transition);
			}
		}
		
		/**
		 * @protected
		 * fake all keyboard interaction as if it had the ctrl key down
		 * @param event type KeyboardEvent
		 * @return void
		 */
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			// this is technically illegal, but works
			event.ctrlKey=true;
			event.shiftKey=false;
			super.keyDownHandler(event);
		}
		
		/**
		 * To set the row color in the data grid
		 */
		public var rowColorFunction:Function;
		
		/**
		 * @protected
		 * @param s type Sprite
		 * @param rowIndex type integer
		 * @param y type number
		 * @param height type number
		 * @param color type uint
		 * @param dataIndex type integer
		 * @return void
		 */
		
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			if (rowColorFunction != null)
			{
				var item:Object;
				if (dataIndex < dataProvider.length)
				{
					item=dataProvider[dataIndex];
				}
				
				if (item)
				{
					color=rowColorFunction(item, rowIndex, dataIndex, color);
				}
			}
			
			super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
		}
	}

}
