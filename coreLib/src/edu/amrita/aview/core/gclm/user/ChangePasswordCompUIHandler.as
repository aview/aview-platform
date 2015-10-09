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
 * File			: ChangePasswordCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 *
 *
 */
import com.adobe.crypto.SHA1;

import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.UserVO;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 *  To keep track if the user has clicked on the cancel button 
 */
public var hasClickedCancelButton:Boolean;

/**
 * The user object whose password needs to be changed 
 */
private var user:UserVO;
/**
 * The error message string to display as part of validation 
 */
private var errMsg:String="";
/**
 * The new encrypted password 
 */
private var strNewPasswordEnc:String="";
/**
 * The helper class to communicate with the server 
 */
private var userHelper:UserHelper=null;
/**
 * To check if the selected user is same as of logged in user 
 */
private var sameUser:Boolean=true;
/**
 * The message to store as part of audtiting 
 */
private var attr1Value:String="User details for password change: ";

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.user.ChangePasswordCompUIHandler.as");

/**
 * @public
 * This function sets all the initial info that is required for the ChangePassword.
 * This is invoked from the UserComp
 * @param user type of UserVO
 * @return void
 */
public function init(user:UserVO):void
{
	userHelper=new UserHelper();
	hasClickedCancelButton=true;
	this.user=new UserVO();
	this.user=user;
	lblUserName.text=user.userName;
	//Check if the user is admin, if so, they do not need to enter the old password
	if (user.userName != ClassroomContext.userVO.userName)
	{
		// No need to enter the old password if master admin/institute admin changes the password
		sameUser=false;
		txtInpOldPassword.text="No need to enter";
		txtInpOldPassword.enabled=false;
		txtInpOldPassword.displayAsPassword=false;
	}
}

/**
 * @public
 * This function is the result handler for changing the password
 * @param event type of ResultEvent
 * @return void
 */
public function updateUserChangePassResultHandler(event:ResultEvent):void
{
	hasClickedCancelButton=false;
	applicationType::DesktopWeb{
		changePasswordEventLog(attr1Value, Constants.CHANGE_PASSWORD_SUCCESS);
		CustomAlert.info("Password updated successfully");
		closeChangePasswordComp();
	}
	applicationType::mobile{
		MessageBox.show("Password updated successfully","Information",MessageBox.MB_OK,this,closeChangePasswordComp,null,MessageBox.IC_INFO);
	}
}

/**
 *
 * @private
 * Audits the "Change Password" action, when the user changes his/her password through gclm
 *
 * @param userDetails - userId of the user
 * @param status - Status of the password change operation success/failure
 * @return void
 *
 */
private function changePasswordEventLog(userDetails:String, status:String):void
{
	AuditContext.userAction.createAction(AuditConstants.changePassword, userDetails, status, null);
}

/**
 * @public
 * This function is the fault handler for changing the password
 * @param event type of FaultEvent
 * @return void
 */
public function updateUserChangePassFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::user::ChangePasswordCompUIHandler::updateUserChangePassFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	hasClickedCancelButton=false;
	applicationType::DesktopWeb{
		changePasswordEventLog(attr1Value, Constants.CHANGE_PASSWORD_FAILED);
		CustomAlert.error("Fault occured while changing the password. Please contact administrator");
		closeChangePasswordComp();
	}
	applicationType::mobile{
		MessageBox.show("Fault occurred while changing the password. Please contact administrator","Information",MessageBox.MB_OK,this,closeChangePasswordComp,null,MessageBox.IC_INFO);
	}
}

/**
 * @private
 * This function is to validate the existing password and send the new encrypted password to server for changing
 *
 * @return void
 */
private function setNewPassword():void
{
	//Validate the user input data
	if (ValidateUserPasswordDetails())
	{
		attr1Value+=user.userId;
		userHelper.updateUserChangePass(strNewPasswordEnc, user.userId, ClassroomContext.userVO.userId,updateUserChangePassResultHandler,updateUserChangePassFaultHandler);
	}
	else
	{
		applicationType::DesktopWeb{
			CustomAlert.error(errMsg);
		}
		applicationType::mobile{
			MessageBox.show(errMsg,"Error Info",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
}

/**
 * @private
 * This function is the validater for this window
 *
 * @return Boolean
 */
private function ValidateUserPasswordDetails():Boolean
{
	var result:Boolean=true;
	var strOldPassword:String=new String(txtInpOldPassword.text);
	var strNewPassword:String=new String(txtInpNewPwd.text);
	strNewPasswordEnc=SHA1.hash(strNewPassword);
	if (sameUser)
	{
		//Check for empty and null values
		if (txtInpOldPassword.text == "" || txtInpNewPwd.text == "" || txtInpConfirmPwd.text == "")
		{
			result=false;
			errMsg="Please fill mandatory details";
		}
		//Check for empty and null values
		else if (user.password != SHA1.hash(strOldPassword))
		{
			result=false;
			errMsg="Current password does not match";
		}
	}
	//Admin & Master Admins
	//Check for empty and null values
	else if (txtInpNewPwd.text == "" || txtInpConfirmPwd.text == "")
	{
		result=false;
		errMsg="Please fill mandatory details";
	}
	
	if(!Constants.PASSWORD_STRENGTH_REGEXP.test(txtInpNewPwd.text))
	{
		result = false;
		errMsg = "New password must contain atleast 8 characters with atleast one upper case letter, one lower case letter, one digit and one special character";
	}
	//Check if new password and confirm new password matches
	else if (txtInpNewPwd.text != txtInpConfirmPwd.text)
	{
		result=false;
		errMsg="New password and Confirm password does not match";
	}
	// Fix for Bug #2564 start
	else if (strNewPasswordEnc == user.password)
	{
		result=false;
		errMsg="New password and Current password cannot be the same";
	}
	// Fix for Bug #2564 end
	return result;
}


/**
 * @private
 * This function is called when the user tries to close the change password comp
 *
 * @return void
 */
applicationType::DesktopWeb{
	private function closeChangePasswordComp():void
	{
		PopUpManager.removePopUp(this);
	}
}
applicationType::mobile{
	private function closeChangePasswordComp(event:MessageBoxEvent) : void
	{
		this.close();
	}
}