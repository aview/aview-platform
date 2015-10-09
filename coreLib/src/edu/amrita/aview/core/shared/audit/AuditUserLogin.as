////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: AuditUserLogin.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * This class helps in auditing the user login details during login
 * and also update the same audit details during logout.
 *
 */

package edu.amrita.aview.core.shared.audit
{
	//A-VIEW imports
	import edu.amrita.aview.core.shared.audit.helper.AuditUserLoginHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.UserLoginVO;
	
	//Utility imports
	import flash.system.Capabilities;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	applicationType::DesktopMobile
	{
		import flash.net.NetworkInfo;
		import flash.net.NetworkInterface;
	}
	
	/**
	 * This class helps in auditing the user login details during login
	 * and also update the same audit details during logout.
	 *
	 */
	public class AuditUserLogin
	{
		/**
		 * Logger for file and console logging
		 */
		private var auditLog:ILogger=Log.getLogger("edu.amrita.aview.audit.AuditUserLogin");
		
		/**
		 * Helps in sending the AuditUserLoginVO to database
		 */
		private var userLoginHelper:AuditUserLoginHelper=new AuditUserLoginHelper();
		
		/**
		 * Flag to prevent update being called multiple times from various logout/close functions
		 */
		public var updateUserLoginCalled:Boolean=false;
		
		/**
		 * @public
		 *
		 * Populates the UserLoginVO with various details and passes it the helper class for storing in database
		 *
		 * @param version - Version of the A-VIEW client software
		 *
		 * @return void
		 */
		public function auditLogin(version:String):void
		{
			/*To find Network details*/
			applicationType::DesktopMobile
			{
				var results:Vector.<NetworkInterface>=NetworkInfo.networkInfo.findInterfaces();
				for (var i:int=0; i < results.length; i++)
				{
					if (ClassroomContext.networkConnectionType.length == 0)
					{
						ClassroomContext.networkConnectionType=results[i].displayName;
					}
					else
					{
						ClassroomContext.networkConnectionType=ClassroomContext.networkConnectionType + "," + results[i].displayName;
					}
					for (var j:int=0; j < results[i].addresses.length; j++)
					{
						if (ClassroomContext.ipAddress.length == 0)
						{
							ClassroomContext.ipAddress=results[i].addresses[j].address;
						}
						else
						{
							ClassroomContext.ipAddress=ClassroomContext.ipAddress + "," + results[i].addresses[j].address;
						}
					}
					if (results[i].hardwareAddress != "")
					{
						ClassroomContext.hardwareAddress=results[i].hardwareAddress;
					}
				}
			}
			
			var userLoginVO:UserLoginVO=new UserLoginVO();
			//User id
			userLoginVO.userId=ClassroomContext.userVO.userId;
			
			//A-VIEW Version
			userLoginVO.aviewVersion=version;
			
			//Setup the network details
			userLoginVO.ipAddress=ClassroomContext.ipAddress;
			userLoginVO.hardwareAddress=ClassroomContext.hardwareAddress;
			userLoginVO.networkConnectionType=ClassroomContext.networkConnectionType;
			
			//OS and Software details
			userLoginVO.operatingSystem=Capabilities.os;
			userLoginVO.flashPlayerVersion=Capabilities.version;
			userLoginVO.guiMode="Single Window";
			applicationType::DesktopWeb{
				userLoginVO.authMode=FlexGlobals.topLevelApplication.mainApp.authenticationMode;
			}
			applicationType::mobile{
				userLoginVO.authMode=FlexGlobals.topLevelApplication.authenticationMode;
			}
			//Login time is set on the server side.
			userLoginHelper.createUserLogin(userLoginVO,createUserLoginResultHandler);
		
		}
		
		/**
		 * @public
		 *
		 * Result handler for the database storage call
		 *
		 * @param userLoginVO - Returned UserLoginVO from the server. Has the database id populated
		 *
		 * @return void
		 */
		public function createUserLoginResultHandler(userLoginVO:UserLoginVO):void
		{
			if (Log.isInfo()) auditLog.info("createUserLogin{0}", userLoginVO.toString());
			AuditContext.userLoginVO=userLoginVO;
		}
		
		/**
		 * @public
		 *
		 * Update the UserLoginVO on the server. Called during logout/closing the application to update the logout time.
		 *
		 * @param userLoginVO - UserLoginVO which was returned from the server after the login
		 *
		 * @return void
		 */
		public function updateAuditUserLogin(userLoginVO:UserLoginVO):void
		{
			if (!updateUserLoginCalled)
			{
				updateUserLoginCalled=true;
				userLoginHelper.updateUserLogin(userLoginVO,updateUserLoginResultHandler);
			}
		}
		
		/**
		 * @public
		 *
		 * Result handler for the database update call
		 *
		 * @param userLoginVO - Returned UserLoginVO from the server after updating the logout time
		 *
		 * @return void
		 */
		public function updateUserLoginResultHandler(userLoginVO:UserLoginVO):void
		{
			if (Log.isInfo())auditLog.info("updateAuditUserLogin{0}", userLoginVO.toString());
		}
	
	}
}

