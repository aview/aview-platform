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
 *
 * File			: FileLoader.as
 * Module		: common
 * Developer(s)	: Haridas
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 */
/**
 * VPCR: Add file description */
package edu.amrita.aview.common.components.fileloader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import edu.amrita.aview.common.components.fileloader.events.FileLoadedEvent;
	/**
	 * VPCR: Add class description */
	
	public class FileLoader extends EventDispatcher
	{
		/**
		 * The URLLoader class downloads data from a URL as text, binary data, or URL-encoded variables
		 */
		private var urlLoader:URLLoader;
		
		/**Platform specific imports and variables*/
		applicationType::desktop
		{
			import flash.filesystem.File;
			import flash.filesystem.FileStream;
			/**
			 * to store the file details
			 */
			private var file:File;
			/**
			 * to store the file infomations
			 */
			private var fileStream:FileStream;
		}
		
		/**
		 * @public
		 * constructor
		 */
		
		public function FileLoader()
		{
			urlLoader=new URLLoader();
		}
		
		/**
		 * @public
		 * @param fileUrl keeps the file path
		 * @return void
		 */
		public function loadFile(fileUrl:String):void
		{
			//adding the event lister to the urlLoader
			urlLoader.addEventListener(Event.COMPLETE, onPageLoaderStatus)
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onPageLoaderStatus)
			urlLoader.load(new URLRequest(fileUrl));
		}
		
		/**
		 * @private
		 * @param event which are passed as parameters to event listeners when an event occurs.
		 * @return void
		 */
		private function onPageLoaderStatus(event:Event):void
		{
			
			var fileLoadedEvent:FileLoadedEvent
			if (event.type == Event.COMPLETE)
			{
				//creating an xml object
				var xml:XML=new XML()
				//adding the event listner to remove the function from the URLLoader 
				urlLoader.removeEventListener(Event.COMPLETE, onPageLoaderStatus)
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
