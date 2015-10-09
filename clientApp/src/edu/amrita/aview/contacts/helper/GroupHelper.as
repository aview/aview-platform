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
 * File			: GroupListHelper.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 */
/**
 * Package for grouplisthelper
 */
//VGCR:- Function description
package edu.amrita.aview.contacts.helper
{
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	/**
	 * @public
	 * //PNCR: add class description
	 * extends AbstractHelper
	 */
	public class GroupHelper extends AbstractHelper
	{
		private var groupHelperRO:RemoteObject=null;
		
		/**
		 * @public
		 * Default Constructor 
		 */
		public function GroupHelper()
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
			
			groupHelperRO.getAllContactsByUser.addEventListener("result",getAllContactsByUserResultHandler);
			groupHelperRO.getAllContactsByUser.addEventListener("fault",genericFaultHandler);
			
			groupHelperRO.getGroupsAndContacts.addEventListener("result",getGroupsAndContactsResultHandler);
			groupHelperRO.getGroupsAndContacts.addEventListener("fault",genericFaultHandler);
			
			groupHelperRO.acceptSharedGroup.addEventListener("result",acceptSharedGroupResultHandler);
			groupHelperRO.acceptSharedGroup.addEventListener("fault",acceptSharedGroupFaultHandler);
				
		}
		
		/**
		 * @public
		 * Function to create group
		 * @param callerComp of type Object.
		 * @param group of type GroupVO.
		 * @param creatorId of type int.
		 */
		public function createGroup(group:GroupVO, creatorId:int,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.createGroup(group, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for createGroup.
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
		public function updateGroup(group:GroupVO, updaterId:int,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=groupHelperRO.updateGroup(group, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for updateGroup.
		 * @param event of type ResultEvent
		 */
		private function updateGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for updateGroup.
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
		 * ResultHandler for deleteGroup
		 * @param event of type ResultEvent
		 */
		private function deleteGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for deleteGroup
		 * @param event of type FaultEvent
		 */
		private function deleteGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to get groups by Ownerid
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
		 * Function TO get all groups
		 * @param callerComp of type Object
		 */
		public function getAllGroups(onResult:Function,onFault:Function= null):void
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
		public function getAllContactsByUser(userId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.getAllContactsByUser(userId);
			token.onResult = onResult;
			token.onFault=onFault;
		}
		public function getAllContactsByUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		public function getGroupsAndContacts(userId:Number,onResult:Function=null,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.getGroupsAndContacts(userId);
			token.onResult = onResult;
			token.onFault=onFault;
		}
		public function getGroupsAndContactsResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
	  
		public function acceptSharedGroup(groupId:Number,receiverId:Number,groupTransferId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupHelperRO.acceptSharedGroup(groupId,receiverId,groupTransferId);
			token.onResult = onResult;
			token.onFault=onFault;
		}
		
		public function acceptSharedGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		public function acceptSharedGroupFaultHandler(event:FaultEvent):void
		{
			if (event.fault.faultString && event.fault.faultString.indexOf("Duplicate entry")>-1)
			{
				event.token.onFault(event);
			}
			else
			{
				genericFaultHandler(event);
			}
		}
	}
}
