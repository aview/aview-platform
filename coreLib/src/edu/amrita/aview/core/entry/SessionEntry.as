package edu.amrita.aview.core.entry
{
	import edu.amrita.aview.core.common.FMSPortTester;
	import edu.amrita.aview.core.gclm.helper.LectureHelper;
	import edu.amrita.aview.core.gclm.vo.ClassServerVO;
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	import edu.amrita.aview.core.gclm.vo.LectureListVO;
	import edu.amrita.aview.core.login.boilerplate.Strings;
	import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
	import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
	import edu.amrita.aview.core.shared.service.content.ContentService;
	import edu.amrita.aview.core.shared.vo.AViewResponseVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class SessionEntry extends EventDispatcher
	{
		public function SessionEntry()
		{
		}
		private var lectureDetail:LectureListVO=null;
		
		private var logger:ILogger=Log.getLogger("aview.GetClassDetails.as");
		
		public function getClassRoomLecture(lectureId:Number):void {
			var lectureHelper:LectureHelper=new LectureHelper();
			//Refreshing to get the latest values. To take care of any changes done on the backend between the gap of listing and double clicking
			lectureHelper.getClassRoomLectureByLectureId(lectureId,getClassRoomLectureByLectureIdResultHandler);
		}
		public function getClassRoomLectureByLectureIdResultHandler(response:AViewResponseVO):void {
			
			if (response.responseId != AViewResponseVO.REQUEST_SUCCESS) {
				Alert.show(response.responseMessage);
				return;
			}			
			lectureDetail=response.result as LectureListVO;
			gotoclass();
		}
		public function gotoclass():void {
			//Fix for Bug#16309:Start
			if(ClassroomContext.aviewClass == null)
			{
				ClassroomContext.aviewClass = new ClassVO;
			}
			//Fix for Bug#16309:End
			ClassroomContext.aviewClass=lectureDetail.aviewClass;
			ClassroomContext.course=lectureDetail.course;
			ClassroomContext.lecture=lectureDetail.lecture;
			ClassroomContext.institute=lectureDetail.institute;
			
			//Fix for Bug#16309:Start
			if (lectureDetail.aviewClass.classServers.length == 0)
			{
				Alert.show("No Server has been allocated for this class. Please contact the Administrator", "Error", 4, null, closeHandler);
				return;
			}
			//Fix for Bug#16309:End
	
			if (ClassroomContext.userVO.role != Constants.ADMIN_TYPE && ClassroomContext.userVO.role != Constants.MASTER_ADMIN_TYPE) {
				applicationType::web {
					//For Guest Login: Guest user has no class registration details
					if (!FlexGlobals.topLevelApplication.mainApp.ssoMode != Strings.guestLogin) {
						ClassroomContext.nodeTypeId=lectureDetail.classRegistration.nodeTypeId;
					}
					//Added following logic to restrict the Teacher to enter into classroom if number of video streams for this class has been set to 'Multiple'.
					if (ClassroomContext.aviewClass.isMultiBitrate == "Y" && (lectureDetail.isModerator == "Y" || ClassroomContext.userVO.role == Constants.TEACHER_TYPE)) {
						Alert.show("Number of video streams for this class has been set to 'Multiple', which is not currently supported in A-VIEW web version, kindly use desktop version or contact your A-VIEW Institute Administrator to change the video settings", "WARNING");
						return;
					}
					//Guest Login: Guest user has no class registration details
					if (!FlexGlobals.topLevelApplication.mainApp.ssoMode != Strings.guestLogin && lectureDetail.classRegistration.isModerator == "Y") {
						ClassroomContext.isModerator=true;
						ClassroomContext.moderatorName=ClassroomContext.userVO.userName;
					} else {
						ClassroomContext.isModerator=false;
					}
					//Guest Login: Guest user has no class registration details
					if (!FlexGlobals.topLevelApplication.mainApp.ssoMode != Strings.guestLogin) {
						ClassroomContext.IS_AUDIO_VIDEO_ENABLED=(lectureDetail.classRegistration.enableAudioVideo == "Y");
						ClassroomContext.IS_DOCUMENT_SHARING_ENABLED=(lectureDetail.classRegistration.enableDocumentSharing == "Y");
						ClassroomContext.IS_DESKTOP_SHARING_ENABLED=(lectureDetail.classRegistration.enableDesktopSharing == "Y");
						ClassroomContext.IS_VIDEO_SHARING_ENABLED=(lectureDetail.classRegistration.enableVideoSharing == "Y");
						ClassroomContext.IS_2D_ENABLED=(lectureDetail.classRegistration.enable2DSharing == "Y");
						ClassroomContext.IS_3D_ENABLED=(lectureDetail.classRegistration.enable3DSharing == "Y");
					}
				}
				applicationType::desktop {
					ClassroomContext.nodeTypeId=lectureDetail.classRegistration.nodeTypeId;	
					if (lectureDetail.classRegistration.isModerator == "Y") {
						ClassroomContext.isModerator=true;
						ClassroomContext.moderatorName=ClassroomContext.userVO.userName;
					} else {
						ClassroomContext.isModerator=false;
					}
					ClassroomContext.IS_AUDIO_VIDEO_ENABLED=(lectureDetail.classRegistration.enableAudioVideo == "Y");
					ClassroomContext.IS_DOCUMENT_SHARING_ENABLED=(lectureDetail.classRegistration.enableDocumentSharing == "Y");
					ClassroomContext.IS_DESKTOP_SHARING_ENABLED=(lectureDetail.classRegistration.enableDesktopSharing == "Y");
					ClassroomContext.IS_VIDEO_SHARING_ENABLED=(lectureDetail.classRegistration.enableVideoSharing == "Y");
					ClassroomContext.IS_2D_ENABLED=(lectureDetail.classRegistration.enable2DSharing == "Y");
					ClassroomContext.IS_3D_ENABLED=(lectureDetail.classRegistration.enable3DSharing == "Y");
				}
			}
			applicationType::DesktopWeb{
				//RGCR: Instead of referring the mainContainerComp this way, it can be passed as a parameter during creation and that param can be used inside.
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.initializeClassroomComponent();
				//		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.actionBtns.chkboxPushToTalk.selected = false;
			}
			
			
			ClassroomContext.classStartedFlag=true;
			populateClassRoomServers(false);
			//createRemoteFolder();
			if (ClassroomContext.aviewClass.classType == "Meeting" && ClassroomContext.isModerator) {
				Alert.show("Start your Audio and Video", "INFO",Alert.OK|Alert.CANCEL,FlexGlobals.topLevelApplication.mainApp,confirmVideoPublishing);

				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.startStopVideoAfterScreenCameraCheck("Start");
			}
			applicationType::web {
				//Callback from javascript function to get the details of java plugin is enabled or not
				if (ExternalInterface.available) {
					ExternalInterface.addCallback('isJavaPluginEnabled', FlexGlobals.topLevelApplication.mainApp.mainContainerComp.setJavaAvailability);
				}
			}
		}
		
		/*
		//PNCR: commented the function. The functionality is added in the Wamp fileList.php file.
		//PNCR: added function to fix folder creation error for file listing
		private function createRemoteFolder():void {
			var contentService:ContentService=new ContentService();
			contentService.createFolder(ClassroomContext.CONTENT_FOLDER+ "/" + ClassroomContext.userVO.userName, succesFolderCreation, onFault);
		}
		
		private function succesFolderCreation(msg:Object):void {
		}
		private function onFault(event:Event):void {	
		}
		*/
		private function confirmVideoPublishing(event:CloseEvent):void {
			if(event.detail==Alert.OK)
			{
				applicationType::DesktopWeb{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setSetting();
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isPretestingPrompt = true;
				}
			}
		}

		public function populateClassRoomServers(isServerFailOver:Boolean):void {
			applicationType::DesktopWeb {
				//Fix for issue #11616
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isServerFailOver=isServerFailOver;
			}
			var missingServers:ArrayList=new ArrayList();
			missingServers.addItem(Constants.FMS_PRESENTER_DISPLAY);
			missingServers.addItem(Constants.FMS_DATA_DISPLAY);
			missingServers.addItem(Constants.FMS_DESKTOP_SHARING_DISPLAY);
			missingServers.addItem(Constants.FMS_VIEWER_DISPLAY);
			missingServers.addItem(Constants.CONTENT_SERVER_DISPLAY);
			
			//get the ip address of each server related to the class
			for (var counter:int=0; counter < ClassroomContext.aviewClass.classServers.length; counter++) {
				var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClass.classServers.getItemAt(counter));
				if (classServer.serverTypeName == Constants.CONTENT_SERVER || classServer.serverTypeName == Constants.MEETING_CONTENT_SERVER) {
					logger.info("CONTENT_SERVER:" + classServer.server.serverName + ":" + classServer.server.serverIp);
					ClassroomContext.CONTENT_DOCUMENT=classServer.server.serverIp;
					ClassroomContext.CONTENT_WHITEBOARD=classServer.server.serverIp;
					ClassroomContext.CONTENT_VIEWER3D=classServer.server.serverIp;
					ClassroomContext.CONTENT_VIEWER2D=classServer.server.serverIp;
					ClassroomContext.CONTENT_RECORD_SERVER=classServer.server.serverIp;
					ClassroomContext.contentServerSupportsAnimations=(classServer.server.supportsAnimation == "Y");
					missingServers.removeItem(Constants.CONTENT_SERVER_DISPLAY);
				} else if (classServer.serverTypeName == Constants.FMS_DATA || classServer.serverTypeName == Constants.MEETING_COLLABORATION_SERVER) {
					logger.info("FMS_DATA:" + classServer.server.serverName + ":" + classServer.server.serverIp);
					ClassroomContext.FMS_USER=classServer.server.serverIp;
					ClassroomContext.FMS_USER_SERVER_CATEGORY=classServer.server.serverCategory;
					missingServers.removeItem(Constants.FMS_DATA_DISPLAY);
				} else if (classServer.serverTypeName == Constants.FMS_DESKTOP_SHARING || classServer.serverTypeName == Constants.MEETING_FMS_DESKTOP_SHARING) {
					logger.info("FMS_DESKTOP_SHARING:" + classServer.server.serverName + ":" + classServer.server.serverIp);
					ClassroomContext.DESKTOP_SHARING_SERVER=classServer.server.serverIp;
					missingServers.removeItem(Constants.FMS_DESKTOP_SHARING_DISPLAY);
				} else if (classServer.serverTypeName == Constants.FMS_VIEWER || classServer.serverTypeName == Constants.MEETING_FMS_VIEWER) {
					missingServers.removeItem(Constants.FMS_VIEWER_DISPLAY);
				} else if (classServer.serverTypeName == Constants.FMS_PRESENTER || classServer.serverTypeName == Constants.MEETING_FMS_PRESENTER) {
					missingServers.removeItem(Constants.FMS_PRESENTER_DISPLAY);
				}
			}
			if (missingServers.length > 0) {
				throwMissingServersAlert(missingServers);
				return;
			}
//			renameClassNames();
			//ashcr: simplified the usage of function
			var spacePattern:RegExp = / /g;
			ClassroomContext.aviewClass.className = ClassroomContext.aviewClass.className.replace(spacePattern,"_");
			//call function to set the vidoe record server which has least publishing bandwidth.
			getVideoRecordServer();
			//Call to enterclass function in the main.mxml file.
			applicationType::DesktopWeb{
				if (!isServerFailOver) {
					//Fix for bug # 18492 start
					//No need to call enterClass as this is called in the result handler of FMSPortTest
					//FlexGlobals.topLevelApplication.mainApp.enterclass();
					//Fix for bug # 18492 end
					//Fix for Bug #18008
					var portTester:FMSPortTester=new FMSPortTester(ClassroomContext.FMS_USER, "/" + Constants.COLLABORATION_SERVER_MODULE_NAME + "/ConnectionTester",FlexGlobals.topLevelApplication.mainApp.enterclass,FlexGlobals.topLevelApplication.mainApp);
					portTester.selectFMSPort();
				} 
					//Avoid null object reference issue, when user exit from the classroom and administrator do server fail over.
				else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp) {
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initiateServerSwitching();
				}
			}
			applicationType::mobile{
				FlexGlobals.topLevelApplication.mainApp.videoServersData=slicingVideoServerData();
				if (!isServerFailOver) {
					FlexGlobals.topLevelApplication.mainApp.enterclass();
				}
				else
				{
					FlexGlobals.topLevelApplication.initiateServerSwitching();
				}
			}
		}
		
		
		private function throwMissingServersAlert(missingServers:ArrayList):void {
			var missingMessge:String="Class needs the following " + missingServers.length + " Servers allocated ";
			for (var i:int=0; i < missingServers.length; i++) {
				missingMessge+="\n" + (i + 1) + ". "; //List each server in a new line with a number
				missingMessge+=missingServers.getItemAt(i);
			}
			MessageBox.show(missingMessge, "Error", MessageBox.MB_OK,null, closeHandler);
			
		}
		public function slicingVideoServerData():ArrayCollection {
			var videoServersData:ArrayCollection=new ArrayCollection();
			videoServersData.removeAll();
			for (var i:int=0; i < ClassroomContext.aviewClass.classServers.length; i++) {
				var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClass.classServers.getItemAt(i));
				var tempObject:Object=new Object();
				if (classServer.serverTypeName == Constants.FMS_PRESENTER || classServer.serverTypeName == Constants.FMS_VIEWER) {
					tempObject.ip=classServer.server.serverIp;
					tempObject.serverCategory=classServer.server.serverCategory;
					tempObject.serverType=classServer.serverTypeName;
					tempObject.portNumber=classServer.serverPort;
					tempObject.bandWidth=classServer.presenterPublishingBandwidthKbps;
					videoServersData.addItem(tempObject);
				}
			}
			var sort:Sort=new Sort();
			sort.fields=[new SortField("serverType", true), new SortField("bandWidth", true, false, true)];
			videoServersData.sort=sort;
			videoServersData.refresh();
			return videoServersData;
			//Alert.show(videoServersData[0].serverType+videoServersData[0].bandWidth+videoServersData[1].serverType+videoServersData[1].bandWidth+videoServersData[2].serverType+videoServersData[2].bandWidth+videoServersData[3].serverType+videoServersData[3].bandWidth);
		}
		
		public function getVideoRecordServer():void {
			var videoPreseneterSerevrArray:ArrayCollection=new ArrayCollection();
			
			for (var i:int=0; i < ClassroomContext.aviewClass.classServers.length; i++) {
				var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClass.classServers.getItemAt(i));
				var tempObject:Object=new Object();
				if (classServer.serverTypeName == Constants.FMS_PRESENTER ||classServer.serverTypeName ==Constants.MEETING_FMS_PRESENTER ) {
					logger.info("FMS_PRESENTER:" + classServer.server.serverName + ":" + classServer.server.serverIp + ":" + classServer.presenterPublishingBandwidthKbps);
					tempObject.server_ip=classServer.server.serverIp;
					tempObject.presenter_publishing_bw_kbps=classServer.presenterPublishingBandwidthKbps;
					videoPreseneterSerevrArray.addItem(tempObject);
				} else if (classServer.serverTypeName == Constants.FMS_VIEWER || classServer.serverTypeName == Constants.MEETING_FMS_VIEWER) {
					logger.info("FMS_VIEWER:" + classServer.server.serverName + ":" + classServer.server.serverIp);
					ClassroomContext.VIEWER_VIDEO_RECORD_SERVER=classServer.server.serverIp;
				}
			}
			var sort:Sort=new Sort();
			sort.fields=[new SortField("presenter_publishing_bw_kbps", true, false, true)];
			videoPreseneterSerevrArray.sort=sort;
			videoPreseneterSerevrArray.refresh();
			
			if (videoPreseneterSerevrArray.length > 0) {
				ClassroomContext.VIDEO_RECORD_SERVER=videoPreseneterSerevrArray.getItemAt(0).server_ip;
			}
		}
		private function closeHandler(event:Event):void
		{
			this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
	}
}