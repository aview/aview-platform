
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.Event;
	
	public class SlidePlaybackEvent extends PlaybackEvent
	{
		public static const CURRENT_SLIDE_INDEX_CHANGED:String="currentSlideIndexChanged";
		public static const SLIDE_LOADING_COMPLETE:String="slideLoadingComplete";
		
		private var m_slideIndex:Number;
		
		public function SlidePlaybackEvent(type:String, slideIndex:Number=0){
			super(type);
			m_slideIndex=slideIndex;
		}
		
		public function get slideIndex():Number{
			return m_slideIndex;
		}
		
		public override function clone():Event{
			return new SlidePlaybackEvent(type, slideIndex);
		}
	}
}
