// ActionScript file
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
File		: DeleteConfirmationFormHandler.as
Module		: Biometric
Developer(s): Jerald P
Reviewer(s)	: Ramesh Guntha

This component invoked when user select Biometric login.
This is used for delete the biometric user image.
*/
import edu.amrita.aview.audit.AuditConstants;
import edu.amrita.aview.audit.AuditContext;
import edu.amrita.aview.biometric.BiometricConstants;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;

import flash.utils.ByteArray;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 * For delete process keep specified template id
 */
private var deleteTemplateId:int;
/**
 * Sever IP
 */
private var serverIp:String;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.biometric.DeleteConfirmationFormHandler.as");

/**
 * @public
 * This funtion used for initialization
 */
public function init():void
{
	if (Log.isDebug()) log.debug("Biometric::DeleteConfirmationForm::init");
	btnYes.setFocus();
}

/**
 * @public
 * This function used for get the template data.
 * @param templateId of type int
 * @param faceIcon of type ByteArray
 * @param serverIP of type String
 * 
 */
public function getTemplateData(templateId:int, faceIcon:ByteArray, serverIP:String):void
{
	if (Log.isDebug()) log.debug("Biometric::DeleteConfirmationForm::getTemplateData");
	deleteTemplateId=templateId;
	faceImage.source=faceIcon;
	serverIp=serverIP;
}

/**
 * @public
 * Function used for face delete function call.
 */
public function deleteFace():void
{
	if (Log.isDebug()) log.debug("Biometric::DeleteConfirmationForm::deleteFace");
	deleteRegisteredFace(deleteTemplateId);
}

/**
 * @public
 * This function used for delete the registered face. 
 * @param templateID of type int
 * 
 */
public function deleteRegisteredFace(templateID:int):void
{
	if (Log.isDebug()) log.debug("Biometric::DeleteConfirmationForm::deleteRegisteredFace");
	httpFaceRemoveService.url=encodeURI(BiometricConstants.HTTP + "://" + serverIp + ":" + ClassroomContext.portWAMP + "/" + ClassroomContext.WEBAPP_AVIEW + "/" + BiometricConstants.REMOVAL + "?" + BiometricConstants.TEMPLATE_ID + "=" + templateID);
	httpFaceRemoveService.send();
}

/**
 * @private
 * This function used for deleted registered face result handler. 
 * @param event of type ResultEvent
 * 
 */
private function deleteResultHandler(event:ResultEvent):void
{
	if (Log.isDebug()) log.debug("Biometric::DeleteConfirmationForm::deleteResultHandler");
	BiometricConstants.biometricFaceCount--;
	faceRecognitionRemoveEventLog(String(BiometricConstants.biometricFaceCount));
	PopUpManager.removePopUp(this);
}

/**
 *
 * @private
 * Audits the "FaceRecognitionRemove" action, when the user removes a pre-registered face against the user name.
 *
 * @param numberFaces - Current number of faces
 * @return void
 *
 */
private function faceRecognitionRemoveEventLog(numberFaces:String):void
{
	AuditContext.userAction.createAction(AuditConstants.faceRecognitionRemove, numberFaces, null, null);
}

/**
 * @private
 * This function used for deleted fault handler. 
 * @param event of type FaultEvent
 * 
 */
private function deleteFaultHandler(event:FaultEvent):void
{
	if (Log.isError()) log.error("Biometric::DeleteConfirmationForm::deleteFaultHandler:" +AbstractHelper.getStaticFaultMessage(event));
	Alert.show(event.fault.faultString, this.resourceManager.getString('myResource', 'biometric.error'));
}
