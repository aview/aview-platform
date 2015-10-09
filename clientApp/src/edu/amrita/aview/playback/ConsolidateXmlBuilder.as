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
 * File			: ConsolidateXmlBuilder.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:This class used for consolidate all xml data of chat,documentsharing and white board
 * In to one xml.
 */

package edu.amrita.aview.playback{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;

	import edu.amrita.aview.common.components.fileloader.FileLoaderManager;
	import edu.amrita.aview.playback.events.AviewPlayerEvent;
	
	/**
	 *  You use the ConsolidateXmlBuilder class to create the consolidate all recorded data of play back modules in to an XML.
	 */ 
	public class ConsolidateXmlBuilder extends EventDispatcher{
		/**
		 * for consloidating data of all modules
		 */
		public var consolidateXml:XML
		/**
		 * total time duration of recoreded session
		 */
		private var recordingDuration:Number;
		/**
		 * This class for collecting  the xml data from server for each module
		 */
		private var fileLoaderManager:FileLoaderManager
		/**
		 * Thumbnail path for document playbacvk
		 */
		public var thumbnailFolderPath:String;
		/**
		 * Information about thumbnail data
		 */
		public var thumbnailCollection:ArrayCollection=new ArrayCollection();
		/**
		 * Array for viewer videos
		 */
		public var viewerVideoTagArray:Array=new Array();
		/**
		 * Array for presenter  video
		 */
		public var presenterVideoTagArray:Array=new Array();
		/**
		 * Array for desktop sharing  video
		 */
		public var deskTopVideoTagArray:Array=new Array();
		
		
		
		/**
		 * @public
		 * This is constructor for ConsolidateXmlBuilder class
		 * we are setting the fileLoaderManager  and thumbnailFolderPath here
		 * @param  fileLoaderManager of FileLoaderManager
		 * @param thumbnailFolderPath of String
		 */
		public function ConsolidateXmlBuilder(fileLoaderManager:FileLoaderManager, thumbnailFolderPath:String){
			this.fileLoaderManager=fileLoaderManager;
			this.thumbnailFolderPath=thumbnailFolderPath + "/Contents/";
		}
		
		/**
		 * @public
		 * for initilize to bulid consolidate xml for all modules		 * 
		 * @return void
		 */
		public function buildConsilidateXml():void{
			consolidateXml=<ctime></ctime>;
			parseChatXml(fileLoaderManager.chatXml);
			parseDocXml(fileLoaderManager.docXml);
			parsePointerXml(fileLoaderManager.wbPointerXml, "wbPointer");
			parsePointerXml(fileLoaderManager.docPointerXml, "docPointer");
			parsePttXml(fileLoaderManager.pttXml);
			parseVideoXml(fileLoaderManager.pVideoXml, "pVideo");
			parseVideoXml(fileLoaderManager.vVideoXml, "vVideo");
			parseVideoXml(fileLoaderManager.desktopXml, "desktop");
			parseWhiteBoardxmlFile(fileLoaderManager.wbXml)
			var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.CONSOLIDATE_XML_CREATED)
			evnt.viewerVideoTagArray=viewerVideoTagArray;
			evnt.desktopVideoTagArray=deskTopVideoTagArray;
			evnt.presenterVideoTagArray=presenterVideoTagArray;
			dispatchEvent(evnt);
		}
		
		
		/**
		 * @private
		 * For clearing the whiteboard content from Whiteboard		 * 
		 * @return void
		 */
		private function clearWb(wbSprite:Sprite):void{
			for (var i:int=wbSprite.numChildren - 1; i >= 0; i--){
				wbSprite.removeChildAt(i);
			}
		}		
		
		/**
		 * @private
		 * For getting  start timeTage for each module and formating
		 * @param time as Number
		 * @return Number
		 */
		private function getTimeTag(time:Number):Number{
			time=Math.floor((time / 100))
			return time=time * 100
		}		
	
		/**
		 * @private
		 * For parsing the whiteborad recorded data in to consolidateXml
		 * @param xml of XML
		 * @return void
		 */
		private function parseWhiteBoardxmlFile(xml:XML):void{
			var tempXml:XML;			
			var tempXml2:XML;
			var str:String;
			var tempTime:Number;
			for each (var page:XML in xml.elements()){
				str="t" + getTimeTag(page.@ctime);
				tempXml=XML("<" + str + "></" + str + ">")
				tempXml2=<event></event>;
				tempXml2.@module="wb";
				tempXml2.@tag="page";
				tempXml2.@num=page.@num;
				if (XMLList(consolidateXml[str]).length() == 0){
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml);
					
				}
				else{
					consolidateXml[str].appendChild(tempXml2);
				}
				for each (var size:XML in page.elements()){
					str="t" + getTimeTag(size.@ctime);
					tempXml=XML("<" + str + "></" + str + ">")
					tempXml2=<event></event>
					tempXml2.@module="wb";
					tempXml2.@tag="size";
					tempXml2.@width=size.@width;
					tempXml2.@height=size.@height;
					if (XMLList(consolidateXml[str]).length() == 0){
						tempXml.appendChild(tempXml2);
						consolidateXml.appendChild(tempXml)
						
					}
					else{
						consolidateXml[str].appendChild(tempXml2);
					}
					for each (var shape:XML in size.elements()){
						str="t" + getTimeTag(shape.@ctime);
						tempXml=XML("<" + str + "></" + str + ">");
						tempXml2=<event></event>;
						tempXml2.@module="wb";
						tempXml2.@tag="shape";
						tempXml2.@toolName=shape.@toolName;
						tempXml2.@lineColor=shape.@lineColor;
						tempXml2.@lineThickness=shape.@lineThickness;
						tempXml2.@lineAlfa=shape.@lineAlfa;
						tempXml2.@drawnAreaWidth=shape.@drawnAreaWidth;
						tempXml2.@drawnAreaHeight=shape.@drawnAreaHeight;						
						tempXml2.@shapeX=shape.@shapeX;
						tempXml2.@shapeY=shape.@shapeY;
						if (shape.@toolName == "txt"){
							tempXml2.@txtToolFnt=shape.@txtToolFnt;
							tempXml2.@txt_str=shape.@txt_str;
							tempXml2.@txtAreaWidth=shape.@txtAreaWidth;
							tempXml2.@txtAreaHeight=shape.@txtAreaHeight;
						}
						tempXml2.appendChild(shape.content);
						if (XMLList(consolidateXml[str]).length() == 0){
							tempXml.appendChild(tempXml2);
							consolidateXml.appendChild(tempXml);
							
						}
						else{
							consolidateXml[str].appendChild(tempXml2);
						}
					}
				}
			}
		}	
		
		
	   //VVCR: This function does not seems to be usable. The setter variable scope is limited to the same function 
	   //which does not return anything back. As per the documentation its purpose is for setting the thubnail path,
	   //the preffered implementation can be of two ways:
	   // 1.Keep the variable definition outside the function: ie  var str:String =""; public function setThumbpath(path:String):void{ str= path;}
	   // 2.trurn the value from the setter function ie. public function setThumbpath(str:String):String{var str:String = path; return str;}
		
		/**
		 * @public
		 * for setting the thumbnail path of Document play back
		 * @parm path of String
		 * @return void
		 */
		public function setThumbpath(path:String):void{
			var str:String=path;
		}
		
		/**
		 * @private
		 * For parsing the document recorded data in to consolidateXml
		 * @param xml of XML
		 * @return void
		 */
		private function parseDocXml(xml:XML):void{
			//variable initialization is a good practice.
			var tempXml:XML;
			var tempXml2:XML
			var str:String
			var obj:Object;
			var fullThumbnailPath:String;
			for each (var doc:XML in xml.elements()){
				var tempString:String=doc.@src;
				var filename:String=doc.@orginalName;
				fullThumbnailPath=thumbnailFolderPath + tempString.slice(0, tempString.lastIndexOf("/")) + "/@@-Thumbnails-@@/" + filename + "_files/" + tempString.substr(tempString.lastIndexOf("/") + 1) + "/";
				str="t" + getTimeTag(doc.@ctime);			
				tempXml=XML("<" + str + "></" + str + ">")
				tempXml2=<event></event>
				tempXml2.@module="doc";
				tempXml2.@tag="docloaded";
				tempXml2.@src=doc.@src;
				tempXml2.@type=doc.@type;
				tempXml2.@filename=doc.@orginalName;
				
				if (XMLList(consolidateXml[str]).length() == 0){
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml)
				}
				else{
					consolidateXml[str].appendChild(tempXml2)
				}
				for each (var size:XML in doc.elements()){
					str="t" + getTimeTag(size.@ctime);
					tempXml=XML("<" + str + "></" + str + ">")
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
					if (XMLList(consolidateXml[str]).length() == 0){
						tempXml.appendChild(tempXml2);
						consolidateXml.appendChild(tempXml)
						
					}
					else{
						consolidateXml[str].appendChild(tempXml2)
					}
					var tempPageno:Number=0;
					for each (var event:XML in size.elements()){
						obj=new Object();
						if (event.@action == "page" || event.@action == "animation"){
							var pageNo:Number=event.@pageno;
							if (tempPageno != pageNo){
								obj.filepath=fullThumbnailPath + "thumbnail_" + pageNo + ".jpg";
								obj.ctime=event.@ctime;
								obj.pageno=event.@pageno;
								thumbnailCollection.addItem(obj);
								tempPageno=pageNo
							}
						}
						str="t" + getTimeTag(event.@ctime);
						tempXml=XML("<" + str + "></" + str + ">")
						event.@module="doc";
						if (XMLList(consolidateXml[str]).length() == 0){
							tempXml.appendChild(event);
							consolidateXml.appendChild(tempXml)
							
						}
						else{
							consolidateXml[str].appendChild(event)
						}
					}
					
				}
				
			}
		}
		
		/**
		 * @private
		 * For parsing the chat recorded data in to consolidateXml
		 * @param xml of XML
		 * @return void
		 */
		private function parseChatXml(xml:XML):void{
			var tempXml:XML;			
			var tempXml2:XML;
			var str:String;
			for each (var msg:XML in xml.elements()){
				str="t" + getTimeTag(msg.@ctime);
				tempXml=XML("<" + str + "></" + str + ">")
				tempXml2=<event></event>;
				tempXml2.@module="chat";
				tempXml2.@msg=msg.@content;
				tempXml2.@textSize=msg.@textSize;
				if (XMLList(consolidateXml[str]).length() == 0){
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml);
					
				}
				else consolidateXml[str].appendChild(tempXml2)
			}
			
		}
		
		/**
		 * @private
		 * For parsing the video recorded data in to consolidateXml
		 * @param xml of XML
		 * @param module of String
		 * @return void
		 */
		private function parseVideoXml(xml:XML, module:String):void{
			var tempXml:XML;			
			var tempXml2:XML;
			var str:String;
			var seekStart:int=-1;
			var seekValue:int=-1;
			for each (var video:XML in xml.elements()){ 
				if (module == "vVideo") viewerVideoTagArray.push(video);
				else if (module == "desktop") deskTopVideoTagArray.push(video)
				else presenterVideoTagArray.push(video)
				str="t" + getTimeTag(video.@stime);
				tempXml=XML("<" + str + "></" + str + ">")
				tempXml2=<event></event>
				tempXml2.@module=module;
				tempXml2.@displyname=video.@displyname;
				tempXml2.@uname=video.@uname;
				tempXml2.@src=video.@src;
				tempXml2.@etime=video.@etime;
				tempXml2.@isAudioOnly=video.@isAudioOnly;
				tempXml2.@seekStartValue=video.@seekStartValue;
				tempXml2.@seekExist=video.@seekExist;
				tempXml2.@seekTime=video.@seekTime;
				
				if (video.@fileSize.length() > 0) tempXml2.@fileSize=video.@fileSize;
				if (tempXml2.@seekExist == "true"){
					seekStart=tempXml2.@seekStartValue;
					seekValue=tempXml2.@seekTime;
				}
				else{
					tempXml2.@seekStartValue=seekStart;
					tempXml2.@seekTime=seekValue;
				}
				if (XMLList(consolidateXml[str]).length() == 0){
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml);
					
				}
				else consolidateXml[str].appendChild(tempXml2);
			}
			
		}
		
		/**
		 * @private
		 * For parsing the doument pointer's recorded data in to consolidateXml
		 * @param xml of XML
		 * @param module of String
		 * @return void
		 */
		private function parsePointerXml(xml:XML, module:String):void{
			var tempXml:XML;
			var tempXml2:XML;
			var str:String;
			for each (var pointer:XML in xml.elements()){
				str="t" + getTimeTag(pointer.@ctime);
				tempXml=XML("<" + str + "></" + str + ">")
				tempXml2=<event></event>
				tempXml2.@module=module;
				tempXml2.@x=pointer.@x;
				tempXml2.@y=pointer.@y;
				tempXml2.@cwidth=pointer.@cwidth;
				tempXml2.@cheight=pointer.@cheight;
				tempXml2.@container=pointer.@container;
				if (XMLList(consolidateXml[str]).length() == 0){
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml);
					
				}
				else{
					consolidateXml[str].appendChild(tempXml2);
				}
			}
			
		}
		
		/**
		 * @private
		 * For parsing the whiteborad pointer's recorded data in to consolidateXml
		 * @param xml of XML
		 * @return void
		 */
		private function parsePttXml(xml:XML):void{
			var tempXml:XML;		
			var tempXml2:XML;
			var str:String;
			for each (var ptt:XML in xml.elements()){
				str="t" + getTimeTag(ptt.@ctime);
				tempXml=XML("<" + str + "></" + str + ">")
				tempXml2=<event></event>;
				tempXml2.@module="ptt";
				tempXml2.@state=ptt.@state;
				tempXml2.@isPresenter=ptt.@isPresenter;
				if (XMLList(consolidateXml[str]).length() == 0){
					tempXml.appendChild(tempXml2);
					consolidateXml.appendChild(tempXml);
					
				}
				else{
					consolidateXml[str].appendChild(tempXml2);
				}
			}
			
		}
		
		/**
		 * @public
		 * for collect xml data from consolidateXML at  a particular time
		 * @param time of Number
		 * @parm module of String
		 * @return XML
		 */
		public function getDataAtTime(time:Number, module:String):XML{		
			var str:String="t" + time;
			var xml:XMLList=consolidateXml[str];
			var dataXml:XML=<data></data>;
			for each (var temp:XML in xml.elements()){
				if (temp.@module == module)
					dataXml.appendChild(temp);
			}
			return dataXml;
			
		}
		
		/**
		 * @public
		 * For seting  the chat xml data from consolidateXml at particular time
		 * @param time of Number
		 * @return XML
		 */
		public function setChatContext(time:Number):XML{
			var xml:XML=<chat></chat>;
			var tempArray:Array=new Array(3);
			var i:int;
			for (i=0; i < fileLoaderManager.chatXml.children().length(); i++){
				if (fileLoaderManager.chatXml.msg[i].@ctime > time)
					break;
				xml.prependChild(fileLoaderManager.chatXml.msg[i]);
				
			}
			return xml;
		}
	}
}
