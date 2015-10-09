package edu.amrita.aview.meeting.itemRenderers
{
	import mx.controls.dataGridClasses.DataGridColumn;
	
	[Event(name="click", type="flash.events.MouseEvent")]
	
	public class CheckBoxHeaderColumn extends DataGridColumn
	{
		public var checkBoxHeaderRenderer : CheckBoxHeaderRenderer;
		
		public function CheckBoxHeaderColumn(columnName:String=null)
		{
			super(columnName);
		}
		/**is the checkbox selected**/
		public var selected:Boolean = false;
		/*
		private var _selected:Boolean = false;
		 
		public function set selected(value:Boolean):void{
			_selected = value;
			Alert.show("headercolumn::selected::" + _selected);
			dispatchEvent(new ListEvent(ListEvent.CHANGE));
		}
		
		public function get selected():Boolean{
			return _selected;
		}   */

	}
}