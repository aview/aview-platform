package edu.amrita.aview.contacts
{
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import spark.components.Group;
	
    [Bindable]
	public class GroupListModel
	{
		public static const ALL_CONTACTS="All Contacts";
		
		public var selectedGroup:GroupVO=null;
		public var allGroupsAndContacts:ArrayCollection=null;
		public var allContactCount:int=0;
		public var allContactsGroup:GroupVO=null;
		public var receivedGroups:ArrayCollection=null;
		private var _contactsTitle:String=null;
		
		public function GroupListModel(allContacts:ArrayCollection)
		{
			allGroupsAndContacts=allContacts;
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param group of type GroupVO
		 * 
		 */
		public function addContactGroup(group:GroupVO):void
		{
			if(allGroupsAndContacts==null)
			{
				allGroupsAndContacts=new ArrayCollection();
			}
			allGroupsAndContacts.addItem(group);
			createAllContactsGroup();
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param oldGroup of type GroupVO
		 * @param newGroup of type GroupVO
		 * 
		 */
		public function updateContactGroup(oldGroup:GroupVO, newGroup:GroupVO):void
		{
			for each (var group:GroupVO in allGroupsAndContacts)
			{
				if (group.contactGroupName == oldGroup.contactGroupName)
				{
					group.contactGroupName=newGroup.contactGroupName;
					group.modifiedDate=newGroup.modifiedDate;
					group.modifiedByUserId=newGroup.modifiedByUserId;
					allGroupsAndContacts.refresh();
					break;
				}
			}
			createAllContactsGroup();
		}
		/**
		 * @public 
		 * //PNCR: description 
		 * @param groupId of type Number
		 * 
		 */
		public function deleteContactGroup(groupId:Number):void
		{
			for (var i:int = 0; i < allGroupsAndContacts.length; i++)
			{
				if (allGroupsAndContacts[i].contactGroupId == groupId)
				{
					allGroupsAndContacts.removeItemAt(i);
					allGroupsAndContacts.refresh();
					break;
				}
			}
			createAllContactsGroup();
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param groupName of type String
		 * @return Boolean
		 * 
		 */
		public function checkGroupNameDuplicity(groupName:String):Boolean
		{
			if(allGroupsAndContacts==null)
			{
				return false;
			}
			for each (var contactGroup:GroupVO in allGroupsAndContacts)
			{
				if (contactGroup.contactGroupName == groupName)
				{
					return true;
				}
			}
			return false;
		}
		
		public function getGroupById(groupId:Number):GroupVO
		{
			for(var index:int=0;index<allGroupsAndContacts.length;index++)
			{
				if(allGroupsAndContacts[index].contactGroupId==groupId)
				{
					return allGroupsAndContacts[index] as GroupVO;
				}
			}
			return null;
		}
		
		public function createAllContactsGroup():void
		{
			var allGroupUsers:ArrayCollection=new ArrayCollection();
			for(var index:int=0;index<this.allGroupsAndContacts.length;index++)
			{   
				var groupUsers:ArrayCollection=(this.allGroupsAndContacts[index] as GroupVO).groupUsers;
				if(groupUsers!=null)
				{					
					for (var j:int=0; j < groupUsers.length; j++)
					{
						var userExist:Boolean=false;
						for( var i:int=0;i<allGroupUsers.length;i++)
						{
							if(allGroupUsers[i].user.userName == groupUsers[j].user.userName)
							{
								userExist=true;
								break;						
							}
						}
						if(!userExist)
						{
							var obj:Object=ObjectUtil.copy(groupUsers[j]);
							
							//TODO: add userstatus
							allGroupUsers.addItem(obj);
						}
					}
					
				}
			}			
			allContactsGroup=new GroupVO();
			allContactsGroup.contactGroupName=ALL_CONTACTS;
			allContactsGroup.groupUsers=allGroupUsers;
			allContactCount=allGroupUsers.length;
		}
		public function setAllContactsSelection():void
		{
			selectedGroup=allContactsGroup;
		}

	}
}