package edu.amrita.aview.meeting.itemRenderers
{
import flash.display.Sprite;
import flash.events.KeyboardEvent;

import mx.controls.CheckBox;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IListItemRenderer;

/** 
 *  DataGrid that uses checkboxes for multiple selection
 */
public class CheckBoxDataGrid extends DataGrid  //implements IFooterDataGrid
{
	//include "_footerDataGrid.as";
	public function createListData(text:String, dataField:String, i:int):BaseListData
	{
		return new DataGridListData(text, dataField, i, null, this, -1);
	}
	
	override protected function selectItem(item:IListItemRenderer,
                                  shiftKey:Boolean, ctrlKey:Boolean,
                                  transition:Boolean = true):Boolean
	{
		// only run selection code if a checkbox was hit and always
		// pretend we're using ctrl selection
		if (item is CheckBox || item is CheckBoxItemrenderer )
			return super.selectItem(item, false, true, transition);
		return false;
	}

 	// turn off selection indicator
    override protected function drawSelectionIndicator(
                                indicator:Sprite, x:Number, y:Number,
                                width:Number, height:Number, color:uint,
                                itemRenderer:IListItemRenderer):void
    {
	} 

	// whenever we draw the renderer, make sure we re-eval the checked state
    override protected function drawItem(item:IListItemRenderer,
                                selected:Boolean = false,
                                highlighted:Boolean = false,
                                caret:Boolean = false,
                                transition:Boolean = false):void
    {
    	if (item is CheckBox){
			CheckBox(item).invalidateProperties();
    	} 
		
		if(item != null)
		{
			super.drawItem(item, selected, highlighted, caret, transition);
		}
	}

	// fake all keyboard interaction as if it had the ctrl key down
	override protected function keyDownHandler(event:KeyboardEvent):void
	{
		// this is technically illegal, but works
		event.ctrlKey = true;
		event.shiftKey = false;
		super.keyDownHandler(event);
	}
	
	public var rowColorFunction:Function;
    
    override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, 
      												color:uint, dataIndex:int):void{
      if(rowColorFunction != null) 
      {
        var item:Object;
        if(dataIndex < dataProvider.length)
        {
          item = dataProvider[dataIndex];
        }
        
        if(item)
        {
          color = rowColorFunction(item, rowIndex, dataIndex, color);
        }
      }
      
      super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
    }
	
	public function getCheckBoxHeaderColumn():CheckBoxHeaderColumn
	{
		for(var i:int=0;i<this.columns.length;i++)
		{
			if(this.columns[i] is CheckBoxHeaderColumn)
			{
				return this.columns[i];
			}
		}
		return null;
	}
}

}