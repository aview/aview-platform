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
 * Developer(s)	: Ramesh Guntha, Haridas
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:- Function Description for all functions
//VGCR:- Functional Description
package edu.amrita.aview.core.shared.service.content
{
	
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	
	import org.osmf.logging.Logger;
	
	/**
	 * This class provides easy to use methods to handle all content managment requests to the remote Contentserver
	 * @author rameshg
	 */
	public class ContentService extends HTTPService
	{
		private var createDirectoryScript:String;
		private var deleteFileScript:String;
		private var copyFileScript:String;
		private var checkFileExistanceScript:String;
		private var uploadScript:String;
		private var print2Flash	:String;	
		private var iSPring	:String;
		private var uploadwinScript:String;
		private var fileListScript:String;
		private var centralRepPathScript:String;
		private var updateColladaScript:String;
		private var baseURL:String;
		private var address:String;
		private var checkLogFileExistanceScript:String;
		
		private var port:int;
		private var protocol:String;
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.edu.amrita.aview.core.shared.servive.content.ContentService.as");

		/**
		 * @Constructor
		 * can be called without params or with connection details
		 * @params proto: the protocol to use; for e.g "http", "https", "ftp" etc
		 * @params domain: for e.g apps.aview.in
		 * @params port: port of the url to connect to
		 * Function constructs the base url for the duration of the connection
		 */

		public function ContentService(proto:String="http", domain:String="", port:int = 80){
			//ashwini: todo need to get the script paths from config
			// ashwini todo: have to remove this hard-coded port number 80
			_setContentscritps();
			this.protocol = proto;
			this.port = port;
			//this.address = (domain != "" ) ? domain : "";
			//this.baseURL = this._getURL();
			// if domain is passed, then set the url with passed in params
			if(domain != "") {
				this.address = domain;
				this.baseURL = this._getURL(this.protocol, this.address, this.port);
			}else {
			// else use the classroomcontext approach
				this.address = "";
				this.baseURL = this._getURL();
			}
		}
		
		private function _setContentscritps():void{
			//todo: read this from a config file
			centralRepPathScript 	  ="/AVScript/Upload/CentralRep/scripts/centralRepPath.php";
			checkFileExistanceScript  ="/AVScript/Upload/checkFileExistance.php";
			checkLogFileExistanceScript="/AVScript/Upload/checkLogFileExistence.php";
			copyFileScript 	          ="/AVScript/Upload/CentralRep/scripts/copyFile.php";
			createDirectoryScript 	  ="/AVScript/Upload/createDirectory.php";
			deleteFileScript 	      ="/AVScript/Upload/deleteFile.php";
			fileListScript 	          ="/AVScript/Upload/fileList.php";
			updateColladaScript 	  ="/AVScript/Upload/updateCollada.php";
			uploadScript 	          ="/AVScript/Upload/upload.php";
			print2Flash				  ="/AVScript/Upload/print2flash.php";
			iSPring					  ="/AVScript/Upload/ispring.php";
		}

		private function _getURL(proto:String="http", domain:String="", port:int = 80):String{
			var url:String="";
			if(domain != ""){
				url = this.protocol + "://" + domain + ":" + this.port;
			} else {
				url = this.protocol + "://" + ClassroomContext.CONTENT_DOCUMENT + ":" + ClassroomContext.portWAMP;
			}
			return url;
		}
		
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
			var requestParam:Object=new Object();
			requestParam.folderPath=folderPath;
			var url:String= this._getURL() + this.createDirectoryScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
		}
		public function createVideoFolder(folderPath:String, onResult:Function, onFault:Function,domain:String=""):void
		{
			var requestParam:Object=new Object();
			requestParam.folderPath=folderPath;
			var url:String= this._getURL("http",domain) + this.createDirectoryScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
		}
		
		/**
		 * @public
		 * For deleting the folder/files recursively under the specified path
		 * @params filePath:String: Remote folder/file path which will be deleted recursively.
		 * 
		 * @params onResult:Function, result handler function should accept ResultEvent parameter
		 * @params onFault:Function, fault handler function should accept FaultEvent parameter
		*/
		public function deleteFile(filePath:String,onResult:Function, onFault:Function,usingModule:String=null,remoteFileName:String=null):void
		{
			var requestParam:Object=new Object();
			requestParam.filePath=filePath;
			requestParam.usingModule=usingModule;
			requestParam.remoteFileName=remoteFileName;
			var url:String= this._getURL() + this.deleteFileScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
		}
		
		public function deleteVideoFile(filePath:String,onResult:Function, onFault:Function,usingModule:String=null,remoteFileName:String=null,domain:String=""):void
		{
			var requestParam:Object=new Object();
			requestParam.filePath=filePath;
			requestParam.usingModule=usingModule;
			requestParam.remoteFileName=remoteFileName;
			var url:String= this._getURL("http",domain) + this.deleteFileScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
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
			var requestParam:Object=new Object();
			requestParam.sourceURL=sourcePath;
			requestParam.destURL=destinationPath;
			var url:String= this._getURL() + this.copyFileScript;
			
			callService(url, "text", requestParam, "POST", onResult, onFault);
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
			var requestParam:Object=new Object();
			requestParam.filePath=filePath;
			var url:String= this._getURL() + this.checkFileExistanceScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
		}
		public function checkVideoFileExistance(filePath:String, onResult:Function, onFault:Function,domain:String=""):void
		{
			var requestParam:Object=new Object();
			requestParam.filePath=filePath;
			var url:String= this._getURL("http",domain) + this.checkFileExistanceScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
		}
		
		public function checkLogFileExistance(filePath:String, onResult:Function, onFault:Function):void
		{
			var requestParam:Object=new Object();
			requestParam.filePath=filePath;
			var url:String= this._getURL() + this.checkLogFileExistanceScript;
			callService(url, "text", requestParam, "GET", onResult, onFault);
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
		public function uploadFile(folderPath:String, fileReference:FileReference,onResult:Function, onFault:Function,userId:Number=0):void
		{
			var requestParam:URLVariables=new URLVariables();
			requestParam.folderPath=folderPath;
			var uploadUrl:String;
			var request:URLRequest=new URLRequest();
			uploadUrl= this._getURL() + this.uploadScript;
			request.url=uploadUrl;
			request.method=URLRequestMethod.POST;
			request.data=requestParam;
			fileReference.upload(request);
			fileReference.addEventListener(Event.COMPLETE, onResult);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFault);
		}
		public function uploadFileDocument(folderPath:String, fileReference:FileReference,onResult:Function, onFault:Function,userId:Number=0,databaseIP:String="",isAnimatedFile:String="",area:String=""):void
		{
			var requestParam:URLVariables=new URLVariables();
			requestParam.folderPath=folderPath;
			requestParam.areaSelect=area;
			var uploadUrl:String;
			/*requestParam.userId=userId;
			requestParam.databaseIP=databaseIP;
			requestParam.isAnimatedFile=isAnimatedFile;*/
			var request:URLRequest=new URLRequest();
			if(isAnimatedFile=="N")
			{
				uploadUrl= this._getURL() + this.print2Flash;
			}
			else
			uploadUrl= this._getURL() + this.iSPring;
			request.url=uploadUrl;
			request.method=URLRequestMethod.POST;
			request.data=requestParam;
			fileReference.upload(request);
			fileReference.addEventListener(Event.COMPLETE, onResult);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFault);
		}
		public function uploadVideoFile(folderPath:String, fileReference:FileReference,onResult:Function, onFault:Function,userId:Number=0,domain:String=""):void
		{
			var requestParam:URLVariables=new URLVariables();
			requestParam.folderPath=folderPath;
			var uploadUrl:String;
			var request:URLRequest=new URLRequest();
			if(ClassroomContext.CONTENT_DOCUMENT==domain)
			{
				uploadUrl= this._getURL("http",domain) + this.uploadScript;
			}
			else
			{
				uploadUrl="http://"+domain+":8080"+this.uploadScript;
			}
			request.url=uploadUrl;
			request.method=URLRequestMethod.POST;
			request.data=requestParam;
			fileReference.upload(request);
			fileReference.addEventListener(Event.COMPLETE, onResult);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFault);
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
			var fileReference:FileReference=new FileReference()
			var downloadedfile:URLRequest=new URLRequest(encodeURI( this.baseURL + filePath));
			var requestParam:Object=new Object();
			requestParam.folderName=filePath;
			fileReference.download(downloadedfile);
			fileReference.addEventListener(Event.COMPLETE, onResult)
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFault)
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
			var url:String= this._getURL() + this.fileListScript;
			callService(url, "object", requestParam, "POST", onResult, onFault);
		}
		
		public function getVideoFileList(rootFolder:String, onResult:Function, onFault:Function,domain:String=""):void
		{
			var requestParam:Object=new Object();
			requestParam.rootFolder=rootFolder;
			var url:String= this._getURL("http",domain) + this.fileListScript;
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
			var requestParam:Object=new Object();
			requestParam.rootFolder=url;
			requestParam.libraryXML=libraryXML;
			var url:String= this._getURL() + this.centralRepPathScript;
			callService(url, "object", requestParam, "POST", onResult, onFault);
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
			var requestParam:Object=new Object();
			var urlPath:String= this._getURL() + folderPath;
			callService(urlPath, "xml", requestParam, "GET", onResult, onFault);
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
			var requestParam:Object=new Object();
			requestParam.fileName=filePath;
			requestParam.content=content;
			var url:String=encodeURI( this._getURL() + this.updateColladaScript);
			callService(url, "object", requestParam, "GET", onResult, onFault);
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
			//token.addResponder(new Responder,onResult,onFault);
			//token.addResponder(new Responder ,genericResultHandler,genericFaultHandler);
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
			if(Log.isDebug()) log.debug("genericResultHandler ContentService:Result Event"+event.result);
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
			if(Log.isDebug()) log.debug("genericResultHandler ContentService:Fault Event"+event.fault.faultString);
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
