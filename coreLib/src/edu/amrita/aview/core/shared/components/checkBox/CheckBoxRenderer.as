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
 * File			: CheckBoxRender.as
 * Module		: common
 * Developer(s)	: Abhirami
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */

/**
 * VPCR: Add file description */

package edu.amrita.aview.core.shared.components.checkBox
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.ListBase;
	
	/**
	 * VPCR: Add class description */
	
	public class CheckBoxRenderer extends CheckBox
	{
		/**
		 * checkbox header custom component
		 */
		private var _checkBoxHeaderColumn:CheckBoxHeaderColumn;
		
		/**
		 * @public
		 * constructor
		 */
		public function CheckBoxRenderer()
		{
			super();
			addEventListener("click", clickHandler);
		}
		/**
		 * SKCR: add comments */
		/**
		 * @public
		 * @param value type Object
		 * @return void
		 */
		override public function set data(value:Object):void
		{
			super.data=value;
			var dataGrid:DataGrid=listData.owner as DataGrid;
			_checkBoxHeaderColumn=dataGrid.columns[listData.columnIndex];
			invalidateProperties();
		}
		/**
		 * SKCR: add comments */
		/**
		 * @public
		 * @return void
		 */
		override public function validateProperties():void
		{
			super.validateProperties();
			if (listData)
			{
				
				var dg:DataGrid=DataGrid(listData.owner);
				
				var column:CheckBoxHeaderColumn=dg.columns[listData.columnIndex];
				column.addEventListener("click", columnHeaderClickHandler);
			}
		}
		/**
		 * SKCR: add comments */
		/**
		 * @protected
		 * @param event type MouseEvent
		 * @return void
		 */
		override protected function clickHandler(event:MouseEvent):void
		{
			if (!selected)
			{
				if (_checkBoxHeaderColumn.checkBoxHeaderRenderer != null)
					_checkBoxHeaderColumn.checkBoxHeaderRenderer.selected=selected;
			}
			event.stopPropagation();
		}
		
		/**
		 * @private
		 * @param event type MouseEvent
		 * @return void
		 */
		private function columnHeaderClickHandler(event:MouseEvent):void
		{
			selected=event.target.selected;
		}
		/**
		 * SKCR: add comments */
		/**
		 * @protected
		 * @return void
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (owner is ListBase)
				selected=ListBase(owner).isItemSelected(data);
		}
		
		/**
		 * @protected
		 * eat keyboard events, the underlying list will handle them
		 * @param event type KeyboardEvent
		 * @return void
		 */
		
		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == 32)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
			}
			super.keyDownHandler(event);
		}
		
		/**
		 * @protected
		 * eat keyboard events, the underlying list will handle them
		 * @param event type KeyboardEvent
		 * @return void
		 */
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
		}
		
		/**
		 * @protected
		 * center the checkbox if we're in a datagrid
		 * @param width type Number
		 * @param height type Number
		 * @return void
		 */
		override protected function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width, height);
			
			if (listData is DataGridListData)
			{
				var n:int=numChildren;
				for (var i:int=0; i < n; i++)
				{
					var c:DisplayObject=getChildAt(i);
					if (!(c is TextField))
					{
						c.x=(width - c.width) / 2;
						c.y=0;
					}
				}
			}
		}
	
	}

}
