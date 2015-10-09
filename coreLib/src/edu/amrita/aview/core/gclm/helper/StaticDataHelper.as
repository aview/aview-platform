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
 * File			: StaticDataHelper.as
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
	import edu.amrita.aview.core.shared.vo.StatusVO;
	import edu.amrita.aview.core.shared.vo.SystemParameterVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.gclm.GCLMContext;
	import edu.amrita.aview.core.gclm.vo.BrandingAttributeVO;
	import edu.amrita.aview.core.gclm.vo.ServerVO;
	
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class StaticDataHelper extends AbstractHelper
	{
		private var districtHelperRO:RemoteObject=null;
		private var stateHelperRO:RemoteObject=null;
		private var instituteCategoryHelperRO:RemoteObject=null;
		private var nodeTypeHelperRO:RemoteObject=null;
		private var statusHelperRO:RemoteObject=null;
		private var serverHelperRO:RemoteObject=null;
		private var brandingAttributeHelperRO:RemoteObject=null;
		private var serverTypeHelperRO:RemoteObject=null;
		private var systemParameterHelperRO:RemoteObject=null;
		private var moduleHelperRO:RemoteObject=null;
		
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("edu.amrita.aview.core.gclm.helper.StaticDataHelper");
		
		public function StaticDataHelper()
		{
			districtHelperRO=new RemoteObject();
			districtHelperRO.destination="districthelper";
			districtHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			districtHelperRO.showBusyCursor=true;
			
			districtHelperRO.getDistricts.addEventListener("result", getDistrictsResultHandler);
			districtHelperRO.getDistricts.addEventListener("fault", genericFaultHandler);
			
			stateHelperRO=new RemoteObject();
			stateHelperRO.destination="statehelper";
			stateHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			stateHelperRO.showBusyCursor=true;
			
			stateHelperRO.getStates.addEventListener("result", getStatesResultHandler);
			stateHelperRO.getStates.addEventListener("fault", genericFaultHandler);
			
			instituteCategoryHelperRO=new RemoteObject();
			instituteCategoryHelperRO.destination="institutecategoryhelper";
			instituteCategoryHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			instituteCategoryHelperRO.showBusyCursor=true;
			
			instituteCategoryHelperRO.getInstituteCategories.addEventListener("result", getInstituteCategoriesResultHandler);
			instituteCategoryHelperRO.getInstituteCategories.addEventListener("fault", genericFaultHandler);
			
			nodeTypeHelperRO=new RemoteObject();
			nodeTypeHelperRO.destination="nodetypehelper";
			nodeTypeHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			nodeTypeHelperRO.showBusyCursor=true;
			
			nodeTypeHelperRO.getAllNodeTypes.addEventListener("result", getAllNodeTypesResultHandler);
			nodeTypeHelperRO.getAllNodeTypes.addEventListener("fault", genericFaultHandler);
			
			statusHelperRO=new RemoteObject();
			statusHelperRO.destination="statushelper";
			statusHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			statusHelperRO.showBusyCursor=true;
			
			statusHelperRO.getStatuses.addEventListener("result", getStatusesResultHandler);
			statusHelperRO.getStatuses.addEventListener("fault", genericFaultHandler);
			
			serverHelperRO=new RemoteObject();
			serverHelperRO.destination="serverhelper";
			serverHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			serverHelperRO.showBusyCursor=true;
			
			serverHelperRO.getServers.addEventListener("result", getServersResultHandler);
			serverHelperRO.getServers.addEventListener("fault", genericFaultHandler);
			
			systemParameterHelperRO=new RemoteObject();
			systemParameterHelperRO.destination="systemParameterhelper";
			systemParameterHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			systemParameterHelperRO.showBusyCursor=true;
			
			systemParameterHelperRO.getSystemParameters.addEventListener("result", getSystemParametersResultHandler);
			systemParameterHelperRO.getSystemParameters.addEventListener("fault", genericFaultHandler);
			
			brandingAttributeHelperRO=new RemoteObject();
			brandingAttributeHelperRO.destination="brandingattributehelper";
			brandingAttributeHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			brandingAttributeHelperRO.showBusyCursor=true;
			
			brandingAttributeHelperRO.getBrandingAttributes.addEventListener("result", getBrandingAttributesResultHandler);
			brandingAttributeHelperRO.getBrandingAttributes.addEventListener("fault", genericFaultHandler);
			
			serverTypeHelperRO=new RemoteObject();
			serverTypeHelperRO.destination="servertypehelper";
			serverTypeHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			serverTypeHelperRO.showBusyCursor=true;
			
			serverTypeHelperRO.getAllServerTypes.addEventListener("result", getAllServerTypesResultHandler);
			serverTypeHelperRO.getAllServerTypes.addEventListener("fault", genericFaultHandler);
			
			systemParameterHelperRO.getSystemParameterForAllowedCharactersInNamingConvention.addEventListener("result", getSystemParameterForAllowedCharactersInNamingConventionResultHandler);
			systemParameterHelperRO.getSystemParameterForAllowedCharactersInNamingConvention.addEventListener("fault", genericFaultHandler);
			
			moduleHelperRO=new RemoteObject();
			moduleHelperRO.destination="moduleHelper";
			moduleHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			moduleHelperRO.showBusyCursor=true;
			
			moduleHelperRO.getModules.addEventListener("result", getModulesResultHandler);
			moduleHelperRO.getModules.addEventListener("fault", genericFaultHandler);
		
		}
		
		/**
		 * @public
		 * Function :To get Districts
		 *
		 * @return void
		 */
		public function getDistricts():void
		{
			districtHelperRO.getDistricts();
		}
		
		/**
		 * @public
		 * Function :To get States
		 *
		 * @return void
		 */
		public function getStates():void
		{
			stateHelperRO.getStates();
		}
		
		/**
		 * @public
		 * Function :To get InstituteCategories
		 *
		 * @return void
		 */
		public function getInstituteCategories():void
		{
			instituteCategoryHelperRO.getInstituteCategories();
		}
		
		/**
		 * @public
		 * Function :To get AllNodeTypes
		 *
		 * @return void
		 */
		public function getAllNodeTypes():void
		{
			nodeTypeHelperRO.getAllNodeTypes();
		}

		/**
		 * @public
		 * Function :To get Statuses
		 *
		 * @return void
		 */
		public function getStatuses():void
		{
			statusHelperRO.getStatuses();
		}
		
		/**
		 * @public
		 * Function :To get Servers
		 *
		 * @return void
		 */
		public function getServers():void
		{
			serverHelperRO.getServers();
		}
		
		/**
		 * @public
		 * Function :To get SystemParameters
		 *
		 * @return void
		 */
		public function getSystemParameters():void
		{
			systemParameterHelperRO.getSystemParameters();
		}
		
		/**
		 * @public
		 * Function :To get BrandingAttributes
		 *
		 * @return void
		 */
		public function getBrandingAttributes():void
		{
			brandingAttributeHelperRO.getBrandingAttributes();
		}
		
		/**
		 * @public
		 * Function :To get All ServerTypes
		 *
		 * @return void
		 */
		public function getAllServerTypes():void
		{
			serverTypeHelperRO.getAllServerTypes();
		}
		
		/**
		 * @public
		 * Function :To get All Modules
		 *
		 * @return void
		 */
		public function getAllModules():void
		{
			moduleHelperRO.getModules();
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getDistricts
		 * @param event
		 * @return void
		 */
		private function getDistrictsResultHandler(event:ResultEvent):void
		{
			if (event.result != null)
			{
				GCLMContext.districtsAC.removeAll();
				var obj:Object=new Object();			
				for (var i:int=0; i < event.result.length; i++)
				{
					obj=new Object();
					obj.districtId=event.result[i].districtId;
					obj.districtName=event.result[i].districtName;
					obj.stateId=event.result[i].stateId;
					GCLMContext.districtsAC.addItem(obj);
				}
			}
			else
			{
				if (Log.isDebug()) log.debug("Could not fetch the district details");
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getStates
		 * @param event
		 * @return void
		 */
		private function getStatesResultHandler(event:ResultEvent):void
		{
			GCLMContext.statesAC.removeAll();
			var obj:Object=new Object();
			for (var i:int=0; i < event.result.length; i++)
			{
				obj=new Object();
				obj.stateId=event.result[i].stateId;
				obj.stateName=event.result[i].stateName;
				GCLMContext.statesAC.addItem(obj);
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getInstituteCategories
		 * @param event
		 * @return void
		 */
		private function getInstituteCategoriesResultHandler(event:ResultEvent):void
		{
			GCLMContext.instituteCategoriesAC.removeAll();
			var obj:Object=new Object();
			obj.instituteCategoryId=0;
			obj.instituteCategoryName="Select";
			GCLMContext.instituteCategoriesAC.addItem(obj);
			if (event.result != null)
			{
				var tmpAC:ArrayCollection=event.result as ArrayCollection;
				for (var i:int=0; i < tmpAC.length; i++)
				{
					obj=new Object();
					obj.instituteCategoryId=tmpAC[i].instituteCategoryId;
					obj.instituteCategoryName=tmpAC[i].instituteCategoryName;
					GCLMContext.instituteCategoriesMap[tmpAC[i].instituteCategoryId]=tmpAC[i].instituteCategoryName;
					GCLMContext.instituteCategoriesAC.addItem(obj);
				}
			}
			else
			{
				if (Log.isDebug()) log.debug("Error in getting the institute category details");
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getStatuses
		 * @param event
		 * @return void
		 */
		private function getStatusesResultHandler(event:ResultEvent):void
		{
			GCLMContext.statusesAC.removeAll();
			var obj:Object=new Object();
			//Fix for Bug#14860
			/*obj.statusId=0;
			obj.statusName="Select";
			GCLMContext.statusesAC.addItem(obj);*/
			if (event.result != null)
			{
				var tmpAC:ArrayCollection=event.result as ArrayCollection;
				for (var i:int=0; i < tmpAC.length; i++)
				{
					obj=new Object();
					obj.statusId=tmpAC[i].statusId;
					obj.statusName=tmpAC[i].statusName;
					GCLMContext.statusesAC.addItem(obj);
					GCLMContext.statusesHash[tmpAC[i].statusId]=tmpAC[i].statusName;
					
					switch(obj.statusName)
					{
						case Constants.STATUS_ACTIVE:
							StatusVO.ACTIVE_STATUS = obj.statusId;
							break;
						case Constants.STATUS_DELETED:
							StatusVO.DELETED_STATUS = obj.statusId;
							break;
						case Constants.STATUS_PENDING:
							StatusVO.PENDING_STATUS = obj.statusId;
							break;
						case Constants.STATUS_CLOSED:
							StatusVO.CLOSED_STATUS = obj.statusId;
							break;
						case Constants.STATUS_COMMUNICATING:
							StatusVO.COMMUNICATING_STATUS = obj.statusId;
							break;
						case Constants.STATUS_TESTING:
							StatusVO.TESTING_STATUS = obj.statusId;
							break;
						case Constants.STATUS_FAILEDTESTING:
							StatusVO.FAILEDTESTING_STATUS = obj.statusId;
							break;
						case Constants.STATUS_INACTIVE:
							StatusVO.INACTIVE_STATUS = obj.statusId;
							break;
						case Constants.STATUS_JOINED:
							StatusVO.JOINED_STATUS = obj.statusId;
							break;
						case Constants.STATUS_EXITED:
							StatusVO.EXITED_STATUS = obj.statusId;
							break;
							
					}
				}
			}
			else
			{
				if (Log.isDebug()) log.debug("Error in getting status details");
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getServers
		 * @param event
		 * @return void
		 */
		private function getServersResultHandler(event:ResultEvent):void
		{
			if (event.result != null)
			{
				GCLMContext.serversAC=event.result as ArrayCollection;
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getSystemParameters
		 * @param event
		 * @return void
		 */
		private function getSystemParametersResultHandler(event:ResultEvent):void
		{
			var systemParameters:ArrayCollection=null;
			if (event.result != null)
			{
				systemParameters=event.result as ArrayCollection;
				ClassroomContext.SYSTEM_PARAMETERS=new Object();
				
				for (var i:int=0; i < systemParameters.length; i++)
				{
					var systemParameter:SystemParameterVO=systemParameters.getItemAt(i) as SystemParameterVO;
					ClassroomContext.SYSTEM_PARAMETERS[systemParameter.parameterName]=systemParameter.parameterInfo;
				}
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getBrandingAttributes
		 * @param event
		 * @return void
		 */
		private function getBrandingAttributesResultHandler(event:ResultEvent):void
		{
			if (event.result != null)
			{
				GCLMContext.brandingAttributesAC=event.result as ArrayCollection;
				
				var brandingAttribute:BrandingAttributeVO=null;
				for (var i:int=0; i < GCLMContext.brandingAttributesAC.length; i++)
				{
					brandingAttribute=GCLMContext.brandingAttributesAC.getItemAt(i) as BrandingAttributeVO;
					if (brandingAttribute.brandingAttributeName == BrandingAttributeVO.LOGO)
					{
						BrandingAttributeVO.logoBrandingAttributeVO=brandingAttribute;
					}
					else if (brandingAttribute.brandingAttributeName == BrandingAttributeVO.STYLE_SHEET)
					{
						BrandingAttributeVO.styleBrandingAttributeVO=brandingAttribute;
					}
				}
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getAllServerTypes
		 * @param event
		 * @return void
		 */
		private function getAllServerTypesResultHandler(event:ResultEvent):void
		{
			if (event.result != null)
			{
				GCLMContext.serverTypesAC=event.result as ArrayCollection;
				for (var i:int=0; i < event.result.length; i++)
				{
					if (event.result[i].serverType == Constants.FMS_DATA)
					{
						ServerVO.FM_DATA_SERVER_TYPE=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.CONTENT_SERVER)
					{
						ServerVO.CONTENT_SERVER_TYPE=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.FMS_PRESENTER)
					{
						ServerVO.FM_VIDEO_PRESENTER_TYPE=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.FMS_VIEWER)
					{
						ServerVO.FM_VIDEO_VIEWER_TYPE=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.FMS_DESKTOP_SHARING)
					{
						ServerVO.FM_DESKTOP_SHARING_TYPE=event.result[i].serverTypeId;
					}
					
					else if (event.result[i].serverType == Constants.MEETING_COLLABORATION_SERVER)
					{
						ServerVO.MEETING_COLLABORATION_SERVER=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.MEETING_FMS_PRESENTER)
					{
						ServerVO.MEETING_PRESENTER_VIDEO=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.MEETING_CONTENT_SERVER)
					{
						ServerVO.MEETING_CONTENT_SERVER=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.MEETING_FMS_VIEWER)
					{
						ServerVO.MEETING_VIEWER_VIDEO=event.result[i].serverTypeId;
					}
					else if (event.result[i].serverType == Constants.MEETING_FMS_DESKTOP_SHARING)
					{
						ServerVO.MEETING_DESKTOP_SHARING_SERVER=event.result[i].serverTypeId;
					}
					
				}
			}
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getAllNodeTypes
		 * @param event
		 * @return void
		 */
		private function getAllNodeTypesResultHandler(event:ResultEvent):void
		{
			if (event.result != null)
			{
				for (var i:int=0; i < event.result.length; i++)
				{
					if (event.result[i].nodeTypeName == Constants.PC_NODE_TYPE)
					{
						GCLMContext.PC_NODE_TYPE=event.result[i].nodeTypeId;
					}
					else if (event.result[i].nodeTypeName == Constants.CR_NODE_TYPE)
					{
						GCLMContext.CR_NODE_TYPE=event.result[i].nodeTypeId;
					}
				}
			}
		}
		
		/**
		 * @private
		 * Function :To get SystemParameter For Allowed Characters In NamingConvention
		 *
		 * @return void
		 */
		public function getSystemParameterForAllowedCharactersInNamingConvention():void
		{
			systemParameterHelperRO.getSystemParameterForAllowedCharactersInNamingConvention();
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getSystemParameterForAllowedCharactersInNamingConvention
		 * @param event
		 * @return void
		 */
		private function getSystemParameterForAllowedCharactersInNamingConventionResultHandler(event:ResultEvent):void
		{
			var systemParameter:SystemParameterVO=event.result as SystemParameterVO;
			GCLMContext.allowedCharactersForName=systemParameter.parameterInfo;
		}
		
		/**
		 * @private
		 * Function :ResultHandler for getModules
		 * @param event
		 * @return void
		 */
		private function getModulesResultHandler(event:ResultEvent):void
		{
			GCLMContext.modulesAC=event.result as ArrayCollection;
		}
	}
}
