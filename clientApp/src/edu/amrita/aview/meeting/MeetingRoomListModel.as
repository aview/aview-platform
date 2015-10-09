package edu.amrita.aview.meeting
{	
	
	
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	[Bindable]
	public class MeetingRoomListModel
	{
		public static const ALL_MEETINGS:String="All Meetings";		
		public var selectedMeetingRoomVO:MeetingRoomVO=null;
		public var allMeetingRoomVOs:ArrayCollection=null;
		public var allMeetingsRoomVO:MeetingRoomVO=null;
		public var allMeetingsCount:int=0;
		
		public function MeetingRoomListModel()
		{
		}
		
		public function processAllMeetingRooms():void
		{
			//Consolidated all the meetings
			var allMeetings:ArrayCollection = new ArrayCollection();
			for (var i:int=0; i < allMeetingRoomVOs.length; i++)
			{
				var meetingRoomVO:MeetingRoomVO = allMeetingRoomVOs[i];
				meetingRoomVO.computePastAndUpcomingMeetings();
				allMeetings.addAll(meetingRoomVO.lecturesAC);
			}
			makeAllMeetingsRoom(allMeetings);
		}
		private function makeAllMeetingsRoom(allMeetings:ArrayCollection):void
		{
			allMeetingsRoomVO = new MeetingRoomVO();
			allMeetingsRoomVO.lecturesAC = allMeetings;
			allMeetingsRoomVO.computePastAndUpcomingMeetings();
			var allMeetingRoom:ClassVO = new ClassVO();
			allMeetingsRoomVO.className = ALL_MEETINGS;
			allMeetingsRoomVO.meetingRoom = allMeetingRoom;
			allMeetingsRoomVO.meetingRoom.className=ALL_MEETINGS;
			allMeetingsCount=allMeetingsRoomVO.meetingCount;
		}
		
		public function setCurrentMeetingRoom(meetingRoomVO:MeetingRoomVO):void
		{
			//Replace the current room with the new room
			selectedMeetingRoomVO =meetingRoomVO;
			
			if(selectedMeetingRoomVO==null)
			
				selectedMeetingRoomVO = allMeetingsRoomVO;	
			
			if(selectedMeetingRoomVO!=null)
			{
				selectedMeetingRoomVO.sortAndRefresh();
			}
		}
		public function updateCurrentMeetingRoom():void
		{
			if(selectedMeetingRoomVO==null)
			{
				return;
			}
			else
			{
				for (var i:int=0; i < allMeetingRoomVOs.length; i++)
				{
					if((allMeetingRoomVOs[i] as MeetingRoomVO ).meetingRoom.classId==selectedMeetingRoomVO.meetingRoom.classId)
					{
						selectedMeetingRoomVO= allMeetingRoomVOs[i] as MeetingRoomVO;
					}
				}
			}
		}


	}
}