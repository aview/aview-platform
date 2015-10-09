
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IReferenceInfo;
	
	public class ReferenceInfo implements IReferenceInfo
	{
		private var m_obj:Object;
		
		public function ReferenceInfo(obj:Object)
		{
			m_obj=obj;
		}
		
		public function get title():String
		{
			return m_obj.title;
		}
		
		public function get url():String
		{
			return m_obj.url;
		}
		
		public function get target():String
		{
			return m_obj.target;
		}
	}
}
