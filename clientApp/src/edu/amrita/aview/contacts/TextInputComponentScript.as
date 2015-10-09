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
 * File		   : TextInputComponent.as
 * Module	   : contacts
 * Developer(s): NidhiSarasan,Soumya M.D
 * Reviewer(s) : Bri.Radha
 *
 *  This code is used to Add groups,Edit Groups and Add meeting Subject
 *
 */
import edu.amrita.aview.contacts.TextInputCustomEvent;

import mx.managers.PopUpManager;

/**
 * variable to store the actions like add group,edit group and add meeting subject.
 */
[Bindable]
private var action:String;

/**
 * @protected
 * Click on ok will dispatch an event and
 * done the appropriate work based on the action.
 * (Add groups,Edit Groups,Add meeting Subject)
 * @return void 
 */
protected function okHandler():void
{
	if (this.txtTitle.text != "")
	{
		var txtName:String=this.txtTitle.text;
		this.dispatchEvent(new TextInputCustomEvent(action, txtName));
	}
	PopUpManager.removePopUp(this);
}

/**
 * @protected
 * Remove the TextInputComponent
 * @return void 
 */
protected function cancelHandler():void
{
	PopUpManager.removePopUp(this);
}

/**
 * @protected
 * Describes the title,action,label and value for ech action.
 * That is for add group,edit group and add meeting subject.
 *
 * @param title of type String
 * @param action of type String
 * @param label of type String
 * @param value of type Object
 * @return void
 */

public function setProperties(title:String, action:String, label:String, value:String):void
{
	this.lblTitle.text=label;
	this.nameTitle.text=title;
	this.txtTitle.text=value;
	this.action=action;
}
