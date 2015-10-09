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
	internal class WhiteBoardRecorder
	{
		public var whiteboardXml:XML;
		private var sizeTagIndex:int
		private var pageTagIndex:int
		private var shapeTagIndex:int
		private var currentWbWidth:Number;
		private var currentWbHeight:Number;
		public function WhiteBoardRecorder()
		{
			whiteboardXml=<wb></wb>;
			currentWbWidth=-1;
			currentWbHeight=-1;
		}
		public function addSizeTag(ctime:uint,width:Number,height:Number):void
		{
				pageTagIndex=whiteboardXml.page.length()-1;
				currentWbWidth=width;
				currentWbHeight=height;
				var xml:XML=<size></size>;
				xml.@ctime=ctime;
				xml.@width=width;
				xml.@height=height;
				whiteboardXml.page[pageTagIndex].appendChild(xml);
			
		}
		public function addPageTag(ctime:uint,number:uint):void
		{
		
			var xml:XML=<page></page>;
			xml.@ctime=ctime;
			xml.@num=number;
			whiteboardXml.appendChild(xml);
		}
		public function addShapeTag(shape:XML):void
		{
			
 		    pageTagIndex=whiteboardXml.page.length()-1;
			sizeTagIndex=whiteboardXml.page[pageTagIndex].size.length()-1
			whiteboardXml.page[pageTagIndex].size[sizeTagIndex].appendChild(shape)
			
		}
		public function addPointTag(x:Number,y:Number):void
		{
			var xml:XML=<point></point>
			xml.@x=x;
			xml.@y=y;
			pageTagIndex=whiteboardXml.page.length()-1;
			sizeTagIndex=whiteboardXml.page[pageTagIndex].size.length()-1
			shapeTagIndex=whiteboardXml.page[pageTagIndex].size[sizeTagIndex].shape.length()-1
			whiteboardXml.page[pageTagIndex].size[sizeTagIndex].shape[shapeTagIndex].appendChild(xml);
		}

	}
}