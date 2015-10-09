import com.adobe.utils.StringUtil;

import edu.amrita.aview.common.components.autoComplete.CustomEvent;
//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.core.shared.eventmap.EventMap;
//import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.meeting.MeetingMembersModel;
import edu.amrita.aview.meeting.itemRenderers.CheckBoxHeaderColumn;

import mx.collections.ArrayCollection;

[Bindable]
public var meetingMembersModel:MeetingMembersModel=null;

private var contactEventMap:EventMap=null;
private var strSearch:String=null;
public function init(eventMap:EventMap):void
{
	this.contactEventMap=eventMap;
	this.contactEventMap.registerMapListener("searchMembers",onSearchData,"meetingRoom");
}
private function onSearchData(event:CustomEvent):void
{
	strSearch=event.data.toString();
	meetingMembersModel.meetingMembers.filterFunction=filterMeetingContactList;
	meetingMembersModel.meetingMembers.refresh();
}
private function toggleSelectionMeetingMembers():void
{
	var col:CheckBoxHeaderColumn=meetingMembersList.getCheckBoxHeaderColumn();
	
	if (meetingMembersModel.meetingMembers==null)
	{
		return;
	}
	if (col.selected)
	{
		meetingMembersList.selectedItems=meetingMembersModel.meetingMembers.toArray();
		meetingMembersModel.selectedMembers=new ArrayCollection(meetingMembersList.selectedItems);
		
	}
	else
	{
		meetingMembersList.selectedItems=[];		
	}
}
private function setSelectedMeetingMembers():void
{
	meetingMembersModel.selectedMembers=new ArrayCollection(meetingMembersList.selectedItems);
}
private function filterMeetingContactList(item:Object):Boolean
{
	if (StringUtil.trim(strSearch) == "")
	{
		return true;
	}
	var itemtext:String=String(item.user.userDisplayName).toLowerCase();
	return itemtext.indexOf(StringUtil.trim(strSearch)) > -1;
}