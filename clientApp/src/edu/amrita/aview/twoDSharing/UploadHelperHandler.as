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
 * File			: UploadHelperHandler.as
 * Module		: 2DViewer
 * Developer(s)	: Manjith CM, Deepu Diwakar,Jayakrishnan R
 * Reviewer(s)	: Pradeesh
 *
 * UploadHelperHandler file used to check the swf is supported or not before uploading to server.
 *
 */
import edu.amrita.aview.twoDSharing.V2DEvent;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.system.Capabilities;

/**
 * Variable used to convert SWF to movie clip.
 */
private var movieClip:MovieClip;
/**
 * String variable used to store supported files
 */
private var supportedFile:String;
/**
 * String variable used to store delete path
 */
private var deletePath:String


/**Platform specific variables*/
/* There is no 'File' property for web application.*/
applicationType::desktop {
	private var deleteFile:File;
}

/**
 *
 * @protected
 * This  event is executed when the swf loading completed.
 * Convert to movieclip and check if supported.
 *
 * MovieClip constraint
 *
 * We can use both  graphic symbol and movie clip symbol to create  animation.
 * But only movie clips instances can be uniquely identified using ActionScript.
 * We cannot identify graphic symbol in the swf using Action Script 3.0.
 * So the interaction is only possible with movie clip symbol.

 * Version constarin
 *
 * http://livedocs.adobe.com/flex/3/html/help.html?content=Working_with_MovieClips_7.html
 * Considerations for loading an older SWF file
 * If the external SWF file has been published with an older version of ActionScript,
 * there are important limitations to consider.
 * Unlike an ActionScript 3.0 SWF file that runs in AVM2 (ActionScript Virtual Machine 2),
 * a SWF file published for ActionScript 1.0 or 2.0 runs
 * in AVM1 (ActionScript Virtual Machine 1).
 * When an AVM1 SWF file is successfully loaded,
 * the loaded object (the Loader.content property) will be an AVM1Movie object.
 * An AVM1Movie instance is not the same as a MovieClip instance. It is a display object,
 * but unlike a movie clip, it does not include timeline-related methods or properties.
 * The parent AVM2 SWF file will not have access to the properties, methods,
 * or objects of the loaded AVM1Movie object.
 *
 * Multiple moviclips constarin
 *
 * If the swf have multiple movie clips, it is not able to control the movie playing.
 * But We consider the a parent movieclip with 1 frame and single child movieclip.
 * Considering this case we have all the  frames in child
 * so we can control the movie
 *
 * @param event of type Event
 * @return void
 *
 ***/
// AKCR: there is deep nesting of "if" statements. Please reconsider to re-write this function
// AKCR: for e.g: you can formulate all the conditons in 1 if statement that result in "movieFormatError()" and then in the 
// AKCR: else part, you can write the movie-processing code.
// AKCR: IMPORTANT: Please test the code thoroughly :) after refactoring
protected function swCompleteHandler(event:Event):void {
	//Genuine swf or not(from flash Professional )
	if (this.swfLoad.content.loaderInfo.contentType == "application/x-shockwave-flash") {
		//Check version 
		if (this.swfLoad.content.loaderInfo.actionScriptVersion == 3) {
			movieClip=this.swfLoad.movieClip;

			//Multiple movie clips or not
			if (movieClip.totalFrames <= 1 && movieClip.numChildren > 1) {
				movieFormatError();
			} else {
				//Considering this case we have all the  frames in child 
				//so we can control the movie
				if (movieClip.totalFrames == 1 && movieClip.numChildren == 1) {
					movieClip=movieClip.getChildAt(0) as MovieClip;
				}

				if (movieClip) {
					//If atlease have 1 second length to play,the file can upload
					if (movieClip.totalFrames >= 24) {
						this.swfLoad.unloadAndStop();
						//Following code used to delete the local cache directory. Since there is no local cache in web application.
						applicationType::desktop {
							deleteFile.deleteDirectoryAsync(true);
						}
						supportedFile="true";
						this.dispatchEvent(new V2DEvent(V2DEvent.SUPPORTED_FILE, false, false, supportedFile));
					} else {
						movieFormatError();
					}
				}
				//else for if (movieClip.totalFrames >= 24)
				else {
					movieFormatError();
				}
			}
		}
		// else for if(swfLoad.content.loaderInfo.actionScriptVersion==3)
		else {
			movieFormatError();
		}
	}
	// else for if(swfLoad.content.loaderInfo.contentType=="application/x-shockwave-flash")
	else {
		movieFormatError();
	}
}

/**
 *
 * @protected
 * File will deleted from local and unload from the loader.
 * Dispatch unsupported event
 *
 * @return void.
 *
 **/
protected function movieFormatError():void {
	this.swfLoad.unloadAndStop();
	//Following code used to delete the local cache directory. Since there is no local cache in web application.
	applicationType::desktop {
		deleteFile.deleteDirectoryAsync(true);
	}
	supportedFile="false";
	this.dispatchEvent(new V2DEvent(V2DEvent.SUPPORTED_FILE, false, false, supportedFile));
}

/**
 *
 * @protected
 * If IO error occures file will deleted from local and unload from the loader.
 * Dispatch unsupported event
 *
 * @param event of type IOErrorEvent.
 * @return void.
 *
 **/
protected function swfLoad_ioErrorHandler(event:IOErrorEvent):void {
	this.swfLoad.unloadAndStop();
	//Following code used to delete the local cache directory. Since there is no local cache in web application.
	applicationType::desktop {
		deleteFile.deleteDirectoryAsync(true);
	}
	supportedFile="false";
	this.dispatchEvent(new V2DEvent(V2DEvent.SUPPORTED_FILE, false, false, supportedFile));
}

/**
 *
 * @public
 * Files are copied to local directory because we canot load file from network drive
 * Called from the upload before uploading
 * Load file to check supported or not.
 *
 * @param path of type String.
 * @return void.
 *
 **/
public function checkFile(path:String):void {
	this.swfLoad.unloadAndStop();
	//Following code used to delete the 2D File from local cache . Since there is no local cache in web application.
	applicationType::desktop {
		// AKCR: please move the hard coded string to a variable. The variable should be declared along with all static variables
		deletePath=File.applicationStorageDirectory.nativePath + "/AVContent/My 2D Temp";
		deleteFile=File.applicationStorageDirectory.resolvePath(deletePath);
	}
	if (Capabilities.os.toLowerCase().indexOf("mac") > -1) {
		// AKCR: please use a variable for the file access protocol, i.e var FILE_ACCESS_PROTOCOL = "file:///".
		path="file:///" + path;
	}
	this.swfLoad.load(path);
}
