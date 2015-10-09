package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.common.FileLoaderManager;
	import edu.amrita.aview.core.playback.events.AviewPlayerEvent;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class ConsolidateXmlBuilder extends EventDispatcher
	{
		public var consolidateXml:XML
		
		private var recordingDuration:Number;
		private var fileLoaderManager:FileLoaderManager
		public var thumbnailFolderPath:String;
		public function ConsolidateXmlBuilder(fileLoaderManager:FileLoaderManager,thumbnailFolderPath:String)
		{
			this.fileLoaderManager=fileLoaderManager;
			this.thumbnailFolderPath=thumbnailFolderPath+"/Contents/";
		}
		public function buildConsilidateXml():void
		{
			consolidateXml=<ctime></ctime>;
			parseChatXml(fileLoaderManager.chatXml);
			parseDocXml(fileLoaderManager.docXml);
			parsePointerXml(fileLoaderManager.wbPointerXml,"wbPointer");
			parsePointerXml(fileLoaderManager.docPointerXml,"docPointer");
			parsePttXml(fileLoaderManager.pttXml);
			parseVideoXml(fileLoaderManager.pVideoXml,"pVideo");
			parseVideoXml(fileLoaderManager.vVideoXml,"vVideo");
			parseWbXmlFile(fileLoaderManager.wbXml)
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.CONSOLIDATE_XML_CREATED)
			dispatchEvent(evnt);
		}
		private function clearWb(wbSprite:Sprite):void
		{
			for(var i:int=wbSprite.numChildren-1;i>=0;i--)
        	{
        		wbSprite.removeChildAt(i);
        	}
    	

		}
		
		private function getTimeTag(ctime:Number):Number
		{
			ctime=Math.floor((ctime/100))
			return ctime=ctime*100
		}
		private function parseWbXmlFile(xml:XML):void
		{
			var tempXml:XML;
			var tempXml2:XML
			var str:String
			var tempTime:Number
			for each(var page:XML in xml.elements()) 
			{ 
				/*if(!fileLoaderManager.isWbXmlLoaded)
				{
					fileLoaderManager.isWbXmlLoaded =true;
				} */
 				str="t"+getTimeTag(page.@ctime);
		 		tempXml=XML("<"+str+"></"+str+">")
				tempXml2=<event></event>
				tempXml2.@module="wb";
				tempXml2.@tag="page";
				tempXml2.@num=page.@num;
				if(XMLList(consolidateXml[str]).length() == 0)
				{
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml)
	
				}
				else
				{
				   consolidateXml[str].appendChild(tempXml2)
				}
				for each(var size:XML in page.elements()) 
				{
					str="t"+getTimeTag(size.@ctime);
					tempXml=XML("<"+str+"></"+str+">")
					tempXml2=<event></event>
					tempXml2.@module="wb";
					tempXml2.@tag="size";
					tempXml2.@width=size.@width;
					tempXml2.@height=size.@height;
					//var c:int=consolidateXml[str].childIndex()
					if(XMLList(consolidateXml[str]).length() == 0)
					{
						tempXml.appendChild(tempXml2);
						consolidateXml.appendChild(tempXml)
	
					}
					else
					{
				  		consolidateXml[str].appendChild(tempXml2)
					}
					for each(var shape:XML in size.elements()) 
					{
						str="t"+getTimeTag(shape.@ctime);
						tempXml=XML("<"+str+"></"+str+">")
						tempXml2=<event></event>
						tempXml2.@module="wb";
						tempXml2.@tag="shape";
						tempXml2.@toolName=shape.@toolName;
						tempXml2.@lineColor=shape.@lineColor;
						tempXml2.@lineThickness=shape.@lineThickness;
						tempXml2.@lineAlfa=shape.@lineAlfa;
						tempXml2.@drawnAreaWidth=shape.@drawnAreaWidth;
		 				tempXml2.@drawnAreaHeight=shape.@drawnAreaHeight;
						//tempXml2.@lectrueName=tempXml2.@lectrueName;
						if(shape.@toolName=="txt")
						{
							tempXml2.@txtAreaX=shape.@txtAreaX;
							tempXml2.@txtAreaY=shape.@txtAreaY;
							tempXml2.@shapeX=shape.@shapeX;
							tempXml2.@shapeY=shape.@shapeY;
							tempXml2.@txtToolFnt=shape.@txtToolFnt;
							tempXml2.@txt_str=shape.@txt_str;
							tempXml2.@txtAreaWidth=shape.@txtAreaWidth;
							tempXml2.@txtAreaHeight=shape.@txtAreaHeight;
						}
						tempXml2.appendChild(shape.content);
						if(XMLList(consolidateXml[str]).length() == 0)
						{
							tempXml.appendChild(tempXml2);
							consolidateXml.appendChild(tempXml)
		
						}
						else
						{
					  		consolidateXml[str].appendChild(tempXml2)
						}
					}
				}
			}
		}
		public function setThumbpath(path:String):void
		{
			var str:String=path;
		}
		public var thumbnailCollection:ArrayCollection=new ArrayCollection();
		private function parseDocXml(xml:XML):void
		{
			var tempXml:XML;
			var tempXml2:XML
			var str:String
			var obj:Object;
			var fullThumbnailPath:String;
			for each(var doc:XML in xml.elements()) 
			{
			
				trace("path"+doc.@src);
				var tempString:String=doc.@src;
				var filename:String=doc.@orginalName;
				fullThumbnailPath=thumbnailFolderPath+tempString.slice(0,tempString.lastIndexOf("/"))+"/@@-Thumbnails-@@/"+filename+"_files/"+
					tempString.substr(tempString.lastIndexOf("/")+1)+"/";
				str="t"+getTimeTag(doc.@ctime);
				tempXml=XML("<"+str+"></"+str+">")
				tempXml2=<event></event>
				tempXml2.@module="doc";
				tempXml2.@tag="docloaded";
				tempXml2.@src=doc.@src;
				tempXml2.@type=doc.@type;
				tempXml2.@filename=doc.@orginalName;	
				
				if(XMLList(consolidateXml[str]).length() == 0)
				{
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml)				
				}
				else
				{					
					consolidateXml[str].appendChild(tempXml2)
				}
				for each(var size:XML in doc.elements()) 
				{				
					str="t"+getTimeTag(size.@ctime);
					tempXml=XML("<"+str+"></"+str+">")
					tempXml2=<event></event>
					tempXml2.@module="doc";
					tempXml2.@tag="size";
					tempXml2.@maxX=size.@maxx;
					tempXml2.@maxY=size.@maxy;
					tempXml2.@width=size.@width;
					tempXml2.@height=size.@height;
					tempXml2.@zoomfactorX=size.@zoomfactorX;
					tempXml2.@zoomfactorY=size.@zoomfactorY;
					tempXml2.@scrollDirection=size.@scrollDirction;
					tempXml2.@scrollPosition=size.@scrollPosition;
					if(XMLList(consolidateXml[str]).length() == 0)
					{
						tempXml.appendChild(tempXml2);
						consolidateXml.appendChild(tempXml)
						
					}
					else
					{
						consolidateXml[str].appendChild(tempXml2)
					}
					var tempPageno:Number=0;
					for each(var event:XML in size.elements()) 
					{
						obj=new Object();
						if(event.@action=="page" || event.@action=="animation")
						{					
							var pageNo:Number=event.@pageno;
							if(tempPageno!=pageNo)
							{
								obj.filepath=fullThumbnailPath+"thumbnail_"+pageNo+".jpg";
								obj.ctime=event.@ctime;
								obj.pageno=event.@pageno;
								thumbnailCollection.addItem(obj);
								tempPageno=pageNo
							}
						}
						str="t"+getTimeTag(event.@ctime);
						tempXml=XML("<"+str+"></"+str+">")
						event.@module="doc";
						if(XMLList(consolidateXml[str]).length() == 0)
						{
							tempXml.appendChild(event);
							consolidateXml.appendChild(tempXml)
							
						}
						else
						{
							consolidateXml[str].appendChild(event)
						}
					}
					
				}
				
			}
		}
		
		
		
		private function parseChatXml(xml:XML):void
		{
			var tempXml:XML;
			var tempXml2:XML
			var str:String
			for each(var msg:XML in xml.elements()) 
			{
				str="t"+getTimeTag(msg.@ctime);
				tempXml=XML("<"+str+"></"+str+">")
				tempXml2=<event></event>
				tempXml2.@module="chat";
				tempXml2.@msg=msg.@content;
				tempXml2.@textSize=msg.@textSize;
				if(XMLList(consolidateXml[str]).length() == 0)
				{
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml)

				}
				else
				{
			  		consolidateXml[str].appendChild(tempXml2)
				}
			}

	   }
	   
	   private function parseVideoXml(xml:XML,module:String):void
		{
			var tempXml:XML;
			var tempXml2:XML
			var str:String;
			var seekStart:int = -1;
			var seekValue:int = -1;
			for each(var video:XML in xml.elements()) 
			{
				/* if(!fileLoaderManager.isPresenterVideoXmlLoaded && module=="pVideo")
				{
					fileLoaderManager.isPresenterVideoXmlLoaded=true;
					
				}
				if(!fileLoaderManager.isViewerVideoXmlLoaded && module=="vVideo")
				{
					fileLoaderManager.isViewerVideoXmlLoaded=true;
				} */
				str="t"+getTimeTag(video.@stime);
				tempXml=XML("<"+str+"></"+str+">")
				tempXml2=<event></event>
				tempXml2.@module=module;
				tempXml2.@displyname=video.@displyname;
				tempXml2.@uname=video.@uname;
				tempXml2.@src=video.@src;
				tempXml2.@etime=video.@etime;
				tempXml2.@isAudioOnly=video.@isAudioOnly;
				tempXml2.@seekStartValue= video.@seekStartValue;
				tempXml2.@seekExist=video.@seekExist;
				tempXml2.@seekTime=video.@seekTime;
				
				if(video.@fileSize.length() > 0)
					tempXml2.@fileSize = video.@fileSize;
					
				if(tempXml2.@seekExist == "true")
				{
					seekStart = tempXml2.@seekStartValue;
					seekValue = tempXml2.@seekTime;
				}
				else
				{
					tempXml2.@seekStartValue = seekStart;
					tempXml2.@seekTime = seekValue;
				}
				if(XMLList(consolidateXml[str]).length() == 0)
				{
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml)

				}
				else
				{
			  		consolidateXml[str].appendChild(tempXml2)
				}
			}

	   }
	   
	   
	   	private function parsePointerXml(xml:XML,module:String):void
		{
			var tempXml:XML;
			var tempXml2:XML
			var str:String
			for each(var pointer:XML in xml.elements()) 
			{
				/* if(!fileLoaderManager.isWbPointerXmlLoaded && module == "wbPointer")
				{
					fileLoaderManager.isWbPointerXmlLoaded=true;
				}
				if(!fileLoaderManager.isDocPointerXmlLoaded && module=="docPointer")
				{
					fileLoaderManager.isDocPointerXmlLoaded=true;
				} */
				str="t"+getTimeTag(pointer.@ctime);
				tempXml=XML("<"+str+"></"+str+">")
				tempXml2=<event></event>
				tempXml2.@module=module;
				tempXml2.@x=pointer.@x;
				tempXml2.@y=pointer.@y;
				tempXml2.@cwidth=pointer.@cwidth;
				tempXml2.@cheight=pointer.@cheight;
				tempXml2.@container=pointer.@container;
				if(XMLList(consolidateXml[str]).length() == 0)
				{
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml)

				}
				else
				{
			  		consolidateXml[str].appendChild(tempXml2)
				}
			}

	   }
	   
	   	private function parsePttXml(xml:XML):void
		{
			var tempXml:XML;
			var tempXml2:XML
			var str:String
			for each(var ptt:XML in xml.elements()) 
			{
				/* if(!fileLoaderManager.isPttXmlLoaded)
				{
					fileLoaderManager.isPttXmlLoaded=true;
				} */
				str="t"+getTimeTag(ptt.@ctime);
				tempXml=XML("<"+str+"></"+str+">")
				tempXml2=<event></event>
				tempXml2.@module="ptt";
				tempXml2.@state=ptt.@state;
				tempXml2.@isPresenter=ptt.@isPresenter;
				if(XMLList(consolidateXml[str]).length() == 0)
				{
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml);

				}
				else
				{
			  		consolidateXml[str].appendChild(tempXml2)
				}
			}

	   }
	   
	   public  function getDataAtTime(time:Number,module:String):XML
	   {
		   	var str:String="t"+time
		   	var xml:XMLList=consolidateXml[str];
		   	//trace(xml);
		   	var dataXml:XML=<data></data>
		   	for each(var temp:XML in xml.elements())
		   	{
		   		if(temp.@module==module)
		   			dataXml.appendChild(temp);
		   	}
		   	return dataXml;
		   	
	   }
	  /*  public function setWbContext(time:Number):XML
	   {
	   	var xml:XML;
	   	return xml; 
	   	
	   }	*/
	   public function setChatContext(time:Number):XML   
	   {
	   		var xml:XML=<chat></chat>;
	   		var tempArray:Array=new Array(3)
	   		 var i:int;
	   	    for(i=0;i<fileLoaderManager.chatXml.children().length();i++)
	   	    {
	   			if(fileLoaderManager.chatXml.msg[i].@ctime>time)
	   				break;
	   			xml.prependChild(fileLoaderManager.chatXml.msg[i])
	   			
	   		}
	   		
	   		return xml;
	   }
	  
	   

}
}