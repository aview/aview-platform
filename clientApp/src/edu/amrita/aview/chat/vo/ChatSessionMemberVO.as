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
 * File			: ChatSessionMemberVO.as
 * Module		: chat
 * Developer(s)	: Soumya M.D, NidhiSarasan
 * Reviewer(s)	:
 *
 *
 */
package edu.amrita.aview.chat.vo
{
	import edu.amrita.aview.common.vo.Auditable;
	
	[RemoteClass(alias="edu.amrita.aview.chat.entities.ChatSessionMember")]
	/**
	 * @public
	 *
	 * @return null
	 * 
	 */
	//RGCR: Chat participants
	public class ChatSessionMemberVO extends Auditable
	{
		/**
		 * @public
		 * Default constructor
		 *
		 * @return null
		 *
		 */
		public function ChatSessionMemberVO()
		{
		
		}
		
		public function getServerObject():Object
		{
			var obj:Object = new Object();
			obj["chatSessionMemberId"] = chatSessionMemberId;
			obj["member"] = member.getServerObject();
			obj["chatSessionId"] = chatSessionId;
			return obj;
		}
		/**
		 * variable to store the chatSessionMemberId
		 */
		private var _chatSessionMemberId:Number=0;
		/**
		 * variable to store the memeber
		 */
		import edu.amrita.aview.core.gclm.vo.UserVO;
		private var _member:UserVO=null;
		
		private var _chatSessionId:Number = 0;
		
		/**
		 * @public
		 * Function to get chat Session Member Id
		 *
		 * @return Number(chatSessionMemberId)
		 */
		public function get chatSessionMemberId():Number
		{
			return _chatSessionMemberId;
		}
		/**
		 * @public
		 * Function to set chat Session Member Id
		 * @param value of type Number
		 * @return void
		 */
		public function set chatSessionMemberId(value:Number):void
		{
			_chatSessionMemberId=value;
		}
		/**
		 * @public
		 * Function to get member
		 *
		 * @return UserVO(member)
		 */
		public function get member():UserVO
		{
			return _member;
		}
		/**
		 * @public
		 * Function to set member
		 * @param value of type UserVO
		 * @return void
		 */
		public function set member(value:UserVO):void
		{
			_member=value;
		}
		/**
		 * @public
		 * Function to get chat Session id
		 *
		 * @return Number(chat Session id)
		 */
		public function get chatSessionId():Number
		{
			return _chatSessionId;
		}

		/**
		 * @public
		 * Function to set chat Session id
		 * @param value of type Number
		 * @return void
		 */
		public function set chatSessionId(value:Number):void
		{
			_chatSessionId = value;
		}
	
	
	}
}
