import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.entry.SessionEntry;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.gclm.vo.LectureListVO;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.eventmap.EventMap;
import edu.amrita.aview.core.shared.util.AViewStringUtil;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.utils.StringUtil;

import objectResolver.EntryFac;

[Bindable]
public var todaysLectures:ArrayCollection;
[Bindable]
private var todaysLecturesList:ArrayList;

private var reCheckData:Boolean=false;

private var sessionRetrievalTimer:Timer=null;

[Bindable]
public var liveSesions:ArrayCollection=new ArrayCollection;
[Bindable]
public var upComingSessions:ArrayCollection=new ArrayCollection;
[Bindable]
public var expiredSessions:ArrayCollection=new ArrayCollection;

public function getTodaysLectures(event:Event=null):void {
	var lectureHelper:LectureHelper=new LectureHelper();
	applicationType::web {
		//SSO - Passing Lecture ID to invoke datagrid double click process function
		//Fix for issue #20426
		if(ClassroomContext.classStartedFlag == false){
			//For Guest Login
			if (FlexGlobals.topLevelApplication.mainApp.ssoMode == Constants.guestLogin){
				sessionEntry = new SessionEntry();
				sessionEntry.getClassRoomLecture(FlexGlobals.topLevelApplication.parameters.lrid);
			}//For Direct class entry
			else if (FlexGlobals.topLevelApplication.mainApp.ssoMode == Constants.classEntry) {
				sessionEntry = new SessionEntry();
				sessionEntry.getClassRoomLecture(FlexGlobals.topLevelApplication.parameters.lrid);
			} else {
				lectureHelper.getTodaysLectures(getTodaysLecturesResultHandler);
			}
		}
	}
	applicationType::DesktopMobile {
		lectureHelper.getTodaysLectures(getTodaysLecturesResultHandler);
	}
}

public function getTodaysLecturesResultHandler(lectureListVOs:ArrayCollection):void 
{

	liveSesions=new ArrayCollection();
	upComingSessions=new ArrayCollection();
	expiredSessions=new ArrayCollection();
	applicationType::mobile
	{
		todaysLectures = new ArrayCollection();
		todaysLectures.removeAll() ;
	}
	
	var i:int;
	
	if (lectureListVOs.length == 0)
	{
		applicationType::DesktopWeb
		{
			Alert.show("You do not have any registered sessions to enter right now.");
		}
		
		applicationType::mobile
		{
			MessageBox.show("You do not have any registered classes to enter right now.", "Information", MessageBox.MB_OK, this.parent, null, null, MessageBox.IC_INFO) ;
		}
	}
	else
	{
		for (i=0; i < lectureListVOs.length; i++)
		{
			var lectureListVO:LectureListVO=LectureListVO(lectureListVOs.getItemAt(i));
			var cls:ClassVO=lectureListVO.aviewClass;
			
			if (cls.maxStudents == -1 || cls.maxStudents == 0)
			{
				lectureListVO.displyMaxStudents=Constants.UNLIMITED;
			}
			else
			{
				lectureListVO.displyMaxStudents=cls.maxStudents;
			}
			
			if (cls.maxPublishingBandwidthKbps == -1 || cls.maxPublishingBandwidthKbps == 0)
			{
				lectureListVO.displyMaxPublishingBandwidthKbps=Constants.UNLIMITED;
			}
			else
			{
				lectureListVO.displyMaxPublishingBandwidthKbps=cls.maxPublishingBandwidthKbps;
			}
			
			if (cls.minPublishingBandwidthKbps == -1 || cls.minPublishingBandwidthKbps == 0)
			{
				lectureListVO.displyMinPublishingBandwidthKbps=Constants.UNLIMITED;
			}
			else
			{
				lectureListVO.displyMinPublishingBandwidthKbps=cls.minPublishingBandwidthKbps;
			}
			applicationType::DesktopWeb
			{
				
				//Fix for 17019 start
				//Manual Merging code from 3.1 branch rev 10994 start
				
				/*
				var startTime:Number = getHHMMSSTime(lectureListVO.lecture.startTime);
				var currentTime:Number = getHHMMSSTime(lectureListVO.currentTime);
				var endTime:Number = getHHMMSSTime(lectureListVO.lecture.endTime);
				*/
				
				setMilliSecondsToZero(lectureListVO.lecture.startTime);
				setMilliSecondsToZero(lectureListVO.currentTime);
				setMilliSecondsToZero(lectureListVO.lecture.endTime);
				//Fix for Bug 18783 :Start
				var TWO_HOURS_IN_MILLISECONDS:Number = 2 * 60 * 60 * 1000;
				var startTimeMinus2Hours:Date = new Date;
				startTimeMinus2Hours.time = lectureListVO.lecture.startTime.time - TWO_HOURS_IN_MILLISECONDS;
				//Meeting also starts 2 hours before but ends at the time when moderator 
				if(cls.classType=="Meeting")
				{
					//Bugfix for 17850 starts
					if (startTimeMinus2Hours <= lectureListVO.currentTime && lectureListVO.lecture.endTime >= lectureListVO.currentTime) //Live Sessions
					{
						liveSesions.addItem(lectureListVOs[i]);
					}
					else if (startTimeMinus2Hours > currentTime) //Upcoming Sessions
					{
						upComingSessions.addItem(lectureListVOs[i]);
					}
					else if (lectureListVO.lecture.endTime < currentTime) //Expired Sessions
					{
						expiredSessions.addItem(lectureListVOs[i]);
					}
					//Bugfix for 17850 ends
				}
				else
				{
					//Fix for Bug#17483, 18783:Start 
					//Live Session will have lectures 2 hours before its start time and 2 hours after its end time.					
					var currentTime:Date = lectureListVO.currentTime;
					var endTimePlus2Hours:Date = new Date;
					endTimePlus2Hours.time = lectureListVO.lecture.endTime.time + TWO_HOURS_IN_MILLISECONDS;
					//Manual Merging code from 3.1 branch rev 10994 end
					//Fix for 17019 end
					if (startTimeMinus2Hours <= currentTime && endTimePlus2Hours >= currentTime) //Live Sessions
					{
						liveSesions.addItem(lectureListVOs[i]);
					}
					else if (startTimeMinus2Hours > currentTime) //Upcoming Sessions
					{
						upComingSessions.addItem(lectureListVOs[i]);
					}
					else if (endTimePlus2Hours < currentTime) //Expired Sessions
					{
						expiredSessions.addItem(lectureListVOs[i]);
					}
					//Fix for Bug#17483, 18783:End
				}
			}
		}
		applicationType::DesktopWeb
		{
			dataGrid.addEventListener("updateFailed", callingFromItemR);
			var searchString:String=txtClassFilter.text.toLowerCase();
			if(searchString!="" && searchString!="enter session to filter")
			{
				filterResults();
			}
		}
	}
	applicationType::DesktopWeb{ 
		todaysLectures=lectureListVOs;
		todaysLectures.refresh();
	} 
	applicationType::mobile{
		var obj:Object;
		for (var j:int=0; j < lectureListVOs.length; j++) 
		{
			var lectureListsVO:LectureListVO=LectureListVO(lectureListVOs.getItemAt(j));
			var classVO:ClassVO=lectureListsVO.aviewClass;
			if(classVO.classType!="Meeting"){
				obj=new Object();
				obj=lectureListVOs[j];
				obj.className=lectureListVOs[j].aviewClass.className;
				todaysLectures.addItem(obj);
			}
		}
	}
}

private function getHHMMSSTime(date:Date):Number
{
	//Fix for 17019 start
	//Manual Merging code from 3.1 branch rev 10994 start
	//date.setFullYear(0,0,0);
	var currentDate:Date = new Date();
	date.date = currentDate.date;
	date.month = currentDate.month;
	date.fullYear = currentDate.fullYear;
	date.setMilliseconds(0);
	return date.time;
	//Manual Merging code from 3.1 branch rev 10994 start end
	//Fix for 17019 end
}

private function setMilliSecondsToZero(date:Date):void
{
	date.setMilliseconds(0);				
}

private function focusOutFilterText():void
{
	applicationType::DesktopWeb{
		if (txtClassFilter.text == "")
		{
			txtClassFilter.text="Enter session to filter";
			txtClassFilter.setStyle("color", '#939393');
		}
	}
}

private function clearClick():void
{
	applicationType::DesktopWeb{
		if (txtClassFilter.text == "Enter session to filter")
		{
			txtClassFilter.text="";
			txtClassFilter.setStyle("color", '#000000');
		}
	}
}

private function filterResults():void
{
	applicationType::DesktopWeb{
		liveSesions.filterFunction=filterMyArrayCollection;				
		upComingSessions.filterFunction=filterMyArrayCollection;				
		expiredSessions.filterFunction=filterMyArrayCollection;
		
		liveSesions.refresh();
		upComingSessions.refresh();
		expiredSessions.refresh();
	}
}
public function joinToSession(event:Event):void
{
	//Fix for Bug#17644
	stopSessionRetrievalTimer();
	listDoubleClickHandler();
}


public function initApp(event:Event):void 
{
	var delay:Number=3 * 60 * 1000;
	sessionRetrievalTimer=new Timer(delay);
	sessionRetrievalTimer.addEventListener(TimerEvent.TIMER, getTodaysLectures);
	sessionRetrievalTimer.start();
	getTodaysLectures();
	applicationType::DesktopWeb{
		dataGrid.addEventListener("joinNow", joinToSession);
		if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE || ClassroomContext.userVO.role == Constants.STUDENT_TYPE) {
			maxStudentColumn.visible=false;
			minBWColumn.visible=false;
			maxBWColumn.visible=false;
		}
	}
	
}
public function registerApplicationEvents(appEventMap:EventMap):void
{
	appEventMap.registerMapListener(EntryFac.CLOSE_INVITATION,onCloseInvitation);
}
private function onCloseInvitation(event:Event):void
{
	refresh();
}


applicationType::DesktopWeb{
	private function filterMyArrayCollection(item:Object):Boolean {
		var searchString:String=txtClassFilter.text.toLowerCase();
		//Fix for Bug #14190 start
		//Changed the filtering criteria to use lecture display name instead of class name
		var className:String=(item.lecture.displayName as String).toLowerCase();
		if(item.aviewClass.classType=="Meeting")
		{
			className=(item.lecture.displayName as String).toLowerCase();
		}
		//Fix for Bug #14190 end
			return className.indexOf(searchString) > -1;
	}
}



private function course_mycalendar():void {

}

private function callingFromItemR(event:Event):void
{
	initApp(new Event(" not updated class"));
}

public function clearClassSearchFilter():void {
	applicationType::DesktopWeb{
		var classFilter:String;
		classFilter=txtClassFilter.text;
	
		if (classFilter == Constants.CLASS_SEARCH_STR) {
			txtClassFilter.text="";
			txtClassFilter.setStyle("color", 0x060606);
		} else {
			if (StringUtil.trim(classFilter) == null || StringUtil.trim(classFilter) == "") {
				//		CustomAlert.error("Empty class filter search.") ;
				txtClassFilter.setFocus();
			} else {
				txtClassFilter.text=StringUtil.trim(classFilter);
			}
		}
	}
}

private function btn_keyBoardStroke(event:KeyboardEvent):void {
	//applicationType::DesktopWeb{
		if ((event.keyCode == Keyboard.ENTER) || (event.keyCode == Keyboard.SPACE)) {
			listDoubleClickHandler();
			event.stopImmediatePropagation();
		//}
	}
}

private function refresh():void
{
	var lectureHelper:LectureHelper=new LectureHelper();
	lectureHelper.getTodaysLectures(getTodaysLecturesResultHandler);
}

protected function refreshBtnMouseOverHandler(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		lectureRefreshIcon=lectureRefreshOver_Icon;
	}
}

protected function refreshBtnMouseOutHandler(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		lectureRefreshIcon=lectureRefresh_Icon;
	}
}
//Fix for Bug#17644:Start
/**
 * @Public
 * To stop sessionRetrievalTimer
 * If not this timer function will call after every 3 minutes.
 * @return void
 */
public function stopSessionRetrievalTimer():void
{
	if(sessionRetrievalTimer && sessionRetrievalTimer.running)
	{
		sessionRetrievalTimer.removeEventListener(TimerEvent.TIMER,getTodaysLectures);
		sessionRetrievalTimer.stop();
	}
}
//Fix for Bug#17644:End