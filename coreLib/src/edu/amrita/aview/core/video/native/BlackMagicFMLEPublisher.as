package edu.amrita.aview.core.video.native
{
	//---------------------------------------------------------------------------------------------
	// 1. Authors      : Ajith Kumar R
	// 2. Description  :   
	// 3. Dependencies : Video_ScriptCode.as
	//---------------------------------------------------------------------------------------------
	
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
       	
	
	public class BlackMagicFMLEPublisher
	{
		/**
		 * file that is to be called by the native process.
		 */
		private var file:File;
		
		/**
		 * file that is used for writing the A/V settings & Stream Settings.
		 */
		private var startUpFile:File;
		
		/**
		 * File Stream object to write the arguments in to the shell script file.
		 */	
		private var fileStream:FileStream=new FileStream();
		private var fileStream1:FileStream=new FileStream();
		
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
		 * URL Pointing to the stream of user to the FMIS. 
		 */
		private var srteamURL:String="";
		
		/**
		 * String used for writing the changed values in to startup XML file.
		 */	
		private var newXMLStr:String="";
		
		/**
		 * Holds the current values in the startup XML file while a read operation is done.
		 */	
		private var xmlFileData:String="";
		
		/**
		 * XML object to modify the startup XML file with suer given A?V & Stream settings. 
		 */	
		private var presetXML:XML;
		
		/** 
		 * Varibale to store the stream name of user.
		 */
		private var streamName:String;		
		
		/**
		 * This function is used for calling FMLE process with user specific audio/video & stream
		 * settings. This function is called by Video_ScriptCode.as while user click 'Start' button 
		 * 
		 * @param AVParam  Audio,Video and Stream parameters based on settings.
		 * @return void
		 */		
		public function publishVideo(AVParam:Object,ipFMS:String,applicationName:String):void
		{
			//START--------------------------------------------------------------------------------
			//create object for NativeProcessStartupInfo and for Process arguments as vector string
			//END----------------------------------------------------------------------------------
			nativeProcessStartupInfo=new NativeProcessStartupInfo();
			processArgs=new Vector.<String>();		
			//Set the streanName of current user
			streamName=AVParam.streamName.toString();		
			//Set the URL for user stream from FMIS
			srteamURL= ClassroomContext.protocolFMS+"://"+ipFMS+":"+ ClassroomContext.portFMS+"/"+applicationName+"/"+AVParam.className.toString()+"_"+ClassroomContext.aviewClass.classId;	
			//Set the file object by poining it to commandline version of FMLE.					
			file=File.applicationDirectory;	
			file=file.resolvePath("app:///NativeApps/Windows/bin/fmle/FMLECmd.exe");	
			
			//START--------------------------------------------------------------------------------
			//open the fmle start up file using the startUpFile object and open it in read mode
			//after that read the content in to a string and then typecast it to an XML Object
			//after that close the file stream.
			//END----------------------------------------------------------------------------------
			var appDir:String = File.applicationDirectory.nativePath;
			startUpFile=new File(appDir+"\\NativeApps\\Windows\\bin\\fmle\\startup.xml");
			fileStream.open(startUpFile, FileMode.READ);		
			xmlFileData=fileStream.readMultiByte(fileStream.bytesAvailable,"UTF-16");
			presetXML = XML(xmlFileData);
			fileStream.close();				
			//START--------------------------------------------------------------------------------
			//change the xml file contents with the new audio,video and stream settings from the
			//user selection.Once this is done  the modified contents where copied in to a new 
			//string with XML file header are added.
			//END----------------------------------------------------------------------------------
			presetXML.capture.video.device =AVParam.videoDeviceDrive.toString();
			presetXML.capture.video.size.width=AVParam.videoCaptureWidth.toString();
			presetXML.capture.video.size.height=AVParam.videoCaptureHeight.toString();
			presetXML.capture.video.crossbar_input="0";
			presetXML.capture.video.frame_rate ="15";//"25";
			presetXML.capture.audio.device =AVParam.audioDeviceDrive.toString();
			presetXML.capture.audio.crossbar_input="0";
			presetXML.capture.audio.sample_rate="22050";//"44100";
			presetXML.capture.audio.channels="1";
			presetXML.capture.audio.input_volume="75";
			//presetXML.encode.video.datarate =AVParam.videoBitRate.toString()+";"+"440"+";";
			//presetXML.encode.video.outputsize="320*240"+";"+"320*240"+";";
			////presetXML.encode.video.advanced.keyframe_frequency=AVParam.videoKeyFrameFrequency.toString();
			//presetXML.encode.audio.datarate =AVParam.audioBitRate.toString();
			presetXML.output.rtmp.url = srteamURL;	

			var datarate:int=(AVParam.bandwidth*8)/1024;
			presetXML.encode.video.datarate =datarate.toString()+";56;";
			presetXML.encode.video.format ="H.264";
			presetXML.encode.video.advanced.profile="Baseline";
			presetXML.encode.video.advanced.level="3.1";
			presetXML.encode.video.advanced.keyframe_frequency="5 Seconds";
			
			//presetXML.encode.video.outputsize=AVParam.videoCaptureWidth.toString()+"x"+AVParam.videoCaptureHeight.toString()+";320x240;";//"320x240"+";";
			/*if(AVParam.videoCaptureWidth<1280 && AVParam.videoCaptureHeight<720)
				presetXML.encode.video.outputsize=AVParam.videoCaptureWidth.toString()+"x"+AVParam.videoCaptureHeight.toString()+";320x180;";
			else
				presetXML.encode.video.outputsize="1280x720;320x180;";//768x432;*/
			if(datarate<256 || (AVParam.videoCaptureWidth<640 && AVParam.videoCaptureHeight<360))
				presetXML.encode.video.outputsize="320x180;320x180;";
				//presetXML.encode.video.outputsize=AVParam.videoCaptureWidth.toString()+"x"+AVParam.videoCaptureHeight.toString()+";320x180;";
			else
				presetXML.encode.video.outputsize="640x360;320x180;";//768x432;
			presetXML.encode.audio.datarate ="48";//"56";//AVParam.audioBitrate.toString();
			presetXML.output.rtmp.stream=streamName+";"+streamName+"_local;";

			//Alert.show(presetXML.toString());
			
			newXMLStr="<?xml version=\"1.0\" encoding=\"UTF-16\"?>"+"\n"+presetXML.toXMLString();
			
			//START--------------------------------------------------------------------------------
			//open the file in write mode and the add the contents with the latest changes from 
			//user selection. Close the stream after the write operation.
			//END----------------------------------------------------------------------------------
			fileStream1.open(startUpFile, FileMode.WRITE);
			fileStream1.writeMultiByte(newXMLStr,"UTF-16");
			fileStream1.close();			
			//START--------------------------------------------------------------------------------
			//pass the aruments needed for the FMLE command line process.
			//"/p" denotes profile and after that we pass the profile xml file.
			//"/d" denotes that use default values for tags in the XML file where no values are set
			//END----------------------------------------------------------------------------------
			processArgs.push( "/p" );
			processArgs.push(startUpFile.nativePath.toString());
			processArgs.push( "/d" );						
			//pass the file that has to be executed in to Native Process Class
			nativeProcessStartupInfo.executable = file;
			//pass the arguments the need to be used by the process to execute.
			nativeProcessStartupInfo.arguments=processArgs;		
			//Alert.show(processArgs.toString());
			//START--------------------------------------------------------------------------------
			//check fi the platform supports Native Process API. If true then let the prcess to
			//call the application that need to be executed. else through an error message
			//END----------------------------------------------------------------------------------
			if(NativeProcess.isSupported==true)
			{
				if(process.running==false)
					process.start(nativeProcessStartupInfo);
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo)
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.myVideo.playLocalVideoStream();
			}
			else
				Alert.show("not supported","FMLE Publisher");			
			
		}		
		public function startCapture():void
		{}
		
		public function stopCapture():void
		{}
		
		public  function killProcess():void
		{
			//Alert.show("pr"+process.length.toString());
			//for(var i:int=0;i<process.length;i++)
			{
				if(process.running==true)
				{
					process.exit(true);
				}
				//intt++;
			}
		}
	}
}
