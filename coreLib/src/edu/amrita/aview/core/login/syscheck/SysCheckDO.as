package edu.amrita.aview.core.login.syscheck
{
	public class SysCheckDO
	{
		public function SysCheckDO(){
		}
		
		private var _OSType:String;
		
		public function get OSType():String
		{
			return _OSType;
		}

		public function set OSType(value:String):void
		{
			_OSType = value;
		}

	}
}