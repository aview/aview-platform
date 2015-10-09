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
 * File		   : ContactsEvent.as
 * Module	   : contacts
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) : Bri.Radha
 */
//VGCR:-function Description 
//VGCR:-Variable Description 
package edu.amrita.aview.contacts.events
{
	import flash.events.Event;
	
	/**
	 * @public
	 * extends Event
	 * //PNCR: class description
	 */
	public class ContactsEvent extends Event
	{
		public static const CREATE_GROUP:String = "createGroup";
		public static const EDIT_GROUP_NAME:String = "editGroupName";
		public static const DELETE_GROUP:String = "deleteGroup";
		public static const GET_USERS:String = "getUsers";
		public static const ADD_USER:String = "addUser";
		public static const SEARCH_USER:String = "searchUser";
		public static const DELETE_USERS:String = "deleteUsers";
		public static const DELETED_USERS:String = "deletedUsers";
		public static const START_GROUP_CHAT_BY_GROUP:String = "startGroupChatByGroup";
		public static const START_GROUP_CHAT_BY_MEMBERS:String = "startGroupChatByContacts";
		public static const START_PRIVATE_CHAT:String = "startPrivateChat";
		public static const SELECTED_GROUP:String = "selectedGroup";
		public static const USER_STATUS_CHANGED:String="userStatusChanged";
		public static const REFRESH:String="Refresh";
		
	
		
		
		private var _data:Object = null;
		
		/**
		 * @public 
		 * //PNCR: description
		 * @param type of type String
		 * @param data of type Object default value=null
		 */
		public function ContactsEvent(type:String, data:Object=null)
		{
			super(type, true);
			this._data = data;
			
		}

		/**
		 * @public 
		 * //PNCR: description
		 * @return Object
		 */
		public function get data():Object
		{
			return _data;
		}
		
		
	}
}