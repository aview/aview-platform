package edu.amrita.aview.entry
{
	import com.keepcore.calendar.CalendarObjectSample;
	
	public class MyCalendarObjectSample extends CalendarObjectSample
	{
		public var itemID:int;
		public var classID:int;
		public var courseID:int;
		public var instituteID:int;
		
		public function MyCalendarObjectSample(lectureid:int, classid:int, courseid:int, instituteId:int)
		{
			super();
			itemID=lectureid;
			classID=classid;
			courseID=courseid;
			instituteID=instituteId;
		}
	}
}
