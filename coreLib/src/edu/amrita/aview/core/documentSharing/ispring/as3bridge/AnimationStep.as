package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	
	public class AnimationStep
	{
		private var m_playTime:Number;
		private var m_pauseTime:Number;
		private var m_startTime:Number;
		private var m_pauseStartTime:Number;
		private var m_pauseEndTime:Number;
		
		public function AnimationStep(internalClass:InternalClass, stepInfo:Object)
		{
			m_playTime=stepInfo.playTime;
			m_pauseTime=stepInfo.pauseTime;
			m_startTime=stepInfo.startTime;
			m_pauseStartTime=stepInfo.pauseStartTime;
			m_pauseEndTime=stepInfo.pauseEndTime;
		}
		
		public function get playTime():Number
		{
			return m_playTime;
		}
		
		public function get pauseTime():Number
		{
			return m_pauseTime;
		}
		
		public function get startTime():Number
		{
			return m_startTime;
		}
		
		public function get pauseStartTime():Number
		{
			return m_pauseStartTime;
		}
		
		public function get pauseEndTime():Number
		{
			return m_pauseEndTime;
		}
	}
}
