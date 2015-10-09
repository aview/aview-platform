package edu.amrita.aview.meeting
{
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.ContactsProviderEvent;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.helper.InstituteHelper;
	import edu.amrita.aview.core.gclm.vo.InstituteVO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.ServerVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.meeting.events.CommonEvent;
	import edu.amrita.aview.meeting.events.MeetingEvent;
	import edu.amrita.aview.meeting.events.MeetingRoomEvent;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;

	public class MeetingRoomController extends EventDispatcher
	{
		private var meetingRoomModel:MeetingRoomModel=null;		
		private var meetingRoomView:MeetingRoomView=null;
		private var meetingsListController:MeetingsListController=null;
		private var meetingMembersListController:MeetingMembersController=null;
		private var contactModuleRO:ModuleRO=null;
		private var meetingRoomManagerController:MeetingRoomManagerController=null;
		private var allContacts:ArrayCollection=null;
		private var meetingScheduleController:MeetingScheduleController=null;
		public function MeetingRoomController(moduleRO:ModuleRO,allContacts:ArrayCollection):void
		{
			contactModuleRO=moduleRO;
			this.allContacts=allContacts;
		}
		public function init():void
		{
			contactModuleRO.moduleEventMap.registerMapListener
				(MeetingRoomEvent.SELECT_MEETINGROOM,onMeetingRoomSelected);
			var instituteHelper:InstituteHelper=new InstituteHelper;
			instituteHelper.getInstituteById(contactModuleRO.userVO.instituteId,getInstituteByIdResultHandler,null);
			contactModuleRO.moduleEventMap.registerInitiator(this,MeetingRoomEvent.SELECT_MEETINGROOM);

		}
		public function unregisterListenersAndIntiators():void
		{
			contactModuleRO.moduleEventMap.unregisterMapListener(MeetingRoomEvent.SELECT_MEETINGROOM,onMeetingRoomSelected);
			contactModuleRO.moduleEventMap.unregisterInitiator(this,MeetingRoomEvent.SELECT_MEETINGROOM);
		}
		public function getInstituteByIdResultHandler(instvo:InstituteVO):void
		{			
			meetingRoomModel.meetingServersAllocated=isMeetingServerAllocated(instvo);			
		}
		
		private function isMeetingServerAllocated(institutevo:InstituteVO):Boolean
		{
			var meetingServers:ArrayCollection=new ArrayCollection();
			var serverCount:int=0;
			var serversAC:ArrayCollection=new ArrayCollection();
			for(var index:int=0;index<institutevo.instituteServers.length;index++)
			{
				serversAC= institutevo.instituteServers;
				
				if(serversAC[index].serverTypeId ==ServerVO.MEETING_COLLABORATION_SERVER )
				{						
					serverCount++;											
				}
				else if(serversAC[index].serverTypeId == ServerVO.MEETING_CONTENT_SERVER)
				{
					
					serverCount++;
					
				}
				else if(serversAC[index].serverTypeId == ServerVO.MEETING_PRESENTER_VIDEO)
				{
					
					serverCount++;
					
				}
				else if(serversAC[index].serverTypeId == ServerVO.MEETING_VIEWER_VIDEO)
				{
					
					serverCount++;
					
				}
				else if(serversAC[index].serverTypeId == ServerVO.MEETING_DESKTOP_SHARING_SERVER)
				{
					
					serverCount++;						
				}				
				
			}
			if(serverCount<5)
			{
				return false;
			}
			
			return true;
		}
		public function getMeetingRoomView():MeetingRoomView
		{
			if(this.meetingRoomView==null)
			{
				this.meetingRoomView=new MeetingRoomView();
			}
			else
			{
				meetingRoomView.setMeetingButtons();
			}
			meetingRoomView.addEventListener(FlexEvent.CREATION_COMPLETE,onMeetingRoomViewCreated);
			meetingRoomView.addEventListener(CommonEvent.SELECTED,onChangeSelectedOption);
			meetingRoomView.addEventListener(MeetingRoomEvent.ADD_PEOPLE_MEETINGROOM,onAddPeopleToMeetingRoom);
			meetingRoomView.addEventListener(MeetingRoomEvent.START_ADHOC_MEETING,onCreateAdhocMeeting);
			meetingRoomView.addEventListener(MeetingRoomEvent.SCHEDULE_MEETING,onScheduleMeeting);
			meetingRoomView.addEventListener(MeetingEvent.EDIT_MEETING,onEditMeeting);
			meetingRoomView.meetingRoomModel=getMeetingRoomModel();
			meetingRoomView.contactEventMap=this.contactModuleRO.moduleEventMap;
			
			return meetingRoomView;
		}
		
		public function createMeetingRoomControllers():void
		{
			createMeetingsListController();
			createMeetingMembersController();
		}
		public function onMeetingRoomViewCreated(event:Event):void
		{		
			meetingRoomView.setMeetingButtons();
			addMeetingsListView();						
		}
		
		public function getMeetingRoomModel():MeetingRoomModel
		{
			if(this.meetingRoomModel==null)
			{
				this.meetingRoomModel=new MeetingRoomModel();
			}
			return meetingRoomModel;
		}
		public function createMeetingsListController():void
		{
			if(this.meetingsListController == null)
			{
				this.meetingsListController=new MeetingsListController(contactModuleRO);
			}
			this.meetingsListController.initialize();
		}
		public function createMeetingMembersController():void
		{
			if(this.meetingMembersListController == null)
			{
				this.meetingMembersListController=new 
					MeetingMembersController(contactModuleRO);
				this.meetingMembersListController.init();
			}			
		}
		
		private function addMeetingsListView():void
		{ 
			var meetingsList:MeetingsListView=meetingsListController.getMeetingsListView();
			meetingRoomView.navMeetingsList.addElement(meetingsList);
		}
		private function addMeetingsMembersView():void
		{ 
			var meetingMembersList:MeetingMembersView=meetingMembersListController.getMeetingMembersView();
			meetingRoomView.navContacts.addElement(meetingMembersList);
		}
		
		
		public function onMeetingRoomSelected(event:MeetingRoomEvent):void
		{
			this.meetingRoomModel.meetingRoomName=event.selectedMeetingRoom.meetingRoomName;
			this.meetingRoomModel.currentMeetingRoom=event.selectedMeetingRoom;
			this.meetingRoomModel.setMeetingRoomProperties();
			this.meetingRoomModel.setMeetingTitleAndPrefix();
			if(this.meetingRoomModel.meetingRoomName==MeetingRoomListModel.ALL_MEETINGS)
			{
				this.meetingRoomView.allMeetingsSelectionHandler();
			}
			else
			{
				this.meetingRoomView.meetingRoomSelectionHandler();
			}
		}
		
		private function onAddPeopleToMeetingRoom(event:MeetingRoomEvent):void
		{
			meetingRoomManagerController=new MeetingRoomManagerController
				(contactModuleRO,
				ObjectUtil.copy(allContacts) as ArrayCollection,
				null,
				event.selectedMeetingRoom.meetingRoomMembers,
				event.selectedMeetingRoom.meetingRoomName,
				event.selectedMeetingRoom.meetingRoom,				
				MeetingRoomManagerModel.MODE_ADD_CONTACTS);
			var meetingManagerView:MeetingRoomManagerView=meetingRoomManagerController.createMeetingRoomManagerView(this.meetingRoomView.parentApplication as UIComponent);
			meetingManagerView.title="Add People";
			meetingRoomManagerController.addEventListener(MeetingRoomEvent.EDITED_MEETINGROOM,onMeetingRoomEdited);	
		}
		private function onMeetingRoomEdited(event:MeetingRoomEvent):void
		{
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp!=null)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.classMembers=event.selectedMeetingRoom.meetingRoomMembers;
			else
				if(event.selectedMeetingRoom!=null)
				{
					meetingRoomModel.currentMeetingRoom.meetingRoomMembers=event.selectedMeetingRoom.meetingRoomMembers;
				}
				this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.SELECT_MEETINGROOM,meetingRoomModel.currentMeetingRoom));
			
		}
		private function onChangeSelectedOption(event:CommonEvent):void
		{
			if(this.meetingRoomModel.selectedOption=="Contacts")
			{
				if(this.meetingRoomView.navContacts.numElements==0)
				{
					addMeetingsMembersView();
				}
			}
		}
		private function onCreateAdhocMeeting(event:MeetingRoomEvent):void
		{
			createMeetingScheduleComponent(false,false,meetingRoomModel.currentMeetingRoom,null);
		}
		private function onScheduleMeeting(event:MeetingRoomEvent):void
		{
			createMeetingScheduleComponent(true,false,meetingRoomModel.currentMeetingRoom,null);
		}
		private function onEditMeeting(event:MeetingEvent):void
		{
			meetingsListController.onEditMeeting(event);
		}
		private function createMeetingScheduleComponent(isScheduledMeeting:Boolean,
														isEditMeetingSchedule:Boolean,
														selectedMeetingRoom:MeetingRoomVO,
														selectedMeetingSchedule:LectureVO):void
		{
			meetingScheduleController=new MeetingScheduleController(contactModuleRO);
			meetingScheduleController.initialize();
			var meetingScheduleView:MeetingScheduleView=meetingScheduleController.getMeetingScheduleView(meetingRoomView);
			var meetingScheduleModel:MeetingScheduleModel=meetingScheduleController.getMeetingScheduleModel();
			meetingScheduleModel.selectedRoom=selectedMeetingRoom;
			meetingScheduleModel.selectedSchedule=selectedMeetingSchedule;
			meetingScheduleModel.isEditScheduledMeeting=isEditMeetingSchedule;
			meetingScheduleModel.isScheduledMeeting=isScheduledMeeting;
			if(meetingScheduleModel.isScheduledMeeting)
			{
				meetingScheduleView.title="Schedule Meeting";
			}
			else
			{
				meetingScheduleView.title="Meet Now";
			}
		}
		public function setAllContacs(allGroupsAndContacts:ArrayCollection):void
		{
			this.allContacts=allGroupsAndContacts;
		}

	}
}