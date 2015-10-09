package edu.amrita.aview.playback.oldPlayback.Print2Flash
{
	import flash.events.Event;
	
	public class PageLoadedEvent extends Event
	{
		private var _page:Number;
		
		public function get page():Number
		{
			return _page;
		}
		
		public function PageLoadedEvent(page:Number)
		{
			super("onPageLoaded");
			_page=page;
		}
		
		override public function clone():Event
		{
			return new PageLoadedEvent(page);
		}
	}
}
