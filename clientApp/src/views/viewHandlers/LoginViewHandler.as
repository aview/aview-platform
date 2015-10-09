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
 * File			: LoginViewHandler.as
 * Module		: Login
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Pradeesh, Jayakrishnan R
 * 
 * LoginViewHandler.as contains business logic for Login view
 * 
 */

/**
 * Importing MessageBox component and event
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.login.boilerplate.events.LoginStatusEvent;
import edu.amrita.aview.core.shared.audit.AuditContext;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

import views.HomeView;

[Bindable]
public var selectedServerIndex:int =-1;
/**
 * @private
 *
 * To add eventListener for login
 *
 * @return void
 */
private function initApp():void
{
	ClassroomContext.resetClassroomContextValues();
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.createDataServices();
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.addEventListener(LoginStatusEvent.LOGIN_SUCCESS,loginSucess);
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.addEventListener(LoginStatusEvent.LOGIN_FAILED,resetUserName);
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.addEventListener(LoginStatusEvent.APPLICATION_CLOSE,cloaseApplication);
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.addEventListener(LoginStatusEvent.INVALID_SERVER,invalidServerHandler);
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.addEventListener(LoginStatusEvent.SERVER_ERROR,setAutoLogin);
}
/**
 * @private
 *
 * To reset the user credentials
 *
 * @param event of LoginStatusEvent
 * @return void
 */
private function invalidServerHandler(event:LoginStatusEvent):void
{
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.userName = "";
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.password = "";
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.logInButtonState=true;
}
/**
 * @private
 *
 * To navigate to home view
 *
 * @param event of LoginStatusEvent
 * @return void
 */
private function loginSucess(event:LoginStatusEvent):void
{
	FlexGlobals.topLevelApplication.mainApp.userNameInFile = ClassroomContext.userVO.userName;
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.removeEventListener(LoginStatusEvent.LOGIN_SUCCESS,loginSucess);
	FlexGlobals.topLevelApplication.mainApp.getClassRepositoryFolderStructure();
	navigator.pushView(views.ClassroomListView);
	if(FlexGlobals.topLevelApplication.loginUserVideoDriver != null && FlexGlobals.topLevelApplication.loginUserBandwidh != null)
	{
		FlexGlobals.topLevelApplication.saveSettingsToFile(FlexGlobals.topLevelApplication.mainApp.prepareLogin.userName,
			FlexGlobals.topLevelApplication.mainApp.prepareLogin.password,
			FlexGlobals.topLevelApplication.loginUserVideoDriver,
			FlexGlobals.topLevelApplication.loginUserBandwidh,
			FlexGlobals.topLevelApplication.mainApp.prepareLogin.selectedServerIP);
	}
	else
	{
		FlexGlobals.topLevelApplication.saveSettingsToFile(FlexGlobals.topLevelApplication.mainApp.prepareLogin.userName,FlexGlobals.topLevelApplication.mainApp.prepareLogin.password,"","",FlexGlobals.topLevelApplication.mainApp.prepareLogin.selectedServerIP);
	}
	AuditContext.init();
	AuditContext.login.auditLogin(Constants.AVIEW_VERSION);
}
/**
 * @private
 *
 * To reset the username and password fields
 *
 * @param event of Event
 * @return void
 */
private function resetUserName(event:Event = null):void
{	
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.userName = "";
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.password = "";
	FlexGlobals.topLevelApplication.mainApp.prepareLogin.logInButtonState=true;
}
/**
 * @private
 *
 * To close the application
 *
 * @param event of ApplicationStatusEvent
 * @return void
 */
private function cloaseApplication(event:LoginStatusEvent):void
{
	NativeApplication.nativeApplication.exit();
}
/**
 * @protected
 *
 * To close the application, when user cliks on exit menu
 *
 * @param event of MouseEvent
 * @return void
 */
protected function applicationExit(event:MouseEvent):void
{
	NativeApplication.nativeApplication.exit();
}
/**
 * @protected
 *
 * To close the application, when user cliks on exit menu
 *
 * @param event of MouseEvent
 * @return void
 */
protected function setAutoLogin(event:LoginStatusEvent):void
{
	FlexGlobals.topLevelApplication.isAutoLogin = true;
}