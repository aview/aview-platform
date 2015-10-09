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
 * File			: CreateMeetingServersUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Swati, Abhirami, Sivaram SK
 *
 * This file is the script handler for CreateMeetingServersComp.mxml
 *
 */
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.events.MeetingServersSelectedEvent;
import edu.amrita.aview.core.gclm.vo.InstituteServerVO;
import edu.amrita.aview.core.gclm.vo.ServerVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.ComboBase;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;

import spark.components.ComboBox;

/**
 * The variable to store the label text to be displayed in the create meeting server comp
 */
[Bindable]
public var meetingServerTitle:String="Select Class Servers for the Institute ";
/**
 * The variable to store all the collaboration servers that can be used for avc meeting
 */
[Bindable]
public var allAVMCollaborationServers:ArrayCollection=new ArrayCollection();
/**
 * The variable to store all the content servers that can be used for avc meeting
 */
[Bindable]
public var allAVMContentServers:ArrayCollection=new ArrayCollection();
/**
 * The variable to store all the desktop sharing servers that can be used for avc meeting
 */
[Bindable]
public var allAVMDesktopSharingServers:ArrayCollection=new ArrayCollection();
/**
 * The variable to store all the presenter video servers that can be used for avc meeting
 */
[Bindable]
public var allAVMPresenterVideoServers:ArrayCollection=new ArrayCollection();
/**
 * The variable to store all the viewer video servers that can be used for avc meeting
 */
[Bindable]
public var allAVMViewerVideoServers:ArrayCollection=new ArrayCollection();
/**
 * The variable to store all the selected meeting servers during the previous save. For the first time this has no data
 */
[Bindable]
public var allSelectedAVMServers:ArrayCollection=new ArrayCollection();

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.CreateMeetingServersCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the creating meeting servers
 * This function is called from CreateInstituteCompUIHandler.as
 *
 * @return void
 *
 ***/
public function init():void
{
	var i:int=0;
	/**
	 * Check all the previosly selected meeting
	 * servers and put them in the against
	 * the appropriate list box based on the server type id
	 *
	 */
	//Fix for Bug#18507:Sorting is done before setting the selected meeting server(combobox's selectedIndex).
	//Fix for Bug#15038:Start
	sortComboBoxData(compAVMCollaborationServers);
	sortComboBoxData(compAVMContentServers);
	sortComboBoxData(compAVMDesktopSharingServers);
	sortComboBoxData(compAVMPresenterVideoServers);
	sortComboBoxData(compAVMViewerVideoServers);
	//Fix for Bug#15038:End
	for (i=0; i < allSelectedAVMServers.length; i++)
	{
		var obj:Object=new Object();
		obj.index=allSelectedAVMServers[i].server.serverId;
		obj.instituteServerId=allSelectedAVMServers[i].instituteServerId;
		obj.createdByUserId=allSelectedAVMServers[i].createdByUserId;
		obj.createdDate=allSelectedAVMServers[i].createdDate;
		obj.serverName=allSelectedAVMServers[i].server.serverName;
		obj.serverId=allSelectedAVMServers[i].server.serverId;
		obj.serverIp=allSelectedAVMServers[i].server.serverIp;
		obj.serverDomain=allSelectedAVMServers[i].server.serverDomain;
		//If the server type id is of type meeting collaboration, then add to the selected collaboration meeting server list
		if (allSelectedAVMServers[i].serverTypeId == ServerVO.MEETING_COLLABORATION_SERVER)
		{
			setMeetingServerIndex(compAVMCollaborationServers, allAVMCollaborationServers, obj);
		}
		//If the server type id is of type meeting content, then add to the selected content meeting server list
		else if (allSelectedAVMServers[i].serverTypeId == ServerVO.MEETING_CONTENT_SERVER)
		{
			setMeetingServerIndex(compAVMContentServers, allAVMContentServers, obj);
		}
		//If the server type id is of type meeting presenter video, then add to the selected presenter video server list
		else if (allSelectedAVMServers[i].serverTypeId == ServerVO.MEETING_PRESENTER_VIDEO)
		{
			setMeetingServerIndex(compAVMPresenterVideoServers, allAVMPresenterVideoServers, obj);
		}
		//If the server type id is of type meeting viewer video, then add to the selected viewer video server list
		else if (allSelectedAVMServers[i].serverTypeId == ServerVO.MEETING_VIEWER_VIDEO)
		{
			setMeetingServerIndex(compAVMViewerVideoServers, allAVMViewerVideoServers, obj);
		}
		//If the server type id is of type meeting desktop sharing, then add to the selected desktop sharing server list
		else if (allSelectedAVMServers[i].serverTypeId == ServerVO.MEETING_DESKTOP_SHARING_SERVER)
		{
			setMeetingServerIndex(compAVMDesktopSharingServers, allAVMDesktopSharingServers, obj);
		}
	}
	//Setting the server id as the index for each item for all servers
	for (i=0; i < allAVMCollaborationServers.length; i++)
	{
		allAVMCollaborationServers[i].index=allAVMCollaborationServers[i].serverId;
	}
	for (i=0; i < allAVMContentServers.length; i++)
	{
		allAVMContentServers[i].index=allAVMContentServers[i].serverId;
	}
	for (i=0; i < allAVMPresenterVideoServers.length; i++)
	{
		allAVMPresenterVideoServers[i].index=allAVMPresenterVideoServers[i].serverId;
	}
	for (i=0; i < allAVMViewerVideoServers.length; i++)
	{
		allAVMViewerVideoServers[i].index=allAVMViewerVideoServers[i].serverId;
	}
	for (i=0; i < allAVMDesktopSharingServers.length; i++)
	{
		allAVMDesktopSharingServers[i].index=allAVMDesktopSharingServers[i].serverId;
	}

	// If no servers are selected, then make the first server as the default selected meeting server
	/*
	if (allSelectedAVMServers.length == 0)
	{
		setMeetingServerIndex(compAVMCollaborationServers, allAVMCollaborationServers, allAVMCollaborationServers[0]);
		setMeetingServerIndex(compAVMContentServers, allAVMContentServers, allAVMContentServers[0]);
		setMeetingServerIndex(compAVMPresenterVideoServers, allAVMPresenterVideoServers, allAVMPresenterVideoServers[0]);
		setMeetingServerIndex(compAVMViewerVideoServers, allAVMViewerVideoServers, allAVMViewerVideoServers[0]);
		setMeetingServerIndex(compAVMDesktopSharingServers, allAVMDesktopSharingServers, allAVMDesktopSharingServers[0]);
	}
	*/
	
}

/**
 *
 * @private
 * This function sets the selected items from the all server list for the given combobox
 * @param comp:the combobox control for which the selected index to be set
 * @param acData:The meeting server array collection
 * @param selectedObj: The selected object by the previous operation which needs 
 * to be set as selected index
 * @return void
 *
 ***/
private function setMeetingServerIndex(comp:ComboBox, acData:ArrayCollection, selectedObj:Object):void
{
	for (var i:int=0; i < acData.length; i++)
	{
		if (acData[i].serverId == selectedObj.serverId)
		{
			comp.selectedIndex=i;
			break;
		}
	}
}

/**
 *
 * @private
 * This function is to save the selected meeting server that can be used by 
 * the institute
 *
 * @return void
 *
 ***/
private function saveMeetingServersDetails():void
{
	if(Log.isDebug()) log.debug("Coming inside save institute meeting servers");
	var i:int=0;
	//Clear all the previosly selected meeting servers
	allSelectedAVMServers.removeAll();
	//Add the newly selected servers for all the modules
	allSelectedAVMServers.addItem(ObjectUtil.copy(compAVMCollaborationServers.selectedItem));
	allSelectedAVMServers.addItem(ObjectUtil.copy(compAVMContentServers.selectedItem));
	allSelectedAVMServers.addItem(ObjectUtil.copy(compAVMDesktopSharingServers.selectedItem));
	allSelectedAVMServers.addItem(ObjectUtil.copy(compAVMPresenterVideoServers.selectedItem));
	allSelectedAVMServers.addItem(ObjectUtil.copy(compAVMViewerVideoServers.selectedItem));
	//Fix for Bug Id 3041 start	
	//Dispatch the event to inform the InstituteComp that the meeting servers have been selected
	if ((compAVMContentServers.selectedIndex >= 0) && (compAVMPresenterVideoServers.selectedIndex >= 0) && (compAVMViewerVideoServers.selectedIndex >= 0) && (compAVMCollaborationServers.selectedIndex >= 0) && (compAVMDesktopSharingServers.selectedIndex >= 0))
	{
		this.dispatchEvent(new MeetingServersSelectedEvent(MeetingServersSelectedEvent.MEETING_SERVERS_SELECTED, false, false, allSelectedAVMServers));
		closeSaveMeetingServersComp();
	}
	//Alert user when no server is selected for any of the module
	else
	{
		CustomAlert.info("Please add meeting server(s) for the institute");
	}
	//Fix for Bug Id 3041 end	
}

/**
 *
 * @private
 * This function is called when the user clicks on the Close button CreateMeetingServersComp
 *
 * @return void
 *
 ***/
private function closeSaveMeetingServersComp():void
{
	//Before closing clear the dataproviders
	if (allAVMCollaborationServers != null)
	{
		allAVMCollaborationServers.removeAll();
	}
	if (allAVMContentServers != null)
	{
		allAVMContentServers.removeAll();
	}
	if (allAVMDesktopSharingServers != null)
	{
		allAVMDesktopSharingServers.removeAll();
	}
	if (allAVMPresenterVideoServers != null)
	{
		allAVMPresenterVideoServers.removeAll();
	}
	if (allAVMViewerVideoServers != null)
	{
		allAVMViewerVideoServers.removeAll();
	}
	if(Log.isDebug()) log.debug("Removing Save Institute Meeting Servers comp");
	PopUpManager.removePopUp(this);
}
//Fix for Bug#15038:Start
private function sortComboBoxData(comboBox:ComboBox):void
{
	if ((comboBox != null ) && (comboBox.dataProvider != null) && (comboBox.dataProvider.length > 0))
	{
		var s:Sort=new Sort();
		var dataSortField:SortField = new SortField(comboBox.labelField);
		dataSortField.numeric = false;
		dataSortField.caseInsensitive = true;
		
		s.fields=[dataSortField];
		(comboBox.dataProvider as ArrayCollection).sort=s;
		(comboBox.dataProvider as ArrayCollection).refresh();
	}
}
//Fix for Bug#15038:End