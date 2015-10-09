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
 * File			: DocumentActionEvent.as
 * Module		: Document Sharing
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK 
 *
 * DocumentActionEvent is used to,
 * 
 * 	1. Open fileManger componet
 * 	2. Refresh document
 * 	3. Share mouse pointer
 * 	4. Restore to actual size
 * 	5. Open document detail component
 */
package edu.amrita.aview.core.shared.events.mobileCustomEvents
{
	/**
	 * Importing flash library
	 */
	import flash.events.Event;

	/**
	 * DocumentActionEvent class contains custom events for implementing document sharing functionalities.
	 */
	public class DocumentActionEvent extends Event
	{
		/**
		 * Static constants for document sharing functionalities
		 */
		public static var MY_DOCUMENTS:String = "My_Documents";
		public static var TEACHER_DOCUMENT_REFRESH:String = "Teacher_Docrefresh";
		public static var STUDENT_DOCUMENT_REFRESH:String = "Student_Docrefresh";
		public static var ENABLE_MOUSE_POINTER:String = "Mouse_Pointer";
		public static var DOCUMENT_ACTUAL_SIZE:String = "Doc_Actualsize";
		public static var DOCUMENT_ROTATE:String = "Doc_Rotate";
		public static var TEACHER_DOCUMENT_DETAILS:String = "Teacher_Docdetails";
		public static var STUDENT_DOCUMENT_DETAILS:String = "Student_Docdetails";
		
		/**
		 * To holds current object
		 */
		public var data:Object;
		
		/**
		 * @public
		 * 
		 * Constructor
		 * To set type and object
		 * 
		 * @param type holds type of the event
		 * @param data holds target object instance
		 * @param bubbles optional boolean value
		 * @param cancelable optional boolean value
		 */
		public function DocumentActionEvent(type:String, data:Object=null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type,bubbles,cancelable);
			this.data = data;
		}
	}
}