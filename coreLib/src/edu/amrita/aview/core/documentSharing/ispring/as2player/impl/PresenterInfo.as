
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresenterInfo;
	
	public class PresenterInfo implements IPresenterInfo
	{
		private var m_obj:Object;
		
		public function PresenterInfo(obj:Object)
		{
			m_obj=obj;
		}
		
		public function get name():String
		{
			return m_obj.name;
		}
		
		public function get title():String
		{
			return m_obj.title;
		}
		
		public function get biographyText():String
		{
			return m_obj.biographyText;
		}
		
		public function get email():String
		{
			return m_obj.email;
		}
		
		public function get webSite():String
		{
			return m_obj.webSite;
		}
		
		public function hasPhoto():Boolean
		{
			return m_obj.hasPhoto;
		}
		
		public function get index():Number
		{
			return m_obj.index;
		}
	}
}
