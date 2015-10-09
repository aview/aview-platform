////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: AviewPlayerEvent.as
 * Module		: PlayBack
 * Developer(s)	: Haridas ,Anu
 * Reviewer(s)	: Remya T
 *
 * AviewPlayerEvent is a extended class of Event class.
 * This class contain all the information about the session.
 */

package edu.amrita.aview.playback.events{
	import flash.events.Event;
	/** 
	 * AviewPlayerEvent is a extended class of Event class.
	 * This class contain all the information about the session.
	 */
	public class AviewPlayerEvent extends Event{
		/**
		 *WB_TAB_CHANGED is  Event type of this class.
		 */		
		public static const WB_TAB_CHANGED:String="wbTabChanged";
		/**
		 *WB_CLEARED is  Event type of this class.
		 */		
		public static const WB_CLEARED:String="onWbClear";
		/**
		 *DOC_TAB_CHANGED is  Event type of this class.
		 */		
		public static const DOC_TAB_CHANGED:String="docTabChanged";
		/**
		 *WB_PAGE_CHANGED is  Event type of this class.
		 */
		public static const WB_PAGE_CHANGED:String="wbPageChanged";
		/**
		 *CONSOLIDATE_XML_CREATED is  Event type of this class.
		 */		
		public static const CONSOLIDATE_XML_CREATED:String="consolidateXmlCreated";
		/**
		 *SLIDE_PANNEL_CLOSSED is  Event type of this class.
		 */		
		public static const SLIDE_PANNEL_CLOSSED:String="slidePannelClosed";
		/**
		 *STREAM_READY is  Event type of this class.
		 */		
		public static const STREAM_READY:String="onStreamReady";
		/**
		 *STREAM_NOT_READY is  Event type of this class.
		 */		
		public static const STREAM_NOT_READY:String="onStreamNotReady";
		/**
		 *STREAM_PLAY_COPMLETE is  Event type of this class.
		 */		
		public static const STREAM_PLAY_COPMLETE:String="onPlayComplete";
		/**
		 *STREAM_SEEK is  Event type of this class.
		 */
		
		public static const STREAM_SEEK:String="onStreamSeek";
		/**
		 *SlideSlected is  Event type of this class.
		 */		
		public static const SlideSlected:String="slideSelected";
		/**
		 *SLIDE_CHANGE is  Event type of this class.
		 */
				public static const SLIDE_CHANGE:String="onSildeChange";
		/**
		 *MUTE_PRESENTER_STREAM is  Event type of this class.
		 */
		
		public static const MUTE_PRESENTER_STREAM:String="mutePresenterStream";
		/**
		 *UNMUTE_PRESENTER_STREAM is  Event type of this class.
		 */		
		public static const UNMUTE_PRESENTER_STREAM:String="unMutePresenterStream";
		/**
		 *MUTE_VIEWER_STREAM is  Event type of this class.
		 */
		public static const MUTE_VIEWER_STREAM:String="muteViewerStream";
		/**
		 *UNMUTE_VIEWER_STREAM is  Event type of this class.
		 */
		//RTCR: Mention use of this variable.
		public static const UNMUTE_VIEWER_STREAM:String="unMuteViewerStream";
		/**
		 *Document page number
		 */		
		public var pageNumber:int;
		/**
		 *Time of current event type dispatching
		 */
		public var time:Number;
		/**
		 *Slide index of Document slides
		 */
		public var currentSlideIndex:uint;
		/**
		 *Video information about Viewer's
		 */
		public var viewerVideoTagArray:Array
		/**
		 *Video information about Presenter's
		 */
		public var presenterVideoTagArray:Array
		/**
		 *Video information about desktopSharing
		 */
		public var desktopVideoTagArray:Array
		
		/**
		 * Constructor
		 * @param type of type String
		 * @param bubbles of type Boolean
		 * @param cancelable of type Boolean
		 *
		 */
		public function AviewPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
	}
}
