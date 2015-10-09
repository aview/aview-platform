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
 * File			: AuditUserAction.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * Helps the application modules in auditing actions.
 * Each action has a corresponding in this class, which translates the specific action details
 * to generic action details and calls the UserActionHelper class
 * which communicates and stores the action in the database.
 *
 */

package edu.amrita.aview.audit
{
	//Importing helper for db communications
	import edu.amrita.aview.audit.helper.UserActionHelper;
	import edu.amrita.aview.audit.vo.UserActionVO;
	
	import mx.core.FlexGlobals;
	
	//Importing Global constants and context
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	/**
	 * Helps the application modules in auditing actions.
	 * Each action has a corresponding in this class, which translates the specific action details
	 * to generic action details and calls the UserActionHelper class
	 * which communicates and stores the action in the database.
	 */
	public class AuditUserAction
	{
		/**
		 * Initializing the helper class for db communications
		 */
		private var userActionHelper:UserActionHelper=new UserActionHelper();
		
		/**
		 *
		 * @public
		 * The user actions are not sent to db directly. They are batched and sent to db server in the intervals of 5 mins.
		 * So when the user is exiting the classroom, if there are any pending actions, then this method send them to db server
		 * @return void
		 *
		 */
		public function insertPendingActionsWhileExitingClassroom():void
		{
			userActionHelper.databaseInsert();
		}
		/**
		 *
		 * @public
		 * Audits the "InteractionEnded" action, when the user/presenter ends the interaction
		 *
		 * @param userName of the viewer who's interaction just ended
		 * @param interactionCount - Total number of interactions including the current one
		 * @return void
		 *
		 */	
		public function userInteractionEndedEventLog(userName:String, interactionCount:int):void
		{
			createAction(AuditConstants.interactionEnded, userName, interactionCount + "", null);
		}
		/**
		 *
		 * @public
		 * Audits the "ConnectionSuccess" action for a module
		 *
		 * @param module - A-VIEW Module name
		 * @param portFMS - FMS port to which the connection being made
		 * @param connectionRetrys - Current number of connection retrys
		 * @return void
		 *
		 */
		public function connectionSuccessEventLog(module:String, portFMS:String, connectionRetrys:String):void
		{
			if (AuditContext.actionsHash != null)
				createAction(AuditConstants.connectionSuccess, module, portFMS, connectionRetrys);
		}
		/**
		 *
		 * @public
		 * Audits the "ConnectionClose" action for a module
		 *
		 * @param module - A-VIEW Module name
		 * @param portFMS - FMS port to which the connection being made
		 * @return void
		 *
		 */	
		public function connectionCloseEventLog(module:String, portFMS:String):void
		{
			createAction(AuditConstants.connectionClose, module, portFMS, null);
		}
		/**
		 *
		 * @public
		 * Audits the "ConnectionFail" action for a module
		 *
		 * @param module - A-VIEW Module name
		 * @param portFMS - FMS port to which the connection being made
		 * @return void
		 *
		 */	
		public function connectionFailEventLog(module:String, portFMS:String):void
		{
			createAction(AuditConstants.connectionFail, module, portFMS, null);
		}
		/**
		 *
		 * @public
		 * Audits the "ConnectionReject" action for a module
		 *
		 * @param module - A-VIEW Module name
		 * @param portFMS - FMS port to which the connection being made
		 * @return void
		 *
		 */
		public function connectionRejectEventLog(module:String, portFMS:String):void
		{
			createAction(AuditConstants.connectionReject, module, portFMS, null);
		}
		/**
		 *
		 * @public
		 * Audits the "DesktopSharingStart" action, when the presenter starts sharing his/her desktop
		 *
		 * @param sharingMode - Whether the mode is Application sharing or Desktop sharing
		 * @param applicationName - Total number of interactions including the current one
		 * @return void
		 *
		 */
		public function desktopSharingStartEventLog(sharingMode:String, applicationName:String):void
		{
			createAction(AuditConstants.desktopSharingStart, sharingMode, applicationName, null);
		}
		
		/**
		 *
		 * @public
		 * Audits the "DesktopSharingEnd" action, when the presenter stops sharing his/her desktop
		 *
		 * @param sharingMode - Whether the mode is Application sharing or Desktop sharing
		 * @param applicationName - Total number of interactions including the current one
		 * @return void
		 *
		 */	
		public function desktopSharingEndEventLog(sharingMode:String, applicationName:String):void
		{
			createAction(AuditConstants.desktopSharingEnd, sharingMode, applicationName, null);
		}
		/**
		 *
		 * @public
		 * Audits the "KeyboardShortcut" action, when the user uses any short cut in any module
		 *
		 * @param shortCut used
		 * @param module in which it's used
		 * @return void
		 *
		 */
		public function keyBoardShortcutEventLog(shortCut:String, module:String):void
		{
			createAction(AuditConstants.keyboardShortcut, shortCut, module, null);
		}
		/**
		 *
		 * @public
		 * Audits the "Pre-CheckLaunch" action, when the user launches the pretesting launch window
		 *
		 * @param launchFrom - 'Settings' or 'Prompt'
		 * @return void
		 *
		 */
		public function pretestingLaunchEventLog(launchFrom:String):void
		{
			createAction(AuditConstants.pretestingLaunch, launchFrom, null, null);
		}
		/**
		 *
		 * @public
		 * Audits the "PrefUninterruptedDesktopSharing" action, when the presenter/moderator changes the Uninterrupted DesktopSharing preference.
		 *
		 * @param status - UninterruptedDesktopSharing Off/On
		 * @return void
		 *
		 */
		public function changePrefUninterruptedDesktopSharingEventLog(status:String):void
		{
			createAction(AuditConstants.prefUninterruptedDesktopSharing, status, null, null);
		}
		/**
		 *
		 * @public
		 * Audits the "VideoWallPopOut" action, when the user Pops out the video wall tab
		 *
		 * @return void
		 *
		 */
		public function videoWallPopOutEventLog():void
		{
			createAction(AuditConstants.videoWallPopOut, null, null, null);
		}
		
		/**
		 *
		 * @public
		 * Audits the "VideoWallPopIn" action, when the user Pops in/closes the video wall tab
		 *
		 * @return void
		 *
		 */
		public function videoWallPopInEventLog():void
		{
			createAction(AuditConstants.videoWallPopIn, null, null, null);
		}
		/**
		 *
		 * @private
		 * Pakcages the action into the UserActionVO and calls the userActionHelper for storing in the databse
		 *
		 * @param actionName - Name of the Action being audited
		 * @param attributeValue1 - Associated details related to the action
		 * @param attributeValue2 - Associated details related to the action
		 * @param attributeValue3 - Associated details related to the action
		 * @return void
		 *
		 */
		public function createAction(actionName:String, attributeValue1:String, attributeValue2:String, attributeValue3:String):void
		{
			if(AuditContext.actionsHash[actionName])
			{
				var actionId:int = AuditContext.actionsHash[actionName];
				if (ClassroomContext.aviewClass == null || ClassroomContext.aviewClass.auditLevel == Constants.AUDIT_ACTION_LEVEL)
				{
					if(AuditContext.userLoginVO)//Some times actions coming even before the login audit is done, we have to skip these actions..:-(
					{
						var userActionVO:UserActionVO=new UserActionVO();
						userActionVO.auditUserLoginId=AuditContext.userLoginVO.auditUserLoginId;
						userActionVO.actionId=actionId;
						userActionVO.attribute1Value=attributeValue1;
						userActionVO.attribute2Value=attributeValue2;
						userActionVO.attribute3Value=attributeValue3;
						
						if (ClassroomContext.lecture)
						{
							userActionVO.lectureId=ClassroomContext.lecture.lectureId;
							if (AuditContext.lecture && AuditContext.auditLectureVO)
							{
								userActionVO.auditLectureId=AuditContext.auditLectureVO.auditLectureId;
							}
						}
						userActionHelper.createUserAction(userActionVO);
					}
				}
			}
		}
		
		/*			
		/**
		 *
		 * @public
		 * Audits the "2DSharingLoad" action, when the presenter is loading 2D Animation from library
		 *
		 * @param url of the 2D Animation
		 * @return void
		 *
		 */
		/*public function twoDSharingLoadEventLog(url:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.twoDSharingLoad], url, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "2DSharingStop" action, when the presenter is stopping the animation
		 *
		 * @param url of the 2D Animation
		 * @return void
		 *
		 */
		/*public function twoDSharingStopEventLog(url:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.twoDSharingStop], url, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "2DSharingUpload" action, when the presenter is uploading the animation
		 *
		 * @param url of the 2D Animation
		 * @param animation - Whether the file has animations
		 * @param size - Size of the file
		 * @return void
		 *
		 */
		/*public function twoDSharingUploadEventLog(url:String, animation:String, size:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.twoDSharingUpLoad], url, animation, size);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "3DSharingLoad" action, when the presenter is loading 3D Model from library
		 *
		 * @param url of the 3D Model
		 * @return void
		 *
		 */
		/*public function threeDSharingLoadEventLog(url:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.threeDSharingLoad], url, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "3DSharingStop" action, when the presenter is stopping the 3D Model
		 *
		 * @param url of the 3D Model
		 * @return void
		 *
		 */
		/*public function threeDSharingStopEventLog(url:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.threeDSharingStop], url, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "DocumentThumbnail" action, when the presenter enables the Thumbnail navigation
		 *
		 * @param url of the document
		 * @param orientaion - Thumbnail layout, horizontal or vertical
		 * @return void
		 *
		 */	
		/*public function documentThumbNailEventLog(url:String, orientaion:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.documentThumbnail], url, orientaion, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "FullScreenVideoPresenter" action, when the viewer is making the presenter's video to fullscreen
		 *
		 * @param presenterUserName - userName presenter
		 * @return void
		 *
		 */
		/*public function fullScreenVideoPresenterEventLog(presenterUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.fullScreenVideoPresenter], presenterUserName, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "FullScreenVideoSelectedViewer" action, when the viewer is making the interacting viewer's video to fullscreen
		 *
		 * @param viewerUserName - userName of the interacting viewer
		 * @return void
		 *
		 */
		/*public function fullScreenVideoSelectedViewerEventLog(viewerUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.fullScreenVideoSelectedViewer], viewerUserName, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "FullScreenVideoViewedViewer" action, when the presenter makes the viewed viewer video into fullscreen
		 *
		 * @param viewerUserName - userName of the viewed viewer
		 * @return void
		 *
		 */
		/*public function fullScreenVideoViewedViewerEventLog(viewerUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.fullScreenVideoViewedViewer], viewerUserName, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "CloseFullScreenVideoPresenter" action, when the viewer is closeing the presenter's fullscreen video
		 *
		 * @param presenterUserName - userName presenter
		 * @return void
		 *
		 */
		/*public function closeFullScreenVideoPresenterEventLog(viewerUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.closeFullScreenVideoPresenter], viewerUserName, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "CloseFullScreenVideoSelectedViewer" action, when the viewer is closing the interacting viewer's fullscreen video
		 *
		 * @param viewerUserName of the interacting viewer
		 * @return void
		 *
		 */
		/*public function closeFullScreenVideoSelectedViewerEventLog(viewerUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.closeFullScreenVideoSelectedViewer], viewerUserName, null, null);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "CloseFullScreenVideoViewedViewer" action, when the presenter/moderator is closeing the viewed viewer's fullscreen video
		 *
		 * @param viewerUserName - userName of the viewed viewer
		 * @return void
		 *
		 */
		/*public function closeFullScreenVideoViewedViewerEventLog(viewerUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.closeFullScreenVideoViewedViewer], viewerUserName, null, null);
		}*/	
		/*	
		/**
		 *
		 * @public
		 * Audits the "PresenterVideoToggle" action, when the user starts/stops an incoming video
		 *
		 * @param toggleMode:String - Stop Video/Start Video
		 * @param publishingBW:String - The published bandwidth of incoming video
		 * @param presenterUserName:String - The user name of the incoming video
		 * @return void
		 *
		 */
		/*public function presenterVideoToggleEventLog(toggleMode:String, publishingBW:String, presenterUserName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.presenterVideoToggle], toggleMode, publishingBW, presenterUserName);
		}*/
		/*	
		/**
		 *
		 * @public
		 * Audits the "Feedback" action, when the user submits a feedback item
		 *
		 * @param lectureName related to the feedback
		 * @return void
		 *
		 */
		/*public function feedBackEventLog(lectureName:String):void
		{
			createAction(AuditContext.actionsHash[AuditConstants.feedBack], lectureName, null, null);
		}*/
	}
}

