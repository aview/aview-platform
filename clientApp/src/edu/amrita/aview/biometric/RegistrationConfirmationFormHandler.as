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
File		: RegistrationConfirmationFormHandler.as
Module		: Biometric
Developer(s): Jerald P
Reviewer(s)	: Ramesh Guntha

This component invoked when user select Biometric login.
This component used for face registration confirmation.
*/
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.biometric.BiometricConstants;
applicationType::DesktopWeb{
	import edu.amrita.aview.biometric.FaceRegistrationForm;
}
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.Base64Decoder;

/**
 * For user Login ID
 */
private var userLoginID:int;
/**
 * For face template
 */
private var faceTemplate:String;
/**
 * For face Icon Data
 */
private var faceIconData:String;
/**
 * For server IP
 */
private var serverIp:String;
/**
 * For SQL
 */
[Bindable]
public var sql:String;
/**
 * For database name
 */
[Bindable]
private var database:String=BiometricConstants.DATABASE_NAME;

applicationType::DesktopWeb{
	/**
	 * For face Registration
	 */
	private var faceRegistration:FaceRegistrationForm;
}
/**
 * For result array collection
 */
[Bindable]
private var result:ArrayCollection=new ArrayCollection;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.biometric.RegistrationConfirmationFormHandler.as");

/**
 * @public
 * This funtion used for initialization
 */
public function init():void
{
	if (Log.isDebug()) log.debug("Biometric::RegistrationConfirmationForm::init");
	btnYes.setFocus();
}

/**
 * @public 
 * This funtion used for load face image data
 * @param serverIP of type String
 * @param userID of type int
 * @param faceTemplateData of type String
 * @param faceImageData of type String
 */
public function loadData(serverIP:String, userID:int, faceTemplateData:String, faceImageData:String):void
{
	if (Log.isDebug()) log.debug("Biometric::RegistrationConfirmationForm::loadData");
	userLoginID=userID;
	faceTemplate=faceTemplateData;
	faceIconData=faceImageData;
	serverIp=serverIP;
	var faceDecoder:Base64Decoder=new Base64Decoder();
	faceDecoder.decode(faceImageData);
	faceIcon.source=faceDecoder.flush();
}

/**
 * @public
 * This funtion used for enrollment face approved
 */
public function enrolledFaceApproved():void
{
	if (Log.isDebug()) log.debug("Biometric::RegistrationConfirmationForm::enrolledFaceApproved");
	var faceData:String=faceTemplate + "&" + faceIconData;
	var params:Object={faceData: faceData};
	httpDataService.url=encodeURI(BiometricConstants.HTTP + "://" + serverIp + ":" + ClassroomContext.portWAMP + "/" + ClassroomContext.WEBAPP_AVIEW + "/" + BiometricConstants.ENROLLMENT + "?" + BiometricConstants.USER_ID + "=" + userLoginID);
	httpDataService.send(params);
}

/**
 * @private
 * This funtion used for result handler 
 * @param event of type ResultEvent
 */
private function resultHandler(event:ResultEvent):void
{
	if (Log.isDebug()) log.debug("Biometric::RegistrationConfirmationForm::resultHandler");
	var result:String=event.result.toString().substring(0, event.result.toString().indexOf("."));
	if (result == BiometricConstants.REGIST_SUCESSFULLY)
	{
		if (Log.isDebug()) log.debug("resultHandler: Registered Successfully");
		BiometricConstants.biometricFaceCount++;
		faceRecognitionRegisterEventLog(String(BiometricConstants.biometricFaceCount));
		PopUpManager.removePopUp(this);
	}
	else
	{
		if (Log.isDebug()) log.debug("resultHandler: ERROR");
		PopUpManager.removePopUp(this);
		faceRecognitionNotRegisteredEventLog(String(BiometricConstants.biometricFaceCount));
		Alert.show(event.result.toString(), this.resourceManager.getString('myResource', 'biometric.error'));
	}
}

/**
 *
 * @private
 * Audits the "FaceRecognitionNotRegistered" action, when the uesr's face registration fails
 *
 * @param numberFaces - Current number of registered faces
 * @return void
 *
 */
private function faceRecognitionNotRegisteredEventLog(numberFaces:String):void
{
	AuditContext.userAction.createAction(AuditConstants.faceRecognitionNotRegistered, numberFaces, null, null);
}

/**
 *
 * @private
 * Audits the "FaceRecognitionRegister" action, when the user registers his/her face against the user name.
 *
 * @param numberFaces - Current number of faces
 * @return void
 *
 */
private function faceRecognitionRegisterEventLog(numberFaces:String):void
{
	AuditContext.userAction.createAction(AuditConstants.faceRecognitionRegister, numberFaces, null, null);
}

/**
 * @private
 * This funtion used for registered face fault handler 
 * @param event of type FaultEvent
 */
private function faultHandler(event:FaultEvent):void
{
	if (Log.isError()) log.error("Biometric::RegistrationConfirmationForm::faultHandler:" +AbstractHelper.getStaticFaultMessage(event));
	Alert.show(event.fault.faultString, this.resourceManager.getString('myResource', 'biometric.error'));
}
