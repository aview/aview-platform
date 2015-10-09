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
 * File			: ReportIssueHandler.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 *
 * // ashCR: TODO: "more issues" in? Please provide more specifics
 * file to handle more issues
 */
// ashCR: TODO: please change multi line comment to single line by using //

/**
 * Importing the utils package
 */
import com.adobe.utils.StringUtil;
/**
 * Importing the gclm package
 */
import edu.amrita.aview.core.gclm.GCLMContext;

import flash.events.Event;
import flash.events.MouseEvent;
/**
 * Importing the collections package
 */
import mx.collections.ArrayCollection;
/**
 * Importing the controls package
 */
import mx.controls.Alert;
/**
 * Importing the core package
 */
import mx.core.FlexGlobals;
/**
 * Importing the events package
 */
import mx.events.FlexEvent;

// ashCR: TODO: the following documentation is really not needed. It is very obvious for any developer
/**
 * Creating an object variable
 */
private var obj:Object=new Object();
/**
 * Creating an array collection for storing the report issues
 */
[Bindable]
private var arrModuleList:ArrayCollection=new ArrayCollection();

// ashCR: TODO: the function descriptions are a copy paste of each other. can we provide more meaningful documentation?
/**
 * @protected
 * this will update the data in the arraycollection
 *
 * @return void
 */
protected function txtIssueChangeHandler():void
{
	this.data.Issue=StringUtil.trim(txtIssue.text);
}

// ashCR: TODO: the function descriptions are a copy paste of each other. can we provide more meaningful documentation?
/**
 * @protected
 * this will update the data in the arraycollection
 *
 * @return void
 */
protected function txtDescChangeHandler():void
{
	this.data.Desc=StringUtil.trim(txtDesc.text);

}

// ashCR: TODO: the function descriptions are a copy paste of each other. can we provide more meaningful documentation?
/**
 * @protected
 * this will update the data in the arraycollection
 *
 * @return void
 */
protected function cmbModuleChangeHandler():void
{
	if (cmbModuleName.selectedIndex != -1)
	{
		this.data.ModuleID=cmbModuleName.selectedItem.moduleId;
		this.data.ModuleName=cmbModuleName.selectedItem.moduleName;
		
	}
	else
	{
		this.data.ModuleID=0;
		this.data.ModuleName='';
	}
}

/**
 * @protected
 * For creating report issue UI
 *
 * @param event type  MouseEvent
 * @return void
 */
protected function addReportIssue(event:MouseEvent):void
{
	var status:Boolean=false;
	if (cmbModuleName.selectedItem != null)
	{
//ashCR: TODO: is it possible to mode the hard coded string to configuration? In case the string needs a change in future
//ashCR: TODO: a code change will not be needed, but only a config change.
		
		//it will check the components are null or not before creating an UI
		if (cmbModuleName.selectedItem.moduleName == '' || cmbModuleName.selectedItem.moduleName == 'None')
			Alert.show("Please select the affected module", "Error");
		else if (StringUtil.trim(txtIssue.text) == '')
			Alert.show("Please enter the issue", "Error");
		else
		{
			
			btnAddIssue.visible=false;
			btnAddIssue.includeInLayout=false;
			btnRemoveIssue.visible=true;
			btnRemoveIssue.includeInLayout=true;
			this.data.showAddButton=false;
			this.data.showRemoveButton=true;
			ruler.visible=true;
			ruler.includeInLayout=true;
			//the addIssueComp event will dispatch from here and it will catch in the Feedbackform
			this.dispatchEvent(new Event('addIssueComp', true, false));
			//the setScrollPosition event will dispatch from here and it will catch in the Feedbackform
			this.dispatchEvent(new Event('setScrollPosition', true, false));
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.feedback.flagScroll=true;
		}
	}
	else
	{
		Alert.show("Please select the affected module", "Error");
		var tempModuleObj:Object=new Object();
		
		tempModuleObj.mName='';
		tempModuleObj.mID='';
		tempModuleObj.titleIssue='';
		tempModuleObj.reportDesc='';
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.feedback.arrModuleList.addItem(tempModuleObj);
	}

}

/**
 * @protected
 * For removing the selected report issue
 *
 * @param event type MouseEvent
 * @return void
 */
protected function removeReportIssue(event:MouseEvent):void
{
	//the removeIssueComp event will dispatch from here and it will catch in the Feedbackform
	this.dispatchEvent(new Event('removeIssueComp', true, false));
	this.data.showAddButton=true;
	this.data.showRemoveButton=false;
}

/**
 * @protected
 * This function will add the item to the array collection
 *
 * @param event type FlexEvent
 * @return void
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	var objModule:Object=new Object();
	objModule.moduleId=0;
	objModule.moduleName="None";
	
	arrModuleList.addItem(objModule);
	for (var i:int=0; i < GCLMContext.modulesAC.length; i++)
	{
		arrModuleList.addItem(GCLMContext.modulesAC[i]);
	}

}
