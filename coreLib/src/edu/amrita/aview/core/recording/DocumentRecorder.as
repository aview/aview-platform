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
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.rpc.http.mxml.HTTPService;
	
	internal class DocumentRecorder
	{
		public var docXml:XML
		private var p2fWidth:Number=0;
		private var p2fHight:Number=0;
		private var recordingFolder:String;
		public function DocumentRecorder()
		{
			
			docXml=<document></document>
			recordingFolder="/"+ClassroomContext.institute.instituteId+"/"+ClassroomContext.course.courseId+"/"+ClassroomContext.aviewClass.classId
				+"/"+ClassroomContext.lecture.lectureId+"/Contents";
			
		}
		public function addDocLoadedTag(ctime:uint,src:String,type:String,orginalName:String):void
		{
			var tempDate:Date;
			p2fHight=0;
			p2fWidth=0;
			var xml:XML=<docloaded></docloaded>;
			var tempPath:String = src;
			src=src.substring(src.search("/")+1);
			if(tempPath.slice(0,3) == "../")
				src=src.substring(src.search("/"));
			else
				src = "/"+src;
			/*src=src.substring(src.search("/")+1);
			src=src.substring(src.search("/"));
			src=src.substring(src.search("/")+1);
			src=src.substring(src.search("/"));*/
			tempDate = new Date();
			var timeStamp:String=tempDate.time.toString();
			xml.@ctime=ctime;
			xml.@src=src.substr(0,src.lastIndexOf(".")+1)+timeStamp+src.substr(src.lastIndexOf("."));;
			xml.@type=type;
			xml.@orginalName=orginalName;
			docXml.appendChild(xml);
			tempDate = new Date();
			var sourceFileName:String=src.substring(src.lastIndexOf("/")); 
			var destinationFileName:String=sourceFileName.substr(0,sourceFileName.lastIndexOf(".")+1)+timeStamp+sourceFileName.substr(sourceFileName.lastIndexOf("."));
			src=src.substring(0,src.lastIndexOf("/"));			
			var createServerSideFolderService:HTTPService=new HTTPService();
			
				createServerSideFolderService.url=encodeURI("http://" + ClassroomContext.CONTENT_RECORD_SERVER+":"+ClassroomContext.portWAMP + "/AVScript/Record/" + 
						"copyDocument.php?recordingFolder="+recordingFolder+
						"&sourceFileName="+sourceFileName+"&destinationFileName="+destinationFileName+"&orginalFileName="+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.remoteFileName+"&commonPath="+src);
				
			createServerSideFolderService.send();
		}
		public function addSizeTag(ctime:uint,maxx:Number,maxy:Number,width:Number,height:Number,zoomfactorX:Number,zoomfactorY:Number,scrollX:Number,scrollY:Number):void
		{
			var docloadedIntex:int=docXml.docloaded.length()-1;
			var sizeTagIntex:int=docXml.docloaded[docloadedIntex].size.length()-1;
			if(p2fWidth!=width||p2fHight!=height || sizeTagIntex < 0)
			{
				p2fHight=height;
				p2fWidth=width;
				var xml:XML=<size></size>
				xml.@ctime=ctime;
				xml.@maxx=maxx;
				xml.@maxy=maxy;
				xml.@scrollX=scrollX;
				xml.@scrollY=scrollY;
				xml.@width=width;
				xml.@height=height;
				xml.@zoomfactorX=zoomfactorX;
				xml.@zoomfactorY=zoomfactorY;
				var docloadedIntex:int=docXml.docloaded.length()-1;
				docXml.docloaded[docloadedIntex].appendChild(xml);
			}
		}
		public function addPageEvent(ctime:uint,pageNo:int):void
		{
			var xml:XML=<event></event>
			xml.@action="page";
			xml.@ctime=ctime;
			xml.@pageno=pageNo;
			addEventTag(xml);
			
		}
		public function addScrollEvent(ctime:uint,scrollDirction:String,scrollPosition:Number):void
		{
			var xml:XML=<event></event>
			xml.@action="scroll";
			xml.@ctime=ctime;
			xml.@scrollDirction=scrollDirction;
			xml.@scrollPosition=scrollPosition;
			addEventTag(xml);
		}
		public function addZoomEvent(ctime:uint,zoomX:Number,zoomY:Number,maxx:Number,maxy:Number):void
		{
			var xml:XML=<event></event>
			xml.@action="zoom";
			xml.@ctime=ctime;
			xml.@zoomX=zoomX;
			xml.@zoomY=zoomY;
			xml.@maxx=maxx;
			xml.@maxy=maxy;
			addEventTag(xml);
		}
		public function addRotateEvent(ctime:uint,value:uint):void
		{
			var xml:XML=<event></event>
			xml.@action="rotation";
			xml.@ctime=ctime;
			xml.@value=value;
			addEventTag(xml);
		}
		public function addTabEvent(ctime:uint):void
		{
			var xml:XML=<event></event>
			xml.@action="tab";
			xml.@ctime=ctime;
			addEventTag(xml);
		}
		public function addUnloadEvent(ctime:uint):void
		{
			var xml:XML=<event></event>
			xml.@action="unload";
			xml.@ctime=ctime;
			addEventTag(xml);
		}
		public function addAnimationStepTag(ctime:uint,value:uint,pageNumber:uint):void
		{
			var xml:XML=<event></event>
			xml.@action="animation";
			xml.@ctime=ctime;
			xml.@value=value;
			xml.@pageno=pageNumber;
			addEventTag(xml);		
		}
		private function addEventTag(xml:XML):void
		{
			var docloadedIntex:int=docXml.docloaded.length()-1;
			var sizeTagIntex:int=docXml.docloaded[docloadedIntex].size.length()-1;
			docXml.docloaded[docloadedIntex].size[sizeTagIntex].appendChild(xml);
		}

	}
}
