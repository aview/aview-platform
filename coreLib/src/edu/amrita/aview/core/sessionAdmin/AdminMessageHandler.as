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
 * File			: AdminMessageHandler.as
 * Module		: SessionAdmin
 * Developer(s) : Salil George, Ramesh Guntha
 * Reviewer(s)	: Remya T
 *
 * AdminMessage is a component for sending the administrator message to the selected user
 *
 */
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

/**
 * Used to hold the selected user name
 */
private var selectedUserName:String;

/**
 *
 * @private
 * This Method is used to remove the opened AdminMessage popup
 * Called by AdminMessage close event function
 *
 *
 * @return void
 *
 */
private function closePopup():void{
	PopUpManager.removePopUp(this);
}

/**
 *
 * @private
 * This Method is used to set the selected user name
 *
 *
 * @return void
 *
 */
public function setSelectedUserName(name:String):void{
	selectedUserName=name;
}

/**
 *
 * @private
 * This Method is used to send the message to particular user by calling server side call
 * Called by adminMesgBtn click
 *
 *
 * @return void
 *
 */
private function sendAdminMessage():void{
	var strmsg:String;
	var tim:Date=new Date;
	strmsg=tim.getHours() + ":" + tim.getMinutes() + ":" + tim.getSeconds() + ":- " + adminInputMsg.text;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.call("msgFromClient", null, strmsg, selectedUserName);
	closeSendMsg();
}

/**
 *
 * @private
 * This Method is used to close AdminMessage popup after message sent
 * Called by sendAdminMessage Method
 *
 *
 * @return void
 *
 */
private function closeSendMsg():void{
	Alert.show("Message Sent", "Message");
	closePopup()
}
