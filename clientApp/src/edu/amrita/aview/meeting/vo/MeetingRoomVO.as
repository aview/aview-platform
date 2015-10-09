package edu.amrita.aview.meeting.vo
{
	
	
	import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	[RemoteClass(alias="edu.amrita.aview.meeting.vo.MeetingRoomVO")]
	public dynamic class MeetingRoomVO
	{
		public function MeetingRoomVO()
		{
		}
		private var _lecturesAC:ArrayCollection = null;
		private var _meetingRoom:ClassVO = null;
		private var _meetingRoomMembers:ArrayCollection=null;

		private var _pastMeetings:ArrayCollection = null;
		private var _currentAndUpcomingMeetings:ArrayCollection = null;
		private var _meetingCount:int = 0;
		

		public function get meetingRoom():ClassVO
		{
			return _meetingRoom;
		}

		public function set meetingRoom(value:ClassVO):void
		{
			_meetingRoom = value;
		}

		public function get lecturesAC():ArrayCollection
		{
			return _lecturesAC;
		}

		public function set lecturesAC(value:ArrayCollection):void
		{
			_lecturesAC = value;
		}

		
		public function get pastMeetings():ArrayCollection
		{
			return _pastMeetings;
		}

		
		public function get currentAndUpcomingMeetings():ArrayCollection
		{
			return _currentAndUpcomingMeetings;
		}

		public function computePastAndUpcomingMeetings():void
		{
			_pastMeetings = new ArrayCollection();
			_currentAndUpcomingMeetings = new ArrayCollection();
			if(_lecturesAC !=null)
			for (var i:int=0; i < _lecturesAC.length; i++)
			{
				var startDate:Date=_lecturesAC[i].startDate;
				var endTime:Date=_lecturesAC[i].endTime;
				var endDate:Date=new Date(startDate.fullYear, startDate.month, startDate.date, endTime.hours, endTime.minutes, endTime.seconds);
				//TODO: Need to change current date 
				if (endDate.time <= new Date().time)
				{
					_pastMeetings.addItem(_lecturesAC[i]);
				}
				else
				{
					_currentAndUpcomingMeetings.addItem(_lecturesAC[i]);
				}
			}
			
			_meetingCount = currentAndUpcomingMeetings.length;
		}
		
		public function sortAndRefresh():void
		{
			if (_currentAndUpcomingMeetings.length > 0)
			{
				var sort:Sort=new Sort();
				var nameSort:SortField=new SortField("startDate", false);
				nameSort.descending=false;
				nameSort.numeric=true;
				sort.fields=[nameSort];
				_currentAndUpcomingMeetings.sort=sort;
			}
			
			pastMeetings.refresh();
			currentAndUpcomingMeetings.refresh();
		}

		public function get meetingCount():int
		{
			return _meetingCount;
		}
		
		public function get meetingRoomName():String
		{
			return meetingRoom.className;
		}

		public function get meetingRoomMembers():ArrayCollection
		{
			return _meetingRoomMembers;
		}

		public function set meetingRoomMembers(value:ArrayCollection):void
		{
			_meetingRoomMembers = value;
		}
		
		public function getMeetingRoomUsers():ArrayCollection
		{
			var users:ArrayCollection = new ArrayCollection;
			for each (var member:ClassRegisterVO in _meetingRoomMembers)
			{
				users.addItem(member.user);
			}
			return users;
		}

	}
}