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
 * File			: ApplicationSharingModule.as
 * Module		: DesktopSharing
 * Developer(s)	: Ajith Kumar R, Remya T
 * Reviewer(s)	: Meena S
 *
 *ApplicationSharingModule.as is used to invoke JScrCap (third party component) for sharing applications and pass parameters to the JAR.
 *Also used for finding active applications list.
 *
 */
/** Platform specific script */
applicationType::desktop
{
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.desktopSharing.ActiveApplicationList;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;

import flash.events.Event;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.core.FlexGlobals;
//import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.utils.Base64Decoder;
//Fix for issue #16851 and #16852
/*import spark.collections.Sort;
import spark.collections.SortField;*/

/**
 * Variable for JScrCap library (JScrCapLib.swc).
 */
private var jscLibAppSharing:JScrCapLib;
/**
 * Variable for storing the screen resolution values.
 */
private var scrBounds:String;
/**
 * Variable for storing the details of active applications.
 */
private var activeProcessList:ArrayCollection;
/**
 * Variable for storing the name of selected applications.
 */
private var selectedApplication:ArrayCollection;
/**
 * Variable for storing the streaming server URL.
 */
private var applicationSharingServerURL:String;
/**
 * Variable for storing the stream name.
 */
private var applicationSharingStreamName:String;
/**
 * Variable for storing the decoded details of the active applications.
 */
private var base64Dec:Base64Decoder;
/**
 * Variable for storing the details of selected active applications for sharing.
 */
private var selectedActiveProcessList:String="";
//Fix for issue #16851 and #16852
/*[Bindable]
private var activeApps:ArrayCollection = new ArrayCollection();*/
/**
 * Variable of custom popup component 'ActiveApplicationList' for choosing the active applications for sharing.
 */
public var popUpDisplay:ActiveApplicationList;
/**
 * Variable for notifying user selection of stream color change.
 */
public var streamColorSelect:Boolean=true;
/**
 * @public
 * Function used for initialising parameters for JScrCap applet JAR(for application sharing).
 *
 *
 * @return void
 */
public function initApplicationSharing():void{
	//Fix for issue #15823
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			//Create a new instance of FlexJava Library
			jscLibAppSharing=new JScrCapLib();
			//Set the launcher jar of the jar sets
			jscLibAppSharing.setJar("thirdParty//desktopSharing//JSCSWLibRhino.jar");
			//Add event listener for JScrCap Event
			jscLibAppSharing.addEventListener(applicationSharingJSCEventHandler);
			//Add result listener to retrive the returns of JScrCap functions
			jscLibAppSharing.addResultListener(JSCResultApplicationSharing);
			//Add a closing event listener so jscrcap process will be terminated
			this.addEventListener(Event.CLOSING, closeApplicationSharing);
			//Fix for issue #16807
			scrBounds="0,0,1024,768";
			FlexGlobals.topLevelApplication.mainApp.operatingSystemName=flash.system.Capabilities.os;
			//PNCR:  Move the protocal constant to some global file  
			applicationSharingServerURL="rtmp://" + ClassroomContext.DESKTOP_SHARING_SERVER + ":" + ClassroomContext.portFMS + "/desktopsharing_module";
			if(ClassroomContext.aviewClass.classType=="Meeting")
			{
				applicationSharingStreamName = "myScreen_"+ClassroomContext.lecture.lectureId;
			}
			else
			{
				applicationSharingStreamName = "myScreen_"+ClassroomContext.aviewClass.className;
			}
			base64Dec=new Base64Decoder();
			// Start jscrcap process
			jscLibAppSharing.startJScrCap();
			//CursorManager.setBusyCursor();
		}
	}//Fix for issue #15823
	else{
		MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
		return;
	}
}

/**
 * @private
 * Event handler function for JScrCap JAR.
 *
 * @param oprt of type String
 * @param code of type String
 * @param desc of type String
 * @return void
 */
private function applicationSharingJSCEventHandler(oprt:String, code:String, desc:String):void{
	//If connection to FMS is fine then pass the appropriate command to JscrCap JAR control streaming
	//PNCR: Should use maximum constants instead of hardcoded strings.
	//Fix for issue #15591
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			if (oprt == "load"){
				jscLibAppSharing.sendCommand("get_desktoprect()");
				jscLibAppSharing.sendCommand("setConsoleName(\"SWLauncher\")");
				
				if (applicationSharingRestart == false) loadApplicationList();
				else{
					applicationSharingRestart=false;
					callDesktopSharing();
					//CursorManager.removeBusyCursor();
				}
			}
			else if (oprt.indexOf("MenuItem Clicked") != -1){
				if (code == "ScreenShare:StopPop") stopWinCap();
				else if (code == "ScreenShare:StopRemotePop") jscLibAppSharing.sendCommand("stopRemoteControl()");
				else if (code == "ScreenShare:StopThisWindowPop") jscLibAppSharing.sendCommand("stopSharingThisWindow(\"" + desc + "\")");
			}
			else if (oprt == "SkinButton Clicked"){
				if (code == "ScreenShare:Down") jscLibAppSharing.sendCommand("showPopupMenu(\"" + code + "\", \"" + desc + "\")");
				else if (code == "ScreenShare:Start") jscLibAppSharing.sendCommand("startSharingThisWindow(\"" + desc + "\")");
				else if (code == "ScreenShare:Stop") stopWinCap();
			}
			//PNCR: this line also should be an else if.
			if (oprt == "thread" && code == "stopped") callDesktopSharing();
		}
	}
}

/**
 * @private
 * Result handler function for JScrCap JAR.
 *
 * @param funcName of type String
 * @param result of type String
 * @return void
 */
private function JSCResultApplicationSharing(funcName:String, result:String):void{
	//Process the commands passed from JscrCap JAR file
	if (funcName.indexOf("get_desktoprect()") != -1) scrBounds=result;
	else if (funcName.indexOf("getApplicationsList()") != -1) createActiveApplicationList(result);
}

public function setColorApplicationSharing():void
{
	if(isDesktopSharingStarted)
	{
		startWinCap();
	}
}

/**
 * @public
 * Function used for start streaming the selected applications to the server.
 *
 *
 * @return void
 */
public function startWinCap():void{
	if(streamColorSelect)
	{
		streamColorSelect = false;
		var param:String;
		var pimg:String="";
		selectedActiveProcessList = "";
		//Fix for issue #16304 and #16520
		//To store the name of selected applications from the list
		selectedApplication = new ArrayCollection();
		//Take the details of the selected applications from the active application list for start capturing
		for (var i:int=0; i < popUpDisplay.appList.selectedIndices.length; i++)	{
			//Fix for issue #16304 and #16520
			selectedApplication.addItem(appList.dataProvider.getItemAt(popUpDisplay.appList.selectedIndices[i]).label);
			pimg=activeProcessList.getItemAt(popUpDisplay.appList.selectedIndices[i]).toString();
			pimg=pimg.replace(/%/g, "%25");
			pimg=pimg.replace(/\\/g, "%5c");
			pimg=pimg.replace(/&/g, "%26");
			selectedActiveProcessList+="&pimg:" + pimg;
		}
		//Assigning value to selectedColor for streaming video
		/*if(desktopSharingCollabObject.getData()["desktopColorQuality"] == null)
		{
			selectedColor = "5";
		}
		else
		{
			//Fixed for #18484
			selectedColor = desktopSharingCollabObject.getData()["desktopColorQuality"].quality;
		}*/
		param=applicationSharingServerURL + "+" + applicationSharingStreamName + "\\\\\\\\vsrc:screen:" + scrBounds + "\\\\vid:-svc2&bits:5\\\\vproc:WindowCapture" + selectedActiveProcessList;
		jscLibAppSharing.sendCommand("start_streaming(\"" + param + "\")");
		AuditContext.userAction.desktopSharingStartEventLog("Application", selectedActiveProcessList);
		//PNCR: use constant
		sendDesktopSharingStatus("started");
		//Fix for issue #20295
		var appListDataProvider : ArrayList = popUpDisplay.appList.dataProvider as ArrayList;
		//To store the selectedIndices of selected applications
		var appListIndices:Vector.<int> = new Vector.<int>();
		if(appListDataProvider != null && selectedApplication != null)
		{		
			for (var i:int=0; i < selectedApplication.length; i++)
			{
				for (var j:int=0; j < appListDataProvider.length; j++){
					if(appListDataProvider.source[j].label == selectedApplication[i])
					{
						appListIndices.push(j);
						break;
					}
				}
			}
			popUpDisplay.appList.selectedIndices = appListIndices;
		}
	//Start recording
	//if (recorder.isRecording) recorder.desktopRecorder.recordStream(desktopSharingConnection, "false", ClassroomContext.desktopSharingStreamName, ClassroomContext.desktopSharingStreamName, true);
	}
}

/**
 * @private
 * Function used for stop streaming to the server.
 *
 *
 * @return void
 */
private function stopWinCap():void{
	jscLibAppSharing.sendCommand("stop_streaming()");
}

/**
 * @private
 * Function for populating the active application list.
 *
 * @param list of type String
 * @return void
 */
private function createActiveApplicationList(list:String):void{
	if (appList.dataProvider == null) appList.dataProvider=new ArrayList();
	if (activeProcessList == null) activeProcessList=new ArrayCollection();
	appList.dataProvider.removeAll();
	activeProcessList.removeAll();
	//Fix for issue #16851 and #16852
	//Fix for issue #11924 and #13508
	//activeApps.removeAll();
	
	//Create the active applications list passed from JscrCap JAR
	var applist:Array=list.split("|JSC|");
	for (var i:int=0; i < applist.length; i++){
		var attr:Array=applist[i].toString().split(",");
		var s:int;
		var e:int;
		var pname:String;
		if (FlexGlobals.topLevelApplication.mainApp.operatingSystemName.toUpperCase().indexOf("WIN") != -1){
			s=attr[0].toString().lastIndexOf("\\");
			e=attr[0].toString().toLowerCase().indexOf(".exe");
		}
		else{
			s=attr[0].toString().lastIndexOf("/");
			e=attr[0].toString().toLowerCase().indexOf(".app");
		}
		if (s >= 0 && e < 0) pname=attr[0].toString().substr(s + 1);
		else if (s >= 0 && e > s) pname=attr[0].toString().substring(s + 1, e);
		activeProcessList.addItem(attr[0].toString());
		
		var appName:String=pname.charAt(0).toUpperCase() + pname.substr(1);
		base64Dec.decode(attr[1].toString());
		var imgBA:ByteArray=base64Dec.toByteArray();
		var item:Object=new Object();
		item.label=appName;
		item.ico=imgBA;
		
		appList.dataProvider.addItem(item);
		//Fix for issue #11924 and #13508
		//Fix for issue #16851 and #16852
		//activeApps.addItem(item);
	}
	
	appList.visible=true;
	//Fix for issue #11924 and #13508
	//Fix for issue #16851 and #16852
	/*var sortA:Sort = new Sort();
	sortA.fields=[new SortField("label")];
	activeApps.sort=sortA;
	//Refresh the collection view to show the sort.
	activeApps.refresh();*/
	//Create popup for showing the active application list
	//Fix for issue #15919 and #16268
	popUpDisplay.appList.dataProvider=appList.dataProvider;
	//Fix for issue #16304 and #16520
	var appListDataProvider : ArrayList = popUpDisplay.appList.dataProvider as ArrayList;
	//To store the selectedIndices of selected applications
	var appListIndices:Vector.<int> = new Vector.<int>();
	if(appListDataProvider != null && selectedApplication != null)
	{		
		for (var i:int=0; i < selectedApplication.length; i++)
		{
			for (var j:int=0; j < appListDataProvider.length; j++){
				if(appListDataProvider.source[j].label == selectedApplication[i])
				{
					appListIndices.push(j);
					break;
				}
			}
		}
		popUpDisplay.appList.selectedIndices = appListIndices;
	}
}

/**
 * @private
 * Function for creating popup for displaying the active application list.
 *
 * @return void
 */
public function createActiveApplicationListPopUp():void{
	popUpDisplay=new ActiveApplicationList();
	popUpSharingMode.hgOptionsContainer.visible= true;
	popUpSharingMode.hgOptionsContainer.includeInLayout= true;
	popUpSharingMode.hgOptionsContainer.addElement(popUpDisplay);
	popUpDisplay.appList.dataProvider=appList.dataProvider;	
}

/**
 * @private
 * Function used for stopping application sharing.
 *
 * @param event of type Event
 * @return void
 */
private function closeApplicationSharing(event:Event):void{
	stopApplicationSharing();
}

/**
 * @public
 * Function used for stopping application sharing.
 *
 * @return void
 */
public function stopApplicationSharing():void{
	try	{
		//If the current user is a presenter then stop application sharing
		//PNCR: Constant for stopped
		if (getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE) sendDesktopSharingStatus("stopped");
		//Fix for issue #15746
		if(jscLibAppSharing){
			//Fix for issue #15844
			isDesktopSharingStarted=false;
			jscLibAppSharing.stopJScrCap();
		}
		/*if (recorder.isRecording) recorder.desktopRecorder.addEndtime(recorder.getCentralTime(), recorder.desktopRecorder.streamsInfo[0].streamName, false);
		AuditContext.userAction.desktopSharingEndEventLog("Application", selectedActiveProcessList);*/
	}
	catch (e:Error){
		if(Log.isError()) log.error("Error in stopApplicationSharing method:"+ e.getStackTrace());
	}
	//Fix for issue #18173
	if(selectedSharingMode == 0 && selectedApplication != null) {
		selectedApplication.removeAll();
	}
	//Fix for issue #19022
	streamColorSelect = true;
}

/**
 * @private
 * Function for sending command to JscrCap JAR for populating the active application list.
 *
 * @return void
 */
private function loadApplicationList():void{
	jscLibAppSharing.sendCommand("getApplicationsList()");
}
}
