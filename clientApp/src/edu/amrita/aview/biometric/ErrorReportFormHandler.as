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
File		: ErrorReportFormHandler.as
Module		: Biometric
Developer(s): Jerald P
Reviewer(s)	: Ramesh Guntha

This component invoked when user select Biometric login.
This component used for error message handling.
*/
import edu.amrita.aview.biometric.BiometricConstants;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import mx.logging.ILogger;
import mx.logging.Log;

/**
 * For error report message
 */
private var errorMessageReport:String;
/**
 * For error process report
 */
private var errorProcessReport:String;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.biometric.ErrorReportFormHandler.as");
/**
 * For html String
 */
[Bindable]
private var htmlStr1:String="For guidelines, please refer the <b>'Biometrics'</b> <br>section in the help document.";

/**
 * @public
 * This funtion used for initialization
 */
public function init():void
{
	if (Log.isDebug()) log.debug("Biometric::ErrorReportForm::init");
	btnOk.setFocus();
}

/**
 * @public
 * This funtion used for load error message 
 * @param errorMessage of type String
 * @param errorProcess of type String
 * 
 */
public function loadData(errorMessage:String, errorProcess:String):void
{
	if (Log.isDebug()) log.debug("Biometric::ErrorReportForm::loadData");
	errorMessageReport=errorMessage;
	errorProcessReport=errorProcess;
}

/**
 * @private
 * This funtion used for assign error message
 */
private function assignOutputString():void
{
	if (Log.isDebug()) log.debug("Biometric::ErrorReportForm::assignOutputString");
	errorMessage.htmlText=errorMessageReport;
}

/**
 * @private
 * This funtion used for set title
 */
private function setTitleString():void
{
	if (Log.isDebug()) log.debug("Biometric::ErrorReportForm::setTitleString");
	//PNCR: use conditional operator
	if (errorProcessReport == BiometricConstants.ENROLL) //"Enroll"
	{
		errorReport.title=this.resourceManager.getString('myResource', 'biometric.registFailed');
	}
	else //"Match"
	{
		errorReport.title=this.resourceManager.getString('myResource', 'biometric.loginFailed');
	}
}
