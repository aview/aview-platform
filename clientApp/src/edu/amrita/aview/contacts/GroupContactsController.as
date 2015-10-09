package edu.amrita.aview.contacts
{
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.ContactsProviderEvent;
	import edu.amrita.aview.contacts.events.UserStatusProviderEvent;
	import edu.amrita.aview.contacts.helper.GroupUserHelper;
	import edu.amrita.aview.contacts.search.SearchController;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.core.shared.events.ChatEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class GroupContactsController extends EventDispatcher
	{
		private var groupContactsView:GroupContactsView=null;
		[Bindable]
		private var groupContactsModel:GroupContactsModel=null;		
		private var moduleEventMap:EventMap=null;
		private var searchController:SearchController=null;
		private var userVO:UserVO=null;
		private var callbackFunction:Function=null;
		private var moduleRO:ModuleRO = null
		public function GroupContactsController(mro:ModuleRO)
		{
			this.moduleRO = mro;
			this.moduleEventMap=mro.moduleEventMap;
			this.userVO=mro.userVO;
		}
		public function initialize():void
		{
			if(groupContactsView==null)
			{
				groupContactsView=new GroupContactsView();
				groupContactsView.groupContactsModel=getGroupContactsModel();
				groupContactsView.addEventListener(ContactsEvent.ADD_USER,onAddUser);
				groupContactsView.addEventListener(ContactsEvent.DELETE_USERS,deleteSelectedUsers);
				groupContactsView.addEventListener(ContactsEvent.START_GROUP_CHAT_BY_MEMBERS,onStartGroupChatEvent);
				groupContactsView.addEventListener(ContactsEvent.START_PRIVATE_CHAT,onStartPrivateChatEvent)
			}
			this.moduleRO.applicationEventMap.registerMapListener(ContactsEvent.USER_STATUS_CHANGED,onChangeUserStatus);
			this.moduleEventMap.registerMapListener(ContactsEvent.SELECTED_GROUP,updateGroupUsers);
			this.moduleEventMap.registerInitiator(this,ContactsEvent.REFRESH);
			this.moduleEventMap.registerInitiator(this,ChatEvent.INITIATE_GROUP_CHAT);
			this.moduleEventMap.registerInitiator(this,ChatEvent.INITIATE_PRIVATE_CHAT);
			this.moduleEventMap.registerInitiator(this,UserStatusProviderEvent.USER_STATUS_CHANGE);
		}
		public function unregisterListenersAndInitiators():void
		{
			this.moduleRO.applicationEventMap.unregisterMapListener(ContactsEvent.USER_STATUS_CHANGED,onChangeUserStatus);
			this.moduleEventMap.unregisterMapListener(ContactsEvent.SELECTED_GROUP,updateGroupUsers);
			this.moduleEventMap.unregisterInitiator(this,ContactsEvent.REFRESH);
			this.moduleEventMap.unregisterInitiator(this,ChatEvent.INITIATE_GROUP_CHAT);
			this.moduleEventMap.unregisterInitiator(this,ChatEvent.INITIATE_PRIVATE_CHAT);
			this.moduleEventMap.unregisterInitiator(this,UserStatusProviderEvent.USER_STATUS_CHANGE);
		}
		
		private function updateGroupUsers(event:ContactsEvent):void
		{
			groupContactsModel.currentGroup=event.data as GroupVO;
			groupContactsModel.groupUsers=groupContactsModel.currentGroup.groupUsers;
			groupContactsView.updateViewOnGroupSelection();
			this.dispatchEvent(new UserStatusProviderEvent(UserStatusProviderEvent.USER_STATUS_CHANGE,setUserStatus));
		}
		public function getGroupContactsView():GroupContactsView
		{
			return groupContactsView;			
		}
		public function getGroupContactsModel():GroupContactsModel
		{
			if(groupContactsModel==null)
			{
				groupContactsModel=new GroupContactsModel();
			}
			return groupContactsModel;
		}
		private function setUserStatus(onlineUsers:Object):void
		{
			if(groupContactsModel.groupUsers==null)
				return;
			for(var index:int=0;index<groupContactsModel.groupUsers.length;index++)
			{
				var user:UserVO=groupContactsModel.groupUsers[index].user;
				if(onlineUsers[user.userName]!=null)
				{
					user.userStatus=onlineUsers[user.userName];
				}
			}
		}
		private function onChangeUserStatus(event:ContactsEvent):void
		{	
			if(this.groupContactsModel!=null)
			{
				var groupUsers:ArrayCollection=this.groupContactsModel.groupUsers;
				if(groupUsers!=null)
				{
					for each(var gUser:GroupUserVO in groupUsers)
					{
						if(gUser.user.userName==event.data.name)
						{
							gUser.user.userStatus=event.data.userStatus;
							break;
						}
					}
					groupUsers.refresh();
				}
			}
			
		}
		private function onAddUser(event:ContactsEvent):void
		{
			createSearchController();
		}
		private function createSearchController():void
		{
			searchController=new SearchController(userVO,groupContactsModel.currentGroup,moduleRO);
			searchController.init();
			searchController.showSearchView(this.getGroupContactsView());
		}
		private function deleteSelectedUsers(event:ContactsEvent):void
		{
			if (groupContactsModel.selectedUsers!=null && groupContactsModel.selectedUsers.length > 0)
			{
				Alert.show("Are you sure you want to delete the selected contact(s) from this group?", "Confirmation", Alert.YES | Alert.NO, null, deleteContactFromGroup);
			}
		}
		/**
		 * Event Listener for Result event to delete users from a group.
		 * @param event
		 */
		public function deleteUsersFromGroupResultHandler(event:ResultEvent):void
		{
			Alert.show("Selected contact(s) is deleted from this Group", "Information");
			groupContactsModel.currentGroup.groupUsers=groupContactsModel.groupUsers;
			this.dispatchEvent(new ContactsEvent(ContactsEvent.REFRESH,null));
		}
		
		private function deleteContactFromGroup(event:CloseEvent):void
		{			
			var userIds:ArrayCollection=new ArrayCollection;
			var selectedUserId:int;
			var tempId:Number;
			var groupUserHelper:GroupUserHelper=new GroupUserHelper;
			if (event.detail == Alert.YES)
			{
				for (var i:int=groupContactsModel.selectedUsers.length - 1; i >= 0; i--)
				{
					tempId=groupContactsModel.selectedUsers[i].groupUserId;
					selectedUserId=groupContactsModel.selectedUsers[i].user.userId;
					userIds.addItem(tempId);
					for (var j:int=0; j < groupContactsModel.groupUsers.length; j++)
					{
						if (selectedUserId == groupContactsModel.groupUsers[j].user.userId)
						{
							groupContactsModel.groupUsers.removeItemAt(j);
							break;
						}
					}
				}
				groupContactsModel.currentGroup.groupUsers=groupContactsModel.groupUsers;
				groupContactsModel.groupUsers.refresh();
				groupUserHelper.deleteUsersFromGroup(userIds, userVO.userId,deleteUsersFromGroupResultHandler,deleteUsersFromGroupFaultHandler);
			}
		}
		
		public function deleteUsersFromGroupFaultHandler(event:FaultEvent):void
		{			
			Alert.show("Failed removing users from group","Error");							
		}
		
		private function onStartGroupChatEvent(event:ContactsEvent):void
		{
			var selectedUsers:ArrayCollection = event.data as ArrayCollection;
			this.dispatchEvent(new ChatEvent(ChatEvent.INITIATE_GROUP_CHAT,selectedUsers,null,null,null));
		}
		
		
		private function onStartPrivateChatEvent(event:ContactsEvent):void
		{
			var user:UserVO = event.data as UserVO;
			this.dispatchEvent(new ChatEvent(ChatEvent.INITIATE_PRIVATE_CHAT,user,null,null,null));
		}
		 public function setCurrentGroup(group:GroupVO):void
		 {
			if(group!=null)
			{
			 	groupContactsModel.currentGroup=group;
			 	groupContactsModel.groupUsers=group.groupUsers;
			}
		 }
		
		
	}
}