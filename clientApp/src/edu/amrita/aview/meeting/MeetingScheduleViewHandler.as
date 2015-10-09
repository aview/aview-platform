// ActionScript file
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.meeting.MeetingScheduleModel;
import edu.amrita.aview.meeting.events.MeetingEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.sampler.NewObjectSample;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;

import spark.events.TextOperationEvent;

private const emailId_regex:RegExp = /([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/;

[Embed(source="/edu/amrita/aview/meeting/assets/images/Medium_close.png")]
[Bindable]
public var closePng:Class;

[Embed(source="/edu/amrita/aview/meeting/assets/images/Medium_close_over.png")]
[Bindable]
public var closeOverPng:Class;

[Bindable]
private var disabledEndDate:Date=new Date();

[Bindable]
public var meetingScheduleModel:MeetingScheduleModel=null;

protected function onClickSave():void
{
	var guestUserMailIds:Array = new Array;
	if (StringUtil.trim(txtTitle.text) != "")
	{
		if(StringUtil.trim(txtIvite.text)!="")
		{
			var guestMailIds:Array=txtIvite.text.split(",");
			var emailId:String="";
			var isIncorrectEmailId:Boolean=false;
			for(var i:int=0;i<guestMailIds.length;i++)
			{
				emailId=guestMailIds[i];
				var patterns:Array=emailId.match(emailId_regex);
				if(patterns==null || patterns[0]!=emailId)
				{
					isIncorrectEmailId=true;
					break;
				}
				if(guestUserMailIds.indexOf(emailId) == -1)
				{
					guestUserMailIds.push(guestMailIds[i]);
				}
				else
				{
					trace('Mail id already exist');
				}
			}
			if(isIncorrectEmailId)
			{
				Alert.show("Please provide correct e-mailIds","Information");
				return;
			}
		}	
		if(!meetingScheduleModel.isScheduledMeeting && !meetingScheduleModel.isEditScheduledMeeting)
		{
			meetingScheduleModel.guestMailIds=new ArrayCollection(guestUserMailIds);
			this.dispatchEvent(new MeetingEvent(MeetingEvent.CREATE_ADHOC_MEETING,meetingScheduleModel));
		}
		else
		{
			if(meetingScheduleModel.isScheduledMeeting && !meetingScheduleModel.isEditScheduledMeeting)
			{
				if(validateDateTimes())
				{							
					meetingScheduleModel.guestMailIds=new ArrayCollection(guestUserMailIds);
					meetingScheduleModel.meetingName=StringUtil.trim(txtTitle.text);
					this.dispatchEvent(new MeetingEvent(MeetingEvent.CREATE_SCHEDULED_MEETING,meetingScheduleModel));
				}
			}
			else if(meetingScheduleModel.isEditScheduledMeeting)
			{
				if(validateDateTimes())
				{
					meetingScheduleModel.guestMailIds=new ArrayCollection(guestUserMailIds);							
					meetingScheduleModel.meetingName=StringUtil.trim(txtTitle.text);
					this.dispatchEvent(new MeetingEvent(MeetingEvent.EDIT_MEETING,meetingScheduleModel));
				}
			}						
		}
	}
	else
	{
		txtTitle.text="";
		Alert.show("Please enter the meeting title", "WARNING");
	}
}
private function validateDateTimes():Boolean
{
	var startDate:Date=null;				
	var endDate:Date=null;
	
	if(startDateField.selectedDate==null)
	{
		Alert.show("Please select the schedule start Date","Warning");
		return false;
	}
	else
	{
		startDate=startDateField.selectedDate;
	}
	if(endDateField.enabled )
	{
		if(endDateField.selectedDate==null)
		{
			Alert.show("Please select the schedule end Date","Warning");
			return false;
		}
		endDate=endDateField.selectedDate;
	}
	else
	{
		
		endDate=startDate;
	}
	if(recurringChkBox.selected)
	{
		if(startDate.time ==endDate.time)
		{
			Alert.show("End Date should be greater than Start Date","WARNING");
			return false;
		}
	}
	if(hoursStartClassa.value>12 ||hoursStartClassa.value<0)
	{
		Alert.show("Please check start Time","Warning");
		return false;
	}
	if(hoursEndClassa.value>12 || hoursEndClassa.value<0)
	{
		Alert.show("Please check end Time","Warning");
		return false;
	}
	var startTimeFactor:Number=0;
	var endTimeFactor:Number=0;
	if(amStartClassa.selected)
	{
		if(hoursStartClassa.value==12)
		{
			startTimeFactor=-12;
		}
		else
			startTimeFactor=0;
	}
	else
	{
		if(hoursStartClassa.value==12)
		{
			startTimeFactor=0;
		}
		else
			startTimeFactor=12;
	}
	if(amEndClassa.selected)
	{
		if(hoursEndClassa.value==12)
		{
			endTimeFactor=-12;
		}
		else
			endTimeFactor=0;
	}
	else
	{
		if(hoursEndClassa.value==12)
		{
			endTimeFactor=0;
		}
		else
			endTimeFactor=12;
	}
	var startTime:Date=new Date(null,null,null,hoursStartClassa.value+startTimeFactor ,minsStartClassa.value);
	var endTime:Date=new Date(null,null,null,hoursEndClassa.value+endTimeFactor,minsEndClassa.value);
	
	if(startDate!=null)
	{
		
		var scheduleStartTime:Date=new Date(startDate.fullYear,
			startDate.month,startDate.date,startTime.hours,startTime.minutes,startTime.seconds);
		var currDate:Date = new Date();
		var currDateNoSecMSec:Date = new Date(currDate.fullYear,currDate.month,currDate.date,currDate.hours,currDate.minutes,0,0);
		if(scheduleStartTime.time<currDateNoSecMSec.time)
		{
			Alert.show("Invalid schedule,Please check your start time","Warning");
			return false;
		}
	}
	if(startDate.time>endDate.time)
	{
		Alert.show("Start date should be less than end date","Error");
	}
	else if(startTime.time>endTime.time)
	{
		Alert.show("Invalid schedule, Please select your end time","Error");
	}
	else if(startTime.time == endTime.time)
	{
		Alert.show("Start time and end time should not be the same","WARNING");
	}
	else
	{
		
		meetingScheduleModel.startDate=startDate;
		meetingScheduleModel.startTime=startTime;
		meetingScheduleModel.endDate=endDate;
		meetingScheduleModel.endTime=endTime;
		
		if(weeklyRadioBtn.selected)
		{
			meetingScheduleModel.weekDays=getWeekDays();
		}
		else if(recurringChkBox.selected)
		{
			meetingScheduleModel.weekDays="YYYYYYY";
		}
		else
		{
			meetingScheduleModel.weekDays="NNNNNNN";
		}
		return true;
	}
	return false;
}

private function getWeekDays():String
{
	var weekDays:String="";
	if(weeklyRadioBtn.selected)
	{
		if(chkSun.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
		if(chkMon.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
		if(chkTue.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
		if(chkWed.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
		if(chkThu.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
		if(chkFri.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
		if(chkSat.selected)
		{
			weekDays+="Y";
		}
		else
		{
			weekDays+="N";
		}
	}
	if(weekDays=="")
	{
		weekDays="YYYYYYY";
	}
	return weekDays;
}
protected function onClickCancel():void
{
	txtTitle.text="";
	recurringChkBox.selected=false;
	weeklyRadioBtn.selected=false;
	meetingScheduleVGroup.visible=false;
	meetingScheduleVGroup.includeInLayout=false;
	recurringVGroup.visible=false;
	recurringVGroup.includeInLayout=false;
	weekdaysCheckBox.visible=false;
	weekdaysCheckBox.includeInLayout=false;
	PopUpManager.removePopUp(this);
}

private function mouseOverHandler(event:MouseEvent):void
{
	btnClose.source=closeOverPng;
}

private function mouseOutHandler(event:MouseEvent):void
{
	btnClose.source=closePng;
}

private function formatDateTime(date:Date):String
{
	return dtf.format(date);
}

protected function recurringchecked(event:Event):void
{
	if (recurringChkBox.selected)
	{
		recurringVGroup.visible=true;
		recurringVGroup.includeInLayout=true;
		endDateField.enabled=true;
		DailyRadioBtn.selected=true;
	}
	else
	{
		recurringVGroup.visible=false;
		recurringVGroup.includeInLayout=false;
		DailyRadioBtn.selected=false;
		weeklyRadioBtn.selected=false;
		recurringVGroup.visible=false;
		recurringVGroup.includeInLayout=false;
		weekdaysCheckBox.visible=false;
		weekdaysCheckBox.includeInLayout=false;
		endDateField.enabled=false;
		endDateField.selectedDate = startDateField.selectedDate;
	}
}

protected function creationCompleteHandler(event:FlexEvent):void
{
	disabledEndDate.time=new Date().time-(60*60*1000*24);
	startDateField.disabledRanges=[{rangeEnd: disabledEndDate}];
	endDateField.disabledRanges=[{rangeEnd: disabledEndDate}];
	
	if(meetingScheduleModel.isEditScheduledMeeting)
	{
		txtTitle.text = meetingScheduleModel.meetingName;
	}
}
private function formatHour(value:Date):Number
{
	var strTime:String = timeFormatter.format(value);
	return Number(strTime.substr(0,2));
	
}
private function formatMinute(value:Date):Number
{
	var strTime:String = timeFormatter.format(value);
	return Number(strTime.substr(3,5));
	
}
private function formatAMPM(value:Date):String
{
	var strTime:String = timeFormatter.format(value);
	return strTime.substr(6,8);
	
}
protected function startDateField_changeHandler(event:CalendarLayoutChangeEvent):void
{
	// TODO Auto-generated method stub
	if(!endDateField.enabled)
	{
		endDateField.selectedDate=startDateField.selectedDate;
	}
}
