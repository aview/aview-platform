package edu.amrita.aview.core.common
{
	import edu.amrita.aview.core.common.Events.FileLoadedEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	applicationType::desktop{
		import flash.filesystem.File;
		import flash.filesystem.FileStream;
	}
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class FileLoader extends EventDispatcher
	{
		//private var fileUrl:String
		applicationType::desktop{
			private  var file:File;
			private var fileStream:FileStream;
		}
		private var urlLoader:URLLoader;
		public function FileLoader()
		{
			//this.fileUrl=fileUrl;
		urlLoader=new URLLoader();
		}
		public function loadFile(fileUrl:String):void
		{
			urlLoader.addEventListener(Event.COMPLETE,onPageLoaderStatus)
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onPageLoaderStatus)
			urlLoader.load(new URLRequest(fileUrl));
		}
		private function onPageLoaderStatus(evnt:Event):void
		{
			var fileLoadedEvent:FileLoadedEvent
			if(evnt.type==Event.COMPLETE)
			{
				var xml:XML=new XML()
				urlLoader.removeEventListener(Event.COMPLETE,onPageLoaderStatus)
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onPageLoaderStatus)
				xml=XML(urlLoader.data); 
				fileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.LOADED)
				fileLoadedEvent.fileData=xml;
				dispatchEvent(fileLoadedEvent);
			}
			else
			{
				fileLoadedEvent=new FileLoadedEvent(FileLoadedEvent.NOT_LOADED)
				dispatchEvent(fileLoadedEvent);
			}
	
		}

	}
}