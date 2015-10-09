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
 * File			: Action.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * Loads all the ActionVOs from database.
 * Initialized and invoked during application startup
 */

package edu.amrita.aview.core.shared.audit
{
	//Helper Imports
	import edu.amrita.aview.core.shared.audit.helper.ActionHelper;
	
	//Utils Imports
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	//Loggin Imports
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	/**
	 * Loads all the ActionVOs from database.
	 * Initialized and invoked during application startup
	 */
	public class Action
	{
		/**
		 * Helper class for database operations. Connects with Java backend
		 */
		private var actionHelper:ActionHelper=new ActionHelper();
		/**
		 * Logger class for client side file and console logging
		 */
		private var auditLog:ILogger=Log.getLogger("edu.amrita.aview.audit.Action");
		/**
		 *
		 * @public
		 * Gets all the actions from the database/java layer.
		 * Usually called during the application initialization
		 *
		 * @return void
		 *
		 ***/
		public function getActions():void
		{
			actionHelper.getActions(getActionsResultHandlers);
		}
		
		/**
		 *
		 * @public
		 * Receives the ActionVOs from the result handler and populates them in the AuditContext as map
		 * The rest of the application accesses these ActionVOs while auditing various actions
		 *
		 * @param ActionVOs coming in from result handler of actionHelper.getActions
		 * @return void
		 *
		 ***/
		public function getActionsResultHandlers(actions:ArrayCollection):void
		{
			if (Log.isInfo()) auditLog.info("got {0} Actions", actions.length);
			AuditContext.populateActionIds(actions);
		}
	}
}

