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
 * File			: ChatHandler.as
 * Module		: Chat
 * Developer(s)	: Ravishankar
 * Reviewer(s)	: Vishnupreethi K 
 * 
 * The default skin to create new chat session.
 * This is the action script file for Chat component.
 * 
 */
import com.amrita.edu.collaboration.AutoPropertyName;
import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.ColorText;
	import edu.amrita.aview.common.components.alert.CustomAlert;
	import edu.amrita.aview.core.entry.ClassroomComponent;
	import edu.amrita.aview.questions.BreakSession;
}
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.events.ChatEvent;
import edu.amrita.aview.questions.events.BreakSessionEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import flashx.textLayout.conversion.TextConverter;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;

import spark.utils.TextFlowUtil;
import mx.events.FlexEvent;
applicationType::DesktopWeb{
	import edu.amrita.aview.playback.components.ChatCom;
	import edu.amrita.aview.core.shared.events.ChatStatusEvent;
}
import edu.amrita.aview.chat.ChatComponent;
import spark.components.supportClasses.StyleableTextField;
import mx.utils.ObjectUtil;
import com.adobe.utils.ArrayUtil;
import mx.utils.ArrayUtil;
import com.adobe.utils.DateUtil;
import mx.collections.ArrayCollection;
import flash.utils.ByteArray;
import flash.net.FileReference;

applicationType::mobile{
	import edu.amrita.aview.core.entry.MainMobileApplication;
}
applicationType::DesktopWeb{
	[Bindable]
	[Embed(source="assets/images/view-fullscreen1.png")]
	public var popoutIcon:Class;
	
	[Bindable]
	[Embed(source="assets/images/windows_nofullscreen.png")]
	public var popinIcon:Class;
}
/**Platform specific imports*/
applicationType::desktop
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NotificationType;
	
	import edu.amrita.aview.chat.ChatPopOut;
}

/**
 * For Log API
 */
private var logg:ILogger=Log.getLogger("aview.ChatComponent");

public var chatCollaborationObject:CollaborationObject;

public var isPopOut:Boolean=false;

//Variable added to clear the old chat message when server fail over happens
private var failOverCount : int = 0;

/*[Bindable]
private var chatMessages:String="";*/
[Bindable]
private var chatMessages:ArrayCollection;
public var preRecordedChats:Array=new Array();
applicationType::DesktopWeb{
	private var classroomComp:ClassroomComponent;
	private var parentComp:Canvas;
}
applicationType::mobile{
	private var classroomComp:MainMobileApplication;
	//Break session
	public  var brkSessionBool : Boolean = false ;
	private var isChatIntialized:Boolean = false;
}
private var classRoomModuleRO:ModuleRO;

/**Platform specific variables*/
applicationType::desktop
{
	public var chatPopComp:ChatPopOut;
}

/**Variable to remember the count of last network reconnection*/
public var lastReconnectionCount:int = 0;

/**
 * The function is used to initiliaze the chat component.
 *
 *
 * @return void
 */
// The function is used to initiliaze the chat component.This sets the height,width and x value
// of the chat component.This function sets connection with the FMS server.
applicationType::DesktopWeb{
	public function init(classroomComp:ClassroomComponent,mro:ModuleRO):void
	{
		this.classroomComp = classroomComp;
		this.classRoomModuleRO = mro;
		this.parentComp = classroomComp.classroomComponentSgl.Chat_canvas0;
		this.parentComp.addChild(this);
		setupEvents();
	}
}
applicationType::mobile{
	public function init(classroomComp:MainMobileApplication,mro:ModuleRO):void
	{
		this.classroomComp = classroomComp;
		this.classRoomModuleRO = mro;
		setupEvents();
	}
}
private function setupEvents():void{
	this.classRoomModuleRO.moduleEventMap.registerMapListener(ChatEvent.SEND_CHAT_MESSAGE,sendChatMessage,"Session");
}

private function clearEvents():void{
	this.classRoomModuleRO.moduleEventMap.unregisterMapListener(ChatEvent.SEND_CHAT_MESSAGE,sendChatMessage,"Session");
}

/**
 * @public
 * This  function is used when moderator clicks to clear all existing chat messages.
 * It request's for a confirmation through a pop up with option to clear (Yes) or cancel (No).
 * 
 *
 * @return void 
 * 
 */
public function clearChatArea(event:ChatEvent= null):void
{
	if (ClassroomContext.isModerator)
	{
		// AKCR: can we use conditional operator here? for e.g
		//		MessageBox.show(Constants.CHAT_CLEAR_TEXT_MODERATOR, 
		//						Constants.CHAT_CLEAR_TITLE, 
		//						MessageBox.MB_YESNO, 
		//						isPopOut? this : null, 
		//						confirmClearChat);
		if (isPopOut)
		{
			MessageBox.show(Constants.CHAT_CLEAR_TEXT_MODERATOR, Constants.CHAT_CLEAR_TITLE, MessageBox.MB_YESNO, this, confirmClearChat);
		}
		else
		{
			MessageBox.show(Constants.CHAT_CLEAR_TEXT_MODERATOR, Constants.CHAT_CLEAR_TITLE, MessageBox.MB_YESNO, null, confirmClearChat);
		}
	}
	else
	{
		// AKCR: Can we use conditional operator here? for e.g
		//		MessageBox.show(Constants.CHAT_CLEAR_NO_MESSAGES, 
		//			Constants.CHAT_CLEAR_TITLE, 
		//			MessageBox.MB_OK, 
		//			isPopOut? this : null);
		
		if (isPopOut)
		{
			MessageBox.show(Constants.CHAT_CLEAR_NO_MESSAGES, Constants.CHAT_CLEAR_TITLE, MessageBox.MB_OK, this);
		}
		else
		{
			MessageBox.show(Constants.CHAT_CLEAR_NO_MESSAGES, Constants.CHAT_CLEAR_TITLE, MessageBox.MB_OK, null);
		}
	}
}
/**
 * @private
 * This  function clears the chat messages and notifies all the viewers about chat being cleared.
 * 
 * @param chatClrEvt of type MessageBoxEvent
 * @return void 
 * 
 */
private function confirmClearChat(chatClrEvt:MessageBoxEvent):void
{
	if (chatClrEvt.type.toString() == MessageBoxEvent.MESSAGEBOX_YES)
	{
		if (Log.isInfo()) logg.info("Chat: Clear confirmed - ");
		chatCollaborationObject.removeAllValues();
		sendChatMessage(new ChatEvent(ChatEvent.SEND_CHAT_MESSAGE,Constants.CHAT_CLEAR_KEY));
		chatClearEventLog();
	}
	else
	{
		MessageBox.show(Constants.CHAT_CLEAR_NO_MESSAGES, Constants.CHAT_CLEAR_TITLE, MessageBox.MB_OK, (isPopOut)?this:null);
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
private function zoomSize_ChangeHandler(event:Event):void
{
	applicationType::DesktopWeb{		
		messageArea.setStyle("fontSize", zoomSize.value);
		messageArea.ensureCellIsVisible(messageArea.selectedIndex);
		if (ClassroomContext.isModerator && classroomComp.recorder.isRecording)
		{
			classroomComp.recorder.chatRecorder.recordChat(classroomComp.recorder.getCentralTime(), "", zoomSize.value);
		}
	}
}
/**
 * @public
 * This function to handle the right click on a mouse selection.
 * 
 * @param event of type MouseEvent
 * @return void 
 * 
 */
public function rightMouseDownHandler(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		if (!MouseEvent.RIGHT_MOUSE_DOWN)
		{
			event.stopImmediatePropagation();
			{
				CustomAlert.info(Constants.CHAT_SELECT_NO_MESSAGES, Constants.CHAT_SELECT_TITLE);
			}
		}
	}
}
/**
 * @private
 * This function to set / unset the full screen mode.
 * 
 * @param isVisible of type Boolean
 * @return void 
 * 
 */
private function popOutBtnVisble(isVisible:Boolean):void
{
	applicationType::desktop{
		// AKCR: please use conditional operator
		if (isVisible)
		{
			popOutBtn.alpha=1;
		}
		else
		{
			popOutBtn.alpha=0;
		}
	}
}
/**
 * @private
 * The function to close the chat window.
 * 
 * @param event of type Event
 * @return void 
 * 
 */
public function closeHandler(event:Event):void
{
	applicationType::desktop
	{
		chatPopComp.removeEventListener(Event.CLOSING, closeHandler);
		popChatWindow();
	}	
}
/**
 * @public
 * This function to open / exit a full screen chat window.
 * 
 *
 * @return void 
 * 
 */
public function popChatWindow():void
{
	applicationType::desktop{
		if (!isPopOut)
		{
			if (this.parentComp && this.parentComp.contains((this)))
			{
				this.parentComp.removeElement(this);
				classroomComp.setMessageForFullScreenForChat(this.parentComp, Constants.FULLSCREEN_MSG, "15");
				chatPopComp=new ChatPopOut();
				chatPopComp.addEventListener(Event.CLOSING, closeHandler);
				this.percentWidth=100;
				this.messageArea.percentWidth=100;
				chatPopComp.addElement(this);
				isPopOut=true;
				chatPopComp.open(true);
				chatPopComp.maximize();
				chatPopComp.title="Chat ( A-VIEW - " + ClassroomContext.aviewClass.className + " )";
				popOutBtn.setStyle("icon", popinIcon);
				popOutBtn.toolTip="CHAT: Exit full screen";
				popOutChatEventLog();
				//bug fix 15224 
				writeMessage('');				
			}
		}
		else
		{
			if (this.parentComp)
			{
				/*				chatPopComp.dispatchEvent(new ChatPopOutClose(ChatPopOutClose.QB, true)) ;*/
				try
				{
					chatPopComp.removeElement(this);
					chatPopComp.close();
				}
				catch (e:Error)
				{
					if (Log.isError()) logg.error("Error in popChatWindow method- " + e.getStackTrace());
				}
				this.width=250;
				this.messageArea.width=250;
				this.parentComp.addChild(this);
				classroomComp.unSetMessageForFullScreenForChat(this.parentComp);
				isPopOut=false;
				popOutBtn.setStyle("icon", popoutIcon);
				popOutBtn.toolTip="CHAT: Full screen";
				popInChatEventLog();
				//bug fix 15224 
				writeMessage('');				
			}
		}
	}
}

private function updateScrollToEnd(end:Boolean=false):void
{
	this.messageArea.validateNow();
	this.messageArea.setSelectedIndex(this.messageArea.dataProvider.length-1);
	this.messageArea.ensureCellIsVisible(this.messageArea.selectedIndex);	
}

/**
 *
 * @private
 * Audits the "PopInChat" action, when the user Pops in/closes the chat tab
 *
 * @return void
 *
 */
private function popInChatEventLog():void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.popInChat, null, null, null);	
		
	}
}

/**
 *
 * @private
 * Audits the "PopOutChat" action, when the user Pops out the chat tab
 *
 * @return void
 *
 */
private function popOutChatEventLog():void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.popOutChat, null, null, null);
		updateScrollToEnd();
	}
}

private function removeTabsAndNewLines($str:String):String
{
	var rex:RegExp = /(\t|\n|\r)/gi;
	$str = $str.replace(rex,' ');
	return $str;
}


private function saveChatText():void
{
	var toRet:String='';	
	for each( var obj:Object in this.messageArea.dataProvider ) {
		toRet  = toRet + obj['Message']+"\r\n";					
	}		
	var bytes:ByteArray = new ByteArray();
	var fileRef:FileReference=new FileReference();
	fileRef.save(toRet, "chatText.html");	
}

/**
 * @public
 * The function is used to send the chat message to server.
 * The message also displays the time when the chat is send
 * along with the chat message.
 * The 'setFocus' function sets the focus of the cursor in 
 * the same text field after each message is sent. 
 *
 *
 * @return void
 */

public function sendChatMessage(event:ChatEvent= null):void
{
	
	var strMsg:String;
	var tim:Date=new Date;
	var fontColour:String=Constants.DEFAULT_CHAT_COLOR;
	var fontFace:String="Arial";
	var fontSize:String;
	var fontWeight:String=Constants.DEFAULT_CHAT_FONT_WEIGHT;
	if(event == null){
		applicationType::DesktopWeb{			
			strMsg=removeTabsAndNewLines(chatMessageInput.text);			       
			strMsg=StringUtil.trim(strMsg);
		}
		applicationType::mobile{
			strMsg=StringUtil.trim(FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.text);
		}
	}else{
		strMsg=StringUtil.trim(event.data as String);
	}
	
	var message:Object=new Object();
	message.fontColour=fontColour;
	message.fontFace=fontFace;
	message.fontWeight=fontWeight;
	message.fontSize=fontSize;
	message.messageText=strMsg.slice(0,299);
	
	message.sender=ClassroomContext.userVO.userDisplayName;
	//	Moderator name and timestamp set to maroon colour & bold type
	if(ClassroomContext.isModerator)
	{
		fontColour=Constants.MODERATOR_CHAT_COLOR;
		fontWeight=Constants.CHAT_FONT_WEIGHT_BOLD;
	}	
	else
		
		//	Presenter name and timestamp set to green colour & bold type	
		if (classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
			fontColour=Constants.PRESENTER_CHAT_COLOR;
			fontWeight=Constants.CHAT_FONT_WEIGHT_BOLD;
		}
	message.fontColour=fontColour;
	message.fontWeight=fontWeight;
	
	
	if(strMsg!="")
	{
		chatCollaborationObject.addValue(message);
	}
	chatMessageEventLog(strMsg);
	applicationType::DesktopWeb{
		chatMessageInput.text="";
		chatMessageInput.setFocus();
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.chatToolBox.chatMessageInput.text="";
	}
}

/**
 *
 * @private
 * Audits the "ChatMessage" action, when the user sends a chat message
 *
 * @param message - Chat message
 * @return void
 *
 */
private function chatMessageEventLog(message:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.chatMessage, message, null, null);
	}
}

/**
 *
 * @private
 * Audits the "ChatClear" action, when the moderator presses clear chat button
 *
 * @return void
 *
 */
private function chatClearEventLog():void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.chatClear, null, null, null);
	}
}

/**
 * @public
 * The function is used to display the chat message on the chat component.
 *
 *
 * @param msg of type String
 * @return void
 */
private function writeMessage(msg:String):void
{
	applicationType::DesktopWeb{
		if(lastReconnectionCount != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.connectionRetrys ||
			failOverCount != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.failOverCount)
		{			
			chatMessages.addItem({'Message':msg});
			lastReconnectionCount = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.connectionRetrys;
			failOverCount = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.failOverCount;
		}
		else
		{
			if(msg!=='' && msg!=Constants.CHAT_CLEAR_KEY)				
				chatMessages.addItem({'Message':msg});
		}
	}
	applicationType::mobile{
		chatMessages=chatMessages + msg;
	}
	//	Implement 'Clear Chat Msg(s)' feature - Initiated and confirmed by moderator thru Alert.	SRS
	//	Comply action at Viewers with a msg stating that clr was initiated by moderator				SRS
	applicationType::mobile{
		if(!ClassroomContext.isModerator)
		{
			if (msg.indexOf("SESSION BREAK MESSAGE") > 0 )
			{
				var msg1:String = msg.slice(0,msg.indexOf("<"));
				//				var msg2:String = msg.slice(msg.indexOf("@"),msg.lastIndexOf("-"));
				msg = msg1;//+"\n"+msg2+"\n";
				chatMessages=chatMessages+msg;
			}
		}
	}
	if (msg.indexOf(Constants.CHAT_CLEAR_KEY) > 0)
	{
		if (Log.isInfo()) logg.info("Chat: Clear confirmation key: " + msg + " Index value of key: " + msg.indexOf(Constants.CHAT_CLEAR_KEY));
		chatMessages=new ArrayCollection();
		this.messageArea.dataProvider=chatMessages;		
		if (!ClassroomContext.isModerator)
		{
			msg=msg.substring(0, msg.lastIndexOf(":-"));
			applicationType::DesktopWeb{
				chatMessages.addItem({'Message':"<b><font color = '" + Constants.CHAT_CLEAR_MSG_COLOR + "'>" + msg + Constants.CHAT_CLEAR_TEXT_VWR + ClassroomContext.moderatorName + "</font></b><br>"});
			}
			applicationType::mobile{
				chatMessages=msg + Constants.CHAT_CLEAR_TEXT_VWR + ClassroomContext.moderatorName + "\n";
			}		
		}
	}
	applicationType::DesktopWeb{	
		
		updateScrollToEnd();
		messageArea.setStyle("fontSize",zoomSize.value);
		if (ClassroomContext.isModerator && classroomComp.recorder.isRecording)
		{
			classroomComp.recorder.chatRecorder.recordChat(classroomComp.recorder.getCentralTime(), msg, zoomSize.value);
		}
		else
		{
			preRecordedChats.push({msg: msg, fontSize: zoomSize.value});
		}
	}
	applicationType::mobile{
		if(this.messageArea.textDisplay!= null){
			StyleableTextField(this.messageArea.textDisplay).htmlText = chatMessages;
		}
	}	
}


/**
 * 
 * END of Break Session code additions
 * @public
 * To establish netconnection  with the shard object
 * @return void 
 * 
 */
public function connectChatCollaborationObject():void
{
	chatCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("ChatUsers", AutoPropertyName.DATE);
	chatCollaborationObject.setOnSync(chatMessageSync);
	//chatCollaborationObject.setOnChange(chatMessageChange);
	chatCollaborationObject.setOnClear(onClearChatCollaboration);
}
/**
 * @public
 *
 * @return void 
 * 
 */
public function onClearChatCollaboration():void
{
	if (chatCollaborationObject.syncEventCount != 1)
	{
		chatMessages=new ArrayCollection();		
	}
	else
	{
		chatCollaborationObject.removeOnChange();
		chatCollaborationObject.setOnSync(chatMessageSync);
		processAllMessages(chatCollaborationObject.getData());
	}
}
private function chatMessageSync(allMessages:Object):void
{
	if(chatCollaborationObject.syncEventCount!=1)
	{
		//  remove this handler and add onChange handler	
		adjustHandlers();
	}
}

private function adjustHandlers():void
{
	//	chatCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("ChatUsers", AutoPropertyName.DATE);
	
	chatCollaborationObject.removeOnSync();
	chatCollaborationObject.setOnChange(chatMessageChange);
}

// function to flatten the object into array and sort on timestamp
private function sortObject(msgObjs:Object):Array{
	var tempobj:Array = new Array();
	for (var i in msgObjs){
		tempobj.push({id: i, val:msgObjs[i]});
	}
	tempobj.sortOn("id", Array.NUMERIC);
	return tempobj;
}

private function processAllMessages(allMessages:Object):void
{	
	var messageString:String='';
	var msgArray:Array = sortObject(allMessages);	
	var messageArrayCollection:ArrayCollection=new ArrayCollection();
	for (var j:int = 0; j < msgArray.length; j++) 
	{
		var chatMessage = msgArray[j]["val"];
		var messageObj:Object=chatMessage.propertyValue;
		applicationType::DesktopWeb{
			if(messageObj.messageText!=Constants.CHAT_CLEAR_KEY && messageObj.messageText!='')
				messageArrayCollection.addItem({'Message':"<b><font color = '" + messageObj.fontColour + "' face = '" + messageObj.fontFace + "' size = '" + messageObj.fontSize + "'>" + messageObj.sender + ":" + chatMessage.timestamp + "</font></b> " + messageObj.messageText + "<br>"});
		}
		applicationType::mobile{
			if(messageObj.fontColour == "#000000"){
				messageString+="<b>"+messageObj.sender + ":" + chatMessage.timestamp +"</b>"+messageObj.messageText+"\n";
			}else{
				messageString+="<b><i>"+messageObj.sender + ":" + chatMessage.timestamp +"</i></b>"+messageObj.messageText+"\n";
			}
			writeMessage(messageString);
		}
	}
	applicationType::DesktopWeb{
		chatMessages =  new ArrayCollection();//[{Message:""}]
		chatMessages.addAll(messageArrayCollection);
		// ashwini: TODO: this event should not be dispatched while sending the chat message
		if(messageArrayCollection.length!=0)
		{
			classroomComp.chatComp.dispatchEvent(new ChatStatusEvent(ChatStatusEvent.CHAT_RECEIVED));
			this.messageArea.validateNow();		
			updateScrollToEnd();
		}
		messageArrayCollection.removeAll();
	}
	
}
/**
 * @public
 * Set the attribute properties of the chat message.
 * call stack: server -> collab obj -> chatMessageSync
 * @param chatMessage of type Object
 * @param chatOldMessage of type Object
 * @return void 
 * 
 */
public function chatMessageChange(chatMessage:Object, chatOldMessage:Object):void
{
	var messageObj:Object=chatMessage.propertyValue;
	applicationType::DesktopWeb{
		var messageString:String="<b><font color = '" + messageObj.fontColour + "' face = '" + messageObj.fontFace + "' size = '" + messageObj.fontSize + "'>" + messageObj.sender + ":" + chatMessage.timestamp + "</font></b> " + messageObj.messageText + "<br>";
	}
	applicationType::mobile{
		if(messageObj.fontColour == "#000000"){
			var messageString:String="<b>"+messageObj.sender + ":" + chatMessage.timestamp +"</b>"+messageObj.messageText+"\n";
		}else{
			var messageString:String="<b><i>"+messageObj.sender + ":" + chatMessage.timestamp +"</i></b>"+messageObj.messageText+"\n";
		}
	}
	applicationType::DesktopWeb{
		// ashwini: TODO: this event should not be dispatched while sending the chat message
		classroomComp.chatComp.dispatchEvent(new ChatStatusEvent(ChatStatusEvent.CHAT_RECEIVED));
	}
	writeMessage(messageString);
}
/**
 * @public
 * To close the chat shared object.
 * 
 *
 * @return void 
 * 
 */
public function closeCollaborationObject():void
{
	ClassroomContext.collaborationService.closeCollaborationObject("ChatUsers");
}
applicationType::mobile{
	protected function onChatCreate(event:FlexEvent):void
	{
		isChatIntialized = true;
		StyleableTextField(this.messageArea.textDisplay).htmlText = chatMessages;		
		chatContainer.percentWidth=100;
		//Add event listeners for chat tools.
		FlexGlobals.topLevelApplication.chatToolBox.addEventListener(ChatEvent.SEND_CHAT_MESSAGE,sendChatMessage);
		FlexGlobals.topLevelApplication.chatClearTool.addEventListener(ChatEvent.CLEAR_CHAT_AREA,clearChatArea);
		
	}
}