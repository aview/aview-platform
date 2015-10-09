package edu.amrita.aview.core.playback
{
	import edu.amrita.aview.core.entry.Constants;
	
	import flashx.textLayout.conversion.TextConverter;
	
	import spark.components.TextArea;
	
	

	public class ChatPlayer
	{
		private var consolidateXmlbuilder:ConsolidateXmlBuilder = null;
		private var chatbox:TextArea
		public var msg:String="";
		
		public function setConsolidateXML(consolidateXmlbuilder:ConsolidateXmlBuilder):void
		{
			this.consolidateXmlbuilder = consolidateXmlbuilder;
		}
		public function setUiReference(chatbox:TextArea):void
		{
			this.chatbox=chatbox;
		}
		public function ChatPlayer()
		{
		}
		// ActionScript file
		public function playChat(time:Number):void
		{
			var xml:XML=consolidateXmlbuilder.getDataAtTime(time,"chat");
			for each(var evnt:XML in xml.elements())
			{
				if(evnt.@module=="chat")
				if (evnt.@msg.indexOf(Constants.CHAT_CLEAR_KEY) > 0)
				{
					chatbox.text="";
				}
				else if (evnt.@msg != ""){
					msg+=evnt.@msg;					
					chatbox.textFlow=TextConverter.importToFlow(msg, TextConverter.TEXT_FIELD_HTML_FORMAT);
				}
				else if (evnt.@msg == ""){
					chatbox.setStyle("fontSize", parseFloat(evnt.@textSize));
				}
				/*else
				{
					chatbox.text+=evnt.@msg
					chatbox.setStyle("fontSize", parseFloat(evnt.@textSize));
				}*/
					
			}
		}
		
			
		 public function updateChat(time:Number):void
		 {
		   	var xml:XML=consolidateXmlbuilder.setChatContext(time); 
			var msgChat:String;
			msg="";
		    chatbox.text="";
			//for(var i:int=0; i<5 && i< xml.children().length();i++)
		   	for(var i:int=xml.children().length()-1; i>-1;i--)
		   	{
				if (xml.msg[i].@content.indexOf(Constants.CHAT_CLEAR_KEY) > 0)
				{
					chatbox.text="";
				}
				else
				{
					//chatbox.text+=xml.msg[i].@content
					msgChat+=xml.msg[i].@content;
					msg+=xml.msg[i].@content;
					chatbox.textFlow=TextConverter.importToFlow(msg, TextConverter.TEXT_FIELD_HTML_FORMAT);
				}
 
		   	}
			if(xml.children().length()>0)
			chatbox.setStyle("fontSize", parseFloat(xml.msg[0].@textSize));
		   	
		 }

	}
}