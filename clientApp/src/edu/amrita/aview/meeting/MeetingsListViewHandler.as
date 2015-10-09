import com.adobe.utils.StringUtil;

import edu.amrita.aview.common.components.autoComplete.CustomEvent;
//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.meeting.MeetingScheduleModel;
import edu.amrita.aview.meeting.MeetingsListModel;
import edu.amrita.aview.meeting.itemRenderers.CheckBoxHeaderColumn;
import edu.amrita.aview.meeting.itemRenderers.CheckBoxRenderer;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.ItemClickEvent;
import mx.events.ListEvent;

[Bindable]
public var meetingsListModel:MeetingsListModel=null;
public var contactModuleEventMap:EventMap=null;

private var strSearch:String=null;

public function init(moduleEventMap:EventMap):void
{
	contactModuleEventMap=moduleEventMap;
	contactModuleEventMap.registerMapListener("searchMeetings",onSearchMeetings,"meetingRoom");
}
private function toggleSelectionMeetingList():void
{
	var col:CheckBoxHeaderColumn=meetingsList.getCheckBoxHeaderColumn();
	
	if (meetingsListModel.allMeetings == null)
	{
		return;
	}
	if (col.selected)
	{
		meetingsList.selectedItems=meetingsListModel.allMeetings.toArray();
		meetingsListModel.selectedMeetings=new ArrayCollection(meetingsList.selectedItems);	
	}
	else
	{
		meetingsList.selectedItems=[];		
	}	
}
private function onSearchMeetings(event:CustomEvent):void
{
	strSearch=event.data.toString();
	meetingsListModel.currentAndUpcomingMeetings.filterFunction=filterMeetingContactList;
	meetingsListModel.pastMeetings.filterFunction=filterMeetingContactList;
	meetingsListModel.pastMeetings.refresh();
	meetingsListModel.currentAndUpcomingMeetings.refresh();
}
private function formatDate(item:Object, data:Object):String
{
	var sDate:String=dateFormatter.format(item.startDate) + '  ' + timeFormatter.format(item.startTime);
	return sDate;
}
protected function meetingsList_changeHandler(event:Event):void
{	
	meetingsListModel.selectedMeetings=new ArrayCollection(meetingsList.selectedItems);	
}
private function filterMeetingContactList(item:Object):Boolean
{
	if (StringUtil.trim(strSearch) == "")
	{
		return true;
	}
	var itemtext:String=String(item.displayName).toLowerCase();
	return itemtext.indexOf(StringUtil.trim(strSearch)) > -1;
}
