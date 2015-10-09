
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import flash.events.EventDispatcher;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISoundController;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.SoundEvent;
	
	public class SoundController extends EventDispatcher implements ISoundController
	{
		private var m_connection:Connection;
		
		private var m_volume:Number;
		
		public function SoundController(connection:Connection, obj:Object)
		{
			m_connection=connection;
			
			m_volume=obj.volume;
			
			m_connection.addEventListener(ConnectionEvent.SOUND_VOLUME_CHANGED, soundVolumeChanged);
		}
		
		public function get volume():Number
		{
			return m_volume;
		}
		
		public function set volume(value:Number):void
		{
			m_connection.setVolume(value);
		}
		
		private function soundVolumeChanged(e:ConnectionEvent):void
		{
			dispatchEvent(new SoundEvent(SoundEvent.SOUND_VOLUME_CHANGED, Number(e.parameter)));
		}
	}
}
