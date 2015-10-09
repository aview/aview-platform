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
 * File			: ContextSetter.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)	: Remya T
 *
 * ContextSetter class is to create the context data of each module at
 * particular time.
 */

package edu.amrita.aview.playback{
	import flash.events.EventDispatcher;
	
	import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
	/**
	 *  You use the ContextSetter class to create the context all play back modules.
	 */
	public class ContextSetter extends EventDispatcher{
		/**
		 * Variable used to store document context time.
		 */		
		public var docContextTime:Number;
		/**
		 *Variable used to store Whiteboard context time.
		 */		
		public var wbContextTime:Number;
		/**
		 * FileLoaderManager class for accessing the XML files from server
		 */
		private var fileLoaderManager:FileLoaderManager
		/**
		 * Context Xml for Whiteboard
		 */
		private var wbContext:XML=<data></data>
		
		/**
		 * Constructor
		 * @param fileLoaderManager of FileLoaderManager for
		 * getting the xml files from servers
		 *
		 */
		public function ContextSetter(fileLoaderManager:FileLoaderManager){
			this.fileLoaderManager=fileLoaderManager;
		}
		
		/**
		 * @public
		 * Setting the PushToTalk context data
		 *
		 * @param playHeadTime of type Number
		 * @return XML
		 *
		 */
		public function setPttContext(playHeadTime:Number):XML{
			var pttContext:XML=<data></data>;
			var states:XMLList=fileLoaderManager.pttXml.state.(attribute("ctime") <= playHeadTime);
			if (states.length() > 0)
				pttContext.appendChild(states[states.length() - 1]);
			return pttContext;
		}
		
		/**
		 * @public
		 * Setting the whiteboard page context data
		 *
		 * @param playHeadTime of type Number
		 * @param pageNo of type int
		 * @return  XML
		 *
		 */
		public function setWbPageContext(playHeadTime:Number, pageNo:int):XML{
			wbContext=<data></data>;
			var pages:XMLList=fileLoaderManager.wbXml.page.(attribute("num") == pageNo);
			for each (var page:XML in pages){
				if (page.@ctime <= playHeadTime){
					wbContextTime=page.@ctime;
					var tempXml:XML=<event></event>;
					tempXml.@module="wb";
					tempXml.@tag="page";
					tempXml.@num=page.@num;
					wbContext.appendChild(tempXml);
					drawPage(page, playHeadTime);
				}
			}
			return wbContext;
		}
		
		/**
		 * @private
		 * For drawing the Whiteboard content
		 *
		 * @param pageData of type XML
		 * @param playHeadTime of type Number
		 * @return void
		 */
		private function drawPage(pageData:XML, playHeadTime:Number):void{
			for each (var size:XML in pageData.elements()){
				if (size.@ctime > playHeadTime)
					break;
				for each (var shape:XML in size.elements()){
					if (shape.@ctime > playHeadTime)
						break;
					var tempXml:XML=<event></event>;
					wbContextTime=shape.@ctime;
					tempXml.@module="wb";
					tempXml.@tag="shape";
					tempXml.@toolName=shape.@toolName;
					tempXml.@lineColor=shape.@lineColor;
					tempXml.@lineThickness=shape.@lineThickness;
					tempXml.@lineAlfa=shape.@lineAlfa;
					tempXml.@drawnAreaWidth=shape.@drawnAreaWidth;
					tempXml.@drawnAreaHeight=shape.@drawnAreaHeight;
					tempXml.@shapeX=shape.@shapeX;
					tempXml.@shapeY=shape.@shapeY;
					if (shape.@toolName == "txt"){
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
		
		/**
		 * @public
		 * Setting the whiteboard context data
		 *
		 * @param playHeadTime of type Number
		 * @return XML
		 *
		 */
		public function setWbContext(playHeadTime:Number):XML{
			
			var previousPage:XML;
			wbContextTime=-1;
			if (fileLoaderManager.wbXml.page.length() == 1) setWbPageContext(playHeadTime, fileLoaderManager.wbXml.page[0].@num);
			else if (fileLoaderManager.wbXml.page.length() > 1){
				previousPage=fileLoaderManager.wbXml.page[0];
				for (var i:uint=0; i < fileLoaderManager.wbXml.page.length(); i++){
					if (fileLoaderManager.wbXml.page[i].@ctime > playHeadTime){
						setWbPageContext(playHeadTime, previousPage.@num);
						return wbContext;
						
					}
					previousPage=fileLoaderManager.wbXml.page[i];
					
				}
				if (fileLoaderManager.wbXml.page[fileLoaderManager.wbXml.page.length() - 1].@ctime < playHeadTime){
					setWbPageContext(playHeadTime, fileLoaderManager.wbXml.page[fileLoaderManager.wbXml.page.length() - 1].@num);
				}
			}
			return wbContext;
		}
		
		/**
		 * @public
		 * Setting the Document  context data
		 *
		 * @param time of Number
		 * @return  XML
		 *
		 */
		public function setDocContext(time:Number):XML{
			var doc:XML;
			var context:XML;
			var i:int;
			docContextTime=-1;
			for (i=0; i < fileLoaderManager.docXml.docloaded.length(); i++){
				if (((i + 1) != fileLoaderManager.docXml.docloaded.length()) && fileLoaderManager.docXml.docloaded[i].@ctime <= time && time < fileLoaderManager.docXml.docloaded[i + 1].@ctime){
					doc=fileLoaderManager.docXml.docloaded[i];
					break;
				}
				else if (i == 0 && fileLoaderManager.docXml.docloaded.length() == 1 && fileLoaderManager.docXml.docloaded[i].@ctime >= time){
					doc=fileLoaderManager.docXml.docloaded[i];
					
				}
				else if (i == fileLoaderManager.docXml.docloaded.length() - 1 && fileLoaderManager.docXml.docloaded[i].@ctime <= time){
					doc=fileLoaderManager.docXml.docloaded[i];
				}
			}
			if (doc != null){
				context=<context></context>;
				context.@src=doc.@src;
				context.@type=doc.@type;				
				for each (var size:XML in doc.elements()){
					context.@maxx=size.@maxx;
					context.@maxy=size.@maxy;
					context.@width=size.@width;
					context.@height=size.@height;
					context.@zoomfactorX=size.@zoomfactorX;
					context.@zoomfactorY=size.@zoomfactorY;
					context.@unloaded="";
					context.@verticalScrollPosition=size.@scrollY;
					context.@horizontalScrollPosition=size.@scroll;
					for each (var event:XML in size.event){
						if (event.@ctime > time)
							break;
						docContextTime=event.@ctime;
						switch (event.@action.toString()){
							case "page":
								context.@page=event.@pageno;
								context.@verticalScrollPosition=0;
								context.@horizontalScrollPosition=0;
								break;
							case "unload":
								context.@unloaded="true";
								break;
							case "scroll":
								if (event.@scrollDirction == "vertical") context.@verticalScrollPosition=event.@scrollPosition;
								else context.@horizontalScrollPosition=event.@scrollPosition;
								break;
							case "rotation":
								context.@rotation=event.@value
								break;
							case "zoom":
								context.@zoomfactorX=event.@zoomX;
								context.@zoomfactorY=event.@zoomY;
								context.@maxx=event.@maxx;
								context.@maxy=event.@maxy;
								break;
							case "animation":
								context.@step=event.@value;
								context.@page=event.@pageno;
								break;
						}
					}
				}
			}
			return context;
		}
		
		/**
		 * @public
		 * Setting the DesktopSharing   context data
		 * @param time of type Number
		 * @return XML
		 *
		 */
		public function getDesktopVideoContext(time:Number):XML{
			var videoData:XML=<data></data>;
			for each (var temp:XML in fileLoaderManager.desktopXml.video){
				if ((temp.@stime <= time + 99) && (time + 99 <= temp.@etime)){
					videoData.appendChild(temp);
					break;
				}
			}
			return videoData;
		}
		
		/**
		 * @public
		 * Setting the PresenterVideo context data		 *
		 * @param time of type Number
		 * @return XML
		 *
		 */
		public function getPresenterVideoContext(time:Number):XML{
			var videoData:XML=<data></data>;
			for each (var temp:XML in fileLoaderManager.pVideoXml.video){
				if ((temp.@stime <= time + 99) && (time + 99 <= temp.@etime)){
					videoData.appendChild(temp);
					break;
				}
			}
			return videoData;
		}
		
		/**
		 * @public
		 * Setting the ViewerVideo context data		 *
		 * @param time of type Number
		 * @return  XML
		 *
		 */
		public function getViewerVideoContext(time:Number):XML{
			var videoData:XML=<data></data>;
			for each (var temp:XML in fileLoaderManager.vVideoXml.video){
				if ((temp.@stime <= time + 99) && (time + 99 <= temp.@etime)) videoData.appendChild(temp);
			}
			return videoData;
		}
	}
}
