package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	import flash.events.EventDispatcher;
	import flash.display.DisplayObjectContainer;
	
	public class BridgeLoader extends EventDispatcher
	{
		public static const BRIDGE_LOADED:String="bridgeLoaded";
		
		private var m_target:DisplayObjectContainer;
		private var m_player:Player;
		private var m_log:LogConsole;
		
		public function BridgeLoader(target:DisplayObjectContainer)
		{
			m_log=LogConsole.getInstance();
			m_target=target;
			
			m_player=new Player(new InternalClass(), m_target);
			m_player.addEventListener(BridgeEvent.BRIDGE_LOADED, onBridgeLoaded);
			m_player.addEventListener(BridgeEvent.PRESENTATION_LOADED, onPresentationLoaded);
		}
		
		public function connectToBridge(bridgeURL:String, commandConnectionName:String="", eventConnectionName:String=""):void
		{
			m_player.connectToBridge(bridgeURL, commandConnectionName, eventConnectionName);
		}
		
		public function loadPresentation(presentationURL:String):Player
		{
			m_player.loadMovie(new InternalClass(), presentationURL);
			return m_player;
		}
		
		private function onPresentationLoaded(e:BridgeEvent):void
		{
			var sendEvent:BridgeEvent=new BridgeEvent(e.type);
			sendEvent.player=e.player;
			sendEvent.succeeded=e.succeeded
			dispatchEvent(sendEvent);
		}
		
		private function onBridgeLoaded(e:BridgeEvent):void
		{
			dispatchEvent(new BridgeEvent(BridgeEvent.BRIDGE_LOADED));
		}
	}
}
