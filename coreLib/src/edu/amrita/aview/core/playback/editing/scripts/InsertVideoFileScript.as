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
 * File			: InsertVideoFileScript.as
 * Module		: Video Editing
 * Developer(s)	: Ashish Pillai
 * Reviewer(s)	: Remya T
 *
 * File contains the functionalities for driver validation and publishing the video to server.
 *
 */
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.playback.editing.scripts.CloseFileHandler;

import flash.media.Camera;
import flash.media.Microphone;
import flash.media.scanHardware;
import flash.system.Capabilities;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

/**
 * Variable holds the camera device choosen from dropdownlist.
 */
public var selectedCameraDeviceName:String=null;

/**
 * Variable holds the microphone device choosen from dropdownlist.
 */
public var selectedMicrophoneDeviceName:String=null;

/**
 * Array holds the camera driver names.
 */
private var arCameraDrivers:Array;

/**
 * Array holds the microphone driver names.
 */
private var arMicroPhoneDrivers:Array;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.playback.editing.scripts.InsertVideoFileScript.as");

/**
 * @private
 * Function attaches the dataproviders to combobox.
 *
 * @param void
 * @return void
 */
private function init():void{
	try{
		// Checks the flag based on OS. Since the functionality is not common for all OS.
		if (Capabilities.os.toLowerCase().indexOf("win") > -1){
			if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag){
				scanHardware();
			}
		}
	}
	catch (e:Error){
		if(Log.isError()) log.error("Error in init method in InsertVideoFileScript:"+ e.getStackTrace());
	}
	arCameraDrivers=Camera.names;
	//Exclude known desktop capturing drivers like 'Screencamera' and 'UscreenCapture' from the video driver list.
	for (var i:int=0; i < arCameraDrivers.length; i++){
		if (arCameraDrivers[i] == "UScreenCapture" || arCameraDrivers[i] == "ScreenCamera HR" || arCameraDrivers[i] == "ScreenCamera Video Camera"  || arCameraDrivers[i] == "ScreenCamera IM Device")
			arCameraDrivers.splice(i, 1);
	}
	arMicroPhoneDrivers=Microphone.names;
	arCameraDrivers.unshift(Constants.VIDEO_SELECT_PROMPT);
	arMicroPhoneDrivers.unshift(Constants.MICROPHONE_SELECT_PROMPT);
	cmbCameraSelect.dataProvider=arCameraDrivers;
	cmbMicrophoneSelect.dataProvider=arMicroPhoneDrivers;
}

/**
 * @private
 * Function dispatches the close event and removes the pop up.
 *
 * @param void
 * @return void
 */
private function cancel():void{
	var objCloseFileHandler:CloseFileHandler=new CloseFileHandler(CloseFileHandler.CLOSED_VIDEO_SETTING);
	this.dispatchEvent(objCloseFileHandler);
	PopUpManager.removePopUp(this);
}

/**
 * @private
 * Function checks the availability of audio/video drivers.
 * Stores the selected device names.
 *
 * @param void
 * @return void
 */
private function ok():void{
	if (arCameraDrivers.length == 0 && arMicroPhoneDrivers.length == 0){
		Alert.show("No Camera\Audio Devices Detected!\nPlease check your Camera\Audio Devices", "   Hardware Error", Alert.OK, this);
	}
	else if (arCameraDrivers.length == 0){
		Alert.show("No Camera Detected!\nPlease plugin a Camera & refresh the Application", "   Hardware Error", Alert.OK, this);
	}
	else if (arMicroPhoneDrivers.length == 0){
		Alert.show("No Audio Devices Detected!\nPlease check your audio devices", "   Hardware Error", Alert.OK, this);
	}
	else{
		selectedCameraDeviceName=cmbCameraSelect.selectedItem.toString();
		selectedMicrophoneDeviceName=cmbMicrophoneSelect.selectedItem.toString();
		cancel();
	}
}