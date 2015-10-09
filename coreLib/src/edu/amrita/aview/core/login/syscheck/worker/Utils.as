package edu.amrita.aview.core.login.syscheck.worker
{	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	
	public class Utils
	{
		private var process:NativeProcess;

		public function Utils()
		{
		}

		public function findOSType():String{
			return "win"; 
		}
		public function killAllAviewRelated():void{
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
			}
			
			return;
			
		}
	}
}