package edu.amrita.aview.meeting.itemRenderers
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
 *  The Renderer.
 */
public class CheckBoxRenderer extends CheckBox
{
	//private static const ADD_ROW:String = "Click to Add Row";
	private var _checkBoxHeaderColumn : CheckBoxHeaderColumn;
	public function CheckBoxRenderer()
	{
		//focusEnabled = false;
		super();
		addEventListener("click", clickHandler);
	}

	
	override public function set data(value:Object):void
	{
		super.data = value;
		var dataGrid : DataGrid = listData.owner as DataGrid;
		_checkBoxHeaderColumn = dataGrid.columns[listData.columnIndex];
			/*if (data.categoryName == ADD_ROW){
			enabled = false;
			selected = false;
		} */
		invalidateProperties();
	}

	override public function validateProperties():void
	{
		super.validateProperties();
		if (listData)
		{
			
			var dg:DataGrid = DataGrid(listData.owner);

			var column:CheckBoxHeaderColumn =	dg.columns[listData.columnIndex];
			column.addEventListener("click",columnHeaderClickHandler);
			//selected = data[column.dataField];
		}
	}
	override protected function clickHandler(event:MouseEvent):void
	{
		if (!selected){
			if (_checkBoxHeaderColumn.checkBoxHeaderRenderer != null)
				_checkBoxHeaderColumn.checkBoxHeaderRenderer.selected = selected;
		}
		event.stopPropagation();
	}
	private function columnHeaderClickHandler(event:MouseEvent):void
	{
		//why this alery shows three times for a data of 2 rows
		//mx.controls.Alert.show("alert");
		/* if (data.categoryName == ADD_ROW){
			enabled = false;
			selected = false;
			return;
		} */
		selected = event.target.selected;
	}
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		if (owner is ListBase)
			selected = ListBase(owner).isItemSelected(data);
	}

	/* eat keyboard events, the underlying list will handle them */
	protected override function keyDownHandler(e : KeyboardEvent) : void {
		if (e.keyCode == 32) { // Spacebar
			e.preventDefault();
			e.stopImmediatePropagation();
			return;
		}
		super.keyDownHandler(e);
	}

	/* eat keyboard events, the underlying list will handle them */
	override protected function keyUpHandler(event:KeyboardEvent):void
	{
	}

	/* eat mouse events, the underlying list will handle them */
	/*override protected function clickHandler(event:MouseEvent):void
	{
		*///super.clickHandler(event);
		/* if (data.categoryName == ADD_ROW){
			enabled = false;
			selected = false;
			return;
		} */
		/*if (!selected){
			if (_checkBoxHeaderColumn.checkBoxHeaderRenderer != null)
				_checkBoxHeaderColumn.checkBoxHeaderRenderer.selected = selected;
		}
	} */

	/* center the checkbox if we're in a datagrid */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		if (listData is DataGridListData)
		{
			var n:int = numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var c:DisplayObject = getChildAt(i);
				if (!(c is TextField))
				{
					c.x = (w - c.width) / 2;
					c.y = (h - c.height) / 2;
				}
			}
		}
	}

}

}