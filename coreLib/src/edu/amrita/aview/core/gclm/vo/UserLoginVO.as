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
 * File			: UserLoginVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for User Login
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.audit.entities.AuditUserLogin")]
	public class UserLoginVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function UserLoginVO()
		{
		}
		/**
		 * The audit user login id
		 */
		private var _auditUserLoginId:Number=0;
		/**
		 * The user id
		 */
		private var _userId:Number=0;
		/**
		 * The login time
		 */
		private var _loginTime:Date=null;
		/**
		 * The log out time
		 */
		private var _logOutTime:Date=null;
		/**
		 * The operating system
		 */
		private var _operatingSystem:String=null;
		/**
		 * The flash player version
		 */
		private var _flashPlayerVersion:String=null;
		/**
		 * The network connection type
		 */
		private var _networkConnectionType:String=null;
		/**
		 * The ip address
		 */
		private var _ipAddress:String=null;
		/**
		 * The aview version
		 */
		private var _aviewVersion:String=null;
		/**
		 * The gui mode
		 */
		private var _guiMode:String=null;
		/**
		 * The authentication mode
		 */
		private var _authMode:String=null;
		/**
		 * The hardware address
		 */
		private var _hardwareAddress:String=null;
		/**
		 * The external ip address
		 */
		private var _externalIPAddress:String=null;
		
		/**
		 * @public
		 * function to get authMode
		 *
		 * @return String
		 */
		public function get authMode():String
		{
			return _authMode;
		}
		
		/**
		 * @public
		 * function to set authentication Mode
		 * @param value type of String
		 * @return void
		 */
		public function set authMode(value:String):void
		{
			_authMode=value;
		}
		
		/**
		 * @public
		 * function to get userId,login details,system details,aview details.
		 *
		 * @return String
		 */
		public function toString():String
		{
			return auditUserLoginId + ":" + userId + ":" + loginTime + ":" + logOutTime + ":" + operatingSystem + ":" + flashPlayerVersion + ":" + networkConnectionType + ":" + ipAddress + ":" + externalIPAddress + ":" + hardwareAddress + ":" + aviewVersion + ":" + _guiMode + ":";
		}
		
		/**
		 * @public
		 * function to get audit User Login Id
		 *
		 * @return Number
		 */
		public function get auditUserLoginId():Number
		{
			return _auditUserLoginId;
		}
		
		/**
		 * @public
		 * function to set audit User Login Id
		 * @param auditUserLoginId type of Number
		 * @return void
		 */
		public function set auditUserLoginId(auditUserLoginId:Number):void
		{
			this._auditUserLoginId=auditUserLoginId;
		}
		
		/**
		 * @public
		 * function to get userId
		 *
		 * @return Number
		 */
		public function get userId():Number
		{
			return _userId;
		}
		
		/**
		 * @public
		 * function to set userId
		 * @param userId type of Number
		 * @return void
		 */
		public function set userId(userId:Number):void
		{
			this._userId=userId;
		}
		
		/**
		 * @public
		 * function to get login Time
		 *
		 * @return Date
		 */
		
		public function get loginTime():Date
		{
			return _loginTime;
		}
		
		/**
		 * @public
		 * function to set login Time
		 * @param loginTime type of Date
		 * @return void
		 */
		public function set loginTime(loginTime:Date):void
		{
			this._loginTime=loginTime;
		}
		
		/**
		 * @public
		 * function to get logOut Time
		 *
		 * @return Date
		 */
		
		public function get logOutTime():Date
		{
			return _logOutTime;
		}
		
		/**
		 * @public
		 * function to set logOut Time
		 * @param logOutTime type of Date
		 * @return void
		 */
		public function set logOutTime(logOutTime:Date):void
		{
			this._logOutTime=logOutTime;
		}
		
		/**
		 * @public
		 * function to get operating System
		 *
		 * @return String
		 */
		
		public function get operatingSystem():String
		{
			return _operatingSystem;
		}
		
		/**
		 * @public
		 * function to set operating System
		 * @param operatingSystem type of String
		 * @return void
		 */
		public function set operatingSystem(operatingSystem:String):void
		{
			this._operatingSystem=operatingSystem;
		}
		
		/**
		 * @public
		 * function to get flashPlayer Version
		 *
		 * @return String
		 */
		
		public function get flashPlayerVersion():String
		{
			return _flashPlayerVersion;
		}
		
		/**
		 * @public
		 * function to set flash Player Version
		 * @param flashPlayerVersion type of String
		 * @return void
		 */
		public function set flashPlayerVersion(flashPlayerVersion:String):void
		{
			this._flashPlayerVersion=flashPlayerVersion;
		}
		
		/**
		 * @public
		 * function to get network Connection Type
		 *
		 * @return String
		 */
		
		public function get networkConnectionType():String
		{
			return _networkConnectionType;
		}
		
		/**
		 * @public
		 * function to set network Connection Type
		 * @param networkConnectionType type of String
		 * @return void
		 */
		public function set networkConnectionType(networkConnectionType:String):void
		{
			this._networkConnectionType=networkConnectionType;
		}
		
		/**
		 * @public
		 * function to get ip Address
		 *
		 * @return String
		 */
		
		public function get ipAddress():String
		{
			return _ipAddress;
		}
		
		/**
		 * @public
		 * function to set ip Address
		 * @param ipAddress type of String
		 * @return void
		 */
		public function set ipAddress(ipAddress:String):void
		{
			this._ipAddress=ipAddress;
		}
		
		/**
		 * @public
		 * function to get aview Version
		 *
		 * @return String
		 */
		
		public function get aviewVersion():String
		{
			return _aviewVersion;
		}
		
		/**
		 * @public
		 * function to set aview Version
		 * @param aviewVersion type of String
		 * @return void
		 */
		public function set aviewVersion(aviewVersion:String):void
		{
			this._aviewVersion=aviewVersion;
		}
		
		/**
		 * @public
		 * function to get gui Mode
		 *
		 * @return String
		 */
		
		public function get guiMode():String
		{
			return _guiMode;
		}
		
		/**
		 * @public
		 * function to set gui Mode
		 * @param value type of String
		 * @return void
		 */
		public function set guiMode(value:String):void
		{
			_guiMode=value;
		}
		
		/**
		 * @public
		 * function to get hardware Address
		 *
		 * @return String
		 */
		
		public function get hardwareAddress():String
		{
			return _hardwareAddress;
		}
		
		/**
		 * @public
		 * function to set hardware Address
		 * @param value type of String
		 * @return void
		 */
		public function set hardwareAddress(value:String):void
		{
			_hardwareAddress=value;
		}
		
		/**
		 * @public
		 * function to get external IP Address
		 *
		 * @return String
		 */
		
		public function get externalIPAddress():String
		{
			return _externalIPAddress;
		}
		
		/**
		 * @public
		 * function to set external IPAddress
		 * @param value type of String
		 * @return void
		 */
		public function set externalIPAddress(value:String):void
		{
			_externalIPAddress=value;
		}
	}
}
