import edu.amrita.aview.contacts.ContactsSelectionModel;
import edu.amrita.aview.meeting.MeetingRoomManagerModel;
import edu.amrita.aview.meeting.events.MeetingRoomEvent;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;

import spark.components.Button;

private var _closer:Button=new Button();
private const emailId_regex:RegExp = /([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/;

[Embed(source="assets/images/Medium_close.png")]
[Bindable] public var closePng:Class;

[Embed(source="assets/images/Medium_close_over.png")] 
[Bindable] public var closeOverPng:Class;

[Bindable]
public var meetingRoomManagerModel:MeetingRoomManagerModel=null;

//public var contactsSelectionModel:ContactsSelectionModel = null;


private function init():void
{
	this.addElementAt(_closer,0);
	_closer.width = 18;
	_closer.height = 18;
	_closer.x = this.width - _closer.width - 8;
	_closer.y = -25;
	_closer.toolTip="Close";
	_closer.addEventListener(MouseEvent.CLICK, closeWindow);
	_closer.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
	_closer.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
	_closer.setStyle('icon', closePng);
	_closer.useHandCursor = false;
	if(meetingRoomManagerModel.isEditRoom())
	{
		this.title="Edit MeetingRoom";
		btnOk.label="Save";
	}
	else if(meetingRoomManagerModel.isCreateRoom())
	{
		this.title="Create MeetingRoom";
		btnOk.label="Save";
	}
	else if(meetingRoomManagerModel.isAddContactsGuests()||meetingRoomManagerModel.isAddPeople())
	{
		this.title="Add People";
		if(meetingRoomManagerModel.isAddContactsGuests())
			btnOk.label="Invite";
		else
			btnOk.label="Add";
	}
		
}
private function createOrUpdateRoom():void
{
	
	if(meetingRoomManagerModel.isRoomNameVisible()
		&& validateMeetingRoom())
	{
		if(meetingRoomManagerModel.isEditRoom())
		{
			this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.EDIT_MEETINGROOM));		
			
		}
		else
		{
			this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.CREATE_MEETINGROOM));
		}
	}
	else if(meetingRoomManagerModel.isAddPeople() || meetingRoomManagerModel.isAddContactsGuests())
	{
		if(meetingRoomManagerModel.isAddContactsGuests())
		{
			getGuestEmailIds();
		}
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.EDIT_MEETINGROOM));	
	}
	
}
private function getGuestEmailIds():void
{
	
	var guestMailIds:Array=guestEmail.text.split(",");
	for(var index:int=0;index<guestMailIds.length;index++)
	{
		var guestEmailId:String=StringUtil.trim(guestMailIds[index]);
		if(guestEmailId.match(emailId_regex)!=null && guestEmailId.match(emailId_regex)[0]==guestEmailId)
		{
			if(meetingRoomManagerModel.guestEmailIds==null)
			{
				meetingRoomManagerModel.guestEmailIds=new ArrayCollection;
			}
			meetingRoomManagerModel.guestEmailIds.addItem(guestEmailId);
		}
	}
}
//clear the text box for enter guest user name to search
protected function clearGuestTxtClick():void
{
	if(guestEmail.text == "Enter guest email address")
	{
		guestEmail.text ="";
		guestEmail.setStyle("color", '#000000');
		guestEmail.setStyle("fontStyle", 'normal');
	}
}
private function focusOutGuestText():void
{
	if (StringUtil.trim(guestEmail.text) == "")
	{
		guestEmail.text="Enter guest email address";
		guestEmail.setStyle("color", '#949494');
		guestEmail.setStyle("fontStyle", 'italic');
	}
}


private function validateMeetingRoom():Boolean
{
	if(StringUtil.trim(txtRoomName.text)!="")
	{
		var newRoomName:String=StringUtil.trim(txtRoomName.text).toLocaleLowerCase();		
		return !meetingRoomManagerModel.isRoomNameExist(newRoomName);

	}
	else
	{
		Alert.show("Please enter room name","WARNING");
		return false;
	}
}
private function closeWindow(event:MouseEvent):void
{
	PopUpManager.removePopUp(this);
}

private function mouseOverHandler(event:MouseEvent):void
{
	_closer.setStyle('icon',closeOverPng);
}


private function mouseOutHandler(event:MouseEvent):void
{
	_closer.setStyle('icon',closePng);
}
