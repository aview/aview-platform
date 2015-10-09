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
 * File			: MobileUploadAS.as
 * Module		: FileManager
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Pradeesh
 *
 */

/**
 * Importing DataManager class
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.shared.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.core.shared.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.core.shared.components.fileManager.events.UploadCompletedEvent;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MediaEvent;
import flash.filesystem.File;
import flash.media.CameraRoll;
import flash.media.MediaPromise;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.text.ReturnKeyLabel;
import flash.utils.IDataInput;
import flash.utils.clearTimeout;
import flash.utils.setInterval;

import flashx.textLayout.elements.BreakElement;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;


/**
 * Holds remote root folder path
 */
public var currentParentFolder:String="";
/**
 * Holds server IP
 */
//public var serverIPAddress:String="";
/**
 * Holds module name
 */
//public var usingModule:String="";
/**
 * Holds upload path of 2D
 */
private var uploadPath2D:String;
/**
 * Holds uploading file name
 */
[Bindable]
private var uploadFile:String="";
/**
 * Holds file extention
 */
private var fileExtention:String="";
/**
 * Holds dublicate name of uploading file
 */
private var fileName:String="";
/**
 * Holds uploading file URL
 */
private var uploadUrl:String;
/**
 * Set to true, if file is animated file
 */
private var animated:Boolean=false;
/**
 * CameraRoll object to upload image files
 */
//private var fileReference:CameraRoll;
/**
 * Holds native path of uploading file
 */
public var tempNativepath:String="";
/**
 * Holds promised media data
 */
private var dataSource:IDataInput;
/**
 * Holds uploading image file
 */
private var upLoadImage:File;
/**
 * Check for file existance
 */
private var checkFileExistsCount:Number=0;
/**
 * Check for whether uploding is completed or not
 */
private var isUploadingComplete:Boolean=false;
/**
 * Used for uploading
 */
private var uplodingTimeOut:uint=0;
/**
 *  Used to check whether folder is exist
 */
//private const ERROR:String="Error";

/**
 * @private
 * 
 * Add eventlistener for the events select and complete to file reference(CameraRoll)
 * 
 * @param null
 * @return void
 */
private function initializeUpload():void
{
	serverIPAddress=ClassroomContext.CONTENT_DOCUMENT;
	fileReference=new CameraRoll();
	if (CameraRoll.supportsBrowseForImage)
	{
		fileReference.browseForImage();
		fileReference.addEventListener(ContentOperationEvent.UPLOAD, onUploadInitilize);
		fileReference.addEventListener(Event.CANCEL, cancelHandler);
		fileReference.addEventListener(Event.SELECT, selectHandler);
	}
}
/**
 * @private
 * 
 * To close upload window and remove eventlistener
 * 
 * @param null
 * @return void
 */
private function closeUpload():void
{
	if (fileReference)
	{
		fileReference.removeEventListener(Event.CANCEL, cancelHandler);
		fileReference.removeEventListener(MediaEvent.SELECT, selectHandler);
		fileReference=null;
	}
	this.dispatchEvent(new CloseFileComponentEvent(CloseFileComponentEvent.UPLOAD));
}
/**
 * @private
 * 
 * To start upload file process
 * 
 * @param null
 * @return void
 */
private function startUpload():void
{
	checkFileExistance(currentParentFolder + "/@@-OriginalDocs-@@/" + uploadFile);
}
/**
 * @private
 * 
 * To cancel uploading process
 * 
 * @param event of cancel event
 * @return void
 */
private function cancelHandler(event:Event):void
{
	if (tempNativepath != "")
	{
		upLoadImage.nativePath=tempNativepath;
	}
}
/**
 * @private
 * 
 * To select the file for uploading and checking the constraints
 * 
 * @param event holds the values of selected image file details
 * @return void
 */
private function selectHandler(event:MediaEvent):void
{
	upLoadImage=new File();
	fileExtention=event.data.file.extension;
	isUploadingComplete=false;
	var imagePromise:MediaPromise=event.data;
	dataSource=imagePromise.open();
	//CBMS:uploadFile=MobileFileManager.replaceSpecialChars(event.data.file.name, "File", this);
	fileName=uploadFile;
	tempNativepath=imagePromise.file.nativePath;
	uploadFile=imagePromise.file.name;
	upLoadImage=imagePromise.file;
	startUpload();
}
/**
 * @private
 * 
 *  To complete the file uploading process
 * 
 * @param event of complete event
 * @return void
 */
private function completeHandler(event:Event):void
{
	var dataSource:String;
	//remove the event listener for select and complete events
	fileReference.addEventListener(Event.CANCEL, cancelHandler);
	fileReference.removeEventListener(Event.SELECT, selectHandler);
	fileReference.removeEventListener(Event.COMPLETE, completeHandler);
	isUploadingComplete=true;
	checkFileExistance(currentParentFolder + "/_sfp__" + uploadFile);
}
/**
 * @private
 * 
 *  To check whether file is arleady exist
 * 
 * @param filePath holds the value of remote file path
 * @return void
 */
private function checkFileExistance(filePath:String):void
{
	filePath=filePath.replace("./../../../../", "../../");
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CHECKEXISTANCE)
	this.dispatchEvent(event);
	
}

/**
 * @private
 * 
 *  Result handler for checkFileExistance service to start uplaod process if file is not exist. Otherwise load the files.
 * 
 * @param event holds the value of whether file is exist or not
 * @return void
 */
private function checkFileExistanceResultHandler(event:ResultEvent):void
{
	var result:String=String(event.result);
	if (result.indexOf(ERROR) == -1)
	{
		if (isUploadingComplete)
		{
			if (checkFileExistsCount == 1)
			{
				downloadNotifier();
			}
			else
			{
				uplodingTimeOut=setInterval(updateConversionStatus, 60000, "Not Completed");
			}
		}
		else
		{
			confirmUpload();
		}
	}
	else
	{
		if (isUploadingComplete)
		{
			downloadNotifier();
			clearTimeout(uplodingTimeOut);
		}
		else
		{
			MessageBox.show("Are you sure you want to overwrite this file ?", "WARNING", MessageBox.MB_YESNO, this, confirmOverwrite, null, MessageBox.IC_INFO);
		}
	}
}
/**
 * @private
 * 
 * To load the files
 * 
 * @param null
 * @return void
 */
private function downloadNotifier():void
{
	currentParentFolder=currentParentFolder.replace("../../", "/");
	this.dispatchEvent(new UploadCompletedEvent(uploadFile, fileExtention, currentParentFolder + "/" + uploadFile, animated));
	this.close();
}
/**
 * @private
 * 
 * To upadte the file existance
 * 
 * @param status holds the value of whether file is uploaded or not
 * @return void
 */
private function updateConversionStatus(status:String):void
{
	checkFileExistsCount=checkFileExistsCount + 1;
	if (animated)
	{
		checkFileExistance(currentParentFolder + "/" + uploadFile + ".swf");
	}
	else
	{
		checkFileExistance(currentParentFolder + "/_sfp__" + uploadFile);
	}
	clearTimeout(uplodingTimeOut);
}
/**
 * @private
 * 
 * Confirmation for overwrite the file
 * 
 * @param event holds the value of messagebox type
 * @return void
 */
/*private function confirmOverwrite(event:MessageBoxEvent):void
{
	if (event.type == "messageBoxYES")
	{
		confirmUpload();
	}
}*/

/**
 * @private
 * 
 * To upload a file after the confirmation.
 * 
 * @param null
 * @return void
 */
public function confirmUpload():void
{
	//temperory variable for storing the path of print2flash.php
	if (usingModule == MobileFileManager.MODULE_DOCUMENT_SHARING)
	{
		currentParentFolder=currentParentFolder.replace("./../../../../", "../../");
		uploadUrl=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/Windows/print2flash.php?folderName=" + currentParentFolder + "&module=" + usingModule + "&folder=");
		fileUpload(uploadUrl);
		animated=false;
		upLoadImage.addEventListener(Event.COMPLETE, completeHandler);
	}
}
/**
 * @private
 * 
 * Upload file to remote server
 * 
 * @param uploadUrl holds the value of remote path
 * @return void
 */
private function fileUpload(uploadUrl:String):void
{
	var request:URLRequest=new URLRequest();
	request.url=uploadUrl;
	upLoadImage.upload(request);
}
/**
 * @private
 * 
 * Confirmation for keeping animation
 * 
 * @param event holds the value of message box type
 * @return void
 */
private function confirmAnimationFile(event:MessageBoxEvent):void
{
	var Upload:String;
	if (event.type == "messageBoxYES")
	{

		uploadUrl=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/Windows/ispring.php?folderName=" + currentParentFolder);
		animated=true;
	}
	else
	{
		uploadUrl=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/Windows/print2flash.php?folderName=" + currentParentFolder);
		animated=false;
	}
	fileUpload(uploadUrl);
}

/**
 * @private
 * 
 * Used to handle 2D Viewer supported/unsupported file format and file upload.
 * 
 * @param event holds the value of whether file is suppoerted or nor
 * @return void
 */
/*
private function viewer2dUploadHelper(event:V2DEvent):void
{
	DataManager.viewercom.uploadHelper2D.removeEventListener(V2DEvent.SUPPORTED_FILE, viewer2dUploadHelper)
	if (event.data == "true")
	{
		checkFileExistance(uploadPath2D);
	}
	else
	{
		MessageBox.show("This movie format is not supported in 2D Viewer Please read help(?)", "Unsupported Format", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		closeUpload()
		uploadFile="";
		fileName=uploadFile;
		tempNativepath="";
	}
}*/

/**
 * @private
 * 
 * Fault handler for checkFileExistance service
 * 
 * @param event holds fault message
 * @return void
 */
private function faultHandler(event:FaultEvent):void
{
	//showing error message if folderPath.php is not executed 
	trace(event.fault.toString());
	if (usingModule == MobileFileManager.MODULE_DOCUMENT_SHARING)
	{
		dummyXML=<dirs><files label="Doucument listing is failed  due to network issue.Please Try Again..." type="fault"/></dirs>;
	}
	else if (usingModule == MobileFileManager.MODULE_3D_SHARING)
	{
		dummyXML=<dirs><files label="3D object listing is failed  due to network issue.Please Try Again..." type="fault"/></dirs>;
	}
	treeXmlListDp=dummyXML.children();

}
/**
 * @private
 * 
 * Fault handler for centralRepository HTTPService
 * 
 * @param event holds fault message
 * @return void
 */
private function centralFaultHandler(event:FaultEvent):void
{
	//showing error message if folderPath.php is not executed 
	trace(event.fault.toString());
	if (usingModule == MobileFileManager.MODULE_DOCUMENT_SHARING)
	{
		dummyXML=<dirs><files label="Doucument listing is failed  due to network issue.Please Try Again..." type="fault"/></dirs>;
	}
	else if (usingModule == MobileFileManager.MODULE_3D_SHARING)
	{
		dummyXML=<dirs><files label="3D object listing is failed  due to network issue.Please Try Again..." type="fault"/></dirs>;
	}
	treeXmlListDp=dummyXML.children();

}
