package edu.amrita.aview.core.video.native
{
	//---------------------------------------------------------------------------------------------
	// 1. Authors      : Vivek
	// 2. Description  : FFMPEGPublisher.as is used for calling the ffmpeg A/V library for staring 
	//                   the video audio encoding and streaming to server. Here Native API class					  
	//					 is being used for calling ffmpeg which is the encdoing engine.All needed
	//					 parameters are passed to ffmpeg through NativeProcessStartupInfo class.  
	// 3. Dependencies : Video_ScriptCode.as
	//---------------------------------------------------------------------------------------------
	
	import edu.amrita.aview.common.service.MediaServerConnection;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.video.AVParameters;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;
	
	
	public class FFMPEGPublisher
	{
		/**
		 * file that is to be called by the native process.
		 */
		private var file:File;
		
		/**
		 * The NativeProcess object for calling the ffmpeg shell script from LinuxOS.
		 */
		public var process:NativeProcess=new NativeProcess();
		
		/**
		 * The command line arguments that will be passed to the process on startup.
		 */
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		/**
		 * Each string in the processArgs vector will be passed as separate argument to application
		 * Here the whole shell script is passed as argument.
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
		private var srteamURL1:String;
		private var srteamURL2:String;
		
		/**
		 * Holds the entire command that has to be written in to the file.
		 */
		private var fileContentString:String;
		
		/**
		 * File object is used for creating the shell script file
		 * <br> This shell script is used for calling ffmpeg from Linux<br>
		 */
		private var ffmpegScript:File;
		
		/**
		 * File path where the shell script is to be updated for changes in A/V & stream settings.
		 */
		private const FFMPEG_SHELL_SCRIPT:String="/opt/A-VIEW CLASSROOM/share/NativeApps/linux/bin/ffmpeg-script.sh";
		
		/**
		 * Used to display the local video as a preview.
		 */
		private var localVideoDisplay:LocalVideoDisplay;
		
		/**
		 * Varibale to store the stream name of user.
		 */
		private var streamName:String;
		private var streamName1:String;
		private var streamName2:String;
		
		
		
		public function publishFFMPEGVideo(avParams:AVParameters, ipFMS:String, applicationName:String,videoConnection:MediaServerConnection):void
		{
			nativeProcessStartupInfo=new NativeProcessStartupInfo();
			processArgs=new Vector.<String>();
			
			streamName=avParams.streamName.toString();
			srteamURL=ClassroomContext.protocolFMS + "://" + ipFMS + "/" + applicationName + "/" + avParams.className.toString() + "/" + streamName;
			if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE && ClassroomContext.aviewClass.isMultiBitrate == "Y")
			{
//				streamName1=avParams.userName1.toString();
//				srteamURL1=ClassroomContext.protocolFMS + "://" + avParams.ipFms.toString() + "/" + Constants.VIDEO_SERVER_MODULE_NAME + "/" + avParams.className.toString() + "/" + streamName1;
//				streamName2=avParams.userName2.toString();
//				srteamURL2=ClassroomContext.protocolFMS + "://" + avParams.ipFms.toString() + "/" + Constants.VIDEO_SERVER_MODULE_NAME + "/" + avParams.className.toString() + "/" + streamName2;
//				fileContentString="#! /bin/bash" + "\n\n" + "ffmpeg  -f video4linux2 -i /dev/video0 -s " + avParams.videoCaptureWidth.toString() + "*" + avParams.videoCaptureHeight.toString() + " -s " + avParams.videoCaptureWidth1.toString() + "*" + avParams.videoCaptureHeight1.toString() + " -s " + avParams.videoCaptureWidth2.toString() + "*" + avParams.videoCaptureHeight2.toString() + " -vcodec flv -b " + (avParams.videoBitRate * 1000).toString() + " -b " + (avParams.videoBitRate1 * 1000).toString() + " -b " + (avParams.videoBitRate2 * 1000).toString() + " -acodec libmp3lame  -ab " + (avParams.audioBitRate * 1000).toString() + " -ab " + (avParams.audioBitRate1 * 1000).toString() + " -ab " + (avParams.audioBitRate2 * 1000).toString() + " -y -f flv " + srteamURL + " -f flv " + srteamURL1 + " -f flv " + srteamURL2 + "\n";
			}
			else
			{
				fileContentString="#! /bin/bash" + "\n\n" + "ffmpeg  -f video4linux2 -i /dev/video0 -s " + avParams.videoCaptureWidth.toString() + "*" + avParams.videoCaptureHeight.toString() + " -vcodec flv -b " + (avParams.videoBitrate * 1000).toString() + " -acodec libmp3lame  -ab " + (avParams.audioBitrate * 1000).toString() + " -y -f flv " + srteamURL + "\n";
			}
			
			
			ffmpegScript=File.applicationDirectory;
			ffmpegScript=ffmpegScript.resolvePath(FFMPEG_SHELL_SCRIPT);
			
			fileStream.open(ffmpegScript, FileMode.WRITE);
			fileStream.writeUTFBytes(fileContentString);
			fileStream.close();
			
			file=new File("file:///bin/bash");
			processArgs.push(FFMPEG_SHELL_SCRIPT);
			
			nativeProcessStartupInfo.executable=file;
			nativeProcessStartupInfo.arguments=processArgs;
			
			if (NativeProcess.isSupported == true)
				process.start(nativeProcessStartupInfo);
			else
				Alert.show("not supported", "FF MPEG");
			
			localVideoDisplay=new LocalVideoDisplay();
			localVideoDisplay.open(true);
			localVideoDisplay.setMediaServerConnection(videoConnection, streamName);
		
		}
		
		public function startCapture():void
		{
		}
		
		public function stopCapture():void
		{
		}
		
		public function killFFMPEGProcess():void
		{
			process.exit();
			localVideoDisplay.closeEventHandler(Event.CLOSE as Event);
		/*
		if(process.running==true)
		process.exit(true);*/		
		}
	}
}
