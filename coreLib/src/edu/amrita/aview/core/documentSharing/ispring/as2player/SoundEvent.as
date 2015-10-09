
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.Event;
	
	public class SoundEvent extends Event
	{
		public static const SOUND_VOLUME_CHANGED:String="soundVolumeChanged";
		
		private var m_volume:Number;
		
		public function SoundEvent(type:String, volume:Number=0){
			super(type);
			m_volume=volume;
		}
		
		public function get volume():Number{
			return m_volume;
		}
		
		public override function clone():Event{
			return new SoundEvent(type, volume);
		}
	}
}
