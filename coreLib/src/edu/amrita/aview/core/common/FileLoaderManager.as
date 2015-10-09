package edu.amrita.aview.core.common
{
	
	
	import edu.amrita.aview.core.common.Events.FileLoadedEvent;
	
	import flash.events.EventDispatcher;
	
	public class FileLoaderManager extends EventDispatcher
	{
		public static const TOTAL_FILES_TO_LOAD:uint=9
		public static const WB_FILE_NAME:String="wb.xml"
		public static const WB_POINTER_FILE_NAME:String="wbPointer.xml"
		public static const DOC_FILE_NAME:String="doc.xml"
		public static const DOC_POINTER_FILE_NAME:String="docPointer.xml"
		public static const CHAT_FILE_NAME:String="chat.xml"
		public static const PRESENTER_VIDEO_FILE_NAME:String="pVideo.xml"
		public static const VIEWER_VIDEO_FILE_NAME:String="vVideo.xml"
		public static const PTT_FILE_NAME:String="ptt.xml"
		public static const ENDTIME_FILE_NAME:String="endTime.xml"
		/* public var wbXmlIsEmpty:Boolean;
		public var docXmlIsEmpty:Boolean;
		public var presenterVideoXmlIsEmpty:Boolean;
		public var viewerVideoXmlIsEmpty:Boolean;
		public var pttXmlLoaded:Boolean;
		public var wbPointerXmlLoaded:Boolean;
		public var chatXmlLoaded:Boolean;
		public var docPointerXmlLoaded:Boolean; */
		public var filesLoaded:Boolean
		private var fileLoadedCount:uint;
		public var wbXml:XML;
		public var docXml:XML;
		public var chatXml:XML;
		public var pVideoXml:XML;
		public var vVideoXml:XML;
		public var wbPointerXml:XML;
		public var docPointerXml:XML;
		public var endTimeXml:XML;
		public var pttXml:XML;
		private var chatFileLoader:FileLoader
		private var wbFileLoader:FileLoader
		private var docFileLoader:FileLoader
		private var pttFileLoader:FileLoader
		private var wbpointerFileLoader:FileLoader
		private var docPointerFileLoader:FileLoader;
		private var endTimeFileLoader:FileLoader;
		private var presenterVideoFileLoader:FileLoader
		private var viewerVideoFileLoader:FileLoader
		private var remoteFileLocation:String;
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
			endTimeFileLoader=new FileLoader();
		}
		public function loadRecordedFiles():void
		{
			fileLoadedCount=0;
			loadEndtimeXml()
		}
		
		private function loadEndtimeXml():void
		{
			loadFilesFromServer(endTimeFileLoader,remoteFileLocation+ENDTIME_FILE_NAME); 
		}
		private function loadFilesFromServer(loader:FileLoader,fileUrl:String):void
		{
			if(loader==endTimeFileLoader)
			{
				loader.addEventListener(FileLoadedEvent.LOADED,onEndtimeFileLoded);
				loader.addEventListener(FileLoadedEvent.NOT_LOADED,onEndtimeFileLoded);
				loader.loadFile(fileUrl);
			}
			else
			{
				loader.addEventListener(FileLoadedEvent.LOADED,onFileLoded);
				loader.addEventListener(FileLoadedEvent.NOT_LOADED,onFileLoded);
				loader.loadFile(fileUrl);
			}
		}
		private function onEndtimeFileLoded(evnt:FileLoadedEvent):void
		{
			if(evnt.type==FileLoadedEvent.LOADED)
			{
				endTimeXml=evnt.fileData;
				var fileLoadedEvent:FileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.ENDTIME_LOADED)
				dispatchEvent(fileLoadedEvent);
				loadFiles();	 
			}
			else
			{
				var fileLoadedEvent:FileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.FILES_NOT_EXISTS)
				dispatchEvent(fileLoadedEvent);
			}	
			fileLoadedCount++
		}
		private function onFileLoded(evnt:FileLoadedEvent):void
		{
			
			if(evnt.currentTarget==wbFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					wbXml=evnt.fileData;		
				}
				else
				{
					wbXml =<wb></wb>;
				}
				fileLoadedCount++;
			}
			else if(evnt.currentTarget==docFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					docXml=evnt.fileData;
				}
				else
				{
					docXml=<document></document>;
				}
				fileLoadedCount++
			}
			else if(evnt.currentTarget==chatFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					chatXml=evnt.fileData;
				}
				else
				{
					chatXml=<chat></chat>;
				}
				fileLoadedCount++
			}
			else if(evnt.currentTarget==presenterVideoFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					pVideoXml=evnt.fileData;
					
				}
				else
				{
					pVideoXml=<presenter></presenter>
				}
				
				fileLoadedCount++
			}
			else if(evnt.currentTarget==viewerVideoFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					vVideoXml=evnt.fileData;
					
				}
				else
				{
					vVideoXml=<viewer></viewer>
				}
				fileLoadedCount++
			}
			else if(evnt.currentTarget==pttFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					
					pttXml=evnt.fileData;
					
				}	
				else
				{
					pttXml=<ptt></ptt>;
				}
				fileLoadedCount++		
			}
			else if(evnt.currentTarget==wbpointerFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					wbPointerXml=evnt.fileData;
					
				}
				else
				{
					wbPointerXml=<pointer></pointer>;
				}
				fileLoadedCount++				
			}
			else if(evnt.currentTarget==docPointerFileLoader)
			{
				if(evnt.type==FileLoadedEvent.LOADED)
				{
					docPointerXml=evnt.fileData;
					
				}	
				else
				{
					docPointerXml=<pointer></pointer>;;
				}
				fileLoadedCount++
			}
			
			checkAllFilesLoaded()
			
		}
		private function loadFiles():void
		{
			
			loadFilesFromServer(wbFileLoader,remoteFileLocation+WB_FILE_NAME);
				
			loadFilesFromServer(docFileLoader,remoteFileLocation+DOC_FILE_NAME);
				
			loadFilesFromServer(chatFileLoader,remoteFileLocation+CHAT_FILE_NAME);
				
			loadFilesFromServer(pttFileLoader,remoteFileLocation+PTT_FILE_NAME);
				
			loadFilesFromServer(viewerVideoFileLoader,remoteFileLocation+VIEWER_VIDEO_FILE_NAME);
				
			loadFilesFromServer(presenterVideoFileLoader,remoteFileLocation+PRESENTER_VIDEO_FILE_NAME);
				
			loadFilesFromServer(wbpointerFileLoader,remoteFileLocation+WB_POINTER_FILE_NAME);
				
			loadFilesFromServer(docPointerFileLoader,remoteFileLocation+DOC_POINTER_FILE_NAME); 
			
		}
		private function checkAllFilesLoaded():void
		{
			if(fileLoadedCount==TOTAL_FILES_TO_LOAD)
			{
				var fileLoadedEvent:FileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.ALL_LOADED)
				dispatchEvent(fileLoadedEvent);
			}
		}
		

	}
}
