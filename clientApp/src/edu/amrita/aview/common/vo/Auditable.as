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
 * File			: Auditable.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Sivaram SK,Veena Gopal K.V
 */
//VGCR:-Function Description 
//VGCR:-Variable Description
//VGCR:-Class Description
package edu.amrita.aview.common.vo
{
	import mx.collections.ArrayCollection;
	
	//The remote java class file which is mapped with this VO class
	[RemoteClass(alias="edu.amrita.aview.common.entities.Auditable")]
	public class Auditable
	{
		private var _createdByUserId:Number=0;
		private var _modifiedByUserId:Number=0;
		private var _createdDate:Date=null;
		private var _modifiedDate:Date=null;
		private var _statusId:int=0;
		
		/**
		 * @public
		 * function to get created by user id
		 * @return Number
		 */
		public function get createdByUserId():Number
		{
			return _createdByUserId;
		}
		/**
		 * @public
		 * function to set created by user id
		 * @param createdByUserId the user id to set of type Number
		 * 
		 */
		public function set createdByUserId(createdByUserId:Number):void
		{
			this._createdByUserId=createdByUserId;
		}
		/**
		 * @public
		 * function to get created Date
		 * @return Date
		 */
		
		public function get createdDate():Date
		{
			return _createdDate;
		}
		/**
		 * @public
		 * function to set created Date
		 * @param createdDate the date of creation of a user to set of type Date
		 */
	
		public function set createdDate(createdDate:Date):void
		{
			this._createdDate=createdDate;
		}
		/**
		 * @public
		 * function to get modified By UserId
		 * @return Number
		 */
		
		public function get modifiedByUserId():Number
		{
			return _modifiedByUserId;
		}
		/**
		 * @public
		 * function to set modified By UserId
		 * @param modified_by_user_id the user id to set of Type Number
		 */
		public function set modifiedByUserId(modifiedByUserId:Number):void
		{
			this._modifiedByUserId=modifiedByUserId;
		}
		/**
		 * @public
		 * function to get modifiedDate
		 * @return Date
		 */
		public function get modifiedDate():Date
		{
			return _modifiedDate;
		}
		/**
		 * @public
		 * function to set modifiedDate
		 * @param modifiedDate the date to be set of type Date
		 */
		public function set modifiedDate(modifiedDate:Date):void
		{
			this._modifiedDate=modifiedDate;
		}
		/**
		 * @public
		 * function to get statusId
		 * @return int
		 */
		public function get statusId():int
		{
			return _statusId;
		}
		/**
		 * @public
		 * function to set statusId
		 * @param status_id the status id to set of type int
		 */
		
		public function set statusId(statusId:int):void
		{
			this._statusId=statusId;
		}
		
		/**
		 * @public
		 * function to get server objects
		 * @return array
		 */
		public static function getServerObjects(objCollection:ArrayCollection):Array
		{
			var arr:Array = new Array();
			for each(var obj:Object in objCollection)
			{
				arr.push(obj.getServerObject());
			}
			return arr;
		}
		
	}
}
