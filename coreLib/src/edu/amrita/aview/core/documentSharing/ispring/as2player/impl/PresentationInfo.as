
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlidesCollection;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresenterInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ICompanyInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IReferencesCollection;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentersCollection;
	
	public class PresentationInfo implements IPresentationInfo
	{
		private var m_obj:Object;
		private var m_slidesCollection:ISlidesCollection;
		private var m_presenterInfo:IPresenterInfo;
		private var m_referencesCollection:IReferencesCollection;
		private var m_companyInfo:ICompanyInfo;
		private var m_presenters:IPresentersCollection;
		
		public function PresentationInfo(obj:Object)
		{
			m_obj=obj;
		}
		
		public function get title():String
		{
			return m_obj.title;
		}
		
		public function get slides():ISlidesCollection
		{
			if (!m_slidesCollection && m_obj.slides)
			{
				m_slidesCollection=new SlidesCollection(m_obj.slides);
			}
			return m_slidesCollection;
		}
		
		public function get slideWidth():Number
		{
			return m_obj.slideWidth;
		}
		
		public function get slideHeight():Number
		{
			return m_obj.slideHeight;
		}
		
		public function hasPresenter():Boolean
		{
			return m_obj.hasPresenter;
		}
		
		public function get presenterInfo():IPresenterInfo
		{
			if (!m_presenterInfo && m_obj.presenterInfo)
			{
				m_presenterInfo=new PresenterInfo(m_obj.presenterInfo);
			}
			return m_presenterInfo;
		}
		
		public function get frameRate():Number
		{
			return m_obj.frameRate;
		}
		
		public function get duration():Number
		{
			return m_obj.duration;
		}
		
		public function hasCompanyInfo():Boolean
		{
			return m_obj.hasCompanyInfo;
		}
		
		public function get companyInfo():ICompanyInfo
		{
			if (!m_companyInfo && m_obj.companyInfo)
			{
				m_companyInfo=new CompanyInfo(m_obj.companyInfo);
			}
			return m_companyInfo;
		}
		
		public function hasReferences():Boolean
		{
			return m_obj.hasReferences;
		}
		
		public function get references():IReferencesCollection
		{
			if (!m_referencesCollection && m_obj.references)
			{
				m_referencesCollection=new ReferencesCollection(m_obj.references);
			}
			return m_referencesCollection;
		}
		
		public function get visibleDuration():Number
		{
			return m_obj.visibleDuration;
		}
		
		public function get presenters():IPresentersCollection
		{
			if (!m_presenters && m_obj.presenters)
			{
				m_presenters=new PresentersCollection(m_obj.presenters);
			}
			return m_presenters;
		}
	}
}
