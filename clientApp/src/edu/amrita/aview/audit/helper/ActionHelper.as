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
 * File			: ActionHelper.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 * 
 * Helper class for getting all the Actions from database.
 * Called at the time of login to pre fetch all the Actions
 *  
 */
package edu.amrita.aview.audit.helper
{
	//Util imports
	import mx.collections.ArrayCollection;
	
	//Communication imports
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	//Auditing imports
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.common.helper.AbstractHelper;
	
	/**
	 * 
	 * Helper class for getting all the Actions from database.
	 * Called at the time of login to pre fetch all the Actions
	 *  
	 */
	public class ActionHelper extends AbstractHelper
	{
		/**
		 * @private
		 * Remote object for communicating with Database
		 */
		private var actionRO:RemoteObject=null;
		
		/**
		 * 
		 * @public
		 * Constructor. 
		 * Initializes the remote objects and registers the result and fault handlers		 * 
		 * 
		 */
		public function ActionHelper()
		{
			actionRO=new RemoteObject();
			actionRO.destination="actionHelper";
			actionRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			actionRO.showBusyCursor=false;
			
			actionRO.getActions.addEventListener("result", getActionsResultHandler);
			actionRO.getActions.addEventListener("fault", genericFaultHandler);
		}
		
		/**
		 * 
		 * @public
		 * Fetches all the actions from Database from the action table.
		 * 
		 * @param callerComp. The reference to the calling component/class.
		 * Used by this class to call back in the result/fault handlers.
		 * The reference is assigned to AsyncToken and then accessed 
		 * by the result/fault handers to call back on this object.
		 * 
		 * @return void
		 */
		public function getActions(onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=actionRO.getActions();
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * 
		 * @private
		 * Result handler for getActions methods. Invoked when the actions retuned from the database
		 * 
		 * @param event. The result event. 
		 * The event's result attribute is the ArrayCollection containing the ActionVOs
		 * 
		 * @return void
		 */
		private function getActionsResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ArrayCollection);
		}
	}
}
