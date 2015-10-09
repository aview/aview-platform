import edu.amrita.aview.core.desktopSharing.DesktopSharingComponent;
import edu.amrita.aview.core.desktopSharing.SharingMode;
import edu.amrita.aview.core.entry.SessionEntry;
import edu.amrita.aview.core.entry.events.SessionStatusEvent;
import edu.amrita.aview.core.evaluation.Evaluation;
import edu.amrita.aview.core.evaluation.polling.Polling;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.login.MainApp;
import edu.amrita.aview.core.login.boilerplate.Strings;
import edu.amrita.aview.core.shared.events.ChatEvent;
import edu.amrita.aview.core.shared.events.ChatStatusEvent;
import edu.amrita.aview.core.video.VideoWallPopOut;

import flash.utils.getDefinitionByName;
import flash.utils.getTimer;

import mx.containers.Canvas;
import mx.controls.Label;
import mx.utils.ObjectUtil;

import objectResolver.EntryFac;
import objectResolver.localObjects.CoreSingleInstance;

applicationType::DesktopWeb {
	import edu.amrita.aview.core.entry.MainComponent;
    import com.amrita.edu.collaboration.CollaborationObject;
    import edu.amrita.aview.core.shared.audit.AuditContext;
    import edu.amrita.aview.core.shared.components.ImageButton;
    import edu.amrita.aview.core.shared.components.alert.CustomAlert;
    import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
    import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
    import edu.amrita.aview.core.shared.components.userList.CRActionButtons;
    import edu.amrita.aview.core.shared.components.userList.PTTBox;
    import edu.amrita.aview.core.shared.components.userList.UserList;
    import edu.amrita.aview.core.shared.eventmap.EventMap;
    import edu.amrita.aview.core.shared.helper.AbstractHelper;
    import edu.amrita.aview.core.shared.skins.ResizeImageButtonSkin;
    import edu.amrita.aview.core.desktopSharing.ScreenSharingComponent;
    import edu.amrita.aview.core.documentSharing.DocComponent;
    import edu.amrita.aview.core.entry.ClassRoomSgl;
    import edu.amrita.aview.core.entry.ClassroomContext;
    import edu.amrita.aview.core.entry.Constants;
    import edu.amrita.aview.core.entry.ModuleRO;
    import edu.amrita.aview.core.entry.ModuleVO;
    import edu.amrita.aview.core.gclm.CanvasPopup;
    import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
    import edu.amrita.aview.core.gclm.helper.LectureHelper;
    import edu.amrita.aview.core.gclm.lecture.CreateLectureComp;
    import edu.amrita.aview.core.gclm.vo.UserVO;


    import edu.amrita.aview.core.recording.Events.RecordingStatus;
    import edu.amrita.aview.core.recording.Recorder;
    import edu.amrita.aview.core.video.pretesting.Pretesting;
    import edu.amrita.aview.core.video.setting;
    import edu.amrita.aview.core.whiteboard.WhiteboardComp;

    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.system.Capabilities;
    import flash.utils.Timer;
    import flash.utils.clearInterval;
    import flash.utils.clearTimeout;
    import flash.utils.setInterval;
    import flash.utils.setTimeout;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.FlexGlobals;
    import mx.core.UIComponent;
    import mx.events.CloseEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.managers.PopUpManager;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;
    import mx.utils.StringUtil;

    /**Platform specific imports*/
    applicationType::desktop {
        import mx.events.AIREvent;
        import edu.amrita.aview.core.documentSharing.DocSharing;
        import edu.amrita.aview.core.whiteboard.Whiteboard;
    }
    //: API : done
    public var entryFac:EntryFac = new EntryFac;
//    public var MeetingRoomEvent = null;
    public var videoShareObj:* = null;
	//PNCR: added a new videosharing class to get static constants. 
	public var videoSharing:* = null;
    public var breakSessionEvent = null;
//    public var ChatStatusEvent = null;
    public var quizObj = null;
    public var viewer3DComp = null;
    public var viewer2DComp = null;
    public var chatComp = null;
    public var questionComp = null;

//  Commented unused code
//	public var polling = new Polling;
	public var pollingObj = new Polling;

	applicationType::DesktopWeb{
    	public var classroomComponentSgl:ClassRoomSgl;
	}
    public var recorder:Recorder = null;

//	public static var meetingRoomVO = entryFac.meetingRoomVO();
	public var docComp:DocComponent=new DocComponent;
	//Bug #15781. Singleton object will not refresh the module at the time of relogin.
    public var wbComp:WhiteboardComp = new WhiteboardComp();
    [Bindable]
    public var actionButtons:CRActionButtons = new CRActionButtons();
    [Bindable]
    public var classroomContextObj:ClassroomContext = new ClassroomContext();

    //For quiz module
    public var evaluationFlag:Boolean = false;
    public var pollingFlag:Boolean = false;
	public var uploadCompl:Boolean=false;
    public var chatIntervalId:int = 0;
    public var userIntervalId:int = 0;
    public var questionIntervalId:int = 0;

//PNCR: move Declaration to corresponding modules
    public var isSettingPopedUp:Boolean = false;
    public var viewer3DLoaded:Boolean;
    public var viewer3DInitial:Boolean;
    public var remove3D:Boolean = true;
    public var viewer2DLoaded:Boolean = false;

//PNCR: use single "l" in selectedModulle
    public var selectedModulle:int = -1;
    public var class_info:String;
    public var Teacher_Info_Box:String;

    public var initWb_flag:int = 0;
    public var initdoc_flag:int = 0;
    public var initquiz_flag:int = 0;
    public var initviewer3D_flag:int = 0;

    public var selectedModule_so:CollaborationObject;
    public var previdx:int = 0;
    public var u:String;
    public var message:String;
    public var curTime:Number = 0;

    public var flag_openwin_WB:int = 0;
    public var flag_openwin_doc:int = 0;

    public var pttBox:PTTBox = new PTTBox;
    public var selectModuleByUser:Boolean = false;

    /**
     * Maximum number of retries performed to re establish video connection,
     * incase the connection gets closed.
     */
    public var MAX_CHAT_CONNECTION_RETRIES:int = 30;

    /**
     * Current number of retries to re establish video connection
     */
    public var chatConnectionRetries:int = 0;

	public var failOverCount : int = 0;
    /**
     * Wait time between video reconnections
     */
    private var CHAT_CONNECTION_RETRY_WAIT_TIME_MS:int = 3000;

    private static const VideoConnectedMessage:String = "Video connected"
    private static const WhiteboardConnectedMessage:String = "Whiteboard connected."
    private static const DocumentConnectedMessage:String = "Document connected."
    private static const ChatConnectedMessage:String = "Chat connected."
    private static const UserConnectedMessage:String = "Collaboration connected"
    private static const Viewer3DConnectedMessage:String = "3DViewer connected."
    private static const Viewer2DConnectedMessage:String = "2DViewer connected."

    private static const VideoReconnectingMessage:String = "Reconnecting Video..."
    private static const WhiteboardReconnectingMessage:String = "Reconnecting Whiteboard..."
    private static const DocumentReconnectingMessage:String = "Reconnecting Document..."
    private static const ChatReconnectingMessage:String = "Reconnecting Chat..."
    private static const UserReconnectingMessage:String = "Reconnecting Collaboration..."
    private static const Viewer3DReconnectingMessage:String = "Reconnecting 3DViewer..."
    private static const Viewer2DReconnectingMessage:String = "Reconnecting 2DViewer..."

    public var isVideoConnected:Boolean = false;
    public var isWhiteboardConnected:Boolean = false;
    public var isDocumentConnected:Boolean = false;
    public var isChatConnected:Boolean = false;
    public var isViewer3DInitialized:Boolean = false;

//public var savedLectureName:String="";
    public var savedKeywords:String = "";

    private var preRecordedChats:Array = new Array();
    public var fmsip:String;
    public var teacherflag:int = 0;
    public var studentflag:int = 0;
// PNCR: since viewer2DMWActive is 2D-flag arg it should be define inside 2D module 
    public var viewer2DMWActive:Boolean = false;

    public var chat_count:int; // flag to check the number of chat windows open
    public var isVideoShareModuleAvailable:Boolean;
    public var quiz_count:int;
    public var polling_count:int;
//PNCR: Delcare in 3D module
    public var viewer3D_count:int; // flag to check the number of 3DViewer windows open

    public var my_res_X:int;
    public var my_res_Y:int;

    private var chatConnectionTimeoutId:uint;

//For 3Dviewer
    public var netStatusmsg:Boolean = true;

    [Bindable]
    public var automaticRecording:Boolean = false;

    public var isPretestingPrompt:Boolean = false;
    public var videoStartButtonStatus:String = "";

    public var can1:CanvasPopup = new CanvasPopup;
    private var callcreate_flag:int = 0;
    public var videofilename:String;
    private var videopath:String;
    private var xmlpath:String;
    private var date:String;

    public var isStartAVButtonCanbeEnabled:Boolean = true;
//CRJH: Timer can be replaced with setTimeOut or setTimeInterval, whichever appropriate
    public var timerSocket:Timer;

////////////////////////////////////////////////////
// Added a HTTPService to communicate with server
// Also added a method checkWAMPserver() to check whether WAMP server is up or not
// Issue #199 ---STARTS

    /* This service checks if the WAMP server is up or not. */
//RGCR: Rename this variable as serverTimeService
    private var httpServerMonitor:HTTPService;
//RGCR: This variable is not used. Can be removed
    private var httpServerMonitor1:HTTPService;
//RGCR: This variable is not used and it's handlers are also not used. Can be removed
    private var httpServerMonitor2:HTTPService;

    private var viewerVideoFolderCreateService:HTTPService;
    private var presenterVideoFolderCreateService:HTTPService;
    private var desktopRecordingFolderCreateService:HTTPService;
    private var viewerVideoFolderCreateStatus:String;
    private var presenterVideoFolderCreateStatus:String;
    private var desktopRecordingFolderCreateStatus:String;
    private var allContacts:ArrayCollection = null;
    private var isAddPeople:Boolean = false;
	public var isQuizPollingMod:Boolean = false;

    public var objPretesting:Pretesting;

    [Bindable]
    public var xmlClassRepository:XML = null;

    private var userConnectionCloseTimeOutId:uint;
    private var videoConnectionCloseTimeOutId:uint;

    public var videoStarted_flag:Boolean = false;
    public var openall_flag_wb:int = 0;
    public var openall_flag_doc:int = 0;
    public var openall_flag_3DViewer:int = 0;

    public var activeModuleIndex:Number;
    private var messageLabel:spark.components.Label = new spark.components.Label();
	private var messageLabelForMXMLComponents:mx.controls.Label = new mx.controls.Label();
	private var messageLabelForChat:mx.controls.Label = new mx.controls.Label();
	private var messageLabelForVideo:mx.controls.Label = new mx.controls.Label();
    public var Course_Name:String = "Guest"; //Name of Course
    public var Teacher_Name:String = "Guest"; //Name of teacher
    public var Topic_Name:String = "Seminar"; //Name of topic
    public var Centre_Name:String = "Unknown"; //Name of center
    public var lecturename:String; //Name of lecture

    private var pop:setting;
    /**
     * For debug log
     */
    private var log:ILogger = Log.getLogger("aview.modules.entry.ClassroomComponentHandler.as");

    public var recordButtonBlinkedOnce:Boolean = false;
    private var isRecordingFailed:Boolean;

    private var enableConnectionAfterServerSwitching:Timer;
    private var hideServerSwitchingAlert:Timer;
    private var sc:Boolean = true;
    public var resumePublishing:Boolean = false;
    public var alertServerSwitching:Alert = null;
	/* Variable holds the extension of vidoe file*/
    public var videoFileExt:String = null;

    private var lectureCreate:CreateLectureComp = null;

    private var closeFlag_record:int = 0;
//[Bindable]
    public var exitContext:String = "";
    public var classroomExited:Boolean;
    public var labelMsg:mx.controls.Label;
    public var isFirstTime:Boolean = true;

    public var btnResize:ImageButton = new ImageButton;
    private var userConnectionCloseTimeOutID:uint;

//CRJH: Wrong Comment and variable name: The flag is used by audio-video
    /** Boolean Variable for checking the existence of main window */
    public var isMainAppClosed:Boolean = false;
	//Fix for issue #18167
	public var unInterruptedDesktopSharingOFFAlert:Alert = null;
    [Bindable]
    public var userLstSortFlag:Boolean = true;

//CRJH: API : done ashwini
    [Bindable]
    public var prefSettings = entryFac.preferenceSettings();
	public var deskPreference = entryFac.desktopPreference();

    public var isEndSessionByModerator:Boolean = false;
    /**
     * Object of custom component UserList for displaying the names and icons of all online users.
     */
    public var lstUsers:UserList;

    private var classRoomModuleVO:ModuleVO = null;
//CRJH: API : todo
//    private var chatManager:ChatManager = null;
    public var contactModuleRO:ModuleRO = null;

	private var startTime:Number;
	private var endTime:Number;
	private var notificationTimer:Timer;
	
    /**Platform specific variables*/
    applicationType::web {
        /*Changed private to public to access this variable from screenSharingComponent.mxml file and also renamed this variable.*/
        public var isDesktopSharingStarted:Boolean = false;
        /*Set flag as true when user resize the browser window.*/
        public var IsApplicationResized:Boolean = false;
        /*Vaiable holds Desktop sharing server name */
        public var DESKTOP_SERVER_MODULE_NAME:String = "desktopsharing_module";
        /*For Guest Login: Timeout id for video share module */
        public var videoShareTimeoutID:uint;
        /*Set flag as true when administrator do server fail over */
        //public var isServerFailOver:Boolean;
        public var screenSharingComp:ScreenSharingComponent = new ScreenSharingComponent();
		/* Variable for storing the sharing mode (0-Desktop,1-Application) selected from the SharingMode popup. */
		public var selectedSharingMode:uint=0;
    }

    applicationType::desktop {
        //CRJH: API : done ashwini
        public var videoshareMultiWindow = null;
        public var quizMultiWindow = null;
        public var viewer3DModule = null;
        public var viewer2DMW = null;
        public var pollingMultipleWindow = null;
        //CRJH: API : done ----------------------
        private var delete3DDirectory:File;
        public var documentSharingMW:DocSharing; // document sharing component for multiple ui
        public var whiteboardMW:Whiteboard; // whiteboard component for multiple ui
        //PNCR: this object is using only inside 2D no need to define here.
        private var isDesktopSHaringStarted:Boolean = false;
		public var desktopSharingComp:DesktopSharingComponent = new DesktopSharingComponent();
		/**
		 * Variable of custom popup component 'SharingMode' for choosing sharing mode (Desktop/Application).
		 */
		public var popUpSharingMode:SharingMode = new SharingMode();
		/**
		 * Variable for setting parent for displaying uninterrupted desktop sharing alert .
		 */
		public var parentForUninterruptedSharingAlert = null;
    }
    applicationType::DesktopWeb {
		/*Set flag as true when administrator do server fail over */
		public var isServerFailOver:Boolean = false;
		//variable used set the initial state of the question interaction while pressing cancel button
		public var questionInitialInteractionStatus:Boolean=true;
		public var interactionStatusChanged:Boolean=false;

        [Bindable]
        public var muiInteractionflag:Boolean = false;
		[Bindable]
		public var peopleCountFlag:Boolean = false;
        [Bindable]
        public var videoLayoutFlag:Boolean = false;
        [Bindable]
        public var questionFlag:Boolean = true;
        [Bindable]
        public var multiUserInteractionStatus:Boolean = false;
        [Bindable]
        public var questionInteractionStatus:Boolean = true;

        [Bindable]
        public var userListSortingStatus:Boolean = false;
        [Bindable]
        public var questionAnswerEnabledState:Boolean = false;

		
		[Bindable]
		[Embed(source="/edu/amrita/aview/core/entry/assets/images/connect.png")]
		private var connected:Class;
		[Bindable]
		[Embed(source="/edu/amrita/aview/core/entry/assets/images/disconnect.png")]
		private var disConnected:Class;
		
		[Bindable]
		[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/videoconnected.png")]
		private var videoConnected:Class;
		[Bindable]
		[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/videodisconnected.png")]
		private var videoDisconnected:Class;
		
		[Bindable]
		[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/colabarationconnected.png")]
		private var colabarationConnected:Class;
		[Bindable]
		[Embed(source="/edu/amrita/aview/core/login/boilerplate/assets/images/colabarationdisconnected.png")]
		private var colabarationDisconnected:Class;
		
    }

	//Fix for Bug # 20432 start
	private var recordingOnReConnectionAlert : Alert = null;
	private var recordingOnReConnectionAlertTimer:Timer = null;
	//Fix for Bug # 20432 end
	
//************************************************Functions Start****************				

    public function initNonCoreObjects():void{
		//ChatStatusEvent = entryFac.chatStatusEvent();
		
        videoShareObj = entryFac.videoSharing();
	videoSharing = entryFac.videoSharingClass();
        quizObj = new Evaluation();
        pollingObj = entryFac.polling();
        viewer3DComp = entryFac.viewer3DComponent();
        viewer2DComp = entryFac.viewer2DComponent();
        chatComp = entryFac.chatComponent();
        questionComp = entryFac.questionComponent();
//		Commented unused code
//        polling = entryFac.polling();

	applicationType::desktop {
            //CRJH: API : done ashwini
            videoshareMultiWindow = entryFac.videoSharingWindow();
            quizMultiWindow = entryFac.quizWindow();
            viewer3DModule = entryFac.viewer3DModule(); // 3DViewer component for multipile UI
            viewer2DMW = entryFac.viewer2DWindow();
            pollingMultipleWindow = entryFac.pollingWindow();
        }
    }
    public function getClassRepositoryFolderStructure():void {
        var classRegHelper:ClassRegistrationHelper = new ClassRegistrationHelper();
        classRegHelper.getClassRepositoryFolderStructure(ClassroomContext.userVO.userId, getClassRepositoryFolderStructureResultHandler);
    }

    public function getClassRepositoryFolderStructureResultHandler(xmlString:String):void {
        xmlClassRepository = new XML(xmlString);
    }

    public function onModeratorEndSession(event:Event):void {
        //CRASH: TODO : need to change this...
		event.target.removeEventListener(EntryFac.END_SESSION, onModeratorEndSession);
//		entryFac.eveMeeting.
        exitContext = "exitClassroom";
        Alert.show("Moderator ended session", "Information", null, null, function(event) {
			//Fix for issue #18772
			applicationType::web{
				if(classroomComponentSgl.isFullScreen){
					classroomComponentSgl.fullScreenSelected();
				}
			}
            FlexGlobals.topLevelApplication.mainApp.showFeedbackForm(exitContext);
            FlexGlobals.topLevelApplication.mainApp.classRoomFlag = false;
        });
    }


    /**
     * This function creates object of userlist component and set it's position in the UI
     *
     *
     * @return void
     */
    public function createUserList():void {
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("createUserList, usersConnection.netConnection.connected:" + usersConnection.netConnection.connected);
		//Fix for Bug#18497:Start
		if(ClassroomContext.userVO.role==Constants.ADMIN_TYPE ||
			ClassroomContext.userVO.role==Constants.MASTER_ADMIN_TYPE)
		{
	        actionButtons.init(this, null, classRoomModuleVO as ModuleRO);
			return;
		}
		//Fix for Bug#18497:End
        // creates object of userlist component 
        lstUsers = new UserList;

        actionButtons.init(this, lstUsers, classRoomModuleVO as ModuleRO);
		lstUsers.init(this, actionButtons,classRoomModuleVO as ModuleRO,contactModuleRO);

        lstUsers.getClassRegisters();
        //Attach the userlist to HBox named 'usersBox'
        classroomComponentSgl.UserlistCanvas.addChild(lstUsers);
    }



    public function sortUserList():void {
        lstUsers.setSortingOption(chkBoxUserSorting.selected);
        //Guest Login: Restrict user action buttons(Handraise,Presenter request etc) for guest user
        //if (ClassroomContext.userVO.role != Constants.GUEST_TYPE) {
        actionButtons.setupUserActionButtons();
        //}
        setMuteSortedArray();

        changePrefUserListSortingEventLog(chkBoxUserSorting.selected ? "On" : "Off");
    }

    /**
     *
     * @private
     * Audits the "PrefUserListSorting" action, when the presenter/moderator changes the User List Sorting preference.
     *
     * @param status - UserListSorting Off/On
     * @return void
     *
     */
    private function changePrefUserListSortingEventLog(status:String):void {
        AuditContext.userAction.createAction(AuditConstants.prefUserListSorting, status, null, null);
    }

    public function enableIcons():void {
        VideoIcon = Video_unclicked;
        DocumentIcon = Document_unclicked;
        WhiteboardIcon = Whiteboard_unclicked;
        CourseIcon = Course_unclicked;
        LectureIcon = Lecture_unclicked;
        UserAccountIcon = UserAccount_unclicked;
        LiveQuizIcon = liveQuiz_unclicked;
        pollingIcon = poll_unclicked;
        ClassRegistrationIcon = ClassRegistration_unclicked;
        MyProfileIcon = MyProfile_unclicked;
		startStopVideoToggleIcon = startVideoIcon;
    }

    public function showMeetingRoomManager():void {
        var meetingRoomManager = entryFac.getMeetingRoomManagerController(this.contactModuleRO, this.allContacts, null, lstUsers.classMembers, ClassroomContext.aviewClass.className, ClassroomContext.aviewClass, EntryFac.MODE_ADD_CONTACTS_GUESTS);
        meetingRoomManager.addEventListener(EntryFac.EDITED_MEETINGROOM, onMeetingRoomEdited);
        meetingRoomManager.createMeetingRoomManagerView(this as UIComponent);
    }

    private function onMeetingRoomEdited(passedEvent:Object):void {

        lstUsers.classMembers = passedEvent.selectedMeetingRoom.meetingRoomMembers;
    }

    public function onClickAddPeople():void {
        isAddPeople = true;
        getAllContacts();
    }

    public function getAllContacts():void {
        this.classRoomModuleVO.applicationEventMap.registerInitiator(this, EntryFac.REFRESH_CONTACTS);       
        this.dispatchEvent(entryFac.getContactsProviderEvent(EntryFac.REFRESH_CONTACTS, onRefreshContacts) as Event);
    }

    private function onRefreshContacts(allContacts:ArrayCollection):void {
        this.allContacts = allContacts;
        if (isAddPeople) {
            showMeetingRoomManager();
        }
    }

	
	private function _transitionToBaseState(btnName:String= "Conso_Doc", moduleIdx:int=0, myFrameRate:int=7):void{
		
		// videowall hack starts
		/*if(selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6 ){
			onChangeModule();
		}*/
		// end: videowall hack
		this._unload3d();
		if (entryFac.contextManager() && entryFac.contextManager().viewer2DModule) {
			entryFac.contextManager().viewer2DModule.loadedListVisiblityChange();
		}
		//start: change button state
		//make all buttons visible
		var btns:Array = ["btnShowViewersWall", "Conso_Whiteboard", "Conso_Doc", "Conso_vidsharing",
			"Conso_PollingQuiz", "Conso_LiveQuiz", "Conso_3DViewer", "Conso_2DViewer"];
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			for (var i:int = 0; i < btns.length; i++){
				classroomComponentSgl[btns[i]].enabled = true;
			}
			// todo: ashwini: for lack of a better consise code, doing the following line explicitly
			applicationType::DesktopWeb{
				classroomComponentSgl.btnDesktopSharing.enabled = true;
			}
			//disable the button that was selected
			classroomComponentSgl[btnName].enabled = false;
		}
		else
		{
			for (var i:int = 0; i < btns.length; i++){
				classroomComponentSgl[btns[i]].enabled = false;
			}
			classroomComponentSgl.btnDesktopSharing.enabled = false;
			classroomComponentSgl[btnName].enabled = true;
		}
		
		// end: change button state
		if (selectModuleByUser) setActiveWindowInSO(moduleIdx);
		this.systemManager.stage.frameRate = myFrameRate;
		pollingFlag = false;
		evaluationFlag = false;
		selectedModulle = moduleIdx;
		classroomComponentSgl.tab2.selectedIndex = moduleIdx;

		if (docComp && docComp.contextMenuList) {
			docComp.hideContextMenuList();
		}
        addRemoveDocComp("remove");
	}
	
	private function _unload3d():void{
		//CRJH: API : done ashwini
		if (viewer3DLoaded && viewer3DComp && viewer3DComp.viewer3DSWC) {
			initviewer3D_flag = 0;
			if (viewer3DComp) {
				viewer3DComp.viewer3DSWC.removeComponent();
			}
			viewer3DLoaded = false;
		}
	}
	
	private function changeToSimpleLayout(module:String):void
	{
		if((selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6) || isQuizPollingMod ){
			
			isQuizPollingMod = false;
			var obj:Object = {
				"documentMW" 	 :0
				,"whiteboardMW"  :1
				,"3dMW" 		 :2
				,"2dMW" 		 :3
				,"videoShareMW"  :4
				,"videoWallMW"   :6
				,"quickNoteMW" 	 :7
				,"youtubeLiveMW" :8};
		
			selectedModulle = obj[module];
			var funcMap:Object = {
				0 : "doc"
				,1 : "wb"
				,2 : "3D" 
				,3 : "2D" 
				,4 : "vidsh"
				,5 : "Desktop"
				,6 : "vw"
			};
			if(selectedModulle!=6)
			{
				onChangeModule();
				this["click_Conso_"+ funcMap[selectedModulle]]();//,500);
			}
		}
	}
    /**
     * The function is called when button document is clicked in consolidated mode.
     * init_doc function is called if the document component is not initialized.
     *
     *
     * @return void
     */
// This function gets invoked when the document button is clicked.
// If the document component is not initialized then 'init_doc' function is called. 
    public function click_Conso_doc():void {
		if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
			return;
		if((selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6) || isQuizPollingMod ){
			onChangeModule();
			isQuizPollingMod = false;
		}
		this._transitionToBaseState("Conso_Doc", 0);
		
        //Remove the key down event listner when the document tab is selected
        if (wbComp && this.systemManager.stage.hasEventListener(KeyboardEvent.KEY_DOWN)) {
            this.systemManager.stage.removeEventListener(KeyboardEvent.KEY_DOWN, wbComp.handleKeyboardShortcut);
        }
        if (ClassroomContext.isModerator && recorder.isRecording && recorder.docRecorder) {
            addDocTabEvent()
        }
        if (initdoc_flag == 0) {
            init_doc();
        }

        if (docComp && docComp.isPopOut) {
            setMessageForFullScreen(classroomComponentSgl.docBox, Constants.FULLSCREEN_MSG);
            applicationType::desktop {
               if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
             docComp.documentSharingMW.activate();
           }
        } 
		else {
            applicationType::desktop {
                if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
                    FlexGlobals.topLevelApplication.activate();
            }
            addRemoveDocComp("add");
        }
    }

    /**
     * The function is called when button whiteboard is clicked in consolidated mode.
     * init_wb function is called if the while board component is not initialized.
     *
     *
     * @return void
     */
// This function gets invoked when the white board button is clicked.
// If the white board component is not initialized then 'init_wb' function is called. 
    public function click_Conso_wb():void {
		if((selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6) || isQuizPollingMod ){
			onChangeModule();
			isQuizPollingMod = false;
		}


        if (ClassroomContext.isModerator && recorder.isRecording) {
            addWhiteboardTabEvent();
        }
        //Add the key down event listner when whiteboard tab is selected
        if (wbComp && !this.stage.hasEventListener(KeyboardEvent.KEY_DOWN)) {
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, wbComp.handleKeyboardShortcut);
        }

		this._transitionToBaseState("Conso_Whiteboard",1,7);
		
        if (wbComp && wbComp.isPopOut) {
            setMessageForFullScreen(classroomComponentSgl.wbBox, Constants.FULLSCREEN_MSG);
            applicationType::desktop {
                if (!isUnInterruptedDesktopsharingON())
                    wbComp.whiteBoardFullWndw.activate();
            }

        } else {
            applicationType::desktop {
                if (!isUnInterruptedDesktopsharingON())
                    FlexGlobals.topLevelApplication.activate();
            }
        }
        if (initWb_flag == 0) {
            init_wb();
        }
    }

    /**
     * The function is called when button video sharing is clicked in consolidated mode.
     */
    public function click_Conso_vidsh():void {
		if((selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6) || isQuizPollingMod ){
			onChangeModule();
			isQuizPollingMod = false;
		}
		this._transitionToBaseState("Conso_vidsharing",4,7);

		videoShareObj.userRole = classroomContextObj.userRole;
        //CRJH: API : done ashwini
        if (videoShareObj.isPopOut) {
            setMessageForFullScreenForMXMLComponents(classroomComponentSgl.vidbox, Constants.FULLSCREEN_MSG);
            applicationType::desktop {
				if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
                videoShareObj.activatePopOutWindow();
            }
        } else {
            videoShareObj.width = classroomComponentSgl.vidbox.width;
            videoShareObj.height = classroomComponentSgl.vidbox.height;
            applicationType::desktop {
                if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
                    FlexGlobals.topLevelApplication.activate();
            }
            if (classroomComponentSgl.vidbox.numChildren == 0) {
                classroomComponentSgl.vidbox.addChild(videoShareObj);
            }
        }
        videoShareObj.resetPlayerControls();
    }

    /**
     * This method is invoked when the btnDesktopSharing button is clicked
     * if the screenSharing component is not initialized then it will be initialized
     * from this method
     */
    public function click_Conso_Desktop():void {
		applicationType::DesktopWeb {
			if((selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6) || isQuizPollingMod ){
				onChangeModule();
				isQuizPollingMod = false;
			}
			applicationType::desktop{
				//Fix for issue #20130
				if(desktopViewer.isPopOut)
				{
					setMessageForFullScreen(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopSharingComp, Constants.FULLSCREEN_MSG);
					desktopViewer.desktopSharingWindow.activate();	
				}
			}
			this._transitionToBaseState("btnDesktopSharing",5,7);
			classroomComponentSgl.btnDesktopSharing.enabled = false;
		}
    }

    /**
     * The function is used to initialize the Document sharing component in consolidated mode.
     * It sets the size and visibility of the Document sharing component.
     *
     *
     * @return void
     */
    /* This function initializes the document sharing component.It checks whether the selected
    option is single window or multiple window mode and opens the window accordingly.
    It also sets the properties of the document sharing accordingly. */
    public function init_doc():void {
        docComp.userName = ClassroomContext.userVO.userName;
        docComp.presenterName = ClassroomContext.currentPresenterName;
        docComp.userRole = classroomContextObj.userRole;
        docComp.ipAddress = ClassroomContext.CONTENT_DOCUMENT;
        initdoc_flag = 1;
        docComp.width = classroomComponentSgl.docBox.width;
        docComp.height = classroomComponentSgl.docBox.height;
        classroomComponentSgl.docBox.addElement(docComp);
    }

    /**
     * The function is used to initialize the Whiteboard component in consolidated mode.
     * It sets the size and visibility of the Whiteboard component.
     *
     *
     * @return void
     */
    /* This function initializes the whiteboard component.Checks whether the selected mode is single
    window or multi window mode.Sets the properties of the white board component accordingly. */
    public function init_wb():void {
        initWb_flag = 1;
        wbComp.percentWidth = classroomComponentSgl.wbBox.percentWidth;
        wbComp.percentHeight = classroomComponentSgl.wbBox.percentHeight;
        //wbBox.numChildren==0 means there is no whiteboard object exists
        if (classroomComponentSgl.wbBox.numChildren == 0) {
            classroomComponentSgl.wbBox.addElement(wbComp);
			if ((wbComp.toolBoxContainer.y + wbComp.toolBoxContainer.height) >= wbComp.height) {
				wbComp.toolBoxContainer.x=70;
				wbComp.toolBoxContainer.y=32;
				//toolBoxContainer.stopDrag();
			}
			if ((wbComp.presenterControls.y + wbComp.presenterControls.height) >= wbComp.height) {
				wbComp.presenterControls.x=2;
				wbComp.presenterControls.y=32;
				//toolBoxContainer.stopDrag();
			}
			if ((wbComp.toolBoxContainer.x + wbComp.toolBoxContainer.width) >= wbComp.width) {
				//val=0;
				//val=(toolBoxContainer.x + toolBoxContainer.width) - this.width;
				wbComp.toolBoxContainer.x=70;
				wbComp.toolBoxContainer.y=32;
			}
			if ((wbComp.presenterControls.x + wbComp.presenterControls.width) >= wbComp.width) {
				//val=0;
				//val=(toolBoxContainer.x + toolBoxContainer.width) - this.width;
				wbComp.presenterControls.x=2;
				wbComp.presenterControls.y=32;
			}
        }
    }


    /**
     * The function is used to initialize the screen sharing component in consolidated mode.
     *
     *
     * @return void
     */
   private function init_Desktop():void {
   		//if screenSharingComp is not added to the desktopSharingBox
        if (classroomComponentSgl.desktopSharingBox.numChildren == 0) {
			applicationType::web {
                //add screenSharingComp to the desktopSharingBox
                classroomComponentSgl.desktopSharingBox.addChild(screenSharingComp);
            }
			applicationType::desktop{
				//add desktopSharingComp to the desktopSharingBox
				classroomComponentSgl.desktopSharingBox.addChild(desktopSharingComp);
			}
        }
    }

    /**
     * The function is called on clicking '3DViewer' button in multiple mode.
     *
     *
     *
     * @return void
     */
    public function multiple_3DViewer():void {
        selectedModulle = 2;
        if (selectModuleByUser) {
            setActiveWindowInSO(2);
        }
        if (viewer3D_count == 0) {
            viewer3D_count = 1;
            //CRJH: API : done ashwini
            applicationType::desktop {
                viewer3DModule = entryFac.viewer3DModule(); //new Viewer3DModule();
                viewer3DModule.open(true);
                viewer3DModule.viewer3DComp = viewer3DComp;
                viewer3DModule.viewer3DCanvas.addChild(viewer3DComp);
                viewer3DModule.userRole = classroomContextObj.userRole;
            }
            ViewerIcon3D = Viewer3D_clicked;
        } else {
            //CRJH: API : ashwini
            applicationType::desktop {
                if (!isUnInterruptedDesktopsharingON())
                    viewer3DModule.activate();
            }
        }
    }

    /**
     * The function is used to set the size of video sharing component
     */
    public function onVidShareResize():void {
	if (videoShareObj.isPopOut) {
            return;
        }
        videoShareObj.width = classroomComponentSgl.vidbox.width;
        videoShareObj.height = classroomComponentSgl.vidbox.height;
		videoShareObj.vBoxVideoPlayer.height = videoShareObj.height / 100 * 75;
        if (videoShareObj.vBoxVideoPlayer.numChildren != 0) {
            if (!videoShareObj.isLibraryVideo) {
                videoShareObj.vBoxVideoPlayer.height = videoShareObj.height / 100 * 75;
			setTimeout(videoShareObj.resizeYoutubeVideoPlayer, 300);
            } else if (videoShareObj.isLibraryVideo) {
                videoShareObj.vBoxVideoPlayer.height = videoShareObj.height / 100 * 75;
                videoShareObj.libraryVideoPlayer.percentWidth = 100;
                videoShareObj.libraryVideoPlayer.height = videoShareObj.height / 100 * 75;
            }
        }
    }

    /**
     * The function is used to set the size of desktop sharing component
     * when the component is resized in cosolidated mode.
     *
     *
     * @return void
     */
    applicationType::DesktopWeb {
        // Fix for issue #8561: Shared screen is also moving to right side when viewer do show panel 
        public function desktopSharingComponentResizeHandler():void {
			applicationType::web{
				screenSharingComp.width = classroomComponentSgl.desktopSharingBox.width;
				screenSharingComp.height = classroomComponentSgl.desktopSharingBox.height;
			}
			applicationType::desktop{
				desktopSharingComp.width = classroomComponentSgl.desktopSharingBox.width;
				desktopSharingComp.height = classroomComponentSgl.desktopSharingBox.height;
			}
        }
    }

    /**
     * The function is used to set the size of document sharing component
     * when the component is resized in cosolidated mode.
     *
     *
     * @return void
     */
// This function is used to set the size of document sharing component when the component is 
// resized in cosolidated mode. 
    public function onDocResize():void {
        if (!docComp || docComp.isPopOut)
            return;
        docComp.width = classroomComponentSgl.docBox.width - 5;
        docComp.height = classroomComponentSgl.docBox.height - 5;
		docComp.toolbarMoveHandler();
    }

    /**
     * The function is used to set the size of whiteboard component
     * when the component is resized in cosolidated mode.
     *
     *
     * @return void
     */
// The function is used to set the size of whiteboard component 
// when the component is resized in cosolidated mode. 
    public function onWbResize():void {
        if (Log.isDebug())
            log.debug("onWbResize");
        if (!wbComp)
            return;
        wbComp.percentWidth = classroomComponentSgl.wbBox.percentWidth;
        wbComp.percentHeight = classroomComponentSgl.wbBox.percentHeight;
		//Fix for Bug#18497:Start
		if (wbComp.toolBoxContainer && (wbComp.toolBoxContainer.y + wbComp.toolBoxContainer.height) >= wbComp.height) {
			wbComp.toolBoxContainer.x=70;
			wbComp.toolBoxContainer.y=32;
			//toolBoxContainer.stopDrag();
		}
		if (wbComp.presenterControls && (wbComp.presenterControls.y + wbComp.presenterControls.height) >= wbComp.height) {
			wbComp.presenterControls.x=2;
			wbComp.presenterControls.y=32;
			//toolBoxContainer.stopDrag();
		}
		if (wbComp.toolBoxContainer && (wbComp.toolBoxContainer.x + wbComp.toolBoxContainer.width) >= wbComp.width) {
			//val=0;
			//val=(toolBoxContainer.x + toolBoxContainer.width) - this.width;
			wbComp.toolBoxContainer.x=70;
			wbComp.toolBoxContainer.y=32;
		}
		if (wbComp.presenterControls && (wbComp.presenterControls.x + wbComp.presenterControls.width) >= wbComp.width) {
			//val=0;
			//val=(toolBoxContainer.x + toolBoxContainer.width) - this.width;
			wbComp.presenterControls.x=2;
			wbComp.presenterControls.y=32;
		}
		//Fix for Bug#18497:End
    }


    /**
     * This method is used to remove the Document Sharing
     * Component, while user is on whiteboard
     * This is done to get rid of straight line issues
     * during free hand drawing
     */
    public function addRemoveDocComp(operation:String):void {
        if (messageLabel && classroomComponentSgl.docBox.contains(messageLabel)) {
            return;
        }
        if (classroomComponentSgl.docBox != null && docComp != null) {
			
            if (docComp.p2fCanvas != null && (docComp.p2fCanvas.height <= 0 || docComp.p2fCanvas.width <= 0)&&!docComp.pptLoaded)
                return;

            if (operation == "add" && classroomComponentSgl.docBox.numChildren == 0) {
                docComp.isPopOut = false;
                classroomComponentSgl.docBox.addElement(docComp);
                onDocResize();
                classroomComponentSgl.docBox.invalidateDisplayList();
            } else if (operation == "remove" && classroomComponentSgl.docBox.numChildren > 0) {
                if (docComp.isPopOut) {
                    return;
                }
                if (classroomComponentSgl.docBox.contains(docComp)) {
                    classroomComponentSgl.docBox.removeElement(docComp);
                    classroomComponentSgl.docBox.invalidateDisplayList();
                }
            }
        }
    }
	
	public function clickPolling():void
	{
		//Fix for issue #19316
		setActiveWindowInSO(8);
		if(selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6 )
		{
			isQuizPollingMod = true;
		}  
	}

    /**
     * ToDO: This function is not used.
     *
     *
     * @return void.
     */
//JHCR: Though it is mentioned it is not used, it is invoked from 2 places, why?
    public function clickLiveQuiz():void {
		//Fix for issue #19316
		setActiveWindowInSO(7);
		if(selectedModule_so && selectedModule_so.getData()["val"] == 6 && selectedModulle == 6 )
		{
			isQuizPollingMod = true;
		}
        if (ClassroomContext.isModerator) {
            classroomComponentSgl.quizBox.removeAllChildren();
            //CRJH: API : done ashwini
            if (viewer3DLoaded && viewer3DComp && viewer3DComp.viewer3DSWC) {
                FlexGlobals.topLevelApplication.mainApp.stage.frameRate = 7;
                initviewer3D_flag = 1;
                viewer3DComp.viewer3DSWC.removeComponent();
                viewer3DLoaded = false;
            }
			classroomComponentSgl.btnShowViewersWall.enabled=true;
            ClassroomContext.checkIsClassRoom = true;
            classroomComponentSgl.Conso_Whiteboard.enabled = true;
            classroomComponentSgl.Conso_Doc.enabled = true;
            classroomComponentSgl.Conso_vidsharing.enabled = true;
            classroomComponentSgl.Conso_LiveQuiz.enabled = false;
            classroomComponentSgl.Conso_3DViewer.enabled = true;
            classroomComponentSgl.Conso_PollingQuiz.enabled = true;
            applicationType::DesktopWeb {
                // Enabled desktop sharing button
                classroomComponentSgl.btnDesktopSharing.enabled = true;
            }
            pollingFlag = false;
            classroomComponentSgl.Conso_2DViewer.enabled = true;
            if (classroomComponentSgl.quizBox.numChildren == 0) {
                /* To solve a UI issue in Quiz*/
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.evaluationWnd=new Evaluation();
                classroomComponentSgl.quizBox.addChild(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.evaluationWnd);
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.evaluationWnd.hBoxParent.includeInLayout = false;
                classroomComponentSgl.tab2.selectedIndex = classroomComponentSgl.tab2.getChildIndex(classroomComponentSgl.quizBox);
                evaluationFlag = true;
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.evaluationWnd.initEvaluation();
            }
            if (docComp && docComp.contextMenuList) {
                docComp.hideContextMenuList();
            }
        }
		//Fix for Bug#17799
		addRemoveDocComp("remove");
    }

    public function SetQuizSendBtnvisibility():void {
        //FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quizWnd.SetQuizSendBtnVisible();
        if (selectedModule_so == null) {
            previdx = 0;
        } else {
            previdx = selectedModule_so.getData()["val"];
        }

        if (previdx == 0) {
            click_Conso_doc();
        } else if (previdx == 1) {
            click_Conso_wb();
        } else if (previdx == 2) {
            viewer3DLoaded = false;
            //CRJH: API : done ashwini
            viewer3DComp.click_Conso_3DViewer();
        } else if (previdx == 3) {
            //CRJH: API : done ashwini
            viewer2DComp.click_Conso_2DViewer();
        } else if (previdx == 4) {
            click_Conso_vidsh();
        }
    }

//JHCR: Change the function name, PollingBtnVisibility
    /*
    //PNCR: Seems there is no polling button visibility change feature. if so please change the button name.
    // Also seems the below code is repeatedly using in some other functions. example: SetQuizSendBtnvisibility, setActiveModule
    */
    public function PollingBtnVisibility():void {
        if (selectedModule_so == null) {
            previdx = 0;
        } else {
            previdx = selectedModule_so.getData()["val"];
        }
        if (previdx == 0) {
            click_Conso_doc();
        } else if (previdx == 1) {
            click_Conso_wb();
        } else if (previdx == 2) {
            viewer3DLoaded = false;
            //CRJH: API : done ashwini
            viewer3DComp.click_Conso_3DViewer();
        } else if (previdx == 3) {
            //CRJH: API : done ashwini
            viewer2DComp.click_Conso_2DViewer();
        } else if (previdx == 4) {
            click_Conso_vidsh();
        } else if (previdx == 6) {
            showViewerWall(true);
        }
        // In web project,we use a separate tab for desktop sharing.
        applicationType::web {
            if (previdx == 5) {
                click_Conso_Desktop();
            }
        }
    }

	private function enableRecordBtn():void
	{
		classroomComponentSgl.btnRecord.enabled = true;
	}
	
	public function changeRecordIcon():void
	{
		recordIcon = startRecordIcon;
	}
    /**
     * The function is used to start and stop of recording of class
     *
     *
     * @return void
     */
// 	If the user is teacher and the button label is 'record'
// then the class is recorded. Else stop recording the class.
    public function startRecord():void {
        if (recordIcon == startRecordIcon) {
            //////////////////////////////////////////////////////////////////////////////////////
            // Before start recording, the system checks whether WAMP Server is accessible or not 
            // The method checkWAMPserver() is used to check this
            // If Server is not accessible, displays an error message
            // Issue #199 ---STARTS
            if ((videoServersData[0].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || videoServersData[0].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN || videoServersData[videoServersData.length - 1].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || videoServersData[videoServersData.length - 1].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN) && ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264) {
                Alert.show("Recording is not possible as RED5 server & High definition codec is used for the class.", "RECORDING");
                return;
            }
			classroomComponentSgl.btnRecord.enabled = false;
			stopBlink(classroomComponentSgl.btnRecord, blinkTimerIntervalForRecordBtn)
            recordIcon = stopRecordIcon;
            checkWAMPserver();
			setTimeout(enableRecordBtn, 2000);
                // Issue #199 ---ENDS
        } else {
            recordingEndEventLog();
            stopRecording();
            if (Log.isDebug())
                FlexGlobals.topLevelApplication.mainApp.log.debug("Stop Recording");
        }
    }

    /**
     *
     * @private
     * Audits the "RecordingEnd" action, when the moderator/presenter/adming ends the recording
     *
     * @return void
     *
     */
    private function recordingEndEventLog():void {
        AuditContext.userAction.createAction(AuditConstants.recordingEnd, null, null, null);
    }

    /**
     * This function used to stio blinking of  display object by startBlink() method
     * @target The display object which is  blinking
     * @blinkTimerInterval THe reference value returned by startBlink()
     * @return void.

     */
    public function stopBlink(target:DisplayObject, blinkTimerInterval:uint):void {
        target.alpha = 1;
        clearInterval(blinkTimerInterval);
    }

    /**
     * This function used to blink display object like button canvas etc
     * @target The display object which need to blink
     * @delay This determines the speed of blinking. This is timedelay in milliseconds.
     * @count Determines how many times the blinking happens. A value 0 indicates blinking contnues
     * until we stop it using stopBlink function.
     * @see stopBlink().
     * @return The value can used to stop blinking , by calling the stopBlink() method.

     */
    public function startBlink(target:DisplayObject, delay:Number, count:int):int {
        if (videoServersData[0].serverCategory.indexOf("RED5") != -1 && ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264) {
            return -1;
        }
        var interval:uint
        var loopCount:uint = 0;
        interval = setInterval(function blinkObject():void {
            if (target.alpha == 0)
                target.alpha = 1;
            else
                target.alpha = 0
            if (count > 0 && ++loopCount == count) {
                clearInterval(interval);
            }
        }, delay);
        return interval
    }

    applicationType::desktop {
        //PNCR: change name to pupoutWindowDeactivateHandler
        public function multipleWindowDeactivateHandler(event:AIREvent):void {
            activeModuleIndex = selectedModulle;
            //PNCR: what is 99. please use constants with description
            selectedModulle = 99;
        }
    }

//PNCR: change name to popoutWindowActiveHandler
    public function multipleWindowActivateHandler(module:String):void {
		changeToSimpleLayout(module);
		var obj:Object = {
		"documentMW" 	 :0
		,"whiteboardMW"  :1
		,"3dMW" 		 :2
		,"2dMW" 		 :3
		,"videoShareMW"  :4
		,"videoWallMW"   :6
		,"quickNoteMW" 	 :7
		,"youtubeLiveMW" :8};
		
		selectedModulle = obj[module];
		setActiveWindowInSO(selectedModulle);
		
		if (Log.isInfo()) log.info(module + " activate");

		if (ClassroomContext.isModerator && recorder.isRecording && recorder.whiteBoardRecorder){
			if (module == "whiteboardMW"){
				addWhiteboardTabEvent();
			}else if (module == "documentMW"){
				addDocTabEvent();
			}
		}
    }

			
    private function addDocTabEvent():void {
        if (recorder.docRecorder != null && recorder.isRecording 
			&& (docComp.p2fContainer.content != null || docComp.pptLoaded)) {
            var tempDocLength:int = recorder.docRecorder.docXml.docloaded.length();
            var tempSource:String = docComp.remoteFilePath.substr(docComp.remoteFilePath.search("/") + 1);
            var src:String = recorder.docRecorder.docXml.docloaded[tempDocLength - 1].@src;
            src = src.substr(0, src.lastIndexOf("."));
            src = src.substr(0, src.lastIndexOf("."));
            if (tempDocLength <= 0 || (tempDocLength > 0 && tempSource.substr(0, tempSource.lastIndexOf(".")) != "AVContent/Upload" + src)) {
                docComp.recordedRemoteFilePath = docComp.remoteFilePath;
                if (!docComp.pptLoaded)
                    recorder.docRecorder.addDocLoadedTag(recorder.getCentralTime(), tempSource, "p2f", docComp.remoteFileName);
                else
                    recorder.docRecorder.addDocLoadedTag(recorder.getCentralTime(), tempSource, "ispring", docComp.remoteFileName);
                recorder.docRecorder.addSizeTag(recorder.getCentralTime(), docComp.maxX, docComp.maxY, docComp.p2fWidth, docComp.p2fHeight, docComp.p2fContainer.scaleX, docComp.p2fContainer.scaleY, docComp.scrollPositionX, docComp.scrollPositionY);
                recorder.docRecorder.addPageEvent(recorder.getCentralTime(), parseInt(docComp.entPage.text));
            } else {
                recorder.docRecorder.addTabEvent(recorder.getCentralTime());
            }
        }
    }

    /**
     * The function is called on clicking 'document' button in multiple mode.
     * It initializes the document sharing component and sets the size and
     * visibility of document sharing component.
     *
     *
     * @return void
     */
// This fucntion is called when the document sharing button is clicked.
// Once a document is selected, the properties of the component is set and the document is opened.
    public function click_doc():void {
        selectedModulle = 0;
        if (selectModuleByUser) {
            setActiveWindowInSO(0);
			log.info("Document Module Clicked");
        }
        if (ClassroomContext.isModerator && recorder.isRecording && recorder.docRecorder) {
            addDocTabEvent();
        }
        if (initdoc_flag == 0) {
            init_doc();
        }
        DocumentIcon = Document_clicked;
        applicationType::desktop {
            if (!documentSharingMW || documentSharingMW.closed) {
                documentSharingMW = new DocSharing();
                documentSharingMW.docComp = docComp;
                documentSharingMW.open(true);
                documentSharingMW.width = 920;
                documentSharingMW.height = 710;
                documentSharingMW.loginname = ClassroomContext.userVO.userName;
                documentSharingMW.presenterName = ClassroomContext.currentPresenterName;

                try {
                    docComp.containerStack.y = 45;
                } catch (err:Error) {
                    if (Log.isError())
                        log.error("Error in click_doc method:" + err.getStackTrace());
                }
            } else {
                if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
                    documentSharingMW.activate();
            }
        }
    }

    private function addWhiteboardTabEvent():void {
        if (recorder.whiteBoardRecorder.whiteboardXml.page.length() > 0 && wbComp.recordedExistingContent) {
            var xml:XML = <shape><content></content></shape>
            xml.@toolName = "tab";
            xml.@ctime = recorder.getCentralTime();
            recorder.whiteBoardRecorder.addShapeTag(xml);
        } else if (!wbComp.recordedExistingContent) {
            wbComp.recordExistingContent();
        }
    }

    /**
     * The function is called on clicking 'whiteboard' button in multiple mode.
     * It initializes the whiteboard component and sets the size and
     * visibility of the whiteboard component.
     *
     *
     * @return void
     */
// This function is called when clicking 'whiteboard' in multi window mode. It sets the 
// size of the whiteboard component accordingly and also changes the whiteboard icon.
    public function click_wb():void {
        selectedModulle = 1;
        if (selectModuleByUser) {
            setActiveWindowInSO(1);
        }
        if (ClassroomContext.isModerator && recorder.isRecording) {
            addWhiteboardTabEvent();
        }
        if (initWb_flag == 0) {
            init_wb();
        }
        WhiteboardIcon = Whiteboard_clicked;
        applicationType::desktop {
            if (!whiteboardMW || whiteboardMW.closed) {
                whiteboardMW = new Whiteboard();
                whiteboardMW.open(true);
                whiteboardMW.wbComp = wbComp;
                whiteboardMW.width = 920;
                whiteboardMW.height = 710;
                whiteboardMW.presenterName = ClassroomContext.currentPresenterName;
                whiteboardMW.de = Teacher_Info_Box;
            } else {
                if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON())
                    whiteboardMW.activate();
            }
        }
    }

    public function initModules():void {


        if (ClassroomContext.aviewClass.classType == "Meeting") {
            showViewerWall();
            init_doc();

        } else if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE) {
			showViewerWall();
        }
		else
		{
			click_Conso_doc();
		}
        //CRJH: API : done soumya
        chatComp.init(this,classRoomModuleVO as ModuleRO);
        //CRJH: API : done soumya
        questionComp.init(this,classRoomModuleVO as ModuleRO);
		//To sync question added in the QuestionComponent with the UserList.Use:To show data in QuestionInterface.
		questionComp.addEventListener("QuestionSync",questionCompSyncHandler);
		if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
	        init_wb();
	        //CRJH: API : done ashwini
	        viewer3DComp.init_viewer3D();
	        viewer2DComp.init_viewer2D();
	        initVideoShare(); // ashwini: dont know why this is here
	        applicationType::DesktopWeb {
	            //Invoke init_Desktop() to initialize Desktop and Application sharing component.
	            init_Desktop();
			}
        }
        getAllContacts();

    }

    public function initVideoShare():void {
        //CRJH: API : done ashwini
        videoShareObj.width = classroomComponentSgl.vidbox.width;
        videoShareObj.height = classroomComponentSgl.vidbox.height;
        videoShareObj.userRole = classroomContextObj.userRole;
        if (!videoShareObj.isPopOut)
            addRemoveDocComp("remove");

        if (classroomComponentSgl.vidbox.numChildren == 0) {
            classroomComponentSgl.vidbox.addChild(videoShareObj);
        }
        videoShareObj.resetPlayerControls();
    }

    /**
     * This function is called from gettingToClass().
     * This initializes the Single Window Component for Single Window mode
     ***/
    public function initialiseSingleWindow():void {
        classroomComponentSgl = new ClassRoomSgl();
        classroomContainer.addChild(classroomComponentSgl);
        classroomComponentSgl.classRmActions.addChild(actionButtons);
        applicationType::web {
            // For Guest Login: Make classroom action button container invisible for guest user
            if (ClassroomContext.userVO.role == Strings.GUEST_TYPE) {
                classroomComponentSgl.classRmActions.includeInLayout=false;
                classroomComponentSgl.classRmActions.visible=false;
                classroomComponentSgl.leftPanelTabNav.bottom=0;
            }
        }
        //For showing and hiding the video,chat and user contained panel in the single window
        btnResize.verticalCenter = -45;
        //btnResize.left=290;
        btnResize.height = 26;
        btnResize.width = 12;
        btnResize.setStyle('skinClass', edu.amrita.aview.core.shared.skins.ResizeImageButtonSkin);
        btnResize.id = "hideLeftPannel";
        btnResize.setStyle('imageSkin', hideVideoPannel);
        btnResize.addEventListener(MouseEvent.MOUSE_OVER, mouse_overHandler);
        btnResize.addEventListener(MouseEvent.MOUSE_OUT, mouse_outHandler);
        btnResize.toolTip = "Hide Panel";
        btnResize.useHandCursor = true;
        btnResize.buttonMode = true;
        btnResize.addEventListener(MouseEvent.CLICK, classroomComponentSgl.hideLeftPannel_clickHandler);
        Classroom_canvas.addChild(btnResize);
        if (!ClassroomContext.IS_AUDIO_VIDEO_ENABLED) {
            classroomComponentSgl.btnRefresh.enabled = false;
            classroomComponentSgl.btnStart.enabled = false;
            classroomComponentSgl.btnRefresh.toolTip = Constants.VIDEO_MODULE_DISABLE_MSG;
            classroomComponentSgl.btnStart.toolTip = Constants.VIDEO_MODULE_DISABLE_MSG;
            classroomComponentSgl.pnlTeacher.videoBox.toolTip = Constants.VIDEO_MODULE_DISABLE_MSG;
            actionButtons.btn_handraise.enabled = false;
            actionButtons.prsntrRequestButton.enabled = false;
            actionButtons.btn_handraise.toolTip = Constants.VIDEO_MODULE_DISABLE_MSG;
            actionButtons.prsntrRequestButton.toolTip = Constants.VIDEO_MODULE_DISABLE_MSG;
            classroomComponentSgl.lblSelectedViewers.text = Constants.VIDEO_MODULE_DISABLE_MSG;
                //classroomComponentSgl.pnlTeacher.enabled = false;
        }
    }

    private function mouse_outHandler(event:MouseEvent):void {
        if (btnResize.left == 0)
            btnResize.setStyle('imageSkin', unHideVideoPannel);
        else
            btnResize.setStyle('imageSkin', hideVideoPannel);
    }

    private function mouse_overHandler(event:MouseEvent):void {
        if (btnResize.left == 0)
            btnResize.setStyle('imageSkin', unHideVideoPannel_select);
        else
            btnResize.setStyle('imageSkin', hideVideoPannel_select);
    }

    

    public function onResizeQuizWindow():void {
        applicationType::desktop {
            //CRJH: API : done ashwini
            quizObj.minWidth = quizMultiWindow.width - 150;
            quizObj.minHeight = quizMultiWindow.height - 25;
        }
    }

    public function onResizePollingWindow():void {
        applicationType::desktop {
            //CRJH: API : done ashwini
            pollingObj.minWidth = pollingMultipleWindow.width - 70;
            pollingObj.minHeight = pollingMultipleWindow.height - 25;
        }
    }

    /**
     * The function is called from Video_ScriptCode.as
     *
     *
     * @return void
     */
// This function is called from the Video_ScriptCode.as file
// If the net connection is success then this function is called.
    public function getvideo_intial():void {
        if (classroomComponentSgl) {
            classroomComponentSgl.pnlTeacher.isFullScreenPresent = false;
        }
        if (classroomContextObj.userRole == Constants.MODERATOR_ROLE) {
            pttBox.chkboxPushToTalk.visible = true;
            pttBox.chkboxPushToTalk.includeInLayout = true;
        }
    }

    /**
     * TODO: This function is not used.
     *
     * @param msg of type string
     * @return void.
     */
    public function setUserID(msg:Number):void {
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("showMessage: " + msg + "\n");
    }

    public function blinkChat(passedEvent:Object):void {

        if (chatIntervalId == 0 ){
            if (classroomComponentSgl.leftPanelTabNav.selectedIndex != 1) {
	        	chatIntervalId = setInterval(blinkChatTab, 800);
            }
        }
    }

    private function blinkChatTab():void {
        glowEffect.play([classroomComponentSgl.chatTab]);
    }

    private function blinkTaskBar():void {
        //Once a chat message comes to user there is a notificaition at his end and is done
        //by higlighting the taskbar icon with a different color. nativeWindow.notifyUser 
        //is a deafult class for notifying user when some event happens in the application
        // when the same is not in focus.
        applicationType::desktop {
            if (NativeApplication.supportsDockIcon) {
                var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
                dock.bounce(NotificationType.CRITICAL);
            } else {
                stage.nativeWindow.notifyUser(NotificationType.CRITICAL);
            }
        }
    }

    /**
     * Function is used to display a message when content server and hosting server are different.
     * @messageParent The display object
     * @message Text message which is to be displayed
     * @return void
     */
    applicationType::web {
        public function setMessageFor2D(messageParent:DisplayObjectContainer, message:String):void {
            messageLabel.text = message;
            messageParent.addChild(messageLabel);
            messageLabel.percentWidth = 100;
            messageLabel.height = 100;
            messageLabel.setStyle("textAlign", "center");
            messageLabel.setStyle("fontSize", "20");
        }
    }

    public function setMessageForFullScreen(messageParent:*, message:String, fontSize:String = "30"):void {
        messageLabel.text = message;
        messageParent.addElement(messageLabel);
        messageLabel.percentWidth = 100;
        messageLabel.height = 50;
        messageLabel.setStyle("textAlign", "center");
        messageLabel.setStyle("fontSize", fontSize);
        messageLabel.horizontalCenter = 0;
        messageLabel.verticalCenter = 0;
    }

	public function setMessageForFullScreenForChat(messageParent:*, message:String, fontSize:String = "30"):void {
		messageLabelForChat.text = message;
		messageParent.addChild(messageLabelForChat);
		messageLabelForChat.percentWidth = 100;
		messageLabelForChat.height = 50;
		messageLabelForChat.setStyle("textAlign", "center");
		messageLabelForChat.setStyle("fontSize", fontSize);
		messageLabelForChat.horizontalCenter = 0;
		messageLabelForChat.verticalCenter = 0;
	}
	public function setMessageForFullScreenForMXMLComponents(messageParent:*, message:String, fontSize:String = "30"):void {
		messageLabelForMXMLComponents.text = message;
		messageParent.addChild(messageLabelForMXMLComponents);
		messageLabelForMXMLComponents.percentWidth = 100;
		messageLabelForMXMLComponents.height = 50;
		messageLabelForMXMLComponents.setStyle("textAlign", "center");
		messageLabelForMXMLComponents.setStyle("fontSize", fontSize);
		messageLabelForMXMLComponents.horizontalCenter = 0;
		messageLabelForMXMLComponents.verticalCenter = 0;
	}
	
	public function setMessageForFullScreenForVideo(messageParent:*, message:String, fontSize:String = "30"):void {
		messageLabelForVideo.text = message;
		messageParent.addChild(messageLabelForVideo);
		messageLabelForVideo.percentWidth = 100;
		messageLabelForVideo.height = 50;
		messageLabelForVideo.setStyle("textAlign", "center");
		messageLabelForVideo.setStyle("fontSize", fontSize);
		messageLabelForVideo.horizontalCenter = 0;
		messageLabelForVideo.verticalCenter = 0;
	}
	public function unSetMessageForFullScreenForMXMLComponents(messageParent:*):void {
		if (messageParent.contains(messageLabelForMXMLComponents))
			messageParent.removeChild(messageLabelForMXMLComponents);
	}
	
	public function unSetMessageForFullScreenForVideo(messageParent:*):void {
		if (messageParent.contains(messageLabelForVideo))
			messageParent.removeChild(messageLabelForVideo);
	}
	
	public function unSetMessageForFullScreenForChat(messageParent:*):void {
		if (messageParent.contains(messageLabelForChat))
			messageParent.removeChild(messageLabelForChat);
	}
	
    public function unSetMessageForFullScreen(messageParent:*):void {
        if (messageParent.contains(messageLabel))
            messageParent.removeElement(messageLabel);
    }

    /**
     * The function is called when the setting button in class is clicked.
     * It sets the audio/video driver and the bandwidth for streaming.
     *
     *
     * @return void
     */
// This function gets invoked once the 'setting' button is clicked.
// Here we can set the video device driver,audio devide driver and the band width.
// If not set, the selected index is set to 0.
    public function setSetting():void {
        refreshDriverList();
        pop = setting(PopUpManager.createPopUp(this, setting, true));
        applicationType::desktop {
            PopUpManager.centerPopUp(pop);
        }
        applicationType::web {
            // Set popup window x and y position to fix issue (#6813) 'User can't change his bandwidth on video settings window'.
            pop.x = (stage.stageWidth / 2) - (pop.width / 2);
            pop.y = stage.stageHeight / 2.75;
        } 

        if (recordIcon == stopRecordIcon) {
            pop.chkrecordsession.enabled = false;
            //pop.chkrecordsession.selected=false;
            pop.lectureTopicValue.enabled = false;
            pop.txtkeywords.enabled = false;
            pop.txtkeywords.text = ClassroomContext.lecture.keywords;
        } else if (ClassroomContext.lecture.recordedContentUrl != null && ClassroomContext.lecture.recordedContentUrl != "" || ClassroomContext.lecture.recordedVideoFilePath != null && ClassroomContext.lecture.recordedVideoFilePath != "" || ClassroomContext.lecture.recordedPresenterVideoUrl != null && ClassroomContext.lecture.recordedPresenterVideoUrl != "" || ClassroomContext.lecture.recordedViewerVideoUrl != null && ClassroomContext.lecture.recordedViewerVideoUrl != "") {
            pop.txtkeywords.text = ClassroomContext.lecture.keywords;
        }
        if (ClassroomContext.aviewClass.classType == "Meeting") {
            pop.bandwidthSelect.selectedIndex = 2;
        }
    }

///////////////////////////////////////////////
//for solving the issue of cut off the documnt sharing contents
// we assigning the height and width of outer canvas to inner HBox
//Issue #226 ---START 
    public function resizeFunction():void {
        if (classroomComponentSgl.docBox) {
            classroomComponentSgl.docBox.width = classroomComponentSgl.canvas3.width;
            classroomComponentSgl.docBox.height = classroomComponentSgl.canvas3.height;
        }
        //CRJH: API : done ashwini
		//Fix for Bug#18497
        if (classroomComponentSgl.viewer3DBox && viewer3DComp && !viewer3DComp.isPopOut) {
            classroomComponentSgl.viewer3DBox.width = classroomComponentSgl.canvas3.width;
            classroomComponentSgl.viewer3DBox.height = classroomComponentSgl.canvas3.height;
        }
        //CRJH: API : done ashwini
        if (classroomComponentSgl.viewer2DBox && viewer2DComp) {
            viewer2DComp.setV2DWindowSize(classroomComponentSgl.canvas3.width - 15, classroomComponentSgl.canvas3.height - 40);
        }
		//Fix for local video position issue in full screen mode.
		applicationType::web{
			changeMyVideoPosision();
		}
    }

    private function glowUserTab():void {
        if (userIntervalId == 0) {
            userIntervalId = setInterval(blinkuserTab, 800)
        }
    }

    public function glowQuestionTab():void {
        if (questionIntervalId == 0) {
			if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE){
            	 if (classroomComponentSgl.leftPanelTabNav.selectedIndex != 3) {
                questionIntervalId = setInterval(blinkQuestionTab, 800)
            	}
        	}
		}
    }

    /**
     * The function is called when there is a viewer request
     * only at presenter side
     *  */
    public function handraiseNotification():void {
        if (ClassroomContext.userVO.userName == ClassroomContext.currentPresenterName) {
            if (classroomComponentSgl.leftPanelTabNav.selectedIndex != 0) {
                glowUserTab();
            }
            // Blink the task bar while recive the handraiseNotification
            blinkTaskBar();
        }
    }

    /**
     * The function is called when there is a presenter request
     * only at Moderator side
     */
    public function presenterReqNotification():void {
        if (ClassroomContext.userVO.userName == ClassroomContext.moderatorName) {
            if (classroomComponentSgl.leftPanelTabNav.selectedIndex != 0) {
                glowUserTab();
            }
            blinkTaskBar();
        }
    }

// The function is used for  chatTab blink
    private function blinkuserTab():void {
        glowEffect.play([classroomComponentSgl.userListTab]);
    }

// The function is used for  chatTab blink
    private function blinkQuestionTab():void {
        glowEffect.play([classroomComponentSgl.questionTab]);
    }

//The function is used for chat and userTab unglow
    public function onUserTabChange():void {
		applicationType::desktop{
			actionButtons.setupUserActionButtons();
		}
		applicationType::web{
			// For Guest Login: 
			if (ClassroomContext.userVO.role != Strings.GUEST_TYPE) {
				actionButtons.setupUserActionButtons();
			}
		}        
		var temp: Object = {0: "userTabUnglow", 1: "chatTabUnglow", 2: "donothing", 3: "questionTabUnglow" };
		var sanitizedIndex:int = classroomComponentSgl.leftPanelTabNav.selectedIndex % 4 ; //handle exceptions
		this[temp[sanitizedIndex]]();
    }
	public function donothing():void{
		trace ("correct, this is a totally useless function");
	}

    public function chatTabUnglow():void {
        if (chatIntervalId != 0) {
            clearInterval(chatIntervalId);
            glowEffect.stop();
            unglowEffect.play([classroomComponentSgl.chatTab]);
            chatIntervalId = 0;
        }
    }

//The function is used for Usertab Unglow
    public function userTabUnglow():void {
        if (userIntervalId != 0) {
            clearInterval(userIntervalId);
            glowEffect.stop()
            unglowEffect.play([classroomComponentSgl.userListTab])
            userIntervalId = 0;
        }
    }

//The function is used for Usertab Unglow
    public function questionTabUnglow():void {
        if (questionIntervalId != 0) {
            clearInterval(questionIntervalId);
            glowEffect.stop();
            unglowEffect.play([classroomComponentSgl.questionTab])
            questionIntervalId = 0;
        }
    }
    private var recordingMessageBox:MessageBox = null;

    private function disableRecordingButton():void {
        classroomComponentSgl.btnRecord.enabled = false;
    }

    private function setCollaborationRecordValue(objRecordDetails:Object):void {
        recordCollaborationObject.lock()
        recordCollaborationObject.setValue("record", objRecordDetails);
        recordCollaborationObject.flush();
        recordCollaborationObject.unlock();
    }


    private function stopRecording():void {
        
        var objRecordDetails:Object = new Object();
        objRecordDetails.userName = ClassroomContext.userVO.userName;
        objRecordDetails.command = "stop";
        setCollaborationRecordValue(objRecordDetails);
 		if(recorder.isRecording && getPresentersVideoConnection(0).ncVideo.connectionRetrys<1 && getViewersVideoConnection().ncVideo.connectionRetrys<1)
		{
			recordingMessageBox = MessageBox.show("Please wait while recording is stopping.");
			var currentRecordingViewer:String="";
			if(recorder.viewerVideoRecorder.currentrecordingStream!="")
			{
				currentRecordingViewer=recorder.viewerVideoRecorder.currentrecordingStream.substring(0,
					recorder.viewerVideoRecorder.currentrecordingStream.lastIndexOf("_VIEWER"));
			}
			isRecordingFailed=false;
			
			// Check whether any other means for current presenter name
			if(currentRecordingViewer !=""&& getUserSO(currentRecordingViewer) && getUserSO(currentRecordingViewer).isVideoPublishing)
			{
				recorder.viewerVideoRecorder.addEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE,onViewerVideoFileCopyHandler);
				recorder.viewerVideoRecorder.addEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR,onViewerVideoFileCopyHandler);
				if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Main-stopRecording. Calling addEndtime for viewer- Stream Name:"+currentRecordingViewer+"_VIEWER");
				stopRecordingViewer(currentRecordingViewer);
				classroomComponentSgl.btnRecord.enabled=false;
				
			}
			if(getUserSO(recorder.presenterVideoRecorder.currentrecordingStream) && 
				getUserSO(recorder.presenterVideoRecorder.currentrecordingStream).isVideoPublishing )
			{
				recorder.presenterVideoRecorder.addEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE,onPresenterVideoFileCopyHandler);
				recorder.presenterVideoRecorder.addEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR,onPresenterVideoFileCopyHandler);
				if(Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Main-stopRecording. Calling addEndtime for presenter- Stream Name:"+recorder.presenterVideoRecorder.currentrecordingStream);
				recorder.presenterVideoRecorder.addEndtime(recorder.getCentralTime(),recorder.presenterVideoRecorder.currentrecordingStream);
				classroomComponentSgl.btnRecord.enabled=false;
			}
			recorder.addEventListener(RecordingStatus.RECORDED_XML_COPY_COMPLETE,onRecordedXmlFilesCopyHandler);
			recorder.addEventListener(RecordingStatus.RECORDED_XML_COPY_ERROR,onRecordedXmlFilesCopyHandler);
			recorder.stopRecording();
			//RecordIcon=Dis_StartRecordIcon;
			
			//Bug fix Bug #5742: Issue in recording while using space bar.
			//Moved the Enabling of the record button code to a method enableRecording from here and calling the method at the end of file copying code.
			//The reason for this bug is that it's calling the buttonClick event twice. Once on the Space Bar down and on Space Bar up.
			//So we are delaying the activation of the button, so that space bar up won't be called.
			
			//wbComp.fwriteWbRec="";
			////////////////////////////////////
			// To show error message when a lecture is not recorded properly, following changes have been made
			// The following LOC is moved to RecordingAview.as to display it 
			// only when recording is done successfully
			// Also disables the button to record again until a message is shown (Success or Failure)
			// Issue #199 ---STARTS 
			// Deleted LOC: Alert.show("Your Lecture with Title: '"+can1.txtlecture.text+"' has been recorded on "+date+" successfully.");
			//record.lectureName=can1.txtlecture.text;
			
			// Issue #199 ---ENDS
		}
		else if( getPresentersVideoConnection(0).ncVideo.connectionRetrys>0 ||  getViewersVideoConnection().ncVideo.connectionRetrys>0)
		{
			//Fix for Bug # 20432 start
			recordingOnReConnectionAlert = Alert.show("Please wait while video is re-connecting.. ","RECORDING INFO");
			recordingOnReConnectionAlertTimer = new Timer(3000, 1);
			recordingOnReConnectionAlertTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hideRecordingOnReConnectionAlert); 
			recordingOnReConnectionAlertTimer.start();
			//Fix for Bug # 20432 end
		}
    }
	
	//Fix for Bug # 20432 start
	private function hideRecordingOnReConnectionAlert(event:TimerEvent) : void  
	{
		recordingOnReConnectionAlertTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, hideRecordingOnReConnectionAlert);
		if(recordingOnReConnectionAlert)
		{
			PopUpManager.removePopUp(recordingOnReConnectionAlert);
		}
		recordingOnReConnectionAlert = null;
		recordingOnReConnectionAlertTimer = null;
	}
	//Fix for Bug # 20432 end
	
//Bug fix Bug #5742: Issue in recording while using space bar.
    private function enableRecording():void {
        if (classroomComponentSgl.btnRecord.enabled && recordIcon == stopRecordIcon) {
            recordIcon = startRecordIcon;
        }
		recordIcon = startRecordIcon;
        classroomComponentSgl.btnRecord.toolTip = "Start Recording";
    }

    private function onViewerVideoFileCopyHandler(evnt:RecordingStatus):void {
        recorder.viewerVideoRecorder.removeEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE, onViewerVideoFileCopyHandler);
        recorder.viewerVideoRecorder.removeEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR, onViewerVideoFileCopyHandler);
        if (evnt.type == RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE) {
            checkRecordingSuccess();
        } else {
            removeRecordingPopupMessage();
            isRecordingFailed = true;
            Alert.show("Failed to Save Viewer Video ", "RECORDING ERROR");
            //Bug fix Bug #5742: Issue in recording while using space bar.
            enableRecording();
        }
    }

    private function onPresenterVideoFileCopyHandler(evnt:RecordingStatus):void {
        recorder.presenterVideoRecorder.removeEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE, onPresenterVideoFileCopyHandler);
        recorder.presenterVideoRecorder.removeEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR, onPresenterVideoFileCopyHandler);
        if (evnt.type == RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE) {
            checkRecordingSuccess();
        } else {
            removeRecordingPopupMessage();
            isRecordingFailed = true;
            Alert.show("Failed to Save Presenter Video ", "RECORDING ERROR");
            //Bug fix Bug #5742: Issue in recording while using space bar.
            enableRecording();
        }
    }

   /* private function onDesktopFileCopyHandler(evnt:RecordingStatus):void {
        recorder.desktopRecorder.removeEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE, onDesktopFileCopyHandler);
        recorder.desktopRecorder.removeEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR, onDesktopFileCopyHandler);
        if (evnt.type == RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE) {
            checkRecordingSuccess();
        } else {
            removeRecordingPopupMessage();
            isRecordingFailed = true;
            Alert.show("Failed to Save Desktop Video ", "RECORDING ERROR");
            enableRecording();
        }
    }*/


    private function onRecordedXmlFilesCopyHandler(evnt:RecordingStatus):void {
        recorder.removeEventListener(RecordingStatus.RECORDED_XML_COPY_COMPLETE, onRecordedXmlFilesCopyHandler);
        recorder.removeEventListener(RecordingStatus.RECORDED_XML_COPY_ERROR, onRecordedXmlFilesCopyHandler);
        if (evnt.type == RecordingStatus.RECORDED_XML_COPY_COMPLETE) {
            checkRecordingSuccess();
        } else {
            removeRecordingPopupMessage();
            isRecordingFailed = true;
            Alert.show("Failed to Save Recorded Files ", "RECORDING ERROR");
            //Bug fix Bug #5742: Issue in recording while using space bar.
            enableRecording();
        }
    }

    private function checkRecordingSuccess():void {
        if (!isRecordingFailed && !recorder.hasEventListener(RecordingStatus.RECORDED_XML_COPY_COMPLETE) && !recorder.hasEventListener(RecordingStatus.RECORDED_XML_COPY_ERROR) && !recorder.presenterVideoRecorder.hasEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE) && !recorder.presenterVideoRecorder.hasEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR) && !recorder.viewerVideoRecorder.hasEventListener(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE) && !recorder.viewerVideoRecorder.hasEventListener(RecordingStatus.RECORDED_VIDEO_COPY_ERROR)) {
            if (!classroomExited) {
                removeRecordingPopupMessage();
                Alert.show("Lecture Recorded Successfully ", "Success");

            }
            //Bug fix Bug #5742: Issue in recording while using space bar.
            enableRecording();
        }
    }

    private function removeRecordingPopupMessage():void {
        if (recordingMessageBox) {
            PopUpManager.removePopUp(recordingMessageBox)
        }

    }

    /**
     * The function is used to close the video in multiple window mode.
     *
     *
     * @return void
     */
// This function is used to close the video in multiple window mode whether the user 
// is teacher or student.
    public function close_video():void {
        isMainAppClosed = false;
        VideoIcon = Video_unclicked;

        for (var i:int = 0; i < selectedViewersData.length; i++) {
            stopSelectedViewersStream(selectedViewersData[i].userName, true);
            i = i - 1;
        }
        stopPresentersStream();
        //Issue #281--End
        try {
            applicationType::desktop {
                if (classroomComponentSgl.pnlTeacher.isFullScreenPresent) {
                    classroomComponentSgl.pnlTeacher.videoFullScreenComp.close();
                }
            }
        } catch (er:Error) {
            if (Log.isError())
                log.error("Error in close_video method:" + er.getStackTrace());
        }
    }


    private function getStatusAppender():String {
        var appender:String = "";
        if (ClassroomContext.portFMS == Constants.FMS_SERVER_PORT_FIREWALL) {
            appender = "^";
        } else if (ClassroomContext.protocolFMS == Constants.PROTOCOL_FIREWALL_FMS_SERVER) {
            appender = "*";
        }
        return appender;
    }

    public function updateStatusbar(obj:Object):void {
        switch (obj.module) {
            case "users":
                if (obj.connectionStatus) {
                    FlexGlobals.topLevelApplication.mainApp.usersStatus.text = UserConnectedMessage + getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.usersStatus.setStyle("color", "#068506");
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.text="Connected "+ getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.setStyle("color", "#068506");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("backgroundColor", "#FFFFFF");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("borderColor", "#7d817d");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusIcon = connected;
					FlexGlobals.topLevelApplication.mainApp.colabarationConnectionStatusIcon = colabarationConnected;
					
                } else {
					FlexGlobals.topLevelApplication.mainApp.usersStatus.text = UserReconnectingMessage + getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.usersStatus.setStyle("color", "#cd0606");
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.text="Reconnecting "+ getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.setStyle("color", "#cd0606");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("backgroundColor", "#FB9898");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("borderColor", "#cd0606");
					FlexGlobals.topLevelApplication.mainApp.notificationStatusContainer.visible=true;
					FlexGlobals.topLevelApplication.mainApp.connectionStatusIcon = disConnected;
					FlexGlobals.topLevelApplication.mainApp.colabarationConnectionStatusIcon = colabarationDisconnected;
					startTimer();
                }
                break;

            case "video":

                if (arrVideoConnections.length == ClassroomContext.videoConnectedCount) {
					FlexGlobals.topLevelApplication.mainApp.videoStatus.text = VideoConnectedMessage + getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.videoStatus.setStyle("color", "#068506");
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.text="Connected "+ getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.setStyle("color", "#068506");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("backgroundColor", "#FFFFFF");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("borderColor", "#7d817d");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusIcon = connected;
					FlexGlobals.topLevelApplication.mainApp.videoConnectionStatusIcon =videoConnected;
                } else {
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.text="Reconnecting "+ getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.videoStatus.text = VideoReconnectingMessage + getStatusAppender();
					FlexGlobals.topLevelApplication.mainApp.videoStatus.setStyle("color", "#cd0606");
					FlexGlobals.topLevelApplication.mainApp.connectionStatus.setStyle("color", "#cd0606");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("backgroundColor", "#FB9898");
					FlexGlobals.topLevelApplication.mainApp.connectionStatusContainer.setStyle("borderColor", "#cd0606");
					FlexGlobals.topLevelApplication.mainApp.notificationStatusContainer.visible=true;
					FlexGlobals.topLevelApplication.mainApp.connectionStatusIcon = disConnected;
					FlexGlobals.topLevelApplication.mainApp.videoConnectionStatusIcon =videoDisconnected;
					startTimer();
                }
                break;

            case "viewer3D":
                if (obj.connectionStatus) {
                   // ViewerStatus.text = Viewer3DConnectedMessage + getStatusAppender();
                   // ViewerStatus.setStyle("color", "#0505c1");
                } else {
                   // ViewerStatus.text = Viewer3DReconnectingMessage + getStatusAppender();
                   // ViewerStatus.setStyle("color", "#c10505");
                }
                break;

            case "viewer2D":
                if (obj.connectionStatus) {
                   // ViewerStatus.text = Viewer2DConnectedMessage + getStatusAppender();
                   // ViewerStatus.setStyle("color", "#0505c1");
                } else {
                  //  ViewerStatus.text = Viewer2DConnectedMessage + getStatusAppender();
                  // ViewerStatus.setStyle("color", "#c10505");
                }
                break;
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
			FlexGlobals.topLevelApplication.mainApp.notificationStatusContainer.visible=false;
			notificationTimer.stop();
		}else{
			//countDownTimerDisplay.text = Math.round((endTime - now)/1000).toString();
			notificationTimer.start();
		}
	}
	
    /**
     * TODO: This function is not used.
     */
    /* 			public function stopTimer():void
    {
    timer.removeEventListener(TimerEvent.TIMER, onTick);
    curTime=0;
    timer.stop();
    } */


    /**
     * The function is used to handle Security Error event during netconnection.
     *
     * @param event of type SecurityErrorEvent
     * @return void
     */
// The function is used to handle Security Error event during netconnection.  
    private function netSecurityError(event:SecurityErrorEvent):void {
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("netSecurityError: " + event);
    }

    private function connectSelectedModule():void {
        selectedModule_so = ClassroomContext.collaborationService.connectCollaborationObject("selectedModule");
        selectedModule_so.setOnClear(onClearSelectedModule);
        selectedModule_so.setOnSync(OnSync_selectedModule);
		

    }


	private function click_Conso_3D():void{
		viewer3DComp.click_Conso_3DViewer(); 
	}
	
	private function click_Conso_2D():void{
		viewer2DComp.click_Conso_2DViewer(); 
	}

	private function click_Conso_vw():void{
		if (ClassroomContext.currentPresenterName != null && ClassroomContext.currentPresenterName != "") 
			showViewerWall(true); 
	}


	// ashwini: synchronize all AVC active modules
	public function setActiveModuleInAVC(calledFromAVC:Boolean, module:int = -1):void{
		if(ClassroomContext.userVO.role==Constants.MONITOR_TYPE)
			return;
		// no matter who logs in, if there is an active module already set in FMS, then this user
		// should get back to that module
		var modIdxFms:int = (selectedModule_so && selectedModule_so.getData() != null) ? selectedModule_so.getData()["val"]:0;
		//Bug# 18752. Added extra conditions to check whether it is initial call or call from other modules.
		if (selectedModule_so && !selectedModule_so.getData().hasOwnProperty("val") && ClassroomContext.aviewClass.classType == "Meeting") 
			modIdxFms = 6;
		module = (module == -1)? modIdxFms : module ; 
		log.info("setActiveModuleInAVC called: passed params " + calledFromAVC + "|to:"+ module + "|fms:" + modIdxFms + "|curr:" + selectedModulle);
		trace("Class Room Component :setActiveModuleInAVC called: passed params " + calledFromAVC + "|to:"+ module + "|fms:" + modIdxFms + "|curr:" + selectedModulle);
		
		// ashwini : todo: the following lines are giving error...right now I am not able to figure out why...so will check again
		//			if (module != 1 && wbComp) 
		//				wbComp.disableRightClickMenu(); // remove the right click option; ashwini: is this needed?
		
		var funcMap:Object = {
			0 : "doc"
			,1 : "wb"
			,2 : "3D" 
			,3 : "2D" 
			,4 : "vidsh"
			,5 : "Desktop"
			,6 : "vw"
		};
		log.error("calling function : click_Conso_"+ funcMap[module]);
		if(selectedModulle != module && funcMap[module] != null)
			this["click_Conso_"+ funcMap[module]]();
	}
	
	// ashwini: set active module in the shared object
	public function setActiveWindowInSO(index:uint):void {
		// ashwini: TODO: as soon as I get a request, let me log time
		// ashwini: TODO: then timebox number of requests in a given time
		// actual condition should be that if there are too many moduleChangeReq within a certain time limit, then invoke this pause
		if (currClickCount > fastClickThreshold) { // this is incomplete, since it happens every 5 clicks and dosent take care of the frequency 
			throttleClicks(index);
			return;
		}

		currClickCount ++;
		//ashwini**** the following line is a hack for managing desktop sharing....for lack of better option, I am retaining it...however, it needs to 
		// be re-positioned
		//Fix for issue #19908
		if(selectedModulle != 5) {
			callDesktopSharingStop(index);
		}
		log.info("being asked to changed to module no: " + index);
		if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
			selectedModule_so.lock();
			selectedModule_so.setValue("val", 99);
			selectedModule_so.setValue("val", index);
			selectedModule_so.unlock();
		}
	}

	
	var fastClickThreshold:int = 6; //ashwini: magic number
	var currClickCount: int = 0;
	var timerStarted:Boolean = false;
	var throttledIndexTab:int = 0;
	private function throttleClicks(index:int):void{
		throttledIndexTab = index;
		// add pause for 5 seconds
		if (timerStarted == false){
			var myTimer:Timer = new Timer(5000,1); 
			myTimer.addEventListener(TimerEvent.TIMER, function(){
				trace ("resetting theclickcount");
				currClickCount = 0;
				timerStarted = false;
				// get current active module and send that to media server
				setActiveWindowInSO(throttledIndexTab);
			});
			myTimer.start();
			timerStarted = true;
			// ashwini: leaving the trace here, since it does not make it to the production build
			trace (">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>resetClickCount called");
		}
		// then reset click count
	}
	
	/**
	 * @Depricated : will delete after QA clears all test cases
	 * 
	 */
    public function setActiveModule(calledFromModuleSync:Boolean, module:int = -1):void {
		setActiveModuleInAVC(calledFromModuleSync, module); 
		return ;
		
		/****************************************************************
		 * ashwini: older code shown below is unused...planning to depricate this function soon.
		 */ 
		
		var modIdxFms:int = (selectedModule_so.getData() != null) ? selectedModule_so.getData()["val"]:0;
		log.info("setActiveModule called: passed params module="+ module + ", server side value=" + modIdxFms);
		if((classroomContextObj.userRole == Constants.PRESENTER_ROLE && selectedModule_so && selectedModule_so.getData()) && (selectedModule_so.getData()["val"] == 6 && isPopOutPresent)){
			// for meeting
			index = selectedModule_so.getData()["val"];
			if (index == 6 && selectedModulle == 6 && ClassroomContext.currentPresenterName != null && ClassroomContext.currentPresenterName != "") {
				//showViewerWall(true);
			}
		}
		
        if ((classroomContextObj.userRole == Constants.VIEWER_ROLE && selectedModule_so && selectedModule_so.getData()) || (calledFromModuleSync && selectedModule_so.getData())) {
            var index:int = -1;
			
            if (calledFromModuleSync) {
                index = module;
            } else {
                if (!selectedModule_so.getData().hasOwnProperty("val") && ClassroomContext.aviewClass.classType == "Meeting") {
                    index = 6;
                }
                index = selectedModule_so.getData()["val"];
            }
            if (index != 1 && wbComp) {
                wbComp.disableRightClickMenu();
            } 
            if (index > -1 && index < 5) {
                if (index == 0 && selectedModulle != 0) {
                    if (ClassroomContext.aviewClass.classType == "Meeting") {
                        // showViewerWall();
                        click_Conso_doc();

                    } else {
                        click_Conso_doc();
                    }
                } else if (index == 1 && selectedModulle != 1) {
                    click_Conso_wb();
                } else if (index == 2 && selectedModulle != 2) {
                    //CRJH: API : done ashwini
                    viewer3DComp.click_Conso_3DViewer();
                } else if (index == 3 && selectedModulle != 3) {
                    //CRJH: API : done ashwini
                    viewer2DComp.click_Conso_2DViewer();

                } else if (index == 4 && selectedModulle != 4) {
                           click_Conso_vidsh();
                }
            } else if (index == 6 && selectedModulle != 6 && ClassroomContext.currentPresenterName != null && ClassroomContext.currentPresenterName != "") {
                showViewerWall(true);
            }
            applicationType::DesktopWeb {
                // In web project,we use a separate tab for desktop sharing.
                if (index == 5 && selectedModulle != 5) {
                    click_Conso_Desktop();
                }
            }
        } 
    }

    /**
     * This function is called from the CollaborationObject/synchandler. 
	 * 
	 * ###The function is used to bring the student side
     * ###modules in sync with the teacher side.
     *
     * @param event of type SyncEvent
     * @return void
     */
    public function OnSync_selectedModule(selectedModuleData:Object):void {
//		setActiveModule(true, selectedModuleData.val );
		// ashwini: the line above was creating an infinite loop due to which modules were getting inerchangibly selected
		// need to re-do the entire thing in one shot...for now reverting to the old behaviour
        setActiveModule(false);
    }

    public function onClearSelectedModule():void {
        if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
			var index:int;
            if (selectedModule_so.getData()["val"] == null) {
                if (ClassroomContext.aviewClass.classType == "Meeting") {
                    index = 6;
                    showViewerWall();

                } else {
                    index = 0;
                }

            } else
                index = selectedModule_so.getData()["val"];

			setActiveWindowInSO(index);
        }
        setActiveModule(false);
    }
	
	//ashwini**** the following code is a hack function for managing desktop sharing....for lack of better option, I am retaining it...however, it needs to 
	// be re-positioned
	private function callDesktopSharingStop(currentIdx:int):void{
        // ashwini: localizing all the desktop-sharing hacks. moved the below line from setSelectedModuleInSO
       if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
			//if viewer switches to another module then  the teacher activate the window  again it 
			//will not call the viewer side sync since we  are setting the same value. 
			if (usersConnection) {
				applicationType::web {
					//Fix for issue #18482
					if (isDesktopSharingStarted && !isUnInterruptedDesktopsharingON() && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected) {
						//Fix for issue #18167
						unInterruptedDesktopSharingOFFMessage();
						screenSharingComp.screenSharingContainerObj.screenPublisher.stopScreenSharing();
					}
				}
				applicationType::desktop {
					//Fix for issue #18398 & #19027
					if (isDesktopSharingStarted && !isUnInterruptedDesktopsharingON() && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected) {
						//Fix for issue #18167
						unInterruptedDesktopSharingOFFMessage();
						//Fix for issue #15394
						stopDesktopSharing();
					}
				}
			}
		}
	}


	private var idServerSwitching:uint;

    private function resetServerSwitchingVariable():void {
        clearTimeout(idServerSwitching);
        if ((usersConnection) && 
			(usersConnection.isConnected()))
		{
            isServerSwitchingDone = false;
		}
        else
		{
            idServerSwitching = setInterval(resetServerSwitchingVariable, 10000);
		}
    }

    public function initiateServerSwitching():void {

        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("initiateServerSwitching");
		
		if (ClassroomContext.isModerator) 
		{
			alertServerSwitching = Alert.show("Administrator has changed the Servers for this Class. A-VIEW will now reconnect. Please restart Video/Recording/Documents and other Active Modules.", "Connection");
		}
		else 
		{
			alertServerSwitching = Alert.show("Administrator has changed the Server for this Class. A-VIEW will now reconnect.", "Connection");
		}		
		exitClassRoomForServerSwitch();
		/**
		
        if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) 
		{
            if (alertServerSwitching == null) 
			{
                alertServerSwitching = Alert.show("Administrator has changed the Server for this Class.Document, 2D or 3D models may be re-loaded, if they are no longer in display.", "Connection");
            }
			closeUserConnection();
        } 
		else 
		{
            //isServerSwitchingDone = true;
            idServerSwitching = setInterval(resetServerSwitchingVariable, 60000);
            for (var i:int = 0; i < selectedViewersData.length; i++) {
                stopSelectedViewersStream(selectedViewersData[i].userName, false);
                i = i - 1;
            }
            if (recordIcon == stopRecordIcon) {
                stopRecording()
            }
            if (alertServerSwitching == null) {
                if (ClassroomContext.isModerator) {
                    alertServerSwitching = Alert.show("Administrator has changed the Servers for this Class.Kindly reload documents or 2D /3D model which were earlier in display.Further, please do restart the recording if it was going on earlier.", "Connection");
                } else {
                    alertServerSwitching = Alert.show("Administrator has changed the Server for this Class.Document, 2D or 3D models may be re-loaded, if they are no longer in display.", "Connection");
                }
            }
            if (isVideoPublished) {
                resumePublishing = true;
                stopPublish();
            }
            applicationType::desktop {
                if (isDesktopSharingStarted) {
                    isDesktopSHaringStarted = true;
					stopSharing();
                }
            }
			trace("*************** Starting the Server Fail Over********************");
			closeUserConnection();
            for (var j:int = 0; j < arrVideoConnections.length; j++) {
                arrVideoConnections[j].connection.isConnectionDroppedManually = true;
                arrVideoConnections[j].connection.ncVideo.close();
            }
            clearInterval(connectionTimeOut);
	        enableConnectionAfterServerSwitching = new Timer(3000, 1);
            enableConnectionAfterServerSwitching.addEventListener(TimerEvent.TIMER_COMPLETE, reConnectionOnServerFailOver);
            enableConnectionAfterServerSwitching.start();           
        }
		 **/		
    }
	
	private function reConnectionOnServerFailOver(event : TimerEvent) : void
	{
		trace("***********Enter reConnectionOnServerFailOver**************");
		enableConnectionAfterServerSwitching.removeEventListener(TimerEvent.TIMER_COMPLETE, reConnectionOnServerFailOver);
		connectionClosedHandler();
		if (ClassroomContext.aviewClass.videoCodec == "VP6" || ClassroomContext.aviewClass.isMultiBitrate == "Y")
		{
			enableConnectionAfterServerSwitching = new Timer(14000, 1);
		}
		else
		{
			enableConnectionAfterServerSwitching = new Timer(4500, 1);
		}		
		enableConnectionAfterServerSwitching.addEventListener(TimerEvent.TIMER_COMPLETE, resumeCollaborationOnServerFailOver);
		enableConnectionAfterServerSwitching.start();
		trace("***********Exit reConnectionOnServerFailOver**************");
	}

	private function resumeCollaborationOnServerFailOver(event : TimerEvent) : void 
	{
		trace("***********Enter resumeCollaborationOnServerFailOver**************");
		enableConnectionAfterServerSwitching.removeEventListener(TimerEvent.TIMER_COMPLETE, resumeCollaborationOnServerFailOver);
		reConnectCollaboration();
		videoServersData = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.sessionEntry.slicingVideoServerData();
		createVideoConnection(videoServersData);
		resumePublishingAfterSwitching(event);
		trace("***********Exit resumeCollaborationOnServerFailOver**************");
	}
	
	private function reConnectCollaboration() : void
	{
		trace("***********Enter reConnectCollaboration**************");
		isCollabObjsInited = false;
		failOverCount++;
		createUsersConnection(false);
		isServerFailOver = false;
		if (!ClassroomContext.isModerator) {
			hideServerSwitchingAlert = new Timer(6000, 1);
			hideServerSwitchingAlert.addEventListener(TimerEvent.TIMER_COMPLETE, hideSwitchingAlert);
			hideServerSwitchingAlert.start();
		}
		trace("***********Exit reConnectCollaboration**************");
	}
	
    private function hideSwitchingAlert(event:TimerEvent):void {
        hideServerSwitchingAlert.removeEventListener(TimerEvent.TIMER_COMPLETE, hideSwitchingAlert);
        if (!ClassroomContext.isModerator && alertServerSwitching) {
            PopUpManager.removePopUp(alertServerSwitching);
        }
        alertServerSwitching = null;
    }

    /**
     * The function is used to handle saving of a lecture when recording starts.
     *
     *
     * @return void
     */
// This function saves the lecture when recording starts.	
    private function addtolibrarypopup():void {
        can1.str = "Recordedlectures";
        // Bug Fix for Issue #145
        PopUpManager.addPopUp(can1, this, true, null);
        PopUpManager.centerPopUp(can1);
        can1.init();
        can1.okRecordLecture.addEventListener(MouseEvent.CLICK, writeValue);
        //Now we added code to close the popup from canvaspopup
        can1.cancelRecordLecture.addEventListener(MouseEvent.CLICK, cancelRecording);
        can1.lblCourse.text = ClassroomContext.course.courseName;
        if (isRecordbyAdmin)
            can1.okRecordLecture.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        isRecordbyAdmin = false;
    }

    /**
     * The function is used to save lecture details in the database.
     *
     *
     * @return void
     */
// This function saves the lecture details in the database.
    private function addtoLibrary(lectureTopic:String, keywords:String):void {
        //RGCR: Why are we checking for all the variables?
        if (ClassroomContext.lecture.recordedContentUrl == null || ClassroomContext.lecture.recordedContentUrl == "" || ClassroomContext.lecture.recordedContentFilePath == null || ClassroomContext.lecture.recordedContentFilePath == "" || ClassroomContext.lecture.recordedPresenterVideoUrl == null || ClassroomContext.lecture.recordedPresenterVideoUrl == "" || ClassroomContext.lecture.recordedViewerVideoUrl == null || ClassroomContext.lecture.recordedViewerVideoUrl == "" || ClassroomContext.lecture.recordedVideoFilePath == null || ClassroomContext.lecture.recordedVideoFilePath == "") {
            ClassroomContext.lecture.recordedContentUrl = encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER + ":" + ClassroomContext.portWAMP + "/");
            ClassroomContext.lecture.recordedContentFilePath = "AVContent/Record/" + ClassroomContext.institute.instituteId + "/" + ClassroomContext.course.courseId + "/" + ClassroomContext.aviewClass.classId + "/" + ClassroomContext.lecture.lectureId + "/";
            ClassroomContext.lecture.recordedVideoFilePath = ClassroomContext.institute.instituteId + "/" + ClassroomContext.course.courseId + "/" + ClassroomContext.aviewClass.classId + "/" + ClassroomContext.lecture.lectureId + "/";
            ClassroomContext.lecture.recordedPresenterVideoUrl = "rtmp://" + ClassroomContext.VIDEO_RECORD_SERVER + "/vod"
            ClassroomContext.lecture.recordedViewerVideoUrl = "rtmp://" + ClassroomContext.VIEWER_VIDEO_RECORD_SERVER + "/vod"

            ClassroomContext.lecture.recordedDesktopVideoUrl = "rtmp://" + ClassroomContext.DESKTOP_SHARING_SERVER + "/vod"

            ClassroomContext.lecture.keywords = keywords;
//		ClassroomContext.lecture.lectureName=lectureTopic;
            var lectureHelper:LectureHelper = new LectureHelper();
            lectureHelper.updateLecture(ClassroomContext.lecture, ClassroomContext.userVO.userId, updateLectureResultHandler, updateLectureFaultHandler);
        }
        callcreate_flag = 1;
        automaticRecording = false;
        classroomComponentSgl.btnRecord.enabled = true;
    }

//JH-Not used
    public function updateLectureResultHandler(event:ResultEvent):void {
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("Lecture Detailes Updated Successfully");
    }

//JH-Not used
    public function updateLectureFaultHandler(event:FaultEvent):void {
        if (Log.isError())
            log.error("entry::ClassroomComponentHandler::updateLectureFaultHandler: Error while starting to record:" + AbstractHelper.getStaticFaultMessage(event));
        Alert.show("Failed to Update Record", "WARNING");
    }

    /**
     * The function is used to close the popup window used to save lecture details.
     *
     * @return void
     */
// The function is used to close the popup window used to save lecture details.  
    private function cancelRecording(eve:MouseEvent):void {
        var objRecordDetails:Object = new Object();
        objRecordDetails.userName = ClassroomContext.userVO.userName;
        objRecordDetails.command = "stop";
        setCollaborationRecordValue(objRecordDetails);

        PopUpManager.removePopUp(can1);
        recordIcon = startRecordIcon;
        classroomComponentSgl.btnRecord.enabled = true;
        classroomComponentSgl.btnRecord.toolTip = "Start Recording";
    }

    /**
     * The function is used to write the recording values of document and whiteboard into
     * xml file.Also the recording of video is started.
     *
     * @param eve of type MouseEvent
     * @return void
     */
// This function checks for the selected index and writes the value of document and whiteboard 
// accordingly.The 'recordvideo' function is called to start recording the video.
// The button label is changed to stop and the icon is also changed.
    private function writeValue(eve:MouseEvent):void {
        can1.lblLectureName.text = StringUtil.trim(can1.lblLectureName.text);
        can1.txtKeywords.text = StringUtil.trim(can1.txtKeywords.text);
        if (can1.lblLectureName.text != "" && can1.txtKeywords.text != "") {
            PopUpManager.removePopUp(can1);
            initializeRecording("manual");
        } else {
            Alert.show("Please fill the key word field for recording. Leading and trailing spaces are not valid . ", "INFO", 0, this);
        }
    }

    private function onRecordingStatus(evnt:RecordingStatus):void {
        if (evnt.type == RecordingStatus.RECORDING_INIT_COMPLETE) {
            var tempDate:Date = new Date()
            date = DateDisplay.format(tempDate);
            if (automaticRecording) {
                initializeRecording("automatic")
            } else {
                if ((ClassroomContext.lecture.recordedContentUrl == null || ClassroomContext.lecture.recordedContentUrl == "") || (ClassroomContext.lecture.recordedVideoFilePath == null || ClassroomContext.lecture.recordedVideoFilePath == "") || (ClassroomContext.lecture.recordedPresenterVideoUrl == null || ClassroomContext.lecture.recordedPresenterVideoUrl == "")) {
                    addtolibrarypopup();
                } else {
                    initializeRecording("manual");
                }
            }
        } else if (evnt.type == RecordingStatus.RECORDING_ERROR) {
            Alert.show("Unable to start recording.Please re-start the recording.", "Error");
        }
    }

    /**
     * This function is called from FMS after stream starts get recording
     */
    public function onVideoRecordingStarts(streamName:String, fileName:String):void {

    }

    private function initializeRecording(mode:String):void {
        recordingStartEventLog();
        classroomComponentSgl.btnRecord.toolTip = "Stop Recording";
        recordIcon = stopRecordIcon;
        recorder.startRecording();
        var ctime:Number = recorder.getCentralTime();
        wbComp.recordedExistingContent = false;
        handlePTTrecording();
        if (classroomComponentSgl.tab2.selectedIndex == 1) {
            recorder.whiteBoardRecorder.addPageTag(ctime, wbComp.pageNumber);
            recorder.whiteBoardRecorder.addSizeTag(ctime, wbComp.drawingArea.width, wbComp.drawingArea.height);
            wbComp.recordExistingContent();
        } else if (classroomComponentSgl.tab2.selectedIndex == 0) {
            addDocTabEvent();
        }
        //CRJH: API : done soumya
        if (chatComp.messageArea.dataProvider.length > 0) {
            for (var i:int = 1; i < chatComp.preRecordedChats.length; i++) {
                recorder.chatRecorder.recordChat(ctime, chatComp.preRecordedChats[i].msg, chatComp.preRecordedChats[i].fontSize);
            }
        }
        chatComp.preRecordedChats.splice(0);
        var acceptedStudent:String = getFirstAcceptedStudent();
        //record presenter video if he is publishing video
        if (getUserSO(ClassroomContext.currentPresenterName) && getUserSO(ClassroomContext.currentPresenterName).isVideoPublishing) {
            if (Log.isDebug())
                FlexGlobals.topLevelApplication.mainApp.log.debug("In initializeRecording: Calling recordStream for presenter; Stream Name: " + ClassroomContext.currentPresenterName);
            recorder.presenterVideoRecorder.recordStream(getPresentersVideoConnection(0).ncVideo.netConnection, "true", ClassroomContext.currentPresenterName, usersCollaborationObject.getData()[ClassroomContext.currentPresenterName].userDisplayName);
        }
        //record selected viewers video
        for (var j:int = 0; j < selectedViewersData.length; j++) {
            recordViewer(selectedViewersData[j].userName, usersCollaborationObject.getData()[selectedViewersData[j].userName].userDisplayName);
        }
       /* applicationType::desktop {
            //desktopsharing recording
            if (desktopSharingCollabObject.getData()["desktopSharing"] && desktopSharingCollabObject.getData()["desktopSharing"] != "default" && desktopSharingCollabObject.getData()["desktopSharing"].status == "started") {
                recorder.desktopRecorder.recordStream(desktopSharingConnection, "false", ClassroomContext.desktopSharingStreamName, ClassroomContext.desktopSharingStreamName, true);
            }
        }*/

        if (mode == "manual") {
            if ((ClassroomContext.lecture.recordedContentUrl == null || ClassroomContext.lecture.recordedContentUrl == "") || (ClassroomContext.lecture.recordedVideoFilePath == null || ClassroomContext.lecture.recordedVideoFilePath == "") || (ClassroomContext.lecture.recordedPresenterVideoUrl == null || ClassroomContext.lecture.recordedPresenterVideoUrl == "")) {
                //Bug Fix for Issues #24& #25
                addtoLibrary(can1.lblLectureName.text, can1.txtKeywords.text);
            } else {
                callcreate_flag = 1;
                automaticRecording = false;
                classroomComponentSgl.btnRecord.enabled = true;
            }
        } else {
            addtoLibrary(pop.lectureTopicValue.text, pop.txtkeywords.text);
        }
    }

    private function createModuleVO(appEventMap:EventMap, userVO:UserVO):void {
        classRoomModuleVO = new ModuleRO();
        classRoomModuleVO.userVO = userVO;
        classRoomModuleVO.applicationEventMap = appEventMap;
        classRoomModuleVO.moduleEventMap = new EventMap();
        classRoomModuleVO.lectureVO = ClassroomContext.lecture;
        setupEvents();
    }

    private function onClickQuestionInteractionCheckBox():void {
        // CRASH: API: TODO
//	this.dispatchEvent(new QuestionInteractionEvent((questionInteractionCheckBox.selected)?QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE:QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE)	);
    }

    public function init(appEventMap:EventMap, userVO:UserVO):void {
		
	//#Bugfix for admin logout
	if(ClassroomContext.userVO.role!=Constants.ADMIN_TYPE &&
			ClassroomContext.userVO.role!=Constants.MASTER_ADMIN_TYPE)
		{
			initNonCoreObjects();
			viewer3DComp.enable3DScene();
		}		
		
        createModuleVO(appEventMap, ClassroomContext.userVO);
        chat_count = 0;
        isVideoShareModuleAvailable = false;
        quiz_count = 0;
        polling_count = 0;
        viewer3D_count = 0;
        viewer3DInitial = false;

		// CRAS: API phase I
		//initNonCoreObjects();
        enableIcons();
        // CRASH: API
        

        getClassRepositoryFolderStructure();
        actionButtons.viewcam = true;
        actionButtons.handraise = true;
        actionButtons.presenter = true;
        actionButtons.prsntrReq = true;
		
		this.dispatchEvent(new SessionStatusEvent(SessionStatusEvent.TYPE_SESSION_ENTRY,null));
    }

    private function setupEvents():void {
//	classRoomModuleVO.moduleEventMap.registerInitiator(this,QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE);
//	classRoomModuleVO.moduleEventMap.registerInitiator(this,QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE);
//	
	classRoomModuleVO.applicationEventMap.registerInitiator(this,SessionStatusEvent.TYPE_SESSION_ENTRY);
	//This event mapping done for setting  user status to online (in ContactsController.as)
	this.classRoomModuleVO.applicationEventMap.registerInitiator(this,SessionStatusEvent.TYPE_SESSION_EXIT);
	
	classRoomModuleVO.moduleEventMap.registerMapListener(EntryFac.BREAK_SESSION_STARTED_TYPE,onBreakSessionStartedEvent);
	classRoomModuleVO.moduleEventMap.registerMapListener(EntryFac.BREAK_SESSION_ENDED_TYPE,onBreakSessionEndedEvent);
    }

    private function clearEventsCC():void {
//	classRoomModuleVO.moduleEventMap.unregisterInitiator(this,QuestionInteractionEvent.QUESTIONS_ALLOWED_TYPE);
//	classRoomModuleVO.moduleEventMap.unregisterInitiator(this,QuestionInteractionEvent.QUESTIONS_DISALLOWED_TYPE);
//
	classRoomModuleVO.moduleEventMap.registerMapListener(EntryFac.BREAK_SESSION_STARTED_TYPE,onBreakSessionStartedEvent);
	classRoomModuleVO.moduleEventMap.registerMapListener(EntryFac.BREAK_SESSION_ENDED_TYPE,onBreakSessionEndedEvent);
    }

//CRASH: API
    private function onBreakSessionStartedEvent(breakEvent):void {
		actionButtons.breakSessionObj.questionAnswerEnabledState = breakEvent.breakDetails.enableQuestions;
        onClickQuestionInteractionCheckBox();
    }


    private function onBreakSessionEndedEvent(breakEvent):void {
        //The button state is not changed after break session has started, then reverse the state after ending it
        if (breakEvent.breakDetails && (actionButtons.breakSessionObj.questionAnswerEnabledState == breakEvent.breakDetails.enableQuestions)) {
			actionButtons.breakSessionObj.questionAnswerEnabledState = !actionButtons.breakSessionObj.questionAnswerEnabledState;
            onClickQuestionInteractionCheckBox();
        }
    }

    /**
     *
     * @private
     * Audits the "RecordingStart" action, when the moderator/presenter/adming starts the recording
     *
     * @return void
     *
     */
    private function recordingStartEventLog():void {
        AuditContext.userAction.createAction(AuditConstants.recordingStart, null, null, null);
    }

    /**
     * The function is used to handle switching between whiteboard and document.
     *
     *
     * @return void
     */

    public function Changetxt():void {
		if(!docComp.isPopOut)
		{
        docComp.removeAllPopUpWndw();
		}

        if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
            applicationType::web {
				//Fix for issue #18482
                if (isDesktopSharingStarted && !isUnInterruptedDesktopsharingON() && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected ) {
					//Fix for issue #18167
					unInterruptedDesktopSharingOFFMessage();
					screenSharingComp.screenSharingContainerObj.screenPublisher.stopScreenSharing();
                }
            }
            applicationType::desktop {
				//Fix for issue #18398
				if (isDesktopSharingStarted && !isUnInterruptedDesktopsharingON() && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.netConnection.connected) {
					//Fix for issue #18167
					unInterruptedDesktopSharingOFFMessage();
					//Fix for issue #15394
					stopDesktopSharing();
                }
            }
            //Don't do any thing on Viewer side when quiz or polling clicked on Moderator's side
            if (classroomComponentSgl.tab2.selectedIndex != 7 && classroomComponentSgl.tab2.selectedIndex != 8) {
                usersConnection.netConnection.call("setSelectedModule", null, classroomComponentSgl.tab2.selectedIndex);
            }
        }
        if (classroomComponentSgl.tab2.selectedIndex > 5) {
            selectedModulle = classroomComponentSgl.tab2.selectedIndex;
        }
    }

    /**
     * TODO: This function is not used
     * The mx:buttons that are referring to this function are not visible
     *
     *@param mod of type string
     *@return void.
     */
    public function opencurrentinWindow(mod:String):void {
        applicationType::desktop {
            if (mod == "Conso_Doc") {
                if (!documentSharingMW) {
                    click_doc();
                    flag_openwin_doc = 1;
                    classroomComponentSgl.open_winDoc.label = "v"
                    classroomComponentSgl.tab2.selectedIndex = 1;
                } else {
                    flag_openwin_doc = 0;
                    docComp.p2fContainer.height = 450;
                    docComp.p2fContainer.width = 600;
                    documentSharingMW.close();
                    documentSharingMW = null;
                    docComp.width = classroomComponentSgl.docBox.width;
                    docComp.height = classroomComponentSgl.docBox.height;
                    classroomComponentSgl.docBox.addElement(docComp);
                    classroomComponentSgl.open_winDoc.label = "^"
                    classroomComponentSgl.tab2.selectedIndex = 0;
                }
            } else if (mod == "Conso_Whiteboard") {
                if (!whiteboardMW) {
                    click_wb();
                    flag_openwin_WB = 1;
                    classroomComponentSgl.open_winWB.label = "v"
                    if (!documentSharingMW) {
                        classroomComponentSgl.tab2.selectedIndex = 1;
                    } else {
                        classroomComponentSgl.tab2.selectedIndex = 0;
                    }
                } else {
                    flag_openwin_WB = 0;
                    whiteboardMW.close();
                    whiteboardMW = null;
                    wbComp.width = classroomComponentSgl.wbBox.width;
                    wbComp.height = classroomComponentSgl.wbBox.height;
                    classroomComponentSgl.wbBox.addElement(wbComp);
                    classroomComponentSgl.open_winWB.label = "^"
                    classroomComponentSgl.tab2.selectedIndex = 1;
                }
            }
        }
    }

    private function checkPretesting(event:MessageBoxEvent):void {
        isPretestingPrompt = true;
        if (event.type == MessageBoxEvent.MESSAGEBOX_YES) {
            AuditContext.userAction.pretestingLaunchEventLog("Prompt");
            pretestingDevices();
        } else {
            setSetting();
        }
    }

    public function startStopVideo(mode:String):void {
        stopBlink(classroomComponentSgl.btnRecord, blinkTimerIntervalForRecordBtn)
        videoStartButtonStatus = mode;
        applicationType::web {
            startStopVideoAfterScreenCameraCheck(mode);
        }
        applicationType::desktop {
            if ((Capabilities.os.toLowerCase().indexOf("win") > -1) && mode == "Start" && ((ClassroomContext.aviewClass.videoCodec == Constants.CODEC_VP6) || (ClassroomContext.aviewClass.isMultiBitrate == "Y" && ClassroomContext.userVO.role == Constants.TEACHER_TYPE && (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264 || ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON)))) {
                FlexGlobals.topLevelApplication.mainApp.findScreenCameraInstallationPath();
            } else {
                startStopVideoAfterScreenCameraCheck(mode);
            }
        }
    }

    public function startStopVideoAfterScreenCameraCheck(mode:String):void {
        if (isPretestingPrompt) {
            if (mode == "Start") {
                setSetting();
            } else if (mode == "Stop") {
                stopVideo();
            }
			//isPretestingPrompt = false;
        } else {
            MessageBox.show("Would you like to check your audio/video device?", "Test Audio/Video", MessageBox.MB_YESNO, this, checkPretesting, checkPretesting);
        }
    }
    applicationType::desktop {
        public function timerStartButtonEnable(event:TimerEvent):void {
            if (objPretesting) {
               /* objPretesting.lblWaitInformation.visible = false;
                objPretesting.btnAVStartChecking.enabled = true;*/
            }
            isStartAVButtonCanbeEnabled = true;
            changingButtonStatusToStart();
            ClassroomContext.isUserPublishingVideo = false;
        }
    }

    public function pretestingDevices():void {
        if (objPretesting == null) {
            objPretesting = Pretesting(PopUpManager.createPopUp(this, Pretesting, true));
            PopUpManager.centerPopUp(objPretesting);
        }
    }

    public function removingPretestingPopup():void {
        PopUpManager.removePopUp(objPretesting);
        objPretesting = null;
    }

    private function timerVideoStartHandler(event:TimerEvent):void {
        if (isSettingPopedUp)
            pop.btnStart.enabled = true;
        applicationType::desktop {
            changingButtonStatusToStart();
        }
    }

    public function restrictPublishVideo():void {
        if (ClassroomContext.aviewClass.videoCodec == "VP6") {
            if (isSettingPopedUp)
                pop.btnStart.enabled = false;
            applicationType::desktop {
                changingButtonStatusToStopping();
            }
            timerEnableStartButton = new Timer(15000, 1);
            timerEnableStartButton.addEventListener(TimerEvent.TIMER_COMPLETE, timerVideoStartHandler);
            timerEnableStartButton.start();
        }
    }

    public function removePreTestingPopUp():void {
        //Bug #5148 : Issue in setting window.
        //Change #5165 : VIdeo setting window is not opening up automatically after finishing PRE-TESTING.

        if (!isSettingPopedUp) {
            try {
                setSetting();
            } catch (er:Error) {
                if (Log.isError())
                    log.error("Error in removePreTestingPopUp method::!isSettingPopedUp:" + er.getStackTrace());
            }
        }
		else
			pop.prePopulateSettings();
		
        PopUpManager.removePopUp(objPretesting);
        try {
            if (objPretesting.ncPlayingQuestions)
                objPretesting.ncPlayingQuestions.close();
            if (objPretesting.ncPreTesting)
                objPretesting.ncPreTesting.close();
        } catch (er:Error) {
            if (Log.isError())
                log.error("Error in removePreTestingPopUp method:" + er.getStackTrace());
        }
        objPretesting = null;
    }

    /**
     * The method is to check whether the WAMP server is up or not.
     * The method is called from startRecord()
     * Using PHP script, the method checks if the given Upload.php file is there on the WAMP server or not.
     * @return void
     */
    public function checkWAMPserver():void {
        var objRecordDetails:Object = new Object();
        objRecordDetails.userName = ClassroomContext.userVO.userName;
        objRecordDetails.command = "start";
        //JH-Componentization: Don't know what to do
        setCollaborationRecordValue(objRecordDetails);
        //Searching for some file in the WAMP Server in order to verify that WAMP Server is accessible
        httpServerMonitor1 = new HTTPService();
        httpServerMonitor1.url = encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER + ":" + ClassroomContext.portWAMP + "/AVScript/Record/checkfiles.php?filename=''");

        httpServerMonitor1.addEventListener(ResultEvent.RESULT, httpServerMonitorResultHandler1);
        httpServerMonitor1.addEventListener(FaultEvent.FAULT, httpServerMonitorFaultHandler1);

        httpServerMonitor1.send();
    }

    private function httpServerMonitorResultHandler1(event:ResultEvent):void {
        if (httpServerMonitor1.hasEventListener(ResultEvent.RESULT)) {
            httpServerMonitor1.removeEventListener(ResultEvent.RESULT, httpServerMonitorResultHandler1);
        }
        if (httpServerMonitor1.hasEventListener(FaultEvent.FAULT)) {
            httpServerMonitor1.removeEventListener(FaultEvent.FAULT, httpServerMonitorFaultHandler1);
        }

        var tempFolderPath:String = ClassroomContext.institute.instituteId + "/" + ClassroomContext.course.courseId + "/" + ClassroomContext.aviewClass.classId + "/" + ClassroomContext.lecture.lectureId;
        if (ClassroomContext.VIDEO_RECORD_SERVER == ClassroomContext.VIEWER_VIDEO_RECORD_SERVER) {
            presenterVideoFolderCreateService = new HTTPService();
            presenterVideoFolderCreateStatus = "";
            viewerVideoFolderCreateStatus = "folderCreated";
            presenterVideoFolderCreateService.url = encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + ClassroomContext.portWAMP + "/AVScript/Record/createVodFolders.php?folderPath=" + tempFolderPath);
            presenterVideoFolderCreateService.addEventListener(ResultEvent.RESULT, presenterVideoFolderCreateResultHandler);
            presenterVideoFolderCreateService.addEventListener(FaultEvent.FAULT, presenterVideoFolderCreateFaultHandler);
            presenterVideoFolderCreateService.send();
        } else {
            presenterVideoFolderCreateService = new HTTPService();
            viewerVideoFolderCreateService = new HTTPService();
            presenterVideoFolderCreateStatus = "";
            viewerVideoFolderCreateStatus = "";
            presenterVideoFolderCreateService.url = encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + ClassroomContext.portWAMP + "/AVScript/Record/createVodFolders.php?folderPath=" + tempFolderPath);
            presenterVideoFolderCreateService.addEventListener(ResultEvent.RESULT, presenterVideoFolderCreateResultHandler);
            presenterVideoFolderCreateService.addEventListener(FaultEvent.FAULT, presenterVideoFolderCreateFaultHandler);
            presenterVideoFolderCreateService.send();
            viewerVideoFolderCreateService.url = encodeURI("http://" + ClassroomContext.VIEWER_VIDEO_RECORD_SERVER + ":" + ClassroomContext.portWAMP + "/AVScript/Record/createVodFolders.php?folderPath=" + tempFolderPath);
            viewerVideoFolderCreateService.addEventListener(ResultEvent.RESULT, viewerVideoFolderCreateResultHandler);
            viewerVideoFolderCreateService.addEventListener(FaultEvent.FAULT, viewerVideoFolderCreateFaultHandler);
            viewerVideoFolderCreateService.send();
        }
        //desktop sharing recording
        desktopRecordingFolderCreateService = new HTTPService();
        desktopRecordingFolderCreateStatus = "";
        desktopRecordingFolderCreateService.url = encodeURI("http://" + ClassroomContext.DESKTOP_SHARING_SERVER + ":" + ClassroomContext.portWAMP + "/AVScript/Record/createVodFolders.php?folderPath=" + tempFolderPath);
        desktopRecordingFolderCreateService.addEventListener(ResultEvent.RESULT, desktopRecordingFolderCreateResultHandler);
        desktopRecordingFolderCreateService.addEventListener(FaultEvent.FAULT, desktopRecordingFolderCreateFaultHandler);
        desktopRecordingFolderCreateService.send();
    }

    private function presenterVideoFolderCreateResultHandler(evnt:ResultEvent):void {
        presenterVideoFolderCreateService.removeEventListener(ResultEvent.RESULT, presenterVideoFolderCreateResultHandler);
        presenterVideoFolderCreateService.removeEventListener(FaultEvent.FAULT, presenterVideoFolderCreateFaultHandler);
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("presenterVideoFolderCreateResultHandler:" + evnt.result.status);
        if (evnt.result.status == true || evnt.result.status == "true" || evnt.result.status == "exists") {
            presenterVideoFolderCreateStatus = "folderCreated";
        } else {
            presenterVideoFolderCreateStatus = "failed";
        }
        checkVideoFolderStatus();
    }

    private function viewerVideoFolderCreateResultHandler(evnt:ResultEvent):void {
        viewerVideoFolderCreateService.removeEventListener(ResultEvent.RESULT, viewerVideoFolderCreateResultHandler);
        viewerVideoFolderCreateService.removeEventListener(FaultEvent.FAULT, viewerVideoFolderCreateFaultHandler);
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("viewerVideoFolderCreateResultHandler:" + evnt.result.status);
        if (evnt.result.status == true || evnt.result.status == "true" || evnt.result.status == "exists") {
            viewerVideoFolderCreateStatus = "folderCreated";
        } else {
            viewerVideoFolderCreateStatus = "failed";
        }
        checkVideoFolderStatus();
    }

    private function presenterVideoFolderCreateFaultHandler(evnt:FaultEvent):void {
        presenterVideoFolderCreateService.removeEventListener(ResultEvent.RESULT, presenterVideoFolderCreateResultHandler);
        presenterVideoFolderCreateService.removeEventListener(FaultEvent.FAULT, presenterVideoFolderCreateFaultHandler);
        resetRecorderButtonStatus();
        Alert.show("Can not create recorded video folders for Presenter.\nKindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        if (Log.isError())
            log.error("entry::ClassroomComponentHandler::presenterVideoFolderCreateFaultHandler:" + AbstractHelper.getStaticFaultMessage(evnt));
    }

    private function viewerVideoFolderCreateFaultHandler(evnt:FaultEvent):void {
        viewerVideoFolderCreateService.removeEventListener(ResultEvent.RESULT, viewerVideoFolderCreateResultHandler);
        viewerVideoFolderCreateService.removeEventListener(FaultEvent.FAULT, viewerVideoFolderCreateFaultHandler);
        resetRecorderButtonStatus();
        Alert.show("Can not create recorded video folders for Viewer.\nKindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        if (Log.isError())
            log.error("entry::ClassroomComponentHandler::viewerVideoFolderCreateFaultHandler:" + AbstractHelper.getStaticFaultMessage(evnt));

    }

    private function desktopRecordingFolderCreateResultHandler(evnt:ResultEvent):void {
        desktopRecordingFolderCreateService.removeEventListener(ResultEvent.RESULT, desktopRecordingFolderCreateResultHandler);
        desktopRecordingFolderCreateService.removeEventListener(FaultEvent.FAULT, desktopRecordingFolderCreateFaultHandler);
        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("desktopRecordingFolderCreateResultHandler:" + evnt.result.status);
        if (evnt.result.status == true || evnt.result.status == "true" || evnt.result.status == "exists") {
            desktopRecordingFolderCreateStatus = "folderCreated";
        } else {
            desktopRecordingFolderCreateStatus = "failed";
        }
        checkVideoFolderStatus();
    }

    private function desktopRecordingFolderCreateFaultHandler(evnt:FaultEvent):void {
        desktopRecordingFolderCreateService.removeEventListener(ResultEvent.RESULT, desktopRecordingFolderCreateResultHandler);
        desktopRecordingFolderCreateService.removeEventListener(FaultEvent.FAULT, desktopRecordingFolderCreateFaultHandler);
        resetRecorderButtonStatus();
        Alert.show("Can not create recorded video folders for Presenter.\nKindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        if (Log.isError())
            log.error("entry::ClassroomComponentHandler::desktopRecordingFolderCreateFaultHandler:" + AbstractHelper.getStaticFaultMessage(evnt));
    }


    private function checkVideoFolderStatus():void {
        if (presenterVideoFolderCreateStatus == "folderCreated" && viewerVideoFolderCreateStatus == "folderCreated" && desktopRecordingFolderCreateStatus == "folderCreated") {
            recorder.addEventListener(RecordingStatus.RECORDING_INIT_COMPLETE, onRecordingStatus);
            recorder.addEventListener(RecordingStatus.RECORDING_ERROR, onRecordingStatus);
            recorder.initRecording();
        } else if (presenterVideoFolderCreateStatus == "failed" || viewerVideoFolderCreateStatus == "failed" || desktopRecordingFolderCreateStatus == "failed") {
            resetRecorderButtonStatus();
            Alert.show("Cannot create recording video folders. Kindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        }
    }

    private function resetRecorderButtonStatus():void {
        var objRecordDetails:Object = new Object();
        objRecordDetails.userName = ClassroomContext.userVO.userName;
        objRecordDetails.command = "stop";
        setCollaborationRecordValue(objRecordDetails);

        classroomComponentSgl.btnRecord.toolTip = "Start Recording";
        classroomComponentSgl.btnRecord.enabled = true;
        recordIcon = startRecordIcon;
    }

    private function httpServerMonitorFaultHandler1(event:FaultEvent):void {
        if (Log.isError())
            log.error("entry::ClassroomComponentHandler::httpServerMonitorFaultHandler1:" + AbstractHelper.getStaticFaultMessage(event));
        //WAMP Server is down
        Alert.show("The Web Server for CONTENT is found not working. So the lecture can not be recorded.\nKindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        resetRecorderButtonStatus();
        automaticRecording = false;
    }

    /**
     * The method is called if the file is succesfully located.
     * The method is called from checkWAMPserver().
     * It also checks whether teacher has started his/her video.
     *
     * @param event triggers ResultEvent if some file is found in specified path.
     * @return void
     */
//RGCR: This handler is not used. Remove
    private function httpServerMonitorResultHandler2(event:ResultEvent):void {
        //WAMP Server is UP and accessible
        //Check whether teacher has started the video or not
        if (httpServerMonitor2.hasEventListener(ResultEvent.RESULT)) {
            httpServerMonitor2.removeEventListener(ResultEvent.RESULT, httpServerMonitorResultHandler2);
        }
        if (httpServerMonitor2.hasEventListener(FaultEvent.FAULT)) {
            httpServerMonitor2.removeEventListener(FaultEvent.FAULT, httpServerMonitorFaultHandler2);
        }

        recorder.addEventListener(RecordingStatus.RECORDING_INIT_COMPLETE, onRecordingStatus);
        recorder.addEventListener(RecordingStatus.RECORDING_ERROR, onRecordingStatus);
        recorder.initRecording();
    }

    /**
     * The method is called if the file is not located.
     * The method is called from checkWAMPserver()
     *
     * @param event triggers FaultEvent if no file is found in specified path.
     * @return void
     */
//RGCR: This handler is not used. Remove
    private function httpServerMonitorFaultHandler2(event:FaultEvent):void {
        if (Log.isError())
            log.error("entry::ClassroomComponentHandler::httpServerMonitorFaultHandler2:" + AbstractHelper.getStaticFaultMessage(event));
        //WAMP Server is down
        Alert.show("The Web Server for VIDEO_PRESENTER is found not working. So the lecture can not be recorded.\nKindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        if (httpServerMonitor2.hasEventListener(ResultEvent.RESULT)) {
            httpServerMonitor2.removeEventListener(ResultEvent.RESULT, httpServerMonitorResultHandler2);
        }
        if (httpServerMonitor2.hasEventListener(FaultEvent.FAULT)) {
            httpServerMonitor2.removeEventListener(FaultEvent.FAULT, httpServerMonitorFaultHandler2);
        }
        Alert.show("The recording server is found not working. So the lecture can not be recorded.\nKindly contact A-VIEW Administrator.", "Error in Recording Lecture");
        classroomComponentSgl.btnRecord.enabled = true;
        automaticRecording = false;
    }

    public function showSettingsMenu(value:String=null):void {
        //CRJH: API : done ashwini
        prefSettings = entryFac.preferenceSettings();
		prefSettings.moduleName=value;
		
        PopUpManager.addPopUp(prefSettings, this, true)
        PopUpManager.centerPopUp(prefSettings);
		prefSettings.preferenceSettingsPopup = true;
		prefSettings.prefQuest.chkBoxQuestionInteraction.selected = actionButtons.breakSessionObj.questionAnswerEnabledState;
		prefSettings.userSet.chkBoxPeopleCount.selected = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.peopleCountFlag;

        return;

        if (settingsList.height > 0) {
            settingsList.visible = false;
            settingsListClose.play();
            FlexGlobals.topLevelApplication.settingsMenuOpen = false;
        } else {
            if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
                settingsListOpen.heightTo = 225;
            } else if (classroomContextObj.userRole != Constants.PRESENTER_ROLE && ClassroomContext.userVO.userName == ClassroomContext.moderatorName) {
                settingsListOpen.heightTo = 70;

            }
            settingsList.visible = true;
            settingsListOpen.play();
            FlexGlobals.topLevelApplication.settingsMenuOpen = true;
            if (selectedViewersData.length > 1) {
                isMUISelected = true;
				actionButtons.isMUISelected = true;
                interactionMUICount = ClassroomContext.aviewClass.maxViewerInteraction;
            } else if (!prefSettings.userSet.chkBoxMultiUserInteraction.selected) {
                isMUISelected = false;
				actionButtons.isMUISelected = false;
                interactionMUICount = 1;
            }
            if (videoWallLayout == Constants.PRESENTER_LAYOUT) {
                prefSettings.vidLayout.rbPresentation.selected = true;
            } else if (videoWallLayout == Constants.MEETING_LAYOUT) {
                prefSettings.vidLayout.rbDiscussion.selected = true;
            } else {
                prefSettings.vidLayout.rbSimple.selected = true;
            }
        }

    /*if (settingsList.height > 0) {
        settingsList.visible=false;
        settingsListClose.play();
        FlexGlobals.topLevelApplication.mainApp.settingsMenuOpen=false;
    } else {
        if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
            settingsListOpen.heightTo=120;
        } else if (classroomContextObj.userRole != Constants.PRESENTER_ROLE && ClassroomContext.userVO.userName == ClassroomContext.moderatorName) {
            settingsListOpen.heightTo=70;

        }
        settingsList.visible=true;
        settingsListOpen.play();
        FlexGlobals.topLevelApplication.mainApp.settingsMenuOpen=true;
        if (selectedViewersData.length > 1) {
            isMUISelected=true;
            interactionMUICount=ClassroomContext.aviewClass.maxViewerInteraction;
        } else if (!chkBoxMultiUserInteraction.selected) {
            isMUISelected=false;
            interactionMUICount=1;
        }
    }*/
    }

//*******************************************Server Switching*****************************
    private function resumePublishingAfterSwitching(event:TimerEvent):void {
        enableConnectionAfterServerSwitching.removeEventListener(TimerEvent.TIMER_COMPLETE, resumePublishingAfterSwitching);
        if (ClassroomContext.isModerator)
            alertServerSwitching = null;
        if (resumePublishing) {
            setPublishingBandwidth()
            resumePublishing = false;
            publishVideo();
        }
        if (isDesktopSharingStarted) {
            isDesktopSharingStarted = false;
            restartDesktopSharingTimeoutId = setTimeout(restartDesktopSharing, 100);
        }
        setTimeout(enableVideoWall, 1000);
    }

    private function enableVideoWall():void {
        refreshVideo();
    }

    applicationType::desktop {
        private function windowMinimize(event:NativeWindowDisplayStateEvent):void {
            if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
                if (docComp)
					docComp.windowMinimized = true;
            } else {
                if (docComp)
                    docComp.windowMinimized = false;
            }
        }
    }

//******************Multiple User Interaction(MUI)************************

	public function showViewerWall(isCalledFromBtnWall:Boolean=false):void 
	{
		
		
		if(!isLayoutSOInitialized && ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			setTimeout(showViewerWall, 500);
			return;
		}
		if(ClassroomContext.aviewClass.classType=="Meeting" && !isCalledFromBtnWall && (ClassroomContext.currentPresenterName != "" || ClassroomContext.currentPresenterName == "" && videoWallCollaborationObject.getData()["videoWallLayout"]==Constants.SIMPLE_LAYOUT) && videoWallCollaborationObject.getData()["isSelected"]==false && (videoWallCollaborationObject.getData()["videoWallLayout"]==undefined || videoWallCollaborationObject.getData()["videoWallLayout"]==Constants.SIMPLE_LAYOUT))
		{
			return;
		}
		if( usersConnection &&!usersConnection.netConnection.connected && ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			CustomAlert.customMessage("Your connection to server is lost. Please wait till it reconnects automatically.","WARNING");
			return;
		}
		if(videoWallLayout == Constants.SIMPLE_LAYOUT && ClassroomContext.userVO.role != Constants.MONITOR_TYPE)
		{
			if(videoWallCollaborationObject.getData()["videoWallLayout"] != Constants.SIMPLE_LAYOUT)
				defaultVideoWallLayout = videoWallCollaborationObject.getData()["videoWallLayout"];
			else
				defaultVideoWallLayout = videoWallCollaborationObject.getData()["prevVideoWallLayout"];
			if(defaultVideoWallLayout == null)
			{
				if(ClassroomContext.aviewClass.classType=="Meeting")
					defaultVideoWallLayout = Constants.MEETING_LAYOUT;
				else
					defaultVideoWallLayout = Constants.PRESENTER_LAYOUT;
			}
			videoWallLayout = defaultVideoWallLayout;
		} 
		if(ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
			videoWallLayout = Constants.MEETING_LAYOUT;
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.showViewerWall start");
		this._transitionToBaseState("btnShowViewersWall",6);
		if(classroomContextObj.userRole == Constants.PRESENTER_ROLE)
		{
     			setVideoWallLayout(videoWallLayout);
		}
		else
		{
			layOutDataChange(); 
		}
		
		applicationType::desktop 
		{
			if( FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC)
			{
				
				//Alert.show("enter");
				
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initviewer3D_flag=0;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeComponent();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=false;
			}
			
			//fix for #15770
			if(isPopOutPresent)
			{
				if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON()) 
					videoWallWindow.activate();
				
			}
			else
			{
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON()) //Bug #10482
				//Fix for issue #18757
				if (desktopViewer.isPopOut){
					desktopViewer.desktopSharingWindow.alwaysInFront = true;
					desktopViewer.desktopSharingWindow.open(true);
				}
				FlexGlobals.topLevelApplication.mainApp.windowApp.activate();
		}
		}
		if (Log.isDebug()) FlexGlobals.topLevelApplication.mainApp.log.debug("Video.showViewerWall end");
	}

    private function callVideoSizeFunction():void {
        objMeetingVideoWall.onVideoTileResize();
    }


//************************************Close********************************


    /**
     * The method is invoked when moderator becomes a viewer.
     * This is invoked from Users.as (synchandler function setPresenterAndModerator())
     * This stops the recording if recording is going on.
     *
     * @param moderatorStaus, this is true when moderator is the presenter and is false when he is a viewer
     * @return void
     */

    public function stopRecordingForModerator():void {
    /* if(recorder.isRecording)
    {
    Alert.show("Recording will be stopped and saved automatically.", "Recording information", 0, null, stoprecording_closeapp);
    } */
    }

    /**
     * The function is used to save a recording if application window is closed
     * when recording is happening.
     *
     *
     * @return void
     */
// The function is used to save a recording if application window is closed when recording is 
// happening.It then calls the 'startRecord' function.   
    public function stoprecordingAndExitClassroom(eve:CloseEvent):void {
        closeFlag_record = 1;
        //No need to call stop recprding when no network connection
        if (getPresentersVideoConnection(0).ncVideo.isConnected() < 1 || getViewersVideoConnection().ncVideo.isConnected() < 1) {
            stopRecording();
        }
        processExitClassroom();
    }

	/**
	 * This exit function is called for Server Switching.
	 *
	 * @return void
	 */
	public function exitClassRoomForServerSwitch():void {
		if ((getPresentersVideoConnection(0) && getPresentersVideoConnection(0).ncVideo && getPresentersVideoConnection(0).ncVideo.isConnected() < 1) || 
			(getViewersVideoConnection() && getViewersVideoConnection().ncVideo && getViewersVideoConnection().ncVideo.isConnected() < 1)) 
		{
			trace("stop recording");
			stopRecording();
		}
		exitContext="closeOnServerSwitch";
		applicationType::DesktopWeb{
			AuditContext.userAction.connectionFailEventLog("Collaboation Module", usersConnection.connectionURL);			
		}
		processExitClassroom();
	}

    /**
     * The function is used to to given an alert if application window is closed
     * when recording is happening or Presenter is interacting with the Viewer.
     *
     *
     * @return void
     */
    public function exitClassroomConfirmation():void {

        this.classRoomModuleVO.moduleEventMap.registerInitiator(this, SessionStatusEvent.TYPE_SESSION_EXIT);
		
        this.dispatchEvent(new SessionStatusEvent(SessionStatusEvent.TYPE_SESSION_EXIT, null));

        if (recorder && recorder.isRecording) {
            if (getPresentersVideoConnection(0).ncVideo.isConnected()  && getViewersVideoConnection().ncVideo.isConnected()) {
                Alert.show("Recording is still going on and it will be saved automatically", "Recording information", 0, null, stoprecordingAndExitClassroom);
            } else {
                Alert.show("Application is not connected to server. You may loose some portion of the recorded data", "Recording information", 0, null, stoprecordingAndExitClassroom);
            }
        } else {
            processExitClassroom();
        }
    }

    /**
     * This function shows messsage about the action happening when
     * application is in disabled state
     */
    public function processExitClassroom():void {
        FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg = new spark.components.Label();
        //CRJH: API : done soumya
        applicationType::desktop {
			//#Bugfix for admin logout
            if (chatComp && chatComp.isPopOut) {
				chatComp.popChatWindow();
            }
        }

        switch (exitContext) {
            case "close":
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "Closing application in progress...";
                break;
            case "logout":
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "Log out in progress...";
                break;
			case "closeOnServerSwitch":
				//When the user exits the class/logs out etc, we need to close all the chat windows
				// CRASH: API done(soumya)
				this.dispatchEvent(new ChatEvent(ChatEvent.EXIT_ALL_CHATS));
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "Server reconnection in progress...";
				break;				
            case "exitClassroom":
                //When the user exits the class/logs out etc, we need to close all the chat windows
                // CRASH: API done(soumya)
                this.dispatchEvent(new ChatEvent(ChatEvent.EXIT_ALL_CHATS));
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "Classroom exit in progress...";
                break;
            case "endMeeting":
                //When the user exits the class/logs out etc, we need to close all the chat windows
                //CRASH: API done(soumya)
                this.dispatchEvent(new ChatEvent(ChatEvent.EXIT_ALL_CHATS));
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "Session end in progress...";
                break;
        }
        if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp) {
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.addElement(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg);
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.setStyle("fontSize", "20");
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.setElementIndex(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg, this.numChildren - 1)
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.percentWidth = 100;
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.setStyle("textAlign", "center");
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.horizontalCenter = 0;
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.verticalCenter = -30;
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.unSubscribeClassServerChangeConsumer();
            FlexGlobals.topLevelApplication.mainApp.mainContainerComp.enableDisableMainWindowButtons("FlexGlobals.topLevelApplication.mainApp.mainContainerComp.btnContacts", true);
			if(ClassroomContext.isModerator)
				setAudioMuteSOValue(null);
//			MainApp.mainContainerComp.btnMeeti
        }
        this.enabled = false;
        classroomExited = true;
		//Fix for bug # 18492 start
		//Check added due to null pointer exception
		if(docComp)
		{
			docComp.uploadStatus=false;
		}
		//Fix for bug # 18492 end
        AuditContext.userAction.insertPendingActionsWhileExitingClassroom();
        AuditContext.lecture.auditLectureExit();

		if(viewer3DComp && viewer3DComp.viewer3DSWC && viewer3DComp.viewer3DSWC.waterDemo )
		{
			viewer3DComp.viewer3DSWC.waterDemo.removeWaterDemo();	
		}		
		
        //CRJH: API : done ashwini
        if (viewer3DComp && viewer3DComp.viewer3DSWC && viewer3DComp.viewer3DSWC.objectDetails != null)
		{
            if (viewer3DComp.viewer3DSWC.objectDetails.length > 0) 
			{
                viewer3DComp.viewer3DSWC.reset3DViewer();
            }
        }
        //CRJH: API : TODO
        if (viewer2DLoaded) {
          
            viewer2DComp.dispatchEvent( entryFac.getV2DEvent(EntryFac.MODULE_CLOSE, null));
        }
        closingApplication();
		clearInterval(clearPeopleCountTimeOut);
        clearInterval(connectionTimeOut);
        if (enableConnectionAfterServerSwitching) {
            enableConnectionAfterServerSwitching.stop();
        }
		// If we are closing due to server switch, don't stop this timer here.
        if (exitContext != "closeOnServerSwitch" && hideServerSwitchingAlert) {
            hideServerSwitchingAlert.stop();
        }
        if (timerSocket) {
            timerSocket.stop();
        }

        //Removing EventListeners starts here-----
        //Remove closing event for the app
        applicationType::desktop {
            FlexGlobals.topLevelApplication.mainApp.removeEventListener(Event.CLOSING, closingApplication);
        }
        clearTimeout(connectionTimeOut);
        //Remove Chat sync Event
        if (selectedModule_so) {
            selectedModule_so.removeOnSync();
            selectedModule_so.removeOnClear();
        }
		;
		
        //Remove Video Sharing eventListeners
        //CRJH: API : done ashwini
        if (videoShareObj && videoShareObj.playHeadUpdateTimer && videoShareObj.playHeadUpdateTimer.hasEventListener(TimerEvent.TIMER))
            videoShareObj.playHeadUpdateTimer.removeEventListener(TimerEvent.TIMER, videoShareObj.playheadUpdateTimerHandler);
        if (videoShareObj && videoShareObj.videoStatusCollaborationObject) {
            videoShareObj.videoStatusCollaborationObject.removeOnSync();
			videoShareObj.videoStatusCollaborationObject.removeValue(ClassroomContext.userVO.userName);
            ClassroomContext.collaborationService.closeCollaborationObject("VideoStatus");
        }
        if (videoShareObj && videoShareObj.videoCommandCollaborationObject) {
            videoShareObj.videoCommandCollaborationObject.removeOnSync();
            ClassroomContext.collaborationService.closeCollaborationObject("VideoCommand");
        }

        if (videoWallCollaborationObject) {
            videoWallCollaborationObject.removeOnClear();
            videoWallCollaborationObject.removeOnChangeProperty("selectedUser");
            videoWallCollaborationObject.removeOnChangeProperty("selectedStreamName");
            videoWallCollaborationObject.removeOnChangeProperty("isSelected");
			videoWallCollaborationObject.removeOnChangeProperty("videoWallLayout");
			if (ClassroomContext.collaborationService != null)
				ClassroomContext.collaborationService.closeCollaborationObject("videoWallSharedObject");
        }
        if (recordCollaborationObject) {
            recordCollaborationObject.removeOnClear();
            recordCollaborationObject.removeOnChange();
            if (ClassroomContext.collaborationService != null) {
                ClassroomContext.collaborationService.closeCollaborationObject("recordSharedObj");
            }
        }
        if (muiCollaborationObject) {
            muiCollaborationObject.removeOnClear();
            muiCollaborationObject.removeOnChange();
            if (ClassroomContext.collaborationService != null) {
                ClassroomContext.collaborationService.closeCollaborationObject("muiSharedObj");
            }

        }

        //Removing EventListeners ends here-----

        classroomSessionCloseHandler();

        // Connection closing should be given enough time to perform various actions before closing, such as deleting the cache files etc.
        setTimeout(closeClassroomSession, 500);
        //					}
        //RGCR: This method is called during the class entry..that's how all the values are reset
        //	ClassroomContext.resetClassroomContextValues();

        //Remove snapshot component
        try {
            //CRJH: API : done ashwini
			//if (ClassroomContext.SYSTEM_PARAMETERS["EnablePhotoCapture"] == "Yes" && ClassroomContext.userVO.photoCaptureFrequencySecs > 0 && snapshotObj != null && snapshotObj.snapshotTimer.running) {
            if (ClassroomContext.aviewClass.canMonitor == "Yes" && ClassroomContext.aviewClass.monitorIntervalFreq > 0 && snapshotObj != null && snapshotObj.snapshotTimer.running) {
                removeSnapshotComp();
            }
        } catch (er:Error) {
            if (Log.isError())
                log.error("Error in processExitClassroom method:" + er.getStackTrace());
        }
   }

    /**
     * This function perform the action needed (exit classroom or logout or close), closes the connections etc..
     * and clears the message.
     */
    public function closeClassroomSession():void {
		if(!isServerFailOver)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "";
		}
		clearEventsCC();
        applicationType::web {
            // SSO Entry: Clear flash vars and ssoMode value.
            FlexGlobals.topLevelApplication.parameters.lrid = "";
            FlexGlobals.topLevelApplication.mainApp.ssoMode = "";
        }
		//PNCR: called closeVideoWall before setting classroomComp = null, otherwise it will throw error in closeVideoWall function.
		closeVideoWall(true);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.removeEndSessionListener();
        switch (exitContext) {
            case "close":
                //RGCR: When the close button is pressed, first we need to logout and then close.
                FlexGlobals.topLevelApplication.mainApp.closeApp();
                break;
            case "logout":
                applicationType::web {
                // SSO Entry: Clear flash vars value
                	FlexGlobals.topLevelApplication.parameters.uname = "";
                	FlexGlobals.topLevelApplication.parameters.pwd = "";
            	}
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classRoomContainer.removeAllChildren();
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp = null;
				ClassroomContext.resetClassroomContextValues();
                FlexGlobals.topLevelApplication.mainApp.switchToLoginScreen();
                break;
			case "closeOnServerSwitch":
				if (alertServerSwitching) 
				{
					PopUpManager.removePopUp(alertServerSwitching);
				}
				alertServerSwitching = null;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classRoomContainer.removeAllChildren();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp = null;
				ClassroomContext.lecturePriorToFailOver = ClassroomContext.lecture;
				ClassroomContext.userRolePriorToFailOver = classroomContextObj.userRole;
				ClassroomContext.publishingVideoStatusPriorToFailOver = latestPublishStatus;
				ClassroomContext.resetClassroomContextValues();
				enableConnectionAfterServerSwitching = new Timer(1000, 1);
				enableConnectionAfterServerSwitching.addEventListener(TimerEvent.TIMER_COMPLETE, gettingToClassOnServerFailOver);
				enableConnectionAfterServerSwitching.start();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.navigation("btnClassroom");
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.todaysLectures.refresh();
				break;
            case "exitClassroom":
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classRoomContainer.removeAllChildren();
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp = null;
				ClassroomContext.resetClassroomContextValues();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.navigation("btnClassroom");
                //FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.todaysLectures.refresh();
                break;
            case "endMeeting":
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classRoomContainer.removeAllChildren();
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp = null;
                ClassroomContext.resetClassroomContextValues();
                FlexGlobals.topLevelApplication.mainApp.mainContainerComp.navigation("btnClassroom");			
                break;
        }
	

        userConnectionCloseTimeOutID = setTimeout(closeUserConnection, 100);
        //CRJH: API : done ashwini
        viewer3DComp = null;
		if(viewer2DComp!=null)
		{
        	viewer2DComp.removeViewer2DComponent();
		}
        viewer2DComp = null;
        docComp = null;
        wbComp = null;
        //CRJH: API : done ashwini 
        quizObj = null;
        pollingObj = null;
        //CRJH: API : done ashwini 
        videoShareObj = null;
        objVideoWall = null;
        objMeetingVideoWall = null;
        if (labelMsg != null)
            labelMsg.text = "";

        clearEvents();
    }

	private function gettingToClassOnServerFailOver(event : TimerEvent) : void
	{
		//ClassroomContext.lecture = ClassroomContext.lecturePriorToFailOver;
		enableConnectionAfterServerSwitching.removeEventListener(TimerEvent.TIMER_COMPLETE, gettingToClassOnServerFailOver);
		//var sessionEntry : SessionEntry = new SessionEntry();
		//sessionEntry.getClassRoomLecture(ClassroomContext.lecturePriorToFailOver.lectureId);
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.sessionEntry != null)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.sessionEntry.getClassRoomLecture(ClassroomContext.lecturePriorToFailOver.lectureId);	
		}
		ClassroomContext.lecturePriorToFailOver = null;
		if(ClassroomContext.publishingVideoStatusPriorToFailOver)
		{
			enableConnectionAfterServerSwitching = new Timer(1000, 1);
			enableConnectionAfterServerSwitching.addEventListener(TimerEvent.TIMER_COMPLETE, startVideoOnServerFailOver); 
			enableConnectionAfterServerSwitching.start();
		}
	}
	
	private function startVideoOnServerFailOver(event : TimerEvent) : void
	{
		isServerFailOver = false;
		ClassroomContext.publishingVideoStatusPriorToFailOver = false;
		ClassroomContext.userRolePriorToFailOver = "";
		enableConnectionAfterServerSwitching.removeEventListener(TimerEvent.TIMER_COMPLETE, startVideoOnServerFailOver);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.labelMsg.text = "";
		//callVideo();		
	}
	
    public function classroomSessionCloseHandler():void {
        //Logout time is set on the server side.
        //AuditContext.login.updateAuditUserLogin(AuditContext.userLoginVO);
        if (classroomComponentSgl) {
            addRemoveDocComp("add"); //for clean shut down
        }
        closeAllFullScreens();
        applicationType::desktop {
            //CRJH: API (soumya)
            if (chatComp && chatComp.isPopOut) {
                chatComp.chatPopComp.close();
            }
            if (documentSharingMW) {
                if (documentSharingMW.docComp) {
                    documentSharingMW.docComp.clearServer();
                    documentSharingMW.close();
                    documentSharingMW == null;
                }
            }
		if(isPopOutPresent)
		{
			videoWallWindow.close();
			isPopOutPresent = false;
			buttonContainer.popOutWindow(isPopOutPresent);
			videoWallWindow.removeEventListener(Event.CLOSE, popOutWindowCloseEvent);
			unSetMessageForFullScreen(classroomComponentSgl.viewerVideoWallBox);
		}
        }
        isVideoWallSOReconnected = false;
        if (viewer3DInitial || viewer3D_count == 1) {
            //CRJH: API : done ashwini
            if (viewer3DComp && viewer3DComp.viewer3DSWC && viewer3DComp.viewer3DSWC.clearServerDetails) {
                viewer3DComp.viewer3DSWC.clearServer();
            }
            //CRJH: API done ashwini
            applicationType::desktop {
                if (viewer3DModule) {
                    viewer3DModule.close();
                }
            }
        }
        //PNCR: already dispatched in fn processExitClassroom before calling current function. same for 3D also. Can remove the 2D and 3D dispatch from here. 
        //But there are other fncalls only to the current function. if possible change those to processExitClassroom, then it will more clear function flow.
        //CRJH: API : TODO (ashwini)
        if (viewer2DLoaded) {
            
            viewer2DComp.dispatchEvent(entryFac.getV2DEvent(EntryFac.MODULE_CLOSE, null));
        }

        if (Log.isDebug())
            FlexGlobals.topLevelApplication.mainApp.log.debug("Cleaning Whiteboard");
        if (wbComp != null) {
            applicationType::desktop {
                if (wbComp.whiteBoardFullWndw) {
                    wbComp.whiteBoardFullWndw.close();
                }
            }
            wbComp.resetWhiteboard();
        }
        applicationType::desktop {
            if (whiteboardMW) {
                whiteboardMW.close();
                whiteboardMW = null;
            }
        }

        //CRJH: API : done ashwini
        if (videoShareObj!=null)
		{
			//#Bugfix for 15751 starts
			applicationType::desktop {
				if(videoShareObj.isPopOut)
				{
					videoShareObj.closeVideoSharingWindow();
				}
			}
			//#Bugfix for 15751 ends
			if(videoShareObj.videoURL != "" && (videoShareObj.videoStatus != Constants.VIDEO_COMMAND_LOAD)) {
            	videoShareObj.resetVideoSharing();
			}
        	else if(ClassroomContext.userVO.role != Constants.MONITOR_TYPE) {
            	videoShareObj.clearVideoSharingProperties();
		 	}
			
        }
        //CRJH: API : done ashwini
        applicationType::desktop {
            if (quiz_count == 1) {
                quizMultiWindow.close();
            }
            if (polling_count == 1) {
                pollingMultipleWindow.close();
            }
        }
        if (docComp) {
            docComp.removeEventHandlers();
            docComp.closeDocumentCollaborationObject();
            applicationType::desktop {
                if (docComp.documentSharingMW) {
                    docComp.documentSharingMW.close();
                }
            }
            docComp.clearServer();
            if (classroomContextObj.userRole == Constants.PRESENTER_ROLE)
                docComp.clearServer();
            if (Log.isDebug())
                FlexGlobals.topLevelApplication.mainApp.log.debug("Calling Document Sharing server disconnect");
        }
		if(chatComp)
		{
			chatComp.closeCollaborationObject();
		}
        try {
            // terminate ScreenCamera hidden application 
            launchScreenCamera("0");
        } catch (err:Error) {
            if (Log.isError())
                log.error("Error in classroomSessionCloseHandler method:" + err.getStackTrace());
        }
        applicationType::web {
            // Stop Desktop/Application sharing
            if (classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
                // Added this check to avoid application crash issue in Safari browser  
                if (isDesktopSharingStarted) {
                    screenSharingComp.screenSharingContainerObj.screenPublisher.stopScreenSharing();
                    // Bug fix for issue #8019
                    sendDesktopSharingStatus("stopped");
                }
                // Added this check to avoid null object reference issue, if user reload/close the browser when user is in login page
                if (screenSharingComp) {
                    // Remove desktop sharing event listeners
                    screenSharingComp.screenSharingContainerObj.removeDesktopSharingEventListeners();
                }
            }
        }
        applicationType::desktop {
            //Stop Desktop sharing
            if (selectedSharingMode == 0) {
                closeDesktopSharing();
            } else if (selectedSharingMode == 1) {
                stopApplicationSharing();
            }
            //Close DesktopViewer popup window component
            closeDesktopViewer();
        }
        removeAllEventListners();
        stopPublishToYoutubeLive();
		//SM:#Bugfix for 14732 starts
		disconnectAdminSharedObject();
		//SM:#Bugfix for 14732 ends
    }
    private function disconnectAdminSharedObject():void
	{
		if(adminConsoleCollabObject)
		{			
			adminConsoleCollabObject.removeValue(ClassroomContext.userVO.userName);  
			ClassroomContext.collaborationService.closeCollaborationObject("adminSharedObj");
		}
	}


    applicationType::web {
        /**
         * @public
         *  This function is used to avoid local video move issue when user resize the browser.
         *
         *
         * @return void
         */
        public function resizeLocalVideo():void {
            if (myVideo) {
                //Added this check to avoid the unwanted alert message("Audio Only mode doesn't have fullscreen option") when user publish his audio and resize the browser.
                if (!ClassroomContext.isAudioOnlyMode) {
                    //Set local video height as application height.
                    myVideo.appHeight = stage.stageHeight;
                    //Set true when user resizes the browser window.
                    IsApplicationResized = true;
                    //Restore the local video while user maximizing/restoring the browser window, when user viewes local video in normal mode with restored/maximized browser window.
					//Fix for issue #17249
                    if (myVideo.width == 188 && myVideo.height == 184) {
                       //Added this function to avoid null object reference issue when user resize the browser
						FlexGlobals.topLevelApplication.mainApp.popupWindow_moveHandler(myVideo);
                    }
					//Fix for issue #18028
					else if(myVideo.width == 188 && myVideo.height == 52){
						return;
					}
                    //Maxmize the local video while user maximizing/restoring the browser window, when user viewes local video in full screen mode with restored/maximized browser window.
                    else {
                        myVideo.isResized = false;
                        myVideo.localVideoFullScreen();
                    }
                }
            }
			//Fix for issue #18494
			if(classroomComponentSgl){
				classroomComponentSgl.width = classroomContainer.width;
				classroomComponentSgl.height = classroomContainer.height;
			}
        }
    }

//////Youtube Live/////////////
    // ashwini : push all the youtube code to entry public module
    /**
     * Variable of custom popup component YoutubeLiveSettings for accepting live youtube streaming details (RTMPURL,Stream name ).
     */
//CRJH: API : done ashwini
    private var youtubeLiveSettingsPopUp;
    applicationType::desktop {
        /**
         * NativeProcess variable for handling external process (OBS-OpenBroadcaster) for capturing desktop & streaming to youtube.
         */
        private var nativeProcessOBS:NativeProcess;
    }
    /**
     * Variable for storing the status of live youtube streaming,whether it is started or not.
     */
    public var isYoutubeLiveStarted:Boolean = false;
    /**
     * Variable for storing the status of YoutubeLiveSettings popup,whether it is created or not.
     */
    public var isYoutubeLivePopupCreated:Boolean = false;

    /**
     * @public
     * The function for creating the YoutubeLiveSettings popup.
     *
     *
     * @return void
     */
    public function createYoutubeLiveSettingsPopUp():void {
        FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multipleWindowActivateHandler("youtubeLiveMW");
        //Create the YoutubeLiveSettings popup if not created
        if (!isYoutubeLiveStarted && !isYoutubeLivePopupCreated) {
            isYoutubeLivePopupCreated = true;
            //CRJH: API : done ashwini
            youtubeLiveSettingsPopUp = entryFac.youtubeLiveSettings();
            PopUpManager.addPopUp(youtubeLiveSettingsPopUp, this, true);
        }
        //If OpenBroadcaster (OBS) already running stop it
        else {
            stopPublishToYoutubeLive();
        }
    }

    /**
     * @public
     * The function for starting the external process OpenBroadcaster (OBS) to capture the desktop & streaming to youtube.
     * This works only for Windows7 OS.
     *
     *
     * @return void
     */
    public function publishToYoutubeLive():void {
        //This works only for Windows7 OS
        //CRJH: API : done ashwini
        if (Capabilities.os.toString() == "Windows 7") {
            if (isYoutubeLiveStarted == false) {
                //Check for entries in both textfields in the popup
                if (StringUtil.trim(youtubeLiveSettingsPopUp.txtRTMPURL.text).length > 0 && StringUtil.trim(youtubeLiveSettingsPopUp.txtStreamName.text).length > 0 && StringUtil.trim(youtubeLiveSettingsPopUp.txtRTMPURL.text).search("rtmp://") == 0) {
                    applicationType::desktop {
                        //Setting parameters to nativeprocess for invoking OpenBroadcaster (OBS)
                        var file:File;
                        var nativeProcessStartupInfo:NativeProcessStartupInfo;
                        var processArgs:Vector.<String>;
                        nativeProcessStartupInfo = new NativeProcessStartupInfo();
                        processArgs = new Vector.<String>();
                        file = File.applicationDirectory;
                        file = file.resolvePath("app:///edu/amrita/aview/youtubestreaming/ScreenBroadcaster/ScreenBroadcaster.exe");
                        //URL
                        processArgs.push(youtubeLiveSettingsPopUp.txtRTMPURL.text);
                        //StreamName
                        processArgs.push(youtubeLiveSettingsPopUp.txtStreamName.text);
                        //Screen width
                        processArgs.push(Capabilities.screenResolutionX.toString());
                        //Screen height
                        processArgs.push(Capabilities.screenResolutionY.toString());
                        //window visibility
                        processArgs.push("0");

                        nativeProcessStartupInfo.executable = file;
                        nativeProcessStartupInfo.arguments = processArgs;

                        nativeProcessOBS = new NativeProcess();
                        if (NativeProcess.isSupported == true) {
                            //Start OpenBroadcaster (OBS)
                            if (nativeProcessOBS.running == false) {
                                nativeProcessOBS.start(nativeProcessStartupInfo);
                                isYoutubeLiveStarted = true;
                                classroomComponentSgl.Conso_YoutubeLive.toolTip = "Stop YoutubeLive";
                                youtubelive_IconClass = youtubeliveStop;
                                PopUpManager.removePopUp(youtubeLiveSettingsPopUp);
                                isYoutubeLivePopupCreated = false;
                            }
                        } else if (Log.isDebug())
                            log.debug("Nativeprocess not supported");
                    }
                } else {
                    //Check for valid entries in both textfields in the popup and show proper messages
                    if (StringUtil.trim(youtubeLiveSettingsPopUp.txtRTMPURL.text).length == 0 || StringUtil.trim(youtubeLiveSettingsPopUp.txtRTMPURL.text).search("rtmp://") != 0) {
                        if (StringUtil.trim(youtubeLiveSettingsPopUp.txtStreamName.text).length == 0) {
                            Alert.show("Please enter valid RTMP URL & stream name.");
                        } else
                            Alert.show("Please enter valid RTMP URL.");
                    } else if (StringUtil.trim(youtubeLiveSettingsPopUp.txtStreamName.text).length == 0)
                        Alert.show("Please enter valid stream name.");
                }
            }
            //If OpenBroadcaster (OBS) already running stop it
            else {
                stopPublishToYoutubeLive();
            }
        } else if (Log.isDebug())
            log.debug("Supported only in Windows7");
    }

    /**
     * @public
     * The function for sop the external process OpenBroadcaster (OBS).
     *
     *
     * @return void
     */
    public function stopPublishToYoutubeLive():void {
        //If classrom component not created then exit from the function
        if (!classroomComponentSgl)
            return;
        isYoutubeLiveStarted = false;
        classroomComponentSgl.Conso_YoutubeLive.toolTip = "Start YoutubeLive";
        youtubelive_IconClass = youtubeliveStart;
        try {
            applicationType::desktop {
                //If OpenBroadcaster (OBS) running stop it
                if (nativeProcessOBS && nativeProcessOBS.running == true) {
                    nativeProcessOBS.exit(true);
                }
            }
        } catch (e:Error) {
            if (Log.isError())
                log.error("Error in stopPublishToYoutubeLive method:" + e.getStackTrace());
        }
    }

   	/**
     * @private
     * The function is used to set the status of uninterrupted desktop sharing to shared object.
     *
     *
     * @return void
     */
    private function setUninterruptedDesktopSharingStatus():void {
        applicationType::web {
            screenSharingComp.setUninterruptedDesktopSharingStatusToCollabObject()
        }
        applicationType::desktop {
            setUninterruptedDesktopSharingStatusToCollabObject();
        }
    }

	/**
	 * @private
	 *  This function is used for showing desktopsharing closing message while switching between modules.
	 *
	 *
	 * @return void
	 */
	//Fix for issue #18167
	private function unInterruptedDesktopSharingOFFMessage():void {
		//Fix for issue #19025
		applicationType::desktop {
			if(selectedModulle == 0 && docComp.isPopOut){
				parentForUninterruptedSharingAlert = docComp.documentSharingMW;
			}
			else if(selectedModulle == 1 && wbComp.isPopOut) {
				parentForUninterruptedSharingAlert = wbComp.whiteBoardFullWndw;
			}
			else if(selectedModulle == 2 && viewer3DComp.isPopOut) {
				parentForUninterruptedSharingAlert = viewer3DComp.viewer3DSWC;
			}
			else if(selectedModulle == 3 && viewer2DComp.isPopOut) {
				parentForUninterruptedSharingAlert = viewer2DComp.popWindow;
			}
			else if(selectedModulle == 4 && videoShareObj.isPopOut) {
				parentForUninterruptedSharingAlert = videoShareObj.vBoxVideoPlayer;
			}
			else if(selectedModulle == 6 && videoWallWindow) {
				parentForUninterruptedSharingAlert = videoWallWindow;
			}
			unInterruptedDesktopSharingOFFAlert = Alert.show("Desktop sharing is stopped." + " If you wish to continue sharing desktop even when you are not in Desktop tab," + " please turn on \n'Un-interrupted desktop sharing'.", "INFO",0,parentForUninterruptedSharingAlert);
		}
		
		applicationType::web {
			unInterruptedDesktopSharingOFFAlert = Alert.show("Desktop sharing is stopped." + " If you wish to continue sharing desktop even when you are not in Desktop tab," + " please turn on \n'Un-interrupted desktop sharing'.", "INFO");
		}
	}
	
    public function onClickEndMeeting():void {
        if (ClassroomContext.aviewClass.classType == "Meeting" && ClassroomContext.isModerator) {
            isEndSessionByModerator = true;
            FlexGlobals.topLevelApplication.mainApp.initiateExit("endMeeting");
        }
    }
//To sync question added in the QuestionComponent with the UserList.Use:To show data in QuestionInterface.
public function questionCompSyncHandler(e:Event):void
{
	lstUsers.dispatchEvent(new Event("QuestionSync"));
}
}