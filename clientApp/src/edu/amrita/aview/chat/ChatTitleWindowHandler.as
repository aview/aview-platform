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
 * File			: ChatTitleWindowHandler.as
 * Module		: Chat
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Vishnupreethi K 
 * 
 * 
 */
/**
 * VPCR: Add file description */

import edu.amrita.aview.chat.ChatModel;
applicationType::DesktopWeb{
	import edu.amrita.aview.chat.ChatView;
	import edu.amrita.aview.chat.assets.skins.MinimizableTitleWindowSkin;
}
applicationType::mobile{
	import edu.amrita.aview.chat.PrivateChat;
}
import edu.amrita.aview.core.shared.events.ChatEvent;
//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.managers.ISystemManager;
import mx.binding.utils.ChangeWatcher;

import spark.components.Button;
import spark.components.CheckBox;
import spark.components.Image;
import spark.components.ToggleButton;
import spark.events.IndexChangeEvent;
import spark.events.TitleWindowBoundsEvent;

applicationType::DesktopWeb{
	[SkinState("minimized")]
	
	[SkinPart(required="false")]

	/**
	 * VPCR: Add variable declaration */
	
	public var btnAddPeople:Image;
	
	[SkinPart(required="false")]
	public var exitButton:Button;

	/**
	 *  The skin part that defines the appearance of the 
	 *  button responsible for minimization of the titlewindow.
	 */
	[SkinPart(required="false")]
	public var minimizeButton:Button;
	[Bindable]
	[Embed(source="assets/images/offline.png")]
	public var userOffline:Class;
	
	/** icon for offline users */
	[Bindable]
	[Embed(source="assets/images/online.png")]
	public var userActive:Class;
	
	
	[Bindable]
	[Embed(source="assets/images/maximize.png")]
	public var restoreIcon:Class;
}
/**
 * @private
 * storage variable for <code>minimized</code>property.
 * Add minButton click listener.
 */
protected var _minimized:Boolean;
private var heightWatch:ChangeWatcher;

public var posX:Number = 500;
public var posY:Number = 500;
applicationType::DesktopWeb{
	private var chatView:ChatView = null;
}
applicationType::mobile{
	private var chatView:PrivateChat = null;
}
private var chatSessionId:Number = 0;

private const MAX_CHARS:Number = 23;
private const TITLE_APPENDAGE:String = "...";

private var _moduleRO:ModuleRO = null;


public function changeStatus():void
{
	chatView.addEventListener("STATE_CHANGED",childStateChanged);
	applicationType::DesktopWeb{
		if(chatView.chatModel)
		{
			if(chatView.chatModel.chatSessionVO.isPrivateChat == "Y")
			{
				var members:ArrayCollection = chatView.chatModel.chatSessionVO.members;
				if(members.length!=0)
				{
					for(var i:int=0;i<members.length;i++)
					{
						switch(members[i].member.userStatus)
						{
							case Constants.ONLINE:
							{
							 	(this.skin as MinimizableTitleWindowSkin).iconStatus = userActive;
								break;
							}
							case Constants.OFFLINE:
							{
								(this.skin as MinimizableTitleWindowSkin).iconStatus = userOffline;
								break;
							}
							default:
							{
								(this.skin as MinimizableTitleWindowSkin).iconStatus = userOffline;
							}
						}
					}
				}
				else
				{
					(this.skin as MinimizableTitleWindowSkin).iconStatus = userOffline;
				}
			}
			else
			{
				(this.skin as MinimizableTitleWindowSkin).userStatusIcon.visible = false;
			}
		}
	}
}
private function childStateChanged(event:Event):void
{
	if(chatView.currentState == "SimpleView")
	{
		if(this.width == 400 ||this.width<300 || this.height<300)
		{
			this.width = 300;
			this.height = 300;
		}
			this.minWidth = 300;
			this.minHeight = 300;
	}
	else 
	{
		if(this.width<400 || this.height<300)
		{
			this.width = 400;
			this.height = 300;
		}	
			this.minWidth = 400;
			this.minHeight = 300;
	}
	this.invalidateDisplayList();
}
/**
 * @public 
 * @param value of type String
 * 
 */
/**
 * VPCR: Add function description for all functions */
applicationType::DesktopWeb{
	override public function set title(value:String):void
	{
		if (value.length > MAX_CHARS)
		{
			value = value.slice(0, MAX_CHARS - TITLE_APPENDAGE.length);
			value += TITLE_APPENDAGE;
		}
		super.title = value;
	}
}

/**
 * @private 
 * 
 */
public function init(mro:ModuleRO):void
{
	this._moduleRO = mro;
}

public function get moduleRO():ModuleRO
{
	return this._moduleRO;
}

/**
 * @public 
 * @param posX of type Number
 * @param posY of type Number
 * 
 */
public function setPosition(posX:Number, posY:Number):void
{
	this.posX = posX;
	this.posY = posY;
}

private function addEvents():void
{
	this._moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.MINIMIZE);
//	this._moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.RESTORED, chatSessionId+"");
	this._moduleRO.moduleEventMap.registerInitiator(this, ChatEvent.EXIT_CHAT, chatSessionId+"");
}


private function removeEvents():void
{
	this._moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.MINIMIZE);
//	this._moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.RESTORED, chatSessionId+"");
	this._moduleRO.moduleEventMap.unregisterInitiator(this, ChatEvent.EXIT_CHAT, chatSessionId+"");
}

/**
 * @public 
 * @param chatView
 * @param isModerator of type Boolean
 * 
 */
applicationType::DesktopWeb{
	public function addChatView(chatView:ChatView):void 
	{
		this.chatView = chatView;
		chatView.percentHeight = 100;
		chatView.percentWidth = 100;
		chatHolder.addElement(this.chatView);
		this.chatSessionId = chatView.chatModel.chatSessionVO.chatSessionId;
		chatView.messageArea.scrollToRange(int.MAX_VALUE, int.MAX_VALUE);
		this.title = chatView.chatModel.chatSessionVO.title;
		// AKCR: can the hard-coded string be moved to the MXML file or constants?
		if (chatView.chatModel.chatSessionVO.isPrivateChat == "N")
		{
			this.title = chatView.chatModel.chatSessionVO.title;
			if(chatView.chatModel.isModerator)
			{
				this.exitButton.toolTip = "End Chat Session";
			}
		}
		else
		{
			chatView.clearChatButton.visible = false;
			chatView.showMembers.visible = false;
			this.title = chatView.chatModel.chatSessionVO.members[0].member.userDisplayName+ "_Private Chat";
			this.exitButton.toolTip = "Exit Chat Session";
		}
		
		addEvents();
		
		//this event is handled in MinimizedChatWindowContainer to remove it from the list of minimized chats.
		this.dispatchEvent(new ChatEvent(ChatEvent.RESTORED, this));
	}
}
applicationType::mobile{
	public function addChatView(chatView:PrivateChat):void 
	{
		this.chatView = chatView;
		chatView.percentHeight = 100;
		chatView.percentWidth = 100;
		chatHolder.addElement(this.chatView);
		this.chatSessionId = chatView.chatModel.chatSessionVO.chatSessionId;
		chatView.messageArea.scrollToRange(int.MAX_VALUE, int.MAX_VALUE);
		this.title = chatView.chatModel.chatSessionVO.title;
		// AKCR: can the hard-coded string be moved to the MXML file or constants?
		if (chatView.chatModel.chatSessionVO.isPrivateChat == "N")
		{
			this.title = chatView.chatModel.chatSessionVO.title;
		}
		else
		{
			this.title = chatView.chatModel.chatSessionVO.members[0].member.userDisplayName+ "_Private Chat";
		}
		
		addEvents();
		
		//this event is handled in MinimizedChatWindowContainer to remove it from the list of minimized chats.
		this.dispatchEvent(new ChatEvent(ChatEvent.RESTORED, this));
	}
}

/**
 * This method is used to constrain the movement TitlteWindow to the application. 
 */
/**
 * @private 
 * @param event of type TitleWindowBoundsEvent
 * 
 */
private function windowMovingHandler(event:TitleWindowBoundsEvent):void
{
	var systemManager:ISystemManager =  FlexGlobals.topLevelApplication.systemManager;
	//constrain the horizontal movement
	if (event.afterBounds.left < 0)
	{
		event.afterBounds.left = 0;
	} 
	else if (event.afterBounds.right > systemManager.stage.stageWidth)
	{
		event.afterBounds.left = systemManager.stage.stageWidth - event.afterBounds.width;
	}
	//constrain the vertical movement
	if (event.afterBounds.top < 0) 
	{
		event.afterBounds.top = 0;
	} 
	else if (event.afterBounds.bottom > systemManager.stage.stageHeight)
	{
		event.afterBounds.top = systemManager.stage.stageHeight - event.afterBounds.height;
	}
	/*
	//to make it non-draggable
	event.stopPropagation();
	event.preventDefault();
	*/
	this.posX = this.x;
	this.posY = this.y;
}

/**
 * @protected
 * Invoked when skinpart is Added 
 * @param partName of type String
 * @param instance of type Object
 */

override protected function partAdded(partName:String, instance:Object):void
{
	super.partAdded(partName, instance);
	applicationType::DesktopWeb{
		switch(instance)
		{
			case minimizeButton:
			{
				minimizeButton.addEventListener(MouseEvent.CLICK, minimizeHandler);
				break;
			}
			case exitButton:
			{
				exitButton.addEventListener(MouseEvent.CLICK, exitChatHandler);
				break;
			}
			case btnAddPeople:
			{
				break;
			}
				
			default:
			{
				break;
			}
		}
	}
}
/**
 * @private
 * Remove minButton click listener.
 */
override protected function partRemoved(partName:String, instance:Object) : void
{
	applicationType::DesktopWeb{
		if (instance == minimizeButton)
		{
			Button(instance).removeEventListener(MouseEvent.CLICK, minimizeHandler);
		}
	}
	super.partRemoved(partName, instance);
}
/**
 * @protected
 * Invoked when the minimize button is clicked
 * @param event
 */
private function minimizeHandler(event:MouseEvent):void
{
	minimized = !minimized;
	//this.minimizeButton.setStyle("icon",restoreIcon);
	var data:Object = {"window":this, "chatSessionId":chatSessionId};
	this.dispatchEvent(new ChatEvent(ChatEvent.MINIMIZE, data));
}

/**
 * @private 
 * @param event of type MouseEvent
 * 
 */
private function exitChatHandler(event:MouseEvent):void
{
	this.dispatchEvent(new ChatEvent(ChatEvent.EXIT_CHAT));
	removeEvents();
}


/**
 * Flag indicating whether this titlewindow is minimized or not.
 */ 
public function get minimized():Boolean
{
	return _minimized;
}
/**
 * @private
 */
public function set minimized(value:Boolean):void
{
	_minimized = value;
	_minimized ? (this.height = 30) : (this.height = 300);
	this.invalidateSkinState();
}


/**
 *  @private
 */
override protected function getCurrentSkinState():String
{
	return minimized ? "minimized" : super.getCurrentSkinState();
}

public function chatWindowMoveHandler(event:*):void
{

	heightWatch = ChangeWatcher.watch(FlexGlobals.topLevelApplication,'height',resizechatHandler);
	//checking with the x position and width 
	if (this.x < 0)
		this.x=0;
	if ((this.x + this.width) > FlexGlobals.topLevelApplication.mainApp.stage.stageWidth)
	{
		var val:Number=0;
		val=(this.x + this.width) - FlexGlobals.topLevelApplication.mainApp.stage.stageWidth;
		this.x=this.x - val;
	}
	//checking with the y position and height 
	if (this.y < 0)
		this.y=0;
	if ((this.y + this.height) > FlexGlobals.topLevelApplication.mainApp.stage.stageHeight)
	{
		var val:Number=0;
		val=(this.y + this.height) - FlexGlobals.topLevelApplication.mainApp.stage.stageHeight;
		this.y=this.y - val;
	}
	if(this.x<0 ||this.y<0)
	{
		this.x=0;
		this.y=0;
	}
}

private function resizechatHandler(event:Event):void
{
	if (this.x < 0)
		this.x=0;
	if ((this.x + this.width) > FlexGlobals.topLevelApplication.mainApp.stage.stageWidth)
	{
		var val:Number=0;
		val=(this.x + this.width) - FlexGlobals.topLevelApplication.mainApp.stage.stageWidth;
		this.x=this.x - val;
	}
	//checking with the y position and height 
	if (this.y < 0)
		this.y=0;
	if ((this.y + this.height) > FlexGlobals.topLevelApplication.mainApp.stage.stageHeight)
	{
		var val:Number=0;
		val=(this.y + this.height) - FlexGlobals.topLevelApplication.mainApp.stage.stageHeight;
		this.y=this.y - val;
	} 
	if(this.x<0 ||this.y<0)
	{
		this.x=0;
		this.y=0;
	}
}
