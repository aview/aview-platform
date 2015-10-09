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
 * File			: ChatSessionHelper.as
 * Module		: chat
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Vishnupreethi k
 * 
 * 
 */

/**
 * VPCR: Add file description */

package edu.amrita.aview.chat.helper
{
	import edu.amrita.aview.chat.vo.ChatSessionVO;
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	/**
	 * VPCR: ADD class description */
	
	public class ChatSessionHelper extends AbstractHelper
	{
		/**
		 * variable for remote object
		 */
		private var chatSessionRO:RemoteObject=null;
		
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function ChatSessionHelper()
		{
			chatSessionRO=new RemoteObject();
			chatSessionRO.destination="chatSessionHelper";
			chatSessionRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			chatSessionRO.showBusyCursor=true;
			
			chatSessionRO.createChatSession.addEventListener("result", createChatSessionResultHandler);
			chatSessionRO.createChatSession.addEventListener("fault", genericFaultHandler);
			
			chatSessionRO.getChatSessionById.addEventListener("result", getChatSessionByIdResultHandler);
			chatSessionRO.getChatSessionById.addEventListener("fault", genericFaultHandler);
			
			chatSessionRO.getChatSessionsByMemberId.addEventListener("result", getChatSessionsByMemberIdResultHandler);
			chatSessionRO.getChatSessionsByMemberId.addEventListener("fault", genericFaultHandler);
			
			
			chatSessionRO.deleteChatSessions.addEventListener("result", deleteChatSessionsResultHandler);
			chatSessionRO.deleteChatSessions.addEventListener("fault", genericFaultHandler);
			
			chatSessionRO.updateChatSession.addEventListener("result", updateChatSessionResultHandler);
			chatSessionRO.updateChatSession.addEventListener("fault", genericFaultHandler);
			
			chatSessionRO.getPrivateChatSession.addEventListener("result", getPrivateChatSessionResultHandler);
			chatSessionRO.getPrivateChatSession.addEventListener("fault", genericFaultHandler);
		
		}
		
		/**
		 * @public
		 * Function:createChatSession
		 * @param callerComp of type Object
		 * @param chatSession of type ChatSessionVO
		 * @param creatorId of type int
		 * 
		 */
		public function createChatSession(chatSession:ChatSessionVO, creatorId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionRO.createChatSession(chatSession, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		
		}
		/**
		 * @public
		 * Function:getChatSessionById
		 * @param callerComp of type Object
		 * @param chatSessionId of type Number
		 * @param memberId of type Number
		 * @param groupName of type String
		 * 
		 */
		public function getChatSessionById(chatSessionId:Number,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionRO.getChatSessionById(chatSessionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * Function:getChatSessionByMemberId
		 * @param callerComp of type Object
		 * @param memberId of type int
		 * 
		 */
		public function getChatSessionsByMemberId(memberId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionRO.getChatSessionsByMemberId(memberId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * Function:updateChatSession
		 * @param callerComp of type Object
		 * @param chatSession of type ChatSessionVO
		 * 
		 */
		public function updateChatSession(chatSession:ChatSessionVO,updaterId:Number,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionRO.updateChatSession(chatSession,updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * Function: deleteChatSessions
		 * @param callerComp of type Object
		 * @param csList of type ChatSessionVO
		 * 
		 */
		public function deleteChatSessions(csList:ArrayCollection,deleterId:Number,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionRO.deleteChatSessions(csList,deleterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * Function:getPrivateChatSession
		 * @param callerComp of type Object
		 * @param lectureId of type Number
		 * @param senderId of type Number
		 * @param receiverId of type Number
		 * 
		 */
		public function getPrivateChatSession(lectureId:Number, senderId:Number, receiverId:Number,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionRO.getPrivateChatSession(lectureId, senderId, receiverId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @private
		 * Function:ResultHandler of createChatSession
		 * @param event of type ResultEvent
		 * 
		 */
		private function createChatSessionResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ChatSessionVO);
		}
		
		/**
		 * @private
		 * Function:ResultHandler of getChatSessionById
		 * @param event of type ResultEvent
		 * 
		 */
		private function getChatSessionByIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ChatSessionVO);
		}
		
		/**
		 * @private
		 * Function:ResultHandler of getChatSessionByMemberId
		 * @param event of type ResultEvent
		 * 
		 */
		private function getChatSessionsByMemberIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ArrayCollection);
		}
		
		/**
		 * @private
		 * Function:ResultHandler of deleteChatSession
		 * 
		 */
		private function deleteChatSessionsResultHandler(event:ResultEvent):void
		{
			event.token.onResult();
		}
		
		/**
		 * @private
		 * Function:ResultHandler of updateChatSession
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateChatSessionResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ChatSessionVO);
		}
		
		/**
		 * @private
		 * Function:ResultHandler of getPrivateChatSession
		 * 
		 */
		private function getPrivateChatSessionResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ChatSessionVO);
		}
	
	}
}
