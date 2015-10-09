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
 * File			: ClassRegisterVO
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Class Register
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.ClassRegistration")]
	public dynamic class ClassRegisterVO extends Auditable
	{
		/**
		 * @public 
		 * default constructor
		 *
		 */
		public function ClassRegisterVO()
		{
		}
		/**
		 * The class register id
		 */
		private var _classRegisterId:Number=0;
		/**
		 * The user object
		 */
		private var _user:UserVO=null;
		/**
		 * The aview class object 
		 */
		private var _aviewClass:ClassVO=null;
		/**
		 * The node type id
		 */
		private var _nodeTypeId:Number=0;
		/**
		 * Variable to hold ismoderator value
		 */
		private var _isModerator:String=null;
		/**
		 * Variable to hold enableAudioVideo value
		 */
		private var _enableAudioVideo:String=null;
		/**
		 * Variable to hold enableDocumentSharing value
		 */
		private var _enableDocumentSharing:String=null;
		/**
		 * Variable to hold enableDesktopSharing value
		 */
		private var _enableDesktopSharing:String=null;
		/**
		 * Variable to hold enableVideoSharing value
		 */
		private var _enableVideoSharing:String=null;
		/**
		 * Variable to hold enable2DSharing value
		 */
		private var _enable2DSharing:String=null;
		/**
		 * Variable to hold enable3DSharing value
		 */
		private var _enable3DSharing:String=null;
		/**
		 * The status name
		 */
		private var _statusName:String=null;
		
		/**
		 * @public
		 * Function to get class register id
		 *
		 * @return int
		 */
		public function get classRegisterId():int
		{
			return _classRegisterId;
		}
		
		/**
		* @public
		* Function to set class register id
		* @param classRegisterId type of int
		* @return void
		*/
		public function set classRegisterId(classRegisterId:int):void
		{
			this._classRegisterId=classRegisterId;
		}
		
		/**
		* @public
		* Function to get user
		* @param null
		* @retuen UserVO
		*/
		public function get user():UserVO
		{
			return _user;
		}
		
		/**
		* @public
		* Function to set user
		* @param user type of UserVO
		* @return void
		*/
		public function set user(user:UserVO):void
		{
			this._user=user;
		}
		
		/**
		* @public
		* Function to get aviewClass
		* @param  null
		* @return ClassVO
		*/
		public function get aviewClass():ClassVO
		{
			return _aviewClass;
		}
		
		/**
		* @public
		* Function to set aviewClass
		* @param classvo type of ClassVO
		* @return void
		*/
		public function set aviewClass(classvo:ClassVO):void
		{
			this._aviewClass=classvo;
		}
		
		
		/**
		 * @public
		 * Function to get nodeTypeId
		 *
		 * @return Number
		 */
		public function get nodeTypeId():Number
		{
			return _nodeTypeId;
		}
		
		/**
		 * @public
		 * Function to set nodeTypeId
		 * @param nodeTypeId type of Number
		 * @return void
		 */
		public function set nodeTypeId(nodeTypeId:Number):void
		{
			this._nodeTypeId=nodeTypeId;
		}
		
		/**
		 * @public
		 * Function to get isModerator
		 *
		 * @return String
		 */
		public function get isModerator():String
		{
			return _isModerator;
		}
		
		/**
		 * @public
		 * Function to set isModerator
		 * @param isModerator type of String
		 * @return void
		 */
		public function set isModerator(isModerator:String):void
		{
			this._isModerator=isModerator;
		}
		
		/**
		 * @public
		 * Function to get statusName
		 *
		 * @return String
		 */
		public function get statusName():String
		{
			return _statusName;
		}
		
		/**
		 * @public
		 * Function to set statusName
		 * @param statusName type of String
		 * @return void
		 */
		public function set statusName(statusName:String):void
		{
			this._statusName=statusName;
		}
		
		/**
		 * @public
		 * Function to get enableAudioVideo
		 *
		 * @return String
		 *
		 */
		public function get enableAudioVideo():String
		{
			return _enableAudioVideo;
		}
		
		/**
		 * @public
		 * Function to set enableAudioVideo
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set enableAudioVideo(value:String):void
		{
			_enableAudioVideo=value;
		}
		
		/**
		 * @public
		 * Function to get enableDocumentSharing
		 *
		 * @return String
		 *
		 */
		public function get enableDocumentSharing():String
		{
			return _enableDocumentSharing;
		}
		
		/**
		 * @public
		 * Function to set enableDocumentSharing
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set enableDocumentSharing(value:String):void
		{
			_enableDocumentSharing=value;
		}
		
		/**
		 * @public
		 * Function to get enableDesktopSharing
		 *
		 * @return String
		 *
		 */
		public function get enableDesktopSharing():String
		{
			return _enableDesktopSharing;
		}
		
		/**
		 * @public
		 * Function to set enableDesktopSharing
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set enableDesktopSharing(value:String):void
		{
			_enableDesktopSharing=value;
		}
		
		/**
		 * @public
		 * Function to get enableVideoSharing
		 *
		 * @return String
		 *
		 */
		public function get enableVideoSharing():String
		{
			return _enableVideoSharing;
		}
		
		/**
		 * @public
		 * Function to set enableVideoSharing
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set enableVideoSharing(value:String):void
		{
			_enableVideoSharing=value;
		}
		
		/**
		 * @public
		 * Function to get enable2DSharing
		 *
		 * @return String
		 *
		 */
		public function get enable2DSharing():String
		{
			return _enable2DSharing;
		}
		
		/**
		 * @public
		 * Function to set enable2DSharing
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set enable2DSharing(value:String):void
		{
			_enable2DSharing=value;
		}
		
		/**
		 * @public
		 * Function to get enable3DSharing
		 *
		 * @return String
		 *
		 */
		public function get enable3DSharing():String
		{
			return _enable3DSharing;
		}
		
		/**
		 * @public
		 * Function to set enable3DSharing
		 * @param value type of String
		 * @return void
		 *
		 */
		public function set enable3DSharing(value:String):void
		{
			_enable3DSharing=value;
		}
		
		/**
		 * @public
		 * Function to get the displayName for the class/institute dropdown of LMS
		 * @param void
		 * @return String
		 *
		 */
		public function get lmsDisplayName():String
		{
			return _aviewClass.classNameInstituteName;
		}
	
	}
}
