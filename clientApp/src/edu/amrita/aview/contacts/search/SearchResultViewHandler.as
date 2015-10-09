// ActionScript file
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.contacts.search.SearchModel;
import edu.amrita.aview.contacts.search.SearchResultModel;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.meeting.itemRenderers.CheckBoxHeaderColumn;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

[Bindable]
public var searchResultModel:SearchResultModel=null;


private function init():void
{
	this.addEventListener(CloseEvent.CLOSE, closeSearchComp);
	var sort:Sort=new Sort();
	sort.compareFunction=userArrCompare;

}
private function closeSearchComp(event:Event):void
{
	PopUpManager.removePopUp(this);
}
private function cancel():void
{
	this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
}

protected function add():void
{
	
	if (userGrid.selectedItems != null && userGrid.selectedItems.length > 0)
	{
		btnAddToContact.enabled = false;
		searchResultModel.selectedUsers=new ArrayCollection(userGrid.selectedItems);
		this.dispatchEvent(new ContactsEvent(ContactsEvent.ADD_USER, userGrid.selectedItems));
	}
	else if (userGrid.selectedItem)
	{
		btnAddToContact.enabled = false;
		searchResultModel.selectedUsers=new ArrayCollection();
		searchResultModel.selectedUsers.addItem(userGrid.selectedItem);
		this.dispatchEvent(new ContactsEvent(ContactsEvent.ADD_USER, userGrid.selectedItem));
	}
	else
	{
		Alert.show("Please select a user to add", "Information");
	}
}

private function toggleSelectionContactList():void
{
	var col:CheckBoxHeaderColumn=userGrid.getCheckBoxHeaderColumn();
	if (searchResultModel.users == null)
	{
		return;
	}
	if (col.selected)
	{
		userGrid.selectedItems=searchResultModel.users.toArray();
	}
	else
	{
		userGrid.selectedItems=[];
	}
	searchResultModel.selectedUsers=new ArrayCollection(userGrid.selectedItems);
}
private function userArrCompare(item1:Object,item2:Object,filters:Array=null):int
{
	if(item1.userStatus==Constants.ONLINE && item2.userStatus==Constants.BUSY)
	{
		return -1;
	}
	else if(item1.userStatus==Constants.ONLINE && item2.userStatus==Constants.OFFLINE )
	{
		return -1;
	}
	else if(item1.userStatus==Constants.BUSY && item2.userStatus==Constants.OFFLINE)
	{
		return -1;
	}
	else if(item1.userStatus==Constants.OFFLINE && item2.userStatus==Constants.ONLINE)
	{
		return 1;
	}
	else if(item1.userStatus==Constants.BUSY && item2.userStatus==Constants.ONLINE)
	{
		return 1;
	}
	else if(item1.userStatus==Constants.OFFLINE && item2.userStatus==Constants.BUSY)
	{
		return 1;
	}
	else
		return 0;
	
}
public function enableAddButton():void
{
	btnAddToContact.enabled=true;
}