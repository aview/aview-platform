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
 * File			: DownloadFile.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *DownloadStatus class for to store the file details
 *
 */
package edu.amrita.aview.core.shared.components.fileManager.download
{
	import flash.net.URLLoader;
	
	/**
	 * You use the DownloadStatus class for to store the file details .
	 */
	public class DownloadFile
	{
		
		/**
		 * File name of download file
		 */
		public var fileName:String;
		/**
		 * Page number
		 */		
		public var pageNum:int;
		/**
		 * Download status of files
		 */		
		public var downlodStatus:String;
		/**
		 * Object of URLLoader class
		 */		
		public var urlLoader:URLLoader;	
		
		/**
		 *@public
		 *Constructor
		 * 
		 */
		public function DownloadFile()
		{
		}
	}

}
