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
 * File			: ChatHistoryScript.as
 * Module		: chat
 * Developer(s)	: Soumya M.D,NidhiSarasan
 * Reviewer(s)	: Bri.Radha,Vishnupreethi K
 *
 * component that displays the history of all chat sessions for the current user
 *
 */
import edu.amrita.aview.core.shared.events.ChatEvent;
import edu.amrita.aview.chat.helper.ChatSessionHelper;
import edu.amrita.aview.chat.helper.ChatSessionMemberHelper;
import edu.amrita.aview.chat.vo.ChatSessionMemberVO;
import edu.amrita.aview.chat.vo.ChatSessionVO;
//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.core.gclm.vo.UserVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.events.CloseEvent;
import mx.formatters.DateFormatter;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

import spark.components.Label;

/**
 * Variable to store chat history data as ArrayCollection
 */

[Bindable]
private var chatSessionsHistory:ArrayCollection=null;

/**
 * variable to do logging
 */
private var log:ILogger=Log.getLogger("edu.amrita.aview.chat.ChatHistoryScript");

private var userVO:UserVO = null;

private var appEventMap:EventMap = null;

private var sessionMembersForDeletion:ArrayCollection=new ArrayCollection();
private var sessionsForDeletion:ArrayCollection=new ArrayCollection();

[Bindable]
private var selectedChatSession:ChatSessionVO = null;

/**
 * @private
 * Retrieves the chat Session with members and messages.
 *
 *
 */
private function creationCompletionHandler():void
{
	(new ChatSessionHelper()).getChatSessionsByMemberId(userVO.userId,getChatSessionsByMemberIdResultHandler);	
	appEventMap.registerInitiator(this,ChatEvent.CONTINUE_CHAT);
}

public function init(userVO:UserVO,appEventMap:EventMap):void
{
	this.userVO = userVO;
	this.appEventMap = appEventMap;
}

/**
 * @public
 * ResultHandler for getChatSessionByMemberId , updates the dataprovider for the list
 * that updates the chatHistory
 *
 * @param event of type ResultEvent
 *
 */
public function getChatSessionsByMemberIdResultHandler(chatSessions:ArrayCollection):void	
{
	for each(var session:ChatSessionVO in chatSessions)
	{
		session.prepareChatHistory();
	}
	chatSessionsHistory=chatSessions;
	chatSessionsHistory.refresh();
}

/**
 * @public
 * FaultHandler for getChatSessionByMemberId
 *
 * @param event of type FaultEvent
 *
 */
public function getChatSessionsByMemberIdFaultHandler(event:FaultEvent):void	
{
	log.error("getChatSessionsByMemberIdFaultHandler:Retrieving the chatSession for"+userVO.userName+" is failed");
}

/**
 * @protected
 * Event handler for delete button
 *
 * @param event of type MouseEvent
 */
protected function deleteBtn_clickHandler(event:MouseEvent):void 
{
	//Just to be sure..
	sessionMembersForDeletion.removeAll();
	sessionsForDeletion.removeAll();
	
	for each(var chatSessionVO:ChatSessionVO in chatSessionsHistory)
	{
		if(chatSessionVO.isSelected)
		{
			if(chatSessionVO.owner.userId == userVO.userId){ //Moderator, so delete the entire session..
				sessionsForDeletion.addItem(chatSessionVO);
			}
			else
			{
				var chatSessionMember:ChatSessionMemberVO = chatSessionVO.getMember(userVO.userId);
				if(chatSessionMember != null)
				{
					sessionMembersForDeletion.addItem(chatSessionMember);
				}
			}
		}
	}

	if(sessionsForDeletion.length == 0 && sessionMembersForDeletion.length == 0)
	{
		Alert.show("Please select at least one session for deletion", "Warning");
		return;
	}
	
	Alert.show("Are you sure you want to delete the selection sessions' history?", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {
		if(event.detail == Alert.YES)
		{
			if(sessionMembersForDeletion.length > 0)
			{
				//deleting chatSessionMember entries in database.
				(new ChatSessionMemberHelper()).deleteChatSessionMembers(sessionMembersForDeletion, userVO.userId,
					deleteChatSessionMembersResultHandler);
			}
			if(sessionsForDeletion.length > 0)
			{
				(new ChatSessionHelper()).deleteChatSessions(sessionsForDeletion,userVO.userId,deleteChatSessionsResultHandler);
			}
		}
		else
		{
			sessionMembersForDeletion.removeAll();
			sessionsForDeletion.removeAll();
		}
	}, null, 1);
}

/**
 * @public
 * Result handler for deleteChatSessionMembersByChatSession
 * refreshes the list that displays the chat history
 *
 * @param event of type ResultEvent
 *
 */
public function deleteChatSessionMembersResultHandler():void
{
	Alert.show("Deleted selected participating sessions ", "Information");
	removeDeletedParticipatingSessions();
	sessionMembersForDeletion.removeAll();
}

private function removeSelectedSession(deletedSessionId:Number):void
{
	if(selectedChatSession && deletedSessionId == selectedChatSession.chatSessionId)
	{
		selectedChatSession = null;
	}
}

private function removeDeletedParticipatingSessions():void
{
	for each(var member:ChatSessionMemberVO in sessionMembersForDeletion)
	{
		removeSelectedSession(member.chatSessionId);
		for each(var session:ChatSessionVO in chatSessionsHistory)
		{
			if(member.chatSessionId == session.chatSessionId)
			{
				chatSessionsHistory.removeItemAt(chatSessionsHistory.getItemIndex(session));
				break;
			}
		}
	}
}


/**
 * @public
 * Result handler for deleteChatSessionMembersByChatSession
 * refreshes the list that displays the chat history
 *
 * @param event of type ResultEvent
 *
 */
public function deleteChatSessionsResultHandler():void
{
	Alert.show("Deleted selected moderating sessions ", "Information");
	removeDeletedSessions();
	sessionsForDeletion.removeAll();
}

private function removeDeletedSessions():void
{
	for each(var chatSession:ChatSessionVO in sessionsForDeletion)
	{
		removeSelectedSession(chatSession.chatSessionId);
		chatSessionsHistory.removeItemAt(chatSessionsHistory.getItemIndex(chatSession));
	}
	this.chatContinueBtn.visible= !(chatSession.lectureId == 0 
		|| (chatSession.owner.userId == this.userVO.userId)
		|| chatSession.isPrivateChat == "N");
}

/**
 * @protected
 * Invoked when the item is clicked
 * displays the chatmessages for the selected chat session
 *
 * @param event of type MouseEvent
 */
protected function onChatSessionsListClick(event:MouseEvent):void
{
	if (event.target is Label)
	{
		selectedChatSession=this.chatSessionsList.selectedItem as ChatSessionVO;
		//Only if the user is moderator, private chat or if it's a classs/meeting chat..
		this.chatContinueBtn.visible = !((selectedChatSession.isPrivateChat == "N") && (selectedChatSession.owner.userId != this.userVO.userId))
		
	}
}

protected function onChatContinueBtnClick(event:MouseEvent):void
{
	this.dispatchEvent(new ChatEvent(ChatEvent.CONTINUE_CHAT,selectedChatSession));
}

