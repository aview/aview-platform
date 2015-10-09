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
 * File			: CheckBoxHeaderRender.as
 * Module		: common
 * Developer(s)	: Abhirami
 * Reviewer(s)	: Sivaram SK,Vishnupreethi.k
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.common.components.checkBox
{
	
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.events.DataGridEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(name="click", type="mx.events.MouseEvent")]
	
	/**
	 * VPCR: Add class description */
	
	public class CheckBoxHeaderRenderer extends CheckBox
	{
		//Logging class
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.components.CheckBoxHeaderRenderer");
		
		private var _headerColumn:CheckBoxHeaderColumn;
		
		/**
		 * @public
		 * constructor
		 */
		public function CheckBoxHeaderRenderer()
		{
			super();
			toolTip="Select/Deselect all Rows";
			addEventListener("click", clickHandler);
			addEventListener("Mouseover", clickHandler1);
		
		
		}
		
		/**
		 * @protected
		 * key down handler
		 * @param event type KeyboardEvent
		 * @return void
		 */
		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == 32)
			{ // Spacebar
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
			}
			super.keyDownHandler(event);
		}
		
		/**
		 * @public
		 * @return Object
		 */
		override public function get data():Object
		{
			return _headerColumn;
		}
		
		/**
		 * @public
		 * @param value type Object
		 * @return void
		 */
		override public function set data(value:Object):void
		{
			_headerColumn=value as CheckBoxHeaderColumn;
			_headerColumn.checkBoxHeaderRenderer=this;
			DataGrid(listData.owner).addEventListener(DataGridEvent.HEADER_RELEASE, sortEventHandler);
			selected=_headerColumn.selected;
		}
		
		/**
		 * @private
		 * @param event type DataGridEvent
		 * @return void
		 */
		private function sortEventHandler(event:DataGridEvent):void
		{
			/**
			 * SKCR: add comments */
			if (event.itemRenderer == this)
				event.preventDefault();
		}
		
		/**
		 * @protected
		 * @param event type MouseEvent
		 * @return void
		 */
		override protected function clickHandler(event:MouseEvent):void
		{
			super.clickHandler(event);
			if (Log.isDebug()) log.debug("selected::" + selected);
			data.selected=selected;
			data.dispatchEvent(event);
		
		}
		
		/**
		 * @protected
		 * @param event type MouseEvent
		 * @return void
		 */
		protected function clickHandler1(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
		}
		
		/**
		 * @protected
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
				var c:DisplayObject=getChildAt(0);
				if (!(c is TextField))
				{
					c.x=(width - c.width) / 2;
					c.y=(height - c.height) / 2;
				}
			}
		}
	}
}
