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
 * File			: ContactGroupHelper.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Veena Gopal K.V
 * Package for ContactGroupHelper
 */
//VGCR:-Add function Description
package edu.amrita.aview.contacts.helper
{
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	/**
	 * @public
	 *
	 * extends AbstractHelper
	 */
	public class ContactGroupHelper extends AbstractHelper
	{
		private var groupHelperRO:RemoteObject=null;
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.modules.contacts.helper.ContactGroupHelper.as");
		
		/**
		 * @public
		 * Default Constructor 
		 */
		public function ContactGroupHelper()
		{
			groupHelperRO=new RemoteObject();
			groupHelperRO.destination="groupHelper";
			groupHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			groupHelperRO.showBusyCursor=true;
			
			groupHelperRO.createGroup.addEventListener("result", createGroupResultHandler);
			groupHelperRO.createGroup.addEventListener("fault", createGroupFaultHandler);
			
			groupHelperRO.updateGroup.addEventListener("result", updateGroupResultHandler);
			groupHelperRO.updateGroup.addEventListener("fault", updateGroupFaultHandler);
			
			groupHelperRO.deleteGroup.addEventListener("result", deleteGroupResultHandler);
			groupHelperRO.deleteGroup.addEventListener("fault", deleteGroupFaultHandler);
			
			groupHelperRO.getGroupsByOwner.addEventListener("result", getGroupsByOwnerResultHandler);
			groupHelperRO.getGroupsByOwner.addEventListener("fault", getGroupsByOwnerFaultHandler);
			
			groupHelperRO.getAllGroups.addEventListener("result", getAllGroupsResultHandler);
			groupHelperRO.getAllGroups.addEventListener("fault", getAllGroupsFaultHandler);
		}
		
		/**
		 * @public
		 * Functio to create group
		 * @param callerComp of type Object.
		 * @param group of type GroupVO.
		 * @param creatorId of type int.
		 *
		 */
		public function createGroup(group:GroupVO, creatorId:int,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.createGroup(group, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for createGroup action
		 * @param event of type ResultEvent.
		 */
		private function createGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for createGroup.
		 * @param event of type FaultEvent.
		 */
		private function createGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to update group
		 * @param callerComp of type Object
		 * @param group of type GroupVO
		 * @param updaterId of type int
		 
		 */
		public function updateGroup(group:GroupVO, updaterId:int,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.updateGroup(group, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for update group.
		 * @param event of type ResultEvent
		 */
		private function updateGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for update group.
		 * @param event of type FaultEvent
		 */
		private function updateGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to delete group
		 * @param callerComp of type Object
		 * @param groupId of type Number
		 * @param updaterId of type Number
		 */
		public function deleteGroup(groupId:Number, updaterId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.deleteGroup(groupId, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for delete Group
		 * @param event of type ResultEvent
		 * @return void
		 */
		private function deleteGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for delete group
		 * @param event of type FaultEvent
		 */
		private function deleteGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to get groups by Owner id
		 * @param callerComp of type Object
		 * @param ownerId of type Number
		 */
		public function getGroupsByOwner(ownerId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.getGroupsByOwner(ownerId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for getGroupsByOwner
		 * @param event of type ResultEvent
		 */
		private function getGroupsByOwnerResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for getGroupsByOwner
		 * @param event of type FaultEvent
		 */
		private function getGroupsByOwnerFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to get all groups
		 * @param callerComp of type Object
		 */
		public function getAllGroups(onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=groupHelperRO.getAllGroups();
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for getAllGroups
		 * @param event of type ResultEvent
		 */
		private function getAllGroupsResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for getAllGroups
		 * @param event of type FaultEvent
		 */
		private function getAllGroupsFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
	
	
	}
}
