package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.common.FileLoaderManager;
	
	import flash.events.EventDispatcher;
	
	public class ContextSetter extends EventDispatcher
	{
		public var docContextTime:Number;
		public var wbContextTime:Number;
		private var fileLoaderManager:FileLoaderManager
		public function ContextSetter(fileLoaderManager:FileLoaderManager)
		{
			this.fileLoaderManager=fileLoaderManager;
		}
		private var wbContext:XML=<data></data>
		public function setPttContext(playHeadTime:Number):XML
		{
			var pttContext:XML=<data></data>
			var states:XMLList =fileLoaderManager.pttXml.state.(attribute("ctime") <= playHeadTime);
			if(states.length()>0)
				pttContext.appendChild(states[states.length()-1]);
			return pttContext;
		}
		public function setWbPageContext(playHeadTime:Number,pageNo:int):XML
		{
			wbContext=<data></data>
			var pages:XMLList=fileLoaderManager.wbXml.page.(attribute("num") == pageNo);
			for each (var page:XML in pages)
			{
				if(page.@ctime<=playHeadTime)
				{
					wbContextTime=page.@ctime;
					/* var tempXml:XML=<event></event>
					tempXml.@module="wb";
					tempXml.@tag="page";
					tempXml.@num=page.@num;
					wbContext.appendChild(tempXml); */
					var tempXml:XML=<event></event>
					tempXml.@module="wb";
					tempXml.@tag="page";
					tempXml.@num=page.@num;
					wbContext.appendChild(tempXml);
					drawPage(page,playHeadTime);
					
				}
			}
			return wbContext;				
		}
		private function drawPage(pageData:XML,playHeadTime:Number):void
		{
			for each (var size:XML in pageData.elements())
			{
				if(size.@ctime>playHeadTime)
					break;
				for each (var shape:XML in size.elements())
				{
					 if(shape.@ctime>playHeadTime)
						break;
					 var tempXml:XML=<event></event>
					 wbContextTime=shape.@ctime;
					 tempXml.@module="wb";
					 tempXml.@tag="shape";
					 tempXml.@toolName=shape.@toolName;
					 tempXml.@lineColor=shape.@lineColor;
					 tempXml.@lineThickness=shape.@lineThickness;
					 tempXml.@lineAlfa=shape.@lineAlfa;
				  	 tempXml.@drawnAreaWidth=shape.@drawnAreaWidth;
	 			 	 tempXml.@drawnAreaHeight=shape.@drawnAreaHeight;
					 if(shape.@toolName=="txt")
					 {
						 tempXml.@txtAreaX=shape.@txtAreaX;
						 tempXml.@txtAreaY=shape.@txtAreaY;
						 tempXml.@txtToolFnt=shape.@txtToolFnt;
						 tempXml.@txt_str=shape.@txt_str;
						 tempXml.@txtAreaWidth=shape.@txtAreaWidth;
						 tempXml.@txtAreaHeight=shape.@txtAreaHeight;
					 }
					 tempXml.appendChild(shape.content);
					 wbContext.appendChild(tempXml);
					
	  	 		}
	 	 	}
		}
		public function setWbContext(playHeadTime:Number):XML
		{
			//clearWb(wbSprite);
			var previousPage:XML;
			wbContextTime=-1;
			//Alert.show(""+wbXml.page.length());
			if(fileLoaderManager.wbXml.page.length()==1)
			{
					setWbPageContext(playHeadTime,fileLoaderManager.wbXml.page[0].@num)
			}
			else if(fileLoaderManager.wbXml.page.length()>1)
			{
				previousPage=fileLoaderManager.wbXml.page[0];
				for (var i:uint=0;i< fileLoaderManager.wbXml.page.length();i++)
				{
					if(fileLoaderManager.wbXml.page[i].@ctime>playHeadTime)
					{
						setWbPageContext(playHeadTime,previousPage.@num)
						return wbContext;
						
					}	
					previousPage=fileLoaderManager.wbXml.page[i]			
					
		 		}
		 		if(fileLoaderManager.wbXml.page[fileLoaderManager.wbXml.page.length()-1].@ctime<playHeadTime)
		 		{
		 			setWbPageContext(playHeadTime,fileLoaderManager.wbXml.page[fileLoaderManager.wbXml.page.length()-1].@num)
		 		}
				
			}
			
			return wbContext;
		}
		
	  public function setDocContext(time:Number):XML   
	   {
	   	    var doc:XML;
	   	    var size:XML;
	   	    var context:XML
	   	    var i:int;
			docContextTime=-1;
	   	    for(i=0;i<fileLoaderManager.docXml.docloaded.length();i++)
	   	    {
	   	    	if(((i+1)!=fileLoaderManager.docXml.docloaded.length())&& fileLoaderManager.docXml.docloaded[i].@ctime <=time && time< fileLoaderManager.docXml.docloaded[i+1].@ctime )
	   	    	{
	   	    		doc=fileLoaderManager.docXml.docloaded[i];
	   	    		break
	   	    	}
	   	    	else if(i==0 && fileLoaderManager.docXml.docloaded.length()==1 && fileLoaderManager.docXml.docloaded[i].@ctime >=time )
	   	    	{
	   	    		doc=fileLoaderManager.docXml.docloaded[i];
	   	    		
	   	    	}
	   	    	else if(i==fileLoaderManager.docXml.docloaded.length()-1 && fileLoaderManager.docXml.docloaded[i].@ctime<=time )
	   	    	{
	   	    		doc=fileLoaderManager.docXml.docloaded[i];
	   	    		
	   	    	}
	   	    	
	   	    }
	   	    if(doc!=null)
	   	    {
	
	   	    	context=<context></context>
	   	    	context.@src=doc.@src;
				context.@type=doc.@type;
				for each(var size:XML in doc.elements()) 
				{	
					//docContextTime=size.@ctime;
					context.@maxx=size.@maxx;
					context.@maxy=size.@maxy;
					context.@width=size.@width;
					context.@height=size.@height;
					context.@zoomfactorX=size.@zoomfactorX;
					context.@zoomfactorY=size.@zoomfactorY;
					context.@unloaded="";
					context.@verticalScrollPosition=size.@scrollY;
					context.@horizontalScrollPosition=size.@scroll;
					for each(var event:XML in size.event)
					{
						if(event.@ctime>time)
							break;
						docContextTime=event.@ctime;
						switch(event.@action.toString())
						{
							case "page":
								context.@page=event.@pageno;
								context.@verticalScrollPosition=0;
								context.@horizontalScrollPosition=0;
								break
							case "unload":
								context.@unloaded="true";
								break
							case  "scroll":
								if(event.@scrollDirction=="vertical")
								{	
									context.@verticalScrollPosition=event.@scrollPosition;
								}
								else
								{
									context.@horizontalScrollPosition=event.@scrollPosition;
								}
								break;
							case  "rotation":
								context.@rotation=event.@value
								break;
							case  "zoom":
								context.@zoomfactorX=event.@zoomX;
								context.@zoomfactorY=event.@zoomY;
								context.@maxx=event.@maxx;
								context.@maxy=event.@maxy;
								
								break;
							case  "animation":
								context.@step=event.@value;
								context.@page=event.@pageno;
								break;
						}
					} 
				}
	   	    /*	 for(i=0;i<doc.size.length();i++)
	   	    	{
	   	    		if(((i+1)!=doc.size.length())&& doc.size[i].@ctime <=time && time< doc.size[i+1].@ctime )
		   	    	{
		   	    		size=doc.size[i];
		   	    		break
		   	    	}
		   	    	else if(i==0 && doc.size.length()==1 &&  doc.size[i].@ctime >=time)
		   	    	{
		   	    		size=doc.size[i];
		   	    	}
		   	    	else if(i==doc.size.length()-1 && doc.size[i].@ctime<=time)
		   	    	{
		   	    		size=doc.size[i];
		   	    	}
	   	    	}*/
	   	    	
	   	    }
	   	    if(size!=null)
	   	    {
				
	   	    	
	   	    	
	   	    }
	   		return context;
	   }
	   
	   public function getPresenterVideoContext(time:Number):XML   
	   {
	   		   
	   	 var videoData:XML=<data></data>
	   	 for each(var temp:XML in fileLoaderManager.pVideoXml.video)
	   	 {	   	 	
	   	 	if((temp.@stime<= time+99) && (time+99 <=temp.@etime))
	   	 	{
	   	 		videoData.appendChild(temp);
	   	 		break;
	   	 	}
	   	 }
	   		return videoData;
	   }
	    public function getViewerVideoContext(time:Number):XML   
	   {
	   	    var videoData:XML=<data></data>
	   	    for each(var temp:XML in fileLoaderManager.vVideoXml.video)
	   	 	{
		   	 	if((temp.@stime<= time+99) && (time+99 <=temp.@etime))
		   	 	{  
		   	 		videoData.appendChild(temp);
		   	 	}
	   		}
	   		return videoData;
	   }
		

	}
}