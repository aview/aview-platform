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
 * File			: GroupUserVO.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	:
 *
 * Value Object Class for GroupUser, group_user table
 * Holds the group id and user id and its associated details.
 *
 */
/**
 * Package for GroupUser.
 */
package edu.amrita.aview.contacts.vo
{
	
	import edu.amrita.aview.common.vo.Auditable;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	[RemoteClass(alias="edu.amrita.aview.contacts.entities.GroupUser")]
	
	/**
	 * @public
	 * //PNCR: description
	 */
	[Bindable]
	public dynamic class GroupUserVO extends Auditable
	{
		/**
		 * @public
		 * constructor
		 */
		public function GroupUserVO()
		{
		
		}
		/**
		 * Primary key, auto generated by database, while inserting user to group.
		 */
		private var _groupUserId:Number=01;
		/**
		 * Group details
		 */
		private var _group:GroupVO=null;
		/**
		 * userDetails
		 */
		private var _user:UserVO=null;
		
		//added for my conatct userList
		private var _userStatus:String=null;
		//The following booleans are added for GUI (MeetingRoomManager) purposes
		private var _isExisting:Boolean = false;
		private var _isSelected:Boolean = false;
		private var _isSelectable:Boolean = false;
		
		/**
		 * @public
		 * get function for current user
		 * @return UserVO
		 */
		public function get user():edu.amrita.aview.core.gclm.vo.UserVO
		{
			return _user;
		}
		
		/**
		 * @public
		 * set function for current user
		 * @param value of type UserVO
		 */
		public function set user(value:UserVO):void
		{
			_user=value;
		}
		
		/**
		 * @public
		 * get function for group
		 * @return GroupVO
		 */
		public function get group():GroupVO
		{
			return _group;
		}
		
		/**
		 * @public
		 * set function for group
		 * @param value of type GroupVO
		 */
		public function set group(value:GroupVO):void
		{
			_group=value;
		}
		
		/**
		 * @public
		 * get funciton for group User id
		 * @return Number
		 */
		public function get groupUserId():Number
		{
			return _groupUserId;
		}
		
		/**
		 * @public
		 * set funciton for group User id
		 * @param value of type Number
		 */
		public function set groupUserId(value:Number):void
		{
			_groupUserId=value;
		}
		
		/**
		 * @public
		 * function to get user Status
		 * @return String
		 */
		public function get userStatus():String
		{
			return _userStatus;
		}
		
		/**
		 * @public
		 * function to set user Status
		 * @param value type of String
		 */
		public function set userStatus(value:String):void
		{
			_userStatus=value;
		}
		
		public function get isExisting():Boolean
		{
			return _isExisting;
		}
		
		public function set isExisting(value:Boolean):void
		{
			_isExisting = value;
		}
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
		}
		
		public function get isSelectable():Boolean
		{
			return _isSelectable;
		}
		
		public function set isSelectable(value:Boolean):void
		{
			_isSelectable = value;
		}
		
		
		public function get contactName():String
		{
			return _user.userDisplayName;
		}
	}
}
