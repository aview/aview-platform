////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: FeedbackIssueVO.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 *
 * value object for the feedbackissue
 */
package edu.amrita.aview.feedback.vo
{
	import edu.amrita.aview.common.vo.Auditable;
	
	[RemoteClass(alias="edu.amrita.aview.feedback.entities.FeedbackIssue")]
	public class FeedbackIssueVO extends Auditable
	{
		public function FeedbackIssueVO()
		{
			super();
		}
		private var _feedbackIssueId:Number=0;
		private var _feedback:FeedbackVO=null;
		private var _moduleId:Number=0;
		private var _issueTitle:String=null;
		private var _issueDescription:String=null;
		
		public function get feedbackIssueId():Number
		{
			return _feedbackIssueId;
		}
		
		public function set feedbackIssueId(value:Number):void
		{
			_feedbackIssueId=value;
		}
		
		public function get feedback():FeedbackVO
		{
			return this._feedback;
		}
		
		public function set feedback(value:FeedbackVO):void
		{
			this._feedback=value;
		}
		
		public function get issueTitle():String
		{
			return _issueTitle;
		}
		
		public function set issueTitle(value:String):void
		{
			_issueTitle=value;
		}
		
		public function get issueDescription():String
		{
			return _issueDescription;
		}
		
		public function set issueDescription(value:String):void
		{
			_issueDescription=value;
		}
		
		public function get moduleId():Number
		{
			return _moduleId;
		}
		
		public function set moduleId(value:Number):void
		{
			_moduleId=value;
		}
	
	
	}
}
