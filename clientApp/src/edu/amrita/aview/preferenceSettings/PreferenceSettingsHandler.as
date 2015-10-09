// ActionScript file
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.preferenceSettings.VideoLayout;


import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

public var prefSetVid:VideoLayout;
/**
 * Variable for storing the status of desktop sharing video color quality is changed or not
 */
public var videoQualityChange:Boolean=false;
/**
 * Variable for storing the status of preference settings window is open or not
 */
public var preferenceSettingsPopup:Boolean=false;
public var moduleName:String = '';
/**
 * for settings the values from the shared object at the time of creating the popup window
 * @return void
 */
protected function initPreferenceSettings(event:FlexEvent):void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.muiInteractionflag=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isMUISelected;

	usersettingsHandler();

	setPreferenceQuestion(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionInteractionStatus);
	//Fix for issue #15819
	setPreferenceUninterruptedDesktopSharing(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON());
	//For default color quality of desktop sharing video
	prefDesk.videoQualityList.selectedIndex = 0;
	if(moduleName =='video')
	{
		userSettingsContainer.enabled=false;
		desktopSharingContainer.enabled=false;
		questionInterfaceContainer.enabled=false;
		videoLayoutHandler();
	}
	else
	{
		userSettingsContainer.enabled=true;
		desktopSharingContainer.enabled=true;
		questionInterfaceContainer.enabled=true;
	}
}

/**
 * for removing the popup instance
 * @return void
 */
public function removeMe():void
{	
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.interactionStatusChanged)
	{		
		prefQuest.chkBoxQuestionInteraction.selected=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionInitialInteractionStatus;
	}	
	PopUpManager.removePopUp(this);
	preferenceSettingsPopup = false;
}
/**
 * for saving the settings to the shared values 
 * @return void
 */
public function saveHandler():void
{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON() != this.prefDesk.chkBoxDesktopSharingInteraction.selected)
	{
		applicationType::desktop{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setUninterruptedDesktopSharingStatusToCollabObject();
		}
		applicationType::web{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.setUninterruptedDesktopSharingStatusToCollabObject();
		}
	}
	var currentLayout:String;
	if (vidLayout.rbgLayout.selectedValue.toString() == vidLayout.rbSimple.label)
	{
		currentLayout=Constants.SIMPLE_LAYOUT;
	}
	else if (vidLayout.rbgLayout.selectedValue.toString() == vidLayout.rbDiscussion.label)
	{
		currentLayout=Constants.MEETING_LAYOUT;
	}
	else if (vidLayout.rbgLayout.selectedValue.toString() == vidLayout.rbPresentation.label)
	{
		currentLayout=Constants.PRESENTER_LAYOUT;
	}
	if (currentLayout != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.layoutSelectionChange();
	}
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.userLstSortFlag != userSet.chkBoxUserSorting.selected)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.userLstSortFlag=userSet.chkBoxUserSorting.selected;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.sortUserList();
	}

	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.muiInteractionflag != userSet.chkBoxMultiUserInteraction.selected)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.muiInteractionflag=userSet.chkBoxMultiUserInteraction.selected;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.changeMUIMode(userSet.chkBoxMultiUserInteraction.selected);
	}
		if(userSet.chkBoxPeopleCount.selected)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.peopleCountFlag = true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.chkPeopleCount.selected=true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatus.headerText='PC';
		}
		else
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.chkPeopleCount.selected=false;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.peopleCountFlag = false;
			if(ClassroomContext.userVO.role!=Constants.MONITOR_TYPE)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatus.headerText='IC';
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.lstUsers.countStatus.headerText='MC';
			}
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.sortUserList();
	
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionFlag != prefQuest.chkBoxQuestionInteraction.selected)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.interactionStatusChanged=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionInteractionStatus=prefQuest.chkBoxQuestionInteraction.selected;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionFlag=prefQuest.chkBoxQuestionInteraction.selected;
		//bugFix : #15222
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionButtons.breakSessionObj.questionAnswerEnabledState=prefQuest.chkBoxQuestionInteraction.selected;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.setQuestionInteraction(prefQuest.chkBoxQuestionInteraction.selected);	
	}
	//Fix for #18553
	if(videoQualityChange)
	{
		applicationType::DesktopWeb{
			//Fix for issue #17747
			applicationType::web{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isDesktopSharingStarted){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.screenPublisher.stopScreenSharing();
					setTimeout(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.screenPublisher.callStartSharing,1500);
				}
				//Assign selected desktop color quality to combobox in sharing window
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex != prefDesk.videoQualityList.selectedIndex) {
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex = prefDesk.videoQualityList.selectedIndex;
				}
			}
			//Fix for issue #19023
			applicationType::desktop{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isDesktopSharingStarted){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.click_Conso_Desktop();
				}
				//Assign selected desktop color quality to combobox in sharing window
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex != prefDesk.videoQualityList.selectedIndex) {
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex = prefDesk.videoQualityList.selectedIndex;
				}
			}
			//For color quality setting of desktop sharing video
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setDesktopSharingScreenQualityToCollabObject();
		}
	}
	removeMe();
}
//Fix for #18553
/**
 * @public
 * This function sets the value to videoQualityChange for identifying whether the desktop sharing color quality is changed
 *
 * @return void
 */
public function colorQualityChangeEvent():void
{
	if(!preferenceSettingsPopup && prefDesk != null) {
		prefDesk.videoQualityList.selectedIndex = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setDesktopSharingScreenQualityToCollabObject();
	}
	else if(prefDesk == null) {
		var obj:Object=new Object;
		obj.index=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex;
		obj.quality=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.colorQualityOption[FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex].value;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex == "0") {
			obj.videoQuality = " ";
		}
		else {
			obj.videoQuality = "bitrate:"+obj.quality;
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.setValue("desktopColorQuality", obj);
	}
	videoQualityChange = true;
}

/**
 * @public
 * This function sets the preference list (toggle switch) to indicate if the Question & Answer feature is enabled / disabled
 *
 * @param boolean
 * @return void
 */
public function setPreferenceQuestion(questionBoolean:Boolean):void
{
	prefQuest.chkBoxQuestionInteraction.selected=questionBoolean;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionFlag=questionBoolean;
}
/**
 * @public
 * This function sets the preference list (toggle switch) to indicate if the Uninterrupted Desktop sharing feature is enabled / disabled
 *
 * @param boolean
 * @return void
 */
public function setPreferenceUninterruptedDesktopSharing(unInterruptedDesktopSharingBoolean:Boolean):void
{
	//BUGFIX API. checking for null value. Its required a delay to initialize value.
	if (prefDesk!=null) prefDesk.chkBoxDesktopSharingInteraction.selected=unInterruptedDesktopSharingBoolean;
}
/**
 * 
 * For changing the selection styles of the usersettings menu list 
 * @return void 
 */
public function usersettingsHandler():void
{
	userSettingsContainer.width=180;
	videoLayoutContainer.width=164;
	desktopSharingContainer.width=164;
	questionInterfaceContainer.width=164;
	preferenceTab.selectedIndex=0;
	videoLayoutContainer.setStyle("backgroundColor", '#b6dcfa');
	desktopSharingContainer.setStyle("backgroundColor", '#b6dcfa');
	questionInterfaceContainer.setStyle("backgroundColor", '#b6dcfa');
	userSettingsContainer.setStyle("backgroundColor", '#e1effa');
}
/**
 * 
 * For changing the selection styles of the videolayout menu list 
 * @return void 
 */
public function videoLayoutHandler():void
{
	videoLayoutContainer.width=180;
	userSettingsContainer.width=164;
	desktopSharingContainer.width=164;
	questionInterfaceContainer.width=164;
	preferenceTab.selectedIndex=1;
	userSettingsContainer.setStyle("backgroundColor", '#b6dcfa');
	desktopSharingContainer.setStyle("backgroundColor", '#b6dcfa');
	questionInterfaceContainer.setStyle("backgroundColor", '#b6dcfa');
	videoLayoutContainer.setStyle("backgroundColor", '#e1effa');
}
/**
 * 
 * For changing the selection styles of the desktop menu list 
 * @return void 
 */
protected function desktopHandler():void
{
	desktopSharingContainer.width=180;
	userSettingsContainer.width=164;
	videoLayoutContainer.width=164;
	questionInterfaceContainer.width=164;
	preferenceTab.selectedIndex=2;
	userSettingsContainer.setStyle("backgroundColor", '#b6dcfa');
	videoLayoutContainer.setStyle("backgroundColor", '#b6dcfa');
	questionInterfaceContainer.setStyle("backgroundColor", '#b6dcfa');
	desktopSharingContainer.setStyle("backgroundColor", '#e1effa');
	prefDesk.lblColorQualityDescription.width = 360;
	prefDesk.hgColorQualitySettings.height = 25;
	//Fix for issue #17659
    if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.getData()["desktopColorQuality"] != undefined)
	{
		//Assign value to combobox
		prefDesk.videoQualityList.selectedIndex = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingCollabObject.getData()["desktopColorQuality"].index;
	}
	else
	{
		prefDesk.videoQualityList.selectedIndex = 0;
	}
	if(prefDesk.videoQualityList.selectedIndex != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex) {
		prefDesk.videoQualityList.selectedIndex = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setDesktopSharingScreenQualityToCollabObject();
	}
	setPreferenceUninterruptedDesktopSharing(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON());
}
/**
 * 
 * For changing the selection styles of the question menu list 
 * @return void 
 */
protected function questionHandler():void
{
	questionInterfaceContainer.width=180;
	userSettingsContainer.width=164;
	videoLayoutContainer.width=164;
	desktopSharingContainer.width=164;
	preferenceTab.selectedIndex=3;
	userSettingsContainer.setStyle("backgroundColor", '#b6dcfa');
	videoLayoutContainer.setStyle("backgroundColor", '#b6dcfa');
	desktopSharingContainer.setStyle("backgroundColor", '#b6dcfa');
	questionInterfaceContainer.setStyle("backgroundColor", '#e1effa');
}
