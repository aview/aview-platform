
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.Event;
	
	public class AcquireFocusEvent extends PlaybackEvent
	{
		public static const KEYBOARD_FOCUS_STATE_CHANGED:String="keyboardFocusStateChanged";
		private var m_acquireFocus:Boolean;
		
		public function AcquireFocusEvent(type:String, acquireFocus:Boolean=false){
			super(type);
			m_acquireFocus=acquireFocus;
		}
		
		public function get acquireFocus():Boolean{
			return m_acquireFocus;
		}
		public override function clone():Event{
			return new AcquireFocusEvent(type, acquireFocus);
		}
	}
}
