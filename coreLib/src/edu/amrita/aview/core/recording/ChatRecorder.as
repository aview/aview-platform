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
 * File			:
 * Module		:
 * Developer(s)	:
 * Reviewer(s)	:
 *
 *
 *
 */

/**
 *
 */
package edu.amrita.aview.core.recording
{
	internal class ChatRecorder
	{
		public var chatXml:XML;
		public function ChatRecorder()
		{
			chatXml=<chat></chat>
		}
		public function recordChat(ctime:uint,content:String,textSize:Number):void
		{
			var xml:XML=<msg></msg>;
			xml.@ctime=ctime;
			xml.@content=content;
			xml.@textSize=textSize;
			chatXml.appendChild(xml);
		}

	}
}