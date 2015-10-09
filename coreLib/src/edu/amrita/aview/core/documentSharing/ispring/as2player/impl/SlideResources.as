
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlideResources;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresenterVideo;
	
	public class SlideResources implements ISlideResources
	{
		private var m_obj:Object;
		private var m_presenterVideo:IPresenterVideo;
		
		public function SlideResources(obj:Object)
		{
			m_obj=obj;
		}
		
		public function hasPresenterVideo():Boolean
		{
			return m_obj.hasPresenterVideo;
		}
		
		public function get presenterVideo():IPresenterVideo
		{
			if (!m_presenterVideo && m_obj.presenterVideo)
			{
				m_presenterVideo=new PresenterVideo(m_obj.presenterVideo);
			}
			return m_presenterVideo;
		}
	}
}
