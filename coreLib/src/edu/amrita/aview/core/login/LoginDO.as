package edu.amrita.aview.core.login
{
	public class LoginDO
	{
		public function LoginDO()
		{
		}
		protected var _userId:Number;
		protected var _userName:String;
		protected var _displayName:String;
		protected var _instituteId:Number;
		protected var _instituteName:String;
		protected var _userType:String;
		
		/**
		 * Database unique id of the currently logged in user
		 */
		public function get userId():Number
		{
			return _userId;
		}
		
		/**
		 * Unique userName of the currently logged in user
		 */
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * Display name of the currently logged in user, basically the First Name+Last Name
		 */
		public function get displayName():String
		{
			return _displayName;
		}
		
		/**
		 * Database unique id of the currently logged in user's Institute
		 */
		public function get instituteId():Number
		{
			return _instituteId;
		}
		
		/**
		 * Name of the Institute to which the current logged in User belongs
		 */
		public function get instituteName():String
		{
			return _instituteName;
		}
		
		/**
		 * The type of the logged in user. It can be among the 
		 * Constants.TEACHER_TYPE, Constants.STUDENT_TYPE, Constants.ADMIN_TYPE, Constants.MASTER_ADMIN_TYPE, or Constants.GUEST_TYPE  
		 */
		public function get userType():String
		{
			return _userType;
		}

		public function set userId(value:Number):void
		{
			_userId = value;
		}

		public function set userName(value:String):void
		{
			_userName = value;
		}

		public function set displayName(value:String):void
		{
			_displayName = value;
		}

		public function set instituteId(value:Number):void
		{
			_instituteId = value;
		}

		public function set instituteName(value:String):void
		{
			_instituteName = value;
		}

		public function set userType(value:String):void
		{
			_userType = value;
		}


	}
}