package edu.amrita.aview.core.lms
{
	import com.adobe.utils.StringUtil;
	import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class LocalPlayback extends EventDispatcher
	{
		/**Platform specific imports*/
		applicationType::desktop
		{
			import flash.filesystem.File;
			import flash.filesystem.FileMode;
			import flash.filesystem.FileStream;
		}
		public static const PLAY:String="Play";
		public static const DOWNLOAD:String="Download";
		public static const DOWNLOADFAILED:String="DownloadFailed";
		public static const PLAYFAILED:String="PLAY FAILED";
		
		private var zipFileService:HTTPService=new HTTPService();
		private var zipVideoService:HTTPService=new HTTPService();
		private var zipViewerVideoService:HTTPService=new HTTPService();
		
		private var contentLoader:URLLoader=null;
		private var videoLoader:URLLoader=null;
		private var videoLoader2:URLLoader=null;
		private var desktopVideoLoader:URLLoader=null;
		
		private var presenterVideoURL:String=null;
		private var viewerVideoURL:String=null;
		private var videoFilePath:String=null;
		private var recordedContentURL:String=null;
		private var recordedContentFilePath:String=null;
		private var desktopVideoUrl:String=null;
		private var desktopVideoFilePath:String=null;
		private var _lectureName:String=null;
		
		private var isContentFilesDownloaded:Boolean=false;
		private var isPresenterVideoFilesDownloaded:Boolean=false;
		private var isViewerVideoFilesDownloaded:Boolean=false;
		private var isDesktopVideoFilesDownloaded:Boolean=false;
		
		private const ALLVIDEOS:String="AllVIDEOS";
		private const ALLFILES:String="ALLFILES";
		private const PRESENTERVIDEO:String="PRESENTERVIDEO";
		private const DESKTOPVIDEO:String="DESKTOPVIDEO";
		
		private var downloadingFailed:Boolean=false;
		private var playFailed:Boolean=false;
		
		
		private var _selectedFolder:String=null;
		private var bytes:ByteArray=new ByteArray();
		private var fileName:String=new String();
		private var flNameLength:uint;
		private var xfldLength:uint;
		private var offset:uint;
		private var compSize:uint;
		private var uncompSize:uint;
		private var compMethod:int;
		private var signature:int;
		
		public function LocalPlayback(){ }
		
		public function get lectureName():String{
			return _lectureName;
		}
		public function set lectureName(value:String):void{
			_lectureName=value;
		}
		public function get selectedFolder():String{
			return _selectedFolder;
		}
		public function set selectedFolder(value:String):void{
			_selectedFolder=value;
		}
		public function setPathVariables(presenterVideoURL:String, viewerVideoURL:String, videoFilePath:String, recordedContentURL:String, recordedContentFilePath:String, lectureName:String, desktopVideoUrl:String):void	{
			this.presenterVideoURL=presenterVideoURL;
			this.viewerVideoURL=viewerVideoURL;
			if (viewerVideoURL == "")
				this.viewerVideoURL=this.presenterVideoURL;
			this.videoFilePath=videoFilePath;
			this.recordedContentURL=recordedContentURL;
			this.recordedContentFilePath=recordedContentFilePath;
			this._lectureName=lectureName;
			this.desktopVideoUrl=desktopVideoUrl;
		}
		public function downloadZipFiles():void	{
			isContentFilesDownloaded=false;
			isViewerVideoFilesDownloaded=false;
			isViewerVideoFilesDownloaded=false;
			zipContentFiles();
			if (presenterVideoURL != viewerVideoURL) zipVideoFiles(PRESENTERVIDEO, presenterVideoURL);
			//sets the variable true as the presenter video will be available with all vidoes
			else isPresenterVideoFilesDownloaded=true;
			zipVideoFiles(ALLVIDEOS, viewerVideoURL);
			if (desktopVideoUrl != null && presenterVideoURL != desktopVideoUrl && viewerVideoURL != desktopVideoUrl)
				zipVideoFiles(DESKTOPVIDEO, desktopVideoUrl);
			//sets the variable true as the desktop video will be available with all vidoes
			else isDesktopVideoFilesDownloaded=true;
		}
		
		public function zipContentFiles():void{
			//sends request to check whether the zip file for slected lecture (xml and doc files) is available,if not create the same.
			var url:String=recordedContentURL;
			zipFileService.showBusyCursor=true;
			zipFileService.addEventListener(ResultEvent.RESULT, zipSuccess);
			zipFileService.addEventListener(FaultEvent.FAULT, zipFail);
			zipFileService.url=recordedContentURL + "AVScript/Record/createZip.php?source=" + recordedContentFilePath + "&zipNmae=" + _lectureName + ".zip&fileType=xml";
			var ziptoken:AsyncToken=zipFileService.send();
			ziptoken.zipFile=ALLFILES;
		}
		
		public function zipVideoFiles(tokenString:String, videoURL:String):void{
			//sends request to check whether the zip file for slected lecture (presenter video files) is available,if not create the same.						
			if (tokenString == PRESENTERVIDEO){
				zipVideoService.addEventListener(ResultEvent.RESULT, zipSuccess);
				zipVideoService.addEventListener(FaultEvent.FAULT, zipFail);
				videoURL=videoURL.substring(videoURL.indexOf("://"), videoURL.indexOf("/vod"));
				zipVideoService.url="http" + videoURL + ":80/" + "AVScript/Record/createZip.php?source=" + videoFilePath + "&zipNmae=" + _lectureName + "_videos.zip&fileType=video";
				var token:AsyncToken=zipVideoService.send();
				token.zipFile=tokenString;
			}
			else if (tokenString == DESKTOPVIDEO){
				zipVideoService.addEventListener(ResultEvent.RESULT, zipSuccess);
				zipVideoService.addEventListener(FaultEvent.FAULT, zipFail);
				videoURL=videoURL.substring(videoURL.indexOf("://"), videoURL.indexOf("/vod"));
				zipVideoService.url="http" + videoURL + ":80/" + "AVScript/Record/createZip.php?source=" + videoFilePath + "&zipNmae=" + _lectureName + "_desktopVideos.zip&fileType=video";
				var token2:AsyncToken=zipVideoService.send();
				token2.zipFile=tokenString;
			}
			else{
				//sends request to check whether the zip file for slected lecture (viewer video files) is available,if not create the same.						
				zipViewerVideoService.addEventListener(ResultEvent.RESULT, zipSuccess);
				zipViewerVideoService.addEventListener(FaultEvent.FAULT, zipFail);
				var viewerVideopath:String=viewerVideoURL.substring(viewerVideoURL.indexOf("://"), viewerVideoURL.indexOf("/vod"));
				zipViewerVideoService.url="http" + viewerVideopath + ":80/" + "AVScript/Record/createZip.php?source=" + videoFilePath + "&zipNmae=" + _lectureName + "_allvideos.zip&fileType=video";
				var token1:AsyncToken=zipViewerVideoService.send();
				token1.zipFile=ALLVIDEOS;
			}
		}
		
		public function addFolderToXML(folderName:String, nativePath:String):void{
			var xmlString:String='<folder><name>' + folderName + '</name><path>' + nativePath + '</path></folder>';
			applicationType::desktop{
			var stream:FileStream;
				//File and FileStream not available for web.*/
				var file:File=new File(File.applicationDirectory.nativePath + '/config/folderlist.xml');
				stream=new FileStream();
				stream.open(file, FileMode.READ);
				var bytes:ByteArray=new ByteArray();
				stream.readBytes(bytes);
				stream.close();
			
				var folderXML:XML=new XML(bytes.toString());
				var folderExists:Boolean=false;
				var index:int=0;
				while (index >= 0){
					if (folderXML.child(index).toString() != "" && folderXML.child(index).child(1)[0] == nativePath){
						folderExists=true;
						index=-1;
						break;
					}
					else if (folderXML.child(index).toString() == ""){
						index=-1;
						break;
					}
					else index++;
				}
				if (!folderExists) folderXML.appendChild(new XML(xmlString));
				stream=new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(folderXML.toString());
				stream.close();
			}
		}
		
		private function zipSuccess(e:ResultEvent):void{
			var videoURL:String;
			if (e.token.zipFile == ALLFILES){
				contentLoader=new URLLoader();
				contentLoader.dataFormat=URLLoaderDataFormat.BINARY;
				contentLoader.addEventListener(IOErrorEvent.IO_ERROR, errorLoading);
				contentLoader.addEventListener(Event.COMPLETE, downloadedLectureXml);
				contentLoader.load(new URLRequest(recordedContentURL + "/" + recordedContentFilePath + "/" + _lectureName + ".zip"));
			}
			else if (e.token.zipFile == PRESENTERVIDEO){
				videoLoader=new URLLoader();
				videoLoader.dataFormat=URLLoaderDataFormat.BINARY;
				videoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorLoading);
				videoLoader.addEventListener(Event.COMPLETE, downloadedLecturePresenterVideos);
				videoURL=presenterVideoURL.substring(presenterVideoURL.indexOf("://"), presenterVideoURL.indexOf("/vod"));
				videoLoader.load(new URLRequest("http" + videoURL + ":80/applications/vod/media/" + videoFilePath + "/" + _lectureName + "_videos.zip"));
			}
			else if (e.token.zipFile == ALLVIDEOS){
				videoLoader2=new URLLoader();
				videoLoader2.dataFormat=URLLoaderDataFormat.BINARY;
				videoLoader2.addEventListener(IOErrorEvent.IO_ERROR, errorLoading);
				videoLoader2.addEventListener(Event.COMPLETE, downloadedLectureViewerVideos);
				videoURL=viewerVideoURL.substring(viewerVideoURL.indexOf("://"), viewerVideoURL.indexOf("/vod"));
				videoLoader2.load(new URLRequest("http" + videoURL + ":80/applications/vod/media/" + videoFilePath + "/" + _lectureName + "_allvideos.zip"));
			}
			else if (e.token.zipFile == DESKTOPVIDEO){
				desktopVideoLoader=new URLLoader();
				desktopVideoLoader.dataFormat=URLLoaderDataFormat.BINARY;
				desktopVideoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorLoading);
				desktopVideoLoader.addEventListener(Event.COMPLETE, downloadedLectureViewerVideos);
				videoURL=desktopVideoUrl.substring(desktopVideoUrl.indexOf("://"), viewerVideoURL.indexOf("/vod"));
				desktopVideoLoader.load(new URLRequest("http" + videoURL + ":80/applications/vod/media/" + videoFilePath + "/" + _lectureName + "_desktopVideos.zip"));
			}
		
		}
		
		private function zipFail(e:Event):void{
			if (!downloadingFailed){
				MessageBox.show("Lecture Not Found", "Lecture Error", MessageBox.MB_OK);
				downloadingFailed=true;
				this.dispatchEvent(new Event(DOWNLOADFAILED));
			}
		
		}
		private function errorLoading(e:IOErrorEvent):void{
			if (!downloadingFailed)	{
				MessageBox.show("Error in downloading lecture", "Download Error", MessageBox.MB_OK);
				downloadingFailed=true;
				this.dispatchEvent(new Event(DOWNLOADFAILED));
			}
		}
		
		private function downloadedLectureXml(e:Event):void{
			applicationType::desktop{
				/*File and FileStream not available for web.*/
				var zipFile:File=new File(selectedFolder);
				zipFile=zipFile.resolvePath(lectureName + "/" + _lectureName + ".zip");
				var myFileStream:FileStream=new FileStream();
				myFileStream.open(zipFile, FileMode.WRITE);
				var offset:uint=0;
				if (zipFile.data != null) offset=zipFile.data.bytesAvailable;
				myFileStream.writeBytes(e.target.data, 0);
				myFileStream.close();
			}
			isContentFilesDownloaded=true;
			if (isViewerVideoFilesDownloaded && isPresenterVideoFilesDownloaded && isDesktopVideoFilesDownloaded)
				this.dispatchEvent(new Event(DOWNLOAD));
			contentLoader=null;
		}
		
		private function downloadedLecturePresenterVideos(event:Event):void{
			applicationType::desktop{
				/*File and FileStream not available for web.*/
				var zipFile:File=new File(selectedFolder);
				zipFile=zipFile.resolvePath(_lectureName + "/" + _lectureName + "_videos.zip");
				var myFileStream:FileStream=new FileStream();
				myFileStream.open(zipFile, FileMode.WRITE);
				myFileStream.writeBytes(event.target.data, 0, event.target.data);
				myFileStream.close();
			}
			isPresenterVideoFilesDownloaded=true;
			if (isViewerVideoFilesDownloaded && isContentFilesDownloaded && isDesktopVideoFilesDownloaded)
				this.dispatchEvent(new Event(DOWNLOAD));
			videoLoader=null;
		}
		
		private function downloadedLectureViewerVideos(event:Event):void{
			applicationType::desktop{
				/*File and FileStream not available for web.*/
				var zipFile:File=new File(selectedFolder);
				zipFile=zipFile.resolvePath(_lectureName + "/" + _lectureName + "_allvideos.zip");
				var myFileStream:FileStream=new FileStream();
				myFileStream.open(zipFile, FileMode.WRITE);
				myFileStream.writeBytes(event.target.data, 0, event.target.data);
				myFileStream.close();
			}
			isViewerVideoFilesDownloaded=true;
			if (isPresenterVideoFilesDownloaded && isContentFilesDownloaded && isDesktopVideoFilesDownloaded)
				this.dispatchEvent(new Event(DOWNLOAD));
			videoLoader2=null;
		
		}
		
		private function downloadedLectureDesktopVideos(event:Event):void{
			applicationType::desktop{
				/*File and FileStream not available for web.*/
				var zipFile:File=new File(selectedFolder);
				zipFile=zipFile.resolvePath(_lectureName + "/" + _lectureName + "_desktopVideos.zip");
				var myFileStream:FileStream=new FileStream();
				myFileStream.open(zipFile, FileMode.WRITE);
				myFileStream.writeBytes(event.target.data, 0, event.target.data);
				myFileStream.close();
			}
			isDesktopVideoFilesDownloaded=true;
			if (isPresenterVideoFilesDownloaded && isContentFilesDownloaded && isDesktopVideoFilesDownloaded)
				this.dispatchEvent(new Event(DOWNLOAD));
			desktopVideoLoader=null;
		
		}
		
		public function stopDownLoading():void{
			if (contentLoader != null) contentLoader.close();
			if (videoLoader != null) videoLoader.close();
			if (videoLoader2 != null) videoLoader2.close();
			if (desktopVideoLoader != null) desktopVideoLoader.close();
		}
		
		private function unZipLocaly(unzipPath:String):void{
			if (!playFailed){
				applicationType::desktop{
					/* File and FileStream not available for web.*/
					var zfile:File=null;
					zfile=new File(unzipPath);
					try{
						var zStream:FileStream=new FileStream();
						zStream.open(zfile, FileMode.READ);
						bytes.endian=Endian.LITTLE_ENDIAN;
						while (zStream.position < zfile.size){
							// read fixed metadata portion of local file header
							zStream.readBytes(bytes, 0, 30);
							bytes.position=0;
							signature=bytes.readInt();
							// if no longer reading data files, quit
							if (signature != 0x04034b50)
								break;
							bytes.position=8;
							compMethod=bytes.readByte(); // store compression method (8 == Deflate)
							offset=0; // stores length of variable portion of metadata
							bytes.position=26; // offset to file name length
							flNameLength=bytes.readShort(); // store file name
							offset+=flNameLength; // add length of file name
							bytes.position=28; // offset to extra field length
							xfldLength=bytes.readShort();
							offset+=xfldLength; // add length of extra field
							// read variable length bytes between fixed-length header and compressed file data
							zStream.readBytes(bytes, 30, offset);
							bytes.position=30;
							fileName=bytes.readUTFBytes(flNameLength); // read file name
							bytes.position=18;
							compSize=bytes.readUnsignedInt(); // store size of compressed portion
							bytes.position=22; // offset to uncompressed size
							uncompSize=bytes.readUnsignedInt(); // store uncompressed size
							
							// read compressed file to offset 0 of bytes; for uncompressed files
							// the compressed and uncompressed size is the same
							if (compSize == 0)
								continue;
							zStream.readBytes(bytes, 0, compSize);
							if (compMethod == 8) bytes.uncompress(CompressionAlgorithm.DEFLATE); // if file is compressed, uncompress
							outFile(fileName, bytes, zfile.parent.nativePath); // call outFile() to write out the file
							bytes.clear();
						}
					}
					catch (error:Error){
						if (!playFailed){
							MessageBox.show("Loading lecture failed", "Error", MessageBox.MB_OK);
							playFailed=true;
							this.dispatchEvent(new Event(PLAYFAILED));
						}
					}
				}
			}
		
		}
		
		private function outFile(fileName:String, data:ByteArray, filepath:String):void{
			try	{
				applicationType::desktop{
					/*File and FileStream not available for web.*/
					var outFile:File=new File(filepath);
					outFile=outFile.resolvePath(fileName); // name of file to write
					var outStream:FileStream=new FileStream();
					// open output file stream in WRITE mode
					outStream.open(outFile, FileMode.WRITE);
					// write out the file
					outStream.writeBytes(data, 0, data.length);
					// close it
					outStream.close();
				}
			}
			catch (e:Error){
				playFailed=true;
			}
		}
		
		public function unzipFiles():void{
			applicationType::desktop{
				/*File and FileStream not available for web.*/
				var searchFile:File=new File(selectedFolder);
				
				if (searchFile.exists){
					if ((_lectureName == null || searchFile.name == _lectureName) && searchFile.isDirectory){
						if (_lectureName == null) _lectureName=searchFile.name;
						var xmlfile:File=new File(searchFile.nativePath + "/endTime.xml");
						var lectureDetails:File=new File(searchFile.nativePath + "/" + _lectureName + ".zip");
						if (!xmlfile.exists && !lectureDetails.exists){
							MessageBox.show("Lecture is not availeble in the selected Folder", "Error", MessageBox.MB_OK);
							_lectureName=null;
						}
						else if (lectureDetails.exists){
							unZipLocaly(searchFile.nativePath + "/" + _lectureName + ".zip");
							unZipLocaly(searchFile.nativePath + "/" + _lectureName + "_allvideos.zip");
							if (new File(searchFile.nativePath + "/" + _lectureName + "_videos.zip").exists)
								unZipLocaly(searchFile.nativePath + "/" + _lectureName + "_videos.zip");
							if (new File(searchFile.nativePath + "/" + _lectureName + "_desktopVideos.zip").exists)
								unZipLocaly(searchFile.nativePath + "/" + _lectureName + "_desktopVideos.zip");
							this.dispatchEvent(new Event(PLAY));
						}
					}
					else if (!searchFile.isDirectory && searchFile.name.indexOf(_lectureName) == 0 && (searchFile.extension == "zip" || searchFile.extension == "ZIP"))	{
						var files:Array=searchFile.parent.getDirectoryListing();
						var count:int=0;
						for (var index:int=0; index < files.length; index++){
							if (files[index].toString() == _lectureName + "_videos.zip" || files[index].toString() == _lectureName + "_allvideos.zip" || files[index].toString() == _lectureName + ".zip"){
								unZipLocaly(files[index]);
								count++;
							}
							if (count == 2)
								break;
						}
						this.dispatchEvent(new Event(PLAY));
					}
					else{
						MessageBox.show("Couldn't find the selected recorded lecture in the given folder", "Error", MessageBox.MB_OK);
					}
				}
			}
		}
	}

}
