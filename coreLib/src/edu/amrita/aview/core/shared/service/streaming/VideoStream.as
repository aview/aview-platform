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
 * File			: VideoStream.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.core.shared.service.streaming
{
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.video.AVParameters;
	
	import flash.media.Camera;
	import flash.net.NetStream;
	import flash.net.Socket;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;

	//VGCR:-Class Description
	//VGCR:-Variable Description
	//VGCR:-Description for all functions
	public final class VideoStream
	{
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.VideoStream");
		
		public var streamSubscriptionType:String;
		public var serverType:String;
		public var streamType:String;
		public var streamState:String;
		public var streamName:String;
		public var data:AVParameters;
		public var videoCodec:String;
		public var portNO:int;
		public var published:Boolean;
		
		public var socket:Socket;
		public var stream:NetStream;
		public var isStreamStoppedManually:Boolean;
		public var socketCommand:String;
		public var isExternalProcess:Boolean=false;
		
		/**Platform specific imports and variables*/
		applicationType::desktop
		{
			import flash.desktop.NativeProcess;
			import flash.desktop.NativeProcessStartupInfo;
			import flash.filesystem.File;
			
			private var processInternalCodecMultipleBitrateSlave:NativeProcess;
		}
		
		
		/**
		 *@public
		 * Constructor 
		 * 
		 */
		public function VideoStream()
		{
		}
		public var setIntervalId:int=-1;
		
		/**
		 *@public 
		 * 
		 */
		public function publish():void
		{
			if (data.streamNumber == 1 || ClassroomContext.aviewClass.isMultiBitrate == "N")
			{
				if (Log.isDebug()) log.debug("publish:- Publishing stream. Details.. data.streamNumber :" + data.streamNumber + ", ClassroomContext.aviewClass.isMultiBitrate :" + ClassroomContext.aviewClass.isMultiBitrate + ", Stream :" + streamName+", camWidth:"+data.videoCaptureWidth+", camHeight:"+data.videoCaptureHeight);
				stream.publish(streamName);
			}
			else
			{
				if (Log.isDebug()) log.debug("publish:- Publishing multi bit rate stream with External process...data.streamNumber :" + data.streamNumber + ", ClassroomContext.aviewClass.isMultiBitrate :" + ClassroomContext.aviewClass.isMultiBitrate + ", Stream :" + streamName);
				launchInternalCodecMultipleBitrateEXE(data.streamNumber, true)
			}
		}
		
		
		/**
		 * @public 
		 * @param val of type int
		 * @param attachCamera of type Boolean
		 * 
		 */
		public function launchInternalCodecMultipleBitrateEXE(val:uint, attachCamera:Boolean):void
		{
			if (Log.isDebug()) log.debug("launchInternalCodecMultipleBitrateEXE:- Entered. Details.. StreamName :" + streamName + ", StreamNumber :" + val + ", attachCamera :" + attachCamera);
			applicationType::desktop
			{
				var file:File=File.applicationDirectory;
				var nativeProcessStartupInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
				var processArgs:Vector.<String>=new Vector.<String>();
				
				var paramObj:Object=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.internalCodecMultipleBitratePublish(val - 1);
				processArgs.push(paramObj.camIndex);
				processArgs.push(paramObj.micIndex);
				processArgs.push(paramObj.camWidth);
				processArgs.push(paramObj.camHeight);
				processArgs.push(paramObj.codec);
				processArgs.push(paramObj.camFPS);
				processArgs.push(paramObj.bandwidth);
				processArgs.push(paramObj.quality);
				processArgs.push(paramObj.streamName);
				processArgs.push(paramObj.FMS_URL);
				nativeProcessStartupInfo.arguments=processArgs;
				file=File.applicationDirectory;
				if (val == 2)
				{
					if (attachCamera == true && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.attachedCameraToScreenCamera == false)
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraToScreenCamera(1, data.videoDeviceDrive);
					}
					file=file.resolvePath("NativeApps/Windows/bin/InternalCodecMultipleBitrateSlaveEXE/MulitBitRateStreamer.exe");
				}
				else
				{
					file=file.resolvePath("NativeApps/Windows/bin/InternalCodecMultipleBitrateSlaveEXE2/MulitBitRateStreamer.exe");
				}
				nativeProcessStartupInfo.executable=file;
				processInternalCodecMultipleBitrateSlave=new NativeProcess();
				processInternalCodecMultipleBitrateSlave.start(nativeProcessStartupInfo);
				if (Log.isDebug()) log.debug("launchInternalCodecMultipleBitrateEXE:- Exited. Details..StreamName :" + streamName + ", StreamNumber :" + val + ", attachCamera :" + attachCamera + ", camWidth:"+paramObj.camWidth+", camHeight:"+paramObj.camHeight);
			}
		}
		
		/**
		 * @public 
		 * @param appCloseFlag of type Boolean
		 * 
		 */
		public function exitInternalCodecMultipleBitrateEXE(appCloseFlag:Boolean):void
		{
			try
			{
				applicationType::desktop
				{
					if (Log.isDebug()) log.debug("exitInternalCodecMultipleBitrateEXE:- Entered. Details.. StreamNumber :" + data.streamNumber + ", appCloseFlag :" + appCloseFlag);
					if (processInternalCodecMultipleBitrateSlave)
					{
						processInternalCodecMultipleBitrateSlave.exit();
						processInternalCodecMultipleBitrateSlave=null;
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo)
						{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.camTemp.setMode(320,180,12);
						}
					}
				}
				/*	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.processAttachCam && appCloseFlag == false && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.attachedCameraToScreenCamera == true)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraToScreenCamera(0, "ScreenCamera");
				}*/
				if (Log.isDebug()) log.debug("exitInternalCodecMultipleBitrateEXE:- Exited. Details.. StreamNumber :" + data.streamNumber + ", appCloseFlag :" + appCloseFlag);
			}
			catch (err:Error)
			{
				if(Log.isError()) log.error("Error in exitInternalCodecMultipleBitrateEXE method:"+ err.getStackTrace());
			}
		}
	}
}
