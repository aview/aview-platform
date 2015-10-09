package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPlayer;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationPlaybackController;
	import edu.amrita.aview.core.documentSharing.ispring.flex.PlayerInitEvent;
	import edu.amrita.aview.core.documentSharing.ispring.flex.PresentationContainer;
	import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.SWFLoader;
	import mx.events.ResizeEvent;
	

public class DocumentPlayer extends EventDispatcher
{
	private  var p2fsrc:String;
	public var contWidth:Number;
	public var contHeight:Number;
	public var zoomFactorX:Number;
	public var zoomFactorY:Number;
	private var consolidateXmlBuilder:ConsolidateXmlBuilder=null;
	private var contextSetter:ContextSetter;
	public var p2fLoader:SWFLoader;
	private var docCanvas:Canvas;
	private var baseContainer:Canvas;
	public var ispringLoader:PresentationContainer;
	public var ispringCanvas:Canvas;
	[Bindable]
    public var slideCollection:ArrayCollection;
    public var obj:Object;
    private var docType:String;
	private var documentPath:String;
	private var docPointerPlayer:DocPointerPlayer=null;
	public function DocumentPlayer()
	{		
		
	}
	public function setDocPath(documentPath:String):void
	{
		this.documentPath=documentPath;
	}
	public function setUiReference(p2fLoader:SWFLoader,docCanvas:Canvas,ispringLoader:PresentationContainer,isprCanvas:Canvas,base:Canvas,contHeight:Number,contWidth:Number):void
	{
		this.p2fLoader=p2fLoader;
		this.docCanvas=docCanvas;
		this.ispringLoader=ispringLoader;
		this.ispringCanvas=isprCanvas;
		this.baseContainer=base;
		baseContainer.removeChild(docCanvas);
		baseContainer.removeChild(ispringCanvas);
		baseContainer.addEventListener(ResizeEvent.RESIZE,onDocResize)
		docPointerPlayer=new DocPointerPlayer(ispringLoader,p2fLoader);
		if(consolidateXmlBuilder!=null)
		{
			docPointerPlayer.setCnsolidateXmlBilder(consolidateXmlBuilder)
		}
		var evnt:ResizeEvent;
		onDocResize(evnt);
	}
	
	private var docWidth:Number=0;
	private var docHeight:Number=0;	
	public function onDocResize(event:ResizeEvent):void
	{
		
		getResolution();
			
	    
	}
	public function getResolution():void
	{
		var tempWidth:Number;
		var tempCurrentScrollX:Number;
		var tempCurrentScrollY:Number;
		var tempCurrentMaxScrollX:Number;
		var tempCurrentMaxScrollY:Number;
		if(baseContainer.contains(docCanvas))
		{
			tempCurrentScrollX=docCanvas.horizontalScrollPosition;
			tempCurrentScrollY=docCanvas.verticalScrollPosition;
			tempCurrentMaxScrollX=docCanvas.maxHorizontalScrollPosition;
			tempCurrentMaxScrollY=docCanvas.maxVerticalScrollPosition;
		}
		docHeight=baseContainer.height-10;
		tempWidth=(docHeight / 3) * 4;
		if (tempWidth >= baseContainer.width-10)
		{
			docWidth=baseContainer.width-10;
			docHeight=(docWidth / 4) * 3;
		}
		else
		{
			docWidth=tempWidth;
		}  
		ispringCanvas.width=docWidth;
		docCanvas.height=docHeight;
		docCanvas.width=docWidth;
		ispringCanvas.height=docHeight;
		
		if(baseContainer.contains(docCanvas))
		{
			if(zoomFactorX>0 && zoomFactorY>0)
				documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);
			if(tempCurrentScrollX>0)
			{
				
				timeOutIdXAfterResize=setTimeout(setscrolXAfterResize,75,tempCurrentScrollX,tempCurrentMaxScrollX);
				
			}
			if(tempCurrentScrollY>0)
			{
				timeOutIdYAfterResize=setTimeout(setscrolYAfterResize,75,tempCurrentScrollY,tempCurrentMaxScrollY);
				
			}
				
		}	
		
	}
	private var timeOutIdXAfterResize:uint;
	private var timeOutIdYAfterResize:uint;
	private function setscrolXAfterResize(position:Number,maxPosition:Number):void
	{
		clearTimeout(timeOutIdXAfterResize);
		position = (position*maxX)/maxPosition;
		setDocScrollPosition("horizontal",position);
	}
	private function setscrolYAfterResize(position:Number,maxPosition:Number):void
	{
		clearTimeout(timeOutIdYAfterResize);
		position = (position*maxY)/maxPosition
		setDocScrollPosition("vertical",position);
	}
	private function slideListingpath(filename:String,source:String):String
	{
		var path:String=source.lastIndexOf(filename).toString();;
		return path;
	}
	public function setConsolidateXMLBuilder(consolidateXmlBuilder:ConsolidateXmlBuilder):void
	{
		this.consolidateXmlBuilder = consolidateXmlBuilder;
		if(docPointerPlayer!=null)
		{
			docPointerPlayer.setCnsolidateXmlBilder(consolidateXmlBuilder);
		}
	}
	public function setContextSetter(contextSetter:ContextSetter):void
	{
		this.contextSetter = contextSetter;
	}
	private var tempslide:Number=0;
	private var filename:String;
	private function getSlideIndex(pageno:Number,ctime:Number):void
	{
	   var currentIndex:int=-1;
		for(var i:uint =0; i<slideCollection.length;i++)
		{
			if(slideCollection[i].ctime<=ctime && slideCollection[i].pageno == pageno)
			{
				currentIndex=i;
			}
			else if (slideCollection[i].ctime>ctime )
			{
				break;
			}
		}
		 if(currentIndex>-1)
		 {
			 var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.SLIDE_CHANGE);
			 evnt.currentSlideIndex=currentIndex;
			 dispatchEvent(evnt);
		 }
	}
	public function playDocument(time:Number):void
	{
		if(docPointerPlayer)
		docPointerPlayer.playDocPointer(time);    		      	
		var xml:XML=consolidateXmlBuilder.getDataAtTime(time,"doc");            	
		var ds:XMLList=xml.elements();
		slideCollection=consolidateXmlBuilder.thumbnailCollection;
		for(var i:Number=0;i<ds.length();i++)
		{   
			//tn.selectedIndex=0  
			
			//trace(ds[i].@tag) 
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.DOC_TAB_CHANGED);
			dispatchEvent(evnt);
			if(ds[i].@tag=="docloaded")          		
			{ 
				docType=ds[i].@type ;  
				filename=ds[i].@filename
				if(docType=="p2f")
				{
					
					if(baseContainer.contains(ispringCanvas))
					{
						ispringLoader.unload();
						baseContainer.removeChild(ispringCanvas);
					}
					if(!baseContainer.contains(docCanvas))
					{
						baseContainer.addChild(docCanvas);
					}
					
					p2fsrc=documentPath+"/Contents"+ds[i].@src;           			  
					p2fLoader.addEventListener(Event.COMPLETE,scaleContainer)
				}
				else if(docType=="ispring")
				{
					if(baseContainer.contains(docCanvas))
					{
						p2fLoader.unloadAndStop(true);
						baseContainer.removeChild(docCanvas);
					}
					if(!baseContainer.contains(ispringCanvas))
					{
						baseContainer.addChild(ispringCanvas);
					}
					p2fsrc=documentPath+"/Contents"+ds[i].@src;
					ispringLoader.load(p2fsrc);
				    ispringLoader.addEventListener(PlayerInitEvent.PLAYER_INIT,initializeISpringPlayer)           			  
				}
			}
			 if(ds[i].@tag=="size")
			{
				//trace("cont:"+p2fLoader.contentWidth);
				//trace(ds[i].@zoomfactor)
				////trace("width:"+ds[i].@width) 
				maxX=ds[i].@maxX;
				maxY=ds[i].@maxY;
				contWidth= ds[i].@width;//[i]; 
				contHeight=ds[i].@height; 
				if(ds[i].@zoomfactorX!=0 && ds[i].@zoomfactorY!=0)
				{
					zoomFactorX=ds[i].@zoomfactorX;
					zoomFactorY=ds[i].@zoomfactorY;
					documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);
				}
				
									      			
				
			}  
			
			else if(ds[i].@tag=="event");
			{
				
				if(ds[i].@action=="page")
				{   
					getSlideIndex(ds[i].@pageno,ds[i].@ctime);
					loadDocumnet(p2fsrc,ds[i].@pageno,docType);
					trace("pagenumber"+ds[i].@pageno)
					tempslide=ds[i].@pageno;
				}
				else if(ds[i].@action=="animation" && iSpringSlideControler)
				{	
					getSlideIndex(ds[i].@pageno,ds[i].@ctime);
					trace("animation"+ds[i].@value)
					var stepno:Number=ds[i].@value;
					if(tempslide==ds[i].@pageno)
					{
						iSpringSlideControler.playFromStep(stepno)
					}
					else
					{
						
						iSpringSlideControler.gotoSlide(ds[i].@pageno-1,true);
						tempslide=ds[i].@pageno
						
					}
						
				}					
	  		    else if(ds[i].@action=="rotation")
				{
				       rotateDocument(parseInt(ds[i].@value))
				} 
				else if(ds[i].@action=="scroll")
				{
					setDocScrollPosition(ds[i].@scrollDirction,ds[i].@scrollPosition);            				
				}
				else if(ds[i].@action=="zoom")
				{
					maxX = ds[i].@maxx;
					maxY = ds[i].@maxy;
					zoomFactorX=ds[i].@zoomX;
					zoomFactorY=ds[i].@zoomY;
					documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);		
				}
				else if(ds[i].@action=="tab")
				{    
					//dispatchEvent(evnt);
				}
				else if(ds[i].@action=="unload")
				{    
					if(docType=="p2f")
					{
						p2fLoader.unloadAndStop(true);
						baseContainer.removeChild(docCanvas);
					}
					else
					{
						ispringLoader.unload();
						baseContainer.removeChild(ispringCanvas);
					}
				}
				
			}
			
		}
		 
	 }
	
	private function loadDocumnet(src:String,pageNo:Number,type:String):void
	{
		       if(type=="p2f")
		       {
		      	 p2fLoader.source=src+"/page_"+pageNo+".swf"
		       }
		       else if(type=="ispring" && !seekToIspr)
		       {
				  	 if(iSpringSlideControler)
		       	   	iSpringSlideControler.gotoSlide(pageNo-1);
		       }
		      p2fsrc=src;
			  getResolution();
		       
	} 
	private var iSpringPlayer:IPlayer;
	private var iSpringSlideControler:IPresentationPlaybackController;
    private function  initializeISpringPlayer(event:PlayerInitEvent):void
    {    		
	    iSpringSlideControler=event.player.playbackController;
		if(seekToIspr)
		{
			iSpringSlideControler.gotoSlide(slide-1,true);
			iSpringSlideControler.playFromStep(step);
			seekToIspr=false;
		}
    }
	private function rotateDocument(count:int):void
	{		  
	       	p2fLoader.rotation =count;			
			switch(count)
			{
				case 0:
				  p2fLoader.x = 0;				
				  p2fLoader.y = 0;
				  break;
				case 90:
				  p2fLoader.x = docCanvas.width;
				  p2fLoader.y = 0 ;					
				  break;
				case 180:						
				  p2fLoader.x =docCanvas.width;
				  p2fLoader.y =docCanvas.height;
				  break;
				case 270:						
				  p2fLoader.x = 0;
				  p2fLoader.y= docCanvas.height;
				  break; 
			}
	             
	}
	
	private function setDocScrollPosition(direction:String,position:Number):void
	{
		if(direction=="vertical")
		{
			if(docCanvas.maxVerticalScrollPosition >0)
			{
				position=position*(docCanvas.maxVerticalScrollPosition/maxY);
			}
			if(position.toString()!="NaN")
				docCanvas.verticalScrollPosition=position;
		}
		else if(direction=="horizontal")
		{
			if(docCanvas.maxHorizontalScrollPosition>0)
			{
				position=position*(docCanvas.maxHorizontalScrollPosition/maxX)
			}
			if(position.toString()!="NaN")
				docCanvas.horizontalScrollPosition=position;
		}
	}
	   
	private function documentScaling(width:Number,height:Number,zoomX:Number,zoomY:Number,contHeight:Number,contWidth:Number):void
	{
		p2fLoader.scaleX=zoomX*(width-2)/contWidth;	
		p2fLoader.scaleY=zoomY*(height-2)/contHeight;
	}
	private function scaleContainer(evnt:Event):void
	{          
	    //documentScaling(contWidth,contHeight,zoomFactorX,zoomFactorY);		
	}
	public var seekToIspr:Boolean=false;
	private var slide:Number;
	private var step:Number;
	private var maxX:Number;
	private var maxY:Number;
	 public function setContext(playHeadTime:Number):void
	{
		
		   var xml:XML=contextSetter.setDocContext(playHeadTime);
		   if(contextSetter.docContextTime>contextSetter.wbContextTime)
		   {
			   var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.DOC_TAB_CHANGED);
			   dispatchEvent(evnt);
		   }
		   else
		   {
			   var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.WB_TAB_CHANGED);
			   dispatchEvent(evnt);
			  
		   }
		   if(xml==null)
		   	return;	
		   getSlideIndex(xml.@page,playHeadTime);
		   verticalScrollPositionContext=xml.@verticalScrollPosition;
		   horizontalScrollPositionContext = xml.@horizontalScrollPosition;
		   contWidth=xml.@width
		   contHeight=xml.@height
		   zoomFactorX=xml.@zoomfactorX    
		   zoomFactorY=xml.@zoomfactorY 
		   maxX=xml.@maxx;
		   maxY=xml.@maxy;
		   var src:String=xml.@src
		   docType=xml.@type
		   if(xml.@unloaded == "true")
		   {
			   if(baseContainer.contains(ispringCanvas))
			   {
				   ispringLoader.unload();
				   baseContainer.removeChild(ispringCanvas);
			   } 
			   if(baseContainer.contains(docCanvas))
			   {
				   p2fLoader.unloadAndStop(true);
				   baseContainer.removeChild(docCanvas);
			   }
			   return;
		   }
		   if(docType=="p2f")
		   {
			   
			   if(baseContainer.contains(ispringCanvas))
			   {
				   ispringLoader.unload();
				   baseContainer.removeChild(ispringCanvas);
			   } 
			   if(!baseContainer.contains(docCanvas))
			   {
				   baseContainer.addChild(docCanvas);
			   }
			   
			   var tempp2fsrc:String=documentPath+"/Contents/"+src;   
			   if(p2fLoader.source != tempp2fsrc+"/page_"+xml.@page+".swf")
			   {
			    	p2fLoader.addEventListener(Event.COMPLETE,setScrollContext)
			   }
			   else
			   {
				   documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);
				   setScrollContext1();
			   }
		   }
		   else if(docType=="ispring")
		   {
			   slide=xml.@page
			   step=xml.@step;
			   if(baseContainer.contains(docCanvas))
			   {
				   p2fLoader.unloadAndStop(true);
				   baseContainer.removeChild(docCanvas);
			   }
			   if(!baseContainer.contains(ispringCanvas))
			   {
				   baseContainer.addChild(ispringCanvas);
			   }
			   tempp2fsrc=documentPath+"/Contents/"+src;
			   if(tempp2fsrc!=p2fsrc)
			   {
				    seekToIspr=true
			   		ispringLoader.load(tempp2fsrc);
					p2fsrc=tempp2fsrc;
					if(!ispringLoader.hasEventListener(PlayerInitEvent.PLAYER_INIT))
					ispringLoader.addEventListener(PlayerInitEvent.PLAYER_INIT,initializeISpringPlayer);					
			   }			  
			   
		   }
		   loadDocumnet(tempp2fsrc,xml.@page,docType);
		   if(!seekToIspr && docType =="ispring")
		   {
			   iSpringSlideControler.playFromStep(step);
		   }
		   
		   //documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);
		  
		  // setTimeout(setScrollContext,100,xml.@verticalScrollPosition,xml.@horizontalScrollPosition)
		  
		  /* setDocScrollPosition("vertical",xml.@verticalScrollPosition); 
		   setDocScrollPosition("horizontal",xml.@horizontalScrollPosition); */
		   rotateDocument(parseInt(xml.@rotation)) 		 
		   
	  }
	 private var verticalScrollPositionContext:Number;
	 private var horizontalScrollPositionContext:Number;
	 private function setScrollContext(evnt:Event):void
	 {
		 p2fLoader.removeEventListener(Event.COMPLETE,setScrollContext)
		 documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);
		 timeOutId=setTimeout(setScrollContext1,50)
	 }
	 private var timeOutId:int;
	 private function setScrollContext1():void{
		 
		 clearTimeout(timeOutId);
		 setDocScrollPosition("vertical",verticalScrollPositionContext); 
		 setDocScrollPosition("timeOutIdhorizontal",horizontalScrollPositionContext);
	 }
	 public function clearDocumentPlayer():void
	 {
		 p2fsrc="";
		 
		 if(baseContainer.contains(ispringCanvas))
		 {
			 ispringLoader.unload();
		 } 
		 else if(baseContainer.contains(docCanvas))
		 {
			 p2fLoader.unloadAndStop(true);
		 }
	 }
	  public function closeDocumentPlayer():void
	  {
	  	p2fLoader.unloadAndStop();
	  	p2fLoader=null;
	  }
}
}