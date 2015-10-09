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
 * File			: DocPointerPlayer.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:This class used for handling the Document pointer palyback functionality.
 */
package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.documentSharing.ispring.flex.PresentationContainer;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	
	import mx.controls.SWFLoader;
	/**
	 *  The DocumentPointerPlayer class displays a pointer in Document playback.
	 *  You typically use DocumentPointerPlayer for showing the pointer 
	 *  which is already recorded from live session.	 
	 *
	 *  <p>The DocumentPointerPlayer class lets you make the real experiance like as 
	 *  live session. 
	 *  It can also resize itself to fit the size of document content.
	 *  By default, content is scaled to fit the size of the Document container.</p>  
	 *
	 */
	public class DocumentPointerPlayer
	{
		/**
		 * It refers the pointer shape of Presenter's mouse
		 */
		public  var pointerShape:Shape=null
		/**
		 * It refers for Container for Animated document loader in Document playback
		 */		
	    public var ispringLoader:PresentationContainer;		
		/**
		 * For loading the non animated documents 
		 */
		public var p2fLoader:SWFLoader;
		/**
		 * Non-Animated container width
		 */		
		private var p2fWidth:Number;
		/**
		 * Non-Animated container height
		 */	
		private var p2fHeight:Number;
		/**
		 * Animated container width
		 */	
		private var ispringWidth:Number;
		/**
		 * Animated container height
		 */	
		private var ispringHeight:Number;
		/**
		 * The tempory variable for initilze the container  object
		 */		
		private var container:String="";
		/**
		 * To compare a current container with the previous one, store the
		 * previous container's value in a variable. 
		 */	
		private var tempContainer:String="";
		/**
		 * Consolidate xml data of Document pointer palyback
		 */
		private var consolidateXmlBilder:ConsolidateXmlBuilder = null;
		
		/**
		 * @public
		 * For setting the consolidateXmldata for Document pointer playback
		 * @param consolidateXmlBilder
		 * @return void
		 */
		public function setConsolidateXmlBilder(consolidateXmlBilder:ConsolidateXmlBuilder):void
		{
			this.consolidateXmlBilder=consolidateXmlBilder;
		}
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @public
		 * Initialize all data for  Document pointer playback.
		 * @param isprLoader of PresentationContainer
		 * @param p2fLoader of SWFLoader
		 * @return void
		 */
		public function DocumentPointerPlayer(isprLoader:PresentationContainer,p2fLoader:SWFLoader):void
		{
			this.p2fLoader=p2fLoader;
			this.ispringLoader=isprLoader;
		}
		/**
		 * @public 
		 * for setting the p2f container size
		 * @param p2fwidth of Number
		 * @param p2fheight of Number
		 * 
		 */
		public function getp2fContainerSize(p2fwidth:Number,p2fheight:Number):void
		{
			p2fWidth=p2fwidth;
			p2fHeight=p2fheight;
		}
		/**
		 * @public 
		 * for setting the ispring container size
		 * @param isprwidth of Number
		 * @param isprheight of Number
		 * 
		 */
		public function getispringContainerSize(isprwidth:Number,isprheight:Number):void
		{
			ispringHeight=isprheight;
			ispringWidth=isprwidth;
		}		
		
		/**
		 * @public
		 * For handling the document pointer playback functionality
		 * @param time of Number
		 * @return void
		 */
		public function playDocPointer(time:Number):void
		{
			var xml:XML=consolidateXmlBilder.getDataAtTime(time,"docPointer");
			var len:int=xml.children().length();
			if(len>1)
			{
				var evnt:XML=xml.event[len-1]
				var scaleFactorX:Number;
				var scaleFactorY:Number;
				container=evnt.@container;
					if(container=="p2fContainer")
					{
						showPointer(p2fLoader,evnt.@x,evnt.@y);
					}
					else
					{
						scaleFactorX=(ispringLoader.parent.width/evnt.@cwidth)*evnt.@x;
						scaleFactorY=(ispringLoader.parent.height/evnt.@cheight)*evnt.@y;
						showPointer(ispringLoader,scaleFactorX,scaleFactorY);
					}
				
			}
			else if(pointerShape !=null )
			{
				if(container=="p2fContainer" && p2fLoader.getChildIndex(pointerShape)>0)
				{
					p2fLoader.removeChild(pointerShape);
					
				}
				
				else  if(container!="p2fContainer")
				{
					if( ispringLoader.getChildIndex(pointerShape)>0)
					ispringLoader.removeChild(pointerShape);
				}
				pointerShape=null;
			}
			
		}
		/**
		 * @private
		 * Making the object of mouse of presenter's and added to respective
		 * container
		 * @param dispObj of DisplayObjectContainer
		 * @param x of number
		 * @param y of number
		 * @return void
		 */
		private function showPointer(dispObj:DisplayObjectContainer,x:Number,y:Number):void
		{
		         
			    if(tempContainer!=dispObj.name)
				{
					   pointerShape=null;
				}			
				if(!pointerShape)
				{
					pointerShape=new Shape();
					pointerShape.graphics.beginFill(0xFF0000,.5);
					pointerShape.graphics.lineStyle(1, 0xFF0000,.5);            	
					pointerShape.graphics.drawCircle(15,15,15);		        	 	
					pointerShape.graphics.endFill();  
					dispObj.addChild(pointerShape);	
					//GTMCR:: check the missing semicolon
					tempContainer=dispObj.name
					
				}	
				if(dispObj.getChildIndex(pointerShape)!=dispObj.numChildren-1)
				{
					dispObj.setChildIndex(pointerShape,dispObj.numChildren-1);
				}
				pointerShape.x=x;
				pointerShape.y=y;
				
			
		}
	}
}