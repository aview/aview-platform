////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * 
 * File			: ChatViewHandler.as
 * Module		: chat
 * Developer(s)	: Ravi Shankar,Soumya.M.D,NidhiSarasan
 * Reviewer(s)	: Bri.Radha,Vishnupreethi K
 * 
 */
/**
 *  VPCR: Add file description */

import edu.amrita.aview.chat.ChatModel;
import edu.amrita.aview.core.shared.events.ChatEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
applicationType::DesktopWeb{
	import edu.amrita.aview.contacts.ContactsSelectionController;
}
import edu.amrita.aview.contacts.events.ContactsProviderEvent;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;

import flash.events.Event;
import flash.events.MouseEvent;

import flashx.textLayout.conversion.TextConverter;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import spark.components.ToggleButton;
import spark.components.VScrollBar;
import spark.events.IndexChangeEvent;

/**
 * VPCR: Add variable description */

private var selectedName:String=null;	
private var selectedBy:String;			
private var displayName:String;			

[Bindable]
private var _chatModel:ChatModel = null;

[Bindable]
private var chatMessage:String = null;

[Bindable]
private var isModerator:Boolean = false;

private var moduleRO:ModuleRO = null;
applicationType::DesktopWeb{
	private var contSelectionController:ContactsSelectionController = null;
}

/**
 * @public 
 * @param chatModel of type ChatModel
 * @param isModerator of type Boolean
 * 
 */
/**
 * VPCR: Add function description for all functions */
public function initChatView(chatModel:ChatModel,mro:ModuleRO):void
{
	this._chatModel = chatModel;
	this.isModerator = chatModel.isModerator;
	this.moduleRO = mro;
	
	this.moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.SEND_CHAT_MESSAGE, chatModel.chatSessionVO.chatSessionId+"");
	this.moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.CLEAR_CHAT_AREA, chatModel.chatSessionVO.chatSessionId+"");
	this.moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.DELETE_CHAT_MEMBERS, chatModel.chatSessionVO.chatSessionId+"");
	this.moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.ADD_CHAT_MEMBERS, chatModel.chatSessionVO.chatSessionId+"");
	
	this.moduleRO.applicationEventMap.registerInitiator(this, ContactsProviderEvent.REFRESH_CONTACTS);
	applicationType::DesktopWeb{
		this.showMembers.addEventListener(Event.CHANGE, showChatParticipants);
	}
}
/**
 * @protected 
 * displays the userlist
 * @param event
 */
protected function showChatParticipants(event:Event):void
{
	var imgButton:ToggleButton = event.currentTarget as ToggleButton;
	showParticipants(imgButton.selected);
}
/**
 * @private 
 * @param event of type Event
 * 
 */
private function zoomChatMessageArea(event:Event):void
{
	//messageArea.textFlow  = TextConverter.importToFlow(_chatModel.chatHistory, TextConverter.TEXT_FIELD_HTML_FORMAT);
	applicationType::DesktopWeb{
		this.messageArea.textFlow.fontSize = this.zoomSize.value ;
	}
	this.messageArea.scrollToRange(int.MAX_VALUE, int.MAX_VALUE); 
}
/**
 * @private
 * sends the  chat message.creates the chat message entry in database and sends the 
 * message to fms
 * @return void
 */
/**
 * @private 
 * 
 */
private function sendChatMessage():void
{
	//check if chatMessage is null or empty
	if (!chatMessage)
	{
		return;
	}
	this.dispatchEvent(new ChatEvent(ChatEvent.SEND_CHAT_MESSAGE, chatMessage));
	chatMessage = "";
}

/**
 * @private 
 * 
 */
private function clearChatArea():void
{
	//check if chatMessage is null or empty
	if (chatModel.chatSessionVO.chatHistory == "")
	{
		MessageBox.show("No messages to clear", "Info", MessageBox.MB_OK);
		return;
	}
	MessageBox.show(Constants.CHAT_CLEAR_TEXT_MODERATOR, Constants.CHAT_CLEAR_TITLE, MessageBox.MB_YESNO, this, confirmClearChat);
}

/**
 * @private 
 * @param event of type MessageBoxEvent
 * 
 */
private function confirmClearChat(event:MessageBoxEvent):void
{
	if (event.type == MessageBoxEvent.MESSAGEBOX_YES)
	{
		this.dispatchEvent(new ChatEvent(ChatEvent.CLEAR_CHAT_AREA));
	}
}

/**
 * @private
 * This  function is used to change the font size of the chat message(s) in the text area display.
 * 
 * @param event of type Event
 * @return void 
 * 
 */
private function zoomSizeChangeHandler(event:Event):void
{
	this.messageArea.text = "";
	this.messageArea.textFlow = TextConverter.importToFlow(chatModel.chatSessionVO.chatHistory, TextConverter.TEXT_FIELD_HTML_FORMAT) ;
	this.messageArea.textFlow.fontSize = event.currentTarget.value;
}

/**
 * @public 
 * @return 
 * 
 */
public function get chatModel():ChatModel
{
	return _chatModel;
}


public function showParticipants(show:Boolean):void
{
	applicationType::DesktopWeb{
		if (show)
		{
			this.currentState = "ExpandedView";
			this.buttonGroup.visible = isModerator;
			this.dispatchEvent(new Event("STATE_CHANGED"));
			
			return;
		}
		this.currentState = "SimpleView";
		this.dispatchEvent(new Event("STATE_CHANGED"));
	}
}

private function onChatMemberSelectionChange(event:IndexChangeEvent):void
{
	applicationType::DesktopWeb{
		if(chatModel.chatSessionVO.isPrivateChat=='N')
		{
			if (this.chatMembersList.selectedItem && isModerator)
			{
				this.btnDelete.enabled = true;
				this.btnAdd.enabled = true;
			}
			else
			{
				this.btnDelete.enabled = false;
				this.btnAdd.enabled = false;
			}
		}
	}
}

private function getSelectedMembers():ArrayCollection
{
	var selectedUsers:ArrayCollection = new ArrayCollection;
	applicationType::DesktopWeb{
		for each (var member:Object in this.chatMembersList.selectedItems)
		{
			selectedUsers.addItem(member);
		}
	}
	return selectedUsers;
}

private function onClickAddChatMembers(event:MouseEvent):void
{
	this.dispatchEvent(new ContactsProviderEvent(ContactsProviderEvent.REFRESH_CONTACTS, onAllContactsCallback));
}

private function onAllContactsCallback(allGroupsAndContacts:ArrayCollection):void
{
	applicationType::DesktopWeb{
		contSelectionController = new ContactsSelectionController(allGroupsAndContacts,moduleRO,chatModel.chatSessionVO.getUsers(),false,false);
		contSelectionController.init();
		contSelectionController.contactsSelectionView.addEventListener(FlexEvent.REMOVE,onCloseContactSelection);
		
		PopUpManager.addPopUp(contSelectionController.contactsSelectionView,this,true);
		PopUpManager.centerPopUp(contSelectionController.contactsSelectionView);
	}
}

private function onCloseContactSelection(event:FlexEvent):void
{
	applicationType::DesktopWeb{
		this.dispatchEvent(new ChatEvent(ChatEvent.ADD_CHAT_MEMBERS, contSelectionController.getNewlySelectedUsers()));
	}
}

private function onClickDeleteChatMembers(event:MouseEvent):void
{
	this.dispatchEvent(new ChatEvent(ChatEvent.DELETE_CHAT_MEMBERS, getSelectedMembers()));
}

public function clearEventMap():void
{
	this.moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.SEND_CHAT_MESSAGE, chatModel.chatSessionVO.chatSessionId+"");
	this.moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.CLEAR_CHAT_AREA, chatModel.chatSessionVO.chatSessionId+"");
	this.moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.DELETE_CHAT_MEMBERS, chatModel.chatSessionVO.chatSessionId+"");
	this.moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.ADD_CHAT_MEMBERS, chatModel.chatSessionVO.chatSessionId+"");
	
	this.moduleRO.applicationEventMap.unregisterInitiator(this, ContactsProviderEvent.REFRESH_CONTACTS);
}
