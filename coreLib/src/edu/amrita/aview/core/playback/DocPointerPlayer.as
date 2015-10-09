package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.documentSharing.ispring.flex.PresentationContainer;
	import edu.amrita.aview.core.playback.ConsolidateXmlBuilder;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	
	import mx.controls.SWFLoader;

	public class DocPointerPlayer
	{
		public  var pointerShape:Shape=null
	    public var ispringLoader:PresentationContainer;
		public var p2fLoader:SWFLoader;
		private var p2fWidth:Number;
		private var p2fHeight:Number;
		private var ispringWidth:Number;
		private var ispringHeight:Number;
		private var consolidateXmlBilder:ConsolidateXmlBuilder = null;
		public function setCnsolidateXmlBilder(consolidateXmlBilder:ConsolidateXmlBuilder):void
		{
			this.consolidateXmlBilder=consolidateXmlBilder;
		}
		public function DocPointerPlayer(isprLoader:PresentationContainer,p2fLoader:SWFLoader):void
		{
			this.p2fLoader=p2fLoader;
			this.ispringLoader=isprLoader;
		}
		public function getp2fContainerSize(p2fwidth:Number,p2fheight:Number):void
		{
			p2fWidth=p2fwidth;
			p2fHeight=p2fheight;
		}
		public function getispringContainerSize(isprwidth:Number,isprheight:Number):void
		{
			ispringHeight=isprheight;
			ispringWidth=isprwidth;
		}
		private var originalWidth:Number;
		private var originalHeight:Number;	
		private var container:String="";
		private var tempContainer:String="";
		public function playDocPointer(time:Number):void
		{
			var xml:XML=consolidateXmlBilder.getDataAtTime(time,"docPointer");
			var len:int=xml.children().length()
			if(len>1)
			{
				var evnt:XML=xml.event[len-1]
				var scaleFactorX:Number;
				var scaleFactorY:Number
				container=evnt.@container
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
				else  if(ispringLoader.getChildIndex(pointerShape)>0)
				{
					ispringLoader.removeChild(pointerShape);
				}
				pointerShape=null
			}
			
		}
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