////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: FeedbackHelper.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 *
 * helper class for communication the UI with backend
 */
package edu.amrita.aview.feedback.helper
{
	import edu.amrita.aview.feedback.vo.FeedbackVO;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.common.helper.AbstractHelper;
	
	public class FeedbackHelper extends AbstractHelper
	{
		/**
		 * For Log API
		 */
		public var log:ILogger=Log.getLogger("aview.edu.amrita.aview.feedback.helper.FeedbackHelper");
		
		private var feedbackHelperRO:RemoteObject=null;
		
		public function FeedbackHelper()
		{
			feedbackHelperRO=new RemoteObject();
			feedbackHelperRO.destination="feedbackHelper";
			feedbackHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			feedbackHelperRO.showBusyCursor=true;
			
			feedbackHelperRO.createFeedback.addEventListener("result", createFeedbackResultHandler);
			feedbackHelperRO.createFeedback.addEventListener("fault", genericFaultHandler);
		}
		
		public function createFeedback(callerComp:Object,feedback:FeedbackVO):void
		{
			if (Log.isInfo())log.info("Submitting the feedback " + feedback.toString());
			var token:AsyncToken=feedbackHelperRO.createFeedback(feedback, ClassroomContext.userVO.userId);
			token.caller = callerComp;
		}
		
		private function createFeedbackResultHandler(event:ResultEvent):void
		{
			if (Log.isInfo())log.info("Created the feedback with an Id:" + (event.result as FeedbackVO).feedbackId);
			event.token.caller.createFeedbackResultHandler(event.result as FeedbackVO);
		}
	}
}
