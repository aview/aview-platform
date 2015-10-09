package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	
	public class SlidesCollection
	{
		private var m_bridgeConnector:BridgeConnector;
		
		private var m_slides:Array;
		private var m_slidesCount:Number;
		
		public function SlidesCollection(internalClass:InternalClass, bridgeConnector:BridgeConnector, sc:Object)
		{
			m_slides=new Array();
			m_bridgeConnector=bridgeConnector;
			m_slidesCount=sc.slidesCount;
			initSlides(sc.slides);
			initEventFunctions();
		}
		
		public function get slidesCount():Number
		{
			return m_slidesCount;
		}
		
		public function getSlideInfo(slideIndex:Number):SlideInfo
		{
			return m_slides[slideIndex];
		}
		
		private function onSlideMetadataLoad(slideIndex:Number, slideInfo:Object):void
		{
			m_slides[slideIndex].setMetadata(new InternalClass(), slideInfo);
		}
		
		private function onSlideLoadingComplete(slideIndex:Number):void
		{
			m_slides[slideIndex].loadingComplete(new InternalClass());
		}
		
		private function initEventFunctions():void
		{
			m_bridgeConnector.setOnSlideMetadataLoadCallback(this.onSlideMetadataLoad);
			m_bridgeConnector.setOnSlideLoadingCompleteSlidesCollection(this.onSlideLoadingComplete);
		}
		
		private function initSlides(slidesInfo:Object):void
		{
			for (var i:Number=0; i < m_slidesCount; i++)
			{
				m_slides[i]=new SlideInfo(new InternalClass(), m_bridgeConnector, i, slidesInfo["slide" + i]);
			}
		}
	}
}
