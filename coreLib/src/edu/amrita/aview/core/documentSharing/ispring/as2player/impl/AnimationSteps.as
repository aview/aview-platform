
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IAnimationSteps;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IAnimationStep;
	
	public class AnimationSteps implements IAnimationSteps
	{
		private var m_obj:Object;
		private var m_steps:Array;
		
		public function AnimationSteps(obj:Object)
		{
			m_obj=obj;
			m_steps=new Array();
		}
		
		public function get stepsCount():Number
		{
			return m_obj.stepsCount;
		}
		
		public function get duration():Number
		{
			return m_obj.duration;
		}
		
		public function getStep(index:Number):IAnimationStep
		{
			if (!m_steps[index] && m_obj.steps && m_obj.steps[index])
			{
				m_steps[index]=new AnimationStep(m_obj.steps[index]);
			}
			return m_steps[index];
		}
	}
}
