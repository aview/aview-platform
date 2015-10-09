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
 * File		    : CameraSelectionFormHandler.as
 * Module		: Biometric
 * Developer(s) :  Jerald P
 * Reviewer(s)	: Ramesh Guntha
 * This component invoked when user select Biometric login.
 * This component is used to select the apropriate camera for login.
 */
import edu.amrita.aview.biometric.BiometricConstants;

import flash.media.Camera;
import flash.media.scanHardware;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;

/**
 * Collection camera names Array
 */
[Bindable]
private var cameraNames:ArrayCollection;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.biometric.CameraSelectionFormHandler.as");

/**
 * @public
 * This funtion used for initialization
 * @return void
 */
public function init():void
{
	if (Log.isDebug()) log.debug("Biometric::CameraSelectionForm::init");
	FlexGlobals.topLevelApplication.mainApp.selectionMode=null;
	btnOk.setFocus();
	if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag)
	{
		scanHardware();
	}
	cameraNames=new ArrayCollection(Camera.names);
	//PNCR: use conditional operator
	if (Camera.names.length > 1)
	{
		cameraList.selectedIndex=1;
	}
	else
	{
		cameraList.selectedIndex=0;
	}
}

/**
 * @public
 * This Function used for get the camera name
 * @return void
 */
public function getCameraName():void
{
	if (Log.isDebug()) log.debug("Biometric::CameraSelectionForm::getCameraName");
	//Camera name selected from camera list
	if ((cameraList.selectedItem != null) && (cameraList.selectedItem != ""))
	{
		FlexGlobals.topLevelApplication.mainApp.cameraName=cameraList.selectedIndex;
		FlexGlobals.topLevelApplication.mainApp.selectionMode=BiometricConstants.OK; //"ok"
		PopUpManager.removePopUp(this);
	}
	else
	{
		Alert.show(this.resourceManager.getString('myResource', 'biometric.plsSelValidCam'), this.resourceManager.getString('myResource', 'biometric.deviceErr'));
	}

}

/**
 * @public
 * This function used for cancel the camera selection window
 * @return void
 */
public function cancelCameraSelection():void
{
	if (Log.isDebug()) log.debug("Biometric::CameraSelectionForm::cancelCameraSelection");
	FlexGlobals.topLevelApplication.mainApp.selectionMode=BiometricConstants.CANCEL; //"cancel";
	PopUpManager.removePopUp(this);
}

/**
 * @public
 * This function used for refresh the camara list
 * @return void
 */
public function refreshCameraList():void
{
	if (Log.isDebug()) log.debug("Biometric::CameraSelectionForm::refreshCameraList");
	if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag)
	{
		scanHardware();
	}
	cameraNames.removeAll();
	for (var i:int=0; i < Camera.names.length; i++)
	{
		cameraNames.addItem(Camera.names[i])
	}
	cameraNames.refresh();
	//PNCR: use conditional operator
	if (Camera.names.length > 1)
	{
		cameraList.selectedIndex=1;
	}
	else
	{
		cameraList.selectedIndex=0;
	}
}
