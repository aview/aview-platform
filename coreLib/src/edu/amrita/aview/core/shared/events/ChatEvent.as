////////////////////////////////////////////////////////////////////////////////
//
// Copyright  � 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 *
 * File			: ChatEvent.as
 * Module		: chat
 * Developer(s)	: NidhiSarasan, Soumya M.D.
 * Reviewer(s)	: Bri.Radha,Vishnupreethi K
 *
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.core.shared.events
{
	import com.amrita.edu.collaboration.CollaborationObject;
	
	import flash.events.Event;
	
	import mx.events.ItemClickEvent;

	/**
	 * @public
	 *
	 * 
	 */
	public class ChatEvent extends Event	
	{
		// Event types for ChatEvent
		public static const CONTINUE_CHAT:String = "continueChat";
		public static const INITIATE_GROUP_CHAT:String = "startGroupChat";
		public static const INITIATE_PRIVATE_CHAT:String = "startPrivateChat";
		public static const END_CHAT:String = "endChat";
		public static const EXIT_CHAT:String = "exitChat";
		public static const TERMINATE_CHAT:String = "chatEnded";
		
		public static const SEND_CHAT_MESSAGE:String = "sendChatMessage";
		public static const CLEAR_CHAT_AREA:String = "clearChatArea";

		public static const MINIMIZE:String = "minimize";
		public static const RESTORE:String = "restore";
		public static const RESTORED:String = "restored";
		
		public static const DELETE_CHAT_MEMBERS:String = "deleteChatMembers";
		public static const ADD_CHAT_MEMBERS:String = "addChatMembers";
		
		public static const EXIT_ALL_CHATS:String = "EXIT_ALL_CHATS";
        
		//public static const START_PRIVATE_CHAT:String = "privateChat";
		
		/**
		 * Chat Invitation Received 
		 */
		public static const INVITATION_RECEIVED:String="InvitationReceived";	
		
		/**
		 * Reset the Collaboration Object for chat
		 */
		public static const RESET_COLLAB_OBJECT:String="ResetCollaborationObject";
        /**
		 * Variable for CollaborationObject
		 */
		private var _groupSO:CollaborationObject=null;
		/**
		 * Variable to store the  ownername
		 */
		private var _groupOwner:String=null;
		/**
		 * Variable to store the  groupName
		 */
		private var _groupName:String=null;
		
		private var _data:Object = null;

		/**
		 * @public constructor
		 * @param type of type String
		 * @param groupSO of type CollaborationObject
		 * @param groupOwner of type String
		 * @param groupName of type String
		 * @param bubbles of type Boolean
		 * @param cancelable of type Boolean
		 * 
		 */
		public function ChatEvent(type:String, data:Object=null, groupSO:CollaborationObject=null, groupOwner:String=null, groupName:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this._data = data;
			this._groupSO=groupSO;
			this._groupOwner=groupOwner;
			this._groupName=groupName;
			super(type, true);
		}

		/**
		 * @public
		 *
		 * @return CollaborationObject
		 * 
		 */
		/**
		 * VPCR: Add function description */
		public function get groupSO():CollaborationObject
		{
			return _groupSO;
		}

		/**
		 * @public
		 * 
		 * @return String
		 * 
		 */
		public function get groupOwner():String
		{
			return _groupOwner;
		}
		/**
		 * @public
		 * 
		 * @return String
		 * 
		 */
		public function get groupName():String
		{
			return _groupName;
		}
		/**
		 * @public
		 * @param value of type String 
		 * 
		 */
		public function set groupName(value:String):void
		{
			_groupName=value;
		}

		/**
		 * @public 
		 * @return object
		 * 
		 */
		public function get data():Object
		{
			return _data;
		}
	}
}
