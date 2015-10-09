////////////////////////////////////////////////////////////////////////////////
//
// Copyright  � 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			:
 * Module		:
 * Developer(s)	:
 * Reviewer(s)	:
 *
 *
 *
 */

/**
 *
 */
package edu.amrita.aview.core.recording
{
	
	
	import edu.amrita.aview.core.common.Events.FileLoadedEvent;
	import edu.amrita.aview.core.common.FileLoaderManager;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.recording.Events.RecordingStatus;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	
	public class Recorder extends EventDispatcher
	{
		public var isRecording:Boolean
		private var recordingStartTime:Date;
		public var chatRecorder:ChatRecorder;
		public var whiteBoardRecorder:WhiteBoardRecorder;
		public var presenterVideoRecorder:VideoRecorder;
		public var viewerVideoRecorder:VideoRecorder;
		public var wbPointerRecorder:PointerRecorder;
		public var docPointerRecorder:PointerRecorder;
		public var pttRecorder:PushToTalkRecorder;
		public var docRecorder:DocumentRecorder;
		private var saveTimer:Timer;
		private var uploadCounter:uint;
		applicationType::desktop{
			private var wbFile:File;
			private var wbFileStream:FileStream;
			private var docFile:File;
			private var docFileStream:FileStream;
			private var chatFile:File;
			private var chatFileStream:FileStream;
			private var wbPointerFile:File;
			private var wbPointerFileStream:FileStream;
			private var docPointerFile:File;
			private var docPointerFileStream:FileStream;
			private var pVideoFile:File;
			private var pVideoFileStream:FileStream;
			private var vVideoFile:File;
			private var vVideoFileStream:FileStream;
			private var pttFile:File;
			private var pttFileStream:FileStream;
			private var endTimeFile:File;
			private var endTimeFileStream:FileStream;
		}
		private var previousRecordingEndTime:uint;
		private var fileLoaderManager:FileLoaderManager
		
		private const TOTAL_RECORDED_FILES:int=9;
		private var fileUploadedCount:int=0;
		applicationType::desktop{
			private const FILE_LOCATION:String=File.applicationStorageDirectory.nativePath+"/Recording/";
		}
		private var logger:ILogger=Log.getLogger("aview.modules.RecordingPlayback.Recording.Recorder");
		public function Recorder()
		{
			isRecording=false;
		}
		
		public function initRecording():void
		{
			fileLoaderManager=new FileLoaderManager(encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP + "/AVContent/Record/"+
				ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId+"/"+ClassroomContext.lecture.lectureId+"/"));
			initFileObjects();
			initRecordingModules();
			fileLoaderManager.addEventListener(FileLoadedEvent.ALL_LOADED,onRecordedFilesLoaded);
			fileLoaderManager.addEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onRecordedFilesLoaded);
            fileLoaderManager.loadRecordedFiles();  
			previousRecordingEndTime=0;	
		}
		private function initFileObjects():void
		{
			applicationType::desktop{
				wbFile=new File(FILE_LOCATION+"wb.xml");
				wbFileStream=new FileStream();
				
				docFile=new File(FILE_LOCATION+"doc.xml");
				docFileStream=new FileStream();
				
				chatFile=new File(FILE_LOCATION+"chat.xml");
				chatFileStream=new FileStream();
				
				wbPointerFile=new File(FILE_LOCATION+"wbPointer.xml");
				wbPointerFileStream=new FileStream();
				
				docPointerFile=new File(FILE_LOCATION+"docPointer.xml");
				docPointerFileStream=new FileStream();
				
				pVideoFile=new File(FILE_LOCATION+"pVideo.xml");
				pVideoFileStream=new FileStream();
				
				vVideoFile=new File(FILE_LOCATION+"vVideo.xml");
				vVideoFileStream=new FileStream();
				
				pttFile=new File(FILE_LOCATION+"ptt.xml");
				pttFileStream=new FileStream();
				
				endTimeFile=new File(FILE_LOCATION+"endTime.xml");
				endTimeFileStream=new FileStream();
			}
		}
		private function onRecordedFilesLoaded(evnt:FileLoadedEvent):void
		{
			fileLoaderManager.removeEventListener(FileLoadedEvent.ALL_LOADED,onRecordedFilesLoaded);
			fileLoaderManager.addEventListener(FileLoadedEvent.FILES_NOT_EXISTS,onRecordedFilesLoaded);
			if(evnt.type==FileLoadedEvent.ALL_LOADED)
			{
				previousRecordingEndTime=fileLoaderManager.endTimeXml.etime
				whiteBoardRecorder.whiteboardXml=fileLoaderManager.wbXml;
				docRecorder.docXml=fileLoaderManager.docXml; 
				chatRecorder.chatXml=fileLoaderManager.chatXml; 
				pttRecorder.pttXml=fileLoaderManager.pttXml; 
				viewerVideoRecorder.videoXml=fileLoaderManager.vVideoXml; 
				presenterVideoRecorder.videoXml=fileLoaderManager.pVideoXml; 
				docPointerRecorder.pointerXml=fileLoaderManager.docPointerXml; 
				wbPointerRecorder.pointerXml=fileLoaderManager.wbPointerXml; 
				
				var initRecordvnt:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDING_INIT_COMPLETE);
				dispatchEvent(initRecordvnt)
			}
			else
			{
				previousRecordingEndTime=0;
				
 				var createServerSideFolderService:HTTPService=new HTTPService();
				var tempPath:String="/AVContent/Record/"+ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId
					+"/"+ClassroomContext.lecture.lectureId;
				createServerSideFolderService.url=encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP+ "/AVScript/Common/" + 
						"createFolderStructure.php?folderPath=" + tempPath);
						trace(""+createServerSideFolderService.url);
				createServerSideFolderService.addEventListener(ResultEvent.RESULT, serverSideFolderCreated);
				createServerSideFolderService.addEventListener(FaultEvent.FAULT,failToCreateServerSideFolder);
				createServerSideFolderService.send();
			}
			
		}
		
		
		public function startRecording():void
		{
			isRecording=true; 
			recordingStartTime=new Date;
 			uploadCounter=0;
			
			saveTimer=new Timer(60000,0);
			saveTimer.addEventListener(TimerEvent.TIMER,saveOnInterval);
			saveTimer.start();
			
			
		}
		//public function record
		private function addVideoTag():void
		{
			/* var previousUsersSOState:Object;
			//var uName:String=ClassroomContext.userName;
			var users_so:SharedObject=Application.application.users_so;
			for (var uName:String in users_so.data)
			{			
				previousUsersSOState = Application.application.getPreviousState(uName);
				var date:Date=new Date();
				if(Application.application.getUserSOStatus(uName).userRole == Constants.PRESENTER_ROLE) 
				{ 
		
					presenterVideoRecorder.addVideoTag("true",
						getCentralTime(),uName,users_so.data[uName].userDisplayName,uName+date.getTime());
						
		
				} 
				if(Application.application.getUserSOStatus(uName).userStatus == Constants.ACCEPT && Application.application.getUserSOStatus(uName).userRole == Constants.VIEWER_ROLE) 
				{ 
					if(!previousUsersSOState || 
							(previousUsersSOState && 
								(previousUsersSOState.userStatus != Constants.ACCEPT || previousUsersSOState.userRole == Constants.PRESENTER_ROLE)
							)
					 )
					{
						viewerVideoRecorder.addVideoTag("false",
							getCentralTime(),uName,users_so.data[uName].userDisplayName,uName+date.getTime());
					}
					
				} 
			}  */
		}
		
		private function initRecordingModules():void
		{
			chatRecorder=new ChatRecorder();              
			whiteBoardRecorder=new WhiteBoardRecorder();
			presenterVideoRecorder=new VideoRecorder(ClassroomContext.VIDEO_RECORD_SERVER);
			presenterVideoRecorder.videoXml=<presenter></presenter>
			viewerVideoRecorder=new VideoRecorder(ClassroomContext.VIEWER_VIDEO_RECORD_SERVER);
			viewerVideoRecorder.videoXml=<viewer></viewer>;
			wbPointerRecorder=new PointerRecorder();
			docPointerRecorder=new PointerRecorder();
			pttRecorder=new PushToTalkRecorder();
			docRecorder=new DocumentRecorder();
		}
		
		public function stopRecording():void
		{
			
			isRecording=false;
			clearInterval(presenterVideoRecorder.clearIntervaltTime);
			clearInterval(viewerVideoRecorder.clearIntervaltTime);
			saveTimer.stop();
			fileUploadedCount=0
			isXmlFilesCopyErrorDispated=false;
			uploadCounter=4;
			saveToDisk();
		}
		private function serverSideFolderCreated(evnt:ResultEvent):void
		{
			trace(" SserverSideFolderCreatede");
			previousRecordingEndTime=0;
			var initRecordvnt:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDING_INIT_COMPLETE);
			dispatchEvent(initRecordvnt)
		}
		private function saveOnInterval(evnt:TimerEvent):void
		{
			uploadCounter++;
			if(Log.isDebug()) logger.debug(" In saveOnInterval. uploadCounter:"+uploadCounter);
			saveToDisk();
			
			
			
		}
		private function failToCreateServerSideFolder(evnt:FaultEvent):void
		{
			var event:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDING_ERROR);
			dispatchEvent(event);
			Alert.show("Application Error (Error Number: S/Recording/0001-" 
			+ evnt.fault.errorID +")\nPlease contact A-VIEW Administrator.", "ERROR",0);
		}

		private function saveToDisk():void
		{
			if(uploadCounter==4 && presenterVideoRecorder.currentrecordingStream != "" && saveTimer.running && presenterVideoRecorder.nectConn.connected)
			{ 
				//var tempcurrentrecordingUser = presenterVideoRecorder.currentrecordingUser;
				if(Log.isDebug()) logger.debug("From saveToDisk: Calling addEndtime for presenter- Stream Name:"+presenterVideoRecorder.currentrecordingStream);
				presenterVideoRecorder.isInternalSaving=true;
				presenterVideoRecorder.addEndtime(getCentralTime(),presenterVideoRecorder.currentrecordingStream);
				
			}
			if(uploadCounter==4 && viewerVideoRecorder.currentrecordingStream != "" && saveTimer.running && viewerVideoRecorder.nectConn.connected)
			{
				if(Log.isDebug()) logger.debug("From saveToDisk: Calling addEndtime for viewer- Stream Name:"+viewerVideoRecorder.currentrecordingStream);
				viewerVideoRecorder.isInternalSaving=true;
				viewerVideoRecorder.addEndtime(getCentralTime(),viewerVideoRecorder.currentrecordingStream);
			}
			var xml:XML=<time><etime></etime></time>
			xml.etime=getCentralTime();
			applicationType::desktop{
				saveAndUpload(endTimeFile,endTimeFileStream,xml);
				saveAndUpload(wbFile,wbFileStream,whiteBoardRecorder.whiteboardXml.toXMLString());
				saveAndUpload(docFile,docFileStream,docRecorder.docXml.toXMLString());
				saveAndUpload(chatFile,chatFileStream,chatRecorder.chatXml.toXMLString());
				saveAndUpload(pVideoFile,pVideoFileStream,presenterVideoRecorder.videoXml.toXMLString());
				saveAndUpload(vVideoFile,vVideoFileStream,viewerVideoRecorder.videoXml.toXMLString());
				saveAndUpload(wbPointerFile,wbPointerFileStream,wbPointerRecorder.pointerXml.toXMLString());
				saveAndUpload(docPointerFile,docPointerFileStream,docPointerRecorder.pointerXml.toXMLString());
				saveAndUpload(pttFile,pttFileStream,pttRecorder.pttXml.toXMLString());
			}
			if(uploadCounter==4)
			{
				uploadCounter=0;
			}
		}
		public function getCentralTime():uint
		{
			var time:Date=new Date();
			trace("time"+(time.time-recordingStartTime.time)/1000);
			return (previousRecordingEndTime+(time.time-recordingStartTime.time));
			
		}
		applicationType::desktop{
			private function saveAndUpload(file:File,fileStream:FileStream,xmlData:String):void
			{
				//var biteArray:ByteArray=new ByteArray();
				//biteArray.writeUTFBytes("<?xml version=\"1.0\" encoding=\"utf-8\"?>"+xmlData);
				//biteArray.compress("deflate"); // 
				fileStream.open(file,FileMode.WRITE);
				fileStream.writeUTFBytes("<?xml version=\"1.0\" encoding=\"utf-8\"?>"+xmlData);
				//fs.writeBytes(biteArray,0,biteArray.length); 
				fileStream.close();
				if(uploadCounter==4 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.isConnected())
				{	//
					var tempPath:String="AVContent/Record/"+ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId
						+"/"+ClassroomContext.lecture.lectureId;
					file.addEventListener(Event.COMPLETE,deleteTempFile);
					file.addEventListener(IOErrorEvent.IO_ERROR,errorInUpload);
					file.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorInUpload);
					var url:String=encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP + "/AVScript/Common/upload.php?folderPath="+ tempPath);
					file.upload(new URLRequest(url));
				 }
				else if(uploadCounter==4 && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.usersConnection.isConnected())
				{
					if(Log.isDebug()) logger.debug("saveAndUpload: User is not connected to server." );
					uploadCounter--;
				}
			
			}
		}
		private function deleteTempFile(evnt:Event):void
		{
			evnt.target.deleteFile();
			evnt.target.removeEventListener(Event.COMPLETE,errorInUpload);
			if(++fileUploadedCount == TOTAL_RECORDED_FILES)
			{
				var xmlFilesCopiedEvent:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDED_XML_COPY_COMPLETE); 
				dispatchEvent(xmlFilesCopiedEvent)
			}
			
		}
		private var isXmlFilesCopyErrorDispated:Boolean;
		private function errorInUpload(evnt:Event):void
		{
			evnt.target.removeEventListener(evnt.type,errorInUpload);
			try{
				evnt.target.deleteFile();
			}
			catch(err:Error){}
			if(!isXmlFilesCopyErrorDispated)
			{
				isXmlFilesCopyErrorDispated=true;
				var xmlFilesCopyErrorEvent:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDED_XML_COPY_ERROR); 
				dispatchEvent(xmlFilesCopyErrorEvent)
			}
			
		}
		

	}
}
