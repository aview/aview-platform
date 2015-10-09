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
 * File			: ChatSessionMemberHelper.as
 * Module		: chat
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Bri.Radha,Vishnupreethi K
 * 
 * 
 */

/**
 * VPCR: Add file description */

package edu.amrita.aview.chat.helper
{
	import edu.amrita.aview.chat.vo.ChatSessionMemberVO;
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	/**
	 * VPCR: Add class description */
	
	public class ChatSessionMemberHelper extends AbstractHelper
	{
		/**
		 * Variable for remote object
		 */
		private var chatSessionMemberRO:RemoteObject=null;
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function ChatSessionMemberHelper()
		{
			chatSessionMemberRO=new RemoteObject();
			chatSessionMemberRO.destination="chatSessionMemberHelper";
			chatSessionMemberRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			chatSessionMemberRO.showBusyCursor=true;
			
			chatSessionMemberRO.createChatSessionMember.addEventListener("result", createChatSessionMemberResultHandler);
			chatSessionMemberRO.createChatSessionMember.addEventListener("fault", genericFaultHandler);
			
			chatSessionMemberRO.createChatSessionMembers.addEventListener("result", createChatSessionMembersResultHandler);
			chatSessionMemberRO.createChatSessionMembers.addEventListener("fault", genericFaultHandler);
			
			chatSessionMemberRO.updateChatSessionMember.addEventListener("result", updateChatSessionMemberResultHandler);
			chatSessionMemberRO.updateChatSessionMember.addEventListener("fault", genericFaultHandler);
			
			chatSessionMemberRO.deleteChatSessionMembers.addEventListener("result", deleteChatSessionMembersResultHandler);
			chatSessionMemberRO.deleteChatSessionMembers.addEventListener("fault", genericFaultHandler);
		
		}
		
		/**
		 * @public
		 * Function:createChatSessionMembers
		 * @param chatsessionmembers of type ArrayCollection
		 * @param creatorId of type int
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createChatSessionMembers(chatSessionMembers:ArrayCollection, creatorId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionMemberRO.createChatSessionMembers(chatSessionMembers, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @public
		 * Function:createChatSessionMember
		 * @param callerComp of type Object
		 * @param chatsessionmember of type ChatSessionMemberVO
		 * @param creatorId of type int
		 * 
		 */
		public function createChatSessionMember(chatSessionMember:ChatSessionMemberVO, creatorId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionMemberRO.createChatSessionMember(chatSessionMember, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * Function:updateChatSessionMember
		 * @param callerComp of type Object
		 * @param csm of type ChatSessionMemberVO
		 * 
		 */
		public function updateChatSessionMember(csm:ChatSessionMemberVO,updaterId:Number,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionMemberRO.updateChatSessionMember(csm,updaterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		
		/**
		 * @public
		 * Function:deleteChatSessionMembers
		 * @param chatsessionmembers of type ArrayCollection
		 * @param creatorId of type int
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteChatSessionMembers(chatSessionMembers:ArrayCollection, deleterId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatSessionMemberRO.deleteChatSessionMembers(chatSessionMembers, deleterId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @private
		 * Function:ResultHandler for createChatSessionMember
		 * @param event of type ResultEvent
		 * 
		 */
		private function createChatSessionMemberResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		/**
		 * @private
		 * Function:ResultHandler for createChatSessionMembers
		 * @param event of type ResultEvent
		 * 
		 */
		private function createChatSessionMembersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ArrayCollection);
		}
		
		/**
		 * @private
		 * Function:ResultHandler of updateChatSessionMember
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateChatSessionMemberResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ChatSessionMemberVO);
		}
		
		/**
		 * @private
		 * Function:ResultHandler of deleteChatSessionMembersByChatSession
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteChatSessionMembersResultHandler(event:ResultEvent):void
		{
			event.token.onResult();
		}
	}
}
