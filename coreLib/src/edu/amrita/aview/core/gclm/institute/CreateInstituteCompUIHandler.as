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
 * File			: CreateInstituteCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Swati, Sivaram SK
 *
 * This file is the script handler for CreateInstituteServersComp.mxml
 *
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.events.InstituteAdminsSelectedEvent;
import edu.amrita.aview.core.gclm.events.InstituteBrandingSelectedEvent;
import edu.amrita.aview.core.gclm.events.InstituteServersSelectedEvent;
import edu.amrita.aview.core.gclm.events.MeetingServersSelectedEvent;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.gclm.institute.CreateInstituteAdminsComp;
import edu.amrita.aview.core.gclm.institute.CreateInstituteBranding;
import edu.amrita.aview.core.gclm.institute.CreateInstituteServersComp;
import edu.amrita.aview.core.gclm.institute.CreateMeetingServersComp;
import edu.amrita.aview.core.gclm.vo.InstituteAdminUserVO;
import edu.amrita.aview.core.gclm.vo.InstituteBrandingVO;
import edu.amrita.aview.core.gclm.vo.InstituteServerVO;
import edu.amrita.aview.core.gclm.vo.InstituteVO;
import edu.amrita.aview.core.gclm.vo.ServerVO;
import edu.amrita.aview.core.gclm.vo.UserVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.vo.StatusVO;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

/**
 * To store all the parent institutes
 */
[Bindable]
public var parentInstitutes:ArrayCollection=new ArrayCollection();
/**
 * To store all the selected institute administrators
 */
[Bindable]
public var selectedInstituteAdminUsers:ArrayCollection=new ArrayCollection();
/**
 * To store all the selected servers for the institute
 */
[Bindable]
public var selectedInstituteServers:ArrayCollection=new ArrayCollection();
/**
 * To store all the selected meeting servers for the institute
 */
[Bindable]
public var selectedInstituteMeetingServers:ArrayCollection=new ArrayCollection();
/**
 * To store all the admin users for the institute
 */
[Bindable]
public var instituteAdminUsers:ArrayCollection=new ArrayCollection();
/**
 * To store all the meeting servers for the institute
 */
[Bindable]
public var instituteServers:ArrayCollection=new ArrayCollection();
/**
 *  To store the bandwidth info for selecting the minimum bandwidth that can be used for the class 
 */
[Bindable]
private var minimumPublishingBandwidths:ArrayCollection=new ArrayCollection();
/**
 *  To store the bandwidth info for selecting the maximum receiving bandwidth that can be used for the class 
 */
[Bindable]
private var maximumReceivingBandwidths:ArrayCollection=new ArrayCollection();

/**
 *  To store the bandwidth info for selecting the maximum bandwidth that can be used for the class 
 */
[Bindable]
private var maximimPublishingBandwidths:ArrayCollection=new ArrayCollection();
/**
 *  The minimum bandwidth for streaming for the class by the administrator 
 */
private var minBandwidthForPublish:Object=new Object();
/**
 *  The maximum receiving  bandwidth for streaming for the class by the administrator 
 */
private var maxReceivingBandwidthForPublish:Object=new Object();

/**
 *  The maximum bandwidth for streaming for the class by the administrator 
 * */
private var maxBandwidthForPublish:Object=new Object();
/**
 *  To store the selected bandwidths for video streaming 
 */
[Bindable]
private var bandwidthsSelectedForStreaming:ArrayCollection=new ArrayCollection();
/**
 * To keep track of the cancel button click event
 */
public var hasClickedCancelButton:Boolean;
/**
 * To store the newly created institute
 */
public var newInstituteVO:InstituteVO=null;
/**
 * The different institute types while creating
 */
[Bindable]
private var instituteTypeArray:Array=new Array("Select", "College", "University", "Organization", "School");
/**
 * To enable/disable Add Admin button
 */
[Bindable]
private var hasEnabledAddAdminButton:Boolean=false;
/**
 * To enable/disable Add Branding button
 */
[Bindable]
private var hasEnableAddBrandingButton:Boolean=false;
/**
 *  To store all the bandwidths available for selection for video streaming 
 */
[Bindable]
private var allAvailableBandwidths:ArrayCollection=new ArrayCollection();
/**
 *  To check whether institute is selected or not
 */
[Bindable]
private var hasSelectedInstitute:Boolean=false;
/**
 * To store the selected institute for update
 */
private var institute:InstituteVO;
/**
 * The error message to display for user during validation
 */
private var errorMessage:String="";
/**
 * The helper class to communicate with the Server
 */
private var instituteHelper:InstituteHelper=null;
/**
 *  Variable to set default prompt. 
 * */
private var defaultPrompt:Object=new Object();
/**
 *  To store the bandwidths still available for video streaming 
 */
[Bindable]
private var bandwidthsStillAvailableForSelection:ArrayCollection=new ArrayCollection();

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.CreateInstituteCompUIHandler.as");

/**
 * All the events used by this component
 *
 */
[Event(type="events.InstituteAdminsSelectedEvent", name="instituteadminsselected")]
[Event(type="events.InstituteServersSelectedEvent", name="instituteaserversselected")]
[Event(type="events.MeetingServersSelectedEvent", name="meetingserversselected")]

/**
 *
 * @public
 * This function sets all the initial info required for the CreateInstituteComp
 * This function is called from InstituteCompUIHandler.as
 * @param institute : The institute details to update. For create this will be null
 * @return void
 *
 ***/
public function init(instituteToEdit:InstituteVO=null):void
{
	instituteHelper=new InstituteHelper();
	hasSelectedInstitute=false;	
	hasClickedCancelButton=true;
	this.institute=new InstituteVO();
	var obj:Object;
	defaultPrompt=new Object();
	defaultPrompt.index=0;
	defaultPrompt.value="Select";
	// Commented for new UI change , to select bandwidth
	allAvailableBandwidths.addItem(defaultPrompt);
	minimumPublishingBandwidths.addItem(defaultPrompt);
	//maximumReceivingBandwidths.addItem(defaultPrompt);
	maximimPublishingBandwidths.addItem(defaultPrompt);
	for (var i:int=0; i < Constants.availableVideoPublishingBandwidths.length; i++)
	{
		obj=new Object();
		obj.index=Constants.availableVideoPublishingBandwidths[i].index;
		obj.value=Constants.availableVideoPublishingBandwidths[i].value;
		allAvailableBandwidths.addItem(obj);
		bandwidthsStillAvailableForSelection.addItem(obj);
		minimumPublishingBandwidths.addItem(obj);
		maximimPublishingBandwidths.addItem(obj);
		//maximumReceivingBandwidths.addItem(obj);
	}
	minBandwidthForPublish=defaultPrompt;
	maxBandwidthForPublish=defaultPrompt;
	//maxReceivingBandwidthForPublish=defaultPrompt;

	if (instituteToEdit != null)
	{
		//Need to do a deep copy
		this.institute=ObjectUtil.copy(instituteToEdit) as InstituteVO;
		if(Log.isDebug()) log.debug("Coming inside init");
		populateData();
		hasEnableAddBrandingButton=true;
	}
	else
	{
		resetSmartCombos();
	}
}

/**
 *
 * @public
 * This function is the result handler for create institute
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : The Result Event
 * @return void
 *
 ***/
public function createInstituteResultHandler(event:ResultEvent):void
{
	newInstituteVO=event.result as InstituteVO;
	if(Log.isInfo()) log.info("Institute created successfully. Institute Id:" + newInstituteVO.instituteId);
	//Fix for Bug#8807
	CustomAlert.info("Institute created successfully");
	hasClickedCancelButton=false;
	closeSaveInstituteComp();
}

/**
 *
 * @public
 * This function is the fault handler for create institute
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : The Fault Event
 * @return void
 *
 ***/
public function createInstituteFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::institute::CreateInstituteCompUIHandler::createInstituteFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	/**
	 * If the error message has Duplicate entry keword, alert the user accordingly */
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given Institute name already exists");
		//Fix for Bug # 1852 start
		butSaveInstitute.enabled=true;
			//Fix for Bug # 1852 end
	} // General bug report if it is not duplicate constraint violation
	else
	{
		instituteHelper.genericFaultHandler(event);
		hasClickedCancelButton=false;
		closeSaveInstituteComp();
	}
}

/**
 *
 * @public
 * This function is the result handler for updating the institute details
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : The ResultEvent
 * @return void
 *
 ***/
public function updateInstituteResultHandler(event:ResultEvent):void
{
	newInstituteVO=event.result as InstituteVO;
	if(Log.isInfo()) log.info("Institute updated successfully Institute Id:" + newInstituteVO.instituteId);
	CustomAlert.info("Institute details updated successfully");
	hasClickedCancelButton=false;
	closeSaveInstituteComp();
}

/**
 *
 * @public
 * This function is the fault handler for updating the institute details
 * This function is made public because the InstituteHelper.as will call this once it
 * gets the result from the server
 * @param event : The FaultEvent
 * @return void
 *
 ***/
public function updateInstituteFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::institute::CreateInstituteCompUIHandler::updateInstituteFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	/**
	 * If the error message has Duplicate entry keword, alert the user accordingly */
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given Institute name already exists");
		//Fix for Bug # 1852 start
		butSaveInstitute.enabled=true;
			//Fix for Bug # 1852 end
	} // General bug report if it is not duplicate constraint violation
	else
	{
		instituteHelper.genericFaultHandler(event);
		hasClickedCancelButton=false;
		closeSaveInstituteComp();
	}
}

/**
 *
 * @private
 *
 * This function is used to reset the search result for the institute
 *
 * @return void
 *
 ***/
private function resetSmartCombos():void
{
	cmbParentInstitutes.filterString="";
	cmbParentInstitutes.selectedItem=null;
}

/**
 *
 * @private
 * This function is used get the index of the parent institute for the given institute id
 * @param instituteId : The instituteId for which the index is required
 * @return int the index
 *
 ***/
private function getParentInstituteIndex(instituteId:Number):int
{
	var i:int=0;
	for (i=0; i < parentInstitutes.length; i++)
	{
		if (instituteId == parentInstitutes[i].instituteId)
		{
			return i;
		}
	}
	return -1;
}


/**
 *
 * @private
 * This function is used check if the parent institute has any child institutes associated
 * @param instituteId : The instituteId for which the child institute availability is checked
 * @return Boolean : True/False
 *
 ***/
private function hasChildInsitutes(instituteId:Number):Boolean
{
	var hasChildInstitutes:Boolean=false;
	var i:int=0;

	var allInstitutes:Array=GCLMContext.allInstitutesAC.source;

	for (i=0; i < allInstitutes.length; i++)
	{
		var institute:InstituteVO=allInstitutes[i] as InstituteVO;

		if (instituteId == institute.parentInstituteId)
		{
			hasChildInstitutes=true;
			break;
		}
	}
	return hasChildInstitutes;
}

/**
 *
 * @private
 * This function is used to populate the institute details for editing
 *
 * @return void
 *
 ***/
private function populateData():void
{
	minBandwidthForPublish=new Object();
	maxBandwidthForPublish=new Object();
	//maxReceivingBandwidthForPublish=new Object();
	/**var bwObj:Object=new Object();
	bwObj.index=institute.maxReceivingBandwidthKbps;
	var i:int=getBandwithItemIndex(maximumReceivingBandwidths, bwObj);
	cmbMaxReceivingBandwidth.selectedIndex=i;
	filterBandwidthValues(maximumReceivingBandwidths);
	
	bwObj=new Object();
	bwObj.index=institute.maxPublishingBandwidthKbps;
	i=getBandwithItemIndex(maximimPublishingBandwidths, bwObj);
	cmbMaxBandwidth.selectedIndex=i;
	filterBandwidthValues(maximimPublishingBandwidths);*/
	var i:int=0;
	txtInpInstituteName.text=institute.instituteName;
	if (institute.parentInstituteId != 0)
	{
		var piIndex:int=getParentInstituteIndex(institute.parentInstituteId);
		if (piIndex != -1)
		{
			cmbParentInstitutes.selectedItem=parentInstitutes[piIndex];
			cmbParentInstitutes.selectedIndex=piIndex;
		}
		else
		{
			cmbParentInstitutes.selectedItem=null;
			cmbParentInstitutes.selectedIndex=-1;
		}
	}
	else
	{
		/**
		  * If the current institue is parent for some other institutes, then it can't be a child of other institutes */
		if (hasChildInsitutes(institute.instituteId))
		{
			lblNoParentInstitute.visible=true;
			cmbParentInstitutes.visible=false;
		}
		resetSmartCombos();
	}
	//Fix for Bug  19978,19979 start
	cmbInstituteType.selectedIndex=instituteTypeArray.indexOf(institute.instituteType);
	var bwObj:Object=new Object();

	bwObj.index=institute.minPublishingBandwidthKbps;
	var i:int=getBandwithItemIndex(minimumPublishingBandwidths, bwObj);
	cmbMinBandwidth.selectedIndex=i;
	filterBandwidthValues(minimumPublishingBandwidths);
	bwObj=new Object();
	bwObj.index=institute.maxPublishingBandwidthKbps;
	i=getBandwithItemIndex(maximimPublishingBandwidths, bwObj);
	cmbMaxBandwidth.selectedIndex=i;
	filterBandwidthValues(maximimPublishingBandwidths);

	//Fix for Bug  19978,19979 end
	/**
	 * For getting index of institute category in instituteCategoriesAC arraycollection of GCLMContext */
	for (i=0; i < GCLMContext.instituteCategoriesAC.length; i++)
	{
		/* Checking institute category id */
		if (institute.instituteCategoryId == GCLMContext.instituteCategoriesAC[i].instituteCategoryId)
		{
			break;
		}
	}
	cmbInstituteCategory.selectedIndex=i;
	txtAreaAddress.text=institute.address;
	txtInpCity.text=institute.city;
	/**
	 * Selecting state and district */
	if (institute.stateName != null && institute.districtName != null)
	{
		instituteStateDistrict.selectStateDistrict(institute.stateName, institute.districtId);
	}
	//Fix for Bug id 3018 start
	/**
	 * Check for the null value for the incoming admin users and servers */
	//
	if (institute.instituteAdminUsers != null)
	{
		selectedInstituteAdminUsers=ObjectUtil.copy(institute.instituteAdminUsers) as ArrayCollection;
	}
	if (institute.instituteServers != null)
	{
		populateServers();
	}
	//Fix for Bug id 3018 end
	enableAddAdminButton();
}

/**
 *
 * @private
 * This function is used to separate all the meeting and classroom servers for update
 *
 * @return void
 *
 ***/
private function populateServers():void
{
	// Separating the meeting servers and classroom servers
	for (var i:int=0; i < institute.instituteServers.length; i++)
	{
		if (institute.instituteServers[i].serverTypeId == ServerVO.MEETING_COLLABORATION_SERVER || institute.instituteServers[i].serverTypeId == ServerVO.MEETING_CONTENT_SERVER || institute.instituteServers[i].serverTypeId == ServerVO.MEETING_PRESENTER_VIDEO || institute.instituteServers[i].serverTypeId == ServerVO.MEETING_VIEWER_VIDEO || institute.instituteServers[i].serverTypeId == ServerVO.MEETING_DESKTOP_SHARING_SERVER)
		{
			selectedInstituteMeetingServers.addItem(institute.instituteServers[i]);
		}
		else
		{
			selectedInstituteServers.addItem(institute.instituteServers[i]);
		}
	}
}

/**
 *
 * @private
 * This function is used to get admin users assigned for the institute. This function is invoked once the user
 * has closed the CreateInstituteAdminsComp after the user admin selection
 * @param event : The InstituteAdminsSelectedEvent
 * @return void
 *
 ***/
private function getInstituteAdmins(event:InstituteAdminsSelectedEvent):void
{
	if(Log.isDebug()) log.debug("Coming inside getInstituteAdmins");
	//Clear the existing institute admins
	selectedInstituteAdminUsers.removeAll();
	var obj:InstituteAdminUserVO;
	instituteAdminUsers.removeAll();
	for (var i:int=0; i < event.data.length; i++)
	{
		//We are removing the deleted users from this list
		//Scenario: 1. Some active admins are added to institute. 
		//2. Some of them got deleted later from the User screen
		//3. When the institute Admin screen comes up, it shows them as deleted
		//4. When Saving this time, we have to remove the deleted Admins from list
		if (event.data[i].statusId != StatusVO.DELETED_STATUS && event.data[i].role == Constants.ADMIN_TYPE)
		{
			obj=new InstituteAdminUserVO();
			obj.instituteAdminUserId=event.data[i].instituteAdminUserId;
			obj.createdByUserId=event.data[i].createdByUserId;
			obj.createdDate=event.data[i].createdDate;
			obj.user=new UserVO();
			obj.user.userId=event.data[i].userId;
			obj.user.userName=event.data[i].userName;
			obj.statusId=event.data[i].statusId;
			obj.user.role=event.data[i].role;
			obj.user.instituteName=event.data[i].instituteName;
			obj.user.parentInstituteName=event.data[i].parentInstituteName;
			selectedInstituteAdminUsers.addItem(obj);
		}
	}
}

/**
 *
 * @private
 * This function is used to get branding details for the institute. This function is invoked once the user
 * has closed the CreateInstituteBranding after the branding details selection
 * @param event : The InstituteBrandingSelectedEvent
 * @return void
 *
 ***/
private function getInstituteBranding(event:InstituteBrandingSelectedEvent):void
{
	if(Log.isInfo()) log.info("Coming inside getInstituteBranding");
	//remove the previous data
	institute.instituteBrandings.removeAll();
	for (var i:int=0; i < event.data.length; i++)
	{
		institute.addInstituteBranding(event.data[i] as InstituteBrandingVO);
	}
}

/**
 *
 * @private
 * This function is used to get classroom servers for the institute. This function is invoked once the user
 * has closed the CreateInstituteServersComp after the classroom servers selection
 * @param event : The InstituteServersSelectedEvent
 * @return void
 *
 ***/
private function getInstituteServers(event:InstituteServersSelectedEvent):void
{
	if(Log.isDebug()) log.debug("Coming inside getInstituteServers");
	var obj:InstituteServerVO;
	var i:int=0;
	// remove all the previous institute servers
	selectedInstituteServers.removeAll();

	//Get all the data servers and add to the selectedInstituteServers
	for (i=0; i < event.dataServers.length; i++)
	{
		obj=new InstituteServerVO();
		obj.instituteServerId=event.dataServers[i].instituteServerId;
		obj.createdByUserId=event.dataServers[i].createdByUserId;
		obj.createdDate=event.dataServers[i].createdDate;
		obj.server=new ServerVO();
		obj.server.serverName=event.dataServers[i].serverName;
		obj.server.serverId=event.dataServers[i].serverId;
		obj.server.serverIp=event.dataServers[i].serverIp;
		obj.server.serverDomain=event.dataServers[i].serverDomain;

		obj.serverTypeId=ServerVO.FM_DATA_SERVER_TYPE;
		selectedInstituteServers.addItem(obj);
	}
	//Get all the content servers and add to the selectedInstituteServers
	for (i=0; i < event.contentServers.length; i++)
	{
		obj=new InstituteServerVO();
		obj.instituteServerId=event.contentServers[i].instituteServerId;
		obj.createdByUserId=event.contentServers[i].createdByUserId;
		obj.createdDate=event.contentServers[i].createdDate;
		obj.server=new ServerVO();
		obj.server.serverName=event.contentServers[i].serverName;
		obj.server.serverId=event.contentServers[i].serverId;
		obj.server.serverIp=event.contentServers[i].serverIp;
		obj.server.serverDomain=event.contentServers[i].serverDomain;

		obj.serverTypeId=ServerVO.CONTENT_SERVER_TYPE;
		selectedInstituteServers.addItem(obj);
	}
	//Get all the desktop sharing servers and add to the selectedInstituteServers
	for (i=0; i < event.desktopSharingServers.length; i++)
	{
		obj=new InstituteServerVO();
		obj.instituteServerId=event.desktopSharingServers[i].instituteServerId;
		obj.createdByUserId=event.desktopSharingServers[i].createdByUserId;
		obj.createdDate=event.desktopSharingServers[i].createdDate;
		obj.server=new ServerVO();
		obj.server.serverName=event.desktopSharingServers[i].serverName;
		obj.server.serverId=event.desktopSharingServers[i].serverId;
		obj.server.serverIp=event.desktopSharingServers[i].serverIp;
		obj.server.serverDomain=event.desktopSharingServers[i].serverDomain;

		obj.serverTypeId=ServerVO.FM_DESKTOP_SHARING_TYPE;
		selectedInstituteServers.addItem(obj);
	}

	//Get all the presenter video servers and add to the selectedInstituteServers
	for (i=0; i < event.presenterVideoServers.length; i++)
	{
		obj=new InstituteServerVO();
		obj.instituteServerId=event.presenterVideoServers[i].instituteServerId;
		obj.createdByUserId=event.presenterVideoServers[i].createdByUserId;
		obj.createdDate=event.presenterVideoServers[i].createdDate;
		obj.server=new ServerVO();
		obj.server.serverName=event.presenterVideoServers[i].serverName;
		obj.server.serverId=event.presenterVideoServers[i].serverId;
		obj.server.serverIp=event.presenterVideoServers[i].serverIp;
		obj.server.serverDomain=event.presenterVideoServers[i].serverDomain;

		obj.serverTypeId=ServerVO.FM_VIDEO_PRESENTER_TYPE;
		selectedInstituteServers.addItem(obj);
	}
	//Get all the viewer video servers and add to the selectedInstituteServers
	for (i=0; i < event.viewerVideoServers.length; i++)
	{
		obj=new InstituteServerVO();
		obj.instituteServerId=event.viewerVideoServers[i].instituteServerId;
		obj.createdByUserId=event.viewerVideoServers[i].createdByUserId;
		obj.createdDate=event.viewerVideoServers[i].createdDate;
		obj.server=new ServerVO();
		obj.server.serverName=event.viewerVideoServers[i].serverName;
		obj.server.serverId=event.viewerVideoServers[i].serverId;
		obj.server.serverIp=event.viewerVideoServers[i].serverIp;
		obj.server.serverDomain=event.viewerVideoServers[i].serverDomain;

		obj.serverTypeId=ServerVO.FM_VIDEO_VIEWER_TYPE;
		selectedInstituteServers.addItem(obj);
	}
}

/**
 *
 * @private
 * This function is used to get meeting servers for the institute. This function is invoked once the user
 * has closed the CreateMeetingServersComp after the meeting servers selection
 * @param event : The InstituteServersSelectedEvent
 * @return void
 *
 ***/
private function getMeetingServers(event:MeetingServersSelectedEvent):void
{
	if(Log.isDebug()) log.debug("Coming inside getMeetingServers");

	var obj:InstituteServerVO;
	var i:int=0;
	selectedInstituteMeetingServers.removeAll();

	obj=new InstituteServerVO();
	obj.instituteServerId=event.meetingCollaborationServers.instituteServerId;
	obj.createdByUserId=event.meetingCollaborationServers.createdByUserId;
	obj.createdDate=event.meetingCollaborationServers.createdDate;
	obj.server=new ServerVO();
	obj.server.serverName=event.meetingCollaborationServers.serverName;
	obj.server.serverId=event.meetingCollaborationServers.serverId;
	obj.server.serverIp=event.meetingCollaborationServers.serverIp;
	obj.server.serverDomain=event.meetingCollaborationServers.serverDomain;
	obj.serverTypeId=ServerVO.MEETING_COLLABORATION_SERVER;
	selectedInstituteMeetingServers.addItem(obj);

	obj=new InstituteServerVO();
	obj.instituteServerId=event.meetingContentServers.instituteServerId;
	obj.createdByUserId=event.meetingContentServers.createdByUserId;
	obj.createdDate=event.meetingContentServers.createdDate;
	obj.server=new ServerVO();
	obj.server.serverName=event.meetingContentServers.serverName;
	obj.server.serverId=event.meetingContentServers.serverId;
	obj.server.serverIp=event.meetingContentServers.serverIp;
	obj.server.serverDomain=event.meetingContentServers.serverDomain;
	obj.serverTypeId=ServerVO.MEETING_CONTENT_SERVER;
	selectedInstituteMeetingServers.addItem(obj);

	obj=new InstituteServerVO();
	obj.instituteServerId=event.meetingPresenterVideoServers.instituteServerId;
	obj.createdByUserId=event.meetingPresenterVideoServers.createdByUserId;
	obj.createdDate=event.meetingPresenterVideoServers.createdDate;
	obj.server=new ServerVO();
	obj.server.serverName=event.meetingPresenterVideoServers.serverName;
	obj.server.serverId=event.meetingPresenterVideoServers.serverId;
	obj.server.serverIp=event.meetingPresenterVideoServers.serverIp;
	obj.server.serverDomain=event.meetingPresenterVideoServers.serverDomain;
	obj.serverTypeId=ServerVO.MEETING_PRESENTER_VIDEO;
	selectedInstituteMeetingServers.addItem(obj);

	obj=new InstituteServerVO();
	obj.instituteServerId=event.meetingViewerVideoServers.instituteServerId;
	obj.createdByUserId=event.meetingViewerVideoServers.createdByUserId;
	obj.createdDate=event.meetingViewerVideoServers.createdDate;
	obj.server=new ServerVO();
	obj.server.serverName=event.meetingViewerVideoServers.serverName;
	obj.server.serverId=event.meetingViewerVideoServers.serverId;
	obj.server.serverIp=event.meetingViewerVideoServers.serverIp;
	obj.server.serverDomain=event.meetingViewerVideoServers.serverDomain;
	obj.serverTypeId=ServerVO.MEETING_VIEWER_VIDEO;
	selectedInstituteMeetingServers.addItem(obj);

	obj=new InstituteServerVO();
	obj.instituteServerId=event.meetingDesktopSharingServers.instituteServerId;
	obj.createdByUserId=event.meetingDesktopSharingServers.createdByUserId;
	obj.createdDate=event.meetingDesktopSharingServers.createdDate;
	obj.server=new ServerVO();
	obj.server.serverName=event.meetingDesktopSharingServers.serverName;
	obj.server.serverId=event.meetingDesktopSharingServers.serverId;
	obj.server.serverIp=event.meetingDesktopSharingServers.serverIp;
	obj.server.serverDomain=event.meetingDesktopSharingServers.serverDomain;
	obj.serverTypeId=ServerVO.MEETING_DESKTOP_SHARING_SERVER;
	selectedInstituteMeetingServers.addItem(obj);
}
/**
 * @private
 * This function is to copy all the available bandwidth to the destination
 * @param destination ArrayCollection
 * @return void
 */
private function copyOriginalBandwidths(destination:ArrayCollection):void
{
	destination.removeAll();
	var obj:Object;
	for (var i:int=0; i < allAvailableBandwidths.length; i++)
	{
		obj=new Object();
		obj=allAvailableBandwidths.getItemAt(i);
		destination.addItem(obj);
	}
}



/**
 *
 * @private
 * This function is used to create a new institute.
 *
 * @return void
 *
 ***/
private function createInstitute():void
{
	var i:int=0;
	//Validate the institute details entered before creating
	if (validateInstituteDetails())
	{
		//Fix for Bug # 1852 start
		butSaveInstitute.enabled=false;
		//Fix for Bug # 1852 end
		if (institute.instituteAdminUsers != null)
		{
			institute.instituteAdminUsers.removeAll();
		}
		if (institute.instituteServers != null)
		{
			institute.instituteServers.removeAll();
		}
		/**institute.minPublishingBandwidthKbps=-1;
		institute.maxPublishingBandwidthKbps=-1;
		if(minBandwidthForPublish.index > 0)
		{
			institute.minPublishingBandwidthKbps=minBandwidthForPublish.index;
		}
		if(institute.minPublishingBandwidthKbps == -1)
		{
			errorMessage+="Minimum bandwidth, ";

		}
		if(maxBandwidthForPublish.index > 0)
		{
			institute.maxPublishingBandwidthKbps=maxBandwidthForPublish.index;
		}
		if(institute.maxPublishingBandwidthKbps == -1)
		{
			errorMessage+="Maximum bandwidth, ";
			
		}*/

	    //institute.maxPublishingBandwidthKbps = maximimPublishingBandwidths[cmbMaxBandwidth.selectedIndex].index;
		//institute.maxReceivingBandwidthKbps = maximumReceivingBandwidths[cmbMaxReceivingBandwidth.selectedIndex].index;		
		//Fix for Bug # 10962
		institute.instituteName= StringUtil.trim(txtInpInstituteName.text);
		institute.instituteType=instituteTypeArray[cmbInstituteType.selectedIndex];
		//Fix for Bug # 10962
		institute.address=StringUtil.trim(txtAreaAddress.text);
		institute.instituteCategoryId=cmbInstituteCategory.selectedItem.instituteCategoryId;
		//Fix for Bug # 10962
		if (StringUtil.trim(txtInpCity.text) != '')
		{
			institute.city=StringUtil.trim(txtInpCity.text);
		}
		else
		{
			institute.city=null;
		}
		if (instituteStateDistrict.districtsCB.selectedItem != null)
		{
			institute.districtId=instituteStateDistrict.districtsCB.selectedItem.districtId;
			institute.districtName=instituteStateDistrict.districtsCB.selectedItem.districtName;
		}
		//Fix for Bug Id 3020 start
		if ((cmbParentInstitutes.text != "") && (cmbParentInstitutes.selectedItem != null))
		{
			institute.parentInstituteId=cmbParentInstitutes.selectedItem.instituteId;
			institute.parentInstituteName=cmbParentInstitutes.selectedItem.instituteName;
		}
		else
		{
			institute.parentInstituteId=0;
			institute.parentInstituteName=null;
		}
		//Fix for Bug Id 3020 end

		for (i=0; i < selectedInstituteAdminUsers.length; i++)
		{
			institute.addInstituteAdminUser(selectedInstituteAdminUsers[i]);
		}
		for (i=0; i < selectedInstituteServers.length; i++)
		{
			institute.addInstituteServer(selectedInstituteServers[i]);
		}
		for (i=0; i < selectedInstituteMeetingServers.length; i++)
		{
			institute.addInstituteServer(selectedInstituteMeetingServers[i]);
		}
		if (institute.instituteId == 0)
		{
			instituteHelper.createInstitute(institute, ClassroomContext.userVO.userId,createInstituteResultHandler,createInstituteFaultHandler);
		}
		else
		{
			instituteHelper.updateInstitute(institute, ClassroomContext.userVO.userId,updateInstituteResultHandler,updateInstituteFaultHandler);
		}
	}
	//If the validation fails alert the user accordingly
	else
	{
		CustomAlert.error(errorMessage);
	}
}

/**
 *
 * @private
 * This function is used enable/disable the Add Admin button
 *
 * @return void
 *
 ***/
private function enableAddAdminButton():void
{
	//The add admin button is enabled only after institute name, type and category is selected
	if ((txtInpInstituteName.text != '') && (cmbInstituteType.selectedIndex != 0) && (cmbInstituteCategory.selectedIndex != 0))
	{
		hasEnabledAddAdminButton=true;
	}
	else
	{
		hasEnabledAddAdminButton=false;
	}
}

/**
 *
 * @private
 * This function is used to validate the institute details before creating
 *
 * @return void
 *
 ***/
private function validateInstituteDetails():Boolean
{
	var result:Boolean=true;
	errorMessage="Please fill the following fields: ";
	//Fix for Bug # 10962
	if (StringUtil.trim(txtInpInstituteName.text) == "")
	{
		errorMessage+="\n Institute Name, ";
		result=false;
	}
	if ((cmbParentInstitutes.text != "") && ((cmbParentInstitutes.selectedItem == null) || (cmbParentInstitutes.selectedItem.instituteId == 0)))
	{
		errorMessage+="\n Invalid Parent Institute, ";
		result=false;
	}
	else if (cmbParentInstitutes.selectedItem != null && cmbParentInstitutes.selectedItem.instituteId == institute.instituteId)
	{
		errorMessage+="\n Parent institute cannot be same as the current institute, ";
		result=false;
	}
	if (cmbInstituteType.selectedIndex == 0)
	{
		errorMessage+="\n Institute Type, ";
		result=false;
	}
	if (cmbInstituteCategory.selectedIndex == 0)
	{
		errorMessage+="\n Institute Category, ";
		result=false;
	}
	//Fix for Bug # 10962
	if (StringUtil.trim(txtAreaAddress.text) == '')
	{
		errorMessage+="\n Address, ";
		result=false;
	}
	if (StringUtil.trim(txtInpCity.text) == '')
	{
		errorMessage+="\n City, ";
		result=false;
	}
	if ((instituteStateDistrict.statesCB.text == "") || (instituteStateDistrict.statesCB.selectedItem == null) || (instituteStateDistrict.statesCB.selectedItem.stateId == 0))
	{
		errorMessage+="\n State, ";
		result=false;
	}
	if ((instituteStateDistrict.districtsCB.selectedIndex == -1) || (instituteStateDistrict.districtsCB.selectedItem == null) || (instituteStateDistrict.districtsCB.selectedItem.districtId == 0))
	{
		errorMessage+="\n District, ";
		result=false;
	}
	if(minBandwidthForPublish.index > 0)
	{
		institute.minPublishingBandwidthKbps=minBandwidthForPublish.index;
	}
	//validating minimum bandwidth for publishing
	if(institute.minPublishingBandwidthKbps == -1)
	{
		errorMessage+="Minimum bandwidth, ";
		result=false;		
	}
	//Validating maximum bandwidth for publishing.
	if(maxBandwidthForPublish.index > 0)
	{
		institute.maxPublishingBandwidthKbps=maxBandwidthForPublish.index;
	}
	//Validating maximum bandwidth for publishing.
	if(institute.maxPublishingBandwidthKbps == -1)
	{
		errorMessage+="Maximum bandwidth, ";
		result=false;		
	}
	
	//Validating maximum bandwidth for publishing.
	if(cmbMaxBandwidth.selectedIndex <= 0)
	{
		errorMessage+="\n Max Publishing Bandwidth, ";
		result=false;
	}
	
	//Validating maximum bandwidth for receiving.
	if(cmbMinBandwidth.selectedIndex <= 0)
	{
		errorMessage+="\n Max Receiving Bandwidth, ";
		result=false;
	}
	
	errorMessage=errorMessage.substring(0, errorMessage.lastIndexOf(","));
	return result;
}

/**
 *
 * @private
 * This function is used to close the CreateInstituteComp
 *
 * @return void
 *
 ***/
private function closeSaveInstituteComp():void
{
	errorMessage="";
	if (selectedInstituteAdminUsers != null)
	{
		selectedInstituteAdminUsers.removeAll();
	}
	PopUpManager.removePopUp(this);
	if(Log.isDebug()) log.debug("Closing the save institute comp");
}

/**
 *
 * @private
 * This function is used enable the AddAdmin and AddBranding button when they are closed
 *
 * @return void
 *
 ***/
private function onPopupRemove(event:FlexEvent=null):void
{
	hasEnabledAddAdminButton=true;
	hasEnableAddBrandingButton=true;
}
/**
 *
 * @private
 * This function is to chang the publishing bandwidth selection depends upon the selected
 * bandwidth for min and max publishing
 *
 * @return void
 *
 */
// This function is not now used can be used in future
private function filterBandwidthValues(selectedBandwidth:ArrayCollection):void
{
	var index:int=-1;
	var i:int=0;
	var count:int=0;
	//The logic is if a bandwidth is selected for minimum publishing then the options for maximum 
	//publish should be equal or greater than that of minimum.
	//For example if the mimimum publish bandwidth is selected as 512 Kbps, then max publish bandwidth
	//should be >= 512.
	//If the user first selects the max publish bandwidth, then minimum should be less than or equal 
	//to that
	//For example if the maximum publish bandwidth is selected as 256 Kbps, then min publish bandwidth
	//should be <= 256
	
	if (selectedBandwidth == minimumPublishingBandwidths)
	{
		minBandwidthForPublish=new Object();
		if (cmbMinBandwidth.selectedItem != null)
		{
			minBandwidthForPublish.index=cmbMinBandwidth.selectedItem.index;
			minBandwidthForPublish.value=cmbMinBandwidth.selectedItem.value;
		}
		else
		{
			minBandwidthForPublish.index=-1;
			minBandwidthForPublish.value=-1;
		}
		if (minBandwidthForPublish.index != -1)
		{
			if ((maximimPublishingBandwidths.length) == (allAvailableBandwidths.length))
			{
				index=getBandwithItemIndex(maximimPublishingBandwidths, minBandwidthForPublish);
				for (i=1; i < index; i++)
				{
					maximimPublishingBandwidths.removeItemAt(1);
				}
				if (maxBandwidthForPublish.index != -1)
				{
					index=getBandwithItemIndex(maximimPublishingBandwidths, maxBandwidthForPublish);
					cmbMaxBandwidth.selectedIndex=index;
				}
			}
			else
			{
				copyOriginalBandwidths(maximimPublishingBandwidths);
				filterBandwidthValues(selectedBandwidth);
			}
		}
	}
	else if (selectedBandwidth == maximimPublishingBandwidths)
	{
		maxBandwidthForPublish=new Object();
		if (cmbMaxBandwidth.selectedItem != null)
		{
			maxBandwidthForPublish.index=cmbMaxBandwidth.selectedItem.index;
			maxBandwidthForPublish.value=cmbMaxBandwidth.selectedItem.value;
		}
		else
		{
			maxBandwidthForPublish.index=-1;
			maxBandwidthForPublish.value=-1;
		}
		if (maxBandwidthForPublish.index != -1)
		{
			if ((minimumPublishingBandwidths.length) == (allAvailableBandwidths.length))
			{
				index=getBandwithItemIndex(minimumPublishingBandwidths, maxBandwidthForPublish);
				count=minimumPublishingBandwidths.length - index;
				for (i=0; i < count; i++)
				{
					if ((index + 2) <= (minimumPublishingBandwidths.length))
					{
						minimumPublishingBandwidths.removeItemAt(index + 1);
					}
				}
				if (minBandwidthForPublish.index != -1)
				{
					index=getBandwithItemIndex(minimumPublishingBandwidths, minBandwidthForPublish);
					cmbMinBandwidth.selectedIndex=index;
				}
			}
			else
			{
				copyOriginalBandwidths(minimumPublishingBandwidths);
				filterBandwidthValues(selectedBandwidth);
			}
		}
	}
}



/**
 *
 * @private
 * This function is used to open the CreateInstituteAdminsComp for adding/updating institute admins
 *
 * @return void
 *
 ***/
private function openSaveInstituteAdminsComp():void
{
	hasEnabledAddAdminButton=false;
	var saveInstituteAdmins:CreateInstituteAdminsComp=new CreateInstituteAdminsComp();
	saveInstituteAdmins.addEventListener(InstituteAdminsSelectedEvent.INSTITUTE_ADMINS_SELECTED, getInstituteAdmins);
	saveInstituteAdmins.addEventListener(FlexEvent.REMOVE, onPopupRemove);

	saveInstituteAdmins.selectedInstituteAdminUsers=ObjectUtil.copy(selectedInstituteAdminUsers) as ArrayCollection;
	saveInstituteAdmins.instituteAdminTitle="Admins for " + txtInpInstituteName.text;
	PopUpManager.addPopUp(saveInstituteAdmins, this.parent, true, null);
	PopUpManager.centerPopUp(saveInstituteAdmins);
	saveInstituteAdmins.initComp();
}
/**
 * @private
 * This function is to get the index of the given object from the array collection
 * @param sourceBandwidth ArrayCollection
 * @param selectedBandwidth Object
 * @return int the index
 */
private function getBandwithItemIndex(sourceBandwidth:ArrayCollection, selectedBandwidth:Object):int
{
	//If the index is not available, it returns -1
	var result:int=-1;
	for (var i:int=0; i < sourceBandwidth.length; i++)
	{
		if (sourceBandwidth.getItemAt(i).index == selectedBandwidth.index)
		{
			result=i;
			break;
		}
	}
	return result;
}


/**
 *
 * @private
 * This function is used to open the CreateInstituteServersComp for adding/updating classroom servers
 *
 * @return void
 *
 ***/
private function openSaveInstituteServersComp():void
{
	hasEnabledAddAdminButton=false;
	var saveInstituteServers:CreateInstituteServersComp=new CreateInstituteServersComp();
	saveInstituteServers.addEventListener(InstituteServersSelectedEvent.INSTITUTE_SERVERS_SELECTED, getInstituteServers);
	saveInstituteServers.addEventListener(FlexEvent.REMOVE, onPopupRemove);
	saveInstituteServers.instituteServerTitle="Class Servers for " + txtInpInstituteName.text;
	PopUpManager.addPopUp(saveInstituteServers, this.parent, true, null);
	PopUpManager.centerPopUp(saveInstituteServers);
	//Separate the servers based on the server category.
	for (var i:int=0; i < GCLMContext.serversAC.length; i++)
	{
		if (GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_FMS || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_FMS_WEB || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN)
		{
			saveInstituteServers.allDataServers.addItem(GCLMContext.serversAC[i]);
		}
		if (GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_WEB_WIN || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_FMS_WEB || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_WEB_LIN)
		{
			saveInstituteServers.allContentServers.addItem(GCLMContext.serversAC[i]);
		}
	}
	//Assign all the available servers for each of the functionlity like Collaboration, Content, Presenter video,
	//Viewer video and Desktop sharing
	saveInstituteServers.allDesktopSharingServers=ObjectUtil.copy(saveInstituteServers.allDataServers) as ArrayCollection;
	saveInstituteServers.allPresenterVideoServers=ObjectUtil.copy(saveInstituteServers.allDataServers) as ArrayCollection;
	saveInstituteServers.allPresenterViewerServers=ObjectUtil.copy(saveInstituteServers.allDataServers) as ArrayCollection;
	saveInstituteServers.allSelectedServers=ObjectUtil.copy(selectedInstituteServers) as ArrayCollection;
	saveInstituteServers.init();
}

/**
 *
 * @private
 * This function is used to open the CreateInstituteMeetingServers for adding/updating meeting servers
 *
 * @return void
 *
 ***/
private function openSaveInstituteMeetingServersComp():void
{
	hasEnabledAddAdminButton=false;
	var saveInstituteMeetingServers:CreateMeetingServersComp=new CreateMeetingServersComp();
	saveInstituteMeetingServers.addEventListener(MeetingServersSelectedEvent.MEETING_SERVERS_SELECTED, getMeetingServers);
	saveInstituteMeetingServers.addEventListener(FlexEvent.REMOVE, onPopupRemove);
	saveInstituteMeetingServers.meetingServerTitle="Meeting Servers for " + txtInpInstituteName.text;
	PopUpManager.addPopUp(saveInstituteMeetingServers, this.parent, true, null);
	PopUpManager.centerPopUp(saveInstituteMeetingServers);
	//Separate the servers based on the server category.
	for (var i:int=0; i < GCLMContext.serversAC.length; i++)
	{
		if (GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_FMS || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_FMS_WEB || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN)
		{
			saveInstituteMeetingServers.allAVMCollaborationServers.addItem(GCLMContext.serversAC[i]);
		}
		if (GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_WEB_WIN || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_FMS_WEB || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || GCLMContext.serversAC[i].serverCategory == Constants.SERVER_CATEGORY_WEB_LIN)
		{
			saveInstituteMeetingServers.allAVMContentServers.addItem(GCLMContext.serversAC[i]);
		}
	}
	//Assign all the available servers for each of the functionlity like Collaboration, Content, Presenter video,
	//Viewer video and Desktop sharing
	saveInstituteMeetingServers.allAVMViewerVideoServers=ObjectUtil.copy(saveInstituteMeetingServers.allAVMCollaborationServers) as ArrayCollection;
	saveInstituteMeetingServers.allAVMPresenterVideoServers=ObjectUtil.copy(saveInstituteMeetingServers.allAVMCollaborationServers) as ArrayCollection;
	saveInstituteMeetingServers.allAVMDesktopSharingServers=ObjectUtil.copy(saveInstituteMeetingServers.allAVMCollaborationServers) as ArrayCollection;
	saveInstituteMeetingServers.allSelectedAVMServers=ObjectUtil.copy(selectedInstituteMeetingServers) as ArrayCollection;
	saveInstituteMeetingServers.init();
}

/**
 *
 * @private
 * This function is used to open the CreateInstituteBranding for adding/updating branding details
 *
 * @return void
 *
 ***/
private function openSaveInstituteBrandingComp():void
{
	hasEnableAddBrandingButton=false;
	var saveInstituteBranding:CreateInstituteBranding=new CreateInstituteBranding();
	saveInstituteBranding.instituteId=institute.instituteId;

	saveInstituteBranding.addEventListener(InstituteBrandingSelectedEvent.INSTITUTE_BRANDING_SELECTED, getInstituteBranding);
	saveInstituteBranding.addEventListener(FlexEvent.REMOVE, onPopupRemove);
	//If the institute has already branding details perform an update else create a new branding
	if (institute.instituteBrandings != null && institute.instituteBrandings.length > 0)
	{
		saveInstituteBranding.instituteBrandingTitle="Update " + saveInstituteBranding.instituteBrandingTitle;
	}
	else
	{
		saveInstituteBranding.instituteBrandingTitle="Create " + saveInstituteBranding.instituteBrandingTitle;
	}
	PopUpManager.addPopUp(saveInstituteBranding, this.parent, true, null);
	PopUpManager.centerPopUp(saveInstituteBranding);
	saveInstituteBranding.init(institute.instituteBrandings);
}