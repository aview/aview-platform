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
 * File			: AbstractHelper.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:-Functional Description
package edu.amrita.aview.common.helper
{
	applicationType::DesktopWeb{
		import edu.amrita.aview.common.components.alert.CustomAlert;
	}
	applicationType::mobile{
		import edu.amrita.aview.common.components.messageBox.MessageBox;
	}
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	//VGCR:-Class Description

	public class AbstractHelper
	{
		//VGCR:-Description for Constant
		private static const BASE_MESSAGE:String="Fault occured while performing a remote operation. Please contact the administrator";
		/**
		 * For Log API
		 */
		private var logger:ILogger=Log.getLogger("aview.edu.amrita.aview.common.helper.AbstractHelper");
		/**
		 * @public
		 * Default constructor
		 *
		 */
		public function AbstractHelper()
		{
		}
		/**
		 * @public
		 * function to get static fault message
		 * @param event of type FaultEvent
		 * @return String
		 */

		public static function getStaticFaultMessage(event:FaultEvent):String
		{
			var finalMessage:String=BASE_MESSAGE;
			// AKCR: please combine the outer IF condition with others
			// AKCR: for e.g if (event.fault && event.fault.rootCause &&...)
			if (event.fault)
			{
				if (event.fault.rootCause && event.fault.rootCause.hasOwnProperty("message") && event.fault.rootCause.message)
				{
					finalMessage=event.fault.rootCause.message;
				}
				else if (event.fault.rootCause && event.fault.rootCause.hasOwnProperty("faultDetail") && event.fault.rootCause.faultDetail)
				{
					finalMessage=event.fault.rootCause.faultDetail;
				}
				else if (event.fault.faultString)
				{
					finalMessage=event.fault.faultString;
				}
			}
			return finalMessage;
		}
		/**
		 * @public
		 * function to get Fault Message
		 * @param event
		 * @return String
		 */
		public function getFaultMessage(event:FaultEvent):String
		{
			return getStaticFaultMessage(event);
		}
		/**
		 * @public
		 * function for generic Fault Handler
		 * @param event
		 */ 
		public function genericFaultHandler(event:FaultEvent):void
		{
			if(event.token.onFault != null)
			{
				event.token.onFault(event);
			}
			else
			{
				var faultMessage:String=getFaultMessage(event);
				if (!timeoutExceptions(faultMessage, event))
				{
					logger.error(faultMessage);
					applicationType::DesktopWeb{
						CustomAlert.error(faultMessage);
					}
					applicationType::mobile{
						MessageBox.show(faultMessage);
					}
				}
				else
				{
					logger.error("Timeout fault: code:" + event.fault.faultCode + ", Message:" + faultMessage + ":suppressing from user");
					applicationType::DesktopWeb{
						CustomAlert.info("Your session timed out. Please retry your operation");
					}
					applicationType::mobile{
						MessageBox.show("Your session timed out. Please retry your operation");
					}
					
				}
			}
		}
		
		/**
		 * @private 
		 * function for time out exceptions
		 * @param faultMessgage of type String
		 * @param event of type FaultEvent
		 * @return Boolean
		 * 
		 */
		private function timeoutExceptions(faultMessgage:String, event:FaultEvent):Boolean
		{
			if (event.fault.faultCode == "Client.Error.RequestTimeout")
			{
				return true;
			}
			else if (faultMessgage.indexOf("The FlexClient is invalid") != -1)
			{
				return true;
			}
			else if (faultMessgage.indexOf("Detected duplicate HTTP-based FlexSessions") != -1)
			{
				return true;
			}
			return false;
		}
		
		
	// AKCR: please remove this long comment.
	/*
	private var tokens:ArrayList = new ArrayList();
	
	protected function success(callerId:String,result:Object,message:String):void
	{
		storeResult(callerId,result,message,ROReturn.SUCCESS);
	}
	
	private function storeResult(callerId:String,result:Object,message:String,statusCode:String):void
	{
		var roReturn:ROReturn = new ROReturn();
		roReturn.callerId = callerId;
		roReturn.statusCode = statusCode;
		roReturn.result = result;
		roReturn.statusMessage = message;
	
		tokens.addItem(roReturn);
	}
	
	protected function failure(callerId:String,result:Object,message:String):void
	{
		storeResult(callerId,result,message,ROReturn.FAILURE);
	}
	
	protected function getResult(callerId:String):ROReturn
	{
		for(var i:int;i<tokens.length;i++)
		{
			var roReturn:ROReturn = ROReturn(tokens.getItemAt(i));
			if(roReturn.callerId == callerId)
			{
				tokens.removeItemAt(i);
				return roReturn;
			}
		}
		return null;
	}
	*/
	}
}
