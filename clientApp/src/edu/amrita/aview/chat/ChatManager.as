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
 * File			: ChatManager.as
 * Module		: Chat
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Vishnupreethi K 
 * 
 * The default skin to create new chat session.
 * This is the action script file for Chat component.
 * 
 */
package edu.amrita.aview.chat
{
	import edu.amrita.aview.chat.helper.ChatSessionHelper;
	import edu.amrita.aview.chat.vo.ChatSessionMemberVO;
	import edu.amrita.aview.chat.vo.ChatSessionVO;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.core.shared.events.ChatEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.effects.Move;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	/**
	 * VPCR: Add class description */
	

	public class ChatManager extends EventDispatcher
	{
		private var moduleRO:ModuleRO = null;
		
		private const DEFAULT_POS_X:Number = 710;
		private const DEFAULT_POS_Y:Number = 400;
		private const DELTA_X:Number = 50;
		private const DELTA_Y:Number = 50;
		
		private var nextPosX:Number = DEFAULT_POS_X;
		private var nextPosY:Number = DEFAULT_POS_Y;
		
		private var chatContollers:Object = null;
		applicationType::DesktopWeb{
			private var minimizedChatWindowContainer:MinimizedChatWindowContainer = null;
		}

		private var heightWatch:ChangeWatcher;
		/**
		 * @public 
		 * @param userVO
		 * @param mediaServerConnection
		 * 
		 */
		public function ChatManager(moduleRO:ModuleRO)
		{
			this.moduleRO = moduleRO;
		}
		
		
		/**
		 * @public 
		 * 
		 */
		public function initialize():void
		{
			moduleRO.mediaServerConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, connectionStatusHandler);
			moduleRO.mediaServerConnection.addClientMethod("startChatSession", onStartChatSessionCallback);
			moduleRO.mediaServerConnection.addClientMethod("endChatSession", onEndChatSessionCallback);
			moduleRO.mediaServerConnection.addClientMethod("removedByModerator", onRemovedByModeratorCallback);
			moduleRO.mediaServerConnection.addClientMethod("activeChatSessions", onActiveChatSessionsCallback);
			moduleRO.moduleEventMap.registerMapListener(ChatEvent.EXIT_ALL_CHATS, onExitAllChatSessionsEvent);
			applicationType::DesktopWeb{
				
				createMinimizedChatWindowContainer();
			}
		}
		
		public function registerChatEvents():void
		{
			moduleRO.moduleEventMap.registerMapListener(ChatEvent.INITIATE_GROUP_CHAT, onInitiateGroupChatEvent);
			moduleRO.moduleEventMap.registerMapListener(ChatEvent.INITIATE_PRIVATE_CHAT, onInitiatePrivateChatEvent);
			moduleRO.moduleEventMap.registerMapListener(ChatEvent.TERMINATE_CHAT, onTerminateChatEvent);
			moduleRO.applicationEventMap.registerMapListener(ChatEvent.CONTINUE_CHAT, continueChatSession);
			applicationType::DesktopWeb{
				moduleRO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, onLogoutEvent);
			}
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
		 * On successful reconnection, all the on going chant sessions, which are initiated by this users are updated onto the server.
		 * @return void 
		 */
		private function onConnectionSuccess():void
		{
			if(chatContollers)
			{
				for (var chatSessionId:String in chatContollers)
				{
					var chatContoller:ChatController = chatContollers[chatSessionId] as ChatController;
					if(chatContoller && chatContoller.chatModel.isModerator)
					{
						moduleRO.mediaServerConnection.netConnection.call("populateChatSessionAfterReconnection", 
							null, chatContoller.chatSessionVO.getServerObject());
					}
				}
			}
		}
		
		private function onInitiateGroupChatEvent(event:ChatEvent):void
		{
			onInitiateChatEvent(event,"N");
		}
		
		private function onInitiatePrivateChatEvent(event:ChatEvent):void
		{
			onInitiateChatEvent(event,"Y");
		}
		
		private function setChatTitle(chatSession:ChatSessionVO,groupName:String,lectureVO:LectureVO):void
		{
			
			if(chatSession.lectureId == 0)
			{
				//For Private chat  -> <member name>+"_"+ private chat"
				if(chatSession.isPrivateChat == "Y")
				{
					var member:ChatSessionMemberVO = chatSession.members.getItemAt(0) as ChatSessionMemberVO;
					chatSession.title = member.member.userDisplayName+"_"+" Private chat";
				}
				else
				{
					//For Group chat by group -> <moderator name>+"_"+<group name>+" group chat"
					if(groupName != null)
					{
						chatSession.title = moduleRO.userVO.userDisplayName+"_"+groupName+" Group chat";
					}
					//For Group chat by members -> <moderator name>+"_"+"... group chat"
					else
					{
						var member:ChatSessionMemberVO = chatSession.members.getItemAt(0) as ChatSessionMemberVO;
						chatSession.title = moduleRO.userVO.userDisplayName+"_"+"... Group chat";
						
					}
				}
			}
			else
			{
				//For Session room chat  -> <lecture name>+" session chat"
				if(chatSession.isPrivateChat == "Y")
				{
					chatSession.title = lectureVO.displayName+" Session chat";
				}
				//For Session Private chat  -> <lecture name>+"_"<moderator name>+"_"+<member name>+" private chat"
				else
				{
					var member:ChatSessionMemberVO = chatSession.members.getItemAt(0) as ChatSessionMemberVO;
					chatSession.title = lectureVO.displayName+"_"+moduleRO.userVO.userDisplayName+"_"+member.member.userDisplayName+" Private chat";
				}
			}
		}
		
		/**
		 * @private 
		 * @param event of type ChatEvent
		 * 
		 */
		private function onInitiateChatEvent(event:ChatEvent,isPrivateChat:String):void
		{
			
			var chatSession:ChatSessionVO = new ChatSessionVO;
			chatSession.owner = moduleRO.userVO;
			chatSession.isPrivateChat = isPrivateChat;
			chatSession.lectureId = (moduleRO.lectureVO)?moduleRO.lectureVO.lectureId:0;
			
			if(isPrivateChat == "Y")
			{
				chatSession.addUser(event.data as UserVO);
			}
			else
			{
				var chatMembers:ArrayCollection = event.data as ArrayCollection;
				for each (var user:UserVO in chatMembers)
				{
					chatSession.addUser(user);
				}
			}
			
			setChatTitle(chatSession,event.groupName,moduleRO.lectureVO);
			
			var sessionHelper:ChatSessionHelper = new ChatSessionHelper();
			sessionHelper.createChatSession(chatSession,moduleRO.userVO.userId,createChatSessionResultHandler);
		}
		
		/**
		 * @public
		 * Result handler function for createChatSession.
		 *
		 * @param event of type ResultEvent
		 *
		 */
		public function createChatSessionResultHandler(chatSession:ChatSessionVO):void
		{
			preStartChatSession(chatSession);
		}
		
		private function continueChatSession(event:ChatEvent):void
		{
			var chatSession:ChatSessionVO = event.data as ChatSessionVO;
			preStartChatSession(chatSession);
		}
		
		private function preStartChatSession(chatSession:ChatSessionVO):void
		{
			var inviteOwner:Boolean = false;
			//In private chat, we re-use the earlier private chat session (among these two users) to accumulate the history of messages 
			//and show all the chat history across various sessions together
			//If the current user, who is starting this private chat session is not the owner of the private chat, then
			//the invitation has to be sent to the earlier owner for the chat, not the member in the usual cse.
			if(chatSession.isPrivateChat == "Y" && chatSession.owner.userId != moduleRO.userVO.userId)
			{
				inviteOwner = true;
			}
			
			moduleRO.mediaServerConnection.netConnection.call("initiateChatSession", null, chatSession.getServerObject(),inviteOwner);
			startChatSession(chatSession);
		}

		/**
		 * @private 
		 * @param chatSession
		 * 
		 */
		private function onStartChatSessionCallback(chatSession:Object):void
		{
			(new ChatSessionHelper()).getChatSessionById(chatSession.chatSessionId,startChatSession);			
		}
		
		
		/**
		 * @private 
		 * @param chatSessionDetails
		 * 
		 */
		private function startChatSession(chatSession:ChatSessionVO):void
		{
			if (!chatContollers)
			{
				chatContollers = new Object;
			}
			
			var chatController:ChatController = chatContollers[chatSession.chatSessionId];
			
			if(chatController)
			{
				chatController.restoreChatWindow();
			}
			else
			{
				chatController = new ChatController(moduleRO,chatSession, nextPosX, nextPosY);
				chatContollers[chatSession.chatSessionId] = chatController;
				chatController.initialize();
			}
			
			//set the position for next chat window
			nextPosX -= DELTA_X;
			nextPosY -= DELTA_Y;
		}
		
		
		/**
		 * @private 
		 * 
		 */
		private function createMinimizedChatWindowContainer():void
		{
			applicationType::DesktopWeb{
				heightWatch = ChangeWatcher.watch(FlexGlobals.topLevelApplication,'height',resizeHandler);
				minimizedChatWindowContainer = new MinimizedChatWindowContainer;
				applicationType::desktop {
					var systemManager:ISystemManager =  FlexGlobals.topLevelApplication.systemManager;
					minimizedChatWindowContainer.width = FlexGlobals.topLevelApplication.stage.stageWidth;
					minimizedChatWindowContainer.x = 0;
					minimizedChatWindowContainer.y = FlexGlobals.topLevelApplication.stage.stageHeight - 50;
					minimizedChatWindowContainer.eventMap = moduleRO.moduleEventMap;// as edu.amrita.aview.core.shared.eventmap.EventMap;
					//minimizedChatWindowContainer.left = 20;
					//minimizedChatWindowContainer.bottom = 20;
					PopUpManager.addPopUp(minimizedChatWindowContainer, FlexGlobals.topLevelApplication.document);
				}
				applicationType::web {
					//For Guest Login: To avoid null reference issue when the user is a guest.
					//For guest users, stage may not be initialized at this moment
					if(FlexGlobals.topLevelApplication.stage){
						var systemManager:ISystemManager =  FlexGlobals.topLevelApplication.systemManager;
						minimizedChatWindowContainer.width = FlexGlobals.topLevelApplication.stage.stageWidth;
						minimizedChatWindowContainer.x = 0;
						minimizedChatWindowContainer.y = FlexGlobals.topLevelApplication.stage.stageHeight - 50;
						minimizedChatWindowContainer.eventMap = moduleRO.moduleEventMap;// as edu.amrita.aview.core.shared.eventmap.EventMap;
						PopUpManager.addPopUp(minimizedChatWindowContainer, FlexGlobals.topLevelApplication.document);
					}
				}
			}
		}
		
		private function resizeHandler(event:Event):void
		{
			applicationType::desktop{
				if(minimizedChatWindowContainer!=null)
				{
					minimizedChatWindowContainer.move(0,FlexGlobals.topLevelApplication.stage.stageHeight-50);
					minimizedChatWindowContainer.width =FlexGlobals.topLevelApplication.stage.stageWidth; 
				}
			}
			applicationType::web {
				//For Guest Login: To avoid null reference issue when the user is a guest.
				//For guest users, stage may not be initialized at this moment
				if(FlexGlobals.topLevelApplication.stage){
					if(minimizedChatWindowContainer!=null)
					{
						minimizedChatWindowContainer.move(0,FlexGlobals.topLevelApplication.stage.stageHeight-50);
						minimizedChatWindowContainer.width =FlexGlobals.topLevelApplication.stage.stageWidth; 
					}	
				}
			}
			
		}
		
		
		/**
		 * @private 
		 * 
		 */
		private function removeMinimizedChatWindowContainer():void
		{
			applicationType::DesktopWeb{
				PopUpManager.removePopUp(minimizedChatWindowContainer);
				minimizedChatWindowContainer = null;
			}
		}

		/**
		 * @private 
		 * @param event of type ChatEvent
		 * 
		 */
		private function onTerminateChatEvent(event:ChatEvent):void
		{
			var chatSessionId:String = (event.data as Number)+"";
			deleteChatController(chatSessionId);
		}
		
		/**
		 * @private 
		 * @param chatSessionId
		 *
		 */
		private function onEndChatSessionCallback(chatSessionId:String):void
		{
			var chatContoller:ChatController = chatContollers[chatSessionId];
			chatContoller.endChatSession("Moderator ended the chat session.");
			removeChatSession(chatSessionId);
		}
		
		/**
		 * @private 
		 * @param chatSessionId
		 *
		 */
		private function onRemovedByModeratorCallback(chatSessionId:String):void
		{
			var chatContoller:ChatController = chatContollers[chatSessionId];
			chatContoller.endChatSession("Moderator removed you from chat session.");
			removeChatSession(chatSessionId);
		}
		
		/**
		 * @private 
		 * @param chatSessionId
		 * 
		 */
		private function removeChatSession(chatSessionId:String):void
		{
			var chatController:ChatController = chatContollers[chatSessionId] as ChatController;
			if(chatController)
			{
				chatController.closeChatSession();
				deleteChatController(chatSessionId);
			}
		}
		
		/**
		 * @private 
		 * @param chatSessionId
		 * 
		 */
		private function exitChatSession(chatSessionId:String):void
		{
			var chatController:ChatController = chatContollers[chatSessionId] as ChatController;
			if(chatController)
			{
				chatController.onExitChatEvent();
			}
		}
		
		
		private function deleteChatController(chatSessionId:String):void
		{
			delete chatContollers[chatSessionId];
		}
		
		/**
		 * @private 
		 * @param activeChatSessions
		 * 
		 */
		private function onActiveChatSessionsCallback(activeChatSessions:Object):void
		{
			for each (var chatSessionDetails:Object in activeChatSessions)
			{
				onStartChatSessionCallback(chatSessionDetails);
			}
		}
		
		//logout handler
		private function onLogoutEvent(event:ApplicationStatusEvent):void
		{
			onExitAllChatSessionsEvent();
		}
		
		/**
		 * @private 
		 * 
		 */
		public var prsterControlFlag:Boolean = false;
		private function onExitAllChatSessionsEvent(event:ChatEvent = null):void
		{
			if(event !=null)
			{
				prsterControlFlag = true;
			}
			for (var chatSessionId:String in chatContollers)
			{
				exitChatSession(chatSessionId);
			}
			cleanUp();
		}
		
		public function cleanUp():void
		{
			
			if(chatContollers)
			{
				for (var chatSessionId:String in chatContollers)
				{
					var chatContoller:ChatController = chatContollers[chatSessionId] as ChatController;
					if(chatContoller)
					{
						chatContoller.closeChatSession();
					}
				}
			}
			chatContollers = null;
			if( prsterControlFlag != true)
			{
				// fix Bug #17114
				removeMinimizedChatWindowContainer();
				clearEventMap();
			}			
		}
		
		/**
		 * @private 
		 * 
		 */
		private function clearEventMap():void
		{
			moduleRO.moduleEventMap.unregisterMapListener(ChatEvent.INITIATE_GROUP_CHAT, onInitiateGroupChatEvent);
			moduleRO.moduleEventMap.unregisterMapListener(ChatEvent.INITIATE_PRIVATE_CHAT, onInitiatePrivateChatEvent);
			moduleRO.moduleEventMap.unregisterMapListener(ChatEvent.TERMINATE_CHAT, onTerminateChatEvent);
			moduleRO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, onLogoutEvent);
			moduleRO.applicationEventMap.unregisterMapListener(ChatEvent.CONTINUE_CHAT, continueChatSession);
		}
	}
}