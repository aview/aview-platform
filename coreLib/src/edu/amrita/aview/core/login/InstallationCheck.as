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
 * File			: InstallationCheck.as
 * Module		: Third party installation checking
 * Developer(s)	: Ajith Kumar R,Luis
 * Reviewer(s)	: Monisha,Remya T
 * 
 * InstallationCheck.as is used to check the installation & version of
 * third party applications (JRE,Screencamera) associated with A-VIEW.
 *
 */

// Platform specific check
applicationType::desktop
{
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.clearTimeout;
	
	import mx.controls.Alert;
	import mx.core.IUITextField;
	import mx.events.CloseEvent;
	import mx.utils.StringUtil;
	
	/**
	 * NativeProcess variable for handling external process to find JRE installation.
	 */
	private var javaInstallationCheckProcess:NativeProcess;
	/**
	 * Array for storing missing thirdparty software details.
	 */
	private var missingInstallers:Array=new Array();
	/**
	 * NativeProcess variable for handling external process to read thirdparty software details from windows registry.
	 */
	private var thirdPartySoftwareDetailsProcess:NativeProcess;
	/**
	 * NativeApplicationUpdater variable for handling automatic Screencamera updation.
	 */
	private var screenCameraUpdater:NativeApplicationUpdater;
	/**
	 * Variable for keeping the operating system name.
	 */
	public var operatingSystemName:String=Capabilities.os.toLowerCase();
	/**
	 * Array for storing thirdparty software details read from windows registry.
	 */
	public var thirdPartySoftwareDetails:Array=new Array();
	
	/**
	 * @private
	 * The function for finding whether JRE is installed or not.
	 *
	 *
	 * @return void
	 */
	private function findJavaInstallationPath():void 
	{
		var java:File;
		if (operatingSystemName.indexOf('win') > -1) 
		{
			var directoryListing : Array = File.getRootDirectories();
			var isJavaInstalled:Boolean=false;
			for (var i:uint = 0; i < directoryListing.length; i++) 
			{
				// AKCR: Here we should be checking for the JAVA_HOME variable. The following
				// AKCR: code breaks in the scenario in which a user already has a JAVA installation
				// AKCR: and he skips java-install as a part of a-view install
				//For 32 bit OS
				java = new File(directoryListing[i].name +'/windows/system32/javaw.exe');
				if (!java.exists) 
				{
					//For 64 bit OS
					java = new File(directoryListing[i].name +'/windows/syswow64/javaw.exe');
				}
				if (java.exists) 
				{
					isJavaInstalled=true;
					break;
				}
			}
			
			if (!isJavaInstalled) 
			{
				missingInstallers.push("Java Runtime Environment");
			}
		} 
		else 
		{
			java = new File('/usr/bin/java');
			if (!java.exists) 
			{
				java = new File(operatingSystemName.indexOf('mac') > -1 ? '/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java' : '/etc/alternatives/java');
			}
		}
		
		if (!java.exists)
		{
			//For Linus & MAC
			if (operatingSystemName.indexOf('win') < 0) 
			{
				var args:Vector.<String> = new Vector.<String>;
				args.push('java');
				findJavaInstallationNative(new File('/usr/bin/whereis'), args);
			}
		}
	}
	/**
	 * @private
	 * The function for finding whether JRE is installed or not in Linux & MAC operating systems.
	 *
	 * @param file of type File.
	 * @param args of type Vector.
	 * @return void
	 */
	private function findJavaInstallationNative(file:File, args:Vector.<String> = null):void 
	{
		var findJavaInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		findJavaInfo.executable = file;
		findJavaInfo.workingDirectory = File.applicationDirectory;
		findJavaInfo.arguments = args;
		
		javaInstallationCheckProcess = new NativeProcess();
		javaInstallationCheckProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, findJavaInstallationNativeOutputHandler);
		javaInstallationCheckProcess.start(findJavaInfo);
	}
	/**
	 * @private
	 * This function is the STANDARD_OUTPUT_DATA handler for findJavaProcess NativeProcess.
	 *
	 * @param event of type ProgressEvent.
	 * @return void
	 */
	private function findJavaInstallationNativeOutputHandler(event:ProgressEvent):void 
	{
		var java:File = new File(StringUtil.trim(javaInstallationCheckProcess.standardOutput.readUTFBytes(javaInstallationCheckProcess.standardOutput.bytesAvailable)));
		if (operatingSystemName.indexOf('win') > -1) 
		{
			java = java.resolvePath('bin').resolvePath('javaw.exe');
		}
		if (javaInstallationCheckProcess.running) 
		{
			javaInstallationCheckProcess.exit();
		}
		javaInstallationCheckProcess = null;
		
		if (!java.exists) 
		{
			missingInstallers.push("Java Runtime Environment");
		}
	}
	/**
	 * @public
	 * The function for finding whether ScreenCamera is installed or not in Windows operating systems.
	 *
	 *
	 * @return void
	 */
	public function findScreenCameraInstallationPath():void 
	{
		var scrCam:File;
		if (operatingSystemName.indexOf('win') > -1 && thirdPartySoftwareDetails.length > 0) 
		{
			if(thirdPartySoftwareDetails[1]!="NF")
			{
				var replacePattern:RegExp = /\\/g;  
				thirdPartySoftwareDetails[1].replace(replacePattern, "/");
				scrCam = new File(thirdPartySoftwareDetails[1]+'/ScrCam.exe');
				
				if (!scrCam.exists)
				{
					//Parameters of the alert in order: message text,tile,type of button(eg: 3=YES&NO),parent component,close handler function.
					Alert.show("Please install ScreenCamera and relogin to the application to start your video." +
						"Click 'Yes' to download and install Screencamera.", "WARNING",3,this,downloadScreenCameraHandler);
					
				}
				else
				{
					// ashwini todo: this is another area where there could be a failure. Why do we need to populate the 
					// mainContainerComp??
					mainContainerComp.classroomComp.writeScreenCamFile(thirdPartySoftwareDetails[1]);
				}
			}
			else
			{
				Alert.show("Please install ScreenCamera and relogin to the application to start your video." +
					"Click 'Yes' to download and install Screencamera.", "WARNING",3,this,downloadScreenCameraHandler);
				
			}			
		}
	}
	/**
	 * @private
	 * The function for showing error message if the third party appliactions (JRE,Screencamera) are not installed properly.
	 *
	 *
	 * @return void
	 */
	private function checkInstallation():void 
	{
		clearTimeout(checkInstallationTimeoutId);
		var htmlBody:String = "Some of the components are missing,<br>please reinstall A-VIEW full package." ;
		var alert:Alert;
		if(missingInstallers.length>0)
		{
			alert = Alert.show(htmlBody,"A-VIEW",Alert.OK,null,closeAVIEW);
			use namespace mx.core.mx_internal;
			IUITextField(alert.alertForm.textField).htmlText = htmlBody;
		}
		else
		{
			var lowerVersionInstallers:Array=new Array();
			if(parseFloat(thirdPartySoftwareDetails[0])<1.6)
			{
				lowerVersionInstallers.push("JRE (1.6 or above)");
			}
			if(lowerVersionInstallers.length>0)
			{
				alert = Alert.show(htmlBody,"A-VIEW",Alert.OK,null,closeAVIEW);
				use namespace mx.core.mx_internal;
				IUITextField(alert.alertForm.textField).htmlText = htmlBody;
			}
		}
	}
	/**
	 * @private
	 * The function for closing A-VIEW application if the third party appliactions (JRE,Screencamera) are not installed properly.
	 *
	 * @param event of type Event
	 * @return void
	 */
	private function closeAVIEW(event:Event):void
	{
		this.windowApp.nativeApplication.exit();
	}
	/**
	 * @private
	 * The function for terminating all external processes associated with A-VIEW.
	 *
	 *
	 * @return void
	 */
	//PNCR: function name is not clear
	private function killAkr() : void
	{
		if (Capabilities.os.toLowerCase().indexOf("win") > -1)
		{
			var file:File = File.applicationDirectory;
			//PNCR: API. changed path to NativeApps
			//file = File.applicationDirectory.resolvePath("edu/amrita/aview/core/video/native/Windows/bin/taskkill.exe");
			file = File.applicationDirectory.resolvePath("NativeApps/Windows/bin/taskkill.exe");
			
			var nativeProcessStartupInfo:NativeProcessStartupInfo;
			if (File.userDirectory.resolvePath("JSCUI5LibRhino.pid").exists) 
			{
				var myFile:File = File.userDirectory.resolvePath("JSCUI5LibRhino.pid");
				var myFileStream:FileStream = new FileStream();
				myFileStream.open(myFile, FileMode.READ);
				myFileStream.position = 0;
				//Read the file and put it in results string. 
				var s:String = myFileStream.readUTFBytes(myFileStream.bytesAvailable);
				myFileStream.close();
				var myArrayOfLines:Array = s.split(/\n/);
				
				for each (var i:String in myArrayOfLines) 
				{
					nativeProcessStartupInfo = new NativeProcessStartupInfo();
					nativeProcessStartupInfo.executable = file;
					process = new NativeProcess();
					nativeProcessStartupInfo.arguments.push("/F", "/PID", i);
					process.start(nativeProcessStartupInfo);
				}
				var pidfile:File = File.userDirectory.resolvePath("JSCUI5LibRhino.pid");
				pidfile.deleteFile();
			}
			//PNCR: repeated code using below and inside loop. Create a function with arguments.
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = file;
			process = new NativeProcess();
			nativeProcessStartupInfo.arguments.push("/F", "/IM", "callSC.exe*");
			process.start(nativeProcessStartupInfo);
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = file;
			process = new NativeProcess();
			nativeProcessStartupInfo.arguments.push("/F", "/IM", "ScrCam.exe*");
			process.start(nativeProcessStartupInfo);
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = file;
			process = new NativeProcess();
			nativeProcessStartupInfo.arguments.push("/F", "/IM", "akr.exe*");
			process.start(nativeProcessStartupInfo);
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = file;
			process = new NativeProcess();
			nativeProcessStartupInfo.arguments.push("/F", "/IM", "MulitBitRateStreamer.exe*");
			process.start(nativeProcessStartupInfo);
		}
		
		return;
	}
	/**
	 * @public
	 * The function for reading third party software (JRE,Screencamera) details from windows registry.
	 *
	 *
	 * @return void
	 */
	public function getThirdPartySoftwareDetails():void
	{	 
		//PNCR: API. changed native path to main application.
		var file:File = File.applicationDirectory; //File("D:/Workspace/AviewAPI/core/src/"); // 
		file = file.resolvePath("NativeApps");
		file = file.resolvePath("Windows/bin/thirdPartySoftwareDetails.exe");
		
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		nativeProcessStartupInfo.executable = file;
		
		thirdPartySoftwareDetailsProcess = new NativeProcess();
		thirdPartySoftwareDetailsProcess.start(nativeProcessStartupInfo);
		thirdPartySoftwareDetailsProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, thirdPartySoftwareDetailsProcessOutputDataHandler);
	}
	/**
	 * @public
	 * This function is the STANDARD_OUTPUT_DATA handler for processThirdPartySoftwareDetails NativeProcess.
	 *
	 * @param event of type ProgressEvent.
	 * @return void
	 */
	public function thirdPartySoftwareDetailsProcessOutputDataHandler(event:ProgressEvent):void
	{
		var result:String=thirdPartySoftwareDetailsProcess.standardOutput.readUTFBytes(thirdPartySoftwareDetailsProcess.standardOutput.bytesAvailable);
		thirdPartySoftwareDetails = result.split( ',' );
	}
	
	/**
	 * @private
	 * This function is for initializing automatic updater for ScreenCamera.
	 *
	 * @param event of type CloseEvent.
	 * @return void
	 */
	private function downloadScreenCameraHandler(event:CloseEvent):void
	{
		if(event.detail==Alert.YES)
		{
			screenCameraUpdater=new NativeApplicationUpdater();
			screenCameraUpdater.isNewerVersionFunction=isLatestVersionInstalled;
			screenCameraUpdater.addEventListener(UpdateEvent.INITIALIZED,screenCameraUpdaterInitializedHandler);
			screenCameraUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS,screenCameraUpdaterUpdateStatusHandler);
			//PNCR: protocol constant to be moved to some global file  
			screenCameraUpdater.updateURL="http://" + ClassroomContext.UPDATE_SERVER + "/SCREENCAMERA/update.xml";
			screenCameraUpdater.initialize();
		}
	}
	/**
	 * @protected
	 * This function is the INITIALIZED event handler for screenCameraUpdater.
	 *
	 * @param event of type UpdateEvent.
	 * @return void
	 */
	protected function screenCameraUpdaterInitializedHandler(event:UpdateEvent):void
	{
		// When NativeApplicationUpdater is initialized you can call checkNow function	
		screenCameraUpdater.checkNow();
	}
	/**
	 * @protected 
	 * This function is the UPDATE_STATUS event handler for screenCameraUpdater.
	 *
	 * @param event of type StatusUpdateEvent.
	 * @return void
	 */
	protected function screenCameraUpdaterUpdateStatusHandler(event:StatusUpdateEvent):void
	{
		startScreenCameraUpdate();
		event.preventDefault();
	}
	/**
	 * @protected
	 * This function is for passing the silent install commands to the screenCameraUpdater & initiate download process.
	 *
	 *
	 * @return void
	 */
	protected function startScreenCameraUpdate():void
	{
		showDownladInProgressMessage("ScreenCamera");
		screenCameraUpdater.commandLineArguments=new Vector.<String>();
		screenCameraUpdater.commandLineArguments.push("/SILENT");
		screenCameraUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, screenCameraUpdaterDownloadErrorHandler);
		screenCameraUpdater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, screenCameraUpdaterDownloadCompleteHandler);
		screenCameraUpdater.downloadUpdate();
	}
	/**
	 * @private
	 * This function is the DOWNLOAD_COMPLETE event handler for screenCameraUpdater.
	 *
	 * @param event of type UpdateEvent.
	 * @return void
	 */
	private function screenCameraUpdaterDownloadCompleteHandler(event:UpdateEvent):void
	{
		// When update is downloaded install it.
		screenCameraUpdater.installUpdate("/SILENT","/SLNAME='Amrita E-Learning Initiatives'","/SLKEY='AMRITA-E-LEARNING-8B1A4759-4158-4998-9B48-0B24068C2981'"+"");
	}
	/**
	 * @private
	 * This function is the DOWNLOAD_ERROR event handler for screenCameraUpdater.
	 *
	 * @param event of type DownloadErrorEvent.
	 * @return void
	 */
	private function screenCameraUpdaterDownloadErrorHandler(event:DownloadErrorEvent):void
	{
		Alert.show("Error downloading update file, try again later.","ScreenCamera Update");
	}
}