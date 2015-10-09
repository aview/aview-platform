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
 * File			: GroupUserHelper.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 */
/**
 * package for groupuserhelper
 */
//VGCR:-Function Description
package edu.amrita.aview.contacts.helper
{
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	/**
	 * @public
	 * //PNCR: class description
	 * extends AbstractHelper
	 * 
	 */
	public class GroupUserHelper extends AbstractHelper
	{
		private var groupUserHelperRO:RemoteObject=null;
		
		/**
		 * @public
		 * Default Constructor
		 */
		public function GroupUserHelper()
		{
			groupUserHelperRO=new RemoteObject();
			groupUserHelperRO.destination="groupUserHelper";
			groupUserHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			groupUserHelperRO.showBusyCursor=true;
			
			groupUserHelperRO.createGroupUser.addEventListener("result", createGroupUserResultHandler);
			groupUserHelperRO.createGroupUser.addEventListener("fault", createGroupUserFaultHandler);
			
			groupUserHelperRO.updateGroupUser.addEventListener("result", updateGroupUserResultHandler);
			groupUserHelperRO.updateGroupUser.addEventListener("fault", updateGroupUserFaultHandler);
			
			groupUserHelperRO.deleteGroupUser.addEventListener("result", deleteGroupUserResultHandler);
			groupUserHelperRO.deleteGroupUser.addEventListener("fault", deleteGroupUserFaultHandler);
			
			groupUserHelperRO.addUserToGroup.addEventListener("result", addUserToGroupResultHandler);
			groupUserHelperRO.addUserToGroup.addEventListener("fault", addUserToGroupFaultHandler);
			
			groupUserHelperRO.addUsersToGroup.addEventListener("result", addUsersToGroupResultHandler);
			groupUserHelperRO.addUsersToGroup.addEventListener("fault", addUsersToGroupFaultHandler);
			
			groupUserHelperRO.deleteUserFromGroup.addEventListener("result", deleteUserFromGroupResultHandler);
			groupUserHelperRO.deleteUserFromGroup.addEventListener("fault", deleteUserFromGroupFaultHandler);
			
			groupUserHelperRO.getGroupUser.addEventListener("result", getGroupUserResultHandler);
			groupUserHelperRO.getGroupUser.addEventListener("fault", getGroupUserFaultHandler);
			
			groupUserHelperRO.getUsersFromGroup.addEventListener("result", getUsersFromGroupResultHandler);
			groupUserHelperRO.getUsersFromGroup.addEventListener("fault", getUsersFromGroupFaultHandler);
			
			groupUserHelperRO.deleteUsersFromGroup.addEventListener("result", deleteUsersFromGroupResultHandler);
			groupUserHelperRO.deleteUsersFromGroup.addEventListener("fault", deleteUsersFromGroupFaultHandler);
		
			groupUserHelperRO.getAllContactsForUser.addEventListener("result", getAllContactsForUserResultHandler);
			groupUserHelperRO.getAllContactsForUser.addEventListener("fault", getAllContactsForUserFaultHandler);
		}
		
		/**
		 * @public
		 * Function to create group user
		 * @param callerComp of type Object
		 * @param groupUser of type GroupUserVO
		 * @param creatorId of type Number
		 * 
		 */
		public function createGroupUser(groupUser:GroupUserVO, creatorId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.createGroupUser(groupUser, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for createGroupUser
		 * @param event of type ResultEvent
		 */
		private function createGroupUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for createGroupUser
		 * @param event of type FaultEvent
		 */
		private function createGroupUserFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to update group user
		 * @param callerComp of type Object
		 * @param groupUser of type GroupUserVO
		 * @param updaterId of type Number
		 */
		public function updateGroupUser(groupUser:GroupUserVO, updaterId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.updateGroupUser(groupUser, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for updateGroupUser
		 * @param event of type ResultEvent
		 */
		private function updateGroupUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for updateGroupUser
		 * @param event of type FaultEvent
		 */
		private function updateGroupUserFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to delete group user
		 * @param callerComp of type Object
		 * @param groupUserId of type Number
		 * @param updaterId of type Number
		 */
		public function deleteGroupUser(groupUserId:Number, updaterId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.deleteGroupUser(groupUserId, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for deleteGroupUser
		 * @param event of type ResultEvent
		 */
		private function deleteGroupUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for deleteGroupUser
		 * @param event of type FaultEvent
		 */
		private function deleteGroupUserFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to add user to group
		 * @param callerComp of type Object
		 * @param groupId of type Number
		 * @param userId of type Number
		 */
		public function addUserToGroup(groupId:Number, userId:Number, creatorId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.addUserToGroup(groupId, userId, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for addUserToGroup
		 * @param event of type ResultEvent
		 */
		private function addUserToGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for addUserToGroup
		 * @param event of type FaultEvent
		 */
		private function addUserToGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function tp add users to group
		 * @param callerComp of type Object
		 * @param groupId of type Number
		 * @param userIds of type ArrayCollection
		 * @param creatorId of type Number
		 */
		public function addUsersToGroup(groupId:Number, userIds:ArrayCollection, creatorId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.addUsersToGroup(groupId, userIds, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for addUsersToGroup
		 * @param event of type ResultEvent
		 */
		private function addUsersToGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for addUsersToGroup
		 * @param event of type FaultEvent
		 */
		private function addUsersToGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to delete user from group
		 * @param callerComp of type Object
		 * @param userId of type Number
		 * @param groupId of type Number
		 * @param updaterId of type Number
		 */
		public function deleteUserFromGroup(userId:Number, groupId:Number, updaterId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.deleteUserFromGroup(userId, groupId, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for deleteUserFromGroup
		 * @param event of type ResultEvent
		 */
		private function deleteUserFromGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for deleteUserFromGroup
		 * @param event of type FaultEvent
		 */
		private function deleteUserFromGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to getGroupUser
		 * @param callerComp of type Object
		 * @param userId of type Number
		 * @param groupId of type Number
		 */
		public function getGroupUser(userId:Number, groupId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.getGroupUser(userId, groupId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for getGroupUser
		 * @param event of type ResultEvent
		 */
		private function getGroupUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for getGroupUser
		 * @param event of type FaultEvent
		 */
		private function getGroupUserFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to get users from group
		 * @param callerComp of type Object
		 * @param groupId of type Number
		 */
		public function getUsersFromGroup(groupId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.getUsersFromGroup(groupId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for getUsersFromGroup
		 * @param event of type ResultEvent
		 */
		private function getUsersFromGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for getUsersFromGroup
		 * @param event of type FaultEvent
		 */
		private function getUsersFromGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to delete users from group
		 * @param callerComp of type Object
		 * @param userIds of type ArrayCollection
		 * @param updaterId of type Number
		 */
		public function deleteUsersFromGroup(users:ArrayCollection, updaterId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=groupUserHelperRO.deleteUsersFromGroup(users, updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for deleteUsersFromGroup
		 * @param event of type ResultEvent
		 */
		private function deleteUsersFromGroupResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for deleteUsersFromGroup
		 * @param event of type FaultEvent
		 */
		private function deleteUsersFromGroupFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
		
		/**
		 * @public
		 * Function to getAllContactsForUser
		 * @param callerComp of type Object
		 * @param userId of type Number
		 * @return void
		 */
		public function getAllContactsForUser(userId:Number,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken = groupUserHelperRO.getAllContactsForUser(userId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * ResultHandler for getAllContactsForUser
		 * @param event of type ResultEvent
		 * @return void
		 */
		private function getAllContactsForUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * FaultHandler for getAllContactsForUser
		 * @param event of type FaultEvent
		 * @return void
		 */
		private function getAllContactsForUserFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event);
		}
	}
}
