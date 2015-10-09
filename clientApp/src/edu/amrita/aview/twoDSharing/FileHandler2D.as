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
 * File			: FileHandler2D.as
 * Module		: 2DViewer
 * Developer(s)	: Manjith CM, Deepu Diwakar,Jayakrishnan R, Haridasan PC
 * Reviewer(s)	: Pradeesh
 *
 * For Listing uploaded 2D files
 * Used for Upload/Download 2D files
 *
 */
import context.ContextManager;

import edu.amrita.aview.common.components.fileManager.FileManager;
import edu.amrita.aview.common.components.fileManager.download.FileDownloader;
import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.common.components.fileManager.events.DownloadRequestedEvent;
import edu.amrita.aview.common.components.fileManager.events.UploadCompletedEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.service.content.ContentService;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;


import flash.events.Event;
import flash.net.FileFilter;

import mx.core.FlexGlobals;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;

/**Platform specific imports*/
applicationType::desktop {
	/*Since there is no File property for web application.*/
	import flash.filesystem.File;
}

public var presenterViewer2D:String;
public var remoteFilePath:String="";

[Bindable]
public var remoteFileName:String;

private var fileManagerForViewer2D:FileManager;
private var serverIPForWamp:String;
private var previousRemoteFilePath:String=null;
private var fileDownloaderObj:FileDownloader=new FileDownloader
private var contentService:ContentService=new ContentService();
private var isFolderSelected:Boolean
private var alert:MessageBox;

// AKCR: can we add a private var _2D__ because it is being used in several place. Something like:
// private var TWO_D = "_2D__"  // and then use the constant across the file

/**
 *
 * @protected
 * This function is invoked when the user clicks on "List my 2D files" of fille manager.
 * It creates a file manager popup on window.
 * Sets all parameters for filemanager.
 * Add all the events required for filemanager.
 *
 *
 * @return void
 *
 **/

protected function listRemoteFiles():void {
	fileManagerForViewer2D=new FileManager();
	fileManagerForViewer2D.rootFolder=presenterViewer2D + "/My 2D Models";
	fileManagerForViewer2D.defaultFolderPath="../../AVContent/Upload/Personal/" + presenterViewer2D + "/My 2D Models";
	fileManagerForViewer2D.userRole=Constants.PRESENTER_ROLE;
	fileManagerForViewer2D.serverIPAddress=ClassroomContext.CONTENT_VIEWER2D;
	fileManagerForViewer2D.usingModule=FileManager.MODULE_2D_SHARING;
	fileDownloaderObj.usingModule=FileManager.MODULE_2D_SHARING;

	//To avoid deletion of currently using file 
	if (ContextManager.movieHistory.length > 0) {
		for each (var list:Object in ContextManager.movieHistory) {
			fileManagerForViewer2D.excludeFilePathDeletion(list.DownloadPath, "You cannot delete a 2D file while it is being used!");
			fileManagerForViewer2D.excludeFolderPathDeletionPrefixOf(list.DownloadPath, "You cannot delete a folder while any of its files is being used!");
		}
	}
	fileManagerForViewer2D.addEventListener("onCloseFileComponentEvent", onCloseViewer2DComponentEvent);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.FILELIST, onFileListHandler);
	fileManagerForViewer2D..addEventListener(ContentOperationEvent.SELECTION, onSelectionHandler);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.DELETE, onDleteHandler);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.DOWLOAD, onDownloadHandler);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.UPLOAD, onUploadHandler);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.CHECKEXISTANCE, onCheckFileExistanceHandler);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.CREATFOLDER, onCreateFolderHandler);
	fileManagerForViewer2D.addEventListener(ContentOperationEvent.PREINITILIZEUPLOAD, onPreinitilizeUpload);

	PopUpManager.addPopUp(fileManagerForViewer2D, ContextManager.viewer2DComp, true, PopUpManagerChildList.POPUP);
	//Fix for issue #8032,#11469 - Changed the below logic 
	applicationType::desktop {
		fileManagerForViewer2D.x=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.x + (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.width / 2) - (fileManagerForViewer2D.personalArea.width / 2);
		fileManagerForViewer2D.y=(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.y + 150) + (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.height / 2) - (fileManagerForViewer2D.height / 2);
	}
	applicationType::web {
		fileManagerForViewer2D.move((FlexGlobals.topLevelApplication.width - fileManagerForViewer2D.personalArea.width) / 2, (FlexGlobals.topLevelApplication.height - fileManagerForViewer2D.personalArea.height) / 2);
	}
	fileManagerForViewer2D.isPopUp=false;
}

/**
 *
 * @private
 * Invoked when FILELIST event occur
 * Listing the 2d files from server
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/

private function onFileListHandler(event:ContentOperationEvent):void {
	contentService.getFileList(event.rootFolder, fileListResultHandler, fileListfaultHandler);
}

/**
 *
 * @private
 * Result handler function for onFileListHandler
 * Invoked from onFileListHandler function
 *
 * @param obj of type Object
 * @return void
 *
 */
private function fileListResultHandler(obj:Object):void {
	fileManagerForViewer2D.setFileList(obj.result);
}

/**
 *
 * @private
 * Fault handler function for onFileListHandler
 * Invoked from onFileListHandler function
 *
 * @param obj of type Object
 * @return void
 *
 **/
private function fileListfaultHandler(obj:Object):void {
	fileManagerForViewer2D.showErrorInFileList();
}

/**
 *
 * @private
 * Invoked when user select a file or folder from filemanger
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/
private function onSelectionHandler(event:ContentOperationEvent):void 
{
	var xml:XML=XML(event.selectedItem);
	var tag:String=xml.name();

	fileManagerForViewer2D.setDownloadDiscBtn(false);
	fileManagerForViewer2D.setCreateBtn(false);
	fileManagerForViewer2D.setDeleteBtn(false);
	fileManagerForViewer2D.setDownloadBtn(false);
	fileManagerForViewer2D.setUploadBtn(false);
	if (xml.@type == "initial" || tag == null || xml.@type == "fault") {
		return;
	}
	if ((xml.@label == "-No documents-") && String(xml.@path) == "") {
		alert=MessageBox.show("There is no 2D objects in this folder.", "Info", MessageBox.MB_OK, fileManagerForViewer2D, null, null, MessageBox.IC_INFO)
		//Path of the selected remote file
		remoteFilePath="";
		//name of the selected remote file/folder 
		remoteFileName="";
		isFolderSelected=false;
	} else if (tag) {
		// AKCR: there is duplication of fileManagerFor.... please change it to something like the following:
		// AKCR: boolAction = (tag != "root") ? true : false
		// AKCR: fileManagerForViewer2D.setDeleteBtn(boolAction);
		if (tag != "root") {
			fileManagerForViewer2D.setDeleteBtn(true);
		} else {
			fileManagerForViewer2D.setDeleteBtn(false);
		}

		remoteFilePath=xml.@path;
		remoteFileName=xml.@label;
		// AKCR: please use the conditional operator for single if-else cases
		if (tag == fileManagerForViewer2D.xmlFolder || tag == "root") {
			isFolderSelected=true;
		} else {
			isFolderSelected=false;
		}
	}
	// AKCR: can we re-use the isFolderSelected variable? for e.g:
	// AKCR: 		
//	fileManagerForViewer2D.setUploadBtn(isFolderSelected);
//	fileManagerForViewer2D.setCreateBtn(isFolderSelected);
//	private var isDownloadBtn = (!isFolderSelected && (xml.@label != "-No documents-")) ? true : false
//	fileManagerForViewer2D.setDownloadBtn(isDownloadBtn);
	
	if (isFolderSelected) {
		fileManagerForViewer2D.setDownloadBtn(false);
		fileManagerForViewer2D.setUploadBtn(true);
		fileManagerForViewer2D.setCreateBtn(true);
	} else {
		fileManagerForViewer2D.setUploadBtn(false);
		fileManagerForViewer2D.setCreateBtn(false);

		if (xml.@label != "-No documents-") {
			fileManagerForViewer2D.setDownloadBtn(true);
		}
	}
	if (remoteFilePath.indexOf("../../AVContent/Upload/Common") != -1) {
		// AKCR: please use conditional operator to avoid duplication of "fileManagerForViewer2D.setDownloadBtn"
		// AKCR: var isDnldBtn = (tag != "root" && !isFolderSelected) ? true : false
		// AKCR: fileManagerForViewer2D.setDownloadBtn(isDnldBtn)
		if (tag != "root" && !isFolderSelected) {
			fileManagerForViewer2D.setDownloadBtn(true);
		} else {
			fileManagerForViewer2D.setDownloadBtn(false);
		}
		fileManagerForViewer2D.setUploadBtn(false);
		fileManagerForViewer2D.setCreateBtn(false);
		fileManagerForViewer2D.setDeleteBtn(false);
	}
}

/**
 *
 * @private
 * Invoked when user delete a 2D file from server
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/
// AKCR : spelling of delete
private function onDleteHandler(event:ContentOperationEvent):void {
	if (remoteFileName == "") {
		alert=MessageBox.show("No file selected for deletion", "INFO", MessageBox.MB_OK, fileManagerForViewer2D, null, null, MessageBox.IC_INFO);
		return;
	}
	// AKCR: please comment why 4 dir-up is replaced by2 dir-up
	remoteFilePath=remoteFilePath.replace("./../../../../", "../../");
	var exclusionMsg:String=fileManagerForViewer2D.checkExclusionMessage(remoteFilePath, remoteFileName, isFolderSelected);
	if (exclusionMsg != "") {
		alert=MessageBox.show(exclusionMsg, "INFO", MessageBox.MB_OK, fileManagerForViewer2D, null, null, MessageBox.IC_INFO);
	} else {
		
		if(fileManagerForViewer2D.downloadBtn.enabled==true)
		alert=MessageBox.show("Do You want to Delete This file", "Confirm File Deletion", MessageBox.MB_YESNO, fileManagerForViewer2D, deleteConfirmation, null, MessageBox.IC_DELETE);
		else
		alert=MessageBox.show("Do You want to Delete This folder and all its contents", "Confirm File Deletion", MessageBox.MB_YESNO, fileManagerForViewer2D, deleteConfirmation, null, MessageBox.IC_DELETE);
	}
}

/**
 *
 * @private
 * Function used for confirming swf deletion
 *
 * @param event of type MessageBoxEvent
 * @return void
 *
 **/
private function deleteConfirmation(event:MessageBoxEvent):void {
	if (event.type == "messageBoxYES") {
		contentService.deleteFile(remoteFilePath, successfullDeletion, deletionFaultHandler);
	}
}

/**
 *
 * @private
 * Invoked after user deleted swf from server
 *
 * @param event of type Object
 * @return void
 *
 **/
private function successfullDeletion(event:Object):void {
	fileManagerForViewer2D.loadFileList();
}

/**
 *
 * @private
 * Fault handler function
 * Invoked when an error occur in swf delection
 *
 * @param obj of type Object
 * @return void
 *
 **/
private function deletionFaultHandler(obj:Object):void {

}

/**
 *
 * @private
 * Invoked from "Upload" button click to filter the files for uploading
 *
 * @param event of typeContentOpertaionEvent
 * @return void
 *
 **/
private function onUploadHandler(event:ContentOperationEvent):void 
{
	remoteFileName=event.fileReference.name
	// AKCR: please replace /_2d___ with some constant that is already defined as a private var. Please do not use hard-coded strings
	var folderPath:String=remoteFilePath + "/_2d___" + remoteFileName;
	contentService.uploadFile(folderPath, event.fileReference, uploadComplete, onFault);
}

/**
 *
 * @private
 * Invoked when upload complete event occur
 *
 * @param event of type Event
 * @return void
 *
 **/
private function uploadComplete(event:Event):void 
{
	fileManagerForViewer2D.successUpload();
	onUploadComplete(remoteFileName);
}

/**
 *
 * @private
 * Invoked when an eror occur at the time of uploading
 *
 * @param event of type Event
 * @return void
 *
 **/
private function onFault(event:Event):void {

}

/**
 *
 * @private
 * Invoked when user upload swf to server
 * Checking the swf is already uploaded or not
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/
private function onCheckFileExistanceHandler(event:ContentOperationEvent):void {
	var folderPath:String=remoteFilePath + "/_2d___" + remoteFileName;
	contentService.checkFileExistance(folderPath, checkFileExistanceResultHandler, onFault)
}

/**
 *
 * @private
 * Result handler function.
 * Invoked from "onCheckFileExistanceHandler" function.
 *
 * @param fileExtData of type Object
 * @return void
 *
 */
private function checkFileExistanceResultHandler(fileExtData:Object):void {
	fileManagerForViewer2D.fileExistanceMessage(fileExtData.result);
}

/**
 *
 * @private
 * Invoked when user click on create new folder button
 * Creating the new folder in server.
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/
private function onCreateFolderHandler(event:ContentOperationEvent):void {
	// AKCR: please use a string instead of "/". This code is not portable
	// AKCR: For eg: DELIMITER = "/" //on linux 
	// AKCR: DELIMITER = "\" //on windows etc
	// AKCR: kFor different OS, there will be different types of delimiters
	var folderPath:String=remoteFilePath + "/" + event.folderName;
	contentService.createFolder(folderPath, succesFolderCreation, onFault);
}

/**
 *
 * @private
 * Invoked from "onCreateFolderHandler" function
 *
 * @param msg of type Object
 * @return void
 *
 */
private function succesFolderCreation(msg:Object):void {
	fileManagerForViewer2D.successNewFolder();
}

/**
 *
 * @private
 * Invoked after swf uploading complete
 * Request for swf downloading.
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/
private function onDownloadHandler(event:ContentOperationEvent):void 
{

	/*closeFileList();
	loadFileToCache(getDownloadableRemotePath(remoteFilePath));*/
	
	
	remoteFilePath=getDownloadableRemotePath(remoteFilePath);
	
	// To update history of currently running movie.	
	ContextManager.loadedMovieList.updateHistory();
	
	newMovieName=remoteFilePath.substring(remoteFilePath.lastIndexOf("/") + 1);
	newMovieName=newMovieName.slice(6);
	newDownloadPath=remoteFilePath;
	
	// To remove history if the file previously loaded.
	//file should be new if loading from file library .	
	ContextManager.loadedMovieList.removeHistory(newMovieName);
	
	//To create entry of newly loading movie.
	ContextManager.loadedMovieList.createHistory(newMovieName, newDownloadPath);
	
	ContextManager.viewer2DComp.downloadNewFile(remoteFilePath);
	closeFileList();
// CRASH: merge
//	loadFileToCache(getDownloadableRemotePath(remoteFilePath));
}

/**
 *
 * @private
 * Invoked when user open upload window
 * Filter the 2d files for uploading
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 **/
private function onPreinitilizeUpload(event:ContentOperationEvent):void {
	var fileFileter:FileFilter=new FileFilter("2D Video(.swf)", "*.swf");
	fileManagerForViewer2D.setUploadData(fileFileter);
}

/**
 *
 * @public
 * Invoked when user request to download swf
 * Get the local path for downloading
 *
 * @param remotePath of type String.
 * @return String.
 *
 **/
public function getDownloadableRemotePath(remotePath:String):String {
	var downloadable:String="";
	// AKCR: please move this hard-coded folder name to a variable
	var contentRoot:String="/AVContent/";
	var idx:Number=remotePath.indexOf(contentRoot, 0);
	if (idx != -1) {
		downloadable=remotePath.substring(idx);
	}
	return downloadable;
}

/**
 *
 * @private
 * This event handler will execute when the  file upload completed
 * It removes the filemanager.
 * It will send request to download file with remotefilepath .
 *
 * @param uploadCompletedEvent of type UploadCompletedEvent.
 * @return void.
 *
 **/
private function onUploadComplete(remoteFilename:String,uploadCompletedEvent:Object=null):void 
{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) 
	{
		PopUpManager.removePopUp(fileManagerForViewer2D);
		//remoteFilePath=remoteFilename;
		remoteFilePath==remoteFilePath+ "/_2d___"+remoteFilename;
		downloadReq2D(remoteFilePath,remoteFilename);
	}
}

/**
 *
 * @private
 * This function will create file from remotefilepath
 * It will append extra character with file to uniqually identify 2D.
 * Then it will dispatch downloadrequest event
 *
 * @param remote2Dfile of type String.
 * @return void.
 *
 **/
private function downloadReq2D(remote2Dfile:String,remoteFilename:String):void 
{
	remote2Dfile=remote2Dfile.replace("../../","/");
	//If filemanager is missing then it create instanc and close the popup
	if (!fileManagerForViewer2D) 
	{
		listRemoteFiles();
		closeFileList();
	}
	//Since there is no File property for web application.
	applicationType::desktop 
	{
		var locfile:File=new File(remote2Dfile);
		var moviename:String=locfile.name;
	}
	/*Following lines of code is added to get the 2D file name from the remote2Dfile.
	slice will divide the remote path and last part will give the file name*/
	//applicationType::web 
	//{
		//var moviename:String=remote2Dfile.slice(remoteFilePath.lastIndexOf("/") + 1);
	//}
	//if (remote2Dfile.search("_2d___") == -1)
	//{
		//remote2Dfile=appendRemoteName(remote2Dfile);
	//}
	remote2Dfile=remote2Dfile+ "/_2d___"+remoteFilename;
	//fileManagerForViewer2D.dispatchEvent(new DownloadRequestedEvent(remoteFilename,remote2Dfile,"ToAview"));
	//loadFileToCache(remote2Dfile);
	onDownload2D(remote2Dfile);
}


public function onDownload2D(remoteFilePath:String):void 
{

	//	remoteFilePath=getDownloadableRemotePath(remoteFilePath);
		
		// To update history of currently running movie.	
		ContextManager.loadedMovieList.updateHistory();
		
		newMovieName=remoteFilePath.substring(remoteFilePath.lastIndexOf("/") + 1);
		newMovieName=newMovieName.slice(6);
		newDownloadPath=remoteFilePath;
		
		// To remove history if the file previously loaded.
		//file should be new if loading from file library .	
		ContextManager.loadedMovieList.removeHistory(newMovieName);
		
		//To create entry of newly loading movie.
		ContextManager.loadedMovieList.createHistory(newMovieName, newDownloadPath);
		
		ContextManager.viewer2DComp.downloadNewFile(remoteFilePath);
		closeFileList();

}

/**
 *
 * @private
 * This will listen for downloadrequestevent
 * It will update the history of the running movie.
 * It will remove the histoy of the new movie if exists(movie
 * should be fresh if loading from "List my 2D files" ).
 * It will make entry  to histoy of new movie
 * Then set downloadNewFile property to download movie in all the clients.
 *
 * @param downloadRequestedEvent of type downloadRequestedEvent.
 * @return void.
 *
 **/
private function onDownloadRequest(downloadRequestedEvent:DownloadRequestedEvent):void 
{
	remoteFilePath=downloadRequestedEvent.remotePath;

	// To update history of currently running movie.	
	ContextManager.loadedMovieList.updateHistory();

	newMovieName=remoteFilePath.substring(remoteFilePath.lastIndexOf("/") + 1);
	newMovieName=newMovieName.slice(6);
	newDownloadPath=remoteFilePath;

	// To remove history if the file previously loaded.
	//file should be new if loading from file library .	
	ContextManager.loadedMovieList.removeHistory(newMovieName);

	//To create entry of newly loading movie.
	ContextManager.loadedMovieList.createHistory(newMovieName, newDownloadPath);

	ContextManager.viewer2DComp.downloadNewFile(remoteFilePath);
	closeFileList();
}

/**
 *
 * @private
 * This is used to apped special character with the file name
 * to identify 2D uniqually.
 *
 * @param actpath of type String.
 * @return String.
 *
 **/
private function appendRemoteName(actpath:String):String {
	var slashLeng:int=actpath.lastIndexOf("/") + 1;
	var newFilePath:String=actpath.substr(0, slashLeng) + "_2d___" + actpath.substr(slashLeng, actpath.length);
	return newFilePath;
}

/**
 *
 * @private
 * Function for closing the file panel when user clicks on the close button in the file list panel or
 * user download a 2D file from remote server.
 *
 *
 * @return void.
 *
 **/
private function closeFileList():void {
	onCloseViewer2DComponentEvent();
}

/**
 *
 * @pulic
 * This will used by all the clients to download file from remote server.
 * Here we create a filedownloadobject with necessary details and download.
 *
 * @param filePath of type String.
 * @return void.
 *
 **/
public function loadFileToCache(filePath:String):void 
{
	if (ContextManager.userrole != Constants.PRESENTER_ROLE) 
	{
		fileDownloaderObj.usingModule=FileManager.MODULE_2D_SHARING;
	}
	previousRemoteFilePath=filePath;
	serverIPForWamp=ClassroomContext.CONTENT_VIEWER2D;
	// AKCR: please move the hard-coded string to a variable for e.g:
	// AKCR: downloadScript = "/AVScript/Upload/DownloadFilelist.php?directory="
	fileDownloaderObj.download("http://" + serverIPForWamp + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/DownloadFilelist.php?directory=" + filePath);
}

/**
 *
 * @public
 * It will remove all pop up windows from the application
 *
 * @param event of type CloseFileComponentEvent as null.
 * @return void.
 *
 **/
public function onCloseViewer2DComponentEvent(event:CloseFileComponentEvent=null):void {
	var childList:IChildList;
	if (!isPopOut) {
		childList=FlexGlobals.topLevelApplication.systemManager.popUpChildren;
	} else {
		childList=ContextManager.viewer2DWin.systemManager.popUpChildren;
	}
	for (var i:int=childList.numChildren - 1; i > 0; i--) {
		var child:IFlexDisplayObject=childList.getChildAt(i) as IFlexDisplayObject;
		PopUpManager.removePopUp(child)
	}
}
