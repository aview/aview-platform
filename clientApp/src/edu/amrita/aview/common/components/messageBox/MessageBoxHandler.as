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
 * File			: MessageBoxHandler.as
 * Module		: common
 * Developer(s)	: Ramesh
 * Reviewer(s)	: Remya T,Vishnupreethi K
 */
/**
 * VPCR: Add file description */

import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
/**
 * Global update values
 */

public static const MSG:String="MSG";
public static const MB_OK:String="ST_OK";
public static const MB_OKCANCEL:String="ST_OKCANCEL";
public static const MB_YESNO:String="ST_YESNO";

[Embed(source="assets/images/ic_add.png")]
[Bindable]
public static var IC_ADD:Class;
[Embed(source="assets/images/ic_alert.png")]
[Bindable]
public static var IC_ALERT:Class;
[Embed(source="assets/images/ic_cancel.png")]
[Bindable]
public static var IC_CANCEL:Class;
[Embed(source="assets/images/ic_clear.png")]
[Bindable]
public static var IC_CLEAR:Class;
[Embed(source="assets/images/ic_close.png")]
[Bindable]
public static var IC_CLOSE:Class;
[Embed(source="assets/images/ic_delete.png")]
[Bindable]
public static var IC_DELETE:Class;
[Embed(source="assets/images/ic_edit.png")]
[Bindable]
public static var IC_EDIT:Class;
[Embed(source="assets/images/ic_help.png")]
[Bindable]
public static var IC_HELP:Class;
[Embed(source="assets/images/ic_info.png")]
[Bindable]
public static var IC_INFO:Class;
[Embed(source="assets/images/ic_more.png")]
[Bindable]
public static var IC_MORE:Class;
[Embed(source="assets/images/ic_save.png")]
[Bindable]
public static var IC_SAVE:Class;


public static const MB_NOTIF:String="NOTIF";
public static const MB_NOTIF_OK:String="NOTIF_OK";

[Embed(source="assets/images/notif_interact.png")]
[Bindable]
public static var MSG_IMG_INTRACT:Class;
[Embed(source="assets/images/notif_presenter.png")]
[Bindable]
public static var MSG_IMG_PRSNTR:Class;
[Embed(source="assets/images/PTT_talk_icon.png")]
[Bindable]
public static var MSG_IMG_TALK:Class;
[Embed(source="assets/images/PTT_mute_icon.png")]
[Bindable]
public static var MSG_IMG_MUTE:Class;

/**
 * To store the type of the message
 */
[Bindable]
private var _type:String=null;

[Bindable]
/**
 * VPCR: Add function description */
/**
 * @public 
 * @return String
 * 
 */
public function get type():String
{
	return _type;
}
/**
 * To store the icon details
 */
[Bindable]
public var icon:Class=IC_INFO;
/**
 * To store the icon details
 */
[Bindable]
public var iconZ:Class;
[Bindable]
/**
 * To store the message to show in the message box
 */
public var msg:String="Default Message";
/**
 * To store the title to show the title in the message box
 */
[Bindable]
public var title:String="Information";
/**
 * To store the message to show in the message box
 */
[Bindable]
public var message:String="Default Message";
/**
 * To store the accept function
 */
private var acceptFunctionHandler:Function=null;
/**
 * To store the decline function
 */
private var declineFunctionHandler:Function=null;

/**
 * @public
 * @param newType of type String
 * @return void
 */
public function set type(newType:String):void
{
	// AKCR: this is duplicate code. Please re-write with SWITCH-CASE construct
	// AKCR: please add a default case in the switch statement
	if (newType)
	{
		if (newType == MB_OK)
		{
			_type=MB_OK;
		}
		else if (newType == MB_OKCANCEL)
		{
			_type=MB_OKCANCEL;
		}
		else if (newType == MB_YESNO)
		{
			_type=MB_YESNO;
		}
		else if (newType == MSG)
		{
			_type=MSG;
		}
		else if (newType == MB_NOTIF)
		{
			_type=MB_NOTIF;
		}
		else if (newType == MB_NOTIF_OK)
		{
			_type=MB_NOTIF_OK;
		}
		this.currentState=_type;
	}
	else
	{
		this.currentState=MB_OK;
	}
}


/**
 * @public
 * to show the alert message window
 * @param message of type String
 * @param title of type String
 * @param type of type Default value Null
 * @param parent of type DisplayObject Default value Null
 * @param acceptFunctionHandler of type Function Default value Null
 * @param declineFunctionHandler of type Function Default value Null
 * @param icon of type String Default value Null
 * @param  iconZ of type String Default value Null
 * @return Messagebox
 */

public static function show(message:String="", title:String="", type:String=null, parent:DisplayObject=null, acceptFunctionHandler:Function=null, declineFunctionHandler:Function=null, icon:Class=null, iconZ:Class=null):MessageBox
{
	var msgBox:MessageBox=new MessageBox();
	
	msgBox.iconZ=iconZ;
	msgBox.msg=message;
	
	msgBox.type=type;
	msgBox.icon=icon;
	msgBox.title=title;
	msgBox.message=message;
	msgBox.acceptFunctionHandler=acceptFunctionHandler;
	msgBox.declineFunctionHandler=declineFunctionHandler;
	msgBox.setFocus();
	if (!parent)
	{
		var sm:ISystemManager=ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		var mp:Object=sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		if (mp && mp.useSWFBridge())
			parent=Sprite(sm.getSandboxRoot());
		else
			parent=Sprite(FlexGlobals.topLevelApplication);
	}
	
	PopUpManager.addPopUp(msgBox, parent, true);
	PopUpManager.centerPopUp(msgBox);
	return msgBox;
}

/**
 * @protected
 * function for handling when the ok button pressed
 * @param event of type MouseEvent
 * @return void
 */
protected function okayBtn_clickHandler(event:MouseEvent):void
{
	
	var messageEvent:MessageBoxEvent=new MessageBoxEvent(MessageBoxEvent.MESSAGEBOX_OK);
	PopUpManager.removePopUp(this);
	if (acceptFunctionHandler != null)
		this.acceptFunctionHandler(messageEvent);
}

/**
 * @protected
 * function for handling when the cancel button pressed
 * @param event of type MouseEvent
 * @return void
 */
protected function cancelBtn_clickHandler(event:MouseEvent):void
{
	var messageEvent:MessageBoxEvent=new MessageBoxEvent(MessageBoxEvent.MESSAGEBOX_CANCEL);
	PopUpManager.removePopUp(this);
	if (declineFunctionHandler != null)
		this.declineFunctionHandler(messageEvent);
}
/**
 * @protected
 * function for handling when the yes button pressed
 * @param event of type MouseEvent
 * @return void
 */
protected function yesBtn_clickHandler(event:MouseEvent):void
{
	var messageEvent:MessageBoxEvent=new MessageBoxEvent(MessageBoxEvent.MESSAGEBOX_YES);
	PopUpManager.removePopUp(this);
	if (acceptFunctionHandler != null)
		this.acceptFunctionHandler(messageEvent);
}
/**
 * @protected
 * function for handling when the no button pressed
 * @param event of type MouseEvent
 * @return void
 */
protected function noBtn_clickHandler(event:MouseEvent):void
{
	var messageEvent:MessageBoxEvent=new MessageBoxEvent(MessageBoxEvent.MESSAGEBOX_NO);
	PopUpManager.removePopUp(this);
	if (declineFunctionHandler != null)
		this.declineFunctionHandler(messageEvent);
}
private function setSkin(event:FlexEvent):void
{
	applicationType::mobile{
		import spark.skins.mobile.ButtonSkin;
		event.target.setStyle('skinClass', spark.skins.mobile.ButtonSkin);
	}
	applicationType::DesktopWeb{
		event.target.setStyle("cornerRadius",3);
	}
}