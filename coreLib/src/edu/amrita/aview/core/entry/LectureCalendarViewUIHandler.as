import com.keepcore.calendar.utils.CalendarDateUtils;

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.components.ArrayCollectionExtended;
import edu.amrita.aview.core.gclm.helper.ClassHelper;
import edu.amrita.aview.core.gclm.helper.CourseHelper;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

[Bindable]
private var classesAC:ArrayCollection=new ArrayCollection();
[Bindable]
private var claslist:ArrayCollection=new ArrayCollection();
[Bindable]
private var coursesAC:ArrayCollection=new ArrayCollection();
[Bindable]
private var courses:ArrayCollection=new ArrayCollection();
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.InstituteHelper;
import edu.amrita.aview.core.shared.util.AViewStringUtil;
private var instituteHelper:InstituteHelper=null;
import mx.utils.StringUtil;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import flash.events.Event;
import edu.amrita.aview.core.gclm.vo.LectureCalendarViewVO;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.ClassroomContext;
import mx.logging.Log;
import mx.logging.ILogger;

[Bindable]
public var calendararray:ArrayCollectionExtended=new ArrayCollectionExtended;
private var classHelper:ClassHelper=null;
private var courseHelper:CourseHelper=null;
private var lectureHelper:LectureHelper=null;
[Bindable]
private var lecturesAC:ArrayCollection=new ArrayCollection();
private var reCheckData:Boolean=false;
/**
 * For Log API
 */
private var log:ILogger = Log.getLogger("aview.entry.LectureCalendarViewUIHandler.as");

private function initApp(event:Event):void {
	getCourseOfferingInstitutes();
	getClasses();
	getCourses();
	lectureHelper=new LectureHelper();
}

private function getCourseOfferingInstitutes():void {
	instituteHelper=new InstituteHelper();
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE) {
		instituteHelper.getAllCourseOfferingInstitutesForAdmin(this, ClassroomContext.userVO.userId);
	} else {
		instituteHelper.getAllCourseOfferingInstitutes(this);
	}
}

public function getAllCourseOfferingInstitutesResultHandler(institutes:ArrayCollection):void {
	if (institutes != null) {
		GCLMContext.sortSmartComboDataProvider(institutes, "instituteName");
		GCLMContext.allCourseOfferingInstitutesAC=institutes;
		if(Log.isInfo()) log.info("getAllCourseOfferingInstitutesResultHandler After array collection:" + new Date());
	} else {
		CustomAlert.error("Error occured while getting the institutes");
	}
	resetSearchItems();

}

private function getCourses():void {

	courseHelper=new CourseHelper();
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE) {
		courseHelper.getActiveCoursesByAdmin(this, ClassroomContext.userVO.userId);
	} else {
		courseHelper.getActiveCourses(this);
	}
	calendararray.removeAll();
}

private function getClasses():void {
	classHelper=new ClassHelper();
	if (ClassroomContext.userVO.role == Constants.ADMIN_TYPE) {
		classHelper.getActiveClassesByAdmin(this, ClassroomContext.userVO.userId);
	} else {
		classHelper.getActiveClasses(this);
	}
	calendararray.removeAll();
}

public function getActiveClassesResultHandler(classes:ArrayCollection):void {
	if (classes != null) {
		if (classes.length > 0) {
			GCLMContext.sortSmartComboDataProvider(classes, "className");
			classesAC=classes;
			claslist=classes;
		} else {
			CustomAlert.info("No classes are available");
		}
	}
	resetSearchItems();
}

public function getActiveCoursesResultHandler(courses:ArrayCollection):void {
	if (courses != null) {
		if (courses.length > 0) {
			GCLMContext.sortSmartComboDataProvider(courses, "courseName");
			coursesAC=courses;
			courses=courses;
		} else {
			CustomAlert.info("No courses are available");
		}
	}
	resetSearchItems();
}

private function resetSearchItems():void {
	cmbClassName.selectedItem=null;
	cmbClassName.filterString="";
	cmbCourseName.selectedItem=null;
	cmbCourseName.filterString="";
}

private function getCourse():void {
	courses=new ArrayCollection();
	ArrayCollectionUtil.copyData(courses, coursesAC);
	courses.filterFunction=filterByinstituteId;
	courses.refresh();
	resetSearchItems();
	calendararray.filterFunctions=[filterByinsId, filterBycoursesId, filterByclassId];
	calendararray.refresh();
}

private function filterByinstituteId(item:Object):Boolean {
	if (cmbInstitute.selectedItem != null && cmbInstitute.selectedItem.instituteId == item.instituteId) {
		return true;
	}
	if (item.courseId == -1) {
		return true;
	}
	return false;
}

private function getClass():void {
	claslist=new ArrayCollection();
	ArrayCollectionUtil.copyData(claslist, classesAC);
	claslist.filterFunction=filterByCourseId;
	claslist.refresh();
	calendararray.filterFunctions=[filterByinsId, filterBycoursesId, filterByclassId];
	calendararray.refresh();
}

private function classChangeHandler():void {
	calendararray.filterFunctions=[filterByinsId, filterBycoursesId, filterByclassId];
	calendararray.refresh();
}

private function filterByCourseId(item:Object):Boolean {
	if (cmbCourseName.selectedItem != null && cmbCourseName.selectedItem.courseId == item.courseId) {
		return true;
	}
	if (item.classId == -1) {
		return true;
	}
	return false;
}

private function getLecture():void {
	var classId:Number;
	var courseId:Number;
	var instituteId:Number;
	if (cmbClassName.selectedItem == null) {
		classId=0;
	} else {
		classId=cmbClassName.selectedItem.classId;
	}
	if (cmbCourseName.selectedItem == null) {
		courseId=0;
	} else {
		courseId=cmbCourseName.selectedItem.courseId;
	}
	if (cmbInstitute.selectedItem == null) {
		instituteId=0;
	} else {
		instituteId=cmbInstitute.selectedItem.instituteId;
	}
	lectureHelper.getLectures(this, ClassroomContext.userVO.userId, classId, courseId, instituteId, kccal.visibleRange.startDate, kccal.visibleRange.endDate);

}

public function getLecturesResultHandler(lectures:ArrayCollection):void {
	var tempCalendararray:ArrayCollectionExtended=new ArrayCollectionExtended();
	calendararray.removeAll();
	var min_hour:Number;
	var sample:LectureCalendarViewVO;
	lecturesAC.removeAll();
	var someColor:String=new String();
	if (lectures != null) {
		if (lectures.length > 0) {
			lecturesAC=lectures;
			for (var i=0; i < lecturesAC.length; i++) {
				var StartTime:Date=new Date();
				var EndTime:Date=new Date();

				var s_date:Date=lecturesAC.getItemAt(i).lecture.startDate;
				var s_d:String=s_date.date.toString();
				var s_m:String=s_date.month.toString();
				var s_y:String=s_date.fullYear.toString();

				var s_time:Date=lecturesAC.getItemAt(i).lecture.startTime;
				var s_hr:String=s_time.hours.toString();
				var s_min:String=s_time.minutes.toString();

				if (Number(s_hr) < min_hour) {
					min_hour=Number(s_hr);
				}

				var e_date:Date=lecturesAC.getItemAt(i).lecture.startDate;
				var e_d:String=e_date.date.toString();
				var e_m:String=e_date.month.toString();
				var e_y:String=e_date.fullYear.toString();

				var e_time:Date=lecturesAC.getItemAt(i).lecture.endTime;
				var e_hr:String=e_time.hours.toString();
				var e_min:String=e_time.minutes.toString();

				StartTime.setHours(s_hr, s_min);
				StartTime.setFullYear(s_y, s_m, s_d);
				EndTime.setFullYear(e_y, e_m, e_d);
				EndTime.setHours(e_hr, e_min);
				sample=new LectureCalendarViewVO(lectures.getItemAt(i).lectureId, lectures.getItemAt(i).classId, lectures.getItemAt(i).courseId, lectures.getItemAt(i).instituteId);
				//Random color display 
				/*var myColor:Number = Math.round( Math.random()*0xFFFFFF );
				someColor = "0x"+myColor.toString(myColor);
				sample.color=someColor;*/
				sample.color=0x887700;
				sample.startTime=StartTime;
				sample.endTime=EndTime;
				sample.title=lectures.getItemAt(i).lecture.lectureName; //Gives Teacher name
				sample.label=lectures.getItemAt(i).lecture.className;
				sample.readOnly=true;
				sample.courseID=lectures.getItemAt(i).course.courseId;
				sample.classID=lectures.getItemAt(i).aviewClass.classId;
				sample.instituteID=lectures.getItemAt(i).course.instituteId;
				toolTipFunction(sample); //calling custom tooltip
				tempCalendararray.addItem(sample);
			}
			calendararray=tempCalendararray;
		} else {
			CustomAlert.info("No lectures found for the given criteria");
		}
	}
}

public function toolTipFunction(item:Object):String {
	var ret:String;
	if (kccal.isDayView())
		ret="Lecture Name : " + item.label + "\nLecturer Name : " + item.title;
	else if (kccal.isYearView())
		ret=item.label + "" + item.title;
	else {
		var s_min:String=item.startTime.getMinutes(), e_min:String=item.endTime.getMinutes();
		if (item.startTime.getMinutes() < 10)
			s_min="0" + item.startTime.getMinutes();
		if (item.endTime.getMinutes() < 10)
			e_min="0" + item.endTime.getMinutes();
		ret="Lecture Name : " + item.label + "\nStart Time : " + item.startTime.date + " " + CalendarDateUtils.getMonthAndYearToString(item.startTime) + " " + item.startTime.getHours() + ":" + s_min + "\nEnd Time : " + item.endTime.date + " " + CalendarDateUtils.getMonthAndYearToString(item.endTime) + " " + item.endTime.getHours() + ":" + e_min + "\nLecturer Name : " + item.title;
	}
	return ret;
}

protected function KccalCreationCompleteHandler(event:FlexEvent):void {
	lectureHelper.getLectures(this, ClassroomContext.userVO.userId, 0, 0, 0, kccal.visibleRange.startDate, kccal.visibleRange.endDate);
}

private function filterBycoursesId(item:Object):Boolean {
	if (cmbCourseName.selectedItem == null || cmbCourseName.selectedItem.courseId == -1 || item.courseID == cmbCourseName.selectedItem.courseId) {
		return true;
	}
	return false;
}

private function filterByclassId(item:Object):Boolean {
	if (cmbClassName.selectedItem == null || cmbClassName.selectedItem.classId == -1 || item.classID == cmbClassName.selectedItem.classId) {
		return true;
	}
	return false;
}

private function filterByinsId(item:Object):Boolean {
	if (cmbInstitute.selectedItem == null || cmbInstitute.selectedItem.instituteId == -1 || item.instituteID == cmbInstitute.selectedItem.instituteId) {
		return true;
	}
	return false;
}
