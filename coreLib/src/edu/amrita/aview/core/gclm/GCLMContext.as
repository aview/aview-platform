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
 * File			: GCLMContext.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 *  All constants and common info shared across GCLM is defined
 * in this class
 *
 */
package edu.amrita.aview.core.gclm
{
	import edu.amrita.aview.core.gclm.helper.StaticDataHelper;
	import edu.amrita.aview.core.shared.helper.SystemParameterHelper;
	import edu.amrita.aview.core.entry.AVCEnvironment;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.List;
	import mx.core.ClassFactory;
	
	public class GCLMContext
	{
		public function GCLMContext()
		{
		}
		
		// To hold all the district information 
		[Bindable]
		public static var districtsAC:ArrayCollection=new ArrayCollection();
		// To hold all the state information 
		[Bindable]
		public static var statesAC:ArrayCollection=new ArrayCollection();
		// To hold all the server information
		[Bindable]
		public static var serversAC:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var brandingAttributesAC:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var serverTypesAC:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var instituteCategoriesAC:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var allInstitutesAC:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var allCourseOfferingInstitutesAC:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var statusesAC:ArrayCollection=new ArrayCollection();
		/*
		 * To specify allowed characters for name in Class,Course and Institute creation
		*/
		[Bindable]
		public static var allowedCharactersForName:String=new String();
		[Bindable]
		public static var modulesAC:ArrayCollection=new ArrayCollection();
		public static var instituteCategoriesMap:Dictionary=new Dictionary();
		public static var statusesHash:Object=new Object();
		public static var PC_NODE_TYPE:Number=0;
		public static var CR_NODE_TYPE:Number=0;
		public static var myDropdownFactory:ClassFactory = new ClassFactory(List);
		
		/*Row color for a class that is closed for registration */
		public static const REGISTRATION_CLOSED_CLASS_STATUS_ROW_COLOR:uint=0xF5A9A9
		
		/**
		 * @public
		 * To get all the initial data that is used across the GCLM module
		 *
		 *
		 * @return void
		 *
		 ***/
		public static function getAllInitialData():void
		{
			var staticDataHelper:StaticDataHelper=new StaticDataHelper();
			
			staticDataHelper.getSystemParameters();
			
			staticDataHelper.getDistricts();
			staticDataHelper.getStates();
			staticDataHelper.getInstituteCategories();
			
			staticDataHelper.getStatuses();
			
			staticDataHelper.getAllNodeTypes();
			
			staticDataHelper.getAllModules();
			
			//Get server details are required in case of student type as well
			//since during play back the server details are required
			staticDataHelper.getServers();
			
			//Code change for NIC start
			//The teacher who is a moderator for a class, can edit class details. For teacher also, get
			//server details.
			if (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE || ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
			{
				//Code change to get the server details, in case of student role as well
				//since the server details are required during play back
				//staticDataHelper.getServers();
				staticDataHelper.getBrandingAttributes();
			}
			staticDataHelper.getAllServerTypes();
			//Code change for NIC end
			/*
			var systemParameterHelper:SystemParameterHelper = new SystemParameterHelper();
			systemParameterHelper.getSystemParameterForAllowedCharactersInNamingConvention();
			*/
			staticDataHelper.getSystemParameterForAllowedCharactersInNamingConvention();
			if (AVCEnvironment.deviceType != AVCEnvironment.HAND_HELD_DEVICES)
			{
				dropdownFactory=new ClassFactory(List);
			}
		}
		
		/**
		 * @public
		 *
		 *
		 * @param dataProvider of type ArrayCollection
		 * @param DataField of type String
		 *
		 *
		 * @return void
		 *
		 ***/
		public static function sortSmartComboDataProvider(dataProvider:ArrayCollection, dataField:String):void
		{
			var dataSortField:SortField=new SortField();
			dataSortField.name=dataField;
			dataSortField.numeric=false;
			dataSortField.caseInsensitive=true;
			
			/* Create the Sort object and add the SortField object created earlier to the array of fields to sort on. */
			var dataSort:Sort=new Sort();
			dataSort.fields=[dataSortField];
			
			/* Set the ArrayCollection object's sort property to our custom sort, and refresh the ArrayCollection. */
			dataProvider.sort=dataSort;
			dataProvider.refresh();
		
		}
		[Bindable]
		public static var dropdownFactory:ClassFactory;
	}
}
