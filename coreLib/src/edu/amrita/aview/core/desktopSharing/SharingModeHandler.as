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
 * File			: SharingModeHandler.as
 * Module		: DesktopSharing
 * Developer(s)	: Ajith Kumar R, Remya T
 * Reviewer(s)	: Meena S
 *
 *SharingModeHandler.as is used to handle functionalities related to SharingMode custom component.
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;

/**
 * Variable for storing the sharing mode (Desktop/Application).
 */
[Bindable]
private var sharingModes:ArrayList=new ArrayList([{shareName: 'Screen Area'}, {shareName: 'Application'}]);
/**
 * Alert variable for showing option selection information.
 */
public var infoAlert:Alert;
/**
 * @private
 * The function for creating the SharingMode popup.
 *
 *
 * @return void
 */
private function init():void{
	//Bug #14723
	if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
	{
		if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.getData()["unInterruptedDesktopSharing"])
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.setValue("unInterruptedDesktopSharing", "OFF");
		//Fix for issue #15864
		if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.getData()["desktopSharing"]){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.sendDesktopSharingStatus("stopped");
		}
		//To add Desktop setting component from preference settings
		hgDesktopSharingSettings.addElement(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.hgSharingColorQuality);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.hgSharingColorQuality.width="455";
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.lblDesktopQuality.text = "Desktop Sharing Quality:";
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.hgColorQualityDescription.paddingLeft = "20";
		//Assign desktop color quality from shared object
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.getData()["desktopColorQuality"] != undefined)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.getData()["desktopColorQuality"].index;
		}
		else
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex = 0;
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedSharingMode = rbgSelectedSharingMode.selectedValue.toString();
	}
}

/**
 * @private
 * The function for select desktop/application sharing.
 *
 *
 * @return void
 */
private function handleSharingMode(event:ItemClickEvent):void{
	//Fix for issue #16267
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedSharingMode=event.index;
				if (event.index == 0){
					if (vgContainer.containsElement(hgOptionsContainer))
					{
						if(hgOptionsContainer.numChildren != 0)
						{
							hgOptionsContainer.removeAllElements();
						}
						vgContainer.removeElement(hgOptionsContainer);
						//Fix for issue #5219
						lblNote.visible = false;
						lblNote.includeInLayout = false;
						lblSharingDescription.visible = true;
						lblSharingDescription.text = "This mode will share the entire desktop screen with all.";
						lblSharingDescription.includeInLayout = true;
						//Fix for issue #15317
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopApplicationSharing();
					}
				}
				else if (event.index == 1){
					vgContainer.addElementAt(hgOptionsContainer, 1);
					//Fix for issue #5219
					lblNote.visible = true;
					lblNote.includeInLayout = true;
					lblSharingDescription.visible = true;
					lblSharingDescription.text = "This mode will share only the selected running application(s),"
						+ " you may select the application(s) from the below list.";
					lblSharingDescription.includeInLayout = true;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initApplicationSharing();
					//Fix for issue #15919  and #16268
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.createActiveApplicationListPopUp();
				}
		}
	}
	else{
		MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
	}		
	//Fix for issue #15823
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection == null){
		event.index = 0;
	}
}


/**
 * @public
 * The function for initiating desktop/application sharing.
 *
 *
 * @return void
 */
public function callStartSharing():void
{
		//Fix for issue #15316
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedSharingMode == 1){
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpDisplay.appList.selectedItems.length == 0){
				infoAlert=Alert.show("Please select the application(s) you want to share.", "Information");	
				return;
			}
			else{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callDesktopSharing();
			}
		}
		else{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callDesktopSharing();
		}
}

/**
 * @private
 * KeyboardEvent handler function for OK button in ActiveApplicationList popup.
 *
 * @param event of type KeyboardEvent
 * @return void
 */
private function okButtonKeyBoardStrokeHandler(event:KeyboardEvent):void{
	//If 'Enter' button or 'Space' button is pressed then call callStartSharing function for start streaming
	if ((event.keyCode == Keyboard.ENTER) || (event.keyCode == Keyboard.SPACE)){
		//Fix for issue #15316
		callStartSharing();
		event.stopImmediatePropagation();
	}
}
