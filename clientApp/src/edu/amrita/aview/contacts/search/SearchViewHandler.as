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
 * File			: SearchViewHandler.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Bri.Radha
 *
 * This is used to search users for adding to the group
 * Search is done mainly with name.
 * check all the fields(name,username,institute,mail id,phone no)are non empty.
 *
 */

import edu.amrita.aview.common.util.ArrayCollectionUtil;
import edu.amrita.aview.contacts.events.ContactsEvent;
import edu.amrita.aview.contacts.events.SearchEvent;
import edu.amrita.aview.contacts.helper.GroupUserHelper;
import edu.amrita.aview.contacts.search.SearchModel;
import edu.amrita.aview.contacts.vo.GroupVO;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.UserVO;
import edu.amrita.aview.meeting.events.CommonEvent;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

[Bindable]
public var searchModel:SearchModel=null;
/**
 * Get all institutes on init
 */
private function init():void
{	
	this.addEventListener(CloseEvent.CLOSE,closeAddUserWindow);
}


/** update user status */
//TODO:MediaServerConnection status handler	

private function closeAddUserWindow(event:Event):void
{
	PopUpManager.removePopUp(this);
}
//---START----------------------------------------
/** Search users */
protected function search():void
{
	if(StringUtil.trim(txtname.text) == "" && StringUtil.trim(txtuserName.text) == "" && StringUtil.trim(txtemailid.text) =="" && 
		txtinstitute.selectedItem == null && StringUtil.trim(txtphoneno.text) =="" &&
		cmbState.selectedItem == null)
	{
		Alert.show("Please enter any one of the field","Alert");
		txtname.text = "";
		txtuserName.text = "";
		txtemailid.text = "";
		txtphoneno.text = "";
	}
	else
	{
		btnSearch.enabled = false;
		searchModel.fName = StringUtil.trim(txtname.text);
		searchModel.lName = StringUtil.trim(txtname.text);
		searchModel.userName = StringUtil.trim(txtuserName.text);
		searchModel.email = StringUtil.trim(txtemailid.text);
		if(txtinstitute.selectedItem)
		{
			var institute:Object = txtinstitute.selectedItem;
			searchModel.instituteId = institute.instituteId;
		}
		else
		{
			searchModel.instituteId=0;
		}
		if(cmbState.selectedItem)
		{
			var state : Object = cmbState.selectedItem;
			searchModel.stateId = state.stateId;
		}
		else
		{
			searchModel.stateId = 0;
		}
		searchModel.phoneNumber = StringUtil.trim(txtphoneno.text);
		if(StringUtil.trim(txtuserName.text)!=null)
		{
			this.dispatchEvent(new SearchEvent(SearchEvent.SEARCH_EVENT,searchModel));
		}
		else
		{
			Alert.show("Please fill the name field for Search","WARNING");
		}
	}
}




