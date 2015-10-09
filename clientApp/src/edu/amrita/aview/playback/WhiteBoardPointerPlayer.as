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
 * File			: WbPointerPlayer.as
 * Module		: Playback
 * Developer(s)	: Haridas, Anu.P
 * Reviewer(s)	: Thirumalai murugan
 *
 * The pointer playback module for whiteboard recordings.
 * Reads out the X,Y values of the pointer shape from the
 * recordings XML file and processes it to generate the shape
 * in the sprite obeject of the whiteboard playback module.
 *
 */
package edu.amrita.aview.playback
{
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * Class implementing whiteboard pointer playback operation.
	 */
	public class WhiteBoardPointerPlayer 
	{
		/**
		 * Local Shape obeject for storing whiteboard shape values.
		 */
		public  var pointerShape:Shape=null;
		/**
		 * Local object for the ConsolidatedXmlBuiler class.
		 */
		private var consolidateXmlBilder:ConsolidateXmlBuilder = null;
		/**
		 * The Sprite object to hold the shapes.
		 */		
		private var whiteBoardSprite:Sprite;		
		/**
		 *
		 * @public
		 * Constructor function which intitializes the whiteboard pointer player. Sets the
		 * sprite area and the XML builder objects.
		 *
		 * @param consolidateXmlBilder of type ConsolidateXmlBuilder
		 * @param wbSprite of type Sprite
		 * @return void
		 *
		 ***/
		public function WhiteBoardPointerPlayer(consolidateXmlBilder:ConsolidateXmlBuilder,wbSprite:Sprite)
			{
				this.consolidateXmlBilder=consolidateXmlBilder;
				this.whiteBoardSprite=wbSprite;
			}		
		/**
		 *
		 * @public
		 * The main function implementing the whiteboard player
		 * functionalities. The function takes the time values
		 * as input from where the same is being is used for
		 * generating the corresponding XML object once getting
		 * the pointer data from the <code>ConsolidatedXmlBuilder
		 * </code>.
		 * <p>The nodes in the xml objects are iterated
		 * and each poiter co-ordinates are being taken. Then if
		 * there is already a poiner shape defined, that one is
		 * used to playback on the sprite object with the scale
		 * ratio and X,Y co-ordinates got from the XML. If there
		 * is no pointer shape defined before, a new one is created
		 * and is being added to the sprite object.</p>
		 *
		 * <p>If there is already a pointer shape from the previous
		 * play back drawing which is added to the sprite, the same
		 * is being removed for the new one to add and complete the
		 * functionality</p>
		 *
		 * @param time of type Number
		 * @return void
		 *
		 ***/
		public function playWhiteBoardPointer(time:Number):void
            {
            	var xml:XML=consolidateXmlBilder.getDataAtTime(time,"wbPointer");				
            	var len:int=xml.children().length();
            	if(len>1)
            	{
            		var evnt:XML=xml.event[len-1];
            		var scaleFactorX:Number=whiteBoardSprite.parent.width/evnt.@cwidth;
            		var scaleFactorY:Number=whiteBoardSprite.parent.height/evnt.@cheight;
            		if( pointerShape==null)
					{
						
						pointerShape=new Shape();
						pointerShape.graphics.beginFill(0xFF0000,.5);
			    		pointerShape.graphics.lineStyle(1, 0xFF0000,.5);
			  		    pointerShape.graphics.drawCircle(3, 3, 3);
			    		pointerShape.graphics.endFill();
			   			whiteBoardSprite.addChild(pointerShape);
			   			
			   			
					} 
					pointerShape.x=scaleFactorX*evnt.@x;
			   		pointerShape.y=scaleFactorY*evnt.@y;
            	}
				else if(pointerShape!=null && whiteBoardSprite.contains(pointerShape))
				{					
					whiteBoardSprite.removeChildAt(whiteBoardSprite.getChildIndex(pointerShape));
						pointerShape=null;
				}
            }		
           
	}
	
}

 		