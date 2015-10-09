package edu.amrita.aview.common.components
{
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import mx.controls.TextArea;
	public class AutoSizeTextInput extends TextArea {
		public function AutoSizeTextInput() {
			super();
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			this.addEventListener(Event.CHANGE, function(event:Event) {
				invalidateSize();
			});
		}
		override protected function childrenCreated():void {
			this.textField.autoSize = TextFieldAutoSize.LEFT;
			this.textField.wordWrap = true;
			textField.mouseWheelEnabled=false;
			super.childrenCreated();
		}
		override protected function measure():void {
			super.measure();
			//measuredWidth = textField.width;
			measuredHeight = minHeight > textField.height ? minHeight : textField.height;
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			horizontalScrollPolicy = "off";
			height = minHeight > textField.height ? minHeight : textField.height;
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}