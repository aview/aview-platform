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
 * File			: ChatController.as
 * Module		: Chat
 * Developer(s)	: Radha
 * Reviewer(s)	:  
 * 
 * ChatController manages ChatView and ChatModel.
 * 
 */
package edu.amrita.aview.chat
{
	import com.adobe.utils.StringUtil;
	import com.amrita.edu.collaboration.AutoPropertyName;
	import com.amrita.edu.collaboration.CollaborationFactory;
	import com.amrita.edu.collaboration.CollaborationObject;
	import com.amrita.edu.collaboration.CollaborationService;
	
	import edu.amrita.aview.chat.helper.ChatMessageHelper;
	import edu.amrita.aview.chat.helper.ChatSessionHelper;
	import edu.amrita.aview.chat.helper.ChatSessionMemberHelper;
	import edu.amrita.aview.chat.vo.ChatMessageVO;
	import edu.amrita.aview.chat.vo.ChatSessionMemberVO;
	import edu.amrita.aview.chat.vo.ChatSessionVO;
	import edu.amrita.aview.core.shared.events.ChatEvent;
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
	import edu.amrita.aview.common.vo.Auditable;
    import edu.amrita.aview.core.shared.vo.StatusVO;
	import edu.amrita.aview.contacts.events.ContactsEvent;
	import edu.amrita.aview.contacts.events.UserStatusRequesterEvent;
	import edu.amrita.aview.contacts.vo.GroupUserVO;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import flash.display.DisplayObject;

	public class ChatController extends EventDispatcher
	{ 
		private var chatCollaborationObject:CollaborationObject = null;
		applicationType::DesktopWeb{
			private var chatView:ChatView = null;
		}
		applicationType::mobile{
			private var chatView:PrivateChat = null;
		}
		private var _chatModel:ChatModel = null;
		
		private var isPopup:Boolean = false;
		private var allowAddingUsers:Boolean = false;
		applicationType::DesktopWeb{
			private var chatWindow:ChatTitleWindow = null;
		}
		applicationType::mobile{
			private var chatWindow:ChatSkinnablePopupContainer = null;
		}
		private var _chatSessionVO:ChatSessionVO = null;
		
		private var posX:Number = 0;
		
		private var posY:Number = 0;
		
		/**
		 * Logger for file and console logging
		 */
		private var chatLog:ILogger=Log.getLogger("edu.amrita.aview.chat.ChatController");
		
		private var contactModuleRO:ModuleRO = null;
		
		private var selectedMembersForDeletion:ArrayCollection = null;

				
		public function ChatController(moduleRO:ModuleRO,chatSessionVO:ChatSessionVO, posX:Number, posY:Number
									   ,isPopup:Boolean=true, allowAddingUsers:Boolean=true):void
		{
			this.contactModuleRO = moduleRO;
			this._chatSessionVO = chatSessionVO;

			this.posX = posX;
			this.posY = posY;
			
			this.isPopup = isPopup;
			this.allowAddingUsers = allowAddingUsers;
		}
		
		public function initialize():void
		{
			chatSessionVO.prepareChatHistory();
			
			var chatSessionId:Number = chatSessionVO.chatSessionId;

			contactModuleRO.mediaServerConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, connectionStatusHandler);
			contactModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE, onAppCloseEvent);
			contactModuleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, onLogoutEvent);
			contactModuleRO.applicationEventMap.registerInitiator(this, UserStatusRequesterEvent.UPDATE_USER_STATUS);
			contactModuleRO.applicationEventMap.registerMapListener(ContactsEvent.USER_STATUS_CHANGED, updateChatMembersStatus)

			contactModuleRO.moduleEventMap.registerInitiator(this, ChatEvent.RESTORE);
			contactModuleRO.moduleEventMap.registerInitiator(this, ChatEvent.RESTORED,chatSessionId+"");
			contactModuleRO.moduleEventMap.registerInitiator(this, ChatEvent.TERMINATE_CHAT);

			contactModuleRO.moduleEventMap.registerMapListener(ChatEvent.RESTORE, onRestoreEvent);
			contactModuleRO.moduleEventMap.registerMapListener(ChatEvent.EXIT_CHAT, onExitChatEvent, chatSessionId+"");
			contactModuleRO.moduleEventMap.registerMapListener(ChatEvent.ADD_CHAT_MEMBERS, onAddChatMembersEvent, chatSessionId+"");
			contactModuleRO.moduleEventMap.registerMapListener(ChatEvent.DELETE_CHAT_MEMBERS, onDeleteChatMembersEvent, chatSessionId+"");
			contactModuleRO.moduleEventMap.registerMapListener(ChatEvent.SEND_CHAT_MESSAGE, onSendChatMessageEvent, chatSessionId+"");
			contactModuleRO.moduleEventMap.registerMapListener(ChatEvent.CLEAR_CHAT_AREA, onClearChatAreaEvent, chatSessionId+"");
			
			connectChatCollaborationObject();

			startChatSession();
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param event of type MediaServerStatusEvent
		 * @return void 
		 */
		private function connectionStatusHandler(event:MediaServerStatusEvent):void
		{
			switch(event.code)
			{
				case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
					onConnectionSuccess();
					break;
			}
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @return void 
		 */
		private function onConnectionSuccess():void
		{
			populateUserStatus();
		}
		
		private function populateUserStatus():void
		{
			var users:ArrayCollection = chatSessionVO.getUsers();
			users.addItem(chatSessionVO.owner);
			this.dispatchEvent(new UserStatusRequesterEvent(UserStatusRequesterEvent.UPDATE_USER_STATUS,users));
		}
		
		private function startChatSession():void
		{
			populateUserStatus();
			_chatModel = new ChatModel(chatSessionVO,contactModuleRO.userVO);
			
			if(!chatModel.isModerator)
			{
				if(chatSessionVO.currentChatSessionMemberVO.statusId != StatusVO.JOINED_STATUS)
				{
					chatSessionVO.currentChatSessionMemberVO.statusId = StatusVO.JOINED_STATUS;
					(new ChatSessionMemberHelper()).updateChatSessionMember(chatSessionVO.currentChatSessionMemberVO,contactModuleRO.userVO.userId,updateChatSessionMemberResultHandler);
				}
			}
			
			//RGCR: What happens if the isPopup is false?
			if (isPopup)
			{
				applicationType::DesktopWeb{
					chatView = new ChatView;
				}
				applicationType::mobile{
					chatView = new PrivateChat;
				}
				chatView.initChatView(chatModel,contactModuleRO);
				applicationType::DesktopWeb{
					chatWindow = new ChatTitleWindow;
				}
				applicationType::mobile{
					chatWindow = new ChatSkinnablePopupContainer();
				}
				chatWindow.init(contactModuleRO);
				applicationType::DesktopWeb{
					chatWindow.setPosition(posX, posY);
				}
				openChatWindow();
			}
		}
		
		private function connectChatCollaborationObject():void
		{
			chatCollaborationObject = contactModuleRO.collaborationService.connectCollaborationObject(chatSessionVO.chatSessionId + "_chat", AutoPropertyName.NUMERIC);
			
			chatCollaborationObject.setOnChange(updateChatMessages);
			chatCollaborationObject.setOnClear(clearChatMessages);
			chatCollaborationObject.setOnSend("addChatSessionMembers", onAddChatSessionMembersCall);
			chatCollaborationObject.setOnSend("deleteChatSessionMembers", onDeleteChatSessionMembersCall);
			chatCollaborationObject.setOnSend("deleteChatSessionMember", onChatUserDeleteHandlerCall);
		}
		
		private function closeChatCollaborationObjects():void
		{
			contactModuleRO.collaborationService.closeCollaborationObject(chatSessionVO.chatSessionId + "_chat");
		}
		
		private function updateChatMembersStatus(event:ContactsEvent):void
		{
			chatModel.updateChatMembersStatus(event.data.userStatus, event.data.name);
			chatWindow.changeStatus();
			if(chatModel.chatSessionVO.isPrivateChat == "Y" 
				&& event.data.userStatus == Constants.OFFLINE
				&& event.data.name != contactModuleRO.userVO.userName
				&& isChatSessionMemberName(event.data.name)
				)
			{
				applicationType::mobile{
					if(chatView.isPrivateChatKeyBoardIsOpen){
						chatView.isPrivateChatKeyBoardIsOpen = false;
						FlexGlobals.topLevelApplication.stage.focus = null;
						setTimeout(displayAlert,10,"The chat member has logged out. Do you want to close the chat window?");
					}else{
						MessageBox.show("The chat member has logged out. Do you want to close the chat window?", "Information", MessageBox.MB_YESNO, chatWindow, 
							function(event:Event=null){onExitChatEvent()}
						);
					}
				}
				applicationType::DesktopWeb{
					MessageBox.show("The chat member has logged out. Do you want to close the chat window?", "Information", MessageBox.MB_YESNO, chatWindow, 
						function(event:Event=null){onExitChatEvent()}
					);
				}
			}
		}
		applicationType::mobile{
			private function displayAlert(info:String):void{
				var msgBox:MessageBox = MessageBox.show(info, "Information", MessageBox.MB_YESNO, FlexGlobals.topLevelApplication as DisplayObject, 
					function(event:Event=null){onExitChatEvent()}
				);
				msgBox.y = (FlexGlobals.topLevelApplication.height - msgBox.height)/2;
			}
		}
		private function isChatSessionMemberName(userName:String):Boolean
		{
			var members:ArrayCollection=chatModel.chatSessionVO.members;
			
			for(var index:int=0;index<members.length;index++)
			{
				if(members.getItemAt(index).member.userName==userName)
				{
					return true;
				}
			}
			return false;
		}
		private function onAddChatSessionMembersCall(members:ArrayCollection):void
		{
			//Moderator would have already added the members to the local chatModel/chatSession already
			if(!chatModel.isModerator)
			{
				chatModel.addChatMembers(members);
			}
		}
		
		private function onDeleteChatSessionMembersCall(members:ArrayCollection):void
		{
			//Moderator would have already deleted the members from the local chatModel/chatSession already
			if(!chatModel.isModerator)
			{
				chatModel.removeChatMembers(members);
			}
		}
		
		private function onChatUserDeleteHandlerCall(userName:String):void
		{
			chatModel.removeChatMember(userName);
			if(chatModel.chatSessionVO.isPrivateChat == "Y" 
				&& userName != contactModuleRO.userVO.userName
			)
			{
				applicationType::mobile{
					if(chatView.isPrivateChatKeyBoardIsOpen){
						chatView.isPrivateChatKeyBoardIsOpen = false;
						FlexGlobals.topLevelApplication.stage.focus = null;
						setTimeout(displayAlert,10,"The chat member has quit from chat. Do you want to close the chat window?");
					}else{
						MessageBox.show("The chat member has quit from chat. Do you want to close the chat window?", "Information", MessageBox.MB_YESNO, FlexGlobals.topLevelApplication as DisplayObject, 
							function(event:Event=null){onExitChatEvent()}
						);
					}
				}
				applicationType::DesktopWeb{
					MessageBox.show("The chat member has quit from chat. Do you want to close the chat window?", "Information", MessageBox.MB_YESNO, FlexGlobals.topLevelApplication as DisplayObject, 
						function(event:Event=null){onExitChatEvent()}
					);
				}
			}
		}
		
		public function restoreChatWindow():void
		{
			applicationType::DesktopWeb{
				if (chatWindow.minimized)
				{
					//open the chat window
					openChatWindow();
				}
			}
		}
		
		private function updateChatMessages(data:Object, name:String):void
		{
			restoreChatWindow();
			if (chatCollaborationObject.syncEventCount != 1)
			{
				var message:ChatMessageVO = new ChatMessageVO();
				message.populateFromObject(data.propertyValue);
				chatSessionVO.addMessage(message);
			}
		}
		
		private function clearChatMessages():void
		{
			if (chatCollaborationObject.syncEventCount != 1)
			{
				chatSessionVO.clearChatHistoryByModerator();
			}
		}
		
		private function openChatWindow():void
		{
			applicationType::DesktopWeb{
				chatWindow.minimized = false;
				chatWindow.x = chatWindow.posX;
				chatWindow.y = chatWindow.posY;
			}
			PopUpManager.addPopUp(chatWindow, FlexGlobals.topLevelApplication.document);
			chatWindow.addChatView(chatView);
		}
		
		private function onSendChatMessageEvent(event:ChatEvent):void
		{
			var chatMessage:String = StringUtil.trim(event.data as String);

			var chatMessageVO:ChatMessageVO = chatSessionVO.getMessageObject(chatMessage,contactModuleRO.userVO.userId);
			
			//Send it all the participants
			chatCollaborationObject.addValue(chatMessageVO.getMessageObject());
			
			(new ChatMessageHelper()).createChatMessage(chatMessageVO,contactModuleRO.userVO.userId,createChatMessageResultHandler);
			
		}
		
		/**
		 * @public
		 * Result handler for createChatMessage
		 * @param event
		 * @return void
		 */
		public function createChatMessageResultHandler(chatMessage:ChatMessageVO):void
		{
			if (Log.isInfo()) chatLog.info("Chat Message '{0}' is created in db with id '{0}'", chatMessage.chatMessageText,chatMessage.chatMessageId);
		}
		
		private function onClearChatAreaEvent(event:ChatEvent):void
		{
			chatCollaborationObject.removeAllValues();
		}
		
		public function onExitChatEvent(event:ChatEvent = null):void
		{
			if(chatModel.chatSessionVO.isPrivateChat == "N" && chatModel.isModerator)
			{
				contactModuleRO.mediaServerConnection.netConnection.call("endChatSession", null, chatSessionVO.getServerObject());
				chatSessionVO.statusId = StatusVO.CLOSED_STATUS;
				(new ChatSessionHelper()).updateChatSession(chatSessionVO,contactModuleRO.userVO.userId,updateChatSessionResultHandler);
			}
			else
			{
				contactModuleRO.mediaServerConnection.netConnection.call("quitChatSession", null, chatSessionVO.getServerObject(),
					chatSessionVO.owner.userName, contactModuleRO.userVO.userName);
				if(!chatModel.isModerator)
				{
					chatSessionVO.currentChatSessionMemberVO.statusId = StatusVO.EXITED_STATUS;
					(new ChatSessionMemberHelper()).updateChatSessionMember(chatSessionVO.currentChatSessionMemberVO,contactModuleRO.userVO.userId,
					updateChatSessionMemberResultHandler);
				}
				chatCollaborationObject.send("deleteChatSessionMember", contactModuleRO.userVO.userName);

			}
			
			terminateChat(chatSessionVO);
			closeChatSession();
		}
		
		private function terminateChat(chatSessionVO:ChatSessionVO):void
		{
			this.dispatchEvent(new ChatEvent(ChatEvent.TERMINATE_CHAT, chatSessionVO.chatSessionId));
		}
		
		public function createChatMembersResultHandler(newMembers:ArrayCollection):void
		{
			chatModel.addChatMembers(newMembers);
			
			//Update the status of new users..
			var users:ArrayCollection = new ArrayCollection();
			for each(var member:ChatSessionMemberVO in newMembers)
			{
				users.addItem(member.member);
			}
			this.dispatchEvent(new UserStatusRequesterEvent(UserStatusRequesterEvent.UPDATE_USER_STATUS,users));
			
			
			var newMembersServerArray:Array = Auditable.getServerObjects(newMembers); 
			
			//update on fms server
			contactModuleRO.mediaServerConnection.netConnection.call("addChatMembers", null, chatSessionVO.getServerObject(), newMembersServerArray);
			//update every member
			chatCollaborationObject.send("addChatSessionMembers", newMembers);
		}
		
		public function deleteChatMembersResultHandler():void
		{
			
			chatModel.removeChatMembers(selectedMembersForDeletion);
			
			//update on fms server
			var deletedMembersServerArray:Array = Auditable.getServerObjects(selectedMembersForDeletion); 
			contactModuleRO.mediaServerConnection.netConnection.call("deleteChatMembers", null, chatSessionVO.getServerObject(), deletedMembersServerArray);
			//update every user 

			chatCollaborationObject.send("deleteChatSessionMembers", selectedMembersForDeletion);
			
			selectedMembersForDeletion.removeAll();
		}
		
		/**
		 * @public
		 * Result handler for updateChatSession
		 * @param event
		 * @return void
		 */
		public function updateChatSessionResultHandler(cs:ChatSessionVO):void
		{
			if (Log.isInfo()) chatLog.info("Chat session with session Id {0} is successfully updated", cs.chatSessionId);
		}
		
		/**
		 * @public
		 * Result handler for updateChatSessionMember
		 * @param event
		 * @return void
		 */
		public function updateChatSessionMemberResultHandler(csm:ChatSessionMemberVO):void
		{
			if (Log.isInfo()) chatLog.info("Chat session member with member Id {0} is successfully updated", csm.chatSessionMemberId);
		}
		
		private function removePopUp():void
		{
			if (chatWindow.isPopUp)
			{
				PopUpManager.removePopUp(chatWindow);
			}
		}
		
		public function endChatSession(msg:String):void
		{
			if (chatWindow.minimized)
			{
				if (chatWindow.minimized)
				{
					this.dispatchEvent(new ChatEvent(ChatEvent.RESTORE, chatWindow));
				}
			}
			MessageBox.show(msg, "Information", MessageBox.MB_OK, chatWindow, closeChatSession);
		}
		
		private function onRestoreEvent(event:ChatEvent):void
		{
			applicationType::DesktopWeb{
				var win:ChatTitleWindow = event.data as ChatTitleWindow;
				if (chatWindow == win)
				{
					openChatWindow();
				}
			}
		}
		
		private function onAddChatMembersEvent(event:ChatEvent):void
		{
			var newUsers:ArrayCollection = event.data as ArrayCollection;
			
			var newMembers:ArrayCollection = new ArrayCollection();
			for each(var newUser:UserVO in newUsers)
			{
				var newMember:ChatSessionMemberVO = new ChatSessionMemberVO();
				newMember.chatSessionId = chatSessionVO.chatSessionId;
				newMember.member = newUser;
				newMembers.addItem(newMember);
			}
			(new ChatSessionMemberHelper()).createChatSessionMembers(newMembers,contactModuleRO.userVO.userId,createChatMembersResultHandler);
		}
		
		private function onDeleteChatMembersEvent(event:ChatEvent):void
		{
			selectedMembersForDeletion = event.data as ArrayCollection;
			(new ChatSessionMemberHelper()).deleteChatSessionMembers(selectedMembersForDeletion,contactModuleRO.userVO.userId,deleteChatMembersResultHandler);
		}
		
		public function closeChatSession(event:Event=null):void
		{
			if (chatWindow.isPopUp)
			{
				removePopUp();
			}
			if (chatWindow.minimized)
			{
				this.dispatchEvent(new ChatEvent(ChatEvent.RESTORED, chatWindow));
			}
			
			closeChatCollaborationObjects();
			clearEventMap();
		}
		
		private function clearEventMap():void
		{
			//unregister listeners
			contactModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.RESTORE, onRestoreEvent);
			contactModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.SEND_CHAT_MESSAGE, onSendChatMessageEvent, chatSessionVO.chatSessionId+"");
			contactModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.EXIT_CHAT, onExitChatEvent, chatSessionVO.chatSessionId+"");
			contactModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.ADD_CHAT_MEMBERS, onAddChatMembersEvent, chatSessionVO.chatSessionId+"");
			contactModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.DELETE_CHAT_MEMBERS, onDeleteChatMembersEvent, chatSessionVO.chatSessionId+"");
			contactModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.CLEAR_CHAT_AREA, onClearChatAreaEvent, chatSessionVO.chatSessionId+"");

			contactModuleRO.applicationEventMap.unregisterMapListener(ContactsEvent.USER_STATUS_CHANGED, updateChatMembersStatus);
			contactModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, onLogoutEvent);
			contactModuleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE, onAppCloseEvent);
			
			//unregister initiators
			contactModuleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.RESTORE);
			contactModuleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.RESTORED);
			contactModuleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.TERMINATE_CHAT);
			contactModuleRO.applicationEventMap.unregisterInitiator(this, UserStatusRequesterEvent.UPDATE_USER_STATUS);
			
			chatView.clearEventMap();
		}
		
		private function onLogoutEvent(event:ApplicationStatusEvent):void
		{
			closeChatSession();
		}
		
		private function onAppCloseEvent(event:ApplicationStatusEvent):void
		{
			closeChatSession();
		}

		public function get chatSessionVO():ChatSessionVO
		{
			return _chatSessionVO;
		}

		public function get chatModel():ChatModel
		{
			return _chatModel;
		}


	}
}