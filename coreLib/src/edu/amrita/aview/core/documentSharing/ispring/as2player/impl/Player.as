
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import flash.events.EventDispatcher;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPlayer;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationPlaybackController;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISoundController;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.PlayerEvent;
	
	public class Player extends EventDispatcher implements IPlayer
	{
		private var m_connection:Connection;
		private var m_initialized:Boolean=false;
		private var m_pc:IPresentationPlaybackController;
		private var m_sc:ISoundController;
		private var m_settings:Object;
		private var m_pi:IPresentationInfo;
		private var m_obj:Object;
		private var m_info:String="";
		
		public function Player(connection:Connection)
		{
			m_connection=connection;
			m_connection.addEventListener(ConnectionEvent.PLAYER_INIT, playerInit);
			m_connection.addEventListener(ConnectionEvent.INFO, info);
		}
		
		public function get initialized():Boolean
		{
			return m_initialized;
		}
		
		public function get playbackController():IPresentationPlaybackController
		{
			return m_pc;
		}
		
		public function get soundController():ISoundController
		{
			return m_sc;
		}
		
		public function get settings():Object
		{
			return m_settings;
		}
		
		public function get presentationInfo():IPresentationInfo
		{
			return m_pi;
		}
		
		private function playerInit(e:ConnectionEvent):void
		{
			m_connection.addEventListener(ConnectionEvent.SLIDE_LOADING_COMPLETE, slideLoadingComplete);
			m_obj=stringToObject(m_info);
			m_pi=new PresentationInfo(m_obj.presentationInfo);
			m_pc=new PresentationPlaybackController(m_connection, m_obj.playbackController, m_pi.slides);
			m_sc=new SoundController(m_connection, m_obj.soundController);
			m_settings=m_obj.settings;
			
			initSlides(m_obj.presentationInfo.slides);
			
			m_initialized=true;
			dispatchEvent(new PlayerEvent(PlayerEvent.PLAYER_INIT));
		}
		
		private function initSlides(slidesObj:Object):void
		{
			initSlidesNormal(slidesObj);
			initSlidesVisible(slidesObj);
		}
		
		private function initSlidesNormal(slidesObj:Object):void
		{
			for (var index:Number=0; index < slidesObj.slidesCount; ++index)
			{
				var slideObj:Object=slidesObj.slidesInfo[index];
				slideObj.index=index;
			}
		}
		
		private function initSlidesVisible(slidesObj:Object):void
		{
			for (var visibleIndex:Number=0; visibleIndex < slidesObj.visibleSlidesCount; ++visibleIndex)
			{
				var index:Number=slidesObj.visibleSlides[visibleIndex];
				var slideObjVisible:Object=slidesObj.slidesInfo[index];
				slideObjVisible.visibleIndex=visibleIndex;
			}
		}
		
		private function slideLoadingComplete(e:ConnectionEvent):void
		{
			var index:Number=Number(e.parameter);
			var slideObj:Object=m_obj.presentationInfo.slides.slidesInfo[index];
			slideObj.loaded=true;
		}
		
		private function info(e:ConnectionEvent):void
		{
			m_info+=e.parameter;
		}
		
		// deserialization
		private function stringToObject(str:String):Object
		{
			var xml:XMLDocument=new XMLDocument(str);
			return xmlNodeToObject(xml.childNodes[0]);
		}
		
		private function xmlNodeToObject(node:XMLNode):Object
		{
			var name:String=node.nodeName;
			if (name == "o")
			{
				var childNodes:Array=node.childNodes;
				var obj:Object=new Object();
				for (var i:Number=0; i < childNodes.length; ++i)
				{
					var childNode:XMLNode=childNodes[i];
					obj[childNode.attributes.n]=xmlNodeToObject(childNode);
				}
			}
			else if (name == "t")
			{
				obj=true;
			}
			else if (name == "f")
			{
				obj=false;
			}
			else if (name == "l")
			{
				obj=null;
			}
			else if (name == "u")
			{
				obj=undefined;
			}
			else if (name == "n")
			{
				obj=Number(node.attributes.v);
			}
			else if (name == "s")
			{
				obj=String(node.attributes.v);
			}
			return obj;
		}
	}
}
