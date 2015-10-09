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
 * File			: CreateClassCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N, Ashish Pillai
 * Reviewer(s)	: Vinod Kumar P
 *
 * This Action Script handler for CreateClassComp.mxml
 * Based on the logged in user credentials this component behaves as follows:
 * Master Admin: Can view all classes, Create, edit and Delete of classes for any course any institute
 * Institute Administrators: Can view all the classes belongs to their institute/child institutes.
 * Create, Edit and Delete of classes are also possible within their institute boundary
 * Presenter and Viewer: Can view only those classes for which they have been registered.
 * Moderator: Moderator can edit class details.
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.vo.ClassServerVO;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.gclm.vo.InstituteVO;
import edu.amrita.aview.core.gclm.vo.ServerVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.controls.DateField;
import mx.controls.NumericStepper;
import mx.controls.RadioButtonGroup;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

import spark.collections.Sort;
import spark.collections.SortField;

/**
 *  To store all the active courses 
 */
[Bindable]
public var activeCourses:ArrayCollection=new ArrayCollection();

/**
 *  To keep track if the cancel button is clicked by the user 
 */
public var hasClickedCancelButton:Boolean=true;

/**
 *  Constant variable for webinar.
 */
private const WEBINAR:String="Webinar";
/**
 *  Constant variable for classroom type.
 */
private const CLASSROOM_TYPE:String="Classroom";

/**
 *  To store the bandwidths still available for video streaming 
 */
[Bindable]
private var bandwidthsStillAvailableForSelection:ArrayCollection=new ArrayCollection();

/**
 *  To store the selected bandwidths for video streaming 
 */
[Bindable]
private var bandwidthsSelectedForStreaming:ArrayCollection=new ArrayCollection();

/**
 *  To store all the bandwidths available for selection for video streaming 
 */
[Bindable]
private var allAvailableBandwidths:ArrayCollection=new ArrayCollection();

/**
 *  To store all servers 
 */
[Bindable]
private var serversAC:ArrayCollection=new ArrayCollection();

/**
 *  To store the servers selected to use for video streaming 
 */
[Bindable]
private var fmsDataServersAC:ArrayCollection=new ArrayCollection();

/**
 *  To store the servers selected used as content servers 
 */
[Bindable]
private var contentServersAC:ArrayCollection=new ArrayCollection();

/**
 *  To store the servers selected to use for streaming presenter video 
 */
[Bindable]
private var fmVideoPresenterServersAC:ArrayCollection=new ArrayCollection();

/**
 *  To store the servers selected to use for viewer streaming 
 */
[Bindable]
private var fmVideoViewerServersAC:ArrayCollection=new ArrayCollection();

/**
 *  To store the servers selected to use for desktop sharing streaming 
 */
[Bindable]
private var fmDesktopSharingServersAC:ArrayCollection=new ArrayCollection();

/**
 *  The different class registration type 
 */
[Bindable]
private var aviewClassRegistraionType:Array=new Array("Approval", "NoApproval", "OpenWithLogin", "Open");

/**
 *  The upload frequency values
 */
[Bindable]
private var uploadFrequencyValue:Array=new Array("10", "15", "20", "25", "30");

/**
 *  To store the bandwidth info for selecting the minimum bandwidth that can be used for the class 
 */
[Bindable]
private var minimumPublishingBandwidths:ArrayCollection=new ArrayCollection();

/**
 *  To store the bandwidth info for selecting the minimum bandwidth that can be used for the class from institute level
 */
private var tmpMinimumPublishingBandwidths:ArrayCollection=new ArrayCollection();


/**
 *  To store the bandwidth info for selecting the maximum bandwidth that can be used for the class 
 */
[Bindable]
private var maximimPublishingBandwidths:ArrayCollection=new ArrayCollection();

/**
 *  To store the bandwidth info for selecting the maximum bandwidth that can be used for the class from institute level
 */
private var tmpMaximimPublishingBandwidths:ArrayCollection=new ArrayCollection();


/**
 *  To store the count of users interact through aview clas 
 */
[Bindable]
private var aviewClassInteractionCount:Array=new Array("1", "2", "3", "4", "5", "6", "7", "8");

/**
 *  To check if the course has been selected 
 */
[Bindable]
private var hasSelectedCourse:Boolean=false;

/**
 *  The list of characters permissible to enter in the class description 
 */
[Bindable]
private var allowedCharactersForClassDescription:String=" A-z0-9<>'/@?&*()#$%{}!~=.,;?:";

/**
 *  To check if the calendar details has to be enabled or not 
 */
[Bindable]
private var hasEnabledCalendarDetails:Boolean;

/**
 *  To store the class details during create/edit 
 */
private var classvo:ClassVO;

/**
 *  To store the error message while validating 
 * */
private var errorMessage:String="";

/**
 *  Variable to set default prompt. 
 * */
private var defaultPrompt:Object=new Object();

/**
 *  The minimum bandwidth for streaming for the class by the administrator 
 */
private var minBandwidthForPublish:Object=new Object();

/**
 *  The maximum bandwidth for streaming for the class by the administrator 
 * */
private var maxBandwidthForPublish:Object=new Object();

/**
 *  To check if Red5 server has been selected 
 */
private var hasSelectedRed5Server:Boolean=false;
/**
 *  Variable to store default bandwidth. 
 */
//({value: "28Kbps", index: 28}, {value: "56Kbps", index: 56}, {value: "128Kbps", index: 128});
private var defaultBandwidthsSelected:ArrayCollection=new ArrayCollection();

/**
 *  To store the video compression data 
 * */
private var videoCompressions:ArrayCollection

/**
 *  The helper class to communicate to the server 
 */
private var classHelper:ClassHelper=null;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.aviewClass.CreateClassCompUIHandler.as");

private var DEFAULT_MONITORING_FREQ_PERIOD : String = "10";
[Bindable]
private var minPublishingBW:int = 0;
[Bindable]
private var maxPublishingBW:int = 0;

/**
 *
 * @public
 * This function sets all the initial info required for the CreateClassComp
 * This function is called from ClassComp.mxml
 * @param classvo type of ClassVO
 * @return void
 *
 */
public function init(classvo:ClassVO=null):void
{
	classHelper=new ClassHelper();
	defaultBandwidthsSelected.removeAll();
	
	var tmpDefaultBandwidth:Object=new Object();
	tmpDefaultBandwidth.index=28;
	tmpDefaultBandwidth.value="28Kbps";
	defaultBandwidthsSelected.addItem(tmpDefaultBandwidth);
	
	tmpDefaultBandwidth=new Object();
	tmpDefaultBandwidth.index=56;
	tmpDefaultBandwidth.value="56Kbps";
	defaultBandwidthsSelected.addItem(tmpDefaultBandwidth);
	
	tmpDefaultBandwidth=new Object();
	tmpDefaultBandwidth.index=128;
	tmpDefaultBandwidth.value="128Kbps";
	defaultBandwidthsSelected.addItem(tmpDefaultBandwidth);
	
	hasSelectedRed5Server=false;
	hasSelectedCourse=false;
	hasClickedCancelButton=true;
	this.classvo=new ClassVO();
	
	defaultPrompt=new Object();
	defaultPrompt.index=0;
	defaultPrompt.value="Select";
	// Commented for new UI change , to select bandwidth
	allAvailableBandwidths.addItem(defaultPrompt);
	minimumPublishingBandwidths.addItem(defaultPrompt);
	maximimPublishingBandwidths.addItem(defaultPrompt);
	tmpMinimumPublishingBandwidths.addItem(defaultPrompt);
	tmpMaximimPublishingBandwidths.addItem(defaultPrompt);
	
	var obj:Object;
	for (var i:int=0; i < Constants.availableVideoPublishingBandwidths.length; i++)
	{
		obj=new Object();
		obj.index=Constants.availableVideoPublishingBandwidths[i].index;
		obj.value=Constants.availableVideoPublishingBandwidths[i].value;
		bandwidthsStillAvailableForSelection.addItem(obj);
	    minimumPublishingBandwidths.addItem(obj);
		maximimPublishingBandwidths.addItem(obj);
	}
	setClassType(true);
	//Fix for Bug # 19979 end
	minBandwidthForPublish=defaultPrompt;
	maxBandwidthForPublish=defaultPrompt;
	//Enables appropriate video selection buttons. If the pre loaded data is not compatible, then resets in appropriate fields
	resetVideoData();
	//If class details is not null,then copy it to local variable.
	if (classvo != null)
	{
		this.classvo=ObjectUtil.copy(classvo) as ClassVO;
		populateClassData();
	}
	else
	{
		setCalendarDetailsEnableAccess(false);
		resetSmartCombos();
	}
}

/**
 *
 * @public
 * This function is the result handler for create class
 * This function is made public because the ClassHelper.as will call this once it
 * gets the result from the server
 * @param event type of Result Event
 * @return void
 *
 */
public function createClassResultHandler(event:ResultEvent):void
{
	hasClickedCancelButton=false;
	CustomAlert.info("Class created successfully");
	closeCreateClassComp();
}

/**
 *
 * @public
 * This function is the fault handler for create class
 * This function is made public because the ClassHelper.as will call this once it
 * gets the result from the server
 * @param event type of Fault Event
 * @return void
 *
 */
public function createClassFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::aviewClass::CreateClassCompUIHandler::createClassFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	// Display error, if a duplicate entry is found.
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given class name already exists. Please try with a different class name");
		//Fix for Bug # 1852 start
		btnSaveClass.enabled=true;
			//Fix for Bug # 1852 end
	}
	else
	{
		classHelper.genericFaultHandler(event);
		closeCreateClassComp();
	}
}

/**
 *
 * @public
 * This function is the result handler for update class
 * This function is made public because the ClassHelper.as will call this once it
 * gets the result from the server
 * @param event type of Result Event
 * @return void
 *
 */
public function updateClassResultHandler(event:ResultEvent):void
{
	hasClickedCancelButton=false;
	CustomAlert.info("Class updated successfully");
	closeCreateClassComp();
}

/**
 *
 * @public
 * This function is the fault handler for update class
 * This function is made public because the ClassHelper.as will call this once it
 * gets the result from the server
 * @param event type of Fault Event
 * @return void
 *
 */
public function updateClassFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::aviewClass::CreateClassCompUIHandler::updateClassFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	// Display error, if a duplicate entry is found.
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given class name already exists. Please try with a different class name");
		//Fix for Bug # 1852 start
		btnSaveClass.enabled=true;
			//Fix for Bug # 1852 end
	}
	else
	{
		classHelper.genericFaultHandler(event);
		closeCreateClassComp();
	}
}

/**
 *
 * @private
 * This function is to set the enable/disable property for calendar control
 * @param flag type of boolean to set
 * @return void
 *
 */
private function setCalendarDetailsEnableAccess(flag:Boolean):void
{
	this.hasEnabledCalendarDetails=flag;
	if (!flag)
	{
		setWeekDaysSelection(false);
		resetTimeDetails();
	}
}

/**
 *
 * @private
 * This function is to close the CreateClassComp
 *
 * @return void
 *
 */
private function classCompCreationComplete():void
{
	if (!ClassroomContext.isCreateClass)
		return;
	for (var i:int=0; i < Constants.VIDEO_COMPRESSION_TECHNIQUES.length; i++)
	{
		//Checking for CODEC_H264 video compression technique
		//And setting that codec value as selected value for the cmbVideoCompression combobox 
		if (Constants.VIDEO_COMPRESSION_TECHNIQUES[i].data == Constants.CODEC_H264)
		{
			cmbVideoCompression.selectedIndex=i;
			break;
		}
	}
}

/**
 *
 * @private
 * This function is to reset the time if entered previously
 *
 * @return void
 *
 */
private function resetTimeDetails():void
{
	nsHoursStartClass.value=0;
	nsMinsStartClass.value=0;
	nsHoursEndClass.value=0;
	nsMinsEndClass.value=0;
	rbAmStartClass.selected=true;
	rbAmEndClass.selected=true;
	rbPmStartClass.selected=false;
	rbPmEndClass.selected=false;
}

/**
 *
 * @private
 * This function is to set the weekday selection
 * @param flag type of boolean to set/reset
 * @return void
 *
 */
private function setWeekDaysSelection(flag:Boolean):void
{
	chkMonWeekDay.selected=flag;
	chkTueWeekDay.selected=flag;
	chkWedWeekDay.selected=flag;
	chkThuWeekDay.selected=flag;
	chkFriWeekDay.selected=flag;
	chkSatWeekDay.selected=flag;
	chkSunWeekDay.selected=flag;
}

/**
 *
 * @private
 * This function is to make the monitor interval frequency combo box  enabled
 * @return void
 *
 */
private function setMonitorIntervalFrequencyditable(flag : Boolean):void
{
	// Fix for Bug #19514 start. 
	//If the monitoring is set to true, then set the default monitor interval freq as 10 mins
	/**if(flag)
	{
		// Fix for Bug #19549
		if(StringUtil.trim(txtMonitorIntervalFrequency.text) == "")
		{
			txtMonitorIntervalFrequency.text = DEFAULT_MONITORING_FREQ_PERIOD;
		}
	}
	else
	{
		txtMonitorIntervalFrequency.text = "";
	}
	txtMonitorIntervalFrequency.editable = flag;*/
	// Fix for Bug #19514 end
	if(flag)
	{
		if((cmbUploadFrequency.selectedItem) == null)
		{
			cmbUploadFrequency.selectedItem = uploadFrequencyValue[0];
		}
	}
	else
	{
		cmbUploadFrequency.selectedItem = "";
	}
	cmbUploadFrequency.enabled = flag;
	}
		


/**
 *
 * @private
 * This function is to reset the combo box data for course
 *
 * @return void
 *
 */
private function resetSmartCombos():void
{
	cmbCourse.filterString="";
	cmbCourse.selectedItem=null;
}

/**
 *
 * @private
 * This function is to populate all class data during edit operation
 *
 * @return void
 *
 */
private function populateClassData():void
{
	minBandwidthForPublish=new Object();
	maxBandwidthForPublish=new Object();
	
	setClassData();
	setClassDescription();
	// Bug fix for Id #1388 start
	// 1. Checked the property returned by result handler since
	// different property is returned by hibernate and sql
	setAdminData();
	setVideoData();
	setClassServersData();
}

/**
 *
 * @private
 * This function is to set all the data related to aviewClass
 *
 * @return void
 *
 */
private function setClassData():void
{
	var i:int;
	txtInpAviewClassName.text=classvo.className;
	// 1. Check if the returned date is String or Date object .
	dateStartDate.selectedDate=(classvo.startDate is String) ? DateField.stringToDate(String(classvo.startDate).slice(0, 10), "YYYY-MM-DD") : classvo.startDate;
	dateEndDate.selectedDate=(classvo.endDate is String) ? DateField.stringToDate(String(classvo.endDate).slice(0, 10), "YYYY-MM-DD") : classvo.endDate;
	for (i=0; i < activeCourses.length; i++)
	{
		if (activeCourses.getItemAt(i).courseId == classvo.courseId)
		{
			cmbCourse.selectedItem=activeCourses[i];
			cmbCourse.selectedIndex=i;
			courseChangeHandler();
			break;
		}
	}
	setClassScheduleType();
	setTime(classvo.startTime, nsMinsStartClass, rbgAmPmStartClass, nsHoursStartClass, true);
	setTime(classvo.endTime, nsMinsEndClass, rbgAmPmEndClass, nsHoursEndClass, false);
}

/**
 *
 * @private
 * This function is to set class description
 *
 * @return void
 *
 */
private function setClassDescription():void
{
	if (classvo.classDescription != "")
	{
		//rteClassDescription.htmlText = classvo.classDescription;
		textAreaClassDescription.text=classvo.classDescription;
	}
}

/**
 *
 * @private
 * This function is to set the ClassSchedule
 *
 * @return void
 *
 */
private function setClassScheduleType():void
{
	//If class type is adhoc.
	if (classvo.scheduleType == rbAdhocClassType.label)
	{
		rbAdhocClassType.selected=true;
	}
	//If class type is schedule.
	else if (classvo.scheduleType == rbScheduledClassType.label)
	{
		rbScheduledClassType.selected=true;
		setCalendarDetailsEnableAccess(true);
		setDays();
	}
}

/**
 *
 * @private
 * This function is to set all the admin related infor during populate class data
 *
 * @return void
 *
 */
private function setAdminData():void
{
	txtInpMaxUsers.text=classvo.maxStudents.toString();
	
	// Bug fix for Id #1388 end
	
	
	// Bug fix for Id #1388 start
	// 1. Checked the property returned by result handler since
	// different property is returned by hibernate and sql
	
	// Bug fix for Id #1388 end
	// Bug fix for Id #1388 start
	// 1. Checked the property returned by result handler since
	// different property is returned by hibernate and sql
	//bwObj.index=classvo.maxPublishingBandwidthKbps;
	// Bug fix for Id #1388 end
	var bwObj:Object = new Object();
	bwObj.index = classvo.maxPublishingBandwidthKbps;
	
	//Fix for Bug # 19979 start
	cmbMaxBandwidth.selectedIndex = getBandwithItemIndex(tmpMaximimPublishingBandwidths, bwObj);	
	bwObj = new Object();
	bwObj.index = classvo.minPublishingBandwidthKbps;
	cmbMinBandwidth.selectedIndex = getBandwithItemIndex(tmpMinimumPublishingBandwidths, bwObj);
	cmbMaxNumInteraction.selectedItem=String(classvo.maxViewerInteraction);	
	//Fix for Bug # 19979 end
	cmbRegistraionType.selectedItem=classvo.registrationType;
	cmbUploadFrequency.selectedItem=classvo.monitorIntervalFreq;
	//Checking if class type is class room or personal.
	//NPCR : use conditional operator
	/*
	if (classvo.classType == CLASSROOM_TYPE)
	{
		setClassType(true);
	}
	else
	{
		setClassType(false);
	}*/
	//checking if can monitor value is yes or no
	if (classvo.canMonitor == Constants.STATUS_YES) 
	{
		setCanMonitor(true);
	}
	else
	{
		setCanMonitor(false);
		
	}
	//Checking if audio video interaction mode is full or minimal.
	if(classvo.audioVideoInteractionMode == Constants.AUDIO_VIDEO_INTERACTION_MODE[0] )
	{
		setAudioVideoInteractionModeAsFull(true);
		// Bug fix for Id #19804 start
		setAudioVideoInteractionModeAsMinimal(false);
		// Bug fix for Id #19804 end
	}
	else if(classvo.audioVideoInteractionMode == Constants.AUDIO_VIDEO_INTERACTION_MODE[1] )
	{
		setAudioVideoInteractionModeAsFull(false);
		setAudioVideoInteractionModeAsMinimal(true);
	}
	//Checking if enable people count is yes  or no.
	if(classvo.enablePeopleCount == Constants.STATUS_YES )
	{
		setEnablePeopleCount(true);
	}
	else
	{
		setEnablePeopleCount(false);
	}

}

/**
 *
 * @private
 * This function is set if the class is regular online class or webinar
 * @param flag:the boolean for classroom/webinar
 * @return void
 *
 */
private function setClassType(flag:Boolean):void
{
	rbClassRoomType.selected=flag;
	rbWebinarType.selected=!flag;
	//Fix for bug 19914,19829 
	rbClassRoomType.enabled=false;
	rbWebinarType.enabled=false;
	
}

/**
 *
 * @private
 * This function is set if the can monitor is yes or no
 * @param flag:the boolean for yes/no
 * @return void
 *
 */
private function setCanMonitor(flag:Boolean):void
{
	rbCanMonitorYes.selected=flag;
	rbCanMonitorNo.selected=!flag;
	setMonitorIntervalFrequencyditable(flag);	
}

/**
 *
 * @private
 * This function is set if the audio video interaction mode as full
 * @param flag:the boolean for full
 * @return void
 *
 */
private function setAudioVideoInteractionModeAsFull(flag:Boolean):void
{
	//Fix for bug 19923 
	rbFullType.selected=flag;	
}

/**
 *
 * @private
 * This function is set if the audio video interaction mode as minimal
 * @param flag:the boolean for minimal
 * @return void
 *
 */
private function setAudioVideoInteractionModeAsMinimal(flag:Boolean):void
{
	rbMinimalType.selected=flag;	
}
/**
 *
 * @private
 * This function is set if the enable people count is yes or no
 * @param flag:the boolean for yes/no
 * @return void
 *
 */
private function setEnablePeopleCount(flag:Boolean):void
{
	rbEnablepeopleCountYes.selected=flag;
	rbEnablepeopleCountNo.selected=!flag;
}

/**
 *
 * @private
 * This function is to set time for the class
 * @param time : The time to Set
 * @param mins : The ui control where the minutes need to be set
 * @param amPm : The radio button for setting am/pm
 * @param hours : he ui control where the hours need to be set
 * @param isStartTime : the boolean to check if this is the start time
 * @return void
 *
 */
private function setTime(time:Date, mins:NumericStepper, amPm:RadioButtonGroup, hours:NumericStepper, isStartTime:Boolean):void
{
	if (time != null)
	{
		var tmpTime:Date=new Date;
		// Bug fix for Id #1388 start
		// 1. Checked the property returned by result handler since
		// different property is returned by hibernate and sql
		if (time is String)
		{
			tmpTime.hours=Number(String(time).slice(0, 2));
			tmpTime.minutes=Number(String(time).slice(3, 5));
			tmpTime.seconds=Number(String(time).slice(6, 8));
		}
		else
		{
			tmpTime=time;
		}
		// Bug fix for Id #1388 end
		
		//Bug fix for issue #679	
		mins.value=tmpTime.minutes;
		//NPCR : use conditional operator
		if (tmpTime.hours >= 12)
		{
			amPm.selectedValue="pm";
		}
		else
		{
			amPm.selectedValue="am"
		}
		//Bug fix issue #679
		if ((isStartTime && tmpTime.hours == 0) || (!isStartTime && tmpTime.hours == 0 && tmpTime.minutes == 0))
		{
			if (isStartTime)
			{
				hours.value=12;
			}
			else
			{
				hours.value=11;
				mins.value=59;
				amPm.selectedValue="pm";
			}
		}
		else if (tmpTime.hours > 12)
		{
			hours.value=tmpTime.hours % 12;
		}
		else
		{
			hours.value=tmpTime.hours;
		}
	}
}

/**
 *
 * @private
 * This function is set the weekdays on when the class has been scheduled
 *
 * @return void
 *
 */
private function setDays():void
{
	if (classvo.weekDays != null)
	{
		var i:int=0;
		setDay(chkMonWeekDay, i++, classvo.weekDays);
		setDay(chkTueWeekDay, i++, classvo.weekDays);
		setDay(chkWedWeekDay, i++, classvo.weekDays);
		setDay(chkThuWeekDay, i++, classvo.weekDays);
		setDay(chkFriWeekDay, i++, classvo.weekDays);
		setDay(chkSatWeekDay, i++, classvo.weekDays);
		setDay(chkSunWeekDay, i++, classvo.weekDays);
	}
}

/**
 *
 * @private
 * This function is set the days on which the class has been scheduled during create
 * @param dayCheck: The check box component
 * @param index:Day of week
 * @param days:String
 * @return void
 *
 */
private function setDay(dayCheck:CheckBox, index:int, days:String):void
{
	//Bug #1916 start
	// 1. Added else condition for each weekday
	//The days string has Y is the day has scheduled class or N otherwise
	//For example if class has been scheduled for Monday, Wednesday and Saturday the value is YNYNNYN
	//NPCR : use conditional operator
	if (days.charAt(index) == 'Y')
	{
		dayCheck.selected=true;
	}
	else
	{
		dayCheck.selected=false;
	}
	//Bug #1916 end
}

/**
 *
 * @private
 * This function is reset the video settings based on the selected protocol/codec
 *
 * @return void
 *
 */
private function resetVideoData():void
{
	var codec:String=Constants.VIDEO_COMPRESSION_TECHNIQUES[cmbVideoCompression.selectedIndex].data;
	//This code may be used in the future. So has been commented
	/*if(codec == Constants.CODEC_H264 || codec == Constants.CODEC_SORENSON)
	{
		//Set the Video Streams to Single stream as multibit rate is not supported and disable them
		if(!singleVideoStream.selected)
		{
			showMultipleVideoStream(false);
			setSingleBitRateOption();
			setVideoServerLables();
		}
		multipleVideoStream.enabled = false;
		singleVideoStream.enabled = false;
	}
	else*/
	if (codec == Constants.CODEC_VP6 || codec == Constants.CODEC_H264 || codec == Constants.CODEC_SORENSON)
	{
		//Enable the Single/Multi bit rate radio buttons
		rbMultipleVideoStream.enabled=true;
		rbSingleVideoStream.enabled=true;
		resetBandwidthArray(false);
	}
}

/**
 *
 * @private
 * This function is set the video data during populating the class details
 *
 * @return void
 *
 */
private function setVideoData():void
{
	var j:int;
	var i:int;
	//If presenter publishing bandwidth is not null.
	if (classvo.presenterPublishingBwsKbps != null)
	{
		bandwidthsSelectedForStreaming.removeAll();
		var arrBW:Array=classvo.presenterPublishingBwsKbps.toString().split(",");
		
		for (j=0; j < arrBW.length; j++)
		{
			for (i=0; i < bandwidthsStillAvailableForSelection.length; i++)
			{
				if (bandwidthsStillAvailableForSelection[i].index == arrBW[j])
				{
					bandwidthsSelectedForStreaming.addItem(ObjectUtil.copy(bandwidthsStillAvailableForSelection[i]));
					bandwidthsStillAvailableForSelection.removeItemAt(i);
					break;
				}
			}
		}
		
		if (classvo.isMultiBitrate == 'Y')
		{
			setMultipleBitRateOption();
		}
		else if (classvo.isMultiBitrate == 'N')
		{
			setSingleBitRateOption();
		}
		setVideoServerLables();
	}
	setVideoQuality();
}

/**
 *
 * @private
 * This function is to set single bit rate option
 *
 * @return void
 *
 */
private function setSingleBitRateOption():void
{
	rbSingleVideoStream.selected=true;
	rbMultipleVideoStream.selected=false;
}

/**
 *
 * @private
 * This function is to set multi bit rate option
 *
 * @return void
 *
 */
private function setMultipleBitRateOption():void
{
	rbMultipleVideoStream.selected=true;
	rbSingleVideoStream.selected=false;
}

/**
 *
 * @private
 * This function is to set video quality
 *
 * @return void
 *
 */
private function setVideoQuality():void
{
	for (var i:int=0; i < Constants.VIDEO_COMPRESSION_TECHNIQUES.length; i++)
	{
		if (classvo.videoCodec == Constants.VIDEO_COMPRESSION_TECHNIQUES[i].data)
		{
			break;
		}
	}
	cmbVideoCompression.selectedIndex=i;
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
// changed the function such that the min and max publish bandwidth values depending upon institute level values
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
	
	if (selectedBandwidth == tmpMinimumPublishingBandwidths)
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
			if ((tmpMaximimPublishingBandwidths.length) == (allAvailableBandwidths.length))
			{
				index=getBandwithItemIndex(tmpMaximimPublishingBandwidths, minBandwidthForPublish);
				for (i=1; i < index; i++)
				{
					tmpMaximimPublishingBandwidths.removeItemAt(1);
				}
				if (maxBandwidthForPublish.index != -1)
				{
					tmpMaximimPublishingBandwidths.removeItemAt(0);
					index=getBandwithItemIndex(tmpMaximimPublishingBandwidths, maxBandwidthForPublish);
					cmbMaxBandwidth.selectedIndex=index;
				}
			}
			else
			{
				copyOriginalBandwidths(tmpMaximimPublishingBandwidths);
				filterBandwidthValues(selectedBandwidth);
			}
		}
	}
	else if (selectedBandwidth == tmpMaximimPublishingBandwidths)
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
			if ((tmpMinimumPublishingBandwidths.length) == (allAvailableBandwidths.length))
			{
				index=getBandwithItemIndex(tmpMinimumPublishingBandwidths, maxBandwidthForPublish);
				count=tmpMinimumPublishingBandwidths.length - index;
				for (i=0; i < count; i++)
				{
					if ((index + 2) <= (tmpMinimumPublishingBandwidths.length))
					{
						tmpMinimumPublishingBandwidths.removeItemAt(index + 1);
					}
				}
				if (minBandwidthForPublish.index != -1)
				{
					index=getBandwithItemIndex(tmpMinimumPublishingBandwidths, minBandwidthForPublish);
					cmbMinBandwidth.selectedIndex=index;
				}
			}
			else
			{
				copyOriginalBandwidths(tmpMinimumPublishingBandwidths);
				filterBandwidthValues(selectedBandwidth);
			}
		}
	}
}

/**
 *
 * @private
 * This function is to set webinar class settings
 *
 * @return void
 *
 */
private function webinarClassRoomDateSetting():void
{
	//Webinar can be scheduled only for one day irrespective of
	//selecting a different start and end date
	
	if (rbgClassTypeGroup.selectedValue == 'Webinar')
	{
		dateEndDate.text=dateStartDate.text;
		dateEndDate.selectedDate=dateStartDate.selectedDate;
		dateEndDate.enabled=false;
		txtClassRoomInstruction.text='Webinar session is valid for one day only. Your settings have been changed accordingly ';
	}
	else
	{
		dateEndDate.enabled=true;
		txtClassRoomInstruction.text='';
	}
}
/**
 *
 * @private
 * This function is to make users select multiple bandwidths and servers if they opt for multi bit rate video streaming
 * for the class
 * @param flag : The boolean to show/hide multi bit rate property settings
 * @return void
 *
 */
private function showMultipleVideoStream(flag:Boolean):void
{
	resetBandwidthArray(true);
	lstSelectedBandwidth.allowMultipleSelection=flag;
	lstAvailableBandwidth.allowMultipleSelection=flag;
	cmbPresenterVideoServer1.selectedIndex=0;
	cmbPresenterVideoServer2.selectedIndex=0;
	cmbPresenterVideoServer3.selectedIndex=0;
	setVideoServerLables();
}

/**
 *
 * @private
 * This function is to reset the selected bandwidth for streaming
 *
 * @return void
 *
 */
private function resetBandwidthArray(deleteselectedBandWArr:Boolean):void
{
	bandwidthsStillAvailableForSelection.removeAll();
	if (deleteselectedBandWArr || classvo.videoCodec != Constants.VIDEO_COMPRESSION_TECHNIQUES[cmbVideoCompression.selectedIndex].data)
	{
		bandwidthsSelectedForStreaming.removeAll();
	}
	var bwArrayLength:uint=Constants.availableVideoPublishingBandwidths.length;
	//If the selected video compresssion technique is not H.264 then the max publishing bandwidth can be 1 Mbps
	if (Constants.VIDEO_COMPRESSION_TECHNIQUES[cmbVideoCompression.selectedIndex].data != Constants.CODEC_H264)
	{
		bwArrayLength=7; //index of 1Mbps
	}
	
	for (var i:int=0; i < bwArrayLength; i++)
	{
		var obj:Object=new Object();
		obj.index=Constants.availableVideoPublishingBandwidths[i].index;
		obj.value=Constants.availableVideoPublishingBandwidths[i].value;
		bandwidthsStillAvailableForSelection.addItem(obj);
	}
}


/**
 *
 * @private
 * This function is to move the selected bandwidth from available to selected array
 * @param event the MouseEvent
 * @return void
 *
 */
private function addToSelectedBandwidthHandler(event:MouseEvent):void
{
	//First add the selected items from the list to the array
	addBandwidthFromAvailableToSelected(bandwidthsSelectedForStreaming, new ArrayCollection(lstAvailableBandwidth.selectedItems));
	//Sort the remaining data in the arraycollection
	sortAvailableItems();
	//Sort the selected data array collection
	sortSelectedItems(bandwidthsSelectedForStreaming);
	//Remove the selected items from the available bandwidth array
	removeAvailableItems(lstAvailableBandwidth.selectedItems);
}

/**
 *
 * @private
 * This function is to remove the selected bandwidth info from available once it is moved to selected
 * @param event the MouseEvent
 * @return void
 *
 */
private function removeFromSelectedBandwidthHandler(event:MouseEvent):void
{
	//Copy from the selected to available
	copyBandwidth(bandwidthsStillAvailableForSelection, new ArrayCollection(lstSelectedBandwidth.selectedItems));
	//Remove from the selected list the copied items
	removeSelectedItems(lstSelectedBandwidth.selectedItems);
	//Check if selected list still has data, if so sort them accordingly
	if (lstSelectedBandwidth.selectedItems.length > 0)
	{
		sortSelectedItems(bandwidthsSelectedForStreaming);
	}
	//Sort the available bandwidth items
	sortAvailableItems();
}

/**
 *
 * @private
 * This function is to add data from available bandwidth to selected bandwidth
 * @param selectedBandwidth the selectedBandwidth
 * @param availableBandwidth
 * @return void
 *
 */
private function addBandwidthFromAvailableToSelected(selectedBandwidth:ArrayCollection, bandwidthsToCopy:ArrayCollection):void
{
	var o:Object;
	//Copy the selected bandwidths from the available to selected
	for each (o in bandwidthsToCopy)
	{
		if (getBandwithItemIndex1(selectedBandwidth, o) < 0)
		{
			selectedBandwidth.addItem(o);
		}
	}
	//setMultiBitRateOptionsVisible();
	if ((rbMultipleVideoStream.selected && selectedBandwidth.length > 3) || (rbSingleVideoStream.selected && selectedBandwidth.length > 1))
	{
		removeSelectedItems(bandwidthsToCopy.toArray());
		for each (o in bandwidthsToCopy)
		{
			if (bandwidthsStillAvailableForSelection.getItemIndex(o) > -1)
			{
				bandwidthsStillAvailableForSelection.addItemAt(o, bandwidthsStillAvailableForSelection.getItemIndex(o));
			}
		}
	}
}

/**
 *
 * @private
 * This function is to add the data from the given source array collection to destination
 * @param destination the ArrayCollection
 * @param src the ArrayCollection
 * @return void
 *
 */
private function copyBandwidth(destination:ArrayCollection, src:ArrayCollection):void
{
	for each (var obj:Object in src)
	{
		for (var i:int=0; i < Constants.availableVideoPublishingBandwidths.length; i++)
		{
			if (Constants.availableVideoPublishingBandwidths[i].index == obj.index)
			{
				destination.addItem(Constants.availableVideoPublishingBandwidths[i]);
			}
		}
	}
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
	//Fix for Bug#20236,20239
	//If the index is not available, it returns the index of 'Select' prompt
	var result:int=0;
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
//Temporary fix for QEEE session: Video streaming bandwidth selection was not working :Start
private function getBandwithItemIndex1(sourceBandwidth:ArrayCollection, selectedBandwidth:Object):int
{
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
//Temporary fix for QEEE session: Video streaming bandwidth selection was not working :Stop

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
 * @private
 * This function is to sort the selected bandwidth items array collection
 *
 * @return void
 */
private function sortSelectedItems(srcBandwidth:ArrayCollection):void
{
	var sortByIndex:Sort=new Sort();
	if (srcBandwidth.length > 0)
	{
		sortByIndex.fields=[new SortField("index")];
		srcBandwidth.sort=sortByIndex;
		srcBandwidth.refresh();
	}
}

/**
 * @private
 * This function is to sort the available data in the bandwidth arraycollection
 *
 * @return void
 */
private function sortAvailableItems():void
{
	var sortByIndex:Sort=new Sort();
	if (bandwidthsStillAvailableForSelection.length > 0)
	{
		sortByIndex.fields=[new SortField("index")];
		bandwidthsStillAvailableForSelection.sort=sortByIndex;
		bandwidthsStillAvailableForSelection.refresh();
	}
}

/**
 * @private
 * This function is to set the video server labels
 *
 * @return void
 */
private function setVideoServerLables():void
{
	//If bandwidth selected for streaming have something in it,then set initial value to firstBandwidthText.
	//Else set firstBandwidthText to null.
	if (bandwidthsSelectedForStreaming.length > 0)
	{
		firstBandwidthText.text=bandwidthsSelectedForStreaming[0].value;
	}
	else
	{
		firstBandwidthText.text="";
	}
	//If multiple video stream is selected. 
	if (rbMultipleVideoStream.selected)
	{
		lblFirstVideoServer.text=Constants.FMS_PRESENTER_DISPLAY + " - 1";
		//If bandwidth selected for streaming have more than 1 element ,then set value to lblSecondBandwidthText.
		//Else set lblSecondBandwidthText to null.
		if (bandwidthsSelectedForStreaming.length > 1)
		{
			lblSecondBandwidthText.text=bandwidthsSelectedForStreaming[1].value;
		}
		// Bug Fix for #2563 
		// Clearing the text value when a bandwidth is removed in video settings
		else
		{
			lblSecondBandwidthText.text="";
		}
		//If bandwidth selected for streaming have more than 2 element ,then set value to lblThirdBandwidthText.
		//Else set lblThirdBandwidthText to null.
		if (bandwidthsSelectedForStreaming.length > 2)
		{
			lblThirdBandwidthText.text=bandwidthsSelectedForStreaming[2].value;
		}
		// Bug Fix for #2563 
		// Clearing the text value when a bandwidth is removed in video settings
		else
		{
			lblThirdBandwidthText.text="";
		}
	}
	else
	{
		lblFirstVideoServer.text=Constants.FMS_PRESENTER_DISPLAY;
	}

}

/**
 * @private
 * This function is to get the class server index from the given arraycollection
 * @param servers the array collection from which the index is required
 * @param classServer the object which has to be searched for
 * @return int
 */
private function getClassServerItemIndex(servers:ArrayCollection, classServer:Object):int
{
	var result:int=-1;
	for (var i:int=0; i < servers.length; i++)
	{
		if (servers[i].server.serverId == classServer.server.serverId)
		{
			result=i;
			break;
		}
	}
	if (result != -1)
	{
		servers[result]=ObjectUtil.copy(classServer);
		servers[result].serverName=classServer.server.serverName;
	}
	return result;
}

/**
 * @private
 * This function is to set the servers that were allotted for a class
 *
 * @return void
 */
private function setClassServersData():void
{
	var presenterVideoServers:ArrayCollection=new ArrayCollection();
	//If class server is not null
	if (classvo.classServers != null)
	{
		for (var i:int=0; i < classvo.classServers.length; i++)
		{
			//Checking class server type id and choosing the combo box value appropriately
			if (classvo.classServers[i].serverTypeId == ServerVO.FM_DATA_SERVER_TYPE)
			{
				cmbDataServer.selectedIndex=getClassServerItemIndex(fmsDataServersAC, classvo.classServers[i]);
			}
			else if (classvo.classServers[i].serverTypeId == ServerVO.FM_DESKTOP_SHARING_TYPE)
			{
				cmbDesktopShareServer.selectedIndex=getClassServerItemIndex(fmDesktopSharingServersAC, classvo.classServers[i]);
			}
			else if (classvo.classServers[i].serverTypeId == ServerVO.FM_VIDEO_PRESENTER_TYPE)
			{
				presenterVideoServers.addItem(ObjectUtil.copy(classvo.classServers[i]));
			}
			else if (classvo.classServers[i].serverTypeId == ServerVO.FM_VIDEO_VIEWER_TYPE)
			{
				cmbViewerVideoServer.selectedIndex=getClassServerItemIndex(fmVideoViewerServersAC, classvo.classServers[i]);
			}
			else if (classvo.classServers[i].serverTypeId == ServerVO.CONTENT_SERVER_TYPE)
			{
				cmbContentServer.selectedIndex=getClassServerItemIndex(contentServersAC, classvo.classServers[i]);
			}
		}
		for (i=0; i < presenterVideoServers.length; i++)
		{
			var index:int=getClassServerItemIndex(fmVideoPresenterServersAC, presenterVideoServers[i]);
			for (var j:int=0; j < bandwidthsSelectedForStreaming.length; j++)
			{
				if (presenterVideoServers[i].presenterPublishingBandwidthKbps == bandwidthsSelectedForStreaming[j].index)
				{
					//Fix for Bug # 3054, 3055 start
					//NPCR : use associate array instead of similar assignments
					if (j == 0)
					{
						cmbPresenterVideoServer1.selectedIndex=index;
					}
					else if (j == 1)
					{
						cmbPresenterVideoServer2.selectedIndex=index;
					}
					else if (j == 2)
					{
						cmbPresenterVideoServer3.selectedIndex=index;
					}
					//Fix for Bug # 3054, 3055 end
					break;
				}
			}
			//Fix for Bug # 3054, 3055 start
			if (classvo.isMultiBitrate == "N")
			{
				cmbPresenterVideoServer1.selectedIndex=index;
			}
				//Fix for Bug # 3054, 3055 end 
		}
	}
}

/**
 * @private
 * This function is to remove available bandwidth.
 * @param items Array
 * @return void
 */
private function removeAvailableItems(items:Array):void
{
	var i:int=0;
	for each (var o:Object in items)
	{
		i=getBandwithItemIndex1(bandwidthsStillAvailableForSelection, o);
		if (i > -1)
		{
			bandwidthsStillAvailableForSelection.removeItemAt(i);
		}
	}
	setVideoServerLables();
}

/**
 * @private
 * This function is to remove selected bandwidth.
 * @param items Array
 * @return void
 */
private function removeSelectedItems(items:Array):void
{
	for each (var o:Object in items)
	{
		bandwidthsSelectedForStreaming.removeItemAt(bandwidthsSelectedForStreaming.getItemIndex(o));
	}
	setVideoServerLables();
}

/**
 * @private
 * This function is to check if the class settings has valid entry or not
 *
 * @return Boolean
 */
private function checkFieldsForClassSettings():Boolean
{
	errorMessage="Please fill the following fields : \n";
	var houStart:int;
	var houEnd:int;
	var strHrStart:String=new String;
	var strMinStart:String=new String;
	var strSecStart:String='00';
	var strMlSecStart:String='00';
	var strHrEnd:String=new String;
	var strMinEnd:String=new String;
	var strSecEnd:String='00';
	var strMlSecEnd:String='00';
	var nextDayStart:Date;
	var nextDayEnd:Date;
	var weekStr:String="";
	var isClassSettingsValid:Boolean=true;
	
	houStart=nsHoursStartClass.value % 12;
	houEnd=nsHoursEndClass.value % 12;
	classvo.courseId=0;
	classvo.startDate=null;
	classvo.endDate=null;
	
	classvo.className=StringUtil.trim(txtInpAviewClassName.text);
	// Class name validation
	if (classvo.className == "")
	{
		errorMessage+="Class Name, ";
		isClassSettingsValid=false;
	}
	
	// Course validation
	if ((cmbCourse.text == "") || (cmbCourse.selectedItem == null) || (cmbCourse.selectedItem.courseId == 0))
	{
		errorMessage+="Course Name, ";
		isClassSettingsValid=false;
	}
	else
	{
		classvo.courseId=cmbCourse.selectedItem.courseId;
	}
	
	// check start date validation
	if (dateStartDate.selectedDate != null)
	{
		classvo.startDate=new Date(dateStartDate.selectedDate);
	}
	
	// Start date validation
	if (classvo.startDate == null)
	{
		errorMessage+="Start Date, ";
		isClassSettingsValid=false;
	}
	
	// check end date validation
	if (dateEndDate.selectedDate != null)
	{
		classvo.endDate=new Date(dateEndDate.selectedDate);
	}
	
	// End date validation
	if (classvo.endDate == null)
	{
		errorMessage+="End Date, ";
		isClassSettingsValid=false;
	}
	
	// Comparing start date and end date
	if (classvo.startDate > classvo.endDate)
	{
		errorMessage+="Start Date is Greater than End Date, ";
		isClassSettingsValid=false;
	}
	strMinStart=nsMinsStartClass.value.toString();
	//If user selects pm(afternoon) time
	if (rbgAmPmStartClass.selectedValue == "pm")
	{
		houStart=nsHoursStartClass.value;
		//Bug fix for issue #679
		//Validating starting hour and minute
		if ((houStart == 11) && (strMinStart == "59"))
		{
			errorMessage+="Change class start time,";
			isClassSettingsValid=false;
		}
		else if (houStart != 12)
		{
			houStart+=12;
		}
	}
	else
	{
		//Bug fix for issue #679
		houStart=nsHoursStartClass.value % 12;
	}
	
	houEnd=nsHoursEndClass.value;
	strMinEnd=nsMinsEndClass.value.toString();
	//Validating class end time
	if ((houEnd == 0) || ((houEnd == 12) && (rbgAmPmEndClass.selectedValue == "pm")))
	{
		houEnd=23;
		strMinEnd="59";
	}
	else if (rbgAmPmEndClass.selectedValue == "pm")
	{
		//Bug fix for issue #679
		if (houEnd != 12)
		{
			houEnd+=12;
		}
	}
	else if ((houEnd == 12) && (rbgAmPmEndClass.selectedValue == "am"))
	{
		errorMessage+="End time cannot be 12 am,";
		isClassSettingsValid=false;
	}
	strHrStart=houStart.toString();
	
	nextDayStart=new Date(null, null, null, strHrStart, strMinStart, strSecStart, strMlSecStart);
	strHrEnd=houEnd.toString();
	nextDayEnd=new Date(null, null, null, strHrEnd, strMinEnd, strSecEnd, strMlSecEnd);
	//Checking if start time and end time are same.
	if ((houEnd != 0) && (houStart != 0) && (houStart == houEnd) && (strMinEnd == strMinStart))
	{
		errorMessage="Start and End Time cannot be same,";
		isClassSettingsValid=false;
	}
	//Checking if end time is less than start time.
	else if ((nextDayEnd.hours < nextDayStart.hours) || ((nextDayEnd.hours == nextDayStart.hours) && (nextDayEnd.minutes < nextDayStart.minutes)))
	{
		errorMessage="End time cannot be less than Start time,";
		isClassSettingsValid=false;
	}
	classvo.startTime=nextDayStart;
	classvo.endTime=nextDayEnd;
	
	// Set the class mode (adhoc/scheduled)
	classvo.scheduleType=(rbAdhocClassType.selected) ? rbAdhocClassType.label : rbScheduledClassType.label;
	
	//Week days required only in case of Scheduled class
	if (rbScheduledClassType.selected)
	{
		weekStr+=checkForSelection(chkMonWeekDay);
		weekStr+=checkForSelection(chkTueWeekDay);
		weekStr+=checkForSelection(chkWedWeekDay);
		weekStr+=checkForSelection(chkThuWeekDay);
		weekStr+=checkForSelection(chkFriWeekDay);
		weekStr+=checkForSelection(chkSatWeekDay);
		weekStr+=checkForSelection(chkSunWeekDay);
		
		classvo.weekDays=weekStr;
		if (classvo.weekDays.indexOf('Y') == -1)
		{
			errorMessage+="Weekday(s),";
			isClassSettingsValid=false;
		}
	}
	else
	{
		classvo.weekDays="NNNNNNN";
		classvo.startTime=null;
		classvo.endTime=null;
	}
	
	classvo.modifiedByUserId=ClassroomContext.userVO.userId;
	classvo.modifiedDate=new Date();
	// Bug fix for Id #7464 start
	if (classvo.statusId == 0)
	{
		classvo.statusId=1;
	}
	// Bug fix for Id #7464 end
	
	errorMessage=errorMessage.substring(0, errorMessage.lastIndexOf(","));
	errorMessage+="\n -----------------------------------------------";
	errorMessage+="\n In Class Settings Tab";
	
	/*if(flagCS)
	tabNavClass.selectedChild = classSettings ;*/
	return isClassSettingsValid;
}

/**
 * @private
 * This function is to check if the given week day has been selected
 * @param CheckBox
 * @return String
 */
private function checkForSelection(weekDayCheckBox:CheckBox):String
{
	var isSelected:String="N";
	if (weekDayCheckBox.selected)
	{
		isSelected="Y";
	}
	return isSelected;
}

/**
 * @private
 * This function is to check if the admin settings has valid entry or not
 *
 * @return Boolean
 */
private function checkFieldsForAdminSettings():Boolean
{
	var isAdminSettingsValid:Boolean=true;
	errorMessage="Please fill the following fields : \n";
	classvo.maxStudents=-1;
	classvo.minPublishingBandwidthKbps=-1;
	classvo.maxPublishingBandwidthKbps=-1;
	/**classvo.minPublishingBandwidthKbps=cmbMinBandwidth.selectedLabel;
	classvo.maxPublishingBandwidthKbps=cmbMaxBandwidth.selectedLabel;*/
	classvo.maxViewerInteraction=Number(cmbMaxNumInteraction.selectedItem);
	classvo.registrationType=cmbRegistraionType.selectedLabel;
	classvo.monitorIntervalFreq=Number(cmbUploadFrequency.selectedItem);
	//Validating maximum number of students.
	if (txtInpMaxUsers.text != "")
	{
		classvo.maxStudents=Number(txtInpMaxUsers.text);
	}
	
	//Validating maximum number of students.
	if (classvo.maxStudents == -1)
	{
		errorMessage+="Maximum students, ";
		isAdminSettingsValid=false;
	}
	
	//Validating minimum bandwidth for publishing.
	if (minBandwidthForPublish.index > 0)
	{
		classvo.minPublishingBandwidthKbps=minBandwidthForPublish.index;
	}
	
	//Validating minimum bandwidth for publishing.
	if (classvo.minPublishingBandwidthKbps == -1)
	{
		errorMessage+="Minimum bandwidth, ";
		isAdminSettingsValid=false;
	}
	
	//Validating maximum bandwidth for publishing.
	if (maxBandwidthForPublish.index > 0)
	{
		classvo.maxPublishingBandwidthKbps=maxBandwidthForPublish.index;
	}
	
	//Validating maximum bandwidth for publishing.
	if (classvo.maxPublishingBandwidthKbps == -1)
	{
		errorMessage+="Maximum bandwidth, ";
		isAdminSettingsValid=false;
	}
	
	//Validating classroom type.
	if (rbClassRoomType.selected)
	{
		classvo.classType=CLASSROOM_TYPE;
	}
	else
	{
		classvo.classType=WEBINAR;
	}
	
	//validating audio video interaction mode type
	if (rbFullType.selected)
	{
		classvo.audioVideoInteractionMode = Constants.AUDIO_VIDEO_INTERACTION_MODE[0];
	}
	else if(rbMinimalType.selected)
	{
		classvo.audioVideoInteractionMode = Constants.AUDIO_VIDEO_INTERACTION_MODE[1];
	}

	//validating  enable people count type
	if (rbEnablepeopleCountYes.selected)
	{
		classvo.enablePeopleCount = Constants.STATUS_YES;
	}
	else if(rbEnablepeopleCountNo.selected)
	{
		classvo.enablePeopleCount = Constants.STATUS_NO;
	}

	//Validating can monitor value
	if (rbCanMonitorYes.selected)
	{
		classvo.canMonitor = Constants.STATUS_YES;
		// Fix for Bug #19514 start 
		//Validating monitor interval frequency.
		//If user manually deletes the default value then throw error
		/**if (txtMonitorIntervalFrequency.text != "")
		{
			classvo.monitorIntervalFreq = Number(txtMonitorIntervalFrequency.text);
		}
		else
		{
			errorMessage+="Monitor Interval Frequency, ";
			isAdminSettingsValid = false;			
		}**/
		// Fix for Bug #19514 end
	}
	else
	{
		classvo.canMonitor = Constants.STATUS_NO;
	}
	
	errorMessage=errorMessage.substring(0, errorMessage.lastIndexOf(","));
	errorMessage+="\n -----------------------------------------------";
	errorMessage+="\n In Admin Settings Tab";
	return isAdminSettingsValid;
}

/**
 * @private
 * This function is to check if the video settings has valid entry or not
 *
 * @return Boolean
 */
private function checkFieldsForVideoSettings():Boolean
{
	var isVideoSettingsValid:Boolean=true;
	errorMessage="";
	classvo.isMultiBitrate=(rbMultipleVideoStream.selected) ? "Y" : "N";
	classvo.videoCodec=cmbVideoCompression.selectedItem.data;
	classvo.videoStreamingProtocol="RTMP";
	
	var j:int=0;
	var i:int=0;
	var existInArr:Boolean=false;
	//Check if class is multi bit rate
	if (classvo.isMultiBitrate == 'Y')
	{
		//If bandwidthsSelectedForStreaming have some element in it
		if (bandwidthsSelectedForStreaming.length > 0)
		{
			for (j=0; j < defaultBandwidthsSelected.length; j++)
			{
				//If bandwidthsSelectedForStreaming have less than 3 element in it
				if (bandwidthsSelectedForStreaming.length < 3)
				{
					existInArr=false;
					for (i=0; i < bandwidthsSelectedForStreaming.length; i++)
					{
						//Checking if element in defaultBandwidthsSelected exists in bandwidthsSelectedForStreaming 
						if (bandwidthsSelectedForStreaming[i].index == defaultBandwidthsSelected[j].index)
						{
							existInArr=true;
							break;
						}
					}
					
					//If selected bandwidth doesn't exist in defaultBandwidthsSelected
					if (!existInArr)
					{
						bandwidthsSelectedForStreaming.addItem(ObjectUtil.copy(defaultBandwidthsSelected[j]));
					}
				}
				// Bug fix for Id 3054, 3055 start
				else
				{
					break;
				}
					// Bug fix for Id 3054, 3055 end
			}
			sortSelectedItems(bandwidthsSelectedForStreaming);
			var str:String=bandwidthsSelectedForStreaming[0].index + "," + bandwidthsSelectedForStreaming[1].index + "," + bandwidthsSelectedForStreaming[2].index;
			classvo.presenterPublishingBwsKbps=str;
		}
		else
		{
			classvo.presenterPublishingBwsKbps="28,56,128";
			bandwidthsSelectedForStreaming=ObjectUtil.copy(defaultBandwidthsSelected) as ArrayCollection;
		}
	}
	//Check if class is single bit rate
	else if (classvo.isMultiBitrate == 'N')
	{
		// Added for new UI change , to select bandwidth
		if (bandwidthsSelectedForStreaming.length > 0)
		{
			// Bug fix for Id 3054, 3055 start
			//medBandWArr.addItem(ObjectUtil.copy(medBandWArr[0]));
			classvo.presenterPublishingBwsKbps=bandwidthsSelectedForStreaming[0].index;
				// Bug fix for Id 3054, 3055 end
		}
		else
		{
			classvo.presenterPublishingBwsKbps='56';
			bandwidthsSelectedForStreaming.addItem(defaultBandwidthsSelected[1]);
		}
	}
	if ((classvo.videoCodec == "VP6") && (classvo.videoStreamingProtocol == "RTMFP"))
	{
		isVideoSettingsValid=false;
		errorMessage="For low latency video transmission, please select High Definition or Low latency as the compression technique";
	}
	removeAvailableItems(bandwidthsSelectedForStreaming.toArray());
	setVideoServerLables();
	return isVideoSettingsValid;
}

/**
 * @private
 * This function is to check if the server settings has valid entry or not
 *
 * @return Boolean
 */
private function checkFieldsForServerSettings():Boolean
{
	var isServerSettingsValid:Boolean=true;
	errorMessage="Please fill the following fields : \n";
	var count:int=0;
	//Validating collaboration server
	//Fix for Bug #14529
	if (cmbDataServer.selectedIndex <= 0)
	{
		errorMessage+="Collaboration Server, ";
		isServerSettingsValid=false;
	}
	//Validating content server
	//Fix for Bug #14529
	if (cmbContentServer.selectedIndex <= 0)
	{
		errorMessage+="Content Server, ";
		isServerSettingsValid=false;
	}
	//Validating desktop share server
	//Fix for Bug #14529
	if (cmbDesktopShareServer.selectedIndex <= 0)
	{
		errorMessage+="Desktop Share Server, ";
		isServerSettingsValid=false;
	}
	//Validating viewer video server
	//Fix for Bug #14529
	if (cmbViewerVideoServer.selectedIndex <= 0)
	{
		errorMessage+="Viewer Video Server, ";
		isServerSettingsValid=false;
	}
	//Validating presenter video server1
	//Fix for Bug #14529
	if (cmbPresenterVideoServer1.selectedIndex <= 0)
	{
		errorMessage+="Presenter Video Server 1, ";
		isServerSettingsValid=false;
	}
	//If multiple video stream is selected
	if (rbMultipleVideoStream.selected)
	{
		//Validating presenter video server2
		//Fix for Bug #14529
		if (cmbPresenterVideoServer2.selectedIndex <= 0)
		{
			errorMessage+="Presenter Video Server 2, ";
			isServerSettingsValid=false;
		}
		//Validating presenter video server3
		//Fix for Bug #14529
		if (cmbPresenterVideoServer3.selectedIndex <= 0)
		{
			errorMessage+="Presenter Video Server 3, ";
			isServerSettingsValid=false;
		}
	}
	errorMessage=errorMessage.substring(0, errorMessage.lastIndexOf(","));
	errorMessage+="\n -----------------------------------------------";
	errorMessage+="\n In Video and/or Server Settings Tabs";
	return isServerSettingsValid;
}

/**
 * @private
 * This function is to get all the selected servers to be used for the class
 *
 * @return void
 */
private function getClassServers():void
{
	//Clearing classServers.
	if (classvo.classServers != null)
	{
		classvo.classServers.removeAll();
	}
	var classServer:ClassServerVO;
	var server:ServerVO;
	//If user selects a data server
	//Fix for Bug #14529
	if (cmbDataServer.selectedIndex > 0)
	{
		classServer=new ClassServerVO();
		classServer=ObjectUtil.copy(cmbDataServer.selectedItem) as ClassServerVO;
		classServer.serverPort=Constants.FMS_SERVER_PORT;
		classServer.presenterPublishingBandwidthKbps=-1;
		classvo.addClassServer(classServer);
	}
	//If user selects a content server
	//Fix for Bug #14529
	if (cmbContentServer.selectedIndex > 0)
	{
		classServer=new ClassServerVO();
		classServer=ObjectUtil.copy(cmbContentServer.selectedItem) as ClassServerVO;
		classServer.serverPort=Constants.CONTENT_SERVER_PORT;
		classServer.presenterPublishingBandwidthKbps=-1;
		classvo.addClassServer(classServer);
	}
	//If user selects a desktop share server
	//Fix for Bug #14529
	if (cmbDesktopShareServer.selectedIndex > 0)
	{
		classServer=new ClassServerVO();
		classServer=ObjectUtil.copy(cmbDesktopShareServer.selectedItem) as ClassServerVO;
		classServer.serverPort=Constants.FMS_SERVER_PORT;
		classServer.presenterPublishingBandwidthKbps=-1;
		classvo.addClassServer(classServer);
	}
	//If user selects a viewer video server
	//Fix for Bug #14529
	if (cmbViewerVideoServer.selectedIndex > 0)
	{
		classServer=new ClassServerVO();
		classServer=ObjectUtil.copy(cmbViewerVideoServer.selectedItem) as ClassServerVO;
		classServer.serverPort=Constants.FMS_SERVER_PORT;
		classServer.presenterPublishingBandwidthKbps=cmbMinBandwidth.selectedItem.index;
		classvo.addClassServer(classServer);
		checkForRED5ServerSelection(classServer);
	}
	//If user selects any from first presenter video server
	//Fix for Bug #14529
	if (cmbPresenterVideoServer1.selectedIndex > 0)
	{
		classServer=new ClassServerVO();
		classServer=ObjectUtil.copy(cmbPresenterVideoServer1.selectedItem) as ClassServerVO;
		classServer.classServerId=0;
		classServer.serverPort=Constants.FMS_SERVER_PORT;
		classServer.presenterPublishingBandwidthKbps=bandwidthsSelectedForStreaming[0].index;
		classvo.addClassServer(classServer);
		checkForRED5ServerSelection(classServer);
	}
	//If multiple video stream is selected
	if (rbMultipleVideoStream.selected)
	{
		//If user selects any from second presenter video server
		//Fix for Bug #14529
		if (cmbPresenterVideoServer2.selectedIndex > 0)
		{
			classServer=new ClassServerVO();
			classServer=ObjectUtil.copy(cmbPresenterVideoServer2.selectedItem) as ClassServerVO;
			classServer.classServerId=0;
			classServer.serverPort=Constants.FMS_SERVER_PORT;
			classServer.presenterPublishingBandwidthKbps=bandwidthsSelectedForStreaming[1].index;
			classvo.addClassServer(classServer);
			checkForRED5ServerSelection(classServer);
		}
		//If user selects any from third presenter video server
		//Fix for Bug #14529
		if (cmbPresenterVideoServer3.selectedIndex > 0)
		{
			classServer=new ClassServerVO();
			classServer=ObjectUtil.copy(cmbPresenterVideoServer3.selectedItem) as ClassServerVO;
			classServer.classServerId=0;
			classServer.serverPort=Constants.FMS_SERVER_PORT;
			classServer.presenterPublishingBandwidthKbps=bandwidthsSelectedForStreaming[2].index;
			classvo.addClassServer(classServer);
			checkForRED5ServerSelection(classServer);
		}
	}
}

/**
 * @private
 * This function is to check if user has selected Red5 server for video streaming
 * @param classServer the ClassServerVO
 * @return void
 */
private function checkForRED5ServerSelection(classServer:ClassServerVO):void
{
	if(Log.isDebug())
		log.debug(""+classServer.server.serverCategory.localeCompare(Constants.SERVER_CATEGORY_RED5_LIN));
	if(Log.isDebug())
		log.debug(""+classServer.server.serverCategory.localeCompare(Constants.SERVER_CATEGORY_RED5_WIN));
	if(Log.isDebug())
		log.debug(""+classvo.videoCodec.localeCompare(Constants.CODEC_H264));
	if (((classServer.server.serverCategory.localeCompare(Constants.SERVER_CATEGORY_RED5_LIN) == 0) || (classServer.server.serverCategory.localeCompare(Constants.SERVER_CATEGORY_RED5_WIN) == 0)) && (classvo.videoCodec.localeCompare(Constants.CODEC_H264) == 0))
	{
		hasSelectedRed5Server=true;
	}
}

/**
 * @private
 * This function is to get the class description from the text control
 *
 * @return void
 */
private function getClassDescription():void
{
	classvo.classDescription=textAreaClassDescription.text;
}

/**
 * @private
 * This function is to check if all the details for class creation is valid
 *
 * @return void
 */
private function preCheckCreateClass():void
{
	webinarClassRoomDateSetting();
	hasSelectedRed5Server=false;
	//Validating user inputs in class settings,admin settings,video settings and server settings
	if (checkFieldsForClassSettings() && checkFieldsForAdminSettings() && checkFieldsForVideoSettings() && checkFieldsForServerSettings())
	{
		getClassServers();
		getClassDescription();
		//If RED5 server is selected,show this alert message.
		//Else create class.
		if (hasSelectedRed5Server)
		{
			CustomAlert.confirmDefaultYes("The Viewer/Presenter Video Server(s) has High definition video compression. This does not support recording the class. Do you wish to continue?", "Confirmation", checkToCreateClass, this);
		}
		else
		{
			createClass();
		}
	}
	else
	{
		CustomAlert.error(errorMessage);
	}
}

/**
 * @private
 * This function is the confirm from the user for selecting Red5 server which does not support recording
 * @param event type of Close Event
 * @return void
 */
private function checkToCreateClass(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		createClass();
	}
}

/**
 * @private
 * This function is to create the class after all validation is done
 *
 * @return void
 */
private function createClass():void
{
	//Fix for Bug # 1852 start
	btnSaveClass.enabled=false;
	//Fix for Bug # 1852 end
	classvo.allowDynamicSwitching="N";
	classvo.auditLevel="Action";
	//If class id is zero, then create new class
	//Else update class.
	if (classvo.classId == 0)
	{
		classHelper.createClass(classvo, ClassroomContext.userVO.userId,createClassResultHandler,createClassFaultHandler);
	}
	else
	{
		classHelper.updateClass(classvo, ClassroomContext.userVO.userId,updateClassResultHandler,updateClassFaultHandler);
	}
}

/**
 * @private
 * This function is the handler for clearing all data when the course is changed for the class
 *
 * @return void
 */
private function courseChangeHandler():void
{
	var i:int=0;
	
	lblNoServers.text="";
	lblInstiteName.text="";
	lblNoCourse.text="";
	hasSelectedCourse=false;
	//Validating the user selected course
	if ((cmbCourse.text != "") && (cmbCourse.selectedItem != null) && (cmbCourse.selectedItem.courseId != 0))
	{
		var instituteId:int=cmbCourse.selectedItem.instituteId;
		for (i=0; i < GCLMContext.allCourseOfferingInstitutesAC.length; i++)
		{
			if (instituteId == GCLMContext.allCourseOfferingInstitutesAC[i].instituteId)
			{
				break;
			}
		}
		serversAC.removeAll();
		serversAC=ObjectUtil.copy(GCLMContext.allCourseOfferingInstitutesAC[i].instituteServers) as ArrayCollection;
		var sort:Sort=new Sort();
		sort.fields=[new SortField("serverName")];
		serversAC.sort=sort;
		serversAC.refresh();
		
		lblInstiteName.text=GCLMContext.allCourseOfferingInstitutesAC[i].instituteName;
		
		clearAllServersDataProviders();
		
		var classServerObj:ClassServerVO=new ClassServerVO();
		
		classServerObj.serverName="Select";
		classServerObj.server=new ServerVO();
		
		fmsDataServersAC.addItem(classServerObj);
		fmDesktopSharingServersAC.addItem(classServerObj);
		fmVideoPresenterServersAC.addItem(classServerObj);
		fmVideoViewerServersAC.addItem(classServerObj);
		contentServersAC.addItem(classServerObj);
		
		for (i=0; i < serversAC.length; i++)
		{
			// create a class server object, for class
			classServerObj=new ClassServerVO();
			classServerObj.server=new ServerVO();
			classServerObj.server=serversAC[i].server;
			classServerObj.serverName=serversAC[i].server.serverName;
			
			if (serversAC[i].serverTypeId == ServerVO.FM_DATA_SERVER_TYPE)
			{
				classServerObj.serverTypeId=ServerVO.FM_DATA_SERVER_TYPE;
				fmsDataServersAC.addItem(ObjectUtil.copy(classServerObj));
			}
			else if (serversAC[i].serverTypeId == ServerVO.FM_DESKTOP_SHARING_TYPE)
			{
				classServerObj.serverTypeId=ServerVO.FM_DESKTOP_SHARING_TYPE;
				fmDesktopSharingServersAC.addItem(ObjectUtil.copy(classServerObj));
			}
			else if (serversAC[i].serverTypeId == ServerVO.FM_VIDEO_PRESENTER_TYPE)
			{
				classServerObj.serverTypeId=ServerVO.FM_VIDEO_PRESENTER_TYPE;
				fmVideoPresenterServersAC.addItem(ObjectUtil.copy(classServerObj));
			}
			else if (serversAC[i].serverTypeId == ServerVO.FM_VIDEO_VIEWER_TYPE)
			{
				classServerObj.serverTypeId=ServerVO.FM_VIDEO_VIEWER_TYPE;
				fmVideoViewerServersAC.addItem(ObjectUtil.copy(classServerObj));
			}
			else if (serversAC[i].serverTypeId == ServerVO.CONTENT_SERVER_TYPE)
			{
				classServerObj.serverTypeId=ServerVO.CONTENT_SERVER_TYPE;
				contentServersAC.addItem(ObjectUtil.copy(classServerObj));
			}
		}
		
		if ((fmsDataServersAC.length == 1) || (fmVideoPresenterServersAC.length == 1) || (fmVideoViewerServersAC.length == 1) || (contentServersAC.length == 1) || (fmDesktopSharingServersAC.length == 1))
		{
			lblNoServers.text+="* Institute has no Servers. Please contact Administrator.";
//			AlertComp.CustomAlert.info("No servers available for the institute for creating the class. " +
//								 "Please contact the administrator to add servers to the institute.");
			
		}
		else
		{
			hasSelectedCourse=true;
		}
		for(var j:int=0; j < GCLMContext.allCourseOfferingInstitutesAC.length; j++)
		{
			if( GCLMContext.allCourseOfferingInstitutesAC[j].instituteName == lblInstiteName.text)
			{
				var instituteDetails:InstituteVO = GCLMContext.allCourseOfferingInstitutesAC[j] as InstituteVO;
				maxPublishingBW =  instituteDetails.maxPublishingBandwidthKbps;
				minPublishingBW =  instituteDetails.minPublishingBandwidthKbps;
				break;
			}
			
		}
		minBandwidthForPublish = new Object;
		maxBandwidthForPublish = new Object;
		minBandwidthForPublish.index=minPublishingBW;
		minBandwidthForPublish.value=minPublishingBW+"Kbps";
		maxBandwidthForPublish.index=maxPublishingBW;
		maxBandwidthForPublish.value=maxPublishingBW+"Kbps";
		
		var tempMinimumBw:int = getBandwithItemIndex(minimumPublishingBandwidths,maxBandwidthForPublish);
		var tempMaximumBw:int = getBandwithItemIndex(maximimPublishingBandwidths,minBandwidthForPublish);
		//Get the minimum and maximum bandwith values from Institute:End
		var obj:Object;
		for(var i : int = tempMaximumBw-1;i >= 0 && i < tempMinimumBw; i++)
		{
			obj=new Object();
			obj.index=Constants.availableVideoPublishingBandwidths[i].index;
			obj.value=Constants.availableVideoPublishingBandwidths[i].value;
			allAvailableBandwidths.addItem(obj);
			//bandwidthsStillAvailableForSelection.addItem(obj);
			tmpMinimumPublishingBandwidths.addItem(obj);
			tmpMaximimPublishingBandwidths.addItem(obj);
		}	

	}
	else
	{
		lblNoCourse.text="* Course is not Found. Please select a valid Course.";
	}
}

/**
 * @private
 * This function is to clear all the servers allotted for this class
 *
 * @return void
 */
private function clearAllServersDataProviders():void
{
	fmDesktopSharingServersAC.removeAll();
	fmsDataServersAC.removeAll();
	fmVideoPresenterServersAC.removeAll();
	fmVideoViewerServersAC.removeAll();
	contentServersAC.removeAll();
}

/**
 * @private
 * This function is to close CreateCloseComp window
 *
 * @return void
 */
private function closeCreateClassComp():void
{
//	coursesAC.removeAll();
	bandwidthsStillAvailableForSelection.removeAll();
	serversAC.removeAll();
	clearAllServersDataProviders();
	
	minimumPublishingBandwidths.removeAll();
	maximimPublishingBandwidths.removeAll();
	
	minBandwidthForPublish=null
	maxBandwidthForPublish=null;
	PopUpManager.removePopUp(this);
}

/**
 * This function is check for the space key press event
 * @param event type of Keyboard event
 * @return void
 */
private function classSettingsKeyDownHandler(event:KeyboardEvent):void
{
	if (event.keyCode == Keyboard.SPACE)
	{
		((event.currentTarget) as mx.controls.CheckBox).dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}
}

private function toggleCheckFmle(bool:Boolean):void
{
	if(rbFullType.selected==true)
		Alert.show("Recommended for presentation-only sessions (Higher Picture Quality) May introduce a small delay, Do you want to continue ?", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {FMLEConfirmation(event)}, null, 1);
	
}

private function FMLEConfirmation(event:CloseEvent):void
	
{
	if (event.detail == Alert.YES) 
	{
		//setCamResolutionValue();	
	}
	else
	{
		rbMinimalType.selected=true;
		changeSelection('videoMode');
	}
}
public function changeSelection(value:String):void
{
	if (value == "videoMode")
	{
		if (rbMinimalType.selected == true)
		{
			rbMinimalType.setStyle("color", "#026293");
			rbFullType.setStyle("color", "#3e3e3e");
			videoModeDelayContainer.setStyle("backgroundColor", '#FFFFFF');
			VideoModeQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			
		}
		else
		{
			rbFullType.setStyle("color", "#026293");
			rbMinimalType.setStyle("color", "#3e3e3e");
			VideoModeQualityContainer.setStyle("backgroundColor", '#FFFFFF');
			videoModeDelayContainer.setStyle("backgroundColor", '#F0F0F0');
		}
	}
	
}
