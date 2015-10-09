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
 * File			: ChatMessageHelper.as
 * Module		: chat
 * Developer(s)	: Soumya M.D, NidhiSarasan
 * Reviewer(s)	: Vishnupreethi K
 *
 *
 */
/**
 * VPCR: Add file description */

package edu.amrita.aview.chat.helper
{
	import edu.amrita.aview.chat.vo.ChatMessageVO;
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	
	/**
	 * VPCR: Add class description */
	
	public class ChatMessageHelper extends AbstractHelper
	{
        /**
		 * Variable for remote object
		 */
		private var chatMessageRO:RemoteObject=null;
		/**
		 * @public
		 * Default constructor
		 *
		 *
		 */
		public function ChatMessageHelper()
		{
			chatMessageRO=new RemoteObject();
			chatMessageRO.destination="chatMessageHelper";
			chatMessageRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			chatMessageRO.showBusyCursor=true;
			
			chatMessageRO.createChatMessage.addEventListener("result", createChatMessageResultHandler);
			chatMessageRO.createChatMessage.addEventListener("fault", genericFaultHandler);
			
			chatMessageRO.getChatMessageBySessionId.addEventListener("result", getChatMessageBySessionIdResultHandler);
			chatMessageRO.getChatMessageBySessionId.addEventListener("fault", genericFaultHandler);
		
		
		}
		/**
		 * @public
		 * Function to create chat message
		 * @param callerComp of type Object
		 * @param chatmsg of type ChatMessageVO
		 * @param creatorId of type int
		 *
		 */
		public function createChatMessage(chatmsg:ChatMessageVO, creatorId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatMessageRO.createChatMessage(chatmsg, creatorId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * Function to get chat message by session id
		 * @param callerComp of type Object
		 * @param sessionId of type int
		 *
		 */
		public function getChatMessageBySessionId(sessionId:int,onResult:Function,onFault:Function=null):void
		{
			var token:AsyncToken=chatMessageRO.getChatMessageBySessionId(sessionId);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @private
		 * function to create Chat Message Result Handler
		 * @param event of type ResultEvent
		 *
		 */
		private function createChatMessageResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ChatMessageVO);
		}

		/**
		 * @private
		 * function to get  Chat Message By Session Id Result Handler
		 * @param event of type ResultEvent
		 *
		 */
		private function getChatMessageBySessionIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
	}
}
