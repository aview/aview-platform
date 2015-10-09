package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
	import edu.amrita.aview.core.whiteboard.DrawingArea;
	import edu.amrita.aview.core.whiteboard.WhiteboardShape;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	public class WbPlayer extends EventDispatcher
	{
		
		public var isRestore:Boolean=true
		private var wbContextLastCtime:Number
		private var consolidateXmlBuilder:ConsolidateXmlBuilder = null;
		private var contextSetter:ContextSetter
		public var wbSprite:DrawingArea
		private var playHeadTime:Number
		private var event:AviewPlayerEvent
		private var whiteboardShapeArray:Array=new Array();
		private var backupWhiteboardShapeArrayRestore:Array=new Array();	
		public function WbPlayer()
		{
		 	wbSprite=new DrawingArea();
	        wbSprite.drawBackground(0xffffff);
		}		
		public function setValues(consolidateXmlBuilder:ConsolidateXmlBuilder,contextSetter:ContextSetter):void
		{
			this.consolidateXmlBuilder = consolidateXmlBuilder;
	        this.contextSetter=contextSetter;
		}
		public function clearWb():void
		{
			for(var i:int=wbSprite.numChildren-1;i>=0;i--)
			{
				wbSprite.removeChildAt(i);
			}
			dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.WB_CLEARED));
		}
		
		 
		public function playWb(time:Number):void
		{
			playHeadTime=time;
			var xml:XML=consolidateXmlBuilder.getDataAtTime(time,"wb");
			drawWb(xml,"playHeadUpdate");
			
		}
		private function setPageContext(pageNo:int):void
		{
			var xml:XML=contextSetter.setWbPageContext(playHeadTime,pageNo);
			drawWb(xml,"setPageContext");
		}
		public function setContext(time:Number):void
		{
			clearWb();
			playHeadTime=time;
			var xml:XML=contextSetter.setWbContext(time);
			drawWb(xml,"setContext");
		}
		private var currentPageNo:int=-1;
		private function drawWb(wbData:XML,calledFrom:String):void
		{
		
			for each(var evnt:XML in wbData.elements())
			{
		    	if(evnt.@tag=="page")
		    	{
					var pageNo:int=parseInt(evnt.@num)
					if(currentPageNo!=pageNo)
					{
						whiteboardShapeArray.splice(0);
						currentPageNo=pageNo
						event=new AviewPlayerEvent(AviewPlayerEvent.WB_PAGE_CHANGED)
						event.pageNumber= pageNo;
						dispatchEvent(event);
						clearWb();
					}
					
		    		if(calledFrom!="setPageContext")
		    			setPageContext(evnt.@num)
		    	}
		    	else if(evnt.@tag=="size")
		    	{
		    		//trace("");
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
						clearWb();
						whiteboardShapeArray.splice(0);
					}
		    	    else if(evnt.@toolName=="clear")
		    	    {
						clearWb()
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
		private function drawShape(evnt:XML):void
		{
			var shapeObj:WhiteboardShape=new WhiteboardShape()
			shapeObj.initByXML(evnt);
			var shapeSprite:Sprite=shapeObj.drawShapePlayBack(wbSprite.parent.width,wbSprite.parent.height,0xffffff);
			if( shapeSprite!=null)
				wbSprite.addChild(shapeSprite);
		}
		
		
		
	}
}


