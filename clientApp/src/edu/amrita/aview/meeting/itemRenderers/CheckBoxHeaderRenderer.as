package edu.amrita.aview.meeting.itemRenderers
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
	
	
	public class CheckBoxHeaderRenderer extends CheckBox
	{
		private var _headerColumn : CheckBoxHeaderColumn;
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.meeting.itemRenderers.CheckBoxHeaderRenderer.as");
		
		public function CheckBoxHeaderRenderer()
		{
			super();
			toolTip = "Select/Deselect all Rows";
			addEventListener("click", clickHandler);
			
		}
		protected override function keyDownHandler(e : KeyboardEvent) : void {
			if (e.keyCode == 32) { // Spacebar
				e.preventDefault();
				e.stopImmediatePropagation();
				return;
			}
			super.keyDownHandler(e);
		}
		override public function get data():Object
		{
			return _headerColumn;
		}
		
		override public function set data(value:Object):void
		{
			_headerColumn = value as CheckBoxHeaderColumn;
			_headerColumn.checkBoxHeaderRenderer = this;
			DataGrid(listData.owner).addEventListener(DataGridEvent.HEADER_RELEASE, sortEventHandler);
			selected = _headerColumn.selected;
		}
	
		private function sortEventHandler(event:DataGridEvent):void
		{
			if (event.itemRenderer == this)
				event.preventDefault();
		}
		override protected function clickHandler(event:MouseEvent):void
		{
			super.clickHandler(event);
			if(Log.isInfo()) log.info("selected::" + selected);
			data.selected = selected;
			data.dispatchEvent(event);
		}
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			if (listData is DataGridListData)
			{
				var n:int = numChildren;
				var c:DisplayObject = getChildAt(0);
				if (!(c is TextField))
				{
					c.x = (w - c.width) / 2;
					c.y = (h - c.height) / 2;
				}
			}
		}


  }
}  