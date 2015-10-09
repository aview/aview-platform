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
 * File			: ChatSessionVO.as
 * Module		: chat
 * Developer(s)	: Soumya M.D, NidhiSarasan
 * Reviewer(s)	:
 *
 *
 */
package edu.amrita.aview.chat.vo
{
	
	
	import edu.amrita.aview.chat.vo.ChatSessionMemberVO;
	import edu.amrita.aview.common.vo.Auditable;
	import edu.amrita.aview.common.vo.StatusVO;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Text;
	import mx.formatters.DateFormatter;
	import mx.utils.ObjectUtil;
	
	[RemoteClass(alias="edu.amrita.aview.chat.entities.ChatSession")]
	/**
	 * 
	 * @public
	 *
	 * @return null
	 * 
	 */
	public class ChatSessionVO extends Auditable
	{
		/**
		 * @public
		 * Default constructor
		 *
		 * @return null
		 *
		 */
		public function ChatSessionVO()
		{
		
		}
		
		public function getServerObject():Object
		{
			var obj:Object = new Object();
			obj["chatSessionId"] = chatSessionId;
			obj["owner"] = owner.getServerObject();
//			obj["title"] = title;
//			obj["lectureId"] = lectureId;
//			obj["isPrivateChat"] = isPrivateChat;
//			obj["chatHistory"] = chatHistory;
			obj["members"] = Auditable.getServerObjects(members);
			obj["messages"] = Auditable.getServerObjects(messages);
			return obj;
		}
		
		/**
		 * variable to store the chatSessionId
		 */
		private var _chatSessionId:Number=0;
		/**
		 * variable to store the ownerId
		 */
		private var _owner:UserVO=null;
		/**
		 * variable to store the title
		 */
		private var _title:String=null;
		/**
		 * variable to store the groupId
		 */
		private var _groupId:Number=0;
		/**
		 * variable to store the lectureId
		 */
		private var _lectureId:Number=0;
		/**
		 * variable to store if the Session is a private chat or group chat
		 */
		private var _isPrivateChat:String=null;
		
		private var _members:ArrayCollection=new ArrayCollection();
		
		private var _messages:ArrayCollection=new ArrayCollection();
		
		private var _chatHistory:String = "";
		
		//Used in ChatHistory.mxml
		private var _isSelected:Boolean = false;
		
		private var allMembersMap:Object = new Object();
		
		private var _chatHistoryTextFlow:TextFlow = null;
		
		private var _currentChatSessionMemberVO:ChatSessionMemberVO = null;

		
		
		private static var dateTimeFormatter:mx.formatters.DateFormatter = new DateFormatter();
		//Static block
		{
			dateTimeFormatter.formatString="DD-MMM-YYYY HH:NN:SS";
		}
		
		/**
		 * @public
		 * Function to get groupId
		 *
		 * @return Number(groupId)
		 */
		public function get groupId():Number
		{
			return _groupId;
		}
		/**
		 * @public
		 * Function to set groupId
		 * @param value of type Number
		 * @return void
		 */
		public function set groupId(value:Number):void
		{
			_groupId=value;
		}
		/**
		 * @public
		 * Function to get title
		 *
		 * @return String(title)
		 */
		public function get title():String
		{
			return _title;
		}
		/**
		 * @public
		 * Function to set title
		 * @param value of type String
		 * @return void
		 */
		public function set title(value:String):void
		{
			_title=value;
		}
		/**
		 * @public
		 * Function to get owner
		 *
		 * @return UserVO(owner)
		 */
		public function get owner():UserVO
		{
			return _owner;
		}
		/**
		 * @public
		 * Function to set owner
		 * @param value of type UserVO
		 * @return void
		 */
		public function set owner(value:UserVO):void
		{
			_owner=value;
		}
		/**
		 * @public
		 * Function to get chatSessionId
		 *
		 * @return Number(chatSessionId)
		 */
		public function get chatSessionId():Number
		{
			return _chatSessionId;
		}
		/**
		 * @public
		 * Function to set chat SessionId
		 * @param value of type Number
		 * @return void
		 */
		public function set chatSessionId(value:Number):void
		{
			_chatSessionId=value;
		}
		/**
		 * @public
		 * Function to get lectureId
		 *
		 * @return Number(lectureId)
		 */
		public function get lectureId():Number
		{
			return _lectureId;
		}
		/**
		 * @public
		 * Function to set lectureId
		 * @param value of type Number
		 * @return void
		 */
		public function set lectureId(value:Number):void
		{
			_lectureId=value;
		}

		/**
		 * 
		 * @return 
		 */
		public function get members():ArrayCollection
		{
			return _members;
		}

		/**
		 * 
		 * @param value
		 */
		public function set members(value:ArrayCollection):void
		{
			//Remove deleted members
			var tempList:ArrayCollection = new ArrayCollection();
			for each (var member:ChatSessionMemberVO in value)
			{
				allMembersMap[member.member.userId] = member;
				if(member.statusId != StatusVO.DELETED_STATUS)
				{
					tempList.addItem(member);
				}
			}
			_members = tempList;
		}
	
		
		/**
		 * @public
		 * function to add Chat Session Member
		 * @param chatSessionMember type of ChatSessionMemberVO
		 * @return void
		 */
		private function addMember(chatSessionMember:ChatSessionMemberVO):void
		{
			allMembersMap[chatSessionMember.member.userId] = chatSessionMember;

			this._members.addItem(chatSessionMember);
		}
		
		public function get titleWithDate():String
		{
			return title+" @ "+dateTimeFormatter.format(createdDate);
		}
		
		/**
		 * @public 
		 * @param newMembers of type ArrayCollection
		 * 
		 */
		public function addMembers(newMembers:ArrayCollection):void
		{
			for each (var newMember:ChatSessionMemberVO in newMembers)
			{
				addMember(newMember);
			}
		}
		
		public function getMember(userId:Number):ChatSessionMemberVO
		{
			return allMembersMap[userId];
		}
		
		public function getUsers():ArrayCollection
		{
			var users:ArrayCollection = new ArrayCollection();
			for each (var member:ChatSessionMemberVO  in this._members)
			{
				users.addItem(member.member);
			}
			return users;
		}
		
		/**
		 * @public
		 * function to add Chat Session Member
		 * @param user type of UserVO
		 * @return void
		 */
		public function addUser(user:UserVO):void
		{
			addMember(prepareChatSessionMember(user));
		}
		/**
		 * @public
		 * function to remove Chat Session Member
		 * @param user type of UserVO
		 * @return void
		 */
		public function removeUser(user:UserVO):void
		{
			for each(var member:ChatSessionMemberVO in members)
			{
				if(member.member.userId == user.userId)
				{
					members.removeItemAt(members.getItemIndex(member));
					delete allMembersMap[user.userId]
					break;
				}
			}
		}
		
		public function addOwnerAsMember():void
		{
			this._members.addItemAt(prepareChatSessionMember(owner), 0);
		}
		
		private function prepareChatSessionMember(user:UserVO):ChatSessionMemberVO
		{
			var memberVO:ChatSessionMemberVO = new ChatSessionMemberVO();
			memberVO.member = user;
			memberVO.chatSessionId = this._chatSessionId;
			return memberVO;
		}
		/**
		 * variable to store the lectureId
		 */
		public function get isPrivateChat():String
		{
			return _isPrivateChat;
		}

		/**
		 * @private
		 */
		public function set isPrivateChat(value:String):void
		{
			_isPrivateChat = value;
		}

		/**
		 * @public
		 * Function to get chatHistory
		 *
		 * @return String(chatHistory)
		 */
		[Bindable]
		public function get chatHistory():String
		{
			return _chatHistory;
		}
		
		public function clearChatHistoryByModerator():void
		{
			applicationType::DesktopWeb{
				chatHistory = "<b><font color = '" + Constants.CHAT_CLEAR_MSG_COLOR + "'>" + Constants.CHAT_CLEAR_TEXT_VWR + owner.userDisplayName + "</font></b><br>";
			}
			applicationType::mobile{
				chatHistory =Constants.CHAT_CLEAR_TEXT_VWR + owner.userDisplayName;
			}
		}
		
		private function getSenderDisplayName(senderId:Number):String
		{
			
			var sender:UserVO = null;
			if(senderId == owner.userId)
			{
				sender = owner;
			}
			else
			{
				sender = allMembersMap[senderId].member;
			}
			
			return (sender)?sender.userDisplayName:"";
		}
		
		public function addMessage(newMessage:ChatMessageVO):void
		{
			newMessage.prepareChatMessageDispayText(owner.userId,getSenderDisplayName(newMessage.createdByUserId),isPrivateChat);
			messages.addItem(newMessage);
			
			chatHistory += newMessage.chatMessageDispayText;
		}
		
		public function getMessageObject(messageText:String,senderId:Number):ChatMessageVO
		{
			var message:ChatMessageVO = new ChatMessageVO();
			message.chatSessionId = this._chatSessionId;
			message.chatMessageText = messageText;
			message.createdByUserId = senderId;
			
			return message;
		}

		public function get messages():ArrayCollection
		{
			return _messages;
		}

		/**
		 * @public
		 * Function to set chat Message
		 * @param value of type ArrayCollection
		 * @return void
		 */
		public function set messages(value:ArrayCollection):void
		{
			_messages = value;
		}
		
		public function prepareChatHistory():void
		{
			var tmp:String = "";
			for (var index:int=0; index < _messages.length; index++)
			{
				var chatMsg:ChatMessageVO = _messages[index] as ChatMessageVO;
				chatMsg.prepareChatMessageDispayText(owner.userId,getSenderDisplayName(chatMsg.createdByUserId),isPrivateChat);
				tmp+=(messages[index] as ChatMessageVO).chatMessageDispayText;
			}
			chatHistory = tmp;
		}

		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
		}

		public function set chatHistory(value:String):void
		{
			_chatHistory = value;
			chatHistoryTextFlow = TextConverter.importToFlow(_chatHistory, TextConverter.TEXT_FIELD_HTML_FORMAT);
		}

		[Bindable]
		public function get chatHistoryTextFlow():TextFlow
		{
			//Instead of returning the _chatHistoryTextFlow, we are making a new copy of it and returning, so that differnt UI controls can display it.
			_chatHistoryTextFlow = TextConverter.importToFlow(_chatHistory, TextConverter.TEXT_FIELD_HTML_FORMAT);
			return _chatHistoryTextFlow;
		}

		public function set chatHistoryTextFlow(value:TextFlow):void
		{
			_chatHistoryTextFlow = value;
		}
		
		
		public function get currentChatSessionMemberVO():ChatSessionMemberVO
		{
			return _currentChatSessionMemberVO;
		}

		public function set currentChatSessionMemberVO(value:ChatSessionMemberVO):void
		{
			_currentChatSessionMemberVO = value;
		}
		
	}
}
