package edu.amrita.aview.core.common.Events
{
	import flash.events.Event;

	public class FileLoadedEvent extends Event
	{
		public static const LOADED:String="file loaded";
		public static const NOT_LOADED:String="file not loaded";
		public static const ALL_LOADED:String="files loaded";
		public static const FILES_NOT_EXISTS:String="files not exists";
		public static const ENDTIME_LOADED:String="endtime loaded";
		public var fileData:XML
		public var duration:Number
		public function FileLoadedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}