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
 * File			: ClassHelper.as
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
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	
	public class ClassHelper extends AbstractHelper
	{
		private var classHelperRO:RemoteObject=null;
		
		public function ClassHelper()
		{
			classHelperRO=new RemoteObject();
			classHelperRO.destination="classhelper";
			classHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			classHelperRO.showBusyCursor=true;
			
			classHelperRO.getClassCount.addEventListener(ResultEvent.RESULT, getClassCountResultHandler);
			classHelperRO.getClassCount.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.getClass.addEventListener(ResultEvent.RESULT, getClassByIDResultHandler);
			classHelperRO.getClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.getActiveClasses.addEventListener(ResultEvent.RESULT, getActiveClassesResultHandler);
			classHelperRO.getActiveClasses.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.getActiveClassesByAdmin.addEventListener(ResultEvent.RESULT, getActiveClassesResultHandler);
			classHelperRO.getActiveClassesByAdmin.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.getClassByUserId.addEventListener(ResultEvent.RESULT, getActiveClassesResultHandler);
			classHelperRO.getClassByUserId.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.createClass.addEventListener(ResultEvent.RESULT, createClassResultHandler);
			classHelperRO.createClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.updateClass.addEventListener(ResultEvent.RESULT, updateClassResultHandler);
			classHelperRO.updateClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.deleteClass.addEventListener(ResultEvent.RESULT, deleteClassResultHandler);
			classHelperRO.deleteClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.searchClass.addEventListener(ResultEvent.RESULT, searchClassResultHandler);
			classHelperRO.searchClass.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.closeClassForRegistration.addEventListener(ResultEvent.RESULT, closeClassForRegistrationResultHandler);
			classHelperRO.closeClassForRegistration.addEventListener(FaultEvent.FAULT, genericFaultHandler);
			
			classHelperRO.activateClassForRegistration.addEventListener(ResultEvent.RESULT, activateClassForRegistrationResultHandler);
			classHelperRO.activateClassForRegistration.addEventListener(FaultEvent.FAULT, genericFaultHandler);
		}
				
		/**
		 * @public
		 * Function :To get ClassCount by courseId
		 * @param classVO of type ClassVO
		 * @param courseId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassCount( courseId:Number,onResult:Function,onFault:Function = null):void
		{
			var token:AsyncToken=classHelperRO.getClassCount(courseId);
			token.onResult = onResult ;
			token.onFault = onFault ; 
		}
				
		/**
		 * @public
		 * Function :To get all classes by Id
		 * @param classVO of type ClassVO
		 * @param classId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassByID(classId:Number,onResult:Function , onFault:Function = null):void
		{
			var token:AsyncToken=classHelperRO.getClass(classId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
				
		/**
		 * @public
		 * Function :To get all active classes.
		 * @param classVO of type ClassVO
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getActiveClasses(onResult:Function , onFault:Function=null):void
		{
			var token:AsyncToken=classHelperRO.getActiveClasses();
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get all active classes by adminId
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getActiveClassesByAdmin(adminId:Number,onResult:Function ,onFault:Function = null):void
		{
			var token:AsyncToken=classHelperRO.getActiveClassesByAdmin(adminId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get classes by userId
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function getClassByUserId(userId:Number , onResult:Function , onFault:Function = null):void
		{
			var token:AsyncToken=classHelperRO.getClassByUserId(userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get deleteClass by classId and userId
		 * @param classId of type Number
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function deleteClass(classId:Number, userId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classHelperRO.deleteClass(classId, userId);
			token.onResult = onResult;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get close classes for registration
		 * @param classId of type Number
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function closeClassForRegistration(classId:Number, userId:Number,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classHelperRO.closeClassForRegistration(classId, userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get all active classes for registration by classId and userId
		 * @param classId of type Number
		 * @param userId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function`
		 * 
		 */
		public function activateClassForRegistration(classId:Number, userId:Number ,onResult :Function , onFault :Function =null):void
		{
			var token:AsyncToken=classHelperRO.activateClassForRegistration(classId, userId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To get all search classes
		 * @param instituteId of type Number
		 * @param courseId of type Number
		 * @param className of type String
		 * @param statusIds of type Array
		 * @param adminId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function searchClass(instituteId:Number, courseId:Number, className:String, statusIds:Array, onResult :Function,adminId:Number=0 ,onFault :Function = null):void
		{
			var token:AsyncToken=null;
			if (adminId != 0)
			{
				token=classHelperRO.searchClass(instituteId, courseId, className, adminId, statusIds);
			}
			else
			{
				token=classHelperRO.searchClass(instituteId, courseId, className, null, statusIds);
			}
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To Create classes
		 * @param classVO of type ClassVO
		 * @param creatorId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function createClass(classVO:ClassVO, creatorId:Number ,onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classHelperRO.createClass(classVO, creatorId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @public
		 * Function :To  update Class
		 * @param classVO of type ClassVO
		 * @param updaterId of type Number
		 * @param onResult of type Function
		 * @param onFault of type Function
		 * 
		 */
		public function updateClass(classVO:ClassVO, updaterId:Number , onResult :Function , onFault :Function = null):void
		{
			var token:AsyncToken=classHelperRO.updateClass(classVO, updaterId);
			token.onResult = onResult ;
			token.onFault = onFault ;
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getClassCount
		 * @param event of type ResultEvent		 
		 */
		private function getClassCountResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event.result);			
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getClassByID
		 * @param event of type ResultEvent		 
		 */
		private function getClassByIDResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event.result as ClassVO);			
		}
				
		/**
		 * @private
		 * Function :ResultHandler for getActiveClasses
		 * @param event of type ResultEvent
		 * 		 
		 */
		private function getActiveClassesResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event.result);			
		}		
		
		/**
		 * @private
		 * Function :ResultHandler for deleteClass
		 * @param event of type ResultEvent
		 * 		 
		 */
		private function deleteClassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for search Classes.
		 * @param event of type ResultEvent
		 * 
		 */
		private function searchClassResultHandler(event:ResultEvent):void
		{			
			event.token.onResult(event.result);			
		}
		
		/**
		 * @private
		 * Function :ResultHandler for closeClass for Registration
		 * @param event of type ResultEvent
		 * 
		 */
		private function closeClassForRegistrationResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}	
		
		/**
		 * @private
		 * Function :ResultHandler for create classes
		 * @param event of type ResultEvent
		 * 
		 */
		private function createClassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for updateClass
		 * @param event of type ResultEvent
		 * 		 
		 */
		private function updateClassResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		
		/**
		 * @private
		 * Function :ResultHandler for activateClassForRegistration.
		 * @param event of type ResultEvent
		 * 
		 */
		private function activateClassForRegistrationResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
	}
}
