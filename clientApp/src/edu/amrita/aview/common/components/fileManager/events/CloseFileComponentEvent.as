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
 * File			: CloseFileComponenetEvent.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *CloseFileComponentEvent is a custom event.
 *
 */
package edu.amrita.aview.common.components.fileManager.events
{
	import flash.events.Event;
	/**
	 * 	CloseFileComponentEvent is a custom event.
	 *  This is extend class from Event class.
	 *  User can dispatch CloseFileComponentEvent after file manager process.
	 *  
	 */
	public class CloseFileComponentEvent extends Event
	{
		/**
		 * Store te value of component
		 */		
		private var _componentName:String;
		/**
		 * Event type of Folder creation
		 */		
		public static const FOLDER_CREATION:String="FolderCreation";
		/**
		 * Event type of upload
		 */		
		public static const UPLOAD:String="Upload";
		/**
		 * Event type of filemanager
		 */		
		public static const FILE_MANAGER:String="FileManager";
		
		
		/**
		 * @public
		 * Get the value of component
		 * @return String
		 * 
		 */
		public function get componentName():String
		{
			return _componentName;
		}
		
		/**
		 * @public 
		 * Constructor
		 * @param componentName of type String
		 * 
		 */
		public function CloseFileComponentEvent(componentName:String)
		{
			super("onCloseFileComponentEvent");
			_componentName=componentName;
		}
		
		/**
		 * @public
		 * 
		 * @return Event
		 * 
		 */
		override public function clone():Event
		{
			return new CloseFileComponentEvent(componentName);
		}
	
	}
}
