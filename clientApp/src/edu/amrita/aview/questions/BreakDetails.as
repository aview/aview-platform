package edu.amrita.aview.questions
{
	public class BreakDetails
	{
		public function BreakDetails(initFrom:Object = null)
		{
			if(initFrom == null)
			{
				return;
			}
			minutes = initFrom.minutes;
			breakMessage = initFrom.breakMessage;
			enableQuestions = initFrom.enableQuestions;
			breakChatMessage = initFrom.breakChatMessage;
			resumeTime = initFrom.resumeTime;
		}
		
		private var _minutes:int=0;
		private var _breakMessage:String = null;
		private var _disableQuestions:Boolean = false;
		private var _breakChatMessage:String = null;
		private var _resumeTime:Date = null;

		public function get minutes():int
		{
			return _minutes;
		}

		public function set minutes(value:int):void
		{
			_minutes = value;
		}

		public function get breakMessage():String
		{
			return _breakMessage;
		}

		public function set breakMessage(value:String):void
		{
			_breakMessage = value;
		}

		public function get enableQuestions():Boolean
		{
			return _disableQuestions;
		}

		public function set enableQuestions(value:Boolean):void
		{
			_disableQuestions = value;
		}

		public function get breakChatMessage():String
		{
			return _breakChatMessage;
		}

		public function set breakChatMessage(value:String):void
		{
			_breakChatMessage = value;
		}

		public function get resumeTime():Date
		{
			return _resumeTime;
		}

		public function set resumeTime(value:Date):void
		{
			_resumeTime = value;
		}
		
		public function get popupMessage():String{
			return breakMessage+"\nBreak duration: " + minutes + " minute(s)\n";
		}


	}
}