////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * 
 * File			: VideoConnection.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.common.service.streaming
{
	import edu.amrita.aview.audit.AuditContext;
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.common.service.events.MediaServerStatusEvent;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.media.VideoStreamSettings;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.net.Socket;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.VideoDisplay;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	
	//VGCR:-Class Description
	//VGCR:-Variable description
	//VGCR:-Constant Description
	//VGCR:-Description for all functions
	public class VideoConnection
	{
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.VideoConnection");
		
		public var ncVideo:MediaServerConnection;
		private var _ipFMS:String;
		private var serverType:String;
		private var netConnectionStatus:String;
		private var prevNetConnectionStatus:String;
		private var isPublishing:Boolean=false;
		private var canPublish:Boolean=false;
		//private var isFirstSuccessfulConnection:Boolean = true;
		private var streamObjects:ArrayCollection=new ArrayCollection();
		public var portNO:int;
		public var teacherVideoConnected:Boolean=false;
		public var studentVideoConnected:Boolean=false;
		private var cameraObj:Camera;
		private var microPhoneObj:Microphone;
		private var cameraIndex:int;
		private var micIndex:int;
		private var audioDriver:String;
		private var videoDriver:String;
		private var videoCodec:String;
		private var isAudioOnlyOption:Boolean=false;
		private static const PUBLISH_TYPE:String="PUBLISH_TYPE";
		private static const SUBSCRIBE_TYPE:String="SUBSCRIBE_TYPE";
		private static const VIEW_TYPE:String="VIEW_TYPE";
		//private var checkKillVideoIndex:Boolean=true;
		private static const PUBLISHING_STATE:String="PUBLISHING_STATE";
		private static const PUBLISHED_STATE:String="PUBLISHED_STATE";
		private static const STOPPED_STATE:String="STOPPED_STATE";
		private static const STOPPING_STATE:String="STOPPING_STATE";
		private var timerNativeProcessExit:Timer;
		private var socketTimer:Timer;
		public var streamOnPublish:Boolean=false;
		public var streamUnPublish:Boolean=false;
		private var intervalId:uint;
		private var streamingProtocol:String;
		private var applicationName:String;
		private var className:String;
		private var userName:String;
		private var netInfo:NetStreamInfo;
		/**
		 * Variable of type Socket for communicating with 'akr.exe'
		 */
		private var streamSocketError:Boolean=false;
		private var objSocket:Object
		//Issue #284:Start
		/**
		 * When the video receiving connection is closed, we retry the video connection.
		 * But most likely the publshing connection is closed as well.
		 * So we will exit the publishing app video connection close event
		 */
		private var stoppedPublishingWhenRetry:Boolean=false;
		
		private var videoPublished:Boolean=false;
		//Issue #284:End
		
		/**
		 * Variable of type String for passing socket command
		 */
		private var socketCommand:String;
		
		public static const CODEC_SORENSON:String="Sorenson";
		public static const CODEC_H264:String="H.264";
		public static const CODEC_VP6:String="VP6";
		public var isConnectionDroppedManually:Boolean=false;
		
		private var videoAfterREConnection:Timer;
		private var watchTimerAKR:Timer;
		private var isAKRRemoved:Boolean=false;
		public static var checkKillAKR:Boolean=true;
		private var timerCheckKillAKR:Timer;
		private static const STREAM_MUTE:SoundTransform=new SoundTransform(0, 0);
		/**
		 * Variable of type SoundTransform for storing the audio 'unmute' state of netstream
		 */
		private static const STREAM_UN_MUTE:SoundTransform=new SoundTransform(1, 0);
		private var videoStreamAEC:NetStream;
		
		/**Platform specific imports and variables*/
		applicationType::desktop
		{
			import edu.amrita.aview.core.video.native.BlackMagicFMLEPublisher;
			import edu.amrita.aview.core.video.native.FFMPEGPublisher;
			import edu.amrita.aview.core.video.native.FLIXPublisher;
			
			//Removed NativeApps folder
			private var flixPublisher:FLIXPublisher=new FLIXPublisher();
			private var ffmpegPublisher:FFMPEGPublisher=new FFMPEGPublisher();
			private var blackMagicFMLEPublisher:BlackMagicFMLEPublisher=new BlackMagicFMLEPublisher();
		}
		
		
		/**
		 * @public 
		 * @param ipFMS of type String
		 * @param streamingProtocol of type String
		 * @param applicationName of type String
		 * @param className of type String
		 * @param userName of type String
		 * 
		 */
		public function VideoConnection(ipFMS:String, streamingProtocol:String, applicationName:String, className:String, userName:String):void
		{
			this.ipFMS=ipFMS;
			this.streamingProtocol=streamingProtocol;
			this.applicationName=applicationName;
			this.className=className;
			this.userName=userName;
			if (Log.isInfo()) log.info("VideoConnection:- ipFMS :" + ipFMS + ", userName :" + userName + ", streamingProtocol :" + streamingProtocol + ", applicationName :" + applicationName + ", className :" + className + ":");
		}
		
		/**
		 * @public 
		 * @return String
		 * 
		 */
		public function get ipFMS():String
		{
			return _ipFMS;
		}
		
		/**
		 * @public 
		 * @param value of type String
		 * 
		 */
		public function set ipFMS(value:String):void
		{
			_ipFMS=value;
		}
		
		/**
		 * @public 
		 * @param codec of type String
		 * @return Boolean
		 * 
		 */
		public static function isInternalCodec(codec:String):Boolean
		{
			// AKCR: please use conditional operator
			if (codec != CODEC_VP6)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		
		/**
		 * @public 
		 * @return String
		 * 
		 */
		public function getNetConnectionStatus():String
		{
			return netConnectionStatus;
		}

		private var videoFMSURL:String="";
		
		/**
		 *@public
		 *  
		 * 
		 */
		public function createConnection():void
		{
			if (Log.isDebug()) log.debug("createConnection:-  ipFMS " + ipFMS + " applicationName " + applicationName + " className " + className);
			
			var connectionParams:ArrayList = new ArrayList();
			connectionParams.addItem(userName);
			connectionParams.addItem(ClassroomContext.userDetails);
			connectionParams.addItem(ClassroomContext.hardwareAddress);

			ncVideo=new MediaServerConnection(ipFMS,applicationName,className + "_" + ClassroomContext.aviewClass.classId,connectionParams,this);
			ncVideo.addEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, netStatusHandler);
			ncVideo.initialize();
		}
		
		
		/**
		 * @public 
		 * @param streamName of type String
		 * 
		 */
		public function startedStream(streamName:String):void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamName == streamName && tempStream.streamType == PUBLISH_TYPE)
				{
					if (Log.isDebug()) log.debug("startedStream:- ipFMS :" + ipFMS + ", streamName " + tempStream.streamName + " portNO " + tempStream.portNO);
					tempStream.streamState=PUBLISHED_STATE;
						//break;
				}
			}
		}
		
		/**
		 * @public 
		 * @param obj of type Object
		 * 
		 */
		public function recordingStatus(obj:Object):void
		{
			if (obj != null)
			{
				// AKCR : is this a hack? true || "true"
				// AKCR: for string comparisions, please use lower() or upper()
				if (obj.isPresenter == true || obj.isPresenter == "true")
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.recordingStatus(obj);
				}
				else
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.viewerVideoRecorder.recordingStatus(obj);
				}
			}
		}
		
		/**
		 * @private 
		 * @param streamName of type String
		 * @return Boolean
		 * 
		 */
		private function getStreamStoppedManually(streamName:String):Boolean
		{
			var tempBool:Boolean=false;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamName == streamName && tempStream.streamType == PUBLISH_TYPE && tempStream.isStreamStoppedManually)
				{
					if (Log.isInfo()) log.info("getStreamStoppedManually:- ipFMS :" + ipFMS + ", streamName " + tempStream.streamName + " streamType " + tempStream.streamType + ": Stopped manually");
					tempBool=true;
					break;
				}
			}
			return tempBool;
		}
		
		/**
		 * @private 
		 * @param streamName of type String
		 * 
		 */
		private function setStreamStoppedManually(streamName:String):void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamName == streamName && tempStream.streamType == PUBLISH_TYPE)
				{
					if (Log.isInfo()) log.info("setStreamStoppedManually:- ipFMS :" + ipFMS + ", streamName " + tempStream.streamName + " streamType " + tempStream.streamType + ": to false");
					tempStream.isStreamStoppedManually=false;
					break;
				}
			}
		}
		
		/**
		 * @public 
		 * @param newLoginIp of type String
		 * 
		 */
		public function duplicateLogin(newLoginIp:String):void
		{
			if (Log.isDebug()) log.debug("duplicateLogin:- ipFMS :" + ipFMS + ", newLoginIp:" + newLoginIp);
		}
		
//AKCR: FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder is being referred
//		for about 24 times in this file. Can this be referred by some temp variable to reduce the obsessive 
//		verbosity?
		/**
		 * @public 
		 * @param streamName of type String
		 * @param disconnectedDuringRetrys of type Boolean
		 * 
		 */
		public function stoppedStream(streamName:String, disconnectedDuringRetrys:Boolean):void
		{
			if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording)
			{
				
				if (ClassroomContext.currentPresenterName == streamName)
				{
					if (Log.isDebug()) log.debug("In VideoConnection:Calling addEndtime for presenter. Stream Name:" + streamName);
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.addEndtime(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(), streamName, false);
				}
				
			}
			if (Log.isDebug()) log.debug("stoppedStream:- ipFMS :" + ipFMS + ": Processing, streamName :" + streamName + ", disconnectedDuringRetrys :" + disconnectedDuringRetrys + ":");
			if (disconnectedDuringRetrys || ncVideo.connectionRetrys != 0)
			{
				if (Log.isDebug()) log.debug("stoppedStream:- ipFMS :" + ipFMS + ", streamName :" + streamName + ", disconnectedDuringRetrys || ncVideo.connectionRetrys != 0");
				return;
			}
			if (isVideoPublishing() && !getStreamStoppedManually(streamName))
			{
				if (Log.isDebug()) log.debug("stoppedStream:- ipFMS :" + ipFMS + ", streamName :" + streamName + ", if (isVideoPublishing() && !getStreamStoppedManually(streamName))");
				streamUnPublish=true;
			}
			if (getStreamStoppedManually(streamName))
			{
				if (Log.isDebug()) log.debug("stoppedStream:- ipFMS :" + ipFMS + ", streamName :" + streamName + ", if (getStreamStoppedManually(streamName))");
				setStreamStoppedManually(streamName);
			}
			
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamName == streamName)
				{
					tempStream.streamState=STOPPED_STATE;
					break;
				}
			}
		}
		
		/**
		 * @public 
		 * @return Boolean
		 * 
		 */
		public function areAllStreamsInPublishedState():Boolean
		{
			var boolCursor:Boolean=false;
			var notRemoveCursorCount:int=0;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				// AKCR: please combine the following 2 IF statements
				if (tempStream.serverType == "FMS_VIDEO_PRESENTER" || tempStream.serverType==Constants.MEETING_FMS_PRESENTER)
				{
					if (tempStream.streamState != PUBLISHED_STATE)
					{
						notRemoveCursorCount++;
						break;
					}
				}
			}
			if (notRemoveCursorCount == 0)
				boolCursor=true;
			
			if (Log.isDebug()) log.debug("areAllStreamsInPublishedState:- ipFMS :" + ipFMS + ": areAllStreamsInPublishedState:" + boolCursor + ":");
			return boolCursor;
		}
		
		/**
		 * @private 
		 * @param event of type AsyncErrorEvent
		 * 
		 */
		// AKCR: empty function??
		private function asyncError(event:AsyncErrorEvent):void
		{
		
		}
		
		/**
		 * @private 
		 * @param event of type TimerEvent
		 * 
		 */
		private function videoCreationAfterREConnection(event:TimerEvent):void
		{
			var akrNotStoppedState:int=0;
			if (Log.isDebug()) log.debug("videoCreationAfterREConnection:- ipFMS :" + ipFMS + ":");
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamType == PUBLISH_TYPE && tempStream.streamState != STOPPED_STATE)
				{
					if (Log.isDebug()) log.debug("videoCreationAfterREConnection:- ipFMS :" + ipFMS + " streamName:" + tempStream.streamName + ", streamState:" + tempStream.streamState);
					akrNotStoppedState++;
				}
			}
			if (Log.isDebug()) log.debug("videoCreationAfterREConnection:- ipFMS :" + ipFMS + "akrNotStoppedState:" + akrNotStoppedState + ", isAKRRemoved:" + isAKRRemoved);
			if (akrNotStoppedState == 0 && isAKRRemoved)
			{
				if (Log.isDebug()) log.debug("videoCreationAfterREConnection:- ipFMS :" + ipFMS + ": akrNotStoppedState:" + akrNotStoppedState + ", isAKRRemoved :" + isAKRRemoved + ":");
				isAKRRemoved=false;
				videoAfterREConnection.stop();
				publishAllVideos();
			}
		}
		
		/**
		 * @private
		 * Publish video only after successful reconnect and earlier video is fully stopped and
		 * Only if the publish is stopped by the reconnection logic
		 * Once publish is called, reset the stoppedPublishingWhenRetry flag
		 */
		private function startPublishVideoAfterReconnection():void
		{
			//Succssful reconnection
			// AKCR: Do we need this IF/ELSE for logging debug information?
			if (Log.isDebug()) log.debug("startPublishVideoAfterReconnection:- ipFMS :" + ipFMS + ", ncVideo.connectionRetrys" + ncVideo.connectionRetrys + " stoppedPublishingWhenRetry " + stoppedPublishingWhenRetry + " " + ipFMS);
			if (ncVideo.connectionRetrys == 0)
			{
				if (stoppedPublishingWhenRetry)
				{
					if (!isInternalCodec(this.videoCodec))
					{
						videoAfterREConnection=new Timer(1000);
						videoAfterREConnection.addEventListener(TimerEvent.TIMER, videoCreationAfterREConnection);
						videoAfterREConnection.start();
					}
					else
					{
						publishAllVideos();
					}
				}
				else if (!stoppedPublishingWhenRetry && canPublishVideo())
				{
					if (Log.isDebug()) log.debug("startPublishVideoAfterReconnection:- ipFMS :" + ipFMS + ", stoppedPublishingWhenRetry");
				}
				else if (stoppedPublishingWhenRetry && !canPublishVideo())
				{
					if (Log.isDebug()) log.debug("startPublishVideoAfterReconnection:- ipFMS :" + ipFMS + ", not canPublishVideo");
				}
				else
				{
					if (Log.isDebug()) log.debug("startPublishVideoAfterReconnection:- ipFMS :" + ipFMS + ", not stoppedPublishingWhenRetry and not canPublishVideo");
				}
			}
			else
			{
				if (Log.isDebug()) log.debug("startPublishVideoAfterReconnection:- ipFMS :" + ipFMS + ", Not yet reconnected");
			}
		}
		
		
		/**
		 * @private 
		 * 
		 */
		private function onConnectionTestFailed():void
		{
			MessageBox.show("Connection to the Video server failed.\nEither the server is down or the port is closed. Port 80 or 1935 needs to be open for RTMP streaming. \nPlease contact administrator.", "Connection Failed", MessageBox.MB_OK, null, null);
		}

		private var networkChangeTimeoutId:uint=0;
		
		
		/**
		 * @private 
		 * @param event of type MediaServerStatusEvent
		 * @param calledFromTimeout of type Boolean default value=false
		 * 
		 */
		private function netStatusHandler(event:MediaServerStatusEvent, calledFromTimeout:Boolean=false):void
		{
			
			netConnectionStatus=event.code;
			
			/**Inconsistancy - 1: Some times during reconnection, netConnectionStatus shows 'NetConnection.Connect.Success' but the  ncVideo.connected is false.
			 * During such inconsistant status, it's better to set the status as 'NetConnection.Connect.NetworkChange' and make it wait for some time until connection status become consistent
		     */
			if (netConnectionStatus == MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS && !ncVideo.isConnected())
			{
				if (Log.isInfo()) log.info("netStatusHandler:- Inconstant Connection status. Setting the status to NetworkChange. ipFMS :" + ipFMS + ", netConnectionStatus :" + netConnectionStatus + ". NetConnection connected:" + ncVideo.isConnected() + ", ncVideo.connectionRetrys:" + ncVideo.connectionRetrys + ":");
				netConnectionStatus=MediaServerStatusEvent.CODE_NET_STATUS_CHANGE;
			}
			
			/**Inconsistancy - 2: Some times during reconnection, netConnectionStatus shows 'NetConnection.Connect.Closed' but the  ncVideo.connected is true.
			 * During such inconsistant status, it's better to set the status as 'NetConnection.Connect.NetworkChange' and make it wait for some time until connection status become consistent
			*/
			if (netConnectionStatus == MediaServerStatusEvent.CODE_NET_STATUS_CLOSED && ncVideo.isConnected())
			{
				if (Log.isInfo()) log.info("netStatusHandler:- Inconstant Connection status. Setting the status to NetworkChange. ipFMS :" + ipFMS + ", netConnectionStatus :" + netConnectionStatus + ". NetConnection connected:" + ncVideo.isConnected() + ", ncVideo.connectionRetrys:" + ncVideo.connectionRetrys + ":");
				netConnectionStatus=MediaServerStatusEvent.CODE_NET_STATUS_CHANGE;
			}
			
			if (netConnectionStatus == MediaServerStatusEvent.CODE_NET_STATUS_CHANGE)
			{
				/**If the NetworkChange status happens, we are giving it 5 secs to change the status,
				 * If it does not change, then we can assume the below statuses
				 */ 
				if (networkChangeTimeoutId == 0)
				{
					if (Log.isInfo()) log.info("netStatusHandler:- ipFMS :" + ipFMS + ", netConnectionStatus :" + netConnectionStatus + ", Starting timeout. NetConnection connected:" + ncVideo.isConnected() + ", ncVideo.connectionRetrys:" + ncVideo.connectionRetrys + ":");
					networkChangeTimeoutId=setTimeout(netStatusHandler, 5000, event, true);
					return;
				}
				else if (calledFromTimeout)
				{
					if (Log.isInfo()) log.info("netStatusHandler:- ipFMS :" + ipFMS + ", netConnectionStatus :" + netConnectionStatus + ", Called from timeout. NetConnection connected:" + ncVideo.isConnected() + ", ncVideo.connectionRetrys:" + ncVideo.connectionRetrys + ":");
					clearTimeout(networkChangeTimeoutId);
					networkChangeTimeoutId=0;
				}
				else
				{
					if (Log.isInfo()) log.info("netStatusHandler:- ipFMS :" + ipFMS + ", netConnectionStatus :" + netConnectionStatus + ", Not called from timeout. NetConnection connected:" + ncVideo.isConnected() + ", ncVideo.connectionRetrys:" + ncVideo.connectionRetrys + ":");
					return; //Wait for the timeout
				}
				
				if (ncVideo.isConnected())
				{
					netConnectionStatus=MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS;
				}
				else 
					/** It's possible that NetConnection.Connect.NetworkChange would change into NetConnection.Connect.Success in a sec, so we are checking the connection status before retyring.
					 */  
					//See retryVideoConnection 
				{
					netConnectionStatus=MediaServerStatusEvent.CODE_NET_STATUS_CLOSED;
				}
				if (Log.isInfo()) log.info("netStatusHandler:- ipFMS :" + ipFMS + ", netConnectionStatus :" + netConnectionStatus + " NetConnection connected:" + ncVideo.isConnected() + ", ncVideo.connectionRetrys:" + ncVideo.connectionRetrys + ":");
			}
			else if (networkChangeTimeoutId != 0)
			{
				clearTimeout(networkChangeTimeoutId);
				networkChangeTimeoutId=0;
			}
			
//			if(Log.isDebug()) log.debug("netConnectionStatus"+netConnectionStatus);
			switch (netConnectionStatus)
			{
				case MediaServerStatusEvent.CODE_CONNECTION_TEST_FAILED:
					onConnectionTestFailed();
					break;
				case MediaServerStatusEvent.CODE_NET_STATUS_SUCCESS:
					AuditContext.userAction.connectionSuccessEventLog("Video Module", videoFMSURL, ncVideo.connectionRetrys + "");
					if (ncVideo.connectionRetrys != 0)
					{
						if (Log.isDebug()) log.debug("In VideoConnection:netStatusHandler: -User Name : " + userName);
						resetPublishStatus();
						if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording)
						{
							if (Log.isDebug()) log.debug("In VideoConnection:netStatusHandler-isRecording : " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording + ",currentrecordingPresenterStream : " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.currentrecordingStream + ", currentrecordingViewerStream : " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.viewerVideoRecorder.currentrecordingStream);
						}
						if (ClassroomContext.isModerator && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording)
						{
							if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.isStreamRecording(userName))
							{
								if (Log.isDebug()) log.debug("In VideoConnection:Calling addEndtime for presenter. Stream Name:" + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.currentrecordingStream);
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.addEndtime(recordingTimeBeforReconnection, userName, false);
							}
							if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.viewerVideoRecorder.isStreamRecording(userName + "_VIEWER"))
							{
								if (Log.isDebug()) log.debug("In VideoConnection:Calling addEndtime for viewer. Stream Name:" + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.viewerVideoRecorder.currentrecordingStream);
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopRecordingViewerStream(userName + "_VIEWER");
							}
						}
						if (Log.isDebug()) log.debug("netStatusHandler:- ipFMS :" + ipFMS + ", Calling start publish after successful reconnect ");
						startPublishVideoAfterReconnection();
							//isFirstSuccessfulConnection = false;
					}
					
					break;
				
				case MediaServerStatusEvent.CODE_NET_STATUS_REJECTED:
					AuditContext.userAction.connectionRejectEventLog("Video Module", videoFMSURL);
					break;
				
				case MediaServerStatusEvent.CODE_NET_STATUS_CLOSED:
					AuditContext.userAction.connectionCloseEventLog("Video Module", videoFMSURL);
					processConnectionCloseFail();
					break;
				case MediaServerStatusEvent.CODE_NET_STATUS_FAILED:
					AuditContext.userAction.connectionFailEventLog("Video Module", videoFMSURL);
					processConnectionCloseFail();
					break;
				case MediaServerStatusEvent.CODE_COULD_NOT_RECONNECT:
					if (Log.isDebug()) log.debug("checkConnectionAndRetry:- ipFMS :" + ipFMS + ", maxConnectionReached true");
				default:
					break;
			}
			import mx.core.FlexGlobals;
			
			prevNetConnectionStatus=netConnectionStatus;
		}
		private var recordingTimeBeforReconnection:Number;
		
		/**
		 *@private 
		 * 
		 */
		private function processConnectionCloseFail():void
		{
			if (!ClassroomContext.isDuplicateLogin)
			{
				if (ClassroomContext.isModerator && 
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder && 
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.isRecording && 
					ncVideo.connectionRetrys == 0)
				{
					recordingTimeBeforReconnection=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime();
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.currentrecordingStream != "" && ClassroomContext.currentPresenterName == userName)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.presenterVideoRecorder.isVideoReconnected=true;
					}
					var acceptedStudent:String=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getFirstAcceptedStudent();
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.viewerVideoRecorder.currentrecordingStream != "" && acceptedStudent == userName)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.viewerVideoRecorder.isVideoReconnected=true;
					}
				}
				if (Log.isDebug()) log.debug("checkConnectionAndRetry:- ipFMS :" + ipFMS + ", isVideoPublishing() :" + isVideoPublishing() + ", stoppedPublishingWhenRetry :" + stoppedPublishingWhenRetry + ":")
				if (!stoppedPublishingWhenRetry)
				{
					if (!isInternalCodec(this.videoCodec))
					{
						//checkKillVideoIndex=false;
						//CRJH: Either the timer has to be stopped after use or replace it with setTimeOut and clear it after use
						watchTimerAKR=new Timer(1000, 14);
						watchTimerAKR.addEventListener(TimerEvent.TIMER_COMPLETE, watchTimerAKRUpdate);
						watchTimerAKR.start();
					}
					//checkkillAKRProcess();
					killVideoPublishingProcess();
					stoppedPublishingWhenRetry=true;
				}
			}
		}
		
		/**
		 * @private 
		 * @param event of type TimerEvent
		 * 
		 */
		private function watchTimerAKRUpdate(event:TimerEvent):void
		{
			isAKRRemoved=true;
		}
		
		/**
		 * @public
		 * This method checks the status of stream is publishing or not.
		 * This flag is used to determine whether to stop the video or not when video connection fails.
		 * @return Boolean
		 */
		public function isVideoPublishing():Boolean
		{
			var isPublishing:Boolean=false;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (Log.isDebug()) log.debug("isVideoPublishing:- ipFMS :" + ipFMS + ", streamState " + tempStream.streamState + ", StreamName " + tempStream.streamName)
				if (tempStream.streamState == PUBLISHED_STATE || tempStream.streamState == PUBLISHING_STATE)
				{
					if (Log.isDebug()) log.debug("isVideoPublishing:- ipFMS :" + ipFMS + ", isVideoPublishing if");
					isPublishing=true;
					break;
				}
				else if (tempStream.streamState == PUBLISHING_STATE && netConnectionStatus == "NetConnection.Connect.Closed" && prevNetConnectionStatus == "NetConnection.Connect.NetworkChange")
				{
					if (Log.isDebug()) log.debug("isVideoPublishing:- ipFMS :" + ipFMS + ", isVideoPublishing elseif");
					isPublishing=true;
					break;
				}
			}
			return isPublishing;
		}
		
		/**
		 * @private
		 *  This method checks the state of stream is not publishing.
		 * This flag is used to determine wheather to start the video or not when video connection fails
		 * @return Boolean
		 */
		private function canPublishVideo():Boolean
		{
			var canPublish:Boolean=false;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamState == STOPPED_STATE)
				{
					//Alert.show(tempStream.streamName);
					canPublish=true;
					break;
				}
			}
			if (Log.isDebug()) log.debug("isVideoPublishing:- ipFMS :" + ipFMS + ", canPublishVideo :" + canPublish + ":");
			return canPublish;
		}
		
		/**
		 * @private 
		 * 
		 */
		private function publishAllVideos():void
		{
			//Iteratre over avParamObjects and publish
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamType == PUBLISH_TYPE)
				{
					if (Log.isDebug()) log.debug("publishAllVideos:- ipFMS :" + ipFMS + ", Setting the stream " + tempStream.streamName + " to stopped");
					tempStream.streamState=STOPPED_STATE;
					startVideoPublishingProcess(tempStream);
				}
			}
			stoppedPublishingWhenRetry=false;
		}
				
		/**
		 * @public
		 * This function is used for start publishing audio/video stream of the user.
		 * @param AVParamObject of type AVParameters
		 * 
		 */
		applicationType::DesktopWeb{
			import edu.amrita.aview.core.video.AVParameters;
			public function publishVideo(AVParamObject:AVParameters):void
			{
				streamUnPublish=false;
				var videoStream:VideoStream=new VideoStream();
				videoStream.serverType=AVParamObject.serverType;
				videoStream.streamType=PUBLISH_TYPE;
				videoStream.streamState=STOPPED_STATE;
				videoStream.streamName=AVParamObject.streamName;
				videoStream.data=AVParamObject; //TODO: change data to avParam
				videoStream.videoCodec=AVParamObject.videoCodec; //No need, can access from avParam
				videoStream.portNO=AVParamObject.socketPortNo; //No need, can access from avParam
				videoStream.published=false;
				videoStream.isStreamStoppedManually=false;
				streamObjects.addItem(videoStream);
				
				this.cameraIndex=AVParamObject.cameraIndex;
				this.micIndex=AVParamObject.microPhoneIndex;
				this.videoCodec=AVParamObject.videoCodec;
				this.audioDriver=AVParamObject.audioDeviceDrive;
				this.videoDriver=AVParamObject.videoDeviceDrive;
				this.isAudioOnlyOption=AVParamObject.streamingOption;
				if (Log.isDebug()) log.debug("publishVideo:- ipFMS :" + ipFMS + ", for  " + AVParamObject.streamName);
				
				if (AVParamObject.streamNumber > 1)
				{
					videoStream.isExternalProcess=true;
				}
				startVideoPublishingProcess(videoStream);
			}
		}
		/**
		 * @public 
		 * Function for initializing the socket used for communication between A-VIEW app and 'akr.exe'.
		 * @param videoStream of type VideoStream
		 * 
		 */
		public function createSocket(videoStream:VideoStream):void //TODO: Add the socket attribute to the avParamObject itself. Then we do not need arrSocket
		{
			videoStream.socket=new Socket();
			videoStream.socket.addEventListener(IOErrorEvent.IO_ERROR, socketErrorHandler);
			videoStream.socket.addEventListener(Event.CONNECT, onSocketConnect);
			//videoStream.socket.addEventListener(Event.CLOSE,socketCloseHandler);
			videoStream.socketCommand=null;
			if (Log.isDebug()) log.debug("createSocket:- ipFMS :" + ipFMS + ", portNO :" + videoStream.portNO + ", streamName :" + videoStream.streamName + ", selectedBandWidth :" + videoStream.data.selectedBandWidth);
		}
		
		
		/**
		 * 
		 * Function for handling IO_ERROR event of socket.
		 * @param e of type IOErrorEvent
		 * 
		 */
		private function socketErrorHandler(e:IOErrorEvent):void
		{
			Alert.show("socketErrorHandler::" + e.toString(), "Error");
		}
						
		/**
		 * @public
		 * Function for connecting the socket used for communication between A-VIEW app and 'akr.exe'. 
		 * @param arrayVP6Streams of type Array
		 * @param index of type int
		 * 
		 */
		public function callSocket(arrayVP6Streams:Array, index:int):void
		{
			//Alert.show(ipFMS);
			
			if (arrayVP6Streams.length > index)
			{
				//Alert.show(arrayVP6Streams[index].streamName);
				objSocket=new Object();
				objSocket.socketCommand="quit";
				objSocket.streamType=arrayVP6Streams[index].streamType;
				objSocket.streamName=arrayVP6Streams[index].streamName;
				
				// Connect to the server
				arrayVP6Streams[index].socket.connect("127.0.0.1", arrayVP6Streams[index].portNO);
				index++;
				intervalId=setTimeout(callSocket, 500, arrayVP6Streams, index);
			}
			else
			{
				//Alert.show("checkKillAKR=true;");
				checkKillAKR=true;
				clearTimeout(intervalId);
				arrayVP6Streams.splice(0, arrayVP6Streams.length);
			}
		
		
		}
		
		/**
		 * @private 
		 * @param portNo of type int
		 * @return VideoStream
		 * 
		 */
		private function getVideoStream(portNo:int):VideoStream
		{
			var objStream:VideoStream=null;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.portNO == portNo)
				{
					objStream=tempStream;
					break;
				}
			}
			return objStream;
		}
		
		/**
		 * @private 
		 * @param portNo of type int
		 * @return int
		 * 
		 */
		private function getVideoStreamIndex(portNo:int):int
		{
			var index:int=0;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].portNO == portNo)
				{
					index=i;
					break;
				}
			}
			return index;
		}
		
		/**
		 * @private 
		 * @param portNo of type int
		 * 
		 */
		private function executeSocketCommand(portNo:int):void
		{
			var objStream:VideoStream=getVideoStream(portNo);
			var i:int=0;
			if (objStream)
			{
				if (Log.isDebug()) log.debug("executeSocketCommand:- ipFMS :" + ipFMS + ", portNO :" + objStream.portNO + ", streamName :" + objStream.streamName + ", selectedBandWidth :" + objStream.data.selectedBandWidth);
				objStream.socket.writeUTFBytes(objStream.socketCommand);
				objStream.socket.flush();
				if (objStream.socketCommand == "quit" && ncVideo.connectionRetrys == 0)
				{
					i=getVideoStreamIndex(portNo);
					objStream.streamState=STOPPED_STATE;
					//objStream.socket.close();
					streamObjects.removeItemAt(i);
					if (Log.isDebug()) log.debug("executeSocketCommand:- ipFMS :" + ipFMS + ", Closing the socket ncVideo.connectionRetrys==0");
				}
				else if (objStream.socketCommand == "quit" && ncVideo.connectionRetrys > 0)
				{
					i=getVideoStreamIndex(portNo);
					streamObjects[i].streamState=STOPPED_STATE;
					//objStream.socket.close();
					if (Log.isDebug()) log.debug("executeSocketCommand:- ipFMS :" + ipFMS + ", Closing the socket ncVideo.connectionRetrys>0");
				}
				objStream.socket.close();
				objStream.socketCommand=null;
			}
		}
		
		/**
		 * @private
		 * Function for handling CONNECT event of socket.
		 * @param event of type Event
		 */
		private function onSocketConnect(event:Event):void
		{
			if (Log.isDebug()) log.debug("onSocketConnect:- ipFMS :" + ipFMS + ", remotePort :" + event.target.remotePort.toString());
			executeSocketCommand(event.target.remotePort);

		}
		
		/**
		 * @private 
		 * @param videoStream of type VideoStream
		 * 
		 */
		private function startVideoPublishingProcess(videoStream:VideoStream):void
		{
			applicationType::web
			{
				if (this.videoCodec == VideoConnection.CODEC_VP6)
				{
					if (Log.isDebug()) log.debug("startVideoPublishingProcess:- ipFMS :" + ipFMS + ",  with codec :" + this.videoCodec + ": stream :" + videoStream.streamName);
					if (videoStream.data.userStatus == 1)
					{
						videoStream.streamState=PUBLISHING_STATE;
					}
				}
				else if (this.videoCodec == VideoConnection.CODEC_SORENSON || this.videoCodec == VideoConnection.CODEC_H264) //TODO: for all OSs
				{
					if (Log.isDebug()) log.debug("startVideoPublishingProcess:- ipFMS :" + ipFMS + ", with codec :" + this.videoCodec + ": stream :" + videoStream.streamName);
					publishEncodedVideo(videoStream);
				}
			}
			applicationType::desktop
			{
				if (Capabilities.os.toLowerCase().indexOf("win") > -1)
				{
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE && !this.isAudioOnlyOption)
					{
						if (videoStream.data.userStatus == 1)
						{
							/*var camTemp:Camera=Camera.getCamera(videoStream.data.cameraIndex.toString());
							camTemp.setMode(1920,1080,15)
							if(camTemp.width<1920 || camTemp.height<1080)
							{
							Alert.show("Please stop & start with camera which supports '1920x1080' resolution!!!");
							//stopPublish();
							return;
							}*/
							
							videoStream.streamState = PUBLISHING_STATE;
							blackMagicFMLEPublisher.publishVideo(videoStream.data, ipFMS, applicationName);
						}
						return;
					}
					if (this.videoCodec == VideoConnection.CODEC_VP6)
					{
						if (Log.isDebug()) log.debug("startVideoPublishingProcess:- ipFMS :" + ipFMS + ",  with codec :" + this.videoCodec + ": stream :" + videoStream.streamName);
						if (videoStream.data.userStatus == 1)
						{
							videoStream.streamState=PUBLISHING_STATE;
						}
						flixPublisher.publishFlixVideo(videoStream.data, ipFMS, applicationName);
						createSocket(videoStream);
					}
					else if (this.videoCodec == VideoConnection.CODEC_SORENSON || this.videoCodec == VideoConnection.CODEC_H264) //TODO: for all OSs
					{
						if (Log.isDebug()) log.debug("startVideoPublishingProcess:- ipFMS :" + ipFMS + ", with codec :" + this.videoCodec + ": stream :" + videoStream.streamName);
						
						publishEncodedVideo(videoStream);
					}
				}
				else if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
				{
					if (this.videoCodec == VideoConnection.CODEC_SORENSON || this.videoCodec == VideoConnection.CODEC_H264) //TODO: for all OSs
					{
						if (Log.isDebug()) log.debug("startVideoPublishingProcess:- ipFMS :" + ipFMS + ", with codec :" + this.videoCodec + ": stream :" + videoStream.streamName);
						publishEncodedVideo(videoStream);
					}
				}
				else if (Capabilities.os.toLowerCase().indexOf("linux") > -1)
				{
					ffmpegPublisher.publishFFMPEGVideo(videoStream.data, ipFMS, applicationName,this.ncVideo);
				}
			}
		}
		
		/**
		 *@private
		 * 
		 * 
		 */
		private function resetPublishStatus():void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamType == PUBLISH_TYPE)
				{
					tempStream.data.userStatus=Constants.HOLD_VIDEO;
				}
			}
		}
		
		/**
		 * @private 
		 * @param videoStream of type VideoStream
		 * 
		 */
		private function publishEncodedVideo(videoStream:VideoStream):void
		{
			if (Log.isDebug()) log.debug("publishEncodedVideo:- ipFMS :" + ipFMS +", Encoder :"+ ClassroomContext.aviewClass.videoCodec + ", creating new NetStream for :" + videoStream.streamName + ", Connected:" + this.ncVideo.isConnected());
			
			videoStream.stream=new NetStream(this.ncVideo.netConnection);
			
			if (videoStream.data.streamNumber == 1)
			{
				microPhoneObj=Microphone.getEnhancedMicrophone(this.micIndex);
				microPhoneObj.codec=SoundCodec.SPEEX;
				microPhoneObj.encodeQuality=10;
				microPhoneObj.setUseEchoSuppression(true);
				microPhoneObj.setSilenceLevel(0);
				microPhoneObj.gain=50;
				
				if(ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON)
				{
					var sorensonCodec:VideoStreamSettings=new VideoStreamSettings();
					videoStream.stream.videoStreamSettings=sorensonCodec;
				}
				else if(ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264)
				{
					var h264Codec:H264VideoStreamSettings=new H264VideoStreamSettings();
					if(videoStream.data.h264Profile=="BaseLine")
						h264Codec.setProfileLevel(H264Profile.BASELINE,videoStream.data.h264ProfileValue.toString());
					else
						h264Codec.setProfileLevel(H264Profile.MAIN,videoStream.data.h264ProfileValue.toString());
					videoStream.stream.videoStreamSettings=h264Codec;
				}
				
				videoStream.stream.attachAudio(microPhoneObj);
				if (!this.isAudioOnlyOption)
				{
					if (ClassroomContext.aviewClass.isMultiBitrate == "Y" && ClassroomContext.userVO.role == Constants.TEACHER_TYPE && (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264 || ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON))
					{
						var i:int=0;
						for (i=0; i < Camera.names.length; i++)
						{
							if (Camera.names[i] == FlexGlobals.topLevelApplication.mainApp.SCREEN_CAMERA_DRIVER_NAME)
							{
								break;
							}
						}
						cameraObj=Camera.getCamera(i.toString());
					}
					else
					{
						cameraObj=Camera.getCamera(this.cameraIndex.toString());
					}
					if (videoStream.data.userStatus == 1)// && ClassroomContext.aviewClass.isMultiBitrate != "Y")
					{
						cameraObj.setQuality(videoStream.data.bandwidth, videoStream.data.quality);
						cameraObj.setMode(videoStream.data.videoCaptureWidth, videoStream.data.videoCaptureHeight, videoStream.data.fps);
						cameraObj.setKeyFrameInterval(videoStream.data.keyFrames);
					}
					videoStream.stream.attachCamera(cameraObj)
				}
			}
			if (videoStream.data.userStatus == 1)
			{
				if (Log.isDebug()) log.debug("publishEncodedVideo:- ipFMS :" + ipFMS +", Encoder :"+ ClassroomContext.aviewClass.videoCodec + ", Setting the PUBLISHING_STATE for stream :" + videoStream.streamName + " and publishing");
				videoStream.streamState=PUBLISHING_STATE;
				videoStream.publish();
				if (ClassroomContext.aviewClass.classType == Constants.CLASS_TYPE_WEBINAR)
					ncVideo.netConnection.call('recordWebinar', null, videoStream.streamName.toString());
			}
			else
			{
				if (Log.isDebug()) log.debug("publishEncodedVideo:- ipFMS :" + ipFMS +", Encoder :"+ ClassroomContext.aviewClass.videoCodec + ", Holding for stream :" + videoStream.streamName);
			}
			videoStreamAEC=videoStream.stream;
		}
		
		/**
		 *@private
		 * 
		 * 
		 */
		private function killVideoAVParamObjects():void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].streamType == PUBLISH_TYPE && ncVideo.connectionRetrys == 0)
				{
					if (Log.isDebug()) log.debug("killVideoAVParamObjects:- ipFMS :" + ipFMS + ", removing stream :" + streamObjects[i].streamName);
					streamObjects.removeItemAt(i);
					i--;
				}
				else if (streamObjects[i].streamType == PUBLISH_TYPE && ncVideo.connectionRetrys > 0)
				{
					if (Log.isDebug()) log.debug("killVideoAVParamObjects:- ipFMS :" + ipFMS + ", Setting the state to StoppedState for stream :" + streamObjects[i].streamName);
					streamObjects[i].streamState=STOPPED_STATE;
				}
			}
		}
		
		
		//private var arrayVP6Streams:Array
		//private var socketIndex:int=0;
		
		/**
		 *@public 
		 * 
		 */
		public function killVideoPublishingProcess():void
		{
			applicationType::web
			{
				killVideoPublishingProcessHandler();
			}
			applicationType::desktop
			{
				if (Capabilities.os.toLowerCase().indexOf("win") > -1)
				{
					killVideoPublishingProcessHandler();
				}
				else if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
				{
					if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", Stopping the MAC-FMLE publishing process");
					
					try
					{
						for (var j:int=0; j < streamObjects.length; j++)
						{
							var objStream:VideoStream=streamObjects[j];
						
							if (objStream.videoCodec == VideoConnection.CODEC_SORENSON)
							{
								if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop")
								{
									objStream.stream.attachCamera(null);
								}
								objStream.streamState=STOPPED_STATE;
								objStream.stream.close();
								if (ncVideo.connectionRetrys == 0)
								{
									streamObjects.removeItemAt(j);
									j--;
								}
								if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", removing stream :" + objStream.streamName);
							}
							else if (objStream.videoCodec == VideoConnection.CODEC_H264)
							{
								if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop")
								{
									objStream.stream.attachCamera(null);
								}
								objStream.streamState=STOPPED_STATE;
								objStream.stream.close();
								if (ncVideo.connectionRetrys == 0)
								{
									streamObjects.removeItemAt(j);
									j--;
								}
								if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", removing stream :" + objStream.streamName);
							}
						}
					}
					catch (er:Error)
					{
						if(Log.isError()) log.error("Error in killVideoPublishingProcess method:"+ er.getStackTrace());
					}
				}
				else if (Capabilities.os.toLowerCase().indexOf("linux") > -1)
				{
					if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", Stopping the Linux-FFMPG publishing process");
					ffmpegPublisher.killFFMPEGProcess();
				}
			}
		}
		//RTCR: Need to change the function name
		/**
		 *@private 
		 * 
		 */
		private function killVideoPublishingProcessHandler():void
		{
			if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS);
			
			try
			{
				for (var i:int=0; i < streamObjects.length; i++)
				{
					var objStream:VideoStream=streamObjects[i];
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
					{
						applicationType::desktop{
							blackMagicFMLEPublisher.killProcess();
						}
						objStream.streamState=STOPPED_STATE;
						if (ncVideo.connectionRetrys == 0)
						{
							streamObjects.removeItemAt(i);
							i--;
							if(Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :"+ipFMS+", removing stream :"+objStream.streamName);
						}
						continue;
					}
					if (objStream.videoCodec == VideoConnection.CODEC_VP6) //TODO: Store the codec and bit rate as class level variables, same as the audio/vido drivers
					{
						objStream.socketCommand="quit";
						objStream.socket.connect("127.0.0.1", objStream.portNO);
						objStream.streamState=STOPPING_STATE;
						if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", Setting the state to STOPPING_STATE for stream :" + objStream.streamName);
					}
					else if (objStream.videoCodec == VideoConnection.CODEC_SORENSON || objStream.videoCodec == VideoConnection.CODEC_H264)
					{
						if (!objStream.isExternalProcess)
						{
							if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop")
							{
								objStream.stream.attachCamera(null);
							}
							objStream.stream.close();
						}
						else
						{
							objStream.exitInternalCodecMultipleBitrateEXE(false);
						}
						
						objStream.streamState=STOPPED_STATE;
						
						if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", Setting the state to STOPPED_STATE for stream :" + objStream.streamName);
						if (ncVideo.connectionRetrys == 0)
						{
							streamObjects.removeItemAt(i);
							i--;
							if (Log.isDebug()) log.debug("killVideoPublishingProcess:- ipFMS :" + ipFMS + ", removing stream :" + objStream.streamName);
						}
					}
				}
			}
			catch (er:Error)
			{
				if(Log.isError()) log.error("Error in killVideoPublishingProcessHandler method:"+ er.getStackTrace());
			}
		}
		
		/**
		 * @private 
		 * @param event of type TimerEvent
		 * 
		 */
		private function timerNativeProcessExitHandler(event:TimerEvent):void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.streamType == PUBLISH_TYPE)
				{
					tempStream.streamState=STOPPED_STATE;
				}
			}
		}
		
		/**
		 * @public
		 * This function is used for stop publishing audio/video stream of the user.
		 * @param flag of type uint (indicate whether it is called for multiple or consolidate)
		 * 
		 */
		public function stopPublish():void
		{
			streamUnPublish=false;
			//checkkillAKRProcess();
			killVideoPublishingProcess();
			if (Log.isDebug()) log.debug("stopPublish:- ipFMS :" + ipFMS + ", Exited");
		}
		
		/**
		 * @public 
		 * @param objVideo of type Video
		 * @param objVideoDisplay of type VideoDisplay
		 * @param streamName of type String
		 * @param isReceiveAudio of type Boolean
		 * 
		 */
		public function startStream(objVideo:Video, objVideoDisplay:VideoDisplay, streamName:String, isReceiveAudio:Boolean):void
		{
			var objVideoStream:VideoStream=new VideoStream();
			objVideoStream.streamName=streamName;
			objVideoStream.streamType=SUBSCRIBE_TYPE;
			objVideoStream.stream=new NetStream(this.ncVideo.netConnection);
			objVideoStream.stream.client=new Object();
			objVideoStream.stream.client.onMetaData=ns_onMetaData;
			streamObjects.addItem(objVideoStream);
			objVideo.attachNetStream(objVideoStream.stream);
			objVideoStream.stream.bufferTime=0;
			objVideoStream.stream.play(streamName);
			objVideoStream.stream.receiveAudio(isReceiveAudio);
			if (objVideoDisplay != null)
				objVideoDisplay.addChild(objVideo);
			teacherVideoConnected=true;
			if (Log.isDebug()) log.debug("startStream:- ipFMS :" + ipFMS + ", streamName :" + streamName)
		}
		
		
		/**
		 * @private
		 * Dummy handler for onMetaData event. Issue #173 
		 * @param item of type Object
		 * 
		 */
		private function ns_onMetaData(item:Object):void
		{
			if (Log.isDebug()) log.debug("ns_onMetaData:- ipFMS :" + ipFMS);
		}
		
		/**
		 * @public 
		 * @param StreamName of type String
		 * @return int
		 * 
		 */
		public function streamStrength(StreamName:String):int
		{
			var strength:int
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].streamName == StreamName && streamObjects[i].streamType == SUBSCRIBE_TYPE)
				{
					netInfo=streamObjects[i].stream.info;
					strength=Math.round(netInfo.currentBytesPerSecond);
					break;
				}
			}
			return strength;
		}
		
		/**
		 * @public 
		 * @param StreamName of type String
		 * @return 
		 * 
		 */
		public function getAudiActivity(StreamName:String):int
		{
			var strength:int=0;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				// AKCR: Can the following 2 IF conditions be combined?
				if (streamObjects[i].streamName == StreamName && streamObjects[i].streamType == SUBSCRIBE_TYPE)
				{
					if (streamObjects[i].stream.soundTransform.volume == 0)
					{
						strength=0;
					}
					else
					{
						netInfo=streamObjects[i].stream.info;
						strength=Math.round(netInfo.audioBytesPerSecond);
					}
					break;
				}
			}
			return strength;
		}
		
		/**
		 * @public  
		 * @param StreamName of type String
		 * 
		 */
		public function stopStream(StreamName:String):void
		{
			//var objExist:Boolean=false;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].streamName == StreamName && streamObjects[i].streamType == SUBSCRIBE_TYPE)
				{
					if (Log.isDebug()) log.debug("stopStream:- ipFMS :" + ipFMS + ", StreamName :" + StreamName);
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop")
					{
						streamObjects[i].stream.attachCamera(null);
					}
					streamObjects[i].stream.close();
					streamObjects.removeItemAt(i);
					break;
				}
			}
			
			teacherVideoConnected=false;
		}
		
		/**
		 * @public  
		 * @param streamName of type String
		 * @return Boolean
		 * 
		 */
		public function doesStreamExist(streamName:String):Boolean
		{
			return (netStreamValue(streamName) != null);
		}
		
		/**
		 * @private 
		 * @param streamName of type String
		 * @return NetStream
		 * 
		 */
		private function netStreamValue(streamName:String):NetStream
		{
			var tempNetStream:NetStream=null;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].streamName == streamName && streamObjects[i].streamType == SUBSCRIBE_TYPE)
				{
					tempNetStream=streamObjects[i].stream;
					break;
				}
			}
			
			return tempNetStream;
		
		
		}
		
		/**
		 * @public 
		 * @param portNo of type int
		 * @param cmd of type String
		 * 
		 */
		public function startCapture(portNo:int, cmd:String):void
		{
			//Alert.show(watchTimerAKR.currentCount.toString());
			if (Log.isDebug()) log.debug("startCapture:- ipFMS :" + ipFMS + ", portNo :" + portNo + ": cmd:" + cmd + ":");
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (Log.isDebug()) log.debug("startCapture:- ipFMS :" + ipFMS + ", portNo :" + tempStream.portNO + " stream name:" + tempStream.streamName + " type:" + tempStream.streamState)
				if (tempStream.portNO == portNo && tempStream.streamState != PUBLISHED_STATE && tempStream.streamState != PUBLISHING_STATE)
				{
					tempStream.streamState=PUBLISHING_STATE;
					tempStream.data.userStatus=Constants.STREAM_VIDEO;
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE && !this.isAudioOnlyOption)
					{
						applicationType::desktop{
							blackMagicFMLEPublisher.publishVideo(tempStream.data, ipFMS, applicationName);
						}
					}
					else
					{
						if (Log.isDebug()) log.debug(tempStream.socket.connected.toString());
						if (tempStream.socket.connected)
						{
							tempStream.socketCommand=cmd;
							executeSocketCommand(portNo);
						}
						else
						{
							tempStream.socketCommand=cmd;
							//tempStream.socket.
							tempStream.socket.connect("127.0.0.1", portNo);
						}
					}
					if (Log.isDebug()) log.debug("startCapture:- ipFMS :" + ipFMS + ", Matched, portNO :" + tempStream.portNO + ", streamName :" + tempStream.streamName + ", selectedBandWidth :" + tempStream.data.selectedBandWidth + ", cmd :" + cmd);
					
					break;
				}
			}
		}
		
		/**
		 * @public 
		 * @param portNo of type int
		 * @param cmd of type String
		 * 
		 */
		public function stopCapture(portNo:int, cmd:String):void
		{
			if (Log.isDebug()) log.debug("stopCapture:- ipFMS :" + ipFMS + ", Entered with PortNo:" + portNo + ", cmd :" + cmd + ", ip:" + ipFMS);
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (tempStream.portNO == portNo)
				{
					tempStream.data.userStatus=Constants.HOLD_VIDEO;
					if (Log.isInfo()) log.info("stopCapture:- ipFMS :" + ipFMS + ", Calling stopCaptureForStream with PortNo:" + tempStream.portNO + ", cmd :" + cmd + ", Stream Name :" + tempStream.streamName + ", Stream State :" + tempStream.streamState + ", IP :" + ipFMS + ":");
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
					{
						tempStream.streamState = STOPPED_STATE;
						applicationType::desktop{
							blackMagicFMLEPublisher.killProcess();
						}
					}
					else
					{
						stopCaptureForStream(tempStream,portNo,cmd)
					}
					break;
				}
			}
		}
		
		/**
		 * @private 
		 * @param tempStream of type VideoStream
		 * @param portNo of type int
		 * @param cmd of type String
		 * 
		 */
		private function stopCaptureForStream(tempStream:VideoStream, portNo:int, cmd:String):void
		{
			if (tempStream.setIntervalId != -1)
			{
				clearInterval(tempStream.setIntervalId);
				tempStream.setIntervalId=-1;
			}
			if (tempStream.streamState == PUBLISHED_STATE)
			{
				tempStream.isStreamStoppedManually=true;
				tempStream.streamState=STOPPED_STATE;
				//if(Log.isDebug()) log.debug(tempStream.socket.connected.toString());
				if (tempStream.socket.connected)
				{
					tempStream.socketCommand=cmd;
					executeSocketCommand(portNo);
				}
				else
				{
					tempStream.socketCommand=cmd;
					tempStream.socket.connect("127.0.0.1", portNo);
				}
				if (Log.isDebug()) log.debug("stopCaptureForStream:- ipFMS :" + ipFMS + ", Matched, portNO :" + tempStream.portNO + ", streamName :" + tempStream.streamName + ", selectedBandWidth :" + tempStream.data.selectedBandWidth + ", cmd :" + cmd);
				
			}
			else if (tempStream.streamState == PUBLISHING_STATE)
			{
				if (Log.isDebug()) log.debug("stopCaptureForStream:- ipFMS :" + ipFMS + ", setinterval stopInternalCodecCapture ");
				tempStream.setIntervalId=setInterval(stopCaptureForStream, 1000, tempStream, portNo);
			}
		}
		
		/**
		 * @public 
		 * @param portNo of type int
		 * 
		 */
		public function startInternalCodecCapture(portNo:int):void
		{
			if (Log.isDebug()) log.debug("startInternalCodecCapture:- ipFMS :" + ipFMS + ", portNo :" + portNo + ":");
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (Log.isDebug()) log.debug("startInternalCodecCapture:- ipFMS :" + ipFMS + ", portNo :" + tempStream.portNO + " stream name:" + tempStream.streamName + " streamState:" + tempStream.streamState)
				if (tempStream.portNO == portNo && tempStream.streamState != PUBLISHED_STATE && tempStream.streamState != PUBLISHING_STATE)
				{
					tempStream.streamState=PUBLISHING_STATE;
					tempStream.data.userStatus=Constants.STREAM_VIDEO;
					
					if (!this.isAudioOnlyOption)
					{
						cameraObj.setQuality(tempStream.data.bandwidth, tempStream.data.quality);
						cameraObj.setMode(tempStream.data.videoCaptureWidth, tempStream.data.videoCaptureHeight, tempStream.data.fps);
					}
					
					if (Log.isDebug()) log.debug("startInternalCodecCapture:- ipFMS :" + ipFMS + ", portNo :" + tempStream.portNO + " stream name:" + tempStream.streamName + " streamState:" + tempStream.streamState)
					//	tempStream.stream.publish(tempStream.streamName.toString());
					tempStream.publish();
				}
			}
		}
		
		/**
		 * @private 
		 * @param stream of type VideoStream
		 * @param portNo of type int
		 * 
		 */
		private function stopInternalCodecCaptureForStream(stream:VideoStream, portNo:int):void
		{
			if (stream.setIntervalId != -1)
			{
				clearInterval(stream.setIntervalId);
				stream.setIntervalId=-1;
			}
			stream.isStreamStoppedManually=true;
			if (Log.isDebug()) log.debug("stopInternalCodecCaptureForStream:- ipFMS :" + ipFMS + ", portNo :" + stream.portNO + " stream name:" + stream.streamName + " type:" + stream.streamState)
			if (stream.streamState == PUBLISHED_STATE)
			{
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.lblStart.text != "Stop")
				{
					stream.stream.attachCamera(null);
				}
				stream.stream.close();
				stream.streamState=STOPPED_STATE;
			}
			else if (stream.streamState == PUBLISHING_STATE)
			{
				stream.setIntervalId=setInterval(stopInternalCodecCaptureForStream, 1000, stream, portNo);
			}
		}
		
		/**
		 * @public 
		 * @param portNo of type int
		 * 
		 */
		public function stopInternalCodecCapture(portNo:int):void
		{
			if (Log.isDebug()) log.debug("stopInternalCodecCapture:- ipFMS :" + ipFMS + ", portNo :" + portNo + ":");
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStream:VideoStream=streamObjects[i];
				if (Log.isDebug()) log.debug("stopInternalCodecCapture:- ipFMS :" + ipFMS + ", portNo :" + tempStream.portNO + " stream name:" + tempStream.streamName + " type:" + tempStream.streamState)
				if (tempStream.portNO == portNo)
				{
					tempStream.data.userStatus=Constants.HOLD_VIDEO;
					stopInternalCodecCaptureForStream(tempStream, portNo);
				}
				if (tempStream.isExternalProcess)
				{
					tempStream.exitInternalCodecMultipleBitrateEXE(false);
				}
			}
		}
		
		/**
		 * @public 
		 * @param streamName of type String
		 * @param setValue of type  Boolean
		 * @return Boolean
		 * 
		 */
		public function toggleVideo(streamName:String, setValue:Boolean):Boolean
		{
			var tempNetstreamStatus:Boolean=false;
			var tempNetStream:NetStream=netStreamValue(streamName);
			if (tempNetStream)
			{
				tempNetStream.receiveVideo(setValue);
			}
			if (tempNetStream != null)
			{
				tempNetstreamStatus=true;
			}
			
			return tempNetstreamStatus;
		}
		
		/**
		 * @public 
		 * @param unMuteStream of type String
		 * @param skipStream of type String
		 * 
		 */
		public function muteAllOtherStreams(unMuteStream:String, skipStream:String):void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].streamType == SUBSCRIBE_TYPE)
				{
					if (streamObjects[i].streamName == skipStream)
					{
						continue;
					}
					
					// AKCR: Please use conditional operator, for e.g 
//					streamObjects[i].stream.soundTransform  = (streamObjects[i].streamName == unMuteStream) ? 
//																	STREAM_UN_MUTE : STREAM_MUTE;
					
					if (streamObjects[i].streamName == unMuteStream)
					{
						streamObjects[i].stream.soundTransform=STREAM_UN_MUTE;
					}
					else
					{
						streamObjects[i].stream.soundTransform=STREAM_MUTE;
					}
				}
			}
		}
		
		/**
		 * @public 
		 * 
		 */
		public function unMuteAllStreams():void
		{
			for (var i:int=0; i < streamObjects.length; i++)
			{
				if (streamObjects[i].streamType == SUBSCRIBE_TYPE)
				{
					streamObjects[i].stream.soundTransform=STREAM_UN_MUTE;
				}
			}
		}
		
		/**
		 * @public 
		 * @param streamName of type String
		 * @param mute of type Boolean
		 * 
		 */
		public function mutePTTStream(streamName:String,mute:Boolean):void
		{
			var tempNetStream:NetStream;
			tempNetStream=netStreamValue(streamName);
			if ((ncVideo != null && ncVideo.isConnected()) && tempNetStream)
			{
				if (Log.isDebug()) log.debug("mutePTTStream:- ipFMS :" + ipFMS +", isMute :"+ mute +", netStream.info.currentBytesPerSecond:" + tempNetStream.info.currentBytesPerSecond + ":" + " streamName " + streamName);
				// AKCR: extra curly brackets?
				{
					// AKCR: please use conditional operator, for e.g
					// mute unmute teachers audio
					// tempNetStream.soundTransform=(mute)? STREAM_MUTE : STREAM_UN_MUTE;
					if(mute)
					{
						//set teacher's audio to 'mute' 
						tempNetStream.soundTransform=STREAM_MUTE;
					}
					else
					{
						//set teacher's audio to 'unmute' 
						tempNetStream.soundTransform=STREAM_UN_MUTE;
					}
				}
			}
		}
		
		/**
		 * @public 
		 * @return Boolean
		 *  
		 */
		public function isVideoInPublish():Boolean
		{
			var isPublishing:Boolean=false;
			for (var i:int=0; i < streamObjects.length; i++)
			{
				var tempStreamObjects:VideoStream=streamObjects[i];
				if (tempStreamObjects.streamType == PUBLISH_TYPE)
				{
					isPublishing=true;
					break;
				}
			}
			return isPublishing;
		}
		
		/**
		 * @public 
		 * 
		 */
		public function closeConnection():void
		{
			ncVideo.close();
			ncVideo.removeEventListener(MediaServerStatusEvent.TYPE_CONNECTION_STATUS, netStatusHandler);
		}
	}
}
