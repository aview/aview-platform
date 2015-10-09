package edu.amrita.aview.core.documentSharing.ispring.flex
{
	import flash.display.Sprite;
	import flash.net.URLRequest;
	
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPlayer;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.PlayerEvent;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.PresentationLoader;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	public class PresentationContainer extends UIComponent
	{
		private var m_presentationLoader:PresentationLoader;
		protected var m_container:Sprite;
		private var m_player:IPlayer;
		private var m_adjustSizeToBorders:Boolean=false;
		
		public function PresentationContainer()
		{
			super();
			m_container=new Sprite;
			addChild(m_container);
			m_container.visible=false;
			
			m_presentationLoader=new PresentationLoader;
			m_container.addChild(m_presentationLoader);
			
			m_presentationLoader.addEventListener(PlayerEvent.PLAYER_INIT, onPlayerInit);
			
			addEventListener(ResizeEvent.RESIZE, onResize);
		}
		
		public function set adjustSizeToBorders(v:Boolean):void
		{
			m_adjustSizeToBorders=v;
		}
		
		public function get adjustSizeToBorders():Boolean
		{
			return m_adjustSizeToBorders;
		}
		
		public function load(presentationUrl:String):void
		{
			var request:URLRequest=new URLRequest(presentationUrl);
			m_presentationLoader.load(request);
		}
		
		public function unload():void
		{
			m_container.visible=false;
			m_presentationLoader.unload();
			m_player=null;
		}
		
		private function onResize(e:ResizeEvent):void
		{
			if (m_player)
			{
				rescaleContainer();
			}
		}
		
		private function onPlayerInit(e:PlayerEvent):void
		{
			m_player=m_presentationLoader.player;
			rescaleContainer();
			m_container.visible=true;
			
			dispatchEvent(new PlayerInitEvent(PlayerInitEvent.PLAYER_INIT, m_player));
		}
		
		protected function rescaleContainer():void
		{
			if (!m_player)
				return;
			
			var slideWidth:int=m_player.presentationInfo.slideWidth;
			var slideHeight:int=m_player.presentationInfo.slideHeight;
			
			if (m_adjustSizeToBorders)
			{
				m_container.x=0;
				m_container.y=0;
				
				m_container.scaleX=width / slideWidth;
				m_container.scaleY=height / slideHeight;
			}
			else
			{
				var presentationAspectRatio:Number=slideWidth / slideHeight;
				var componentAspectRatio:Number=width / height;
				
				if (componentAspectRatio > presentationAspectRatio)
				{
					m_container.scaleY=height / slideHeight;
					m_container.scaleX=m_container.scaleY;
				}
				else
				{
					m_container.scaleX=width / slideWidth;
					m_container.scaleY=m_container.scaleX;
				}
				
				m_container.x=width / 2 - (slideWidth * m_container.scaleX) / 2;
				m_container.y=height / 2 - (slideHeight * m_container.scaleY) / 2;
			}
		}
	}
}
