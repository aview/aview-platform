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
 * File			: ConnectionClient.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
//VGCR:-Functional description
//VGCR:-Description for all functions
package edu.amrita.aview.core.shared.service.streaming
{
	import mx.logging.ILogger;
	import mx.logging.Log;

	/**
	 * For Log API
	 */
	private var log:ILogger=Log.getLogger("aview.common.service.streaming.ConnectionClient.as");
	//VGCR:-Class Description
	public class ConnectionClient
	{
		/**
		 *@public  
		 * Default Constructor
		 */
		public function ConnectionClient()
		{
		}
		
		/**
		 * @public 
		 * @param rest
		 * 
		 */
		public function onBWDone(... rest):void
		{
		
		}
		
		/**
		 * @public 
		 * @param info of type Object
		 * 
		 */
		public function onMetaData(info:Object):void
		{
			if(Log.isInfo()) log.info(info.width + ", " + info.height + ": " + info.duration);
		}
		
		/**
		 * @public 
		 * @param info of type Object
		 * 
		 */
		public function onPlayStatus(info:Object):void
		{
		
		}
	}
}
