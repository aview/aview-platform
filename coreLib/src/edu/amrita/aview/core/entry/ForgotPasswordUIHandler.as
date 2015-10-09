import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.shared.components.Captcha;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
}
applicationType::mobile{
	import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
	import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
}
import edu.amrita.aview.core.shared.helper.AbstractHelper;

import flash.events.Event;

import mx.core.FlexGlobals;
import mx.events.ValidationResultEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

private var isValidEmail:Boolean=true;
private var captcha:Captcha = null;
private var errMsg:String="";
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.entry.ForgotPasswordUIHandler.as");

applicationType::DesktopWeb{
	private function closePopupWindow(event:Event=null):void
	{
		PopUpManager.removePopUp(this);
	}
}
applicationType::mobile{
	private function closePopupComp(event:MessageBoxEvent) : void
	{
		this.close();
	}
}

private function emailValidationHandler(event:ValidationResultEvent):void
{
	if ((event.results != null) && (event.results[0].isError))
	{
		isValidEmail=false;
	}
	else if (event.type == "valid")
	{
		isValidEmail=true;
	}
}

private function ValidateUserDetails():Boolean
{
	var result:Boolean=true;
	errMsg="Please fill the following fields: ";
	if (tiLoginUserForForgotPassword.text == '')
	{
		errMsg+=" User name, ";
		result=false;
	}
	if (tiEmail.text == '')
	{
		errMsg+=" Email, ";
		result=false;
	}
	if (!isValidEmail && (tiEmail.text!='') )
	{
		errMsg="Please enter a valid email id,";
		result=false;
	}
	errMsg=errMsg.substring(0, errMsg.lastIndexOf(","));
	return result;
}

private function resetUserPassword():void
{
	if (ValidateUserDetails())
	{
		var userHelper:UserHelper=new UserHelper();
		userHelper.resetPassword(tiLoginUserForForgotPassword.text, tiEmail.text,resetPasswordResultHandler,resetPasswordFaultHandler);
	}
	else
	{
		applicationType::DesktopWeb{
			CustomAlert.error(errMsg);
		}
		applicationType::mobile{
		   MessageBox.show(errMsg,"Information",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
		}
	}
}

public function resetPasswordResultHandler(event:ResultEvent):void
{
	applicationType::DesktopWeb{
		CustomAlert.info("Your password has been reset and the new password is sent to your registered email id. Please check your email after sometime. Once you login with the new password, please change the same.", "Password changed", closePopupWindow);
	}
	applicationType::mobile{
		MessageBox.show("Your password has been reset and the new password is sent to your registered email id. Please check your email after sometime. Once you login with the new password, please change the same.","Password changed",MessageBox.MB_OK,this,closePopupComp,null,MessageBox.IC_INFO);
	}
}
private function createCaptcha() : void
{
	txtCaptcha.text = "";
	if(captcha != null)
	{
		applicationType::DesktopWeb{
			captchaImage.removeChild(captcha);
		}
		applicationType::mobile{
			captchaImage.removeElement(captcha);
		}
	}
	captcha = new Captcha("alphaCharsnum",4);
	applicationType::DesktopWeb{
		captchaImage.addChild(captcha);
	}
	applicationType::mobile{
		captchaImage.addElement(captcha);
	}
}
public function resetPasswordFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("entry::ForgotPasswordUIHandler::resetPasswordFaultHandler:"+ AbstractHelper.getStaticFaultMessage(event));
	var faultMessage:String=AbstractHelper.getStaticFaultMessage(event);
	applicationType::DesktopWeb{
		CustomAlert.error(faultMessage);
	}
	applicationType::mobile{
		MessageBox.show(faultMessage,"Error",MessageBox.MB_OK,this,null,null,MessageBox.IC_INFO);
	}
}