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
 * File			: ClassVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Class
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	import mx.collections.ArrayCollection;
	
	//The remote java class file which is mapped with this VO class	
	//This class is declared as dynamic, since it uses some of the class 
	//variables which are not therer at the server side.
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.Class")]
	public class ClassVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		public function ClassVO()
		{
		}
		/**
		 * The class id
		 */
		private var _classId:Number=0;
		/**
		 * The class name
		 */
		private var _className:String=null;
		/**
		 * The class description
		 */
		private var _classDescription:String=null;
		/**
		 * The start date
		 */
		private var _startDate:Date=null;
		/**
		 * The end date
		 */
		private var _endDate:Date=null;
		/**
		 * The course id
		 */
		private var _courseId:Number=0;
		/**
		 * The start time
		 */
		private var _startTime:Date=null;
		/**
		 * The end time
		 */
		private var _endTime:Date=null;
		/**
		 * The week days
		 */
		private var _weekDays:String=null;
		/**
		 * The schedule type
		 */
		private var _scheduleType:String=null;
		/**
		 * The maximum number of students
		 */
		private var _maxStudents:Number=0;
		/**
		 * The maximum publishing bandwidth in Kbps
		 */
		private var _maxPublishingBandwidthKbps:Number=0;
		/**
		 * The minimum publishing bandwidth in Kbps
		 */
		private var _minPublishingBandwidthKbps:Number=0;
		/**
		 * The video codec
		 */
		private var _videoCodec:String=null;
		/**
		 * The video streaming protocol
		 */
		private var _videoStreamingProtocol:String=null;
		/**
		 * The isMultiBitrate value
		 */
		private var _isMultiBitrate:String=null;
		/**
		 * The presenter publishing bandwidth in Kbps
		 */
		private var _presenterPublishingBwsKbps:String=null;
		/**
		 * The allowDynamicSwitching value
		 */
		private var _allowDynamicSwitching:String=null;
		/**
		 * The auditLevel value
		 */
		private var _auditLevel:String=null;
		/**
		 * The maximum number of viewer interaction
		 */
		private var _maxViewerInteraction:Number=1;
		/**
		 * The registration type
		 */
		private var _registrationType:String=null;
		/**
		 * The can monitor value
		 */
		private var _canMonitor:String=Constants.STATUS_NO;
		/**
		 * The monitor interval frequency value
		 */
		private var _monitorIntervalFreq:Number=0; 
		/**
		 * The audio video interaction mode value
		 */
		private var _audioVideoInteractionMode:String= Constants.AUDIO_VIDEO_INTERACTION_MODE[0];
		/**
		 * The class type
		 */
		private var _classType:String=null;
		/**
		 * The class servers
		 */
		private var _classServers:ArrayCollection=null;
		/**
		 * The enable people count value
		 */
		private var _enablePeopleCount:String= Constants.STATUS_NO;
		
		/**
		 * The course name
		 */
		//non mapped attributes
		private var _courseName:String=null;
		/**
		 * The institute name
		 */
		private var _instituteName:String=null;
		/**
		 * The class name institute name
		 */
		//Client only attributes
		private var _classNameInstituteName:String=null;
		/**
		 * The week days name
		 */
		private var _weekDaysName:String=null;
		
		private var _isPeopleCountEnabled:Boolean = false;
		
		public function get isPeopleCountEnabled():Boolean
		{
			return _isPeopleCountEnabled;
		}

		public function set isPeopleCountEnabled(value:Boolean):void
		{
			_isPeopleCountEnabled = value;
		}

		/**
		 * @public
		 * function to get maxViewerInteraction
		 *
		 * @return Number
		 *
		 */
		public function get maxViewerInteraction():Number
		{
			return _maxViewerInteraction;
		}
		
		/**
		 * @public
		 * function to set maxViewerInteraction
		 * @param value type of Number
		 * @return void
		 *
		 */
		public function set maxViewerInteraction(value:Number):void
		{
			_maxViewerInteraction=value;
		}
		
		/**
		 * @public
		 * function to get classNameInstituteName
		 *
		 * @return String
		 *
		 */
		public function get classNameInstituteName():String
		{
			return _className + "-" + _instituteName;
		}
		
		/**
		 * @public
		 * function to set classNameInstituteName
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set classNameInstituteName(value:String):void
		{
			_classNameInstituteName=value;
		}
		
		/**
		 * @public
		 * function to get allowDynamicSwitching
		 *
		 * @return String
		 *
		 */
		public function get allowDynamicSwitching():String
		{
			return _allowDynamicSwitching;
		}
		
		/**
		 * @public
		 * function to set allowDynamicSwitching
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set allowDynamicSwitching(value:String):void
		{
			_allowDynamicSwitching=value;
		}
		
		/**
		 * @public
		 * function to get classId
		 *
		 * @return Number
		 */
		public function get classId():Number
		{
			return _classId;
		}
		
		/**
		 * @public
		 * function to set classId
		 * @param class_id type of Number
		 * @return void
		 *
		 */
		public function set classId(class_id:Number):void
		{
			this._classId=class_id;
		}
		
		/**
		 * @public
		 * function to get startDate
		 *
		 * @return Date
		 *
		 */
		public function get startDate():Date
		{
			return _startDate;
		}
		
		/**
		 * @public
		 * function to set startDate
		 * @param start_date type of Date
		 * @return void
		 *
		 */
		public function set startDate(start_date:Date):void
		{
			this._startDate=start_date;
		}
		
		/**
		 * @public
		 * function to get endDate
		 *
		 * return Date
		 *
		 */
		public function get endDate():Date
		{
			return _endDate;
		}
		
		/**
		 * @public
		 * function to set endDate
		 * @param end_date type of Date
		 * @return void
		 *
		 */
		public function set endDate(end_date:Date):void
		{
			this._endDate=end_date;
		}
		
		/**
		 * @public
		 * function to get courseId
		 *
		 * @return Number
		 *
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
		 *
		 */
		public function set courseId(courseId:Number):void
		{
			this._courseId=courseId;
		}
		
		/**
		 * @public
		 * function to get className
		 *
		 * @return String
		 *
		 */
		[Bindable]
		public function get className():String
		{
			return _className;
		}
		
		/**
		 * @public
		 * function to set className
		 * @param className type of String
		 * @return void
		 *
		 */
		public function set className(className:String):void
		{
			this._className=className;
		}
		
		/**
		 * @public
		 * function to get classDescription
		 *
		 * @return String
		 */
		public function get classDescription():String
		{
			return _classDescription;
		}
		
		/**
		 * @public
		 * function to set classDescription
		 * @param classDescription type of String
		 * @return void
		 *
		 */
		public function set classDescription(classDescription:String):void
		{
			this._classDescription=classDescription;
		}
		
		/**
		 * @public
		 * function to get startTime
		 *
		 * @return Date
		 *
		 */
		public function get startTime():Date
		{
			return _startTime;
		}
		
		/**
		 * @public
		 * function to set startTime
		 *  @param startTime type of Date
		 * @return void
		 *
		 */
		public function set startTime(startTime:Date):void
		{
			this._startTime=startTime;
		}
		
		/**
		 * @public
		 * function to get endTime
		 *
		 * @return Date
		 *
		 */
		public function get endTime():Date
		{
			return _endTime;
		}
		
		/**
		 * @public
		 * function to set endTime
		 * @param endTime type of Date
		 * @return void
		 *
		 */
		public function set endTime(endTime:Date):void
		{
			this._endTime=endTime;
		}
		
		/**
		 * @public
		 * function to get weekDays
		 *
		 * @return String
		 *
		 */
		public function get weekDays():String
		{
			return _weekDays;
		}
		
		/**
		 * @public
		 * function to set weekDays
		 * @param weekDays type of String
		 * @return void
		 *
		 */
		public function set weekDays(weekDays:String):void
		{
			this._weekDays=weekDays;
		}
		
		/**
		 * @public
		 * function to get scheduleType
		 *
		 * @return String
		 *
		 */
		public function get scheduleType():String
		{
			return _scheduleType;
		}
		
		/**
		 * @public
		 * function to set scheduleType
		 * @param classMode type of String
		 * @return void
		 *
		 */
		public function set scheduleType(classMode:String):void
		{
			this._scheduleType=classMode;
		}
		
		/**
		 * @public
		 * function to get maxStudents
		 *
		 * @return Number
		 *
		 */
		public function get maxStudents():Number
		{
			return _maxStudents;
		}
		
		/**
		 * @public
		 * function to set maxStudents
		 * @param maxStudents type of Number
		 * @return void
		 *
		 */
		public function set maxStudents(maxStudents:Number):void
		{
			this._maxStudents=maxStudents;
		}
		
		/**
		 * @public
		 * function to get maxPublishingBandwidthKbps
		 *
		 * @return Number
		 *
		 */
		public function get maxPublishingBandwidthKbps():Number
		{
			return _maxPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to set maxPublishingBandwidthKbps
		 * @param maxPublishingBandwidthKbps type of Number
		 * @return void
		 *
		 */
		public function set maxPublishingBandwidthKbps(maxPublishingBandwidthKbps:Number):void
		{
			this._maxPublishingBandwidthKbps=maxPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to get minPublishingBandwidthKbps
		 *
		 * @return Number
		 *
		 */
		public function get minPublishingBandwidthKbps():Number
		{
			return _minPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to set minPublishingBandwidthKbps
		 * @param minPublishingBandwidthKbps type of Number
		 * @return void
		 *
		 */
		public function set minPublishingBandwidthKbps(minPublishingBandwidthKbps:Number):void
		{
			this._minPublishingBandwidthKbps=minPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to get videoCodec
		 *
		 * @return String
		 *
		 */
		public function get videoCodec():String
		{
			return _videoCodec;
		}
		
		/**
		 * @public
		 * function to set videoCodec
		 * @param videoCodec type of String
		 * @return void
		 *
		 */
		public function set videoCodec(videoCodec:String):void
		{
			this._videoCodec=videoCodec;
		}
		
		/**
		 * @public
		 * function to get videoStreamingProtocol
		 *
		 * @return String
		 *
		 */
		public function get videoStreamingProtocol():String
		{
			return _videoStreamingProtocol;
		}
		
		/**
		 * @public
		 * function to set videoStreamingProtocol
		 * @param videoStreamingProtocol type of String
		 * @return void
		 *
		 */
		public function set videoStreamingProtocol(videoStreamingProtocol:String):void
		{
			this._videoStreamingProtocol=videoStreamingProtocol;
		}
		
		/**
		 * @public
		 * function to get isMultiBitrate
		 *
		 * @return String
		 *
		 */
		public function get isMultiBitrate():String
		{
			return _isMultiBitrate;
		}
		
		/**
		 * @public
		 * function to set isMultiBitrate
		 * @param isMultiBitrate type of String
		 * @return void
		 *
		 */
		public function set isMultiBitrate(isMultiBitrate:String):void
		{
			this._isMultiBitrate=isMultiBitrate;
		}
		
		/**
		 * @public
		 * function to get presenterPublishingBwsKbps
		 *
		 * @return String
		 *
		 */
		public function get presenterPublishingBwsKbps():String
		{
			return _presenterPublishingBwsKbps;
		}
		
		/**
		 * @public
		 * function to set presenterPublishingBwsKbps
		 * @param presenterPublishingBws type of String
		 * @return void
		 *
		 */
		public function set presenterPublishingBwsKbps(presenterPublishingBws:String):void
		{
			this._presenterPublishingBwsKbps=presenterPublishingBws;
		}
		
		/**
		 * @public
		 * function to get courseName
		 *
		 * @return String
		 *
		 */
		public function get courseName():String
		{
			return _courseName;
		}
		
		/**
		 * @public
		 * function to set courseName
		 * @param courseName type of String
		 * @return void
		 *
		 */
		public function set courseName(courseName:String):void
		{
			this._courseName=courseName;
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
		 *
		 */
		public function set instituteName(instituteName:String):void
		{
			this._instituteName=instituteName;
		}
		
		/**
		 * @public
		 * function to get classServers
		 *
		 * @return ArrayCollection
		 *
		 */
		public function get classServers():ArrayCollection
		{
			return _classServers;
		}
		
		/**
		 * @public
		 * function to set classServers
		 * @param classServers type of ArrayCollection
		 * @return void
		 *
		 */
		public function set classServers(classServers:ArrayCollection):void
		{
			this._classServers=classServers;
		}
		
		/**
		 * @public
		 * function to  add Class Server
		 * @param classServer type of ClassServerVO
		 * @return void
		 *
		 */
		public function addClassServer(classServer:ClassServerVO):void
		{
			//Check for null value. If null create a new object of class server array collection
			if (this._classServers == null)
			{
				this._classServers=new ArrayCollection();
			}
			classServer.aviewClass=this;
			this._classServers.addItem(classServer);
		}
		
		/**
		 * @public
		 * function to get auditLevel
		 *
		 * @return String
		 *
		 */
		public function get auditLevel():String
		{
			return _auditLevel;
		}
		
		/**
		 * @public
		 * function to set auditLevel
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set auditLevel(value:String):void
		{
			_auditLevel=value;
		}
		
		/**
		 * @public
		 * function to get registrationType
		 *
		 * @return String
		 *
		 */
		public function get registrationType():String
		{
			return _registrationType;
		}
		
		/**
		 * @public
		 * function to get classType
		 *
		 * @return String
		 *
		 */
		[Bindable]
		public function get classType():String
		{
			return _classType;
		}
		
		/**
		 * @public
		 * function to get canMonitor
		 * @return String
		 *
		 */
		[Bindable]
		public function get canMonitor():String
		{
			return _canMonitor;
		}
		
		/**
		 * @public
		 * function to get monitorIntervalFreq
		 * @return Number
		 */
		[Bindable]
		public function get monitorIntervalFreq():Number
		{
			return _monitorIntervalFreq;
		}
		/**
		 * @public
		 * function to get audioVideoInteractionMode
		 * @return String
		 *
		 */
		[Bindable]
		public function get audioVideoInteractionMode():String
		{
			return _audioVideoInteractionMode;
		}
		/**
		 * @public
		 * function to get enablePeopleCount
		 * @return String
		 *
		 */
		[Bindable]
		public function get enablePeopleCount():String
		{
			return _enablePeopleCount;
		}


		/**
		 * @public
		 * function to set registrationType
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set registrationType(value:String):void
		{
			_registrationType=value;
		}
		
		/**
		 * @public
		 * function to set classType
		 * @param classType type of String
		 * @return void
		 *
		 */
		public function set classType(classType:String):void
		{
			_classType=classType;
		}
		
		/**
		 * @public
		 * function to set canMonitor
		 * @param value type of String 
		 * @return void
		 *
		 */
		public function set canMonitor(value:String):void{
			_canMonitor = value;
		}
		/**
		 * @public
		 * function to set audioVideoInteractionMode
		 * @param value type of String 
		 * @return void
		 *
		 */
		public function set audioVideoInteractionMode(value:String):void{
			_audioVideoInteractionMode = value;
		}

		/**
		 * @public
		 * function to set monitorIntervalFreq
		 * @param value type of String
		 * @return void
		 *
		 */		
		public function set monitorIntervalFreq(value:Number):void{
			_monitorIntervalFreq = value;
		}
		/**
		 * @public
		 * function to set enablePeopleCount
		 * @param value type of String 
		 * @return void
		 *
		 */
		public function set enablePeopleCount(value:String):void{
			_enablePeopleCount = value;
		}

			
		/**
		 * @public
		 * function to get weekDaysName
		 *
		 * @return String
		 *
		 */
		public function get weekDaysName():String
		{
			return _weekDaysName;
		}
		
		/**
		 * @public
		 * function to set weekDaysName
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set weekDaysName(value:String):void
		{
			_weekDaysName=value;
		}
	}
}
