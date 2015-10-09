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
 * File			: CourseVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Course
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.Course")]
	public class CourseVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		public function CourseVO()
		{
		}
		/**
		 * The course id
		 */
		private var _courseId:Number=0;
		/**
		 * The course name
		 */
		private var _courseName:String=null;
		/**
		 * The course code
		 */
		private var _courseCode:String=null;
		
		/**
		 * The institute id
		 */
		private var _instituteId:Number=0;
		
		/**
		 * The institute name
		 */
		private var _instituteName:String=null;
		
		/**
		 * @public
		 * function to get courseId
		 *
		 * @return Number
		 */
		public function get courseId():Number
		{
			return _courseId;
		}
		
		/**
		 * @public
		 * function to set courseId
		 * @param courseId type of Number
		 * @return void
		 */
		public function set courseId(courseId:Number):void
		{
			this._courseId=courseId;
		}
		
		/**
		 * @public
		 * function to get courseName
		 *
		 * @return String
		 */
		[Bindable]
		public function get courseName():String
		{
			return _courseName;
		}
		
		/**
		 * @public
		 * function to set courseName
		 * @param courseName type of String
		 * @return void
		 */
		public function set courseName(courseName:String):void
		{
			this._courseName=courseName;
		}
		
		/**
		 * @public
		 * function to get courseCode
		 *
		 * @return String
		 */
		public function get courseCode():String
		{
			return _courseCode;
		}
		
		/**
		 * @public
		 * function to set courseCode
		 * @param courseCode type of String
		 * @return void
		 */
		public function set courseCode(courseCode:String):void
		{
			this._courseCode=courseCode;
		}
		
		/**
		 * @public
		 * function to get instituteName
		 *
		 * @return String
		 */
		public function get instituteName():String
		{
			return _instituteName;
		}
		
		/**
		 * @public
		 * function to set instituteName
		 * @param instituteName type of String
		 * @return void
		 */
		public function set instituteName(instituteName:String):void
		{
			this._instituteName=instituteName;
		}
		
		/**
		 * @public
		 * function to get instituteId
		 *
		 * @return Number
		 */
		public function get instituteId():Number
		{
			return _instituteId;
		}
		
		/**
		 * @public
		 * function to set instituteId
		 * @param instituteId type of Number
		 * @return void
		 *
		 */
		public function set instituteId(instituteId:Number):void
		{
			this._instituteId=instituteId;
		}
	}

}
