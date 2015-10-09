package edu.amrita.aview.meeting
{
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	[Bindable]
	public class MeetingRoomModel
	{
		public var meetingRoomName:String=null;
		public var meetingTitlePrefix:String=null;
		public var meetingTitle:String=null;
		public var selectedOption:String=null;
		public var searchString:String=null;
		public var meetingsCount:int=0;
		public var membersCount:int=0;
		public var currentMeetingRoom:MeetingRoomVO=null;
		public var meetingServersAllocated:Boolean=false;
		public function MeetingRoomModel()
		{
		}		
		
		

		public function setMeetingTitleAndPrefix():void
		{
			if (meetingRoomName != MeetingRoomListModel.ALL_MEETINGS)
			{
				if (selectedOption  == "Meetings")
				{
					meetingTitlePrefix="Meetings in \"";
				}
				else
				{
					meetingTitlePrefix="Contacts in \"";
				}
				meetingTitle =  meetingRoomName+"\"";
			}
			else
			{
				meetingTitlePrefix="";
				meetingTitle = meetingRoomName;
			}
		}
		public function setMeetingRoomProperties():void
		{
			meetingRoomName=currentMeetingRoom.meetingRoomName;
			meetingsCount=currentMeetingRoom.currentAndUpcomingMeetings.length;
			if(currentMeetingRoom.meetingRoomMembers!=null)
			membersCount=currentMeetingRoom.meetingRoomMembers.length;
		}

		


	}
}