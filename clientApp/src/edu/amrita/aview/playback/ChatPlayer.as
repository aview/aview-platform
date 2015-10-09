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
 * File			: ChatPlayer.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:This class used for handling the chat palyback functionality.
 */

package edu.amrita.aview.playback{
	
	import flashx.textLayout.conversion.TextConverter;
	
	import spark.components.TextArea;
	import edu.amrita.aview.core.entry.Constants;
	
	/**
	 *  You use the ChatPlayer class for handling the chat play back.
	 */
	public class ChatPlayer{
		/**
		 * Consolidate xml data of chat playback
		 */
		private var consolidateXmlbuilder:ConsolidateXmlBuilder=null;
		/**
		 * Text area of chat
		 */
		private var chatbox:TextArea;
		/**
		 * This refers for message
		 */
		public var msg:String="";
		
		/**
		 * @public
		 * For setting the consolidateXmldata for chat playback
		 * @param consolidateXmlBuilder of ConsolidateXmlBuilder
		 * @return void
		 */
		public function setConsolidateXML(consolidateXmlbuilder:ConsolidateXmlBuilder):void{
			this.consolidateXmlbuilder=consolidateXmlbuilder;
		}
		
		/**
		 * @public
		 * Here we are set the User interface reference of this class
		 * @param chatbox of TextArea
		 * @return void
		 */
		public function setUiReference(chatbox:TextArea):void{
			this.chatbox=chatbox;
		}
		
		/**
		 * @public
		 * For handling the chat playback functionality.
		 * @param time of Number
		 * @return void
		 */
		public function playChat(time:Number):void{
			var xml:XML=consolidateXmlbuilder.getDataAtTime(time, "chat");
			
			for each (var evnt:XML in xml.elements()){
				if (evnt.@module == "chat")
					if (evnt.@msg.indexOf(Constants.CHAT_CLEAR_KEY) > 0){
						chatbox.text="";
					}
					else if (evnt.@msg != ""){
						msg+=evnt.@msg;						
						chatbox.textFlow=TextConverter.importToFlow(msg, TextConverter.TEXT_FIELD_HTML_FORMAT);
					}
					else if (evnt.@msg == ""){
						chatbox.setStyle("fontSize", parseFloat(evnt.@textSize));
					}
				
			}
		}
		
		/**
		 * @public
		 * This function will handling the Updation of chat area
		 * @param time of Number
		 * @return void
		 */
		public function updateChat(time:Number):void{
			var xml:XML=consolidateXmlbuilder.setChatContext(time);
			msg="";		
			for (var i:int=xml.children().length() - 1; i > -1; i--){
				if (xml.msg[i].@content.indexOf(Constants.CHAT_CLEAR_KEY) > 0){
					chatbox.text="";
				}
				else{
					msg+=xml.msg[i].@content;
					chatbox.textFlow=TextConverter.importToFlow(msg, TextConverter.TEXT_FIELD_HTML_FORMAT)
				}
				
			}
			if (xml.children().length() > 0)
				chatbox.setStyle("fontSize", parseFloat(xml.msg[0].@textSize));
			
		}
		
	}
}
