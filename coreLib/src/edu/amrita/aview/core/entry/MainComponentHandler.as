applicationType::desktop{
	import edu.amrita.aview.core.entry.Bandwidth;
}

import mx.events.ResizeEvent;
import mx.graphics.BitmapFill;
import edu.amrita.aview.core.login.boilerplate.Strings;


applicationType::DesktopWeb{
	
import objectResolver.EntryFac;



import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomComponent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.HomePage;
import edu.amrita.aview.core.entry.LectureNoticeBoard;
import edu.amrita.aview.core.login.MainApp;
import edu.amrita.aview.core.entry.SessionEntry;
import edu.amrita.aview.core.evaluation.Evaluation;
import edu.amrita.aview.core.gclm.Administration;
import edu.amrita.aview.core.gclm.helper.ClassServerChangeConsumer;
import edu.amrita.aview.core.gclm.vo.BrandingAttributeVO;
import edu.amrita.aview.core.gclm.vo.ClassServerVO;
import edu.amrita.aview.core.gclm.vo.InstituteBrandingVO;
import edu.amrita.aview.core.gclm.vo.InstituteVO;
import edu.amrita.aview.core.lms.Lms;
import edu.amrita.aview.core.recording.Recorder;
import edu.amrita.aview.core.sessionAdmin.AdminConsole;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.profileMenuComponent;
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.core.shared.events.ChatStatusEvent;
import edu.amrita.aview.core.shared.helper.AbstractHelper;


import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import mx.binding.utils.BindingUtils;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.events.ModuleEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.styles.IStyleManager2;
import mx.styles.StyleManager;

import spark.components.Label;
import spark.events.IndexChangeEvent;
public var classEntryCheck:Boolean=false;
public var classroomComp:ClassroomComponent;
public var entryFac:EntryFac = new EntryFac;

[Bindable]
public var fileName:String=''; //for holding the help pdf file name, this has taken from the help config file 
[Bindable]
private var serverUrl:String=''; //for holding the help pdf file path, this has taken from the help config file
[Bindable]
public var configXML:XMLList=new XMLList;

public var lmsInst:Lms=new Lms();

//---help---
//RGCR: Prepend the variables with the word 'help'
private var request:URLRequest=new URLRequest;
private var stream:URLStream=new URLStream();

public var adminConsoleInst:AdminConsole;
private var adminInst:Administration=new Administration(); // Administrator admin module instance

[Bindable]
public var bugreportFormSpeedTestEnable:Boolean=false;

public var lectureNotice_Can:LectureNoticeBoard; //instance of custom component LectureNoticeBoard 

//variables declared for bug report form
private var reportCompcnt:int=0;

//RGCR: Below variable is not used.
public var bugreport_sel_ip:String="";

[Bindable]
private var popDownload = entryFac.helpDownloadWindow();
//RGCR: This variable is not set any other value. But used in condition
private var classSchedule_flag:int=0;

private var styleURL:String="";

//RGCR: These three variables below are not used.
[Bindable]
private var writeString:String="";

private var contactsManager = null;

//RGCR: All the below Preference related variables till 'noIntialxml_flag' are not used.
public var interaction_mode:String;
public var stud_mode:String;
public var autorecord:String;
public var systemcheck:String;
public var beepoption:String;
public var beepselect:String;
public var microphoneselect:String;
public var cameraselect:String;
public var vid_pref_flag:int=0;
public var aud_pref_flag:int=0;
public var noIntialxml_flag:int=0; //TODO: not used 
public var helpMenuUI:HelpMenu;

public var evaluationWnd:Evaluation=new Evaluation();
public var profileMenu:profileMenuComponent;
public var isPlayback:Boolean=false;

/* for meeting starts*/
//public var aviewMeeting:AViewMeeting=null;
private var meetingStarted:Boolean=false;
private var clearExitRoomMessage:MessageBox;
private var isNormalExit:Boolean=false;
/* for meeting ends*/
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.entry.MainComponentHandler.as");

public var labelMsg:spark.components.Label;
//QuickNote/////////////
public var quickNote = null;
public var quickNoteOpenFlag:Boolean=false;

//**************Feedbackform**************
[Bindable]
public var feedback = null;
[Bindable]
public var isPopupFeedbackForm:Boolean=false;

[Bindable]
public var isPopupFeedbackComment:Boolean=false;

[Bindable]
public var txtOverAllRatingStatus:Boolean=false;
[Bindable]
public var overAll:String='';
[Bindable]
public var txtAudioRatingStatus:Boolean=false;
[Bindable]
public var audioRate:String='';
[Bindable]
public var txtVideoRatingStatus:Boolean=false;
[Bindable]
public var videoRate:String='';
[Bindable]
public var txtInteractionRatingStatus:Boolean=false;
[Bindable]
public var interactionRate:String='';
[Bindable]
public var txtWBRatingStatus:Boolean=false;
[Bindable]
public var wbRate:String='';
[Bindable]
public var txtDocRatingStatus:Boolean=false;
[Bindable]
public var docRate:String='';
[Bindable]
public var txtDeskRatingStatus:Boolean=false;
[Bindable]
public var deskRate:String='';
[Bindable]
public var txtUIRatingStatus:Boolean=false;
[Bindable]
public var uiRate:String='';

private var _appEventMap:EventMap = null;

//Localization localechain array
// Bug #14558: disabling the feature
[Bindable]
public var localeChainDataProvider:ArrayCollection=new ArrayCollection();
//public var localeChainDataProvider:ArrayCollection=new ArrayCollection([{label: "English(UNITED STATES)", locale: "en_US"}, {label: "française(France)", locale: "fr_FR"}, {label: "?????(INDIA)", locale: "hi_IN"}, {label: "????? (INDIA)", locale: "ta_IN"}, {label: "(JAPAN)", locale: "ja_JP"}, {label: "??????(INDIA)", locale: "ml_IN"}, {label: "?????? (INDIA)", locale: "te_IN"}, {label: "svenska(SWEDEN)", locale: "sv_SE"}, {label: "Turkish(TURKEY)", locale: "tr_TR"}]);

/**Platform specific variables*/
applicationType::desktop {
	[Bindable]
	public var file:File=new File;
	[Bindable]
	private var _file:File;
	[Bindable]
	private var _fileStream:FileStream;
}

applicationType::web {
	/* Varaible to store whether java plug-in is enabled or not in the browser */
	public var isJavaEnabledFlag:Boolean;
}

public function initializeEntryFacVar(){
	quickNote = entryFac.quickNoteComponent();
}
applicationType::desktop{
	[Bindable]
	private var checkBandwidth:Bandwidth;
}
//**************************functions start*********************************
/**
 * The function is to choose from the various languages.
 * Localization of application is being done.
 *
 */
protected function localeComboBox_changeHandler(event:IndexChangeEvent):void {
	// TODO Auto-generated method stub
//	this.resourceManager.localeChain=[localeComboBox.selectedItem.locale];
}

public function get appEventMap():EventMap
{
	return _appEventMap;
}

public function set appEventMap(value:EventMap):void
{
	_appEventMap = value;
}

/**
 *
 * Help document downlaod starts here
 *
 * **/
//Configuration Details Setting to downlaod the help pdf file
//RGCR:Method should be renamed to preinitializeHandler
protected function windowedapplication1_preinitializeHandler(event:FlexEvent):void {
	helpConfigService.send();
}


private function init():void {
	initializeEntryFacVar();
	
	FlexGlobals.topLevelApplication.mainApp.classRoomFlag=false;
	maincontrolbar.selectedChild=Homepage;
	var homepageInst:HomePage=new HomePage();
	//RGCR: Why are we adding home page to itself?
//	Homepage.addChild(homepageInst);

	if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE || ClassroomContext.userVO.role == Constants.ADMIN_TYPE) {
		btnEvaluation.visible=false;
		btnEvaluation.includeInLayout=false;
		lblEvaluation.visible=false;
		lblEvaluation.includeInLayout=false;
		imgSeprator.visible=false;
		imgSeprator.includeInLayout=false;
		quizMenuContainer.visible=false;
		quizMenuContainer.includeInLayout=false;
		btnAdministrator.toolTip=Constants.SETUP_ADMIN_TOOLTIP;
	}
	liveSessionMenuContainer.backgroundFill = activeBackground;
	lblLiveSession.setStyle("color",0xFFFFFF);
	//changeBackground(activeBackground);
	
}

private function createContactsManager():void
{
	contactsManager = entryFac.getContactsManager(ClassroomContext.userVO,this.appEventMap);
	contactsManager.initialize();
}
private function showContactsView():void
{
	//navigation("btnContacts");
	if (meetingCanvas)
	{
		meetingCanvas.removeAllChildren();
	}
	Homepage.removeAllChildren();
	//Fix for issue #19317
	applicationType::web {
		closePlaybackPopUpWindow();
	}
	//enableDisableMainWindowButtons("btnContacts", true);
	maincontrolbar.selectedChild = meetingCanvas;
	contactsView = contactsManager.getContactsView();
	meetingCanvas.addChild(contactsView);
}
public function endMeetingSession():void
{
	var netConnection:NetConnection=contactsManager.getMediaServerConnection().netConnection;
	netConnection.call("endSession",null,getcurrentActiveMembers());
}

private function openChathistory():void {
	navigation("btnChatHistory");
}


private function getcurrentActiveMembers():Array
{
	var memberNames:Array=new Array();
	for(var userName:String in classroomComp.usersCollaborationObject.getData())
	{
		if(userName!=ClassroomContext.userVO.userName )
		{
			memberNames.push(userName);
		}
	}
	for(var i:int=0;i<classroomComp.lstUsers.offlineUsersArray.length;i++)
	{
		if(classroomComp.lstUsers.offlineUsersArray[i].user.userName != ClassroomContext.userVO.userName)
		{
			memberNames.push(classroomComp.lstUsers.offlineUsersArray[i].user.userName);
		}
	}
	return memberNames;
	
}


public function openHelpContents():void {
	var helpFilePath:String;
	applicationType::web {
		//Assign help content remote path
		var helpFilePath:String=serverUrl + fileName
		//if file is not exist download the ontent else open it in new browser window;
		if (fileName == null && serverUrl == null) {
			downloadHelpDoc();
		} else {
			navigateToURL(new URLRequest(helpFilePath), "_blank");
		}
	}
	applicationType::desktop {
		if (Capabilities.os.toLowerCase().indexOf("mac") > -1) {
			helpFilePath="file:///" + file.nativePath;
		} else {
			helpFilePath=file.nativePath;
		}

		if (file.exists) {
			if (file.name != fileName) {
				downloadHelpDoc();
			} else
				navigateToURL(new URLRequest(helpFilePath), "_self");
		} else {
			downloadHelpDoc();
		}
	}
}

//downloading the help doc
private function downloadHelpDoc():void {
	applicationType::desktop {
		//CRJH: API (done: JH) - Not needed
		//popDownload=new HelpDownloadWindow;
		PopUpManager.addPopUp(popDownload, FlexGlobals.topLevelApplication as DisplayObject, true);
		PopUpManager.centerPopUp(popDownload);
		stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
		stream.addEventListener(Event.COMPLETE, onComplete);
		stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadIoError);
		stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
		request.url=serverUrl + fileName;
		stream.load(request);
	}
	//navigateToURL(new URLRequest(serverUrl + fileName), "_blank");
}

// to open the PDF file after the download
private function onComplete(event:Event):void {
	popDownload.btnView.visible=true;
	popDownload.btnView.setFocus();
	popDownload.warningMsg.visible=true;

	var fileData:ByteArray=new ByteArray();
	stream.readBytes(fileData, 0, stream.bytesAvailable);
	applicationType::desktop {
		var fileStream:FileStream=new FileStream();
		fileStream.open(file, FileMode.WRITE);
		fileStream.writeBytes(fileData, 0, fileData.length);
		fileStream.close();
	}
}

// to show the progressbar based on the download of the help pdf file
private function onDownloadProgress(event:ProgressEvent):void {
	try {
		popDownload.progBar.label="Downloading [" + Math.round(event.bytesLoaded / event.bytesTotal * 100).toString() + "%]";
		popDownload.progBar.setProgress(event.bytesLoaded, event.bytesTotal);
	} 
	catch (ex:Error) {
		Alert.show(ex.message.toString());
	}
}

// Called on downlaod io error
private function onDownloadIoError(event:IOErrorEvent):void {
	Alert.show(event.text.toString());
}

// Called on downlaod security error
private function onDownloadSecurityError(event:SecurityErrorEvent):void {
	Alert.show(event.text.toString());
}

/**
 * result handler for the help pdf configuration
 * This method will invoke from the http service
 * which is specified in the declaration part "helpConfigService"
 **/
private function configResultHandler(event:ResultEvent):void {
	//This variable will store the xml list
	configXML=XMLList(event.result);
	//for storing the file name of the document file
	applicationType::web {
		fileName=(configXML[0]..webhelp.@filename).toString();
		//for storing the server path of the PDF file for the downloading purpose
		serverUrl=(configXML[0]..webhelp.@serverURL).toString();
	}
	applicationType::desktop {
		fileName=(configXML[0]..help.@filename).toString();
		serverUrl = (configXML[0]..help.@serverURL).toString();
		file=File.documentsDirectory.resolvePath(fileName);
	}
}

// fault handler for the help pdf configuration
private function configFaultHandler(evt:FaultEvent):void {
	if(Log.isError()) log.error("entry::MainComponentHandler::configFaultHandler:"+ AbstractHelper.getStaticFaultMessage(evt));
	var title:String=evt.type + " (" + evt.fault.faultCode + ")";
	var text:String=evt.fault.faultString;
}

/**
 * The function is used to handle the navigation between classroom,library and
 * administration buttons.Depending on the module clicked by the user, buttons are set
 * accordingly and corresponding canvas are added to homepage canvas.Also the
 * components for corresponding module are initialized.
 *
 * @param Button_name of type String
 * @return void
 */
/* If the button clicked is classroom then, classroom button is disabled and library and administration buttons are enabled.
The library and administration buttons are changed accordingly as Library_unclicked and Administration_unclicked.
Similarly depending on the module clicked by the user, buttons are set accordingly and corresponding canvas are added to
homepage canvas.Also the components for corresponding module are initialized. */
private var contactsView=null;
private var chatHistory =null ;

//RGCR: All the various if blocks in this method can be broken into different methods, as there is no common code in this method outside the if blocks
public function navigation(Button_name:String):void {
	//Fix for issue #20102
	applicationType::DesktopMobile{
		contactsManager.removeEventListener(EntryFac.END_SESSION, refreshNoticeBoard);
	}
	applicationType::web{
		if(contactsManager){
			contactsManager.removeEventListener(EntryFac.END_SESSION, refreshNoticeBoard);
		}
	}
	//Fix for Bug#17644:Start
	//To avoid timer in lecturenoticeboard.
	if(lectureNotice_Can != null)
	{
		lectureNotice_Can.stopSessionRetrievalTimer();
		//lectureNotice_Can = null;
	}
	//Fix for Bug#17644:End
	if (Button_name != "btnContacts") {
		//clearMeetingCanvas();

	}
	if (Button_name == "btnChatHistory") {
		if (meetingCanvas) {
			meetingCanvas.removeAllChildren();
		}
		Homepage.removeAllChildren();
		//enableDisableMainWindowButtons("btnChathistory", true);
		maincontrolbar.selectedChild=meetingCanvas;
		//CRSM: updated every  time a new ChatHistory object needs to be created.
		chatHistory=entryFac.chatHistory();
		chatHistory.init(ClassroomContext.userVO,this.appEventMap);
		meetingCanvas.addChild(chatHistory);
	}
//	if (Button_name == "btnContacts") {
//		if (meetingCanvas) {
//			meetingCanvas.removeAllChildren();
//		}
//		Homepage.removeAllChildren();
//		enableDisableMainWindowButtons("btnContacts", true);
//		maincontrolbar.selectedChild=meetingCanvas;
////		mycontacts=new MyContacts;
////		mycontacts.onlineUserDirConnection=this.onlineUserDirConnection;
////		meetingCanvas.addChild(mycontacts);
//	}
	if (Button_name == "btnClassroom") {
		if (meetingStarted) {
			MessageBox.show("Meeting is going on.\nClick 'ok' to close meeting and enter classroom.", "Warning", MessageBox.MB_OKCANCEL, this, null, null);

				//this.addEventListener("Meeting_End",meetingEndHandler);
		} else {
			loadClassroom();
		}
	} else if (Button_name == "btnLibrary") {
		//enableDisableMainWindowButtons("btnLibrary", true);
		//Bug fix issue #7882 
		if (Library_canvas.contains(adminInst)) {
			Library_canvas.removeElement(adminInst);
		}
		applicationType::web {
			if (Library_canvas) {
				maincontrolbar.addChild(Library_canvas);
			}
		}
		maincontrolbar.selectedChild=Library_canvas;
		try {
			Homepage.removeAllChildren();
			FlexGlobals.topLevelApplication.mainApp.faceRegistration.stopCameraInterface();
			Biometric_canvas.removeAllChildren();
			//CRJH: not sure why again creating an instance
			lmsInst = new Lms();
		} 
		catch (err:Error) {
			if(Log.isError()) log.error("Error in navigation method::btnLibrary:"+ err.getStackTrace());
		}
		
		applicationType::web {
			//Fix for issue #19317 
			if (lmsInst.player) {
				//Fix for issue #19317
				lmsInst.player.visible=true;
				lmsInst.player.playerComp.visible=true;
			}
			if (lmsInst.player && lmsInst.player.playerComp){
				if(lmsInst.player.playerComp.presenterVid){
					lmsInst.player.playerComp.presenterVid.visible=true;
				}
				if(lmsInst.player.playerComp.viewerVid) {
					lmsInst.player.playerComp.viewerVid.visible=true;
				}
				if(lmsInst.player.playerComp.chatWndw){
					lmsInst.player.playerComp.chatWndw.visible = true;
				}	
			}
			else {
				Library_canvas.addChild(lmsInst);
			}
		}
		
	
		applicationType::desktop {
			Library_canvas.addChild(lmsInst);
		}
		hideClassroomComp();
		
	} else if (Button_name == "btnBiometric") {
		//enableDisableMainWindowButtons("btnBiometric", true);
		maincontrolbar.selectedChild=Biometric_canvas;
		try {
			Homepage.removeAllChildren();
			Biometric_canvas.removeAllChildren();
		} 
		catch (err:Error) {
			if(Log.isError()) log.error("Error in navigation method::btnBiometric:"+ err.getStackTrace());
		}
		hideClassroomComp();

		FlexGlobals.topLevelApplication.mainApp.faceRegistration= entryFac.faceRegistrationForm();
		FlexGlobals.topLevelApplication.mainApp.faceRegistration.userID=ClassroomContext.userVO.userId;
		FlexGlobals.topLevelApplication.mainApp.faceRegistration.serverIP=MainApp.BIOMETRIC_SERVER;
		Biometric_canvas.addChild(FlexGlobals.topLevelApplication.mainApp.faceRegistration);
		applicationType::web {
			closePlaybackWindows();
			closePlaybackPopUpWindow();
		}
	} else if (Button_name == "btnAdministrator") {
		//enableDisableMainWindowButtons("btnAdministrator", true);
		applicationType::desktop{
			maincontrolbar.selectedChild=Library_canvas;
		}
		try {
			Homepage.removeAllChildren();
			applicationType::web {
				//Bug fix issue #7882 
				if (Library_canvas.contains(lmsInst)) {
					Library_canvas.removeChild(lmsInst);
				}
				//Fix for issue #19317
				if (lmsInst.player) {
					lmsInst.player.visible=false;
				}
			}
			applicationType::desktop {
				Library_canvas.removeAllChildren();
			}
			FlexGlobals.topLevelApplication.mainApp.faceRegistration.stopCameraInterface();
			Biometric_canvas.removeAllChildren();
		} 
		catch (err:Error) {
			if(Log.isError()) log.error("Error in navigation method::btnAdministrator:"+ err.getStackTrace());
		}
		hideClassroomComp();
		applicationType::web {
			//Bug fix issue #7882 
			if (Library_canvas) {
				maincontrolbar.addChild(Library_canvas);
			}
			maincontrolbar.selectedChild=Library_canvas;
		}
		Library_canvas.addChild(adminInst);
		if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
			adminInst.clickInstitute();
		} else {
			adminInst.clickCourse();
		}
		applicationType::web {
			closePlaybackPopUpWindow();
		}
	} else if (Button_name == "btnbugreport") {
		//enableDisableMainWindowButtons("btnbugreport", true);
		maincontrolbar.selectedChild=bug_report_form;
		try {
			Homepage.removeAllChildren();
			bug_report_form.removeAllChildren();
			FlexGlobals.topLevelApplication.mainApp.faceRegistration.stopCameraInterface();
			Biometric_canvas.removeAllChildren();
		} 
		catch (err:Error) {
			if(Log.isError()) log.error("Error in navigation method::btnbugreport:"+ err.getStackTrace());
		}
		hideClassroomComp();

		applicationType::web {
			closePlaybackPopUpWindow();
		}
	}

	else if (Button_name == "btnEvaluation") {
		ClassroomContext.checkIsClassRoom=false;
		//enableDisableMainWindowButtons("btnEvaluation", true);
		maincontrolbar.selectedChild=evaluationCanvas;

		try {
			Homepage.removeAllChildren();
			applicationType::web {
				//Bug fix issue #7882 
				maincontrolbar.removeChild(Library_canvas);
			}
			applicationType::desktop {
				Library_canvas.removeAllChildren();
			}
			FlexGlobals.topLevelApplication.mainApp.faceRegistration.stopCameraInterface();
			Biometric_canvas.removeAllChildren();
		} 
		catch (err:Error) {
			if(Log.isError()) log.error("Error occured while opening the evaluation module:"+ err.getStackTrace());
		}
		hideClassroomComp();
		if (evaluationWnd != null) {
			evaluationWnd=new Evaluation();
			evaluationCanvas.addChild(evaluationWnd);
			evaluationWnd.hBoxParent.includeInLayout=true;
			evaluationWnd.initEvaluation();
		}
		applicationType::web {
			closePlaybackPopUpWindow();
		}
	}
}

public function loadClassroom():void {
	//Fixing bugs Bug #10369 & Bug #7856
	//Admin's can re-enter the class and some cleanup..
	//				if(classroomComp && (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE))
	//				{
	//					FlexGlobals.topLevelApplication.mainApp.initiateExit('exitClassroom');
	//					return;
	//				}
	ClassroomContext.checkIsClassRoom=true;
	//enableDisableMainWindowButtons("btnClassroom", true);
	//RGCR: Why are setting the Homepage as the selected child?
	maincontrolbar.selectedChild=Homepage;

	if (Homepage != null) {
		Homepage.removeAllChildren();
	}

	if (Library_canvas != null) {
		applicationType::web {
			//Bug fix issue #7882 
			if (maincontrolbar.contains(Library_canvas)) {
				maincontrolbar.removeChild(Library_canvas);
			}
		}
		applicationType::desktop {
			Library_canvas.removeAllChildren();
		}
	}

	if (FlexGlobals.topLevelApplication.mainApp.faceRegistration != null) {
		FlexGlobals.topLevelApplication.mainApp.faceRegistration.stopCameraInterface();
	}

	if (Biometric_canvas != null) {
		Biometric_canvas.removeAllChildren();
	}
	//RGCR: The part of contents of this if block can be in the ClassroomComponent
	//RGCR: What about the else part?
	if (classroomComp) {
		classroomComp.settingsList.visible=false;
		classroomComp.settingsList.height=0;

		if (classroomComp.evaluationFlag) {
			//RGCR: Why are we calling click live Quiz?
			classroomComp.clickLiveQuiz();
		}
		if (classroomComp.pollingFlag) {
			//RGCR: Why are we calling click polling?
			classroomComp.pollingObj.clickPollingQuiz();
		}
		if (classroomComp.Classroom_canvas) {
			classroomComp.Classroom_canvas.visible=true;
		}
		//RGCR: What if the classroomComponentSgl is null?
		if (classroomComp.classroomComponentSgl) {
			classroomComp.classroomContainer.addChild(classroomComp.classroomComponentSgl);
			classroomComp.classroomComponentSgl.visible=true;
			if (!classroomComp.Classroom_canvas.getChildByName("btnResize")) {
				classroomComp.Classroom_canvas.addChild(classroomComp.btnResize);
			}
		}
		applicationType::web {
			//Bug fix for issue #8091
			if (classroomComp.viewer3DLoaded) {
				classroomComp.viewer3DComp.enable3DScene();
			}
		}
		applicationType::desktop {
			//Fix for Bug#17735:Start
			if (classroomComp.viewer3DLoaded) 
			{
				classroomComp.viewer3DComp.enable3DScene();
			}
			//Fix for Bug#17735:End
		}
	}

	if (ClassroomContext.classStartedFlag == false) {
		var cam_select_log:Boolean;
		lectureNoticeBoard();
	} else {
		//Fix for Bug#17644:Start
		if(lectureNotice_Can != null)
		{
			lectureNotice_Can.stopSessionRetrievalTimer();
			//lectureNotice_Can = null;
		}
		//Fix for Bug#17644:End
		gettingToClass();
	}
	applicationType::web {
		closePlaybackPopUpWindow();
	}
	if (Log.isDebug()) 		FlexGlobals.topLevelApplication.mainApp.log.debug(ClassroomContext.classStartedFlag + "");
}

//RGCR: Why can't we just hide the classroomComp and disable 3d for cpu reasons alone. Why do we have to remove children etc?
private function hideClassroomComp():void {
	if (classroomComp) {
		//Fix for Bug#17735:Start
		if(classroomComp.viewer3DComp)
		{
			classroomComp.viewer3DComp.disable3DScene();
		}
		//Fix for Bug#17735:End
		try {
			classroomComp.lstUsers.userGrid.selectedIndex=-1;
		} 
		catch (err:Error) {
			if(Log.isError()) log.error("Error in hideClassroomComp method:"+ err.getStackTrace());
		}
		if (classroomComp.Classroom_canvas != null) {
			classroomComp.Classroom_canvas.visible=false;
		}
		if (classroomComp.classroomComponentSgl) {
			classroomComp.classroomComponentSgl.visible=false;
		}
	}
}


//This function is used for enable/disable the main window buttons based on the button selection.
//RGCR: No need of the boolean value parameter
public function enableDisableMainWindowButtons(buttonID:String, value:Boolean):void {
	//RGCR: The whole below code can be replaced with below block
	/*
	btnClassroom.enabled = (buttonID != "btnClassroom");
	btnLibrary.enabled = (buttonID != "btnLibrary");
	btnQuiz.enabled = (buttonID != "btnQuiz");
	btnBiometric.enabled = (buttonID != "btnBiometric");
	btnAdministrator.enabled = (buttonID != "btnAdministrator");
	btnbugreport.enabled = (buttonID != "btnbugreport");

	VirtualClass=(buttonID != "btnClassroom")?VirtualClass_unclicked:VirtualClass_clicked;
	LibraryIcon=(buttonID != "btnLibrary")?Library_unclicked:Library_clicked;
	QuizIcon = (buttonID != "btnQuiz")?Quiz_unclicked:Quiz_clicked;
	BiometricIcon=(buttonID != "btnBiometric")?Biometric_unclicked:Biometric_clicked;
	AdministrationIcon=(buttonID != "btnAdministrator")?Administration_unclicked:Administration_clicked;
	Feedback_icon=(buttonID != "btnbugreport")?feedback_unclicked:feedback_clicked;
	*/

	switch (buttonID) {
		case "btnClassroom":  {
			btnClassroom.enabled=!value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=value;
			//btnbugreport.enabled=value;
			//btnHelpContents.enabled=value;
			//btnContacts.enabled=value;
			
			VirtualClass=VirtualClass_clicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_unclicked;
			EvaluationIcon=Quiz_unclicked;
			BiometricIcon=Biometric_unclicked;
			AdministrationIcon=Administration_unclicked;
			PreferenceIcon=Preference_unclicked;
			Feedback_icon=feedback_unclicked;
			MeetingIcon=Meeting_unclicked;
			break;
		}
		case "btnContacts":  {
			btnClassroom.enabled=value;
			btnContacts.enabled=!value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=value;
		//	btnbugreport.enabled=value;
			//btnHelpContents.enabled=value;
			
			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_clicked
			LibraryIcon=Library_unclicked;
			EvaluationIcon=Quiz_unclicked;
			BiometricIcon=Biometric_unclicked;
			AdministrationIcon=Administration_unclicked;
			PreferenceIcon=Preference_unclicked;
			Feedback_icon=feedback_unclicked;
			break;
		}
		case "btnLibrary":  {
			btnClassroom.enabled=value;
			btnLibrary.enabled=!value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=value;
			//btnbugreport.enabled=value;
			//btnHelpContents.enabled=value;
			btnContacts.enabled=value;
		//	btnChatHistory.enabled=value;

			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_clicked;
			EvaluationIcon=Quiz_unclicked;
			BiometricIcon=Biometric_unclicked;
			AdministrationIcon=Administration_unclicked;
			PreferenceIcon=Preference_unclicked;
			Feedback_icon=feedback_unclicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			break;
		}
		case "btnBiometric":  {
			btnClassroom.enabled=value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=!value;
			btnAdministrator.enabled=value;
			//btnbugreport.enabled=value;
			//btnHelpContents.enabled=value;
			btnContacts.enabled=value;
			//btnChatHistory.enabled=value;

			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_unclicked;
			EvaluationIcon=Quiz_unclicked;
			BiometricIcon=Biometric_clicked;
			AdministrationIcon=Administration_unclicked;
			Feedback_icon=feedback_unclicked;
			PreferenceIcon=Preference_unclicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			break;
		}
		case "btnAdministrator":  {
			btnClassroom.enabled=value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=!value;
			//btnbugreport.enabled=value;
			//btnHelpContents.enabled=value;
			btnContacts.enabled=value;
			//btnChatHistory.enabled=value;

			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_unclicked;
			EvaluationIcon=Quiz_unclicked;
			BiometricIcon=Biometric_unclicked;
			AdministrationIcon=Administration_clicked;
			PreferenceIcon=Preference_unclicked;
			Feedback_icon=feedback_unclicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			break;
		}
		case "btnbugreport":  {
			btnClassroom.enabled=value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=value;
			//btnbugreport.enabled=!value;
			//btnHelpContents.enabled=value;
			btnContacts.enabled=value;
			//btnChatHistory.enabled=value;

			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_unclicked;
			EvaluationIcon=Quiz_unclicked;
			BiometricIcon=Biometric_unclicked;
			AdministrationIcon=Administration_unclicked;
			PreferenceIcon=Preference_unclicked;
			Feedback_icon=feedback_clicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			break;
		}
		case "Preferences":  {
			break;
		}
		case "btnEvaluation":  {
			btnClassroom.enabled=value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=value;
			//btnbugreport.enabled=value;
			//btnHelpContents.enabled=!value;
			btnContacts.enabled=value;
			//btnChatHistory.enabled=value;

			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_unclicked;
			BiometricIcon=Biometric_unclicked;
			EvaluationIcon=Quiz_clicked;
			Feedback_icon=feedback_unclicked;
			AdministrationIcon=Administration_unclicked;
			PreferenceIcon=Preference_unclicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			break;
		}
		default: //all
		{
			btnClassroom.enabled=value;
			btnLibrary.enabled=value;
			btnEvaluation.enabled=value;
			//btnBiometric.enabled=value;
			btnAdministrator.enabled=value;
			//btnbugreport.enabled=value;
			//btnHelpContents.enabled=value;
			btnContacts.enabled=value;
			//btnChatHistory.enabled=value;

			VirtualClass=VirtualClass_unclicked;
			MeetingIcon=Meeting_unclicked
			LibraryIcon=Library_unclicked;
			BiometricIcon=Biometric_unclicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			EvaluationIcon=Quiz_unclicked;
			LiveQuizIcon=liveQuiz_unclicked;
			pollingIcon=poll_unclicked;
			Feedback_icon=feedback_unclicked;
			AdministrationIcon=Administration_unclicked;
			PreferenceIcon=Preference_unclicked;
			MeetingIcon=Meeting_unclicked;
			chatHistoryIcon=chatHistory_unclicked;
			break;
		}
	}
}

//RGCR: This method should be part of 'ClassroomComponent' and can be called when entering the class
public function initializeClassroomComponent():void {
	classroomComp=new ClassroomComponent;
	classroomComp.init(appEventMap,ClassroomContext.userVO);
	FlexGlobals.topLevelApplication.mainApp.classRoomFlag=true;
	classRoomContainer.addChild(classroomComp);
	if(ClassroomContext.aviewClass.classType=="Meeting")
	{
		contactsManager.addEventListener(EntryFac.END_SESSION,classroomComp.onModeratorEndSession);
	}
}
public function removeEndSessionListener():void
{
	contactsManager.removeEventListener(EntryFac.END_SESSION,classroomComp.onModeratorEndSession);
}
private var cscc:ClassServerChangeConsumer;

public function unSubscribeClassServerChangeConsumer():void {
	if (cscc)
		cscc.unSubscribeConsumer();
}

public function connectToCollaborationServer(isFirstTime : Boolean = true) : void
{
	//Fix for Bug#18497
	classroomComp.createUsersConnection(isFirstTime);
	//Fix for Bug#18497	
}


/**
 * The function is used to enter into a classroom once a lecture is selected.
 * It sets the various buttons and states.It initializes various components
 * like video,chat and document sharing.
 *
 *
 * @return void
 */
/* This function checks whether a classroom is selected. If not then get classroom option.
It sets various buttons and states. It initializes various components like chat,video , whiteboard and document sharing
according to whether single window or multiple window mode is selected. */
//RGCR: This method should be part of ClassroomComponent
public function gettingToClass():void {
	//Messaging client to watch for sever changes and switch connections
	//Fix for bug # 19598 start
	//Checking for null before initializing. This is to avoid un necessary creation 
	//of object multiple times, when user navigates to a different screen and come back
	classEntryCheck=true;
	if(cscc == null)
	{
		cscc=new ClassServerChangeConsumer();
	}
	cscc.subscribeConsumer();
	//Fix for issue #20102
	applicationType::DesktopMobile{
		//Fix for bug # 19598 end
		contactsManager.removeEventListener(EntryFac.END_SESSION, refreshNoticeBoard);
	}
	applicationType::web{
		if(contactsManager){
			contactsManager.removeEventListener(EntryFac.END_SESSION, refreshNoticeBoard);
		}
	}
	applicationType::web {
		//Check if ExternalInterface is available or not to call/callBack javascript function
		if (ExternalInterface.available) {
			//Call javascript function to check whether Java is enabled or not
			ExternalInterface.call("checkJavaPlugin");
			//callback to add the video back in video panel in the main app
			ExternalInterface.addCallback('addUserVideo', classroomComp.popOutCloseHandler);
			//callback to get the fullscreen video close details
			ExternalInterface.addCallback('getStreamClose', classroomComp.updateVideoFullscreenLSO);
			//callback to create selected viewer fullscreen array
			ExternalInterface.addCallback("getFullScreenStream",classroomComp.createSelectedViewerFullScreenArray);
			//callback to upadte selected viewer fullscreen array details
			ExternalInterface.addCallback('getLSOValues', classroomComp.getLSOStatus);
			//callback from javascript function when user resizes the browser window
			ExternalInterface.addCallback('resizeApplication',classroomComp.resizeLocalVideo);
			//Callback from javascript function when user close the browser.
			//Fix for issue #17775
			ExternalInterface.addCallback('closeApplication',webAppCloseHandler);
			//Callback from javascript function when popout window is getting loaded.
			ExternalInterface.addCallback('popoutLoadedMessage',classroomComp.getValueFromPopOutWindow);
			//Fix for issue #19163
			ExternalInterface.addCallback('closeBandwidth', closeBandwidthWindow);
			//For Guest Login: Call javascript function to set logged in user is guest or not
			if (ClassroomContext.userVO.role == Strings.GUEST_TYPE) {
				ExternalInterface.call("guestUser", true);
			} else //Normal users
			{
				ExternalInterface.call("guestUser", false);
			}
			//Fix for issue #20122
			if(FlexGlobals.topLevelApplication.mainApp.ssoMode == Strings.classEntry){
				ExternalInterface.call("directClassEntry", true);
			}
		}
	}
	bugreportFormSpeedTestEnable=true;
	/** Creating an instance of RecordingAview to handle recording related functions. */
	if (classroomComp.recorder == null) {
		classroomComp.recorder=new Recorder();
	}
	//Setting the logo based on the institute which is offering the course
	setBranding(ClassroomContext.institute);
	//CRSM:API
	if(classroomComp.chatComp)
	{
		classroomComp.chatComp.addEventListener(ChatStatusEvent.CHAT_RECEIVED, classroomComp.blinkChat);
	}
	
	applicationType::web {
		//For Guest Login: To avoid null reference issue when the user is a guest.
		//For guest users, stage may not be initialized at this moment, hence PTT keyboard shortcuts won't work.
		if (stage) {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, classroomComp.keyDown_track);
		}
	}
	applicationType::desktop {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, classroomComp.keyDown_track);
	}
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) {
		//Admin's can re-enter the class room list
		btnClassroom.enabled=true;
		//Fix for bug # 19598 start
		//Checking for null before initializing. This is to avoid un necessary creation 
		//of object multiple times, when user navigates to a different screen and come back
		if(adminConsoleInst == null)
		{
			adminConsoleInst=new AdminConsole;
		}
		//Fix for bug # 19598 end
		Homepage.addChild(adminConsoleInst);
		//Fix for bug # 19598 start
		//Initialization and connecting to fms server is needed only once
		if(classroomComp.isFirstTime)
		{
			classroomComp.isFirstTime = false;
			classroomComp.initialiseSingleWindow();
			connectToCollaborationServer();
			AuditContext.lecture.auditLectureEntry();
			classroomComp.createUserList();
		}
		//Fix for bug # 19598 end		
	} else {
		//CRJH: Seems like not used
		/* if (!selectedOption)//single window
		{
		getClassroomOption();
		} */
		FlexGlobals.topLevelApplication.mainApp.checkStudentBWLimit();

		VirtualClass=VirtualClass_clicked;
		LibraryIcon=Library_unclicked;
		BiometricIcon=Biometric_unclicked;
		Feedback_icon=feedback_unclicked;
		AdministrationIcon=Administration_unclicked;
		PreferenceIcon=Preference_unclicked;
		quickNoteIcon=quickNoteIcon_UnClicked;
		VideoIcon=Video_clicked;
		chatHistoryIcon=chatHistory_unclicked;

		maincontrolbar.selectedChild=classRoomContainer;
		quickNoteIcon=quickNoteIcon_UnClicked;
		if (classroomComp.isFirstTime) 
		{
			classroomComp.isFirstTime=false;

			if (this.getChildByName("labelMsg"))
				this.removeElement(labelMsg);

			if (ClassroomContext.aviewClass.classType == "Meeting") {
				classroomComp.videoServersData=slicingVideoServerData();
			}
			else if (lectureNotice_Can != null) 
			{
				//classroomComp.videoServersData=new SessionEntry().slicingVideoServerData();
				classroomComp.videoServersData = lectureNotice_Can.sessionEntry.slicingVideoServerData();
			}
			classroomComp.createVideoConnection(classroomComp.videoServersData);
			classroomComp.initialiseSingleWindow();
			classroomComp.createLayoutComponents();
			//Fix for issue #200102
			applicationType::DesktopMobile{
				classroomComp.contactModuleRO=this.contactsManager.getContactsModuleRO();
			}
			applicationType::web{
				if(FlexGlobals.topLevelApplication.mainApp.ssoMode==Strings.classEntry){
					createContactsManager();
				}
				classroomComp.contactModuleRO=this.contactsManager.getContactsModuleRO();
			}
			classroomComp.adminInitialise();
			AuditContext.lecture.auditLectureEntry();

			classroomComp.userSoSyncStatus="NotSynced";
			connectToCollaborationServer();
			classroomComp.initModules();
			classroomComp.createUserList();

			//CRJH_Ashish: Seems like this code is not needed now since pnlTeacher is not visible initially
			/*if (classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE)
			{*/
				if (classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) 
				{
					classroomComp.classroomComponentSgl.pnlTeacher.maxWidth=0;
					classroomComp.classroomComponentSgl.pnlTeacher.maxHeight=0;
					classroomComp.classroomComponentSgl.pnlTeacher.includeInLayout=false;
				} 
				else
				{
					classroomComp.classroomComponentSgl.pnlTeacher.btnFreeTalk.visible=false;
					classroomComp.classroomComponentSgl.pnlTeacher.btnFreeTalk.includeInLayout=false;
					if (classroomComp.classroomComponentSgl.pnlTeacher.widthChangeWatcher == null) 
					{
						classroomComp.classroomComponentSgl.pnlTeacher.widthChangeWatcher=BindingUtils.bindSetter(classroomComp.classroomComponentSgl.pnlTeacher.setHeight, classroomComp.classroomComponentSgl.pnlTeacher, "width");
					}
				}
			/*} else {
				classroomComp.classroomComponentSgl.pnlTeacher.btnFreeTalk.visible=false;
				classroomComp.classroomComponentSgl.pnlTeacher.btnFreeTalk.includeInLayout=false;
				if (classroomComp.classroomComponentSgl.pnlTeacher.widthChangeWatcher == null) {
					classroomComp.classroomComponentSgl.pnlTeacher.widthChangeWatcher=BindingUtils.bindSetter(classroomComp.classroomComponentSgl.pnlTeacher.setHeight, classroomComp.classroomComponentSgl.pnlTeacher, "width");
				}
			}*/
			

			applicationType::desktop
			{
				FlexGlobals.topLevelApplication.addEventListener(Event.CLOSING, classroomComp.closingApplication);
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.imgMultiViewer=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multiVideoWall;
			
		}
		else
		{
			VideoIcon=Video_unclicked;
		}
		if (ClassroomContext.aviewClass.maxViewerInteraction == 1) {
			classroomComp.chkBoxMultiUserInteraction.enabled=false
		}
		if ((Capabilities.os.toLowerCase().indexOf("mac") > -1 || AVCEnvironment.runTime == AVCEnvironment.BROWSER) && ClassroomContext.aviewClass.videoCodec == "VP6") {
			Alert.show("Current video compression setting is Low Bandwidth, which is not supported in web version. Kindly use desktop version or contact your A-VIEW Institute Administrator to change the video compression setting. You can use this version to listening/monitoring the session.", "WARNING");
		}
	}

	//modified for webinar					
	if (ClassroomContext.aviewClass.classType == Constants.CLASS_TYPE_WEBINAR) {
		classroomComp.classroomComponentSgl.btnRecord.enabled=false;
		classroomComp.classroomComponentSgl.btnRefresh.enabled=false;
		classroomComp.classroomComponentSgl.docBox.enabled=false;
		classroomComp.classroomComponentSgl.classOptionButtons.enabled=false;
		classroomComp.actionButtons.enabled=false;
		classroomComp.classroomComponentSgl.btnRecord.visible=false;
		classroomComp.classroomComponentSgl.btnRefresh.visible=false;
		classroomComp.classroomComponentSgl.docBox.visible=false;
		classroomComp.classroomComponentSgl.classOptionButtons.visible=false;
		classroomComp.classroomComponentSgl.btnRecord.includeInLayout=false;
		//classroomComp.lstUsers.releaseAllSingle.visible=false;
		classroomComp.classroomComponentSgl.btnLocalVideo.visible=false;
	}
	//Activate snapshot feature
	try {
		if(Log.isError()) log.error("gettingToClass():canMonitor:"+ClassroomContext.aviewClass.canMonitor+",monitorIntervalFreq:"+ClassroomContext.aviewClass.monitorIntervalFreq+",EnablePhotoCapture="+ ClassroomContext.SYSTEM_PARAMETERS["EnablePhotoCapture"]+",photoCaptureFrequencySecs:"+ClassroomContext.userVO.photoCaptureFrequencySecs);
		//if (ClassroomContext.SYSTEM_PARAMETERS["EnablePhotoCapture"] == "Yes" && ClassroomContext.userVO.photoCaptureFrequencySecs > 0 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj == null) {
		if (ClassroomContext.aviewClass.canMonitor == "Yes" && ClassroomContext.aviewClass.monitorIntervalFreq > 0 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.snapshotObj == null) {
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.createSnapshotComp();
		}
		if (ClassroomContext.aviewClass.classType == "Meeting") {
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.chkBoxMultiUserInteraction.enabled=true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.chkBoxMultiUserInteraction.selected=true;

		}
	} 
	catch (er:Error) {
		if(Log.isError()) log.error("Error in gettingToClass method:"+ er.getStackTrace());
	}
}
//Fix for issue #17775
applicationType::web{
	private function webAppCloseHandler():void{	
		if (classroomComp) {
			classroomComp.exitContext="close";
			classroomComp.processExitClassroom();
		}
	}
}
/**
 * The function is used to create an instance of LectureNoticeBoard component
 * and adds it to the Homepage canvas.
 *
 *
 * @return void
 */
// The function is used to create an instance of LectureNoticeBoard component and adds it to the Homepage canvas.
private function lectureNoticeBoard():void {
	//Setting the logo based on the institute to which the user belongs to
	setBranding(ClassroomContext.userInstituteVO);
	
	if(lectureNotice_Can == null)
	{
		lectureNotice_Can=new LectureNoticeBoard();
	}
	
	lectureNotice_Can.getTodaysLectures();
	
	Homepage.addChild(lectureNotice_Can);
	
	lectureNotice_Can.registerApplicationEvents(appEventMap);
	//Fix for issue #20102
	applicationType::DesktopMobile{
		contactsManager.addEventListener(EntryFac.END_SESSION,refreshNoticeBoard);
	}
	applicationType::web{
		if(contactsManager){
			contactsManager.addEventListener(EntryFac.END_SESSION,refreshNoticeBoard);
		}
	}
	
}
private function refreshNoticeBoard(event:Event):void
{
	
	setTimeout(lectureNotice_Can.getTodaysLectures,1000);
	
}
public function slicingVideoServerData():ArrayCollection {
	var videoServersData:ArrayCollection=new ArrayCollection();
	videoServersData.removeAll();
	for (var i:int=0; i < ClassroomContext.aviewClass.classServers.length; i++) {
		var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClass.classServers.getItemAt(i));
		var tempObject:Object=new Object();
		if (classServer.serverTypeName == Constants.MEETING_FMS_PRESENTER || classServer.serverTypeName == Constants.MEETING_FMS_VIEWER) {
			tempObject.ip=classServer.server.serverIp;
			tempObject.serverCategory=classServer.server.serverCategory;
			tempObject.serverType=classServer.serverTypeName;
			tempObject.portNumber=classServer.serverPort;
			tempObject.bandWidth=classServer.presenterPublishingBandwidthKbps;
			videoServersData.addItem(tempObject);
		}
	}
	var sort:mx.collections.Sort=new mx.collections.Sort();
	sort.fields=[new mx.collections.SortField("serverType", true), new mx.collections.SortField("bandWidth", true, false, true)];
	videoServersData.sort=sort;
	videoServersData.refresh();
	return videoServersData;
	//Alert.show(videoServersData[0].serverType+videoServersData[0].bandWidth+videoServersData[1].serverType+videoServersData[1].bandWidth+videoServersData[2].serverType+videoServersData[2].bandWidth+videoServersData[3].serverType+videoServersData[3].bandWidth);
}

public function setBranding(institute:InstituteVO):void {
	if (institute.instituteBrandings == null || institute.instituteBrandings.length == 0) {
		if (FlexGlobals.topLevelApplication.mainApp.Aviewbanner.source != defaultBanner) {
			FlexGlobals.topLevelApplication.mainApp.Aviewbanner.source=defaultBanner;
		}
		return;
	}
	var brandinglocation:String=encodeURI("http://" + ClassroomContext.DATABASE_SERVER + "/InstituteBrandings/" + institute.instituteId + "/");
	var instituteBranding:InstituteBrandingVO=null;
	for (var i:int=0; i < institute.instituteBrandings.length; i++) {
		instituteBranding=institute.instituteBrandings.getItemAt(i) as InstituteBrandingVO;
		if (instituteBranding.brandingAttribute.brandingAttributeName == BrandingAttributeVO.LOGO) {
			FlexGlobals.topLevelApplication.mainApp.Aviewbanner.source=brandinglocation + instituteBranding.brandingAttributeValue;
		} else if (instituteBranding.brandingAttribute.brandingAttributeName == BrandingAttributeVO.STYLE_SHEET) {
			styleURL=brandinglocation + instituteBranding.brandingAttributeValue;
			setBrandingStyles();
		}
	}
}

public function setBrandingStyles():void {
	var urlRequest:URLRequest=new URLRequest(styleURL);
	var urlLoader:URLLoader=new URLLoader();
	urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
	urlLoader.addEventListener(Event.COMPLETE, bytesLoadedHandler);
	urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errHandler);
	urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errHandler);
	urlLoader.load(urlRequest);
}

public function bytesLoadedHandler(event:Event):void {
	var urlLoader:URLLoader=URLLoader(event.target);
	var styleModuleBytes:ByteArray=ByteArray(urlLoader.data);
	var module:IModuleInfo=ModuleManager.getModule(styleURL);
	module.addEventListener(ModuleEvent.READY, modReadyHandler);
	module.addEventListener(ModuleEvent.ERROR, errHandler);
	module.load(null, null, styleModuleBytes);
}

private function modReadyHandler(event:ModuleEvent):void {
	ModuleManager.getModule(styleURL).factory.create();
	var myStyleManager:IStyleManager2=StyleManager.getStyleManager(this.moduleFactory);
	myStyleManager.loadStyleDeclarations2(styleURL);
	myStyleManager.styleDeclarationsChanged();
}

private function errHandler(event:Event):void {
	if (event is ModuleEvent) {
		this.dispatchEvent(event.clone());
	} else if (event is ErrorEvent) {
		this.dispatchEvent(new ModuleEvent(ModuleEvent.ERROR, false, false, 0, 0, ErrorEvent(event).text));
	} else if (event is ProgressEvent) {
		this.dispatchEvent(new ModuleEvent(ModuleEvent.ERROR, false, false, 0, 0, ErrorEvent(event).text));
	}
}

/**
 * The function is used to open a site on clicking
 * contact us link in home page.
 *
 *
 * @return void
 */
// This fucntion opens the amrita website on clicking the link.
public function contactus():void {
	var x:String=encodeURI("http://amrita.edu/");
	var url1:URLRequest=new URLRequest(x);
	navigateToURL(url1, "_blank");
}

//*********************************Close***************************

public function logoutHandler():void {
	if (meetingStarted) {
		//closeMeeting();
		if (isNormalExit) {
			isNormalExit=false;
			displayExitAppMsg("Please wait while the application is closing..");
			setTimeout(FlexGlobals.topLevelApplication.mainApp.closeApp, 1500);
			contactsManager.removeEventListener(EntryFac.END_SESSION, refreshNoticeBoard);
		}
	}
	if(lectureNotice_Can && Homepage.contains(lectureNotice_Can))
		Homepage.removeChild(lectureNotice_Can);
	closePlaybackWindows();
	applicationType::web {
		closePlaybackPopUpWindow();
	}
	//					//Logout time is set on the server side.
	//					AuditContext.login.updateAuditUserLogin(AuditContext.userLoginVO);
	//					ClassroomContext.resetUserContextValues();
	closeQuickNote();
}


private function displayExitAppMsg(msg:String):void {
	labelMsg=new spark.components.Label();
	labelMsg.text=msg;
	this.addChild(labelMsg);

	labelMsg.setStyle("fontSize", "20")
	//setChildIndex(labelMsg, numChildren - 1);
	labelMsg.verticalCenter=0;
	labelMsg.horizontalCenter=0;
	this.enabled=false;
}

private function closePlaybackWindows():void {
	if (lmsInst.playBackActiveflag != 0) {
		//Fix for issue #19317
		applicationType::web
		{	
			lmsInst.player.playerComp.closePlayback();
		}
		applicationType::desktop {
			if (lmsInst.recordedLecturesDataGrid.selectedItem.PLAYER != "OLD") {
				lmsInst.player.close();
			}
	 		else {
				lmsInst.design_LMS.close();
			}
		}
	}
	if (lmsInst.editingActiveflag == 1) {
		//close() method not available for web
		applicationType::desktop {
			//lmsInst.videoEditor.onCuttingWindowCloseEvent();
			lmsInst.videoEditor.close();
		}
	}

}

//for showing the feedbackform
public function showFeedbackForm():void {
	//CRJH: API (done: JH) - not needed
	/*feedback=new FeedbackForm();*/
	if(feedback==null)
		feedback = entryFac.feedbackForm();
	feedback.context='';
	isPopupFeedbackForm=true;
	txtOverAllRatingStatus=false;
	txtAudioRatingStatus=false;
	txtVideoRatingStatus=false;
	txtDeskRatingStatus=false;
	txtDocRatingStatus=false;
	txtInteractionRatingStatus=false;
	txtWBRatingStatus=false;
	txtUIRatingStatus=false;
	overAll='';
	videoRate='';
	audioRate='';
	uiRate='';
	wbRate='';
	deskRate='';
	docRate='';
	interactionRate='';
	Feedback_icon=feedback_clicked;
	PopUpManager.addPopUp(feedback, this, true);
	PopUpManager.centerPopUp(feedback);
}

public function loadQuickNote():void {
	if (!quickNoteOpenFlag) {
		//CRJH: API  (done: JH) - not needed
		if (quickNote == null)
			quickNote=entryFac.quickNoteComponent();

		quickNoteIcon=quickNoteIcon_Clicked;
		quickNoteOpenFlag=true;
		PopUpManager.addPopUp(quickNote, this, false);
		PopUpManager.centerPopUp(quickNote);
	} else {
		applicationType::desktop {
			//For Web:activate() method is not available for web
			if (quickNote && quickNote.popOut) {
				quickNote.popOut.activate();
			}
		}
	}
}

public function closeQuickNote():void {
	if (quickNote) {
		quickNoteOpenFlag=false;
		quickNoteIcon=quickNoteIcon_UnClicked;
		//quickNote.isMainAppClosed=true;
		applicationType::desktop {
			//close() method is not available for web
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.popOut) {
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.popOut.nativeWindow.close();
			}
		}
		quicknoteMenuContainer.backgroundFill = normalBackground;
		lblQuickNote.setStyle("color",0x12548E);
		PopUpManager.removePopUp(quickNote);
		quickNote=null;
	}
}

//////////////////////////

private function mainComponent_creationCompleteHandler(event:FlexEvent):void {
	prepareUserDetails();
	//Fix for issue #20102
	applicationType::DesktopMobile{
		createContactsManager();
		navigation('btnClassroom');
	}
	applicationType::web{
		if(FlexGlobals.topLevelApplication.mainApp.ssoMode!=Strings.classEntry){
			createContactsManager();
			navigation('btnClassroom');
		}
	}
	this.addEventListener(ResizeEvent.RESIZE,resizeHandler);
}
protected function resizeHandler(event:ResizeEvent):void
{
	quickNote.quickNoteMoveHandler(event);
	
}
/**
 * This function has moved form users.as to here
 * for the purpose of accessing the details to entire application
 *
 * **/
public function prepareUserDetails():void {
	//ClassroomContext.userDetails=new Object();

	ClassroomContext.userDetails.operatingSystem=Capabilities.os;
	ClassroomContext.userDetails.playerVersion=Capabilities.version;
	applicationType::web {
		//Native application property is not available for web.So we use Capabilities.version
		ClassroomContext.userDetails.airVersion=Capabilities.version;
	}
	applicationType::desktop {
		ClassroomContext.userDetails.airVersion=NativeApplication.nativeApplication.runtimeVersion;
	}
	ClassroomContext.userDetails.screenResolution=Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY;
	ClassroomContext.userDetails.pixelAspectRatio=Capabilities.pixelAspectRatio;
	ClassroomContext.userDetails.AVIEW_VERSION=MainApp.AVIEW_VERSION;
	ClassroomContext.userDetails.maxLevelIDC=Capabilities.maxLevelIDC;
	ClassroomContext.userDetails.cpuArchitecture=Capabilities.cpuArchitecture;
	ClassroomContext.userDetails.supports64Bit=Capabilities.supports64BitProcesses;
	ClassroomContext.userDetails.avHardware=Capabilities.avHardwareDisable;
	ClassroomContext.userDetails.localFileRead=Capabilities.localFileReadDisable;


}




//For new exit option
public function showExitMenu(event:MouseEvent=null):void {
	if (!profileMenu) {
		profileMenu=new profileMenuComponent();
		profileMenu.right=5;
		profileMenu.top=hBoxProfileContainer.top + hBoxWelcomeMsgContainer.height + 5;
		this.addElement(profileMenu);
	}
}

/**
 *  This function is used to close play-back pop up windows (chat and Video) when user navigates to another tab
 * (Virtual classroom, Setup, Face registration etc..).
 *
 *
 * @return void
 *
 * **/
applicationType::web {
	private function closePlaybackPopUpWindow():void {
		//Fix for issue #19317
		if(lmsInst && lmsInst.player && lmsInst.player.playerComp){
			if(lmsInst.player.playerComp.stopButton.enabled)
			{
				lmsInst.player.playerComp.stopPalayBack();
			}
			lmsInst.player.playerComp.stopButton.enabled=true;
			lmsInst.player.playerComp.visible = false;
			if(lmsInst.player.playerComp.presenterVid)
			{
				lmsInst.player.playerComp.presenterVid.visible = false;
			}
			if(lmsInst.player.playerComp.viewerVid)
			{
				lmsInst.player.playerComp.viewerVid.visible = false;
			}
			if(lmsInst.player.playerComp.chatWndw)
			{
				lmsInst.player.playerComp.chatWndw.visible = false;
			}
		} 
		//Set playback flag to enable Play Video button.
		lmsInst.playBackActiveflag=0;
	}
}

protected function openHelpMenu():void
{
	if(!helpMenuUI)
	{
		helpMenuUI = new HelpMenu();
		helpMenuUI.right=85;
		helpMenuUI.top=bandwidthContainer.top + bandwidthContainer.height + 2;
		//helpMenuUI.top=btnHelpContents.top+btnHelpContents.height+1;
		this.addElement(helpMenuUI);
	}
}

/**
 * This function is used to set availability of java plug-in.
 * @enabled boolean
 * @return void
 *
 * **/
applicationType::web {
	public function setJavaAvailability(enabled:Boolean):void {
		isJavaEnabledFlag=enabled;
	}
}

public function changeBackground(menuName:String):void
{
	switch (menuName)
	{
		case "liveSession":
			liveSessionMenuContainer.backgroundFill = activeBackground;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = normalBackground;
			if(quickNote==null)
				quicknoteMenuContainer.backgroundFill = normalBackground;
			adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0xFFFFFF);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0x12548E);
			if(quickNote==null)
				lblQuickNote.setStyle("color",0x12548E);
			lblAdmin.setStyle("color",0x12548E);
			break;
		case "meeting":
			liveSessionMenuContainer.backgroundFill = normalBackground;
			meetingMenuContainer.backgroundFill = activeBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = normalBackground;
			if(quickNote==null)
				quicknoteMenuContainer.backgroundFill = normalBackground;
			adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0xFFFFFF);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0x12548E);
			if(quickNote==null)
				lblQuickNote.setStyle("color",0x12548E);
			lblAdmin.setStyle("color",0x12548E);
			break;
		case "library":
			liveSessionMenuContainer.backgroundFill = normalBackground;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = activeBackground;
			quizMenuContainer.backgroundFill = normalBackground;
			if(quickNote==null)
				quicknoteMenuContainer.backgroundFill = normalBackground;
			adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0xFFFFFF);
			lblEvaluation.setStyle("color",0x12548E);
			if(quickNote==null)
				lblQuickNote.setStyle("color",0x12548E);
			lblAdmin.setStyle("color",0x12548E);
			break;
		case "evaluation":
			liveSessionMenuContainer.backgroundFill = normalBackground;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = activeBackground;
			if(quickNote==null)
				quicknoteMenuContainer.backgroundFill = normalBackground;
			adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0xFFFFFF);
			if(quickNote==null)
				lblQuickNote.setStyle("color",0x12548E);
			lblAdmin.setStyle("color",0x12548E);
			break;
		case "quicknote":
			/*liveSessionMenuContainer.backgroundFill = normalBackground;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = normalBackground;*/
			quicknoteMenuContainer.backgroundFill = activeBackground;
			/*adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0x12548E);*/
			lblQuickNote.setStyle("color",0xFFFFFF);
			//lblAdmin.setStyle("color",0x12548E);
			break;
		case "help":
			/*liveSessionMenuContainer.backgroundFill = normalBackground;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = normalBackground;*/
			Help.backgroundFill = activeBackground;
			/*adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0x12548E);*/
			lblhelpMenu.setStyle("color",0xFFFFFF);
			//lblAdmin.setStyle("color",0x12548E);
			break;
		case "admin":
			liveSessionMenuContainer.backgroundFill =normalBackground ;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = normalBackground;
			if(quickNote==null)
				quicknoteMenuContainer.backgroundFill = normalBackground;
			adminMenuContainer.backgroundFill = activeBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0x12548E);
			if(quickNote==null)
				lblQuickNote.setStyle("color",0x12548E);
			lblAdmin.setStyle("color",0xFFFFFF);
			break;
		case "bandwidth":
			/*liveSessionMenuContainer.backgroundFill = normalBackground;
			meetingMenuContainer.backgroundFill = normalBackground;
			libraryMenuContainer.backgroundFill = normalBackground;
			quizMenuContainer.backgroundFill = normalBackground;*/
			bandwidthContainer.backgroundFill = activeBackground;
			/*adminMenuContainer.backgroundFill = normalBackground;
			lblLiveSession.setStyle("color",0x12548E);
			lblMeeting.setStyle("color",0x12548E);
			lblLibrary.setStyle("color",0x12548E);
			lblEvaluation.setStyle("color",0x12548E);*/
			lblBandWidth.setStyle("color",0xFFFFFF);
			//lblAdmin.setStyle("color",0x12548E);
			break;
	}
	
}

public function closeBandwidthWindow(event:Event=null):void
{
	bandwidthContainer.backgroundFill = normalBackground;
	lblBandWidth.setStyle("color",0x12548E);
}
public function showBandwidthWindow():void
{	
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp)
	{
		applicationType::desktop{
			checkBandwidth= new Bandwidth();
			PopUpManager.addPopUp(checkBandwidth,this,true);
			PopUpManager.centerPopUp(checkBandwidth);
			checkBandwidth.setFocus();
		}
		//Fix for issue #16794
		applicationType::web{
			//Fix for issue #18215
			//If single server is used for both content and streaming, then web server would be listening on 80, otherwise on 8080
			var contentServerPort:Number=(ClassroomContext.CONTENT_DOCUMENT == ClassroomContext.VIDEO_RECORD_SERVER) ? Constants.CONTENT_SERVER_PORT : Constants.CONTENT_SERVER_PORT_FIREWALL;
			var toolTipLnk:String=encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + contentServerPort + "/speedtest/");
			//Fix for issue #17755		
			if (! ExternalInterface.available)
			{
				throw new Error("ExternalInterface is not available in this container. Internet Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other browsers that support NPRuntime are required.");
			}
			ExternalInterface.call("loadIFrame", toolTipLnk);
			ExternalInterface.call("showIFrame");
			moveIFrame();
		}
	}
	else
	{
	
		Alert.show("Please enter the classroom to check the bandwidth","Info",null,null ,closeBandwidthWindow);

	}
}
applicationType::web{
	public function moveIFrame(): void
	{		
		var localPt:Point = new Point(0, 0);
		var globalPt:Point = this.localToGlobal(localPt);
		
		ExternalInterface.call("moveIFrame", globalPt.x, 0, 400, 300);
	}
}

private function showHideMainMenu():void
{
	menuIconContainer.percentWidth=100;
	if(menuIconContainer.height==44)
	{
		/*hideMenuBar.play();
		showMenuBar.stop();*/
		menuIconContainer.height=0;
		rotateHideIcon.play();
		rotateShowIcon.stop();
		
	}
	else
	{
		/*showMenuBar.play();
		hideMenuBar.stop();*/
		menuIconContainer.height=44;
		rotateShowIcon.play();
		rotateHideIcon.stop();
	}
}
}