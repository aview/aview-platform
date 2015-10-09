package edu.amrita.aview.meeting
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	[Bindable]
	public class MeetingsListModel
	{
		public var allMeetings:ArrayCollection=null;
		public var selectedMeetings:ArrayCollection;
		
		public var pastMeetings:ArrayCollection = null;
		public var currentAndUpcomingMeetings:ArrayCollection = null;
		public var meetingCount:int=0;
		public var isAllMeetingsSelected:Boolean=false;
		
		public function MeetingsListModel()
		{
		}
		
          
		public function removeSelectedMeetings():void
		{
			for(var index:int=0;index<selectedMeetings.length;index++)
			{
				allMeetings.removeItemAt(allMeetings.getItemIndex(selectedMeetings[index]));
			}
		}
		public function addMeetings(newMeetings:ArrayCollection):void
		{
			for(var index:int=0;index<newMeetings.length;index++)
			{
				allMeetings.addItem(newMeetings[index]);
			}
		}
		
		public function computePastAndUpcomingMeetings():void
		{
			pastMeetings = new ArrayCollection();
			currentAndUpcomingMeetings = new ArrayCollection();
			if(allMeetings !=null)
				for (var i:int=0; i < allMeetings.length; i++)
				{
					var startDate:Date=allMeetings[i].startDate;
					var endTime:Date=allMeetings[i].endTime;
					var endDate:Date=new Date(startDate.fullYear, startDate.month, startDate.date, endTime.hours, endTime.minutes, endTime.seconds);
					//TODO: Need to change current date 
					if (endDate.time <= new Date().time)
					{
						pastMeetings.addItem(allMeetings[i]);
					}
					else
					{
						currentAndUpcomingMeetings.addItem(allMeetings[i]);
					}
				}
			
			meetingCount = currentAndUpcomingMeetings.length;
		}
		
		public function sortAndRefresh():void
		{
			var sort:Sort=new Sort();
			var dateSort:SortField=new SortField("startDate", false);
			dateSort.descending=false;
			dateSort.numeric=true;
			var timeSort:SortField=new SortField("startTime", false);
			timeSort.descending=false;
			timeSort.numeric=true;
			sort.fields=[dateSort,timeSort];
			
			if (currentAndUpcomingMeetings.length > 0)		
				currentAndUpcomingMeetings.sort=sort;
				
			if(pastMeetings.length>0)
				pastMeetings.sort=sort;
			
			pastMeetings.refresh();
			currentAndUpcomingMeetings.refresh();
		}
		

	}
}