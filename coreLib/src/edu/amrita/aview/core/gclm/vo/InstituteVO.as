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
 * File			: InstituteVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Institute
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	import mx.collections.ArrayCollection;
	
	//The remote java class file which is mapped with this VO class	
	//This class is declared as dynamic, since it uses some of the class 
	//variables which are not therer at the server side.
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.Institute")]
	public dynamic class InstituteVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function InstituteVO()
		{
		}
		/**
		 * The institute id
		 */
		private var _instituteId:Number=0;
		/**
		 * The institute name
		 */
		private var _instituteName:String=null;
		/**
		 * The institute type
		 */
		private var _instituteType:String=null;
		/**
		 * The institute category
		 */
		private var _instituteCategory:String=null;
		
		/**
		 * The address
		 */
		private var _address:String=null;
		/**
		 * The city
		 */
		private var _city:String=null;
		
		/**
		 * The district id
		 */
		private var _districtId : Number = 0;		
		/**
		 * The parent institute id
		 */
		private var _parentInstituteId:Number=0;
		
		/**
		 * The district name
		 */
		private var _districtName:String=null;
		/**
		 * The parent institute name
		 */
		private var _parentInstituteName:String=null;
		/**
		 * The state name
		 */
		private var _stateName:String=null;
		/**
		 * The isFireWalled value
		 */
		private var _isFireWalled:String=null;
		
		/**
		 * The institute admin users
		 */
		private var _instituteAdminUsers:ArrayCollection=null;
		
		/**
		 * The institute servers
		 */
		private var _instituteServers:ArrayCollection=null;
		
		/**
		 * The institute brandings
		 */
		private var _instituteBrandings:ArrayCollection=null;
		/**
		 * The maximum publishing bandwidth in Kbps
		 */
		private var _maxPublishingBandwidthKbps:Number=0;
		/**
		 * The maximum receiving bandwidth in Kbps
		 */
		private var _minPublishingBandwidthKbps:Number=0;

		
		/**
		 * @public
		 * function to get isFireWalled
		 *
		 * @return String
		 */
		public function get isFireWalled():String
		{
			return _isFireWalled;
		}
		
		/**
		 * @public
		 * function to set isFireWalled
		 * @param value type of String
		 * @return void
		 */
		public function set isFireWalled(value:String):void
		{
			_isFireWalled=value;
		}
		
		/**
		 * @public
		 * function to get instituteId
		 *
		 * @return Number
		 */
		
		public function get instituteId():Number
		{
			return _instituteId;
		}
		
		/**
		 * @public
		 * function to set instituteId
		 * @param instituteId type of Number
		 * @return void
		 */
		
		public function set instituteId(instituteId:Number):void
		{
			this._instituteId=instituteId;
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
		 * function to get instituteType
		 *
		 * @return String
		 */
		
		public function get instituteType():String
		{
			return _instituteType;
		}
		
		/**
		 * @public
		 * function to set instituteType
		 * @param instituteType type of String
		 * @return void
		 */
		
		public function set instituteType(instituteType:String):void
		{
			this._instituteType=instituteType;
		}
		
		/**
		 * @public
		 * function to get instituteCategory
		 *
		 * @return String
		 */
		
		public function get instituteCategory():String
		{
			return _instituteCategory;
		}
		
		/**
		 * @public
		 * function to set instituteCategory
		 * @param instituteCategory type of String
		 * @return void
		 */
		
		public function set instituteCategory(instituteCategory:String):void
		{
			this._instituteCategory=instituteCategory;
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
		 * @param instituteAddress type of String
		 * @return void
		 */
		
		public function set address(instituteAddress:String):void
		{
			this._address=instituteAddress;
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
		 * @param instituteCity type of String
		 * @return void
		 */
		
		public function set city(instituteCity:String):void
		{
			this._city=instituteCity;
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
		 * @param instituteDistrictId the instituteDistrictId to set
		 */
		
	   	public function set districtId(instituteDistrictId: Number) : void
		{
			this._districtId = instituteDistrictId;
	   	}

		/**
		 * @return the instituteDistrictId
		 */
		public function get districtId() : Number
		{
			return _districtId;
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
		 * @param institutePI type of String
		 * @return void
		 */
		
		public function set parentInstituteName(institutePI:String):void
		{
			this._parentInstituteName=institutePI;
		}
		
		/**
		 * @public
		 * function to get parentInstituteId
		 *
		 * @return Number
		 */
		
		public function get parentInstituteId():Number
		{
			return _parentInstituteId;
		}
		
		/**
		 * @public
		 * function to set parentInstituteId
		 * @param institutePIId type of Number
		 * @return void
		 */
		
		public function set parentInstituteId(institutePIId:Number):void
		{
			this._parentInstituteId=institutePIId;
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
		 * function to get maxPublishingBandwidthKbps
		 *
		 * @return Number
		 *
		 */
		
		public function get maxPublishingBandwidthKbps():Number
		{
			return _maxPublishingBandwidthKbps;
		}

		/**
		 * @public
		 * function to set maxPublishingBandwidthKbps
		 * @param maxPublishingBandwidthKbps type of Number
		 * @return void
		 *
		 */
		
		public function set maxPublishingBandwidthKbps(maxPublishingBandwidthKbps:Number):void
		{
			this._maxPublishingBandwidthKbps=maxPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to get maxReceivingBandwidthKbps
		 *
		 * @return Number
		 *
		 */
		
		public function get minPublishingBandwidthKbps():Number
		{
			return _minPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to set maxReceivingBandwidthKbps
		 * @param  maxReceivingBandwidthKbps type of Number
		 * @return void
		 *
		 */
		
		public function set minPublishingBandwidthKbps(minPublishingBandwidthKbps:Number):void
		{
			this._minPublishingBandwidthKbps=minPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to get instituteAdminUsers
		 *
		 * @return ArrayCollection
		 */
		
		public function get instituteAdminUsers():ArrayCollection
		{
			return this._instituteAdminUsers;
		}
		
		/**
		 * @public
		 * function to set instituteAdminUsers
		 * @param instituteAdminUsers type of ArrayCollection
		 * @return void
		 */
		
		public function set instituteAdminUsers(instituteAdminUsers:ArrayCollection):void
		{
			this._instituteAdminUsers=instituteAdminUsers;
		}
		
		/**
		 * @public
		 * function to add Institute Admin User
		 * @param instituteAdminUser type of InstituteAdminUserVO
		 * @return void
		 */
		
		public function addInstituteAdminUser(instituteAdminUser:InstituteAdminUserVO):void
		{
			//Check for null. If null create the new array collection object
			if (this._instituteAdminUsers == null)
			{
				this._instituteAdminUsers=new ArrayCollection();
			}
			instituteAdminUser.institute=this;
			this._instituteAdminUsers.addItem(instituteAdminUser);
		}
		
		/**
		 * @public
		 * function to get instituteServers
		 *
		 * @return ArrayCollection
		 */
		
		public function get instituteServers():ArrayCollection
		{
			return this._instituteServers;
		}
		
		/**
		 * @public
		 * function to set instituteServers
		 * @param instituteServers type of ArrayCollection
		 * @return void
		 */
		public function set instituteServers(instituteServers:ArrayCollection):void
		{
			this._instituteServers=instituteServers;
		}
		
		/**
		 * @public
		 * function to  add Institute Server
		 * @param instituteServer type of InstituteServerVO
		 * @return void
		 */
		public function addInstituteServer(instituteServer:InstituteServerVO):void
		{
			//Check for null. If null create the new array collection object
			if (this._instituteServers == null)
			{
				this._instituteServers=new ArrayCollection();
			}
			instituteServer.institute=this;
			this._instituteServers.addItem(instituteServer);
		}
		
		/**
		 * @public
		 * function to get instituteBrandings
		 *
		 * @return ArrayCollection
		 */
		
		public function get instituteBrandings():ArrayCollection
		{
			return this._instituteBrandings;
		}
		
		/**
		 * @public
		 * function to set instituteBrandings
		 * @param instituteBrandings type of ArrayCollection
		 * @return void
		 */
		public function set instituteBrandings(instituteBrandings:ArrayCollection):void
		{
			this._instituteBrandings=instituteBrandings;
		}
		
		/**
		 * @public
		 * function to add Institute Branding
		 * @param instituteBranding type of InstituteBrandingVO
		 * @return void
		 */
		public function addInstituteBranding(instituteBranding:InstituteBrandingVO):void
		{
			//Check for null. If null create the new array collection object
			if (this._instituteBrandings == null)
			{
				this._instituteBrandings=new ArrayCollection();
			}
			instituteBranding.institute=this;
			this._instituteBrandings.addItem(instituteBranding);
		}
	}
}
