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
 * File			: SystemParameterHelper.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:-Functional Description
package edu.amrita.aview.common.helper
{

	import edu.amrita.aview.common.vo.SystemParameterVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import edu.amrita.aview.core.entry.ClassroomContext;
	//VGCR:-Class Description
	public class SystemParameterHelper extends AbstractHelper
	{
		//VGCR:-Variable description
		private var systemParameterHelperRO:RemoteObject=null;
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function SystemParameterHelper()
		{
			applicationType::DesktopWeb{
				systemParameterHelperRO = new RemoteObject();
				systemParameterHelperRO.destination="systemParameterhelper";
				systemParameterHelperRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
				systemParameterHelperRO.showBusyCursor = true;
				
				systemParameterHelperRO.getSystemParameterByName.addEventListener("result", getSystemParameterByNameResultHandler);
				systemParameterHelperRO.getSystemParameterByName.addEventListener("fault", genericFaultHandler);
				
				systemParameterHelperRO.getSystemParameterForAllowedCharactersInNamingConvention.addEventListener("result", getSystemParameterForAllowedCharactersInNamingConventionResultHandler);
				systemParameterHelperRO.getSystemParameterForAllowedCharactersInNamingConvention.addEventListener("fault", genericFaultHandler);
			}
		}
		
		/**
		 * @public
		 * function to get system parameter by name 
		 * @param callerComp of type Object
		 * @param systemParameterName of type String
		 * @return void
		 */
		public function getSystemParameterByName(systemParameterName:String,onResult:Function,onFault:Function= null):void
		{
			var token:AsyncToken=systemParameterHelperRO.getSystemParameterByName(systemParameterName);
			token.onResult=onResult;
			token.onFault=onFault;
		}
		/**
		 * @public
		 * function to get system parameter For Allowed Characters InNaming Convention 
		 *
		 * @return void
		 */
		public function getSystemParameterForAllowedCharactersInNamingConvention():void
		{
			systemParameterHelperRO.getSystemParameterForAllowedCharactersInNamingConvention();
		}
		
		/**
		 * @private
		 * function to  get System Parameter ByName Result Handler
		 * @param event of type ResultEvent
		 * @return void
		 */
		private function getSystemParameterByNameResultHandler(event:ResultEvent):void
		{
			event.token.onResult(event);
		}
		/**
		 * @private
		 * function to  get System Parameter For Allowed Characters InNaming Convention Result Handler
		 * @param event of type ResultEvent
		 * @return void
		 */
		
		private function getSystemParameterForAllowedCharactersInNamingConventionResultHandler(event:ResultEvent):void
		{
			applicationType::DesktopWeb{
				if (event != null)
				{
					var systemParameter:SystemParameterVO=event.result as SystemParameterVO;
					import edu.amrita.aview.core.gclm.GCLMContext;
					GCLMContext.allowedCharactersForName=systemParameter.parameterInfo;
				}
			}
		}
	}
}
