//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.meeting.MeetingRoomListModel;
import edu.amrita.aview.meeting.events.MeetingRoomEvent;
import edu.amrita.aview.meeting.vo.MeetingRoomVO;

import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.events.ItemClickEvent;
import mx.events.ListEvent;

[Bindable]
public var meetingRoomListModel:MeetingRoomListModel=null;
[Bindable]
private var allMeetingsCount:int=0;	
private var eventMap:EventMap=null;

public function init(eventMap:EventMap,model:MeetingRoomListModel):void
{
	this.eventMap=eventMap;
	this.eventMap.registerInitiator(this,MeetingRoomEvent.SELECT_MEETINGROOM);
	this.meetingRoomListModel=model;
	if(meetingRoomsList.selectedIndex==-1)
	{
		allMeeting_clickHandler(null);
	}
}

private function createRoomBtnHandler(event:MouseEvent):void
{
	this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.CREATE_MEETINGROOM,meetingRoomsList.selectedItem as MeetingRoomVO));
}
public function allMeeting_clickHandler(event:MouseEvent):void
{
	allRoomContainer.setStyle('backgroundColor', '#E3EEFA');	
	if(this.meetingRoomListModel!=null && this.meetingRoomListModel.allMeetingsRoomVO!=null)
	{
		meetingRoomsList.selectedIndex=-1;
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.SELECT_MEETINGROOM,this.meetingRoomListModel.allMeetingsRoomVO));
	}
}
private function meetingRoomClickHandler(event:ListEvent):void
{
	if(meetingRoomsList.selectedItem!=null){
		this.meetingRoomListModel.selectedMeetingRoomVO=meetingRoomsList.selectedItem as MeetingRoomVO;
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.SELECT_MEETINGROOM,meetingRoomListModel.selectedMeetingRoomVO));
	}
}
private function editMeetingRoomHandler(event:MouseEvent):void
{
	if(meetingRoomsList.selectedItem!=null)
	{	this.meetingRoomListModel.selectedMeetingRoomVO=meetingRoomsList.selectedItem as MeetingRoomVO;
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.EDIT_MEETINGROOM,this.meetingRoomListModel.selectedMeetingRoomVO));
	}
	else
	{
		Alert.show("Please select a meeting room to edit","Information");
	}
}
private function deleteMeetingRoombtnHandler(event:MouseEvent):void
{
	if(meetingRoomsList.selectedItem!=null)
	{
		this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.DELETE_MEETINGROOM,meetingRoomsList.selectedItem as MeetingRoomVO));
	}
	else
	{
		Alert.show("Please select a meeting room to delete","Information");
	}
}
public function setCurrentMeetingRoom():void
{	
	var selectedRoomVO:MeetingRoomVO=meetingRoomListModel.selectedMeetingRoomVO;
 	if(selectedRoomVO!=null)
 	{
	 	for(var index:int=0;index<meetingRoomListModel.allMeetingRoomVOs.length;index++)
	 	{
		 	var currentRoomVO:MeetingRoomVO=meetingRoomListModel.allMeetingRoomVOs[index] ;
		 	if(selectedRoomVO.meetingRoom.classId==currentRoomVO.meetingRoom.classId)
		 	{
			 	meetingRoomsList.selectedIndex=index;
			 	break;
		 	}
	 	}
 	}
}
