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
 * File			: CreateInstituteServersUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Swati, Sivaram SK
 *
 * This file is the script handler for CreateInstituteServersComp.mxml
 *
 */
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.events.InstituteServersSelectedEvent;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.vo.InstituteServerVO;
import edu.amrita.aview.core.gclm.vo.ServerVO;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;

import mx.core.FlexGlobals;
/**
 * The variable used to label the window
 */
[Bindable]
public var instituteServerTitle:String="Select Class Servers for the Institute ";
/**
 * To store all data servers
 */
[Bindable]
public var allDataServers:ArrayCollection=new ArrayCollection();
/**
 * To store the selected data servers
 */
[Bindable]
public var selectedDataServers:ArrayCollection=new ArrayCollection();
/**
 * To store all content servers
 */
[Bindable]
public var allContentServers:ArrayCollection=new ArrayCollection();
/**
 * To store the selected content servers
 */
[Bindable]
public var selectedContentServers:ArrayCollection=new ArrayCollection();
/**
 * To store all desktop sharing servers
 */
[Bindable]
public var allDesktopSharingServers:ArrayCollection=new ArrayCollection();
/**
 * To store the selected desktop sharing servers
 */
[Bindable]
public var selectedDesktopSharingServers:ArrayCollection=new ArrayCollection();
/**
 * To store all presenter video servers
 */
[Bindable]
public var allPresenterVideoServers:ArrayCollection=new ArrayCollection();
/**
 * To store the selected presenter video servers
 */
[Bindable]
public var selectedPresenterVideoServers:ArrayCollection=new ArrayCollection();
/**
 * To store all viewer video servers
 */
[Bindable]
public var allPresenterViewerServers:ArrayCollection=new ArrayCollection();
/**
 * To store the selected viewer video servers
 */
[Bindable]
public var selectedViewerVideoServers:ArrayCollection=new ArrayCollection();
/**
 * To store all selected servers
 */
[Bindable]
public var allSelectedServers:ArrayCollection=new ArrayCollection();

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.CreateInstituteServersCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the creating institute servers
 * This function is called from CreateInstituteCompUIHandler.as
 *
 * @return void
 *
 ***/
public function init():void
{
	var i:int=0;
	//If there is already servers selected for the institute assign them in the 
	//selected servers list box
	for (i=0; i < allSelectedServers.length; i++)
	{
		var obj:Object=new Object();
		obj.index=allSelectedServers[i].server.serverId;
		obj.instituteServerId=allSelectedServers[i].instituteServerId;
		obj.createdByUserId=allSelectedServers[i].createdByUserId;
		obj.createdDate=allSelectedServers[i].createdDate;
		obj.serverName=allSelectedServers[i].server.serverName;
		obj.serverId=allSelectedServers[i].server.serverId;
		obj.serverIp=allSelectedServers[i].server.serverIp;
		obj.serverDomain=allSelectedServers[i].server.serverDomain;
		//If the server type id is of data server, then add to the selected classroom data server
		if (allSelectedServers[i].serverTypeId == ServerVO.FM_DATA_SERVER_TYPE)
		{
			selectedDataServers.addItem(obj);
		}
		//If the server type id is of content server, then add to the selected classroom content server
		else if (allSelectedServers[i].serverTypeId == ServerVO.CONTENT_SERVER_TYPE)
		{
			selectedContentServers.addItem(obj);
		}
		//If the server type id is of desktop sharing server, then add to the selected classroom desktop sharing server
		else if (allSelectedServers[i].serverTypeId == ServerVO.FM_DESKTOP_SHARING_TYPE)
		{
			selectedDesktopSharingServers.addItem(obj);
		}
		//If the server type id is of presenter video server, then add to the selected presenter video server
		else if (allSelectedServers[i].serverTypeId == ServerVO.FM_VIDEO_PRESENTER_TYPE)
		{
			selectedPresenterVideoServers.addItem(obj);
		}
		//If the server type id is of viewer video server, then add to the selected viewer video server
		else if (allSelectedServers[i].serverTypeId == ServerVO.FM_VIDEO_VIEWER_TYPE)
		{
			selectedViewerVideoServers.addItem(obj);
		}
	}
	//Set the index for all servers with the server id
	for (i=0; i < allDataServers.length; i++)
	{
		allDataServers[i].index=allDataServers[i].serverId;
	}
	for (i=0; i < allContentServers.length; i++)
	{
		allContentServers[i].index=allContentServers[i].serverId;
	}
	for (i=0; i < allDesktopSharingServers.length; i++)
	{
		allDesktopSharingServers[i].index=allDesktopSharingServers[i].serverId;
	}
	for (i=0; i < allPresenterVideoServers.length; i++)
	{
		allPresenterVideoServers[i].index=allPresenterVideoServers[i].serverId;
	}
	for (i=0; i < allPresenterViewerServers.length; i++)
	{
		allPresenterViewerServers[i].index=allPresenterViewerServers[i].serverId;
	}

	//Bug fix for throwing the creation complete event
	compDataServers.dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
	compContentServers.dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
	compDesktopServers.dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
	compViewerServers.dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
	compPresenterServers.dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
}

/**
 *
 * @private
 * This function is used to save the selected servers for the institute
 *
 * @return void
 *
 ***/
private function saveInstituteServersDetails():void
{
	if(Log.isDebug()) log.debug("Coming inside save institute admins");
	//Remove the previously available server
	allSelectedServers.removeAll();
	//Copy the different servers that is selected for the institute
	allSelectedServers.addItem(ObjectUtil.copy(compDataServers.selectedDataAC) as ArrayCollection);
	allSelectedServers.addItem(ObjectUtil.copy(compContentServers.selectedDataAC) as ArrayCollection);
	allSelectedServers.addItem(ObjectUtil.copy(compDesktopServers.selectedDataAC) as ArrayCollection);
	allSelectedServers.addItem(ObjectUtil.copy(compPresenterServers.selectedDataAC) as ArrayCollection);
	allSelectedServers.addItem(ObjectUtil.copy(compViewerServers.selectedDataAC) as ArrayCollection);
	//Fix for Bug Id 3041 start	
	//Once the servers are selected throw an event so that CreateInstituteCompUIHandler will take care from then
	if ((compDataServers.selectedDataAC.length > 0) && (compContentServers.selectedDataAC.length > 0) && (compDesktopServers.selectedDataAC.length > 0) && (compPresenterServers.selectedDataAC.length > 0) && (compViewerServers.selectedDataAC.length > 0))
	{
		this.dispatchEvent(new InstituteServersSelectedEvent(InstituteServersSelectedEvent.INSTITUTE_SERVERS_SELECTED, false, false, allSelectedServers));
		closeSaveInstituteServersComp();
	}
	//If servers are not selected for atleast one module type, alert the user
	else
	{
		CustomAlert.info("Please add server(s) for the institute");
	}
	//Fix for Bug Id 3041 end
}

/**
 *
 * @private
 * This function is used to close the CreateInstituteServersComp window
 *
 * @return void
 *
 ***/
private function closeSaveInstituteServersComp():void
{
	// Before closing the window, clear all the data
	if (allDataServers != null)
	{
		allDataServers.removeAll();
	}
	if (allContentServers != null)
	{
		allContentServers.removeAll();
	}
	if (allDesktopSharingServers != null)
	{
		allDesktopSharingServers.removeAll();
	}
	if (allPresenterVideoServers != null)
	{
		allPresenterVideoServers.removeAll();
	}
	if (allPresenterViewerServers != null)
	{
		allPresenterViewerServers.removeAll();
	}

	if (selectedDataServers != null)
	{
		selectedDataServers.removeAll();
	}
	if (selectedContentServers != null)
	{
		selectedContentServers.removeAll();
	}
	if (selectedPresenterVideoServers != null)
	{
		selectedPresenterVideoServers.removeAll();
	}
	if (selectedViewerVideoServers != null)
	{
		selectedViewerVideoServers.removeAll();
	}
	if (selectedDesktopSharingServers != null)
	{
		selectedDesktopSharingServers.removeAll();
	}
	if(Log.isDebug()) log.debug("Removing Save Institute Admin comp");
	PopUpManager.removePopUp(this);
}
