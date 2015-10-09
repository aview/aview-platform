package edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents
{
	import flash.events.Event;
	
	
	public class OnSlideClickEvent extends Event
	{
		private var _slideobject:Object;
		
		public function get slideobject():Object
		{
			return _slideobject;
		}
		
		public function OnSlideClickEvent(index:Object)
		{
			super("OnSlideClickEvent");
			_slideobject=index;
		}
		
		override public function clone():Event
		{
			return new OnSlideClickEvent(slideobject);
		}
	}
}
