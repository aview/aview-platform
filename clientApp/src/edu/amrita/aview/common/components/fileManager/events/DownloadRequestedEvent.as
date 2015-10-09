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
 * File			: DownloadRequestedEvent.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 *
 */
package edu.amrita.aview.common.components.fileManager.events
{
	import flash.events.Event;
	/**
	 * 	DownloadRequestedEvent is a custom event class for download process.
	 *  This calss is extends from Event class.
	 *  User can dispatch DownloadRequestedEvent after user give the request for download.
	 *  Along with this event we send filename,filepath and downloadtype for each request.
	 */
	public class DownloadRequestedEvent extends Event
	{
		/**
		 * For store the value of File name
		 */		
		private var _remoteFileName:String;
		/**
		 * For store the value of file path
		 */		
		private var _remotePath:String;
		/**
		 * For store the value of download type
		 */		
		private var _downloadType:String;
		
		/**
		 * @public 
		 * Get the value of file name
		 * @return String
		 * 
		 */
		public function get remoteFileName():String
		{
			return _remoteFileName;
		}
		
		/**
		 *@public
		 * get the value of file path
		 * @return String
		 * 
		 */
		public function get remotePath():String
		{
			return _remotePath;
		}
		
		/**
		 * @public
		 * get the value of download type
		 * @return String
		 * 
		 */
		public function get downloadType():String
		{
			return _downloadType;
		}
		
		/**
		 * @public 
		 * Constructor
		 * @param remoteFileName of type String
		 * @param remotePath of type String
		 * @param type of type String
		 * 
		 */
		public function DownloadRequestedEvent(remoteFileName:String, remotePath:String, type:String)
		{
			super("onDownloadRequest");
			_remoteFileName=remoteFileName;
			_remotePath=remotePath;
			_downloadType=type;
		}
		
		/**
		 * @public
		 * 
		 * @return Event
		 * 
		 */
		override public function clone():Event
		{
			return new DownloadRequestedEvent(remoteFileName, remotePath, downloadType);
		}
	
	}
}
