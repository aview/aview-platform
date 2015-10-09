package edu.amrita.aview.core.video{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Image;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(name="Resized", type="edu.amrita.aview.core.video.VideoTileEvent")]
	public class ResizableTitleWindow extends TitleWindow{
		
		[Embed(source="assets/images/resizeCursorTLBR.gif")]
		private static var CURSOR_CLASS:Class;
		
		[Embed(source="assets/images/icon_grip.png")]
		private static var ICON_CLASS:Class;
		
		private static var CURSOR_X_OFFSET:Number=-10;
		
		private static var CURSOR_Y_OFFSET:Number=-10;
		
		public function ResizableTitleWindow(){
		}
		
		public var resizeHandleSize:int=10;
		
		private var _resizeFactorTitleWindow:Number=0;
		
		private var _resizable:Boolean=false;
		
		private var m_dragStartMouseX:Number;
		
		private var m_dragStartMouseY:Number;
		
		private var m_resizeHandle:Image  = null;
		
		private var m_startHeight:Number;
		
		private var m_startWidth:Number;
		private var minresizeFactor:uint=4;
		private var _maxResizeFactor:uint=0;
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.video.ResizableTitleWindow.as");
		
		override protected function createChildren():void{
			super.createChildren();
			
			if (_resizable){
				m_resizeHandle = new Image();
				m_resizeHandle.source=ICON_CLASS;
				m_resizeHandle.width = resizeHandleSize;
				m_resizeHandle.height = resizeHandleSize;
				m_resizeHandle.alpha = 1.0;
				m_resizeHandle.focusEnabled = false;
				m_resizeHandle.toolTip="Resize Tile";
				
				m_resizeHandle.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
				m_resizeHandle.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
				m_resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				
				rawChildren.addChild(m_resizeHandle);
				
				
			}
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(m_resizeHandle){
			m_resizeHandle.x = this.width - resizeHandleSize ;
			m_resizeHandle.y = this.height - resizeHandleSize ;
			m_resizeHandle.width = m_resizeHandle.height = resizeHandleSize;
			}
		}
		
		private function resizeTile():void{
			const dragAmountX:Number=parent.mouseX - (m_startWidth + this.x);
			const dragAmountY:Number=parent.mouseY - (m_startHeight + this.y);
			
			if (_resizeFactorTitleWindow > 0 && dragAmountX != 0 && dragAmountY != 0){
				if (parent.mouseX < parent.width && parent.mouseY < parent.height){
					var increaseFactor:Number;
					if (dragAmountX > dragAmountY){
						increaseFactor=dragAmountX / 16;
					}
					else{
						increaseFactor=dragAmountY / 9;
					}
					//if(dragAmountX>0){
					_resizeFactorTitleWindow=_resizeFactorTitleWindow + Math.floor(increaseFactor);
					//}
					/*else if(dragAmountX<0){
					_resizeFactorTitleWindow=_resizeFactorTitleWindow-Math.floor(increaseFactor);
					}*/
					
					if(Log.isDebug()) log.debug("_resizeFactorTitleWindow:" + _resizeFactorTitleWindow);
				}
				else{
					_resizeFactorTitleWindow=maxResizeFactor;
				}
				if (minresizeFactor > _resizeFactorTitleWindow){
					_resizeFactorTitleWindow=minresizeFactor;
				}
				else if (_maxResizeFactor < _resizeFactorTitleWindow){
					_resizeFactorTitleWindow=maxResizeFactor;
				}
			}
			else if (parent.mouseX < parent.width && parent.mouseY < parent.height){
				this.width=Math.max(m_startWidth + dragAmountX, minWidth);
				this.height=Math.max(m_startHeight + dragAmountY, minHeight);
			}
		}
		
		
		/**
		 * Mouse down on any resize handle.
		 */
		private function mouseDownHandler(event:MouseEvent):void{
			this.stopDrag();
			setCursor();
			
			//systemManager.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			systemManager.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler, false, 0, true);
		}
		
		private function mouseLeaveHandler(event:Event):void{
			mouseUpHandler();
			systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent=null):void{
			this.stopDrag();
			m_dragStartMouseX=parent.mouseX;
			m_dragStartMouseY=parent.mouseY;
			
			m_startWidth=this.width;
			m_startHeight=this.height;
			
			if (parent.height > parent.width){
				_maxResizeFactor=(parent.width) / 16;
			}
			else{
				_maxResizeFactor=(parent.height) / 9;
			}
			resizeTile();
			if(_resizeFactorTitleWindow < 14)
				_resizeFactorTitleWindow = 14;
			this.width=_resizeFactorTitleWindow * 16;
			this.height=_resizeFactorTitleWindow * 9;
			//systemManager.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			cursorManager.removeCursor(cursorManager.currentCursorID);
			var TileResizedEvent:VideoTileEvent=new VideoTileEvent(VideoTileEvent.RESIZED, this.resizeFactorTitleWindow);
			this.dispatchEvent(TileResizedEvent);
			
		}
		
		private function rollOutHandler(event:MouseEvent):void{
			if (!event.buttonDown){
				cursorManager.removeCursor(cursorManager.currentCursorID);
			}
		}
		
		private function rollOverHandler(event:MouseEvent):void{
			if (!event.buttonDown){
				setCursor();
			}
		}
		
		private function setCursor():void{
			
			cursorManager.removeCursor(cursorManager.currentCursorID);
			cursorManager.setCursor(CURSOR_CLASS, 2, CURSOR_X_OFFSET, CURSOR_Y_OFFSET);
		}
		
		[Bindable]
		public function get resizeFactorTitleWindow():Number{
			return _resizeFactorTitleWindow;
		}
		
		public function set resizeFactorTitleWindow(value:Number):void{
			_resizeFactorTitleWindow=value;
			
		}
		
		[Bindable]
		public function get resizable():Boolean{
			return _resizable;
		}
		
		public function set resizable(value:Boolean):void{
			_resizable=value;
			
			if(!_resizable && m_resizeHandle!=null && numChildren>0){
			
			m_resizeHandle.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			m_resizeHandle.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			m_resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			rawChildren.removeChild(m_resizeHandle);
			m_resizeHandle=null;
			if(minresizeFactor>0){
			this.width=minresizeFactor*16;
			this.height=minresizeFactor*9;
			}
			}
			else if(_resizable && m_resizeHandle==null && numChildren>0){
			m_resizeHandle = new Image();
			m_resizeHandle.source=ICON_CLASS;
			m_resizeHandle.width = resizeHandleSize;
			m_resizeHandle.height = resizeHandleSize;
			m_resizeHandle.alpha = 1.0;
			m_resizeHandle.focusEnabled = false;
			m_resizeHandle.toolTip="Resize Tile";
			m_resizeHandle.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			m_resizeHandle.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			m_resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			
			rawChildren.addChild(m_resizeHandle);
			
			}
		}
		
		public function get maxResizeFactor():uint{
			return _maxResizeFactor;
		}
		
		public function set maxResizeFactor(value:uint):void{
			_maxResizeFactor=value;
		}		
	}
}