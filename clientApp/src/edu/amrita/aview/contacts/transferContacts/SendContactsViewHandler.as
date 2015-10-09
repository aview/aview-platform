import edu.amrita.aview.contacts.events.ContactsTransferEvent;
import edu.amrita.aview.contacts.events.SearchEvent;
import edu.amrita.aview.contacts.search.SearchModel;
import edu.amrita.aview.contacts.transferContacts.SendContactsModel;
import edu.amrita.aview.core.gclm.vo.UserVO;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.utils.ArrayUtil;
import mx.utils.StringUtil;

[Bindable]
private var sendContactsModel:SendContactsModel=null;
private var userVO:UserVO

public function init(sendContactsModel:SendContactsModel,userVO:UserVO):void
{
	this.userVO=userVO;
	this.sendContactsModel=sendContactsModel;
}
public function removePopup():void
{
	this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
	PopUpManager.removePopUp(this);
}
public function searchUsers():void
{
	if(txtSearchInput.text==null || txtSearchInput.text==""||StringUtil.trim(txtSearchInput.text)=="")
	{
		Alert.show("Please enter a name to search","Information");
		return;
	}
	sendContactsModel.searchKey=txtSearchInput.text;
	this.dispatchEvent(new SearchEvent(SearchEvent.SEARCH_EVENT));
}
public function setSelectedUsers():void
{
	if(sendContactsModel.selectedUsers==null)
	{
		sendContactsModel.selectedUsers=new ArrayCollection();
	}
	for(var i:int=0;i<lstUsers.selectedItems.length;i++)
	{
		var selectedUser:UserVO=lstUsers.selectedItems[i] as UserVO;
		var isUserExist:Boolean=false;
		for(var j:int=0;j<sendContactsModel.selectedUsers.length;j++)
		{
			if(selectedUser.userId==sendContactsModel.selectedUsers.getItemAt(j).userId)
			{
				isUserExist=true;
				break;
			}
		}
		if(!isUserExist)
		
			sendContactsModel.selectedUsers.addItem(lstUsers.selectedItems[i]);
		
	}
}
public function sendContactsToSelectedUsers():void
{
	if(validateSelectedUsers())
	{
		this.dispatchEvent(new ContactsTransferEvent(ContactsTransferEvent.SEND_GROUP));
	}
}
private function validateSelectedUsers():Boolean
{
	for(var index:int=0;index<sendContactsModel.selectedUsers.length;index++)
	{
		if(sendContactsModel.selectedUsers.getItemAt(index).userId==userVO.userId)
		{
			Alert.show("Please Remove your name from the list and try again!","Information");
			return false;
		}
	}
	return true;
}
private function txtSearchInputKeyUpHandler(event:KeyboardEvent):void
{
	if(event.keyCode==Keyboard.ENTER)
	{
		searchUsers();
	}
}