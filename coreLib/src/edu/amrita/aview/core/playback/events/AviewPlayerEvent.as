package edu.amrita.aview.core.playback.events
{
	import flash.events.Event;

	public class AviewPlayerEvent extends Event
	{
		public static const WB_TAB_CHANGED:String="wbTabChanged";
		public static const WB_CLEARED:String="onWbClear";
		public static const DOC_TAB_CHANGED:String="docTabChanged";
		public static const WB_PAGE_CHANGED:String="wbPageChanged";
		public static const CONSOLIDATE_XML_CREATED:String="consolidateXmlCreated";
		public static const SLIDE_PANNEL_CLOSSED:String="slidePannelClosed";
		public static const STREAM_READY:String="onStreamReady";
		public static const STREAM_NOT_READY:String="onStreamNotReady";
		public static const STREAM_PLAY_COPMLETE:String="onPlayComplete";
		public static const STREAM_SEEK:String="onStreamSeek";
		public static const SlideSlected:String="slideSelected";
		public static const SLIDE_CHANGE:String="onSildeChange";
		public static const MUTE_PRESENTER_STREAM:String="mutePresenterStream";
		public static const UNMUTE_PRESENTER_STREAM:String="unMutePresenterStream";
		public static const MUTE_VIEWER_STREAM:String="muteViewerStream";
		public static const UNMUTE_VIEWER_STREAM:String="unMuteViewerStream";
		public var pageNumber:int;
		public var time:Number;
		public var currentSlideIndex:uint;
		public function AviewPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}