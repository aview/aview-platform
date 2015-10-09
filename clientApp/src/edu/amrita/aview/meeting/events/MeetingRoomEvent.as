package edu.amrita.aview.meeting.events
{
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import flash.events.Event;
	
	public class MeetingRoomEvent extends Event
	{
		public static const CREATE_MEETINGROOM:String="MeetingRoomCreate";
		public static const CREATED_MEETINGROOM:String="MeetingRoomCreated";
		public static const EDIT_MEETINGROOM:String="MeetingRoomEdit";
		public static const ADD_PEOPLE_MEETINGROOM:String="AddPeopleMeetingRoom";
		public static const EDITED_MEETINGROOM:String="MeetingRoomEdited";
		public static const DELETE_MEETINGROOM:String="MeetingRoomDelete";		
		public static const DELETED_MEETINGROOM:String="MeetingRoomDeleted";	
		public static const SELECT_MEETINGROOM:String="MeetingRoomSelect";
		public static const SCHEDULE_MEETING:String="ScheduleMeeting";
		public static const START_ADHOC_MEETING:String="ADHOCMeeting";
		
		public static const DELETE_MEMBERS:String="DeleteMembers";
		
		private  var _currentMeetingRoom:MeetingRoomVO=null;
		
		public function MeetingRoomEvent(type:String,meetingRoom:MeetingRoomVO=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._currentMeetingRoom=meetingRoom;
		}

		public function get selectedMeetingRoom():MeetingRoomVO
		{
			return _currentMeetingRoom;
		}

	}
}