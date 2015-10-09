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
 * File			: ChatHistoryItemRendererScript.as
 * Module		: chat
 * Developer(s)	: Soumya M.D,NidhiSarasan
 * Reviewer(s)	: Vishnupreethi K
 *
 * Item renderer for lstchtHistory in ChatHistory.mxml
 *
 */
import edu.amrita.aview.chat.vo.ChatSessionVO;

import flash.events.Event;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;

import spark.components.CheckBox;

/** icon for online users */
[Bindable]
[Embed(source="../assets/images/group_chat.png")]
public var groupChat:Class;

/** icon for offline users */
[Bindable]
[Embed(source="../assets/images/private_chat.png")]
public var privateChat:Class;
/** class for showing status icon */
[Bindable]
public var iconChatTypeSrc:Class=privateChat;

/**
 * For Log API
 */
 private var log:ILogger=Log.getLogger("aview.chat.chatHistory.ChatHistoryItemRendererScript.as");
/**
 * @protected
 * Invoked when the check box selection is changed
 *
 * @param event of type Event
 */
protected function chkSelectionChangeHandler(event:Event):void
{
	this.selected = false;
	this.data.isSelected=this.chkSelection.selected;
	if(Log.isInfo()) log.info(""+this.data);
}

protected function creationCompleteHandler(event:FlexEvent):void
{
	iconChatTypeSrc = ((this.data as ChatSessionVO).isPrivateChat == "Y")?privateChat:groupChat
}

