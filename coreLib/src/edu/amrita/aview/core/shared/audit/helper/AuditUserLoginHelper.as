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
 * File			: AuditUserLoginHelper.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 * 
 * Helper class recording user login/logout details into the database.
 * Stores/Retrieves the contents of UserLoginVO
 */
package edu.amrita.aview.core.shared.audit.helper
{
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.UserLoginVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	
	/**
	 * Helper class recording user login/logout details into the database.
	 * Stores/Retrieves the contents of UserLoginVO
	 */
	public class AuditUserLoginHelper extends AbstractHelper
	{
		/**
		 * @private
		 * Remote object for communicating with Database
		 */
		private var audituserLoginHelperRO:RemoteObject=null;
		
		/**
		 * 
		 * @public
		 * constructor
		 * Initializes the remote objects and registers the result and fault handlers		 * 
		 */
		public function AuditUserLoginHelper()
		{
			audituserLoginHelperRO=new RemoteObject();
			audituserLoginHelperRO.destination="auditUserLoginHelper";
			audituserLoginHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			audituserLoginHelperRO.showBusyCursor=false;
			
			audituserLoginHelperRO.createUserLogin.addEventListener("result", createUserLoginResultHandler);
			audituserLoginHelperRO.createUserLogin.addEventListener("fault", genericFaultHandler);
			
			audituserLoginHelperRO.updateUserLogin.addEventListener("result", updateUserLoginResultHandler);
			audituserLoginHelperRO.updateUserLogin.addEventListener("fault", genericFaultHandler);
		}
		
		
		/**
		 * 
		 * @public
		 * Called after successful login into A-VIEW. The created date and updated date of the record will be same as the login time.
		 * The updated date gets updated during logout, while created date stays same, indicating the login time
		 * 
		 * @param callerComp. The reference to the calling component/class.
		 * Used by this class to call back in the result/fault handlers.
		 * The reference is assigned to AsyncToken and then accessed 
		 * by the result/fault handers to call back on this object.
		 * 
		 * @param userLoginVO: UserLoginVOs details, which are stored in the database.
		 * 
		 * @return void
		 */
		public function createUserLogin(userLoginVO:UserLoginVO,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=audituserLoginHelperRO.createUserLogin(userLoginVO, ClassroomContext.userVO.userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		
		/**
		 * 
		 * @private
		 * Result handler for createUserLogin methods. Invoked when the actions retuned from the database
		 * 
		 * @param event. The result event. 
		 * The event's result attribute is the UserLoginVO, which was inserted. Now it has the database id populated.
		 * 
		 * @return void
		 */
		private function createUserLoginResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as UserLoginVO);
		}
		
		/**
		 * 
		 * @public
		 * Called during logout. It updates the login database entry with the logout time (updateddate)
		 * 
		 * @param callerComp. The reference to the calling component/class.
		 * Used by this class to call back in the result/fault handlers.
		 * The reference is assigned to AsyncToken and then accessed 
		 * by the result/fault handers to call back on this object.
		 * 
		 * @param userLoginVO:UserLoginVO: The UserLoginVO object would be updated with the log out time on the server.
		 * 
		 * @return void
		 */
		public function updateUserLogin(userLoginVO:UserLoginVO,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=audituserLoginHelperRO.updateUserLogin(userLoginVO, ClassroomContext.userVO.userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		
		/**
		 * 
		 * @private
		 * Result handler for updateUserLogin methods. Invoked when the actions retuned from the database
		 * 
		 * @param event. The result event. 
		 * The event's result attribute is the UserLoginVO
		 * 
		 * @return void
		 */
		private function updateUserLoginResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as UserLoginVO);
		}
	
	}
}
