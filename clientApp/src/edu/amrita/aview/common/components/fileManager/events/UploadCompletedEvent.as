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
 * File			: UploadCompletedEvent.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 * UploadCompletedEvent is a custom event class for Upload complete process.
 * This calss is extends from Event class.
 *
 */
package edu.amrita.aview.common.components.fileManager.events
{
	import flash.events.Event;
	/**
	 * 	UploadCompletedEvent is a custom event class for Upload complete process.
	 *  This calss is extends from Event class.
	 *  User can dispatch UploadCompletedEvent after uplad complete process.
	 *  Along with this event we send filename ,filePath and extension fro each process. 
     */
	public class UploadCompletedEvent extends Event
	{
		/**
		 * For file name
		 */
		private var _fileName:String;
		/**
		 * For file extension
		 */		
		private var _fileExtension:String;
		/**
		 * For file path
		 */		
		private var _remotePath:String;
		/**
		 * For file type
		 */		
		private var _animated:Boolean;
		
		/**
		 * @public
		 * get the file name
		 * @return String
		 * 
		 */
		public function get fileName():String
		{
			return _fileName;
		}
		
		/**
		 * @public
		 * get the file extension
		 * @return String 
		 * 
		 */
		public function get fileExtension():String
		{
			return _fileExtension;
		}
		
		/**
		 * @public
		 * get the file path
		 * @return String
		 * 
		 */
		public function get remotePath():String
		{
			return _remotePath;
		}
		
		/**
		 * @public
		 * get the file type
		 * @return Boolean
		 * 
		 */
		public function get animated():Boolean
		{
			return _animated;
		}
		
		/**
		 * @public 
		 * Constructor
		 * @param fileName of type String
		 * @param fileExtension of type String
		 * @param remotePath of type String
		 * @param animated of type Boolean
		 * 
		 */
		public function UploadCompletedEvent(fileName:String, fileExtension:String, remotePath:String, animated:Boolean)
		{
			super("onUploadCompleted");
			_fileName=fileName;
			_fileExtension=fileExtension;
			_remotePath=remotePath;
			_animated=animated;
		
		}
		
		/**
		 * @public 
		 * @return Event
		 * 
		 */
		override public function clone():Event
		{
			return new UploadCompletedEvent(fileName, fileExtension, remotePath, animated);
		}
	
	}
}
