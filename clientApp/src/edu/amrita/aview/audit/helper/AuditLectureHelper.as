//
// Copyright  � 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * 
 * File			: AuditLectureHelper.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * Helper class for recording user's entry into an A-VIEW session.
 * Stores/Retrieves the contents of the AuditLectureVO to the database
 */
package edu.amrita.aview.audit.helper
{
	import edu.amrita.aview.audit.vo.AuditLectureVO;
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	/**
	 * 
	 * Helper class for recording user's entry into an A-VIEW session.
	 * Stores/Retrieves the contents of the AuditLectureVO to the database
	 */
	public class AuditLectureHelper extends AbstractHelper
	{
		/**
		 * @private
		 * Remote object for communicating with Database
		 */
		private var auditLectureRO:RemoteObject=null;
		
		/**
		 * 
		 * @public
		 * constructor
		 * Initializes the remote objects and registers the result and fault handlers		 * 
		 */
		public function AuditLectureHelper()
		{
			auditLectureRO=new RemoteObject();
			auditLectureRO.destination="auditLectureHelper";
			auditLectureRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			auditLectureRO.showBusyCursor=false;
			
			auditLectureRO.createAuditLecture.addEventListener("result", createAuditLectureResultHandler);
			auditLectureRO.createAuditLecture.addEventListener("fault", genericFaultHandler);
			
			auditLectureRO.updateAuditLectureById.addEventListener("result", updateAuditLectureByIdResultHandler);
			auditLectureRO.updateAuditLectureById.addEventListener("fault", genericFaultHandler);
		}
		
		/**
		 * 
		 * @public
		 * Creates the Lecture entry audit record in audit_lecture table. 
		 * This method is called when the user enters the session.
		 * 
		 * @param callerComp. The reference to the calling component/class.
		 * Used by this class to call back in the result/fault handlers.
		 * The reference is assigned to AsyncToken and then accessed 
		 * by the result/fault handers to call back on this object.
		 * 
		 * @param auditLectureVO. The AuditLectureVO containing the data to be inserted.
		 * 
		 * @return void
		 */
		public function createAuditLecture(auditLectureVO:AuditLectureVO,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=auditLectureRO.createAuditLecture(auditLectureVO, ClassroomContext.userVO.userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * 
		 * @public
		 * Updates the Lecture entry audit record, which was created during session entry,
		 * when the user exits a session. 
		 * 
		 * @param callerComp. The reference to the calling component/class.
		 * Used by this class to call back in the result/fault handlers.
		 * The reference is assigned to AsyncToken and then accessed 
		 * by the result/fault handers to call back on this object.
		 * 
		 * @param auditLectureId. The Primary key reference to the lecture entry audit record, which will be updated.
		 * 
		 * @return void
		 */
		public function updateAuditLectureById(auditLectureId:Number,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=auditLectureRO.updateAuditLectureById(auditLectureId, ClassroomContext.userVO.userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * 
		 * @private
		 * Result handler for createAuditLecture method. 
		 * Invoked when the Lecture entry audit call returned successfully from the database
		 * 
		 * @param event. The reference to the calling component/class.
		 * Used by this class to call back in the result/fault handlers.
		 * 
		 * @return void
		 */
		private function createAuditLectureResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as AuditLectureVO);
		}
		
		/**
		 * 
		 * @private
		 * Result handler for updateAuditLectureById methods. Invoked when the actions retuned from the database
		 * 
		 * @param event:ResultEvent The event object containing the result from Database server.
		 * 
		 * @return void
		 */
		private function updateAuditLectureByIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as AuditLectureVO);
		}
	}
}
