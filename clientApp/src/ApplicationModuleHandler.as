package {
	import com.amrita.edu.collaboration.CollaborationObject;
	
	import context.ContextManager;
	
	import edu.amrita.aview.audit.AuditConstants;
	import edu.amrita.aview.chat.ChatManager;
	import edu.amrita.aview.chat.events.ChatStatusEvent;
	import edu.amrita.aview.chat.vo.ChatSessionVO;
	import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;
	import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
	import edu.amrita.aview.common.components.fileManager.events.DownloadRequestedEvent;
	import edu.amrita.aview.common.components.fileManager.events.UploadCompletedEvent;
	import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
	import edu.amrita.aview.common.components.fileloader.events.FileLoadedEvent;
	import edu.amrita.aview.common.helper.AbstractHelper;
	import edu.amrita.aview.common.helper.SystemParameterHelper;
	import edu.amrita.aview.common.log.LogUtil;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.service.content.ContentService;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
	import edu.amrita.aview.common.util.DeleteZipFromServers;
	import edu.amrita.aview.common.util.StringUtility;
	import edu.amrita.aview.common.vo.AViewResponseVO;
	import edu.amrita.aview.common.vo.Auditable;
	import edu.amrita.aview.common.vo.StatusVO;
	import edu.amrita.aview.common.vo.SystemParameterVO;
	import edu.amrita.aview.core.entry.ModuleRO;
	applicationType::DesktopWeb{
		import edu.amrita.aview.common.components.userList.UserSOValue;
		import edu.amrita.aview.common.components.ArrayCollectionExtended;
		import edu.amrita.aview.chat.helper.ChatSessionHelper;
		import edu.amrita.aview.common.service.streaming.*;
		import edu.amrita.aview.common.service.streaming.VideoConnection;
		import edu.amrita.aview.audit.AuditContext;
		import edu.amrita.aview.biometric.CameraSelectionForm;
		import edu.amrita.aview.biometric.ErrorReportForm;
		import edu.amrita.aview.biometric.FaceRegistrationForm;
		import edu.amrita.aview.biometric.SnapshotComponent;
		import edu.amrita.aview.chat.ChatComponent;
		import edu.amrita.aview.chat.ChatHistory;
		import edu.amrita.aview.contacts.ContactsManager;
		import edu.amrita.aview.contacts.ContactsView;
		import edu.amrita.aview.contacts.events.ContactsProviderEvent;
		import edu.amrita.aview.common.components.Captcha;
		import edu.amrita.aview.common.components.CaptchaComponent;
		import edu.amrita.aview.common.components.ImageButton;
		import edu.amrita.aview.common.components.ProfileMenuComponent;
		import edu.amrita.aview.common.components.alert.CustomAlert;
		import edu.amrita.aview.common.components.checkBox.CheckBoxDataGrid;
		import edu.amrita.aview.common.components.checkBox.CheckBoxHeaderColumn;
		import edu.amrita.aview.common.components.checkBox.CheckBoxRenderer;
		import edu.amrita.aview.common.components.fileManager.FileManager;
		import edu.amrita.aview.common.components.userList.CRActionButtons;
		import edu.amrita.aview.common.components.userList.PTTBox;
		import edu.amrita.aview.common.components.userList.UserList;
		import edu.amrita.aview.videoSharing.VideoSharing;
		import edu.amrita.aview.threeDSharing.Viewer3DComponent;
		import edu.amrita.aview.twoDSharing.V2DEvent;
		import edu.amrita.aview.twoDSharing.Viewer2DComponent;
		import edu.amrita.aview.common.skins.ResizeImageButtonSkin;
		import edu.amrita.aview.common.util.AViewDateUtil;
		import edu.amrita.aview.common.util.AViewStringUtil;
		import edu.amrita.aview.common.util.ArrayCollectionUtil;
		import edu.amrita.aview.core.evaluation.polling.Polling;
		
		import edu.amrita.aview.core.shared.eventmap.EventMap;
		import edu.amrita.aview.core.shared.events.ChatEvent;
		import edu.amrita.aview.meeting.MeetingInvitation;
		import edu.amrita.aview.meeting.MeetingRoomManagerController;
		import edu.amrita.aview.meeting.MeetingRoomManagerModel;
		import edu.amrita.aview.meeting.MeetingScheduleModel;
		import edu.amrita.aview.meeting.events.CommonEvent;
		import edu.amrita.aview.meeting.events.MeetingEvent;
		import edu.amrita.aview.meeting.events.MeetingRoomEvent;
		import edu.amrita.aview.meeting.helper.MeetingManagerHelper;
		import edu.amrita.aview.meeting.vo.MeetingRoomVO;
		import edu.amrita.aview.core.gclm.vo.ClassVO;
		import edu.amrita.aview.core.gclm.vo.UserVO;
		import edu.amrita.aview.feedback.FeedbackForm;
		import edu.amrita.aview.help.HelpDownloadWindow;
		import edu.amrita.aview.meeting.InvitationMessage;
		import edu.amrita.aview.preferenceSettings.PreferenceSettings;
		import edu.amrita.aview.questions.QuestionComponent;
		import edu.amrita.aview.questions.events.QuestionInteractionEvent;
		import edu.amrita.aview.quickNotes.QuickNoteComponent;
		import edu.amrita.aview.questions.BreakSession;
		import edu.amrita.aview.preferenceSettings.Desktop;
	}
	applicationType::desktop{
		import edu.amrita.aview.threeDSharing.Viewer3DModule;
		import edu.amrita.aview.twoDSharing.Viewer2DWindow;
		import edu.amrita.aview.videoSharing.VideoSharingWindow;
		import edu.amrita.aview.core.evaluation.polling.PollingWindow;
		import edu.amrita.aview.core.evaluation.quiz.QuizWindow;
		import edu.amrita.aview.youTubeStreaming.YoutubeLiveSettings;
	}
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
	import edu.amrita.aview.questions.BreakDetails;
	import edu.amrita.aview.questions.events.BreakSessionEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import edu.amrita.aview.contacts.events.UserStatusProviderEvent;

	applicationType::mobile{
		import edu.amrita.aview.questions.QuestionComponentMobile;
		import edu.amrita.aview.questions.BreakSessionMobile;
		import edu.amrita.aview.chat.ChatMobileComponent;
	}
	

	public class ApplicationModuleHandler {

		public function ApplicationModuleHandler() {
		}

		public var abstractHelper:AbstractHelper;
		
		public var auditable:Auditable;
		public var auditConstants:AuditConstants;
		
		public var aViewResponseVO:AViewResponseVO;
		
		public var breakSessionEvent:BreakSessionEvent;
		
		public var chatStatusEvent:ChatStatusEvent;
		
		public var closeFileComponentEvent:CloseFileComponentEvent;
		public var chatSessionVO:ChatSessionVO;
		public var chatManager:ChatManager;
		applicationType::DesktopWeb{
			public var arrayCollectionExtended:ArrayCollectionExtended;
			public var commonEvent:CommonEvent;
			public var chatEvent:ChatEvent;
			public var chatSessionHelper:ChatSessionHelper;
			public var arrayCollectionUtil:ArrayCollectionUtil;
			public var aViewStringUtil:AViewStringUtil;
			public var auditContext:AuditContext;
			public var aViewDateUtil:AViewDateUtil;
			public var cameraSelectionForm:CameraSelectionForm;
			public var captcha:Captcha;
			public var captchaComponent:CaptchaComponent;
			public var chatComponent:ChatComponent;
			public var chatHistory:ChatHistory;
			public var checkBoxDataGrid:CheckBoxDataGrid;
			public var checkBoxHeaderColumn:CheckBoxHeaderColumn;
			public var checkBoxRenderer:CheckBoxRenderer;
			public var contactsManager:ContactsManager;
			public var contactsProviderEvent:ContactsProviderEvent;
			public var contactsView:ContactsView;
			public var customAlert:CustomAlert;
			public var cRActionButtons:CRActionButtons;
			public var errorReportForm:ErrorReportForm;
			public var faceRegistrationForm:FaceRegistrationForm;
			public var fileManager:FileManager;
			public var imageButton:ImageButton;
			public var helpDownloadWindow:HelpDownloadWindow;
			public var invitationMessage:InvitationMessage;
			public var meetingEvent:MeetingEvent;
			public var meetingInvitation:MeetingInvitation;
			public var meetingManagerHelper:MeetingManagerHelper;
			public var meetingRoomEvent:MeetingRoomEvent;
			public var meetingRoomManagerController:MeetingRoomManagerController;
			public var meetingRoomManagerModel:MeetingRoomManagerModel;
			public var meetingRoomVO:MeetingRoomVO;
			public var preferenceSettings:PreferenceSettings;
			public var profileMenuComponent:ProfileMenuComponent;
			public var pTTBox:PTTBox;
			public var questionComponent:QuestionComponent;
			public var questionInteractionEvent:QuestionInteractionEvent;
			public var quickNoteComponent:QuickNoteComponent;
			public var resizeImageButtonSkin:ResizeImageButtonSkin;
			public var snapshotComponent:SnapshotComponent;
			public var userList:UserList;
			public var v2DEvent:V2DEvent;
			public var videoConnection:VideoConnection;
			public var viewer2DComponent:Viewer2DComponent;
			public var viewer3DComponent:Viewer3DComponent;

			public var eventMap:EventMap;
			public var feedbackForm:FeedbackForm;
			public var userSOValue:UserSOValue;
			
			applicationType::desktop{
				public var viewer2DWindow:Viewer2DWindow;
				public var viewer3DModule:Viewer3DModule;
				public var youtubeLiveSettings:YoutubeLiveSettings;
			}
		}
		public var messageBox:MessageBox;
		public var messageBoxEvent:MessageBoxEvent;
		public var contentOperationEvent:ContentOperationEvent;
		public var contentService:ContentService;
		public var contextManager:ContextManager;
		public var deleteZipFromServers:DeleteZipFromServers;
		public var downloadRequestedEvent:DownloadRequestedEvent;
		
		
		public var fileLoadedEvent:FileLoadedEvent;
		public var fileLoaderManager:FileLoaderManager;
		
		public var logUtil:LogUtil;
		public var mediaServerConnection:MediaServerConnection;
		public var mediaServerStatusEvent:MediaServerStatusEvent;
		public var statusVO:StatusVO;
		public var stringUtility:StringUtility;
		public var systemParameterHelper:SystemParameterHelper;
		public var systemParameterVO:SystemParameterVO;
		public var uploadCompletedEvent:UploadCompletedEvent;
		
		
		//--entry ends--
		public function getcontextManagerObj():* {
			//#BUGFIX API. removed new to get static class reference to get viewer2DComp object.
			// error in classroomcomponentHandler.as line 534 (if (entryFac.contextManager() && entryFac.contextManager().viewer2DModule))
			return ContextManager; 
		}
		public function getauditConstantsObj():* {return new AuditConstants; }
		public function getchatStatusEventObj(type:String, bubbles:Boolean=false, cancelable:Boolean=false):*{
			return new ChatStatusEvent(type,bubbles,cancelable);
		}
		
		
		public function getfileLoadedEventObj(type:String, bubbles:Boolean=false, cancelable:Boolean=false):*{return new FileLoadedEvent(type,bubbles,cancelable);}
		public function getfileLoaderManagerObj(remoteFileLocation:String):* {return new FileLoaderManager(remoteFileLocation);}
		public function getcloseFileComponentEventObj(componentName:String):* {return new CloseFileComponentEvent(componentName);}
		public function getcontentOperationEventObj(type:String, bubbles:Boolean=false, cancelable:Boolean=false):* {return new ContentOperationEvent(type,bubbles,cancelable);}
		public function getdownloadRequestedEventObj(remoteFileName:String, remotePath:String, type:String):* {return new DownloadRequestedEvent(remoteFileName,remotePath,type);}
		public function getuploadCompletedEventObj(fileName:String, fileExtension:String, remotePath:String, animated:Boolean):* {return new UploadCompletedEvent(fileName,fileExtension,remotePath,animated);}
		public function getabstractHelperObj():* {return new AbstractHelper; }
		public function getsystemParameterHelperObj():* {return new SystemParameterHelper; }
		public function getlogUtilObj():* {return new LogUtil; }
		public function getcontentServiceObj():* {return new ContentService; }
//		public function getmediaServerStatusEventObj():* {return new MediaServerStatusEvent;}
		public function getmediaServerConnectionObj(serverIP:String, appName:String, instanceName:String, connectionParams:IList, client:Object):*{return new MediaServerConnection(serverIP,appName,instanceName,connectionParams,client);}
		
		public function getstringUtilityObj():* {return new StringUtility; }
		public function getauditableObj():* {return new Auditable; }
		public function getaViewResponseVOObj():* {return new AViewResponseVO; }
		public function getstatusVOObj():* {return new StatusVO; }
		public function getsystemParameterVOObj():* {return new SystemParameterVO; }
		public function getbreakSessionEventObj(type:String,breakDetails:BreakDetails=null, bubbles:Boolean=false, cancelable:Boolean=false):*{return new BreakSessionEvent(type,breakDetails,bubbles,cancelable);}
		public function getchatManagerObj(moduleRO:ModuleRO):* {return new ChatManager(moduleRO); }
		public function getchatSessionVOObj():* {return new ChatSessionVO; }
		public function getmessageBoxEventObj(type:String, bubbles:Boolean=false, cancelable:Boolean=false):*{return new MessageBoxEvent(type,bubbles,cancelable);}
		public function getmessageBoxObj():* {return new MessageBox; }
		applicationType::mobile{
			public function getbreakSessionObj():*{return new BreakSessionMobile;}
			public function getchatComponentObj():* {return new ChatMobileComponent; }
			public function getquestionComponentObj():* {return new QuestionComponentMobile; }
		}
		applicationType::DesktopWeb{
			public function getuserSOValueObj(userValue:Object):*{return new UserSOValue(userValue);}
			public function getarrayCollectionExtendedObj():* {return new ArrayCollectionExtended; }
			public function getbreakSessionObj():*{return new BreakSession;}
			public function getquestionInteractionEventObj(type:String, bubbles:Boolean=false, cancelable:Boolean=false):*{return new QuestionInteractionEvent(type,bubbles,cancelable);}
			public function gethelpDownloadWindowObj():* {return new HelpDownloadWindow; }
			public function getchatEventObj(type:String, data:Object=null, groupSO:CollaborationObject=null, groupOwner:String=null, groupName:String=null, bubbles:Boolean=false, cancelable:Boolean=false):*{return new ChatEvent(type,data,groupSO,groupOwner,groupName,bubbles,cancelable);}
			public function getcommonEventObj(type:String, data:Object):*{return new CommonEvent(type,data);}
			public function getvideoConnectionObj(ipFMS:String, streamingProtocol:String, applicationName:String, className:String, userName:String):*{return new VideoConnection(ipFMS,streamingProtocol,applicationName,className,userName);}
			public function geteventMapObj():* {return new EventMap; }
			public function getchatSessionHelperObj():* {return new ChatSessionHelper; }
			public function getauditContextObj():* {return new AuditContext; }
			public function getarrayCollectionUtilObj():* {return new ArrayCollectionUtil; }
			public function getaViewDateUtilObj():* {return new AViewDateUtil; }
			public function getaViewStringUtilObj():* {return new AViewStringUtil; }
			public function getcameraSelectionFormObj():* {return new CameraSelectionForm; }
			public function geterrorReportFormObj():* {return new ErrorReportForm; }
			public function getfaceRegistrationFormObj():* {return new FaceRegistrationForm; }
			public function getsnapshotComponentObj():* {return new SnapshotComponent; }
			public function getchatComponentObj():* {return new ChatComponent; }
			public function getchatHistoryObj():* {return new ChatHistory; }
			public function getcustomAlertObj():* {return new CustomAlert; }
			public function getcontactsProviderEventObj(type:String, callbackFunction:Function=null,bubbles:Boolean=false, cancelable:Boolean=false):*{return new ContactsProviderEvent(type,callbackFunction,bubbles,cancelable);}
			public function getcaptchaObj(type:String,counter:Number):* {return new Captcha(type,counter); }
			public function getcaptchaComponentObj():* {return new CaptchaComponent; }
			public function getcheckBoxDataGridObj():* {return new CheckBoxDataGrid; }
			public function getcheckBoxHeaderColumnObj():* {return new CheckBoxHeaderColumn; }
			public function getcheckBoxRendererObj():* {return new CheckBoxRenderer; }
			public function getdeleteZipFromServersObj():* {return new DeleteZipFromServers; }
			public function getfileManagerObj():* {return new FileManager; }
			public function getimageButtonObj():* {return new ImageButton; }
			public function getprofileMenuComponentObj():* {return new ProfileMenuComponent; }
			public function getcRActionButtonsObj():* {return new CRActionButtons; }
			public function getresizeImageButtonSkinObj():* {return new ResizeImageButtonSkin; }
			
			public function getcontactsViewObj():* {return new ContactsView; }
			public function getfeedbackFormObj():* {return new FeedbackForm;}
			public function getmeetingEventObj(type:String,schedule:MeetingScheduleModel, invitations:Array=null, bubbles:Boolean=false, cancelable:Boolean=false):*{return new MeetingEvent(type,schedule,invitations,bubbles,cancelable);}
			public function getmeetingRoomEventObj(type:String,meetingRoom:MeetingRoomVO=null, bubbles:Boolean=false, cancelable:Boolean=false):*{return new MeetingRoomEvent(type,meetingRoom,bubbles,cancelable);}
			public function getmeetingManagerHelperObj():* {return new MeetingManagerHelper; }
			public function getinvitationMessageObj():* {return new InvitationMessage; }
			public function getmeetingInvitationObj():* {return new MeetingInvitation; }
			public function getmeetingRoomManagerModelObj(meetingMembers:ArrayCollection,mode:String,roomName:String,allMeetingRooms:ArrayCollection,userVO:UserVO):*{return new MeetingRoomManagerModel(meetingMembers,mode,roomName,allMeetingRooms,userVO);}
			public function getmeetingRoomVOObj():* {return new MeetingRoomVO; }
			public function getpreferenceSettingsObj():* {return new PreferenceSettings; }
			public function getdesktopPreferenceSettingobj():* {return new Desktop;}
			public function getpTTBoxObj():* {return new PTTBox; }
			public function getuserListObj():* {return new UserList; }
			public function getquestionComponentObj():* {return new QuestionComponent; }
			public function getquickNoteComponentObj():* {return new QuickNoteComponent; }
			public function getviewer3DComponentObj():* {return new Viewer3DComponent; }
			public function getv2DEventObj(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:*=null):*{return new V2DEvent(type,bubbles,cancelable,data);}
			public function getviewer2DComponentObj():* {return new Viewer2DComponent;}
			public function getVideoSharingClass():* {return VideoSharing; }
			//PNCR: added missing functions
			public function getvideoSharingObj():* {return new VideoSharing;}
			public function getpollingObj():* {return new Polling;}
			applicationType::desktop{
				public function getviewer2DWindowObj():* {return new Viewer2DWindow;}
				public function getvideoSharingWindowObj():* {return new VideoSharingWindow;}
				public function getpollingWindowObj():* {return new PollingWindow;}
				public function getquizWindowObj():* {return new QuizWindow;}
				public function getviewer3DModuleObj():* {return new Viewer3DModule;}
				public function getyoutubeLiveSettingsObj():* {return new YoutubeLiveSettings;}
			}
			public function getcontactsManagerObj(userVO:UserVO,appEventMap:EventMap):*{return new ContactsManager(userVO,appEventMap);}
			public function getmeetingRoomManagerControllerObj(moduleRO:ModuleRO,allContacts:ArrayCollection,allMeetingRooms:ArrayCollection,meetingRoomMembers:ArrayCollection,roomName:String,meetingRoom:ClassVO,mode:String):*{return new MeetingRoomManagerController(moduleRO,allContacts,allMeetingRooms,meetingRoomMembers,roomName,meetingRoom,mode);}
		    public function getUserStatusProviderEventObj(userStatusReceiver:Function):*{return new UserStatusProviderEvent(UserStatusProviderEvent.USER_STATUS_CHANGE,userStatusReceiver);}
		}
		//PNCR: added a seperate class return to access static constants without object. 
		//#BUGFIX. in classroomComponentHandler.as. function - processExitClassroom. line - ClassroomContext.collaborationService.closeCollaborationObject(videoSharing.VIDEO_STATUS_ID); 
		
		
	}
}
