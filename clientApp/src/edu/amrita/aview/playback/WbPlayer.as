////////////////////////////////////////////////////////////////////////////////
//
// Copyright  � 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: WbPlayer.as
 * Module		: playback
 * Developer(s)	: Haridas, Anu.P
 * Reviewer(s)	: Thirumalai murugan
 *
 * The playback module for whiteboard recordings.
 * Reads out the whiteboard recordings XML file and
 * processes each node of the XML and re-generate the
 * actions during the live session.
 *
 */
package edu.amrita.aview.playback{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import edu.amrita.aview.playback.events.AviewPlayerEvent;
	import edu.amrita.aview.core.whiteboard.WhiteboardShape;
	import edu.amrita.aview.core.whiteboard.DrawingArea;
	
	/**
	 * Class for implementing whiteboard player.
	 */
	public class WbPlayer extends EventDispatcher{
		/**
		 * Stores the value of the whiteboard restore status.
		 */
		public var isRestore:Boolean=true
		
		/**
		 * Local object for the ConsolidatedXmlBuiler class.
		 */
		private var consolidateXmlBuilder:ConsolidateXmlBuilder=null;
		/**
		 * Local object for the ContextSetter class.
		 */
		private var contextSetter:ContextSetter
		/**
		 * Sprite component object for implementing drawing functionalities.
		 */
		
		public var whiteBoardSprite:DrawingArea
		/**
		 * Stores the current play head time from the XML file.
		 */
		private var playHeadTime:Number
		/**
		 * Object of custom AVIEWPlayerEvent. Used to fire whiteboard events.
		 */
		private var event:AviewPlayerEvent
		/**
		 * Stores the shape values from the XML file for processoing.
		 */
		private var whiteboardShapeArray:Array=new Array();
		/**
		 * Copy of the <code>whiteboardShapeArray</code>variable. Used during shape drawing.
		 */
		private var backupWhiteboardShapeArrayRestore:Array=new Array();		
		/**
		 * Constructor
		 * @public
		 * Initializes the drawing are and sets the background
		 * color property to 0xffffff.
		 *
		 * @param  void
		 * @return void
		 *
		 ***/
		public function WbPlayer()
		{
		 	whiteBoardSprite=new DrawingArea()
	        whiteBoardSprite.drawBackground(0xffffff);
		}		
	
		/**
		 * @public
		 * Initializes the drawing are and sets the background
		 * color property to 0xffffff.		 
		 * @param consolidateXmlBuilder of ConsolidateXmlBuilder
		 * @param contextSetter of ContextSetter
		 * 
		 */
		public function setValues(consolidateXmlBuilder:ConsolidateXmlBuilder,contextSetter:ContextSetter):void
		{
			this.consolidateXmlBuilder = consolidateXmlBuilder;
	        this.contextSetter=contextSetter;
		}		
		/**
		 *
		 * @public
		 * <p>Clears the drawing on the whiteboard sprite component.
		 * Since whiteboard can have multiple pages of drwaings,
		 * the logic iterates through the all child objects of
		 * wbSprite object and removes them one by one.</p>
		 * <p> Once all the child objects have been removed, will
		 * send a AviewPlayerEvent of type WB_CLEARED notifying the
		 * completion of the task.
		 *
		 * @param  void
		 * @return void
		 *
		 ***/
		public function clearWhiteBoard():void
		{
			for(var i:int=whiteBoardSprite.numChildren-1;i>=0;i--)
			{
				whiteBoardSprite.removeChildAt(i);
			}
			dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.WB_CLEARED));
		}		
		/**
		 *
		 * @public
		 * Playheadtime is taken as a parameter and
		 * finds out the whiteboard related data at
		 * that particular point of time from the consolidated XML
		 * file. Once afer getting the whiteboard related data
		 * the <code>drawWb()</code> function is called to pass on
		 * the created XML object which has the data for the given
		 * time with a reference name of the caller.
		 *
		 * @param  time of type Number The recorded time value from XML file.
		 * @return void
		 *
		 * @see drawWb
		 *
		 ***/
		public function playWhiteBoard(time:Number):void
		{
			playHeadTime=time;
			var xml:XML=consolidateXmlBuilder.getDataAtTime(time,"wb");
			drawWhiteBoard(xml,"playHeadUpdate");
			
		}
		/**
		 *
		 * @public
		 * Setting the whiteboard page context according to the page number
		 * and the given playhead time. The values are passed on to
		 * an XML object by using the <code>setWbPageContext</code>
		 * of the <code>contextSetter</code> class. The resulted XML
		 * object is then passed to the drawWb function along with the
		 * caller reference to complete the action.
		 *
		 * @param  pageNo of type Int Page number of the whiteboard context.
		 * @return void
		 *
		 ***/
		private function setPageContext(pageNo:int):void
		{
			var xml:XML=contextSetter.setWbPageContext(playHeadTime,pageNo);
			drawWhiteBoard(xml,"setPageContext");
		}
		
		/**
		 *
		 * @public
		 * Sets the whiteboard context according to the playhead time.
		 * The current time value is passed on and the function will
		 * first clear the current whiteboard drawing context. Then the
		 * playheadtime is updated with the provided time value and is used
		 * to set a new context according to the new playheadtim by passing
		 * the values to <code>drawWb</code> function.
		 *
		 * @param  time of type Number
		 * @return void
		 *
		 ***/
		public function setContext(time:Number):void
		{
			clearWhiteBoard();
			playHeadTime=time;
			var xml:XML=contextSetter.setWbContext(time);
			drawWhiteBoard(xml,"setContext");
		}
		/**
		 * Stores the current page number value during playback.
		 */
		private var currentPageNo:int=-1;		
		/**
		 *
		 * @public
		 * The function iterates through various whiteboard
		 * operations defined in the XML tags and if the given
		 * XML tags has values found matching with any of
		 * the existing opreational tags, then the operations
		 * is carried out with the given values.
		 *
		 * @param  wbData of type XML
		 * @param  calledFrom of type String
		 * @return void
		 *
		 ***/
		private function drawWhiteBoard(wbData:XML,calledFrom:String):void
		{
		
			for each(var evnt:XML in wbData.elements())
			{
		    	if(evnt.@tag=="page")
		    	{					
					var pageNo:int=parseInt(evnt.@num);
					if(currentPageNo!=pageNo)
					{
						whiteboardShapeArray.splice(0);
						currentPageNo=pageNo;
						event=new AviewPlayerEvent(AviewPlayerEvent.WB_PAGE_CHANGED);
						event.pageNumber= pageNo;
						dispatchEvent(event);
						clearWhiteBoard();
					}
					
		    		if(calledFrom!="setPageContext")
		    			setPageContext(evnt.@num);
		    	}		    	
		    	else if(evnt.@tag=="shape")
		    	{
		    	
		    		if(evnt.@toolName=="tab")
		    		{
		    			event=new AviewPlayerEvent(AviewPlayerEvent.WB_TAB_CHANGED);
		    			dispatchEvent(event);
		    	    }
					else if(evnt.@toolName=="cleared")
					{
						clearWhiteBoard();
						whiteboardShapeArray.splice(0);
					}
		    	    else if(evnt.@toolName=="clear")
		    	    {
						clearWhiteBoard()
		    	    	isRestore=false;
						backupWhiteboardShapeArrayRestore = whiteboardShapeArray.concat();
						whiteboardShapeArray.splice(0);
		    	    }
		    	    else if(evnt.@toolName=="restore")
		    	    {
		    	    	isRestore=true;
						whiteboardShapeArray=backupWhiteboardShapeArrayRestore.concat();
						var length:uint=whiteboardShapeArray.length
						for(var i:uint=0;i<length;i++)
						{
							drawShape(whiteboardShapeArray[i]);
						}
		    	    }
		    	    else
		    	    {
						 if(isRestore)
						 {
							 isRestore=false;
							 backupWhiteboardShapeArrayRestore.splice(0);
						 }
						 whiteboardShapeArray.push(evnt);
						 drawShape(evnt);
		    	    	
		    	    }
		    	}
		    }
		}		
		/**
		 *
		 * @public
		 * The <code>drawWb</code>has any shape tags found in its
		 * inuputs the corresponding shapes has to be drawn in the
		 * whiteboard sprite and for that <code>drawShape</code>
		 * function is being used. This function will take the corresponding
		 * XML object and will draw the shaped according to the values defined
		 * in it.
		 *
		 * @param  event of type XML
		 * @return void
		 *
		 ***/
		private function drawShape(evnt:XML):void
		{
			var shapeObj:WhiteboardShape=new WhiteboardShape()
			shapeObj.initByXML(evnt);
			var shapeSprite:Sprite=shapeObj.drawShape(whiteBoardSprite.parent.width,whiteBoardSprite.parent.height,0xffffff);
			if( shapeSprite!=null)
				whiteBoardSprite.addChild(shapeSprite);
		}
	}
}


