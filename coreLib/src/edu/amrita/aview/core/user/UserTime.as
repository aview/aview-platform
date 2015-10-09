package edu.amrita.aview.core.user
{
	
	
	public class UserTime
	{
		private var lastUserStatusTime:Number=0;
		private var lastPublishingStatusTime:Number=0;
		
		private var milliSeconds:uint=1000;
		private var _userStatus:String="";
		private var _isVideoPublishing:Boolean=false;
		private var _userName:String="";
		private var timeDiff:int;
		
		public function UserTime()
		{
		}
		
		public function get userStatus():String
		{
			return _userStatus;
		}
		
		public function set userStatus(newUserStatus:String):void
		{
			if (_userStatus != newUserStatus)
			{
				_userStatus=newUserStatus;
				this.lastUserStatusTime=new Date().time;
			}
		}
		
		public function setUserStatusTime():void
		{
			this.lastUserStatusTime=new Date().time;
		}
		
		public function get isVideoPublishing():Boolean
		{
			return _isVideoPublishing;
		}
		
		public function set isVideoPublishing(newPublishingState:Boolean):void
		{
			if (_isVideoPublishing != newPublishingState)
			{
				_isVideoPublishing=newPublishingState;
				this.lastPublishingStatusTime=new Date().time;
			}
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function set userName(value:String):void
		{
			_userName=value;
		}
		
		public function canSelectForInteraction(tempBool:Boolean):Boolean
		{
			if (tempBool)
			{
				timeDiff=14;
			}
			else
			{
				timeDiff=4;
			}
			var tempTime:Date=new Date();
			var tempDifferenceUser:Number=(tempTime.time - lastUserStatusTime) / milliSeconds;
			var tempDifferencePublishing:Number=(tempTime.time - lastPublishingStatusTime) / milliSeconds;
			if (tempDifferenceUser > timeDiff && tempDifferencePublishing > 10)
			{
				return true;
			}
			return false;
		}
	
	
	}
}
