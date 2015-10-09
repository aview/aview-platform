package objectResolver {
    import edu.amrita.aview.core.entry.ModuleRO;
    import edu.amrita.aview.core.entry.ModuleVO;
    import edu.amrita.aview.core.gclm.vo.ClassVO;
    import edu.amrita.aview.core.gclm.vo.UserVO;
    import edu.amrita.aview.core.shared.eventmap.EventMap;
    
    import mx.collections.ArrayCollection;
    import mx.core.FlexGlobals;

	public class EntryFac {
          
            public function abstractHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();}
            public function administration():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getadministrationObj();}
            public function arrayCollectionExtended():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getarrayCollectionExtendedObj();}
            public function arrayCollectionUtil():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getarrayCollectionUtilObj();}
            public function auditConstants():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getauditConstantsObj();}
            public function auditContext():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getauditContextObj();}
            public function aViewResponseVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewResponseVOObj();}
            public function aViewStringUtil():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewStringUtilObj();}
            public function brandingAttributeVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getbrandingAttributeVOObj();}
			public function breakSessionMessage():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getbreakSessionObj();}
            public function cameraSelectionForm():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcameraSelectionFormObj();}
            public function canvasPopup():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcanvasPopupObj();}
            public function captcha():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcaptchaObj();}
            public function captchaComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcaptchaComponentObj();}
            public function chatComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatComponentObj();}
            public function chatEvent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatEventObj();}
            public function chatHistory():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatHistoryObj();}
            public function chatSessionHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatSessionHelperObj();}
            public function chatSessionVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatSessionVOObj();}
            public function chatStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):Object{
				return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatStatusEventObj(type,bubbles,cancelable);
			}
            public function classHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getclassHelperObj();}
            public function classRegisterVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getclassRegisterVOObj();}
            public function classRegistrationHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getclassRegistrationHelperObj();}
            public function classServerChangeConsumer():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getclassServerChangeConsumerObj();}
            public function classServerVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getclassServerVOObj();}
            public function classVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getclassVOObj();}
            public function commonEvent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcommonEventObj();}
            public function contactsView():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcontactsViewObj();}
            public function contextManager():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcontextManagerObj();}
            public function courseHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcourseHelperObj();}
            public function courseVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcourseVOObj();}
            public function cRActionButtons():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcRActionButtonsObj();}
            public function createLectureComp():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcreateLectureCompObj();}
            public function customAlert():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getcustomAlertObj();}
            public function desktopPreference():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getdesktopPreferenceSettingobj();}
			public function errorReportForm():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.geterrorReportFormObj();}
            public function eventMap():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.geteventMapObj();}
            public function faceRegistrationForm():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getfaceRegistrationFormObj();}
            public function feedbackForm():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getfeedbackFormObj();}
            public function gCLMContext():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getgCLMContextObj();}
            public function getBreakSessionEventObj(type:String,breakDetails:*=null, bubbles:Boolean=false, cancelable:Boolean=false):Object{ 
				//#BUGFIX API. Breakdetails argument were missing. 
				return FlexGlobals.topLevelApplication.applicationModuleHandler.getbreakSessionEventObj(type,breakDetails,bubbles,cancelable);
			}
            public function getChatManagerObj(classRoomModuleRO:ModuleRO):Object{ return FlexGlobals.topLevelApplication.applicationModuleHandler.getchatManagerObj(classRoomModuleRO);}
            public function getContactsManager(userVO:UserVO,appEventMap:EventMap):Object{ return FlexGlobals.topLevelApplication.applicationModuleHandler.getcontactsManagerObj(userVO,appEventMap);}
            public function getContactsProviderEvent(type:String, callbackFunction:Function=null):Object{ return FlexGlobals.topLevelApplication.applicationModuleHandler.getcontactsProviderEventObj(type,callbackFunction);}
            public function getMeetingRoomManagerController(moduleRO:ModuleRO,allContacts:ArrayCollection,allMeetingRooms:ArrayCollection,meetingRoomMembers:ArrayCollection,roomName:String,meetingRoom:ClassVO,mode:String):Object{ return FlexGlobals.topLevelApplication.applicationModuleHandler.getmeetingRoomManagerControllerObj(moduleRO,allContacts,allMeetingRooms,meetingRoomMembers,roomName,meetingRoom,mode);}
            public function getV2DEvent(type:String,data:Object):Object{ return FlexGlobals.topLevelApplication.applicationModuleHandler.getv2DEventObj(type,false,false,data);}
            public function helpDownloadWindow():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.gethelpDownloadWindowObj();}
            public function imageButton():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getimageButtonObj();}
            public function instituteBrandingVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getinstituteBrandingVOObj();}
            public function instituteHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getinstituteHelperObj();}
            public function instituteVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getinstituteVOObj();}
            public function invitationMessage():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getinvitationMessageObj();}
            public function lectureCalendarViewVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getlectureCalendarViewVOObj();}
            public function lectureHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getlectureHelperObj();}
            public function lectureListVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getlectureListVOObj();}
            public function lectureVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getlectureVOObj();}
            public function logUtil():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getlogUtilObj();}
            public function mediaServerConnection():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmediaServerConnectionObj();}
            public function mediaServerStatusEvent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmediaServerStatusEventObj();}
            public function meetingEvent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmeetingEventObj();}
            public function meetingInvitation():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmeetingInvitationObj();}
            public function meetingManagerHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmeetingManagerHelperObj();}
            public function meetingRoomManagerModel():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmeetingRoomManagerModelObj();}
            public function meetingRoomVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmeetingRoomVOObj();}
            public function messageBox():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxObj();}
            public function messageBoxEvent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getmessageBoxEventObj();}
            public function polling():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getpollingObj();}
            public function preferenceSettings():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getpreferenceSettingsObj();}
            public function profileMenuComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getprofileMenuComponentObj();}
            public function pTTBox():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getpTTBoxObj();}
            public function questionComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getquestionComponentObj();}
            public function questionInteractionEvent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getquestionInteractionEventObj();}
            public function questionPaperQuestions():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getquestionPaperQuestionsObj();}
            public function quickNoteComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getquickNoteComponentObj();}
            public function resizeImageButtonSkin():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getresizeImageButtonSkinObj();}
            public function snapshotComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getsnapshotComponentObj();}
            public function stringUtility():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getstringUtilityObj();}
            public function userHelper():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getuserHelperObj();}
            public function userList():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getuserListObj();}
            public function userSOValue():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getuserSOValueObj();}
            public function userVO():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getuserVOObj();}
            public function videoSharing():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getvideoSharingObj();}
			applicationType::desktop{
				public function pollingWindow():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getpollingWindowObj();}
				public function quizWindow():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getquizWindowObj();}
            	public function videoSharingWindow():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getvideoSharingWindowObj();}
				public function viewer2DWindow():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getviewer2DWindowObj();}
				public function viewer3DModule():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getviewer3DModuleObj();}
			}
            public function viewer2DComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getviewer2DComponentObj();}
            public function viewer3DComponent():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getviewer3DComponentObj();}
            public function youtubeLiveSettings():Object{return FlexGlobals.topLevelApplication.applicationModuleHandler.getyoutubeLiveSettingsObj();}
			
			public function videoSharingClass():Object {return FlexGlobals.topLevelApplication.applicationModuleHandler.getVideoSharingClass(); }
			public function getUserStatusProviderEventObj(userStatusReceiver:Function){return FlexGlobals.topLevelApplication.applicationModuleHandler.getUserStatusProviderEventObj(userStatusReceiver);}

		public function EntryFac() {}
		
		/**
		 * Event type used to notify that break session has started
		 */
		public static const BREAK_SESSION_STARTED_TYPE:String="BREAK_SESSION_STARTED_TYPE";
		/**
		 * Event type used to notify that break session has ended
		 */
		public static const BREAK_SESSION_ENDED_TYPE:String="BREAK_SESSION_ENDED_TYPE";
		/**
		 * Event used to notify to cancel the break session
		 */
		public static const CANCEL_BREAK_SESSION:String="CANCEL_BREAK_SESSION";
		
		public static const END_SESSION:String="End Session";
		
		public static const EDIT_MEETINGROOM:String="MeetingRoomEdit";
		public static const EDITED_MEETINGROOM:String="MeetingRoomEdited";
		
		public static const MODE_ADD_CONTACTS_GUESTS:String = "MODE_ADD_CONTACTS_GUESTS";
		
		public static const REFRESH_CONTACTS:String="RefreshContacts";
        
		public static const MODULE_CLOSE:String = "moduleclose"; //2D Event
		
		public static const CLOSE_INVITATION:String="CloseInvitation";
		
		public static const RECEIVED_INVITATION:String="MeetingInvitationReceived";		
		public static const SCHEDULED_MEETING_CREATED:String="MeetingCreated";
		public static const ADHOC_MEETING_CREATED:String="MeetingCreated";
		public static const MEETING_EDITED:String="MeetingEdited";
		public static const MEETING_DELETED:String="MeetingDeleted";
		public static const CREATE_ADHOC_MEETING:String="CreateAdhocMeeting";
		public static const CREATE_SCHEDULED_MEETING:String="CreateScheduledMeeting";
		public static const EDIT_MEETING:String="EditMeeting";
		public static const DELETE_MEETING:String="DeleteMeeting";
		public static const START_SESSION:String="StartSession";
		public static const REFRESH_MEETING_ROOM:String="RefreshMeeting";
        public static const TYPE_ROLE_CHANGE:String="roleChange"
		
	}
} 
