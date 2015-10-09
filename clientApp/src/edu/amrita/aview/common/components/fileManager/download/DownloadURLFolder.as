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
 * File			: DownloadURLFolder.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 * DownloadURLFolder class to represent an file downloading from server to local
 *
 *
 */
package edu.amrita.aview.common.components.fileManager.download
{
	
	import edu.amrita.aview.common.helper.AbstractHelper;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	/**
	 *  You use the DownloadURLFolder class to represent an file downloading from server to local.
	 *  DownloadURLFolder object in ActionScript. When you call the FileDownloader object's
	 *  in constructor method, it will Make http service request for download process.
	 *
	 */
	public class DownloadURLFolder
	{
		// AKCR: please remove the unwanted comment blocks 
		/**
		 * For checking whether the downloading in progress or not
		 * @deafult false means downloading not started
		 */		
		[Bindable]
		public var downloadInProgress:Boolean=false;
		/**
		 * The download count of files.
		 */		
		[Bindable]
		public var downloadedCount:int=0;
		/**
		 * The total file which are need to download
		 */		
		[Bindable]
		public var totalFileCount:int=0;
		/**
		 *The file names in Folder 
		 */		
		[Bindable]
		public var filesInFolder:String="";
		/**
		 * module name which is currently using this class
		 */		
		private var usingModule:String;
		/**
		 *The collection of files
		 */		
		private var fileList:Array=new Array();
		/**
		 * The local direcotry path for downloading
		 */		
		private var localCacheDirecotry:String=null;
		/**
		 * The Remote server path of download file 
		 */		
		private var remoteFolderURL:String=null;
		/**
		 * Remote Url of files
		 */		
		private var fileListURL:String=null;
		/**
		 * Timer for status updation for downloading process
		 */		
		private var downloadTimeOutNumber:uint=0;
		/**
		 * Object of HttpService
		 */		
		private var getFileList:HTTPService;
		/**
		 * Object of DownloadFile
		 */		
		private var fileNameObject:DownloadFile;
		/**
		 * 
		 */		
		public var downloadFile:DownloadFile;
		/**
		 *File extension
		 */		
		private var fileExtension:String;
		/**
		 * File name
		 */		
		public var fileName:String;
		/**
		 * Object of ILoger class
		 */		
		public var logger:ILogger=Log.getLogger("aview.modules.2D3Ddownload");
		/**
		 * Store the value which is number of bytes downloded
		 */		
		private var bytesLoaded:Number;
		/**
		 * Total number of bytes to be download
		 */		
		private var bytesTotal:Number;
		/**
		 * Number of bytes downloade to localy
		 */		
		private var localfileTotal:Number;
		/**
		 * Wheather to check the dwonload progress is restarted or not
		 * @default is false means not restarted
		 */		
		private var restartDownload:Boolean=false;
		/**
		 * For checking the index of file name 
		 */		
		private var fileToCheck:String;
		
		/**Platform specific imports and variables*/
		applicationType::DesktopMobile
		{
			import flash.filesystem.File;
			import flash.filesystem.FileMode;
			import flash.filesystem.FileStream;
			
			/**
			 * Local storage directory for files
			 */
			private var localFolder:File=File.applicationStorageDirectory;
			/**
			 * Object of FileStream
			 */			
			private var fileStream:FileStream;
			/**
			 * Object of File
			 */			
			private var fileCheck:File;
			/**
			 * Object of File
			 */			
			private var tempFile:File;
			/**
			 * Object of File
			 */			
			private var deleteFile:File;
		}
		
		/**
		 * @public 
		 * Constructoe
		 * @param fileListURL of type String
		 * @param remoteFolderURL of type String
		 * @param localDirectory of type String
		 * @param usingModule of type String
		 * 
		 */
		public function DownloadURLFolder(fileListURL:String, remoteFolderURL:String, localDirectory:String, usingModule:String)
		{
			this.fileListURL=fileListURL;
			this.remoteFolderURL=remoteFolderURL;
			this.localCacheDirecotry=localDirectory;
			this.usingModule=usingModule;
			httpServiceRequest();
		}
		
		/**
		 * @private
		 * Create the bridge of client and server for download process.
		 * 
		 * 
		 */
		private function httpServiceRequest():void
		{
			if (Log.isInfo()) logger.info("HttpService for accessing remote folder starting");
			getFileList=new HTTPService();
			getFileList.addEventListener(FaultEvent.FAULT, faultHandler);
			getFileList.addEventListener(ResultEvent.RESULT, getFileListHandler);
			getFileList.url=encodeURI(fileListURL);
			reset();
			downloadInProgress=true;
			getFileList.send();
		}
		
		/**
		 * @private
		 * reseting all the data for download
		 * 
		 * 
		 */
		private function reset():void
		{
			filesInFolder="";
			fileList.splice(0);
			downloadedCount=0;
			totalFileCount=0;
		}
		
		/**
		 * @private 
		 * Get the file lists to be download from server
		 * @param event of type ResultEvent
		 * 
		 */
		private function getFileListHandler(event:ResultEvent):void
		{
			var fileListXML:XML=new XML(event.message.body.toString());
			var fileXMLCollection:Array=fileListXML.children().children().toXMLString().split("\n");
			applicationType::DesktopMobile
			{
				tempFile=localFolder.resolvePath(localCacheDirecotry);
				if (!tempFile.exists)
				{
					tempFile.createDirectory();
				}
			}
			for (var i:int=0; i < fileXMLCollection.length; i++)
			{
				fileNameObject=new DownloadFile();
				fileNameObject.fileName=fileXMLCollection[i];
				fileNameObject.pageNum=getPageNumber(fileNameObject.fileName);
				fileNameObject.downlodStatus=DownloadStatus.NOT_STARTED;
				fileList.push(fileNameObject);
			}
			fileList.sortOn("fileName", Array.UNIQUESORT);
			for (i=0; i < fileList.length; i++)
			{
				fileExtension=fileList[i].fileName;
				fileExtension=fileExtension.substr(fileExtension.lastIndexOf(".") + 1, fileExtension.length);
				// AKCR: please move hard-coded string to a constant, external to this file
				if (fileExtension == "dae")
				{
					fileNameObject=new DownloadFile();
					fileNameObject.fileName=fileList[i].fileName;
					fileNameObject.pageNum=fileList[i].pageNum;
					fileNameObject.downlodStatus=DownloadStatus.NOT_STARTED;
					fileList.splice(i, 1);
					fileList.push(fileNameObject);
				}
			}
			totalFileCount=fileList.length;
			
			filesInFolder+="";
			for (i=0; i < fileList.length; i++)
			{
				downloadFile=DownloadFile(fileList[i]);
				if (i == 0)
				{
					filesInFolder+=downloadFile.fileName;
				}
				else
				{
					filesInFolder+="\n" + downloadFile.fileName;
				}
				var fileURL:String=this.remoteFolderURL + downloadFile.fileName;
				var fileExist:Boolean=false;
				applicationType::DesktopWeb{
					import edu.amrita.aview.common.components.fileManager.FileManager;
					if (usingModule == FileManager.MODULE_3D_SHARING)
					{
						fileExtension=downloadFile.fileName;
						fileExtension=fileExtension.substr(fileExtension.lastIndexOf(".") + 1, fileExtension.length);
						if (fileExtension == "dae" || fileExtension == "f3d")
						{
							fileName=downloadFile.fileName;
							applicationType::web
							{
								/**To pass remote folder path to viewer3Dswc file.*/
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.loadObjectsToTheScene(this.remoteFolderURL + "/" + fileName);
							}
						}
						applicationType::desktop
						{
							fileCheck=new File(localCacheDirecotry + "/" + downloadFile.fileName);
							if (!fileCheck.exists || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isUploadComplete || localfileTotal != bytesTotal && restartDownload)
							{
								fileExist=false;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isUploadComplete=false;
							}
							else
							{
								fileExist=true;
							}
						}
					}
					if (usingModule == FileManager.MODULE_2D_SHARING)
					{
						applicationType::desktop
						{
							var fileCheck2d:File;
							fileCheck2d=new File(localCacheDirecotry + "/" + downloadFile.fileName);
							if (!fileCheck2d.exists || localfileTotal != bytesTotal && restartDownload)
							{
								fileExist=false;
							}
							else
							{
								fileExist=true;
								restartDownload=false;
								if (Log.isInfo())							{
									logger.info("2DViewer Download Completed and loading called(File exist)");
								}
								var downDetails:Object=new Object;
								downDetails.localpath=fileCheck2d.nativePath;
								downDetails.filename=downloadFile.fileName;
								downDetails.downloadpath=remoteFolderURL.slice(remoteFolderURL.indexOf("/AVContent"), -1);
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer2DComp.downloadCompleated(fileCheck2d.nativePath, downloadFile.fileName, remoteFolderURL.slice(remoteFolderURL.indexOf("/AVContent"), -1));
							}
						}
						/**For web version localCacheDirecotry is always null.
						 * if it is null, passes localpath, filename and downloadpath.
						 */
						applicationType::web
						{
							if (localCacheDirecotry != null)
							{
								fileExist=false;
							}
							else
							{
								fileExist=true;
								restartDownload=false;
								if (Log.isInfo())							{
									logger.info("2DViewer Download Completed and loading called(File exist)");
								}
								var downDetails:Object=new Object;
								/**Assign remote folder path as localpath.*/
								downDetails.localpath=remoteFolderURL + downloadFile.fileName;
								downDetails.filename=downloadFile.fileName;
								downDetails.downloadpath=remoteFolderURL.slice(remoteFolderURL.indexOf("/AVContent"), -1);
								/**Pass first parameter as downloded 2D file remote path.*/
								//Fix for issue #17075 
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer2DComp.downloadCompleated(downDetails.localpath, downloadFile.fileName, remoteFolderURL.slice(remoteFolderURL.indexOf("/AVContent"), -1));
							}
						}
					}
				}
				applicationType::mobile{
					import edu.amrita.aview.core.shared.components.fileManager.MobileFileManager;
					if (usingModule == MobileFileManager.MODULE_3D_SHARING)
					{
						fileExtension=downloadFile.fileName;
						fileExtension=fileExtension.substr(fileExtension.lastIndexOf(".") + 1, fileExtension.length);
						if (fileExtension == "dae" || fileExtension == "f3d")
						{
							fileName=downloadFile.fileName;
						}
						fileCheck=new File(localCacheDirecotry + "/" + downloadFile.fileName);
						if (!fileCheck.exists || FlexGlobals.topLevelApplication.viewer3DComp.isUploadComplete || localfileTotal != bytesTotal && restartDownload)
						{
							fileExist=false;
							FlexGlobals.topLevelApplication.viewer3DComp.isUploadComplete=false;
						}
						else
						{
							fileExist=true;
						}
					}
				}
				applicationType::web
				{
					/**For web version localCacheDirecotry is always null */
					if (localCacheDirecotry != null)
					{
						loadFileHandler(fileURL);
					}
				}
				applicationType::DesktopMobile
				{
					if (!fileExist)
					{
						loadFileHandler(fileURL);
					}
				}
			}
			applicationType::DesktopWeb{
				if (fileExist && usingModule == FileManager.MODULE_3D_SHARING)
				{
					restartDownload=false;
					if (Log.isInfo())				{
						logger.info("3DViewer Download Completed and loading called(File Exist)");
					}
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.loadObjectsToTheScene(localCacheDirecotry + "/" + fileName);
				}
			}
			applicationType::mobile{
				if (fileExist && usingModule == MobileFileManager.MODULE_3D_SHARING)
				{
					restartDownload=false;
					if (Log.isInfo())				{
						logger.info("3DViewer Download Completed and loading called(File Exist)");
					}
					FlexGlobals.topLevelApplication.viewer3DComp.viewer3DSWC.loadObjectsToTheScene(localCacheDirecotry + "/" + fileName);
				}
			}
			downloadTimeOutNumber=setInterval(updateDownloadStatus, 100);
		}
		//RTCR: Need to change the function name
		/**
		 * @private
		 * Initilize the download processa
		 * @param fileURL of type String 
		 * 
		 */
		private function loadFileHandler(fileURL:String):void
		{
			var loadFile:URLLoader=new URLLoader();
			loadFile.dataFormat=URLLoaderDataFormat.BINARY;
			loadFile.addEventListener(Event.COMPLETE, downloadFileHandler);
			loadFile.addEventListener(IOErrorEvent.IO_ERROR, fileReadIOError);
			loadFile.addEventListener(IOErrorEvent.NETWORK_ERROR, fileReadNetworkError);
			loadFile.addEventListener(ProgressEvent.PROGRESS, fileReadProgress);
			loadFile.load(new URLRequest(fileURL));
			downloadFile.downlodStatus=DownloadStatus.STARTED;
			downloadFile.urlLoader=loadFile;
		}
		
		/**
		 * @private 
		 * For getting the page number
		 * @param fileName of type String
		 * @return int
		 * 
		 */
		private function getPageNumber(fileName:String):int
		{
			var pageNum:int=0;
			var startIdx:int=0;
			var endIdx:int=0;
			startIdx=fileName.lastIndexOf("_");
			if (startIdx != -1)
			{
				endIdx=fileName.indexOf(".", startIdx);
			}
			if (startIdx != -1 && endIdx != -1)
			{
				pageNum=int(fileName.substring(startIdx + 1, endIdx));
			}
			return pageNum;
		}
		
		/**
		 * @private
		 * For Update the status of downloading
		 * 
		 */
		private function updateDownloadStatus():void
		{
			var dowloaded:int=fileList.length;
			for (var i:int=0; i < fileList.length; i++)
			{
				var downloadFile:DownloadFile=DownloadFile(fileList[i]);
				if (downloadFile.downlodStatus != DownloadStatus.COMPLETED)
				{
					dowloaded=i;
					break;
				}
				if (totalFileCount > 1)
				{
					if (fileList[totalFileCount - 1].downlodStatus == DownloadStatus.COMPLETED)
					{
						dowloaded=totalFileCount;
					}
				}
			}
			
			if (dowloaded == fileList.length)
			{
				restartDownload=false;
				clearTimeout(downloadTimeOutNumber);
				downloadInProgress=false;
				applicationType::DesktopWeb{
					import edu.amrita.aview.common.components.fileManager.FileManager;
					if (usingModule == FileManager.MODULE_3D_SHARING)
					{
						if (Log.isInfo())					{
							logger.info("3DViewer Download Completed and loading called(file not exist)");
						}
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.loadObjectsToTheScene(localCacheDirecotry + "/" + fileName);
					}
					else if (usingModule == FileManager.MODULE_2D_SHARING)
					{
						applicationType::desktop
						{
							var fileCheck2d2:File;
							// AKCR: please use the constant PATH_SEPARATOR
							fileCheck2d2=new File(localCacheDirecotry + "/" + downloadFile.fileName);
							if (Log.isInfo())						{
								logger.info("2DViewer Download Completed and loading called(file not exist)");
							}
							var downDetails:Object=new Object;
							downDetails.localpath=fileCheck2d2.nativePath;
							downDetails.filename=downloadFile.fileName;
							downDetails.downloadpath=remoteFolderURL.slice(remoteFolderURL.indexOf("/AVContent"), -1);
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer2DComp.downloadCompleated(fileCheck2d2.nativePath, downloadFile.fileName, remoteFolderURL.slice(remoteFolderURL.indexOf("/AVContent"), -1));
						}
					}
				}
				applicationType::mobile{
					import edu.amrita.aview.core.shared.components.fileManager.MobileFileManager;
					if (usingModule == MobileFileManager.MODULE_3D_SHARING)
					{
						if (Log.isInfo())					{
							logger.info("3DViewer Download Completed and loading called(file not exist)");
						}
						FlexGlobals.topLevelApplication.viewer3DComp.viewer3DSWC.loadObjectsToTheScene(localCacheDirecotry + "/" + fileName);
					}
				}
			}
			downloadedCount=dowloaded;
		}
		
		/**
		 * @private 
		 * For geting the DownloadFile object for download
		 * @param urlLoader of type URLLoader
		 * @return DownloadFile
		 * 
		 */
		private function getFileNameObject(urlLoader:URLLoader):DownloadFile
		{
			var fileNameObject:DownloadFile=null;
			for (var i:int=0; i < fileList.length; i++)
			{
				var downloadFile:DownloadFile=DownloadFile(fileList[i]);
				if (downloadFile.urlLoader == urlLoader)
				{
					fileNameObject=fileList[i];
					break;
				}
			}
			return fileNameObject;
		}
		
		/**
		 * @private 
		 * Hanlding the downloading process
		 * @param event of type Event
		 * 
		 */
		private function downloadFileHandler(event:Event):void
		{
			var loadFile:URLLoader;
			try
			{
				fileNameObject=getFileNameObject(URLLoader(event.currentTarget));
				applicationType::DesktopMobile
				{
					fileStream=new FileStream();
					fileStream.addEventListener(IOErrorEvent.IO_ERROR, fileWriteIOError);
					if (Log.isInfo())					{
						logger.info("Download started for:-" + fileNameObject.fileName);
					}
					fileStream.open(new File(localCacheDirecotry + fileNameObject.fileName), FileMode.WRITE);
					fileStream.writeBytes(event.currentTarget.data);
					fileStream.close();
				}
				if (totalFileCount > 1)
				{
					fileExtension=fileNameObject.fileName;
					fileExtension=fileExtension.substr(fileExtension.lastIndexOf(".") + 1, fileExtension.length);
					if (fileExtension != "dae")
					{
						fileNameObject.downlodStatus=DownloadStatus.COMPLETED;
					}
					else
					{
						loadFile=new URLLoader();
						loadFile.dataFormat=URLLoaderDataFormat.BINARY;
						fileToCheck=fileNameObject.fileName;
						loadFile.addEventListener(Event.COMPLETE, downloadStatusCheck);
						loadFile.load(new URLRequest(localCacheDirecotry + fileNameObject.fileName));
					}
				}
				else
				{
					loadFile=new URLLoader();
					loadFile.dataFormat=URLLoaderDataFormat.BINARY;
					fileToCheck=fileNameObject.fileName;
					loadFile.addEventListener(Event.COMPLETE, downloadStatusCheck);
					loadFile.load(new URLRequest(localCacheDirecotry + fileNameObject.fileName));
				}
			}
			catch (error:Error)
			{
				if(Log.isError()) logger.error("Error in downloadFileHandler Method:"+error.getStackTrace());
			}
		}
		
		/**
		 * @private 
		 * It will invoked after download complete
		 * @param completeEvent of type Event
		 * 
		 */
		private function downloadStatusCheck(completeEvent:Event):void
		{
			var localFilePath:String;
			if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
			{
				localFilePath=decodeURI(localCacheDirecotry).replace("app-storage:/", "")
			}
			else
			{
				applicationType::mobile{
					localFilePath = decodeURI(localCacheDirecotry).replace("app-storage:/","")
				}
				applicationType::DesktopWeb{
					localFilePath=localCacheDirecotry;
				}
			}
			applicationType::DesktopMobile
			{
				var localFile:File=File.applicationStorageDirectory;
				localFile=localFile.resolvePath(localFilePath + fileToCheck);
				if (Log.isInfo())				{
					logger.info("Local file download status check starting" + localFile.nativePath);
				}
				fileStream=new FileStream();
				fileStream.addEventListener(ProgressEvent.PROGRESS, localFileReadProgress);
				fileStream.addEventListener(IOErrorEvent.IO_ERROR, localFileError);
				fileStream.addEventListener(Event.COMPLETE, localFileReadcompleted);
				fileStream.openAsync(localFile, FileMode.READ);
			}
		}
		
		/**
		 *@private 
		 * While IO error in server
		 * @param ioError of type IOErrorEvent
		 * 
		 */
		private function localFileError(ioError:IOErrorEvent):void
		{
			if (Log.isInfo())			{
				applicationType::desktop
				{
					fileStream.close();
				}
				logger.info("Local file read error");
			}
		}
		
		/**
		 *@private 
		 * Updating the Downloading process
		 * @param event of type ProgressEvent
		 * 
		 */
		private function localFileReadProgress(event:ProgressEvent):void
		{
			if (Log.isInfo())			{
				logger.info("Local file size check progress");
			}
			localfileTotal=event.bytesLoaded;
			if (bytesTotal == event.bytesLoaded)
			{
				if (Log.isInfo())				{
					logger.info("Local file size equal to the bytes to be downloaded(download completed)");
				}
				applicationType::DesktopMobile
				{
					fileStream.close();
				}
				fileNameObject.downlodStatus=DownloadStatus.COMPLETED;
				if (fileToCheck.indexOf("dae") > 1 && totalFileCount > 1)
				{
					fileList[totalFileCount - 1].downlodStatus=DownloadStatus.COMPLETED;
				}
			}
		}
		
		/**
		 *@private 
		 * For reatring the download process if have any error occured in previous download process
		 * @param event of type Event
		 * 
		 */
		private function localFileReadcompleted(event:Event):void
		{
			if (localfileTotal != bytesTotal)
			{
				if (Log.isInfo())				{
					logger.info("Local file size not equal to the bytes to be downloaded(Restarting)");
				}
				applicationType::DesktopMobile
				{
					fileStream.close();
				}
				try
				{
					applicationType::DesktopMobile
					{
						tempFile.deleteDirectoryAsync(true);
					}
				}
				catch (error:Error)
				{
					if(Log.isError()) logger.error("Error in localFileReadcompleted Method:"+ error.getStackTrace());
				}
				restartDownload=true;
				clearTimeout(downloadTimeOutNumber);
				httpServiceRequest();
			}
		}
		
		/**
		 *@private 
		 * Updating the read progress of files
		 * @param progressEvent of type ProgressEvent
		 * 
		 */
		private function fileReadProgress(progressEvent:ProgressEvent):void
		{
			bytesTotal=progressEvent.bytesTotal;
			bytesLoaded=progressEvent.bytesLoaded;
			if (Log.isInfo())			{
				logger.info("File read progress" + bytesLoaded);
			}
		}
		
		/**
		 *@private 
		 * While io error in server
		 * @param ioError of type IOError
		 * 
		 */
		private function fileReadIOError(ioError:IOError):void
		{
			if (Log.isInfo())			{
				logger.info("IOError while reading and restart downloading");
			}
			restartDownload=true;
			clearTimeout(downloadTimeOutNumber);
			httpServiceRequest();
		}
		
		/**
		 * @private 
		 * Network error in server
		 * @param netWorkError of type Event
		 * 
		 */
		private function fileReadNetworkError(netWorkError:Event):void
		{
			if (Log.isInfo())			{
				logger.info("Network error while reading and restart downloading");
			}
			restartDownload=true;
			clearTimeout(downloadTimeOutNumber);
			httpServiceRequest();
		}
		
		/**
		 * @private 
		 * IO error in server
		 * @param ioError of type IOErrorEvent
		 * 
		 */
		private function fileWriteIOError(ioError:IOErrorEvent):void
		{
			if (Log.isInfo())			{
				logger.info("IOError while writing and restart downloading");
			}
			restartDownload=true;
			clearTimeout(downloadTimeOutNumber);
			httpServiceRequest();
		}
		
		/**
		 *@private 
		 * Fault handler for downloading
		 * @param event of type FaultEvent
		 * 
		 */
		private function faultHandler(event:FaultEvent):void
		{
			if (Log.isError())	{
				logger.error("Fault event while accessing server file restarting download:" +AbstractHelper.getStaticFaultMessage(event));
			}
			restartDownload=true;
			clearTimeout(downloadTimeOutNumber);
			httpServiceRequest();
		}
	
	}
}

