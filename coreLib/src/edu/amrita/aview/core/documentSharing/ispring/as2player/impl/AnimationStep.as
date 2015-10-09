
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IAnimationStep;
	
	public class AnimationStep implements IAnimationStep
	{
		private var m_obj:Object;
		
		public function AnimationStep(obj:Object)
		{
			m_obj=obj;
		}
		
		public function get playTime():Number
		{
			return m_obj.playTime;
		}
		
		public function get pauseTime():Number
		{
			return m_obj.pauseTime;
		}
		
		public function get startTime():Number
		{
			return m_obj.startTime;
		}
		
		public function get pauseStartTime():Number
		{
			return m_obj.startTime;
		}
		
		public function get pauseEndTime():Number
		{
			return m_obj.startTime;
		}
	}
}
