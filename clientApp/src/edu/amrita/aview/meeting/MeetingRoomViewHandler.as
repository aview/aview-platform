import com.adobe.utils.StringUtil;

import edu.amrita.aview.common.components.autoComplete.CustomEvent;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.meeting.MeetingRoomController;
import edu.amrita.aview.meeting.MeetingRoomListModel;
import edu.amrita.aview.meeting.MeetingRoomModel;
import edu.amrita.aview.meeting.MeetingScheduleController;
import edu.amrita.aview.meeting.MeetingsListModel;
import edu.amrita.aview.meeting.events.CommonEvent;
import edu.amrita.aview.meeting.events.MeetingEvent;
import edu.amrita.aview.meeting.events.MeetingRoomEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.ModuleEvent;

[Bindable]
[Embed(source="assets/images/addPeople.png")]
public var addPeopleIcon:Class;
[Bindable]
public var add_People:Class=addPeopleIcon;



/** Icon  for edit meeting */
[Bindable]
[Embed(source="assets/images/editMeeting.png")]
public var editMeetIcon:Class;
[Bindable]
public var edit_Meet:Class=editMeetIcon;


/** Icon  for deleting user from group */
[Bindable]
[Embed(source="assets/images/deleteUser.png")]
public var deleteuserIcon:Class;
[Bindable]
public var delete_user:Class=deleteuserIcon;

[Bindable]
public var meetingRoomModel:MeetingRoomModel=null;

public var contactEventMap:EventMap=null;
private function creationCompleteHandler(event:Event):void
{
	contactEventMap.registerInitiator(this,"searchMembers","meetingRoom");
	contactEventMap.registerInitiator(this,"searchMeetings","meetingRoom");
	contactEventMap.registerInitiator(this,MeetingEvent.DELETE_MEETING,"MeetingsList");
	contactEventMap.registerInitiator(this,MeetingRoomEvent.DELETE_MEMBERS,"MeetingMembers");
	changeTabSelection();
	
}
public function setMeetingButtons():void
{
	if(ClassroomContext.aviewClass.classId!=0)
	{
		meetNowBtn.visible=false;
		meetNowBtn.includeInLayout=false;
		meetLaterBtn.visible=false;
		meetLaterBtn.includeInLayout=false;
	}
	else
	{
		meetNowBtn.visible=true;
		meetNowBtn.includeInLayout=true;
		meetLaterBtn.visible=true;
		meetLaterBtn.includeInLayout=true;
	}
}
public function allMeetingsSelectionHandler():void
{
	meetingsRadioBtn.selected =true;
	showImageForDelete(false);
	showImageForEditMeeting(false);
	if(contactRadioBtn.selected)
	{
		changeTabSelection();
	}
	resetFilterText();
}
public function meetingRoomSelectionHandler():void
{
	showImageForDelete(true);
	if(meetingsRadioBtn.selected)
	{
		showImageForEditMeeting(true);
		
	}
	resetFilterText();
}
public function changeTabSelection():void
{
	
	if (meetingsRadioBtn.selected == true)
	{
		meetingsRadioBtn.setStyle("color", "#026293");
		contactRadioBtn.setStyle("color", "#3e3e3e");
		showImageForAddPeople(false);
		searchContacts.text="Filter Meetings";
		contactContainer.setStyle("backgroundColor", '#FFFFFF');
		vskMeetings.selectedIndex=0;
		meetingContainer.setStyle("backgroundColor", '#F0F0F0');
		if(this.meetingRoomModel.meetingRoomName!=MeetingRoomListModel.ALL_MEETINGS)
		{
			showImageForEditMeeting(true);
		}
		this.meetingRoomModel.selectedOption="Meetings";
	}
	else
	{
		meetingsRadioBtn.setStyle("color", "#3e3e3e");
		contactRadioBtn.setStyle("color", "#026293");
		showImageForAddPeople(true);
		searchContacts.text="Filter Contacts";
		meetingContainer.setStyle("backgroundColor", '#FFFFFF');
		vskMeetings.selectedIndex=1;
		contactContainer.setStyle("backgroundColor", '#F0F0F0');
		showImageForEditMeeting(false);
		this.meetingRoomModel.selectedOption="Contacts";
	}
	this.meetingRoomModel.setMeetingTitleAndPrefix();
	this.dispatchEvent(new CommonEvent(CommonEvent.SELECTED,null));
}


private function showImageForEditMeeting(flag : Boolean) : void
{
	if(imgEditMeet!=null)
	{
		imgEditMeet.visible = flag;
		imgEditMeet.includeInLayout = flag;
	}
}

private function showImageForAddPeople(flag : Boolean) : void
{
	if(imgAddPpl)
	{
		imgAddPpl.visible = flag;
		imgAddPpl.includeInLayout = flag;
	}
}
private function showImageForDelete(flag : Boolean) : void
{
	if(imgDeleteUsers)
	{
		imgDeleteUsers.visible = flag;
		imgDeleteUsers.includeInLayout = flag;
	}
}
protected function clearClick():void
{
	
	if(searchContacts.text == "Filter Contacts" || 
		searchContacts.text == "Filter Meetings")
	{
		searchContacts.text="";
	}
	searchContacts.setStyle("color", '#000000');
	searchContacts.setStyle("fontStyle", 'normal');
}
private function focusOutContactsText():void
{
	if (StringUtil.trim(searchContacts.text) == "")
	{
		resetFilterText();
	}
}
private function resetFilterText():void
{
	if (meetingRoomModel.selectedOption == "Meetings")
	{
		searchContacts.text="Filter Meetings";			
		
	}
	else
	{
		searchContacts.text="Filter Contacts";
	}
	searchContacts.setStyle("color", '#949494');
	searchContacts.setStyle("fontStyle", 'italic');
}

private function editScheduledMeeting(event:Event):void
{	
	this.dispatchEvent(new MeetingEvent(MeetingEvent.EDIT_MEETING,null));
}

private function search(event:Event):void
{
	if(meetingRoomModel.selectedOption=="Meetings")
	{
		this.dispatchEvent(new CustomEvent("searchMeetings",searchContacts.text));
	}
	else		
		this.dispatchEvent(new CustomEvent("searchMembers",searchContacts.text));
}

	
/**
 * Start the meeting.
 * Check that users are seleted to invite. If yes,enter the meeting.
 * Else show an alert message to select users for invite.
 */
protected function meetNowHandler(event:MouseEvent):void
{
	
	if (ClassroomContext.aviewClass==null ||ClassroomContext.aviewClass.classId==0 )
	{
		if (meetingRoomModel.currentMeetingRoom==null ||
		    meetingRoomModel.currentMeetingRoom.meetingRoomName==MeetingRoomListModel.ALL_MEETINGS)
		{
			Alert.show("Please select atleast one meeting room from your room(s) to start meeting", "Information");
			return;
		}
		if(meetingRoomModel.currentMeetingRoom.meetingRoomMembers==null ||
	 	meetingRoomModel.currentMeetingRoom.meetingRoomMembers.length==0)		
		{
			Alert.show("You can not start a meeting without any participants.", "WARNING");
			return;
		}
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.START_ADHOC_MEETING,meetingRoomModel.currentMeetingRoom));
	}
	else
	{
		Alert.show("You cannot start a meeting now as you are already taking part in a meeting session. " +
			"Please exit from the meeting session to start the meeting", "Alert");
	}
	
	
}

/**
 * Start the meeting.
 * Check that users are seleted to invite. If yes,enter the meeting.
 * Else show an alert message to select users for invite.
 */
protected function meetLaterHandler(event:MouseEvent):void
{
	if (ClassroomContext.aviewClass==null || ClassroomContext.aviewClass.classId==0)
	{
		if (meetingRoomModel.currentMeetingRoom==null ||
			meetingRoomModel.currentMeetingRoom.meetingRoomName==MeetingRoomListModel.ALL_MEETINGS)
		{
			Alert.show("Please select atleast one meeting room from your room(s) to schedule meeting", "Information");
			return;
		}
		if(meetingRoomModel.currentMeetingRoom.meetingRoomMembers==null ||
			meetingRoomModel.currentMeetingRoom.meetingRoomMembers.length==0)		
		{
			Alert.show("You can not schedule a meeting without any participants.", "WARNING");
			return;
		}
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.SCHEDULE_MEETING,meetingRoomModel.currentMeetingRoom));
	}
	else
	{
		Alert.show("You cannot schedule a meeting now as you are already taking part in a meeting session. " +
			"Please exit from the meeting session to start the meeting", "Alert");
	}
	
}
protected function addPeopleToMeeting(event:MouseEvent):void
{
	this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.ADD_PEOPLE_MEETINGROOM,this.meetingRoomModel.currentMeetingRoom));
}
/**
 * click handler for delete button of contacts or meetings
 */
private function deleteClickHandler():void
{
	if(vskMeetings.selectedIndex==0 )
	{
		this.dispatchEvent(new MeetingEvent(MeetingEvent.DELETE_MEETING,null));	}
	else
	{
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.DELETE_MEMBERS,meetingRoomModel.currentMeetingRoom));

	}
}

