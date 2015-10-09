import edu.amrita.aview.common.components.autoComplete.CustomEvent;
import edu.amrita.aview.contacts.ContactsSelectionModel;
import edu.amrita.aview.contacts.vo.GroupUserVO;
import edu.amrita.aview.contacts.vo.GroupVO;

import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.managers.PopUpManager;

[Bindable]
public var contactsSelectionModel:ContactsSelectionModel=null;

private function init():void
{
	contactList.addEventListener('expandRoom',expandGroup);
	contactList.addEventListener('colapseRoom',collapseGroup);
	contactList.addEventListener('toggleSelection',toggleSelection);
}

private function toggleSelection(event:CustomEvent):void
{
	var selected:Boolean=event.data as Boolean;
	
	if(contactList.selectedItem != null)
	{
		if(contactList.selectedItem is GroupVO)
		{
			var group:GroupVO = contactList.selectedItem as GroupVO;
			group.isSelected=selected;
			for(var uIdx:int = 0;uIdx < group.groupUsers.length; uIdx++)
			{
				var gUser:GroupUserVO = group.groupUsers[uIdx];
				if(gUser.isSelectable)
				{
					gUser.isSelected=selected;
				}
			}
			
			if(!group.isExpanded && selected)
			{
				group.isExpanded = true;
				expandGroup(null);
			}
			
		}
		else
		{
			var gUser:GroupUserVO = contactList.selectedItem as GroupUserVO;
			gUser.isSelected=selected;
		}
		refreshVisibleContacts();
	}
}

private function refreshVisibleContacts():void
{
	var currScrollPos:Number = contactList.verticalScrollPosition;
	contactsSelectionModel.visibleContacts.refresh();
	contactList.verticalScrollPosition = currScrollPos;
}

private function expandGroup(event:CustomEvent):void
{
	if(contactList.selectedItem!=null)
	{
		var group:GroupVO=contactList.selectedItem as GroupVO;
		for (var index:int=0; index < contactsSelectionModel.visibleContacts.length; index++)
		{
			if (index == contactList.selectedIndex)
			{
				if(group.groupUsers.length == 0)
				{
					Alert.show("No Contacts listed in the selected Group","WARNING");
					if(group.isExpanded)
					{
						group.isExpanded = false;
					}
					return;
				}
				for (var index1:int=0; index1 < group.groupUsers.length; index1++)
				{
					var gUser:GroupUserVO=group.groupUsers[index1] as GroupUserVO;
					contactsSelectionModel.visibleContacts.addItemAt(gUser, index + index1+1);
				}
				break;
			}
		}
	}
}

private function collapseGroup(event:CustomEvent):void
{
	for (var index:int=0; index < contactsSelectionModel.visibleContacts.length; index++)
	{
		if (contactList.selectedIndex == index)
		{
			for (var i:int=index + 1; i < contactsSelectionModel.visibleContacts.length; i++)
			{
				if (contactsSelectionModel.visibleContacts[i] is GroupUserVO)
				{
					contactsSelectionModel.visibleContacts.removeItemAt(i);
					i--;
				}
				else
				{
					break;
				}
			}
		}
	}
}

private function closeWindow(event:MouseEvent):void
{
	PopUpManager.removePopUp(this);
}

private function saveSelection():void
{
	PopUpManager.removePopUp(this);
}
