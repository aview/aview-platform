////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: AuditConstants.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * Constants file for the Audit modules.
 */

package edu.amrita.aview.audit
{
	
	/**
	 * Constants file for the Audit modules.
	 */
	public class AuditConstants
	{
		/**
		 * @Constructor
		 * Default, no argument constructor. No business logic here. 
		 * 
		 */
		public function AuditConstants()
		{
		}
		
		//2D Module Action Names
		public static const twoDSharingUpLoad:String="2DSharingUpload";
		public static const twoDSharingLoad:String="2DSharingLoad";
		public static const twoDSharingPlay:String="2DSharingPlay";
		public static const twoDSharingPause:String="2DSharingPause";
		public static const twoDSharingSeek:String="2DSharingSeek";
		public static const twoDSharingStop:String="2DSharingStop";
		
		//3D Module Action Names
		public static const threeDSharingLoad:String="3DSharingLoad";
		public static const threeDSharingStop:String="3DSharingStop";
		public static const threeDSharingUpload:String="3DSharingUpload";
		
		//Chat Module Action Names
		public static const chatClear:String="ChatClear";
		public static const chatMessage:String="ChatMessage";
		public static const privateChatMessage:String="PrivateChatMessage";
		
		//Media Server Connection Action Names
		public static const connectionClose:String="ConnectionClose";
		public static const connectionFail:String="ConnectionFail";
		public static const connectionReject:String="ConnectionReject";
		public static const connectionSuccess:String="ConnectionSuccess";
		
		//Desktop Sharing Module Action Names
		public static const desktopSharingStart:String="DesktopSharingStart";
		public static const desktopSharingEnd:String="DesktopSharingEnd";
		
		//Document Sharing Module Action Names
		public static const documentUpload:String="DocumentUpload";
		public static const documentView:String="DocumentView";
		public static const documentThumbnail:String="DocumentThumbnail";
		public static const documentNavigation:String="DocumentNavigation";
		public static const documentPointer:String="DocumentPointer";
		public static const documentRotate:String="DocumentRotate";
		public static const documentZoomIn:String="DocumentZoomIn";
		public static const documentZoomOut:String="DocumentZoomOut";
		public static const documentZoomReset:String="DocumentZoomReset";
		public static const documentRefresh:String="DocumentRefresh";
		public static const documentAllowDownload:String="DocumentAllowDownload";
		public static const documentDenyDownload:String="DocumentDenyDownload";
		public static const documentUnload:String="DocumentUnload";
		public static const documentDownloadLocal:String="DocumentDownloadLocal";
		public static const documentAnnotationTools:String="DocumentAnnotationTools";
		public static const documentRemoveAnnotationTools:String="DocumentRemoveAnnotationTools";
		public static const documentAnnotationToolSelection:String="DocumentAnnotationToolSelection";
		
		//Video Sharing Module Action Names
		public static const videoSharingUpload:String="VideoSharingUpload";
		public static const videoSharingLoad:String="VideoSharingLoad";
		public static const videoSharingPlay:String="VideoSharingPlay";
		public static const videoSharingPause:String="VideoSharingPause";
		public static const videoSharingSeek:String="VideoSharingSeek";
		public static const videoSharingStop:String="VideoSharingStop";
		
		//Playback Module Action Names
		public static const playbackEnd:String="PlaybackEnd";
		public static const playbackStart:String="PlaybackStart";
		
		//Editing Module Action Names
		public static const editingEnd:String="EditingEnd";
		public static const editingStart:String="EditingStart";
		
		//User Interaction Module Action Names
		public static const presenterRequest:String="PresenterRequest";
		public static const interacting:String="Interacting";
		public static const handraised:String="Handraised";
		public static const handraiseReleased:String="HandraiseReleased";
		public static const interactionEnded:String="InteractionEnded";
		public static const viewed:String="Viewed";
		public static const closeViewed:String="CloseViewed";
		public static const userRole:String="UserRole";
		public static const releaseAllHandRaises:String="ReleaseAllHandRaises";
		
		//Question Module Action Names
		public static const questionAnswer:String="QuestionAnswer";
		public static const questionAsk:String="QuestionAsk";
		public static const questionDelete:String="QuestionDelete";
		public static const questionVote:String="QuestionVote";
		
		//Recording Module Action Names
		public static const recordingEnd:String="RecordingEnd";
		public static const recordingStart:String="RecordingStart";
		
		//Video Module Action Names
		public static const presenterVideoToggle:String="PresenterVideoToggle";
		public static const viewerVideoToggle:String="ViewerVideoToggle";
		public static const videoRefresh:String="VideoRefresh";
		public static const videoPublishStart:String="VideoPublishStart";
		public static const videoPublishEnd:String="VideoPublishEnd";
		public static const videoBitrateSelection:String="VideoBitrateSelection";
		public static const fullScreenVideoPresenter:String="FullScreenVideoPresenter";
		public static const fullScreenVideoSelectedViewer:String="FullScreenVideoSelectedViewer";
		public static const fullScreenVideoViewedViewer:String="FullScreenVideoViewedViewer";
		public static const closeFullScreenVideoPresenter:String="CloseFullScreenVideoPresenter";
		public static const closeFullScreenVideoSelectedViewer:String="CloseFullScreenVideoSelectedViewer";
		public static const closeFullScreenVideoViewedViewer:String="CloseFullScreenVideoViewedViewer";
		public static const pushToTalk:String="PushToTalk";
		public static const freeTalk:String="FreeTalk";
		
		//Whiteboard Module Action Names
		public static const whiteBoardCollaboration:String="WhiteBoardCollaboration";
		public static const whiteBoardHide:String="WhiteBoardHide";
		public static const whiteBoardPageChange:String="WhiteBoardPageChange";
		public static const whiteBoardTool:String="WhiteBoardTool";
		public static const whiteBoardPointer:String="WhiteBoardPointer";
		public static const whiteBoardLineColor:String="WhiteBoardLineColor";
		public static const whiteBoardClear:String="WhiteBoardClear";
		public static const whiteBoardRestore:String="WhiteBoardRestore";
		public static const whiteBoardLineThickness:String="WhiteBoardLineThickness";
		
		//Interface/GUI Action Names
		public static const keyboardShortcut:String="KeyboardShortcut";
		public static const filterUsers:String="FilterUsers";
		public static const hidePanel:String="HidePanel";
		public static const showPanel:String="ShowPanel";
		public static const prefUserListSorting:String="PrefUserListSorting";
		public static const prefMultiUserInteration:String="PrefMultiUserInteration";
		public static const prefUninterruptedDesktopSharing:String="PrefUninterruptedDesktopSharing";
		
		//Feedback Module Action Names
		public static const feedBack:String="Feedback";
		
		//Pretesting Module Action Names
		public static const pretestingLaunch:String="Pre-CheckLaunch";
		public static const pretestingSpeakerTab:String="Pre-CheckSpeakerTab";
		public static const pretestingSpeakerTestResult:String="Pre-CheckSpeakerTest";
		public static const pretestingMikeTab:String="Pre-CheckMikeTab";
		public static const pretestingMikeTestResult:String="Pre-CheckMikeTest";
		public static const pretestingCameraTab:String="Pre-CheckCameraTab";
		public static const pretestingCameraTestResult:String="Pre-CheckCameraTest";
		public static const pretestingSave:String="Pre-CheckSave";
		
		//Help Module Action Names
		public static const helpUsage:String="HelpUsage";
		
		//Biometric Module Action Names
		public static const faceRecognitionRegister:String="FaceRecognitionRegister";
		public static const faceRecognitionRemove:String="FaceRecognitionRemove";
		public static const faceRecognitionNotRegistered:String="FaceRecognitionNotRegistered";
		
		//Login Module Action Names
		public static const changePassword:String="Change Password";
		
		//Popout/popin Module Action Names
		public static const popOutDocument:String="PopOutDocument";
		public static const popInDocument:String="PopInDocument";
		public static const popOutWhiteBoard:String="PopOutWhiteBoard";
		public static const popInWhiteBoard:String="PopInWhiteBoard";
		public static const popOut2D:String="PopOut2D";
		public static const popIn2D:String="PopIn2D";
		public static const popOutVideoSharing:String="PopOutVideoSharing";
		public static const popInVideoSharing:String="PopInVideoSharing";
		public static const popOutChat:String="PopOutChat";
		public static const popInChat:String="PopInChat";
		
		//Videowall module Action names
		public static const videoWallOpen:String="VideoWallOpen";
		public static const videoWallClose:String="VideoWallClose";
		public static const videoWallPopOut:String="VideoWallPopOut";
		public static const videoWallPopIn:String="VideoWallPopIn";
	
	}
}
