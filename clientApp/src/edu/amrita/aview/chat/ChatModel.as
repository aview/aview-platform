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
 * File			: ChatModel.as
 * Module		: Chat
 * Developer(s)	: Ravishankar
 * Reviewer(s)	: Vishnupreethi K  
 */

/**
 * VPCR: Add file description */
package edu.amrita.aview.chat
{
	import edu.amrita.aview.chat.vo.ChatSessionMemberVO;
	import edu.amrita.aview.chat.vo.ChatSessionVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import mx.collections.ArrayCollection;

	/**
	 * VPCR: Add class description */
	
	[Bindable]
	public class ChatModel
	{
		
		private var _isModerator:Boolean = false;
		
		private var _chatSessionVO:ChatSessionVO = null;
		
		private var _currentUserVO:UserVO = null;
		
		
		/**
		 * @public 
		 * @param userVO of type UserVO
		 * @param chatSessionId of type String
		 * @param moderator  of type String
		 * @param members of type ArrayCollection
		 * @param title  of type String
		 * 
		 */
		public function ChatModel(chatSessionVO:ChatSessionVO,user:UserVO)
		{
			this._chatSessionVO = chatSessionVO;
			this._currentUserVO = user;
			this._isModerator = (_currentUserVO.userId == _chatSessionVO.owner.userId);
			
			//If chat session is not already processed for currentChatSessionMemberVO...
			if (!_chatSessionVO.currentChatSessionMemberVO)
			{
				//remove the current user from member list and add moderator at the top.
				if (!isModerator)
				{
					var members:ArrayCollection = _chatSessionVO.members;
					for (var i:int = 0; i < members.length; i++)
					{
						if (members[i].member.userName == _currentUserVO.userName)
						{
							_chatSessionVO.currentChatSessionMemberVO = members[i];
							members.removeItemAt(i);
							break;
						}
					}
					chatSessionVO.addOwnerAsMember();
				}
			}
			
		}
		/**
		 * @public 
		 * @param newMembers of type ArrayCollection
		 * 
		 */
		public function addChatMembers(newMembers:ArrayCollection):void
		{
			_chatSessionVO.addMembers(newMembers);
		}
		
		/**
		 * @public 
		 * @param deletedMembers of type ArrayCollection
		 * 
		 */
		public function removeChatMembers(deletedMembers:ArrayCollection):void
		{
			for each (var deletedMember:ChatSessionMemberVO in deletedMembers)
			{
				removeChatMember(deletedMember.member.userName);
			}
		}
		
		public function removeChatMember(userName:String):void
		{
			var members:ArrayCollection = _chatSessionVO.members;
			for (var i:int = 0; i < members.length; i++)
			{
				if (members[i].member.userName == userName)
				{
					members.removeItemAt(i);
					break;
				}
			}
		}
		

		public function updateChatMembersStatus(userStatus:String, name:String):void
		{
			if(_chatSessionVO.owner.userName == name)
			{
				_chatSessionVO.owner.userStatus = userStatus;
			}
			else
			{
				for each (var member:ChatSessionMemberVO in _chatSessionVO.members)
				{
					if (member.member.userName == name)
					{
						member.member.userStatus = userStatus;
						_chatSessionVO.members.refresh();
						break;
					}
				}
			}
		}

		public function get isModerator():Boolean
		{
			return _isModerator;
		}

		[Bindable]
		public function get chatSessionVO():ChatSessionVO
		{
			return _chatSessionVO;
		}
	}
}