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
 * File			: DeleteZipFromServers.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.core.shared.util
{
	import mx.rpc.http.HTTPService;
	//VGCR:- class Description
	//VGCR:- function Description for all functions
	public class DeleteZipFromServers
	{
		/**
		 * @public 
		 * Constructor
		 */
		public function DeleteZipFromServers()
		{
		}
		
		/**
		 * @public 
		 * @param presenterServer of type String
		 * @param viewerServer of type String
		 * @param desktopServer of type String
		 * @param contentServer of type String
		 * @param comonFolderPath of type String
		 * @param lectureName of type String
		 * 
		 */
		public static function deleteZipFiles(presenterServer:String, viewerServer:String, desktopServer:String, contentServer:String, comonFolderPath:String, lectureName:String):void
		{
			// AKCR: please move all the hard coded strings to constant variable.
			
			var sourceFile:String="/AVContent/Record/" + comonFolderPath + lectureName + ".zip";
			var fileDeleteService:HTTPService=new HTTPService();
			fileDeleteService.url="http://" + contentServer + "/AVScript/Common/deleteFile.php?source=" + sourceFile;
			fileDeleteService.send();
			sourceFile="applications/vod/media/" + comonFolderPath + lectureName + "_allvideos.zip";
			fileDeleteService.url="http://" + viewerServer + "/AVScript/Common/deleteFile.php?source=" + sourceFile;
			fileDeleteService.send();
			
			
			if (presenterServer != viewerServer)
			{
				sourceFile="/applications/vod/media/" + comonFolderPath + lectureName + "_videos.zip";
				fileDeleteService.url="http://" + presenterServer + "/AVScript/Common/deleteFile.php?source=" + sourceFile;
				fileDeleteService.send();
			}
			if (presenterServer != viewerServer && desktopServer != viewerServer)
			{
				sourceFile="/applications/vod/media/" + comonFolderPath + lectureName + "_desktopVideos.zip";
				fileDeleteService.url="http://" + desktopServer + "/AVScript/Common/deleteFile.php?source=" + sourceFile;
				fileDeleteService.send();
			}
		
		
		}
	}
}
