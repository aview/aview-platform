////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * 
 * File			: TimeStampHelper.as
 * Module		: Common
 * Developer(s)	: 
 * Reviewer(s)	: 
 */

package edu.amrita.aview.common.helper
{
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	public class TimeStampHelper
	{
		/**
		 * For Log API
		 */
		private var logger:ILogger=Log.getLogger("edu.amrita.aview.common.helper.TimeStampHelper");
		
		/**
		 * HTTPService to get server date and time.
		 */
		private var httpGetServerDate:HTTPService;
		/**
		 * @public
		 * Default constructor
		 * Initializes HTTPService to obtain server date and time.
		 * It takes data from Wamp Server.
		 */
		
		public function TimeStampHelper()
		{
			httpGetServerDate = new HTTPService();
			httpGetServerDate.url = 'http://' + ClassroomContext.CONTENT_WHITEBOARD+':'+ClassroomContext.portWAMP + '/AVScript/Whiteboard/serverDate.php?module=quiz'; 
			httpGetServerDate.addEventListener(ResultEvent.RESULT,getServerDateAndTimeResultHandler);
			httpGetServerDate.addEventListener(FaultEvent.FAULT,getServerDateAndTimeFaultHandler);
			httpGetServerDate.method = "POST";
		}
		
		/**
		 * @public
		 * Function :To get current date and time from server
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getServerDateAndTime(onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken = httpGetServerDate.send();
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getServerDateAndTime
		 * @param event of type ResultEvent
		 * 		 
		 */
		private function getServerDateAndTimeResultHandler(event:ResultEvent):void
		{
			if(Log.isInfo()) logger.info("Server date and time is : " + event.result.toString());
			event.token.onResult(event.result.toString());
		}
		
		/**
		 * @private
		 * Function :FaultHandler for getServerDateAndTime
		 * @param event of type FaultEvent
		 * 		 
		 */
		private function getServerDateAndTimeFaultHandler(event:FaultEvent):void
		{
			if(event.token.onFault)
			{
				event.token.onFault();
			}
		}
		
	}
}
