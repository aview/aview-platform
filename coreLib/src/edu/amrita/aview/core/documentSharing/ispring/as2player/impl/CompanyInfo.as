
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ICompanyInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ICompanyLogo;
	
	public class CompanyInfo implements ICompanyInfo
	{
		private var m_obj:Object;
		private var m_logo:ICompanyLogo;
		
		public function CompanyInfo(obj:Object)
		{
			m_obj=obj;
		}
		
		public function hasLogo():Boolean
		{
			return m_obj.hasLogo;
		}
		
		public function get logo():ICompanyLogo
		{
			if (!m_logo && m_obj.logo)
			{
				m_logo=new CompanyLogo(m_obj.logo);
			}
			return m_logo;
		}
	}
}
