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
 * File			: ClassRegistrationHelper.as
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
	import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.utils.NameUtil;
	
	public class ClassRegistrationHelper extends AbstractHelper
	{
		private var classRegistrationRO:RemoteObject=null;
		//PNCR: the result handlers should be private function.
		public function ClassRegistrationHelper()
		{
			classRegistrationRO=new RemoteObject();
			classRegistrationRO.destination="classregistrationhelper";
			classRegistrationRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			classRegistrationRO.showBusyCursor=true;
			
			classRegistrationRO.getUserClassRegistrationCount.addEventListener(ResultEvent.RESULT, getUserClassRegistrationCountResultHandler);
			classRegistrationRO.getUserClassRegistrationCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.getClassRegistrationCount.addEventListener(ResultEvent.RESULT, getClassRegistrationCountResultHandler);
			classRegistrationRO.getClassRegistrationCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.getClassRegister.addEventListener(ResultEvent.RESULT, getClassRegisterByIdResultHandler);
			classRegistrationRO.getClassRegister.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.getClassRegistersForMasterAdminApproval.addEventListener(ResultEvent.RESULT, getClassRegistersForApprovalResultHandler);
			classRegistrationRO.getClassRegistersForMasterAdminApproval.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.getClassRegistersForInstituteAdminApproval.addEventListener(ResultEvent.RESULT, getClassRegistersForApprovalResultHandler);
			classRegistrationRO.getClassRegistersForInstituteAdminApproval.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.approvePendingClassRegistrations.addEventListener(ResultEvent.RESULT, approvePendingClassRegistrationsResultHandler);
			classRegistrationRO.approvePendingClassRegistrations.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.searchForClassRegister.addEventListener(ResultEvent.RESULT, searchForClassRegisterResultHandler);
			classRegistrationRO.searchForClassRegister.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.searchForClassRegisterForUser.addEventListener(ResultEvent.RESULT, searchForClassRegisterResultHandler);
			classRegistrationRO.searchForClassRegisterForUser.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.createClassRegistration.addEventListener(ResultEvent.RESULT, createClassRegistrationResultHandler);
			classRegistrationRO.createClassRegistration.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.updateClassRegistration.addEventListener(ResultEvent.RESULT, updateClassRegistrationResultHandler);
			classRegistrationRO.updateClassRegistration.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.deleteClassRegister.addEventListener(ResultEvent.RESULT, deleteClassRegisterResultHandler);
			classRegistrationRO.deleteClassRegister.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.getClassRepositoryFolderStructure.addEventListener(ResultEvent.RESULT, getClassRepositoryFolderStructureResultHandler);
			classRegistrationRO.getClassRepositoryFolderStructure.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classRegistrationRO.getAllRegisteredAndOpenClassesForUser.addEventListener("result", getAllRegisteredAndOpenClassesForUserResultHandler);
			classRegistrationRO.getAllRegisteredAndOpenClassesForUser.addEventListener("fault", genericFaultHandler);
			
			//Code change for NIC start
			//Event listener API to get the pending registration approvals for the moderator
			classRegistrationRO.getClassRegistersForModeratorApproval.addEventListener(ResultEvent.RESULT, getClassRegistersForApprovalResultHandler);
			classRegistrationRO.getClassRegistersForModeratorApproval.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			//Code change for NIC end
			
			classRegistrationRO.getClassRegistersForClass.addEventListener(ResultEvent.RESULT,getClassRegistersForClassResultHandler);
			classRegistrationRO.getClassRegistersForClass.addEventListener(FaultEvent.FAULT,getClassRegistersForClassFaultHandler);
		}
		
		public function getAllRegisteredAndOpenClassesForUser(userId:Number, onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken = classRegistrationRO.getAllRegisteredAndOpenClassesForUser(userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		public function getAllRegisteredAndOpenClassesForUserResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ArrayCollection)
		}
		
		/**
		 * @public
		 * Function :To get UserClassRegistrationCount
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getUserClassRegistrationCount(userId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getUserClassRegistrationCount(userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get ClassRegistrationCount
		 * @param classId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRegistrationCount(classId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRegistrationCount(classId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get ClassRegistration by classRegistrationId
		 * @param classRegistrationId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRegistrationById(classRegistrationId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRegister(classRegistrationId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get ClassRepositoryFolderStructure
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRepositoryFolderStructure(userId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRepositoryFolderStructure(userId);
			token.onResult =  onResult ;
			token.onFault = onFault ; 
		}
		
		/**
		 * @public
		 * Function :To get ClassRegistersForMasterAdminApproval
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRegistersForMasterAdminApproval(instituteId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRegistersForMasterAdminApproval(instituteId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get ClassRegisters For InstituteAdminApproval
		 * @param instituteId of type Number
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRegistersForInstituteAdminApproval(instituteId:Number, adminId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRegistersForInstituteAdminApproval(instituteId, adminId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To approve Pending ClassRegistrations
		 * @param classRegisterIds of type Array
		 * @param approverId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function approvePendingClassRegistrations(classRegisterIds:Array, approverId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.approvePendingClassRegistrations(classRegisterIds, approverId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To search for classRegister
		 * @param userName of type String
		 * @param fName of type String
		 * @param lName of type String
		 * @param classId of type Number
		 * @param isModerator of type String
		 * @param courseId of type Number
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param adminId of type Number
		 * @param onFault of type Function
		 * 
		 */
		public function searchForClassRegister(userName:String, fName:String, lName:String, classId:Number, isModerator:String, courseId:Number, instituteId:Number, onResult :Function, adminId:Number=0 , onFault :Function = null):void
		{
			var token:AsyncToken=null;
			if (adminId > 0)
			{
				token=classRegistrationRO.searchForClassRegister(userName, fName, lName, classId, isModerator, courseId, instituteId, adminId);
			}
			else
			{
				token=classRegistrationRO.searchForClassRegister(userName, fName, lName, classId, isModerator, courseId, instituteId);
			}
			
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 *  @public
		 * Function :To search ClassRegister for User
		 * @param userId of type Number
		 * @param classId of type Number
		 * @param isModerator of type String
		 * @param courseId of type Number
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function searchForClassRegisterForUser(userId:Number, classId:Number, isModerator:String, courseId:Number, instituteId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.searchForClassRegisterForUser(userId, classId, isModerator, courseId, instituteId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To create ClassRegistration
		 * @param classRegistration of type ClassRegisterVO
		 * @param creatorId of type Number
		 * @param statusId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createClassRegistration(classRegistration:ClassRegisterVO, creatorId:Number, statusId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.createClassRegistration(classRegistration, creatorId, statusId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To update ClassRegistration
		 * @param classRegistration of type ClassRegisterVO
		 * @param updaterId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function updateClassRegistration(classRegistration:ClassRegisterVO, updaterId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.updateClassRegistration(classRegistration, updaterId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete ClassRegister
		 * @param classRegistrationId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteClassRegister(classRegistrationId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.deleteClassRegister(classRegistrationId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		//Code change for NIC start
		//API to get the pending registration approvals for the moderator
		/**
		 *  @public
		 * Function :To getClassRegisters For ModeratorApproval
		 * @param instituteId of type Number
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassRegistersForModeratorApproval(instituteId:Number, adminId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRegistersForModeratorApproval(instituteId, adminId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}		
		//Code change for NIC end
		
		public function getClassRegistersForClass(classId:Number,onResult:Function,onFault:Function):void
		{
			var token:AsyncToken=classRegistrationRO.getClassRegistersForClass(classId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		private function getClassRegistersForClassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}
		private function getClassRegistersForClassFaultHandler(event:FaultEvent):void
		{
			event.token.onFault(event.fault);
		}
		
		
		/**
		 * @private
		 * Function :ResultHandler for getUserClassRegistrationCount
		 * @param event of type ResultEvent
		 * 
		 */
		private function getUserClassRegistrationCountResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result)			
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getClassRegistrationCount
		 * @param event of type ResultEvent
		 * 
		 */
		private function getClassRegistrationCountResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as Number) ;	
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for ClassRegisterById
		 * @param event of type ResultEvent
		 * 
		 */
		private function getClassRegisterByIdResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as ClassRegisterVO) ;			
		}
				
		/**
		 * @private
		 * Function :ResultHandler for getClassRepositoryFolderStructure
		 * @param event of type ResultEvent
		 * 
		 */
		private function getClassRepositoryFolderStructureResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result as String);			
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for getClassRegistersForApproval
		 * @param event of type ResultEvent
		 *
		 */
		private function getClassRegistersForApprovalResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for approvePendingClassRegistrations
		 * @param event of type ResultEvent
		 * 
		 */
		private function approvePendingClassRegistrationsResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for searchForClassRegister
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchForClassRegisterResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for createClassRegistration
		 * @param event of type ResultEvent
		 * 
		 */
		private function createClassRegistrationResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for updateClassRegistration
		 * @param event of type ResultEvent
		 * 
		 */
		private function updateClassRegistrationResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for deleteClassRegister
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteClassRegisterResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
	
		//Code change for NIC start
		/**
		 * @private
		 * Function :ResultHandler for getClassRegistersForModeratorApproval
		 * @param event of type ResultEvent
		 * 
		 */
		private function getClassRegistersForModeratorApprovalResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}		
	}
}