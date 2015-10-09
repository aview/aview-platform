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
	internal class PushToTalkRecorder
	{
		public var pttXml:XML
		public function PushToTalkRecorder()
		{
			pttXml=<ptt></ptt>
		}
		public function addPttState(ctime:uint,talkingstate:String,isPresenter:String):void
		{
			if(talkingstate!=null && talkingstate!="null")
			{
				var xml:XML=<state></state>;
				xml.@ctime=ctime;
				xml.@state=talkingstate;
				xml.@isPresenter=isPresenter;
				pttXml.appendChild(xml);
			}
		}

	}
}