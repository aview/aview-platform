package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.LoaderInfo;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	
	public class Player extends EventDispatcher
	{
		private var m_target:DisplayObjectContainer;
		private var m_bridgeConnector:BridgeConnector;
		private var m_playbackController:PlaybackController;
		private var m_soundController:SoundController;
		private var m_presentationInfo:PresentationInfo;
		private var m_initialized:Boolean=false;
		private var m_bridgeLoader:Loader;
		private var m_log:LogConsole;
		
		public function Player(internalClass:InternalClass, target:DisplayObjectContainer)
		{
			m_log=LogConsole.getInstance();
			m_target=target;
			initBridgeLoader();
		}
		
		public function connectToBridge(bridgeURL:String, commandConnectionName:String="", eventConnectionName:String=""):void
		{
			if (m_bridgeConnector != null)
				return;
			
			m_log.writeLine("ConnectToBridge: " + bridgeURL);
			if (commandConnectionName == "")
				commandConnectionName=getConnectionName("command");
			if (eventConnectionName == "")
				eventConnectionName=getConnectionName("event");
			
			var bridgeRequest:URLRequest=new URLRequest(bridgeURL);
			
			var bridgeVariables:URLVariables=new URLVariables();
			bridgeVariables.commandConnectionName=commandConnectionName;
			bridgeVariables.eventConnectionName=eventConnectionName;
			bridgeRequest.data=bridgeVariables;
			
			m_bridgeConnector=new BridgeConnector(eventConnectionName, commandConnectionName);
			initEventFunctions();
			m_playbackController=new PlaybackController(new InternalClass(), m_bridgeConnector);
			m_soundController=new SoundController(new InternalClass(), m_bridgeConnector);
			m_presentationInfo=new PresentationInfo(new InternalClass(), m_bridgeConnector);
			
			m_bridgeLoader.load(bridgeRequest);
		}
		
		public function get playbackController():PlaybackController
		{
			if (!m_initialized)
			{
				return null;
			}
			return m_playbackController;
		}
		
		public function get soundController():SoundController
		{
			if (!m_initialized)
			{
				return null;
			}
			return m_soundController;
		}
		
		public function get presentationInfo():PresentationInfo
		{
			if (!m_initialized)
			{
				return null;
			}
			return m_presentationInfo;
		}
		
		public function get initialized():Boolean
		{
			return m_initialized;
		}
		
		public function loadMovie(internalClass:InternalClass, presentationURL:String):void // internal method
		{
			m_bridgeConnector.sendCommand("loadPresentation", presentationURL);
			m_initialized=false;
		}
		
		private function initBridgeLoader():void
		{
			m_bridgeLoader=new Loader();
			m_target.addChild(m_bridgeLoader);
			
			var bridgeLoaderInfo:LoaderInfo=m_bridgeLoader.contentLoaderInfo;
			bridgeLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBridgeLoaderError);
		}
		
		private function onPresentationLoaded(succeeded:Boolean):void
		{
			m_log.writeLine(succeeded ? "onPresentationLoaded: successed" : "onPresentationLoaded: unsuccessed");
			m_initialized=succeeded;
			
			if (succeeded)
				m_soundController.volume=m_soundController.volume;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.PRESENTATION_LOADED);
			e.succeeded=succeeded;
			e.player=this;
			dispatchEvent(e);
		}
		
		private function getConnectionName(type:String):String
		{
			var date:Date=new Date();
			
			switch (type)
			{
				case "command":
					return "cmd_" + date.getTime() + "_" + getTimer();
				case "event":
					return "evt_" + date.getTime() + "_" + getTimer();
			}
			
			return "";
		}
		
		private function initEventFunctions():void
		{
			m_bridgeConnector.setOnPresentationLoadedCallbackPlayer(this.onPresentationLoaded);
			m_bridgeConnector.setOnBridgeLoadedCallback(this.onBridgeLoaded);
		}
		
		private function onBridgeLoaded():void
		{
			dispatchEvent(new BridgeEvent(BridgeEvent.BRIDGE_LOADED));
		}
		
		private function onBridgeLoaderError(e:IOErrorEvent):void
		{
			m_log.writeLine("onBridgeLoaderError: " + e.type);
			onPresentationLoaded(false);
		}
	}
}
