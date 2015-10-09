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
 * File			: UserVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for User
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	import edu.amrita.aview.core.entry.Constants;

	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.User")]
	public class UserVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		public function UserVO()
		{
		}
		
		public function getServerObject():Object
		{
			var obj:Object = new Object();
			obj["userId"] = userId;
			obj["userName"] = userName;
//			obj["userDisplayName"] = userDisplayName;
			return obj;
		}
		/**
		 * The user id
		 */
		private var _userId:Number=0;
		/**
		 * The user name
		 */
		private var _userName:String=null;
		/**
		 * The password
		 */
		private var _password:String=null;
		/**
		 * The role
		 */
		private var _role:String=null;
		/**
		 * The first name
		 */
		private var _fname:String=null;
		/**
		 * The last name
		 */
		private var _lname:String=null;
		/**
		 * The address
		 */
		private var _address:String=null;
		/**
		 * The city
		 */
		private var _city:String=null;
		/**
		 * The zip id
		 */
		private var _zipId:String=null;
		/**
		 * The email
		 */
		private var _email:String=null;
		/**
		 * The mobile number
		 */
		private var _mobileNumber:String=null;
		/**
		 * The institute id
		 */
		private var _instituteId:Number=0;
		/**
		 * The photo capture frequency seconds
		 */
		private var _photoCaptureFrequencySecs:Number=-1;
		
		/**
		 * The state id
		 */
		private var _stateId:Number=0;
		/**
		 * The district id
		 */
		private var _districtId:Number=0;
		
		/**
		 * The state name
		 */
		private var _stateName:String=null;
		/**
		 * The district name
		 */
		private var _districtName:String=null;
		/**
		 * The institute name
		 */
		private var _instituteName:String=null;
		/**
		 * The parent institute name
		 */
		private var _parentInstituteName:String=null;
		/**
		 * The user display name
		 */
		private var _userDisplayName:String=null;
		
		//Added for the Admin tool purpose.
		/**
		 * The isSelected value
		 */
		private var _isSelected:Boolean=false;
		/**
		 * The institute admin user id
		 */
		private var _instituteAdminUserId:Number=0;
		
		private var _createdFrom:String = null ;

		
		/**
		 * The user status
		 */
		public var userStatus:String = Constants.OFFLINE;
		
		
		
		/**
		 * @public
		 * function to get user Display Name
		 *
		 * @return String
		 */
		public function get userDisplayName():String
		{
			if(_fname!=_email)
			{
				_userDisplayName = _fname+" "+_lname;
			}
			else
			{
				_userDisplayName =_fname;
			}
			return _userDisplayName;
		}
		
		/**
		 * @public
		 * function to get institute Id
		 *
		 * @return Number
		 */
		
		public function get instituteId():Number
		{
			return _instituteId;
		}
		
		/**
		 * @public
		 * function to set institute Id
		 * @param value type of Number
		 * @return void
		 */
		public function set instituteId(value:Number):void
		{
			_instituteId=value;
		}
		
		/**
		 * @public
		 * function to get user Id
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
		 * function to get userName
		 *
		 * @return String
		 */
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * @public
		 * function to set userName
		 * @param userName type of String
		 * @return void
		 */
		
		public function set userName(userName:String):void
		{
			this._userName=userName;
		}
		
		/**
		 * @public
		 * function to get password
		 *
		 * @return String
		 */
		
		public function get password():String
		{
			return _password;
		}
		
		/**
		 * @public
		 * function to set password
		 * @param password type of String
		 * @return void
		 */
		
		public function set password(password:String):void
		{
			this._password=password;
		}
		
		/**
		 * @public
		 * function to get role
		 *
		 * @return String
		 */
		public function get role():String
		{
			return _role;
		}
		
		/**
		 * @public
		 * function to set role
		 * @param role type of String
		 * @return void
		 */
		
		public function set role(role:String):void
		{
			this._role=role;
		}
		
		/**
		 * @public
		 * function to get fname
		 *
		 * @return String
		 */
		
		public function get fname():String
		{
			return _fname;
		}
		
		/**
		 * @public
		 * function to set fname
		 * @param fname type of String
		 * @return void
		 */
		
		public function set fname(fname:String):void
		{
			this._fname=fname;
		}
		
		/**
		 * @public
		 * function to get lname
		 *
		 * @return String
		 */
		
		public function get lname():String
		{
			return _lname;
		}
		
		/**
		 * @public
		 * function to set lname
		 * @param lname type of String
		 * @return void
		 */
		
		public function set lname(lname:String):void
		{
			this._lname=lname;
		}
		
		/**
		 * @public
		 * function to get address
		 *
		 * @return String
		 */
		
		public function get address():String
		{
			return _address;
		}
		
		/**
		 * @public
		 * function to set address
		 * @param address type of String
		 * @return void
		 */
		
		public function set address(address:String):void
		{
			this._address=address;
		}
		
		/**
		 * @public
		 * function to get city
		 *
		 * @return String
		 */
		
		public function get city():String
		{
			return _city;
		}
		
		/**
		 * @public
		 * function to set city
		 * @param city type of String
		 * @return void
		 */
		
		public function set city(city:String):void
		{
			this._city=city;
		}
		
		/**
		 * @public
		 * function to get zipId
		 *
		 * @return String
		 */
		
		public function get zipId():String
		{
			return _zipId;
		}
		
		/**
		 * @public
		 * function to set zipId
		 * @param zipId type of String
		 * @return void
		 */
		
		public function set zipId(zipId:String):void
		{
			this._zipId=zipId;
		}
		
		/**
		 * @public
		 * function to get email
		 *
		 * @return String
		 */
		
		public function get email():String
		{
			return _email;
		}
		
		/**
		 * @public
		 * function to set email
		 * @param email type of String
		 * @return void
		 */
		
		public function set email(email:String):void
		{
			this._email=email;
		}
		
		/**
		 * @public
		 * function to get mobileNumber
		 *
		 * @return String
		 */
		
		public function get mobileNumber():String
		{
			return _mobileNumber;
		}
		
		/**
		 * @public
		 * function to set mobileNumber
		 * @param mobileNumber type of String
		 * @return void
		 */
		
		public function set mobileNumber(mobileNumber:String):void
		{
			this._mobileNumber=mobileNumber;
		}
		
		/**
		 * @public
		 * function to get stateName
		 *
		 * @return String
		 */
		
		public function get stateName():String
		{
			return _stateName;
		}
		
		/**
		 * @public
		 * function to set stateName
		 * @param stateName type of String
		 * @return void
		 */
		
		public function set stateName(stateName:String):void
		{
			this._stateName=stateName;
		}
		
		/**
		 * @public
		 * function to get districtName
		 *
		 * @return String
		 */
		
		public function get districtName():String
		{
			return _districtName;
		}
		
		/**
		 * @public
		 * function to set districtName
		 * @param districtName type of String
		 * @return void
		 */
		
		public function set districtName(districtName:String):void
		{
			this._districtName=districtName;
		}
		
		/**
		 * @public
		 * function to get instituteName
		 *
		 * @return String
		 */
		
		public function get instituteName():String
		{
			return _instituteName;
		}
		
		/**
		 * @public
		 * function to set instituteName
		 * @param instituteName type of String
		 * @return void
		 */
		
		public function set instituteName(instituteName:String):void
		{
			this._instituteName=instituteName;
		}
		
		/**
		 * @public
		 * function to get parentInstituteName
		 *
		 * @return String
		 */
		
		public function get parentInstituteName():String
		{
			return _parentInstituteName;
		}
		
		/**
		 * @public
		 * function to set parentInstituteName
		 * @param parentInstituteName type of String
		 * @return void
		 */
		
		public function set parentInstituteName(parentInstituteName:String):void
		{
			this._parentInstituteName=parentInstituteName;
		}
		
		/**
		 * @public
		 * function to get stateId
		 *
		 * @return Number
		 */
		
		public function get stateId():Number
		{
			return _stateId;
		}
		
		/**
		 * @public
		 * function to set stateId
		 * @param value type of Number
		 * @return void
		 */
		public function set stateId(value:Number):void
		{
			_stateId=value;
		}
		
		/**
		 * @public
		 * function to get districtId
		 *
		 * @return districtId type of Number
		 */
		
		public function get districtId():Number
		{
			return _districtId;
		}
		
		/**
		 * @public
		 * function to set districtId
		 * @param value type of Number
		 * @return void
		 */
		public function set districtId(value:Number):void
		{
			_districtId=value;
		}
		
		/**
		 * @public
		 * function to get isSelected
		 *
		 * @return Boolean
		 */
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		
		/**
		 * @public
		 * function to set isSelected
		 * @param value type of Boolean
		 * @return void
		 */
		public function set isSelected(value:Boolean):void
		{
			_isSelected=value;
		}
		
		/**
		 * @public
		 * function to get instituteAdminUserId
		 *
		 * @return Number
		 */
		
		public function get instituteAdminUserId():Number
		{
			return _instituteAdminUserId;
		}
		
		/**
		 * @public
		 * function to set institute Admin UserId
		 * @param value type of Number
		 * @return void
		 */
		public function set instituteAdminUserId(value:Number):void
		{
			_instituteAdminUserId=value;
		}
		
		/**
		 * @public
		 * function to get photo Capture Frequency Secs
		 *
		 * @return Number
		 */
		
		public function get photoCaptureFrequencySecs():Number
		{
			return _photoCaptureFrequencySecs;
		}
		
		/**
		 * @public
		 * function to set photo Capture Frequency Secs
		 * @param value type of Number
		 * @return void
		 */
		public function set photoCaptureFrequencySecs(value:Number):void
		{
			_photoCaptureFrequencySecs=value;
		}

		/**
		 * Denotes from which application (Website, GCLM, Meeting guest etc) the user is created 
		 */
		public function get createdFrom():String
		{
			return _createdFrom;
		}

		/**
		 * @private
		 */
		public function set createdFrom(value:String):void
		{
			_createdFrom = value;
		}

	}
}
