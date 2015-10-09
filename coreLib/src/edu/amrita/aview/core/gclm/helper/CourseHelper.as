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
 * File			: CourseHelper.as
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
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.CourseVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class CourseHelper extends AbstractHelper
	{
		private var courseHelperRO:RemoteObject=null;
		
		public function CourseHelper()
		{
			courseHelperRO=new RemoteObject();
			courseHelperRO.destination="coursehelper";
			courseHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			courseHelperRO.showBusyCursor=true;
			
			courseHelperRO.getCourseCount.addEventListener(ResultEvent.RESULT, getCourseCountResultHandler);
			courseHelperRO.getCourseCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.getCourse.addEventListener(ResultEvent.RESULT, getCourseByIdResultHandler);
			courseHelperRO.getCourse.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.getActiveCourses.addEventListener(ResultEvent.RESULT, getActiveCoursesResultHandler);
			courseHelperRO.getActiveCourses.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.getActiveCoursesByAdmin.addEventListener(ResultEvent.RESULT, getActiveCoursesResultHandler);
			courseHelperRO.getActiveCoursesByAdmin.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.getActiveCoursesForUser.addEventListener(ResultEvent.RESULT, getActiveCoursesResultHandler);
			courseHelperRO.getActiveCoursesForUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.searchCourse.addEventListener(ResultEvent.RESULT, searchCourseResultHandler);
			courseHelperRO.searchCourse.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.createCourse.addEventListener(ResultEvent.RESULT, createCourseResultHandler);
			courseHelperRO.createCourse.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.updateCourse.addEventListener(ResultEvent.RESULT, updateCourseResultHandler);
			courseHelperRO.updateCourse.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			courseHelperRO.deleteCourse.addEventListener(ResultEvent.RESULT, deleteCourseResultHandler);
			courseHelperRO.deleteCourse.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 * @public
		 * Function :To get CourseCount
		 * @param institudeId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getCourseCount(institudeId:Number ,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.getCourseCount(institudeId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get course by courseId 
		 * @param courseId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function courseById(courseId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.getCourse(courseId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Active Courses
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getActiveCourses(onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.getActiveCourses();
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Active Courses by adminId
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getActiveCoursesByAdmin(adminId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.getActiveCoursesByAdmin(adminId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Active Courses for user
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getActiveCoursesForUser(userId:Number , onResult :Function , onFault :Function=null):void
		{
			var token:AsyncToken=courseHelperRO.getActiveCoursesForUser(userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To search for course
		 * @param courseName of type String
		 * @param courseCode of type String
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param adminId of type Number
		 * @param onFault of type Function
		 * 
		 */
		public function searchCourse(courseName:String, courseCode:String, instituteId:Number, onResult :Function, adminId:Number=0 , onFault :Function = null):void
		{
			var token:AsyncToken=null;
			//NPCR : use conditional operator
			if (adminId != 0)
			{
				token=courseHelperRO.searchCourse(courseName, courseCode, instituteId, adminId);
			}
			else
			{
				token=courseHelperRO.searchCourse(courseName, courseCode, instituteId);
			}
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete course
		 * @param courseId of type Number
		 * @param updatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteCourse(courseId:Number, updatorId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.deleteCourse(courseId, updatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To create course
		 * @param courseVO of type CourseVO
		 * @param creatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createCourse(courseVO:CourseVO, creatorId:Number, onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.createCourse(courseVO, creatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To update Course
		 * @param courseVO of type  CourseVO
		 * @param updaterId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function updateCourse(courseVO:CourseVO, updaterId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=courseHelperRO.updateCourse(courseVO, updaterId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getCourseCount
		 * @param event of type ResultEvent
		 * 
		 */
		private function getCourseCountResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getCourseById
		 * @param event of type ResultEvent
		 * 
		 */
		private function getCourseByIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as CourseVO);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getActiveCourses
		 * @param event of type ResultEvent
		 * 
		 */
		private function getActiveCoursesResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event.result);		
		}
	
		/**
		 * @private
		 * Function :ResultHandler for searchCourse
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchCourseResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for deleteCourse
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteCourseResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
			
		/**
		 * @private
		 * Function :ResultHandler for createCourse
		 * @param event of type ResultEvent
		 * 
		 */
		private function createCourseResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for updateCourse
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateCourseResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}		
	}
}