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
 * File			: FileDownloader.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *FileDownloader class to represent an file downloading from server to local
 *
 */
package edu.amrita.aview.core.shared.components.fileManager.download
{
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	/**
	 *  You use the FileDownloader class to represent an file downloading from server to local.
	 *  FileDownloader object in ActionScript. When you call the FileDownloader object's
	 *  <code>downlaod()</code> method, it will take care of downloading process.
	 *
	 */
	public class FileDownloader
	
	{
		/**
		 * @public 
		 * Constructor
		 */
		public function FileDownloader()
		{
		}
		/**
		 * Object of DownloadURLFolder
		 */		
		[Bindable]
		public var downloader:DownloadURLFolder;
		/**
		 * Store the value of url of remote Folder
		 */		
		private var remoteFolderRoot:String;
		/**
		 * This refrence a static vallue "directory"
		 */		
		private static const DIRECTORY_PARAM:String="directory";
		/**
		 * Store the module name ,which is currently use this class.
		 */		
		public var usingModule:String;
		/**
		 * Ibject of Loger class
		 */		
		public var logger:ILogger=Log.getLogger("aview.modules.2D3Ddownload");
		
		/**Platform specific imports and variables*/
		applicationType::desktop
		{
			import flash.filesystem.File;
			/**
			 * 
			 */			
			private var localFolder:File=File.applicationStorageDirectory;
			/**
			 * 
			 */			
			public var tempFile:File;
		}
		
		/**
		 *@public
		 *The method for downloading process
		 *@param downloadUrl of type String
		 *
		 */
		public function download(downloadUrl:String):void
		{
			if (Log.isInfo())			{
				logger.info("FileDownloader constructor called and path:-" + downloadUrl);
			}
			// AKCR: please use constant variable for protocols like http://
			remoteFolderRoot=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP);
			var remoteDirectory:String=getRemoteDirectory(downloadUrl);
			if (downloadUrl == "" || remoteDirectory == "")
			{
				Alert.show("Url is either empty or missing the directory= parameter", "WARNING", 0, null, null);
				return;
			}
			applicationType::desktop
			{
				tempFile=localFolder.resolvePath(remoteDirectory);
				downloader=new DownloadURLFolder(downloadUrl, remoteFolderRoot + "/" + remoteDirectory + "/", tempFile.url + "/", usingModule);
			}
			applicationType::web
			{
				/**For web, since there is no local caching, we pass the last argument as null */
				downloader=new DownloadURLFolder(downloadUrl, remoteFolderRoot + "/" + remoteDirectory + "/", null, usingModule);
			}
		}
		
		/**
		 * @private
		 * Method for getting the server path of requested file.
		 * @param url of type String
		 * @return String    
		 */
		private function getRemoteDirectory(url:String):String
		{
			var directory:String="";
			var startIndex:int=0;
			var endIndex:int=0;
			
			if (url != null)
			{
				startIndex=url.indexOf(DIRECTORY_PARAM + "=");
				if (startIndex != -1)
				{
					startIndex+=DIRECTORY_PARAM.length + 2; //Advance the index by DIRECTORY_PARAM+"=/"
					endIndex=url.indexOf("&", startIndex);
					// AKCR: use conditional operator
					if (endIndex != -1)
					{
						directory=url.substring(startIndex, endIndex);
					}
					else
					{
						directory=url.substring(startIndex);
					}
				}
			}
			return directory;
		}
	}
}
