package edu.amrita.aview.contacts
{
	import edu.amrita.aview.contacts.TextInput.TextInputController;
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.ContactsTransferEvent;
	import edu.amrita.aview.contacts.events.TextInputEvent;
	import edu.amrita.aview.contacts.helper.GroupHelper;
	import edu.amrita.aview.contacts.helper.GroupTransferHelper;
	import edu.amrita.aview.contacts.transferContacts.SendContactsController;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.core.shared.events.ChatEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class GroupListController extends EventDispatcher
	{
		[Bindable]
		private var groupListModel:GroupListModel=null;
		[Bindable]
		private var allContacts:ArrayCollection=null;
		private var groupListView:GroupsListView=null;		
		private var userVO:UserVO=null;
		private var moduleEventMap:EventMap=null;		
		private var moduleRO:ModuleRO = null;
		
		private var sendContactsController:SendContactsController=null;
		
		private var selectedGroupTransferId:Number=0;
		
		public function GroupListController(mro:ModuleRO)
		{
			this.moduleRO = mro;
			this.moduleEventMap=mro.moduleEventMap;
			this.userVO=mro.userVO;
		}
		
		public function initialize(allGroupsAndContacts:ArrayCollection):void
		{			
			allContacts=allGroupsAndContacts;
			this.moduleEventMap.registerInitiator(this,ChatEvent.INITIATE_GROUP_CHAT);
			this.moduleEventMap.registerMapListener(ContactsTransferEvent.ACCEPT_GROUP,acceptGroup);
			this.moduleEventMap.registerMapListener(ContactsTransferEvent.REJECT_GROUP,rejectGroup);
			this.moduleEventMap.registerMapListener(ContactsTransferEvent.REFRESH_SHARED_GROUPS,refreshSharedGroups);
			this.moduleEventMap.registerInitiator(this,ContactsEvent.REFRESH);
			this.moduleEventMap.registerInitiator(this,ContactsEvent.SELECTED_GROUP);
			getSharedGroups();
		}
		public function unregisterListenersAndIntiators():void
		{
			this.moduleEventMap.unregisterInitiator(this,ChatEvent.INITIATE_GROUP_CHAT);
			this.moduleEventMap.unregisterMapListener(ContactsTransferEvent.ACCEPT_GROUP,acceptGroup);
			this.moduleEventMap.unregisterMapListener(ContactsTransferEvent.REJECT_GROUP,rejectGroup);
			this.moduleEventMap.unregisterMapListener(ContactsTransferEvent.REFRESH_SHARED_GROUPS,refreshSharedGroups);
			this.moduleEventMap.unregisterInitiator(this,ContactsEvent.REFRESH);
		}
	
		public function getGroupListView():GroupsListView
		{
			if(groupListView==null)
			{
				groupListView=new GroupsListView();
				groupListView.init(moduleEventMap);
				groupListView.groupListModel=groupListModel;
				groupListView.addEventListener(ContactsEvent.CREATE_GROUP,onCreateGroup);
				groupListView.addEventListener(ContactsEvent.EDIT_GROUP_NAME,onEditGroup);
				groupListView.addEventListener(ContactsEvent.DELETE_GROUP,deleteGroup);
				groupListView.addEventListener(ContactsEvent.START_GROUP_CHAT_BY_GROUP,onStartGroupChatEvent);
				groupListView.addEventListener(ContactsTransferEvent.SELECT_GROUP,onSelectGroup);
			}
			return groupListView;
		}
		public function getGroupListModel():GroupListModel
		{
			if(groupListModel==null)
			{
				groupListModel=new GroupListModel(allContacts);
				
			}
			return groupListModel;
		}
		private function onCreateGroup(event:ContactsEvent):void
		{
			getInput("Create Group",null);
		}
		private function onEditGroup(event:ContactsEvent):void
		{
			groupListModel.selectedGroup=event.data as GroupVO;
			getInput("Edit Group",groupListModel.selectedGroup.contactGroupName);
		}
		
		private function onSelectGroup(event:ContactsTransferEvent):void
		{
			var selectedGroup:GroupVO=event.selectedGroup;
			sendContactsController=new SendContactsController();
			sendContactsController.init(selectedGroup,this.moduleRO);
			sendContactsController.getSendContactsView(); 
			sendContactsController.addSendContactsView(this.groupListView);
		}
		/**
		 * @private
		 * Function to display new Component to enter the group name.
		 *
		 * @param title of type String
		 * @param oldValue of type String
		 * @return void
		 */
		private function getInput(title:String, oldValue:String):void
		{
			var textInputController:TextInputController = new TextInputController();
			textInputController.addEventListener(TextInputEvent.VALUE_CHANGED, createOrUpdate);
			textInputController.showTextInputView(title, oldValue, groupListView);
		}
		
		/**
		 * @private
		 * //PNCR: description 
		 * @param event of type TextInputEvent
		 * @return void
		 */
		private function createOrUpdate(event:TextInputEvent):void
		{
			var newValue:String = event.data.newValue;
			var isDuplicate:Boolean = groupListModel.checkGroupNameDuplicity(newValue);
			if (isDuplicate)
			{
				Alert.show("Duplicate group name. Try again.", "Error Creating Group");
				return;
			}
			if (event.data.oldValue == null)
			{
				createGroup(event.data.newValue);
				return;	
			}
			updateGroup(event.data.newValue);
		}
		
		
		private function createGroup(groupName:String):void
		{
			var groupVO:GroupVO = new GroupVO;
			groupVO.contactGroupName = groupName;
			groupVO.groupOwnerId = userVO.userId;
			var contactGroupHelper:GroupHelper = new GroupHelper();
			contactGroupHelper.createGroup(groupVO, userVO.userId,createGroupResultHandler);
		}
		/**
		 * @public
		 * //PNCR: description 
		 * @param event of type ResultEvent
		 * @return void
		 */
		public function createGroupResultHandler(event:ResultEvent):void
		{
			groupListModel.addContactGroup(event.result as GroupVO);
		}
		/**
		 * @private
		 * //PNCR: description 
		 * @param groupName of type String 
		 * @return void
		 */
		private function updateGroup(groupName:String):void
		{
			var groupVO:GroupVO = groupListModel.selectedGroup;
			groupVO.contactGroupName = groupName;
			var contactGroupHelper:GroupHelper = new GroupHelper();
			contactGroupHelper.updateGroup(groupVO, userVO.userId,updateGroupResultHandler);
		}
		/**
		 * @public
		 * Result handler function for updateGroup.
		 * Show an alert on successfully update the group
		 *
		 * @param event of type ResultEvent.
		 * @return void
		 */
		public function updateGroupResultHandler(event:ResultEvent):void
		{
				var group:GroupVO = event.result as GroupVO;
				groupListModel.updateContactGroup(groupListModel.selectedGroup, group);
		}
		
		/**
		 * @private
		 * //PNCR: description 
		 * @param event of type MessageBoxEvent
		 */
		private function deleteGroup(event:ContactsEvent):void
		{
			groupListModel.selectedGroup=event.data as GroupVO;
			var groupId:Number =groupListModel.selectedGroup.contactGroupId;
			var contactGroupHelper:GroupHelper = new GroupHelper();
			contactGroupHelper.deleteGroup(groupId, userVO.userId,deleteGroupResultHandler);
		}
		
		private function onStartGroupChatEvent(event:ContactsEvent):void
		{
			var selectedGroup:GroupVO = event.data as GroupVO;
			var selectedUsers:ArrayCollection = new ArrayCollection();
			for each (var groupUser:GroupUserVO in selectedGroup.groupUsers)
			{
				selectedUsers.addItem(groupUser.user);
			}
			this.dispatchEvent(new ChatEvent(ChatEvent.INITIATE_GROUP_CHAT,selectedUsers,null,null,selectedGroup.contactGroupName));
		}
		/**
		 * @public
		 * Result handler function for deleteGroup.
		 * Delete the group
		 *
		 * @param event of type ResultEvent.
		 * @return void
		 */
		public function deleteGroupResultHandler(event:ResultEvent):void
		{
			var groupId:Number = event.result as Number;
			Alert.show("Deleted group "+groupListModel.selectedGroup.contactGroupName);
			groupListModel.deleteContactGroup(groupListModel.selectedGroup.contactGroupId);
			groupListModel.selectedGroup=null;	
			groupListView.groupList.selectedIndex=-1;
			groupListModel.createAllContactsGroup();
			this.dispatchEvent(new ContactsEvent(ContactsEvent.SELECTED_GROUP,groupListModel.allContactsGroup));
		}
		
		public function getAllGroupsAndContacts():ArrayCollection
		{
			if(groupListModel==null)
			{
				return null;
			}
			return groupListModel.allGroupsAndContacts;
		}
		public function setAllContacts(allContacts:ArrayCollection):void
		{	
			var selectedGroupId:Number=-1;
		
			if(groupListModel.selectedGroup!=null)
			{
				 selectedGroupId=groupListModel.selectedGroup.contactGroupId;
			}
			groupListModel.allGroupsAndContacts=allContacts;
			groupListModel.selectedGroup=groupListModel.getGroupById(selectedGroupId);
			groupListModel.createAllContactsGroup();
		}
		
		private function getSharedGroups():void
		{
			var groupTransferHelper:GroupTransferHelper=new GroupTransferHelper();
			groupTransferHelper.getTransferredGroupsByReceiver(userVO.userId,getTransferredGroupsByReceiverResultHandler);
		}
		public function getTransferredGroupsByReceiverResultHandler(event:ResultEvent):void
		{
			groupListModel.receivedGroups=event.result as ArrayCollection;
		}
		private function acceptGroup(event:ContactsTransferEvent):void
		{
			var selectedGroup:GroupVO=event.selectedGroup;
			var groupHelper:GroupHelper=new GroupHelper();
			selectedGroupTransferId=event.target.selectedItem.groupTransferId;
			groupHelper.acceptSharedGroup(selectedGroup.contactGroupId,userVO.userId,selectedGroupTransferId,acceptSharedGroupResultHandler,acceptSharedGroupFaultHandler);			
				
		}
		public function acceptSharedGroupResultHandler(event:ResultEvent):void
		{
			this.dispatchEvent(new ContactsEvent(ContactsEvent.REFRESH));
			groupListModel.receivedGroups.removeItemAt(groupListView.receivedGroupsList.selectedIndex);
		}
		public function acceptSharedGroupFaultHandler(event:FaultEvent):void
		{
			Alert.show("A group with same name alredy exists in your group list.Rename it or delete it and try again","Information");
		}
		private function rejectGroup(event:ContactsTransferEvent):void
		{
			selectedGroupTransferId=event.target.selectedItem.groupTransferId;
			deleteSelectedGroupTransferEntry();
		}
		private function deleteSelectedGroupTransferEntry():void
		{
			var groupTransferHelper:GroupTransferHelper=new GroupTransferHelper();
			groupTransferHelper.deleteGroupTransfer(selectedGroupTransferId,onDeleteGroupTransfer);
		}
		public function onDeleteGroupTransfer(event:ResultEvent):void
		{
			trace("deleted group Transfer entry");			
			groupListModel.receivedGroups.removeItemAt(groupListView.receivedGroupsList.selectedIndex);
		}
		
		public function refreshSharedGroups(event:ContactsTransferEvent):void
		{
			getSharedGroups();
		}
	}
}