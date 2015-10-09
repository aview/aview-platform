package edu.amrita.aview.core.playback
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class WbPointerPlayer 
	{
			
			public  var pointerShape:Shape=null
			private var consolidateXmlBilder:ConsolidateXmlBuilder = null;
			private var wbSprite:Sprite;
			public function WbPointerPlayer(consolidateXmlBilder:ConsolidateXmlBuilder,wbSprite:Sprite)
			{
				this.consolidateXmlBilder=consolidateXmlBilder;
				this.wbSprite=wbSprite;
			}
            public function playWbPointer(time:Number):void
            {
            	var xml:XML=consolidateXmlBilder.getDataAtTime(time,"wbPointer");
            	var len:int=xml.children().length()
            	if(len>1)
            	{
            		var evnt:XML=xml.event[len-1]
            		var scaleFactorX:Number=wbSprite.parent.width/evnt.@cwidth;
            		var scaleFactorY:Number=wbSprite.parent.height/evnt.@cheight;
            		if( pointerShape==null)
					{
						//pointerEnabled=true;
						pointerShape=new Shape();
						pointerShape.graphics.beginFill(0xFF0000,.5);
			    		pointerShape.graphics.lineStyle(1, 0xFF0000,.5);
			  		    pointerShape.graphics.drawCircle(3, 3, 3);
			    		pointerShape.graphics.endFill();
			   			wbSprite.addChild(pointerShape);
			   			
			   			
					} 
					pointerShape.x=scaleFactorX*evnt.@x;
			   		pointerShape.y=scaleFactorY*evnt.@y;
            	}
				else if(pointerShape!=null && wbSprite.getChildIndex(pointerShape)>0)
				{
					//wbSprite.removeChild(pointerShape);
					wbSprite.removeChildAt(wbSprite.getChildIndex(pointerShape));
						pointerShape=null
				}
            }
            public function removePointer():void
            {
            	
            }
           
	}
	
}

 		