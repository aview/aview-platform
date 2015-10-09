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
 * File			: FeedbackFormHandler.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP, Pradeesh
 *
 * Business logic for the feedback module
 */
//ashCR: TODO: No comments for the imports are needed, or all of them can be wrapped in one line/para

/**
 * Importing the utils package
 */
import com.adobe.utils.StringUtil;

import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.MainComponent;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.feedback.RatingComponent;
import edu.amrita.aview.feedback.helper.FeedbackHelper;
import edu.amrita.aview.feedback.vo.FeedbackIssueVO;
import edu.amrita.aview.feedback.vo.FeedbackVO;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.system.System;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;


applicationType::desktop{
	import edu.amrita.aview.core.entry.Bandwidth;
}

/**
 * For storing the close button in the normal state
 */
[Embed(source="assets/images/Medium_close.png")]
[Bindable]
public var closePng:Class;

applicationType::desktop{
	[Bindable]
	public var checkBandwidth:Bandwidth;
}

/**
 * For storing the close button in the mouse over state
 */
[Embed(source="assets/images/Medium_close_over.png")]
[Bindable]
public var closeOverPng:Class;
/**
 * For storing the type (logout, exit classroom or close)
 * while closing the application we are passing the type and
 * based on this type the event will excecuted
 */
[Bindable]
public var context:String='';
/**
 *This variable is used to storing the reportdetails
 */
[Bindable]
public var reportIssueDP:ArrayCollection=new ArrayCollection();

/**
 * Creating an object for the rating component
 */
[Bindable]
public var arrModuleList:ArrayList=new ArrayList();
/**
 * to enable the scrolling feature in the report issue component
 */
[Bindable]
public var flagScroll:Boolean=false;
/**
 * creating a rating components
 */
[Bindable]
//public var ratingComp:RatingComponent;

/**
 * Dynamicaly creating the close button for closing the popup window
 * this button will add to the FeedbackForm title bar at the time of creation complete
 */
private var closer:mx.controls.Button=new mx.controls.Button();

/**
 * For storing the tooltip link 
 */
[Bindable]
private var toolTipLnk:String;
/**
 * For storing alert message status for avoiding the duplication 
 */
[Bindable]
private var alertStatus:Boolean=false;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.feedback.FeedbackFormHandler.as");

//ashCR: TODO: the description confused me. Does it mean that the func will be called after the Feedback form module has loaded
/**
 * @protected
 * This function will invoke at the time of
 * creation complete of the FeedbackForm Module
 *
 * @param event type FlexEvent
 * @return void
 */
protected function init(event:FlexEvent):void
{
	//ratingComp =new RatingComponent();
	this.btnSubmit.enabled=true; 
	this.titleBar.addChild(closer);
//	ashCR: TODO: these hard coded values can create issues for different display sizes. Can these values be externalized?
	closer.width=18;
	closer.height=18;
	closer.x=this.width - closer.width - 8;
	closer.y=7;
	closer.toolTip="Close";
	closer.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
	{
		closeFeedback(event)
	});
	closer.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	closer.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	closer.setStyle('icon', closePng);
	closer.useHandCursor=false;
	createReportIssueComponent(false);
	//this.feedBackRating.addElementAt(ratingComp, 1);
	//ashCR: TODO: can this magic number be put in some global scope
	//ashCR: TODO: for e.g. ratingComp.setStyle("paddingLeft", PADDING_LEFT) , where PADDING_LEFT is already defined in some central/global location
	ratingComp.setStyle("paddingLeft", 8);
	ratingComp.setStyle("paddingRight", 8);
	//This will create the event listner for report issue
	this.issue.addEventListener("addIssueComp", function(event):void
	{
		createReportIssueComponent(true, event)
	});
	
	//the event listner will add the custom event for 
	// setting the scroll position in the report issue list
	
	this.issue.addEventListener("setScrollPosition", setScrollPostionForList);
	
	//the event listner will add the custom event to 
	//removing the selected issue items from the report issue list
	
	this.issue.addEventListener("removeIssueComp", removeIssueConfim);
}

/**
 * @private
 * For removing the selected item from the report issue component
 * This function has dispatched from the report issue component
 * confirmation window for removing the component
 *
 * @param event type Event
 * @return void
 **/
private function removeIssueConfim(event:Event):void
{
	Alert.show("Are you sure you want to remove the issue regarding the module " + reportIssueDP[issue.selectedIndex].ModuleName + "?", "Confirmation", Alert.YES | Alert.NO, null, removeIssue, null, 1);

}

/**
 * @private
 * For removing the selected item from the report issue component
 * based on the confirmation the item will remove from the component
 *
 * @param event type CloseEvent
 * @return void
 **/
private function removeIssue(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		reportIssueDP.removeItemAt(this.issue.selectedIndex);
	}
	else
	{
		this.issue.selectedItem.showAddButton=false;
		this.issue.selectedItem.showRemoveButton=true;
	}
}

/**
 * @private
 * For changing the close button on the mouse over
 * this will invoke from the mouse over in the close button
 *
 * @param type MouseEvent
 * @return void
 **/
private function mouseOverHandler(event:MouseEvent):void
{
	closer.setStyle('icon', closeOverPng);
}

/**
 * @private
 * For restoring the close button on the mouse out
 * this will invoke from the mouse out in the close button
 *
 * @param type MouseEvent
 * @return void
 **/
private function mouseOutHandler(event:MouseEvent):void
{
	closer.setStyle('icon', closePng);
}

/**
 * @private
 * For creating the report issue modules
 * this will invoke from addIssueComp event
 *
 * @param isRuleNeeds type Boolean
 * @return void
 *
 **/

private function createReportIssueComponent(isRuleNeeds:Boolean, evt:*=null):void
{
	/**
	 * based on the value for showing the seperator
	 * isRuleNeeds = true
	 **/
	var objReportIssue:Object;
	if (isRuleNeeds == true)
	{
		objReportIssue=new Object();
		objReportIssue.ModuleName='';
		objReportIssue.ModuleID='';
		objReportIssue.Issue='';
		objReportIssue.Desc='';
		objReportIssue.showRuler=isRuleNeeds;
		objReportIssue.showAddButton=true;
		objReportIssue.showRemoveButton=false;
		reportIssueDP.addItem(objReportIssue);
	}
	else
	{
		objReportIssue=new Object();
		objReportIssue.ModuleName='';
		objReportIssue.ModuleID='';
		objReportIssue.Issue='';
		objReportIssue.Desc='';
		objReportIssue.showRuler=isRuleNeeds;
		objReportIssue.showAddButton=true;
		objReportIssue.showRemoveButton=false;
		reportIssueDP.addItem(objReportIssue);
	}
}

/**
 * @private
 * For saving the Feedback details
 * This method will invoke from the btnSubmit button
 *
 * @return void
 */
private function submitFeedback():void
{
	//For keeping the submit status value.
	var submitStatus:Boolean=false;
	//For disabling the submit button when the submit button clicked
	btnSubmit.enabled=false;
	var feedbackHelper:FeedbackHelper=new FeedbackHelper();
	//For storing the values in the feedback VO this will go to the database
	var feedbackVOInst:FeedbackVO=new FeedbackVO();
	feedbackVOInst.userId=ClassroomContext.userVO.userId;
	feedbackVOInst.auditUserLoginId=AuditContext.userLoginVO.auditUserLoginId;
	if (AuditContext.auditLectureVO != null)
		feedbackVOInst.auditLectureId=AuditContext.auditLectureVO.auditLectureId;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
	{
		feedbackVOInst.bandwidthRating=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getAverageBandwidthRating();
	}
	feedbackVOInst.givenMM=parseFloat((ClassroomContext.userDetails.totalMemory / (1024 * 1024)).toFixed(3));
	feedbackVOInst.leftMM=parseFloat((ClassroomContext.userDetails.freeMemory / (1024 * 1024)).toFixed(3));
	feedbackVOInst.memoryUsedMB=parseFloat((ClassroomContext.userDetails.privateMemory / (1024 * 1024)).toFixed(3));
	feedbackVOInst.cpuArchitecture=ClassroomContext.userDetails.cpuArchitecture;
	feedbackVOInst.usedCPUPercentage=Number(ClassroomContext.userDetails.cpuUsage);
	feedbackVOInst.is64bitSupport=(ClassroomContext.userDetails.supports64Bit == true) ? 'Y' : 'N';
	feedbackVOInst.hasAudioVideo=(getValueFromBoolean(!ClassroomContext.userDetails.avHardware) == "Yes") ? 'Y' : 'N';
	feedbackVOInst.hasFileReadPermission=(getValueFromBoolean(!ClassroomContext.userDetails.localFileRead) == "Yes") ? 'Y' : 'N';
	feedbackVOInst.operatingSystem=ClassroomContext.userDetails.operatingSystem;
	feedbackVOInst.runtimeVersion=ClassroomContext.userDetails.airVersion;
	feedbackVOInst.maxIDCLevel=ClassroomContext.userDetails.maxLevelIDC;
	feedbackVOInst.screenResolutionX=Number(ClassroomContext.userDetails.screenResolutionX);
	feedbackVOInst.screenResolutionY=Number(ClassroomContext.userDetails.screenResolutionY);
	
	feedbackVOInst.overallRating=ratingComp.overallRating.rate;
	feedbackVOInst.overallFeedback=StringUtil.trim(ratingComp.txtOverAllRating.text);
	feedbackVOInst.audioRating=ratingComp.audioRating.rate;
	feedbackVOInst.audioFeedback=StringUtil.trim(ratingComp.txtAudioRating.text);
	feedbackVOInst.videoRating=ratingComp.videoRating.rate;
	feedbackVOInst.videoFeedback=StringUtil.trim(ratingComp.txtvideoRating.text);
	feedbackVOInst.interactionRating=ratingComp.interactionRating.rate;
	feedbackVOInst.interactionFeedback=StringUtil.trim(ratingComp.txtinteractionRating.text);
	feedbackVOInst.whiteboardRating=ratingComp.whiteBrdRating.rate;
	feedbackVOInst.whiteboardFeedback=StringUtil.trim(ratingComp.txtwhiteBrdRating.text);
	feedbackVOInst.documentSharingRating=ratingComp.contentRating.rate;
	feedbackVOInst.documentSharingFeedback=StringUtil.trim(ratingComp.txtcontentRating.text);
	feedbackVOInst.desktopSharingRating=ratingComp.shrRating.rate;
	feedbackVOInst.desktopSharingFeedback=StringUtil.trim(ratingComp.txtshrRating.text);
	feedbackVOInst.usabilityRating=ratingComp.userInterRating.rate;
	feedbackVOInst.usabilityFeedback=StringUtil.trim(ratingComp.txtUserInterRating.text);
	feedbackVOInst.otherFeedback=StringUtil.trim(txtOtherFeedback.text);
	
	feedbackVOInst.stageWidth=ClassroomContext.userDetails.stageWidth;
	feedbackVOInst.stageHeight=ClassroomContext.userDetails.stageHeight;
	feedbackVOInst.downloadBWKb=Number(txtDownload.text);
	feedbackVOInst.uploadBWKb=Number(txtUpload.text);
	
	//For storing the values based on the selection
	//If the selected value is Yes, The value will be stored as 'Y' in the variable
	//If the selected value is No, The value will be stored as 'N' in the variable
	//If it is unselected value '', The value will be stored as 'null' in the variable
	
	if (rbFirewall.selectedValue == 'Yes')
		feedbackVOInst.isBehindFirewall='Y';
	else if (rbFirewall.selectedValue == 'No')
		feedbackVOInst.isBehindFirewall='N';
	else
		feedbackVOInst.isBehindFirewall=null;
	
	//For storing the values based on the selection
	//If the selected value is Yes, The value will be stored as 'Y' in the variable
	//If the selected value is No, The value will be stored as 'N' in the variable
	// If it is unselected value '', The value will be stored as 'null' in the variable
	
	if (rbProxy.selectedValue == 'Yes')
		feedbackVOInst.hasProxyServer='Y';
	else if (rbProxy.selectedValue == 'No')
		feedbackVOInst.hasProxyServer='N';
	else
		feedbackVOInst.hasProxyServer=null;
	
	// For storing the values based on the selection
	// If the selected value is Yes, The value will be stored as 'Y' in the variable
	// If the selected value is No, The value will be stored as 'N' in the variable
	// If it is unselected value '', The value will be stored as 'null' in the variable
	
	if (rbAnti.selectedValue == 'Yes')
		feedbackVOInst.hasAVS='Y';
	else if (rbFirewall.selectedValue == 'No')
		feedbackVOInst.hasAVS='N';
	else
		feedbackVOInst.hasAVS=null;
	
	// For storing the values based on the selection
	// If the selected value is Yes, The antivirus name will be stored
	// If the selected value is No, The antivirus name will be stored as null
	
	if (rbAnti.selectedValue == 'Yes')
	{
		feedbackVOInst.antiVirusName=StringUtil.trim(txtName.text);
	}
	else
	{
		feedbackVOInst.antiVirusName='';
	}
	
	// For validating the report issues
	// The for loop will check the data one by one and check if there is any null value
	// and show the alert message based on the component
	
	
	for (var i:int=0; i < reportIssueDP.length; i++)
	{
		if (!isNaN(reportIssueDP[i].ModuleID))
		{
			if (reportIssueDP[i].ModuleID == 0 && reportIssueDP[i].Issue == '' && reportIssueDP[i].Desc == '')
			{
			}
			else if (reportIssueDP[i].ModuleID == 0)
			{
				Alert.show("Please select the affected module", "Error");
				submitStatus=true;
				btnSubmit.enabled=true;
				break;
			}
			else if (reportIssueDP[i].Issue == '')
			{
				Alert.show("Please enter the issue", "Error");
				submitStatus=true;
				btnSubmit.enabled=true;
				break;
			}
			else if (reportIssueDP[i].Desc == '' && alertStatus == false)
			{
				Alert.show("Do you want to submit without description", "Confirm", Alert.YES | Alert.NO, null, confirmHandler, null, 1);
				submitStatus=true;
				btnSubmit.enabled=true;
				break;
			}
			if (submitStatus == false)
			{
				for (var j:int=0; j < feedbackVOInst.feedbackIssues.length; j++)
				{
					if (reportIssueDP[i].ModuleID == feedbackVOInst.feedbackIssues.source[j].moduleId)
					{
						Alert.show("Please combine issues related to same module in one report.", "Error");
						submitStatus=true;
						btnSubmit.enabled=true;
						break;
					}
				}
			}
			
			if (submitStatus == false)
			{
				if (reportIssueDP[i].ModuleName != '' || StringUtil.trim(reportIssueDP[i].Issue) != '' || StringUtil.trim(reportIssueDP[i].Desc) != '')
				{
					var feedbackIssueVO:FeedbackIssueVO=new FeedbackIssueVO();
					feedbackIssueVO.issueDescription=reportIssueDP[i].Desc;
					feedbackIssueVO.feedbackIssueId=0;
					feedbackIssueVO.issueTitle=reportIssueDP[i].Issue;
					feedbackIssueVO.moduleId=reportIssueDP[i].ModuleID;
					feedbackVOInst.addFeedbackIssue(feedbackIssueVO);
				}
			}
			else
				break;
		}
	}
	if (submitStatus == false)
	{
		feedbackHelper.createFeedback(this,feedbackVOInst);
	}

}

/**
 * @private
 * This function is used to confirm for saving the data
 * and this will invoke from the submitFeedback();
 *
 * @param event type CloseEvent
 * @return void
 * **/
private function confirmHandler(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		alertStatus=true;
		submitFeedback();
	}
	else
	{
		alertStatus=false;
	}

}

/**
 * @private
 * This function is used to close the feedbackform
 * and this will invoke from the submitFeedback();
 * need to pass the parameter 'close Event'
 * Also when we selected the Logout, ExitClassroom or Close Application
 * that value has stored in the context and based on that the closefeedback will work
 *
 * @param event type * to handle the close event and mouse event
 * @return void
 * **/
private function closeFeedback(event:*=null):void
{ 
	PopUpManager.removePopUp(this);
	
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.isPopupFeedbackForm=false;
	switch (context)
	{ 
		case 'logout':
			FlexGlobals.topLevelApplication.mainApp.logoutConfirmationHandler();
			break;
		case 'close':
			FlexGlobals.topLevelApplication.mainApp.closeConfirmationHandler();
			break;
		case 'exitClassroom':
			FlexGlobals.topLevelApplication.mainApp.exitClassroomConfirmationHandler();
			break;
		case 'endMeeting':
			FlexGlobals.topLevelApplication.mainApp.exitClassroomConfirmationHandler();
			break;
		case '':
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Feedback_icon=FlexGlobals.topLevelApplication.mainApp.feedback_unclicked;
			break;
	}
	
	// For reseting the values in the variable
	// also reseting the components visibility
	
	
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.overAll='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.audioRate='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.videoRate='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.interactionRate='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.wbRate='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.docRate='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.deskRate='';
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.uiRate='';
	
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtDeskRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtOverAllRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtAudioRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtDocRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtInteractionRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtUIRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtVideoRatingStatus=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.txtWBRatingStatus=false;
	
	txtOtherFeedback.text='';
	feedbackformNavigator.selectedIndex=0;
	ratingComp.overallRating.rate=0;
	ratingComp.audioRating.rate=0;
	ratingComp.videoRating.rate=0;
	ratingComp.whiteBrdRating.rate=0;
	ratingComp.contentRating.rate=0;
	ratingComp.interactionRating.rate=0;
	ratingComp.shrRating.rate=0;
	ratingComp.userInterRating.rate=0;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.feedback=null;
}

/**
 * @protected
 * For removing the default text from the component
 * This will invoke from the txtName click
 *
 * @param event type MouseEvent
 * @return void
 * 
 * **/
protected function txtAntivirusNameClickHandler(event:MouseEvent):void
{
	if (txtName.text == "Name of my Anti-virus")
	{
		txtName.text='';
		txtName.setStyle("color", '#000000');
		txtName.setStyle("fontStyle", 'normal');
	}
}

/**
 * @protected
 * For reseting the text to 'Name of my Anti-virus' it will reset only the components
 * values are null or selected value is set to 'not sure'
 * This will invoke from the txtName focusout event
 *
 * @param event type FocusEvent
 * @return void
 */
protected function txtAntivirusFocusOutHandler(event:FocusEvent):void
{
	if (txtName.text == '')
	{
		txtName.text='Name of my Anti-virus';
		//ashCR: TODO: can we give a human friendly name to the color value? What I am inclining towards is more of a CSS style mode for centralizing numeric values
		txtName.setStyle("color", '#949494');
		txtName.setStyle("fontStyle", 'italic');
	}
	else if (rbAnti.selectedValue == "Not sure")
	{
		txtName.text='Name of my Anti-virus';
		//ashCR: TODO: can we give a human friendly name to the color value? What I am inclining towards is more of a CSS style mode for centralizing numeric values
		txtName.setStyle("color", '#949494');
		txtName.setStyle("fontStyle", 'italic');
	}
	else
		
	{
		txtName.text=txtName.text;
		//ashCR: TODO: can we give a human friendly name to the color value? What I am inclining towards is more of a CSS style mode for centralizing numeric values
		txtName.setStyle("color", '#000000');
		txtName.setStyle("fontStyle", 'normal');
	}
}

/**
 * @public
 * Used for checking the bandwidth
 *
 * @return void
 */
public function initUrl():void
{
	
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
		{
			tooltipFetcher.send(); 
		}
		else
		{
			Alert.show("Please enter the classroom to check the bandwidth","Info");
		}
}

/**
 * @public
 * This function is to load the speed test web page when the user click the link to test connection speed
 *
 * @param event type ResultEvent
 * @return void
 */
public function getSpeedTestURLResultHandler(event:ResultEvent):void
{
	
	//If single server is used for both content and streaming, then web server would be listening on 80, otherwise on 8080
	/*var contentServerPort:Number=(ClassroomContext.CONTENT_DOCUMENT == ClassroomContext.VIDEO_RECORD_SERVER) ? Constants.CONTENT_SERVER_PORT : Constants.CONTENT_SERVER_PORT_FIREWALL;
	//ashCR: TODO: can the protocal constant be moved to some global file  
	toolTipLnk=encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + contentServerPort + event.result.tool.Link);
	applicationType::desktop{
		navigateToURL(new URLRequest(toolTipLnk), "_blank");
	}
	//Fix for issue #18435
	applicationType::web{
		if (ExternalInterface.available)
		{	
			ExternalInterface.call("loadIFrame", toolTipLnk);
			ExternalInterface.call("showIFrame");
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.moveIFrame();
		}
	}*/
	
		applicationType::desktop{
			checkBandwidth= new Bandwidth();
			PopUpManager.addPopUp(checkBandwidth,this,true);
			PopUpManager.centerPopUp(checkBandwidth);
		
			
		}
		
		//Fix for issue #16794
		applicationType::web{
			//Fix for issue #18215
			//If single server is used for both content and streaming, then web server would be listening on 80, otherwise on 8080
			var contentServerPort:Number=(ClassroomContext.CONTENT_DOCUMENT == ClassroomContext.VIDEO_RECORD_SERVER) ? Constants.CONTENT_SERVER_PORT : Constants.CONTENT_SERVER_PORT_FIREWALL;
			var toolTipLnk:String=encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + contentServerPort + "/speedtest/");
			//Fix for issue #17755		
			if (! ExternalInterface.available)
			{
				throw new Error("ExternalInterface is not available in this container. Internet Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other browsers that support NPRuntime are required.");
			}
			ExternalInterface.call("loadIFrame", toolTipLnk);
			ExternalInterface.call("showIFrame");
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.moveIFrame();
		}
}

/**
 * @public
 * This method will invoke when an error occurs in the bandwidth testing
 *
 * @param event type FaultEvent
 * @return void
 */
public function getSpeedTestURLFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("feedback::FeedbackFormHandler::getSpeedTestURLFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	// ashCR: TODO: this string "Fault occured" is used frequently across the code base. This needs to be made a constant and the hard-coding should be removed
}

/**
 * @private
 * This a common function for changing the value from 'True' to 'Yes' and 'False' to 'No'
 * this method is used to show the values in the UI
 *
 * @param isTrue type boolean
 * @return String
 */
private function getValueFromBoolean(isTrue:Boolean):String
{
	// ashCR: 1 TODO: can we change the following code to conditional operator? for e.g the following 6 lines can be replace by the following single line:
	// ashCR: 2 TODO: var str:String = (isTrue == true) ? 'Yes' : 'No'; 
	var str:String='';
	if (isTrue == true)
		str='Yes';
	else
		str='No';
	return str;
}

/**
 * @protected
 * For setting the scrollposition of the list after adding an item to the list.
 *
 * @param event type Event
 * @return void
 */

protected function setScrollPostionForList(event:Event):void
{
	if (flagScroll == true)
	{
		event.currentTarget.ensureIndexIsVisible(reportIssueDP.length - 1);
		flagScroll=false;
	}
}

/**
 * @protected
 * This function will collect the details about the screen resolution,
 * memory details, application width and height and it will stored in an object
 * this will invoke from the preinitializeHandler
 *
 * @param event type FlexEvent
 * @return void
 */
protected function preInitializeHandler(event:FlexEvent):void
{
	ClassroomContext.userDetails.screenResolutionX=Capabilities.screenResolutionX;
	ClassroomContext.userDetails.screenResolutionY=Capabilities.screenResolutionY;
	ClassroomContext.userDetails.privateMemory=System.privateMemory;
	ClassroomContext.userDetails.totalMemory=System.totalMemory;
	ClassroomContext.userDetails.freeMemory=System.freeMemory;
	ClassroomContext.userDetails.cpuUsage=System.processCPUUsage;
	ClassroomContext.userDetails.stageWidth=FlexGlobals.topLevelApplication.mainApp.stage.stageWidth;
	ClassroomContext.userDetails.stageHeight=FlexGlobals.topLevelApplication.mainApp.stage.stageHeight;
}
public function createFeedbackResultHandler(feedback:FeedbackVO):void
{
	if(context=="logout")
	{
		Alert.show("Thank you for your valuable feedback","Info",Alert.OK,null,closeFeedbackConfirm);
		PopUpManager.removePopUp(this);
	}
	else if(context=="close")
	{
		Alert.show("Thank you for your valuable feedback","Info",Alert.OK,null,closeFeedbackConfirm);
		PopUpManager.removePopUp(this);
	}
	else
	{
		Alert.show("Thank you for your valuable feedback","Info");
		closeFeedback();
		btnSubmit.enabled=true;
	}
}

private function closeFeedbackConfirm(event:CloseEvent):void
{
	if(event.detail == Alert.OK)
	{
		closeFeedback();
		btnSubmit.enabled=true;
	}
}