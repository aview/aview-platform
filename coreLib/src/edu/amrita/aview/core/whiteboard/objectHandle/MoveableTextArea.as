package edu.amrita.aview.core.whiteboard.objectHandle
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.core.IFlexDisplayObject;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.IFocusManagerContainer;
	
	import spark.components.RichEditableText;
	import spark.components.TextArea;
	
	/**
	 * This is an example and not part of the core ObjectHandles library.
	 **/
	
	public class MoveableTextArea extends spark.components.TextArea implements IFocusManagerContainer
	{
		protected var _model:TextDataModel;
		private var charecterLockWidth:Number=0;
		private var charecterLockHeight:Number=0;
		public var shapeType:String;
		public var drawnBy:String;
		private var okButton:spark.components.Button;
		
		public function MoveableTextArea()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			needsSoftKeyboard=false;
		}
		
		public function get defaultButton():IFlexDisplayObject
		{
			return this;
		}
		
		public function set defaultButton(value:IFlexDisplayObject):void
		{
		}
		
		private function onCreationComplete(evnt:FlexEvent):void
		{
			scroller.focusManager=this.focusManager;
			this.addEventListener(Event.CHANGE, onTextInput);
			setStyle("horizontalScrollPolicy", "off");
			setStyle("verticalScrollPolicy", "off");
			//this.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			//this.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.scroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onScrollEvent);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true, 0, false);
			this.addEventListener(Event.PASTE, onPasteText);
			this.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseRightDown);
			//this.scroller.verticalScrollBar.addEventListener(Event.CHANGE, onScrollEvent);
			//addEventListener(TextOperationEvent.CHANGE, preventArrokeys);
		}
		
		/*private function preventArrokeys(evnt:TextOperationEvent):void{
			evnt.preventDefault();
		}*/
		// Disable context menu
		private function onMouseRightDown(event:MouseEvent):void
		{
			
			if ((this.textDisplay as RichEditableText) != null && (this.textDisplay as RichEditableText).contextMenu != null)
			{
				((this.textDisplay as RichEditableText).contextMenu as ContextMenu).hideBuiltInItems();
				((this.textDisplay as RichEditableText).contextMenu as ContextMenu).clipboardMenu=false;
			}
		}
		
		private function onPasteText(evnt:Event):void
		{
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, onPasteTextComplete);
		}
		
		private function onPasteTextComplete(evnt:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.UPDATE_COMPLETE, onPasteTextComplete);
			setScrollOnBegining();
		}
		
		public function setScrollOnBegining():void
		{
			this.scroller.viewport.horizontalScrollPosition=0;
			this.scroller.viewport.verticalScrollPosition=0;
		}
		
		private function onScrollEvent(evnt:PropertyChangeEvent):void
		{
			if ((evnt.property == "contentHeight" || evnt.property == "contentWidth") && scroller.viewport.contentHeight > this.height)
			{
				var lastChar:String=text.substring(text.length - 1);
				//PNCR: Bug #15074. Commented the logic to remove the newline at the end of text area.
				//text=text.substring(0, text.length - 1);
				if (lastChar != "\n") // Not called bu hitting Enter key
					maxChars=text.length;
			}
		/*if(evnt.property == "verticalScrollPosition"  && scroller.viewport.contentHeight<=this.height)
			textEdited =false;*/
		
		}
		
		//Disabling mouse wheel scrolling
		private function mouseWheelHandler(event:MouseEvent):void
		{
			var originalEvent:MouseEvent=event.clone() as MouseEvent;
			
			event.preventDefault();
			event.stopPropagation();
			event.stopImmediatePropagation();
			
			this.dispatchEvent(originalEvent);
		}
		
		private function onFocusIn(evnt:FocusEvent):void
		{
			setStyle("borderAlpha", "1");
		}
		
		private function onFocusOut(evnt:FocusEvent):void
		{
			setStyle("borderAlpha", "0");
		}
		
		public function set model(val:TextDataModel):void
		{
			if (_model)
				_model.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			_model=val;
			reposition();
			
			val.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
		}
		
		protected function onTextInput(event:Event):void
		{
			if (_model)
			{
				_model.text=text;
			}
		}
		
		protected function onPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property == "text" || event.property == "width" && _model.width > charecterLockHeight || event.property == "height" && _model.height > charecterLockHeight)
			{
				text+="";
				maxChars=0;
				
			}
			reposition();
		
		}
		
		protected function reposition():void
		{
			drawFocus(false);
			x=_model.x;
			y=_model.y;
			width=_model.width;
			height=_model.height;
			rotation=_model.rotation;
			text=_model.text;
		}
	
	}
}
