
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.Event;
	
	public class PlaybackPositionEvent extends PlaybackEvent
	{
		public static const SLIDE_POSITION_CHANGED:String="slidePositionChanged";
		private var m_position:Number;
		public function PlaybackPositionEvent(type:String, position:Number=0){
			super(type);
			m_position=position;
		}
		public function get position():Number{
			return m_position;
		}
		public override function clone():Event{
			return new PlaybackPositionEvent(type, position);
		}
	}
}
