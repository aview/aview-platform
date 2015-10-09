
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.Event;
	
	public class StepPlaybackEvent extends PlaybackEvent
	{
		public static const ANIMATION_STEP_CHANGED:String="animationStepChanged";
		
		private var m_stepIndex:Number;
		
		public function StepPlaybackEvent(type:String, stepIndex:Number=0)
		{
			super(type);
			m_stepIndex=stepIndex;
		}
		
		public function get stepIndex():Number{
			return m_stepIndex;
		}
		
		public override function clone():Event{
			return new StepPlaybackEvent(type, stepIndex);
		}
	}
}
