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
 * File			: InstituteAdminUserVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Institute Admin User
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.InstituteAdminUser")]
	public class InstituteAdminUserVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function InstituteAdminUserVO()
		{
		}
		/**
		 * The institute admin user id
		 */
		private var _instituteAdminUserId:Number=0;
		/**
		 * The institute object
		 */
		private var _institute:InstituteVO=null;
		/**
		 * The user object
		 */
		private var _user:UserVO=null;
		
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
		 * function to set instituteAdminUserId
		 * @param instituteAdminUserId type of Number
		 * @return void
		 */
		
		public function set instituteAdminUserId(instituteAdminUserId:Number):void
		{
			this._instituteAdminUserId=instituteAdminUserId;
		}
		
		/**
		 * @public
		 * function to get user
		 *
		 * @return UserVO
		 */
		
		public function get user():UserVO
		{
			return _user;
		}
		
		/**
		 * @public
		 * function to set user
		 * @param user type of UserVO
		 * @return void
		 */
		
		public function set user(user:UserVO):void
		{
			this._user=user;
		}
		
		/**
		 * @public
		 * function to get institute
		 *
		 * @return InstituteVO
		 */
		
		public function get institute():InstituteVO
		{
			return this._institute;
		}
		
		/**
		 * @public
		 * function to set institute
		 * @param institute type of InstituteVO
		 * @return void
		 */
		
		public function set institute(institute:InstituteVO):void
		{
			this._institute=institute;
		}
	}
}
