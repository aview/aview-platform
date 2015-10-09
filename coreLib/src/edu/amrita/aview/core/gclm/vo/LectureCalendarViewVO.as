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
 * File			: LectureCalendarViewVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Lecture Calender View
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import com.keepcore.calendar.CalendarObjectSample;
	
	public class LectureCalendarViewVO extends CalendarObjectSample
	{
		/**
		 * The item id
		 */
		public var itemID:int;
		/**
		 * The class id
		 */
		public var classID:int;
		/**
		 * The course id
		 */
		public var courseID:int;
		/**
		 * The institute id
		 */
		public var instituteID:int;
		
		/**
		 * @public
		 * constructor
		 * @param lectureid type of int
		 * @param classid type of int
		 * @param courseid type of int
		 * @param instituteId type of int
		 */
		
		public function LectureCalendarViewVO(lectureid:int, classid:int, courseid:int, instituteId:int)
		{
			super();
			itemID=lectureid;
			classID=classid;
			courseID=courseid;
			instituteID=instituteId;
		}
	}
}
