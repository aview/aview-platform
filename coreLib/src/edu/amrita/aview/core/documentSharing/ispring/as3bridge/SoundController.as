package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	import flash.events.EventDispatcher;
	
	public class SoundController extends EventDispatcher
	{
		private var m_bridgeConnector:BridgeConnector;
		
		private var m_volume:Number=1;
		
		public function SoundController(internalClass:InternalClass, bridgeConnector:BridgeConnector)
		{
			m_bridgeConnector=bridgeConnector;
			initEventFunctions();
		}
		
		public function get volume():Number
		{
			return m_volume;
		}
		
		public function set volume(v:Number):void
		{
			m_bridgeConnector.sendCommand("setVolume", v);
		}
		
		private function initEventFunctions():void
		{
			m_bridgeConnector.setOnSoundVolumeChangedCallback(this.onSoundVolumeChanged);
			m_bridgeConnector.setOnVolumeChangingCompleteCallback(this.onVolumeChangingComplete);
		}
		
		private function onVolumeChangingComplete():void
		{
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.VOLUME_CHANGING_COMPLETE);
			e.volume=m_volume;
			e.soundController=this;
			dispatchEvent(e);
		}
		
		private function onSoundVolumeChanged(volume:Number):void
		{
			m_volume=volume;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.VOLUME_CHANGE);
			e.volume=volume;
			e.soundController=this;
			dispatchEvent(e);
		}
	}
}
