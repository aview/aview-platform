////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 *
 * File			: ContactsModel.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Bri.Radha
 *
 * 
 */
//VGCR:-function Description 
package edu.amrita.aview.contacts
{
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.contacts.vo.GroupVO;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	//PNCR: class description
	public class ContactsModel
	{
		public var contactGroups:ArrayCollection = null;

		public var groupUsers:ArrayCollection = null;
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param userVO of type UserVO
		 * @param contactGroups of type ArrayCollection
		 * 
		 */
		public function ContactsModel(contactGroups:ArrayCollection)
		{
			this.contactGroups = contactGroups;
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
			for each (var contactGroup:GroupVO in contactGroups)
			{
				if (contactGroup.contactGroupName == groupName)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param group of type GroupVO
		 * 
		 */
		public function addContactGroup(group:GroupVO):void
		{
			contactGroups.addItem(group);
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
			for each (var group:GroupVO in contactGroups)
			{
				if (group.contactGroupName == oldGroup.contactGroupName)
				{
					group = newGroup;
					contactGroups.refresh();
					break;
				}
			}
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param groupId of type Number
		 * 
		 */
		public function deleteContactGroup(groupId:Number):void
		{
			for (var i:int = 0; i < contactGroups.length; i++)
			{
				if (contactGroups[i].contactGroupId == groupId)
				{
					contactGroups.removeItemAt(i);
					contactGroups.refresh();
					break;
				}
			}
		}
		
		/**
		 * @public
		 * //PNCR: description 
		 * @param userName of type String
		 * @return Boolean
		 */
		public function checkUserDuplicity(userName:String):Boolean
		{
			for each (var groupUser:GroupUserVO in groupUsers)
			{
				if (groupUser.user.userName == userName)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param user of type GroupUserVO
		 */
		public function addGroupUser(user:GroupUserVO):void
		{
			groupUsers.addItem(user);
		}
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @param users of type ArrayCollection
		 * @return void
		 */
		public function deleteGroupUsers(users:ArrayCollection):void
		{
			for each (var groupUser:GroupUserVO in users)
			{
				for (var i:int = 0; i < groupUsers.length; i++)
				{
					if (groupUsers[i].user.userId == groupUser.user.userId)
					{
						groupUsers.removeItemAt(i);
					}
				}
			}
		}
	}
}