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
 * File	    	: VideoUpload.as
 * Module		: videoSharing
 * Developer(s) : LIVIN M.MIRANDA,SOUMYA M.D,Haridasan P.C
 * Reviewer(s)	: Sivaram SK, Meena S
 * 
 * This file includes the file management functions for video sharing module
 * The functions for invoking fileManager and ContentService methods and 
 * the corresponding event handlers
 * are defined in this.
 * */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.fileManager.ExcludedFileOperation;
import edu.amrita.aview.core.shared.components.fileManager.FileManager;
import edu.amrita.aview.core.shared.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.core.shared.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.service.content.ContentService;

import flash.events.Event;
import flash.net.FileFilter;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;


/**
 * Complete path, includes folder path and file name
 */
private var remoteFilePath:String="";
/**
 * File name of selected file
 */
private var remoteFileName:String="";
/**
 * The filepath where the video file is uploaded 
 */
private var uploadPath:String="";

/**
 * handling file operations for videos
 * The file operations in this module: 
 * file upload, file download,list files,create folder and check existence of agiven file
 */
private var contentService:ContentService=null;


/**
 * holds the root folder name in file manager control
 */
private static const MY_VIDEOS:String="My Videos";

/**
 * set to true when a folder is selected from file manager 
 */
private  var isFolderSelected:Boolean


/**
 * displays warning messages for file selection and deletion
 */
private var alert:MessageBox;

/**
 * The filemanager popup that displays th list of video files
 */
private var fileManager:FileManager;


/**
 * @private
 * displays the file list to be downloaded
 *
 * @return void
 */
private function showFileList():void
{
	if (fileManager)
	{
		return;
	}
	contentService=new ContentService("http",ClassroomContext.DESKTOP_SHARING_SERVER);
	//if block handles the case when presenter switches and when he comes back the current 
	//remotepath has changed but has not been set so to clear that, it is set to null.
	if ((videoURL.indexOf(remoteFilePath)) == -1)
	{
		remoteFilePath="";
	}
	//PNCR: added just for testing. will remove.
	fileManager=new FileManager();
	//sets fileManager properties
	fileManager.exclusions=new ExcludedFileOperation();
	fileManager.usingModule=FileManager.MODULE_VIDEO_SHARING;
	fileManager.addEventListener(ContentOperationEvent.FILELIST,onListFiles);
	fileManager.rootFolder=ClassroomContext.currentPresenterName+"/My Videos";
	fileManager.serverIPAddress=ClassroomContext.DESKTOP_SHARING_SERVER;
	fileManager.userRole=userRole;	
	fileManager.excludeFileDeletion(" - My Videos - ", "No video to delete!");
	fileManager.excludeFilePathDeletion(remoteFilePath, "You cannot delete a video while it is being used!");
	fileManager.excludeFolderPathDeletionPrefixOf(remoteFilePath, "You cannot delete a folder while any of its video is being used!");
	fileManager.dummyXML=<dirs><files label="Video list is loading, Please wait..." /></dirs>;
	//Event listener for close event of FileManager
	fileManager.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
	//Event handlers for file upload, file download,list files,create folder and check existence 
	//of given file
	fileManager.addEventListener(ContentOperationEvent.DELETE,onDeleteFile);
	fileManager.addEventListener(ContentOperationEvent.FILELIST,onListFiles);
	fileManager.addEventListener(ContentOperationEvent.SELECTION,onSelectionHandler)
	fileManager.addEventListener(ContentOperationEvent.DOWLOAD,onDownloadFile);
	fileManager.addEventListener(ContentOperationEvent.UPLOAD,onUploadFile);
	fileManager.addEventListener(ContentOperationEvent.CHECKEXISTANCE,onCheckFileExistance);
	fileManager.addEventListener(ContentOperationEvent.CREATFOLDER,onCreateFolder);
	fileManager.addEventListener(ContentOperationEvent.PREINITILIZEUPLOAD,onPreInitializeUpload)
	
	PopUpManager.addPopUp(fileManager, vBoxVideoPlayer, true, PopUpManagerChildList.POPUP);
	PopUpManager.centerPopUp(fileManager);
	fileManager.isPopUp=false;

}
/**
 * Function to add set the first folder as selected. 
 * Othewise if user choose any action without selecting any file, then the remotefilePath will be null.
 */
private function setFirstFolderSelected():void{
	fileManager.fileList.selectedIndex = 0;
	remoteFilePath = fileManager.fileList.selectedItem.@path;
}

/**
 * @private
 * Invoked when a file/folder is selected by the user 
 * @param event ContentOpertaionEvent dispatched from fileManager
 * @return void
 */
private function onSelectionHandler(event:ContentOperationEvent):void
{
	//gets the xmldata associated with the selected file/folder in fileManager
	var xml:XML = XML(event.selectedItem);
	//holds xml tag name
	var tag:String = xml.name();	
	
	//disabling upload,downolad,create,delete buttons
	fileManager.setDownloadDiscBtn(false);
	fileManager.setCreateBtn(false);
	fileManager.setDeleteBtn(false);
	fileManager.setDownloadBtn(false);
	fileManager.setUploadBtn(false);
	
	//Displaying the messages based on the xml data related to the selected item
	if(xml.@type =="initial" ||tag == null  ||xml.@type =="fault")
	{					
		return;
	}
	if (xml.@status =="Conversion Started")
	{
		alert=MessageBox.show("Selected file has been converting.","Info",MessageBox.MB_OK,fileManager,null,null,MessageBox.IC_INFO)
		return;
	}
	if (xml.@status =="Conversion not started" )
	{
		alert=MessageBox.show("Selected file has in conevrsion queue.","Info",MessageBox.MB_OK,fileManager,null,null,MessageBox.IC_INFO)
		return;
		
	}
	if ((xml.@label =="-No Video Files-") && String(xml.@path) == "" )
	{
		alert=MessageBox.show("There is no videos in this folder.","Info",MessageBox.MB_OK,fileManager,null,null,MessageBox.IC_INFO)
		//Path of the selected remote file
		remoteFilePath="";
		//name of the selected remote file/folder 
		remoteFileName="";
		isFolderSelected = false;
	}
		//--END-------------------------------------------------------------------------------------------
		
	else if(tag)
	{	
		//disables delete button if the root folder (My Videos) is selected.
		//enables the same if any subfolder is selected.
		if(tag != "root")
		{
			fileManager.setDeleteBtn(true);
		}
		else
		{
			fileManager.setDeleteBtn(false);
		}
		//The native file path for the selected file/folder in server
		remoteFilePath=xml.@path;
	
		//The selected filename
		remoteFileName=xml.@label;
		
		
		if(tag == fileManager.xmlFolder || tag == "root")
		{			
			isFolderSelected = true;
		} 
		else
		{			
			isFolderSelected = false;	
		
		}
		if (tag == "emptyFolder"){
			
			isFolderSelected=true;
		}
	}	
	//IF a folder is selected from fileManager then enables the  upload and create button
	// and the download button is disabled
	//OTHERWISE if a file is selected then the dowload button is enabled and
	//upload and create buttons are disabled
	//START---------------------
	if(isFolderSelected)
	{		
		fileManager.setDownloadBtn(false);
		fileManager.setUploadBtn(true);
		fileManager.setCreateBtn(true);
		
	}
	else
	{
		fileManager.setUploadBtn(false);
		fileManager.setCreateBtn(false);
		
		if(xml.@label !="-No Video Files-")
		{
			fileManager.setDownloadBtn(true);
		}		
	}
	//END---------------------
	
}
/**
 * @private
 * This method is invoked when a file is selected to delete.
 * Invokes the content service to start the actual delete operation.
 * @param event ContentOpertaionEvent that gives the path for the selected file.
 * @return void
 */
private function onDeleteFile(event:ContentOperationEvent):void
{
	if (remoteFileName == "")
	{			
		alert=MessageBox.show("No file selected for deletion", "INFO", MessageBox.MB_OK, fileManager,null,null,MessageBox.IC_INFO);			
		return;			
	}	
	remoteFilePath=remoteFilePath.replace("./../../../../","../../");
	//holds true/false that returned from checkExclusionMessage
	var exclusionMsg:String=fileManager.checkExclusionMessage(remoteFilePath,remoteFileName,isFolderSelected);
	if(exclusionMsg != "")
	{
		alert=MessageBox.show(exclusionMsg, "INFO", MessageBox.MB_OK, fileManager,null,null,MessageBox.IC_INFO);
	}		
	else
	{	if(fileManager.downloadBtn.enabled==true)	
		alert=MessageBox.show("Do You want to Delete This file","Confirm File Deletion",MessageBox.MB_YESNO,fileManager,onDeleteConfirmation,null,MessageBox.IC_DELETE);
	else
		alert=MessageBox.show("Do You want to Delete This folder and all its contents","Confirm File Deletion",MessageBox.MB_YESNO,fileManager,onDeleteConfirmation,null,MessageBox.IC_DELETE);
	}
}

/**
 * @private
 * Event handler for alert box that asks for confirmation that deletes a file.
 * @param event
 * @return void
 */
private function onDeleteConfirmation(event:MessageBoxEvent):void
{
	if(event.type =="messageBoxYES" )
	{
		contentService.deleteVideoFile(remoteFilePath,onFileDeletion,onFileDeletionFault,null,null,ClassroomContext.DESKTOP_SHARING_SERVER);
	}
}
/**
 * @private
 * Invoked when a video file/folder is successfully deleted from server.
 * @param message
 * @return void
 */
private function onFileDeletion(message:Object):void
{
	//reloads fileList
	fileManager.loadFileList();
}
/**
 * @private
 * Invoked when a file/folder  deletion is failed
 * @param message
 * @return void
 */
private function onFileDeletionFault(message:String):void
{
	Alert.show("File Deletion Failed");
}


/**
 * @public
 * applyinng file filters to the file manager before browsing the files  from file manager.
 * @param event ContentOpertaionEvent
 * @return void
 */
public function onPreInitializeUpload(event:ContentOperationEvent):void
{
	//fileFilter object for video files
	var fileFilter:FileFilter=new FileFilter("Video Files", "*.flv;*.FLV;*.mp4;*.MP4;*.f4v;*.F4V");
	fileManager.setUploadData(fileFilter);
}
/**
 * @private
 * This method is invoked when a user clicks the download button.
 * @param event
 * @return void
 */
private function onDownloadFile(event:ContentOperationEvent):void
{
	closeFileList();
	txtYoutubeURL.text='Paste YouTube URL here and hit enter key';
	setSelectedVideo(getDownloadableRemotePath(remoteFilePath));
}
/**
 * @private
 * Invoked when contentSerivice instance is ready to upload a selected file.
 * @param event ContentOpertaionEvent
 * @return void
 */
private function onUploadFile(event:ContentOperationEvent):void
{    	
	contentService.uploadVideoFile(remoteFilePath,event.fileReference,onUploadResult,onUploadFault,0,ClassroomContext.DESKTOP_SHARING_SERVER);
	//contentService.uploadFile(remoteFilePath,event.fileReference,onUploadResult,onUploadFault);
}
/**
 * @private
 * Invoked after a successful video file upload
 * @param event
 * @return void
 */
private function onUploadResult(event:Event):void
{
	//#bugfix for 15596
	if(fileManager!=null)
	{
		fileManager.successUpload();
	
		setSelectedVideo(uploadPath);
	
		closeFileList();
	
		videoSharingUploadEventLog(uploadPath);
	}
}

/**
 *
 * @private
 * Audits the "VideoSharingUpload" action, when the presenter uploads the video to library
 *
 * @param url of the Video
 * @return void
 *
 */
private function videoSharingUploadEventLog(url:String):void
{
	AuditContext.userAction.createAction(AuditConstants.videoSharingUpload, url, null, null);
}

/**
 * @private
 * Invoked when a video upload operation is failed
 * @param event
 * @return void
 */
private function onUploadFault(event:Event):void
{
	log.info("onUploadFault:uploading video to"+ uploadPath+"failed");
}

/**
 * @private
 * Event Listener for ContentOpertaionEvent.CHECKEXISTANCE of fileManager
 * @param event ContentOpertaionEvent
 * @return void
 */
private function onCheckFileExistance(event:ContentOperationEvent):void
{
	//The folderpath for remote folder(new folder)
	
	var folderPath:String=remoteFilePath+"/"+event.fileName;
	uploadPath=folderPath.substring(folderPath.indexOf("/VideoShare/"),folderPath.length);	
	contentService.checkVideoFileExistance(folderPath,checkFileExistanceResultHandler,checkFileExistanceFaultHandler,ClassroomContext.DESKTOP_SHARING_SERVER)
}
/**
 * @private
 * Invoked after a successful file existance check operation from contentService
 * @param message
 * @return void
 */
private function checkFileExistanceResultHandler(message:Object):void
{
	fileManager.fileExistanceMessage(message.result);
}
/**
 * @private
 * Invoked after the file existance check operation is failed.
 * @param event
 * @return void
 */
private function checkFileExistanceFaultHandler(event:Event):void
{
	log.info("checkFileExistanceFault:uploading video to"+ uploadPath +"failed");
}
/**
 * @private
 * Invoked when the contentService instance is ready to create 
 * a new folder on the selected location in remote server.
 * @param event
 * @return void
 */
private function onCreateFolder(event:ContentOperationEvent):void
{
	//The folderpath for remote folder(new folder)
	//PNCR: Bug #15138. Set a default remotefilePath, if there not folder is selected.
	if (remoteFilePath=="") 
		setFirstFolderSelected();
	var folderPath:String=remoteFilePath+"/"+event.folderName;	
	contentService.createVideoFolder(folderPath,onFolderCreationResult,onFolderCreationFault,ClassroomContext.DESKTOP_SHARING_SERVER);
}
/**
 * @private
 * Invoked after a successful new folder creation by contentService
 * @param message
 * @return void
 */
private function onFolderCreationResult(message:Object):void
{
	fileManager.successNewFolder();
}
/**
 * @private 
 * Invoked when the folder creation operation is failed
 * @param event
 * @return void
 */
private function onFolderCreationFault(event:Event):void
{
	
	log.info("checkFileExistanceFault:create Folder service failed");
}
/**
 * @private 
 * Invoked when the list of video files are ready to be retrieved.
 * @param event ContentOpertaionEvent
 * @return void
 */
private function onListFiles(event:ContentOperationEvent):void
{	
	//sends request to server to get the file list.
	//contentService.getVideoFileList(event.rootFolder,fileListResultHandler,onListFilesServiceFault,ClassroomContext.DESKTOP_SHARING_SERVER);
	contentService.getVideoFileList(event.rootFolder,fileListResultHandler,onListFilesServiceFault,ClassroomContext.DESKTOP_SHARING_SERVER);
	
	
}

/**
 * @private
 * Invoked after retrieving the list of video files from content server.
 * @param obj
 * @return void
 * 
 */
private function fileListResultHandler(obj:Object):void
{
	if(fileManager!=null)
	fileManager.setFileList(obj.result);
	var xml:XML=XML(obj.result);
	if(xml.root[0]!=null && xml.root[0].folder[0]!=null)
	{
		remoteFilePath=xml.root[0].folder[0].@path;
	}
}

/**
 * @private
 * Invoked after the file listing service is failed.
 * @param obj
 * @return void
 */
private function onListFilesServiceFault(obj:Object):void
{
	log.info("onListFilesServiceFault:Listing video files for user:"+ClassroomContext.userVO.userName+"failed");
}
/**
 * @public
 * retrieving the location of file which needs to be appended with the rtmp end point.
 * @param remotePath native filepath for remote video
 * @return String relative  path for the selected file
 * 
 */
public function getDownloadableRemotePath(remotePath:String):String
{
	// The downloadable filepath for the video in fms vod folder
	var downloadable:String = "";
	//prefix for library folder path. The deafult location for vod folder
	var prefix:String = "/vod/media";
	//The index of the prefix in remote filepath.
	var idx:int = remotePath.indexOf(prefix,0);
	if(idx != -1)
	{
		downloadable = remotePath.substring(idx+prefix.length);
	}
	//Added for Red5 streaming server
	else
	{
		prefix = "/vod/streams";
		idx = remotePath.indexOf(prefix,0);
		if(idx != -1)
		{
			downloadable = remotePath.substring(idx+prefix.length);
		}
	}
	
	return downloadable;
}
/**
 *  @private
 *  sets the selected video filepath to the player control
 *  Invoked when new video is successfully uploaded to library
 *  or downloaded from library
 *  @param videoPath
 *  @return void
 */
private function setSelectedVideo(videoPath:String):void
{
	remoteFilePath=videoPath;
	// The video url which is already loaded
	var oldURL:String=videoURL;

	videoURL=Constants.PROTOCOL_FMS_SERVER + PROTOCOL_SEP + ClassroomContext.DESKTOP_SHARING_SERVER + "/vod" + remoteFilePath;
	// The variable that holds the filename with extension
	var tempURI:String=videoURL.substring(videoURL.lastIndexOf("/")+1, videoURL.length);
	//if a new url needs tobe loaded
	if (labelFileName.text != tempURI )
	{
		if(labelFileName.text!="")
		{
			//Stop any currently playing video at all users end
			updateVideoProperties(oldURL, Constants.VIDEO_STATE_STOP, 0);
			if (Log.isInfo()) log.info("updateVideoProperties:selectedVideo url:" + oldURL + ", command:" + Constants.VIDEO_STATE_STOP + ", timer:" + 0);
		}
		initiateLoadLibraryVideo();
		if (txtYoutubeURL.text != '' && txtYoutubeURL.text == 'Paste YouTube URL here and hit enter key')
			labelFileName.text=tempURI;
	}
	else if (labelFileName.text != "" && labelFileName.text == tempURI)
	{
		labelFileName.setFocus();
		alertControl=Alert.show("Video already loaded", "Video Module", 4, this);
	}

}


/**
 * @private
 * Invoked when the fileManager component is closed.
 * @param event CloseFileComponentEvent dispatched from fileManager
 * 
 * @return void
 */
private function onCloseFileComponentEvent(event:CloseFileComponentEvent):void
{
	if (event.componentName == CloseFileComponentEvent.FILE_MANAGER)
	{
		closeFileList();
	}
}

/**
 * @private
 * removes the fileManager component
 * @return void
 */
private function closeFileList():void
{
	if (fileManager != null)
	{
		PopUpManager.removePopUp(fileManager);
		fileManager=null;
	}
}


