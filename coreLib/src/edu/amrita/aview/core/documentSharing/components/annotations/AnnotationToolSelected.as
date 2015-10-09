package edu.amrita.aview.core.documentSharing.components.annotations
{
	import flash.events.Event;
	
	
	public class AnnotationToolSelected extends Event
	{
		private var _toolName:String;
		
		public function get toolName():String{
			return _toolName;
		}
		public function AnnotationToolSelected(toolName:String)	{
			super("onAnnotationToolSelected");
			_toolName=toolName;
		}
		override public function clone():Event{
			return new AnnotationToolSelected(toolName);
		}
	}
}
