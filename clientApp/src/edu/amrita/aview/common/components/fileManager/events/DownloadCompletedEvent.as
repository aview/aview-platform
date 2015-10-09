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
 * File			: DownloadCompletedEvent.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *	DowloadCompletedEvent is a custom event class for download process.
 *
 */
package edu.amrita.aview.common.components.fileManager.events
{
	import flash.events.Event;
	/**
	 * 	DowloadCompletedEvent is a custom event class for download process.
	 *  This calss is extends from Event class.
	 *  User can dispatch DowloadCompletedEvent after download completion.
	 *  Along with this event we send filename,filepath,page number and local path for each request.
	 */
	public class DownloadCompletedEvent extends Event
	{
		/**
		 * For store the value of file name 
		 */
		private var _fileName:String;
		/**
		 *  For store the value of file extension
		 */		
		private var _fileExtension:String;
		/**
		 *  For store the value of file local path 
		 */		
		private var _localPath:String;
		/**
		 *  For store the value of remote file path 
		 */		
		private var _remotePath:String;
		/**
		 *  For store the value of total number of pages 
		 */		
		private var _totalPages:Number;
		
		/**
		 * @public
		 * Get value of file name 
		 * @return String
		 * 
		 */
		public function get fileName():String
		{
			return _fileName;
		}
		
		/**
		 * @public
		 * Get value of file extension 
		 * @return String
		 * 
		 */
		public function get fileExtension():String
		{
			return _fileExtension;
		}
		
		/**
		 * @public
		 * Get value of local file path 
		 * @return String
		 * 
		 */
		public function get localPath():String
		{
			return _localPath;
		}
		
		/**
		 *@public
		 * Get value of remote file path 
		 * @return String
		 * 
		 */
		public function get remotePath():String
		{
			return _remotePath;
		}
		
		/**
		 * @public
		 * Get value of total number of pages 
		 * @return Number
		 * 
		 */
		public function get totalPages():Number
		{
			return _totalPages;
		}
		
		/**
		 * Constructor
		 * @public 		 
		 * @param fileName of type String
		 * @param fileExtension of type String
		 * @param localPath of type String
		 * @param remotePath of type String
		 * @param totalPages of type Number
		 * 
		 */
		public function DownloadCompletedEvent(fileName:String, fileExtension:String, localPath:String, remotePath:String, totalPages:Number)
		{
			super("onDownloadCompleted");
			_fileName=fileName;
			_fileExtension=fileExtension;
			_localPath=localPath;
			_remotePath=remotePath;
			_totalPages=totalPages;
		}
		
		/**
		 *@public
		 * 
		 * @return Event
		 * 
		 */
		override public function clone():Event
		{
			return new DownloadCompletedEvent(fileName, fileExtension, localPath, remotePath, totalPages);
		}
	
	
	}
}
