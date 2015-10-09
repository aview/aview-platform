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
 * File			: MeetingServersSelectedEvent.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This event is generated whenever the user is done with the selection of meeting servers for an Institute
 *
 */
package edu.amrita.aview.core.gclm.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	/**
	 * The event class
	 */
	public class MeetingServersSelectedEvent extends Event
	{
		/* The event type */
		public static var MEETING_SERVERS_SELECTED:String="meetingserversselected";
		
		/**
		 * Stores list of selected meeting servers 
		 */
		private var _selectedMeetingServers:ArrayCollection;
		
		/**
		 * Stores details of meeting presenter video server
		 */
		private var _meetingPresenterVideoServers:Object;
		
		/**
		 * Stores details of meeting collaboration server 
		 */
		private var _meetingCollaborationServers:Object;
		
		/**
		 * Stores details of meeting viewer video server 
		 */
		private var _meetingViewerVideoServers:Object;
		
		/**
		 * Stores details of meeting content server 
		 */
		private var _meetingContentServers:Object;
		
		/**
		 * Stores details of meeting desktop sharing server 
		 */
		private var _meetingDesktopSharingServers:Object;
		
		/**
		 *
		 * @public
		 * Constructor for this classs
		 * @param type : The event type
		 * @param bubbles : Boolean if the event has to be bubbled
		 * @param cancelable : Boolean if the event can be cancelled
		 * @param data : The branding info
		 * @return NA
		 *
		 ***/
		public function MeetingServersSelectedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:ArrayCollection=null)
		{
			super(type, bubbles, cancelable);
			selectedMeetingServers=data;
			meetingCollaborationServers=ObjectUtil.copy(data[0]) as Object;
			meetingContentServers=ObjectUtil.copy(data[1]) as Object;
			meetingDesktopSharingServers=ObjectUtil.copy(data[2]) as Object;
			meetingPresenterVideoServers=ObjectUtil.copy(data[3]) as Object;
			meetingViewerVideoServers=ObjectUtil.copy(data[4]) as Object;
		}
		
		/**
		 *
		 * @public
		 * Overridden function from the base class
		 *
		 * @return Event
		 *
		 ***/
		override public function clone():Event
		{
			return new InstituteServersSelectedEvent(type, bubbles, cancelable, selectedMeetingServers);
		}
		
		/**
		 * @return the selected meeting servers
		 */
		public function get selectedMeetingServers():ArrayCollection
		{
			return _selectedMeetingServers;
		}
		
		public function set selectedMeetingServers(value:ArrayCollection):void
		{
			_selectedMeetingServers=value;
		}
		
		/**
		 * @return the presenter video servers for meeting
		 */
		public function get meetingPresenterVideoServers():Object
		{
			return _meetingPresenterVideoServers;
		}
		
		public function set meetingPresenterVideoServers(value:Object):void
		{
			_meetingPresenterVideoServers=value;
		}
		
		/**
		 * @return the collaboration servers for meeting
		 */
		public function get meetingCollaborationServers():Object
		{
			return _meetingCollaborationServers;
		}
		
		public function set meetingCollaborationServers(value:Object):void
		{
			_meetingCollaborationServers=value;
		}
		
		/**
		 * @return the viewer video servers for meeting
		 */
		public function get meetingViewerVideoServers():Object
		{
			return _meetingViewerVideoServers;
		}
		
		public function set meetingViewerVideoServers(value:Object):void
		{
			_meetingViewerVideoServers=value;
		}
		
		/**
		 * @return the content servers for meeting
		 */
		public function get meetingContentServers():Object
		{
			return _meetingContentServers;
		}
		
		public function set meetingContentServers(value:Object):void
		{
			_meetingContentServers=value;
		}
		
		/**
		 * @return the desktop sharing servers for meeting
		 */
		public function get meetingDesktopSharingServers():Object
		{
			return _meetingDesktopSharingServers;
		}
		
		public function set meetingDesktopSharingServers(value:Object):void
		{
			_meetingDesktopSharingServers=value;
		}
	}
}
