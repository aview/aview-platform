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
 * File			: SystemParameterVO.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.core.shared.vo
{
	
	//VGCR:- Class Description
	//VGCR:-Variable Description
	[RemoteClass(alias="edu.amrita.aview.common.entities.SystemParameter")]
	public class SystemParameterVO extends Auditable
	{
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function SystemParameterVO()
		{
		
		}
		
		private var _parameterId:Number=0;
		private var _parameterName:String=null;
		private var _parameterInfo:String=null;
		/**
		 * @public
		 * function to get parameterId
		 *
		 * @return the Number
		 */
		public function get parameterId():Number
		{
			return _parameterId;
		}
		/**
		 * @public
		 * function to set parameterId
		 * @param value of type Number
		 * 
		 */
		public function set parameterId(value:Number):void
		{
			_parameterId=value;
		}
		/**
		 * @public
		 * function to get parameterName
		 * @return String
		 */
		public function get parameterName():String
		{
			return _parameterName;
		}
		/**
		 * @public
		 * function to set parameterName
		 * @param value of type String
		 */
		public function set parameterName(value:String):void
		{
			_parameterName=value;
		}
		/**
		 * @public
		 * function to get parameterInfo
		 * @return String
		 */
		public function get parameterInfo():String
		{
			return _parameterInfo;
		}
		/**
		 * @public
		 * function to set parameterInfo
		 * @param value of type String
		 * 
		 */
		public function set parameterInfo(value:String):void
		{
			_parameterInfo=value;
		}
	
	
	}
}
