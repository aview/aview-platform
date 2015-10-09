import edu.amrita.aview.core.documentSharing.DocComponent;
import edu.amrita.aview.core.entry.ClassRoomSgl;
import edu.amrita.aview.core.entry.ClassroomComponent;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.login.ExitPopupMenu;
import edu.amrita.aview.core.login.MainApp;
import edu.amrita.aview.core.playback.components.DocComp;

import flash.geom.Point;

applicationType::DesktopWeb {
	import edu.amrita.aview.core.entry.AVCEnvironment;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.login.boilerplate.Strings;
	import edu.amrita.aview.core.entry.ForgotPassword;
	import edu.amrita.aview.core.entry.MainComponent;
	import edu.amrita.aview.core.login.PrepareLogin;
	import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
	import edu.amrita.aview.core.login.boilerplate.events.LoginStatusEvent;
	import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
	import edu.amrita.aview.core.gclm.helper.LectureHelper;
	import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
	import edu.amrita.aview.core.gclm.vo.LectureListVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.playback.AviewPlayer;
	import edu.amrita.aview.core.shared.audit.AuditContext;
	import edu.amrita.aview.core.shared.components.Captcha;
	import edu.amrita.aview.core.shared.components.CaptchaComponent;
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
	import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
	import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.shared.log.LogUtil;
	import edu.amrita.aview.core.shared.vo.AViewResponseVO;
	import edu.amrita.aview.core.userPreference.RemoteServerPreferenceFac;
	import flash.display.BitmapData;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.media.scanHardware;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.graphics.codec.PNGEncoder;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.Base64Encoder;
	import objectResolver.EntryFac;
	import spark.components.TitleWindow;
	/**Platform specific imports*/
	applicationType::desktop {
		import spark.components.WindowedApplication;
		import flash.events.NativeWindowDisplayStateEvent;
		import edu.amrita.aview.core.playback.AviewPlayerDesktop;
		import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
		import flash.desktop.NativeApplication;
	}
	/** Variable declaration */
	[Bindable]
	public var scanHardwareEnableFlag:Boolean=false;
	applicationType::DesktopWeb {
		public var mainContainerComp:MainComponent;
	}
	/** Array to store login type */
	[Bindable]
	public var loginTypearr:Array=new Array("Normal", "Face Recognition");
	[Bindable]
	public var loginServerTypearr:ArrayCollection=new ArrayCollection();
	private var serverValues:ArrayCollection=new ArrayCollection();
	/** ArrrayCollection to store server details like ip and name */
	[Bindable]
	public var serversdet:ArrayCollection=new ArrayCollection();
	public var logUtilObj:LogUtil=new LogUtil();
	/**
	 * For Log API
	 */
	public var log:ILogger=Log.getLogger("aview.main");
	private var avcEnvironment:AVCEnvironment=new AVCEnvironment();
	/**
	 * This flag is set to true if the connection is rejected in netStatusHandler method
	 * If this flag is true, then we do not retry the connections */
//CRJH: Seems like this variable is not used
	public var chatConnectionRejected:Boolean=false;
	private var checkInstallationTimeoutId:uint;
	[Bindable]
	private var sql:String; // sql statement to be executed
	[Bindable]
	private var dbresultArray:ArrayCollection=new ArrayCollection; //to store the details of the logged in user
	[Bindable]
	private var tempUsername:String;
	[Bindable]
	private var tempPassword:String;
//Unsigned Integer for setTimeout for invoking centerWindow() 
	private var centerWindowTimeOutID:uint;
	public var load_class:int=0;
	applicationType::DesktopWeb {
		public var faceRegistration;
	}
	/** Array to store window mode */
	[Bindable]
	public var modearr:Array=new Array("Single Window", "Multiple Windows");
	private var loader:URLLoader;
	private var videoFrame:Video=new Video(640, 480);
	private var video:Video=new Video();
	private var camera:Camera;
	public var cameraName:String;
	public var selectionMode:String;
	public var authenticationMode:String=Strings.NORMAL_LOGIN;
	public static var BIOMETRIC_SERVER:String="";
	private var cameraActivation:Boolean=false;
	[Bindable]
	public var config_array:ArrayCollection=new ArrayCollection(); //TODO: not used
	[Bindable]
	public var settingsMenuOpen:Boolean=false;
	[Bindable]
	public var exitMenuclose:Boolean=false;
	public var entryFac:EntryFac=new EntryFac;
	[Bindable]
	private var prepareLogin:PrepareLogin;
	public var docComp:DocComponent=new DocComponent;
	//public var docComp:DocComponent = new DocComponent;
//CRSM : API
	/*private var invitationAlert:InvitationMessage;
	private var invitation:MeetingInvitation*/
	;
	applicationType::DesktopWeb {
		private var mycontacts=entryFac.contactsView;
	}
	private var lectureHelper:LectureHelper;
	private var lectureDetails:LectureListVO; // =new LectureListVO;
	private var classregHelper:ClassRegistrationHelper;
	private var timerInvMsg:Timer;
	public var serverInfo:RemoteServerPreferenceFac;
	
	private var captcha:Captcha=null;
	[Bindable]
	private var alertWindowStatus:Boolean=false;
	private var cameraNames:ArrayCollection;
	private var captchaComp:CaptchaComponent;
	private var userSelectedServer:String;
	private var userSelectedIP:String;
	private var saveTheseServers:ArrayCollection
	private var cursorID:Number=0;
	[Bindable]
	private var exitConfirmWindow:ExitPopupMenu = new ExitPopupMenu();
	private var startTime:Number;
	private var endTime:Number;
	private var notificationTimer:Timer;
	public var SCREEN_CAMERA_DRIVER_NAME:String;
	
	[Bindable]
	[Embed(source="/edu/amrita/aview/core/entry/assets/images/connect.png")]
	public var connectionStatusIcon:Class;
	
	[Bindable]
	[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/videoconnected.png")]
	public var videoConnectionStatusIcon:Class;
	
	[Bindable]
	[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/colabarationconnected.png")]
	public var colabarationConnectionStatusIcon:Class;
	
	[Bindable]
	[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/footer_bg.png")]
	public var footerBG:Class;
	
	
	/**Platform specific variables*/
	applicationType::web {
		/* Added static version number since we don't have app.xml file*/
		//Removed const keyword
		public static var AVIEW_VERSION:String="";
		/* Variable to store server xml version.*/
		public var serverXMLVersion:String;
		/* Variable to store single sign on mode.*/
		public var ssoMode:String="";
		[Bindable]
		public var COPY_RIGHT_FOOTER:String="";
		//Fix for issue #17085
		public var browserName:String="";
	}
	applicationType::desktop {
		public static const AVIEW_VERSION:String=Strings.getAppVersion();
		private var process:NativeProcess;// ashwini todo: can remove after refactoring
		public var updater:NativeApplicationUpdater=null;
		public var windowApp:WindowedApplication=null;
		[Bindable]
		public var COPY_RIGHT_FOOTER:String="A-VIEW (Amrita Virtual Interactive E-Learning World) Version " + AVIEW_VERSION + "; © 2007-2015";
	}
	
	applicationType::web{
		//Fix for issue #17085
		public function getAppVersion(version:String,browser:String):void{
			AVIEW_VERSION = version;
			browserName = browser;
			COPY_RIGHT_FOOTER = "A-VIEW (Amrita Virtual Interactive E-Learning World) Version " + AVIEW_VERSION + "; © 2007-2015";
			//Call this function once we get the application version from index.html
			prepareLogin.createDataServices();
		}
	}
	
	/**
	 * The function handles the maximize event of the application window.
	 *
	 *
	 * @return void
	 */
//The function handles the maximize event
// of the application window and changes 
// the style name of the button accordingly. 
	private function toggleMaximize():void {
		applicationType::desktop {
			if (this.windowApp.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED) {
				this.windowApp.restore();
				maximum_btn.styleName="iconMaximize";
				maximum_btn.toolTip="Maximize window";
			} else {
				this.windowApp.maximize();
				maximum_btn.styleName="iconRestore";
				maximum_btn.toolTip="Restore window size";
			}
		}
	}
	applicationType::desktop {
		private function windowMinimize(event:NativeWindowDisplayStateEvent):void {
			doWindowMinimize(event);
		}
	}

	public function windowActivateAndResizeHandler():void {
		if (mainContainerComp && mainContainerComp.classroomComp) {
			mainContainerComp.classroomComp.changeMyVideoPosision();
		}
	}
	applicationType::DesktopWeb {
		private var feedback;
	}
	[Bindable]
	public var classRoomFlag:Boolean=false;
//	applicationType::DesktopMobile {
//		public static function getAppVersion():String {
//			var appXml:XML=NativeApplication.nativeApplication.applicationDescriptor;
//			var ns:Namespace=appXml.namespace();
//			var appVersion:String=appXml.ns::versionLabel[0];
//			return appVersion;
//		}
//	}


	/**
	 * The function is the CreationCompleteHandler
	 * It is called after creation complete of the app
	 *
	 * @return void
	 */
	public function appCreationCompleteHandler():void {
		FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("mx.managers.CursorManager").setStyle("busyCursor", busyImg);
		prepareLogin = new PrepareLogin(this);
		
		applicationType::web {
			//Retrieve serverXMLVersion from flashvars
			if (FlexGlobals.topLevelApplication.parameters.serverXMLVersion != "") //ServerXMLVersion
			{
				serverXMLVersion=FlexGlobals.topLevelApplication.parameters.serverXMLVersion;
			}
			//For Guest Login
			if (FlexGlobals.topLevelApplication.parameters.lrid != "" && FlexGlobals.topLevelApplication.parameters.uname == "") //lectureID
			{
				ssoMode = Constants.guestLogin;
			}
			else if (FlexGlobals.topLevelApplication.parameters.uname != "" && FlexGlobals.topLevelApplication.parameters.pwd != "" && FlexGlobals.topLevelApplication.parameters.lrid == "") {
				ssoMode=Strings.userLogin;
			}  //SSO - Direct class entry.
			else if (FlexGlobals.topLevelApplication.parameters.uname != "" && FlexGlobals.topLevelApplication.parameters.pwd != "" && FlexGlobals.topLevelApplication.parameters.lrid != "") {
				ssoMode=Strings.classEntry;
			}  // Normal login case or invalid SSO
			else {
				ssoMode="";
				currentState="LoginState";
			}
			lblServerType.visible = false;
			lblServerType.includeInLayout = false;
			cmbServerType.visible = false;
			cmbServerType.includeInLayout = false;
			lblLoginType.top=153;
			//hbxBiometric.top = 153;
			btn_login.top=203;
			btn_ForgotPassword.top=203;
			//Fix for issue #19800
			btn_ForgotPassword.enabled=true;
			//Fix for Bug #15476 start
			//lblPlayOffline.top=203;
			//Fix for Bug #15476 end
			//Fix for flexglobals cleanup in login
			if(ExternalInterface.available)
			{
				Security.allowDomain("*");
				ExternalInterface.call("getApplicationVersion");
				ExternalInterface.addCallback("setApplicationVersion",getAppVersion);
			}
		}
		applicationType::desktop {
			this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, windowMinimize);
			getUpdateServerDetails();
		}
		ClassroomContext.resetClassroomContextValues();
		centerWindow();
		applicationType::DesktopMobile{
			prepareLogin.createDataServices();
		}
		prepareLogin.addEventListener(LoginStatusEvent.LOGIN_SUCCESS, loginSucess);
		prepareLogin.addEventListener(LoginStatusEvent.LOGIN_FAILED, resetUserName);
		prepareLogin.addEventListener(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE, closeApp);
		applicationType::desktop {
			checkInstallationTimeoutId=setTimeout(checkInstallation, 1000);
		}
		//JHCR: Code is not as it is mentioned in the comment, need to check.
		//Since ScanHardware has some issues with Mac and Linux, the flag is set as false for those operating systems
		//Fix for issue #17051
		if (AVCEnvironment.os == AVCEnvironment.WINDOWS) {
			scanHardwareEnableFlag=true;
		} else {
			scanHardwareEnableFlag=false;
		}
		applicationType::web {
			//Call tab/browser close prevent javascript function in main.js file
			if (ExternalInterface.available) {
				ExternalInterface.call("preventWindowClose");
			}
		}
	}

	/**
	 * The function is to make the app centered
	 * It is called from the creationCompleteHandler of the app, appCreationCompleteHandler
	 *
	 * @return void
	 */
	private function centerWindow():void {
		///////// Logic to position the app in the center/////////
		applicationType::desktop {
			var screenBounds:Rectangle=Screen.mainScreen.bounds;
			this.windowApp.nativeWindow.x=Math.floor((screenBounds.width - this.width) / 2);
			this.windowApp.nativeWindow.y=Math.floor((screenBounds.height - this.height) / 2);
			if (centerWindowTimeOutID) {
				clearTimeout(centerWindowTimeOutID);
			}
		}
		applicationType::web {
			loginWin.horizontalCenter=0;
			loginWin.verticalCenter=0;
			loginWin.showCloseButton=false;
		}
	}

	private function startTimer():void
	{
		startTime = new Date().time;
		endTime = new Date().time + Number(10) * 1000;
		if(notificationTimer==null)
			notificationTimer = new Timer(500);
		notificationTimer.addEventListener(TimerEvent.TIMER, onTimerInterval);
		notificationTimer.start();
	}
	
	private function onTimerInterval(event:Event):void{
		var now:Number = new Date().time;
		if(endTime <= now){
			notificationStatusContainer.visible=false;
			notificationTimer.stop();
		}else{
			//countDownTimerDisplay.text = Math.round((endTime - now)/1000).toString();
			notificationTimer.start();
		}
	}
	
	/**
	 * The function is used to read the xml file containing the user details like
	 * username and password.The function is currently not used in AVIEW.
	 * TODO: This function requires some modifications
	 *
	 *
	 * @return void
	 */
	public function getsaveduser_details():void {
		applicationType::desktop {
			var f_userdet:File;
			f_userdet=File.documentsDirectory.resolvePath("A-VIEW/config/UserDetails.xml");
			if (f_userdet.exists) {
				getsaveduserdet.url=f_userdet.url;
				getsaveduserdet.send();
			} else {
				txtLoginUser.setFocus();
			}
		}
		getsaveduserdet.addEventListener(ResultEvent.RESULT, getname_pass);
	}

	/**
	 * The function is an eventhandler to retrive the password of the user,
	 * and autocompletes the password textbox with thre rettieved password.
	 *
	 * The function is currently not used in AVIEW.
	 *
	 * @param event of type ResultEvent.
	 * @return void
	 */
	public function getname_pass(event:ResultEvent):void {
		prepareLogin.userName=getsaveduserdet.lastResult.user.username;
		if (prepareLogin.userName == "") {
			txtLoginUser.setFocus();
		} else {
			applicationType::desktop {
				var storedValue:ByteArray=EncryptedLocalStore.getItem("amma");
				var password:String=storedValue.readUTFBytes(storedValue.length);
				prepareLogin.password=ClassroomContext.userVO.password;
				chk_saveuser.selected=true;
			}
		}
	}

	/**
	 * This function is not used.
	 * TODO: not used
	 * @param event of type FaultEvent.
	 * @return void
	 *
	 */
	public function fautltfun(event:FaultEvent):void {
		if (Log.isError())
			log.error("entry::MainHandler::fautltfun:" + AbstractHelper.getStaticFaultMessage(event));
	}
	private var applicationEventMap:EventMap=new EventMap;

	/**
	 * The function is called during the initializion of the application.
	 * It sets the window count flag of each module to ensure that multiple window
	 * of the same module doesnt get opened during application life cycle.
	 *
	 *
	 * @return void
	 */
//The function is called during the initializion of the application.   
//It sets the window count flag of each module to ensure that multiple window
//of the same module doesnt get opened during application life cycle.	
	public function init():void {
		logUtilObj.initLog();
		var loglevel: int = 8; // ashwini: Error and above; this is set for production value
		if (Constants.LOG_LEVEL >= 0){
			//ashwini: FlexGlobal is the developer override. for development builds, the value is set to 0
			loglevel = Constants.LOG_LEVEL;
		}

		logUtilObj.setLoggingLevel(loglevel);
		applicationType::desktop {
			if (Capabilities.os.toLowerCase().indexOf("win") > -1) {
				getThirdPartySoftwareDetails();
			}
			killAkr();
			findJavaInstallationPath();
			findScreenCameraInstallationPath();
			getScreenCamDriverName();
		}
		initializeServerPreference();
	}
	
	public function getScreenCamDriverName():void
	{
		var osName:String=Capabilities.os.toLowerCase();
		if (osName.indexOf("win") > -1)
		{
			if(parseInt(osName.charAt(osName.length-1))==8)
			{
				SCREEN_CAMERA_DRIVER_NAME = "ScreenCamera Video Camera";
			}
			else
			{
				SCREEN_CAMERA_DRIVER_NAME = "ScreenCamera HR";
			}
			if (Log.isDebug())
				log.debug("getScreenCamDriverName: " + osName+","+SCREEN_CAMERA_DRIVER_NAME);
		}
	}
	private function initializeServerPreference():void {
		serverInfo=new RemoteServerPreferenceFac();
	}

	private function resetFields(event:CloseEvent):void {
		txtLoginPass.setFocus();
	}

	/**
	 * The function sets the application window size,icons,application state, welcome text
	 * and adds custom component homepage to the main canvas of the application.
	 *
	 *
	 * @return void
	 */
// The function sets the application window size,
// icons,application state, welcome text  
// and adds custom component homepage to 
// the main canvas of the application. 
	public function loginSucess(event:LoginStatusEvent):void {
		applicationType::DesktopWeb {
			applicationType::web {
				//Fix for issue #11561
				//Call javascript function to set application size.
				if (ExternalInterface) {
					ExternalInterface.call("setAppSize");
				}
			}
			prepareLogin.userName=null;
			prepareLogin.password=null;
			applicationType::desktop {
				this.windowApp.width=1024;
				this.windowApp.height=768;
				this.windowApp.minHeight=740; // SRS (changed from 768) Bug # 5287 A-VIEW application is occupying the entire screen / monitor including taskbar in the restore mode 
				this.windowApp.minWidth=1024;
			}
			this.currentState="mainapp";
			mainContainerComp=new MainComponent;
			mainContainerComp.appEventMap=applicationEventMap;
			mainComponentContainer.addChild(mainContainerComp);
			//Fix for Bug#11366 : Start
			ClassroomContext.setWelcomeMessage();
			/*var dispName:String;
			var dName:String;
			dispName=ClassroomContext.userVO.userDisplayName;
			if (dispName.length > (Constants.USERLIST_MAX_LEN_MULTI + 3)) {
				dName=dispName.slice(0, Constants.USERLIST_MAX_LEN_MULTI) + "...";
				dispName=dName;
			}
			mainContainerComp.welcomeMsg.text="Welcome " + dispName;
			mainContainerComp.welcomeMsg.toolTip=dispName;*/
			//Fix for Bug#11366 :End
			applicationType::web {
				//SSO - Invoke function to prepare displaying the classroom screen
				if (ssoMode == Strings.classEntry) {
					mainContainerComp.navigation("btnClassroom");
					//Fix for issue #20102
					mainContainerComp.changeBackground( "liveSession");
				} else //Normal login
				{
					mainContainerComp.enableDisableMainWindowButtons("all", true);
				}
			}
			//Added a delay for solving window positioning issue in Mac
			centerWindowTimeOutID=setTimeout(centerWindow, 100);
			// SRS	BEGIN	Bug # 5287 A-VIEW application is occupying the entire screen / monitor including taskbar in the restore mode 		
			applicationType::desktop {
				mainContainerComp.enableDisableMainWindowButtons("all", true);
				var screenBounds:Rectangle=Screen.mainScreen.bounds;
				var bottomPadding:Number=28;
				if (screenBounds.height < 769) {
					this.height=(this.height - bottomPadding);
					this.minHeight=this.height;
				} else {
					this.minHeight=this.minHeight + bottomPadding;
				}
			}
			// SRS	END	Bug # 5287 A-VIEW application is occupying the entire screen / monitor including taskbar in the restore mode
			setUserNameRendererLabelWidth();
			AuditContext.init();
			AuditContext.login.auditLogin(AVIEW_VERSION);
			//Setting the logo based on the institute to which the user belongs to
			mainContainerComp.setBranding(ClassroomContext.userInstituteVO);
		}
	}

//CRJH: Check whether this needs to be moved to any of the components. 
	private function setUserNameRendererLabelWidth():void {
		ClassroomContext.labelWidth=150;
	}

	/**
	 * This function is used to trace connection with the server.
	 *
	 * @param msg of type string
	 * @return void
	 */
//This function is used to trace connection with the server.
//WARNING: This function is not using
//CRJH: Has to be deleted if not used
	private function echoResult(msg:String):void {
		if (Log.isDebug())
			log.debug("echoResult: " + msg + "\n");
		mainContainerComp.classroomComp.Teacher_Info_Box=msg;
		getClassInfo();
	}

	/**
	 * This function is used to trace connection with the server.
	 *
	 * @param event of type Event
	 * @return void
	 */
//This function is used to trace connection with the server.
//WARNING: This function is not using 
//CRJH: Has to be deleted if not used 
	private function echoStatus(event:Event):void {
		if (Log.isDebug())
			log.debug("echoStatus: " + event);
	}

	/**
	 * The function is used to to close all open components and connections
	 * when the application is closed.
	 *
	 *
	 * @return void
	 */
// The function is used to to close
// all open components and connections
// including whiteboard,documents,3DViewer etc.
// when the application is closed.
	public function sessionCloseHandler():void {
		if (this.currentState != "LoginState") {
			logUtilObj.clear();
			mainContainerComp.logoutHandler();
			if (mainContainerComp.classroomComp && !mainContainerComp.classroomComp.classroomExited) {
				mainContainerComp.classroomComp.classroomSessionCloseHandler();
			}
		}
	}

	/**
	 * This function is not used.
	 *
	 *
	 * @return void.
	 */
//CRJH: Not used, using may cause issues since it changes the mode to SingleWindow Mode
	/* private function getClassroomOption():void
	{

	var file:File=File.documentsDirectory.resolvePath("A-View/Config.xml");
	if (!file.exists)
	{
	//TODO: This code should not be here - JH
	//chkMultiWindows.selected=false;
	return;
	}

	loader=new URLLoader(new URLRequest(file.url));
	loader.addEventListener(Event.COMPLETE, onLoadComplete);
	} */
	/**
	 * This function is used to
	 * load single window or multiple window
	 * as selected.
	 *
	 * @param event of type Event.
	 * @return void.
	 */
// This fucntion loads the corresponding window
// whether single or multiple on selection of the mode.
//CRJH: Not used, since the function getClassroomOption() is not used
	/* private function onLoadComplete(event:Event):void
	{

	xml=XML(loader.data);
	loader.close();
	var xmlList:XMLList=xml.descendants("open");
	switch (savedOption)
	{
	case "Single Window":
	default:
	chkMultiWindows.selected=false;
	break;
	case "Multiple Windows":
	chkMultiWindows.selected=true;
	break;

	}

	} */
	public function changeLoginType(event:Event=null):void {
		if (Log.isInfo())
			log.info("Change Login Type:");
		txtLoginUser.setFocus();
		//var loginType:int=event.currentTarget.selectedIndex;
		if (loginTypeCamera.selected == true) {
			authenticationMode=Strings.BIOMETRIC_LOGIN;
			/*var newPopUp:CameraSelectionForm=CameraSelectionForm(PopUpManager.createPopUp(this, CameraSelectionForm, true));
			newPopUp.addEventListener(FlexEvent.REMOVE, popupCloseHandler);
			PopUpManager.centerPopUp(newPopUp);*/
		} else {
			authenticationMode=Strings.NORMAL_LOGIN;
			iconImage.visible=true;
			if (videoDisplay.hasOwnProperty(video) != false)
				videoDisplay.removeChild(video);
			videoDisplay.visible=false;
			videoFrame.attachCamera(null);
			cameraName=null;
			//btnSettings.visible=false;
			resetComponents();
			applicationType::web {
				//For Web:Fix for issue #11896
				cmbServerType.visible=false;
				lblServerType.visible=false;
				cmbServerType.includeInLayout=false;
				lblServerType.includeInLayout=false;
			}
			applicationType::desktop {
				cmbServerType.visible=true;
				lblServerType.visible=true;
				cmbServerType.includeInLayout=true;
				lblServerType.includeInLayout=true;
			}
		}
	}

	/**
	 * This funtion used for check Biometric Login
	 *
	 * @UserVO userVO
	 */
	public function checkBiometricLogin(userVO:UserVO):void {
		if (Log.isDebug())
			log.debug("Check Biometric Login:");
		if (scanHardwareEnableFlag) {
			scanHardware();
		}
		if (Camera.getCamera(cameraName) != null) {
			if (cameraActivation) {
				var bitmapData:BitmapData=new BitmapData(640, 480, true, 0xffffff);
				bitmapData.draw(video);
				var pngenc:PNGEncoder=new PNGEncoder();
				var imageData:ByteArray=pngenc.encode(bitmapData);
				var encoder:Base64Encoder=new Base64Encoder();
				encoder.encodeBytes(imageData);
				var params:Object={ image_data: encoder.flush() };
				httpDataService.url=encodeURI("http://" + BIOMETRIC_SERVER + ":" + ClassroomContext.portWAMP + "/aview/Matcher?userID=" + userVO.userId);
				httpDataService.send(params);
			} else {
				MessageBox.show("Camera is not available.\nPlease check whether the camera is used by another application.", "Device Error", MessageBox.MB_OK, this, resetBiometricLogin);
			}
		} else {
			MessageBox.show("Camera not detected!\nChoose a camera through the Camera Settings.", "Device Error", MessageBox.MB_OK, this, resetBiometricLogin);
		}
	}

	/**
	 * This funtion used for biometric Result Handler
	 *
	 * @ResultEvent event
	 */
	private function biometricResultHandler(event:ResultEvent):void {
		var imageArray:String=event.result.toString();
		var params:Array=imageArray.split("&", 3);
		if (Log.isInfo())
			log.info("Biometric Result Handler::" + params[0]);
		if (params[0] == "Matched Successfully") {
			if (params[1] == ClassroomContext.userVO.userId) {
				videoFrame.attachCamera(null);
				cameraName=null;
				prepareLogin.getAllInitialData();
			} else {
				MessageBox.show("Face verification failed.", "Login Failed", MessageBox.MB_OK, this, resetBiometricLogin);
			}
		} else if (params[0] == "Face detection failed. Try again.") {
			var newPopUp=entryFac.errorReportForm();
			PopUpManager.addPopUp(this, newPopUp, true);
			newPopUp.addEventListener(FlexEvent.REMOVE, guidelinesCloseHandler);
			newPopUp.loadData(params[0], "Match");
			PopUpManager.centerPopUp(newPopUp);
		} else {
			MessageBox.show(params[0], "Login Failed", MessageBox.MB_OK, this, resetBiometricLogin);
		}
	}

	public function guidelinesCloseHandler(event:Event):void {
		txtLoginUser.setFocus();
		prepareLogin.logInButtonState=true;
	}

	/**
	 * This funtion used for biometric Fault Handler
	 *
	 * @ResultEvent event
	 */
	private function biometricFaultHandler(event:FaultEvent):void {
		if (Log.isError())
			log.error("entry::MainHandler::biometricFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
		MessageBox.show(event.fault.faultString, "Error", MessageBox.MB_OK, this, resetBiometricLogin);
	}

	private function resetBiometricLogin(event:MessageBoxEvent):void {
		txtLoginUser.setFocus();
		prepareLogin.userName=null;
	}

	private function resetUserName(event:LoginStatusEvent):void {
		txtLoginUser.setFocus();
		//prepareLogin.userName=null;
		prepareLogin.password=null;
		prepareLogin.logInButtonState=true;
	}

	public function popupCloseHandler(event:Event=null):void {
		if (scanHardwareEnableFlag) {
			scanHardware();
		}
		if (selectionMode == "ok") {
			camera=Camera.getCamera(cameraName);
			if (camera != null) {
				camera.setMode(640, 480, 15, true);
				videoFrame.attachCamera(camera);
				camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
				video=videoFrame;
				video.width=videoDisplay.width;
				video.height=videoDisplay.height;
				videoDisplay.addChild(video);
				videoDisplay.visible=true;
				iconImage.visible=false;
				txtLoginPass.text="";
				//	btnSettings.visible=true;
				txtLoginPass.visible=false;
				lblPassword.visible=false;
				lblLoginType.top=115;
				lblLoginType.right=228;
				//hbxBiometric.top=108;
				//hbxBiometric.right=12;
				lblUserName.right=228;
				txtLoginUser.right=45;
				btn_login.top=210;
				cmbServerType.visible=false;
				lblServerType.visible=false;
				cmbServerType.includeInLayout=false;
				lblServerType.includeInLayout=false;
			} else {
				Alert.show("Please check your camera connection.", "Device Error", Alert.OK, this, resetUserName);
				prepareLogin.loginTypeIndex=0;
				//	btnSettings.visible=false;
				resetComponents();
			}
		} else {
			prepareLogin.loginTypeIndex=0;
			//btnSettings.visible=false;
			selectionMode=null;
			cameraName=null;
			resetComponents();
		}
	}

	public function cameraSettings():void {
// CRAS: TODO: this might be creating a bug for camera??
		var newPopUp=entryFac.cameraSelectionForm();
		PopUpManager.addPopUp(this, newPopUp, true);
		newPopUp.addEventListener(FlexEvent.REMOVE, popupSettingsHandler);
		PopUpManager.centerPopUp(newPopUp);
	}

	public function popupSettingsHandler(event:Event):void {
		if (scanHardwareEnableFlag) {
			scanHardware();
		}
		if (selectionMode == "ok") {
			camera=Camera.getCamera(cameraName);
			if (camera != null) {
				camera.setMode(640, 480, 15, true);
				videoFrame.attachCamera(camera);
				camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
				video=videoFrame;
				video.width=videoDisplay.width;
				video.height=videoDisplay.height;
				videoDisplay.addChild(video);
			} else {
				Alert.show("Please check your camera connection.", "Device Error");
			}
		}
	}

	public function resetComponents():void {
		txtLoginPass.visible=true;
		lblPassword.visible=true;
		applicationType::web {
			lblLoginType.top=155;
			lblLoginType.right=218;
			//hbxBiometric.top=148;
			//hbxBiometric.right=2;
			lblUserName.right=218;
			txtLoginUser.right=35;
			btn_login.top=210;
		}
		applicationType::desktop {
			lblLoginType.top=193;
			lblLoginType.right=218;
			//hbxBiometric.top=190;
			//hbxBiometric.right=2;
			lblUserName.right=218;
			txtLoginUser.right=35;
			btn_login.top=220;
		}
	}

	private function activityHandler(e:ActivityEvent):void {
		cameraActivation=true;
	}
	
	//Fix for Bug #18586
	private function resetPassword(selectedServer:String):void {
		var forgotPasswordWnd:ForgotPassword=new ForgotPassword();
		//Fix for issue #19800
		applicationType::desktop{
			//Fix for Bug #18586
			if(!prepareLogin._validateComboServerEntry(selectedServer))
			{			
				MessageBox.show("Please select the server.", "Login Failed", MessageBox.MB_OK);
				return;
			}
		}
		PopUpManager.addPopUp(forgotPasswordWnd, this, true);
		PopUpManager.centerPopUp(forgotPasswordWnd);
		//CRMerge: TODO: Forgot password change
		//forgotPasswordWnd.lblUserName.setFocus();
	}

	
	private function showExitConfirmationMessage(context:String):void {
		if (!alertWindowStatus) {
			alertWindowStatus=true;
			switch (context) {
				case "exitClassroom":
					ClassroomContext.classStartedFlag=false;
					Alert.show("Are you sure you want to exit from this session?", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {
						processExitConfirmation(event, context)
					}, null, 1);
					break;
				case "endMeeting":
					Alert.show("Ends the current session. Users are removed and cannot join the session again.", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {
						processExitConfirmation(event, context)
					}, null, 1);
					break;
				case "logout":
					Alert.show("Are you sure you want to log out from this session?", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {
						processExitConfirmation(event, context);
					}, null, 1);
					break;
				case "close":
					Alert.show("Are you sure you want to close A-VIEW?", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {
						processExitConfirmation(event, context)
					}, null, 1);
					break;
			}
		}
	}

	private function showExitPopupWindow():void
	{
	
		if(mainContainerComp!=null && mainContainerComp.classroomComp  && mainContainerComp.classroomComp.docComp.uploadCom)
		{
			MessageBox.show("Document upload in progress! Cannot exit A-VIEW until upload is complete.", "INFO",MessageBox.MB_OK,this);
			return;
			
		}
			
		if (exitConfirmWindow == null)
			exitConfirmWindow = new ExitPopupMenu();
		exitConfirmWindow.classroomStatus = classRoomFlag;
		PopUpManager.addPopUp(exitConfirmWindow,this,true);
		PopUpManager.centerPopUp(exitConfirmWindow);
		
	}
	
	
	public function initiateExit(context:String):void {
		if (mainContainerComp) {
			if (mainContainerComp.classroomComp) {
				mainContainerComp.classroomComp.exitContext=context;
			}
			if(mainContainerComp!=null && mainContainerComp.classroomComp  && mainContainerComp.classroomComp.docComp.uploadCom)
			{
				MessageBox.show("Document upload in progress! Cannot exit A-VIEW until upload is complete.", "INFO",MessageBox.MB_OK,this);
				return;
				
			}
			showExitConfirmationMessage(context);
		}
	}

	public function exitClassroomConfirmationHandler():void {
		alertWindowStatus=false;
		PopUpManager.removePopUp(exitConfirmWindow);
		exitConfirmWindow=null;
		mainContainerComp.classroomComp.exitClassroomConfirmation();
	}

	private function processExitCofirmationNo():void {
		if (mainContainerComp.classroomComp) {
			mainContainerComp.classroomComp.isEndSessionByModerator=false;
		}
		alertWindowStatus=false;
	}

	private function processExitConfirmaitonYes(context:String):void {
		showFeedbackForm(context);
		classRoomFlag=false;
		PopUpManager.removePopUp(exitConfirmWindow);
		exitConfirmWindow=null;
	}

	public function showFeedbackForm(context:String):void {
		feedback=entryFac.feedbackForm();
		feedback.context=context;
		PopUpManager.addPopUp(feedback, this, true);
		PopUpManager.centerPopUp(feedback);
	}

//for showing the feedback form
	private function processExitConfirmation(event:CloseEvent, context:String):void {
		applicationType::DesktopWeb {
			if (event.detail == Alert.NO) {
				processExitCofirmationNo();
			} else if (event.detail == Alert.YES && classRoomFlag == true)
			{
				
				if (context == "endMeeting") {
					processEndMeeting();
				}
				processExitConfirmaitonYes(context);
			} else if (context == 'logout')
				logoutConfirmationHandler();
			else if (context == 'close')
				closeConfirmationHandler();
			else if (context == 'exitClassroom')
				exitClassroomConfirmationHandler();
			else if (context == "endMeeting")
				exitClassroomConfirmationHandler();
		}
		
	}

	public function processEndMeeting():void {
		mainContainerComp.endMeetingSession();
		PopUpManager.removePopUp(exitConfirmWindow);
		exitConfirmWindow=null;
		var meetingManagerHelper=entryFac.meetingManagerHelper();
		meetingManagerHelper.endMeeting(this, ClassroomContext.lecture, ClassroomContext.userVO.userId);
	}

//End meeting result handler
	public function endMeetingResultHandler(event:ResultEvent):void {
		if (Log.isDebug())
			FlexGlobals.topLevelApplication.mainApp.log.debug("End Meeting:Lecture Detailes Updated Successfully");
	}

//End meeting fault handler
	public function endMeetingFaultHandler(event:FaultEvent):void {
		Alert.show("Failed to Update Record", "WARNING");
	}

	public function logoutConfirmationHandler():void {
		alertWindowStatus=false;
		//Logout time is set on the server side.
		AuditContext.login.updateAuditUserLogin(AuditContext.userLoginVO);
		//mainContainerComp.closeContacts();
		PopUpManager.removePopUp(exitConfirmWindow);
		exitConfirmWindow=null;
		this.applicationEventMap.registerInitiator(this, ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT);
		this.dispatchEvent(new ApplicationStatusEvent(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT));
		if (mainContainerComp.classroomComp) {
			mainContainerComp.classroomComp.exitClassroomConfirmation();
		} else {
			switchToLoginScreen();
		}
	}
	private var updateUserLoginCalled:Boolean=false;

	public function closeConfirmationHandler():void {
		alertWindowStatus=false;
		this.applicationEventMap.registerInitiator(this, ApplicationStatusEvent.TYPE_APPLICATION_CLOSE);
		this.dispatchEvent(new ApplicationStatusEvent(ApplicationStatusEvent.TYPE_APPLICATION_CLOSE));
		if (!AuditContext.login.updateUserLoginCalled) {
			//Logout time is set on the server side.
			AuditContext.login.updateAuditUserLogin(AuditContext.userLoginVO);
			//The timer is introduced so that it will give enough time for the remote call to server to go throgh
			setTimeout(closeConfirmationHandler, 500);
			return;
		}
		if (mainContainerComp.classroomComp) {
			mainContainerComp.classroomComp.exitClassroomConfirmation();
		} else {
			closeApp();
		}
	}

	public function switchToLoginScreen():void {
		/*
			for (var i:int=0; i < this.systemManager.popUpChildren.numChildren; i++) {
				if (this.systemManager.popUpChildren[i] is PrivateChat) {
					var chatobj:Object=this.systemManager.popUpChildren[i];
					PopUpManager.removePopUp(this.systemManager.popUpChildren[i]);
					chatobj=null;
				}

		}*/
		applicationType::desktop {
			if (this.windowApp.nativeWindow.displayState != NativeWindowDisplayState.NORMAL) {
				this.windowApp.restore();
				setTimeout(switchToLoginScreen, 100);
				return;
			}
			mainContainerComp.logoutHandler();
			mainComponentContainer.removeAllChildren();
			mainContainerComp=null;
			this.removeElement(mainOuterContainer);
			//#Bugfix for UI issue when user logs out
			this.windowApp.minWidth=600;
			this.windowApp.minHeight=268;
			this.windowApp.width=600;
			this.windowApp.height=268;
			this.minHeight=268;
			this.minWidth=600;
			this.width=600;
			this.height=268;
			this.currentState="LoginState";
			prepareLogin.logInButtonState=true;
			this.enabled=true;
			btn_login.enabled=true;
			var screenBounds:Rectangle=Screen.mainScreen.bounds;
			this.windowApp.nativeWindow.x=Math.floor((screenBounds.width - this.width) / 2);
			this.windowApp.nativeWindow.y=Math.floor((screenBounds.height - this.height) / 2);
		}
		applicationType::web {
			//For Web: Fix for issue #20122; Reload the application, when user log out from the class.
			var url:String = FlexGlobals.topLevelApplication.loaderInfo.url;
			url=url.substring(0,url.lastIndexOf("mainWeb.swf"));
			ExternalInterface.call("setCloseMode",true);
			navigateToURL(new URLRequest(url),'_self');
		}
	}

	public function closeApp(event:ApplicationStatusEvent=null):void {
		applicationType::desktop {
			this.windowApp.close();
		}
		applicationType::web {
			//Added this following logic to fix for issue #12003
			//if (ClassroomContext.userVO && ClassroomContext.userVO.role != Constants.GUEST_TYPE) {
			//Call javascript function to close the window without asking window close confirmation alert message.
			ExternalInterface.call("closeWindowWithoutAskConfirmation", true);
			//}
			//Get URL from the address bar and reload the application.
			var url:String=FlexGlobals.topLevelApplication.loaderInfo.url;
			url=url.substring(0, url.lastIndexOf("mainWeb.swf"));
			navigateToURL(new URLRequest(url), '_self');
		}
	}

	public function app_closeHandler(event:Event):void {
		// TODO Auto-generated method stub
		if (mainContainerComp) {
			//Fix for issue #11861
			if (mainContainerComp.classroomComp) {
				mainContainerComp.classroomComp.exitContext="close";
				mainContainerComp.classroomComp.processExitClassroom();
			}
			sessionCloseHandler();
		}
		applicationType::desktop {
			if (player != null && !player.closed) {
				player.close();
				player=null;
			}
		}
	}
//NativeWindowDisplayStateEvent not available for web.
	applicationType::desktop {
		public function doWindowMinimize(event:NativeWindowDisplayStateEvent):void {
			if (mainContainerComp && mainContainerComp.classroomComp && mainContainerComp.classroomComp.docComp) {
				if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
					mainContainerComp.classroomComp.docComp.windowMinimized=true;
				} else {
					mainContainerComp.classroomComp.docComp.windowMinimized=false;
				}
			}
		}
	}

	public function application_clickHandler(event:*=null):void {
		if (settingsMenuOpen == true) {
			mainContainerComp.classroomComp.showSettingsMenu();
		}
		if (mainContainerComp && mainContainerComp.profileMenu && mainContainerComp.profileMenu.menuOpened) {
			this.mainContainerComp.removeElement(mainContainerComp.profileMenu);
			mainContainerComp.profileMenu=null;
		}
		if (mainContainerComp && mainContainerComp.helpMenuUI && mainContainerComp.helpMenuUI.menuOpened) {
			this.mainContainerComp.removeElement(mainContainerComp.helpMenuUI);
			mainContainerComp.helpMenuUI=null;
			mainContainerComp.Help.backgroundFill = mainContainerComp.normalBackground;
			mainContainerComp.lblhelpMenu.setStyle("color",0x12548E);
		}
		if (mainContainerComp && mainContainerComp.classroomComp && mainContainerComp.classroomComp.docComp && mainContainerComp.classroomComp.docComp.toolBoxMenuOpened) {
			mainContainerComp.classroomComp.docComp.thumbnailMenuContainer.visible=false;
			mainContainerComp.classroomComp.docComp.toolBoxMenuOpened=false;
		}
		if (mainContainerComp && mainContainerComp.classroomComp && mainContainerComp.classroomComp.wbComp && mainContainerComp.classroomComp.wbComp.toolBoxEraserMenuOpened) {
			mainContainerComp.classroomComp.wbComp.eraserOptionBox.visible = false;
			mainContainerComp.classroomComp.wbComp.toolBoxEraserMenuOpened=false;
		}
		if (mainContainerComp && mainContainerComp.classroomComp && mainContainerComp.classroomComp.wbComp && mainContainerComp.classroomComp.wbComp.toolBoxShapeMenuOpened) {
			mainContainerComp.classroomComp.wbComp.shapesOptionBox.visible = false;
			mainContainerComp.classroomComp.wbComp.toolBoxShapeMenuOpened=false;
		}
	}

	/**
	 * common function for setting the popup window to move inside the application
	 *
	 * this function won't allow to go beyond the application
	 *
	 *
	 * for setting  the x,y cordinate to inside the
	 * parrent application if it goes beyond the application boundry
	 *
	 * task # 11337
	 *
	 *
	 * */
	public function popupWindow_moveHandler(obj:Object):void {
		var val:Number;
		//checking with the x position and with 
		if (obj.x < 0)
			obj.x=0;
		if ((obj.x + obj.width) > FlexGlobals.topLevelApplication.stage.stageWidth) {
			val=0;
			val=(obj.x + obj.width) - FlexGlobals.topLevelApplication.stage.stageWidth;
			obj.x=obj.x - val;
		}
		//checking with the y position and height 
		if (obj.y < 0)
			obj.y=0;
		if ((obj.y + obj.height) > FlexGlobals.topLevelApplication.stage.stageHeight) {
			val=0;
			val=(obj.y + obj.height) - FlexGlobals.topLevelApplication.stage.stageHeight;
			obj.y=obj.y - val;
		}
	}
	applicationType::desktop {
		// CRASH: merge: TODO: please check if this is creating an issue
		//CRJH - API
		/*private var browseLocalFileControl:BrowseLocalFilePath=new BrowseLocalFilePath();
		private var localPlayback:LocalPlayback=null;*/
		public var player:AviewPlayerDesktop;
	}
	applicationType::web {
		public var player:AviewPlayer;
	}

	protected function lblPlayOffline_clickHandler(event:MouseEvent):void {
		initOfflinePlayback();
		showBrowseDirectoryControl(true);
	}

	private function initOfflinePlayback():void {
		//CRJH - API
	/*applicationType::desktop {
		localPlayback=new LocalPlayback();
		localPlayback.addEventListener(LocalPlayback.PLAYFAILED, playErrorHandler);
	}*/
	}

	private function showBrowseDirectoryControl(isPlayback:Boolean):void {
		applicationType::desktop {
			//CRJH - API
		/*browseLocalFileControl=new BrowseLocalFilePath();
		var popupFolderLocation:TitleWindow=new TitleWindow();
		var btnSelect:spark.components.Button=new spark.components.Button();
		popupFolderLocation.addElement(browseLocalFileControl);
		browseLocalFileControl.enablelblInfo(isPlayback);
		browseLocalFileControl.localPlayBack=this.localPlayback;
		popupFolderLocation.width=500;
		popupFolderLocation.height=250;
		popupFolderLocation.title="Select Folder to Play the Lecture";
		browseLocalFileControl.btnDownload.includeInLayout=false;

		popupFolderLocation.addEventListener(Event.CLOSE, onClosepopupFolderLocation);
		localPlayback.addEventListener(LocalPlayback.PLAY, PlayLectureHandler);
		PopUpManager.addPopUp(popupFolderLocation, this, true);
		PopUpManager.centerPopUp(popupFolderLocation);*/
		}
	}

	private function onClosepopupFolderLocation(event:Event):void {
		PopUpManager.removePopUp(event.target as TitleWindow);
		//CRJH - API
	/*applicationType::desktop {
		browseLocalFileControl=null;
		localPlayback=null;
	}*/
	}

	private function downloadErrorHandler(event:Event):void {
		//CRJH - API
	/*applicationType::desktop {
		if (browseLocalFileControl != null) {
			PopUpManager.removePopUp(browseLocalFileControl.owner as TitleWindow);
			browseLocalFileControl=null;
		}
	}*/
	}

	private function playErrorHandler(event:Event):void {
		//CRJH - API
	/*applicationType::desktop {
		if (browseLocalFileControl != null) {
			PopUpManager.removePopUp(browseLocalFileControl.owner as TitleWindow);
			browseLocalFileControl=null;
			if (player != null) {
				player.close();
			}
			localPlayback=null;
		}
	}*/
	}

	private function PlayLectureHandler(event:Event):void {
		//CRJH - API
	/*applicationType::desktop {
		if (browseLocalFileControl != null) {
			PopUpManager.removePopUp(browseLocalFileControl.owner as TitleWindow);
			browseLocalFileControl=null;
		}
		playVideo();
	}*/
	}

	private function playVideo():void {
		//CRJH - API
	/*applicationType::desktop {
		var selectedFolder:File=new File(localPlayback.selectedFolder);
		if (selectedFolder.parent != null) {
			var parentFolder:String=selectedFolder.parent.nativePath;
			var localFolderPath:String=localPlayback.selectedFolder;
			player=new AviewPlayerDesktop();
			player.width=Capabilities.screenResolutionX - 50;
			player.height=Capabilities.screenResolutionY - 100;
			player.open();
			player.aviewPlayerComp.playerComp.setValues(parentFolder, parentFolder, localFolderPath + "/", parentFolder, selectedFolder.name + "/", selectedFolder.name, parentFolder, true);
			player.x=5;
			player.y=5;
			player.activate();
			player.addEventListener(Event.CLOSE, onPlayerClose);
			lblPlayOffline.enabled=false;
		} else {
			MessageBox.show("Please select the folder in which the lecture is saved", "Error", MessageBox.MB_OK);
		}
	}*/
	}

	private function onPlayerClose(event:Event):void {
		//Fix for Bug #15476 start
		//lblPlayOffline.enabled=true;
		//Fix for Bug #15476 end
		player=null;
	}

	private function resetServerIP(index:int):void {
		clearTimeout(uintServerIP);
		cmbServerType.selectedIndex=index;
	}
	private var uintServerIP:uint;

	protected function cmbServerType_focusOutHandler(event:FocusEvent=null):void {
		if (cmbServerType.textInput.text == Strings.PROMPT_SERVER_DROPDOWN) {
			return;
		}
		txtServerInput=cmbServerType.textInput.text;
		if (cmbServerType.textInput.text != Strings.NATIONAL_SERVER) {
			loginTypeCamera.enabled=false;
			loginTypeCamera.toolTip="Selected server doesn't support face recognition";
			loginTypeNormal.selected=true;
		} else {
			loginTypeCamera.enabled=true;
			loginTypeCamera.toolTip="Focus the camera on your face";
		}
//		if (cmbServerType.textInput.text == "") {
//			setLoginStatus(true);
//			cmbServerType.setStyle("color", "#b6b6b6");
//			//setStyle("fontWeight", "normal");
//			//cmbServerType.textInput.text = Constants.PROMPT_SERVER_DROPDOWN;
//			return;
//		}
		if (cmbServerType.selectedIndex == -1 )
			cmbServerType.setStyle("color", "#b6b6b6");
		
		if (cmbServerType.textInput.text == Strings.NATIONAL_SERVER) {
			//txtServerInput=Constants.NATIONAL_SERVER;
			setLoginStatus(true);
		}
		var isServerInExistingList:Boolean=false;
		var selectedServer:String = "";
		var i:int;
		for (i=0; i < loginServerTypearr.length; i++) {
			if (loginServerTypearr[i].name == txtServerInput) {
				isServerInExistingList=true;
				selectedServer = loginServerTypearr[i].domain;
				break;
			}
		}
		if (!isServerInExistingList) {
			loginServerTypearr.addItem({"name" : txtServerInput 
				,"domain": txtServerInput 
				,"ip":txtServerInput
				,isDefault:0});
			cmbServerType.dataProvider=null;
			cmbServerType.dataProvider=loginServerTypearr;
			cmbServerType.selectedIndex=loginServerTypearr.length-1;
			// when the entry is manually typed in, we need to check the status of the server
			log.info("server " + txtServerInput.toString() + " not found, checking it explicitly");
			serverInfo.checkServer(txtServerInput.toString()); 
		} else {
			uintServerIP=setTimeout(resetServerIP, 100, i);
			cmbServerType.selectedIndex=i;
		}
		setProtocolStatusImage(selectedServer);
	}
	//ashwini: this function is called a lot of times. Perhaps, a function like this should be used
	// to do the login screen validation 
	private function setProtocolStatusImage(selectedServer:String):void{
		if (cmbServerType.textInput.text != "" &&
			cmbServerType.textInput.text != Strings.PROMPT_SERVER_DROPDOWN){
			if(serverInfo.serverStatus(selectedServer)==1)
			{
				btn_ForgotPassword.enabled=true;
				if(serverInfo.isHttpsEnabled(selectedServer))
				{
					imgStatus.source = secure_Icon;
					imgStatus.includeInLayout=true;
					imgStatus.visible=true;
					cmbServerType.width=187;
					cmbServerType.errorString="";
					imgStatus.toolTip="Secured Server connection";
					ClassroomContext.AVIEW_PROTOCOL=Constants.PROTOCOL_HTTPS;
				}
				else
				{
					cmbServerType.width=206;
					cmbServerType.errorString="";
					imgStatus.includeInLayout=false;
					imgStatus.visible=false;
					ClassroomContext.AVIEW_PROTOCOL=Constants.PROTOCOL_HTTP;
				}
			}
			else if(serverInfo.serverStatus(selectedServer)==0)
			{
				btn_ForgotPassword.enabled=false;
				imgStatus.source = info_Icon;
				imgStatus.includeInLayout=true;
				imgStatus.visible=true;
				cmbServerType.width=187;
				imgStatus.toolTip="Encountered some network errors ";
				cmbServerType.errorString="Encountered some network errors";
				
			}
			else
			{
				btn_ForgotPassword.enabled=false;
				imgStatus.source = info_Icon;
				imgStatus.includeInLayout=true;
				imgStatus.visible=true;
				cmbServerType.width=187;
				imgStatus.toolTip="Server is invalid/unreachable";
				cmbServerType.errorString="Server is invalid/unreachable";
			}			
		} 
		//ashwini : TODO
//		cmbServerType.selectedIndex = ind;
		
	}
	

	private var txtServerInput:String;

	private function setLoginStatus(bool:Boolean):void {
		//lblLoginType.visible=bool;
		//hbxBiometric.visible=bool;
		//lblLoginType.includeInLayout=bool;
		//hbxBiometric.includeInLayout=bool;
	}

	protected function cmbServerType_focusInHandler(event:FocusEvent):void {
		cmbServerType.setStyle("color", "#000000"); // TODO Auto-generated method stub
	}

	/*protected function cmbServerType_changeHandler(event:ListEvent):void {

		txtServerInput=event.currentTarget.filterString.toString();

		if (cmbServerType.text.toString() != Constants.NATIONAL_SERVER) {
			setLoginStatus(false);
		} else {
			setLoginStatus(true);
		}
	}*/
	var serverDropDownChanged: Boolean = false ;
	protected function cmbServerType_changeHandler(event:Event):void{
		serverDropDownChanged = true;
		btn_login.enabled = true;
		prepareLogin.logInButtonState = true;
	}
	
	protected function mainWindowMouseMove():void{
		if (serverDropDownChanged == true) {
			serverDropDownChanged = false;
			var selectedServer:String = "";
			trace ("called inside the mouse move event");
			for (var i:int =0; i < loginServerTypearr.length; i++) {
				if (loginServerTypearr[i].name == cmbServerType.textInput.text.toString()) {
					selectedServer = loginServerTypearr[i].domain;
					setProtocolStatusImage(selectedServer);
					break;
				}
			}
		}
	}
	
	protected function cmbServerType_clickHandler(event:MouseEvent):void {
		// TODO Auto-generated method stub
		cmbServerType.setStyle("color", "#000000");
		if (cmbServerType.textInput.text.toString() == Strings.NATIONAL_SERVER || cmbServerType.textInput.text.toString() == Strings.PROMPT_SERVER_DROPDOWN) {
			cmbServerType.textInput.text="";
			cmbServerType.selectedIndex=-1;
		}
	}
	private var alertUserIP:Alert=null;

	protected function cmbServerType_keyDownHandler(event:KeyboardEvent):void {
		if (event.keyCode == 46 && cmbServerType.textInput.text.toString() != Strings.NATIONAL_SERVER && alertUserIP == null) {
			alertUserIP=CustomAlert.confirm("Are you sure you want to delete the selected server?", "Server delete confirmation", closeAlertUserIP);
		}
	}

	private function closeAlertUserIP(event:CloseEvent):void {
		alertUserIP=null;
		if (event.detail == Alert.YES && userSelectedServer != Strings.NATIONAL_SERVER) {
			for (var j:int=0; j < loginServerTypearr.length; j++) {
				if (loginServerTypearr[j].name == userSelectedServer) {
					loginServerTypearr.removeItemAt(j);
					loginServerTypearr.refresh();
					break;
				}
			}
			for (var i:int=0; i < saveTheseServers.length; i++) {
				if (saveTheseServers[i].name == userSelectedServer) {
					saveTheseServers.removeItemAt(i);
					break;
				}
			}
			cmbServerType.selectedIndex=0;
			setLoginStatus(true);
			prepareLogin.saveUserEnteredXML();
		}
	}

	private function mainWindowHeaderMouseDownHandler(event:MouseEvent):void {
		applicationType::desktop {
			this.windowApp.nativeWindow.startMove();
		}
	}

	private function imgResizeMouseDownHandler(event:MouseEvent):void {
		applicationType::desktop {
			this.windowApp.nativeWindow.startResize();
		}
	}

	private function appMinimizeHandler(event:MouseEvent):void {
		applicationType::desktop {
			this.windowApp.minimize();
		}
	}

	public function createCaptcha(flag:Boolean):void {
		//Make the captcha container visible
		//and the login type container in visible
		captchaContainer.visible=flag;
		captchaContainer.includeInLayout=flag;
		loginTypeContainer.visible=!flag;
		loginTypeContainer.includeInLayout=!flag;
		txtCaptcha.text="";
		if (flag) {
			loadCaptcha();
		}
	}

	protected function loadCaptcha():void {
		if (captcha != null) {
			captchaImage.removeChild(captcha);
		}
		captcha=new Captcha("alphaCharsnum", 4);
		captchaImage.addChild(captcha);
	}

	protected function changeSelection():void {
		if (loginTypeNormal.selected == true) {
			//loginTypeCamera.selected=false;
			loginTypeNormalContainer.setStyle("backgroundColor", '#C2DDF2');
			loginTypeCameraContainer.setStyle("backgroundColor", '#FFFFFF');
			changeLoginType();
		} else {
			//loginTypeNormal.selected=true;
			getCameraDetails();
			changeLoginType();
			cameraName=cameraList.selectedIndex.toString();
			selectionMode="ok";
			popupCloseHandler();
			loginTypeNormalContainer.setStyle("backgroundColor", '#FFFFFF');
			loginTypeCameraContainer.setStyle("backgroundColor", '#C2DDF2');
		}
	}

	public function getCameraDetails():void {
		if (scanHardwareEnableFlag) {
			scanHardware();
		}
		cameraNames=new ArrayCollection(Camera.names);
		if (Camera.names.length > 1) {
			cameraList.selectedIndex=1;
		} else {
			cameraList.selectedIndex=0;
		}
	}

	public function refreshCameraList():void {
		if (scanHardwareEnableFlag) {
			scanHardware();
		}
		cameraNames.removeAll();
		for (var i:int=0; i < Camera.names.length; i++) {
			cameraNames.addItem(Camera.names[i])
		}
		cameraNames.refresh();
		if (Camera.names.length > 1) {
			cameraList.selectedIndex=1;
		} else {
			cameraList.selectedIndex=0;
		}
		cameraListChangeHandler();
	}

	protected function cameraListChangeHandler(event:ListEvent=null):void {
		cameraName=cameraList.selectedIndex.toString();
		selectionMode="ok";
		popupCloseHandler();
	}

	protected function rollOverHandler(event:MouseEvent):void {
		// CRASH: API
	cursorID = CursorManager.setCursor(resizeCursorSymbol);
	}

	protected function rollOutHandler(event:MouseEvent):void {
		CursorManager.removeCursor(cursorID);
	}

	
}
