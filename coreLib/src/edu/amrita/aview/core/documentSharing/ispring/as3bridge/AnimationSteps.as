package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	
	public class AnimationSteps
	{
		private var m_steps:Array;
		private var m_stepsCount:Number;
		private var m_duration:Number;
		
		public function AnimationSteps(internalClass:InternalClass, animationSteps:Object)
		{
			m_steps=new Array();
			m_duration=animationSteps.duration;
			m_stepsCount=animationSteps.stepsCount;
			initSteps(animationSteps.steps);
		}
		
		public function get duration():Number
		{
			return m_duration;
		}
		
		public function get stepsCount():Number
		{
			return m_stepsCount;
		}
		
		public function getStep(stepIndex:Number):AnimationStep
		{
			return m_steps[stepIndex];
		}
		
		private function initSteps(stepsInfo:Object):void
		{
			for (var i:Number=0; i < m_stepsCount; i++)
			{
				m_steps[i]=new AnimationStep(new InternalClass(), stepsInfo["step" + i]);
			}
		}
	}
}
