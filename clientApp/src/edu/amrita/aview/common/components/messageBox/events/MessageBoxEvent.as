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
 * File			: MessageBoxEvent.as
 * Module		: common
 * Developer(s)	: Ramesh
 * Reviewer(s)	: Remya T,Vishnupreethi K
 */

/**
 * VPCR: Add file description */

package edu.amrita.aview.common.components.messageBox.events
{
	import flash.events.Event;
	
	/**
	 * VPCR: Add class description */
	
	public class MessageBoxEvent extends Event
	{
		/**
		 * Global update values
		 */
		public static const MESSAGEBOX:String='messageBox';
		public static const MESSAGEBOX_OK:String='messageBoxOK';
		public static const MESSAGEBOX_CANCEL:String='messageBoxCANCEL';
		public static const MESSAGEBOX_YES:String='messageBoxYES';
		public static const MESSAGEBOX_NO:String='messageBoxNO';
		
		/**
		 * @public
		 * constructor
		 * @param type
		 * @param bubbles Default value False
		 * @param cancelable Default value False
		 */
		public function MessageBoxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
