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
File		: FaceRegistrationFormHandler.as
Module		: Biometric
Developer(s): Jerald P
Reviewer(s)	: Ramesh Guntha

This component invoked when user select Biometric login.
This component used for face registration.
*/
import edu.amrita.aview.biometric.BiometricConstants;
import edu.amrita.aview.biometric.CameraSelectionForm;
import edu.amrita.aview.biometric.DeleteConfirmationForm;
import edu.amrita.aview.biometric.ErrorReportForm;
import edu.amrita.aview.biometric.RegistrationConfirmationForm;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.ActivityEvent;
import flash.events.Event;
import flash.media.Camera;
import flash.media.Video;
import flash.media.scanHardware;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.graphics.codec.PNGEncoder;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;

/**
 * For user id
 */
public var userID:int;
/**
 * For server IP
 */
public var serverIP:String;
/**
 * For sql
 */
[Bindable]
public var sql:String;
/**
 * For database name
 */
[Bindable]
private var database:String=BiometricConstants.DATABASE_NAME;
/**
 * For collection of result Array
 */
[Bindable]
private var result:ArrayCollection=new ArrayCollection;
/**
 * For template ID
 */
//RGCR: Why can't this be an array of ids?
private var templateID0:int;
private var templateID1:int;
private var templateID2:int;
private var templateID3:int;
private var templateID4:int;
/**
 * For image data array
 */
//RGCR: Why can't this be an array of ByteArrays?
private var imageData0:ByteArray;
private var imageData1:ByteArray;
private var imageData2:ByteArray;
private var imageData3:ByteArray;
private var imageData4:ByteArray;
/**
 * Face image id
 */
private var faceImageID:String;
/**
 * For camera class instance creation
 */
private var camera:Camera;
/**
 * For delete image icon
 */
[Embed(source="assets/images/DeleteRed.png")]
/**
 * For delete face icon
 */
[Bindable]
public var deleteFaceIcon:Class;
/**
 * For video object
 */
private var video:Video;
/**
 * For camera activation state
 */
private var cameraActivation:Boolean=false;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.biometric.FaceRegistrationFormHandler.as");

/**
 * @public
 * This funtion used for initialization
 */
public function init():void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::init");
	btnRegister.setFocus();
	CursorManager.removeBusyCursor();
	retrieveRegisteredFaces();
}

/**
 * @public
 * This funtion used for video display.
 */
public function videoDisplaySetting():void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::videoDisplaySetting");
	var newPopUp:CameraSelectionForm=CameraSelectionForm(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, CameraSelectionForm, true));
	newPopUp.addEventListener(FlexEvent.REMOVE, cameraCloseHandler);
	PopUpManager.centerPopUp(newPopUp as mx.core.IFlexDisplayObject);
	
}

/**
 * @public
 * This funtion used for camera close event handler. 
 * @param event of type Event
 */
public function cameraCloseHandler(event:Event):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::cameraCloseHandler");
	if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag)
	{
		scanHardware();
	}
	// Check Camera selection is ok then get the camera name  
	if (FlexGlobals.topLevelApplication.mainApp.selectionMode == BiometricConstants.OK) //"ok")
	{
		camera=Camera.getCamera(FlexGlobals.topLevelApplication.mainApp.cameraName);
		// Get Camera name and set the frame size as 640 x 480
		if (camera != null)
		{
			camera.setMode(640, 480, 15, true);
			faceImage.attachCamera(camera);
			camera.addEventListener(ActivityEvent.ACTIVITY, activationHandler);
		} //Camera name is null then return message as camera not detected.
		else
		{
			Alert.show(this.resourceManager.getString('myResource', 'biometric.camNotDetected') + "\n" + this.resourceManager.getString('myResource', 'biometric.camThroughtCamSetting'), this.resourceManager.getString('myResource', 'biometric.deviceErr'));
		}
	}
}

/**
 * @private
 * This funtion used for camera activation event handler 
 * @param activityEvent of type ActivityEvent
 */
private function activationHandler(activityEvent:ActivityEvent):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::activationHandler");
	cameraActivation=true;
}

/**
 * @public 
 * This funtion used for detect facial features extractor
 * @param displayComponent of type DiaplayObject
 */
public function detectFacialFeatures(displayComponent:DisplayObject):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::detectFacialFeatures");
	// Check the camera selected or not 
	if ((FlexGlobals.topLevelApplication.mainApp.cameraName != null))
	{
		if (FlexGlobals.topLevelApplication.mainApp.scanHardwareEnableFlag)
		{
			scanHardware();
		}
		// Get the selected camera existing or not
		if (Camera.getCamera(FlexGlobals.topLevelApplication.mainApp.cameraName) != null)
		{
			// check whether the camera is used by another application.
			// Captured image send to server and extract the facial features 
			if (cameraActivation)
			{
				CursorManager.setBusyCursor();
				btnRegister.enabled=false;
				var bitmapData:BitmapData=new BitmapData(displayComponent.width, displayComponent.height, true, 0xffffff);
				bitmapData.draw(displayComponent);
				
				var pngEncoder:PNGEncoder=new PNGEncoder();
				var imageData:ByteArray=pngEncoder.encode(bitmapData);
				var encoder:Base64Encoder=new Base64Encoder();
				encoder.encodeBytes(imageData);
				var params:Object={image_data: encoder.flush()};
				httpImageDataService.url=encodeURI(BiometricConstants.HTTP + "://" + serverIP + ":" + ClassroomContext.portWAMP + "/" + ClassroomContext.WEBAPP_AVIEW + "/" + BiometricConstants.EXTRACTOR + "?" + BiometricConstants.USER_ID + "=" + userID);
				
				httpImageDataService.send(params);
			}
			else
			{
				Alert.show(this.resourceManager.getString('myResource', 'biometric.camNotAvailable') + "\n" + this.resourceManager.getString('myResource', 'biometric.checkCamUsedAnotherApp'), this.resourceManager.getString('myResource', 'biometric.deviceErr'));
			}
		}
		else
		{
			Alert.show(this.resourceManager.getString('myResource', 'biometric.camNotDetected') + "\n" + this.resourceManager.getString('myResource', 'biometric.camThroughtCamSetting'), this.resourceManager.getString('myResource', 'biometric.deviceErr'));
		}
	}
	else
	{
		Alert.show(this.resourceManager.getString('myResource', 'biometric.camNotSelected') + "\n" + this.resourceManager.getString('myResource', 'biometric.camThroughtCamSetting'), this.resourceManager.getString('myResource', 'biometric.deviceErr'));
	}
}


/**
 * @private 
 *  This funtion used for Enrollment result event handler
 * @param eventResult of type ResultEvent
 */
private function resultHandler(eventResult:ResultEvent):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::resultHandler");
	CursorManager.removeBusyCursor();
	var imageArray:String=eventResult.result.toString();
	var params:Array=imageArray.split("&", 3);
	// If check params return to face Enrolled Successfully
	if (params[0] == BiometricConstants.ENROLLED_SUCESSFULLY)
	{
		if (Log.isDebug()) log.debug("resultHandler: Enrolled Successfully");
		showConfirmationPopUp(params[1], params[2]);
	} // Else if check params return to Face detection failed. Try again.
	else if (params[0] == BiometricConstants.FACE_DETECTION_FAILED)
	{
		if (Log.isDebug()) log.debug("Face detection failed. Try again.");
		var newPopUp:ErrorReportForm=ErrorReportForm(PopUpManager.createPopUp(this, ErrorReportForm, true));
		newPopUp.addEventListener(FlexEvent.REMOVE, guidelinesCloseHandler);
		newPopUp.loadData(params[0], BiometricConstants.ENROLL); // "Enroll");
		PopUpManager.centerPopUp(newPopUp);
	} // Else Face Registration Failed.
	else
	{
		if (Log.isDebug()) log.debug("Registration Failed");
		Alert.show(params[0], this.resourceManager.getString('myResource', 'biometric.registFailed'));
		btnRegister.enabled=true;
	}
}

/**
 * @public
 * This funtion used for close handler guidelines 
 * @param event of type Event
 */
public function guidelinesCloseHandler(event:Event):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::guidelinesCloseHandler");
	btnRegister.enabled=true;
}
/**
 * @private 
 * This funtion used for fault handler
 * @param faultEvent of type FaultEvent
 */
private function faultHandler(faultEvent:FaultEvent):void
{
	if (Log.isError()) log.error("Biometric::FaceRegistrationForm::faultHandler:" +AbstractHelper.getStaticFaultMessage(faultEvent));
	CursorManager.removeBusyCursor();
	btnRegister.enabled=true;
	Alert.show(faultEvent.fault.message, this.resourceManager.getString('myResource', 'biometric.error'));
}
/**
 * @private 
 * This funtion used for confirmation popup
 * @param faceTemplateData of type String
 * @param faceImageData of type String
 */
private function showConfirmationPopUp(faceTemplateData:String, faceImageData:String):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::showConfirmationPopUp");
	var newPopUp:RegistrationConfirmationForm=RegistrationConfirmationForm(PopUpManager.createPopUp(this, RegistrationConfirmationForm, true));
	newPopUp.addEventListener(FlexEvent.REMOVE, popupCloseHandler);
	newPopUp.loadData(serverIP, userID, faceTemplateData, faceImageData);
	PopUpManager.centerPopUp(newPopUp);
}
/**
 * @public
 * This funtion used for popup close handler 
 * @param event of type Event
 */
public function popupCloseHandler(event:Event):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::popupCloseHandler");
	btnRegister.enabled=true;
	retrieveRegisteredFaces();
}

/**
 * @public
 * This funtion used for retrieve registered faces
 */
public function retrieveRegisteredFaces():void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::retrieveRegisteredFaces");
	httpFaceDetectorService.url=encodeURI(BiometricConstants.HTTP + "://" + serverIP + ":" + ClassroomContext.portWAMP + "/" + ClassroomContext.WEBAPP_AVIEW + "/" + BiometricConstants.PROFILER + "?" + BiometricConstants.USER_ID + "=" + userID);
	httpFaceDetectorService.send();
}

/**
 * @private 
 * This funtion used for registered face result handler
 * @param event of type ResultEvent
 */
private function faceResultHandler(event:ResultEvent):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::faceResultHandler");
	var imageArray:String=event.result.toString();
	var params:Array=imageArray.split("&", 10);
	showRegisteredFaces(params);
	BiometricConstants.biometricFaceCount=Math.floor(params.length / 2);
}

/**
 * @private 
 * This funtion used for registered face fault handler
 * @param event of type FaultEvent
 */
private function faceFaultHandler(event:FaultEvent):void
{
	if (Log.isError()) log.error("Biometric::FaceRegistrationForm::faceFaultHandler:" +AbstractHelper.getStaticFaultMessage(event));
	Alert.show(event.fault.faultString, this.resourceManager.getString('myResource', 'biometric.error'));
}

//RGCR: userFaces stores both templateId and ImageSource. Can you store these two different types of info on two separate arrays?
//RGCR: Or you can use a list/array of objects containing these two infos.
/**
 * @private 
 * This funtion used for show registered faces
 * @param userFaces of type Array
 */
private function showRegisteredFaces(userFaces:Array):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::showRegisteredFaces");
	//RGCR: Shouldn't it be lenght 0?
	if (Log.isDebug()) log.debug("Registered Faces " + userFaces.length);
	//PNCR: use switch case instead of nested if
	if (userFaces.length == 1)
	{
		//RGCR: Why we have to repeat the below log for each if block?
		assignTemplateId(0, 0, 0, 0, 0);
		assignImageSource(null, null, null, null, null);
	}
	else if (userFaces.length == 2)
	{
		assignTemplateId(userFaces[0], 0, 0, 0, 0);
		assignImageSource(userFaces[1], null, null, null, null);
	}
	else if (userFaces.length == 4)
	{
		assignTemplateId(userFaces[0], userFaces[2], 0, 0, 0);
		assignImageSource(userFaces[1], userFaces[3], null, null, null);
	}
	else if (userFaces.length == 6)
	{
		assignTemplateId(userFaces[0], userFaces[2], userFaces[4], 0, 0);
		assignImageSource(userFaces[1], userFaces[3], userFaces[5], null, null);
	}
	else if (userFaces.length == 8)
	{
		assignTemplateId(userFaces[0], userFaces[2], userFaces[4], userFaces[6], 0);
		assignImageSource(userFaces[1], userFaces[3], userFaces[5], userFaces[7], null);
	}
	else if (userFaces.length == 10)
	{
		assignTemplateId(userFaces[0], userFaces[2], userFaces[4], userFaces[6], userFaces[8]);
		assignImageSource(userFaces[1], userFaces[3], userFaces[5], userFaces[7], userFaces[9]);
	}
	//RGCR: Instead of the big if/else loop is there any way to use just one block and some function?
}

//RGCR: Can this be done by taking a list/array and using a loop?
/**
 * @public 
 * This funtion used for assign image source
 * @param image0 of type String
 * @param image1 of type String
 * @param image2 of type String
 * @param image3 of type String
 * @param image4 of type String
 * 
 */
public function assignImageSource(image0:String, image1:String, image2:String, image3:String, image4:String):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::assignImageSource");
	//PNCR: seems the below if-else conditions are doing similar functionality. 
	//PNCR: Check whether can combine all these in a single function with arguments.
	if (image0 != null)
	{
		if (Log.isDebug()) log.debug("assign Image0 ");
		var decoder0:Base64Decoder=new Base64Decoder();
		decoder0.decode(image0);
		imageData0=decoder0.flush();
		faceIcon0.source=imageData0;
		deleteIcon0.visible=true;
	}
	else
	{
		if (Log.isDebug()) log.debug("assign Image0 Null ");
		faceIcon0.source="";
		deleteIcon0.visible=false;
	}
	
	if (image1 != null)
	{
		if (Log.isDebug()) log.debug("assign Image1 ");
		var decoder1:Base64Decoder=new Base64Decoder();
		decoder1.decode(image1);
		imageData1=decoder1.flush();
		faceIcon1.source=imageData1;
		deleteIcon1.visible=true;
	}
	else
	{
		if (Log.isDebug()) log.debug("assign Image1 Null ");
		faceIcon1.source="";
		deleteIcon1.visible=false;
	}
	
	if (image2 != null)
	{
		if (Log.isDebug()) log.debug("assign Image2 ");
		var decoder2:Base64Decoder=new Base64Decoder();
		decoder2.decode(image2);
		imageData2=decoder2.flush();
		faceIcon2.source=imageData2;
		deleteIcon2.visible=true;
	}
	else
	{
		if (Log.isDebug()) log.debug("assign Image2 Null ");
		faceIcon2.source="";
		deleteIcon2.visible=false;
	}
	
	if (image3 != null)
	{
		if (Log.isDebug()) log.debug("assign Image3 ");
		var decoder3:Base64Decoder=new Base64Decoder();
		decoder3.decode(image3);
		imageData3=decoder3.flush();
		faceIcon3.source=imageData3;
		deleteIcon3.visible=true;
	}
	else
	{
		if (Log.isDebug()) log.debug("assign Image3 Null ");
		faceIcon3.source="";
		deleteIcon3.visible=false;
	}
	
	if (image4 != null)
	{
		if (Log.isDebug()) log.debug("assign Image4 ");
		var decoder4:Base64Decoder=new Base64Decoder();
		decoder4.decode(image4);
		imageData4=decoder4.flush();
		faceIcon4.source=imageData4;
		deleteIcon4.visible=true;
	}
	else
	{
		if (Log.isDebug()) log.debug("assign Image4 Null");
		faceIcon4.source="";
		deleteIcon4.visible=false;
	}
}

/**
 * @public 
 * This funtion used for assign template ID
 * @param templateId0 of type int
 * @param templateId1 of type int
 * @param templateId2 of type int
 * @param templateId3 of type int
 * @param templateId4 of type int
 * 
 */
public function assignTemplateId(templateId0:int, templateId1:int, templateId2:int, templateId3:int, templateId4:int):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::assignTemplateId");
	templateID0=templateId0;
	templateID1=templateId1;
	templateID2=templateId2;
	templateID3=templateId3;
	templateID4=templateId4;
}

//RGCR: Instead of repeating logic for each face image, we can use a component with image and buttons etc
//RGCR: That will reduce the code repetition and lines
/**
 * @private 
 * This funtion used for registered face delete confirmation
 * @param imageID of type String
 * 
 */
private function faceDeleteConfirmation(imageID:String):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::faceDeleteConfirmation");
	btnRegister.enabled=false;
	faceImageID=imageID;
	var deleteTemplateId:int;
	var deleteIcon:ByteArray;
	//PNCR: use switch case instead of nested if
	if (faceImageID == deleteIcon0.id)
	{
		if (Log.isDebug()) log.debug("Delete face Image ID: " + faceImageID);
		deleteTemplateId=templateID0;
		deleteIcon=imageData0;
	}
	else if (faceImageID == deleteIcon1.id)
	{
		if (Log.isDebug()) log.debug("Delete face Image ID: " + faceImageID);
		deleteTemplateId=templateID1;
		deleteIcon=imageData1;
	}
	else if (faceImageID == deleteIcon2.id)
	{
		if (Log.isDebug()) log.debug("Delete face Image ID: " + faceImageID);
		deleteTemplateId=templateID2;
		deleteIcon=imageData2;
	}
	else if (faceImageID == deleteIcon3.id)
	{
		if (Log.isDebug()) log.debug("Delete face Image ID: " + faceImageID);
		deleteTemplateId=templateID3;
		deleteIcon=imageData3;
	}
	else if (faceImageID == deleteIcon4.id)
	{
		if (Log.isDebug()) log.debug("Delete face Image ID: " + faceImageID);
		deleteTemplateId=templateID4;
		deleteIcon=imageData4;
	}
	var newPopUp:DeleteConfirmationForm=DeleteConfirmationForm(PopUpManager.createPopUp(this, DeleteConfirmationForm, true));
	newPopUp.addEventListener(FlexEvent.REMOVE, deleteCloseHandler);
	newPopUp.getTemplateData(deleteTemplateId, deleteIcon, serverIP);
	PopUpManager.centerPopUp(newPopUp);
}

/**
 * @public
 * This funtion used for registered delete close handler 
 * @param event of type Event
 * 
 */
public function deleteCloseHandler(event:Event):void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::deleteCloseHandler");
	btnRegister.enabled=true;
	retrieveRegisteredFaces();
}

/**
 * @public
 * This funtion used for stop camera interface
 */
public function stopCameraInterface():void
{
	if (Log.isDebug()) log.debug("Biometric::FaceRegistrationForm::stopCameraInterface");
	this.removeAllElements();
	faceImage.attachCamera(null);
	FlexGlobals.topLevelApplication.mainApp.cameraName=null;
}
