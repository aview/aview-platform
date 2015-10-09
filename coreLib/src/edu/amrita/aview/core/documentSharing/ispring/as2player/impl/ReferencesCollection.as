
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IReferencesCollection;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IReferenceInfo;
	
	public class ReferencesCollection implements IReferencesCollection
	{
		private var m_obj:Object;
		private var m_references:Array;
		
		public function ReferencesCollection(obj:Object)
		{
			m_obj=obj;
			m_references=new Array();
		}
		
		public function get count():Number
		{
			return m_obj.count;
		}
		
		public function getReference(index:Number):IReferenceInfo
		{
			if (!m_references[index] && m_obj.references && m_obj.references[index])
			{
				m_references[index]=new ReferenceInfo(m_obj.references[index])
			}
			return m_references[index];
		}
	}
}
