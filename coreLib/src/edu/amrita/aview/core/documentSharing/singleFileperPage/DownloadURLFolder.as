package edu.amrita.aview.core.documentSharing.singleFileperPage
{
	import edu.amrita.aview.core.playback.components.DocComp;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class DownloadURLFolder
	{
		[Bindable]
		public var downloadInProgress:Boolean=false;
		[Bindable]
		public var downloadedCount:int=0;
		[Bindable]
		public var totalFileCount:int=0;
		[Bindable]
		private var fileList:Array=new Array();
		private var localCacheDirecotry:String=null;
		private var remoteFolderURL:String=null;
		private var fileListURL:String=null;
		private var downloadTimeOutNumber:uint=0;
		private var getFileList:HTTPService;
		public static var currentRoleStatus:int=1;
		private var isNewFile:Boolean=false;
		private var latestPreferredPage:Number;
		private var latestStartRange:Number;
		private var latestEndRange:Number;
		[Bindable]
		public var temPrevPage:Number;
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.edu.amrita.aview.core.documentsharing.singleFileperPage.DownloadURLFolder.as");
		
		public function DownloadURLFolder(fileListURL:String, remoteFolderURL:String, localDirectory:String, preferred:Number, totalNoOfFiles:Number){
			trace("Make Presenter1");
			this.fileListURL=fileListURL;
			this.remoteFolderURL=remoteFolderURL;
			applicationType::DesktopMobile{
				this.localCacheDirecotry=localDirectory;
			}
			applicationType::web{
				this.localCacheDirecotry = remoteFolderURL;
			}
			latestPreferredPage=preferred;
			isNewFile=true;
			reset();
			if (totalNoOfFiles == 0){
				if (Log.isDebug()) log.debug("Request giving to download....");
				getFileList=new HTTPService();
				getFileList.addEventListener(FaultEvent.FAULT, faultHandler);
				getFileList.addEventListener(ResultEvent.RESULT, getFileListHandler);
				getFileList.url=this.fileListURL;
				getFileList.send();
			}
			else{
				message="able to open";
				getFileNameObjects(totalNoOfFiles);
				if (Log.isDebug()) log.debug("Request comming from Presenter Side....The total Number of pages are" + totalNoOfFiles);
			}
		}
		
		public function getFileNameObjects(totalNoOfFiles:Number):void{
			//trace("Make Presenter1");
			if (Log.isDebug()) log.debug("In getFileNAmeObjects...The total number of file which we are going to download is" + totalNoOfFiles);
			for (var i:int=1; i <= totalNoOfFiles; i++)	{
				var fileNameObject:DownloadFile=new DownloadFile();
				fileNameObject.fileName="page_" + i + ".swf";
				fileNameObject.pageNum=getPageNumber(fileNameObject.fileName);
				fileNameObject.downlodStatus=DownloadStatus.NOT_STARTED;
				fileList.push(fileNameObject);
			}
			totalFileCount=fileList.length;
			download(latestPreferredPage - 2, latestPreferredPage + 2, latestPreferredPage)
		}
		
		public function download(startRange:Number, endRange:Number, preferedPage:Number):void
		{
		
			trace("download called");
			temPrevPage=preferedPage;
			downloadInProgress=true;
			isRequestSend=false;
			if (fileList.length == 0)
				return;
			if (startRange < 1) startRange=1;
			if (endRange > fileList.length) endRange=fileList.length
			latestPreferredPage=preferedPage;
			latestStartRange=startRange;
			latestEndRange=endRange;
			for (var i:Number=startRange - 1; i < endRange; i++){
				//|| fileList[i].downlodStatus == DownloadStatus.FAILED
				var downloadFile:DownloadFile=DownloadFile(fileList[i]|| fileList[i].downlodStatus == DownloadStatus.FAILED);
				if (fileList[i].downlodStatus == DownloadStatus.NOT_STARTED ){
					var fileURL:String=this.remoteFolderURL + downloadFile.fileName;
					if (Log.isDebug()) log.debug("In Download....:Remote Path of" + i + 1 + "th Page is :" + fileURL);
					var loadFile:URLLoader=new URLLoader();
					loadFile.dataFormat=URLLoaderDataFormat.BINARY;
					loadFile.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
					loadFile.addEventListener("complete", downloadFileHandler);
					loadFile.load(new URLRequest(fileURL));
					downloadFile.downlodStatus=DownloadStatus.STARTED;
					downloadFile.urlLoader=loadFile;
				}
			}
			downloadTimeOutNumber=setInterval(updateDownloadStatus, 100, message);
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.isPresnter=false;
			
		}
			
		
		private function IOErrorHandler(event:IOErrorEvent):void{
			if (Log.isDebug()) log.debug("In IOError....:This Page downloading is Failed");
			applicationType::DesktopWeb{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.isDownloadDisturbed=true;
			}
			applicationType::mobile{
				FlexGlobals.topLevelApplication.docComp.isDownloadDisturbed=true;
			}
			var fileNameObject:DownloadFile=getFileNameObject(URLLoader(event.currentTarget));
			fileNameObject.downlodStatus=DownloadStatus.FAILED;
		
		}
		private var isRequestSend:Boolean=false;
		
		private function updateDownloadStatus(message:String):void{
			if (message == "able to open")	{
				var dowloaded:int=fileList.length;
				for (var i:int=latestStartRange - 1; i < latestEndRange; i++){
					
					var downloadFile:DownloadFile=DownloadFile(fileList[i]);
					if (fileList[latestPreferredPage - 1].downlodStatus == DownloadStatus.COMPLETED && !isRequestSend){
						if (Log.isDebug()) log.debug("The Preffered page is number:" + latestPreferredPage + ", Name:" + fileList[latestPreferredPage - 1].fileName);
						applicationType::DesktopWeb{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.showSFPDocument(localCacheDirecotry, message, latestStartRange, latestEndRange, latestPreferredPage, dowloaded, isNewFile, true);
						}
						applicationType::mobile{
							FlexGlobals.topLevelApplication.docComp.showSFPDocument(localCacheDirecotry, message, latestStartRange, latestEndRange, latestPreferredPage, dowloaded, isNewFile, true);
						}
						isRequestSend=true;
						isNewFile=false
						clearTimeout(downloadTimeOutNumber);
					}
					
					if (downloadFile.downlodStatus != DownloadStatus.COMPLETED){
						dowloaded=i;
						break;
					}
				}
			}
			else if (message == "Unable to open"){
				applicationType::DesktopWeb{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.showSFPDocument(localCacheDirecotry, message, latestStartRange, latestEndRange, latestPreferredPage, dowloaded, isNewFile, false);
				}
				applicationType::mobile{
					FlexGlobals.topLevelApplication.docComp.showSFPDocument(localCacheDirecotry, message, latestStartRange, latestEndRange, latestPreferredPage, dowloaded, isNewFile, false);
				}
			}
		
		}
		import mx.rpc.events.ResultEvent;
		
		private function reset():void{
			fileList.splice(0);
			downloadedCount=0;
			totalFileCount=0;
		}
		private var message:String="";
		private function getFileListHandler(event:ResultEvent):void	{
			if(Log.isInfo()) log.info(event.currentTarget.url);
			if (event.result == "Unable to open"){
				message="Unable to open"
				updateDownloadStatus(message);
			}
			else{
				message="able to open"
				var fileListXML:XML=new XML(event.message.body.toString());
				var fileXMLCollection:Array=fileListXML.children().children().toXMLString().split("\n");
				getFileNameObjects(fileXMLCollection.length)
			}
		}
		
		private function getPageNumber(fileName:String):int	{
			var pageNum:int=0;
			var startIdx:int=0;
			var endIdx:int=0;
			startIdx=fileName.lastIndexOf("_");
			if (startIdx != -1)
				endIdx=fileName.indexOf(".", startIdx);
			if (startIdx != -1 && endIdx != -1)
				pageNum=int(fileName.substring(startIdx + 1, endIdx));
			return pageNum;
		}
		private function getFileNameObject(urlLoader:URLLoader):DownloadFile{
			var fileNameObject:DownloadFile=null;
			for (var i:int=0; i < totalFileCount; i++){
				var downloadFile:DownloadFile=DownloadFile(fileList[i]);
				if (downloadFile.urlLoader == urlLoader){
					fileNameObject=fileList[i];
					break;
				}
			}
			return fileNameObject;
		}
		
		private function downloadFileHandler(event:Event):void{
			var fileNameObject:DownloadFile=getFileNameObject(URLLoader(event.currentTarget));
			applicationType::DesktopMobile{
				import flash.filesystem.File;
				import flash.filesystem.FileMode;
				import flash.filesystem.FileStream;
				
				var fs:FileStream=new FileStream();
				fs.open(new File(localCacheDirecotry + fileNameObject.fileName), FileMode.WRITE);
				fs.writeBytes(event.currentTarget.data);
				fs.close();
			}
			fileNameObject.downlodStatus=DownloadStatus.COMPLETED;
			applicationType::DesktopWeb{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.isDownloadDisturbed=false;
			}
			applicationType::mobile{
				FlexGlobals.topLevelApplication.docComp.isDownloadDisturbed=false;
			}
			if (Log.isDebug()) log.debug("Local Downloading: Download is COMPLETED.... " + localCacheDirecotry + fileNameObject.fileName);
		}
		
		private function faultHandler(event:FaultEvent):void
		{
			applicationType::DesktopWeb{
				if (Log.isError()) log.error("DocumentSharing::singleFileperPage::DownloadURLFolder::faultHandler:"+ AbstractHelper.getStaticFaultMessage(event));
			}
		}
	
	}
}
