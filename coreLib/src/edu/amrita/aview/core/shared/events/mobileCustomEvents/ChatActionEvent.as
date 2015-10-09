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
 * File			: ChatActionEvent.as
 * Module		: Chat
 * Developer(s)	: Jeevanantham N
 * Reviewer(s)	: Sivaram SK
 *
 * ChatActionEvent is a custom event class for sending/clearing chat messages.
 * 
 */
package edu.amrita.aview.core.shared.events.mobileCustomEvents
{
	/**
	 * Importing flash library
	 */
	import flash.events.Event;

	
	/**
	 * ChatActionEvent class contains custom events for sending/clearing chat messages.
	 */
	public class ChatActionEvent extends Event
	{
		/**
		 * Static constants to send and clear chat message
		 */
		public static var CHAT_SEND:String = "sendChat";
		public static var CHAT_CLEAR:String= "clearChat";
		
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
		public function ChatActionEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.data = data;
			super(type,bubbles,cancelable);
		}
	}
}