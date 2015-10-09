package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
//	import mx.controls.TextArea;
	import flash.display.DisplayObjectContainer;
	
	public class LogConsole
	{
		private static var m_instance:LogConsole;
		
//		private var m_log:TextArea;
		
		function LogConsole(singleton:LogSingleton)
		{
		
		}
		
		public static function getInstance():LogConsole
		{
			if (m_instance == null)
			{
				m_instance=new LogConsole(new LogSingleton());
			}
			
			return m_instance;
		}
		
		public function init(container:DisplayObjectContainer, x:int, y:int, w:int, h:int):void
		{
		/*			if (m_log != null)
						return;
		
					m_log = new TextArea();
					m_log.editable = false;
					m_log.x = x;
					m_log.y = y;
					m_log.width = w;
					m_log.height = h;
					container.addChild(m_log);*/
		}
		
		public function show():void
		{
//			m_log.visible = true;
		}
		
		public function hide():void
		{
//			m_log.visible = false;
		}
		
		public function writeLine(msg:String):void
		{
		/*			if (m_log == null)
						return;
		
					m_log.text += msg + "\n";
					m_log.verticalScrollPosition = m_log.maxVerticalScrollPosition;*/
		}
		
		public function printObject(obj:Object, depth:int=0):void
		{
			for (var i:String in obj)
			{
				var spaces:String="";
				for (var k:int=0; k < depth; ++k)
					spaces+="    ";
				var line:String=spaces + i + ": ";
				if (typeof(obj[i]) == "object")
				{
					writeLine(line);
					printObject(obj[i], depth + 1);
				}
				else
				{
					line+=obj[i];
					writeLine(line);
				}
			}
		}
	}
}

class LogSingleton
{

}
