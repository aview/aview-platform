package edu.amrita.aview.core.video{
	import flash.events.Event;
	
	public class VideoTileEvent extends Event{
		public static const RESIZED:String="Resized";
		public static const VIDEOADDED:String="VideoAdded";
		private var _resizeFactor:Number=0;
		
		public function VideoTileEvent(type:String, resizeFactor:Number=0, bubbles:Boolean=false, cancelable:Boolean=false){
			_resizeFactor=resizeFactor;
			super(type, bubbles, cancelable);
		}
		
		public function get resizeFactor():Number{
			return _resizeFactor;
		}
		
	}
}
