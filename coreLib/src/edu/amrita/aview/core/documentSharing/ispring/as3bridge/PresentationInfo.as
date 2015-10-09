package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	
	public class PresentationInfo
	{
		private var m_bridgeConnector:BridgeConnector;
		
		private var m_title:String;
		private var m_duration:Number;
		private var m_slideWidth:Number;
		private var m_slideHeight:Number;
		private var m_hasReferences:Boolean;
		private var m_hasPresenter:Boolean;
		private var m_frameRate:Number;
		
		private var m_presenterInfo:PresenterInfo;
		private var m_referencesCollection:ReferencesCollection;
		private var m_slidesCollection:SlidesCollection;
		
		public function PresentationInfo(internalClass:InternalClass, bridgeConnector:BridgeConnector)
		{
			m_bridgeConnector=bridgeConnector;
			initEventFunctions();
		}
		
		public function get hasPresenter():Boolean
		{
			return m_hasPresenter;
		}
		
		public function get presenterInfo():PresenterInfo
		{
			return m_presenterInfo;
		}
		
		public function get slides():SlidesCollection
		{
			return m_slidesCollection;
		}
		
		public function get references():ReferencesCollection
		{
			return m_referencesCollection;
		}
		
		public function get title():String
		{
			return m_title;
		}
		
		public function get duration():Number
		{
			return m_duration;
		}
		
		public function get slideWidth():Number
		{
			return m_slideWidth;
		}
		
		public function get slideHeight():Number
		{
			return m_slideHeight;
		}
		
		public function get hasReferences():Boolean
		{
			return m_hasReferences;
		}
		
		public function get frameRate():Number
		{
			return m_frameRate;
		}
		
		private function initEventFunctions():void
		{
			m_bridgeConnector.setOnPresentationLoadedCallbackPresentationInfo(this.onPresentationLoaded);
		}
		
		private function onPresentationLoaded(presentationInfo:Object):void
		{
			m_title=presentationInfo.title;
			m_duration=presentationInfo.duration;
			m_slideWidth=presentationInfo.slideWidth;
			m_slideHeight=presentationInfo.slideHeight;
			m_hasReferences=presentationInfo.hasReferences;
			m_hasPresenter=presentationInfo.hasPresenter;
			m_frameRate=presentationInfo.frameRate;
			
			if (m_hasPresenter)
			{
				m_presenterInfo=new PresenterInfo(new InternalClass(), presentationInfo.presenterInfo);
			}
			if (m_hasReferences)
			{
				m_referencesCollection=new ReferencesCollection(new InternalClass(), presentationInfo.referencesCollection);
			}
			m_slidesCollection=new SlidesCollection(new InternalClass(), m_bridgeConnector, presentationInfo.slidesCollection);
		}
	}
}
