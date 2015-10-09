
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresenterVideo;
	
	public class PresenterVideo implements IPresenterVideo
	{
		private var m_obj:Object;
		
		public function PresenterVideo(obj:Object)
		{
			m_obj=obj;
		}
		
		public function get width():Number
		{
			return m_obj.width;
		}
		
		public function get height():Number
		{
			return m_obj.height;
		}
	}
}
