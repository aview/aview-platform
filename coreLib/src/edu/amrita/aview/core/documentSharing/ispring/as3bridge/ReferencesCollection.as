package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	
	public class ReferencesCollection
	{
		private var m_references:Array;
		private var m_referencesCount:Number;
		
		public function ReferencesCollection(internalClass:InternalClass, rc:Object)
		{
			m_references=new Array();
			m_referencesCount=rc.referencesCount;
			initReferences(rc.references);
		}
		
		public function getReference(referenceIndex:Number):ReferenceInfo
		{
			return m_references[referenceIndex];
		}
		
		public function get referencesCount():Number
		{
			return m_referencesCount;
		}
		
		private function initReferences(references:Object):void
		{
			for (var i:Number=0; i < m_referencesCount; i++)
			{
				m_references[i]=new ReferenceInfo(new InternalClass(), references["reference" + i]);
			}
		}
	}
}
