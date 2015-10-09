package edu.amrita.aview.core.entry
{
	import com.amrita.edu.collaboration.CollaborationService;
	
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	import edu.amrita.aview.core.gclm.vo.CourseVO;
	import edu.amrita.aview.core.gclm.vo.InstituteVO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ClassroomContext
	{
		public function ClassroomContext()
		{
		}
		
		public static function resetClassroomContextValues():void
		{
			isModerator=false;
			STREAMING_OPTION="Audio and Video";
			isAudioOnlyMode=false;
			isUserPublishingVideo=false;
			subscriber_bandwidthSelection="Manual";
			subscriber_prev_bandwidthSelection="Manual";
			
			classStartedFlag=false;
			is_teacherPublishing=false;
			videoConnectionFirstTime=true;
			record_selectionCheck=true;
			
			isDuplicateLogin=false;
			checkIsClassRoom=false;
			
			IS_AUDIO_VIDEO_ENABLED=true;
			IS_DOCUMENT_SHARING_ENABLED=true;
			IS_2D_ENABLED=true;
			IS_3D_ENABLED=true;
			IS_DESKTOP_SHARING_ENABLED=true;
			IS_VIDEO_SHARING_ENABLED=true;
			
			subscriber_bandwidthQualityIndex=0;
			subscriber_prev_bandwidthQualityIndex=0;
			subscriber_bandwidthQualityName="";
			publisherVideoQuality=-1;
			
			/*To clear quizzes if any, that were conducted during the previous classroom session*/
			//Fix for Bug #15857 : Code commented
			/*if (conductedLiveQuizzes)
			{
				conductedLiveQuizzes.removeAll();
			}*/
			
			currentPresenterName	= "";	
			moderatorName	= "";	
			courseID	= "";	
			courseName	= "";	
			presenterBandwidth	="";	
			viewerBandwidth	="";	
			className	= "";	
			classID	=-1;	
			//Fix for Bug#16309
			aviewClass	= new ClassVO();	
			course	= null;	
			lecture	= null;	
			institute	= null;	
			classEntryTime	= "";	
			userDetails	= new Object();	
			videoReconnectingCount	= -1;	
			videoConnectionFirstTime		
			labelWidth	= 0;	
			FMS_USER	= "";	
			FMS_USER_SERVER_CATEGORY	= "";	
			FMS_VIEWER3D	= "";	
			FMS_VIEWER2D	= "";	
			DESKTOP_SHARING_SERVER	= "";	
			CONTENT_WHITEBOARD	= "";	
			CONTENT_DOCUMENT	= "";	
			CONTENT_VIEWER3D	= "";	
			CONTENT_VIEWER2D	= "";	
			CONTENT_RECORD_SERVER	= "";	
			VIDEO_RECORD_SERVER	= "";	
			VIEWER_VIDEO_RECORD_SERVER	= "";	
			protocolFMS	= Constants.PROTOCOL_FMS_SERVER;	
			portFMS	= Constants.FMS_SERVER_PORT;	
			portWAMP	= Constants.CONTENT_SERVER_PORT;	
			isFireWalled	= "";	
			lectureName	= "" ;	
			nodeTypeId 	= 0;		
			checkIsClassRoom = false;
			
			RECORDED_CONTENT_URL = "";
			RECORDED_CONTENT_FILE_PATH = "";
			
			collaborationService = null;
		}
		
		public static function resetUserContextValues():void
		{
			userVO=null;
			userInstituteVO=null;
			ipAddress="";
			hardwareAddress="";
			networkConnectionType="";
			SYSTEM_PARAMETERS=null;
			// Fix for Bug#11366
			welcomeMessage = "";
		}
		// Fix for Bug#11366 :Start
		public static function setWelcomeMessage():void
		{ 
			var dName:String = ''; 
			var dispName :String=ClassroomContext.userVO.userDisplayName;
			if (dispName.length > (Constants.USERLIST_MAX_LEN_MULTI + 3)) {
			dName=dispName.slice(0, Constants.USERLIST_MAX_LEN_MULTI) + "...";
			dispName=dName;
			}
			welcomeMessage = "Welcome " + dispName;
			loginUserName = ClassroomContext.userVO.userDisplayName;
		}
		
		public static var loginUserName:String = "";
		public static var welcomeMessage:String = '';
		// Fix for Bug#11366 :End
		public static var userVO:UserVO=null;
		public static var userInstituteVO:InstituteVO=null;
		
		public var userRole:String;
		
		public static var contentServerSupportsAnimations:Boolean=false;
		
		public static var currentPresenterName:String="";
		public static var moderatorName:String="";
		public static var isModerator:Boolean;
		public static var STREAMING_OPTION:String;
		public static var isAudioOnlyMode:Boolean;
		public static var isUserPublishingVideo:Boolean;
		
		public static var courseID:String="";
		
		public static var courseName:String="";
		public static var presenterBandwidth:String="";
		public static var viewerBandwidth:String="";
		
		public static var className:String="";
		public static var classID:Number=-1;
		
		public static var aviewClass:ClassVO=null;
		public static var aviewClassServerFailover:ClassVO=null;
		
		public static var course:CourseVO=null;
		public static var lecture:LectureVO=null;
		public static var institute:InstituteVO=null;
		
		public static var isCreateClass:Boolean;
		
		public static var SYSTEM_PARAMETERS:Object=null;
		
		public static var subscriber_bandwidthSelection:String;
		public static var subscriber_prev_bandwidthSelection:String;
		public static var subscriber_bandwidthQualityIndex:int=0;
		public static var subscriber_prev_bandwidthQualityIndex:int=0;
		public static var subscriber_bandwidthQualityName:String="";
		public static var publisherVideoQuality:int=-1;
		
		/*The variable holds the Users IP addresses.*/
		public static var ipAddress:String="";
		public static var hardwareAddress:String="";
		public static var networkConnectionType:String="";
		/*The variable holds the time when the user enters the classroom*/
		public static var classEntryTime:String="";
		
		
		public static var userDetails:Object=new Object();
		//RGCR: Instead of classStartedFlag, can we use the presence of the classroomComponent?
		public static var classStartedFlag:Boolean;
		
		public static var is_teacherPublishing:Boolean;
		
		public static var videoConnectedCount:int=-1;
		public static var videoReconnectingCount:int=-1;
		public static var videoConnectionFirstTime:Boolean;
		
		public static var record_selectionCheck:Boolean;
		
		//UserNameRenderer.mxml's Label's width. This should be set by the single/multi window mode
		public static var labelWidth:int=0;
		
		
		// Server Details for the Class
		
		public static var FMS_USER:String="";
		
		public static var FMS_USER_SERVER_CATEGORY:String="";
		
		public static var FMS_VIEWER3D:String="";
		
		public static var FMS_VIEWER2D:String="";
		
		public static var DESKTOP_SHARING_SERVER:String="";
		
		public static var CONTENT_WHITEBOARD:String="";
		
		public static var CONTENT_DOCUMENT:String="";
		
		public static var CONTENT_VIEWER3D:String="";
		
		public static var CONTENT_VIEWER2D:String="";
		
		public static var CONTENT_RECORD_SERVER:String="";
		
		public static var VIDEO_RECORD_SERVER:String="";
		
		public static var VIEWER_VIDEO_RECORD_SERVER:String="";
		
		public static var DATABASE_SERVER:String="";
		
		public static var NATIONAL_SERVER_IP:String="";
		
		public static var AVIEW_PROTOCOL:String = "http";
		
		public static var UPDATE_SERVER:String="ups001.aview.in";
		
		public static var protocolFMS:String=Constants.PROTOCOL_FMS_SERVER;
		
		public static var portFMS:int=Constants.FMS_SERVER_PORT;
		public static var portWAMP:int=Constants.CONTENT_SERVER_PORT;
		
		public static var WEBAPP_AVIEW:String="aview";
		public static var WEBAPP_AVIEW_END_POINT:String="";
		public static var WEBAPP_AVIEW_STREAMING_END_POINT:String="";
		public static var WEBAPP_AVIEW_POLLING_END_POINT:String="";
		
		//PNCR: Default content folder location
		public static var CONTENT_FOLDER:String="../../AVContent/Upload/Personal";
		
		public static var isDuplicateLogin:Boolean; //Set by Users module
		
		public static var isFireWalled:String="";
		
		public static var desktopSharingStreamName:String="";
		
		public static var collaborationService:CollaborationService = null;
		
		//For storing the help document config file path
		public static var HELP_DOCUMENT_URL:String = "";
		
		public static function setFireWallPorts(isFireWalled:String):void
		{
		
		}
		
		//Added for Quiz module
		public static var nodeTypeId:Number=0;
		//RGCR: See if this flag can be replaced by checking for the classroom comp. Please check with Sethu. Can the ClassroomContext.classStartedFlag be used?
		public static var checkIsClassRoom:Boolean;
		public static var lectureName:String="";
		//Fix for Bug#15194:Start
		public static var quizCategories:ArrayCollection = new ArrayCollection;
		public static var quizSubCategories:ArrayCollection = new ArrayCollection;
		public static var qpSubCategories:ArrayCollection = new ArrayCollection;
		public static var quizDifficultyLevels:ArrayCollection =  new ArrayCollection;
		public static var quizQuestionTypes:ArrayCollection = new ArrayCollection;
		//Fix for Bug#15194:End
		public static var EASY:Number=1;
		public static var DIFFICULT:Number=2;
		
		
		public static var questionPaperId:Number;
		public static var quizQuestionPaperQuestions:ArrayCollection;
		
		public static var RECORDED_CONTENT_URL:String;
		public static var RECORDED_CONTENT_FILE_PATH:String;
		
		public static var IS_AUDIO_VIDEO_ENABLED:Boolean;
		public static var IS_DOCUMENT_SHARING_ENABLED:Boolean;
		public static var IS_2D_ENABLED:Boolean;
		public static var IS_3D_ENABLED:Boolean;
		public static var IS_DESKTOP_SHARING_ENABLED:Boolean;
		public static var IS_VIDEO_SHARING_ENABLED:Boolean;
		/*
		 * For live class only
		 * Array to hold quizzes which are conducted in one session
		*/
		//Fix for Bug #15857 : Code commented
//		public static var conductedLiveQuizzes:ArrayCollection=new ArrayCollection;
		public static var meetingRoomVO:Object=null;
		
		public static var lecturePriorToFailOver : LectureVO = null;
		public static var publishingVideoStatusPriorToFailOver : Boolean = false;
		public static var userRolePriorToFailOver : String = ""; 
	}
}
