package edu.amrita.aview.core.logfilecheck	
{
	
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.text.ReturnKeyLabel;
	import flash.utils.Timer;
	import flash.utils.setInterval;
	
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class LogFileRandomCheck
	{
		public static var logFileMyTimer:Timer;
		private var log:ILogger=Log.getLogger("aview.main.PrepareLogin");
		
		public function initFileRandomCheck():void{
			startLogFileRandomChecker();
			startCheckInTimer();	
		}
		
		//Method For Delete Older Log File in the aview starting process.
		public function startLogFileRandomChecker():void
		{
			var fmt:DateFormatter = new DateFormatter();
			fmt.formatString = "DD-MM-YYYY";
			var dateString:String=fmt.format(new Date());
			var parentFolder:File = File.userDirectory.resolvePath(File.userDirectory.nativePath+"\\AppData\\Roaming\\A-VIEW\\Local Store\\Logs");
			if(parentFolder.exists) 
			{
				var parentFolderSize:Number =GetFolderSize(parentFolder.getDirectoryListing());
				if(parentFolderSize>4){
					var getChildfilesArray:Array =parentFolder.getDirectoryListing();
					bubbleSortInAscendingOrder(getChildfilesArray);
					for (var i:int = 0; i < getChildfilesArray.length; i++) { 
						var name:String=getChildfilesArray[i].nativePath;
						if(name.indexOf(dateString) <= 0){
							new File(name).deleteFile();
							parentFolderSize=GetFolderSize(parentFolder.getDirectoryListing());
							if(parentFolderSize<4){
								break;
							}
						}
					}	
				}
			}
		}
	
		public function startCheckInTimer():void {
			logFileMyTimer = new Timer(1888000);
			logFileMyTimer.addEventListener(TimerEvent.TIMER,logFileRandomCheckerInTimer);
			logFileMyTimer.start();
		}
		
		//Method For Delete Older Log File in log Folder on Timer with 30 mnt.
		
		public function logFileRandomCheckerInTimer(e:TimerEvent):void
		{
			var fmt:DateFormatter = new DateFormatter();
			fmt.formatString = "DD-MM-YYYY";
			var dateString:String=fmt.format(new Date());
			var parentFolder:File = File.userDirectory.resolvePath(File.userDirectory.nativePath+"\\AppData\\Roaming\\A-VIEW\\Local Store\\Logs");
			if(parentFolder.exists) 
			{
				var parentFolderSize:Number =GetFolderSize(parentFolder.getDirectoryListing());
				if(parentFolderSize>4){
					var getChildfilesArray:Array =parentFolder.getDirectoryListing();
					bubbleSortInAscendingOrder(getChildfilesArray);
					for (var i:int = 0; i < getChildfilesArray.length; i++) { 
						var name:String=getChildfilesArray[i].nativePath;
						if(name.indexOf(dateString) <= 0){
							new File(name).deleteFile();
							 parentFolderSize=GetFolderSize(parentFolder.getDirectoryListing());
							if(parentFolderSize<4){
								break;
							}
						}
					}	
				}
			}
		}
		
		//Method For Checking logfile folder size
		
		public function GetFolderSize(Source:Array):Number
		{
			var TotalSizeInteger:Number = new Number();
			for(var i:int = 0;i<Source.length;i++){
				if(Source[i].isDirectory){
					TotalSizeInteger +=   this.GetFolderSize(Source[i].getDirectoryListing());
				}
				else{
					TotalSizeInteger += Source[i].size;
				}
			}
			return TotalSizeInteger /1073741824;
		}
		
		// This method sorts the LogFile Name  array in asecnding order Based on File Modified Date
		
		public  function bubbleSortInAscendingOrder(getChildfilesArray:Array):void {
			var temp:File ;
			for (var i:int = 0; i < getChildfilesArray.length; i++) {
				for (var j:int = 1; j < ( getChildfilesArray.length - i); j++) {	
					
					if (getChildfilesArray[j-1].modificationDate > getChildfilesArray [j].modificationDate){
						temp = getChildfilesArray[j - 1];
						getChildfilesArray[j - 1] = getChildfilesArray[j];
						getChildfilesArray[j] = temp;
					}
				}
			}
		}	
	}
}