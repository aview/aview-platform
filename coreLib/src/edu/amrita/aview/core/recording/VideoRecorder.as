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
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.recording.Events.RecordingStatus;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class VideoRecorder extends EventDispatcher
	{
		public var videoXml:XML
		public var currentrecordingStream:String;
		public var isStreamStarted:Boolean;
		public var nectConn:NetConnection;
		private var currentRecordingFileName:String
		public static var streamCopyingList:Array=new Array();
		private var waitingCount:uint
		public var clearIntervaltTime:uint
		/* HTTPService variable for uploading recorded video file to WAMP Server.*/
		private var videoFileCopyService:HTTPService;
		private var recordingServerIP:String = "";
		public var isVideoReconnected:Boolean=false;
		public var isInternalSaving:Boolean=false;
		private var logger:ILogger=Log.getLogger("aview.modules.RecordingPlayback.Recording.VideoRecorder");
		public function VideoRecorder(recordingServer:String)
		{
			this.recordingServerIP = recordingServer;
			currentrecordingStream="";
			isStreamStarted=false;
		}
		public function recordStream(netCon:NetConnection,isPresenter:String,streamName:String,dispName:String):void
		{
			nectConn=netCon;
			if(Log.isDebug()) logger.debug("In  recordStream start: Current Recording Stream: "+currentrecordingStream+
				" New stream :"+streamName);
			if(currentrecordingStream!=streamName)
			{
				
				if(streamCopyingList.indexOf(streamName)>-1)
				{
					waitingCount=0
					clearInterval(clearIntervaltTime);
					clearIntervaltTime=setInterval(waitForCopying,500,netCon,isPresenter,streamName,dispName);
					
					if(Log.isDebug()) logger.debug("In  recordStream. The previous stream is not get copied" +
						"Adding dealy. clearIntervaltTime:  "+clearIntervaltTime);
				}
				else
				{
					var tempDate:Date=new Date()
					if(Log.isDebug())
					{
						logger.debug("From recordStream: Calling addEndtime- Stream Name:"+streamName);
					}
					addEndtime(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(),currentrecordingStream);
					currentrecordingStream=streamName;
					var isF4V:Boolean = (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264);
					var extenstion:String
					if(isF4V)
						extenstion=".f4v";
					else
						extenstion=".flv";
					netCon.call("recordStream",null,isPresenter,streamName,streamName+tempDate.time+extenstion,dispName,isF4V)
					if(Log.isDebug()) logger.debug(" In recordStream. Called server side recording for the stream:"+streamName+"" +
						": isPresenter:"+ isPresenter+":isF4V :"+isF4V);
				}
				
				
			}		
		}
		private function waitForCopying(netCon:NetConnection,isPresenter:String,streamName:String,dispName:String):void
		{
			if(++waitingCount>50 || streamCopyingList.indexOf(streamName)<0)
			{
				clearInterval(clearIntervaltTime);
				if(currentrecordingStream!=streamName)
				{
					var tempDate:Date=new Date()
					if(Log.isDebug()) logger.debug("From waitForCopying: Calling addEndtime- Stream Name:"+streamName);
					addEndtime(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(),currentrecordingStream);
					currentrecordingStream=streamName;
					var isF4V:Boolean = (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264);
					var extenstion:String
					if(isF4V)
						extenstion=".f4v";
					else
						extenstion=".flv";
					netCon.call("recordStream",null,isPresenter,streamName,streamName+tempDate.time+extenstion,dispName,isF4V)
					if(Log.isDebug()) logger.debug(" In waitForCopying. Called server side recording for the stream:"+streamName+"" +
						": isPresenter:"+ isPresenter+":isF4V :"+isF4V+"WaitingCount:"+waitingCount);
				}
			}
		}
		public function recordingStatus(obj:Object):void
		{
			
			if(Log.isDebug()) logger.debug(" In recordingStatus. CurrentrecordingUser:"+currentrecordingStream);
			if(obj.status == "success")
			{
				var tempUname:String=currentrecordingStream;
 				if(tempUname.search("_VIEWER")>0)
					tempUname=tempUname.substr(0,tempUname.lastIndexOf("_VIEWER"));
				if(obj.streamName == currentrecordingStream && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(tempUname) &&
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(tempUname).isVideoPublishing)//fast switching 
				{
					currentRecordingFileName=obj.fileName;
					addVideoTag(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recorder.getCentralTime(),obj.streamName,obj.dispName,obj.fileName);
				}
			}
			else if(obj.status == "failed")
			{
				Alert.show("Failed to record video for the user: "+currentrecordingStream+". Please restart the recording."  ,"Recording Error");
			}

		}
		private function recordingError(obj:Object):void
		{
			Alert.show("Unable to record video on the server. Please restart the recording.","Recording Error");
		}
		private function addVideoTag(ctime:uint,uname:String,dispName:String,fileName:String):void
		{
				if(Log.isDebug()) logger.debug(" In addVideoTag. Adding xml Tag. File name:"+fileName);
				var xml:XML=<video></video>
				xml.@stime=ctime;
				xml.@uname=uname;
				xml.@displyname=dispName;
				xml.@src=fileName;
				if(ClassroomContext.aviewClass.videoCodec!="VP6")
				{
					var tempUname:String=uname;
					if(tempUname.search("_VIEWER")>0)
						tempUname=tempUname.substr(0,tempUname.lastIndexOf("_VIEWER"));
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(tempUname).isAudioOnlyMode == null)
					{
						xml.@isAudioOnly="false";
					}
					else
					{
						xml.@isAudioOnly=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(tempUname).isAudioOnlyMode.toString();
					}
				}
				videoXml.appendChild(xml);
			
		}
		public function addEndtime(ctime:uint,uname:String):void
		{
			var videoTagIndex:int=videoXml.video.length();
			if(videoTagIndex>0 && uname==currentrecordingStream && uname != "")
			{
				if(Log.isDebug()) logger.debug(" In addEndtime. Adding xml endtime. currentrecordingUser:"+currentrecordingStream);
				videoXml.video[videoTagIndex-1].@etime=ctime;
				if(!isInternalSaving)
					streamCopyingList.push(uname);
				copyVideoFile();
				if(!isInternalSaving)
					currentrecordingStream="";
			}
		}
		
		private function uploadVideoFile():void
		{
			var videoFile:File;
			var videoFileStream:FileStream;
			var FILE_LOCATION:String=File.applicationStorageDirectory.nativePath+"/Recording/temp/"; 
			
			if(videoXml.name() == "presenter")
				videoFile=new File(FILE_LOCATION+"pVideo.xml");
			else
				videoFile=new File(FILE_LOCATION+"vVideo.xml");
			
				videoFileStream = new FileStream();
				
				videoFileStream.open(videoFile,FileMode.WRITE);
				videoFileStream.writeUTFBytes("<?xml version=\"1.0\" encoding=\"utf-8\"?>"+ videoXml);
				//fs.writeBytes(biteArray,0,biteArray.length); 
				videoFileStream.close();
			
			var tempPath:String="AVContent/Record/"+ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId
				+"/"+ClassroomContext.lecture.lectureId;
			videoFile.addEventListener(Event.COMPLETE,deleteTempFile);
			videoFile.addEventListener(IOErrorEvent.IO_ERROR,deleteTempFile);
			videoFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR,deleteTempFile);
			var url:String=encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP + "/AVScript/Common/upload.php?folderPath="+ tempPath);
			videoFile.upload(new URLRequest(url));

		}
		
		private function deleteTempFile(evnt:Event):void
		{
			evnt.target.deleteFile();
		}
		
			/**
		 * This method is called from stopRecordVideo() method. 
		 * The method copys the recorded video file from FMS/stream directory to playback video folder i.e www/RecordFilesAview/Video in WAMP Server.
		 * 
		 * @return void 
		 */
		private function copyVideoFile():void
		{
			var isF4V:Boolean = (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264);
			var source:String;
			var destination:String
			
			if(isF4V)
			{
				source =currentrecordingStream+".f4v";
			}
			else
			{
				source =currentrecordingStream+".flv";
			}
			
			var sourceFolderName:String = "";
			
			if(ClassroomContext.aviewClass.classType == "Meeting")
			{
				sourceFolderName = ClassroomContext.lecture.lectureId+"_"+ClassroomContext.aviewClass.classId;
			}
			else
			{
				sourceFolderName = ClassroomContext.aviewClass.className+"_"+ClassroomContext.aviewClass.classId;
			}

			
			destination=currentRecordingFileName;
			videoFileCopyService=new HTTPService();
			videoFileCopyService.addEventListener(ResultEvent.RESULT,VideoCopyResultHandler);
			videoFileCopyService.addEventListener(FaultEvent.FAULT,VideoCopyFaultHandler); 
			var tempFolderPath:String=ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId+"/"+ClassroomContext.lecture.lectureId;
			videoFileCopyService.url=encodeURI("http://"+this.recordingServerIP+":"+ClassroomContext.portWAMP+"/AVScript/Record/copyVideoFile.php?sourceFile="+source+
				"&destinationFile="+destination+"&folderPath="+tempFolderPath+"&classname="+sourceFolderName);
			if(Log.isDebug()) logger.debug(" In copyVideoFile- Copy url: "+videoFileCopyService.url);
			if(isVideoReconnected)
			{
				if(Log.isDebug()) logger.debug(" In copyVideoFile-Video reconnected case.");
			}
			videoFileCopyService.send();
		}
		private function VideoCopyResultHandler(evnt:ResultEvent):void
		{
			videoFileCopyService.removeEventListener(ResultEvent.RESULT,VideoCopyResultHandler);
			videoFileCopyService.removeEventListener(FaultEvent.FAULT,VideoCopyFaultHandler);
			if(Log.isDebug()) logger.debug(" In VideoCopyResultHandler. Status: "+evnt.result.results.status);
			
			if(evnt.result.results.status == "true" || evnt.result.results.status == true)
			{
				if(Log.isDebug()) logger.debug(" In VideoCopyResultHandler. Source File: "+evnt.result.results.sourseName
				+", Destination File:"+evnt.result.results.destinationName+" , Size: "+evnt.result.results.size);
				var videoTagIndex:int=videoXml.video.length();
				for(var i:uint = videoTagIndex-1; i>=0; i--)
				{
					if(videoXml.video[i].@src == evnt.result.results.destinationName)
					{
						videoXml.video[i].@fileSize=evnt.result.results.size;
						uploadVideoFile();
						break;
						
					}
				}
				
				
				var tempStr:String=evnt.result.results.sourseName;
				tempStr=tempStr.substr(0,tempStr.length-4);
				streamCopyingList.splice(streamCopyingList.lastIndexOf(tempStr),1);
				if(!isInternalSaving && !isVideoReconnected)
				{
					var isF4V:Boolean = (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264);
					nectConn.call("stopRecordStream",null,tempStr,isF4V);
					if(evnt.result.results.status == "true" || evnt.result.results.status == true)
					{
						var videpFileCopyEvent:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDED_VIDEO_COPY_COMPLETE); 
						dispatchEvent(videpFileCopyEvent)
					}
					else
					{
						var videpFileCopyErrorEvent:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDED_VIDEO_COPY_ERROR); 
						dispatchEvent(videpFileCopyErrorEvent)
					}
					
					//Added to avoid the null pointer reference
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp != null)
					{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnRecord.enabled==false)
						{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnRecord.enabled=true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.RecordIcon = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.StartRecordIcon;
						}
					}
					if(Log.isDebug())
					{
						logger.debug(" In VideoCopyResultHandler.User called stop recording for the stream: "+tempStr);
					}
				}
			}
			else
			{
				if(Log.isDebug()) logger.debug(" In VideoCopyResultHandler. Some error happened during recording. Please restart the recording.");
			}
			isVideoReconnected=false;
			isInternalSaving =false;
		}
		
		/**
		 * The method is called when a fault event is triggered from copyVideoFile()
		 * 
		 */
		private function VideoCopyFaultHandler(evnt:FaultEvent):void
		{
			if(Log.isDebug()) logger.debug(" In VideoCopyFaultHandler.");
			videoFileCopyService.removeEventListener(ResultEvent.RESULT,VideoCopyResultHandler);
			videoFileCopyService.removeEventListener(FaultEvent.FAULT,VideoCopyFaultHandler);
			streamCopyingList.splice(0,streamCopyingList.length);
			var videpFileCopyErrorEvent:RecordingStatus=new RecordingStatus(RecordingStatus.RECORDED_VIDEO_COPY_ERROR); 
			dispatchEvent(videpFileCopyErrorEvent)
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp != null)
			{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnRecord.enabled==false)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnRecord.enabled=true;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.RecordIcon = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.StartRecordIcon;
				}
			}
			isVideoReconnected=false;
			isInternalSaving =false;
		}
		

	}
}
