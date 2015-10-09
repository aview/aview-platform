package edu.amrita.aview.meeting
{
	
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.meeting.events.CommonEvent;
	import edu.amrita.aview.meeting.events.MeetingEvent;
	import edu.amrita.aview.meeting.events.MeetingRoomEvent;
	import edu.amrita.aview.meeting.helper.MeetingManagerHelper;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class MeetingsListController extends EventDispatcher
	{
		
		private var userVO:UserVO=null;
		private var meetingsListModel:MeetingsListModel=null;
		private var meetingsListView:MeetingsListView=null;
		
		private var contactModuleRO:ModuleRO=null;
		
		public function MeetingsListController(contactModuleRO:ModuleRO)
		{
			this.contactModuleRO=contactModuleRO;
		}
		public function initialize():void
		{
			contactModuleRO.moduleEventMap.registerMapListener(MeetingRoomEvent.SELECT_MEETINGROOM,onMeetingRoomSelected);
			contactModuleRO.moduleEventMap.registerMapListener(MeetingEvent.DELETE_MEETING,onDeleteMeetings,"MeetingsList");
			contactModuleRO.moduleEventMap.registerInitiator(this,MeetingEvent.REFRESH_MEETING_ROOM);
			meetingsListModel=getMeetingsListModel();
		}		
		public function onMeetingRoomSelected(event:MeetingRoomEvent):void
		{
			if(event.selectedMeetingRoom!=null)
			{
				if(event.selectedMeetingRoom.meetingRoom.className==MeetingRoomListModel.ALL_MEETINGS)
				{
					this.meetingsListModel.isAllMeetingsSelected=true;
				}
				else
				{
					this.meetingsListModel.isAllMeetingsSelected=false;
				}
				this.meetingsListModel.allMeetings=event.selectedMeetingRoom.lecturesAC;
				this.meetingsListModel.computePastAndUpcomingMeetings();
				this.meetingsListModel.sortAndRefresh();
				
			}
			this.meetingsListModel.selectedMeetings=null;
		}
		public function getMeetingsListView():MeetingsListView
		{
			meetingsListView=new MeetingsListView();
			meetingsListView.addEventListener(CommonEvent.EDIT,onEditMeeting);
			meetingsListView.meetingsListModel=getMeetingsListModel();
			meetingsListView.init(this.contactModuleRO.moduleEventMap);
			return meetingsListView;
		}
		
		
		public function onEditMeeting(event:MeetingEvent):void
		{
			if(meetingsListModel.selectedMeetings==null ||meetingsListModel.selectedMeetings.length==0)
			{
				Alert.show("Please select the meeting to edit", "Information");
				return;
			}
			if(meetingsListModel.selectedMeetings.length>1)
			{
				Alert.show("Please select only one meeting to edit", "WARNING");
				return;
			}
			
			var meetingScheduleController:MeetingScheduleController=new MeetingScheduleController(contactModuleRO);
			meetingScheduleController.initialize();
			var meetingScheduleView:MeetingScheduleView=meetingScheduleController.getMeetingScheduleView(meetingsListView.parentApplication as UIComponent);
			var meetingScheduleModel:MeetingScheduleModel=meetingScheduleController.getMeetingScheduleModel();
			meetingScheduleModel.meetingName=meetingsListModel.selectedMeetings[0].displayName;
			meetingScheduleModel.startDate=meetingsListModel.selectedMeetings[0].startDate;
			meetingScheduleModel.endDate=meetingsListModel.selectedMeetings[0].startDate;
			meetingScheduleModel.startTime=meetingsListModel.selectedMeetings[0].startTime;
			meetingScheduleModel.endTime=meetingsListModel.selectedMeetings[0].endTime;
			meetingScheduleModel.selectedSchedule=meetingsListModel.selectedMeetings[0];
			meetingScheduleModel.isEditScheduledMeeting=true;
			meetingScheduleModel.isScheduledMeeting=true;
			meetingScheduleView.title="Edit Meeting";
			meetingScheduleView.recurringChkBox.visible=false;
			meetingScheduleView.recurringChkBox.includeInLayout=false;
		}
			
		private function getMeetingsListModel():MeetingsListModel
		{
			if(this.meetingsListModel==null)
			{
				this.meetingsListModel=new MeetingsListModel();
			}
			return this.meetingsListModel;
		}
		private function onDeleteMeetings(event:MeetingEvent):void
		{
			if(meetingsListModel.selectedMeetings!=null && meetingsListModel.selectedMeetings.length>0)
			{
				Alert.show("Do you want to delete the selected Meetings?","Confirmation",Alert.YES|Alert.NO,null,onDeleteConfirmation);

			}
			else
			{
				Alert.show("Please select at least one meeting to delete","Warning");
			}
		}
		private function onDeleteConfirmation(event:CloseEvent):void
		{
			if(event.detail==Alert.YES)
			{
				deleteSelectedMeetings();
			}
		}
		public function deleteSelectedMeetings():void
		{			
			var schedules:ArrayCollection=this.meetingsListModel.selectedMeetings;
			var newDate:Date=new Date();
			var startedMeeting:Boolean=false;
			for (var index:int=0; index < schedules.length; index++)
			{
				var schedule:LectureVO=schedules[index] as LectureVO;
				schedule.statusId=2;
			}
			
			var meetingHelper:MeetingManagerHelper=new MeetingManagerHelper();
			meetingHelper.deleteMeetings(this, schedules);
			
		}
		public function deleteMeetingsResultHandler(event:ResultEvent):void
		{
			Alert.show("Selected meeting name(s) is deleted from this Meeting room","INFORMATION");
			meetingsListModel.removeSelectedMeetings();
			this.dispatchEvent(new MeetingEvent(MeetingEvent.REFRESH_MEETING_ROOM,null));
		}
		public function deleteMeetingsFaultHandler(event:FaultEvent):void
		{
			Alert.show("One or more selected meetings are already started. They cannot be deleted ","INFORMATION");
			this.dispatchEvent(new MeetingEvent(MeetingEvent.REFRESH_MEETING_ROOM,null));
		}
		private function onSelectMeetingRoom(event:MeetingRoomEvent):void
		{
			if(event.selectedMeetingRoom!=null)
			{
				meetingsListModel.allMeetings=event.selectedMeetingRoom.lecturesAC;
				meetingsListModel.pastMeetings=event.selectedMeetingRoom.pastMeetings;
				meetingsListModel.currentAndUpcomingMeetings=event.selectedMeetingRoom.currentAndUpcomingMeetings;
			}
		}
	}
}