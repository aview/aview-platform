package edu.amrita.aview.meeting
{
	import com.adobe.utils.StringUtil;
	
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.meeting.vo.MeetingRoomVO;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	[Bindable]
	public class MeetingRoomManagerModel
	{
		public static const MODE_CREATE_ROOM:String = "MODE_CREATE_ROOM"; 
		public static const MODE_EDIT_ROOM:String = "MODE_EDIT_ROOM"; 
		public static const MODE_ADD_CONTACTS:String = "MODE_ADD_CONTACTS"; 
		public static const MODE_ADD_CONTACTS_GUESTS:String = "MODE_ADD_CONTACTS_GUESTS"; 
		
		///private var _meetingRoomVO:MeetingRoomVO=null;
		public var meetingMembers:ArrayCollection=null;
		public var roomName:String=null;		
		public var guestEmailIds:ArrayCollection=null;
		private var _mode:String=null;
		private var allMeetingRooms:ArrayCollection=null;
		private var userVO:UserVO=null;
		
		public function MeetingRoomManagerModel(meetingMembers:ArrayCollection,
												mode:String,
												roomName:String,
												allMeetingRooms:ArrayCollection,
												userVO:UserVO)
		{
			this.meetingMembers=meetingMembers
			this._mode=mode;
			this.roomName=roomName;		
			this.allMeetingRooms=allMeetingRooms;
			this.userVO=userVO;
		}
		
		
		public function get mode():String
		{
			return _mode;
		}
		public function getMeetingUsers():ArrayCollection
		{
			var meetingUsers:ArrayCollection=new ArrayCollection();
			if(this.meetingMembers!=null)
			{
				for(var index:int=0;index<this.meetingMembers.length;index++)
				{
					meetingUsers.addItem(this.meetingMembers[index].user);
				}
			}
			return meetingUsers;
		}
	
		
		public function isRoomNameVisible():Boolean
		{
			return (mode == MeetingRoomManagerModel.MODE_CREATE_ROOM 
				|| mode == MeetingRoomManagerModel.MODE_EDIT_ROOM );
		}
		
		public function allowContactsRemoval():Boolean
		{
			return (mode == MeetingRoomManagerModel.MODE_CREATE_ROOM 
				|| mode == MeetingRoomManagerModel.MODE_EDIT_ROOM );
		}
		
		public function isEditRoom():Boolean
		{
			return (mode == MeetingRoomManagerModel.MODE_EDIT_ROOM);
		}
		public function isAddPeople():Boolean
		{
			return(mode==MeetingRoomManagerModel.MODE_ADD_CONTACTS);
		}
		public function isAddContactsGuests():Boolean
		{
			return(mode == MeetingRoomManagerModel.MODE_ADD_CONTACTS_GUESTS);
		}
			
		
		public function isCreateRoom():Boolean
		{
			return (mode == MeetingRoomManagerModel.MODE_CREATE_ROOM );
		}
		public function getNewGuestMailIds():ArrayCollection
		{
			if(guestEmailIds!=null && guestEmailIds.length>0)
			{				
				for (var index:int=0; index < guestEmailIds.length; index++)
				{
					for (var index1:int=0; index1 <meetingMembers .length; index1++)
					{
						if (guestEmailIds[index] == meetingMembers[index1].user.email)
						{
							guestEmailIds.removeItemAt(index);
							index--;
							break;
						}
					}
				}
			}
			return guestEmailIds;
		}
		public function isNewMembersSelected(userIds:ArrayCollection):Boolean
		{
			if(userIds==null)
				return false;
			var usercount:int=userIds.length;
			for (var index1:int=0;index1<userIds.length;index1++)
			{
				if(userIds[index1]==userVO.userId)
				{
					usercount--;					
				}
				else
				{
					for(var index:int=0;index<meetingMembers.length;index++)
					{
			
						if(meetingMembers[index].user.userId==userIds[index1])
						{
							usercount--;
							break;
						}
					
					}
				}
				
			}
			if(usercount==0)
			{
				return false;
			}
			
			return true;
			
		}
		public function isRoomNameExist(newRoomName:String):Boolean
		{
			if(newRoomName!=null && roomName!=null)
			{				
				var oldRoomName:String=roomName.toLocaleLowerCase();
				if(newRoomName==oldRoomName)
				{
					return false;
				}
				else
				{
					roomName=newRoomName;
				}
			}	
			else if(newRoomName!=null)
			{
				roomName=newRoomName;
			}
			if(allMeetingRooms!=null)
			{
				for(var index:int  = 0; index < allMeetingRooms.length; index++)
				{
					if(roomName == allMeetingRooms[index].meetingRoom.className.toLowerCase())
					{
						Alert.show("Room name is present ,Please give another name","WARNING");
						return true;
					}
				}
			}
			return false;
		}
		
	}
}