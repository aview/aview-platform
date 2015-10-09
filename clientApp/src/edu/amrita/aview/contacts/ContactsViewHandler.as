// ActionScript file
import edu.amrita.aview.core.shared.events.ChatEvent;
//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.meeting.events.CommonEvent;

import flash.events.MouseEvent;

import mx.events.FlexEvent;
[Bindable]
[Embed(source="/edu/amrita/aview/common/assets/images/activeTab.jpg")]
public var activeTab:Class;
[Bindable]
[Embed(source="/edu/amrita/aview/common/assets/images/tabBg.jpg")]
public var inactiveTab:Class;	

[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/groupActive.png")]
public var groupTabIconActive:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/groupDisabled.png")]
public var groupTabIconDisabled:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/roomActive.png")]
public var roomTabIconActive:Class;

[Bindable]
[Embed(source="/edu/amrita/aview/contacts/assets/images/roomDisabled.png")]
public var roomTabIconDisabled:Class;
private var eventMap:EventMap = null;

public function initContacts(eventMap:EventMap):void
{		
	this.eventMap = eventMap;
	this.eventMap.registerInitiator(this, ChatEvent.INITIATE_GROUP_CHAT);
}


private function getBackground(value:int):void
{
	if (value==0)
	{
		meetingTab.setStyle('backgroundImage',activeTab);
		contactTab.setStyle('backgroundImage',inactiveTab);
	}
	else
	{
		contactTab.setStyle('backgroundImage',activeTab);
		meetingTab.setStyle('backgroundImage',inactiveTab);
	}
}

protected function leftTabBar_clickHandler():void
{	
	this.dispatchEvent(new CommonEvent(CommonEvent.SELECTED,vskLeftTabBar.selectedIndex));	
}
private function setImageForContacts(value:int):Class
{
	if (value == 1)
	{
		return groupTabIconActive;
	}
	else
	{
		return groupTabIconDisabled;
	}
}

private function getFontColorForMeeting(value:int):uint
{
	if (value == 0)
		return 0X026293;
	else
		return 0X3e3e3e;
}

private function getFontColorForContacts(value:int):uint
{
	if (value == 1)
		return 0X026293;
	else
		return 0X3e3e3e;
}
private function setImageForRoom(value:int):Class
{
	if (value == 0)
		return roomTabIconActive;
	else
		return roomTabIconDisabled;
}