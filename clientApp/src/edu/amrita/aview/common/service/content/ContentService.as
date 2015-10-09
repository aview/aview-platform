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
 * File			: ContentService.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:- Function Description for all functions
//VGCR:- Functional Description
package edu.amrita.aview.common.service.content
{
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	
	/**
	 * This class provides easy to use methods to handle all content managment requests to the remote Contentserver
	 * @author rameshg
	 */
	public class ContentService extends HTTPService
	{
		
		/**
		 * @public
		 * For creating folder(s) in the remote server
		 * @params folderPath:String, the complete path including the folder to be created. 
		 * If more than folder is new in the path, this function would create all of them
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function createFolder(folderPath:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.folderPath=folderPath;
				// AKCR: please use a constant in place of "http://". In future it may be easier to 
				// AKCR: secure the protocol based on simple configuration rather than hand changing several files
				// AKCR: please use a constant for the upload directory path hard-coded below
				var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/createDirectory.php"
				callService(url, "text", requestParam, "GET", onResult, onFault);
			}
		}
		
		/**
		 * @public
		 * For deleting the folder/files recursively under the specified path
		 * @params filePath:String: Remote folder/file path which will be deleted recursively.
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		*/
		public function deleteFile(filePath:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.filePath=filePath;
				// AKCR: please use a constant in place of "http://". In future it may be easier to 
				// AKCR: secure the protocol based on simple configuration rather than hand changing several files
				// AKCR: please use a constant for the upload directory path hard-coded below
				var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/deleteFile.php";
				callService(url, "text", requestParam, "GET", onResult, onFault);
			}
		}
		
		/**
		 * @public
		 * For process of copying remote folder/files to other locations. 
		 * This method recursively copies all the folders/files to the new destination path
		 * 
		 * @params sourcePath:String, from which the files/folder would copied
		 * @params destinationPath:String, to which the files/folder would copied. 
		 * It would create any directories which are needed to be created. It does not delete files/folders from destination 
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function copyFiles(sourcePath:String, destinationPath:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.sourceURL=sourcePath;
				requestParam.destURL=destinationPath;
				
				// AKCR: please use a constant in place of "http://". In future it may be easier to 
				// AKCR: secure the protocol based on simple configuration rather than hand changing several files
				// AKCR: please use a constant for the script file path hard-coded below
				var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/CentralRep/scripts/copyFile.php";
				
				callService(url, "text", requestParam, "POST", onResult, onFault);
			}
		}
		
		/**
		 * @public
		 * Checks to see if the remote file is already existing or not on the Content server.
		 * If the file exists, it will send the message in ResultEvent 
		 * as "Error: File already exists" and if not "Success: File does not exist"
		 * @param filePath
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function checkFileExistance(filePath:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.filePath=filePath;
				
				// AKCR: please use a constant in place of "http://". In future it may be easier to 
				// AKCR: secure the protocol based on simple configuration rather than hand changing several files
				// AKCR: please use a constant for the upload directory path hard-coded below
				var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/checkFileExistance.php";			
				callService(url, "text", requestParam, "GET", onResult, onFault);
			}
		}
		
		/**
		 * @public
		 * For uploading file to remote location
		 * @params folderPath:String Remote folder path to which the file is uploaded
		 * @params fileReference:FileReference containing the File to be uploaded
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function uploadFile(folderPath:String, fileReference:FileReference, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:URLVariables=new URLVariables();
				requestParam.folderPath=folderPath;
				var request:URLRequest=new URLRequest();
				// AKCR: please use a constant in place of "http://". In future it may be easier to 
				// AKCR: secure the protocol based on simple configuration rather than hand changing several files
				// AKCR: please use a constant for the upload directory path hard-coded below
				var uploadUrl:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/upload.php";
				request.url=uploadUrl;
				request.method=URLRequestMethod.POST;
				request.data=requestParam;
				fileReference.upload(request);
				fileReference.addEventListener(Event.COMPLETE, onResult);
				fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFault);
			}
		}
		/**
		 * @public
		 * For converting files in  remote location
		 * @params folderPath:String Remote folder path to which the file is uploaded
		 * @params fileName:String containing the name of the file
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function addToConevrssionQue(folderPath:String,fileName:String,isAnimated:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.folderPath=folderPath;
				requestParam.animated=isAnimated;
				requestParam.userId=ClassroomContext.userVO.userId
				requestParam.fileName=fileName;
				var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/windows/Upload.php";
				callService(url, "object", requestParam, "POST", onResult, onFault);
			}
		}
		
		/**
		 * @public
		 * For downloading a file from remote location to Application or Personal Computer
		 * @params filepath:String, the full path of the file starting from the doc root of the Content server
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function download(filePath:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var fileReference:FileReference=new FileReference()
					// AKCR: please use a constant in place of "http://". In future it may be easier to 
					// AKCR: secure the protocol based on simple configuration rather than hand changing several files
					// AKCR: please use a constant for the upload directory path hard-coded below
				var downloadedfile:URLRequest=new URLRequest(encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + filePath));
				var requestParam:Object=new Object();
				requestParam.folderName=filePath;
				fileReference.download(downloadedfile);
				fileReference.addEventListener(Event.COMPLETE, onResult)
				fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFault)
			}
		}
		
		/**
		 * @public
		 * For process of getting the list of files/folders from Remote location in xml format
		 * @params rootFolder:String, The remote root directory which is used to get the file list
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function getFileList(rootFolder:String, onResult:Function, onFault:Function):void
		{
			var requestParam:Object=new Object();
			requestParam.rootFolder=rootFolder;
			var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/fileList.php";
			callService(url, "object", requestParam, "POST", onResult, onFault);
		}
		
		/**
		 * @public
		 * For process of getting the file lists  from  shared library
		 * @params url of String
		 * @params libraryXML of XML
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function getSharedFileList(url:String, libraryXML:XML, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.rootFolder=url;
				requestParam.libraryXML=libraryXML;
				var url:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/CentralRep/scripts/centralRepPath.php";
				callService(url, "object", requestParam, "POST", onResult, onFault);
			}
		}
		
		/**
		 * @public 
		 * @param folderPath of type String
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 * 
		 */
		public function textureUpload(folderPath:String, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				var urlPath:String="http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + folderPath;
				callService(urlPath, "xml", requestParam, "GET", onResult, onFault);
			}
		}
		
		/**
		 * @public
		 * @param filePath of type String
		 * @param content of type Content
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 */
		public function updateCollada(filePath:String, content:Array, onResult:Function, onFault:Function):void
		{
			applicationType::DesktopWeb{
				var requestParam:Object=new Object();
				requestParam.fileName=filePath;
				requestParam.content=content;
				var url:String=encodeURI("http://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/updateCollada.php");
				callService(url, "object", requestParam, "GET", onResult, onFault);
			}
		}
		
		/**
		 * @private 
		 * @param url of type String
		 * @param resultFormat of type String
		 * @param requestObj of type Object
		 * @param method of type String
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		 * 
		 */
		private function callService(url:String, resultFormat:String, requestObj:Object, method:String, onResult:Function, onFault:Function):void
		{
			var service:HTTPService=new HTTPService();
			service.resultFormat=resultFormat;
			service.method=method
			service.useProxy=false;
			service.url=encodeURI(url);
			service.request=requestObj;
			var token:AsyncToken=service.send();
			token.onResult=onResult;
			token.onFault=onFault;
			token.service=service;
			service.addEventListener(ResultEvent.RESULT, genericResultHandler)
			service.addEventListener(FaultEvent.FAULT, genericFaultHandler)
		}
		
		/**
		 * @private 
		 * @param event of type ResultEvent
		 * 
		 */
		private function genericResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event)
			cleanupService(event.token.service);
		}
		
		/**
		 * @private 
		 * @param event of type FaultEvent
		 * 
		 */
		private function genericFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event.fault)
			cleanupService(event.token.service);
		}
		
		/**
		 * @private 
		 * @param service of type HTTPService
		 * 
		 */
		private function cleanupService(service:HTTPService):void
		{
			service.disconnect();
			service.removeEventListener(ResultEvent.RESULT, genericResultHandler);
			service.removeEventListener(FaultEvent.FAULT, genericFaultHandler);
		}
	}
}
