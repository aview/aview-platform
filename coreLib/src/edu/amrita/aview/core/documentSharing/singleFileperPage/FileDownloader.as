package edu.amrita.aview.core.documentSharing.singleFileperPage
{
	import mx.controls.Alert;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	public class FileDownloader
	{
		public function FileDownloader(){
		}
		[Bindable]
		private var downloader:DownloadURLFolder;
		private var remoteFolderRoot:String;
		private static const DIRECTORY_PARAM:String="directory";
		
		/**Platform specific imports and variables*/
		applicationType::DesktopMobile{
			import flash.filesystem.File;
			private var localFolder:File=File.applicationStorageDirectory;
			private var tempFile:File;
		}	
		public function download(downloadUrl:String, prefferdPage:Number, totalNoOfFiles:Number):void{
			remoteFolderRoot=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP);
			var remoteDirectory:String=getRemoteDirectory(downloadUrl);
			if (downloadUrl == "" || remoteDirectory == "")	{
				Alert.show("Url is either empty or missing the directory= parameter", "WARNING", 0, null, null);
				return;
			}
			applicationType::DesktopMobile{
				tempFile=localFolder.resolvePath(remoteDirectory);
				if (!tempFile.exists)
					tempFile.createDirectory();
				downloader=new DownloadURLFolder(downloadUrl, remoteFolderRoot + "/" + remoteDirectory + "/", tempFile.url + "/", prefferdPage, totalNoOfFiles);
			}
			applicationType::web{
				downloader=new DownloadURLFolder(downloadUrl, remoteFolderRoot + "/" + remoteDirectory+"/",null,prefferdPage,totalNoOfFiles);
			}
		}
		
		public function downloadPages(startPage:Number, endPage:Number, preferedPage:Number):void{
			downloader.download(startPage, endPage, preferedPage);
		}
		private function getRemoteDirectory(url:String):String{
			var directory:String="";
			var startIndex:int=0;
			var endIndex:int=0;
			if (url != null){
				startIndex=url.indexOf(DIRECTORY_PARAM + "=");
				if (startIndex != -1){
					startIndex+=DIRECTORY_PARAM.length + 2; //Advance the index by DIRECTORY_PARAM+"=/"
					endIndex=url.indexOf("&", startIndex);
					if (endIndex != -1)
						directory=url.substring(startIndex, endIndex);
					else
						directory=url.substring(startIndex);
				}
			}
			return directory;
		}
	
	
	}
}
