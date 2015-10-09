import com.amrita.edu.collaboration.CollaborationFactory;
import com.amrita.edu.collaboration.CollaborationObject;

import edu.amrita.aview.common.service.MediaServerConnection;
import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ModuleRO;
import edu.amrita.aview.core.entry.events.RoleChangeEvent;
import edu.amrita.aview.core.entry.events.SessionStatusEvent;
import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
applicationType::mobile
{
	import edu.amrita.aview.core.shared.components.userList.MobileUserList;
}
import edu.amrita.aview.core.shared.events.ChatEvent;
import edu.amrita.aview.core.user.UserTime;

import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.SyncEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;
import flash.net.Responder;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.logging.Log;
import mx.utils.URLUtil;

import objectResolver.EntryFac;

import spark.formatters.DateTimeFormatter;
import flash.desktop.NativeApplication;
import edu.amrita.aview.core.gclm.classRegistration.ClassRegistrationComp;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import edu.amrita.aview.core.entry.ClassroomComponent;

/**Platform specific imports*/
applicationType::desktop {
	//NetworkInfo is not available for web
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
}

/**
 * MediaServerConnection object for maintaining connection with FlashMediaServer
 */
public var usersConnection:MediaServerConnection;

/**
 *Used to make sure that collaboraiton objects are not re-initialized for every connection success event.
 *Collaboraiton service automatically re-initializes all the CollaborationObjects on reconnection 
 */
private var isCollabObjsInited:Boolean = false;
/**
 * This flag is set to true if the connection is rejected in netStatusHandler method
 * If this flag is true, then we do not retry the connections
 */
public var userConnectionRejected:Boolean=false;

/**
 * CollaborationObject for maintaining userlist of all online users.
 */
public var usersCollaborationObject:CollaborationObject;

public var recordCollaborationObject:CollaborationObject;

public var muiCollaborationObject:CollaborationObject;

public var peopleCountCollaborationObject:CollaborationObject;
//Issue #284:Start
/**
 * Latest users_so shared object data for the current user.
 * This value is updated on every usersSyncHandler call
 */
public var latestUsersStaus:String;
//Issue #284:End

/**
 *  Latest user_so shared object control status of the user.
 *  This is set each time userSync handler is called
 */
public var latestControlData:String;

/**
 *  Latest user_so shared object userRole of the user.
 *  This is set each time userSync handler is called
 */
public var latestUserRole:String;
private var isServerSwitchingDone:Boolean=false;

public var prevUserRole:String;
public var prevUserStat:String;
public var presenterReset:Boolean=false;

/**
 * Latest user_so shared object videoPublishStatus of the user.
 * This is set each time userSync handler is called
 */
public var latestPublishStatus:Boolean;
public var isMute:Boolean = false;
public var isHide:Boolean = false;
//Issue #278 - Start
/**
 * Variable of type Array for storing previous version of users_so data,
 * so that we can process only the users(label) who's state(data) changed
 */
public var previousUsers_SO:Array=new Array();
//Issue #278 - END
/**
 * CollaborationObject for 'push to talk' feature.
 */
public var audioMuteColloaborationObject:CollaborationObject;

private var privateChatCollaborationObject:CollaborationObject;
//Issue #284:Start
/**
 * Latest audioMuteColloaborationObject data for the current user.
 * This value is updated on every audioMuteSyncHandler call
 */
[Bindable]
public var latestAudioMute_COData:String=Constants.FREETALK;
//Issue #284:End

[Bindable]
public var previousAudioMute_COData:String;

/**
 * Variable of type String for temporary storing 'selected user name'
 */
private var tempSelectedUser:String;
/**
 * Timer variable for implement wait (100 millisecond) between 'hold' and 'accept'
 */
private var acceptTimer:Timer;

/**
 * Variable to hold the value of current presenter name which is sent by the server.
 */
[Bindable]
private var currentPresenterName:String;

[Bindable]
private var nowPresenter:String;

[Bindable]
public var isMUISelected:Boolean=false;

private var interactionMUICount:int=1;

/**
 * Variables used for notifying Presenter / Selected Viewers' via POP out message box
 */
private var notifySelectedViewer:Boolean=false;
private var notifyPresenter:Boolean=false;

public var startPresentersStreamTimeoutId:uint;
/**
 * The bindable array holds the logged user data from the server which is pushed in through the Sync method.
 */
[Bindable]
public var loggedinUserDetailsArray:Array;
/**
 * The variable that hold shared object for storing logged in User
 */
public var adminConsoleCollabObject:CollaborationObject;

/**
 * This helps us to creat the shared object only once and after reconnection and after users_so sync event.
 * This has three values. Null (after app start), "N" after every disconnect,
 * and "Y" after every reconnect and sync.
 */
private var isUserCOCreatedAfterReconnection:String=null;

private var tim:Timer;
[Bindable]
public var selectPTTCheckBox:Boolean=false;
public var restartDesktopSharingTimeoutId:uint;
//Fix for issue #15815
public var initDesktopSharingTimeoutId:uint;
public var applicationSharingRestart:Boolean=false;
public var numUsers:uint=0; //RGCR: Why do you need this variable?
private var dummyStreamPublishTimeoutId:uint;
public var audioMuteSyncHandlerTimeoutId:uint;

private var userTimes:ArrayCollection=new ArrayCollection();
public var desktopSharingCollabObject:CollaborationObject;
public var userSoSyncStatus:String;
public var setAudioMuteStatusForStreamTimeoutId:uint;

private var count:Number=0;
private var prevSOStateBeforeReconnection:Object=null;

private var msgBox:MessageBox = null;

private var chatManager = null;

private var isReconnect:Boolean = false;
/* Variable to store unInterrupted desktop sharing value to fix issue #7939. */
private var tempUnInterruptedDesktopSharingValue:String="";

private var  myResponder:Responder = new Responder(onReply);
public var T_SYS_TIME:Object = new Object;
public var isFolder:Boolean = false;
public var uploadUrl:String = "";
private var serverSideFolderCreateService:HTTPService = new HTTPService;

/**Platform specific variables*/
applicationType::web {
	/* To call function after a specified delay */
	public var setTimeOutID:uint;
}
applicationType::mobile{
	[Bindable]
	public var lstUsers:MobileUserList;
	
	/**
	 * Variable of type Array for storing sorted userlist for changing the icon of 'unmuted' user in 'push to talk' mode
	 */
	private var sortedPushToTalkArray:Array=new Array();
	/**
	 * Variable for storing index of last selected user from the userlist.
	 */
	public var lastRollOverIndex:int;
	/**
	 * This helps us to creat the shared object only once and after reconnection and after users_so sync event.
	 * This has three values. Null (after app start), "N" after every disconnect, 
	 * and "Y" after every reconnect and sync.
	 */
	private var isUserSOCreatedAfterReconnection:String = null;
	
}
//admin console
public function adminInitialise():void {
	//Variable contains the  currentuser login date.
	var userLoginDate:Date;
	//For displaying date in format like dd-mm-yyyy.
	var loggedindateformatter:DateTimeFormatter;
	
	
	this.x=0;
	this.y=0;
	loggedindateformatter=new DateTimeFormatter();
	loggedindateformatter.dateTimePattern="dd-MM-yyyy h:mm:ss a";
	userLoginDate=new Date();
	ClassroomContext.classEntryTime=loggedindateformatter.format(userLoginDate);
	//Network Info is not available for web
	/*To find Network details*/
	applicationType::DesktopMobile
	{
		var results:Vector.<NetworkInterface>=NetworkInfo.networkInfo.findInterfaces();
		for (var i:int=0; i < results.length; i++) {
			if (ClassroomContext.networkConnectionType.length == 0) {
				ClassroomContext.networkConnectionType=results[i].displayName;
				
			} else {
				ClassroomContext.networkConnectionType=ClassroomContext.networkConnectionType + "," + results[i].displayName;
				
			}
			for (var j:int=0; j < results[i].addresses.length; j++) {
				if (ClassroomContext.ipAddress.length == 0) {
					ClassroomContext.ipAddress=results[i].addresses[j].address;
					
				} else {
					ClassroomContext.ipAddress=ClassroomContext.ipAddress + "," + results[i].addresses[j].address;
					
				}
			}
		}
	}
	prepareClassDetails();
}


public function prepareClassDetails():void {
	//ClassroomContext.userDetails=new Object();
	ClassroomContext.userDetails.userName=ClassroomContext.userVO.userName;
	ClassroomContext.userDetails.displayName=ClassroomContext.userVO.userDisplayName;
	ClassroomContext.userDetails.instituteName=ClassroomContext.userInstituteVO.instituteName;
	ClassroomContext.userDetails.courseName=ClassroomContext.course.courseName;
	ClassroomContext.userDetails.loginTime=ClassroomContext.classEntryTime;
	ClassroomContext.userDetails.camera=videoDeviceDrive;
	ClassroomContext.userDetails.microphone=audioDeviceDrive;
	ClassroomContext.userDetails.networkConnectionType=ClassroomContext.networkConnectionType;
	ClassroomContext.userDetails.ipAddress=ClassroomContext.ipAddress;
	//ClassroomContext.userDetails.AVIEW_VERSION=main.AVIEW_VERSION;
	
}

//Bug fix 5871 - Chat message getting doubled at user side after network reconnection
//During a reconnection, this call would be made from server to set history. But we want to set history only once during the login.
private var historySet:Boolean=false;


private var presenterVideoConnectionWaitInterval:uint;
private var viewerVideoConnectionWaitInterval:uint;
private var selUserArray:ArrayCollection;

private function waitForPresenterVideoConnection(name:String):void {
	clearInterval(presenterVideoConnectionWaitInterval);
	if (getPresentersVideoConnection(0).ncVideo.isConnected() > 0) {
		presenterVideoConnectionWaitInterval=setInterval(waitForPresenterVideoConnection, 100, name);
	} else {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users.as-In waitForPresenterVideoConnection: Calling recordStream for the presenter; Stream Name: " + name);
		applicationType::DesktopWeb{
			recorder.presenterVideoRecorder.recordStream(getPresentersVideoConnection(0).ncVideo.netConnection, "true", name, usersCollaborationObject.getData()[name].userDisplayName);
		}
	}
	
}

private function waitForViewerVideoConnection(name:String):void {
	clearInterval(viewerVideoConnectionWaitInterval);
	if (getViewersVideoConnection().ncVideo.isConnected() > 0) {
		viewerVideoConnectionWaitInterval=setInterval(waitForViewerVideoConnection, 100, name);
	} else {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users.as-In waitForViewerVideoConnection: Calling recordStream for the viewer; Stream Name: " + name + "_VIEWER");
		if (getAudioMuteSOValue() == Constants.FREETALK) {
			recordViewer(name, usersCollaborationObject.getData()[name].userDisplayName);
		}
		
	}
}

private var removeUserTimeout:uint;

public function removeUserHandler(e:Event):void {
	removeUser();
}

public function removeUser():void {
	if (removeUserTimeout)
		clearTimeout(removeUserTimeout);
	var context:String="exitClassroom";
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp) {
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp) {
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.exitContext=context;
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.exitClassroomConfirmation();
	}
}

private function userConnectionAsyncErrorHandler(e:AsyncErrorEvent):void {
	//Alert.show(e.text)
}

private function getMediaServerClientCallbacks():Object
{
	var client:Object=new Object();
	//If the same user or some other user logs in with the same it, once again, the previous connection should be closed
	client.duplicateLogin=function(newLoginIp:String):void {
		
		
		userConnectionRejected=true;
		ClassroomContext.isDuplicateLogin=true;
		//PNCR: BugFix: #14556. Set mediaserver connection value true.
		usersConnection.isDuplicateLogin = true;
		
		//---Error #4544 ,#4541 , #4446 , #4465
		applicationType::DesktopWeb{
			viewer2DComp.DuplicateLogin();
			//--------------------------------------
			
			viewer3DComp.viewer3DSWC.clear3DWindow();
		}
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User: nc.client.duplicateLogin: newLoginIp:" + newLoginIp + ":connectionRejected:" + userConnectionRejected);
		
		if (!closeAlertIssued) {
			closeAlertIssued=true;
			MessageBox.show("Another user with same username has logged in from IP address " + newLoginIp + ".\n Click OK to re-login.", "WARNING", MessageBox.MB_OK, null, closeapp_error);
		}
	}
	
	client.removeUser=function(name:String):void //adminconsole
	{
		if (!closeAlertIssued) {
			closeAlertIssued=true;
			MessageBox.show("Administrator has removed you from the current session, you will not be allowed to attend the current session again. Please login during the next session", "WARNING", MessageBox.MB_OK, null, closeapp_error);
		}
	}
	
	client.alreadyRemovedUser=function(name:String):void //adminconsole
	{
		removeUserTimeout=setTimeout(removeUser, 2400);
		MessageBox.show("Administrator has removed you from the current session, you will not be allowed to attend the current session again. Please login during the next session", "WARNING");
	}
	
	client.msgFromSrvr=function(msg:String, name:String):void {
		var userMessage:String=msg.slice(14);
		MessageBox.show(userMessage, "Message From Administrator", MessageBox.MB_OK);
		
	}
		
	client.msgAfterFMSRestart=function():void
	{
		selUserArray = new ArrayCollection();
		if(videoWallLayout == Constants.PRESENTER_LAYOUT && ClassroomContext.isModerator)
		{
			for(var i:int=0; i<selectedViewerDisplays.length; i++)
			{
				if(getUserSO(selectedViewerDisplays[i].userName) && getUserSO(selectedViewerDisplays[i].userName).userStatus == Constants.ACCEPT)
				{
					selUserArray.addItem(selectedViewerDisplays[i].userName);
					setUserStatus(selectedViewerDisplays[i].userName, Constants.HOLD);
				}
			}
			
			setTimeout(startSelectedUsers, 1000);
		}
		if(ClassroomContext.isModerator && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName && isVideoPublished && getUserSO(ClassroomContext.userVO.userName) && getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.HOLD)
		{
			setUserStatus(ClassroomContext.userVO.userName, Constants.ACCEPT);
			setTimeout(refreshVideo, 500);
		}
	}
	applicationType::DesktopWeb{
		client.checkForRecording=function(name:String):void {
			if (ClassroomContext.isModerator && recorder.isRecording) {
				isAcceptedStudent(name)
				if (ClassroomContext.currentPresenterName == name) {
					if (ClassroomContext.userVO.userName != name) {
						if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync-checkForRecording. Calling addEndtime for presenter. Stream Name:" + recorder.presenterVideoRecorder.currentrecordingStream);
						recorder.presenterVideoRecorder.addEndtime(recorder.getCentralTime(),recorder.presenterVideoRecorder.currentrecordingStream);
					}
					waitForPresenterVideoConnection(name);
				} else if (isAcceptedStudent(name)) {
					if (ClassroomContext.userVO.userName != name) {
						if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync-checkForRecording. Calling addEndtime for viewer. Stream Name:" + recorder.viewerVideoRecorder.currentrecordingStream);
						stopRecordingViewerStream(recorder.viewerVideoRecorder.currentrecordingStream);
					}
					waitForViewerVideoConnection(name);
				}
				//desktop sharing
				/*if (desktopSharingCollabObject.getData()["desktopSharing"] && desktopSharingCollabObject.getData()["desktopSharing"].status == "started") {
					recorder.desktopRecorder.stopVideoRecording(recorder.getCentralTime(), false, ClassroomContext.desktopSharingStreamName);
				}*/
			}
			
		}
	}
	//For Live Quiz start
	client.startLiveQuizClient=function(currentQuizId:String, isQuiz:Boolean):void {
		//if((ClassroomContext.classroomNodeTypeId == "1") && (ClassroomContext.userVO.role == Constants.STUDENT_TYPE))
		{
			if(Log.isDebug()) log.debug("Live Quiz has been started by the teacher and the quiz id is " + currentQuizId);
			//Fix for Bug # 10399
			//if(classroomContextObj.userRole == Constants.VIEWER_ROLE)
			//To start Quiz
			// Fix for Bug #19528, 19834 start
			// The monitor role should not attend quiz/polling
			if ((isQuiz) && (!ClassroomContext.isModerator) &&
						    (ClassroomContext.userVO.role != Constants.MONITOR_TYPE) &&
			                (ClassroomContext.userVO.role != Constants.ADMIN_TYPE) &&
			                (ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE))
				//Fix for Bug # 19834 end
			{
				applicationType::DesktopWeb{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.evaluationWnd.startLiveQuizForStudents(currentQuizId,isQuiz);
				}
				applicationType::mobile{
					startLiveQuizForStudents(currentQuizId,isQuiz);
				}
			}
			//To start Polling
			//Fix for Bug # 19835 start
			else if ((!isQuiz) && (classroomContextObj.userRole != Constants.PRESENTER_ROLE) &&
								  (ClassroomContext.userVO.role != Constants.MONITOR_TYPE) &&
			                      (ClassroomContext.userVO.role != Constants.ADMIN_TYPE) &&
			                      (ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE))
				//Fix for Bug # 19835 end
				
			{
				applicationType::DesktopWeb{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.evaluationWnd.startLiveQuizForStudents(currentQuizId,isQuiz);
				}
				applicationType::mobile{
					startLiveQuizForStudents(currentQuizId,isQuiz);
				}
			}
			// Fix for Bug #19528 end
		}
		if(Log.isDebug()) log.debug("Live Quiz started");
	}
	//For Live Quiz end
	applicationType::DesktopWeb{
		//For Video Sharing delay handling.
		client.getPlayheadTime=function(clientName:String):void {
			videoShareObj.getPlayheadTime(clientName);
		}
		//For Video Sharing delay handling	
		client.getPlayheadTimeForLateComingUser=function(sliderTim:Number, reqUser:String):void {
			setTimeout(videoShareObj.playVideoForLateComingUser, 250, sliderTim, reqUser);
		}
		
		client.setRecordStatusModerator=function(status:String):void {
			if (ClassroomContext.moderatorName == ClassroomContext.userVO.userName) {
				if (status == "start" && recordIcon == startRecordIcon) {
					//automaticRecording = true;
					if ((ClassroomContext.lecture.recordedContentUrl == null || ClassroomContext.lecture.recordedContentUrl == "") || (ClassroomContext.lecture.recordedVideoFilePath == null || ClassroomContext.lecture.recordedVideoFilePath == "") || (ClassroomContext.lecture.recordedPresenterVideoUrl == null || ClassroomContext.lecture.recordedPresenterVideoUrl == "")) {
						isRecordbyAdmin=true;
					}
					startRecord();
				} else if (status == "stop" && recordIcon == stopRecordIcon) {
					startRecord();
				}
			}
		}
	}
	return client;
}

private function startSelectedUsers():void
{
	for(var i:int=0; i<selUserArray.length; i++)
	{
		setUserStatus(selUserArray[i], Constants.ACCEPT);
	}
}


/**
 * This function is for creating MediaServerConnection with MediaServer.This connection is maintained throughout the whole session.
 * <br>nc.client.stoppedStream,nc.client.startedStream are two funtions calling from server side script.</br>
 * <br>nc.client.stoppedStream:- for stop recording when stream gets stopped</br>
 * <br>nc.client.startedStream:- for removing busy cursor when the stream gets sucessfully started.</br>
 *
 *
 * @return void
 */
public function createUsersConnection(isFirstTime : Boolean = true):void {
	
	trace("Enter Create Users Connection " + ClassroomContext.FMS_USER + ":" + isFirstTime); 
	if(!isFirstTime)
	{
		clearEvents();
	}
	var connectionParams:ArrayList = new ArrayList();
	connectionParams.addItem(ClassroomContext.userVO.userName);
	connectionParams.addItem(ClassroomContext.userDetails);
	connectionParams.addItem(ClassroomContext.userVO.role);
	connectionParams.addItem(ClassroomContext.aviewClass.maxStudents);
	connectionParams.addItem(ClassroomContext.hardwareAddress);
	connectionParams.addItem(ClassroomContext.lecture.lectureId);
	if(ClassroomContext.aviewClass.classType=="Meeting")
	{
		usersConnection=new MediaServerConnection(ClassroomContext.FMS_USER,Constants.COLLABORATION_SERVER_MODULE_NAME,
			ClassroomContext.lecture.lectureId + "_" + ClassroomContext.aviewClass.classId,connectionParams,getMediaServerClientCallbacks());
	}
	else
	{
		usersConnection=new MediaServerConnection(ClassroomContext.FMS_USER,Constants.COLLABORATION_SERVER_MODULE_NAME,
			ClassroomContext.aviewClass.className + "_" + ClassroomContext.aviewClass.classId,connectionParams,getMediaServerClientCallbacks());

	}
	usersConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, userConnectionStatusHandler);
	// Create remote shared object for holding active userlist 
	ClassroomContext.collaborationService=CollaborationFactory.getCollaborationService(usersConnection);
	//Initialize chat manager
	classRoomModuleVO.mediaServerConnection = usersConnection;
	classRoomModuleVO.collaborationService = ClassroomContext.collaborationService;
	
	chatManager = entryFac.getChatManagerObj(classRoomModuleVO as ModuleRO);
	chatManager.initialize();
	usersConnection.initialize();
	initializeEvents();	
}

private function initializeEvents():void
{
		// CRASH: API
		classRoomModuleVO.moduleEventMap.registerInitiator(this,RoleChangeEvent.TYPE_ROLE_CHANGE);
		classRoomModuleVO.moduleEventMap.registerInitiator(this,ChatEvent.EXIT_ALL_CHATS);
		// CRASH: API
		classRoomModuleVO.moduleEventMap.registerInitiator(this,EntryFac.CANCEL_BREAK_SESSION);
	applicationType::DesktopWeb{
		classRoomModuleVO.applicationEventMap.registerMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
		classRoomModuleVO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
		classRoomModuleVO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
	}
}

private function clearEvents():void
{
		// CRASH: API
		classRoomModuleVO.moduleEventMap.unregisterInitiator(this,RoleChangeEvent.TYPE_ROLE_CHANGE);
		classRoomModuleVO.moduleEventMap.unregisterInitiator(this,ChatEvent.EXIT_ALL_CHATS);
		// CRASH: API
		classRoomModuleVO.moduleEventMap.unregisterInitiator(this,EntryFac.CANCEL_BREAK_SESSION);
	applicationType::DesktopWeb{
		classRoomModuleVO.applicationEventMap.unregisterMapListener(SessionStatusEvent.TYPE_SESSION_EXIT,cleanup);
		classRoomModuleVO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE,cleanup);
		classRoomModuleVO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT,cleanup);
	}
}

private function cleanup(event:Event = null):void
{
	clearEvents();
}

/**
 * This function closes the collaboration/user connection
 */
public function closeUserConnection():void {
	applicationType::DesktopWeb{
		if (userConnectionCloseTimeOutID) {
			clearTimeout(userConnectionCloseTimeOutID);
		}
	}
	if (usersConnection && usersConnection.netConnection.connected) {
		usersConnection.close();
		usersConnection=null;
	}	
	AuditContext.resetLectureAudit();
}

/**
 * This method is called whenever admin console shared object get updated i.e when new user
 * logs in or logsout or changes his A-VIEW settings.
 * This method provides updated client list who are logged in to the server as well as their
 * details to the adminconsole from the server.
 * @param evnt Sync event.
 * @returns void.
 */

//adminconsolesyncHandler
private function adminConsoleSyncHandler(adminConsoleData:Object):void {
	var tmploggedinUserDetailsArray : Array = new Array();
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
		for (var uName:String in adminConsoleData) {
			//loggedinUserDetailsArray.push(adminConsoleData[uName]);
			tmploggedinUserDetailsArray.push(adminConsoleData[uName]);			
		}
		loggedinUserDetailsArray = tmploggedinUserDetailsArray;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.userDetails(loggedinUserDetailsArray);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.keepTheSelections();
	}
}

public function removeAllEventListners():void {
	adminConsoleCollabObject.removeOnSync();
	audioMuteColloaborationObject.removeOnSync();
	recordCollaborationObject.removeOnClear();
	recordCollaborationObject.removeOnChange()
}
/**
 * Function is for closing the whole A-VIEW application,if no network connection is available or FMS rejects connection.
 *
 * @param event of type CloseEvent
 * @return void
 * @see null.
 */
private var closeAlertIssued:Boolean=false;

public function closeapp_error(event:MessageBoxEvent):void {
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video: Entering closeapp_error");
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video: Calling cleanupVideo");
	if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE) {
		cleanupVideo();
	}
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video: Closing");
	//In web there is no window.close(), so we invoked the function closeApp() for closing the application when duplicate login will be happened.
	applicationType::web {
		FlexGlobals.topLevelApplication.mainApp.closeApp();
	}
	applicationType::desktop {
		FlexGlobals.topLevelApplication.close();
	}
	applicationType::mobile{
		NativeApplication.nativeApplication.exit();
	}
}

//RG TODO: This should be managed via event/api based communication between the modules
private function setupModulesOnConnection():void {
	if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MONITOR_TYPE) {
		//Added library file for Desktop and Application sharing, so now the following logic is not used for web
		//Restarting desktopsharing after succesfull reconnection of Presenter 
		applicationType::desktop {
			//Fix for issue #15865 and #16095
			if(desktopSharingCollabObject  && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName){
			if(desktopSharingCollabObject.getData()["desktopSharing"] && desktopSharingCollabObject.getData()["desktopSharing"].status == "started"){
					//stopping Desktop sharing
					//Fix for issue #15591
					stopSharing();
					//Fix for issue #15382
					//starting Desktop sharing
					restartDesktopSharingTimeoutId=setTimeout(restartDesktopSharing, 1000);
				}
				//Fix for issue #15815
				else
				{
					if(selectedSharingMode==1 && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName)
					{
						initDesktopSharingTimeoutId=setTimeout(initializeApplication, 100);
					}
					//Fix for issue #17092
					else if(selectedSharingMode==0 && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName)
					{
						if(isDesktopSharingStarted)
						{
							restartDesktopSharingTimeoutId=setTimeout(restartDesktopSharing, 1000);
						}
					}
				}
			}
			//Fix for issue #15336
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpSharingMode.infoAlert!=null)
			{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpSharingMode.infoAlert.isPopUp)
				{
					PopUpManager.removePopUp(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.popUpSharingMode.infoAlert);
				}
			}
		}
		//Fix for issue #14405
		applicationType::web{
			if(desktopSharingCollabObject  && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName){
				if(desktopSharingCollabObject.getData()["desktopSharing"] && desktopSharingCollabObject.getData()["desktopSharing"].status == "started"){
					applicationSharingRestart=true;
					screenSharingComp.screenSharingContainerObj.screenPublisher.stopScreenSharing();					
					//starting Desktop sharing
					restartDesktopSharingTimeoutId=setTimeout(restartDesktopSharing, 5000);
				}
			}
		}
		//Issue #284:End
		//adminconsole
		applicationType::DesktopWeb{
			wbComp.setupWhiteboardOnConnection();
		}
		applicationType::mobile{
			FlexGlobals.topLevelApplication.wbComp.setupWhiteboardOnConnection();
		}
	}	
}

//RG TODO: This should be managed via event/api based communication between the modules

private function setupModulesOnConnectionClose():void {
	if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MONITOR_TYPE) {
		applicationType::DesktopWeb{
			if (videoShareObj != null)
				videoShareObj.clearVideoSharingProperties();
			if (wbComp)
				wbComp.setupWhiteboardOnConnectionClose();
		}
		applicationType::mobile{
			if (FlexGlobals.topLevelApplication.wbComp)
				FlexGlobals.topLevelApplication.wbComp.setupWhiteboardOnConnectionClose();
		}
		//Fix for issue #20093
		applicationType::web{
			if(classroomComponentSgl.isFullScreen){
				classroomComponentSgl.fullScreenSelected();
			}
		}
	}
}

private function connectionSuccessHandler():void{
	//Issue #284:Start
	//Do this only during the initial connection
	applicationType::DesktopWeb{
		AuditContext.userAction.connectionSuccessEventLog("Collaboration Module", usersConnection.connectionURL, String(usersConnection.connectionRetrys));
		updateStatusbar({module: "users", connectionStatus: true});
	}
	applicationType::desktop{
		onCreateVideoWallFolder();
	}
	applicationType::mobile{
		updateStatusbar({connectionStatus: true});
	}
	initializeCollaborationObjects();
	setupModulesOnConnection();
	chatManager.registerChatEvents();
	if (usersConnection.connectionRetrys == 0) {
		setUserSOStatus(ClassroomContext.userVO.userName, Constants.HOLD, null, ClassroomContext.userVO.role, ClassroomContext.isModerator, ClassroomContext.isAudioOnlyMode, ClassroomContext.userVO.userDisplayName, false, isHide, isMute, classroomContextObj.userRole, null, null, ClassroomContext.userInstituteVO.instituteName, AVCEnvironment.runTime, AVCEnvironment.deviceType, videoCaptureHeight, videoCaptureWidth, viewVideoCount);
	} 
	applicationType::web {
		//Added this check , to avoid null object reference issue when Admin enter into the classroom.
		if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE) {
			setTimeOutID=setTimeout(set2DComponentAccessibility, 1000); //Added setTimeOut to solve timing issue for guest users
		}
	}
}

private function connectionRejectedHandler():void{
	//Alert.show("Connection Rejected", "WARNING", 0, this, closeapp_error);
	if (!closeAlertIssued) {
		closeAlertIssued=true;
		Alert.show("Max student Limit in this class reached", "MESSAGE", Alert.OK, null, closeapp_error);
	}
	// Variable used for finding same user already logged in 
	userConnectionRejected=true;
	AuditContext.userAction.connectionRejectEventLog("Collaboration Module", usersConnection.connectionURL);
	setupModulesOnConnectionClose();
	
}

private function connectionLostHandler() : void
{
	//Flash Player has detected a network change, for example, a dropped wireless connection, 
	//a successful wireless connection,or a network cable loss.
	applicationType::DesktopWeb{
		AuditContext.userAction.connectionFailEventLog("Collaboation Module", usersConnection.connectionURL);
		updateStatusbar({module: "users", connectionStatus: false});
	}
	applicationType::mobile{
		updateStatusbar({connectionStatus: false});
	}
}

private function connectionFailedHandler():void{
	applicationType::DesktopWeb{
		AuditContext.userAction.connectionFailEventLog("Collaboation Module", usersConnection.connectionURL);
		updateStatusbar({module: "users", connectionStatus: false});
	}
	applicationType::mobile{
		updateStatusbar({connectionStatus: false});
	}
	isUserCOCreatedAfterReconnection="N";
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("NetConnection.Connect.Failed::isUserSOCreatedAfterReconnection:" + isUserCOCreatedAfterReconnection);
	setupModulesOnConnectionClose();
	clearPreviousUsers_SO();
	isVideoWallSOReconnected = true;
	isReconnect = true;
}

private function connectionClosedHandler():void{
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp) {
			if(usersConnection)
			{
				AuditContext.userAction.connectionCloseEventLog("Collaboration Module", usersConnection.connectionURL);
			}
			
			if(chatManager)
			{
				chatManager.cleanUp();
				
			}
			if (viewer3DLoaded) {
				viewer3DComp.closeFileList();
				viewer3DComp.viewer3DSWC.networkFailHandler()
			}
			if (viewer3DComp) {
				viewer3DComp.enabled=false;
			}
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.visible 
				&& viewer3DLoaded && alertServerSwitching == null && !closeAlertIssued) {
				Alert.show("Your connection to server is lost. Please wait till it reconnects automatically.", "MESSAGE", 0, this, null, null, 1);
			} else {
				netStatusmsg=false;
			}
			updateStatusbar({module: "users", connectionStatus: false});
			isUserCOCreatedAfterReconnection="N";
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("NetConnection.Connect.Closed::isUserSOCreatedAfterReconnection:" + isUserCOCreatedAfterReconnection);
			// Activate main application, if it is minimized 
			// activate() method is not available for web.
			applicationType::desktop {
				FlexGlobals.topLevelApplication.activate();
			}
			lstUsers.setUserListDataProvider();
			//Issue #284:Start
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: NetConnection.Connect.Closed:" + " connectionRejected:" + userConnectionRejected);
			
			setupModulesOnConnectionClose();
			clearPreviousUsers_SO();
		}
	}
	applicationType::mobile{
		updateStatusbar({connectionStatus: false});
		isUserCOCreatedAfterReconnection="N";
		lstUsers.setUserListDataProvider();
		setupModulesOnConnectionClose();
		clearPreviousUsers_SO();
	}
	/*if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isServerFailOver)
	{
		isCollabObjsInited = false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.connectToCollaborationServer(false);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isServerFailOver = false;
	}
	*/
}

private function couldNotConnectHandler():void{
	if (!closeAlertIssued) {
		closeAlertIssued=true;
		Alert.show("Collaboration connection to the server could not be established.\n" + " Please login again.", "Alert", 0, this, closeapp_error);
	}
}

public function onCreateVideoWallFolder():void{
	serverSideFolderCreateService = new HTTPService();
	var tempPath:String="/AVContent/VideoData/"+ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId
		+"/"+ClassroomContext.lecture.lectureId;
	serverSideFolderCreateService.url=encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP+ "/AVScript/Common/" + 
		"createFolderStructure.php?folderPath=" + tempPath);
	serverSideFolderCreateService.addEventListener(ResultEvent.RESULT, serverSideFolderCreated);
	serverSideFolderCreateService.addEventListener(FaultEvent.FAULT,failToCreateServerSideFolder);
	serverSideFolderCreateService.send();
	uploadUrl = serverSideFolderCreateService.url;
	
}
public function serverSideFolderCreated(event:ResultEvent):void{
	
}
public function failToCreateServerSideFolder(evnt:FaultEvent):void{
	trace("failedtocreateserversidefolder ");
}

/**
 * This function is the event listener for MediaServerStatusEvent of MediaServerConnection object
 *
 * @param event of type MediaServerStatusEvent
 * @return void
 */
public function userConnectionStatusHandler(event:MediaServerStatusEvent):void {
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: NetStatusHandler:" + event.code);
	switch (event.code) {
		// The connection attempt to FMS succeeded. 
		case MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED:
			onConnectionTestFailed();
			break;
		case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
			connectionSuccessHandler();
			break;
		// The connection attempt to FMS rejected. 
		case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
			connectionRejectedHandler();
			break;
		// The connection to FMS was closed. 
		case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
			//connectionFailedHandler();
			connectionClosedHandler();
			break;
		case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
			connectionFailedHandler();
			break;
		case MediaServerStatusEvent.CODE_NET_STATUS_CHANGE:
			//For network loss
			connectionLostHandler();
			break;
		default:
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Collaboration Module: WARNING: Unhandled info code " + event.code);
			break;
		
	}
}

private function onConnectionTestFailed():void
{
	if (msgBox)
	{
		PopUpManager.removePopUp(msgBox);
	}
	msgBox = MessageBox.show("Connection to the Collaboration server failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", "Connection Failed", MessageBox.MB_OK, null, closeMediaServerConnection);
}


private function closeMediaServerConnection(event:MessageBoxEvent):void
{
	if (usersConnection)
	{
		usersConnection.close();
	}
}

/**
 * This function is used to solve timing issue for Guest users.
 *
 *
 * @return void
 */
applicationType::web {
	public function set2DComponentAccessibility():void {
		if (setTimeOutID) {
			clearTimeout(setTimeOutID);
		}
		//Bug fix #7068: Because of Security Sandbox Violation, we can't load 2D objects from a different server
		//These logic moved from userConnectionStatusHandler to solve timing issue for Guest users.
		if (ClassroomContext.CONTENT_VIEWER2D != URLUtil.getServerName(FlexGlobals.topLevelApplication.loaderInfo.url)) {
			classroomComponentSgl.viewer2DBox.removeAllChildren();
			setMessageFor2D(classroomComponentSgl.viewer2DBox, "2D sharing will not work in A-VIEW web version with current class settings.\n Please contact your A-VIEW administrator.");
		} else {
			unSetMessageForFullScreen(classroomComponentSgl.viewer2DBox);
			classroomComponentSgl.viewer2DBox.addChild(viewer2DComp);
		}
	}
}


public function clearPreviousUsers_SO():void {
	stopPresentersStream();
	applicationType::DesktopWeb{
		clearAllViewerStreamDisplays(selectedViewerDisplays);
	}
	//Cleanup the previousUsers_SO, so that we can re process all the users statuses again
	previousUsers_SO.splice(0);
	
}

/**
 * This function is for creating and connecting all remote shared objects
 * It also creates object of userlist component and set it's position in the UI
 *
 *
 * @return void
 */
public function initializeCollaborationObjects():void {
	if(!isCollabObjsInited)
	{
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users:connectComponents1, usersConnection.netConnection.connected:" + usersConnection.netConnection.connected);
		
		usersCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("users_so1");
		usersCollaborationObject.setOnSync(usersSyncHandler);
		//usersCollaborationObject.setOnClear(onClearUserData);
		usersCollaborationObject.setOnSend("viewVideoStatusHandler", viewVideoStatusHandler);
		//users_so.addEventListener(AsyncErrorEvent.ASYNC_ERROR, usersAsyncErrorHandler);
		//users_so.connect(usersConnection);
		//users_so.client=this; //for desktopSharingStatusHandler
		peopleCountCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("attendanceSO");
		peopleCountCollaborationObject.setOnClear(peopleCountHandler);
		peopleCountCollaborationObject.setOnSync(peopleCountSOHandler);
		peopleCountCollaborationObject.setOnChange(peopleCountSOHandler);
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users:connectComponents2, usersConnection.netConnection.connected:" + usersConnection.netConnection.connected);
		//Issue #76
		// Create remote shared object for 'push to talk' feature 
		audioMuteColloaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("audioMuteSharedObject1");
		audioMuteColloaborationObject.setOnSync(audioMuteSyncHandler);
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users:connectComponents3, usersConnection.netConnection.connected:" + usersConnection.netConnection.connected);
		
		adminConsoleCollabObject=ClassroomContext.collaborationService.connectCollaborationObject("adminSharedObj");
		if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
		
			adminConsoleCollabObject.setOnSync(adminConsoleSyncHandler);
		}
		
		recordCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("recordSharedObj");
		
		recordCollaborationObject.setOnClear(recordSOClearHandler);
		recordCollaborationObject.setOnChange(recordChangeHandler);
		
		muiCollaborationObject=ClassroomContext.collaborationService.connectCollaborationObject("muiSharedObj");
		muiCollaborationObject.setOnClear(muiHandler);
		muiCollaborationObject.setOnChange(muiHandler);
		if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MONITOR_TYPE) {
			connectModulesCollabObjects();
		}
		//Added library file for desktop sharing, so the following function not used for web.
		applicationType::desktop {
			if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
				createDesktopSharingConnection();
		}
		if(ClassroomContext.aviewClass.classType=="Meeting" && ClassroomContext.isModerator)
		{
			usersConnection.netConnection.call("setMeetingData",null,"YES");
		}
		isCollabObjsInited = true;
	}
}



private var isRecordbyAdmin:Boolean=false;

public function recordSOClearHandler():void {
	applicationType::DesktopWeb{
		var objDetails:Object=recordCollaborationObject.getData()["record"];
		if (objDetails && (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)) {
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst && objDetails.command == "start") {
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.recordIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.stopRecordIcon;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.btnRecord.toolTip="Stop Recording";
			} else {
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.recordIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.startRecordIcon;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.btnRecord.toolTip="Start Recording";
			}
		} else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst) {
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.recordIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.startRecordIcon;
		}
	}
}

public function recordChangeHandler(objRecordDetails:Object, oldValue:Object):void {
	applicationType::DesktopWeb{
		if (ClassroomContext.moderatorName == ClassroomContext.userVO.userName) {
			if (objRecordDetails.userName != ClassroomContext.moderatorName) {
				if (objRecordDetails.command == "start" && recordIcon == startRecordIcon) {
					//automaticRecording = true;
					if ((ClassroomContext.lecture.recordedContentUrl == null || ClassroomContext.lecture.recordedContentUrl == "") || (ClassroomContext.lecture.recordedVideoFilePath == null || ClassroomContext.lecture.recordedVideoFilePath == "") || (ClassroomContext.lecture.recordedPresenterVideoUrl == null || ClassroomContext.lecture.recordedPresenterVideoUrl == "")) {
						isRecordbyAdmin=true;
					}
					startRecord();
				} else if (objRecordDetails.command == "stop" && recordIcon == stopRecordIcon) {
					startRecord();
				}
			}
		} else if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
			if (objRecordDetails.command == "start" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst) {
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.recordIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.stopRecordIcon;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.btnRecord.toolTip="Stop Recording";
			} else if (objRecordDetails.command == "stop" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst) {
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.recordIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.startRecordIcon;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.adminConsoleInst.btnRecord.toolTip="Start Recording";
			}
		}
	}
}
private var waitForUserSyncAndConnectModulesCollabObjectsTimeoutId:uint;

private function waitForUserSyncAndConnectModulesCollabObjects():void {
	clearTimeout(waitForUserSyncAndConnectModulesCollabObjectsTimeoutId);
	
	if (userSoSyncStatus == "NotSynced") {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: waitForUserSyncAndConnectModulesCollabObjects: Waiting..");
		waitForUserSyncAndConnectModulesCollabObjectsTimeoutId=setTimeout(waitForUserSyncAndConnectModulesCollabObjects, 100);
	} else {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: waitForUserSyncAndConnectModulesCollabObjects: Done.");
		connectModulesCollabObjects();
	}
}

private var moduleSOStatus:String="NotConnected";

private function connectModulesCollabObjects():void {
	if (userSoSyncStatus == "NotSynced") {
		waitForUserSyncAndConnectModulesCollabObjects();
		return;
	}
	applicationType::DesktopWeb{
		chatComp.connectChatCollaborationObject();
		connectSelectedModule();
		docComp.initializeDocumentCollaborationObject();
		wbComp.connectWhiteboardCollabObjects();
		videoShareObj.setConnection(usersConnection);
		viewer3DComp.connectSharedObjects();
		viewer2DComp.set2DSharedObjects();
		connectDesktopSharingCollabObject();
		connectVideoWallCollabObject();
		moduleSOStatus="Connected";
		if (ClassroomContext.aviewClass.classType == "Meeting") {
			showViewerWall();
		}
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.chatComp.connectChatCollaborationObject();
		FlexGlobals.topLevelApplication.connectSelectedModule();
		FlexGlobals.topLevelApplication.wbComp.connectWhiteboardCollabObjects();
		if(FlexGlobals.topLevelApplication.deviceDPI.deviceModel != "Nexus 7"){
			connectDesktopSharingCollabObject();
		}
		moduleSOStatus="Connected";
	}
}

private function getUserTime(userName:String):UserTime {
	var userTime:UserTime=null;
	for (var i:int=0; i < userTimes.length; i++) {
		if (userTimes[i].userName == userName) {
			userTime=userTimes[i];
			break;
		}
	}
	return userTime;
}

private function setUserTimes():void {
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Entered setUserTimes");
	for (var uName:String in usersCollaborationObject.getData()) {
		var userTime:UserTime=getUserTime(uName);
		
		if (userTime == null) {
			userTime=new UserTime();
			userTime.userName=uName;
			userTimes.addItem(userTime);
		}
		var user:Object=getUserSO(uName);
		userTime.userStatus=user.userStatus;
		userTime.isVideoPublishing=user.isVideoPublishing;
	}
}

private var selectedViewersForAdmin:ArrayList=new ArrayList();

public function getFirstAcceptedViewerAdmin():String {
	var first:String="";
	if (selectedViewersForAdmin.length > 0) {
		first=selectedViewersForAdmin.getItemAt(0).toString();
	}
	return first;
}

private function addAcceptedViewerForAdmin(userName:String):void {
	var index:int=findAcceptedViewerIndexForAdmin(userName);
	if (index == -1) {
		selectedViewersForAdmin.addItem(userName);
	}
}

private function removeAcceptedViewerForAdmin(userName:String):void {
	var index:int=findAcceptedViewerIndexForAdmin(userName);
	if (index != -1) {
		selectedViewersForAdmin.removeItemAt(index);
	}
}

private function findAcceptedViewerIndexForAdmin(userName:String):int {
	var index:int=-1;
	for (var i:int=0; i < selectedViewersForAdmin.length; i++) {
		if (selectedViewersForAdmin.getItemAt(i) == userName) {
			index=i;
			break;
		}
	}
	return index;
}

private function removeNonExistingViewersForAdmin():void {
	for (var i:int=0; i < selectedViewersForAdmin.length; i++) {
		var found:Boolean=false;
		for (var uName:String in usersCollaborationObject.getData()) {
			if (selectedViewersForAdmin.getItemAt(i) == uName) {
				found=true;
				break;
			}
		}
		if (!found) {
			selectedViewersForAdmin.removeItemAt(i);
			i--;
		}
	}
}

private function setPresenterModeratorAndSelectedViewer():void {
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Entered setPresenterAndModerator");
	var moderatorFound:Boolean=false;
	var presenterFound:Boolean=false;
	var selectedViewerFound:Boolean=false;
	
	for (var uName:String in usersCollaborationObject.getData()) {
		//Set the moderator
		if (usersCollaborationObject.getData()[uName].isModerator == true) {
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Setting:" + uName + ":As Moderator");
			ClassroomContext.moderatorName=uName;
			moderatorFound=true;	
		}
		
		//Set the presentor
		if (getUserSO(uName).userRole == Constants.PRESENTER_ROLE) {
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Setting:" + uName + ":As Presenter");
			if (ClassroomContext.currentPresenterName != uName) {
				applicationType::DesktopWeb{
					//Fix for bug # 18492 start
					//Check added due to null pointer exception
					if(iVideoWallLayout)
					{
						iVideoWallLayout.removeOldPresenterFromBigScreenInVideoWall(ClassroomContext.currentPresenterName, uName);
					}
					//Fix for bug # 18492 end
				}
			}
			applicationType::desktop{
				//Fix for #20126
				if(desktopViewer.desktopSharingWindow) {
//					desktopViewer.desktopSharingWindow.close();
//					desktopViewer.popOutDesktopSharingWindow();
					desktopViewer.setPopOutButtonVisibility(true);
				}
			}
			setCurrentPresenter(uName);
			presenterFound=true;
			removeAcceptedViewerForAdmin(uName);
		} else if (getUserSO(uName).userRole == Constants.VIEWER_ROLE && getUserSO(uName).userStatus == Constants.ACCEPT) {
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Setting:" + uName + ":As SelectedViewer");
			selectedViewerFound=true;
			addAcceptedViewerForAdmin(uName);
			if (getPreviousState(uName) && getPreviousState(uName).userStatus != Constants.ACCEPT && ClassroomContext.userVO.userName == uName) {
				if(!isUserIntraAlertDuringReconnection){
				lstUsers.notifySelectedViewer=true;
				isUserIntraAlertDuringReconnection = true;
				}
				
			}
		} else {
			removeAcceptedViewerForAdmin(uName);
			//#Bugfix for admin login
			if(lstUsers && ClassroomContext.userVO.userName == uName)
			lstUsers.notifySelectedViewer=false;
			
			
		}
		//#Bugfix for admin login
		
		//Fix for bug # 18492 start
		//Check for null 
		if(lstUsers)
		{
			lstUsers.setRoleStatusDisplay(uName);
			lstUsers.notifySelectedViewer=false;
		}
		//Fix for bug # 18492 end
			
	}
	
	removeNonExistingViewersForAdmin();
	
	if (!moderatorFound) {
		if (Log.isWarn()) FlexGlobals.topLevelApplication.mainApp.log.warn("No Moderator found. Setting Moderator as blank");
		ClassroomContext.moderatorName="";
	}
	if (!presenterFound) {
		if (Log.isWarn()) FlexGlobals.topLevelApplication.mainApp.log.warn("No Presenter found. Setting Presenter as blank");
		setCurrentPresenter("");
	}
	if (!selectedViewerFound) {
		if (Log.isInfo()) FlexGlobals.topLevelApplication.mainApp.log.info("No Selected Viewer found. Setting Viewer as blank");
	}
	
	if (getUserSO(ClassroomContext.moderatorName) != null) {
		if (getUserSO(ClassroomContext.moderatorName).userRole != Constants.PRESENTER_ROLE) {
			//moderator is viewer (not presenter)
			//Stop recording if he has started recording the lecture
			applicationType::DesktopWeb{
				stopRecordingForModerator();
			}
		}
	}
	applicationType::DesktopWeb{
		if (ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName && selectedModule_so && getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE && previousUsers_SO != null && getPreviousState(ClassroomContext.userVO.userName) != null && getPreviousState(ClassroomContext.userVO.userName).userRole == Constants.VIEWER_ROLE) {
			if (videoWallLayout == Constants.SIMPLE_LAYOUT && selectedModule_so.getData()["val"] == 6) {
				stopSelectedViewersStream(ClassroomContext.userVO.userName, false);
				showViewerWall(true);
			} else if (videoWallLayout != Constants.SIMPLE_LAYOUT  && selectedModule_so.getData()["val"] != 6) {
				if (videoWallCollaborationObject && videoWallCollaborationObject.getData()["isSelected"] == false)
					toggleVideoWall();
				setActiveModule(false);
			}
		}
	}
}

private function setButtonStatusReconnection():void
{
	var userSOObj:Object=getUserSO(ClassroomContext.userVO.userName);
	if(userSOObj && userSOObj.userRole == Constants.VIEWER_ROLE)
		updateUI(false);
}
/**
 * This method creates the users_so entree of the current user after a reconnection.
 * But we are calling this after the user sync has happend, so that we know who is the current presenter.
 * This will be called only once after reconnection. This is ensured by the life cycle of isUserSOCreatedAfterReconnection variable.
 * This variable is set to null on startup, set to "N" after loosing connection and set to "Y" after reconnection and resync.
 */
private function createUserSOEntreeAfterReconnectionAndUserSOSync():void {
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Entered createUserSOEntreeAfterReconnectionAndUserSOSync::" + latestUsersStaus + ":" + isUserCOCreatedAfterReconnection);
	if (isUserCOCreatedAfterReconnection == "N") {
		
		//Bug #5007:Presenter's icon color changes to grey after restarting the network
		//Moving this logic to server side setUsersCollaborationObject method
		
		
		//		//If the current user is not a moderator and was presenter before connection was lost, 
		//		//most likely he is no longer the presenter as the moderator would have been made the presenter
		//		//If that's the case, then we should change the user's status to HOLD, instead of earlier ACCEPT
		//		//Bug #686
		//		if(!ClassroomContext.isModerator && classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		//		{
		//			latestUsersStaus = Constants.HOLD;
		//		}
		
		//If user connection fails immediately after log in, the shared object would not been set till now
		//In that case latestUserStatus would be null
		//Hence initializing to HOLD.
		if (latestUsersStaus == null) {
			latestUsersStaus=Constants.HOLD;
		}
		
		//On reconnection, resetting the last status of the current user.
		//Because the status might have got cleared by onDisconnect function on the server side
		
		setUserSOStatus(ClassroomContext.userVO.userName, latestUsersStaus, latestControlData, ClassroomContext.userVO.role, ClassroomContext.isModerator, ClassroomContext.isAudioOnlyMode, ClassroomContext.userVO.userDisplayName, latestPublishStatus, isHide, isMute, classroomContextObj.userRole, streamDataObjects, interactionCount, ClassroomContext.userInstituteVO.instituteName, AVCEnvironment.runTime, AVCEnvironment.deviceType, videoCaptureHeight, videoCaptureWidth, viewVideoCount);
	applicationType::DesktopWeb{
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE){
				setTimeout(setButtonStatusReconnection, 1000);
				if(lastSelectedUser!=null && getUserSO(lastSelectedUser)!=null && getUserSO(lastSelectedUser).userStatus == Constants.ACCEPT)
				{
					
					setVideoWallSharedSO(videoWallSelected,lastSelectedUser,lastSelectedStream, videoWallLayout);
				}
				else 
				{
					setVideoWallSharedSO(videoWallSelected,ClassroomContext.currentPresenterName,ClassroomContext.currentPresenterName, videoWallLayout);
				}
			}
			else if(classroomContextObj.userRole == Constants.VIEWER_ROLE && latestUsersStaus == Constants.ACCEPT)
			{
				setTimeout(changeLayoutMessgeReconnection, 1000);
			}
			audioMuteSyncHandlerTimeoutId=setTimeout(setAudioMuteSyncHandler, 100);
		}
		isUserCOCreatedAfterReconnection="Y";
	}
}

private function setAudioMuteSyncHandler():void {
	clearTimeout(audioMuteSyncHandlerTimeoutId);
	var evt:SyncEvent;
	audioMuteSyncHandler(evt);
}
import mx.core.UIComponent;
import mx.managers.PopUpManager;
import edu.amrita.aview.core.evaluation.questionPaper.QuestionPaperQuestions;
import flash.media.Microphone;
import mx.core.FlexGlobals;
import ws.tink.mx.events.AlertEvent;
import flash.display.ActionScriptVersion;
import mx.utils.StringUtil;
applicationType::DesktopWeb{
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
	import edu.amrita.aview.core.video.VideoStreamDisplay;
}
import spark.components.Button;
import edu.amrita.aview.core.shared.components.userList.UserSOValue;
import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ClassroomContext;
import mx.utils.ObjectUtil;
import edu.amrita.aview.core.shared.audit.AuditConstants;
// CRASH: API
//import edu.amrita.aview.questions.events.BreakSessionEvent;
import edu.amrita.aview.core.login.PrepareLogin;
import edu.amrita.aview.core.desktopSharing.DesktopSharingComponent;
import edu.amrita.aview.core.video.IVideoWallLayout;
import flash.events.MouseEvent;
import edu.amrita.aview.core.login.boilerplate.Strings;



private function auditUserStates():void {
	//If refresh button is clicked, then do not audit as the synchandler is called not because of actual change 
	if (!isRefreshPressed) {
		var previousUsersSOState:Object=getPreviousState(ClassroomContext.userVO.userName);
		if (previousUsersSOState) {
			//			if(previousUsersSOState.userStatus != latestUsersStaus)
			//			{
			//				AuditContext.userAction.userStatusEventLog(latestUsersStaus);
			//			}
			
			if (previousUsersSOState.userRole != latestUserRole) {
				userRoleEventLog(latestUserRole);
			}
			
			
			if (previousUsersSOState.isVideoPublishing != latestPublishStatus) {
				var publishingMode:String="AudioVideo"
				if (ClassroomContext.isAudioOnlyMode)
					publishingMode="AudioOnly"
				if (latestPublishStatus) {
					applicationType::DesktopWeb{
						//TODO:This mode should be based on the user selection
						videoPublishStartEventLog(publishingMode, audioDeviceDrive + "," + videoDeviceDrive);
					}
				} else {
					applicationType::DesktopWeb{
						videoPublishEndEventLog(publishingMode, audioDeviceDrive + "," + videoDeviceDrive);
					}
				}
			}
		}
	}
	
}

/**
 *
 * @private
 * Audits the "VideoPublishEnd" action, when the user stops publishing the video
 *
 * @param mode of publishing (Audio only or Audio/Video)
 * @param AVDriver - The audio video driver string
 * @return void
 *
 */
private function videoPublishEndEventLog(mode:String, AVDriver:String):void
{
	var bandWidth:String=publishingBandwidthUserRole(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userStatus);
	AuditContext.userAction.createAction(AuditConstants.videoPublishEnd, mode, bandWidth, AVDriver);
}

/**
 *
 * @public
 * Audits the "VideoPublishStart" action, when the user starts publishing the video
 *
 * @param mode of publishing (Audio only or Audio/Video)
 * @param AVDriver - The audio video driver string
 * @return void
 *
 */
public function videoPublishStartEventLog(mode:String, AVDriver:String):void
{
	var bandWidth:String=publishingBandwidthUserRole(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userStatus);
	AuditContext.userAction.createAction(AuditConstants.videoPublishStart, mode, bandWidth, AVDriver);
}

/**
 *
 * @private
 * Audits the "UserRole" action, when the user role is changed between presenter/viewer
 *
 * @param currentRole the new role of this user
 * @return void
 *
 */
private function userRoleEventLog(currentRole:String):void
{
	var bandWidth:String=publishingBandwidthUserRole(currentRole);
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.userRole, currentRole, bandWidth, null);
	}
}
/**
 *
 * @private
 * Finds the published bandwidth for the user based on the role and type of the user
 *
 * @param currentRole - Current role of the user
 * @return String: The publising bandwidth (Numeric value) as String.
 *
 */
private function publishingBandwidthUserRole(currentRole:String):String
{
	var tempBandwidth:String="";
	var i:int=0;
	if (currentRole == Constants.PRESENTER_ROLE)
	{
		if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE)
		{
			applicationType::DesktopWeb{
				for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData.length; i++)
				{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].serverType == Constants.FMS_PRESENTER)
					{
						tempBandwidth=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].bandWidth;
						break;
					}
				}
			}
			applicationType::mobile{
				for (i=0; i < videoServersData.length; i++)
				{
					if (videoServersData[i].serverType == Constants.FMS_PRESENTER)
					{
						tempBandwidth=videoServersData[i].bandWidth;
						break;
					}
				}
			}
		}
		else
		{
			applicationType::DesktopWeb{
				for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData.length; i++)
				{
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].serverType == Constants.FMS_PRESENTER)
					{
						tempBandwidth+=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].bandWidth + ",";
					}
				}
			}
			applicationType::mobile{
				for (i=0; i < videoServersData.length; i++)
				{
					if (videoServersData[i].serverType == Constants.FMS_PRESENTER)
					{
						tempBandwidth+=videoServersData[i].bandWidth + ",";
					}
				}
			}
		}
	}
	else
	{
		applicationType::DesktopWeb{
			for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData.length; i++)
			{
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].serverType == Constants.FMS_VIEWER)
				{
					tempBandwidth=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].bandWidth;
				}
			}
		}
		applicationType::mobile{
			for (i=0; i < videoServersData.length; i++)
			{
				if (videoServersData[i].serverType == Constants.FMS_VIEWER)
				{
					tempBandwidth=videoServersData[i].bandWidth;
				}
			}
		}
	}
	return tempBandwidth;
}

/**
 * This function is the event listener for SyncEvent of users_so shared object.
 * It is used to update the status of all active users at all the nodes.
 *
 * The function is called in the following cases to update the status of all active users.
 * (The status of the shared object in each case is also specified):
 * 1.When a PRESENTER or VIEWER logs in                 (Status  - hold) .
 * 2.When a PRESENTER starts his own video              (Status  - accept).
 * 3.When a PRESENTER selects a VIEWER for interaction  (Status  - accept).
 * 4.When a PRESENTER selects a VIEWER in ‘view’ mode   (Status  - view).
 * 5.When a PRESENTER stops interaction with a VIEWER   (Status  - hold).
 * 6.When a PRESENTER releases VIEWER from ‘view’ mode  (Status  - hold).
 * 7.When a VIEWER clicks on ‘hand raise’ button        (Status  - waiting).
 * 8.When a VIEWER clicks on ‘release me’ button        (Status  - hold).
 *
 * @param event of type SyncEvent
 * @return void
 */
public function usersSyncHandler(userData:Object):void {
	//usersSyncHandler is called with null event from VideoScript_Code.
	//Once on reconnection and once on refresh
	//In both those times, we should process this method only if the User connection is live and user_so is synced atleast once after the connection is made
	applicationType::DesktopWeb{
		if ((userData == null && isUserCOCreatedAfterReconnection == "N") || classroomExited) {
			return;
		}
	}
	applicationType::mobile{
		if ((userData == null && isUserCOCreatedAfterReconnection == "N")) {
			return;
		}
	}
	// ArrayCollection to store the viewer's in  'view' mode.
	var viewedUsersArray:ArrayCollection;
	
	// Array to hold the active viewer list. 
	var tmpusersArray:Array=new Array();
	
	
	// Flag to check if a VIEWER is in 'accept' mode 
	var startedPresentorVideo:Boolean=false;
	
	var isReconnectedUserisEmpty:Boolean=false;
	//	if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users:usersSyncHandler, usersConnection.netConnection.connected:" + usersConnection.netConnection.connected);
	
	setPresenterModeratorAndSelectedViewer();
	setQuestionButtonStatus();
	setUserTimes();
	//Issue #76
	//Storing the sortedarray in the global array so that audioMuteSharedObject's sync handler can use it
	if (lstUsers) lstUsers.sortUserList();
	var previousNumUsers:int=numUsers;
	numUsers=(lstUsers) ? lstUsers.sortedPushToTalkArray.length : 0;
	if (previousNumUsers != numUsers) {
		applicationType::DesktopWeb{
			videoShareObj.onVideoStatusSync(null);
		}
	}
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
		return;
	}
	
	//---------------------------------------------------
	//STARTING TO PROCESS CURRENT USER
	//---------------------------------------------------
	var uName:String=ClassroomContext.userVO.userName;
	var previousUsersSOState:Object=getPreviousState(uName);
	if (previousUsersSOState != null) {
		prevSOStateBeforeReconnection=ObjectUtil.copy(previousUsersSOState);
	}
	
	
	if (getUserSO(uName) != null) {
		//			if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug(" user sync getUserSOStatus(uName) != null");
		//Issue #284:Start
		//If the userName is same as the current shared object name, 
		//Then set the usersLatestUsers_SOData
		latestUsersStaus=getUserSO(uName).userStatus;
		latestControlData=getUserSO(uName).controlStatus;
		latestUserRole=getUserSO(uName).userRole;
		latestPublishStatus=getUserSO(uName).isVideoPublishing;
		auditUserStates();
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users.usersSyncHandler :- User :" + uName + ", Status :" + latestUsersStaus + ", role :" + latestUserRole + ",  ControlData :" + latestControlData + ",  PublishStatus :" + latestPublishStatus);
		//Issue #284:End
		
		classroomContextObj.userRole=getUserSO(uName).userRole;
		
		if (userSoSyncStatus == "NotSynced") {
			userSoSyncStatus="synced";
		}
		if (previousUsersSOState == null && beingViewed && getUserSO(uName).isVideoPublishing && getUserSO(uName).userRole == Constants.VIEWER_ROLE) {
			startCapture(Constants.VIEWER_ROLE);
		}
		
		//Start/Stop vidoe publishing process
		//Only when the refresh is not pressed and user is reconnecting due to network outage
		if ((!isRefreshPressed && previousUsersSOState != null) || isUserCOCreatedAfterReconnection == "N") {
			var prevUserRole:String=null;
			var prevUserStat:String=null;
			if (previousUsersSOState != null) {
				prevUserRole=previousUsersSOState.userRole;
				prevUserStat=previousUsersSOState.userStatus;
			}
			controlVideoPublishingOnStatusChange(getUserSO(uName).userRole, getUserSO(uName).userStatus, prevUserRole, prevUserStat);
		}
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("getUserSO(uName).userRole " + getUserSO(uName).userRole + " previousUsersRole " + ((previousUsersSOState == null) ? "Null" : previousUsersSOState.userRole) + "isRefreshPressed  " + isRefreshPressed);
		//This logic is for switching GUI layout when user role changes
		if (getUserSO(uName).userRole == Constants.PRESENTER_ROLE && (previousUsersSOState == null || previousUsersSOState.userRole != Constants.PRESENTER_ROLE)) {
			classroomContextObj.userRole=Constants.PRESENTER_ROLE;
			
			// Fix for Bug #8790 : Uncomment this block to fix the bug
			//Fix for bug:14352  : '!ClassroomContext.isModerator' condition is added
			if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE && !ClassroomContext.isModerator) {
				
				applicationType::DesktopWeb{
					classroomComponentSgl.Conso_LiveQuiz.visible=false;
					classroomComponentSgl.Conso_LiveQuiz.includeInLayout=false;
				}
			}
			actionButtons.prsntrReq=false;
			/*if(quizBox.numChildren > 0)
			{
			SetQuizSendBtnvisibility();
			}
			*/
			stopPresentersStream();
			
			if (previousUsersSOState != null && previousUsersSOState.userStatus == Constants.ACCEPT) {
				applicationType::DesktopWeb{
					stopSelectedViewersStream(uName, false);
				}
				applicationType::mobile{
					stopSelectedViewersStream(uName);
				}
			}
			
			var evt:SyncEvent;
			audioMuteSyncHandler(evt);
			
			//When refresh is pressed, it would clear out the previousUsersSOState and hence the control would
			//Enter this block
			//But we do not want the UI to be refreshed
			if (!isRefreshPressed) {
				updateUI(true);
				applicationType::DesktopWeb{
					if (videoWallLayout != Constants.SIMPLE_LAYOUT ) {
						showPresenterVideoInVideoWall();
						startedPresentorVideo=true;
					}
				}
			}
			
		} else if (getUserSO(uName).userRole == Constants.VIEWER_ROLE && (previousUsersSOState == null || previousUsersSOState.userRole != Constants.VIEWER_ROLE)) {
			if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("getUserSO(uName).userRole " + getUserSO(uName).userRole + " previousUsersSOState " + previousUsersSOState + "isRefreshPressed  " + isRefreshPressed);
			// CRJH: API // potential conflict with 4.0 code
			entryFac.getBreakSessionEventObj(EntryFac.CANCEL_BREAK_SESSION);
			classroomContextObj.userRole=Constants.VIEWER_ROLE;
			if (previousUsersSOState == null) {
				presenterReset=true;
			}
			
			//tab2.selectedIndex=previdx;
			applicationType::DesktopWeb{
				if (!isRefreshPressed) {
					PollingBtnVisibility();
				}
			}
			applicationType::desktop {
				if (polling_count > 0) {
					//close() method not avilable for canvas
					pollingMultipleWindow.close();
				}
				if (quiz_count > 0) {
					//close() method not avilable for canvas
					quizMultiWindow.close();
				}
			}
			applicationType::DesktopWeb{
				if (!isRefreshPressed) 
					SetQuizSendBtnvisibility();
			}
			actionButtons.setInteractionRequestButtonStatus();
			
			/*if(getUserSOStatus(ClassroomContext.currentPresenterName) && getUserSOStatus(ClassroomContext.currentPresenterName).isVideoPublishing)
			{
			startPresentersStream();
			}*/
			
			if (getUserSO(uName).userStatus == Constants.ACCEPT && previousUsersSOState == null) {
				//This is to change the title in the selected student panel for the currently loggedin user.
				startSelectedViewersStream(ClassroomContext.userVO.userName);
			}
			
			if (ClassroomContext.aviewClass.videoStreamingProtocol == "RTMFP" || ClassroomContext.aviewClass.videoStreamingProtocol == "rtmfp") {
				stopCapture(Constants.PRESENTER_ROLE);
			}
			
			var evt1:SyncEvent;
			audioMuteSyncHandler(evt1);
			
			//When refresh is pressed, it would clear out the previousUsersSOState and hence the control would
			//Enter this block
			//But we do not want the UI to be refreshed
			if (!isRefreshPressed) {
				updateUI(false);
				applicationType::DesktopWeb{
					if (videoWallLayout == Constants.SIMPLE_LAYOUT) {
						showPresenterVideoInVideoWall();
						startedPresentorVideo=true;
					}
				}
			}
			applicationType::DesktopWeb{
				//We need to remove the viewers from the View video panel (repeater)
				if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
				removeAllViewedViewers();
				//fix for Issue #17811
				if (previousUsersSOState != null && !ClassroomContext.isModerator)
				{
					this.dispatchEvent(new edu.amrita.aview.core.shared.events.ChatEvent(ChatEvent.EXIT_ALL_CHATS,'Y'));
					
				}
				//When a presenter is becoming the viewer, he no longer processes the requests, 
				//hence we can turn off the notification
				userTabUnglow();
			}
		}
			
			
			//Same viewer role but have different status
		else if (getUserSO(uName).userRole == Constants.VIEWER_ROLE && previousUsersSOState.userRole == Constants.VIEWER_ROLE) //SVRS- Issue no 72
		{
			actionButtons.setInteractionRequestButtonStatus();
			applicationType::DesktopWeb{
				//If the the logged in user status changes, reset tbe Action buttons 
				if (getUserSO(uName).userStatus != previousUsersSOState.userStatus) {
					actionButtons.setupHandraise();
					if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE && !ClassroomContext.isModerator) {
						actionButtons.setupPresenterRequest();
					}
				}
			}
			applicationType::mobile{
				//If the the logged in user status changes, reset tbe Action buttons 
				if (getUserSO(uName).userStatus == Constants.HOLD && previousUsersSOState.userStatus!= null && (previousUsersSOState.userStatus ==Constants.WAITING || previousUsersSOState.userStatus ==Constants.ACCEPT)) {
					actionButtons.setupHandraise();
					if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE && !ClassroomContext.isModerator) {
						actionButtons.setupPresenterRequest();
					}
				}else if(getUserSO(uName).userStatus == Constants.ACCEPT && previousUsersSOState.userStatus!= null && previousUsersSOState.userStatus ==Constants.HOLD){
					actionButtons.isBtnHandRaiseReleaseVisible = true;
				}
			}
			if (getUserSO(uName).userStatus == Constants.HOLD && previousUsersSOState.userStatus != Constants.HOLD) {
				
				if (previousUsersSOState.userStatus == Constants.ACCEPT && (isAcceptedStudent(ClassroomContext.userVO.userName) || selectedViewersData.length == 0)) {
					applicationType::DesktopWeb{
						stopSelectedViewersStream(uName, false);
					}
					applicationType::mobile{
						stopSelectedViewersStream(uName);
					}
				}
				actionButtons.btn_handrelease.toolTip="Release the handraise request";
			} else if (getUserSO(uName).userStatus == Constants.ACCEPT && previousUsersSOState.userStatus != Constants.ACCEPT) {
				//This is to change the title in the selected student panel for the currently loggedin user.
				startSelectedViewersStream(ClassroomContext.userVO.userName);
				
				//START-------------------------------
				//Check if the current user is a VIEWER and is selected by the PRESENTER for interaction 
				//If yes,check if push to talk mode is selected
				//If yes,change PRESENTER to talking mode
				//END------------------------------------------------
				//if (getAudioMuteSOValue() == Constants.UN_MUTE || getAudioMuteSOValue() == Constants.MUTE)
				if (getAudioMuteSOValue() != Constants.FREETALK && selectedViewerDisplays.length > 0 && selectedViewerDisplays.length == 1 && getAudioMuteSOValue() != ClassroomContext.currentPresenterName) {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Pushtotalk status:" + getAudioMuteSOValue());
					//resetting sharedobject's status (if we set the same property again it won't call the sync handler) 
					//setAudioMuteSOValue(null);					
					setAudioMuteSOValue(uName);
				}
				actionButtons.btn_handrelease.toolTip="Stop interaction with Presenter";
				
			}
		}
		if(( getUserSO(uName)!=null && getUserSO(uName).isVideoPublishing) && previousUsersSOState!=null && (getUserSO(uName).isVideoHide != previousUsersSOState.isVideoHide || getUserSO(uName).isAudioMute != previousUsersSOState.isAudioMute))
		{
			var isAudioOnlyMode:Boolean = getUserSO(uName).isAudioOnlyMode;
			var userName:String = getUserSO(uName).id;
			var userRole:String = getUserSO(uName).userRole;
			var userStatus:String = getUserSO(uName).userStatus;
			var isVideoHide:Boolean = getUserSO(uName).isVideoHide;
			var isAudioMute:Boolean = getUserSO(uName).isAudioMute;
			hideAndMute(userName, userRole, userStatus, isVideoHide, isAudioMute, isAudioOnlyMode);
		}
		
	} else if (isUserCOCreatedAfterReconnection == "N") {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("This User After Reconnection:" + getUserSO(ClassroomContext.userVO.userName));
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("This user Before Reconnection: " + prevSOStateBeforeReconnection);
		isReconnectedUserisEmpty=true;
		
	}
	//---------------------------------------------------
	//END PROCESSING THE CURRENT USER
	//---------------------------------------------------
	//This variable is used to check whether there is a pending request
	var arePendingRequests:Boolean=false;
	
	// Iterates through all the active users in the shared object and performs various
	// actions based on the status of each user
	for (uName in usersCollaborationObject.getData()) {
		
		//Skip processing guest users..
		if (getUserSO(uName).userType == Constants.GUEST_TYPE) {
			continue;
		}
		
		//		if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug(" user sync forloop uName "+uName);
		previousUsersSOState=getPreviousState(uName);
		var date:Date=new Date();
		applicationType::DesktopWeb{
			
			
			if (getUserSO(uName).userRole == Constants.PRESENTER_ROLE && ClassroomContext.isModerator && recorder.isRecording) {
				//If prevoiusly the presenter is a selected student
				if (previousUsersSOState && previousUsersSOState.userRole == Constants.VIEWER_ROLE 
					&& previousUsersSOState.userStatus == Constants.ACCEPT && recorder.viewerVideoRecorder.currentrecordingStream==uName+"_VIEWER") {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync3. Calling addEndtime for viewer. Stream Name:" + uName + "_VIEWER");
					stopRecordingViewer(uName);
					//controlViewerRecording(uName);
				}
				if (getUserSO(uName).isVideoPublishing) {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("In User sync1: Calling recordStream for the  presenter; Stream Name: " + uName);
					recorder.presenterVideoRecorder.recordStream(getPresentersVideoConnection(0).ncVideo.netConnection, "true", uName, usersCollaborationObject.getData()[uName].userDisplayName);
				}
				
			}
			if (getUserSO(uName).userStatus == Constants.ACCEPT && ClassroomContext.isModerator && getUserSO(uName).userRole == Constants.VIEWER_ROLE && recorder.isRecording) {
				if (getFirstAcceptedStudent() == uName && (!previousUsersSOState || (previousUsersSOState && (previousUsersSOState.userStatus != Constants.ACCEPT || previousUsersSOState.userRole == Constants.PRESENTER_ROLE)))) {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("In User sync2: Calling recordStream for the viewer ; Stream Name: " + uName + "_VIEWER");
					if (getAudioMuteSOValue() == Constants.FREETALK) {
						recordViewer(uName, usersCollaborationObject.getData()[uName].userDisplayName);
					}
				}
				
			} // Case 1- when moderator who is corrently presenter give presenter control to  another viewer 
			//case2. release a user
			if (ClassroomContext.isModerator && getUserSO(uName).userStatus != Constants.ACCEPT && getUserSO(uName).userRole == Constants.VIEWER_ROLE && recorder.isRecording) // what happen
			{
				if (recorder.viewerVideoRecorder.currentrecordingStream==uName+"_VIEWER" && (!previousUsersSOState || (previousUsersSOState && (previousUsersSOState.userStatus == Constants.ACCEPT && previousUsersSOState.userRole == Constants.VIEWER_ROLE)))) {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync4. Calling addEndtime for viewer. Stream Name:" + uName + "_VIEWER");
					stopRecordingViewer(uName);
					//controlViewerRecording(uName);
				}
				if (!previousUsersSOState || (previousUsersSOState && previousUsersSOState.userRole == Constants.PRESENTER_ROLE)) {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync5. Calling addEndtime for presenter. Stream Name:" + uName);
					recorder.presenterVideoRecorder.addEndtime(recorder.getCentralTime(), uName)
				}
				
				if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("" + uName);
			}
		}
		//Issue #85 & #21 --START
		//variable of type object used to hold the 'name' and 'status' of the active users.
		//The 'List' component in the uselist uses this object to display the name and icon(refer: list_iconFunc(item:Object))
		var userObject:Object=new Object();
		
		//user name
		userObject.id=uName;
		//display name
		userObject.label=usersCollaborationObject.getData()[uName].userDisplayName;
		userObject.label=usersCollaborationObject.getData()[uName].userInstituteName;
		//user status
		userObject.data=new UserSOValue(usersCollaborationObject.getData()[uName]);
		if (ClassroomContext.userVO.userName == uName)
		{
			interactionCount=userObject.data.userInteractedCount;
			viewVideoCount=userObject.data.viewVideoCount;
		}
		
		//Alert.show(users_so.data[uName].userRole as String);
		tmpusersArray.push(userObject);
		
		//Issue #85 & #21--END
		
		//If the user is not same as the current loggedin user
		if (uName != ClassroomContext.userVO.userName) { 
			if (getUserSO(ClassroomContext.userVO.userName) != null && (classroomContextObj.userRole == Constants.PRESENTER_ROLE || ClassroomContext.userVO.role == Constants.MONITOR_TYPE) && viewVideoStatus(uName)) {
				if (previousUsersSOState != null) {
					if (getUserSO(uName).isVideoPublishing) {
						viewVideoMessage(uName);
					}
					//If the user who is being viewed had started publishing his video after a stop
					if (getUserSO(uName).isVideoPublishing && !previousUsersSOState.isVideoPublishing) {
						applicationType::DesktopWeb{
							removeViewerFromViewPanel(uName);
						}
						sendViewVideoStatus("start", uName);
					}
						//If the user who is being viewed had stopped publishing after a start..then we are making the video a blank
					else if (!getUserSO(uName).isVideoPublishing && previousUsersSOState.isVideoPublishing) {
						applicationType::DesktopWeb{
							removeViewerFromViewPanel(uName);
							addViewerToViewPanel(uName, getUserSO(uName).userDisplayName);
						}
					}
				}
			}
			if(getUserSO(ClassroomContext.userVO.userName) != null && ClassroomContext.userVO.role==Constants.MONITOR_TYPE && viewVideoStatus(uName)){
				//trace("getUserSO(uName).isVideoPublishing =" +getUserSO(uName).isVideoPublishing + "!previousUsersSOState.isVideoPublishing =" +!previousUsersSOState.isVideoPublishing);
				if(previousUsersSOState != null){
				if (getUserSO(uName).isVideoPublishing  && !previousUsersSOState.isVideoPublishing) {
					applicationType::DesktopWeb{
						removeViewerFromViewPanel(uName);
					}
					sendViewVideoStatus("start", uName);
				}
					//If the user who is being viewed had stopped publishing after a start..then we are making the video a blank
				else if (!getUserSO(uName).isVideoPublishing && previousUsersSOState.isVideoPublishing) {
					applicationType::DesktopWeb{
						removeViewerFromViewPanel(uName);
						addViewerToViewPanel(uName, getUserSO(uName).userDisplayName);
					}
				}
			}
		}
			
			//			if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug(" user sync forloop if uName :"+uName+": getUserSOStatus(uName).userStatus :"+getUserSOStatus(uName).userStatus+": getUserSOStatus(uName).userRole :"+getUserSOStatus(uName).userRole);
			//			if(previousUsersSOState != null)
			//				if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("previousUsersSOState.userRole :"+previousUsersSOState.userRole+": previousUsersSOState.userStatus :"+previousUsersSOState.userStatus);
			if (getUserSO(uName).userRole == Constants.VIEWER_ROLE && (previousUsersSOState == null || previousUsersSOState.userRole == Constants.VIEWER_ROLE)) {
				//Issue #30 & #178
				//START-----------------------------------------
				//Check if a PRESENTER has released a VIEWER from 'interaction' mode or if a VIEWER has pressed 'releaseme' button
				//If yes,title of the VIEWERS panel is changed to 'No Student Selected' and clear the VIEWER stream display panel
				//       and chage the VIEWER's status to 'hold'
				//END------------------------------------------------
				//Issue #30 & #178
				if (getUserSO(uName).userStatus == Constants.HOLD && (previousUsersSOState != null && previousUsersSOState.userStatus == Constants.ACCEPT)) {
					try {
						applicationType::DesktopWeb{
							stopSelectedViewersStream(uName, false);
						}
						applicationType::mobile{
							if(FlexGlobals.topLevelApplication.isVideoPrefrenceON){
								stopSelectedViewersStream(uName);
								addSelectedViewerVideoToPanel(null,false);
							}else{
								for (var p:int=0; p < FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.length; p++){
									if(FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails[p].userName == uName){
										FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.removeItemAt(p);
										break;
									}
								}
							}
						}
					} 
					catch (err:Error) {
						if(Log.isError()) log.error("Error in usersSyncHandler method:"+ err.getStackTrace());
					}
				}
					//START-------------------------------
					//Check if a VIEWER has been selected by the PRESENTER for interaction
					//If yes,the VIEWER stream is started at all nodes except the selected VIEWER's node
					//END------------------------------------------------
				else if (getUserSO(uName).userStatus == Constants.ACCEPT && (previousUsersSOState == null || previousUsersSOState.userStatus != Constants.ACCEPT)) {
					isFloatingWindowClosedModerator=false;
					applicationType::DesktopWeb{
						if (ClassroomContext.isModerator && recorder.isRecording && getFirstAcceptedStudent() == uName) {
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("In User sync3: Calling recordStream for the viewer; Stream Name: " + uName + "_VIEWER");
							if (getAudioMuteSOValue() == Constants.FREETALK) {
								recordViewer(uName, usersCollaborationObject.getData()[uName].userDisplayName);
							}
						}
					}
					applicationType::DesktopWeb{
						startSelectedViewersStream(uName);
						if (!getUserSO(uName).isVideoPublishing) {
							clearViewerStreamDisplay(uName);
						}
					}
					applicationType::mobile{
						//To Remove the selected viewer stream when presenter starts interaction with viewer, if the video preference status is in OFF.
						if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON && getUserSO(uName).isVideoPublishing){
							for (var m:int=0; m < FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.length; m++){
								if(FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails[m].userName == uName){
									FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.removeItemAt(m);
									break;
								}
							}
							if(selectedViewerDetails!= null){
								selectedViewerDetails.addItem(createSelectedViewerObject(uName,uName+Constants.VIEWER_APPEND_NAME));
							}
						}
						else if(FlexGlobals.topLevelApplication.isVideoPrefrenceON)
						{
							startSelectedViewersStream(uName);
						}
						
						if(!getUserSO(uName).isVideoPublishing)
						{
							//AVCM:Videoscript_code.as reference error
							removeStudentStream(uName);
						}
					}
					//START-------------------------------
					// This viewer might be currently viewed by the presenter
					// Check and remove the user from view panel
					//END------------------------------------------------
					applicationType::DesktopWeb{
						if (classroomContextObj.userRole == Constants.PRESENTER_ROLE && !isRefreshPressed) {
							for (var i:int=0; i < viewedViewerDisplays.length; i++) {
								if (uName + Constants.VIEWER_APPEND_NAME == viewedViewerDisplays[i].id) {
									removeViewerFromViewPanel(uName);
								}
							}
						}
					}
				}
					//During the interaction, if the student happens to have stopped the video, the student's video would be blank
					//When the student resumes the video, the video should appear again
				else if (getUserSO(uName).userStatus == Constants.ACCEPT && (previousUsersSOState == null || previousUsersSOState.userStatus == Constants.ACCEPT)) {
					if (getUserSO(uName).isVideoPublishing && !previousUsersSOState.isVideoPublishing) {
						var evt2:SyncEvent;
						applicationType::DesktopWeb{
							if (ClassroomContext.isModerator && recorder.isRecording && getFirstAcceptedStudent() == uName) {
								if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("In User sync4: Calling recordStream for viewer; Stream Name: " + uName + "_VIEWER");
								if (getAudioMuteSOValue() == Constants.FREETALK) {
									recordViewer(uName, usersCollaborationObject.getData()[uName].userDisplayName);
								}
							}
							resumeSelectedViewersStream(uName);
						}
						applicationType::mobile{
							addSelectedViewerVideoToPanel(null,false);
						}
						audioMuteSyncHandler(evt2);
					} else if (!getUserSO(uName).isVideoPublishing && previousUsersSOState.isVideoPublishing) {
						applicationType::DesktopWeb{
							if (ClassroomContext.isModerator && recorder.isRecording && recorder.viewerVideoRecorder.currentrecordingStream==uName+"_VIEWER") {
								if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync6. Calling addEndtime for viewer. Stream Name:" + uName + "_VIEWER");
								stopRecordingViewer(uName);
								//checkAndRecordNextSelectedUser(uName);
							}
							clearViewerStreamDisplay(uName);
						}
						applicationType::mobile{
							removeStudentStream(uName);
						}
					}
					if((getUserSO(uName).isVideoPublishing) && (getUserSO(uName).isVideoHide != previousUsersSOState.isVideoHide || getUserSO(uName).isAudioMute != previousUsersSOState.isAudioMute))
					{
						var isAudioOnly = getUserSO(uName).isAudioOnlyMode;
						var name:String = getUserSO(uName).id;
						var role:String = getUserSO(uName).userRole;
						var status:String = getUserSO(uName).userStatus;
						var isHide:Boolean = getUserSO(uName).isVideoHide;
						var isMute:Boolean = getUserSO(uName).isAudioMute;
						hideAndMute(uName, role, status, isHide, isMute, isAudioOnly);
					}
				}
			} else if (getUserSO(uName).userRole == Constants.VIEWER_ROLE && previousUsersSOState.userRole == Constants.PRESENTER_ROLE) {
				//If we started the new presenter's video already, then we do not want to stop the old presenter's video again
				//As the old presenter's video is stopped while starting the new presenter's video in the startTeachersStream method
				
				if (!startedPresentorVideo && !isPopOutPresent) {
					stopPresentersStream(); //Issue #178
				}
			} else if (getUserSO(uName).userRole == Constants.PRESENTER_ROLE && (previousUsersSOState == null || previousUsersSOState.userRole == Constants.VIEWER_ROLE)) {
				
				applicationType::mobile{
					if(FlexGlobals.topLevelApplication.isVideoPrefrenceON)
					{
						//If this new presenter was an accepted student, then we should stop the student stream
						if (previousUsersSOState != null && previousUsersSOState.userStatus == Constants.ACCEPT) {
							try {
								
								stopSelectedViewersStream(uName);
								addSelectedViewerVideoToPanel(null,false);
							} 
							catch (err:Error) {
								if(Log.isError()) log.error("Error in usersSyncHandler method:"+ err.getStackTrace());
							}
						}
						
						//START-------------------------------
						//Check if the PRESENTER has stopped publishing his audio/video
						//If yes, If the condition is satisfied the video panel of the PRESENTER gets cleared at all the VIEWER nodes
						//END------------------------------------------------
						if (getUserSO(uName).userStatus == Constants.HOLD) {
							stopPresentersStream(); //Issue #178
							//Added for VideoTitle
							if(classroomContextObj.userRole != Constants.PRESENTER_ROLE)
							{
								FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = "";
							}
						}
							//START-------------------------------
							//Check if the PRESENTER has started publishing his audio/video
							//If yes, the PRESENTER stream is started
							//END------------------------------------------------
						else if (getUserSO(uName).userStatus == Constants.ACCEPT) {
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("usersync startpresenter");
							startedPresentorVideo=true;
							//For AVCM: To avoid Presenter videogoing blank at tablet user end, if tablet user starts/stops his local video.
							if(getUserSO(uName).isVideoPublishing && ClassroomContext.currentPresenterName == uName)
							{
								if(ClassroomContext.currentPresenterName != presenterStreamName || FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle == "")
								{
									stopPresentersStream();
									startPresentersStream();
								}
							}
							//Added for VideoTitle
							if(classroomContextObj.userRole != Constants.PRESENTER_ROLE)
							{
								FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = Constants.PRESENTER_VIDEO_TITLE + getUserSO(ClassroomContext.currentPresenterName).userDisplayName;
							}
						}
					}
					else if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON)
					{
						startedPresentorVideo = false;
						stopPresentersStream();
					}
				}
				applicationType::DesktopWeb{
					//If this new presenter was an accepted student, then we should stop the student stream
					if (previousUsersSOState != null && previousUsersSOState.userStatus == Constants.ACCEPT) {
						try {
							stopSelectedViewersStream(uName, false);
						} 
						catch (err:Error) {
							if(Log.isError()) log.error("Error in usersSyncHandler method:"+ err.getStackTrace());
						}
					}
					
					//START-------------------------------
					//Check if the PRESENTER has stopped publishing his audio/video
					//If yes, If the condition is satisfied the video panel of the PRESENTER gets cleared at all the VIEWER nodes
					//END------------------------------------------------
					if (getUserSO(uName).userStatus == Constants.HOLD) {
						stopPresentersStream(); //Issue #178
					}
						//START-------------------------------
						//Check if the PRESENTER has started publishing his audio/video
						//If yes, the PRESENTER stream is started
						//END------------------------------------------------
					else if (getUserSO(uName).userStatus == Constants.ACCEPT) {
						if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("usersync startpresenter");
						startedPresentorVideo=true;
						startPresentersStream();
					}
				}
			} else if (getUserSO(uName).userRole == Constants.PRESENTER_ROLE && previousUsersSOState.userRole == Constants.PRESENTER_ROLE) {
				//START-------------------------------
				//Check if the PRESENTER has stopped publishing his audio/video
				//If yes, If the condition is satisfied the video panel of the PRESENTER gets cleared at all the student nodes
				//END------------------------------------------------
				if (getUserSO(uName).userStatus == Constants.HOLD && previousUsersSOState.userStatus == Constants.ACCEPT) {
					applicationType::DesktopWeb{
						if (ClassroomContext.isModerator && recorder.isRecording) {
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync7. Calling addEndtime for presenter. Stream Name:" + prevPresenterStreamName);
							recorder.presenterVideoRecorder.addEndtime(recorder.getCentralTime(), prevPresenterStreamName);
							
						}
					}
					stopPresentersStream(); //Issue #178
					applicationType::mobile{
						//Added for VideoTitle
						if(classroomContextObj.userRole != Constants.PRESENTER_ROLE)
						{
							FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = "";
						}
					}
				}
				
				//START-------------------------------
				//Check if the PRESENTER has started publishing his audio/video
				//If yes, the PRESENTER stream is started
				//END------------------------------------------------
				if (getUserSO(uName).userStatus == Constants.ACCEPT && previousUsersSOState.userStatus == Constants.HOLD) {
					applicationType::DesktopWeb{
						startedPresentorVideo=true;
						if (ClassroomContext.isModerator && recorder.isRecording) {
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("In User sync5: Calling recordStream for the presenter; Stream Name: " + uName);
							recorder.presenterVideoRecorder.recordStream(getPresentersVideoConnection(0).ncVideo.netConnection, "true", ClassroomContext.currentPresenterName, usersCollaborationObject.getData()[ClassroomContext.currentPresenterName].userDisplayName);
							
						}
						startPresentersStream();
					}
					applicationType::mobile{
						if(FlexGlobals.topLevelApplication.isVideoPrefrenceON)
						{
							startedPresentorVideo=true;
							//For AVCM: To avoid Presenter videogoing blank at tablet user end, if tablet user starts/stops his local video.
							if(getUserSO(uName).isVideoPublishing && ClassroomContext.currentPresenterName == uName)
							{
								if(ClassroomContext.currentPresenterName != presenterStreamName || FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle == "")
								{
									startPresentersStream();
								}
							}
							//AVCM:Added for VideoTitle
							if(classroomContextObj.userRole != Constants.PRESENTER_ROLE)
							{
								FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = Constants.PRESENTER_VIDEO_TITLE + getUserSO(ClassroomContext.currentPresenterName).userDisplayName;
							}
						}else if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON)
						{
							startedPresentorVideo = false;
							stopPresentersStream();
						}
					}
				}
				//For AVCM: To Remove the presenter stream , if the video preference status is in OFF.
				else if(getUserSO(uName).userStatus == Constants.ACCEPT && (previousUsersSOState.userStatus  == Constants.HOLD || previousUsersSOState.userStatus  == Constants.ACCEPT))
				{
					applicationType::mobile{
						if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON)
						{
							startedPresentorVideo = false;
							stopPresentersStream();
						}
					}
				}
				//For AVCM: To add the presenter stream , if the video preference status is in ON.
				else if(getUserSO(uName).isVideoPublishing && getUserSO(uName).userStatus == Constants.ACCEPT &&  previousUsersSOState.userStatus  == Constants.ACCEPT )
				{
					applicationType::mobile{
						if(FlexGlobals.topLevelApplication.isVideoPrefrenceON){
							startedPresentorVideo = true;
							//To avoid Presenter videogoing blank at tablet user end, if tablet user starts/stops his local video.
							if(ClassroomContext.currentPresenterName == uName){
								startPresentersStream();
							}
						}
					}
				}
				if((getUserSO(uName).isVideoPublishing) && (getUserSO(uName).isVideoHide != previousUsersSOState.isVideoHide || getUserSO(uName).isAudioMute != previousUsersSOState.isAudioMute))
				{
					var isAudioOnly = getUserSO(uName).isAudioOnlyMode;
					var name:String = getUserSO(uName).id;
					var role:String = getUserSO(uName).userRole;
					var status:String = getUserSO(uName).userStatus;
					var isHide:Boolean = getUserSO(uName).isVideoHide;
					var isMute:Boolean = getUserSO(uName).isAudioMute;
					hideAndMute(uName, role, status, isHide, isMute, isAudioOnly);
				}
			}
		} else {
			if (getUserSO(uName).userStatus == Constants.ACCEPT && (previousUsersSOState == null || previousUsersSOState.userStatus == Constants.ACCEPT)) {
				if (getUserSO(uName).isVideoPublishing && previousUsersSOState && !previousUsersSOState.isVideoPublishing) {
					var evnt:SyncEvent;
					applicationType::DesktopWeb{
						if (ClassroomContext.isModerator && recorder.isRecording && getFirstAcceptedStudent() == uName) {
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("In User sync6: Calling recordStream the viewer; Stream Name: " + uName + "_VIEWER");
							if (getAudioMuteSOValue() == Constants.FREETALK) {
								recordViewer(uName, usersCollaborationObject.getData()[uName].userDisplayName);
							}
						}
						startSelectedViewersStream(uName);
					}
					applicationType::mobile{
						addSelectedViewerVideoToPanel(null,false);
					}
					audioMuteSyncHandler(evnt);
				} else if (!getUserSO(uName).isVideoPublishing && previousUsersSOState && previousUsersSOState.isVideoPublishing) {
					applicationType::DesktopWeb{
						if (ClassroomContext.isModerator && recorder.isRecording && recorder.viewerVideoRecorder.currentrecordingStream==uName+"_VIEWER") {
							if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("User Sync8. Calling addEndtime for viewer. Stream Name:" + uName + "_VIEWER");
							stopRecordingViewer(uName);
							//						checkAndRecordNextSelectedUser(uName);
						}
						clearViewerStreamDisplay(uName);
					}
					applicationType::mobile{
						removeStudentStream(uName);
					}
				}
				applicationType::mobile{
					//For AVCM: To stop publish the video of selected viewer stream when selected viewer changes the video preference to OFF.
					if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON && getUserSO(uName).isVideoPublishing)
					{
						FlexGlobals.topLevelApplication.videoComp.videoSettings();
					}
				}
			}
			//For AVCM: To stop publish the video of viewing viewer stream when viewing viewer changes the video preference to OFF.
			else if(getUserSO(uName).isVideoPublishing)
			{
				applicationType::mobile{
					if(!FlexGlobals.topLevelApplication.isVideoPrefrenceON)
					{
						FlexGlobals.topLevelApplication.videoComp.videoSettings();
					}
					//To close the selected viewer stream,if presenter stops the interaction.
			 		if(getUserSO(uName).userStatus == Constants.HOLD && previousUsersSOState && previousUsersSOState.isVideoPublishing && previousUsersSOState.userStatus == Constants.ACCEPT)
					{
						if(FlexGlobals.topLevelApplication.isVideoPrefrenceON){
							stopSelectedViewersStream(uName);
							addSelectedViewerVideoToPanel(null,false);
						}else{
							for (var n:int=0; n < FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.length; n++){
								if(FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails[n].userName == uName){
									FlexGlobals.topLevelApplication.mainApp.selectedViewerDetails.removeItemAt(n);
									break;
								}
							}
						}
					}
				}
			}
			//CRMUI: Check whether the code inside the following check is needed.
			///////////
			applicationType::DesktopWeb{
				if (videoWallLayout!=Constants.SIMPLE_LAYOUT) {
					var userso:Object=getUserSO(ClassroomContext.userVO.userName);
					var previousUserSO:Object=getPreviousState(ClassroomContext.userVO.userName);
					if (userso != null) {
						if (previousUserSO != null && !previousUserSO.isVideoPublishing && userso.isVideoPublishing && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName && userso.userStatus == Constants.ACCEPT) {
							startPresentersStream();
						} else if (previousUserSO != null && previousUserSO.isVideoPublishing && !userso.isVideoPublishing && userso.userStatus == Constants.HOLD && ClassroomContext.currentPresenterName == ClassroomContext.userVO.userName) {
							stopPresentersStream();
						}
					}
				}
			}
			///////////
		}
		applicationType::DesktopWeb{
			//For presenter request glow
			if (getUserSO(uName).controlStatus == Constants.PRSNTR_REQUEST) {
				arePendingRequests=true;
				if (previousUsersSOState == null || previousUsersSOState.controlStatus != Constants.PRSNTR_REQUEST) {
					presenterReqNotification();
				}
			}
				//For handraise glow
			else if (getUserSO(uName).userStatus == Constants.WAITING) {
				arePendingRequests=true;
				if (previousUsersSOState == null || previousUsersSOState.userStatus != Constants.WAITING) {
					handraiseNotification()
				}
			}
		}
	}
	
	createUserSOEntreeAfterReconnectionAndUserSOSync();
	applicationType::DesktopWeb{
		//For userTab Unglow
		if (arePendingRequests == false) {
			userTabUnglow()
		}
	}
	//Update the user list 
	if (!isRefreshPressed)
		updateUserList();
	
	//Issue #178
	//If there are any users in Selected Viewers Tile who are not present in the latest shared object,
	//And if any of those VIEWERs were in Accept state, then stop theose VIEWER's video
	for (var index:int=0; index < selectedViewerDisplays.length; index++) {
		var currentLength:int=selectedViewerDisplays.length;
		var currentUserStatus:Object=getUserSO(selectedViewerDisplays[index].userName);
		var userExists:Boolean=(currentUserStatus != null);
		var userName:String=selectedViewerDisplays[index].userName;
		if (isReconnectedUserisEmpty && userName == ClassroomContext.userVO.userName) {
			continue;
		}
		//If the VIEWER who was in accept state, no longer present, and no other VIEWER in Accept state, then
		//We can close the VIEWER stream, otherwise the VIEWER video shown as stuck video on other clients
		if (!userExists || (currentUserStatus.userRole == Constants.VIEWER_ROLE && currentUserStatus.userStatus != Constants.ACCEPT || (currentUserStatus.userRole == Constants.PRESENTER_ROLE && userName == ClassroomContext.currentPresenterName))) {
			applicationType::DesktopWeb{
				lstUsers.userGrid.selectedIndex=0;
				
				if (getUserSO(ClassroomContext.userVO.userName) != null && getUserSO(ClassroomContext.userVO.userName).userRole == Constants.PRESENTER_ROLE && actionButtons.chkboxPushToTalk.selected) {
					if (getAudioMuteSOValue() == userName) {
						setAudioMuteSOValue(ClassroomContext.currentPresenterName);
					}
				}
				stopSelectedViewersStream(userName, false);
				if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("currentUserStatus!=null && currentUserStatus.userRole == Constants.PRESENTER_ROLE && userName == ClassroomContext.currentPresenterName  userExists" + userExists);
				if (currentUserStatus != null && currentUserStatus.userRole == Constants.PRESENTER_ROLE && userName == ClassroomContext.currentPresenterName && videoWallLayout == Constants.PRESENTER_LAYOUT ) {
					if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("currentUserStatus!=null && currentUserStatus.userRole == Constants.PRESENTER_ROLE && userName == ClassroomContext.currentPresenterName ");
					startPresentersStream();
				}
			}
			applicationType::mobile{
				lstUsers.selectedIndex=0;
				//For AVCM: To close the selected viewer stream,if that user close/logout from application.
				stopSelectedViewersStream(userName);
				addSelectedViewerVideoToPanel(null,false);
			}
		}
		//If the length changes due to stopSelectedViewersStream
		if (currentLength > selectedViewerDisplays.length) {
			index=index - (currentLength - selectedViewerDisplays.length);
		}
		applicationType::mobile{
			if (!userExists && currentUserStatus.userRole == Constants.PRESENTER_ROLE&& currentUserStatus.userStatus == Constants.ACCEPT && (ClassroomContext.currentPresenterName == "" || ClassroomContext.currentPresenterName == currentUserStatus.id)){
				stopPresentersStream();
				//Added for VideoTitle
				if(classroomContextObj.userRole != Constants.PRESENTER_ROLE){
					FlexGlobals.topLevelApplication.videoComp.presenterVideoTitle = "";
				}
			}
			//For AVCM: To close the private chat popup window, if the user is logout from the class.
			if (!userExists){
				//closeChatWhileLogOut(previousUsers_SO[index].id);
			}
		}
	}
	
	//If the PRESENTER who was in accept state, no longer present and the current PRESENTER is not different 
	//then we can close the PRESENTER's stream
	applicationType::DesktopWeb{
		var presenterDisplay:VideoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
		
		if (getUserSO(presenterDisplay.userName) == null) {
			stopPresentersStream();
		}
	}
	//Issue #278 - Start
	//Clear the previous shared object array..
	previousUsers_SO.splice(0);
	if(Log.isDebug()) log.debug("isReconnectedUserisEmpty:" + isReconnectedUserisEmpty);
	var isReconnectedUserPrevSO:Boolean=false;
	for (uName in usersCollaborationObject.getData()) {
		//Make a seperate copy of the data and store it in the previousUsers_SO array to compare for changes.
		var users_soData:Object=new Object();
		users_soData.id=uName;
		users_soData.data=getUserSO(uName);
		previousUsers_SO.push(users_soData);
		if (isReconnectedUserisEmpty && uName == ClassroomContext.userVO.userName) {
			isReconnectedUserPrevSO=true;
			users_soData.data.userStatus=Constants.HOLD;
		}
	}
	if (isReconnectedUserisEmpty && !isReconnectedUserPrevSO && prevSOStateBeforeReconnection != null && !isServerSwitchingDone) {
		var users_soObj:Object=new Object();
		users_soObj.id=prevSOStateBeforeReconnection.id;
		users_soObj.data=prevSOStateBeforeReconnection;
		users_soObj.data.userStatus=Constants.HOLD;
		previousUsers_SO.push(users_soObj);
		if (videoWallLayout != Constants.SIMPLE_LAYOUT  && ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName && getUserSO(ClassroomContext.userVO.userName) && getUserSO(ClassroomContext.userVO.userName).isVideoPublishing) {
			startPresentersStream();
		}
	}
	//Issue #278 - END
	
	lstUsers.usersArray=tmpusersArray;
	
	if (classroomContextObj.userRole == Constants.PRESENTER_ROLE || ClassroomContext.userVO.role == Constants.MONITOR_TYPE) {
		//The below code block is to close 'studentView' tiles in PRESENTER side, if a VIEWER in 'view' mode 
		//loses connection with the FMS server
		for (var k:int=0; k < viewedViewerDisplays.length; k++) {
			var flag:int=0;
			for (var j:int=0; j < lstUsers.usersArray.length; j++) {
				if (viewedViewerDisplays[k].userName == lstUsers.usersArray[j].id) {
					flag=1;
					break;
				}
			}
			if (flag == 0) {
				applicationType::DesktopWeb{
					lstUsers.userGrid.selectedIndex=0;
					Alert.show(viewedViewerDisplays[k].userName + " has left the session!!!", "INFO");
					removeViewerFromViewPanel(viewedViewerDisplays[k].userName);
				}
				applicationType::mobile{
					lstUsers.selectedIndex=0;
					MessageBox.show(viewedViewerDisplays[k].name + " has left the session!!!","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				}
			}
			//The below code block is to close 'studentView' tiles in PRESENTER side, if a VIEWER in 'view' mode 
			//changes to audio-only mode
			applicationType::DesktopWeb{
				if (viewedViewerDisplays.length > 0 && getUserSO(viewedViewerDisplays[i].userName).isAudioOnlyMode) {
					lstUsers.userGrid.selectedIndex=0;
					Alert.show(viewedViewerDisplays[i].title + " changed to audio only mode!!!", "Info");
					removeViewerFromViewPanel(viewedViewerDisplays[i].userName);
				}
			}
		}
	}
	if (isRefreshPressed) {
		var evt3:SyncEvent;
		audioMuteSyncHandler(evt3);
	}
}

/*
private function controlViewerRecording(currentRecordingViewer:String = null):void
{
	//if PTT is free talk
	//call check and record next user
	//else if presenter then stop viewer recording..
	//else if record viewer
	
	if (getAudioMuteSOValue() == Constants.FREETALK)
	{
		//Called from user sync handler where the current accepted student is no longer a selected viewer 
		//Then we want to switch to the next user in the selectedViewersList
		if(currentRecordingViewer != null)
		{
			var index:int = -1;
			for(var i:uint=0;i<selectedViewersData.length;i++)
			{
				if(selectedViewersData[i].userName==currentRecordingViewer && i<selectedViewersData.length-1)
				{
					index = i;
					break;
				}
			}
			
			var viewerUserName:String = "";
			var viewerDisplayName:String = "";
			if(selectedViewersData.length > 0)
			{
				viewerUserName = selectedViewersData[index+1].userName;
				viewerDisplayName = users_so.data[selectedViewersData[index+1].userName].userDisplayName;
			}
			
			//If the current recording viewer is not found in the interacting viewers list, then we automatically record the first user
			recordViewer(viewerUserName,viewerDisplayName);
		}
		else
		{
			var firstAcceptedViewer:String = getFirstAcceptedStudent();
			var viewerDisplayName:String = "";
			if(firstAcceptedViewer != "" && users_so.data[firstAcceptedViewer])
			{
				viewerDisplayName = users_so.data[firstAcceptedViewer].userDisplayName;
			}
			recordViewer(firstAcceptedViewer,viewerDisplayName);
		}
		
	}
	else if (getAudioMuteSOValue() == ClassroomContext.currentPresenterName) //Presenter
	{
		if(recorder.viewerVideoRecorder.currentrecordingStream != "")
		{
			stopRecordingViewerStream(recorder.viewerVideoRecorder.currentrecordingStream);
		}
	}
	else if(getAudioMuteSOValue()!="")//Viewer - getAudioMuteSOValue() == ""  means there is no  viewers in intraction
	{
		// When giving presenter control to a viewer.
		if(recorder.presenterVideoRecorder.currentrecordingStream == getAudioMuteSOValue())
		{
			return;
		}
		recordViewer(getAudioMuteSOValue(),users_so.data[getAudioMuteSOValue()].userDisplayName);
	}
}*/
//RGCR: Revisit. This function should execute on the event handler of breakmesssage shared object
private function setQuestionButtonStatus():void {
//		questionComp.answerQuestionButton.visible=false;
//		questionComp.answerQuestionButton.includeInLayout=false;
//		questionComp.voteQuestionButton.visible=false;
//		questionComp.voteQuestionButton.includeInLayout=false;
//		questionComp.deleteQuestionButton.visible=false;
//		questionComp.deleteQuestionButton.includeInLayout=false;
//		questionComp.questionInput.visible=false;
//		questionComp.questionInput.includeInLayout=false;
//		questionComp.postQuestionButton.visible=false;
//		questionComp.postQuestionButton.includeInLayout=false;
//		
//		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.questionComp.enableQuestionAnswer(mui_so.getData()["QADsabl"] == "true");
}

private function recordViewer(viewerUserName:String, viewerDisplayName:String):void {
	
	if (viewerUserName != "") {
		applicationType::DesktopWeb{
			if(recorder.viewerVideoRecorder.currentrecordingStream != "" && viewerUserName+"_VIEWER" != recorder.viewerVideoRecorder.currentrecordingStream)
			{
				stopRecordingViewerStream(recorder.viewerVideoRecorder.currentrecordingStream);
			}
			if(viewerUserName+"_VIEWER" != recorder.viewerVideoRecorder.currentrecordingStream &&  
				getUserSO(viewerUserName)&& getUserSO(viewerUserName).isVideoPublishing)
			{
				//controlRecordIndictionOnVideoTile(viewerUserName,true);
				recorder.viewerVideoRecorder.recordStream(getViewersVideoConnection().ncVideo.netConnection,
					"false",viewerUserName+"_VIEWER",viewerDisplayName);
			}
			//When moderator who is in multipple window , close the video window and re-open
			if(viewerUserName+"_VIEWER" == recorder.viewerVideoRecorder.currentrecordingStream)
			{
				//controlRecordIndictionOnVideoTile(viewerUserName,true);
			}
		}
	}
	
}

/*private function controlRecordIndictionOnVideoTile(viewerUserName:String,show:Boolean):void
{	
	for(var i:int=0;i<selectedViewerDisplays.length;i++)
	{
		var videoStreamDisplay:VideoStreamDisplay = selectedViewerDisplays[i] as VideoStreamDisplay;
		var selectedViewerFromArray:String = videoStreamDisplay.userName;
		if( viewerUserName != selectedViewerFromArray)
		{
			continue;
		}
		else
		{
			videoStreamDisplay.isRecording = true;
			blinkingEffect.play([videoStreamDisplay.imgRecordIndicator]);
			videoStreamDisplay.imgRecordIndicator.includeInLayout=show;
			videoStreamDisplay.imgRecordIndicator.visible=show;
			if(videoStreamDisplay.isFullScreenPresent && videoStreamDisplay.videoFullScreenComp)
			{
				videoStreamDisplay.videoFullScreenComp.imgRecordIndicator.includeInLayout=show;
				videoStreamDisplay.videoFullScreenComp.imgRecordIndicator.visible=show;
			}
		}
	}
		var vidDisplay:VideoStreamDisplay=IVideoWallLayout.getMainVideoDisplay();
		
		if(show && vidDisplay!=null )
		{
			blinkingEffect.play([vidDisplay.imgRecordIndicator]);
		}
		else
		{
			if(blinkingEffect.isPlaying)
			{
				blinkingEffect.stop();
			}
		}
		if(vidDisplay!=null && viewerUserName == vidDisplay.userName)
		{
			vidDisplay.imgRecordIndicator.includeInLayout=show;
			vidDisplay.imgRecordIndicator.visible=show;
		}
		if(vidDisplay!=null && vidDisplay.isFullScreenPresent && vidDisplay.videoFullScreenComp)
		{
			vidDisplay.videoFullScreenComp.imgRecordIndicator.includeInLayout=show;
			vidDisplay.videoFullScreenComp.imgRecordIndicator.visible=show;
		}
}*/


public function stopRecordingViewer(viewerUserName:String):void {
	stopRecordingViewerStream(viewerUserName + "_VIEWER");
}

public function stopRecordingViewerStream(viewerStreamName:String):void {
	var recordingViewer:String="";
	if (viewerStreamName != "") {
		recordingViewer=viewerStreamName.substring(0, viewerStreamName.lastIndexOf("_VIEWER"));
	}
	applicationType::DesktopWeb{
		recorder.viewerVideoRecorder.addEndtime(recorder.getCentralTime(), viewerStreamName);
	}
}

private var interactionCount:int=0;
private var recordingPresenterVideoXml:XML=<video></video>
private var recordingViewerVideoXml:XML=<video></video>
private var muiAlert:Alert=null;


public function changeMUIMode(bool:Boolean):void {
		if (!usersConnection.netConnection.connected) {
			applicationType::DesktopWeb{
				if (isMUISelected)
					chkBoxMultiUserInteraction.selected=true;
				else
					chkBoxMultiUserInteraction.selected=false;
				return;
			}
			applicationType::mobile{
				return;
			}
		}
	
	if (bool) {
		interactionMUICount=ClassroomContext.aviewClass.maxViewerInteraction;
		isMUISelected=true;
		actionButtons.isMUISelected = true;
		muiSOValueSet("true");
	} else {
		interactionMUICount=1;
		isMUISelected=false;
		actionButtons.isMUISelected = false;
		applicationType::mobile{
			//Check the number of selected user,if selected user is more than 1 remove the connection.
			if(FlexGlobals.topLevelApplication.isVideoPrefrenceON){
				if(selectedViewersData.length>1){
					MessageBox.show("By turning off this option all selected viewers except the first selected user ,will be removed from interaction.Do you want to continue?","Confirm File Deletion",MessageBox.MB_YESNO,null,checkMUIAlert,checkMUIAlert,MessageBox.IC_INFO);
				}else{
					muiSOValueSet("false");
				}
			}else{//'selectedViewersData' value is null, when user changes video settings to OFF.
				if(selectedViewerDetails.length>1){
					MessageBox.show("By turning off this option all selected viewers except the first selected user ,will be removed from interaction.Do you want to continue?","Confirm File Deletion",MessageBox.MB_YESNO,null,checkMUIAlert,checkMUIAlert,MessageBox.IC_INFO);
				}else{
					muiSOValueSet("false");
				}
			}
		}
		applicationType::DesktopWeb{
			if (selectedViewersData.length > 1) {
				muiAlert=Alert.show("By turning off this option all selected viewers except the first selected" + " user ,will be removed from interaction.Do you want to continue?", "WARNING", Alert.YES | Alert.NO, this, checkMUIAlert);
			} else {
				muiSOValueSet("false");
			}
		}
	}
	/*if(selectedViewersData.length > 1 && chkBoxMultiUserInteraction.selected)
	{
	ClassroomContext.aviewClass.maxViewerInteraction
	Alert.show("");
	}*/
	applicationType::DesktopWeb{
		changePrefMultiUserInterationEventLog(chkBoxMultiUserInteraction.selected ? "On" : "Off");
	}
}
	/**
	 *
	 * @private
	 * Audits the "PrefMultiUserInteration" action, when the presenter/moderator changes the Multi User Interation preference.
	 *
	 * @param status - MultiUserInteration Off/On
	 * @return void
	 *
	 */
applicationType::DesktopWeb{
	private function changePrefMultiUserInterationEventLog(status:String):void
	{
		AuditContext.userAction.createAction(AuditConstants.prefMultiUserInteration, status, null, null);
	}
	
	private function checkMUIAlert(event:CloseEvent):void {
		if (!usersConnection.netConnection.connected)
			return;
		if (event.detail == Alert.YES) {
			closeInteractedUsers();
			muiSOValueSet("false");
		} else {
			isMUISelected=true;
			muiSOValueSet("true");
			actionButtons.isMUISelected = true;
		}
		muiAlert=null;
	}
}
applicationType::mobile{
	private function checkMUIAlert(event:MessageBoxEvent):void{
		if(event.type == "messageBoxYES"){
			closeInteractedUsers();
			muiSOValueSet("false");
		}else{
			isMUISelected = true;
			muiSOValueSet("true");
		}
	}
}
/**
 * When the new user sync event comes in, this function is called to
 * build the latest users list along with all their current states and
 * reflect in the user list
 */
private function updateUserList():void {
	//Issue #76
	//check whether 'push to talk' mode is enabled
	if (getAudioMuteSOValue() != Constants.FREETALK) {
		//set the 'unmute' icon for the talking user
		setMuteSortedArray();
	}
	lstUsers.setUserListDataProvider();
	
	lstUsers.setUserListSelection();
}

public function getUserSO(userName:String):Object {
	if (usersCollaborationObject) {
		return usersCollaborationObject.getData()[userName];
	}
	return null;
}

public function getAudioMuteSOValue():String {
	return audioMuteColloaborationObject.getData()[Constants.PRESENTER_ROLE];
}

public function setUserSOStatus(userName:String, userStatus:String, controlStatus:String, userType:String, isModerator:Boolean, isAudioOnlyMode:Boolean, displayName:String, isVideoPublishing:Boolean, isHide:Boolean, isMute:Boolean, userRole:String, streamDataObjects:Object, iCount:int, instituteName:String, avcRuntime:String, avcDeviceType:String, videoCaptureHeight:int, videoCaptureWidth:int, viewVideoCount:int):void {
	if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE) {
		usersConnection.netConnection.call("setUsersSharedObject", null, userName, userStatus, controlStatus, userType, isModerator, isAudioOnlyMode, displayName, isVideoPublishing, isHide, isMute, classroomContextObj.userRole, streamDataObjects, iCount, ClassroomContext.userInstituteVO.instituteName, avcRuntime, avcDeviceType,videoCaptureHeight, videoCaptureWidth, viewVideoCount);
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Called setUsersSharedObject::" + userName + ":" + userStatus + ":" + controlStatus + ":" + userType + ":" + isModerator + ":" + displayName + ":" + isVideoPublishing + ":" + classroomContextObj.userRole + ":");
	}
}

public function setUserStatus(userName:String, currentStatus:String):void {
	usersConnection.netConnection.call("setUserStatus", null, userName, currentStatus);
}

public function setUserRole(userName:String, currentRole:String):void {
	usersConnection.netConnection.call("setUserRole", null, userName, currentRole);
}

public function setControlStatus(userName:String, currentStatus:String):void {
	presenterRequestEventLog((currentStatus == null) ? Constants.PRSNTR_RELEASE : currentStatus);
	usersConnection.netConnection.call("setControlStatus", null, userName, currentStatus);
}

/**
 *
 * @private
 * Audits the "PresenterRequest" action, when the user clicks on the 'Request/Release for Presenter' button
 *
 * @param currentStatus indicates if the current user is requesting presenter or releaseing the request
 * @return void
 *
 */
private function presenterRequestEventLog(currentStatus:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.presenterRequest, currentStatus, null, null);
	}
}

public function setVideoPublishStatus(userName:String, isVideoPublishing:Boolean, streamPublishingData:Object, videoHeight:int, videoWidth:int):void {
	//PNCR: BugFix: #14556. Added extra null check condition.
	if (usersConnection && usersConnection.netConnection!=null)
		usersConnection.netConnection.call("setVideoPublishStatus", null, userName, isVideoPublishing, streamPublishingData, videoHeight, videoWidth);
}

public function setAudioMuteSOValue(value:String):void {
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Setting the push to talk status:" + value);
	if(audioMuteColloaborationObject)
	{
		audioMuteColloaborationObject.setValue(Constants.PRESENTER_ROLE,value);
	}
}

public function setLocalVideoStatus(userName:String, isHide:Boolean):void{
	if (usersConnection && usersConnection.netConnection!=null)
	{
		usersConnection.netConnection.call("setLocalVideoStatus", null, userName, isHide);
	}
}

public function setLocalAudioStatus(userName:String, isMute:Boolean):void{
	if(usersConnection && usersConnection.netConnection!=null){
		usersConnection.netConnection.call("setLocalAudioStatus", null, userName, isMute);
		
	}
}

public function getStreamTime(userName:String):void{
	if(usersConnection && usersConnection.netConnection!=null){
		usersConnection.netConnection.call("getStreamTime", myResponder, userName);
	}
	
}

public function onReply(T_SYS_TIME:Object):void{
	var resultInfo:Object =  new Object;
	var timeInfo:Array = T_SYS_TIME.split("_");
	resultInfo.time = timeInfo[0];
	resultInfo.userName = timeInfo[1];
	for (var i:int=0; i < totalLogInActivity.length; i++)	
	{
		var temp:Object = totalLogInActivity[i];
		if(temp.userName == resultInfo.userName)
		{
			temp.startTime = resultInfo.time;
		}
	}
}

//Issue #30 & #178
/**
 * This function looks at the previous state of the user list and returns
 * the perticular user's pervious state. This is an utility function
 *
 * @param uName of type String: User Name as seen in the user list.
 * @return String, the previous state. If there is no previous state, then
 * returning empty string
 */
public function getPreviousState(uName:String):Object {
	var previousState:Object;
	for (var i:int=0; i < previousUsers_SO.length; i++) {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("getPreviousState - uName: " + uName + " previousUsers_SO[i].id " + previousUsers_SO[i].id + " previousUsers_SO[i].data.role " + previousUsers_SO[i].data.userRole);
		if (uName == previousUsers_SO[i].id) {
			previousState=previousUsers_SO[i].data;
			break;
		}
	}
	return previousState;
}

//Issue #281--Start
/**
 * This function looks at the previous state of the user list and returns
 * the perticular user's pervious state. This is an utility function
 *
 * @param uName of type String: User Name as seen in the user list.
 * @return String, the previous state. If there is no previous state, then
 * returning empty string
 */
public function getFirstAcceptedStudent():String {
	var firstAcceptedStudent:String="";
	if (selectedViewersData.length > 0) {
		firstAcceptedStudent=selectedViewersData[0].userName;
	}
	
	return firstAcceptedStudent;
}

public function getFirstAcceptedStudentStreamName():String {
	var firstAcceptedStudentStream:String="";
	if (selectedViewersData.length > 0) {
		firstAcceptedStudentStream=selectedViewersData[0].streamName;
	}
	
	return firstAcceptedStudentStream;
}

public function isAcceptedStudent(userName:String):Boolean {
	var isAccepted:Boolean=false;
	
	/*for (var i:int=0; i < selectedViewersData.length; i++)
	{
	if(userName==selectedViewersData[i].userName)
	{
	isAccepted=true;
	break;
	}
	}*/
	if (getUserSO(userName) && getUserSO(userName).userStatus == Constants.ACCEPT) {
		isAccepted=true;
	}
	
	return isAccepted;
}

//Issue #281--End

private function canSelectUserForInteraction(selectedUserName:String):Boolean {
	var userTime:UserTime=getUserTime(selectedUserName);
	if (userTime != null) {
		return userTime.canSelectForInteraction((ClassroomContext.aviewClass.videoCodec == "VP6"));
	}
	return false;
}

/**
 *  Function for handling the timer event of acceptTimer and removes the event listner.
 *
 *  @param event of type TimerEvent
 *  @return void
 *
 */
public function acceptTimerHandler(event:TimerEvent):void {
	// Change the selected user's status to 'accept'
	setAccept(tempSelectedUser);
	acceptTimer.stop();
	acceptTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, acceptTimerHandler);
}

/**
 * This function is for changing the status of a VIEWER to 'accept'(if the user is selected)
 * <br>This option is available only for PRESENTER</br>
 *
 * @param selectedUser of type String
 * @return void
 */
public function setAccept(selectedUser:String):void {
	// Change the user's status to 'accept'
	setUserStatus(selectedUser, Constants.ACCEPT);
	//setUserSOStatus(selectedUser,Constants.ACCEPT,getUserSOStatus(selectedUser).controlStatus,getUserSOStatus(selectedUser).userRole,getUserSOStatus(selectedUser).userType,getUserSOStatus(selectedUser).userDisplayName);
	//	Interaction_StatusIcon=ReleaseIcon;
	userInteractingEventLog(selectedUser, getUserSO(selectedUser).userInteractedCount);
}
/**
 *
 * @private
 * Audits the "Handraised" action, when the user is selected for interaction
 *
 * @param userName of the interacting viewer
 * @param interactionCount - Total number of interactions including the current one
 * @return void
 *
 */
private function userInteractingEventLog(userName:String, interactionCount:int):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.interacting, userName, interactionCount + "", null);
	}
}

public function acceptViewer():Boolean {
	applicationType::DesktopWeb{
		if (!(interactionMUICount > selectedViewersData.length) && chkBoxMultiUserInteraction.selected) {
			MessageBox.show("Reached Maximum number of selected viewers", "INFO", MessageBox.MB_OK);
			return false;
		}
		if (lstUsers.userGrid.selectedItem != null && getUserSO(lstUsers.userGrid.selectedItem.id).userRole == Constants.VIEWER_ROLE) {
			var set_hold_flag:Boolean=false;
			tempSelectedUser=lstUsers.userGrid.selectedItem.id;
			
			if (!(getUserSO(lstUsers.userGrid.selectedItem.id).isVideoPublishing)) {
				Alert.show("The selected user is not publishing video. Please select another user.", "INFO");
				return false;
			}
			if (ClassroomContext.aviewClass.videoCodec == "VP6" && !canSelectUserForInteraction(lstUsers.userGrid.selectedItem.id)) {
				Alert.show("Please select this user after few seconds", "INFO");
				return false;
			}
			
			if (viewVideoStatus(lstUsers.userGrid.selectedItem.id)) {
				removeViewerFromViewPanel(lstUsers.userGrid.selectedItem.id);
			}
			
			if (!isMUISelected) {
				// Find previously selected student and change his state to 'hold' and set the user to 'accept' after 100 milliseconds
				for (var uName:String in usersCollaborationObject.getData()) {
					if (getUserSO(uName).userStatus == Constants.ACCEPT && getUserSO(uName).userRole == Constants.VIEWER_ROLE) {
						setUserStatus(uName, Constants.HOLD);
						AuditContext.userAction.userInteractionEndedEventLog(uName, getUserSO(uName).userInteractedCount);
						//setUserSOStatus(uName,Constants.HOLD,getUserSOStatus(uName).controlStatus,getUserSOStatus(uName).userRole,getUserSOStatus(uName).userType,getUserSOStatus(uName).userDisplayName);
						set_hold_flag=true;
						//CRJH: Timer can be replaced with setTimeOut
						acceptTimer=new Timer(100, 1);
						acceptTimer.addEventListener("timer", acceptTimerHandler);
						acceptTimer.start();
					}
				}
			}
			//If no student is in 'accept' mode before, then change the selected user's status to 'accept'
			if (!set_hold_flag) {
				// Change the selected user's status to 'accept'
				setAccept(tempSelectedUser);
			}
		} else {
			Alert.show("Please select a viewer from the user list", "INFO");
			return false;
		}
	}
	applicationType::mobile{
		//For AVCM: Check whether MUI feature is in ON state and interactioncount is more than 1.
		if(!(interactionMUICount > selectedViewersData.length)&& isMUISelected)
		{
			MessageBox.show("Reached Maximum number of selected viewers","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			return false;
		}
		if (lstUsers.selectedItem != null && getUserSO(lstUsers.selectedItem.id).userRole == Constants.VIEWER_ROLE)
		{
			var set_hold_flag:Boolean=false;
			tempSelectedUser=lstUsers.selectedItem.id;
			
			if(!(getUserSO(lstUsers.selectedItem.id).isVideoPublishing))
			{
				MessageBox.show("The selected user is not publishing video. Please select another user.", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false;
			}
			if(ClassroomContext.aviewClass.videoCodec=="VP6" && !canSelectUserForInteraction(lstUsers.selectedItem.id))
			{
				MessageBox.show("Please select this user after few seconds", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false;
			}
			//For AVCM: Check whether MUI feature is ON/OFF.If it is in off state, Remove previous selected viewer and add new selected viewer.
			if(!isMUISelected)
			{
				// Find previously selected student and change his state to 'hold' and set the user to 'accept' after 100 milliseconds
				for (var uName:String in usersCollaborationObject.getData())
				{
					if (getUserSO(uName).userStatus == Constants.ACCEPT && getUserSO(uName).userRole == Constants.VIEWER_ROLE)
					{
						setUserStatus(uName,Constants.HOLD);
						//setUserSOStatus(uName,Constants.HOLD,getUserSOStatus(uName).controlStatus,getUserSOStatus(uName).userRole,getUserSOStatus(uName).userType,getUserSOStatus(uName).userDisplayName);
						set_hold_flag=true;
						acceptTimer=new Timer(100, 1);
						acceptTimer.addEventListener("timer", acceptTimerHandler);
						acceptTimer.start();
					}
				}
			}
			//If no student is in 'accept' mode before, then change the selected user's status to 'accept'
			if (!set_hold_flag)
			{
				// Change the selected user's status to 'accept'
				setAccept(tempSelectedUser);
			}
		}
		else
		{
			MessageBox.show("Please select one student from the user list", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			return false;
		}
	}
	return true;
}

/**
 * This function is for changing the status of a VIEWER from accept/view to release (reject state)
 * <br>This option is available only for PRESENTER</br>
 *
 *
 * @return void
 */
public function rejectViewer():Boolean {
	var rejectedUserName:String=null;
	applicationType::DesktopWeb{
		if (lstUsers.userGrid.selectedItem != null) {
			if (isAcceptedStudent(lstUsers.userGrid.selectedItem.id)) {
				rejectedUserName=lstUsers.userGrid.selectedItem.id;
				// Change the user's status to 'hold'
				setUserStatus(rejectedUserName, Constants.HOLD);
				AuditContext.userAction.userInteractionEndedEventLog(rejectedUserName, getUserSO(rejectedUserName).userInteractedCount);
				
				//If the rejectedUser is in talk mode,then set currentPresenter to talk.
				if (rejectedUserName == getAudioMuteSOValue()) {
					actionButtons.talkMute(ClassroomContext.currentPresenterName);
				}
			} else {
				//Merged rev 6738-RG
				//			Alert.show("Invalid selection of a non-interactive user", "ERROR") ;
				return false;
			}
		} else {
			Alert.show("Select an interactive user from the Userlist", "INFO");
			return false;
		}
	}
	applicationType::mobile{
		if(lstUsers.selectedItem != null)
		{
			if (isAcceptedStudent(lstUsers.selectedItem.id))
			{
				rejectedUserName = lstUsers.selectedItem.id ;
				// Change the user's status to 'hold'
				setUserStatus(rejectedUserName,Constants.HOLD) ;
				//For AVCM:AuditContext.userAction.userInteractionEndedEventLog(rejectedUserName,getUserSOStatus(rejectedUserName).userInteractedCount);
				
				//If the rejectedUser is in talk mode,then set currentPresenter to talk.
				if(rejectedUserName==getAudioMuteSOValue())
				{
					actionButtons.talkMute(ClassroomContext.currentPresenterName);
				}
			}
			else
			{
				MessageBox.show("Invalid selection of a non-interactive user", "ERROR",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false ;
			}
		}
		else
		{
			MessageBox.show("Select an interactive user from the Userlist", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO) ;
			return false ;
		}
	}
	return true;
}


public function callViewStudent():Boolean {
	applicationType::DesktopWeb{
		if (!ClassroomContext.IS_AUDIO_VIDEO_ENABLED) {
			Alert.show("Your Audio-Video is disabled. You can't select a user for 'view video'.");
			return false;
		}
		if (lstUsers.userGrid.selectedItem != null && getUserSO(lstUsers.userGrid.selectedItem.id).userRole == Constants.VIEWER_ROLE && !getUserSO(lstUsers.userGrid.selectedItem.id).isModerator) {
			
			if (!(getUserSO(lstUsers.userGrid.selectedItem.id).isVideoPublishing)) {
				Alert.show("The selected user is not publishing video. Please select another user.", "INFO");
				return false;
			}
			if (ClassroomContext.aviewClass.videoCodec == "VP6" && !canSelectUserForInteraction(lstUsers.userGrid.selectedItem.id)) {
				Alert.show("Please select this user after few seconds", "INFO");
				return false;
			}
			if (getUserSO(lstUsers.userGrid.selectedItem.id).isAudioOnlyMode) {
				Alert.show("The selected user in Audio only mode.", "INFO");
				return false;
			}
			if (viewVideoStatus(lstUsers.userGrid.selectedItem.id) == false && getUserSO(lstUsers.userGrid.selectedItem.id).userStatus != Constants.ACCEPT) {
				sendViewVideoStatus("start", lstUsers.userGrid.selectedItem.id);
				userViewedEventLog(lstUsers.userGrid.selectedItem.id, getUserSO(lstUsers.userGrid.selectedItem.id).userInteractedCount);
				actionButtons.setupUserActionButtonsOnSelection();
				if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
				{
					usersConnection.netConnection.call("setViewVideoCount",null,lstUsers.userGrid.selectedItem.id);
					//if (lstUsers) lstUsers.sortUserList();
				}
			} else {
				Alert.show("This student is already selected!!!", "Invalid Selection");
				return false;
			}
		} else {
			Alert.show("Please select a student from the user list", "INFO");
			return false;
		}
	}
	applicationType::mobile{
		if (lstUsers.selectedItem != null && getUserSO(lstUsers.selectedItem.id).userRole == Constants.VIEWER_ROLE)
		{
			
			if(!(getUserSO(lstUsers.selectedItem.id).isVideoPublishing))
			{
				MessageBox.show("The selected user is not publishing video. Please select another user.", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false;
			}
			if(ClassroomContext.aviewClass.videoCodec=="VP6" && !canSelectUserForInteraction(lstUsers.selectedItem.id))
			{
				MessageBox.show("Please select this user after few seconds", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false;
			}
			if(getUserSO(lstUsers.selectedItem.id).isAudioOnlyMode)
			{
				MessageBox.show("The selected user in Audio only mode.", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false;
			}
			if (viewVideoStatus(lstUsers.selectedItem.id) == false && getUserSO(lstUsers.selectedItem.id).userStatus != Constants.ACCEPT)
			{
				sendViewVideoStatus("start",lstUsers.selectedItem.id);
				actionButtons.setupUserActionButtonsOnSelection();
			}
			else
			{
				MessageBox.show("This student is already selected!!!","Invalid Selection",MessageBox.MB_OK,null,null,null,MessageBox.IC_ALERT);
				return false;
			}
		}
		else
		{
			MessageBox.show("Please select one student from the user list", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			return false;
		}
	}
	return true;
}

/**
 *
 * @private
 * Audits the "Viewed" action, when the user is viewed by the presenter
 *
 * @param userName of the viewer who is currently being viewed by presenter/moderator
 * @param interactionCount - Total number of interactions so far
 * @return void
 *
 */
private function userViewedEventLog(userName:String, interactionCount:int):void
{
	AuditContext.userAction.createAction(AuditConstants.viewed, userName, interactionCount + "", null);
}

/**
 * This function is for changing the status of a VIEWER from view to hold.
 * <br>This option is available only for PRESENTER</br>
 *
 *
 * @return void
 */
public function closeViewStudent():Boolean {
	applicationType::DesktopWeb{
		if (lstUsers.userGrid.selectedItem != null && getUserSO(lstUsers.userGrid.selectedItem.id).userRole == Constants.VIEWER_ROLE) {
			//Issue #40
			//Changing student's state to 'hold' from 'view'
			if (viewVideoStatus(lstUsers.userGrid.selectedItem.id) == true) {
				sendViewVideoStatus("stop", lstUsers.userGrid.selectedItem.id);
				userCloseViewedEventLog(lstUsers.userGrid.selectedItem.id, getUserSO(lstUsers.userGrid.selectedItem.id).userInteractedCount);
				actionButtons.setupUserActionButtonsOnSelection();
			} else if (getUserSO(lstUsers.userGrid.selectedItem.id).userStatus == Constants.WAITING) {
				remove_viewVideo(lstUsers.userGrid.selectedItem.id);
			} else {
				Alert.show("Please select a student from 'View Video' list.", "INFO");
				return false;
			}
			if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
			{
				if (lstUsers) lstUsers.sortUserList();
			}
		} else {
			Alert.show("Please select a student from the user list", "INFO");
			return false;
		}
	}
	applicationType::mobile{
		if (lstUsers.selectedItem != null && getUserSO(lstUsers.selectedItem.id).userRole == Constants.VIEWER_ROLE)
		{
			//Issue #40
			//Changing student's state to 'hold' from 'view'
			if (viewVideoStatus(lstUsers.selectedItem.id) == true)
			{
				sendViewVideoStatus("stop",lstUsers.selectedItem.id);
				actionButtons.setupUserActionButtonsOnSelection();
			}
			else if (getUserSO(lstUsers.selectedItem.id).userStatus == Constants.WAITING)
			{	//AVCM
				//remove_viewVideo(lstUsers.selectedItem.id);
			}
			else
			{
				MessageBox.show("Please select a student from 'View Video' list.","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
				return false;
			}
		}
		else
		{
			MessageBox.show("Please select one student from the user list", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			return false;
		}
	}
	return true;
}

/**
 *
 * @private
 * Audits the "CloseViewed" action, when the viewing is ended by presenter/moderator
 *
 * @param userName of the viewer who is just been viewed by presenter/moderator
 * @param interactionCount - Total number of interactions so far
 * @return void
 *
 */
private function userCloseViewedEventLog(userName:String, interactionCount:int):void
{
	AuditContext.userAction.createAction(AuditConstants.closeViewed, userName, interactionCount + "", null);
}

///**
// * This function is for changing the status of a student to handraise.
// * <br>This option is available only for students.</br>
// *
// *
// * @return void
// */
public function handRaise():Boolean {
	if (!(getUserSO(ClassroomContext.userVO.userName).isVideoPublishing)) {
		applicationType::DesktopWeb{
			Alert.show("Please start your video before clicking the Handraise button", "INFO");
		}
		applicationType::mobile{
			MessageBox.show("Please start your video before clicking the Handraise button","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
		}
		return false;
	}
	
	if (getUserSO(ClassroomContext.userVO.userName).controlStatus != Constants.PRSNTR_REQUEST) {
		if (getUserSO(ClassroomContext.userVO.userName).userStatus != Constants.ACCEPT) {
			// Change the student's status to 'waiting'
			setUserStatus(ClassroomContext.userVO.userName, Constants.WAITING);
			userHandraisedEventLog(ClassroomContext.userVO.userName, getUserSO(ClassroomContext.userVO.userName).userInteractedCount);
		} else {
			applicationType::DesktopWeb{
				Alert.show("You are already selected!!!", "INFO");
			}
			applicationType::mobile{
				MessageBox.show("You are already selected!!!","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			}
		}
	} else {
		applicationType::DesktopWeb{
			Alert.show("You can't Handraise while you are in 'Requesting Presenter' state. Please press the 'Release' button first.", "INFO");
		}
		applicationType::mobile{
			MessageBox.show("You can't Handraise while you are in 'Requesting Presenter' state. Please press the 'Release' button first.","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
		}
		return false;
	}
	return true;
}

/**
 *
 * @private
 * Audits the "Handraised" action, when the user clicks the handraise buttong
 *
 * @param userName of the Handraised viewer
 * @param interactionCount - Total number of interactions so far
 * @return void
 *
 */
private function userHandraisedEventLog(userName:String, interactionCount:int):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.handraised, userName, interactionCount + "", null);
	}
}

///**
// * This function is for changing the status of a student to hold.
// * <br>This option is available only for students.</br>
// *
// *
// * @return void
// */
public function releaseHandRaise():Boolean {
	if (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT || getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.WAITING) {
		if (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT) {
			applicationType::DesktopWeb{
				AuditContext.userAction.userInteractionEndedEventLog(ClassroomContext.userVO.userName, getUserSO(ClassroomContext.userVO.userName).userInteractedCount);
			}
		} else {
			applicationType::DesktopWeb{
				userHandraiseReleasedEventLog(ClassroomContext.userVO.userName, getUserSO(ClassroomContext.userVO.userName).userInteractedCount);
			}
		}
		setUserStatus(ClassroomContext.userVO.userName, Constants.HOLD);
	} else {
		applicationType::DesktopWeb{
			Alert.show("Sorry, You are not selected", "INFO");
		}
		applicationType::mobile{
			MessageBox.show("Sorry, You are not selected","INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
		}
	}
	return true;
}

/**
 *
 * @private
 * Audits the "HandraiseReleased" action, when the user clicks on the release handraise button
 *
 * @param userName of the viewer who released his handraise
 * @param interactionCount - Total number of interactions so far
 * @return void
 *
 */
private function userHandraiseReleasedEventLog(userName:String, interactionCount:int):void
{
	AuditContext.userAction.createAction(AuditConstants.handraiseReleased, userName, interactionCount + "", null);
}

private var isNewPresenter:Boolean=false;

private function informPresenter(newPresenter:String):void {
	if (ClassroomContext.userVO.userName == newPresenter) {
		MessageBox.show("You have the presenter control now!!! Click OK to continue", null, "NOTIF", null, null, null, null);
	}
}

/**
 * This funtion is only available for MODERATOR user and is used for assiging roles to users.
 * MODERATOR can select a user from the user list and can give him PRESENTER role. This will
 * give the selected user PRESENTER privilages. At the same time this button will change into
 * Take Control mode which means pressing this will get back the PRESENTER role to MODERATOR
 *
 * @param
 * @return void
 *
 */

public function makePresenter():Boolean {
	//Some times after selecting a viewer and before making him presenter
	//the FMS can go down and the users list may be empty
	applicationType::DesktopWeb{
		if (!lstUsers.userGrid.selectedItem) {
			Alert.show("Please select a viewer from the user list", "INFO");
			return false;
		}
		var selectedUserName:String=lstUsers.userGrid.selectedItem.id;
		
		if (viewVideoStatus(selectedUserName)) {
			sendViewVideoStatus("stop", lstUsers.userGrid.selectedItem.id);
			removeViewerFromViewPanel(selectedUserName);
		}
		if (!(getUserSO(lstUsers.userGrid.selectedItem.id).isVideoPublishing)) {
			Alert.show("The selected user is not publishing video. Please select another user.", "INFO");
			return false;
		}
		
		if (!canSelectUserForInteraction(selectedUserName)) {
			Alert.show("Please select this user after few seconds", "INFO");
			return false;
		} else if (lstUsers.userGrid.selectedIndex > 0 && ClassroomContext.currentPresenterName != selectedUserName) {
			isNewPresenter=true;
			nowPresenter=selectedUserName;
			informPresenter(selectedUserName);
			usersConnection.netConnection.call("giveControl", null, lstUsers.userGrid.selectedItem.id, ClassroomContext.moderatorName);
			actionButtons.setupUserActionButtonsOnSelection();
			actionButtons.talkMute(selectedUserName);
			isNewPresenter=false;
		} else {
			Alert.show("Please select a User who is not currently the Presenter", "Selection");
			return false;
		}
		
		if (!recordButtonBlinkedOnce && recordIcon == startRecordIcon) {
			recordButtonBlinkedOnce=true;
			blinkTimerIntervalForRecordBtn=startBlink(classroomComponentSgl.btnRecord, 200, 0);
		}
	}
	applicationType::mobile{
		var selectedUserName:String = lstUsers.selectedItem.id;
		//Some times after selecting a viewer and before making him presenter
		//the FMS can go down and the users list may be empty
		if(!lstUsers.selectedItem)
		{
			return false;
		}
		
		if(!(getUserSO(lstUsers.selectedItem.id).isVideoPublishing))
		{
			MessageBox.show("The selected user is not publishing video. Please select another user.", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			return false;
		}
		
		if(!canSelectUserForInteraction(selectedUserName))
		{
			MessageBox.show("Please select this user after few seconds", "INFO",MessageBox.MB_OK,null,null,null,MessageBox.IC_INFO);
			return false;
		}
		else if(lstUsers.selectedIndex > 0 && ClassroomContext.currentPresenterName != selectedUserName) 
		{   
			nowPresenter = selectedUserName;
			usersConnection.netConnection.call("giveControl",null, lstUsers.selectedItem.id,ClassroomContext.moderatorName);
			actionButtons.setupUserActionButtonsOnSelection();
			actionButtons.talkMute(selectedUserName);
		}
		else
		{
			MessageBox.show("Please select a User who is not currently the Presenter","Selection",MessageBox.MB_OK,null,null,null,MessageBox.IC_ADD);
			return false;
		}
	}
	return true;
}

public function takeControl():Boolean {
	//Some times after selecting a viewer and before making him presenter
	//the FMS can go down and the users list may be empty
	//newPresenter is null if the Moderator is logged out after making some one else presenter and logged in.
	if (nowPresenter != null && nowPresenter != ClassroomContext.currentPresenterName) {
		return false;
	}
	
	//Take Control is pressed
	if (!canSelectUserForInteraction(ClassroomContext.currentPresenterName)) {
		Alert.show("Please take control after few seconds", "INFO");
		return false;
	}
	if (viewVideoStatus(ClassroomContext.currentPresenterName)) {
		sendViewVideoStatus("stop", ClassroomContext.currentPresenterName);
		removeViewerFromViewPanel(ClassroomContext.currentPresenterName);
	}
	if (viewVideoStatus(ClassroomContext.moderatorName)) {
		sendViewVideoStatus("stop", ClassroomContext.moderatorName);
		removeViewerFromViewPanel(ClassroomContext.moderatorName);
	}
	if (viewVideoStatus(ClassroomContext.userVO.userName)) {
		sendViewVideoStatus("stop", ClassroomContext.userVO.userName);
		removeViewerFromViewPanel(ClassroomContext.userVO.userName);
	}
	usersConnection.netConnection.call("takeControl", null, ClassroomContext.moderatorName);
	applicationType::DesktopWeb{
		actionButtons.talkMute(ClassroomContext.moderatorName);
		if (ClassroomContext.isModerator && classroomComponentSgl.pnlTeacher.isFullScreenPresent && videoWallCollaborationObject && videoWallCollaborationObject.getData()["isSelected"] == "false") {
			classroomComponentSgl.pnlTeacher.isVideoReset=false;
			classroomComponentSgl.pnlTeacher.closeFullScreen();
			classroomComponentSgl.pnlTeacher.isFullScreenPresent=false;
		}
	}
	return true;
}


public function presenterRequest():Boolean {
	if (!(getUserSO(ClassroomContext.userVO.userName).isVideoPublishing)) {
		Alert.show("Please start your video before requesting for Presenter Role", "INFO");
		return false;
	} else if (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.WAITING) {
		Alert.show("You can't request for Presenter role while you are in Handraise status. Please press 'Stop interaction with the Presenter' button first.", "Alert");
		return false;
	} else if (getUserSO(ClassroomContext.userVO.userName).userStatus == Constants.ACCEPT) {
		Alert.show("You can't request for Presenter role while you are the selected viewer. Please press 'Stop interaction with the Presenter' button first.", "Alert");
		return false;
	} else {
		setControlStatus(ClassroomContext.userVO.userName, Constants.PRSNTR_REQUEST);
	}
	return true;
}



public function presenterRelease():Boolean {
	
	if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
		if (getUserSO(ClassroomContext.moderatorName) != null) {
			usersConnection.netConnection.call("takeControl", null, ClassroomContext.moderatorName);
			actionButtons.talkMute(ClassroomContext.moderatorName);
		} else {
			applicationType::DesktopWeb{
				Alert.show("The Moderator is not currently logged in. Hence you can't give back Presenter control. Please try after Moderator logs in.", "Alert");
			}
			applicationType::mobile{
				MessageBox.show("The Moderator is not currently logged in. Hence you can't give back Presenter control. Please try after Moderator logs in.","Alert",MessageBox.MB_OK,null,null,null,MessageBox.IC_ALERT);	
			}
			return false;
		}
	} else {
		setControlStatus(ClassroomContext.userVO.userName, null);
	}
	
	return true;
}



/**
 * The function is used to set the button icons and visibility
 * based on whether the user is PRESENTER or VIEWER.
 *
 *
 * @return void
 */
// If the user is 'PRESENTER' 
// btnRecord is set to true and the corresponding 
// icons are set.
// Similarly if the user is 'VIEWER' corresponding
// buttons and icons are set.
// This is based on the functionality that a PRESENTER
// and VIEWER has.
public function setupVideoButtons():void {
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator == true) {
			classroomComponentSgl.videooptions.addChild(classroomComponentSgl.btnRecord);
			//Since there is no record feature for web, we don't make the Record button visible
			// Enabling the Record button visible for presenter
			applicationType::web {
				classroomComponentSgl.btnRecord.enabled=false;
				classroomComponentSgl.btnRecord.includeInLayout=false;
				classroomComponentSgl.btnRecord.visible=false;
			}
			applicationType::desktop {
				classroomComponentSgl.btnRecord.enabled=true;
				classroomComponentSgl.btnRecord.includeInLayout=true;
				classroomComponentSgl.btnRecord.visible=true;
			}
			if (!recorder.isRecording) {
				classroomComponentSgl.btnRecord.toolTip="Start Recording";
				recordIcon=startRecordIcon;
			} else {
				classroomComponentSgl.btnRecord.toolTip="Stop Recording";
				recordIcon=stopRecordIcon;
			}
		}
	}
}

private function setSpaceForViewVideo():void
{
	if (viewedViewerDisplays.length == 1)
	{
		applicationType::DesktopWeb{
			classroomComponentSgl.viewersTile.percentHeight=60;
		}
		setVisiblityViewVideoTile(true);
	}
}

private function setVisiblityViewVideoTile(value:Boolean):void
{
	applicationType::DesktopWeb{
		classroomComponentSgl.hruleViewVideo.visible=value;
		classroomComponentSgl.hruleViewVideo.includeInLayout=value;
		classroomComponentSgl.viewVideoTile.visible=value;
		classroomComponentSgl.viewVideoTile.includeInLayout=value;
	}
		
}


applicationType::DesktopWeb{
	private function setupMUIPTT(selectedViewerName:String=null):void {
		if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE) {
			var videoStreamDisplay:VideoStreamDisplay;
			var selectedViewerFromArray:String;
			if (selectedViewerDisplays.length > 0) {
				for (var i:int=0; i < selectedViewerDisplays.length; i++) {
					var displayName:String;
						var videoDisplay:VideoStreamDisplay=iVideoWallLayout.getMainDisplay();
						if(videoDisplay!=null)
							displayName=videoDisplay.userName;
					videoStreamDisplay=selectedViewerDisplays[i] as VideoStreamDisplay;
					selectedViewerFromArray=videoStreamDisplay.userName;
					if (selectedViewerFromArray == displayName)
						videoStreamDisplay=videoDisplay;
					if (selectedViewerName != null && selectedViewerName != selectedViewerFromArray) {
						continue;
					}
					
					changePTTButtonStatus(videoStreamDisplay, selectedViewerFromArray);
				}
			}
			videoStreamDisplay=iVideoWallLayout.getPresenterVideoStreamDisplay();
			selectedViewerFromArray=videoStreamDisplay.userName;
			if (selectedViewerName != null && selectedViewerName != selectedViewerFromArray) {
				
			} else {
				changePTTButtonStatus(videoStreamDisplay, selectedViewerFromArray);
			}
		}
	}
	public function changePTTButtonStatus(videoStreamDisplay:VideoStreamDisplay, userName:String):void {
		try {
			if (getAudioMuteSOValue() == Constants.FREETALK) {
				actionButtons.setupFreeTalk(videoStreamDisplay.btnFreeTalk, videoStreamDisplay.btnMute, videoStreamDisplay.btnTalk);
				applicationType::desktop {
					if (videoStreamDisplay.isFullScreenPresent && videoStreamDisplay.videoFullScreenComp) {
							actionButtons.setupFreeTalk(videoStreamDisplay.videoFullScreenComp.btnFreeTalk, videoStreamDisplay.videoFullScreenComp.btnMute, videoStreamDisplay.videoFullScreenComp.btnTalk);
						}
				}
			} else {
				videoStreamDisplay.isPTTSet=true;
				if (getAudioMuteSOValue() == userName) {
					actionButtons.setupTalkMute(false, videoStreamDisplay.btnFreeTalk, videoStreamDisplay.btnMute, videoStreamDisplay.btnTalk);
					applicationType::desktop {
						if (videoStreamDisplay.isFullScreenPresent && videoStreamDisplay.videoFullScreenComp) {
								actionButtons.setupTalkMute(false, videoStreamDisplay.videoFullScreenComp.btnFreeTalk, videoStreamDisplay.videoFullScreenComp.btnMute, videoStreamDisplay.videoFullScreenComp.btnTalk);
							}
					}
				} else {
					actionButtons.setupTalkMute(true, videoStreamDisplay.btnFreeTalk, videoStreamDisplay.btnMute, videoStreamDisplay.btnTalk);
					applicationType::desktop {
						if (videoStreamDisplay.isFullScreenPresent && videoStreamDisplay.videoFullScreenComp) {
								actionButtons.setupTalkMute(true, videoStreamDisplay.videoFullScreenComp.btnFreeTalk, videoStreamDisplay.videoFullScreenComp.btnMute, videoStreamDisplay.videoFullScreenComp.btnTalk);
							}
					}
				}
			}
		} 
		catch (ex:Error) {
			if(Log.isError()) log.error("Error in changePTTButtonStatus method:"+ ex.getStackTrace());
		}
	}
}

public function setAudioMuteStatusForStreamTimerHandler():void {
	if (setAudioMuteStatusForStreamTimeoutId) {
		clearTimeout(setAudioMuteStatusForStreamTimeoutId);
	}
	setAudioMuteStatusForStream();
}

/**
 * This method sets the Presenter's auto to mute/unmute based on the Shared object status
 */
public function setAudioMuteStatusForStream():void {
	if (latestAudioMute_COData == Constants.FREETALK) {
		muteTeacherAudio(false);
		unMuteAllViewerStreams();
		applicationType::web{
			//Set PTT status as Unmute
			presenterPttStatus = Constants.UN_MUTE;
			//To send audio freetalk status to pop-out window, if Presenter video in pop-out window.
			if(isPresenterVideoInFullscreen){
				//If user views Presenter video in pop-out window at first time
				if(classroomComponentSgl.pnlTeacher.isFirstTimePresenterInFullscreen){
					setTimeOutID = setTimeout(presenterAudioStatusData,2000,Constants.FREETALK);
					classroomComponentSgl.pnlTeacher.isFirstTimePresenterInFullscreen =false;
				}
				else{
					presenterAudioStatusData(Constants.FREETALK);
				}
			}
		}
	} else if (latestAudioMute_COData == ClassroomContext.currentPresenterName) {
		muteTeacherAudio(false);
		muteAllOtherViewerStreams();
		applicationType::web{
			//Set PTT status as Unmute
			presenterPttStatus = Constants.UN_MUTE;
			//To send audio unmute status to pop-out window, if Presenter video in pop-out window.
			if(isPresenterVideoInFullscreen){
				//If user views Presenter video in pop-out window at first time
				if(classroomComponentSgl.pnlTeacher.isFirstTimePresenterInFullscreen){
					setTimeOutID = setTimeout(presenterAudioStatusData,2000,Constants.UN_MUTE);
					classroomComponentSgl.pnlTeacher.isFirstTimePresenterInFullscreen =false;
				}
				else{
					presenterAudioStatusData(Constants.UN_MUTE)
				}
			}
		}
	} else {
		muteTeacherAudio(true);
		muteAllOtherViewerStreams(latestAudioMute_COData);
		applicationType::web{
			//Set PTT status as Mute  
			presenterPttStatus = Constants.MUTE;
			//To send audio mute status to pop-out window, if Presenter video in pop-out window.
			if(isPresenterVideoInFullscreen){
				//If user views Presenter video in pop-out window at first time
				if(classroomComponentSgl.pnlTeacher.isFirstTimePresenterInFullscreen){
					setTimeOutID = setTimeout(presenterAudioStatusData,2000,Constants.MUTE);
					classroomComponentSgl.pnlTeacher.isFirstTimePresenterInFullscreen =false;
				}
				else{
					presenterAudioStatusData(Constants.MUTE)
				}
			}
		}
	}
}

private function handlePTTrecording():void {
	var latestAudioMute_SOData:String=getAudioMuteSOValue();
	applicationType::DesktopWeb{
		if (latestAudioMute_SOData == "") {
			recorder.pttRecorder.addPttState(recorder.getCentralTime(), latestAudioMute_SOData, "false");
		} else if (latestAudioMute_SOData == Constants.FREETALK) {
			recorder.pttRecorder.addPttState(recorder.getCentralTime(), latestAudioMute_SOData, "false");
		} else if (latestAudioMute_SOData == ClassroomContext.currentPresenterName) {
			recorder.pttRecorder.addPttState(recorder.getCentralTime(), latestAudioMute_SOData, "true");
		} else {
			recorder.pttRecorder.addPttState(recorder.getCentralTime(), latestAudioMute_SOData, "false");
		}
	}
}

/**
 * This function is the event listener for SyncEvent of audioMuteSharedObject shared object (for 'push to talk' feature).
 * It is used to update the status of all the nodes.
 *
 * The function is called in the following cases to update the status of all users.
 * (The status of the shared object in each case is also specified):
 * 1.When a PRESENTER logs in or deselects the 'push to talk' checkbox          (Status  - freetalk),both PRESENTER & selected VIEWER can talk.
 * 2.When a PRESENTER presses 'Talk' button or a VIEWER presses 'Mute' button  (Status  - unmute),only PRESENTER can talk.
 * 3.When a PRESENTER presses 'Mute' button or a VIEWER presses 'Talk' button    (Status  - mute),only selected VIEWER can talk.
 *
 * @param event of type SyncEvent
 * @return void
 */
public function audioMuteSyncHandler(auioMuteData:Object):void {
	//Issue #284:Start
	//Store the latest value of this shared object, so that we can use this to reset it during a reconnect
	previousAudioMute_COData=latestAudioMute_COData;
	latestAudioMute_COData=getAudioMuteSOValue();
	if(latestAudioMute_COData==null)
	{
		//Alert.show("latestAudioMute_COData:"+latestAudioMute_COData);
		setAudioMuteSOValue(Constants.FREETALK);
		return;
	}
	if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug(" presenter value " + latestAudioMute_COData);
	applicationType::DesktopWeb{
		if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
			pttBox.pttCheckBoxState=(latestAudioMute_COData != Constants.FREETALK);
			
			//Wait for the full initialization of all the buttons
			if (!pttBox.btnFreeTalk || !pttBox.btnMute || !pttBox.btnTalk) {
				setTimeout(audioMuteSyncHandler, 500, auioMuteData);
				return;
			}
		} else {
			actionButtons.pttCheckBoxState=(latestAudioMute_COData != Constants.FREETALK);
		}
	}
	//User shared object is not yet connected, so we can't process this method.
	//We should come back when the users shared object is connected.
	if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE && getUserSO(ClassroomContext.userVO.userName) == null) {
		return;
	}
	//recording
	applicationType::DesktopWeb{
		if (ClassroomContext.isModerator && recorder.isRecording) // need to add check isRecording
		{
			
			handlePTTrecording();
			//controlViewerRecording();
		}
		setAudioMuteStatusForStream();
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE || ClassroomContext.isModerator || ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
			if (getAudioMuteSOValue() == Constants.FREETALK) {
				actionButtons.callSetupFreeTalk();
			} else {
				actionButtons.callSetupTalkMute((getAudioMuteSOValue() != ClassroomContext.currentPresenterName));
			}
		}
		//PNCR: added a null check condition to avoid value assing delay. bug#: 14630
		//Fix for Bug#18497
		if (latestAudioMute_COData != null && lstUsers) 
			lstUsers.setTalkMuteStatusDisplay(latestAudioMute_COData);
		setupMUIPTT();
	}
	applicationType::mobile{
		setAudioMuteStatusForStream();
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE || ClassroomContext.isModerator || ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
			if (getAudioMuteSOValue() == Constants.FREETALK) {
				actionButtons.callSetupFreeTalk();
			} else {
				actionButtons.callSetupTalkMute((getAudioMuteSOValue() != ClassroomContext.currentPresenterName));
			}
		}
		if (latestAudioMute_COData != null && lstUsers) 
			lstUsers.setTalkMuteStatusDisplay(latestAudioMute_COData);
	}
	//issue#7531
	setAudioMuteStatusForStreamTimeoutId=setTimeout(setAudioMuteStatusForStreamTimerHandler, 2500);
	//set the 'unmute' icon for the talking user
	setMuteSortedArray();
	//Fix for Bug#18497
	if(lstUsers)
	{
		lstUsers.setUserListDataProvider();
	}
}

/**
 * Function is used for setting the 'unmute' icon for the talking user in 'push to talk' feature.
 *
 *
 * @return void
 */
public function setMuteSortedArray():void {
	if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE) {
		//loop through the sorted user array
		for (var k:int=0; k < lstUsers.sortedPushToTalkArray.length; k++) {
			//check whether the current user is PRESENTER
			if (lstUsers.sortedPushToTalkArray[k].id == ClassroomContext.currentPresenterName) {
				//check whether the PRESENTER is in freetalk mode 
				if (getAudioMuteSOValue() == Constants.FREETALK && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT) {
					lstUsers.sortedPushToTalkArray[k].data.userTalkStatus=Constants.FREETALK;
				}
					//check whether the user is in talking mode 
				else if (getAudioMuteSOValue() == ClassroomContext.currentPresenterName && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT) {
					//set talking icon
					lstUsers.sortedPushToTalkArray[k].data.userTalkStatus=getAudioMuteSOValue();
				}
					//check whether the PRESENTER is in mute mode 
				else if (getAudioMuteSOValue() != ClassroomContext.currentPresenterName && getUserSO(ClassroomContext.currentPresenterName).userStatus == Constants.ACCEPT) {
					lstUsers.sortedPushToTalkArray[k].data.userTalkStatus=getAudioMuteSOValue();
				}
			} else //check whether the current user is VIEWER
			{
				//check whether the student is in freetalk mode 
				if (getAudioMuteSOValue() == Constants.FREETALK && getUserSO(lstUsers.sortedPushToTalkArray[k].id).userStatus == Constants.ACCEPT) {
					lstUsers.sortedPushToTalkArray[k].data.userTalkStatus=Constants.FREETALK;
				}
					//check whether the student is in mute mode 
				else if (getAudioMuteSOValue() == ClassroomContext.currentPresenterName && getUserSO(lstUsers.sortedPushToTalkArray[k].id).userStatus == Constants.ACCEPT) {
					lstUsers.sortedPushToTalkArray[k].data.userTalkStatus=getAudioMuteSOValue();
				}
					//check whether the student is in talking mode 
				else if (getAudioMuteSOValue() != ClassroomContext.currentPresenterName && getUserSO(lstUsers.sortedPushToTalkArray[k].id).userStatus == Constants.ACCEPT) {
					//set talking icon
					lstUsers.sortedPushToTalkArray[k].data.userTalkStatus=getAudioMuteSOValue();
				}
			}
		}
	}
}

//Issue #76 - END



private function up2(ev:TimerEvent):void {
	applicationType::DesktopWeb{
		if (isBusyCursorRunning) {
			removeBusyCursor();
		}
	}
}

private var waitForModuleSOAndUpdateControlesTimeoutId:uint;

private function waitForModuleSOAndUpdateControles(isPresenter:Boolean):void {
	clearTimeout(waitForModuleSOAndUpdateControlesTimeoutId);
	
	if (moduleSOStatus != "Connected") {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: waitForModuleSOAndUpdateControles: Waiting..");
		waitForModuleSOAndUpdateControlesTimeoutId=setTimeout(waitForModuleSOAndUpdateControles, 100, isPresenter);
	} else {
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: waitForModuleSOAndUpdateControles: Done.");
		updateModuleControles(isPresenter);
	}
}


private function updateModuleControles(isPresenter:Boolean):void {
	if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
		return;
	if (moduleSOStatus != "Connected") {
		waitForModuleSOAndUpdateControles(isPresenter);
		return;
	}
	this.dispatchEvent(new RoleChangeEvent(RoleChangeEvent.TYPE_ROLE_CHANGE,classroomContextObj.userRole));
	applicationType::DesktopWeb{
		videoShareObj.resetPlayerControls();
		docComp.updateControls(isPresenter);
		wbComp.updateWbControls(isPresenter);
		viewer3DComp.viewer3DSWC.setupGUI(isPresenter);
		viewer2DComp.updateControl(isPresenter);
	}
	
	applicationType::mobile{
		FlexGlobals.topLevelApplication.docComp.updateControls(isPresenter);
		FlexGlobals.topLevelApplication.wbComp.updateWbControls(isPresenter);
		FlexGlobals.topLevelApplication.videoComp.updateControls(isPresenter);
	}
}

/**
 * This function is for taking care the UI related changes and for passing the control status
 * to document module and whiteboard modules. This is called from the userSyncHandler whenever
 * a change in role happens to any of the logged in users.
 *
 * @param isPresenter of type Boolean
 * @return void
 */

private function updateUI(isPresenter:Boolean):void {
	if(ClassroomContext.userVO.role==Constants.MONITOR_TYPE)
		return;
	if (ClassroomContext.aviewClass.classType != Constants.CLASS_TYPE_WEBINAR)
		setupVideoButtons();
	applicationType::mobile{
			actionButtons.setupUserActionButtons();
	}
	//If this user is becoming presenter then we need to remove the teacher panel, 
	//based on the single/multi window mode
	if (isPresenter) {
		applicationType::DesktopWeb{
			setPresentersPresenterPanelDimensions();
			actionButtons.setupUserActionButtons();
			lstUsers.showHideFilters(true);
			applicationType::desktop{
				//Fix for #20126
				if(desktopViewer.isPopOut && desktopViewer.desktopSharingWindow){
					desktopViewer.desktopSharingWindow.close();
				}
			}
			//Desktop sharing	
			classroomComponentSgl.btnDesktopSharing.visible=true;
			share_Desktop_IconClass=share_Desktop;
			// for maintaing the module for fiving and releasing presenter control 
			if(!isReconnect) 
				onChangeModule();
		}
		//Fix for issue #17054
		applicationType::web{
			//Fix for issue #19270
			classroomComponentSgl.btnContentFullScreen.visible = true;
			classroomComponentSgl.btnContentFullScreen.includeInLayout = true;
			//Fix for issue #17982
			if(buttonContainer.btnControls){
				//Fix for issue #19621,#19625 and #19619
				buttonContainer.setVideoWallFullScreenButtonVisibility(false);
			}
			//fix for issue #18748
			if(classroomComponentSgl.isFullScreen){
				classroomComponentSgl.fullScreenSelected();
			}
		}
		if(isPopOutPresent)
			startPresentersStream();
		/*if (selectedViewersData.length > 1) {
			isMUISelected=true;
			interactionMUICount=ClassroomContext.aviewClass.maxViewerInteraction;
		} else if (!chkBoxMultiUserInteraction.selected) {
			isMUISelected=false;
			interactionMUICount=1;
		}*/
		
	}
		//If the user is becoming viewr, then we are adding back the panel in multi window mode
	else {
		applicationType::DesktopWeb{
			if(ClassroomContext.isModerator)
			{
				lstUsers.showHideFilters(true);
			}
			else
			lstUsers.showHideFilters(false);
			if (classroomComponentSgl.pnlTeacher.parent == null) {
				classroomComponentSgl.controlvidbox.addChildAt(classroomComponentSgl.pnlTeacher, 0);
			}
			setViewersPresenterPanelDimensions();
		}
		//Fix for issue #17054
		applicationType::web{
			// Fix for issue #1927:Made fullscreen button visible for viewer
			classroomComponentSgl.btnContentFullScreen.visible = true;
			classroomComponentSgl.btnContentFullScreen.includeInLayout = true;
			//Fix for issue #18965
			if(presentationLayout){
				if(buttonContainer.isFullscreenPresent){
					iVideoWallLayout.closeFullScreenVideo();
				}
			}
			//Fix for issue #17982
			if(buttonContainer.btnControls){
				buttonContainer.setVideoWallFullScreenButtonVisibility(false);
			}
			//For Guest Login: Restrict user action buttons(Handraise,Presenter request etc) for guest user
			if (ClassroomContext.userVO.role != Strings.GUEST_TYPE) {
				actionButtons.setupUserActionButtons();
			}
		}
		//Stop published video of nodes in VIEW mode
		if (viewedViewerDisplays.length > 0) {
			for (var i:int=0; i < viewedViewerDisplays.length; i++) {
				var parameters:Object=new Object();
				parameters.status="stop";
				parameters.selectedUser=viewedViewerDisplays[i].userName;
				parameters.presenterUser=ClassroomContext.userVO.userName;
				usersCollaborationObject.send("viewVideoStatusHandler", parameters);
				
				removeViewerFromViewPanel(viewedViewerDisplays[i].userName);
				i--;
			}
		}
		
		
		//Web version we are using btnDesktopSharing instead of btnViewDesktop.
		applicationType::DesktopWeb {
			classroomComponentSgl.btnDesktopSharing.visible=true;
			//Added this check to set tooltip for desktop sharing button
			if (ClassroomContext.IS_DESKTOP_SHARING_ENABLED) {
				classroomComponentSgl.btnDesktopSharing.toolTip="Desktop Viewer";
			} else {
				classroomComponentSgl.btnDesktopSharing.enabled=false;
				classroomComponentSgl.btnDesktopSharing.toolTip="Desktop Sharing is Disabled";
			}
			/*//Commented unused code
			if (polling != null) 
			{
				if(Log.isDebug()) log.debug(""+polling.getChildByName("CustomAlert"));
				polling.closeAllChildWindow();
			}*/
			
			if (muiAlert != null) {
				PopUpManager.removePopUp(muiAlert);
				showSettingsMenu();
				muiAlert=null;
			}
		}
		
		// Close the Polling window
		/*if(FlexGlobals.topLevelApplication.mainApp.modearr[1] == FlexGlobals.topLevelApplication.mainApp.savedOption)
		{
		if(polling_count != 0)
		{
		pollingMultipleWindow.closePollingWindow();
		}
		}*/
		setCloseButtonVideoStreamDisplay();
		isDuringModuleChange = false;
		trace("update UI");
		
	}
	setCloseButtonVideoStreamDisplay();
	applicationType::web{
		//For Guest Login: Restrict user action buttons(Handraise,Presenter request etc) for guest user
		if (ClassroomContext.userVO.role != Strings.GUEST_TYPE) {
			actionButtons.setupUserActionButtons();	
		}
	}
	applicationType::desktop{
		actionButtons.setupUserActionButtons();
	}
	applicationType::DesktopWeb {
		youtubelive_IconClass=youtubeliveStart;
	}
	if (isRefreshPressed == false) {
		updateModuleControles(isPresenter);
		//Fix for issue #15315 and #15382
		applicationType::desktop{
			//Added this check to change the desktop sharing UI at Presenter side
			if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
			{
				if (classroomComponentSgl.desktopSharingBox.getElementIndex(desktopSharingComp) > -1) {
					//Fix for issues #15417 and #15541
					//Stops sharing the screen if the desktop sharing stream is publishing
					//Stop Desktop sharing
					//Fix for issue #15746 and #15754
					if(desktopSharingCollabObject){
						//Fix for issue #15865, #16095 and #17092
						if(desktopSharingCollabObject.getData()["desktopSharing"] && desktopSharingCollabObject.getData()["desktopSharing"].status == "started"){	
							//Stop desktop sharing
							if (selectedSharingMode == 0){
								//Fix for issue #18195
								if(!isPresenter) {
									//Fixed for issue #18066
									stopSharing();
								}
								
							}
							//Stop application sharing
							else if (selectedSharingMode == 1){
								stopApplicationSharing();
							}
							if(isPresenter){
								sendDesktopSharingStatus("stopped");
							}
						}else{
							//Fix for issue #16526
							isDesktopSharingStarted = false;
						}
					}
					//Fix for issue #15382
					if(desktopSharingComp.previousRole != classroomContextObj.userRole){
						desktopSharingComp.changeView(isPresenter);
					}
				}
			}
		}
		//Fix for issue #11616 
		applicationType::web {			
			//Added this check to change the desktop sharing UI at Presenter side
			if (classroomComponentSgl.desktopSharingBox.getElementIndex(screenSharingComp) > -1) {
				//Stops sharing the screen if the screensharing stream is publishing
				//Fix for issue #15746 and #15754
				if(desktopSharingCollabObject){
					//Fix for issue #15865, #16095 and #17092
					if(desktopSharingCollabObject.getData()["desktopSharing"] && desktopSharingCollabObject.getData()["desktopSharing"].status == "started"){
						screenSharingComp.screenSharingContainerObj.screenPublisher.stopSharing();
						if(isPresenter){
							sendDesktopSharingStatus("stopped");
						}
					}else{
						isDesktopSharingStarted = false;
					}
				}
				//Fix for issue #14405
				if(screenSharingComp.screenSharingContainerObj.previousRole != classroomContextObj.userRole){
					screenSharingComp.screenSharingContainerObj.changeView(isPresenter);
				}
			}
		}
	}
	isReconnect = false;
}

//private var timeOutNumberWB:uint = -1;
///**
// * Fucntion to make sure the changes related to whiteboard module are applied only 
// * after making sure that the whiteboard connection is established. This will make sure
// * the sucessfull execution of methods in the whiteboard module which are reffered here.
// * 
// * @param isPresenter of type Boolean
// * @return void
// */   
//
//private function waitForWbConnection(isPresenter:Boolean):void
//{
//	
//	clearTimeout(timeOutNumberWB);	
//	
//	if(!wbComp.wbFmsConnection.connected)
//	{
//		if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: waitForWbConnection: WbConnection is not available. Waiting..isPresenter:"+isPresenter);
//		timeOutNumberWB = setTimeout(waitForWbConnection,1000,isPresenter);
//	}
//	else
//	{
//		if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Users: waitForWbConnection: WbConnection is available.isPresenter:"+isPresenter);
//		
//		wbComp.updateWbControls(isPresenter);
//		
//	}		
//}

/**
 * Function to set the current PRESENTER name acorss all modules.
 * This will be called whenever a change in PRESENTER role happens.
 * This fucntion is called from userSyncHandler.
 *
 * @param currentPresenterName of type String
 * @return void
 */
private function setCurrentPresenter(currentPresenterName:String):void {
	ClassroomContext.currentPresenterName=currentPresenterName;
	var previousUsersSOState:Object=getPreviousState(currentPresenterName);
	if (previousUsersSOState == null || previousUsersSOState.userRole != Constants.PRESENTER_ROLE && !ClassroomContext.isModerator) {
		notifyPresenter=true;
	}
	applicationType::DesktopWeb{
		docComp.presenterName=currentPresenterName;
		if(viewer3DComp!=null)
		//Bug fix 4697 start
		viewer3DComp.presenterViewer3D=currentPresenterName;
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.docComp.presenterName=currentPresenterName;
		if(FlexGlobals.topLevelApplication.viewer3DComp!=null)
			//Bug fix 4697 start
			FlexGlobals.topLevelApplication.viewer3DComp.presenterViewer3D=currentPresenterName;
	}
	//Bug fix 4697 end
}

public function usersAsyncErrorHandler(e:AsyncErrorEvent):void {
}

private function restartDesktopSharing():void {
	clearTimeout(restartDesktopSharingTimeoutId);
	   //Fix for issue #18106
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
			//Web version, added library file for Desktop and Application sharing, so now the following code is not used
		applicationType::desktop {
			if (selectedSharingMode == 1) {
				applicationSharingRestart=true;
				initApplicationSharing();
			} else {
				callDesktopSharing();
			}
		}
		//Fix for issue #14405
		applicationType::web{
			screenSharingComp.screenSharingContainerObj.screenPublisher.callStartSharing();
		}
	}
}
applicationType::desktop{
	//Fix for issue #15815
	private function initializeApplication():void{	
		clearTimeout(initDesktopSharingTimeoutId);
		initApplicationSharing();
	}
}

public function setStreamingStatus():void {
	usersConnection.netConnection.call("setStreamingStatus", null, ClassroomContext.userVO.userName, ClassroomContext.isAudioOnlyMode);
}

private function connectDesktopSharingCollabObject():void {
	desktopSharingCollabObject=ClassroomContext.collaborationService.connectCollaborationObject("desktopSharingSharedObject1");
	desktopSharingCollabObject.setOnSync(desktopSharingSyncHandler);
}

/**
 * Function to send desktop sharing status to server
 * This will be called whenever PRESENTER starts/stops desktop and application sharing
 * This fucntion is called from userSyncHandler.
 *
 * @param status of type String
 * @param capRect of type String
 * @return void
 */
applicationType::web {
	public function sendDesktopSharingStatus(status:String):void {
		var obj:Object=new Object;
		obj.user=ClassroomContext.userVO.userName;
		obj.status=status;
		desktopSharingCollabObject.setValue("desktopSharing", obj);
	}
	
	/**
	 * @public
	 * The function is used to set the color quality of desktop sharing screen video to shared object.
	 *
	 *
	 * @return void
	 */
	//Fix for issue #17747
	public function setDesktopSharingScreenQualityToCollabObject():void{
		//Fixed for #18484
        var obj:Object=new Object;
		obj.index=prefSettings.prefDesk.videoQualityList.selectedIndex;
		obj.quality=prefSettings.prefDesk.colorQualityOption[prefSettings.prefDesk.videoQualityList.selectedIndex].value;
		desktopSharingCollabObject.setValue("desktopColorQuality", obj);
	}
}

public function desktopSharingSyncHandler(sharedDesktopData:Object):void {
	//Fix for issue #16464
	applicationType::DesktopWeb {
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings)
		{
			applicationType::desktop {
				if(sharedDesktopData["desktopSharing"] && sharedDesktopData["desktopColorQuality"] != undefined && sharedDesktopData["desktopSharing"].status == "started")
					{
						if(selectedSharingMode == 0)
						{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setColorDesktopSharing();
						}
						else if(selectedSharingMode == 1)
						{	
							streamColorSelect = true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setColorApplicationSharing();
						}
					}
				//Fix for issue #20303
				else
				{
					if(selectedSharingMode == 0)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setColorDesktopSharing();
					}
					else if(selectedSharingMode == 1)
					{	
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setColorApplicationSharing();
					}
				}
			}
			//Fix for issue #17747
			/*applicationType::web {
				if (sharedDesktopData["desktopSharing"] && sharedDesktopData["desktopSharing"] != "default"){
					if (sharedDesktopData["desktopSharing"].user && sharedDesktopData["desktopSharing"].user != ClassroomContext.userVO.userName) {
						if(sharedDesktopData["desktopSharing"] && sharedDesktopData["desktopColorQuality"] != undefined && sharedDesktopData["desktopSharing"].status == "started")
						{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.screenSharingComp.screenSharingContainerObj.setColorDesktopSharing();
						}
					}
				}
			}*/
			if (sharedDesktopData["unInterruptedDesktopSharing"]=="ON")
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.setPreferenceUninterruptedDesktopSharing(true);
			}
			else
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.prefSettings.setPreferenceUninterruptedDesktopSharing(false);
			}
		}
	}
	if (sharedDesktopData["desktopSharing"] && sharedDesktopData["desktopSharing"] != "default") {
		if (sharedDesktopData["desktopSharing"].user && sharedDesktopData["desktopSharing"].user != ClassroomContext.userVO.userName) {
			if (sharedDesktopData["desktopSharing"].status == "started") {
				applicationType::web {
					if (screenSharingComp != null) {
						//Fix for issue #7939
						if (tempUnInterruptedDesktopSharingValue != "" && tempUnInterruptedDesktopSharingValue != sharedDesktopData["unInterruptedDesktopSharing"]) {
							tempUnInterruptedDesktopSharingValue=sharedDesktopData["unInterruptedDesktopSharing"].toString();
							return;
						}
						//Added following logic,since we have added library file for Desktop and Application sharing
						if (screenSharingComp.screenSharingContainerObj.isScreenSharingCompAdded == false) {
							screenSharingComp.assignValues();
							screenSharingComp.screenSharingContainerObj.addDesktopSharingPlayer();
						}
						click_Conso_Desktop();
						//In AVC desktop version, they have hard-coded the resolution, so we also set the area statically
						//Reduce desktop player width and height to avoid scrollbar in desktop sharing window
						//display the player
						screenSharingComp.screenSharingContainerObj.viewDesktop(true, "1,1,1273,1017");
					}
				}
				applicationType::DesktopMobile {
					//Fix for issue #16464 and #17092
					if (tempUnInterruptedDesktopSharingValue != "" && tempUnInterruptedDesktopSharingValue != sharedDesktopData["unInterruptedDesktopSharing"] && sharedDesktopData["unInterruptedDesktopSharing"]) {	
					    tempUnInterruptedDesktopSharingValue=sharedDesktopData["unInterruptedDesktopSharing"].toString();
						return;
					}
					if (desktopSharingComp != null) {
						applicationType::mobile{
							FlexGlobals.topLevelApplication.setActiveModule(true,5);
						}
						if (desktopViewerWindowOpenFlag == false) {
							createDesktopViewer();
						}
						applicationType::desktop{
							//Fix for issue #16290 and #16293
							click_Conso_Desktop();
						}
						viewDesktop(true,"1,1,1273,1017");
						applicationType::desktop{
							//Fix for issue #16305 and #16308
							FlexGlobals.topLevelApplication.activate();
						}
					}
				}
			} else {
				//In AVC desktop version, they have hard-coded the resolution, so we also set the area statically
				//Reduce desktop player width and height to avoid scrollbar in desktop sharing window
				//remove the player
				applicationType::web {
					if (screenSharingComp != null) {
						screenSharingComp.screenSharingContainerObj.viewDesktop(false, "1,1,1273,1017");
					}
				}
				applicationType::DesktopMobile {
					if (desktopSharingComp != null) {
						if (desktopViewer) {
							desktopViewer.isDesktopPlayerCreated=true;
							if(desktopViewer.isPopOut){
								desktopViewer.popOutDesktopSharingWindow();
							}
							//Fix for issues #15386, #15417,#15418 and #15541
							viewDesktop(false,"1,1,1273,1017");
						}
					}
				}
			}
		}
	}
	//Added this check to avoid null object reference issue, when user enter into the classroom. 
	applicationType::DesktopWeb {
		if (sharedDesktopData["unInterruptedDesktopSharing"]) {
			//Set previous value for unInterruptedDesktopSharing. This is a temporary fix for issue #7939
			tempUnInterruptedDesktopSharingValue=sharedDesktopData["unInterruptedDesktopSharing"].toString();
		}
	}
}

public function sendViewVideoStatus(status:String, selectedUser:String):void {
	var userTime:UserTime=getUserTime(selectedUser);
	userTime.setUserStatusTime();
	var parameters:Object=new Object();
	parameters.status=status;
	parameters.selectedUser=selectedUser;
	parameters.presenterUser=ClassroomContext.userVO.userName;
	if((ClassroomContext.userVO.role == Constants.MONITOR_TYPE  && getUserSO(selectedUser).userStatus != Constants.ACCEPT)||ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
	usersCollaborationObject.send("viewVideoStatusHandler", parameters);
	//users_so.send("viewVideoStatusHandler", status, selectedUser, ClassroomContext.userVO.userName);
	applicationType::DesktopWeb{
		if (status == "start") {
			addViewerToViewPanel(selectedUser, getUserSO(selectedUser).userDisplayName);
		} else {
			remove_viewVideo(lstUsers.userGrid.selectedItem.id);
		}
	}
}

private var beingViewed:Boolean=false;

public function viewVideoStatusHandler(parameters:Object):void {
	if (parameters.selectedUser == ClassroomContext.userVO.userName) {
		if (parameters.status == "start") {
			if (isVideoPublishedState() == true) {
				startCapture(Constants.VIEWER_ROLE);
				beingViewed=true;
			}
		} else {
			if (isVideoPublishedState() == true) {
				stopCapture(Constants.VIEWER_ROLE);
				beingViewed=false;
			}
		}
	}
}

public function viewVideoStatus(uName:String):Boolean {
	var flag:int=0;
	applicationType::DesktopWeb{
		for (var i:int=0; i < viewedViewerDisplays.length; i++) {
			if (uName + Constants.VIEWER_APPEND_NAME == viewedViewerDisplays[i].id) {
				flag=1;
				break;
			}
		}
	}
	if (flag == 1)
		return true;
	else
		return false;
}

public function isUnInterruptedDesktopsharingON():Boolean {
	var unInterruptedDesktopsharingON:Boolean=false;
	try {
		if (desktopSharingCollabObject && desktopSharingCollabObject.getData()["unInterruptedDesktopSharing"] && desktopSharingCollabObject.getData()["unInterruptedDesktopSharing"] == "ON") {
			unInterruptedDesktopsharingON=true;
		} else {
			//Fix for issue #19188
			if(desktopSharingCollabObject.getData()["unInterruptedDesktopSharing"] == undefined) {
				if(tempUnInterruptedDesktopSharingValue == "ON") {
					unInterruptedDesktopsharingON=true;
				}
				else if(tempUnInterruptedDesktopSharingValue == "OFF") {
					unInterruptedDesktopsharingON=false;
				}
				desktopSharingCollabObject.setValue("unInterruptedDesktopSharing", tempUnInterruptedDesktopSharingValue);
			}
			else
			{
				unInterruptedDesktopsharingON=false;
			}
		}
	} 
	catch (err:Error) {
		if(Log.isError()) log.error("Error in isUnInterruptedDesktopsharingON method:"+ err.getStackTrace());
	}
	return unInterruptedDesktopsharingON;
}
public function viewVideoMessage(uName:String):void{
	applicationType::DesktopWeb{
		for (var i:int=0; i <  viewedViewerDisplays.length; i++){
			var videoDisplay:VideoStreamDisplay= viewedViewerDisplays[i] as VideoStreamDisplay;
			var viewerDisplay:VideoStreamDisplay=iVideoWallLayout.getViewerVideoStreamDisplay(videoDisplay);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setViewerVideoDisplaySize(viewerDisplay, false);
			if(viewerDisplay.userName == uName){
				showViewVideo(getUserSO(uName).isAudioOnlyMode,getUserSO(uName).isVideoHide,getUserSO(uName).isAudioMute,viewerDisplay);
			}
		}
	}
}
applicationType::mobile{
	public function prepareUserDetails():void {
		ClassroomContext.userDetails.operatingSystem=Capabilities.os;
		ClassroomContext.userDetails.playerVersion=Capabilities.version;
		ClassroomContext.userDetails.screenResolution=Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY;
		ClassroomContext.userDetails.pixelAspectRatio=Capabilities.pixelAspectRatio;
		ClassroomContext.userDetails.AVIEW_VERSION=PrepareLogin.AVIEW_VERSION;
		ClassroomContext.userDetails.maxLevelIDC=Capabilities.maxLevelIDC;
		ClassroomContext.userDetails.cpuArchitecture=Capabilities.cpuArchitecture;
		ClassroomContext.userDetails.supports64Bit=Capabilities.supports64BitProcesses;
		ClassroomContext.userDetails.avHardware=Capabilities.avHardwareDisable;
		ClassroomContext.userDetails.localFileRead=Capabilities.localFileReadDisable;
		
	}
}

