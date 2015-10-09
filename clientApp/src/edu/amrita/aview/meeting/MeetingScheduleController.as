package edu.amrita.aview.meeting
{
	import com.adobe.utils.StringUtil;
	
	//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.vo.AViewResponseVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.entry.SessionEntry;
	import edu.amrita.aview.core.gclm.helper.LectureHelper;
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	import edu.amrita.aview.core.gclm.vo.LectureListVO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.meeting.events.MeetingEvent;
	import edu.amrita.aview.meeting.helper.MeetingManagerHelper;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;

	public class MeetingScheduleController extends EventDispatcher
	{
		private var eventMap:EventMap=null;
		private var userVO:UserVO=null;
		private var meetingScheduleView:MeetingScheduleView=null;
		private var meetingScheduleModel:MeetingScheduleModel=null;
		private var mediaServerConnection:MediaServerConnection=null;
		public function MeetingScheduleController(contactModuleRO:ModuleRO)
		{
			this.eventMap=contactModuleRO.moduleEventMap;
			this.userVO=contactModuleRO.userVO;
			this.mediaServerConnection=contactModuleRO.mediaServerConnection;
		}
		
		public function initialize():void
		{
			eventMap.registerInitiator(this,MeetingEvent.REFRESH_MEETING_ROOM);
		}
		public function getMeetingScheduleView(parent:UIComponent):MeetingScheduleView
		{
			if(meetingScheduleView==null)
			{
				meetingScheduleView=new MeetingScheduleView();
				meetingScheduleView.meetingScheduleModel=getMeetingScheduleModel();
				meetingScheduleView.addEventListener(MeetingEvent.CREATE_ADHOC_MEETING,onCreateAdhocMeeting);
				meetingScheduleView.addEventListener(MeetingEvent.CREATE_SCHEDULED_MEETING,onCreateScheduledMeeting);
				meetingScheduleView.addEventListener(MeetingEvent.EDIT_MEETING,onUpdateMeetingSchedule);
				PopUpManager.addPopUp(meetingScheduleView,parent);
				PopUpManager.centerPopUp(meetingScheduleView);
			}			
			return meetingScheduleView;
		}
		public function getMeetingScheduleModel():MeetingScheduleModel
		{
			if(meetingScheduleModel==null)
			{
				meetingScheduleModel=new MeetingScheduleModel();
				
			}
			return meetingScheduleModel;
		}
		
		private function onCreateAdhocMeeting(event:MeetingEvent):void
		{
			PopUpManager.removePopUp(this.meetingScheduleView);
			
			meetingScheduleModel.meetingName=StringUtil.trim(meetingScheduleView.txtTitle.text);
			var aviewClass:ClassVO=meetingScheduleModel.selectedRoom.meetingRoom;
			/*if (Log.isDebug())
			{
				FlexGlobals.topLevelApplication.log.debug("Enter Meeting Room");
			}*/
			createAdhocMeeting(aviewClass);
			
		}
		private function createAdhocMeeting(aviewClass:ClassVO):void
		{
			var currentTime:Date=new Date();
			var currentDate:Date=new Date(currentTime.fullYear, currentTime.month, currentTime.date, 0, 0, 0);
			var endTime:Date=new Date(null, null, null, '23', '59', '59', '0');
			var meetingHelper:MeetingManagerHelper=new MeetingManagerHelper();
			meetingHelper.createAdhocMeeting
				(this, aviewClass, meetingScheduleModel.guestMailIds, 
				meetingScheduleModel.meetingName, 
				currentDate, currentTime, endTime, userVO.userId);
		}
		
		public function createAdhocMeetingResultHandler(event:ResultEvent):void
		{
			if (event.result == null)
			{
				Alert.show("Meeting call failed ,Please try later", "Error");
				return;
			}
			var lecture:LectureVO=event.result as LectureVO;
			var obj:Object=new Object;
			obj.title=StringUtil.trim(meetingScheduleModel.meetingName);
			obj.userName=userVO.userName;
			obj.moderatorName=userVO.userName;
			obj.userId=userVO.userId;
			obj.lectureId=lecture.lectureId;
			obj.classId=meetingScheduleModel.selectedRoom.meetingRoom.classId;
			
			sendInvitation(meetingScheduleModel.selectedRoom.meetingRoomMembers.toArray(), obj);
			this.dispatchEvent(new MeetingEvent(MeetingEvent.START_SESSION,meetingScheduleModel));	
			var sessionEntry:SessionEntry=new SessionEntry();
			sessionEntry.getClassRoomLecture(lecture.lectureId);
			ClassroomContext.meetingRoomVO=meetingScheduleModel.selectedRoom;			
		}
		public function createMeetingScheduleResultHandler(event:ResultEvent):void
		{			
			this.dispatchEvent(new MeetingEvent(MeetingEvent.REFRESH_MEETING_ROOM,meetingScheduleModel));
			Alert.show("Meeting(s) scheduled successfully", "Information");
			removeMeetingScheduleView();
		}
		
		public function createAdhocMeetingFaultHandler(event:FaultEvent):void
		{
			Alert.show("Meeting call failed ,Please try later", "Error");
			removeMeetingScheduleView();			
		}
		private function removeMeetingScheduleView():void
		{
			PopUpManager.removePopUp(meetingScheduleView);
			meetingScheduleView=null;
			meetingScheduleModel=null;
		}	
		
		private function onUpdateMeetingSchedule(event:MeetingEvent):void
		{
			var lectureVO:LectureVO=ObjectUtil.clone(meetingScheduleModel.selectedSchedule) as LectureVO;
			lectureVO.startDate=meetingScheduleModel.startDate;
			lectureVO.startTime=meetingScheduleModel.startTime;
			lectureVO.endTime=meetingScheduleModel.endTime;
			lectureVO.lectureName =meetingScheduleModel.meetingName; 
			var guestUserIds:ArrayCollection=null;
			if (meetingScheduleModel.guestMailIds != null)
			{
				guestUserIds=meetingScheduleModel.guestMailIds;
			}
			var meetingManagerHelper:MeetingManagerHelper=new MeetingManagerHelper();
			meetingManagerHelper.updateMeetingSchedule(this, lectureVO, guestUserIds, userVO.userId);
		}
		
		public function updateMeetingScheduleResultHandler(event:ResultEvent):void
		{	
			this.dispatchEvent(new MeetingEvent(MeetingEvent.REFRESH_MEETING_ROOM,meetingScheduleModel));
			removeMeetingScheduleView();
			Alert.show("Meeting updated successfully", "INFORMATION");
		}
		private function onCreateScheduledMeeting(event:MeetingEvent):void
		{
			createNewSchedule();
		}
		private function createNewSchedule():void
		{
			var meetingManagerHelper:MeetingManagerHelper=new MeetingManagerHelper();
			var guestIds:ArrayCollection=null;
			var aviewClass:ClassVO=meetingScheduleModel.selectedRoom.meetingRoom as ClassVO;
			if (meetingScheduleModel.guestMailIds != null && meetingScheduleModel.guestMailIds.length > 0)
			{
				guestIds=getNewGuestMailIds(meetingScheduleModel.guestMailIds);
			}
			meetingManagerHelper.createMeetingSchedule(this, aviewClass, guestIds, meetingScheduleModel.meetingName, meetingScheduleModel.weekDays, meetingScheduleModel.startDate,
				meetingScheduleModel.endDate, meetingScheduleModel.startTime, meetingScheduleModel.endTime, userVO.userId);
			
		}
		private function getNewGuestMailIds(guestMailIds:ArrayCollection):ArrayCollection
		{
			var meetingMembers:ArrayCollection=meetingScheduleModel.selectedRoom.meetingRoomMembers;
			for (var index:int=0; index < guestMailIds.length; index++)
			{
				for (var index1:int=0; index1 <meetingMembers .length; index1++)
				{
					if (guestMailIds[index] == meetingMembers[index1].user.email)
					{
						guestMailIds.removeItemAt(index);
						index--;
						break;
					}
				}
			}
			return guestMailIds;
		}
		
		//needs to be moved to a common place, same function required within the meeting Room
		private function sendInvitation(members:Array, meetingInfo:Object):void
		{
			var invitationDetails:Array=new Array;
			for each (var meetingMember:Object in members)
			{
				var classRegistrationId:Number=meetingScheduleModel.getMemberRegistrationId(meetingMember.user.userId);
				if (meetingMember.user.userId != meetingInfo.userId)
				{
					var obj:Object={userName: meetingMember.user.userName,
						meetingName: meetingInfo.title, 
						moderatorName: meetingInfo.moderatorName,
						lectureId: meetingInfo.lectureId, 
						userId: meetingMember.user.userId,
						classRegistrationId:classRegistrationId
					    };
					invitationDetails.push(obj);
				}
			}
			if (mediaServerConnection != null)
				mediaServerConnection.netConnection.call("sendInvitation", null, invitationDetails);
		}
	}
}