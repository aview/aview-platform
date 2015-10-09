
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlideInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlidesCollection;
	
	public class SlidesCollection implements ISlidesCollection
	{
		private var m_obj:Object;
		private var m_slides:Array;
		private var m_visibleSlides:Array;
		
		public function SlidesCollection(obj:Object)
		{
			m_obj=obj;
			m_slides=new Array();
			m_visibleSlides=new Array();
		}
		
		public function get slidesCount():Number
		{
			return m_obj.slidesCount;
		}
		
		public function getSlideInfo(slideIndex:Number):ISlideInfo
		{
			if (!m_slides[slideIndex] && m_obj.slidesInfo && m_obj.slidesInfo[slideIndex])
			{
				m_slides[slideIndex]=new SlideInfo(m_obj.slidesInfo[slideIndex]);
			}
			return m_slides[slideIndex];
		}
		
		public function get visibleSlidesCount():Number
		{
			return m_obj.visibleSlidesCount;
		}
		
		public function getVisibleSlide(visibleSlideIndex:Number):ISlideInfo
		{
			if (m_obj && m_obj.visibleSlides && m_obj.visibleSlides[visibleSlideIndex] != null)
			{
				return getSlideInfo(m_obj.visibleSlides[visibleSlideIndex]);
			}
			return null;
		}
	}
}
