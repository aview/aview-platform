package edu.amrita.aview.core.video.native
{
	//---------------------------------------------------------------------------------------------
	// 1. Authors      : Vivek,Ashish Pillai
	// 2. Description  : FLIXPublisher.as is used for calling the flix video publisher for staring 
	//                   the video audio encoding and streaming to server. Here Native API class					  
	//					 is being used for calling the akr.exe which is the flix engine.The video
	//					 parameters are passed to akr.exe through NativeProcessStartupInfo class.  
	// 3. Dependencies : Video_ScriptCode.as
	//---------------------------------------------------------------------------------------------
	
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	
	public class FLIXPublisher
	{
		private var intt:int=0;
		/**
		 * file that is to be called by the native process.
		 */
		private var file:File;
		
		/**
		 * The NativeProcess object for calling akr.exe from windows os.
		 */
		public var process:Array=new Array();
		//public var process2:NativeProcess=new NativeProcess();
		//public var process3:NativeProcess=new NativeProcess();
		
		/**
		 * The command line arguments that will be passed to the process on startup.
		 */
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		/**
		 * Each string in the processArgs vector will be passed as separate argument to application
		 * Here we pass A/V settings & Stream settings as arguments.
		 */
		private var processArgs:Vector.<String>;
		
		/**
		 * File Stream object to write the arguments in to the shell script file.
		 */
		private var fileStream:FileStream=new FileStream();
		
		/**
		 * URL Pointing to the stream of user to the FMIS.
		 */
		private var srteamURL:String;
		
		/**
		 * String holding the values for ake.exe process.
		 */
		private var flixParameters:String;
		
		/**
		 * Varibale to store the stream name of user.
		 */
		private var streamName:String;
		
		/**
		 * Varibale for temporarly storing the encoder-settings parameters.
		 */
		private var tempAVParam:Object;
		private var tempAVParam1:Object;
		private var tempAVParam2:Object;
		private var ipFMS:String;
		private var applicationName:String;
		
		public function publishFlixVideo(AVParam:Object, ipFMS:String, applicationName:String):void
		{
			this.ipFMS=ipFMS;
			this.applicationName=applicationName;
			tempAVParam=AVParam;
			nativeProcessStartupInfo=new NativeProcessStartupInfo();
			processArgs=new Vector.<String>();
			streamName=AVParam.streamName.toString();
			srteamURL=ClassroomContext.protocolFMS + "://" + ipFMS + ":" + ClassroomContext.portFMS + "/" + applicationName + "/" + AVParam.className.toString();
			flixParameters="," + ipFMS + ":" + ClassroomContext.portFMS + "," + applicationName + "/" + AVParam.className.toString() + "_" + ClassroomContext.aviewClass.classId + "," + streamName + "," + AVParam.videoDeviceDrive.toString() + "," + AVParam.audioDeviceDrive.toString() + "," + AVParam.videoBitrate.toString() + "," + AVParam.audioBitrate.toString() + "," + 1 + "," + 1 + "," + AVParam.videoCaptureWidth.toString() + "," + AVParam.videoCaptureHeight.toString() + "," + AVParam.outputFileWrite.toString() + "," + AVParam.videoKeyFrameFrequency.toString() + "," + AVParam.userStatus.toString() + "," + AVParam.deskTopSharing.toString() + "," + 1 + "," + AVParam.socketPortNo.toString();
			file=File.applicationDirectory;
			file=file.resolvePath("app:///NativeApps/Windows/bin/akr.exe");
			//Alert.show(flixParameters.toString());
			processArgs.push(flixParameters);
			
			nativeProcessStartupInfo.executable=file;
			nativeProcessStartupInfo.arguments=processArgs;
			
			process[process.length - 1]=new NativeProcess();
			if (NativeProcess.isSupported == true)
			{
				if (process[process.length - 1].running == false)
				{
					process[process.length - 1].start(nativeProcessStartupInfo);
				}
				else
				{
					setTimeout(reStartFlixPublisher, 2000);
				}
			}
			else
				Alert.show("not supported", "Flix Publisher");
		}
		
		/* public function publishFlixVideo2(AVParam:Object):void
		{
			tempAVParam1=AVParam;
			nativeProcessStartupInfo=new NativeProcessStartupInfo();
			processArgs=new Vector.<String>();
		
			streamName=AVParam.userName.toString();
			srteamURL= "rtmp://"+AVParam.ipFms.toString()+"/"+Constants.VIDEO_SERVER_MODULE_NAME+"/"+AVParam.className.toString();
		
			flixParameters="," + AVParam.ipFms.toString()+ ","+Constants.VIDEO_SERVER_MODULE_NAME+"/" + AVParam.className.toString() + "," + streamName+ "," + "ScreenCamera HR" + "," + AVParam.audioDeviceDriver.toString() + "," + AVParam.videoBitRate.toString() + "," + AVParam.audioBitRate.toString() + "," + 1 + "," + 1 + "," + AVParam.videoCaptureWidth.toString() + "," + AVParam.videoCaptureHeight.toString()+","+AVParam.outputFileWrite.toString()+","+AVParam.videoKeyFrameFrequency.toString()+","+1+","+AVParam.desktopSharing.toString()+","+2;
			file=File.applicationDirectory;
			file=file.resolvePath("app:///NativeApps/Windows/bin/akr.exe");
		  // Alert.show("akr2="+flixParameters.toString());
			processArgs.push(flixParameters);
		
			nativeProcessStartupInfo.executable=file;
			nativeProcessStartupInfo.arguments=processArgs;
		
			if(NativeProcess.isSupported==true)
			{
				if(process2.running==false)
				{
					process2.start(nativeProcessStartupInfo);
				}
				else
				{
					//setTimeout(reStartFlixPublisher,2000);
				}
			}
			else
				Alert.show("not supported");
		}
		
		public function publishFlixVideo3(AVParam:Object):void
		{
			tempAVParam2=AVParam;
			nativeProcessStartupInfo=new NativeProcessStartupInfo();
			processArgs=new Vector.<String>();
		
			streamName=AVParam.userName.toString();
			srteamURL= "rtmp://"+AVParam.ipFms.toString()+"/"+Constants.VIDEO_SERVER_MODULE_NAME+"/"+AVParam.className.toString();
		
		
			flixParameters="," + AVParam.ipFms.toString()+ ","+Constants.VIDEO_SERVER_MODULE_NAME+"/" + AVParam.className.toString() + "," + streamName+ "," + "ScreenCamera HR" + "," + AVParam.audioDeviceDriver.toString() + "," + AVParam.videoBitRate.toString() + "," + AVParam.audioBitRate.toString() + "," + 1 + "," + 1 + "," + AVParam.videoCaptureWidth.toString() + "," + AVParam.videoCaptureHeight.toString()+","+AVParam.outputFileWrite.toString()+","+AVParam.videoKeyFrameFrequency.toString()+","+1+","+AVParam.desktopSharing.toString()+","+3;
			file=File.applicationDirectory;
			file=file.resolvePath("app:///NativeApps/Windows/bin/akr.exe");
		   //Alert.show("akr3="+flixParameters.toString());
			processArgs.push(flixParameters);
		
			nativeProcessStartupInfo.executable=file;
			nativeProcessStartupInfo.arguments=processArgs;
		
			if(NativeProcess.isSupported==true)
			{
				if(process3.running==false)
				{
					process3.start(nativeProcessStartupInfo);
				}
				else
				{
					//setTimeout(reStartFlixPublisher,2000);
				}
			}
			else
				Alert.show("not supported");
		} */
		
		
		
		public function reStartFlixPublisher():void
		{
			publishFlixVideo(tempAVParam, ipFMS, applicationName);
		/* if(ClassroomContext.userType==Constants.TEACHER_TYPE && ClassroomContext.is_multi_bitrate==true)
		{
			publishFlixVideo2(tempAVParam1);
			publishFlixVideo3(tempAVParam2);
		} */
		}
		
		public function startCapture():void
		{
			FlexGlobals.topLevelApplication.mainApp.callSocket('startCapture');
		}
		
		public function stopCapture():void
		{
			FlexGlobals.topLevelApplication.mainApp.callSocket('stopCapture');
		}
		
		public function killFlixProcess():void
		{
			//Alert.show("pr"+process.length.toString());
			for (var i:int=0; i < process.length; i++)
			{
				if (process[i].running == true)
				{
					process[i].exit();
				}
					//intt++;
			}
		}
	}
}
