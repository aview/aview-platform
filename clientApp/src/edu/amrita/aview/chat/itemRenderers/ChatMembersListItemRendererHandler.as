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
 * File			: ChatMembersListItemRendererHandler.as
 * Module		: chat
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Bri.Radha,Vishnupreethi K
 *
 * This is the item renderer for the ChatMembersList in MyContacts.mxml.
 * Display checkbox,username,instituteName and status icon.
 *
 */
import edu.amrita.aview.core.entry.Constants;

import flash.events.Event;

/** icon for online users */
[Bindable]
[Embed(source="../assets/images/offline.png")]
public var userOffline:Class;

/** icon for offline users */
[Bindable]
[Embed(source="../assets/images/online.png")]
public var userActive:Class;
/** class for showing status icon */
[Bindable]
public var iconStatus:Class=userOffline;


/**
 * @private
 * change user status
 *
 *
 * @return void
 *
 */
private function changeUserStatus():void
{
	if (this.data == null)
	{
		return;
	}
	/**if status of user is online, the icon is userActive icon
	*if status of user is offline, the icon is userOffline icon
    */
	switch(this.data.member.userStatus)
	{
		case Constants.ONLINE:
		{
			iconStatus = userActive;
			break;
		}
		case Constants.OFFLINE:
		{
			iconStatus = userOffline;
			break;
		}
		default:
		{
			iconStatus = userOffline;
		}
	}
}
