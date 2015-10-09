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
 * File			: DocumentPlayer.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:This class used for handling the document palyback functionality.
 */
package edu.amrita.aview.playback
{
	
	
	import edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents.OnSlideChangedEvent;
	import edu.amrita.aview.core.documentSharing.components.thumbnails.ThumList;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationPlaybackController;
	import edu.amrita.aview.core.documentSharing.ispring.flex.PlayerInitEvent;
	import edu.amrita.aview.core.documentSharing.ispring.flex.PresentationContainer;
	import edu.amrita.aview.playback.events.AviewPlayerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.SWFLoader;
	import mx.events.ResizeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	/**
	 *  The DocumentPlayer class displays all the documents in an particular 
	 *  recorded session.
	 *  You typically use this  for showing the document events one by one which was recorded 
	 *  from live session
	 * 
	 *  <p>The DocumentPlayer class lets you make the new experince like wa. 
	 *  It can also resize itself to fit the size of parent  container.
	 *  By default, content is scaled to fit the size of the parent container.</p>  
	 *
	 */
	public class DocumentPlayer extends EventDispatcher
	{
		//VVCR: Spellings for comments are written wrong. Need to correct them  
		/**
		 * Surce of document which have already loaded
		 */
		private  var p2fsrc:String;
		
		//VVCR: Spellings for comments are written wrong. Need to correct them  
		/**
		 *  Docuement Content width
		 */
		
		//VVCR: Spellings for comments are written wrong. Need to correct them  
		public var contWidth:Number;
		/**
		 * Docuement Content height
		 */
		public var contHeight:Number;
		/**
		 * Document zoom postion of X-axis
		 */
		public var zoomFactorX:Number;
		/**
		 *  Document zoom postion of Y-axis
		 */
		public var zoomFactorY:Number;
		/**
		 * Consolidate xml data of document playback
		 */
		private var consolidateXmlBuilder:ConsolidateXmlBuilder=null;
		/**
		 * Context data of document playback
		 */
		private var contextSetter:ContextSetter;
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.playback.DocumentPlayer.as");
		
		/**
		 * Non-Animated player
		 */
		public var p2fLoader:SWFLoader;
		/**
		 * Parent document of Non-animated document player
		 */
		private var docCanvas:Canvas;
		/**
		 * Main container for all type of loader
		 */
		private var baseContainer:Canvas;	
		/**
		 * Player of Animated document
		 */
		public var ispringLoader:PresentationContainer;
		/**
		 * Parent conatiner for IpsringLoader
		 */
		public var ispringCanvas:Canvas;
		/**
		 * Data collection of slide info
		 */
		[Bindable]
	    public var slideCollection:ArrayCollection;
	    public var obj:Object;
		/**
		 * This refers for Tyoe of document
		 * There are two type of document
		 * one is Animated and other one is Non-Animated
		 */
	    private var docType:String;
		/**
		 * This refers for pointer playback class DocPointerPlayer
		 */
		private var documentPath:String;
		/**
		 * This refers for pointer playback class DocPointerPlayer
		 */
		private var docPointerPlayer:DocumentPointerPlayer=null;
		public function DocumentPlayer()
		{		
			
		}
		
		/**
		 * @public
		 * Here we set the document source path for document playback
		 * @param documentPath of String
		 * @return void
		 */
		public function setDocPath(documentPath:String):void
		{
			this.documentPath=documentPath;
		}
		/**
		 * @public
		 *  Here we are set the User interface reference  of this class
		 * @param p2fLoader of SWFLoader
		 * @param docCanvas of Canvas
		 * @param ispringLoader PresentationContainer
		 * @param isprCanvas of Canvas
		 * @param base of Canvas
		 * @param contHeight of Number
		 * @param contWidth of Number
		 * @return void
		 */
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
			docPointerPlayer=new DocumentPointerPlayer(ispringLoader,p2fLoader);
			if(consolidateXmlBuilder!=null)
			{
				docPointerPlayer.setConsolidateXmlBilder(consolidateXmlBuilder)
			}
			var evnt:ResizeEvent;
			onDocResize(evnt);
		}
		
		//VVCR: Variable definitions can be in a single place, right after the class declaration.
		/**
		 * This refers for document container width
		 */	
		private var docWidth:Number=0;
		/**
		 * This refers for document container height
		 */
		private var docHeight:Number=0;	
		/**
		 * @public
		 * This function will invoke while resize the document container
		 * @param event of ResizeEvent
		 * @return void
		 */
		public function onDocResize(event:ResizeEvent):void
		{
		
			getResolution();
			
	    
		}
	
		/**
		 * @public
		 *To adjust the resolution of document play back window
		 *This maintain the 3/4th ratio of parent component
		 *
		 */
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
		
		//VVCR: Variable definitions can be in a single place, right after the class declaration.
		
		/**
		 * This refers for timing of vertical scroll position
		 */
		private var timeOutIdXAfterResize:uint;
		/**
		 * This refers for timing of horizontal scroll position
		 */
		private var timeOutIdYAfterResize:uint;
		//GTMCR:: change the function name setscrolXAfterResize to setScrollXAfterResize
		/**
		 * @private
		 * For adjusting the horizontal scroll position after resizing
		 * @param position of Number
		 * @param maxPosition of Number
		 * @return void
		 *
		 */
		private function setscrolXAfterResize(position:Number,maxPosition:Number):void
		{
			clearTimeout(timeOutIdXAfterResize);
			position = (position*maxX)/maxPosition;
			setDocScrollPosition("horizontal",position);
		}
		//GTMCR:: change the function name setscrolYAfterResize to setScrollYAfterResize
		/**
		 * @private
		 * For adjusting the vertical scroll position after resizing
		 * @param position of number
		 * @param maxPosition of number
		 * @return void
		 */
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
		/**
		 * @public
		 * For setting the consolidateXmldata for Documnet playback
		 * @param consolidateXmlBuilder of ConsolidateXmlBuilder
		 * @return void
		 */
		public function setConsolidateXMLBuilder(consolidateXmlBuilder:ConsolidateXmlBuilder):void
		{
			this.consolidateXmlBuilder = consolidateXmlBuilder;
			if(docPointerPlayer!=null)
			{
				docPointerPlayer.setConsolidateXmlBilder(consolidateXmlBuilder);
			}
		}
		
		/**
		 * @public
		 * For setting the context data for document playback
		 * @param contextSetter of ContextSetter
		 * @return void
		 */
		public function setContextSetter(contextSetter:ContextSetter):void
		{
			this.contextSetter = contextSetter;
		}
		
		
		//VVCR: Variable definitions can be in a single place, right after the class declaration.
		//VVCR: If the temporary variable is used within the file only, it ca be declared as private 
		/**
		 * Temporory variable for slide number
		 */
		
		public var tempSlide:Number=0;
		/**
		 * Filename of current loaded document
		 */		
		private var fileName:String;
		
		/**
		 * @private
		 * for getting the loaded page's slide index from slide panel
		 * @param pageno of Number
		 * @param ctime of Number
		 * @return int
		 *
		 */
		private function getSlideIndex(pageno:Number,ctime:Number):int
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
			return currentIndex;
		}
	public function playDocument(time:Number):void
	{
		slideCollection=consolidateXmlBuilder.thumbnailCollection;
		if(docPointerPlayer)
		docPointerPlayer.playDocPointer(time);    		      	
		var xml:XML=consolidateXmlBuilder.getDataAtTime(time,"doc");            	
		var ds:XMLList=xml.elements();		
		for(var i:Number=0;i<ds.length();i++)
		{   			
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.DOC_TAB_CHANGED);
			dispatchEvent(evnt);
			if(ds[i].@tag=="docloaded")          		
			{ 
				getResolution();
				docType=ds[i].@type ;  
				fileName=ds[i].@filename
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
					ThumList.slideIndex=getSlideIndex(ds[i].@pageno,ds[i].@ctime);	
					dispatchEvent(new OnSlideChangedEvent(ThumList.slideIndex));
					loadDocumnet(p2fsrc,ds[i].@pageno,docType);
					if(Log.isDebug()) log.debug("pagenumber"+ds[i].@pageno)
					tempSlide=ds[i].@pageno;
				}
				else if(ds[i].@action=="animation" && iSpringSlideControler)
				{	
					ThumList.slideIndex=getSlideIndex(ds[i].@pageno,ds[i].@ctime);	
					dispatchEvent(new OnSlideChangedEvent(ThumList.slideIndex));
					if(Log.isDebug()) log.debug("animation"+ds[i].@value)
					//VVCR: Varibale name does not follow the naming convention. It should be stepNo
					var stepno:Number=ds[i].@value;
					if(tempSlide==ds[i].@pageno)
					{
						iSpringSlideControler.playFromStep(stepno)
					}
					else
					{
						
						iSpringSlideControler.gotoSlide(ds[i].@pageno-1,true);
						tempSlide=ds[i].@pageno
						
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
	/**
	 * @private
	 * For laoding the content to document container
	 * @param src of String
	 * @param pageNo of Number
	 * @param type of String
	 * @return void
	 *
	 */
	private function loadDocumnet(src:String,pageNo:Number,type:String):void
	{
		       if(type=="p2f")
		       {
				   //VVCCR: Its good practice to check whether the passed parameter values are not null.
				   //this will avoid occurance of the many runtime errors due to null pointer exception.
				   //In this case both src and pageNo values can be null, so checking that would be nice.
		      	 p2fLoader.source=src+"/page_"+pageNo+".swf"
		       }
		       else if(type=="ispring" && !seekToIspr)
		       {
				  	 if(iSpringSlideControler)
		       	   	iSpringSlideControler.gotoSlide(pageNo-1);
		       }
		      p2fsrc=src;
		       
	} 	
	
	//VVCR: Variable definitions can be in a single place, right after the class declaration.
	
	/**
	 * This refers for ispring player controls
	 */
	private var iSpringSlideControler:IPresentationPlaybackController;
	/**
	 * @private
	 * This function invoked on the time of file loading to
	 * iSpringSlideControler
	 * @param event of PlayerInitEvent
	 * @return void
	 */
    private function  initializeISpringPlayer(event:PlayerInitEvent):void
    {    		
	    iSpringSlideControler=event.player.playbackController;
		if(seekToIspr)
		{
			iSpringSlideControler.gotoSlide(slide-1,true);
			//iSpringSlideControler.playFromStep(step);
			seekToIspr=false;
		}
    }
	/**
	 * @private
	 * For hanlding the rotationg functionality in document loader
	 * This will rotate the document according to the rotaing count
	 * @param count of int
	 * @return void
	 */
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
	/**
	 * @private
	 * For checking which scroll position would be adjusting .
	 * There are two conditon like  'vertical' or 'horizontal'.
	 * Adjusting apropriate postion of document container agianst to
	 * the direction
	 * @param direction of String
	 * @param position of Number
	 * @return void
	 */
	private function setDocScrollPosition(direction:String,position:Number):void
	{
		if(direction=="vertical")
		{
			if(docCanvas.maxVerticalScrollPosition >0)
			{
				position=position*(docCanvas.maxVerticalScrollPosition/maxY);
			}
			docCanvas.verticalScrollPosition=position;
		}
		else if(direction=="horizontal")
		{
			if(docCanvas.maxHorizontalScrollPosition>0)
			{
				position=position*(docCanvas.maxHorizontalScrollPosition/maxX)
			}
			docCanvas.horizontalScrollPosition=position;
		}
	}
	/**
	 * @private
	 * For Handling the Document scaling functionality Scaling means to adjusting
	 * the zoom positon of document.
	 * @param width of Number
	 * @param height of Number
	 * @param zoomX of Number
	 * @param zoomY of Number
	 * @param contWidth of Number
	 * @return void
	 */   
	private function documentScaling(width:Number,height:Number,zoomX:Number,zoomY:Number,contHeight:Number,contWidth:Number):void
	{
		p2fLoader.scaleX=zoomX*(width)/contWidth;	
		p2fLoader.scaleY=zoomY*(width)/contWidth;
	}
	
	//VVCR: If the function is not used, as it looks like,it can be removed.
	private function scaleContainer(evnt:Event):void
	{          
	    //documentScaling(contWidth,contHeight,zoomFactorX,zoomFactorY);		
	}
	
	//VVCR: Variable definitions can be in a single place, right after the class declaration.
	/**
	 * This boolean refers to check whether the seeking to animated documnet.
	 * @default false means not to animated document
	 */
	public var seekToIspr:Boolean=false;
	/**
	 * This refers for slide index of  documnet container
	 */	
	private var slide:Number;
	private var step:Number;
	/**
	 * This refers for maximum  X-axis postion of documnet content
	 */
	private var maxX:Number;
	/**
	 * This refers for maximum  Y-axis postion of documnet content
	 */
	private var maxY:Number;
	/**
	 * @public
	 * This function will invoked on timer time change.
	 * We collect the data context from contextSetter class
	 * and set in to document container.
	 * @param playHeadTime of Number
	 * @return void
	 */
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
		   ThumList.slideIndex=getSlideIndex(xml.@page,playHeadTime);	
		   dispatchEvent(new OnSlideChangedEvent(ThumList.slideIndex));
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
	 
	 //VVCR: Variable definitions can be in a single place, right after the class declaration.
	 
	 /**
	  * This refers for vertical postion of documnet content
	  */
	 private var verticalScrollPositionContext:Number;
	 /**
	  * This refers for horizhontal postion of documnet content
	  */	 
	 private var horizontalScrollPositionContext:Number;
	 /**
	  * @private
	  * For handling the scroll position of document content
	  * 
	  * @return void
	  */
	 private function setScrollContext(evnt:Event):void
	 {
		 p2fLoader.removeEventListener(Event.COMPLETE,setScrollContext)
		 documentScaling(docWidth,docHeight,zoomFactorX,zoomFactorY,contHeight,contWidth);
		 timeOutId=setTimeout(setScrollContext1,50)
	 }
	 /**
	  *This refers for timing of scroll position maintains
	  */
	 private var timeOutId:int;
	 private function setScrollContext1():void{
		 
		 clearTimeout(timeOutId);
		 setDocScrollPosition("vertical",verticalScrollPositionContext); 
		 setDocScrollPosition("timeOutIdhorizontal",horizontalScrollPositionContext);
	 }
	 public function clearDocumentPlayer():void
	 {
		 p2fsrc="";
		 
		 /*if(baseContainer.contains(ispringCanvas))
		 {
			 ispringLoader.unload();
		 } 
		 else if(baseContainer.contains(docCanvas))
		 {
			 p2fLoader.unloadAndStop(true);
		 }*/
	 }
	 /**
	  * @public
	  * For clearing the document container while colsing the  playback session
	  * 
	  * @return void
	  */
	  public function closeDocumentPlayer():void
	  {
	  	p2fLoader.unloadAndStop();
	  	p2fLoader=null;
	  }
}
}