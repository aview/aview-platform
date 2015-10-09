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
 * File			: DownloadStatus.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 *DownloadStatus class to represent an varibles for downloading status 
 */
package edu.amrita.aview.core.shared.components.fileManager.download
{
	/**
	 *  You use the DownloadStatus class to represent an varibles for downloading status .
	 * 
	 */
	  public final class DownloadStatus
	  {
		
		/**
		 *@public 
		 * Constructor 
		 * 
		 */
		public function DownloadStatus()
		{
		}
		/**
		 * This is  the variable for refering the download status is Not started
		 */		
		public static const NOT_STARTED:String="NotStarted";
		/**
		 *  This is  the variable for refering the download status is started
		 */		
		public static const STARTED:String="Started";
		/**
		 *  This is  the variable for refering the download status is Completed
		 */		
		public static const COMPLETED:String="Completed";
	}
}
