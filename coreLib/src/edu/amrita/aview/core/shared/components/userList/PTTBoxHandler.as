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
 * File			: PTTBoxHandler.as
 * Module		: Common
 * Developer(s)	: Ravi Sankar
 * Reviewer(s)	: Veena Gopal K.V
 *
 * 
 */
//VGCR:-Description for bindable variables
//VGCR:-Variable Description
//VGCR:-Function Description
import edu.amrita.aview.core.shared.components.userList.CRActionButtons;

import mx.core.FlexGlobals;

[Bindable]
public var pttCheckBoxState:Boolean=false;


[Bindable]
public var btnFreeTalkVisible:Boolean=false;

[Bindable]
public var btnMuteVisible:Boolean=false;

[Bindable]
public var btnTalkVisible:Boolean=false;


private var actionButtons:CRActionButtons;


/**
 * @public
 * @param actionButtons of type CRActionButtons
 * 
 */
public function init(actionButtons:CRActionButtons):void
{
	this.actionButtons = actionButtons;
}
