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
 *
 * File			: MeetingEvent.as
 * Module		: meeting
 * Developer(s)	: NidhiSarasan,Soumya M.D
 * Reviewer(s)	:
 *
 *
 *
 */
package edu.amrita.aview.meeting.events
{
	import edu.amrita.aview.meeting.MeetingScheduleModel;
	
	import flash.events.Event;
	
	import mx.rpc.xml.SchemaTypeRegistry;
	
	public class MeetingEvent extends Event
	{
		/**
		 * Meeting Invitation Received 
		 */
		public static const RECEIVED_INVITATION:String="MeetingInvitationReceived";		
		public static const SCHEDULED_MEETING_CREATED:String="MeetingCreated";
		public static const ADHOC_MEETING_CREATED:String="MeetingCreated";
		public static const MEETING_EDITED:String="MeetingEdited";
		public static const MEETING_DELETED:String="MeetingDeleted";
		public static const CREATE_ADHOC_MEETING:String="CreateAdhocMeeting";
		public static const CREATE_SCHEDULED_MEETING:String="CreateScheduledMeeting";
		public static const EDIT_MEETING:String="EditMeeting";
		public static const DELETE_MEETING:String="DeleteMeeting";
		public static const START_SESSION:String="StartSession";
		public static const END_SESSION:String="End Session";
		public static const REFRESH_MEETING_ROOM:String="RefreshMeeting";
		/**
		 * Variable to store invitations as array
		 */
		private var _invitations:Array=null;
		private var _meetingScheduleModel:MeetingScheduleModel=null
		
		/**
		 * @public
		 * @param type of type String
		 * @param invitations of type Array
		 * @param bubbles of type Boolean
		 * @param cancelable of type Boolean
		 * @return null
		 *
		 */
		public function MeetingEvent(type:String,schedule:MeetingScheduleModel, invitations:Array=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_invitations=invitations;
			this._meetingScheduleModel=schedule;
		}
		
		public function get meetingScheduleModel():MeetingScheduleModel
		{
			return _meetingScheduleModel;
		}

		/**
		 * @public
		 *
		 * @return Array
		 *
		 */
		public function get invitations():Array
		{
			return _invitations;
		}
	
	}
}
