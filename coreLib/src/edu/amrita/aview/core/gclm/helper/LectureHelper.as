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
 * File			: LectureHelper.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This helper class is used to call the remote java methods
 * 
 */
package edu.amrita.aview.core.gclm.helper
{
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.shared.vo.AViewResponseVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.LectureListVO;
	import edu.amrita.aview.core.gclm.vo.LectureVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import spark.modules.*;
	
	public class LectureHelper extends AbstractHelper
	{
		private var lectureRO:RemoteObject=null;
		
		public function LectureHelper()
		{
			lectureRO=new RemoteObject();
			lectureRO.destination="lecturehelper";
			lectureRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			lectureRO.showBusyCursor=true;
			
			lectureRO.getLectureCount.addEventListener(ResultEvent.RESULT, getLectureCountResultHandler);
			lectureRO.getLectureCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.getLecture.addEventListener(ResultEvent.RESULT, getLecturebyIdResultHandler);
			lectureRO.getLecture.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.getTodaysAllLectures.addEventListener(ResultEvent.RESULT, getTodaysLecturesResultHandler);
			lectureRO.getTodaysAllLectures.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.getClassRoomLectureByLectureId.addEventListener(ResultEvent.RESULT, getClassRoomLectureByLectureIdResultHandler);
			lectureRO.getClassRoomLectureByLectureId.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.getLecturesForClass.addEventListener(ResultEvent.RESULT, getLecturesForClassResultHandler);
			lectureRO.getLecturesForClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.createLecture.addEventListener(ResultEvent.RESULT, createLectureResultHandler);
			lectureRO.createLecture.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.updateLecture.addEventListener(ResultEvent.RESULT, updateLectureResultHandler);
			lectureRO.updateLecture.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.deleteLecture.addEventListener(ResultEvent.RESULT, deleteLectureResultHandler);
			lectureRO.deleteLecture.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.getLectures.addEventListener(ResultEvent.RESULT, getLecturesResultHandler);
			lectureRO.getLectures.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.deleteLectureRecording.addEventListener(ResultEvent.RESULT, deleteLectureRecordingResultHandler);
			lectureRO.deleteLectureRecording.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.getRecordedLectures.addEventListener(ResultEvent.RESULT, getRecordedLecturesResultHandler);
			lectureRO.getRecordedLectures.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			lectureRO.searchRecordedLectures.addEventListener(ResultEvent.RESULT, getRecordedLecturesResultHandler);
			lectureRO.searchRecordedLectures.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		
		}
	
		/**
		 * @public
		 * Function :To get LectureCount
		 * @param classId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getLectureCount(classId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.getLectureCount(classId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * 
		 * @param classId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getRecordedLectures(classId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken = lectureRO.getRecordedLectures(classId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * 
		 * @param classId of type Number
		 * @param title of type String
		 * @param keywords of type String
		 * @param date of type Date
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function searchRecordedLectures(classId:Number,title:String,keywords:String,date:Date,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken = lectureRO.searchRecordedLectures(classId,title,keywords,date);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get LecturebyId
		 * @param lectureId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getLecturebyId(lectureId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.getLecture(lectureId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Todays Lectures
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getTodaysLectures(onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.getTodaysAllLectures(ClassroomContext.userVO.userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get ClassRoom Lecture By LectureId
		 * @param lectureId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRoomLectureByLectureId(lectureId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.getClassRoomLectureByLectureId(ClassroomContext.userVO.userId, lectureId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Lectures for class
		 * @param classId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getLecturesForClass(classId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.getLecturesForClass(classId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete Lecture
		 * @param lectureId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteLecture(lectureId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.deleteLecture(lectureId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete Lecture Recording
		 * @param lectureId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteLectureRecording(lectureId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.deleteLectureRecording(lectureId, ClassroomContext.userVO.userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To create Lecture
		 * @param lectureVO of type LectureVO
		 * @param creatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createLecture(lectureVO:LectureVO, creatorId:Number,onResult:Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.createLecture(lectureVO, creatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To update Lecture
		 * @param lectureVO of type LectureVO
		 * @param updatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function updateLecture(lectureVO:LectureVO, updatorId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=lectureRO.updateLecture(lectureVO, updatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Lectures
		 * @param userId of type Number
		 * @param classId of type Number
		 * @param courseId of type Number
		 * @param instituteId of type Number
		 * @param startDate of type Date
		 * @param endDate of type Date
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getLectures(userId:Number, classId:Number, courseId:Number, instituteId:Number, startDate:Date, endDate:Date,onResult:Function ,onFault:Function = null):void
		{
			var token:AsyncToken=lectureRO.getLectures(userId, classId, courseId, instituteId, startDate, endDate);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getLectureCount
		 * @param event of type ResultEvent
		 * 
		 */
		private function getLectureCountResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as Number)
		}		
		
		/**
		 * Function :ResultHandler for getRecordedLectures
		 * @param event of type ResultEvent
		 * 
		 */
		private function getRecordedLecturesResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ArrayCollection)
		}			
		
		/**
		 * @private
		 * Function :ResultHandler for getLecturebyId
		 * @param event of type ResultEvent
		 * 
		 */
		private function getLecturebyIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as LectureVO)
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getTodaysLectures
		 * @param event of type ResultEvent
		 * 
		 */
		private function getTodaysLecturesResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ArrayCollection);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for  getClassRoomLectureByLectureId
		 * @param event of type ResultEvent
		 * 
		 */
		private function getClassRoomLectureByLectureIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as AViewResponseVO);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getLecturesForClass
		 * @param event of type ResultEvent
		 *
		 */
		private function getLecturesForClassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getLectures
		 * @param event of type ResultEvent
		 *
		 */
		private function getLecturesResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for deleteLecture
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteLectureResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for deleteLectureRecording
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteLectureRecordingResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for  createLecture
		 * @param event of type ResultEvent
		 * 
		 */
		//PNCR: send event.result and change caller function to recieve LectureVO object.
		private function createLectureResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for updateLecture
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateLectureResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}		
	}
}
