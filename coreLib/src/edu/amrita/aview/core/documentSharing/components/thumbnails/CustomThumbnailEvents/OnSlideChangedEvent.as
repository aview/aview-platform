package edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents
{
	import flash.events.Event;
	
	public class OnSlideChangedEvent extends Event
	{
		private var _index:Number;
		
		public function get index():Number
		{
			return _index;
		}
		
		public function OnSlideChangedEvent(value:Number)
		{
			super("OnSlideChangedEvent");
			_index=value;
		}
		
		override public function clone():Event
		{
			return new OnSlideChangedEvent(index);
		}
	}
}
