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
 * File			: LectureVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Lecture
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.Lecture")]
	public class LectureVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function LectureVO()
		{
		}
		/**
		 * The lecture id
		 */
		private var _lectureId:Number=0;
		/**
		 * The lecture name
		 */
		private var _lectureName:String=null;
		/**
		 * The start date
		 */
		private var _startDate:Date=null;
		/**
		 * The recorded presenter video url
		 */
		private var _recordedPresenterVideoUrl:String=null;
		/**
		 * The recorded viewer video url
		 */
		private var _recordedViewerVideoUrl:String=null;
		/**
		 * The recorded video file path
		 */
		private var _recordedVideoFilePath:String=null;
		/**
		 * The recorded content url
		 */
		private var _recordedContentUrl:String=null;
		/**
		 * The recorded content file path
		 */
		private var _recordedContentFilePath:String=null;
		/**
		 * The class id
		 */
		private var _classId:Number=0;
		/**
		 * The keywords
		 */
		private var _keywords:String=null;
		/**
		 * The lecture number
		 */
		private var _lectureNumber:Number=0;
		/**
		 * The start time
		 */
		private var _startTime:Date=null;
		/**
		 * The end time
		 */
		private var _endTime:Date=null;
		/**
		 * The recorded desktop video url
		 */
		private var _recordedDesktopVideoUrl:String=null;
		
		/**
		 * The class name
		 */
		//non mapped attribute
		private var _className:String=null;
		/**
		 * The course name
		 */
		private var _courseName:String=null;
		/**
		 * The institute name
		 */
		private var _instituteName:String=null;
		
		private var _displayName : String = null;
		
		/**
		 * @public
		 * function to get recordedDesktopVideoUrl
		 *
		 * @return String
		 */
		
		public function get recordedDesktopVideoUrl():String
		{
			return _recordedDesktopVideoUrl;
		}
		
		/**
		 * @public
		 * function to set recordedDesktopVideoUrl
		 * @param value type of String
		 * @return void
		 */
		public function set recordedDesktopVideoUrl(value:String):void
		{
			_recordedDesktopVideoUrl=value;
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
		 * @param value type of String
		 * @return void
		 */
		public function set instituteName(value:String):void
		{
			_instituteName=value;
		}
		
		/**
		 * @public
		 * function to get courseName
		 *
		 * @return String
		 */
		
		public function get courseName():String
		{
			return _courseName;
		}
		
		/**
		 * @public
		 * function to set courseName
		 * @param value type of String
		 * @return void
		 */
		public function set courseName(value:String):void
		{
			_courseName=value;
		}
		
		/**
		 * @public
		 * function to get lectureId
		 *
		 * @return Number
		 */
		
		public function get lectureId():Number
		{
			return _lectureId;
		}
		
		/**
		 * @public
		 * function to set lectureId
		 * @param lectureId type of Number
		 * @return void
		 */
		
		public function set lectureId(lectureId:Number):void
		{
			this._lectureId=lectureId;
		}
		
		/**
		 * @public
		 * function to get lectureName
		 *
		 * @return String
		 */
		[Bindable]
		public function get lectureName():String
		{
			return _lectureName;
		}
		
		/**
		 * @public
		 * function to set lectureName
		 * @param lectureName type of String
		 * @return void
		 */
		
		public function set lectureName(lectureName:String):void
		{
			this._lectureName=lectureName;
		}
		
		/**
		 * @public
		 * function to get startDate
		 *
		 * @return Date
		 */
		
		public function get startDate():Date
		{
			return _startDate;
		}
		
		/**
		 * @public
		 * function to set startDate
		 * @param startDate type of Date
		 * @return void
		 */
		
		public function set startDate(startDate:Date):void
		{
			this._startDate=startDate;
		}
		
		/**
		 * @public
		 * function to get recorded Presenter VideoUrl
		 *
		 * @return String
		 */
		
		public function get recordedPresenterVideoUrl():String
		{
			return _recordedPresenterVideoUrl;
		}
		
		/**
		 * @public
		 * function to set recordedPresenterVideoUrl
		 * @param recordedPresenterVideoUrl type of String
		 * @return void
		 */
		
		public function set recordedPresenterVideoUrl(recordedPresenterVideoUrl:String):void
		{
			this._recordedPresenterVideoUrl=recordedPresenterVideoUrl;
		}
		
		/**
		 * @public
		 * function to get recordedVideoFilePath
		 *
		 * @return String
		 */
		
		public function get recordedVideoFilePath():String
		{
			return _recordedVideoFilePath;
		}
		
		/**
		 * @public
		 * function to set recordedVideoFilePath
		 * @param recordedVideoFilePath type of String
		 * @return void
		 */
		
		public function set recordedVideoFilePath(recordedVideoFilePath:String):void
		{
			this._recordedVideoFilePath=recordedVideoFilePath;
		}
		
		/**
		 * @public
		 * function to get recordedContentUrl
		 *
		 * @return String
		 */
		
		public function get recordedContentUrl():String
		{
			return _recordedContentUrl;
		}
		
		/**
		 * @public
		 * function to set recordedContentUrl
		 * @param recordedContentUrl type of String
		 * @return void
		 */
		public function set recordedContentUrl(recordedContentUrl:String):void
		{
			this._recordedContentUrl=recordedContentUrl;
		}
		
		/**
		 * @public
		 * function to get recordedContentFilePath
		 *
		 * @return String
		 */
		
		public function get recordedContentFilePath():String
		{
			return _recordedContentFilePath;
		}
		
		/**
		 * @public
		 * function to set recordedContentFilePath
		 * @param xmlFileName type of String
		 * @return void
		 */
		
		public function set recordedContentFilePath(xmlFileName:String):void
		{
			this._recordedContentFilePath=xmlFileName;
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
		 * @param classId type of Number
		 * @return void
		 */
		
		public function set classId(classId:Number):void
		{
			this._classId=classId;
		}
		
		/**
		 * @public
		 * function to get keywords
		 *
		 * @return String
		 */
		
		public function get keywords():String
		{
			return _keywords;
		}
		
		/**
		 * @public
		 * function to set keywords
		 * @param keywords type of String
		 * @return void
		 */
		
		public function set keywords(keywords:String):void
		{
			this._keywords=keywords;
		}
		
		/**
		 * @public
		 * function to get lectureNumber
		 *
		 * @return Number
		 */
		
		public function get lectureNumber():Number
		{
			return _lectureNumber;
		}
		
		/**
		 * @public
		 * function to set lectureNumber
		 * @param lectureNumber type of Number
		 * @return void
		 */
		
		public function set lectureNumber(lectureNumber:Number):void
		{
			this._lectureNumber=lectureNumber;
		}
		
		/**
		 * @public
		 * function to get startTime
		 *
		 * @return Date
		 */
		
		public function get startTime():Date
		{
			return _startTime;
		}
		
		/**
		 * @public
		 * function to set startTime
		 * @param startTime type of Date
		 * @return void
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
		 */
		
		public function set endTime(endTime:Date):void
		{
			this._endTime=endTime;
		}
		
		/**
		 * @public
		 * function to get className
		 *
		 * @return String
		 */
		
		public function get className():String
		{
			return _className;
		}
		
		/**
		 * @public
		 * function to set className
		 * @param className type of String
		 * @return void
		 */
		
		public function set className(className:String):void
		{
			this._className=className;
		}
		
		/**
		 * @public
		 * function to get recordedViewerVideoUrl
		 *
		 * @return String
		 */
		public function get recordedViewerVideoUrl():String
		{
			return _recordedViewerVideoUrl;
		}
		
		/**
		 * @public
		 * function to set recordedViewerVideoUrl
		 * @param value type of String
		 * @return void
		 */
		public function set recordedViewerVideoUrl(value:String):void
		{
			_recordedViewerVideoUrl=value;
		}
		
		
		/**
		 * The displayName is derived from the lectureName, by cutting off the date&time portion.
		 * @return String, the display name.
		 */
		public function get displayName():String
		{
			return this._displayName;
		}
		
		
		
		/**
		 * Static method used by the code which does not have access to LectureVO object, but only knows the lectureName 
		 * The displayName is derived from the lectureName, by cutting off the date&time portion.
		 * @param sessionName:LectureName
		 * @return String, the display name.
		 * 
		 */
		public function set displayName(displayName:String):void
		{
			this._displayName = displayName;
		}
	
	}
}
