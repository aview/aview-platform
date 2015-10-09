package edu.amrita.aview.meeting
{
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class MeetingScheduleModel
	{
		public var startDate:Date=new Date();
		public var startTime:Date=new Date();
		public var endDate:Date=new Date();
		public var endTime:Date=new Date();
		public var weekDays:String=null;
		public var guestMailIds:ArrayCollection=null;
		public var meetingName:String=null;
		public var selectedRoom:MeetingRoomVO=null;
		public var selectedSchedule:LectureVO=null;
		//This variable is used to differentiate beween adhoc meeting
		// and scheduled meeting
		public var isScheduledMeeting:Boolean=false;
		
		public var isEditScheduledMeeting:Boolean=false;
		
		public function MeetingScheduleModel()
		{
		}
		
		public function getMemberRegistrationId(userId:Number):Number
		{
			for(var index:int=0;index<selectedRoom.meetingRoomMembers.length;index++)
			{
				if(selectedRoom.meetingRoomMembers[index].user.userId==userId)
				{
					return selectedRoom.meetingRoomMembers[index].classRegisterId;
				}
			}
			return -1;
		}
		
	}
}