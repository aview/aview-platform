//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.contacts.GroupListModel;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.contacts.events.ContactsTransferEvent;
import edu.amrita.aview.contacts.transferContacts.SendContactsController;
import edu.amrita.aview.contacts.vo.GroupVO;
import edu.amrita.aview.core.shared.eventmap.EventMap;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import spark.components.List;
import spark.events.ListEvent;

[Bindable]
public var groupListModel:GroupListModel=null;
private var eventMap:EventMap=null;

/** Icon  for adding new group in the grouplist */
[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/addGroup.png")]
public var addgroupIcon:Class;
[Bindable]
public var add_group:Class=addgroupIcon;

/** Icon  for Editing group in the grouplist */
[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/editGroup.png")]
public var editGroupIcon:Class;
[Bindable]
public var edit_group:Class=editGroupIcon;

/** Icon  for Deleting group in the grouplist */
[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/delGroup.png")]
public var deleteGroupIcon:Class;
[Bindable]
public var delete_group:Class=deleteGroupIcon;	

/** Icon  for Deleting group in the grouplist */
[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/group_chat.png")]
public var groupChatIcon:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/share.png")]
public var shareGroupIcon:Class;


private var menuItems:ArrayCollection=new ArrayCollection([{itemName:"Send To"}]);


public function init(eventMap:EventMap):void
{
	this.eventMap=eventMap;
	eventMap.registerInitiator(this,ContactsEvent.SELECTED_GROUP);
	
}
protected function group1_creationCompleteHandler(event:FlexEvent):void
{
	selectAllContacts();
	eventMap.registerInitiator(receivedGroupsList,ContactsTransferEvent.ACCEPT_GROUP);
	eventMap.registerInitiator(receivedGroupsList,ContactsTransferEvent.REJECT_GROUP);
}

//Get the users name in the selected group.
protected function onClickGroupList():void
{
	
	if (groupList.selectedItem)
	{
		groupListModel.selectedGroup=groupList.selectedItem;
	  this.dispatchEvent(new ContactsEvent(ContactsEvent.SELECTED_GROUP,groupList.selectedItem));		
	}
}
private function onClickEdit(e:Event):void
{
	if (groupList.selectedItem != null)
	{
		this.dispatchEvent(new ContactsEvent(ContactsEvent.EDIT_GROUP_NAME,groupList.selectedItem));
	}
	else
	{
		Alert.show("Please select one group to edit", "Information");
	}
}
private function onClickDelete(event:Event):void
{
	if (groupList.selectedItem)
	{
		Alert.show("Are you sure you want to delete the group " + groupList.selectedItem.contactGroupName + " ?", "Confirmation", Alert.YES | Alert.NO, null, delGroupName);
	}
	else
	{
		Alert.show("Please select one group to delete", "Information");
	}
}
private function delGroupName(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		this.dispatchEvent(new ContactsEvent(ContactsEvent.DELETE_GROUP,groupList.selectedItem));
	}
}
/**
 *  Display new Component to enter the group name.
 */
protected function addGroup(event:MouseEvent):void
{
	this.dispatchEvent(new ContactsEvent(ContactsEvent.CREATE_GROUP,null));
}
/**
 *  Display new Component to enter the group name.
 */
protected function startGroupChat(event:MouseEvent):void
{
	if (groupList.selectedItem)
	{
		var groupVO:GroupVO = groupList.selectedItem as GroupVO;
		if(groupVO.groupUsers.length == 0)
		{
			Alert.show("The selected group should have at least one contact to start group chat", "Information");
		}
		else
		{
			this.dispatchEvent(new ContactsEvent(ContactsEvent.START_GROUP_CHAT_BY_GROUP,groupList.selectedItem));
		}
	}
	else
	{
		Alert.show("Please select one group to start group chat", "Information");
	}
}

private function myContacts_clickHandler(event:MouseEvent):void
{
	selectAllContacts();
	groupList.selectedIndex=-1;
}
private function selectAllContacts():void
{
	groupListModel.createAllContactsGroup();	
	this.dispatchEvent(new ContactsEvent(ContactsEvent.SELECTED_GROUP,groupListModel.allContactsGroup));
}


private function shareGroup():void
{
	var group:GroupVO=groupListModel.selectedGroup;
	if(groupList.selectedItem==null)
	{
		Alert.show("Please select a group","Warning");
		return;
	}
	if(group.groupUsers==null || group.groupUsers.length==0)
	{
		Alert.show("The selected group doesn't have any members","Warning");
		return;
	}
	this.dispatchEvent(new ContactsTransferEvent(ContactsTransferEvent.SELECT_GROUP,group));
	
	
}
