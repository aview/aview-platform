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
 * File			: DesktopSharingModule.as
 * Module		: DesktopSharing
 * Developer(s)	: Ajith Kumar R
 * Reviewer(s)	: Meena S
 *
 *DesktopSharingModule.as is used to invoke JScrCap (third party component) for sharing desktop and pass parameters to it.
 *Also used for controlling the DesktopViewer popup window component.
 *
 */
applicationType::DesktopMobile{
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
applicationType::desktop{
	import edu.amrita.aview.core.desktopSharing.DesktopPlayer;
	import edu.amrita.aview.core.desktopSharing.DesktopViewer;
}
applicationType::mobile{
	import edu.amrita.aview.core.desktopSharing.MobileDesktopViewer;
	import edu.amrita.aview.core.shared.components.mobileComponents.FullScreenLabel;
}
import edu.amrita.aview.core.desktopSharing.SharingMode;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditContext;

import flash.display.StageDisplayState;
import flash.events.AsyncErrorEvent;
import flash.system.Capabilities;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;

/**
 * Variable for passing capture resolution to JscrCap JAR,default value is set as the current screen resolution.
 */
private var selectedSize:String=(Capabilities.screenResolutionX - 8) + "," + (Capabilities.screenResolutionY - 8);
/**
 * Variable for passing bandwidth option (based on colour) to JscrCap JAR.
 */
private var selectedColor:String;
/**
 * Variable for JScrCap library (JScrCapLib.swc).
 */
private var jscLib:JScrCapLib;
/**
 * Variable for storing the screen resolution values.
 */
private var frameSettings:String;
/**
 * Variable for storing the screen resolution values.
 */
private var noFrameSettings:String;
/**
 * Variable for storing the xml control values.
 */
private var xmlControl:String;
/**
 * Variable for storing the desktopsharing intraction status.
 */
public var isUnInterruptedDesktopSharingON:Boolean=false;
/**
 * Variable for storing streaming color quality for desktop sharing video.
 */
//public var desktopColorQuality:int = 3;
/**
 * Variable for creating the FMS connection used for desktopsharing recording.
 */
public var desktopSharingConnection:MediaServerConnection;
/**
 * Variable of custom popup window component 'DesktopPlayer' for viewing desktop stream.
 */
applicationType::DesktopWeb{
	public var desktopViewer:DesktopViewer = new DesktopViewer();
}
applicationType::mobile{
	public var desktopViewer:MobileDesktopViewer = new MobileDesktopViewer();
}

/**
 * Variable for storing the open status of popup window component 'DesktopViewer' for viewing desktop stream.
 */
public var desktopViewerWindowOpenFlag:Boolean=false;
/**
 * Variable for storing the status of desktop sharing,whether it is started or not.
 */
public var isDesktopSharingStarted:Boolean=false;

/**
 * Variable for storing the sharing mode (0-Desktop,1-Application) selected from the SharingMode popup.
 */
public var selectedSharingMode:uint=0;
/**
 * Variable of confirmation alert before stopping desktop sharing.
 */
public var stopSharingConfirmationAlert:Alert;

/**
 * @public
 * Function used for initialising parameters for JScrCap applet JAR(for desktop sharing).
 * Also for starting desktop sharing.
 *
 *
 * @return void
 */
public function callDesktopSharing():void{
	//Fix for issue #16050
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			//Desktopsharing stream name
			ClassroomContext.desktopSharingStreamName="myScreen_" + ClassroomContext.aviewClass.className;
			
			//Start desktop sharing
			if (selectedSharingMode == 0){
				initDesktopSharing();
			}
				//Start application sharing
			else if (selectedSharingMode == 1){
				applicationType::DesktopWeb {
					startWinCap();
				}
			}
			isDesktopSharingStarted=true;
			//Fix for issue #15333
			enableDisableControls(false);
		}
	}
	else
	{
		MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
		return;
	}
}

/**
 * @private
 * Function used for enable/disable desktop sharing controls.
 *
 *
 * @return void
 */
//Fix for issue #15333
private function enableDisableControls(isEnable:Boolean):void{
	applicationType::desktop {
		//Fix for issue #18195
		if(popUpSharingMode && popUpSharingMode.btnStopSharing) {
			popUpSharingMode.btnStopSharing.enabled=!isEnable;
			popUpSharingMode.btnStartSharing.enabled= isEnable;
			//Fix for issue #20277
			popUpSharingMode.rbgSelectedSharingMode.enabled= isEnable;
		}
		//Fix for issue #15313
		if(popUpDisplay && popUpDisplay.appList){
			popUpDisplay.appList.enabled = isEnable;
			//Fix for issue #16280
			popUpDisplay.btnRefresh.enabled=isEnable;
		}
	}
}

/**
 * @public
 * Function used for stopping desktop sharing.
 *
 *
 * @return void
 */
public function stopSharing():void{
	isDesktopSharingStarted=false;
	//Stop desktop sharing
	if (selectedSharingMode == 0){
		closeDesktopSharing();
	}
	//Stop application sharing
	else if (selectedSharingMode == 1){
		applicationType::DesktopWeb {
			stopApplicationSharing();
		}
	}
	CursorManager.removeBusyCursor();
	//Fix for issue #15333
	enableDisableControls(true);
}

/**
 * @public
 * Stop button click handler used for stopping desktop sharing.
 *
 *
 * @return void
 */
//Fix for issue #15591
public function stopDesktopSharing():void{
	applicationType::desktop {
		//Fix for issue #15719
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection){
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
				stopSharing();	
				streamColorSelect = true;
				//Fix for issue #15332
				if (selectedSharingMode == 1){
					applicationType::DesktopWeb {
						//Fix for issue #15919 and #16268
						initApplicationSharing();
					}
				}
			}
		}
	}
}
//Fix for issue #16150
public function refreshAppList():void{
	applicationType::DesktopWeb {
		//Fix for issue #16269
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection){
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
				if(popUpDisplay){
					stopApplicationSharing();
				}
				if(selectedApplication != null && selectedApplication.length != 0)
				{
					//Fix for issue #18230
					selectedApplication.removeAll();
				}
				initApplicationSharing();
			}
		}		
		else
		{
			MessageBox.show("Your connection to server is lost. Please wait till it reconnects automatically.", "WARNING", MessageBox.MB_OK, this);
			return;
		}
	}
}

/**
 * @public
 * The function is used to set the status of uninterrupted desktop sharing to shared object.
 *
 *
 * @return void
 */
public function setUninterruptedDesktopSharingStatusToCollabObject():void{
	applicationType::desktop {
		//Set the status of uninterrupted desktop sharing to shared object according to the toggle button
		//PNCR: use constant for unInterruptedDesktopSharing
		if (prefSettings.prefDesk.chkBoxDesktopSharingInteraction.selected){
			isUnInterruptedDesktopSharingON=true;
			desktopSharingCollabObject.setValue("unInterruptedDesktopSharing", "ON");
		}
		else{
			//Fix for issue #19376
			if(selectedModulle != 5 && isDesktopSharingStarted)
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unInterruptedDesktopSharingOFFMessage();
				stopSharing();
			}
			isUnInterruptedDesktopSharingON=false;
			desktopSharingCollabObject.setValue("unInterruptedDesktopSharing", "OFF");
		}
		AuditContext.userAction.changePrefUninterruptedDesktopSharingEventLog(prefSettings.prefDesk.chkBoxDesktopSharingInteraction.selected ? "On" : "Off");
	}
}

/**
 * @public
 * The function is used to set the color quality of desktop sharing screen video to shared object.
 *
 *
 * @return void
 */
public function setDesktopSharingScreenQualityToCollabObject():void{
	applicationType::desktop {
		//Fixed for #18484
        var obj:Object=new Object;
		obj.index=prefSettings.prefDesk.videoQualityList.selectedIndex;
		obj.quality=prefSettings.prefDesk.colorQualityOption[prefSettings.prefDesk.videoQualityList.selectedIndex].value;
		if(prefSettings.prefDesk.videoQualityList.selectedIndex == "0") {
			obj.videoQuality = " ";
		}
		else {
			obj.videoQuality = "bitrate:"+obj.quality;
		}
		desktopSharingCollabObject.setValue("desktopColorQuality", obj);
	}
}

/**
 * @private
 * Function used for initializing JScrCap library file,add event listeners and set default values.
 *
 *
 * @return void
 */
private function initDesktopSharing():void{
	try{
		jscLib=new JScrCapLib();
		jscLib.setJar("thirdParty//desktopSharing//JSCUI5LibRhinoWrapper.jar");
		jscLib.addEventListener(desktopSharingJSCEventHandler);
		jscLib.addResultListener(desktopSharingJSCResultHandler);
		frameSettings="11,4,8421504,16753920,320x240,1920x1200";
		noFrameSettings="0,4,8421504,16753920,320x240,1920x1200";
		xmlControl="<panel size=\"0,0\"></panel>";
		startJScrCap();
	}
	catch (e:Error)	{
		if(Log.isError()) log.error("Java not found:"+ e.getStackTrace());
	}
}

/**
 * @private
 * Function used for setting server URL and encoding parameters.
 *
 * @return String
 */
private function getStreamConfig():String{
	//Create the FMS URL for streaming
	//var svr:String=ClassroomContext.protocolFMS + "://" + ClassroomContext.DESKTOP_SHARING_SERVER + ":" + ClassroomContext.portFMS + "/desktopsharing_module" + "+myScreen_" + ClassroomContext.aviewClass.className;
	var svr:String =null;
	if(ClassroomContext.aviewClass.classType=="Meeting")
	{
		svr=ClassroomContext.protocolFMS+"://"+
			ClassroomContext.DESKTOP_SHARING_SERVER +":"+
			ClassroomContext.portFMS+"/desktopsharing_module"+"+myScreen_"+ClassroomContext.lecture.lectureId;
	}
	else
	{
		svr=ClassroomContext.protocolFMS+"://"+
			ClassroomContext.DESKTOP_SHARING_SERVER +":"+
			ClassroomContext.portFMS+"/desktopsharing_module"+"+myScreen_"+ClassroomContext.aviewClass.className;
	}
	//Assigning value to selectedColor for streaming video
	if(desktopSharingCollabObject.getData()["desktopColorQuality"] == undefined)
	{
		//Fix for issue #17659
		selectedColor=" ";
	}
	else
	{
		//Fixed for #18484
		selectedColor=desktopSharingCollabObject.getData()["desktopColorQuality"].videoQuality;
	}
	var vsrc:String="vsrc:screen:4,4," + selectedSize + "&showmouse:1";
	var vid:String="vid:-svc2&"+selectedColor+"&bits:5";
	//Fix for issue #19337 
	return "\"0\", \"" + svr + "\\\\\\\\" + vsrc + "\\\\" + vid + "\"";
}

/**
 * @private
 * Event handler function for  JScrCap JAR.
 *
 * @param oprt of type String
 * @param code of type String
 * @param desc of type String
 * @return void
 */
//PNCR: function description is not claer. Please describe what it is doing.
private function desktopSharingJSCEventHandler(oprt:String, code:String, desc:String):void{
	//Handle the commands passed from JscrCap JAR
	if (oprt == "load"){
		jscLib.sendCommand("get_desktoprect()");
		startStreaming();
	}
	else if (oprt == "frame_bounds"){
		if (desc.indexOf("move") != -1 || desc.indexOf("resize") != -1){
			jscLib.sendCommand("move_area(\"" + code + "\")");
		}
	}
}

/**
 * @public
 * To Start the shared video with selected color quality.
 *
 * @return void
 */
public function setColorDesktopSharing():void
{
	if(isDesktopSharingStarted)
	{
		startStreaming();
	}
	//Fix for issue #20303
	if(desktopSharingCollabObject.getData()["desktopColorQuality"] == undefined)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex = '0';
	}
	else
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.deskPreference.videoQualityList.selectedIndex = desktopSharingCollabObject.getData()["desktopColorQuality"].index;
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
private function desktopSharingJSCResultHandler(funcName:String, result:String):void{
	//Handle the command passed from JscrCap JAR
	if (funcName.indexOf("get_desktoprect()") != -1){
		var w:int=parseInt(result.split(",")[2]);
		var h:int=parseInt(result.split(",")[3]);
		selectedSize=(w - 8) + "," + (h - 8);
	}
}

/**
 * @private
 * Function used to start JScrCap JAR.
 *
 *
 * @return void
 */
private function startJScrCap():void{
	jscLib.startJScrCap();
	CursorManager.setBusyCursor();
	AuditContext.userAction.desktopSharingStartEventLog("Desktop", null);
}

/**
 * @private
 * Function used for start streaming captured desktop to the server.
 *
 * @return void
 */
private function startStreaming():void{
	//Fix for issue #15199
	CursorManager.removeBusyCursor();
	jscLib.sendCommand("update_frame(\"11,4,8421504,16753920,320x240,1920x1200\", \"4,4," + selectedSize + "\")");
	jscLib.sendCommand("update_controls(\"<panel size=\\\"0,0\\\"></panel>\")");
	var streamCfg:String=getStreamConfig();
	jscLib.sendCommand("start_streaming(" + streamCfg + ")");
	//PNCR: use constant for started
	sendDesktopSharingStatus("started");
	
	//For start recording
	/*if (recorder.isRecording){
		recorder.desktopRecorder.recordStream(desktopSharingConnection, "false", ClassroomContext.desktopSharingStreamName, ClassroomContext.desktopSharingStreamName, true);
	}*/
}

/**
 * @public
 * Function used for setting desktopsharing status (started/stopped) to shared object.
 * The sync handler of the sharedobject will notify the new status to all connected nodes.
 *
 * @param status of type String
 * @return void
 */
public function sendDesktopSharingStatus(status:String):void{
	var obj:Object=new Object;
	obj.user=ClassroomContext.userVO.userName;
	obj.status=status;
	//PNCR: use constant
	desktopSharingCollabObject.setValue("desktopSharing", obj);
}

/**
 * @private
 * Function used for stop streaming captured desktop to the server.
 *
 *
 * @return void
 */
private function stopStreaming():void{
	//Fix for issue #15199
	jscLib.sendCommand("stop_streaming()");
	jscLib.sendCommand("update_frame(\"0,4,8421504,16753920,320x240,1920x1200\", \"0,0,320,240\")");
	//If current user is presenter then stop streaming
	if (getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE){
		//PNCR: use constant
		sendDesktopSharingStatus("stopped");
		/*if (recorder.isRecording){
			recorder.desktopRecorder.addEndtime(recorder.getCentralTime(), recorder.desktopRecorder.streamsInfo[0].streamName, false);
		}*/
	}
}

/**
 * @private
 * Function used for stop streaming captured desktop to the server.
 *
 * @return void
 */
//PNCR: do not require an extra function, only to call a function. 
private function stopJScrCap():void{
	stopStreaming();
}

/**
 * @public
 * Function used for stopping desktop sharing when application get closed.
 *
 * @return void
 */
public function closeDesktopSharing():void{
	//Fix for issue #15199
	try{
		//If current user is presenter then stop sharing
		if (getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE){
			//Setting new status to sharedobject
			//PNCR: use constant
			sendDesktopSharingStatus("stopped");
			//Fix for issue #15844
			isDesktopSharingStarted=false;
			//For stop recording
			/*if (recorder.isRecording){
				recorder.desktopRecorder.addEndtime(recorder.getCentralTime(), recorder.desktopRecorder.streamsInfo[0].streamName, false);
			}*/
			//PNCR: use constant
			AuditContext.userAction.desktopSharingEndEventLog("Desktop", null);
		}
		if(jscLib)
			jscLib.stopJScrCap();
	}
	catch (e:Error)	{
		if(Log.isError()) log.error("Error in closeDesktopSharing method:"+ e.getStackTrace());
	}
	
}

/**
 * @public
 * Function used for viewing the shared desktop stream.
 *
 * @param isStreamAvailable of type Boolean
 * @return void
 */
public function viewDesktop(isStreamAvailable:Boolean,capRect:String):void{
	//capRect is used to set the width and size of the swfloader in player
	var rectArray:Array=capRect.split(",");
	
	//Show the desktop player window
	if (isRefreshPressed == false){
		if (isStreamAvailable == false && desktopViewer.isDesktopPlayerCreated == false){
			Alert.show("Presenter has not started Desktop sharing!!!", "INFO");
			return;
		}
		
		if (isStreamAvailable == true ){
			desktopViewer.host = ClassroomContext.DESKTOP_SHARING_SERVER;
			desktopViewer.port = Constants.FMS_SERVER_PORT.toString();
			//Fix for issue #15604
			desktopViewer.lblSharingMessage.visible=false;
			desktopViewer.displayPlayer(rectArray[2], rectArray[3]);				
		}
		else{
			desktopViewer.removePlayer();
			//If DesktopViewer popup component is in fullscreen,then change to normal mode
			//Fix for issue #15858
			if (desktopViewer.stage && desktopViewer.isFullScreen){
				if (desktopViewer.stage.displayState == StageDisplayState.FULL_SCREEN){
					desktopViewer.toggleFullScreen();
				}
			}
			//Fix for issue #15604 and Fix for issue #15864
			if(desktopViewer && desktopViewer.lblSharingMessage != null)
				desktopViewer.lblSharingMessage.visible=true;
		}
	}
}

/**
 * @private
 * Function used for creating the popup window (DesktopPlayer) for viewing the shared desktop stream.
 *
 *
 * @return void
 */
public function createDesktopViewer():void{
	//If desktop sharing module is enabled,then create desktop player window
	if (!ClassroomContext.IS_DESKTOP_SHARING_ENABLED)
		return;
	if(!desktopSharingComp.contains(desktopViewer)){
		desktopSharingComp.addElement(desktopViewer);
		desktopViewerWindowOpenFlag=true;
		desktopViewer.initDesktopPlayer();
	}
}

/**
 * @private
 * Function used for closing the desktopviewer window when application get closed.
 *
 * @return void
 */
private function closeDesktopViewer():void{
	//Close the desktop player window 
	applicationType::desktop{
		if (desktopViewer.desktopSharingWindow && desktopViewer.desktopSharingWindow.stage != null){
			desktopViewer.desktopSharingWindow.stage.nativeWindow.close();
		}
	}
}


/**
 * @public
 * Function used for creating the FMS connection used for desktopsharing recording.
 *
 * @return void
 */
public function createDesktopSharingConnection():void{
	var connectionParams:ArrayList = new ArrayList();
	connectionParams.addItem(ClassroomContext.userVO.userName);
	
	desktopSharingConnection=new MediaServerConnection(ClassroomContext.DESKTOP_SHARING_SERVER,"desktopsharing_module",null,connectionParams,this);
	desktopSharingConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, desktopSharingConnectionStatusHandler);
}

/**
 * @public
 * AsyncErrorEvent handler function for desktopsharing connection.
 * This function is left blank.
 *
 * @param event of type AsyncErrorEvent
 * @return void
 */
public function desktopSharingAsyncErrorHandler(event:AsyncErrorEvent):void{
}

/**
 * @public
 * MediaServerStatusEvent handler function for desktopsharing connection.
 * This function is left blank.
 *
 * @param event of type MediaServerStatusEvent
 * @return void
 */
public function desktopSharingConnectionStatusHandler(event:MediaServerStatusEvent):void{
	switch(event.code)
	{
		case MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED:
			 MessageBox.show("Connection to the Desktop Sharing server failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", "Connection Failed", MessageBox.MB_OK, null, closeDesktopSharing);
			 break;
		case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
			AuditContext.userAction.connectionSuccessEventLog("DesktopSharing", ClassroomContext.DESKTOP_SHARING_SERVER,desktopSharingConnection.connectionRetrys+"");
			break;
		
		case MediaServerStatusEvent.CODE_COULD_NOT_RECONNECT:
			MessageBox.show("Connection retrys to the Desktop Sharing server are failed.", "Connection Failed", MessageBox.MB_OK, null, closeDesktopSharing);
			break;
		
		case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
			AuditContext.userAction.connectionRejectEventLog("DesktopSharing", ClassroomContext.DESKTOP_SHARING_SERVER);
			connectionRejectedHandler();					
			break;

		case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
			AuditContext.userAction.connectionCloseEventLog("DesktopSharing", ClassroomContext.DESKTOP_SHARING_SERVER);
			break;
		// To check for the network cable loss or wireless disconnection
		case MediaServerStatusEvent.CODE_NET_STATUS_CHANGE:
		case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
			AuditContext.userAction.connectionFailEventLog("DesktopSharing", ClassroomContext.DESKTOP_SHARING_SERVER);
			break;
	}
}

/**
 * @public
 * This function is used for setting the desktopsharing recording status.
 *
 * @param obj of type Object
 * @return void
 */
public function recordingStatus(obj:Object):void{
	//Set the desktopsharing recording status
	if (obj != null){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.desktopRecorder.recordingStatus(obj);
	}
}
/**
 * @private
 * This function is used as the confirmation handler for stopping desktop/application sharing.
 *
 * @param event of type CloseEvent
 * @return void
 */
private function stopSharingConfirmationHandler(event:CloseEvent):void{
	//If YES button is pressed & FMS connection is fine then stop sharing
	if (event.detail == Alert.YES){
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected){
			Alert.show("Your connection to server is lost. Please try after successfull reconnection.", "WARNING");
			return;
		}
		callDesktopSharing();
	}
}
}