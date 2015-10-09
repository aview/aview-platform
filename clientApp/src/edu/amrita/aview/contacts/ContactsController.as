////////////////////////////////////////////////////////////////////////////////
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
 *
 * File		   : ContactsController.as
 * Module	   : contacts
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) : Bri.Radha
 *
 * 
 *
 */
//VGCR:-Function Description
package edu.amrita.aview.contacts
{
	import com.amrita.edu.collaboration.CollaborationObject;
	
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.ContactsProviderEvent;
	import edu.amrita.aview.contacts.events.UserStatusProviderEvent;
	import edu.amrita.aview.contacts.events.UserStatusRequesterEvent;
	import edu.amrita.aview.contacts.helper.GroupHelper;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.entry.events.SessionStatusEvent;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
	import edu.amrita.aview.meeting.MeetingRoomController;
	import edu.amrita.aview.meeting.MeetingRoomListController;
	import edu.amrita.aview.meeting.events.CommonEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	/**
	 *@public
	 * extends EventDispatcher
	 * //PNCR: description
	 */
	public class ContactsController extends EventDispatcher
	{
		//PNCR: variable description
		private var contactModuleRO:ModuleRO = null;
		
		private var contactsModel:ContactsModel = null;
		applicationType::DesktopWeb{
			private var contactsView:ContactsView = null;
		}
		private var isAllGroupsAvailable:Boolean=false;
		private var isSharedObjectConnected:Boolean=false;
		private var meetingRoomListController:MeetingRoomListController=null;
		private var meetingRoomController:MeetingRoomController=null;
		private var groupListController:GroupListController=null;
		private var groupContactsController:GroupContactsController=null;
		
		private var usersCollaborationObject:CollaborationObject = null;
		private var allGroupsAndContacts:ArrayCollection=null;
		applicationType::DesktopWeb{
			private var msgBox:MessageBox = null;
		}
		
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.modules.contacts.ContactsController.as");
		
		private var isContactAdded:Boolean=false;
		
		/**
		 * @public 
		 * //PNCR: description
		 * @param userVO of type UserVO
		 * 
		 */
		public function ContactsController(moduleRO:ModuleRO)
		{
			this.contactModuleRO = moduleRO;
		}
		
		/**
		 * @public 
		 * //PNCR: description
		 * @return void
		 */
		public function initialize():void
		{
			contactModuleRO.moduleEventMap.registerMapListener(UserStatusProviderEvent.USER_STATUS_CHANGE,onUserStatusChange);
			contactModuleRO.moduleEventMap.registerMapListener(ContactsEvent.REFRESH,getContacts);
			contactModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE, onApplicationClose);
			contactModuleRO.mediaServerConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, connectionStatusHandler);
			connectUsersCollaborationObject();
			getContactGroups();
			contactModuleRO.applicationEventMap.registerInitiator(this,ContactsEvent.USER_STATUS_CHANGED);
			contactModuleRO.applicationEventMap.registerMapListener(ContactsProviderEvent.REFRESH_CONTACTS,refreshContactsList);
			contactModuleRO.applicationEventMap.registerMapListener(UserStatusRequesterEvent.UPDATE_USER_STATUS,updateUserStatus);
			contactModuleRO.applicationEventMap.registerMapListener(SessionStatusEvent.TYPE_SESSION_ENTRY,onSessionEntry);	
			contactModuleRO.applicationEventMap.registerMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,onSessionExit);
		}
		public function onSessionEntry(event:SessionStatusEvent):void
		{
			usersCollaborationObject.setValue(this.contactModuleRO.userVO.userName,Constants.BUSY);
		}
		public function onSessionExit(event:SessionStatusEvent):void
		{
			usersCollaborationObject.setValue(this.contactModuleRO.userVO.userName,Constants.ONLINE);
		}
		public function onUserStatusChange(event:UserStatusProviderEvent):void
		{			
			event.userStatusReceiver(usersCollaborationObject.getData());
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param event of type MediaServerStatusEvent
		 * @return void 
		 */
		private function connectionStatusHandler(event:MediaServerStatusEvent):void
		{
			switch(event.code)
			{
				case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
					onConnectionSuccess();
					break;
				
				case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
					onConnectionFailure();
					break;
				
				case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
					onConnectionFailure();
					break;
			}
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @return void 
		 */
		private function onConnectionSuccess():void
		{
			usersCollaborationObject.setValue(contactModuleRO.userVO.userName, Constants.ONLINE);
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @return void
		 */
		private function onConnectionFailure():void
		{
			usersCollaborationObject.setValue(contactModuleRO.userVO.userName, Constants.OFFLINE);
		}
		
		private function refreshContactsList(event:ContactsProviderEvent):void
		{
			event.callbackFunction(allGroupsAndContacts);
		}
		private function getContacts(event:Event):void
		{
			getContactGroups();
		}
		private function updateUserStatus(event:UserStatusRequesterEvent):void
		{
			if(usersCollaborationObject && usersCollaborationObject.syncEventCount > 0)
			{
				var data:Object = usersCollaborationObject.getData();
				var userVOs:ArrayCollection = event.userVOs;
				for each(var userVO:UserVO in userVOs)
				{
					userVO.userStatus = data[userVO.userName];
				}
			}
		}
		/**
		 * @private  
		 * //PNCR: description
		 * @param userVO of type UserVO
		 * @return void
		 */
		private function getContactGroups():void
		{
			var contactGroupHelper:GroupHelper = new GroupHelper;
			contactGroupHelper.getGroupsAndContacts(contactModuleRO.userVO.userId,getGroupsAndContactsResultHandler);
		}
		/**
		 * @public
		 * Result handler function for getGroupsByOwner.
		 * add all the groups to the grouplist.
		 *
		 * @param event of type ResultEvent.
		 * @return void
		 */
		public function getGroupsAndContactsResultHandler(event:ResultEvent):void
		{			
			allGroupsAndContacts=event.result as ArrayCollection;
			isAllGroupsAvailable=true;
			if(isSharedObjectConnected)
			{
				setStatusforGroupMembers();
			}
			if(contactsView && contactsView.parent!=null && !isContactAdded)
			{
				prepareMeetingControllersandViews();
			}	
			
			updateContactsInControllers();
		}
		
		public function updateContactsInControllers():void
		{
			if(groupContactsController!=null)
			{
				groupListController.setAllContacts(allGroupsAndContacts);
				groupContactsController.setCurrentGroup(groupListController.getGroupListModel().selectedGroup);
			}
			if(meetingRoomListController!=null)
			{
				meetingRoomListController.setAllContacs(allGroupsAndContacts);
			}
			if(meetingRoomController!=null)
			{
				meetingRoomController.setAllContacs(allGroupsAndContacts);
			}
		}
		
		/**
		 * @public
		 * Fault handler function for getGroupsByOwner.
		 *
		 * @param event of type FaultEvent.
		 * @return void
		 */
		public function getGroupsByOwnerFaultHandler(event:FaultEvent):void
		{
			if (Log.isError()) log.error("Contacts::ContactsController::getGroupsByOwnerFaultHandler:" +AbstractHelper.getStaticFaultMessage(event));
			applicationType::DesktopWeb{
				MessageBox.show("Failed to retrieve groups for this user.", "Failed", MessageBox.MB_OK);
			}
		}
	
		/**
		 * @private 
		 * //PNCR: description
		 * @param mediaServerConnection of type MediaServerConnection
		 * @return void
		 */
		private function connectUsersCollaborationObject():void
		{
			usersCollaborationObject = contactModuleRO.collaborationService.connectCollaborationObject("users_so");
			usersCollaborationObject.setValue(contactModuleRO.userVO.userName, Constants.ONLINE);
			usersCollaborationObject.setOnClear(onClearCollaborationObject);
			usersCollaborationObject.setOnChange(usersChangeHandler);
			
		}
		private function onClearCollaborationObject():void
		{
			isSharedObjectConnected=true;
			if(isAllGroupsAvailable)
			{
				setStatusforGroupMembers();
			}
		}
		
		/**
		 * To set online status for group members 
		 * 
		 */
		private function setStatusforGroupMembers():void
		{
			for(var index:int=0;index<allGroupsAndContacts.length;index++)
			{
				var group:GroupVO=allGroupsAndContacts[index];
				for(var gIndex:int=0;gIndex<group.groupUsers.length;gIndex++)
				{
					var groupUser:GroupUserVO=group.groupUsers[gIndex];
					var userName:String=groupUser.user.userName;
					if(usersCollaborationObject.getData()[userName]!=null)
						groupUser.user.userStatus=usersCollaborationObject.getData()[userName];
					else
						groupUser.user.userStatus=Constants.OFFLINE;
					
				}
			}
		}
		/**
		 * @private
		 * //PNCR: description 
		 * @return void
		 */		
		private function closeUsersCollaborationObject():void
		{
			usersCollaborationObject.setValue(contactModuleRO.userVO.userName, Constants.OFFLINE);
			contactModuleRO.collaborationService.closeCollaborationObject("users_so");
		}
		/**
		 * @private
		 * //PNCR: description 
		 * @param userStatus of type String
		 * @param name of type String
		 * @return void
		 */
		private function usersChangeHandler(userStatus:String, name:String):void
		{
			usersCollaborationObject.setOnDeleteProperty(name, userDeleteHandler);
			var object:Object=new Object();
			object.name=name;
			object.userStatus=userStatus;
			this.dispatchEvent(new ContactsEvent(ContactsEvent.USER_STATUS_CHANGED,object));
		}
		
		/**
		 * @private
		 * //PNCR: description 
		 * @param name of type String
		 * @return void
		 */
		private function userDeleteHandler(name:String):void
		{
			var object:Object=new Object();
			object.name=name;
			object.userStatus=Constants.OFFLINE;
			this.dispatchEvent(new ContactsEvent(ContactsEvent.USER_STATUS_CHANGED,object));			
		}
		/**
		 * @public
		 * //PNCR: description 
		 * @param userName of type String
		 * @return String
		 */
		public function getUserStatus(userName:String):String
		{
			//If the given username is present in the sharedobject and then return the userstatus 
			//otherwise return user status as offline
			if (usersCollaborationObject != null && usersCollaborationObject.getData() != null)
			{
				if (usersCollaborationObject.getData()[userName] != null)
				{
					return usersCollaborationObject.getData()[userName];
				}
			}
			return Constants.OFFLINE;
		}
		
		/**
		 * @public
		 * //PNCR: description 
		 * @return ContactsView
		 */
		public function getContactsView():ContactsView
		{
			
			this.contactsView = new ContactsView;
			this.contactsView.addEventListener(FlexEvent.CREATION_COMPLETE,onContactsCreationComplete);
			this.contactsView.addEventListener(CommonEvent.SELECTED,onChangeLeftTabBar);
			
			return this.contactsView;
		}
		
		private function onContactsCreationComplete(event:FlexEvent):void
		{	
			if(allGroupsAndContacts!=null)
			{
				prepareMeetingControllersandViews();
			}
		}
		private function prepareMeetingControllersandViews():void
		{			
			getGroupsListController();
			getGroupContactsController();			
			getMeetingRoomListController();
			getMeetingRoomController(groupListController.getAllGroupsAndContacts());
			meetingRoomController.init();
			addMeetingRoomView();
			meetingRoomListController.init(groupListController.getAllGroupsAndContacts());
			this.contactsView.meetingRoomsListNavigator.addElement(meetingRoomListController.getMeetingRoomsListView());
			isContactAdded=true;		
		}
			
		private function onChangeLeftTabBar(event:CommonEvent):void
		{
			if(this.contactsView.vskLeftTabBar.selectedIndex==0)
			{
				removeMeetingRoomViewElements();
				addMeetingRoomView();
			}
			else
			{
				removeMeetingRoomViewElements();
				addGroupsListView();
			    addGroupContactsView();
			}				
		}
		
		private function getMeetingRoomListController():MeetingRoomListController
		{
			if(this.meetingRoomListController==null)
			{
				this.meetingRoomListController=new MeetingRoomListController(contactModuleRO);
			}
			return this.meetingRoomListController;
		}
		private function getMeetingRoomController(allContacts:ArrayCollection):void
		{
			if(this.meetingRoomController==null)
			{
				this.meetingRoomController=new MeetingRoomController(contactModuleRO,allContacts);
				this.meetingRoomController.init();
			}			
		}
		private function addMeetingRoomView():void
		{
			var meetingRoomContainer:IVisualElementContainer=this.contactsView.meetingRoomViewContainer;
			meetingRoomContainer.addElement(this.meetingRoomController.getMeetingRoomView());	
			this.meetingRoomController.createMeetingRoomControllers();
		}
		
		private function removeMeetingRoomViewElements():void
		{
			var meetingRoomContainer:IVisualElementContainer=this.contactsView.meetingRoomViewContainer;
			meetingRoomContainer.removeAllElements();
			
		}
		private function addGroupsListView():void
		{
			var groupListContainer:IVisualElementContainer=this.contactsView.groupsListNavigator;
			var groupListView:GroupsListView=groupListController.getGroupListView();
			groupListContainer.addElement(groupListView);			
				
		}
		private function addGroupContactsView():void
		{
			this.contactsView.meetingRoomViewContainer.addElement(groupContactsController.getGroupContactsView());
			
		}
		public function getGroupsListController():void
		{
			if(groupListController!=null)
			{
				groupListController.unregisterListenersAndIntiators();
				groupListController=null;
			}
			 groupListController=new GroupListController(contactModuleRO);	
			 groupListController.initialize(allGroupsAndContacts);
			
		}
		public function getGroupContactsController():void
		{
			if(groupContactsController!=null)
			{
				groupContactsController.unregisterListenersAndInitiators();
				groupContactsController=null;
			}
			groupContactsController=new GroupContactsController(contactModuleRO);
			groupContactsController.initialize();
			groupListController.getGroupListModel();
		
		}			
		
		public function addGroupsList():void
		{
			this.contactsView.groupsListNavigator.addElement(groupListController.getGroupListView());
		}	
		
		
		
		/**
		 * @private
		 * Function to close user collaboration object.
		 * @param event of type ApplicationStatusEvent
		 * @return void
		 */
		private function onApplicationClose(event:ApplicationStatusEvent):void
		{
			closeUsersCollaborationObject();
		}

		public function unregisterInitiatorsAndListeneres():void
		{
			contactModuleRO.moduleEventMap.unregisterMapListener(UserStatusProviderEvent.USER_STATUS_CHANGE,onUserStatusChange);
			contactModuleRO.moduleEventMap.unregisterMapListener(ContactsEvent.REFRESH,getContacts);
			contactModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE, onApplicationClose);			
			contactModuleRO.applicationEventMap.unregisterMapListener(ContactsProviderEvent.REFRESH_CONTACTS,refreshContactsList);
			contactModuleRO.applicationEventMap.unregisterMapListener(UserStatusRequesterEvent.UPDATE_USER_STATUS,updateUserStatus);
			contactModuleRO.applicationEventMap.unregisterMapListener(SessionStatusEvent.TYPE_SESSION_ENTRY,onSessionEntry);	
			contactModuleRO.applicationEventMap.unregisterMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,onSessionExit);
			contactModuleRO.applicationEventMap.unregisterMapListener(ContactsProviderEvent.REFRESH_CONTACTS,refreshContactsList);
			contactModuleRO.applicationEventMap.unregisterInitiator(this,ContactsEvent.USER_STATUS_CHANGED);
			if(groupListController!=null)
				groupListController.unregisterListenersAndIntiators();
			if(groupContactsController!=null)
				groupContactsController.unregisterListenersAndInitiators();
		}

	}
}