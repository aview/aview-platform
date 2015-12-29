package edu.amrita.aview.core.entry
{
	import edu.amrita.aview.core.login.MainApp;
	import edu.amrita.aview.core.login.boilerplate.Strings;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.logging.LogEventLevel;
	
	public class Constants
	{
		public function Constants()
		{
		}
		public static const COLLABORATION_SERVER_MODULE_NAME:String="collaboration_module";
		//		public static const USER_SERVER_MODULE_NAME:String = "user_module";
		//		public static const CHAT_SERVER_MODULE_NAME:String = "chat_module";
		public static const VIDEO_SERVER_MODULE_NAME:String="video_module";
		//		public static const DOCUMENT_SERVER_MODULE_NAME:String = "documentsharing_module";
		//		public static const WHITEBOARD_SERVER_MODULE_NAME:String = "whiteboard_module";
		public static const VIEWER3D_SERVER_MODULE_NAME:String="3DViewer_module";
		public static const VIEWER2D_SERVER_MODULE_NAME:String="2DViewer_module";
		public static const PRETESTING_SERVER_MODULE_NAME:String="pretesting_module";
		
		public static const TEACHER_TYPE:String="TEACHER";
		public static const STUDENT_TYPE:String="STUDENT";
		public static const GUEST_TYPE:String="GUEST";
		public static const ADMIN_TYPE:String="ADMINISTRATOR";
		public static const MASTER_ADMIN_TYPE:String="MASTER_ADMIN";
		public static const MONITOR_TYPE:String="MONITOR";
		
		public static const NATIONAL_SERVER:String="National Server";
		
		//	Ravishankar		Role & Status Display ...
		public static const ROLE_STATUS_DISPLAY_MODERATOR:String="Moderator";
		public static const ROLE_STATUS_DISPLAY_MODERATOR_PRESENTER:String="Moderator / Presenter";
		public static const ROLE_STATUS_DISPLAY_PRESENTER:String="Presenter";
		public static const ROLE_STATUS_DISPLAY_VIEWER:String="Viewer";
		public static const ROLE_STATUS_DISPLAY_MONITOR:String="Monitor";
		public static const ROLE_STATUS_DISPLAY_VIEWER_INTERACTION:String="Viewer - Interaction";
		public static const ROLE_STATUS_DISPLAY_VIEWER_TALK:String="Viewer - Talk";
		public static const ROLE_STATUS_DISPLAY_VIEWER_MUTED:String="Viewer - Muted";
		public static const ROLE_STATUS_DISPLAY_MODERATOR_MUTED:String="Moderator - Muted";
		public static const ROLE_STATUS_DISPLAY_MOD_PRSNTR_MUTED:String="Moderator / Presenter - Muted";
		public static const ROLE_STATUS_DISPLAY_PRESENTER_MUTED:String="Presenter - Muted";
		public static const PRESENTER_NOTIFICATION:String="You have the presenter control now. \nClick OK to continue.";
		public static const INTERACT_NOTIFICATION:String="Now you can interact with the Presenter. \nClick OK to continue.";
		public static const MUTE_NOTIFICATION:String="The Presenter has Muted your microphone.";
		public static const TALK_NOTIFICATION:String="The Presenter has un-Muted your microphone.";
		
		public static const SETUP_ADMIN_TOOLTIP:String="Setup - Institute, Course, Class, Lecture, User Account and Class Registration";
		
		public static const MODERATOR_ROLE:String="MODERATOR";
		public static const PRESENTER_ROLE:String="PRESENTER";
		public static const VIEWER_ROLE:String="VIEWER";
		
		public static const OPEN_REGISTRATION:String="Open";
		public static const APPROVAL_REGISTRATION:String="Approval";
		public static const NO_APPROVAL_REGISTRATION:String="NoApproval";
		
		//class type checking
		public static const CLASS_TYPE_WEBINAR:String="Webinar";
		public static const CLASS_TYPE_CLASSROOM:String="Classroom";
		
		//Video Sharing...
		public static const URL_INFO:String="urlinfo";
		public static const STATUS:String="videocommand";
		public static const PLAY_TIME:String="playTime";
		
		public static const VIDEO_STATE_LOAD:String="Load";
		public static const VIDEO_STATE_LOADING:String="Loading";
		public static const VIDEO_STATE_LOADED:String="Loaded";
		public static const VIDEO_STATE_PLAY:String="Play";
		public static const VIDEO_STATE_PAUSE:String="Pause";
		public static const VIDEO_STATE_STOP:String="Stop";
		
		public static const VIDEO_COMMAND_LOAD:String="Load";
		public static const VIDEO_COMMAND_PLAY:String="Play";
		public static const VIDEO_COMMAND_REPLAY:String="Replay";
		public static const VIDEO_COMMAND_PAUSE:String="Pause";
		public static const VIDEO_COMMAND_STOP:String="Stop";
		public static const VIDEO_COMMAND_SLIDERPRESS:String="Sliderpress";
		public static const VIDEO_COMMAND_SEEK_PLAY:String="SeekPlay";
		public static const VIDEO_COMMAND_SEEK_PAUSE:String="SeekPause";
		public static const COPY_RIGHT_FOOTER:String=getCopyrightFooter();
		public static const UNLIMITED:String="Unlimited";
		
		public static const USERLIST_MAX_LEN_MULTI:int=10;
		public static const USERLIST_MAX_LEN_CONSO:int=18;
		
		public static const SOCKET_PORT_NO:int=9121;
		public static const SHORTCUT_KEY_PTT:int=84;
		public static const SUBSCRIPTION_PRESENTER:String="SUBSCRIPTION_PRESENTER";
		public static const SUBSCRIPTION_VIEWER:String="SUBSCRIPTION_VIEWER";
		public static const AUDIT_ACTION_LEVEL:String="Action";
		public static const AUDIT_LECTURE_LEVEL:String="Lecture";
		public static const NORMAL_LOGIN:String="Password";
		public static const BIOMETRIC_LOGIN:String="Face Recognition";
		public static const SERVER_CATEGORY_FMS_WEB:String="FMS-WEB";
		public static const SERVER_CATEGORY_FMS:String="FMS";
		public static const SERVER_CATEGORY_WEB_WIN:String="WEB-WIN";
		public static const SERVER_CATEGORY_WEB_LIN:String="WEB-LIN";
		public static const SERVER_CATEGORY_RED5_WIN:String="RED5-WIN";
		public static const SERVER_CATEGORY_RED5_LIN:String="RED5-LIN";
		
		public static const VIDEO_SELECT_PROMPT:String="-- Select Camera --";
		public static const MICROPHONE_SELECT_PROMPT:String="-- Select Microphone --";
		public static const PRESENTER_INTERACT:String = "Show/hide the number of times user has interacted with presenter";
		public static const MONITOR_INTERACT:String = "Show/hide the number of times user has monitored by monitor";
		public static const PEOPLE_COUNT:String = "Show/hide People count";
		/**
		 * Maximum number of retries performed to re establish video connection, incase the connection gets closed.
		 */
		public static const MAX_CONNECTION_RETRYS:int=30;
		
		/**
		 * Wait time between video reconnections
		 */
		public static const CONNECTION_RETRY_WAIT_TIME_MS:int=3000;
		
		public static const CODEC_SORENSON:String="Sorenson";
		public static const CODEC_H264:String="H.264";
		public static const CODEC_VP6:String="VP6";
		
		public static const SORT_OPTION:ArrayList=new ArrayList([{sortOpt: 'All'}, {sortOpt: 'Teachers'}, {sortOpt: 'Handraised'}, {sortOpt: 'Requesting Presenter'}, {sortOpt: 'Students'}, {sortOpt: 'Institute Name'}]);
		public static const USER_SEARCH_STR:String="  -Search User-";
		public static const USER_SEARCH_STRM:String="-Search User-";
		public static const USER_SEARCH_TOOLTIP:String="Search Users";
		
		public static const CLASS_SEARCH_STR:String="Enter class name to filter";
		public static const INSTITUTE_SEARCH_STR:String="Enter institute name to filter";
		public static const COURSE_SEARCH_STR:String="Enter course name to filter";
		public static const USERID_SEARCH_STR:String="Enter user id to filter";
		public static const USERNAME_SEARCH_STR:String="Enter user name to filter";
		
		//UserList Statuses
		public static const ACCEPT:String="accept";
		public static const HOLD:String="hold";
		public static const WAITING:String="waiting";
		public static const VIEW:String="view";
		
		//contactlist user status 
		public static const BUSY:String="busy";
		public static const ONLINE:String="online";
		public static const OFFLINE:String="offline";
		public static const IDLE:String="idle";
		
		//chat constants
		
		public static const PUBLIC_CHAT:String="pubicChat";
		public static const PRIVATE_CHAT:String="privateChat";
		public static const GROUP_CHAT:String="groupChat";
		
		public static const STREAM_VIDEO:int=1;
		public static const HOLD_VIDEO:int=0;
		
		public static const DESKTOP_SHARING_ENABLE:int=1;
		public static const DESKTOP_SHARING_DISABLE:int=0;
		
		//PushToTalk SO statuses
		public static const PTT:String="pushToTalk";
		public static const FREETALK:String="freetalk";
		public static const UN_MUTE:String="unmute";
		public static const MUTE:String="mute";
		
		//multipresenter statuses
		public static const PRSNTR_REQUEST:String="prsntr_request";
		public static const PRSNTR_RELEASE:String="release_prsntr_request"; //Used for auditing purposes only 
		
		//Presenter - give or take control messages
		public static const MAKE_PRESENTER:String="Make Presenter";
		public static const TAKE_PRESENTER:String="Take Control";
		public static const PRESENTER_REQ:String="Make me PRESENTER";
		public static const PRESENTER_CNCL:String="Stop being the PRESENTER";
		public static const FULLSCREEN_MSG:String="Module is in fullscreen mode";
		public static const MODULE_DISABLE_MSG:String="Module is Disabled";
		public static const VIDEO_MODULE_DISABLE_MSG:String="Video Module is Disabled";
		
		//Bug fix for issue #674		
		//public static const USER_TYPE:Array = new Array(STUDENT_TYPE, TEACHER_TYPE, ADMIN_TYPE, MASTER_ADMIN_TYPE);
		//public static const USER_ROLE:Array = new Array(STUDENT_TYPE, TEACHER_TYPE, ADMIN_TYPE);
		public static const USER_ROLE:Array=new Array(STUDENT_TYPE, TEACHER_TYPE);
		
		public static const VIDEO_COMPRESSION_TECHNIQUES:Array=new Array({value: "Low Latency", data: CODEC_SORENSON}, {value: "High Definition", data: CODEC_H264}, {value: "Low Bandwidth", data: CODEC_VP6});
		
		public static const FMS_PRESENTER:String="FMS_VIDEO_PRESENTER";
		public static const FMS_VIEWER:String="FMS_VIDEO_VIEWER";
		public static const FMS_DESKTOP_SHARING:String="FMS_DESKTOP_SHARING";
		public static const FMS_DATA:String="FMS_DATA";
		public static const CONTENT_SERVER:String="CONTENT_SERVER";
		
		public static const MEETING_COLLABORATION_SERVER:String="MEETING_FMS_DATA";
		public static const MEETING_FMS_PRESENTER:String="MEETING_FMS_VIDEO_PRESENTER";
		public static const MEETING_CONTENT_SERVER:String="MEETING_CONTENT_SERVER";
		public static const MEETING_FMS_VIEWER:String="MEETING_FMS_VIDEO_VIEWER";
		public static const MEETING_FMS_DESKTOP_SHARING:String="MEETING_FMS_DESKTOP_SHARING";
		
		public static const AVM_COLLABORATION_DISPLAY:String="Meeting Collaboration Server";
		public static const AVM_VIEWER_VIDEO_DISPLAY:String="Meeting Viewer Server";
		public static const AVM_CONTENT_DISPLAY:String="Meeting Content Server";
		public static const AVM_PRESENTER_VIDEO_DISPLAY:String="Meeting Presenter Server";
		public static const AVM_DESKTOP_SHARING_DISPLAY:String="Meeting Desktop Sharing Server";
		
		public static const FMS_PRESENTER_DISPLAY:String="Presenter Video Server";
		public static const FMS_VIEWER_DISPLAY:String="Viewer Video Server";
		public static const FMS_DESKTOP_SHARING_DISPLAY:String="Desktop Sharing Server";
		public static const FMS_DATA_DISPLAY:String="Collaboration Server";
		public static const CONTENT_SERVER_DISPLAY:String="Content Server";
		
		public static const MEETING_PRESENTER_DISPLAY:String="Presenter Video Server";
		public static const MEETING_VIEWER_DISPLAY:String="Viewer Video Server";
		public static const MEETING_DESKTOP_SHARING_DISPLAY:String="Desktop Sharing Server";
		public static const MEETING_DATA_DISPLAY:String="Collaboration Server";
		public static const MEETING_SERVER_DISPLAY:String="Content Server";
		public static const SERVER_DETAIL_FILENAME:String= "config//ServerDetails.xml";		
		
		public static const PC_NODE_TYPE:String="PERSONAL COMPUTER";
		public static const CR_NODE_TYPE:String="CLASSROOM COMPUTER";
		
		public static const PROTOCOL_HTTPS:String = "https";
		public static const PROTOCOL_HTTP:String="http";
		public static const PROTOCOL_FMS_SERVER:String="rtmp";
		public static const PROTOCOL_FIREWALL_FMS_SERVER:String="rtmpt";
		public static const FMS_SERVER_CHECK_FIREWAL:String="cts001.aview.in";
		
		//Setting the log level to INFO
		public static const LOG_LEVEL:Number = 4;
		
		public static const FMS_SERVER_PORT:Number=1935;
		public static const CONTENT_SERVER_PORT:Number=80;
		
		public static const FMS_SERVER_PORT_FIREWALL:Number=80;
		public static const CONTENT_SERVER_PORT_FIREWALL:Number=8080;
	
		public static const VIEWER_APPEND_NAME:String="_VIEWER";
		
		//Collaboration Mode
		public static const CM_SELECTED_STUDENT_CAN_WRITE:String="SelectedStudentOnly";
		public static const CM_ALL_STUDENT_CAN_WRITE:String="AllStudents";
		public static const CM_NO_STUDENT_CAN_WRITE:String="NoStudent";
		public static const CM_HIDE_WHITEBOARD:String="HideWhiteBoard";
		public static const CM_UNHIDE_WHITEBOARD:String="UnHideWhiteBoard";
		
		//	Ravishankar		Break current Classroom session
		public static const BREAK_SESSION_POPUP_TITLE:String="Break current session";
		public static const BREAK_SESSION_COMPONENT_TITLE:String="Information";
		public static const BREAK_SESSION_TITLE:String="Session Break Message";
		public static const BREAK_MESSAGE_INPUT_TEXT:String="Enter your message here";
		public static const BREAK_SESSION_MSG:String="Session break confirmed?";
		public static const BREAK_SESSION_CONFIRM_TITLE:String="Confirmation?";
		public static const BREAK_CURRENT_SESSION_TITLE:String="Confirm Session Break";
		public static const BREAK_CURRENT_SESSION_MSG:String="Do you want to take a break?";
		public static const BREAK_CURRENT_SESSION_PROMPT:String="Please type-in your 'Session break' broadcast message below:";
		public static const BREAK_CURRENT_SESSION_KEY:String="3 8 6TUOEMIT 777";
		public static const BREAK_TIME_MARKER:String="7-7-7";
		public static const BREAK_MESSAGE_SUCCESS:String="Break session message sent successfully!";
		public static const BREAK_ENABLE_TOOLTIP:String="Break current session and notify users";
		public static const BREAK_DISABLE_TOOLTIP:String="Break session DISABLED until current 'Session Break' expires";
		public static const secondsPerMinute:int=1 * 60;
		public static const millisecondsPerMinute:int=1000 * 60;
		public static const millisecondsPerHour:int=1000 * 60 * 60;
		public static const millisecondsPerDay:int=1000 * 60 * 60 * 24;
		
		//	Ravishankar		Question Answer Tab disable
		public static const QUESTION_ANSWER_DISABLE_TITLE:String="Confirm Disable Q&A";
		public static const QUESTION_ANSWER_DISABLE_MSG:String="Do you want to disable posting of Questions?";
		public static const QA_ALREADY_DISABLED_MSG:String="Posting Questions already disabled";
		public static const QA_ALREADY_ENABLED_MSG:String="Posting Questions already enabled";
		public static const QUESTIONANSWER_STATUS:String="Allow posting questions and voting during the break";
		
		//	Ravishankar		Chat Constants
		public static const MODERATOR_CHAT_FONT:String="Verdana";
		public static const MODERATOR_CHAT_COLOR:String="#FF0000";
		public static const PRESENTER_CHAT_FONT:String="Trebuchet MS";
		public static const PRESENTER_CHAT_COLOR:String="#11CA56";
		public static const CHAT_FONT_WEIGHT_BOLD:String="Bold";
		public static const DEFAULT_CHAT_FONT:String="Arial";
		public static const DEFAULT_CHAT_COLOR:String="#000000";
		public static const DEFAULT_CHAT_FONT_WEIGHT:String="Normal";
		public static const DEFAULT_CHAT_FONT_SIZE:String="12";
		public static const CHAT_CLEAR_MSG_FONT:String="Calibri";
		public static const CHAT_CLEAR_MSG_COLOR:String="#FF0000";
		public static const CHAT_CLEAR_MSG_FONT_SIZE:String="12.9";
		public static const CHAT_CLEAR_TEXT_MODERATOR:String="Are you sure you want to clear all chat messages?";
		public static const CHAT_CLEAR_TEXT_VWR:String="Chat Message(s) cleared by ";
		public static const CHAT_CLEAR_NO_MESSAGES:String="No chat message to clear!";
		public static const CHAT_CLEAR_TITLE:String="Clear Chat Message(s)";
		public static const CHAT_SELECT_NO_MESSAGES:String="No text to select!";
		public static const CHAT_SELECT_TITLE:String="Select Text";
		public static const CHAT_CLEAR_KEY:String="999 *#& Clear Aum Chat Namah Area Shivaya !%* 999";
		public static const CHAT_BREAK_MSG_COLOR:String="#0000FF";  //Blue color
		//Change/Reset Password statuses
		public static const CHANGE_PASSWORD_SUCCESS:String="Success";
		public static const CHANGE_PASSWORD_FAILED:String="Failed";
		
			
		//Server drop down
		public static const PROMPT_SERVER_DROPDOWN:String = "--Select server--";
		
		
		/**Platform specific variables*/
		applicationType::web
		{
			//Single sign on
			public static const guestLogin:String="guestLogin";
			public static const userLogin:String="userLogin";
			public static const classEntry:String="classEntry";
		}
		
		
		//for generating the copyright footer with the application version
		private static function getCopyrightFooter():String {
			applicationType::DesktopWeb{
				return "A-VIEW (Amrita Virtual Interactive E-Learning World) Version " + MainApp.AVIEW_VERSION + "; © 2007-2015";
			}
			applicationType::mobile{
				return "A-VIEW (Amrita Virtual Interactive E-Learning World) Version "+getAppVersion()+" ; © 2007-2015 ";
			}
		}
		
		//Layout for showing the video wall
		public static const MEETING_LAYOUT:String = "Meeting";
		public static const PRESENTER_LAYOUT:String = "Presenter";
		public static const SIMPLE_LAYOUT:String = "Simple";
		//Fix for Bug #14095 start
		/**
		 * Array for storing various bandwidth values.
		 * <br>These values are used to decide audio and video bitrates for encoder.</br>
		 */
		public static const availableVideoPublishingBandwidths:Array=new Array({value: "28Kbps", index: 28}, {value: "56Kbps", index: 56}, {value: "128Kbps", index: 128}, {value: "256Kbps", index: 256}, {value: "512Kbps", index: 512}, {value: "768Kbps", index: 768}, {value:"1024Kbps",index:1024}, {value:"1536Kbps",index:1536}, {value:"2048Kbps",index:2048}, {value:"2520Kbps",index:2520}, {value:"5670Kbps",index:5670}, {value:"8505Kbps",index:8505});		
		//Fix for Bug #14095 end
		
		
		public static const CAM_TYPE_WEBCAM:String = "Webcam";
		public static const CAM_TYPE_HD_WEBCAM:String = "HDWebcam";
		public static const CAM_TYPE_BLACKMAGIC:String = "Blackmagic";
		public static const CAM_TYPE_EASYCAP:String = "EasyCap";
		public static const CAM_TYPE_FMLE:String = "FMLE";
		
		public static const AR_FPS_VALUES:ArrayCollection = new ArrayCollection([{value:"7"},{value:"8"},{value:"9"},{value:"10"},{value:"11"},{value:"12"},{value:"13"},{value:"14"},{value:"15"},{value:"16"},{value:"17"},{value:"18"},{value:"19"},{value:"20"},{value:"21"},{value:"22"},{value:"23"},{value:"24"},{value:"25"},{value:"26"},{value:"27"},{value:"28"},{value:"29"},{value:"30"}]);
		public static const AR_KEY_FRAME_VALUES:ArrayCollection = new ArrayCollection([{value:"1"},{value:"2"},{value:"3"},{value:"4"},{value:"5"},{value:"6"},{value:"7"},{value:"8"},{value:"9"},{value:"10"},{value:"11"},{value:"12"},{value:"13"},{value:"14"},{value:"15"},{value:"16"},{value:"17"},{value:"18"},{value:"19"},{value:"20"},{value:"21"},{value:"22"},{value:"23"},{value:"24"},{value:"25"},{value:"26"},{value:"27"},{value:"28"},{value:"29"},{value:"30"},{value:"31"},{value:"32"},{value:"33"},{value:"34"},{value:"35"},{value:"36"},{value:"37"},{value:"38"},{value:"39"},{value:"40"},{value:"41"},{value:"42"},{value:"43"},{value:"44"},{value:"45"},{value:"46"},{value:"47"},{value:"48"}]);
		public static const AR_H264_PROFILER_VALUES:ArrayCollection = new ArrayCollection([{value:"1"},{value:"2"},{value:"3"},{value:"4"},{value:"5"}]);
		applicationType::web
		{
			//For Web: Removed black magic camera type.
			public static const cameraDeviceType:ArrayCollection=new ArrayCollection([{value:"WebCam", index:CAM_TYPE_WEBCAM,desc:"Normal Webcam with USB Connection"},{value:"HD WebCam", index:CAM_TYPE_HD_WEBCAM,desc:"HD Webcam with USB Connection"},{value:"USB Converter", index:CAM_TYPE_EASYCAP,desc:"RCA/S-Video to USB converter"}]);
		}
		applicationType::desktop
		{
			public static const cameraDeviceType:ArrayCollection=new ArrayCollection([{value:"WebCam", index:CAM_TYPE_WEBCAM,desc:"Normal Webcam with USB Connection"},{value:"HD WebCam", index:CAM_TYPE_HD_WEBCAM,desc:"HD Webcam with USB Connection"},{value:"USB Converter", index:CAM_TYPE_EASYCAP,desc:"RCA/S-Video to USB converter"}, {value:"HDMI", index:CAM_TYPE_BLACKMAGIC,desc:"Direct HDMI inputs to computer"}]);
		}
		
		public static const videoResolutions:ArrayCollection=new ArrayCollection([{value:"160 x 90"}, {value:"320 x 180"}, {value:"640 x 360"},{value:"720 x 576"}, {value:"768 x 432"}, {value:"1280 x 720"}, {value:"1536 x 864"}, {value:"1920 x 1080"}]);
		//public static const webCamVideoResolution:ArrayCollection=new ArrayCollection([{value:"160 x 90"}, {value:"320 x 180"}, {value:"640 x 360"}, {value:"768 x 432"}, {value:"1280 x 720"}]);
		//public static const hdWebCamVideoResolution:ArrayCollection=new ArrayCollection([{value:"160 x 90"}, {value:"320 x 180"}, {value:"640 x 360"}, {value:"768 x 432"}, {value:"1280 x 720"}, {value:"1536 x 864"}, {value:"1920 x 1080"}]);
		//public static const easyCapVideoResolution:ArrayCollection=new ArrayCollection([{value:"720 x 576"}]);
		//public static const blackMagicVideoResolution:ArrayCollection=new ArrayCollection([{value:"1920 x 1080"}]);
		public static const h264Profiles:ArrayCollection=new ArrayCollection([{value:"BaseLine"}, {value:"Main"}]);
		public static const videoQuality:ArrayCollection=new ArrayCollection([{value:"Auto",index:0}, {value:"Low",index:80}, {value:"Medium",index:90}, {value:"High",index:100}]);
		
		//Statuses
		public static const STATUS_ACTIVE:String = "Active";
		public static const STATUS_DELETED:String = "Deleted";
		public static const STATUS_PENDING:String = "Pending";
		public static const STATUS_CLOSED:String = "Closed";
		public static const STATUS_COMMUNICATING:String = "Communicating";
		public static const STATUS_TESTING:String = "Testing";
		public static const STATUS_FAILEDTESTING:String = "FailedTesting";
		public static const STATUS_INACTIVE:String = "InActive";
		public static const STATUS_JOINED:String = "Joined";
		public static const STATUS_EXITED:String = "Exited";
		public static const STATUS_YES = "Yes";
		public static const STATUS_NO = "No";
		public static const AUDIO_VIDEO_INTERACTION_MODE: Array = ["Full", "Minimal"];
		
		public static const PASSWORD_STRENGTH_REGEXP:RegExp = new RegExp("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!\"#$%&'()*+,-./:;<=>?@\[\\]^_`{|}~\\\\]).{8,}$","");
		
		applicationType::DesktopMobile{
			import flash.desktop.NativeApplication;
			public static const AVIEW_APP_ID:String=NativeApplication.nativeApplication.applicationID;
			public static const AVIEW_VERSION:String=getAppVersion();
			
			public static function getAppVersion():String {
				var appXml:XML=NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace=appXml.namespace();
				var appVersion:String=appXml.ns::versionLabel[0];
				return appVersion;
			}
		}
		applicationType::mobile{
			public static const IS_MODERATOR:Boolean = true;
			public static const IS_NOT_PUBLISHING:Boolean = false;
			public static const IS_PUBLISHING:Boolean = true;
			public static const STRING_OK:String = "ok";
			public static const PRESENTER_VIDEO_TITLE:String = "P : ";
			public static const VIEWER_VIDEO_TITLE:String = "V : ";
			public static const USER_HAS_BEEN_SELECTED:String = "User has been selected";
			public static const VIDEO_ON_MESSAGE:String = "Turning OFF video make the application light weight, but you will not be able to send your video and see other's videos."; 
			public static const VIDEO_OFF_MESSAGE:String = "Turn on video to view all incoming videos (Presenter/Viewer)";
			public static const MUI_ON_MESSAGE:String = "Turn on MUI to select multiple user for interaction";
			public static const MUI_OFF_MESSAGE:String = "Turn off MUI to select only one user for interaction";
			
			public static const BTN_DOCUMENT:String = "Document";
			public static const BTN_WHITEBOARD:String = "Whiteboard";
			public static const BTN_CHAT:String = "btnChatModule";
			public static const BTN_VIDEO:String = "Video";
			public static const BTN_THREED:String = "3D Viewer";
			public static const BTN_USER:String = "Users / Chat";
			public static const BTN_CONSOLIDATE:String = "btnConsolidate";
			public static const BTN_DESKTOP_SHARING:String = "Desktop";
			public static const BTN_QUESTION:String = "Question";
			
			//Menu items
			public static const MENU_VIDEO_SETTING:String = "Video Setting";
			public static const MENU_CLOSE:String = "Close";
			public static const MENU_EXIT_SESSION:String = "Exit session";
			public static const MENU_LOGOUT:String = "Logout";
			public static const MENU_HELP:String = "Help";
			public static const MENU_CHANGE_PASSWORD:String = "ChangePassword";
			public static const MENU_MUI:String = "Multiple User Interaction";
			public static const BOOL_FALSE:Boolean=false;
			public static const BOOL_TRUE:Boolean=true;
			public static const SCREENTYPE_INDIVIDUAL:String = "Tabbed View";
			public static const SCREENTYPE_ALLINONE:String = "All-in-one View";	
			
			public static const VIDEO_PREF_ON:String = "Turn on video";
			public static const VIDEO_PREF_OFF:String = "Turn off video";
		}

	}
}
