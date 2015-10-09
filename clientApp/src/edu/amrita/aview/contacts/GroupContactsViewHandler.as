import com.adobe.utils.StringUtil;

import edu.amrita.aview.contacts.GroupContactsModel;
import edu.amrita.aview.contacts.GroupListModel;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.contacts.vo.GroupUserVO;
import edu.amrita.aview.meeting.itemRenderers.CheckBoxHeaderColumn;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.ListEvent;

[Bindable]
[Embed(source="assets/images/deleteUser.png")]
public var deleteuserIcon:Class;

[Bindable]
[Embed(source="assets/images/addUser.png")]
public var adduserIcon:Class;
[Bindable]
public var add_user:Class=adduserIcon;

[Bindable]
public var delete_user:Class=deleteuserIcon;


/** Icon  for Deleting group in the grouplist */
[Bindable]
[Embed(source="assets/images/group_chat.png")]
public var groupChatIcon:Class;


/** Icon  for Deleting group in the grouplist */
[Bindable]
[Embed(source="assets/images/private_chat.png")]
public var privateChatIcon:Class;


[Bindable]
public var groupContactsModel:GroupContactsModel=null;

private function toggleHeaderSelection():void
{
	var col:CheckBoxHeaderColumn=contactUserList.getCheckBoxHeaderColumn();
	if (groupContactsModel.groupUsers == null)
	{
		return;
	}
	btnPrivateChat.enabled = !col.selected;
	if (col.selected)
	{
		contactUserList.selectedItems=groupContactsModel.groupUsers.toArray();
	}
	else
	{
		contactUserList.selectedItems=[];
	}
}
private function toggleRowSelection(event:ListEvent):void
{
//	if(event.target is CheckBox || event.target is CheckBoxItemrenderer)
//	{
		btnPrivateChat.enabled = !(contactUserList.selectedItems.length > 1);
//	}
}

/**
 *  Display new Component to enter the group name.
 */
protected function startGroupChat(event:MouseEvent):void
{
	if (contactUserList.selectedItems.length > 0)
	{
		var users:ArrayCollection = new ArrayCollection();
		for each(var gUser:GroupUserVO in contactUserList.selectedItems)
		{
			users.addItem(gUser.user);
		}

		this.dispatchEvent(new ContactsEvent(ContactsEvent.START_GROUP_CHAT_BY_MEMBERS,users));
	}
	else
	{
		Alert.show("Please select at least one contact to start group chat", "Information");
	}
}

/**
 *  Display new Component to enter the group name.
 */
protected function startPrivateChat(event:MouseEvent):void
{
	if (contactUserList.selectedItems.length == 1)
	{
		for each(var gUser:GroupUserVO in contactUserList.selectedItems)
		{
			this.dispatchEvent(new ContactsEvent(ContactsEvent.START_PRIVATE_CHAT,gUser.user));
			break;
		}
	}
	else
	{
		Alert.show("Please select one contact to start private chat", "Information");
	}
}


private function filterUserContactList(item:Object):Boolean
{
	if (StringUtil.trim(filterContactList.text) == "")
	{
		return true;
	}
	var itemtext:String=String(item.user.userDisplayName).toLowerCase();
	return itemtext.indexOf(StringUtil.trim(filterContactList.text)) > -1;
}
protected function filterContactListClickHandler():void
{
	if(filterContactList.text == "" || filterContactList.text == "Filter Contacts")
	{
		filterContactList.text="";
		filterContactList.setStyle("color", '#000000');
		filterContactList.setStyle("fontStyle", 'normal');
	}
}

private function focusOutfilterContactList():void
{
	if (StringUtil.trim(filterContactList.text) == "")
	{
		filterContactList.text="Filter Contacts";
		filterContactList.setStyle("color", '#949494');
		filterContactList.setStyle("fontStyle", 'italic');
	}
}

private function removeUserListCheckboxSelection():void
{
	var col:CheckBoxHeaderColumn=contactUserList.getCheckBoxHeaderColumn();
	col.selected=false;
}
private function clearGroupContactsFilter():void
{
	groupContactsModel.groupUsers.filterFunction=null;
	groupContactsModel.groupUsers.refresh();
}
private function search(event:Event):void
{	
		groupContactsModel.groupUsers.filterFunction=filterUserContactList;
		groupContactsModel.groupUsers.refresh();
	
}
protected function addingUsers(event:MouseEvent):void
{
	if(groupContactsModel.currentGroup!=null)
	{
		this.dispatchEvent(new ContactsEvent(ContactsEvent.ADD_USER,groupContactsModel.currentGroup));
	}
}
protected function deleteClickHandler():void
{
	groupContactsModel.selectedUsers=new ArrayCollection(contactUserList.selectedItems);
	if(groupContactsModel.selectedUsers!=null)
	{
		this.dispatchEvent(new ContactsEvent(ContactsEvent.DELETE_USERS,groupContactsModel.selectedUsers));
	}
}
public function updateViewOnGroupSelection():void
{
	if(imgAddUser==null)
		return;
	if(groupContactsModel.currentGroup.contactGroupName==GroupListModel.ALL_CONTACTS)
	{
		imgAddUser.visible=false;
		imgDeleteContacts.visible=false;
	}
	else
	{
		imgAddUser.visible=true;
		imgDeleteContacts.visible=true;
	}
}
