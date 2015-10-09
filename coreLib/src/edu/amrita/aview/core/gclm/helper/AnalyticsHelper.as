
package edu.amrita.aview.core.gclm.helper
{
	import com.adobe.net.URI;
	import com.adobe.protocols.dict.Response;
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.XMLListCollection;
	import mx.containers.utilityClasses.PostScaleAdapter;
	import mx.rpc.AsyncRequest;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
		
		public class AnalyticsHelper extends AbstractHelper
		{
			private var AnalyticsHelperRO:RemoteObject=null;
			
			public function AnalyticsHelper()
			{
				AnalyticsHelperRO = new RemoteObject() ;
				AnalyticsHelperRO.destination = "analyticshelper" ;
				AnalyticsHelperRO.endpoint =  ClassroomContext.WEBAPP_AVIEW_END_POINT;
				AnalyticsHelperRO.showBusyCursor = true ;
				
				AnalyticsHelperRO.getUserAndLectureDetailsForLecture.addEventListener(ResultEvent.RESULT, getUserAndLectureDetailsForLectureResultHandler) ;
				AnalyticsHelperRO.getUserAndLectureDetailsForLecture.addEventListener(FaultEvent.FAULT,genericFaultHandler) ;

				AnalyticsHelperRO.getUserAndLectureDetailsForClass.addEventListener(ResultEvent.RESULT, getUserAndLectureDetailsForClassResultHandler) ;
				AnalyticsHelperRO.getUserAndLectureDetailsForClass.addEventListener(FaultEvent.FAULT,genericFaultHandler);
			}
			
			//Calling Server funtion to generete PDF for lecture
			public function getUserAndLectureDetailsForLecture(lectureId:Number, onResult :Function, onFault:Function = null):void
			{
				var token:AsyncToken = AnalyticsHelperRO.getUserAndLectureDetailsForLecture(lectureId);
				token.onResult = onResult ;
				token.onFault = onFault ;
			}
			
			//ResultHandler for lecture pdf generation
			public function getUserAndLectureDetailsForLectureResultHandler(event:ResultEvent) :void
			{
				event.token.onResult(event.result) ;
			}
			
			//Calling Server funtion to generete  PDF for Class
			public function getUserAndLectureDetailsForClass(classId:Number, onResult :Function, onFault :Function = null):void
			{
				var token:AsyncToken=AnalyticsHelperRO.getUserAndLectureDetailsForClass(classId);
				token.onResult = onResult ;
				token.onFault = onFault ;
			}
			
			//ResultHandler for class pdf generation
			public function getUserAndLectureDetailsForClassResultHandler(event:ResultEvent) :void
			{
				event.token.onResult(event.result);
			}
	}
}