package edu.amrita.aview.contacts
{
	import edu.amrita.aview.common.util.ArrayCollectionUtil;
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.UserStatusProviderEvent;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class ContactsSelectionModel extends EventDispatcher
	{
		private var	_allContactCount:int=0;
		private var _allGroupsAndContacts:ArrayCollection=null;
		private var _existingUsers:ArrayCollection=null;
		private var _visibleContacts:ArrayCollection=new ArrayCollection()
		private var _allowContactsRemoval:Boolean=false;
		private var uniqueGroupUserMap:Object=null;
		private var _isEmbedded:Boolean = true;
		private var moduleRO:ModuleRO=null;
		public function ContactsSelectionModel(allContacts:ArrayCollection,moduleRO:ModuleRO,
											   existingUsers:ArrayCollection,allowContactsRemoval:Boolean,isEmbedded:Boolean = true)
		{
			_allGroupsAndContacts = allContacts;
			_existingUsers=existingUsers;
			_allowContactsRemoval=allowContactsRemoval;
			_isEmbedded = isEmbedded; 
			this.moduleRO=moduleRO;
		}
		
		
		public function init():void
		{
			moduleRO.moduleEventMap.registerInitiator(this,UserStatusProviderEvent.USER_STATUS_CHANGE);
			moduleRO.applicationEventMap.registerMapListener(ContactsEvent.USER_STATUS_CHANGED,changeUserStatus);
			this.dispatchEvent(new UserStatusProviderEvent(UserStatusProviderEvent.USER_STATUS_CHANGE,setUserStatusInallContacts));
		}
		
		private function changeUserStatus(event:ContactsEvent):void
		{
			for(var index:int=0;index<visibleContacts.length;index++)
			{
				if(visibleContacts[index] is GroupUserVO)
				{
					var group:GroupUserVO=visibleContacts[index] as GroupUserVO;
					
					var userVO:UserVO=group.user;
					var userStatusObj:Object=event.data;
					if(userStatusObj.name==userVO.userName)
					{
						userVO.userStatus=userStatusObj.userStatus;
						break;
					}
					
				}
			}
			visibleContacts.refresh();
		}
		private function setUserStatusInallContacts(onlineUsers:Object):void
		{
			for (var index:int=0; index < allGroupsAndContacts.length; index++)
			{
				var group:GroupVO=allGroupsAndContacts[index] as GroupVO;
				if(group.groupUsers!=null)
				{
					for(var uIdx:int = 0;uIdx < group.groupUsers.length; uIdx++)
					{
						var gUser:GroupUserVO = group.groupUsers[uIdx];
						var userName:String=gUser.user.userName;
						if(onlineUsers[userName]!=null)
						{
							gUser.user.userStatus=onlineUsers[userName];
						}
						else
						{
							gUser.user.userStatus=Constants.OFFLINE;
						}
						
					}
				}
			}
			prepareAllGroupsAndContacts();
		}
		private function prepareAllGroupsAndContacts():void
		{				
			uniqueGroupUserMap = new Object();
			ArrayCollectionUtil.sortData(allGroupsAndContacts, "contactName", false, true);
			for (var index:int=0; index < allGroupsAndContacts.length; index++)
			{
				var group:GroupVO=allGroupsAndContacts[index] as GroupVO;
				group.isExpanded=false;
				group.isSelected=false;
				group.isExisting=false;
				group.isSelectable=true;
				visibleContacts.addItem(group);
				_allContactCount+=group.memberCount;
				if(group.groupUsers!=null)
				{
					ArrayCollectionUtil.sortData(group.groupUsers, "contactName", false, true);
					for(var uIdx:int = 0;uIdx < group.groupUsers.length; uIdx++)
					{
						var gUser:GroupUserVO = group.groupUsers[uIdx];
					
						var processedUser:GroupUserVO = uniqueGroupUserMap[gUser.user.userId] as GroupUserVO;
						if(processedUser)
						{
							//Replace the current GroupUser with the pre-existing, unique GroupUser, so that they share the same reference.
							//Hence changes to the user in one group, gets automatically reflected in all the occurances of this user in various groups
							group.groupUsers.setItemAt(processedUser,uIdx);
						}
						else
						{
							var exists:Boolean = isUserInExistingContacts(gUser.user.userId);
							gUser.isSelected=exists;
							gUser.isExisting=exists;
							gUser.isSelectable=!(exists && !_allowContactsRemoval);
						
							//Since it's going to be the common UserVO which is 
							//going to get shared across all the groups where this user exists, 
							//we are clearing out unused group specific attributes of the GroupUser
							gUser.group = null;
							gUser.groupUserId = 0;					
							uniqueGroupUserMap[gUser.user.userId] = gUser;
						}
					}
				}
			}
			//Check to see if there are any meeting members who are not in contacts, lists then in a separate group
			addMembersNotInContacts();
			visibleContacts.refresh();
		}
		public function getSelectedContactIds():ArrayCollection
		{
			var selectedContactIds:ArrayCollection = new ArrayCollection();		
			for (var index:int=0; index < allGroupsAndContacts.length; index++)
			{
				var group:GroupVO=allGroupsAndContacts[index] as GroupVO;
				if(group.groupUsers!=null)
				{
					for(var uIdx:int = 0;uIdx < group.groupUsers.length; uIdx++)
					{
						var gUser:GroupUserVO = group.groupUsers[uIdx];
						if(gUser.isSelected)
						{
							if(selectedContactIds.getItemIndex(gUser.user.userId) == -1)
							{
								selectedContactIds.addItem(gUser.user.userId);
							}
						}
					}
				}
			}			
			return selectedContactIds;
		}
		public function getNewlySelectedUsers():ArrayCollection
		{
			var newlySelectedUsers:ArrayCollection = new ArrayCollection();		
			for (var index:int=0; index < allGroupsAndContacts.length; index++)
			{
				var group:GroupVO=allGroupsAndContacts[index] as GroupVO;				
				for(var uIdx:int = 0;uIdx < group.groupUsers.length; uIdx++)
				{
					var gUser:GroupUserVO = group.groupUsers[uIdx];
					if(gUser.isSelected && !gUser.isExisting)
					{
						if(newlySelectedUsers.getItemIndex(gUser.user) == -1)
						{
							newlySelectedUsers.addItem(gUser.user);
						}
					}
				}
			}			
			return newlySelectedUsers;
		}
		private function isUserInExistingContacts(userId:Number):Boolean
		{
			var exists:Boolean = false;
			if(existingUsers)
			{
				for(var i:int=0; i<existingUsers.length;i++)
				{
					if(existingUsers[i].userId == userId)
					{
						exists = true;
						break;
					}
				}
			}
			return exists;
		}
		
		private function addMembersNotInContacts():void
		{
			if(existingUsers)
			{
				var nonContactsGroup:GroupVO = new GroupVO();
				
				nonContactsGroup.contactGroupName = "*PeopleNotInContacts*";
				nonContactsGroup.groupUsers = new ArrayCollection();
				
				nonContactsGroup.isExpanded=false;
				nonContactsGroup.isSelected=false;
				nonContactsGroup.isExisting=true;
				nonContactsGroup.isSelectable=true;
				
				
				for(var i:int=0; i<existingUsers.length;i++)
				{
					if(!uniqueGroupUserMap[existingUsers[i].userId])
					{
						var gUser:GroupUserVO = new GroupUserVO();
						gUser.isSelected=true;
						gUser.isExisting=true;
						gUser.isSelectable=_allowContactsRemoval;
						
						gUser.user = existingUsers[i];
						nonContactsGroup.groupUsers.addItem(gUser);
						uniqueGroupUserMap[gUser.user.userId] = gUser;
					}
				}
				
				if(nonContactsGroup.groupUsers.length > 0)
				{
					nonContactsGroup.memberCount = nonContactsGroup.groupUsers.length;
					ArrayCollectionUtil.sortData(nonContactsGroup.groupUsers, "contactName", false, true);
					allGroupsAndContacts.addItemAt(nonContactsGroup,allGroupsAndContacts.length);
					visibleContacts.addItemAt(nonContactsGroup,visibleContacts.length);
				}
			}
		}

		public function get allContactCount():int
		{
			return _allContactCount;
		}

		public function get allGroupsAndContacts():ArrayCollection
		{
			return _allGroupsAndContacts;
		}

		public function get existingUsers():ArrayCollection
		{
			return _existingUsers;
		}

		public function get visibleContacts():ArrayCollection
		{
			return _visibleContacts;
		}

		public function get allowContactsRemoval():Boolean
		{
			return _allowContactsRemoval;
		}

		public function get isEmbedded():Boolean
		{
			return _isEmbedded;
		}


	}
}