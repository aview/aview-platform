package edu.amrita.aview.meeting
{
	import com.adobe.utils.StringUtil;
	
	import edu.amrita.aview.contacts.ContactsSelectionController;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.meeting.events.MeetingRoomEvent;
	import edu.amrita.aview.meeting.helper.MeetingManagerHelper;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.Panel;

	public class MeetingRoomManagerController extends EventDispatcher
	{
		private var meetingRoomManagerView:MeetingRoomManagerView=null;
		[Bindable]
		private var meetingRoomManagerModel:MeetingRoomManagerModel=null;
		private var contactsSelectionController:ContactsSelectionController = null;
		private var contactModuleRO:ModuleRO=null;
		private var allGroupsAndContacts:ArrayCollection=null;
		private var meetingRoom:ClassVO=null;
		
		public function MeetingRoomManagerController(moduleRO:ModuleRO,
													 allContacts:ArrayCollection,
													 allMeetingRooms:ArrayCollection,
													 meetingRoomMembers:ArrayCollection,
													 roomName:String,
													 meetingRoom:ClassVO,
													 mode:String)
		{
			this.contactModuleRO=moduleRO;			
			meetingRoomManagerModel=new MeetingRoomManagerModel(meetingRoomMembers,mode,roomName,allMeetingRooms,moduleRO.userVO);
			contactsSelectionController = new ContactsSelectionController(ObjectUtil.copy(allContacts) as ArrayCollection,moduleRO,meetingRoomManagerModel.getMeetingUsers(),
				meetingRoomManagerModel.allowContactsRemoval());
			this.meetingRoom=meetingRoom;
		}		
		public function createMeetingRoomManagerView(parent:UIComponent):MeetingRoomManagerView
		{
			contactsSelectionController.init();
			meetingRoomManagerView=new MeetingRoomManagerView();
			addCreateMeetingRoomListener();
			addEditMeetingRoomListener();				
			meetingRoomManagerView.meetingRoomManagerModel=this.meetingRoomManagerModel;
			PopUpManager.addPopUp(meetingRoomManagerView,parent,true);			
			PopUpManager.centerPopUp(meetingRoomManagerView);	
			meetingRoomManagerView.contactsSelectionView.addElement(contactsSelectionController.contactsSelectionView);
			return meetingRoomManagerView;
		}	
		
		private function onCreateRoom(event:MeetingRoomEvent):void
		{
			meetingRoomManagerView.removeEventListener(MeetingRoomEvent.CREATE_MEETINGROOM,onCreateRoom);
			
				createMeetingRoom();			
		}
		private function onEditMeetingRoom(event:MeetingRoomEvent):void
		{
			meetingRoomManagerView.removeEventListener(MeetingRoomEvent.EDIT_MEETINGROOM,onEditMeetingRoom);			
			updateMeetingRoom();		
		}
		private function addCreateMeetingRoomListener():void
		{
			meetingRoomManagerView.addEventListener(MeetingRoomEvent.CREATE_MEETINGROOM,onCreateRoom);
		}
		private function addEditMeetingRoomListener():void
		{
			meetingRoomManagerView.addEventListener(MeetingRoomEvent.EDIT_MEETINGROOM,onEditMeetingRoom);
		}
		
		private function createMeetingRoom():void
		{			
			var classvo:ClassVO = new ClassVO;
			setCourseNameForMeeting(classvo);
			classvo.endDate=new Date();
			classvo.startDate=new Date();
			classvo.startTime=new Date();
			var endTime:Number= new Date(classvo.startTime.fullYear,classvo.startTime.month,classvo.startTime.date,23,59,59).time;		
			var currentDate:Date=new Date();
			currentDate.time=endTime;
			classvo.endTime=currentDate;
			classvo.endDate=new Date();
			classvo.className=meetingRoomManagerModel.roomName;
			var selectedContactIds:ArrayCollection=contactsSelectionController.getSelectedContactIds();
			if(selectedContactIds.length>0)
			{
				var meetingHelper:MeetingManagerHelper=new MeetingManagerHelper();
				meetingHelper.createMeeting(classvo,selectedContactIds,null,contactModuleRO.userVO.userId , this);
			}
			else
			{
				Alert.show("Please Select at least one contact to create a meeting room","Warning");
				addCreateMeetingRoomListener();
			}

		}
		public function createMeetingResultHandler(event:ResultEvent):void
		{
			this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.CREATED_MEETINGROOM, null));
			Alert.show(meetingRoomManagerModel.roomName + " room created successfully","INFORMATION");
			removePopUp();
		}
		private function setCourseNameForMeeting(classvo : ClassVO) : void
		{
			classvo.courseName = meetingRoomManagerModel.roomName + "_" + contactModuleRO.userVO.userName;
		}
		
		//Added the fault handler
		public function createMeetingFaultHandler(event:FaultEvent):void
		{
			Alert.show("Room Could not be created","INFORMATION");
			removePopUp();
		}
		private function updateMeetingRoom():void
		{	
			if(!contactsSelectionController.isGroupExists() && (meetingRoomManagerModel.getNewGuestMailIds()== null || 
				meetingRoomManagerModel.getNewGuestMailIds().length==0)  )
			{
				if(meetingRoomManagerModel.isAddContactsGuests())
				{
					Alert.show("At least one contact needs to be selected to add new people to meeting ","INFORMATION");
					addEditMeetingRoomListener();
					return;
				}
				else if(meetingRoomManagerModel.roomName== meetingRoom.className)
				{
					Alert.show("Current meeting room details are not updated","INFORMATION");
					addEditMeetingRoomListener();
					return;
				}
				
			}
			var classVO:ClassVO = this.meetingRoom;
			classVO.className=meetingRoomManagerModel.roomName;
			//Fix for Bug #13693 start
			setCourseNameForMeeting(classVO);
			var selectedContactIds:ArrayCollection=contactsSelectionController.getSelectedContactIds();
			if(!meetingRoomManagerModel.isAddContactsGuests())
				selectedContactIds.addItem(contactModuleRO.userVO.userId);
			//Fix for Bug #13693 end
			
			var meetingManagerHelper:MeetingManagerHelper = new MeetingManagerHelper();
			if(meetingRoomManagerModel.isAddContactsGuests())
			{
				meetingManagerHelper.updateMeetingRoom(this,classVO, ClassroomContext.lecture,selectedContactIds,meetingRoomManagerModel.getNewGuestMailIds(),"Y",contactModuleRO.userVO.userId);
			}
			else if(meetingRoomManagerModel.guestEmailIds!=null)
			{
				meetingManagerHelper.updateMeetingRoom(this,classVO, null,selectedContactIds,meetingRoomManagerModel.getNewGuestMailIds(),"N",contactModuleRO.userVO.userId);		
			}
			else
			{   //#Bugfix for 16215 starts  
				if(meetingRoomManagerModel.isAddPeople() && !meetingRoomManagerModel.isNewMembersSelected(selectedContactIds))
				{
					Alert.show("Please select atleast one new user from your contacts","Information");
					addEditMeetingRoomListener();
					return;
				}
				//#Bugfix for 16215 ends 
				meetingManagerHelper.updateMeetingRoom(this,classVO, null,selectedContactIds,null,"N",contactModuleRO.userVO.userId);				
			}
		}	
		
		public function updateMeetingRoomResultHandler(event:ResultEvent):void
		{
			//if(meetingRoomManagerModel.isAddContactsGuests())
			//{
				var  classRegHelper:ClassRegistrationHelper=new ClassRegistrationHelper();
				classRegHelper.getClassRegistersForClass(this.meetingRoom.classId,onClassRegistrationResult,null);				
			//}
			//else
			//{
				//this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.EDITED_MEETINGROOM,null));
				Alert.show("Meeting Room updated successfully","INFORMATION");
			//}			
			removePopUp();
		}
		public function onClassRegistrationResult(classRegisters:ArrayCollection):void
		{	
			if(meetingRoomManagerModel.isAddContactsGuests())
			{
				var newMemberIds:Array =getNewMemberIds();			
				var members:Array=new Array();
				for(var index2:int=0;index2<newMemberIds.length;index2++)
				{
					for(var index1:int=0;index1<classRegisters.length;index1++)
					{
						if(classRegisters[index1].user.userId ==newMemberIds[index2])
						{						
							members.push(classRegisters[index1]);
							break;
						}
					}
				}
			
				var lecture:LectureVO=ClassroomContext.lecture;
				var obj:Object=new Object;
				var lectureName:String=lecture.lectureName;
				obj.title=lectureName.substr(0,lectureName.lastIndexOf('~'));
				obj.userName=contactModuleRO.userVO.userName;
				obj.moderatorName=contactModuleRO.userVO.userName;
				obj.userId=contactModuleRO.userVO.userId;
				obj.lectureId=lecture.lectureId;
				obj.classId=this.meetingRoom.classId;
				sendInvitation(members,obj);
			}
			var meetingRoomVO:MeetingRoomVO=new MeetingRoomVO();
			meetingRoomVO.meetingRoom=this.meetingRoom;
			meetingRoomVO.meetingRoomMembers=classRegisters;
			meetingRoomVO.computePastAndUpcomingMeetings();
			this.dispatchEvent(new MeetingRoomEvent(MeetingRoomEvent.EDITED_MEETINGROOM,meetingRoomVO));
			
		}
		private function getNewMemberIds():Array
		{
			var selectedContactsIds:ArrayCollection=contactsSelectionController.getSelectedContactIds();
			var newUsers:Array=new Array();
			for(var index1:int=0;index1<selectedContactsIds.length;index1++)			
			{
				var memberExist:Boolean=false;
				for(var index:int=0;index<meetingRoomManagerModel.meetingMembers.length;index++)
				{				
					if(meetingRoomManagerModel.meetingMembers[index].user.userId==selectedContactsIds[index1])
					{
						memberExist=true;
						break;
					}
				}
				if(!memberExist)
				{
					newUsers.push(selectedContactsIds[index1])
				}
			}
			return newUsers;
		}
		private function sendInvitation(members:Array, meetingInfo:Object):void
		{
			var invitationDetails:Array=new Array;
			for each (var meetingMember:Object in members)
			{
				var classRegistrationId:Number=meetingMember.classRegisterId;
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
			if (contactModuleRO.mediaServerConnection != null)
				contactModuleRO.mediaServerConnection.netConnection.call("sendInvitation", null, invitationDetails);
		}
		public function updateMeetingRoomFaultHandler(event:FaultEvent):void
		{
			Alert.show("Meeting Room update failed","INFORMATION");
			removePopUp();
		}
		private function removePopUp():void
		{
			PopUpManager.removePopUp(this.meetingRoomManagerView);
		}

	}
}