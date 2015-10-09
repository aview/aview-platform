////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: FileLoadedEvent.as
 * Module		: common
 * Developer(s)	: Haridas
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 *
 */
/**
 * VPCR: Add file description */

package edu.amrita.aview.core.shared.components.fileloader.events
{
	import flash.events.Event;
	/**
	 * VPCR: Add class description */
	
	public class FileLoadedEvent extends Event
	{
		/**
		 * Global update values
		 */
		public static const LOADED:String="file loaded";
		public static const NOT_LOADED:String="file not loaded";
		public static const ALL_LOADED:String="files loaded";
		public static const FILES_NOT_EXISTS:String="files not exists";
		public static const ENDTIME_LOADED:String="endtime loaded";
		
		// AKCR: please remove the comments below. Variable is self explanatory
		/**
		 * to store the file data
		 * */
		public var fileData:XML;
		/**
		 * to store the duration
		 */
		public var duration:Number;
		
		/**
		 * @public
		 * constructor
		 * @param type Type String
		 * @param bubbles Type Boolean Default value False
		 * @param cancelable Type Boolean Default value False
		 */
		public function FileLoadedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	
	}
}
