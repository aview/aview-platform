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
 *
 * File			: ChatStatusEvent.as
 * Module		: chat
 * Developer(s)	: Soumya M.D, NidhiSarasan
 * Reviewer(s)	: Vishnupreethi.K
 *
 *
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.chat.events
{
	import flash.events.Event;
	
	/**
	 * @public
	 * 
	 */
	public class ChatStatusEvent extends Event
	{
		/**
		 * constant variable for chat received event
		 */
		public static var CHAT_RECEIVED:String="chatReceived";
		
		/**
		 * @public
		 * @param type of type String
		 * @param bubbles of type Boolean
		 * @param cancelable of type Boolean
		 *
		 */
		public function ChatStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
