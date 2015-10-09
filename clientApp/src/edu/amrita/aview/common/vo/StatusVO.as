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
 * File			: StatusVO.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.common.vo
{
	
	//VGCR:- Class Description
	//VGCR:- function description
	//VGCR:- variable description
	[Bindable]
	[RemoteClass(alias="edu.amrita.aview.common.entities.Status")]
	public class StatusVO extends Auditable
	{
		public static var ACTIVE_STATUS:Number=0;
		public static var DELETED_STATUS:Number=0;
		public static var PENDING_STATUS:Number=0;
		public static var CLOSED_STATUS:Number=0;
		
		public static var COMMUNICATING_STATUS:Number=0;
		public static var TESTING_STATUS:Number=0;
		public static var FAILEDTESTING_STATUS:Number=0;
		public static var INACTIVE_STATUS:Number=0;
		
		public static var JOINED_STATUS:Number=0;
		public static var EXITED_STATUS:Number=0;
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function StatusVO()
		{
		}
		private var _statusName:String=null;
		/**
		 * @public
		 * function to get statusName
		 * @return String
		 */
		public function get statusName():String
		{
			return _statusName;
		}
		/**
		 * @public
		 * function to set statusName
		 * @param statusName the status name to set of type String
	     */
		public function set statusName(statusName:String):void
		{
			this._statusName=statusName;
		}
	}
}
