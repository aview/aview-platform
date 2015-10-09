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
 *
 * File			: ChatMessageVO.as
 * Module		: chat
 * Developer(s)	: Soumya M.D, NidhiSarasan
 * Reviewer(s)	:
 *
 *
 */
package edu.amrita.aview.chat.vo
{
	import edu.amrita.aview.common.vo.Auditable;

	import mx.formatters.DateFormatter;
	
	
	[RemoteClass(alias="edu.amrita.aview.chat.entities.ChatMessage")]
	/**
	 * @public
	 *
	 * @return null
	 * 
	 */
	public dynamic class ChatMessageVO extends Auditable
	{
		/**
		 * @public
		 * Default constructor
		 *
		 * @return null
		 *
		 */
		
		private static var dateTimeFormatter:mx.formatters.DateFormatter = new DateFormatter();
		//Static block
		{
			dateTimeFormatter.formatString="DD-MMM-YYYY HH:NN:SS";
		}
		
		private static var timeFormatter:mx.formatters.DateFormatter = new DateFormatter();
		//Static block
		{
			timeFormatter.formatString="HH:NN:SS";
		}
		
		public function ChatMessageVO()
		{
		
		}
		
		public function populateFromObject(obj:Object):void
		{
			super.createdByUserId = obj.createdByUserId;
			this.chatSessionId = obj.chatSessionId;
			this.chatMessageText = obj.chatMessageText;
			this.timestamp = obj.timestamp;
		}
		
		public function getServerObject():Object
		{
			var obj:Object = new Object();
			obj["chatMessageId"] = chatMessageId;
//			obj["chatMessageText"] = chatMessageText;
//			obj["chatMessageDispayText"] = chatMessageDispayText;
			obj["chatSessionId"] = chatSessionId;
			return obj;
		}
		
		public function getMessageObject():Object
		{
			var obj:Object = new Object();
			obj["chatMessageText"] = chatMessageText;
			obj["chatSessionId"] = chatSessionId;
			obj["createdByUserId"]=this.createdByUserId;
			obj["createdDate"]=this.createdDate;
			return obj;
		}
		/**
		 * variable to store the chat message id. 
		 */
		private var _chatMessageId:Number=0;
		/**
		 * variable to store the chat message text. 
		 */
		private var _chatMessageText:String=null;
		/**
		 * variable to store the chat session. 
		 */
		private var _chatSessionId:Number=0;
		
		/**
		 * variable to store the chat message text. 
		 */
		private var _chatMessageDispayText:String=null;
		
		//This value is set by the collaboration server while sending the message to all the users
		private var _timestamp:String = null;
		
		/**
		 * @public
		 * Function to get chatMessageText
		 *
		 * @return String(chatMessageText)
		 */
		public function get chatMessageText():String
		{
			return _chatMessageText;
		}
		
		private function getFormattedDate():String
		{
			//If the collaboration server induced timestamp value is there, use it, otherwise use the created date set by db
			if(timestamp)
			{
				return timestamp;
			}
			else
			{
				return timeFormatter.format(super.createdDate);
			}
		}
		
		public function prepareChatMessageDispayText(ownerId:Number,senderDisplayName:String,isPrivateChat:String):void
		{
			applicationType::DesktopWeb{
				import edu.amrita.aview.core.entry.Constants;
				var fontFace:String = Constants.DEFAULT_CHAT_FONT;
				var fontColour:String = ((ownerId==super.createdByUserId) && isPrivateChat=="N")?Constants.MODERATOR_CHAT_COLOR:Constants.DEFAULT_CHAT_COLOR;
				var fontWeight:String = ((ownerId==super.createdByUserId) && isPrivateChat=="N")?Constants.CHAT_FONT_WEIGHT_BOLD:Constants.DEFAULT_CHAT_FONT_WEIGHT;
				_chatMessageDispayText = "<b><font color = '" + fontColour + "', face = '" + fontFace + "'>" 
					+ senderDisplayName + ":" + getFormattedDate() + "</font></b> " + chatMessageText + "<br>";
			}
			applicationType::mobile{
				_chatMessageDispayText =  senderDisplayName + ":" + getFormattedDate()+ ":"+ chatMessageText + "\n";
			}
		}
		
		public function get chatMessageDispayText()
		{
			return _chatMessageDispayText;
		}
		
		/**
		 * @public
		 * Function to set chat Message Text
		 * @param value of type String
		 * @return void
		 */
		public function set chatMessageText(value:String):void
		{
			_chatMessageText=value;
		}
		/**
		 * @public
		 * Function to get chatMessageid
		 *
		 * @return Number(chatMessageid)
		 */
		public function get chatMessageId():Number
		{
			return _chatMessageId;
		}
		/**
		 * @public
		 * Function to set chat Message Id
		 * @param value of type Number
		 * @return void
		 */
		public function set chatMessageId(value:Number):void
		{
			_chatMessageId=value;
		}
		/**
		 * @public
		 * Function to get chat Session id
		 *
		 * @return Number(chat Session id)
		 */
		public function get chatSessionId():Number
		{
			return _chatSessionId;
		}
		/**
		 * @public
		 * Function to set chat Session id
		 * @param value of type Number
		 * @return void
		 */
		public function set chatSessionId(value:Number):void
		{
			_chatSessionId=value;
		}

		public function get timestamp():String
		{
			return _timestamp;
		}

		public function set timestamp(value:String):void
		{
			_timestamp = value;
		}

	}
}
