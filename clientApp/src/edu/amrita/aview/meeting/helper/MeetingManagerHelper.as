package edu.amrita.aview.meeting.helper
{
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class MeetingManagerHelper extends AbstractHelper
	{
		
		private var _meetingRO:RemoteObject
		public function MeetingManagerHelper()
		{
			_meetingRO = new RemoteObject();
			_meetingRO.destination = "meetingManagerHelper"; 
			_meetingRO.endpoint = ClassroomContext.WEBAPP_AVIEW_END_POINT;
			_meetingRO.showBusyCursor = true;			
			_meetingRO.createMeetingRoom.addEventListener(ResultEvent.RESULT,createMeetingResultHandler);
			_meetingRO.createMeetingRoom.addEventListener(FaultEvent.FAULT,createMeetingFaultHandler);
			_meetingRO.createAdhocMeeting.addEventListener(ResultEvent.RESULT,createAdhocMeetingResultHandler);
			_meetingRO.createAdhocMeeting.addEventListener(FaultEvent.FAULT,createAdhocMeetingFaultHandler);
			_meetingRO.getMeetingRoomsForModerator.addEventListener(ResultEvent.RESULT,getMeetingRoomsResultHandler);
			_meetingRO.getMeetingRoomsForModerator.addEventListener(FaultEvent.FAULT,getMeetingRoomsFaultHandler);
			_meetingRO.getMeetingRoomMembers.addEventListener(ResultEvent.RESULT,getMeetingRoomMembersResultHandler);
			_meetingRO.getMeetingRoomMembers.addEventListener(FaultEvent.FAULT,getMeetingRoomMembersFaultHandler);
			_meetingRO.createMeetingSchedule.addEventListener(ResultEvent.RESULT,createMeetingScheduleResultHandler);
			_meetingRO.createMeetingSchedule.addEventListener(FaultEvent.FAULT,createMeetingScheduleFaultHandler);
			_meetingRO.deleteMeetings.addEventListener("result", deleteMeetingsResultHandler);
			_meetingRO.deleteMeetings.addEventListener("fault", deleteMeetingsFaultHandler);
			_meetingRO.removeMeetingAttendees.addEventListener(ResultEvent.RESULT,removeMeetingAttendeesResultHandler);
			_meetingRO.removeMeetingAttendees.addEventListener(FaultEvent.FAULT,removeMeetingAttendeesFaultHandler);
			_meetingRO.updateMeetingRoom.addEventListener(ResultEvent.RESULT,updateMeetingRoomResultHandler);
			_meetingRO.updateMeetingRoom.addEventListener(FaultEvent.FAULT,updateMeetingRoomFaultHandler);
			_meetingRO.updateMeetingSchedule.addEventListener(ResultEvent.RESULT,updateMeetingScheduleResultHandler);
			_meetingRO.updateMeetingSchedule.addEventListener(FaultEvent.FAULT,updateMeetingScheduleFaultHandler);
			//Fix for Bug #13291 start
			_meetingRO.deleteMeetingRoom.addEventListener(ResultEvent.RESULT,deleteMeetingRoomResultHandler);
			_meetingRO.deleteMeetingRoom.addEventListener(FaultEvent.FAULT,deleteMeetingRoomFaultHandler);
			//Fix for Bug #13291 end
			
			//Fix for Bug #13457 start
			_meetingRO.endMeeting.addEventListener(ResultEvent.RESULT,endMeetingResultHandler);
			_meetingRO.endMeeting.addEventListener(FaultEvent.FAULT,endMeetingFaultHandler);
			//Fix for Bug #13457 end
			
			_meetingRO.getMeetingsForModerator.addEventListener(ResultEvent.RESULT,getMeetingsForModeratorResultHandler);
			_meetingRO.getMeetingsForModerator.addEventListener(FaultEvent.FAULT,getMeetingsForModeratorFaultHandler);
		}
		
		public function createMeeting(aviewClass:ClassVO,
									   meetingMemberIds:ArrayCollection,
									   guestMembersIds:ArrayCollection,
									   creatorId:Number,
		                               callerComp:Object):void
		{
			var token:AsyncToken=_meetingRO.createMeetingRoom(aviewClass,meetingMemberIds,guestMembersIds,creatorId);
			token.caller=callerComp;
		}
		
		
		private function createMeetingResultHandler(event:ResultEvent):void
		{
			event.token.caller.createMeetingResultHandler(event);
		}
		private function createMeetingFaultHandler(event:FaultEvent):void
		{
			event.token.caller.createMeetingFaultHandler(event);
		}
		
		public function getMeetingRoomMembers(callerComp:Object,classId:Number,moderatorId:Number):void
		{
			var token:AsyncToken=_meetingRO.getMeetingRoomMembers(classId,moderatorId);
			token.caller=callerComp;
		}
		
		public function createMeetingSchedule(callerComp:Object,aviewClass:ClassVO,
											  guestMailIds:ArrayCollection,
											  lectureName:String,
											  weekDays:String,
											  scheduleStartDate:Date,
											  scheduleEndDate:Date,
											  startTime:Date,
											  endTime:Date,
											  moderatorId:Number):void
		{
			var token:AsyncToken=_meetingRO.createMeetingSchedule(aviewClass,guestMailIds,lectureName,
				weekDays,scheduleStartDate,scheduleEndDate,startTime,endTime,moderatorId);
			token.caller=callerComp;
		}
		
		public function getMeetingRoomMembersResultHandler(event:ResultEvent):void
		{
			event.token.caller.getMeetingRoomMembersResultHandler(event.result);
		}
		public function getMeetingRoomMembersFaultHandler(event:FaultEvent):void
		{
			
		}
		public function deleteMeetings(callerComp:Object,meetings:ArrayCollection):void
		{
			var token:AsyncToken = _meetingRO.deleteMeetings(meetings);
			token.caller = callerComp;
		}
		public function getMeetingRooms(callerComp:Object,userId:Number):void
		{
			var token:AsyncToken=_meetingRO.getMeetingRoomsForModerator(userId);
			token.caller=callerComp;
		}
		public function removeMeetingAttendees(callerComp:Object,meetingAttendees:ArrayCollection):void
		{
			var token:AsyncToken=_meetingRO.removeMeetingAttendees(meetingAttendees);
			token.caller=callerComp;
		}
		public function getMeetingRoomsResultHandler(event:ResultEvent):void
		{
			event.token.caller.getMeetingRoomsResultHandler(event.result);
		}
		public function getMeetingRoomsFaultHandler(event:FaultEvent):void
		{
			event.token.caller.getMeetingRoomsFaultHandler(event);
		}
		public function getScheduledMeetings(callerComp:Object,userId:Number):void
		{
			var token:AsyncToken=_meetingRO.getScheduledMeetings(callerComp,ClassroomContext.userVO.userId);
			token.caller=callerComp;
		}
		public function updateMeetingSchedule(callerComp:Object,
											  lecture:LectureVO,
											  guestMailIds:ArrayCollection,
											  updaterId:Number):void
		{
			var token:AsyncToken=_meetingRO.updateMeetingSchedule(lecture,guestMailIds,ClassroomContext.userVO.userId);
			token.caller=callerComp;
		}
		private function removeMeetingAttendeesResultHandler(event:ResultEvent):void
		{
			event.token.caller.removeMeetingAttendeesResultHandler(event);
		}
		private function removeMeetingAttendeesFaultHandler(event:FaultEvent):void
		{
			event.token.caller.removeMeetingAttendeesFaultHandler(event);
		}
		private function createMeetingScheduleResultHandler(event:ResultEvent):void
		{
			event.token.caller.createMeetingScheduleResultHandler(event);
		}
		private function createMeetingScheduleFaultHandler(event:FaultEvent):void
		{
			event.token.caller.createMeetingScheduleFaultHandler(event);
		}
		private function deleteMeetingsResultHandler(event:ResultEvent):void
		{
			event.token.caller.deleteMeetingsResultHandler(event);
		}
		private function deleteMeetingsFaultHandler(event : FaultEvent) : void
		{
			event.token.caller.deleteMeetingsFaultHandler(event);
		}
		public function updateMeetingRoom(callerComp:Object,aviewClass:ClassVO,onGoingLecture:LectureVO, meetingMembers:ArrayCollection,guestMembers:ArrayCollection, isInsideMeetingRoom:String, updaterId:Number) :void
		{
			var token:AsyncToken=_meetingRO.updateMeetingRoom(aviewClass, onGoingLecture, meetingMembers,guestMembers,isInsideMeetingRoom,updaterId);
			token.caller=callerComp;
		}
		
		public function updateMeetingScheduleResultHandler(event:ResultEvent):void
		{
			event.token.caller.updateMeetingScheduleResultHandler(event);
		}
		public function updateMeetingScheduleFaultHandler(event:FaultEvent):void
		{
			event.token.caller.updateMeetingScheduleFaultHandler(event);
		}
		public function createAdhocMeeting(callerComp:Object,
										   aviewClass:ClassVO,
										   guestMembers:ArrayCollection,
										   lectureName:String,
										   scheduleDate:Date,
										   startTime:Date,
		                                   endTime:Date,
		                                   creatorId:Number):void
			
		{
			var token:AsyncToken=_meetingRO.createAdhocMeeting(aviewClass,
				guestMembers,lectureName,scheduleDate,startTime,endTime,creatorId);			
			token.caller=callerComp;
			
		}
		public function getMeetingsForModerator(callerComp:Object,userId:Number):void
		{
			var token:AsyncToken=_meetingRO.getMeetingsForModerator(userId);
			token.caller=callerComp;
		}
		public function getMeetingsForModeratorResultHandler(event:ResultEvent):void
		{
			event.token.caller.getMeetingsForModeratorResultHandler(event);
		}
		public function getMeetingsForModeratorFaultHandler(event:FaultEvent):void
		{
			event.token.caller.getMeetingsForModeratorFaultHandler(event);
		}
		public function createAdhocMeetingResultHandler(event:ResultEvent):void
		{		
			event.token.caller.createAdhocMeetingResultHandler(event);
		}
		public function createAdhocMeetingFaultHandler(event:FaultEvent):void
		{
			event.token.caller.createAdhocMeetingFaultHandler(event);
		}
		public function updateMeetingRoomResultHandler(event:ResultEvent):void
		{
			event.token.caller.updateMeetingRoomResultHandler(event);
		}
		public function updateMeetingRoomFaultHandler(event:FaultEvent):void
		{
			event.token.caller.updateMeetingRoomFaultHandler(event);
		}
		
		public function get meetingRO():RemoteObject
		{
			return _meetingRO;
		}

		public function set meetingRO(value:RemoteObject):void
		{
			_meetingRO = value;
		}
		
		//Fix for Bug #13291 start
		public function deleteMeetingRoom(callerComp:Object,aviewClassId : Number, updaterId:Number) :void
		{
			var token:AsyncToken=_meetingRO.deleteMeetingRoom(aviewClassId, updaterId);
			token.caller=callerComp;
		}
		private function deleteMeetingRoomResultHandler(event:ResultEvent):void
		{
			event.token.caller.deleteMeetingRoomResultHandler(event);
		}
		private function deleteMeetingRoomFaultHandler(event:FaultEvent):void
		{
			event.token.caller.deleteMeetingRoomFaultHandler(event);
		}
		//Fix for Bug #13291 end
		
		//Fix for Bug #13457 start
		public function endMeeting(callerComp:Object, meeting : LectureVO, updaterId:Number) :void
		{
			var token:AsyncToken=_meetingRO.endMeeting(meeting, updaterId);
			token.caller=callerComp;
		}
		private function endMeetingResultHandler(event:ResultEvent):void
		{
			event.token.caller.endMeetingResultHandler(event);
		}
		private function endMeetingFaultHandler(event:FaultEvent):void
		{
			event.token.caller.endMeetingFaultHandler(event);
		}
		//Fix for Bug #13457 end
	}
}