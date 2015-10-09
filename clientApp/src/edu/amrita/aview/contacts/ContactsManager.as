////////////////////////////////////////////////////////////////////////////////
//
// Copyright  � 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * File			: ContactsManager.as
 * Module		: contacts
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	: Bri.Radha
 */
//VGCRR:-Function Description
package edu.amrita.aview.contacts
{
	import com.amrita.edu.collaboration.CollaborationFactory;
	
	import edu.amrita.aview.chat.ChatManager;
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
	import edu.amrita.aview.common.helper.SystemParameterHelper;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
	import edu.amrita.aview.contacts.events.ContactsTransferEvent;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.entry.ModuleVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
	import edu.amrita.aview.core.shared.audit.AuditContext;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	import edu.amrita.aview.core.shared.vo.SystemParameterVO;
	import edu.amrita.aview.meeting.InvitationListener;
	import edu.amrita.aview.meeting.events.MeetingEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.CursorManager;
	import mx.rpc.events.ResultEvent;

	//PNCR: class description
	public class ContactsManager extends EventDispatcher
	{
		//read-only variables
		private var _contactsController:ContactsController = null;
		applicationType::DesktopWeb{
			private var msgBox:MessageBox = null;
		}
		
		private const APP_NAME:String = "online_directory";
		private const INSTANCE_NAME:String = "users";
		public static const END_SESSION:String="EndSession";
		
		private var serverIP:String = null;
		/**
		 * sets to true when a netconnection is failed/rejected/closed
		 *  and the alert that shows the alert message before closing application
		 */
		private var isCloseAlertInvoked:Boolean=false;
		/**
		 * sets to true when the netcnnection for a user is rejected from fms.
		 */
		private var userRejected:Boolean=false;
		
		private var chatManager:ChatManager = null;
		
		private var contactsModuleVO:ModuleVO = null;
		
		private var invitationListener:InvitationListener=null;
		
		private var isControllerInitCalled:Boolean = false;

		/**
		 * @public 
		 * //PNCR: description
		 * @param userVO of type UserVO
		 */
		public function ContactsManager(userVO:UserVO,appEventMap:EventMap)
		{
			contactsModuleVO = new ModuleRO();
			contactsModuleVO.userVO = userVO;
			contactsModuleVO.applicationEventMap = appEventMap;
		}
		
		/**
		 * @public 
		 * //PNCR: description
		 * @return void
		 */
		public function initialize():void
		{
			if(contactsModuleVO.userVO.role!=Constants.ADMIN_TYPE && 
				contactsModuleVO.userVO.role!=Constants.MASTER_ADMIN_TYPE)
			{
				contactsModuleVO.applicationEventMap.registerMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, logoutHandler);
				contactsModuleVO.moduleEventMap=new EventMap();
				getUserDirectoryServer();
				contactsModuleVO.moduleEventMap.registerInitiator(this,ContactsTransferEvent.REFRESH_SHARED_GROUPS);
			}
		}
		
		/**
		 * @private
		 * //PNCR: description 
		 * @param userVO of type UserVO
		 * @return void
		 */
		private function createContactsController():void
		{
			if(_contactsController!=null)
			{
				contactsController.unregisterInitiatorsAndListeneres();
			}
			this._contactsController = new ContactsController(contactsModuleVO as ModuleRO);
		}
		
		/**
		 * @private
		 * //PNCR: description
		 * @return void 
		 */
		private function getUserDirectoryServer():void
		{
			var sysParamHelper:SystemParameterHelper = new SystemParameterHelper();
			sysParamHelper.getSystemParameterByName("OnlineUserDirectoryServer",getSystemParameterByNameResultHandler);
		}
		
		/**
		 * @public
		 * //PNCR: description 
		 * @param event of type ResultEvent
		 * @return void 
		 */
		public function getSystemParameterByNameResultHandler(event:ResultEvent):void
		{
			var sysParam:SystemParameterVO=event.result as SystemParameterVO;
			this.serverIP = sysParam.parameterInfo;
 			connectServer(serverIP);
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param serverIP of type String
		 * @return void 
		 */
		private function connectServer(serverIP:String):void
		{
			var connectionParams:ArrayList = new ArrayList();
			connectionParams.addItem(contactsModuleVO.userVO.userName);
			connectionParams.addItem(ClassroomContext.hardwareAddress);
				
			var client:Object = {duplicateLogin:duplicateLogin};
			
			contactsModuleVO.mediaServerConnection = new MediaServerConnection(serverIP, APP_NAME, INSTANCE_NAME, connectionParams, client);
			contactsModuleVO.mediaServerConnection.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, connectionStatusHandler);
			contactsModuleVO.collaborationService=CollaborationFactory.getCollaborationService(contactsModuleVO.mediaServerConnection);

			//Create the Contacts controller
			createContactsController();
			createChatManager();
			createInvitationListener();

//			CursorManager.setBusyCursor();
			contactsModuleVO.mediaServerConnection.initialize();
			contactsModuleVO.mediaServerConnection.connectingClient.onEndSession=onEndSession;
			contactsModuleVO.mediaServerConnection.connectingClient.refreshSharedGroups=refreshSharedGroups;
		}		
		public function onEndSession():void
		{
			this.dispatchEvent(new Event(MeetingEvent.END_SESSION));
		}
		
		public function refreshSharedGroups():void
		{
			this.dispatchEvent(new ContactsTransferEvent(ContactsTransferEvent.REFRESH_SHARED_GROUPS));
		}
		/**
		 * @private 
		 * //PNCR: description 
		 * @param event of type MediaServerStatusEvent
		 * @return void 
		 */
		private function connectionStatusHandler(event:MediaServerStatusEvent):void
		{
			CursorManager.removeBusyCursor();
			switch(event.code)
			{
				case MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED:
					applicationType::DesktopWeb{
						MessageBox.show("Connection to the Online directory server failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", "Connection Failed", MessageBox.MB_OK, null, closeApplication);
					}
					break;
				case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
					AuditContext.userAction.connectionSuccessEventLog("Contacts", serverIP,contactsModuleVO.mediaServerConnection.connectionRetrys+"");
					onConnectionSuccess();
					break;
				
				case MediaServerStatusEvent.CODE_COULD_NOT_RECONNECT:
					couldNotReconnectHandler();
					break;
				
				case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
					AuditContext.userAction.connectionRejectEventLog("Contacts", serverIP);
					connectionRejectedHandler();					
					break;

				case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
					AuditContext.userAction.connectionCloseEventLog("Contacts", serverIP);
					break;
				
				case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
					AuditContext.userAction.connectionFailEventLog("Contacts", serverIP);
					break;
			}
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @return void 
		 */
		private function onConnectionSuccess():void
		{
			//RGCR: contactsController can be initialized after clicking the contacts button
			if(!isControllerInitCalled){
				this._contactsController.initialize();
				isControllerInitCalled = true;
			}
		}

		/**
		 * @private 
		 * //PNCR: description 
		 * @return void
		 */
		private function couldNotReconnectHandler():void
		{
			applicationType::desktop{
				FlexGlobals.topLevelApplication.activate();
			}
			if (!isCloseAlertInvoked)
			{
				isCloseAlertInvoked=true;
				applicationType::DesktopWeb{
					MessageBox.show("Connection retrys to the Online directory server are failed.", "Connection Failed", MessageBox.MB_OK, null, closeApplication);
				}
			}
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @return void
		 */
		private function connectionRejectedHandler():void
		{
			//set userRejected property to true.
			userRejected = true;
			couldNotReconnectHandler();			
		}
		private function createMeetingContactsController():void
		{
			// invoked when the meeting button is clicked
			// creates the maincomponent
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param newLoginIp of type String
		 * @return void
		 */
		private function duplicateLogin(newLoginIp:String):void
		{  
			contactsModuleVO.mediaServerConnection.isDuplicateLogin=true;
			applicationType::DesktopWeb{
				MessageBox.show("Another user with same loginId is logged in from ip:" + newLoginIp + ", Please Login Again", "Alert", MessageBox.MB_OK, null, closeApplication);
			}
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @return void
		 */
		private function disconnectServer():void
		{
			contactsModuleVO.mediaServerConnection.close();
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param userVO of type UserVO
		 * @param mediaServerConnection of MediaServerConnection
		 * @return ChatManager
		 * 
		 */
		private function createChatManager():void
		{
			chatManager = new ChatManager(contactsModuleVO as ModuleRO);
			chatManager.initialize();
			chatManager.registerChatEvents();
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param userVO of type UserVO
		 * @param mediaServerConnection of type MediaServerConnection
		 * @return void
		 */
		private function createInvitationListener():void
		{
		   invitationListener=new InvitationListener(this.contactsModuleVO as ModuleRO);	
		   invitationListener.init();
		   
		}
		
		/**
		 *@public 
		 * 
		 */
		/*public function closeContacts():void
		{
			if (chatManager)
			{
				chatManager.logutHandler();
			}
			disconnectServer();
		}*/
		
		/**
		 * @public 
		 * //PNCR: description 
		 * @return ContactsView
		 */
		public function getContactsView():ContactsView
		{
			return contactsController.getContactsView();
		}
		
		/**
		 * @private 
		 * //PNCR: description 
		 * @param event of type CloseEvent
		 * @return void
		 */
		private function closeApplication(event:MessageBoxEvent= null):void
		{
			applicationType::desktop{
				FlexGlobals.topLevelApplication.close();
			}
			applicationType::web{
				FlexGlobals.topLevelApplication.mainApp.closeApp();
			}
		}

		/**
		 * @public 
		 * //PNCR: description 
		 * @return ContactsController
		 */
		private function get contactsController():ContactsController
		{
			return _contactsController;
		}
	
		/**
		 * @private
		 * //PNCR: description 
		 * @return void
		 */
		private function logoutHandler(event:ApplicationStatusEvent):void
		{
			setTimeout(disconnectServer, 1000);
			clearEventMap();
		}
		/**
		 * @private
		 * //PNCR: description 
		 * @return void
		 */
		private function clearEventMap():void
		{
			contactsModuleVO.applicationEventMap.unregisterMapListener(ApplicationStatusEvent.TYPE_APPLICATION_LOGOUT, logoutHandler);
			if(_contactsController)
			{
				_contactsController.unregisterInitiatorsAndListeneres();
			}
		}
		public function getMediaServerConnection():MediaServerConnection
		{
			return contactsModuleVO.mediaServerConnection;
		}
		public function getContactsModuleRO():ModuleRO
		{
			return contactsModuleVO as ModuleRO;
		}
	}
}