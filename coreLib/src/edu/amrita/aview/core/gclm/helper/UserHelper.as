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
 * File			: UserHelper.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This helper class is used to call the remote java methods
 * 
 */
package edu.amrita.aview.core.gclm.helper
{
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class UserHelper extends AbstractHelper
	{
		private var userHelperRO:RemoteObject=null;
		
		public function UserHelper()
		{
			userHelperRO=new RemoteObject();
			userHelperRO.destination="userhelper";
			userHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			userHelperRO.showBusyCursor=true;
			
			userHelperRO.getUserCount.addEventListener(ResultEvent.RESULT, getUserCountResultHandler);
			userHelperRO.getUserCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.searchActiveUsers.addEventListener(ResultEvent.RESULT, searchActiveUsersResultHandler);
			userHelperRO.searchActiveUsers.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.createUser.addEventListener(ResultEvent.RESULT, createUserResultHandler);
			userHelperRO.createUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.updateUser.addEventListener(ResultEvent.RESULT, updateUserResultHandler);
			userHelperRO.updateUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.deleteUser.addEventListener(ResultEvent.RESULT, deleteUserResultHandler);
			userHelperRO.deleteUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.getUser.addEventListener(ResultEvent.RESULT, getUserResultHandler);
			userHelperRO.getUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.getUserByUserName.addEventListener(ResultEvent.RESULT, getUserByUserNameResultHandler);
			userHelperRO.getUserByUserName.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.getGuestUserForTheClass.addEventListener(ResultEvent.RESULT, getGuestUserForTheClassResultHandler);
			userHelperRO.getGuestUserForTheClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.getUserByUserNamePassword.addEventListener(ResultEvent.RESULT, getUserResultHandler);
			userHelperRO.getUserByUserNamePassword.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.getUsers.addEventListener(ResultEvent.RESULT, getUsersResultHandler);
			userHelperRO.getUsers.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.searchPendingUsers.addEventListener(ResultEvent.RESULT, searchPendingUsersResultHandler);
			userHelperRO.searchPendingUsers.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.approvePendingUsers.addEventListener(ResultEvent.RESULT, approvePendingUsersResultHandler);
			userHelperRO.approvePendingUsers.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.updateUserChangePass.addEventListener(ResultEvent.RESULT, updateUserChangePassResultHandler);
			userHelperRO.updateUserChangePass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.resetPassword.addEventListener(ResultEvent.RESULT, resetPasswordResultHandler);
			userHelperRO.resetPassword.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.searchUsers.addEventListener(ResultEvent.RESULT, searchUsersResultHandler);
			userHelperRO.searchUsers.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			userHelperRO.searchUsersByName.addEventListener(ResultEvent.RESULT, searchUsersByNameResultHandler);
			userHelperRO.searchUsersByName.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
		}

		/**
		 *  @public
		 * Function :To search Users
		 * @param firstName of type String
		 * @param lastName of type String 
		 * @param userName of type String
		 * @param role of type String
		 * @param location of type String
		 * @param instituteId of type Number
		 * @param instituteAdminId of type Number
		 * @param statusId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function searchUsers(firstName:String, lastName:String, userName:String, role:String, location:String, instituteId:Number, instituteAdminId:Number, statusId:int,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.searchActiveUsers(firstName, lastName, userName, role, location, instituteId, instituteAdminId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get UserCount
		 * @param institudeId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getUserCount(institudeId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.getUserCount(institudeId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To search Active Users
		 * @param fName of type String
		 * @param lName of type String
		 * @param userName of type String
		 * @param role of type String
		 * @param city of type String
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * @param adminId of type Number
		 * @param emailId of type Number
		 * @param mobileNumber of type String
		 * @param districtId of type Number
		 * @param stateId of type Number
		 * 
		 */
		public function searchActiveUsers(fName:String, lName:String,
										  userName:String, role:String, city:String, 
										  instituteId:Number, onResult :Function, onFault :Function =null , adminId:Number=0, 
										  emailId:String=null, mobileNumber:String=null,
										  districtId:Number=0,stateId:Number=0):void
		{
			var token:AsyncToken=userHelperRO.searchActiveUsers(fName, lName, userName, role, city, 
				instituteId, adminId, emailId, mobileNumber,districtId,stateId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 *  @public
		 * Function :To search Active Users
		 * @param fName of type String
		 * @param lName of type String
		 * @param userName of type String
		 * @param role of type String
		 * @param city of type String
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * @param adminId of type Number
		 * @param emailId of type Number
		 * @param mobileNumber of type String
		 * 
		 */
		public function searchPendingUsers(fName:String, lName:String, userName:String, role:String, city:String, instituteId:Number, onResult :Function, onFault:Function =null, adminId:Number=0, emailId:String=null, mobileNumber:String=null, districtId:Number = 0,stateId:Number = 0):void
		{
			var token:AsyncToken=userHelperRO.searchPendingUsers(fName, lName, userName, role, city, instituteId, adminId, emailId, mobileNumber, districtId, stateId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To approve PendingUsers
		 * @param userIds of type Array
		 * @param approverId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function approvePendingUsers(userIds:Array, approverId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.approvePendingUsers(userIds, approverId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get User
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function 
		 * @param callBackFunction of type Function
		 * 
		 */
		public function getUser(userId:Number, onResult :Function ,onFault :Function = null, callBackFunction:Function=null):void
		{
			var token:AsyncToken=userHelperRO.getUser(userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
			if (callBackFunction != null)
			{
				token.callBack=callBackFunction;
			}
		}
		
		/**
		 * @public
		 * Function :To getUser By UserName
		 * @param userName of type String
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getUserByUserName(userName:String,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.getUserByUserName(userName);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To getUser By UserName Password
		 * @param userName of type String
		 * @param password of type String
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getUserByUserNamePassword(userName:String, password:String,onResult:Function , onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.getUserByUserNamePassword(userName, password);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get GuestUser For The Class
		 * @param lectureId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getGuestUserForTheClass(lectureId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.getGuestUserForTheClass(lectureId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get Users
		 * @param userIds of type Array
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getUsers(userIds:Array , onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.getUsers(userIds);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To create User
		 * @param userVO of type UserVO
		 * @param creatorId of type Number
		 * @param statusId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createUser(userVO:UserVO, creatorId:Number, statusId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.createUser(userVO, creatorId, statusId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :updateUser
		 * @param userVO of type UserVO
		 * @param updaterId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function updateUser(userVO:UserVO, updaterId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.updateUser(userVO, updaterId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete User
		 * @param userId of type Number
		 * @param updatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteUser(userId:Number, updatorId:Number,onResult :Function ,onFault :Function =null):void
		{
			var token:AsyncToken=userHelperRO.deleteUser(userId, updatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :updateUserChangePass
		 * @param newPassWd of type String
		 * @param userId of type Number
		 * @param updatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function updateUserChangePass(newPassWd:String, userId:Number, updatorId:Number,onResult :Function ,onFault :Function =null):void
		{
			var token:AsyncToken=userHelperRO.updateUserChangePass(newPassWd, userId, updatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To reset Password
		 * @param callerComp
		 * @param userName
		 * @param emailId
		 * @return void
		 */
		public function resetPassword(userName:String, emailId:String,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.resetPassword(userName, emailId);
			token.onResult = onResult ;
			token.onFault = onFault;
		}
		
		public function searchUsersByName(name:String,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=userHelperRO.searchUsersByName(name);
			token.onResult = onResult ;
			token.onFault = onFault;
		}
		/**
		 * @private
		 * Function :ResultHandler for searchUsers
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchUsersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getUserCount
		 * @param event of type ResultEvent
		 * 
		 */
		private function getUserCountResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as Number);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for searchActiveUsers
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchActiveUsersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}			
		
		/**
		 * @private
		 * Function :ResultHandler for searchPendingUsers
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchPendingUsersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for approvePendingUsers
		 * @param event of type ResultEvent
		 * 
		 */
		private function approvePendingUsersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getUser
		 * @param event of type ResultEvent
		 * 
		 */
		private function getUserResultHandler(event:ResultEvent):void
		{
			if (event.token.callBack == null)
			{
				//var test:UserVO = event.result as UserVO;
				event.token.onResult(event.result as UserVO);
				
			}
			else
			{
				var callBackFunction:Function=event.token.callBack as Function;
				callBackFunction(event.result as UserVO);
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getUserByUserName
		 * @param event of type ResultEvent
		 * 
		 */
		private function getUserByUserNameResultHandler(event:ResultEvent):void
		{
			if (event.token.callBack == null)
			{
				event.token.onResult(event.result as UserVO);
			}
			else
			{
				var callBackFunction:Function=event.token.callBack as Function;
				callBackFunction(event.result as UserVO);
			}
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getGuestUserForTheClass
		 * @param event of type ResultEvent
		 * 
		 */
		private function getGuestUserForTheClassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as UserVO);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getUsers
		 * @param event of type ResultEvent
		 * 
		 */
		private function getUsersResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as UserVO);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for createUser
		 * @param event of type ResultEvent
		 * 
		 */
		private function createUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for updateUser
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for deleteUser
		 * @param event of type ResultEvent
		 * 
		 */
		
		private function deleteUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}		
		
		/**
		 * @private
		 * Function :ResultHandler for updateUserChangePass
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateUserChangePassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for resetPassword
		 * @param event of type ResultEvent
		 * 
		 */
		private function resetPasswordResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		private function searchUsersByNameResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
	}
}
