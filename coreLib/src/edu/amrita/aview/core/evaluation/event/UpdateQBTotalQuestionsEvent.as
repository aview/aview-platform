package edu.amrita.aview.core.evaluation.event
{
	import flash.events.Event;
	
	public class UpdateQBTotalQuestionsEvent extends Event
	{
		public var totalQns:int = 0 ;	
		public static const QB_TOTAL_QNS:String = "QBTotalQns";
		public function UpdateQBTotalQuestionsEvent(type:String , numQns:int)
		{
			super(type);
			this.totalQns = numQns ;	
		}
		override public function clone():Event 
		{
			return new UpdateQBTotalQuestionsEvent(type, totalQns);
		}
	}
}