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
	internal class PointerRecorder
	{
		public var pointerXml:XML;
		public function PointerRecorder()
		{
			pointerXml=<pointer></pointer>;
		}
		public function addEventTag(ctime:uint,x:Number,y:Number,cwidth:Number,cheight:Number,container:String):void
		{
			var xml:XML=<event></event>;
			xml.@ctime=ctime;
			xml.@x=x;
			xml.@y=y;
			xml.@cwidth=cwidth;
			xml.@cheight=cheight;
			xml.@container=container;
			pointerXml.appendChild(xml);
			
		}

	}
}