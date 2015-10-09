package edu.amrita.aview.core.gclm.helper
{
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.PeopleCountVO;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;

	public class PeopleCountHelper
	{
		private var peopleCountRO:RemoteObject = null;
		public function PeopleCountHelper()
		{
			peopleCountRO = new RemoteObject();
			peopleCountRO.destination = "peoplecounthelper";
			peopleCountRO.endpoint = ClassroomContext.WEBAPP_AVIEW_END_POINT;
			peopleCountRO.showBusyCursor = true;
			
			peopleCountRO.createPeopleCount.addEventListener(ResultEvent.RESULT, createPeopleCountResultHandler);
			peopleCountRO.createPeopleCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}
		
		private function createPeopleCountResultHandler(event:ResultEvent):void
		{
		}
		
		private function genericFaultHandler(event:FaultEvent):void
		{
			
		}
		
		public function createPeopleCount(peopleCount:PeopleCountVO,createrId:Number):void
		{
			peopleCountRO.createPeopleCount(peopleCount,createrId);
		}
	}
}