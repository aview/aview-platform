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
 * File			: UserActionHelper.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 * 
 * Helper class for storing the User's actions across all the modules and inside and outside session into the database
 * For performance reasons, the actions are batched and sent to database once every 5 minutes. 
 */
package edu.amrita.aview.core.shared.audit.helper
{
	import edu.amrita.aview.core.shared.audit.vo.UserActionVO;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	
	/**
	 * Helper class for storing the User's actions across all the modules and inside and outside session into the database
	 * For performance reasons, the actions are batched and sent to database once every 5 minutes. 
	 */
	public class UserActionHelper extends AbstractHelper
	{
		/**
		 * @private
		 * Remote object for communicating with Database
		 */
		private var userActionRO:RemoteObject=null;
		/**
		 * @private
		 * The time object which fires once every 5 mins to send the accumulated actions to the Databbase Server
		 */
		private var timerDataInsert:Timer;
		/**
		 * @private
		 * The array collection is used to store the accumulated actions between the timer events.
		 */
		private var acData:ArrayCollection;
		
		/**
		 * 
		 * @public
		 * constructor
		 * Initializes the remote objects and registers the result and fault handlers		 * 
		 */
		public function UserActionHelper()
		{
			acData=new ArrayCollection();
			timerDataInsert=new Timer(1000 * 60 * 5, 0);
			timerDataInsert.addEventListener(TimerEvent.TIMER, timerDataInsertFunction);
			timerDataInsert.start();
			userActionRO=new RemoteObject();
			userActionRO.destination="userActionHelper";
			userActionRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			userActionRO.showBusyCursor=false;
			
			userActionRO.createUserAction.addEventListener("fault", genericFaultHandler);
			
			userActionRO.createUserActions.addEventListener("fault", genericFaultHandler);
		}
		/**
		 * @public
		 * Sends all the pending UserActionVOs to database and emptys the list
		 * 
		 * @return void
		 */
		public function databaseInsert():void
		{
			var tempACData:ArrayCollection=new ArrayCollection();
			
			if (acData.length > 0)
			{
				tempACData.addAll(acData);
				createUserActions(tempACData, (new Date()).time);
				acData.removeAll();
			}
		}

		/**
		 * 
		 * @private
		 * Triggered by the 5 minute timer, to send off any accumulated UserActionVOs to database on the tick.
		 * 
		 * @param event:TimerEvent: The event object indicating the timer fire details
		 * 
		 * @return void
		 */
		private function timerDataInsertFunction(event:TimerEvent):void
		{
			databaseInsert();
		}
		
		
		/**
		 * 
		 * @public
		 * This method is called by AuditUserAction for storing the action into the database.
		 * For performance reasons, this method does not actually send Action to database, it simply stores in a local list.
		 * Every 5 minutes, the local list is sent over to database.
		 * 
		 * @param userAction: UserActionVO contains the details of the action
		 * 
		 * @return void
		 */
		public function createUserAction(userAction:UserActionVO):void
		{
			userAction.actionTimeMS=(new Date()).time;
			acData.addItem(userAction);
		}
		
		
		/**
		 * 
		 * @private
		 * Called by the batching thread once in every 5 minutes. Sends all the accumulated userActions to database
		 * 
		 * @param userActions: ArrayCollection, list UserActions which are accumulated/pending
		 * @param callTimeMS:Number, this local system's time which is sent to server for calcuating the exaction action occurance time on the server side.
		 * 
		 * @return void
		 */
		private function createUserActions(userActions:ArrayCollection, callTimeMS:Number):void
		{
			userActionRO.createUserActions(userActions, ClassroomContext.userVO.userId, callTimeMS);
		}
	}
}
