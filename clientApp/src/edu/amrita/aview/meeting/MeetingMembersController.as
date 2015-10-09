package edu.amrita.aview.meeting
{
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.UserStatusProviderEvent;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.meeting.events.MeetingRoomEvent;
	import edu.amrita.aview.meeting.helper.MeetingManagerHelper;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class MeetingMembersController extends EventDispatcher
	{
		
		private var meetingMembersView:MeetingMembersView=null;
		private var meetingMembersModel:MeetingMembersModel=null;
		private var currentMeetingRoom:MeetingRoomVO=null;
		private var moduleRO:ModuleRO = null;
		
		public function MeetingMembersController(mro:ModuleRO)
		{
			super();
			this.moduleRO = mro;
		}
		public function init():void
		{
			this.moduleRO.moduleEventMap.registerInitiator(this,UserStatusProviderEvent.USER_STATUS_CHANGE);
			this.moduleRO.moduleEventMap.registerMapListener(MeetingRoomEvent.SELECT_MEETINGROOM,onSelectMeetingRoom);
			this.moduleRO.applicationEventMap.registerMapListener(ContactsEvent.USER_STATUS_CHANGED,onChangeUserStatus);
			this.moduleRO.moduleEventMap.registerMapListener(MeetingRoomEvent.DELETE_MEMBERS,onDeleteMeetingMembers,"MeetingMembers");
			
			getMeetingMembersModel();
		}
		public function getMeetingMembersView():MeetingMembersView
		{
			if(meetingMembersView==null)
			{
				meetingMembersView= new MeetingMembersView();
				meetingMembersView.meetingMembersModel=getMeetingMembersModel();
				meetingMembersView.init(this.moduleRO.moduleEventMap);
			}
			return meetingMembersView;
		}
		public function getMeetingMembersModel():MeetingMembersModel
		{
			if(meetingMembersModel==null)
			{
				meetingMembersModel=new MeetingMembersModel();
			}
			return meetingMembersModel;
		}
		private function onSelectMeetingRoom(event:MeetingRoomEvent):void
		{
			if(event.selectedMeetingRoom!=null && this.meetingMembersModel!=null)
			{
				this.meetingMembersModel.meetingMembers=event.selectedMeetingRoom.meetingRoomMembers;
				getMeetingRoomMembers(event.selectedMeetingRoom.meetingRoom.classId);
			}
		}
		private function getMeetingRoomMembers(meetingRoomId:Number):void
		{
			var meetingMemberHelper:MeetingManagerHelper=new MeetingManagerHelper();
			meetingMemberHelper.getMeetingRoomMembers(this, meetingRoomId,this.moduleRO.userVO.userId);
		}
		public function getMeetingRoomMembersResultHandler(meetingMembers:ArrayCollection):void
		{
			if(this.meetingMembersModel!=null)
			{
				this.meetingMembersModel.meetingMembers=meetingMembers;
				this.dispatchEvent(new UserStatusProviderEvent(UserStatusProviderEvent.USER_STATUS_CHANGE,setStatusforMeetingMembers));
			}
		}
		public function setStatusforMeetingMembers(onlineUsers:Object):void
		{
			for(var index:int=0;index<meetingMembersModel.meetingMembers.length;index++)
			{
				var user:UserVO=meetingMembersModel.meetingMembers[index].user;
				if(onlineUsers[user.userName]!=null)
				user.userStatus=onlineUsers[user.userName];
				
			}
		}
		private function onDeleteMeetingMembers(event:MeetingRoomEvent):void
		{
			currentMeetingRoom=event.selectedMeetingRoom;
			if(meetingMembersModel.selectedMembers!=null && meetingMembersModel.selectedMembers.length>0 )
			{
				Alert.show("Do you want to delete the selected Members?","Confirmation",Alert.YES|Alert.NO,null,onDeleteConfirmation);				
					
			}
			else
			{
				Alert.show("Please select at least one member to delete","Warning");			
			}
		}
		private function onDeleteConfirmation(event:CloseEvent):void
		{
			if(event.detail==Alert.YES)
			{
				deleteSelectedMeetingMembers();
			}
		}
		public function deleteSelectedMeetingMembers():void
		{		
			var meetingManagerHelper:MeetingManagerHelper=new MeetingManagerHelper();
			meetingManagerHelper.removeMeetingAttendees(this, meetingMembersModel.selectedMembers);
		}
		
		public function removeMeetingAttendeesResultHandler(event:ResultEvent):void
		{
			// code to remove meeting members from currentMeetingroom
			//#Bugfix for removing selected members
			for(var index:int=0;index<meetingMembersModel.meetingMembers.length;index++)
			{
				for(var index1:int=0;index1<meetingMembersModel.selectedMembers.length;index1++)
				{
					if(meetingMembersModel.meetingMembers[index].user.userId==
						meetingMembersModel.selectedMembers[index1].user.userId)
					{
						meetingMembersModel.meetingMembers.removeItemAt(index);
						index--;
						break;
					}
				}
			}
			currentMeetingRoom.meetingRoomMembers=meetingMembersModel.meetingMembers;
			meetingMembersModel.selectedMembers.removeAll();
			Alert.show("Selected contact(s) is deleted from this Meeting room","INFORMATION");
		}
		
		//Fix for Bug #13243 start
		public function removeMeetingAttendeesFaultHandler(event:FaultEvent):void
		{
			//if (Log.isError()) log.error("Contacts::MyContacts::removeMeetingAttendeesFaultHandler:" +AbstractHelper.getStaticFaultMessage(event));
			Alert.show("Selected meeting members cannot be deleted","Error");
		}
		private function onChangeUserStatus(event:ContactsEvent):void
		{	
			if(this.meetingMembersModel!=null)
			{
				var groupUsers:ArrayCollection=this.meetingMembersModel.meetingMembers;
				for each(var gUser:ClassRegisterVO in groupUsers)
				{
					if(gUser.user.userName==event.data.name)
					{
						gUser.user.userStatus=event.data.userStatus;
						groupUsers.refresh();
						break;
					}
				}
			}
		}
	}
}