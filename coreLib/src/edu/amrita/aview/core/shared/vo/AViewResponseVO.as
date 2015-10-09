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
 * File			: AViewResponseVO.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.core.shared.vo
{
	//VGCR:-Class Description
	//VGCR:-Constant Description
	//VGCR:-Variable Description
	
	[RemoteClass(alias="edu.amrita.aview.common.vo.AViewResponse")]
	public class AViewResponseVO
	{
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function AViewResponseVO()
		{
		}
		public static const REQUEST_SUCCESS:String="REQUEST_SUCCESS";
		public static const ERROR_CLIENT:String="ERROR_CLIENT";
		public static const ERROR_SERVER:String="ERROR_SERVER";
		
		
		private var _responseId:String=null;
		private var _responseMessage:String=null;
		private var _result:Object=null;
		/**
		 * @public
		 * function to get responseId
		 * @return String
		 */
		public function get responseId():String
		{
			return _responseId;
		}
		/**
		 * @public
		 * function to set responseId
		 * @param value of type String
		 */
		public function set responseId(value:String):void
		{
			_responseId=value;
		}
		/**
		 * @public
		 * function to get responseMessage
		 * @return String
		 */
		public function get responseMessage():String
		{
			return _responseMessage;
		}
		/**
		 * @public
		 * function to set responseMessage
		 * @param value
		 */
		public function set responseMessage(value:String):void
		{
			_responseMessage=value;
		}
		/**
		 * @public
		 * function to get result
		 * @return Object
		 */
		public function get result():Object
		{
			return _result;
		}
		/**
		 * @public
		 * function to set result
		 * @param value of type Object
		*/
		public function set result(value:Object):void
		{
			_result=value;
		}
	
	
	}
}
