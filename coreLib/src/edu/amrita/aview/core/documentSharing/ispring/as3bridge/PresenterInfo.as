package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	
	public class PresenterInfo
	{
		private var m_name:String;
		private var m_title:String;
		private var m_biographyText:String;
		private var m_email:String;
		private var m_webSite:String;
		
		public function PresenterInfo(internalClass:InternalClass, pi:Object)
		{
			m_name=pi.name;
			m_title=pi.title;
			m_biographyText=pi.biographyText;
			m_email=pi.email;
			m_webSite=pi.webSite;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		public function get title():String
		{
			return m_title;
		}
		
		public function get biographyText():String
		{
			return m_biographyText;
		}
		
		public function get email():String
		{
			return m_email;
		}
		
		public function get webSite():String
		{
			return m_webSite;
		}
	}
}
