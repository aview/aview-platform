package edu.amrita.aview.questions.events
{
	import flash.events.Event;
	
	public class QuestionInteractionEvent extends Event
	{
		/**
		 * Event type used to notify that break session has started
		 */
		public static const QUESTIONS_ALLOWED_TYPE:String="QUESTIONS_ALLOWED_TYPE";
		/**
		 * Event type used to notify that break session has ended
		 */
		public static const QUESTIONS_DISALLOWED_TYPE:String="QUESTIONS_DISALLOWED_TYPE";

		public function QuestionInteractionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}