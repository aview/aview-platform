package edu.amrita.aview.core.documentSharing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;

	public class StageWebViewComponent extends UIComponent
	{
		public var yOffset:int = 80;
		
		protected var myStage:Stage;
		private var _url:String;
		private var _text:String;
		public var stageWidth:int;
		public var stageHeight:int;
		public var stageX:int;
		public var stageY:int;
		
		public var _stageWebView:StageWebView;
		
		public function get stageWebView():StageWebView{
			return _stageWebView;
		}
		public function StageWebViewComponent()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		public function set url(url:String):void{
			_url = url;
			
			if(_stageWebView){
				_stageWebView.loadURL(url);
			}
		}
		
		public function set text(text:String):void{
			_text = text;
			
			if(_stageWebView){
				_stageWebView.loadString(text);
			}
		}
		
		public function hide():void{
			_stageWebView.stage = null;
		}
		
		public function show():void{
			_stageWebView.stage = myStage;
		}
		public function hideWebView(destroy:Boolean = false):void {
			if(_stageWebView == null) return;
			_stageWebView.stage = null;
			resizeStageWebView(-10,-10,10,10);
			if(!destroy) return;
			_stageWebView.viewPort = null;
			_stageWebView.dispose();
			_stageWebView = null;
		}
		private var portWidth:int = 0 ;
		private var portHeight:int = 0;
		private var portX:int = 0 ;
		private var portY:int = 0 ;
		/** Displays the web view @see flash.media.StageWebView#stage */
		public function showWebView():void {
			if(_stageWebView != null) {
				_stageWebView.stage = myStage;
				
				if(portWidth > 0){
					resizeStageWebView(portX,portY,portWidth,portHeight);
				}
				return; 
			}
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList(); 
		}
		public function takeSnapshot():BitmapData {
			destroySnapshot();
			snapshotBitmapData = new BitmapData(_stageWebView.viewPort.width, _stageWebView.viewPort.height);
			_stageWebView.drawViewPortToBitmapData(snapshotBitmapData);
			webViewBitmap = new Bitmap(snapshotBitmapData);
			portWidth = _stageWebView.viewPort.width;
			portHeight = _stageWebView.viewPort.height;
			portX = _stageWebView.viewPort.x;
			portY = _stageWebView.viewPort.y;
			hideWebView(); 
			addChild(webViewBitmap);
			isSnapshotVisible = true;
			
			return snapshotBitmapData;
		}
		/** Flag indicating if a snapshot is being shown */
		[Bindable]
		public var isSnapshotVisible:Boolean;
		/**
		 * When calling takeSnapshot or setting snapshotMode to true this 
		 * property will contain the bitmap data of the view port. 
		 * */
		public var snapshotBitmapData:BitmapData;
		/**
		 * When calling takeSnapshot or setting snapshotMode a snapshot of 
		 * the Stage Web View is taken and added to the stage. This is a
		 * reference to the displayed bitmap. 
		 * */
		public var webViewBitmap:Bitmap;
		/**
		 * @private
		 * */
		public function get snapshotMode():Boolean {
			return isSnapshotVisible;
		}
		/**
		 * When set to true hides the stage web view and displays a non-interactive 
		 * snapshot of the Stage Web View when the property was set to true.  
		 * */
		public function set snapshotMode(value:Boolean):void {
			value ? takeSnapshot() : removeSnapshot();
		}
		/**
		 * Removes the bitmap snapshot of the Stage Web View from the display list 
		 * and displays the actual Stage Web View.
		 * @copy flash.media.StageWebView#drawViewPortToBitmapData()
		 * */
		public function removeSnapshot():void {
			destroySnapshot();
			showWebView();
		}
		/**
		 * Removes the web view snapshot from the display list and disposes of the 
		 * bitmap data
		 * */
		private function destroySnapshot():void {
			if (webViewBitmap) {
				if (webViewBitmap.parent) removeChild(webViewBitmap);
				if (webViewBitmap.bitmapData) webViewBitmap.bitmapData.dispose();
				webViewBitmap = null;
			}
			if (snapshotBitmapData) {
				snapshotBitmapData.dispose();
				snapshotBitmapData = null;
			}
			isSnapshotVisible = false;
		}
		///////////////////////////
		public function dispose():void{
			hide();
			_stageWebView.dispose();
		}
		
		protected function addedToStageHandler(event:Event):void{
			myStage = event.currentTarget.document.stage;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			_stageWebView = new StageWebView();
			_stageWebView.stage = myStage;
			_stageWebView.viewPort = new Rectangle(stageX, stageY, stageWidth, stageHeight);
			_stageWebView.addEventListener(Event.COMPLETE, completeHandler);
			_stageWebView.addEventListener(ErrorEvent.ERROR, errorHandler);
			_stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChangingHandler);
			_stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, locationChangeHandler);
			if(_url){
				_stageWebView.loadURL(_url);
			}else if(_text){
				_stageWebView.loadString(_text);
			}
			
		}
		
		public function resizeStageWebView(x:int,y:int,width:int,height:int):void{
			if(_stageWebView != null){
				if(FlexGlobals.topLevelApplication.docComp.pptLoaded){
					_stageWebView.viewPort = new Rectangle(x, y, width, height);
				}else{
					_stageWebView.viewPort = new Rectangle(-10, -10, 10, 10);
				}
			}
			trace(" x:"+x+" y : "+y+" W : "+width+" H : "+height);
		}
		protected function completeHandler(event:Event):void{
			trace("StageWebview Completed");
			FlexGlobals.topLevelApplication.docComp.stageWebViewIntiated("Completed");
		}
		
		protected function locationChangingHandler(event:Event):void{
			dispatchEvent(event.clone());
		}
		
		protected function locationChangeHandler(event:LocationChangeEvent ):void{
			FlexGlobals.topLevelApplication.docComp.stageWebViewIntiated("Intiated");
		}
		
		protected function errorHandler(event:Event):void{
			dispatchEvent(event.clone());
			trace("StageWebview Error");
		}
	}
}