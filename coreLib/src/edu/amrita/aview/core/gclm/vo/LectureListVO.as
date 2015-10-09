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
 * File			: LectureListVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Lecture List
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	
	
	//The remote java class file which is mapped with this VO class	
	//This class is declared as dynamic, since it uses some of the class 
	//variables which are not therer at the server side.
	[RemoteClass(alias="edu.amrita.aview.gclm.vo.LectureListVO")]
	public dynamic class LectureListVO
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function LectureListVO()
		{
		}
		/**
		 * The lecture object
		 */
		private var _lecture:LectureVO=null;
		/**
		 * The class object
		 */
		private var _aviewClass:ClassVO=null;
		/**
		 * The course object
		 */
		private var _course:CourseVO=null;
		/**
		 * The institute object
		 */
		private var _institute:InstituteVO=null;
		/**
		 * The class registration object
		 */
		private var _classRegistration:ClassRegisterVO=null;
		
		/**
		 * The server's current time
		 */
		private var _currentTime:Date=null;
		
		/**
		 * The name of the moderator for this lecture
		 */
		private var _moderatorName:String=null;
		/**
		 * @public
		 * function to get course
		 *
		 * @return CourseVO
		 */
		public function get course():CourseVO
		{
			return _course;
		}
		
		/**
		 * @public
		 * function to set course
		 * @param value type of CourseVO
		 * @return void
		 */
		public function set course(value:CourseVO):void
		{
			_course=value;
		}
		
		/**
		 * @public
		 * function to get aviewClass
		 *
		 * @return ClassVO
		 */
		
		public function get aviewClass():ClassVO
		{
			return _aviewClass;
		}
		
		/**
		 * @public
		 * function to set aviewClass
		 * @param value type of ClassVO
		 * @return void
		 */
		public function set aviewClass(value:ClassVO):void
		{
			_aviewClass=value;
		}
		
		/**
		 * @public
		 * function to get lecture
		 *
		 * @return LectureVO
		 */
		
		public function get lecture():LectureVO
		{
			return _lecture;
		}
		
		/**
		 * @public
		 * function to set lecture
		 * @param value type of LectureVO
		 * @return void
		 */
		public function set lecture(value:LectureVO):void
		{
			_lecture=value;
		}
		
		/**
		 * @public
		 * function to get institute
		 *
		 * @return InstituteVO
		 */
		
		public function get institute():InstituteVO
		{
			return _institute;
		}
		
		/**
		 * @public
		 * function to set institute
		 * @param value type of InstituteVO
		 * @return void
		 */
		public function set institute(value:InstituteVO):void
		{
			_institute=value;
		}
		
		/**
		 * @public
		 * function to get classRegistration
		 *
		 * @return ClassRegisterVO
		 */
		
		public function get classRegistration():ClassRegisterVO
		{
			return _classRegistration;
		}
		
		/**
		 * @public
		 * function to set classRegistration
		 * @param value type of ClassRegisterVO
		 * @return void
		 */
		public function set classRegistration(value:ClassRegisterVO):void
		{
			_classRegistration=value;
		}
		
		public function get currentTime():Date
		{
			return _currentTime;
		}
		
		public function set currentTime(value:Date):void
		{
			_currentTime = value;
		}
		
		public function get moderatorName():String
		{
			return _moderatorName;
		}
		
		public function set moderatorName(value:String):void
		{
			_moderatorName = value;
		}
	
	}
}
