
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.impl.Connection;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.impl.Player;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.getTimer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class PresentationLoader extends Sprite
	{
		private static var m_nameIndex:Number=0;
		
		private var m_loader:Loader;
		private var m_commandConnectionName:String;
		private var m_eventConnectionName:String;
		private var m_player:Player;
		private var m_connection:Connection;
		
		/**
		 * For Error log
		 */
		private var log:ILogger=Log.getLogger("aview.documentSharing.ispring.as2player.PresentationLoader.as");
		
		public function PresentationLoader()
		{
			m_loader=new Loader();
			addChild(m_loader);
			m_loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
		}
		
		public function load(request:URLRequest, securityDomain:SecurityDomain=null):void{
			unload();
			
			m_commandConnectionName=null;
			m_eventConnectionName=null;
			
			var loaderContext:LoaderContext=new LoaderContext(false, null, securityDomain);
			
			var vars:URLVariables=URLVariables(request.data);
			
			if (vars == null){
				vars=new URLVariables();
				request.data=vars;
			}
			
			vars.commandConnectionName=commandConnectionName;
			vars.eventConnectionName=eventConnectionName;
			
			m_loader.load(request, loaderContext);
		}
		
		public function unload():void
		{
			if (m_player){
				m_player.removeEventListener(PlayerEvent.PLAYER_INIT, playerInit);
				m_player=null;
			}
			
			if (m_connection){
				try
				{
					m_connection.close();
				}
				catch (e:ArgumentError)	
				{
					if(Log.isError()) log.error("Error in unload method:"+ e.getStackTrace());
				}
				m_connection=null;
			}
			
			m_loader.unload();
		}
		
		public function close():void{
			m_loader.close();
		}
		
		public function get content():DisplayObject{
			return m_loader.content;
		}
		
		public function get contentLoaderInfo():LoaderInfo{
			return m_loader.contentLoaderInfo;
		}
		
		public function get player():IPlayer{
			return m_player;
		}
		
		private function get commandConnectionName():String
		{
			if (m_commandConnectionName == null)
			{
				m_commandConnectionName="_ispring_cmd" + flash.utils.getTimer() + "_" + (m_nameIndex++);
			}
			return m_commandConnectionName;
		
		}
		
		private function get eventConnectionName():String{
			if (m_eventConnectionName == null)
			{
				m_eventConnectionName="_ispring_evt" + flash.utils.getTimer() + "_" + (m_nameIndex++);
			}
			return m_eventConnectionName;
		}
		
		private function onInit(e:Event):void
		{
			m_connection=new Connection(commandConnectionName, eventConnectionName);
			m_player=new Player(m_connection);
			m_player.addEventListener(PlayerEvent.PLAYER_INIT, playerInit);
		}
		
		private function playerInit(e:PlayerEvent):void
		{
			dispatchEvent(e);
		}
	}
}
