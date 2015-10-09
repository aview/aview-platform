package edu.amrita.aview.meeting
{
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.ContactsProviderEvent;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.meeting.events.MeetingEvent;
	import edu.amrita.aview.meeting.events.MeetingRoomEvent;
	import edu.amrita.aview.meeting.helper.MeetingManagerHelper;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	

	public class MeetingRoomListController extends EventDispatcher
	{
		private var meetingRoomsListView:MeetingRoomListView=null;
		private var meetingRoomListModel:MeetingRoomListModel=null;
		private var selectedRoomIndex:int=-1;
		
		
		private var meetingRoomManagerController:MeetingRoomManagerController=null;
		private var contactModuleRO:ModuleRO=null;
		
		private var allGroupsAndContacts:ArrayCollection=null;
		
		public function init(allGroupsAndContacts:ArrayCollection):void
		{
			this.allGroupsAndContacts=allGroupsAndContacts;
			contactModuleRO.moduleEventMap.registerMapListener(MeetingEvent.REFRESH_MEETING_ROOM,onRefreshMeetingRoom);
			contactModuleRO.moduleEventMap.registerInitiator(this,MeetingRoomEvent.SELECT_MEETINGROOM);
			getAllMeetingRoomsList();
		}
		public function unregiterInitiatorsAndListeners():void
		{
			contactModuleRO.moduleEventMap.unregisterMapListener(MeetingEvent.REFRESH_MEETING_ROOM,onRefreshMeetingRoom);
			contactModuleRO.moduleEventMap.unregisterInitiator(this,MeetingRoomEvent.SELECT_MEETINGROOM);
		}
		public function MeetingRoomListController(moduleRO:ModuleRO):void
		{
			contactModuleRO=moduleRO;
		}
		
		public function getMeetingRoomsListView():MeetingRoomListView
		{
			if(this.meetingRoomsListView==null)
			{
				this.meetingRoomsListView=new MeetingRoomListView();	
				this.meetingRoomsListView.init(contactModuleRO.moduleEventMap,getMeetingRoomListModel());
			}			
			this.meetingRoomListModel.selectedMeetingRoomVO=null;
			this.meetingRoomsListView.addEventListener(MeetingRoomEvent.CREATE_MEETINGROOM,onCreateMeetingRoom);
			this.meetingRoomsListView.addEventListener(MeetingRoomEvent.EDIT_MEETINGROOM,onEditMeetingRoom);
			this.meetingRoomsListView.addEventListener(MeetingRoomEvent.DELETE_MEETINGROOM,onDeleteMeetingRoom);		
			return this.meetingRoomsListView;
		}
		
		private var roomClassId:Number;
		private function onDeleteMeetingRoom(event:MeetingRoomEvent):void
		{
			roomClassId = event.selectedMeetingRoom.meetingRoom.classId;
			Alert.show("Do you want to delete the selected meeting room","Confirmation",Alert.YES|Alert.NO,null,onDeleteConfirm);
		}
		private function onDeleteConfirm(event:CloseEvent):void
		{
			if(event.detail == Alert.YES)
			{
				selectedRoomIndex=meetingRoomListModel.allMeetingRoomVOs.getItemIndex(meetingRoomListModel.selectedMeetingRoomVO);
				var meetingManagerHelper:MeetingManagerHelper=new MeetingManagerHelper();
				meetingManagerHelper.deleteMeetingRoom(this,roomClassId,contactModuleRO.userVO.userId);
			}
		}
		public function deleteMeetingRoomResultHandler(event:ResultEvent):void
		{
			Alert.show("Deleted Meetingroom","Alert");
			this.meetingRoomListModel.allMeetingRoomVOs.removeItemAt(selectedRoomIndex);
			meetingRoomListModel.selectedMeetingRoomVO=null;
			getAllMeetingRoomsList();
			
		}
		public function deleteMeetingRoomFaultHandler(event:FaultEvent):void
		{
			trace("Failed Meeting room deletion"+event.message.toString());
		}
		private function onCreateMeetingRoom(event:MeetingRoomEvent):void
		{
			//create MeetingRoomMnager Controller and get MeetingManagerView
			meetingRoomManagerController=new MeetingRoomManagerController
				(contactModuleRO,ObjectUtil.copy(allGroupsAndContacts) as ArrayCollection,
			meetingRoomListModel.allMeetingRoomVOs,
			null,null,null,
			MeetingRoomManagerModel.MODE_CREATE_ROOM);
			var parentContainer:UIComponent=this.meetingRoomsListView.parentApplication as UIComponent;
			var meetingManagerView:MeetingRoomManagerView=meetingRoomManagerController.createMeetingRoomManagerView(parentContainer);
			meetingManagerView.title="Create Room";
			meetingRoomManagerController.addEventListener(MeetingRoomEvent.CREATED_MEETINGROOM,onMeetingRoomCreated);
		}
		
		private function onMeetingRoomCreated(event:MeetingRoomEvent):void
		{
			meetingRoomManagerController.removeEventListener(MeetingRoomEvent.CREATED_MEETINGROOM,onMeetingRoomCreated);
			getAllMeetingRoomsList();
			meetingRoomManagerController=null;
		}
		
		private function onEditMeetingRoom(event:MeetingRoomEvent):void
		{
			//TODO: update meetingroom deletes the meetingroom
			meetingRoomManagerController=new MeetingRoomManagerController
				(contactModuleRO,
				ObjectUtil.copy(allGroupsAndContacts) as ArrayCollection,
				meetingRoomListModel.allMeetingRoomVOs,
				event.selectedMeetingRoom.meetingRoomMembers,
				event.selectedMeetingRoom.meetingRoomName,
				event.selectedMeetingRoom.meetingRoom,
				MeetingRoomManagerModel.MODE_EDIT_ROOM);
			var meetingManagerView:MeetingRoomManagerView=meetingRoomManagerController.createMeetingRoomManagerView(this.meetingRoomsListView);
			meetingManagerView.title="Edit Room";
			meetingRoomManagerController.addEventListener(MeetingRoomEvent.EDITED_MEETINGROOM,onMeetingRoomEdited);
			if(meetingRoomListModel.allMeetingRoomVOs!=null)
			{
				selectedRoomIndex=meetingRoomListModel.allMeetingRoomVOs.getItemIndex(meetingRoomListModel.selectedMeetingRoomVO);
			}			
		}
		private function onMeetingRoomEdited(event:MeetingRoomEvent):void
		{
			meetingRoomManagerController.removeEventListener(MeetingRoomEvent.EDITED_MEETINGROOM,onMeetingRoomEdited);
			getAllMeetingRoomsList();
			meetingRoomManagerController=null;
		}
		
		public function getMeetingRoomListModel():MeetingRoomListModel
		{
			if(this.meetingRoomListModel==null)
			{
				this.meetingRoomListModel=new MeetingRoomListModel();
			}
			return this.meetingRoomListModel;
		}
		private function getAllMeetingRoomsList():void
		{			
			var meetingHelper:MeetingManagerHelper=new MeetingManagerHelper();
			meetingHelper.getMeetingsForModerator(this,contactModuleRO.userVO.userId);
		}
		
		public function getMeetingsForModeratorResultHandler(event:ResultEvent):void
		{			
			this.meetingRoomListModel.allMeetingRoomVOs=event.result as ArrayCollection;	
			meetingRoomListModel.processAllMeetingRooms();
			if(meetingRoomListModel.selectedMeetingRoomVO==null)
			{
				setCurrentMeetingRoom(meetingRoomListModel.allMeetingsRoomVO);
				
			}
			else
			{
				meetingRoomListModel.updateCurrentMeetingRoom();
				meetingRoomsListView.setCurrentMeetingRoom();
			}
			this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.SELECT_MEETINGROOM,meetingRoomListModel.selectedMeetingRoomVO));
		}
		public function setCurrentMeetingRoom(currentMeetingRoom:MeetingRoomVO):void
		{
			meetingRoomListModel.setCurrentMeetingRoom(currentMeetingRoom);
		}
		private function onRefreshMeetingRoom(event:MeetingEvent):void
		{
			getAllMeetingRoomsList();
		}
		public function setAllContacs(allGroupsAndContacts:ArrayCollection):void
		{
			this.allGroupsAndContacts=allGroupsAndContacts;
		}
	}
}