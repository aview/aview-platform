////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 * File			: FileLoaderManager.as
 * Module		: common
 * Developer(s)	: Haridas
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
/**
 * VPCR: Add file description */

package edu.amrita.aview.common.components.fileloader
{
	import flash.events.EventDispatcher;
	
	import edu.amrita.aview.common.components.fileloader.events.FileLoadedEvent;
	
	/**
	 * VPCR: Add class description */
	
	
	public class FileLoaderManager extends EventDispatcher
	{
		/**
		 * Global update values
		 */
		
		public static const TOTAL_FILES_TO_LOAD:uint=10;
		public static const WB_FILE_NAME:String="wb.xml";
		public static const WB_POINTER_FILE_NAME:String="wbPointer.xml";
		public static const DOC_FILE_NAME:String="doc.xml";
		public static const DOC_POINTER_FILE_NAME:String="docPointer.xml";
		public static const CHAT_FILE_NAME:String="chat.xml";
		public static const PRESENTER_VIDEO_FILE_NAME:String="pVideo.xml";
		public static const VIEWER_VIDEO_FILE_NAME:String="vVideo.xml";
		public static const PTT_FILE_NAME:String="ptt.xml";
		public static const ENDTIME_FILE_NAME:String="endTime.xml";
		public static const DESKTOP_FILE_NAME:String="desktop.xml";
		
		/**
		 * to store the file load status
		 */
		public var filesLoaded:Boolean;
		/**
		 * file load count
		 */
		private var fileLoadedCount:uint;
		/**
		 * to store the whiteboard information
		 */
		public var wbXml:XML;
		/**
		 * to store the document information
		 */
		public var docXml:XML;
		/**
		 * to store the chat information
		 */
		public var chatXml:XML;
		/**
		 * to store the presenter video information
		 */
		public var pVideoXml:XML;
		/**
		 * to store the viewer video information
		 */
		public var vVideoXml:XML;
		/**
		 * to store the whiteboard pointer information
		 */
		public var wbPointerXml:XML;
		/**
		 * to store the document pointer information
		 */
		public var docPointerXml:XML;
		/**
		 * to store the end time information
		 */
		public var endTimeXml:XML;
		/**
		 * to store the push to talk information
		 */
		public var pttXml:XML;
		/**
		 * to store the desktop information
		 **/
		public var desktopXml:XML;
		/**
		 * to store the chat file information
		 */
		private var chatFileLoader:FileLoader;
		/**
		 * to store the white board file information
		 */
		private var wbFileLoader:FileLoader;
		/**
		 * to store the desktop file information
		 **/
		private var desktopFileLoader:FileLoader;
		/**
		 * to store the document file information
		 */
		private var docFileLoader:FileLoader;
		/**
		 * to store the push to talk file information
		 */
		private var pttFileLoader:FileLoader;
		/**
		 * to store the white board pointer file information
		 */
		private var wbpointerFileLoader:FileLoader;
		/**
		 * to store the document pointer file information
		 */
		private var docPointerFileLoader:FileLoader;
		/**
		 * to store the endtime file information
		 */
		private var endTimeFileLoader:FileLoader;
		/**
		 * to store the presenter video file information
		 */
		private var presenterVideoFileLoader:FileLoader;
		/**
		 * to store the viewer video file information
		 */
		private var viewerVideoFileLoader:FileLoader;
		/**
		 * to store the remote file location
		 */
		private var remoteFileLocation:String;
		
		/**
		 * @public
		 * constructor
		 * @param remoteFileLocation type string
		 */
		public function FileLoaderManager(remoteFileLocation:String)
		{
			this.remoteFileLocation=remoteFileLocation;
			wbFileLoader=new FileLoader();
			pttFileLoader=new FileLoader();
			docFileLoader=new FileLoader();
			chatFileLoader=new FileLoader();
			presenterVideoFileLoader=new FileLoader();
			viewerVideoFileLoader=new FileLoader();
			wbpointerFileLoader=new FileLoader();
			docPointerFileLoader=new FileLoader();
			desktopFileLoader=new FileLoader();
			endTimeFileLoader=new FileLoader();
			desktopFileLoader=new FileLoader();
		}
		
		/**
		 * @public
		 * to load the recorded files from the server
		 * @return void
		 */
		public function loadRecordedFiles():void
		{
			fileLoadedCount=0;
			loadEndtimeXml();
		}
		
		/**
		 * @private
		 * to load the files from the server
		 * @return void
		 */
		private function loadEndtimeXml():void
		{
			loadFilesFromServer(endTimeFileLoader, remoteFileLocation + ENDTIME_FILE_NAME);
		}
		
		/**
		 * @public
		 * to load the files from the server
		 * @param loader type FileLoader
		 * @param fileUrl type string
		 * @return void
		 */
		private function loadFilesFromServer(loader:FileLoader, fileUrl:String):void
		{
			// AKCR: There is duplication in code. Please avoid it. For e.g.
// AKCR:	var eventHandler = (loader == endTimeFileLoader) ?	onEndtimeFileLoaded : onFileLoaded);
// AKCR:	loader.addEventListener(FileLoadedEvent.LOADED,eventHandler) 
// AKCR:	loader.addEventListener(FileLoadedEvent.NOT_LOADED, eventHandler);
// AKCR:	loader.loadFile(fileUrl);

			if (loader == endTimeFileLoader)
			{
				//adding the event listener to the loader variable
				loader.addEventListener(FileLoadedEvent.LOADED, onEndtimeFileLoaded);
				loader.addEventListener(FileLoadedEvent.NOT_LOADED, onEndtimeFileLoaded);
				loader.loadFile(fileUrl);
			}
			else
			{
				//adding the event listener to the loader variable
				loader.addEventListener(FileLoadedEvent.LOADED, onFileLoaded);
				loader.addEventListener(FileLoadedEvent.NOT_LOADED, onFileLoaded);
				loader.loadFile(fileUrl);
			}
		}
		
		/**
		 * @private
		 * @param event type FileLoadedEvent
		 * @return void
		 */
		private function onEndtimeFileLoaded(event:FileLoadedEvent):void
		{
			var fileLoadedEvent:FileLoadedEvent;
			if (event.type == FileLoadedEvent.LOADED)
			{
				endTimeXml=event.fileData;
				fileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.ENDTIME_LOADED)
				dispatchEvent(fileLoadedEvent);
				loadFiles();
			}
			else
			{
				fileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.FILES_NOT_EXISTS)
				dispatchEvent(fileLoadedEvent);
			}
			fileLoadedCount++;
		}
		
		/**
		 * @private
		 * @param event type FileLoadedEvent
		 * @return void
		 */
		private function onFileLoaded(event:FileLoadedEvent):void
		{
			// AKCR: the following function is very repetative
			// AKCR: It can be greatly simplified; for e.g
//AKCR: 		var match = false;
//AKCR:			target -> {
//AKCR:				wbFileLoader             -> {match : true, targetvar : wbXml ,    xmlTag: '<wb></wb>'}
//AKCR:				docFileLoader            -> {match : true, targetvar : docXml ,   xmlTag: '<document></document>'}
//AKCR:				chatFileLoader           -> {match : true, targetvar : chatXml ,  xmlTag: '<chat></chat>'};
//AKCR:				presenterVideoFileLoader -> {match : true, targetvar : pVideoXml ,xmlTag: '<presenter></presenter>'}
//AKCR:				pttFileLoader            -> {match : true, targetvar : pttXml,    xmlTag: '<ptt></ptt>'}
//AKCR:				desktopFileLoader        -> {match : true, targetvar: desktopXml, xmlTag: '<desktop></desktop>'}
//AKCR:				wbpointerFileLoader      -> {match : true, targetvar: wbPointerXml, xmlTag: '<pointer></pointer>'}
//AKCR:				docPointerFileLoader     -> {match : true, targetvar: docPointerXml,xmlTag: '<pointer></pointer>'}
//AKCR:			}
//AKCR:
//AKCR:			if (event.type == FileLoadedEvent.LOADED)
//AKCR:				target[event.currentTarget].targetvar = event.fileData;
//AKCR:			else
//AKCR:				target[event.currentTarget].targetvar = target[event.currentTarget].xmlTag; 
//AKCR:			if (target[event.currentTarget].match == true) fileLoadedCount++;

			//checking for the whiteboard module
			if (event.currentTarget == wbFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					wbXml=event.fileData;
				}
				else
				{
					wbXml=<wb></wb>;
				}
				fileLoadedCount++;
			}
			//checking for the document module
			else if (event.currentTarget == docFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					docXml=event.fileData;
				}
				else
				{
					docXml=<document></document>;
				}
				fileLoadedCount++;
			}
			//checking for the chat module
			else if (event.currentTarget == chatFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					chatXml=event.fileData;
				}
				else
				{
					chatXml=<chat></chat>;
				}
				fileLoadedCount++;
			}
			//checking for the presenter video module
			else if (event.currentTarget == presenterVideoFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					pVideoXml=event.fileData;
					
				}
				else
				{
					pVideoXml=<presenter></presenter>
				}
				
				fileLoadedCount++;
			}
			//checking for the viewer video module
			else if (event.currentTarget == viewerVideoFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					vVideoXml=event.fileData;
					
				}
				else
				{
					vVideoXml=<viewer></viewer>
				}
				fileLoadedCount++;
			}
			else if (event.currentTarget == pttFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					
					pttXml=event.fileData;
					
				}
				else
				{
					pttXml=<ptt></ptt>;
				}
				fileLoadedCount++;
			}
			//checking for the whiteboard pointer
			else if (event.currentTarget == wbpointerFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					wbPointerXml=event.fileData;
					
				}
				else
				{
					wbPointerXml=<pointer></pointer>;
				}
				fileLoadedCount++;
			}
			//checking for the document pointer
			else if (event.currentTarget == docPointerFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					docPointerXml=event.fileData;
					
				}
				else
				{
					docPointerXml=<pointer></pointer>;
				}
				fileLoadedCount++;
			}
			//checking for the desktop module
			else if (event.currentTarget == desktopFileLoader)
			{
				if (event.type == FileLoadedEvent.LOADED)
				{
					desktopXml=event.fileData;
					
				}
				else
				{
					desktopXml=<desktop></desktop>;
				}
				fileLoadedCount++;
			}
			
			checkAllFilesLoaded();
		
		}
		
		/**
		 * @private
		 * loading the file from the server
		 * @return void
		 */
		private function loadFiles():void
		{
			//loading the files from the server for the whiteboard
			loadFilesFromServer(wbFileLoader, remoteFileLocation + WB_FILE_NAME);
			//loading the files from the server for the document
			loadFilesFromServer(docFileLoader, remoteFileLocation + DOC_FILE_NAME);
			//loading the files from the server for the chat
			loadFilesFromServer(chatFileLoader, remoteFileLocation + CHAT_FILE_NAME);
			//loading the files from the server for the push to talk
			loadFilesFromServer(pttFileLoader, remoteFileLocation + PTT_FILE_NAME);
			//loading the files from the server for the viewer video
			loadFilesFromServer(viewerVideoFileLoader, remoteFileLocation + VIEWER_VIDEO_FILE_NAME);
			//loading the files from the server for the presenter video
			loadFilesFromServer(presenterVideoFileLoader, remoteFileLocation + PRESENTER_VIDEO_FILE_NAME);
			//loading the files from the server for the whiteboard pointer
			loadFilesFromServer(wbpointerFileLoader, remoteFileLocation + WB_POINTER_FILE_NAME);
			//loading the files from the server for the document pointer
			loadFilesFromServer(docPointerFileLoader, remoteFileLocation + DOC_POINTER_FILE_NAME);
			//loading the files from the server for the desktop
			loadFilesFromServer(desktopFileLoader, remoteFileLocation + DESKTOP_FILE_NAME);
		}
		
		/**
		 * @private
		 * used to check the files are loaded
		 * @return void
		 */
		private function checkAllFilesLoaded():void
		{
			if (fileLoadedCount == TOTAL_FILES_TO_LOAD)
			{
				var fileLoadedEvent:FileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.ALL_LOADED)
				dispatchEvent(fileLoadedEvent);
			}
		}
	
	
	}
}
