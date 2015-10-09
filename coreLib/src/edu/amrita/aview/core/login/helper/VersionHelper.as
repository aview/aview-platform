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
 * File			: VersionHelper.as
 * Module		: Login
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This helper class is used to call the remote java methods
 * 
 */
package edu.amrita.aview.core.login.helper
{
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	
	public class VersionHelper extends AbstractHelper
	{
		private var versionHelperRO:RemoteObject=null;
		
		public function VersionHelper()
		{
			versionHelperRO=new RemoteObject();
			versionHelperRO.destination="versionhelper";
			versionHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			versionHelperRO.showBusyCursor=true;
			
			versionHelperRO.checkClientServerCompatibility.addEventListener(ResultEvent.RESULT, checkClientServerCompatibilityResultHandler);
			versionHelperRO.checkClientServerCompatibility.addEventListener(FaultEvent.FAULT, genericFaultHandler);	
			
		}
				
		/**
		 * @public
		 * Function :To get ClassCount by courseId
		 * @param classVO of type ClassVO
		 * @param courseId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function checkClientServerCompatibility(clientVersion : String, onResult:Function, onFault:Function = null):void
		{
			var token:AsyncToken=versionHelperRO.checkClientServerCompatibility(clientVersion);
			token.onResult = onResult;
			token.onFault = onFault; 
		}
			
		/**
		 * @private
		 * Function :ResultHandler for getClassCount
		 * @param event of type ResultEvent		 
		 */
		private function checkClientServerCompatibilityResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event);			
		}
		
	}
}
