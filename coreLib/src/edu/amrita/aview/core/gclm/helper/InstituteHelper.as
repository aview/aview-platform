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
 * File			: InstituteHelper.as
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
	import edu.amrita.aview.core.gclm.vo.InstituteVO;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import spark.modules.*;
	
	public class InstituteHelper extends AbstractHelper
	{
		private var instituteHelperRO:RemoteObject=null;
		
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.gclm.helper.InstituteHelper.as");
		
		public function InstituteHelper()
		{
			instituteHelperRO=new RemoteObject();
			instituteHelperRO.destination="institutehelper";
			instituteHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			instituteHelperRO.showBusyCursor=true;
			
			instituteHelperRO.getInstituteById.addEventListener(ResultEvent.RESULT, getInstituteByIdResultHandler);
			instituteHelperRO.getInstituteById.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllInstitutes.addEventListener(ResultEvent.RESULT, getAllInstitutesResultHandler);
			instituteHelperRO.getAllInstitutes.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllInstitutesData.addEventListener(ResultEvent.RESULT, getAllInstitutesResultHandler);
			instituteHelperRO.getAllInstitutesData.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllInstitutesEssentialDetails.addEventListener(ResultEvent.RESULT, getAllInstitutesEssentialDetailsResultHandler);
			instituteHelperRO.getAllInstitutesEssentialDetails.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllInstitutesForAdmin.addEventListener(ResultEvent.RESULT, getAllInstitutesResultHandler);
			instituteHelperRO.getAllInstitutesForAdmin.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllInstitutesDataForAdmin.addEventListener(ResultEvent.RESULT, getAllInstitutesResultHandler);
			instituteHelperRO.getAllInstitutesDataForAdmin.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			
			instituteHelperRO.getAllInstitutesEssentialDetailsForAdmin.addEventListener(ResultEvent.RESULT, getAllInstitutesEssentialDetailsResultHandler);
			instituteHelperRO.getAllInstitutesEssentialDetailsForAdmin.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllCourseOfferingInstitutes.addEventListener(ResultEvent.RESULT, getAllCourseOfferingInstitutesResultHandler);
			instituteHelperRO.getAllCourseOfferingInstitutes.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.getAllCourseOfferingInstitutesForAdmin.addEventListener(ResultEvent.RESULT, getAllCourseOfferingInstitutesResultHandler);
			instituteHelperRO.getAllCourseOfferingInstitutesForAdmin.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.createInstitute.addEventListener(ResultEvent.RESULT, createInstituteResultHandler);
			instituteHelperRO.createInstitute.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.updateInstitute.addEventListener(ResultEvent.RESULT, updateInstituteResultHandler);
			instituteHelperRO.updateInstitute.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.deleteInstitute.addEventListener(ResultEvent.RESULT, deleteInstituteResultHandler);
			instituteHelperRO.deleteInstitute.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.deleteApprovalPendingInstitutes.addEventListener(ResultEvent.RESULT, deleteApprovalPendingInstitutesResultHandler);
			instituteHelperRO.deleteApprovalPendingInstitutes.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.activateInstitute.addEventListener(ResultEvent.RESULT, activateInstituteResultHandler);
			instituteHelperRO.activateInstitute.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.searchPendingApprovalInstitutes.addEventListener(ResultEvent.RESULT, searchPendingApprovalInstitutesResultHandler);
			instituteHelperRO.searchPendingApprovalInstitutes.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			instituteHelperRO.approvePendingInstitutes.addEventListener(ResultEvent.RESULT, approvePendingInstitutesResultHandler);
			instituteHelperRO.approvePendingInstitutes.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}

		/**
		 * @public
		 * Function :To get Institute by Id.
		 * @param instituteId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getInstituteById(instituteId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.getInstituteById(instituteId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get All Institutes Essential Details
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getAllInstitutesEssentialDetails(onResult :Function , onFault :Function = null):void
		{
			if(Log.isDebug()) log.debug("getAllInstitutes at:" + new Date());
			var token:AsyncToken=instituteHelperRO.getAllInstitutesEssentialDetails();
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get All Institutes
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getAllInstitutes(onResult :Function , onFault :Function = null):void
		{
			if(Log.isDebug()) log.debug("getAllInstitutes at:" + new Date());
			var token:AsyncToken=instituteHelperRO.getAllInstitutes();
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get All Institutes Data
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * @param instName of type String
		 * @param cityName of type String
		 * @param pInstName of type String
		 * 
		 */
		public function getAllInstitutesData(onResult:Function, onFault:Function =null ,instName:String=null, cityName:String=null, pInstName:String=null):void
		{
			if(Log.isDebug()) log.debug("getAllInstitutesData at:" + new Date());
			var token:AsyncToken=instituteHelperRO.getAllInstitutesData(instName, cityName, pInstName);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get All Course Offering Institutes For Admin
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getAllCourseOfferingInstitutesForAdmin(adminId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.getAllCourseOfferingInstitutesForAdmin(adminId);
			token.onResult = onResult;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete Institute
		 * @param instituteId of type Number
		 * @param updatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteInstitute(instituteId:Number, updatorId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.deleteInstitute(instituteId, updatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get All Institutes Essential Details For Admin
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getAllInstitutesEssentialDetailsForAdmin(adminId:Number,onResult :Function , onFault :Function =null):void
		{
			var token:AsyncToken=instituteHelperRO.getAllInstitutesEssentialDetailsForAdmin(adminId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get All Institutes For Admin
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getAllInstitutesForAdmin(adminId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.getAllInstitutesForAdmin(adminId);
			token.onResult = onResult ;
			token.onFault = onFault;
		}
		
		/**
		 * @public
		 * Function :To get All Institutes Data For Admin
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * @param instName of type String
		 * @param cityName of type String
		 * @param pInstName of type String
		 * 
		 */
		public function getAllInstitutesDataForAdmin(adminId:Number, onResult:Function,onFault:Function = null, instName:String=null, cityName:String=null, pInstName:String=null):void
		{
			var token:AsyncToken=instituteHelperRO.getAllInstitutesDataForAdmin(adminId, instName, cityName, pInstName);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get AllCourse Offering Institutes
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getAllCourseOfferingInstitutes(onResult :Function , onFault :Function = null):void
		{
			if(Log.isDebug()) log.debug("getAllCourseOfferingInstitutes at:" + new Date());
			var token:AsyncToken=instituteHelperRO.getAllCourseOfferingInstitutes();
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To search Pending Approval Institutes
		 * @param searchStr of type String
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function searchPendingApprovalInstitutes(searchStr:String , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.searchPendingApprovalInstitutes(searchStr);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To Approve all Pending Institutes
		 * @param instituteIds of type Array
		 * @param creatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function approvePendingInstitutes(instituteIds:Array, creatorId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.approvePendingInstitutes(instituteIds, creatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To delete Approval Pending Institutes
		 * @param instituteIds of type Array
		 * @param creatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteApprovalPendingInstitutes(instituteIds:Array, creatorId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.deleteApprovalPendingInstitutes(instituteIds, creatorId);
			token.onResult = onResult ;
			token.onFault = onFault;
		}
		
		/**
		 * @public
		 * Function :To create Institute
		 * @param instituteVO of type InstituteVO
		 * @param creatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createInstitute(instituteVO:InstituteVO, creatorId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.createInstitute(instituteVO, creatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To Update institute
		 * @param instituteVO of type InstituteVO
		 * @param updaterId of type Number
		 * @param onResult of type Number
		 * @param onFault of type Number
		 * 
		 */
		public function updateInstitute(instituteVO:InstituteVO, updaterId:Number,onResult :Function ,onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.updateInstitute(instituteVO, updaterId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To activate all Institute
		 * @param instituteId of type Number
		 * @param updatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function activateInstitute(instituteId:Number, updatorId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=instituteHelperRO.activateInstitute(instituteId, updatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getInstituteById
		 * @param event of type ResultEvent
		 * 
		 */
		private function getInstituteByIdResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event.result as InstituteVO);
		}		
		
		/**
		 * @private
		 * Function :ResultHandler for getAllInstitutesEssentialDetails
		 * @param event of type ResultEvent
		 * 
		 */
		private function getAllInstitutesEssentialDetailsResultHandler(event:ResultEvent):void
		{
			if(Log.isInfo()) log.info("getAllInstitutesResultHandler at:" + new Date());
			event.token.onResult(event.result);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getAllInstitutes
		 * @param event of type ResultEvent
		 * 
		 */
		private function getAllInstitutesResultHandler(event:ResultEvent):void
		{
			if(Log.isInfo()) log.info("getAllInstitutesResultHandler at:" + new Date());
			event.token.onResult(event.result);
		}

		
		
		/**
		 * @private
		 * Function :ResultHandler for getAllCourseOfferingInstitutesForAdmin
		 * @param event of type ResultEvent
		 * 
		 */
		private function getAllCourseOfferingInstitutesResultHandler(event:ResultEvent):void
		{
			if(Log.isInfo()) log.info("getAllCourseOfferingInstitutesResultHandler at:" + new Date());
			event.token.onResult(event.result);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for deleteInstitute
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteInstituteResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for deleteApprovalPendingInstitutes
		 * @param event of type ResultEvent
		 * 
		 */
		private function deleteApprovalPendingInstitutesResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for createInstitute
		 * @param event of type ResultEvent
		 * 
		 */
		//PNCR: Send event.result to caller function and change all caller function to receive InstituteVO object. 
		private function createInstituteResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for updateInstitute
		 * @param event of type ResultEvent
		 * 
		 */
		//PNCR: Send event.result to caller function and change all caller function to receive InstituteVO object. 
		private function updateInstituteResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for activateInstitute
		 * @param event of type ResultEvent
		 * 
		 */
		private function activateInstituteResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for searchPendingApprovalInstitutes
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchPendingApprovalInstitutesResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for approvePendingInstitutes
		 * @param event of type ResultEvent
		 *
		 */
		private function approvePendingInstitutesResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event.result);
		}		
	}
}


