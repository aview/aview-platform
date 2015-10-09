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
 * File			: FolderCreationSuccess.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *FolderCreationSuccess is a custom event class for Folder creation  process.
 *
 */
package edu.amrita.aview.core.shared.components.fileManager.events
{
	import flash.events.Event;
	/**
	 * 	FolderCreationSuccess is a custom event class for Folder creation  process.
	 *  This calss is extends from Event class.
	 *  User can dispatch FolderCreationSuccess after folder creation success.
	 */
	public class FolderCreationSuccess extends Event
	{
		/**
		 * Constructor
		 * @public  
		 * 
		 */
		public function FolderCreationSuccess()
		{
			super("onFolderCreationSuccess");
		}
		
		/**
		 * @public 
		 * @return Event
		 * 
		 */
		override public function clone():Event
		{
			return new FolderCreationSuccess();
		}
	
	}
}
