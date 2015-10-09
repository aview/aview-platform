
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlideInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IAnimationSteps;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlideResources;
	
	public class SlideInfo implements ISlideInfo
	{
		private var m_obj:Object;
		private var m_steps:IAnimationSteps;
		private var m_resources:ISlideResources;
		
		public function SlideInfo(obj:Object)
		{
			m_obj=obj;
		}
		
		public function get loaded():Boolean
		{
			return m_obj.loaded;
		}
		
		public function get title():String
		{
			return m_obj.title;
		}
		
		public function get animationSteps():IAnimationSteps
		{
			if (!m_steps && m_obj.animationSteps)
			{
				m_steps=new AnimationSteps(m_obj.animationSteps);
			}
			return m_steps;
		}
		
		public function get duration():Number
		{
			//return m_obj.duration;
			return endTime - startTime;
		}
		
		public function get notesText():String
		{
			return m_obj.notesText;
		}
		
		public function get startTime():Number
		{
			return m_obj.startTime;
		}
		
		public function get endTime():Number
		{
			return m_obj.endTime;
		}
		
		public function get startStepIndex():Number
		{
			return m_obj.startStepIndex;
		}
		
		public function get endStepIndex():Number
		{
			return m_obj.endStepIndex;
		}
		
		public function get slideText():String
		{
			return m_obj.slideText;
		}
		
		public function get notesTextNormalized():String
		{
			return m_obj.notesTextNormalized;
		}
		
		public function get titleNormalized():String
		{
			return m_obj.titleNormalized;
		}
		
		public function get level():Number
		{
			return m_obj.level;
		}
		
		public function get hidden():Boolean
		{
			return m_obj.hidden;
		}
		
		public function get index():Number
		{
			return m_obj.index;
		}
		
		public function get visibleIndex():Number
		{
			return m_obj.visibleIndex;
		}
		
		public function get visibleStartTime():Number
		{
			return m_obj.visibleStartTime;
		}
		
		public function get visibleEndTime():Number
		{
			return m_obj.visibleEndTime;
		}
		
		public function get visibleStartStepIndex():Number
		{
			return m_obj.visibleStartStepIndex;
		}
		
		public function get visibleEndStepIndex():Number
		{
			return m_obj.visibleEndStepIndex;
		}
		
		public function get presenterIndex():Number
		{
			return m_obj.presenterIndex;
		}
		
		public function get resources():ISlideResources
		{
			if (!m_resources && m_obj.resources)
			{
				m_resources=new SlideResources(m_obj.resources);
			}
			return m_resources;
		}
	}
}
