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
 * File			: SingleFileUploadAS.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 *
 */
//VGCR:-Function Description for all functions
//VGCR:-Variable Description
//VGCR:-Constant Description 
import edu.amrita.aview.common.components.fileManager.events.UploadCompletedEvent;
import edu.amrita.aview.core.entry.ClassroomContext;

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 * 
 */
[Bindable]
public var uploadFile:String="";
/**
 * 
 */
public var fileFilter:String=null;
/**
 * 
 */
public var fileFilterTitle:String=null;
/**
 * 
 */
public var serverIP:String=ClassroomContext.DATABASE_SERVER;
/**
 * 
 */
public var parentFolder:String="";
/**
 * 
 */

public const defaultFileFilter:String="*.pdf;*.ppt;*.jpg;*.doc;*.docx;*.pptx;*.xlsx;*.bmp;*.gif;*.xls;*.txt";
/**
 * 
 */
public const defaultFileFilterTitle:String="Select a File";
/**
 * 
 */
private var fileExtention:String="";
/**
 * 
 */
private var fileName:String="";
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.components.filemanagement.SingleFileUploadAS");
/**
 * 
 */
private var txtFilter:FileFilter;

/**Platform specific variables*/
applicationType::web
{
	/*File is not available for web. So we changed File to FileReference.*/
	private var fileReference:FileReference;
}
applicationType::desktop
{
	private var fileReference:File;
}

/**
 *@private
 *
 * 
 * 
 */
private function initializeUpload():void
{
	applicationType::web
	{
		//File is not available for web. So we changed File to FileReference
		fileReference=new FileReference();
	}
	applicationType::desktop
	{
		fileReference=new File();
	}
	txtFilter=new FileFilter(((fileFilterTitle != null) ? fileFilterTitle : defaultFileFilterTitle), ((fileFilter != null) ? fileFilter : defaultFileFilter));
	fileReference.browse([txtFilter]);
	fileReference.addEventListener(Event.CANCEL, cancelHandler);
	fileReference.addEventListener(Event.SELECT, selectHandler);
	fileReference.addEventListener(Event.OPEN, openHandler);
	fileReference.addEventListener(Event.COMPLETE, completeHandler);
	fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
}


/**
 * @private 
 * @param event of type Event
 * 
 * 
 */
private function cancelHandler(event:Event):void
{
	if (tempNativepath != "")
	{
		applicationType::desktop
		{
			fileReference.nativePath=tempNativepath;
		}
	}
}
/**
 * function for selecting the file for uploading and checking the constraints
 */
public var tempNativepath:String="";

/**
 * @private 
 * @param event of type Event
 * 
 */
private function selectHandler(event:Event):void
{
	applicationType::web
	{
		// '.type' returns file extension with dot (.) infront of extension (Eg:.jpg)
		fileExtention=event.target.type;
		// '.' is removed from after '*' in following code.
		if (txtFilter.extension.indexOf("*" + fileExtention.toLowerCase()) == -1)
		{
			Alert.show("Selected document " + event.target.name + " is not of a valid file type", "WARNING", 0, this);
			resetFileDetails();
		}
		else
		{
			/**the file name which is selected by user */
			uploadFile=event.target.name;
			fileName=uploadFile;
		}
	}
	applicationType::desktop
	{
		fileExtention=event.target.extension;
		
		if (txtFilter.extension.indexOf("*." + fileExtention.toLowerCase()) == -1)
		{
			Alert.show("Selected document " + event.target.name + " is not of a valid file type", "WARNING", 0, this);
			resetFileDetails();
		}
		else
		{
			/**the file name which is selected by user */
			uploadFile=event.target.name;
			fileName=uploadFile;
			tempNativepath=fileReference.nativePath;
		}
	}
}
//RTCR: Need to change the function name
/**
 * @private 
 *
 * 
 */
private function resetFileDetails():void
{
	uploadFile="";
	fileName=uploadFile;
	tempNativepath="";
}

/**
 * open event handler, it shows the uploading progress message
 */
/**
 * @private 
 * @param event of type Event
 * 
 */
private function openHandler(event:Event):void
{
	this.progressBar.visible=true;
}

/**
 * @private 
 * @param event of type ProgressEvent
 * 
 */
private function progressHandler(event:ProgressEvent):void
{
	this.progressBar.setProgress((event.bytesLoaded / event.bytesTotal) * 100, 100);
}


/**
 *@private 
 * @param event of type Event
 * function for completing the upload file process
 * 
 */
private function completeHandler(event:Event):void
{
	fileReference.removeEventListener(Event.CANCEL, cancelHandler);
	fileReference.removeEventListener(Event.SELECT, selectHandler);
	fileReference.removeEventListener(Event.OPEN, openHandler);
	fileReference.removeEventListener(Event.COMPLETE, completeHandler);
	this.progressBar.setProgress(100, 100); //Setting 100%
	this.progressBar.label="Load completed";
	this.dispatchEvent(new UploadCompletedEvent(uploadFile, fileExtention, parentFolder + "/" + uploadFile, false));
}


/**
 * @private 
 * @param filePath of type String
 * 
 */
private function checkFileExistance(filePath:String):void
{
	this.checkFileExistanceService.url=encodeURI(ClassroomContext.AVIEW_PROTOCOL+"://" + serverIP + "/aview/check_file_existance.jsp?filePath=" + filePath);				
	this.checkFileExistanceService.addEventListener(ResultEvent.RESULT, checkFileExistanceResultHandler);
	this.checkFileExistanceService.addEventListener(FaultEvent.FAULT, faultHandler);
	this.checkFileExistanceService.send();
}

/**
 *@private 
 * @param event of type ResultEvent
 * 
 */
private function checkFileExistanceResultHandler(event:ResultEvent):void
{
	if (event.result.toString().indexOf("true") == 0)
	{
		Alert.show("Are you sure you want to overwrite this file ?", "Warning", Alert.YES | Alert.NO, this, confirmOverwrite, null, Alert.NO);
	}
	else
	{
		confirmUpload();
	}
}

/**
 * 
 * @private
 * fault handler for netService
 * @param event fault event of HTTPService(netService)
 * 
 */
private function faultHandler(event:FaultEvent):void
{
	if (Log.isError()) log.error(event.fault.toString());
	Alert.show("Application Error (Error -" + event.fault.toString() + ")\nPlease contact A-VIEW Administrator.", "ERROR", 0, this);
}


/**
 * @private 
 * @param event of type CloseEvent
 * 
 */
private function confirmOverwrite(event:CloseEvent):void
{
	if (event.detail == Alert.YES)
	{
		confirmUpload();
	}
}

/**
 * @public
 * 
 * 
 */
public function confirmUpload():void
{
	var uploadUrl:String= encodeURI(ClassroomContext.AVIEW_PROTOCOL+"://" + serverIP + "/aview/upload.jsp?folderName=" + parentFolder + "&fileName=" + uploadFile);
	fileUpload(uploadUrl);
	this.upload.enabled=false;
	this.browse.enabled=false;

}

/**
 * @private 
 * @param uploadUrl of type String
 * 
 */
private function fileUpload(uploadUrl:String):void
{
	var request:URLRequest=new URLRequest();
	request.url=uploadUrl;
	fileReference.upload(request);
}


/**
 *@private
 *
 * 
 * 
 */
private function resetUpload():void
{
	uploadFile="";
}

/**
 *@private
 * 
 * 
 */
private function startUpload():void
{
	if (this.uploadFileName.text == "")
	{
		Alert.show("Please choose a document to upload", "INFO", 0, this);
	}
	else if (fileReference.size == 0)
	{
		Alert.show("Your document cannot be uploaded because its size is zero bytes!", "WARNING", 0, this);
	}
	else
		
	{
		checkFileExistance(parentFolder + "/" + uploadFile);
	}
	//--END----------------------------------------------------------------------------
}
