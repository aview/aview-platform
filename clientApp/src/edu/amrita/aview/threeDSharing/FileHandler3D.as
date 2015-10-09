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
 * File			: FileHandler3D.as
 * Module		: 3DViewer
 * Developer(s)	: Jayakrishnan R, Arun V , Haridasan PC
 * Reviewer(s)	: Pradeesh,Remya T
 *
 * For listing uploaded objects
 * Upload/Download objects
 *
 */

import edu.amrita.aview.audit.AuditConstants;
applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.fileManager.FileManager;
}
import edu.amrita.aview.common.components.fileManager.download.FileDownloader;
import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.common.components.fileManager.events.DownloadRequestedEvent;
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.service.content.ContentService;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.shared.audit.AuditContext;
applicationType::mobile{
	import edu.amrita.aview.common.components.fileManager.MobileFileManager;
}

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.FileFilter;
import flash.net.FileReference;

import mx.core.FlexGlobals;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;
import mx.events.FlexMouseEvent;
import spark.events.PopUpEvent;


/**
 * For listing the uploaded objects
 * */
applicationType::DesktopWeb{
	public var fileManagerForViewer3D:FileManager=null;
}
applicationType::mobile{
	public var fileManagerForViewer3D:MobileFileManager=null;
}

/**
 * String for storing the content IPaddress
 * */
public var contentIPAddress:String="";

/**
 * Integer object used as a counter
 * */
private var firstCounter:int;

/**
 * For creating new folder
 * */
private var FOLDER_PREFIX:String="_3d___";

/**
 * To store the object folder path from server
 */
private var initialPath:String;

/**
 * To store the object name
 * */

public var remoteFilename:String;

/**
 * For downloading an object
 * */
private var fileDownloaderObj:FileDownloader=new FileDownloader();
/**
 * Flag to know the uploading completed or not
 * */
public var isUploadComplete:Boolean=false;
/**
 * For uploading and downloading objects
 */
public var contentService:ContentService=new ContentService();
/**
 * For checking the user selected any folder for upload or deletion
 */
private var isFolderSelected:Boolean;
/**
 * For showing message
 */
private var alert:MessageBox;
/**
 * Storing complete path, includes folder path and file name
 * */
public var remoteFilePath:String="";
/**
 * Storing the file name.
 * */
[Bindable]
public var remoteFileName:String;
/**
 * For choosing the file from local machine
 */
applicationType::DesktopMobile{
	import flash.filesystem.File;
	private var fileReference:File;
}

/**
 * For storing collada texture path
 */
public var texturePath:String;

/**
 * For checking the texture uploaded successfuly
 */
private var boolTextureUploadError:Boolean=false;

/**
 * For texture uploading
 */
private var updated:Boolean=false;
/**
 * For storing collada texture names
 */
private var textureNameArray:Array=new Array();
/**
 * For passing a texture array to PHP
 */
private var arrayToPHP:Array=new Array();
/**
 * For storing collada texture name
 */
private var textureName:String;
/**
 * For storing uploading file count
 */
private var uploadCount:int=0;


/**
 * @public
 * Invoked when the click on My3Dlibrary button
 *
 * It show the filemanager window
 * Upload new objects to server
 * Download objects to scene
 * Rename object folder
 *
 * @param mouseEvent of  type MouseEvent
 * @return void
 *
 */
public function listRemoteFiles(mouseEvent:MouseEvent=null):void {
	if (!fileManagerForViewer3D) {
		applicationType::DesktopWeb{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.setValue("val", 99);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.setValue("val", 2);
			if (mouseEvent.target.mouseX < 120 && mouseEvent.currentTarget == viewer3DSWC.btnListingServerFiles) {
				if (viewer3DSWC.scrollComponents.loadedList.height > 0) {
					viewer3DSWC.scrollComponents.loadedList.visible=false;
				}
				if (viewer3DSWC.scrollComponents.objectLayer.height > 0) {
					viewer3DSWC.scrollComponents.objectLayer.openItems=[];
				}
				this.stage.frameRate=24;
				fileManagerForViewer3D=new FileManager();
				fileManagerForViewer3D.rootFolder=presenterViewer3D + "/My 3D Models";
				fileManagerForViewer3D.defaultFolderPath="../../AVContent/Upload/Personal/" + presenterViewer3D + "/My 3D Models";
				fileManagerForViewer3D.serverIPAddress=contentIPAddress;
				fileManagerForViewer3D.userRole=Constants.PRESENTER_ROLE;
				fileManagerForViewer3D.usingModule=FileManager.MODULE_3D_SHARING;
				fileManagerForViewer3D.excludeFileDeletion(" - No documents - ", "No 3D objects to delete!");
				fileManagerForViewer3D.x=((viewer3DSWC.brdrCont3DLoader.width / 2) - (fileManagerForViewer3D.width)) + 100;
				fileManagerForViewer3D.y=(viewer3DSWC.brdrCont3DLoader.height / 2) - (fileManagerForViewer3D.height);
	
				if (viewer3DSWC.objectDetails != null) {
					for (firstCounter=0; firstCounter < viewer3DSWC.objectDetails.length; firstCounter++) {
						var notToBeDeleted:String=viewer3DSWC.objectDetails[firstCounter].packageName;
						fileManagerForViewer3D.excludeFilePathDeletion(notToBeDeleted, "You cannot delete a 3D object while it is being used!");
						fileManagerForViewer3D.excludeFolderPathDeletionPrefixOf(notToBeDeleted, "You cannot delete a package while any of its objects is being used!");
					}
				}
				fileManagerForViewer3D.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.FILELIST, onFileListHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.SELECTION, onSelectionHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.DELETE, onDleteHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.DOWLOAD, onDownloadHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.UPLOAD, onUploadHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.CHECKEXISTANCE, onCheckFileExistanceHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.CREATFOLDER, onCreateFolderHandler);
				fileManagerForViewer3D.addEventListener(ContentOperationEvent.PREINITILIZEUPLOAD, onPreinitilizeUpload);
				if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isPopOut) {
					PopUpManager.addPopUp(fileManagerForViewer3D, viewer3DSWC.brdrCont3DLoader, true, PopUpManagerChildList.POPUP);
				} else {
					applicationType::desktop{
						PopUpManager.addPopUp(fileManagerForViewer3D, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule, true, PopUpManagerChildList.POPUP);
					}
				}
				fileManagerForViewer3D.isPopUp=false;
				if (viewer3DSWC.objectDetails != null) {
					if (viewer3DSWC.objectDetails.length > 0 && viewer3DSWC.flare3DEngineInstance) {
						viewer3DSWC.scrollComponents.objectLayer.visible=true;
					}
				}
			} else {
				//NPCR:Same condition mentioned in above if. Instead can put this if inside second if.
				if (viewer3DSWC.objectDetails != null) {
					if (viewer3DSWC.objectDetails.length > 0) {
						showLoadedFiles();
					}
				}
			}
		}
		applicationType::mobile{
			FlexGlobals.topLevelApplication.selectedModuleSO.setValue("val", 99);
			FlexGlobals.topLevelApplication.selectedModuleSO.setValue("val", 2);
			this.stage.frameRate=24;
			fileManagerForViewer3D=new MobileFileManager();
			fileManagerForViewer3D.rootFolder=presenterViewer3D + "/My 3D Models";
			fileManagerForViewer3D.defaultFolderPath="../../AVContent/Upload/Personal/" + presenterViewer3D + "/My 3D Models";
			fileManagerForViewer3D.serverIPAddress=contentIPAddress;
			fileManagerForViewer3D.userRole=Constants.PRESENTER_ROLE;
			fileManagerForViewer3D.usingModule=MobileFileManager.MODULE_3D_SHARING;
			fileManagerForViewer3D.excludeFileDeletion(" - No documents - ", "No 3D objects to delete!");
			
			if (viewer3DSWC.objectDetails != null) {
				for (firstCounter=0; firstCounter < viewer3DSWC.objectDetails.length; firstCounter++) {
					var notToBeDeleted:String=viewer3DSWC.objectDetails[firstCounter].packageName;
					fileManagerForViewer3D.excludeFilePathDeletion(notToBeDeleted, "You cannot delete a 3D object while it is being used!");
					fileManagerForViewer3D.excludeFolderPathDeletionPrefixOf(notToBeDeleted, "You cannot delete a package while any of its objects is being used!");
				}
			}
			fileManagerForViewer3D.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.FILELIST, onFileListHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.SELECTION, onSelectionHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.DELETE, onDleteHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.DOWLOAD, onDownloadHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.UPLOAD, onUploadHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.CHECKEXISTANCE, onCheckFileExistanceHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.CREATFOLDER, onCreateFolderHandler);
			fileManagerForViewer3D.addEventListener(ContentOperationEvent.PREINITILIZEUPLOAD, onPreinitilizeUpload);
			fileManagerForViewer3D.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, modifyCalloutVisibility);
			fileManagerForViewer3D.addEventListener(PopUpEvent.CLOSE, modifyCalloutVisibility);
			fileManagerForViewer3D.isPopUp=false;
		}
	}
}

/**
 *
 * @private
 * Invoked when FILELIST event occur
 * Listing the objects from server
 *
 * @param event of ContentOpertaionEvent
 * @return void
 *
 */
private function onFileListHandler(event:ContentOperationEvent):void {
	contentService.getFileList(event.rootFolder, fileListResultHandler, fileListfaultHandler);
}

/**
 *
 * @private
 * Invoked from onFileListHandler function
 *
 * @param obj of type Object
 * @return void
 *
 */

private function fileListResultHandler(obj:Object):void {
	fileManagerForViewer3D.setFileList(obj.result);
}

/**
 *
 * @private
 * Invoked from onFileListHandler function
 *
 * @param obj of type Object
 * @return void
 *
 */
private function fileListfaultHandler(obj:Object):void {
	fileManagerForViewer3D.showErrorInFileList();
}

/**
 *
 * @private
 * Invoked when user select a file or folder from filemanger
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 */
private function onSelectionHandler(event:ContentOperationEvent):void 
{
	var xml:XML=XML(event.selectedItem);
	var tag:String=xml.name();

	fileManagerForViewer3D.setDownloadDiscBtn(false);
	fileManagerForViewer3D.setCreateBtn(false);
	fileManagerForViewer3D.setDeleteBtn(false);
	fileManagerForViewer3D.setDownloadBtn(false);
	fileManagerForViewer3D.setUploadBtn(false);
	if (xml.@type == "initial" || tag == null || xml.@type == "fault") {
		return;
	}
	if ((xml.@label == "-No 3Dobjects-") && String(xml.@path) == "") 
	{
		alert=MessageBox.show("There is no objects in this folder.", "Info", MessageBox.MB_OK, fileManagerForViewer3D, null, null, MessageBox.IC_INFO);
		//Path of the selected remote file
		remoteFilePath="";
		//name of the selected remote file/folder 
		remoteFileName="";
		isFolderSelected=false;
	} 
	else if (tag) 
	{
		if (tag != "root") 
		{
			fileManagerForViewer3D.setDeleteBtn(true);
		} else 
		{
			fileManagerForViewer3D.setDeleteBtn(false);
		}
       
		remoteFilePath=xml.@path;
		remoteFileName=xml.@label;
		
		if (tag == fileManagerForViewer3D.xmlFolder || tag == "root") {
			isFolderSelected=true;
		} else {
			isFolderSelected=false;
		}
	} else {
	}
	if (isFolderSelected) {
		fileManagerForViewer3D.setDownloadBtn(false);
		fileManagerForViewer3D.setUploadBtn(true);
		fileManagerForViewer3D.setCreateBtn(true);
	} else {
		fileManagerForViewer3D.setUploadBtn(false);
		fileManagerForViewer3D.setCreateBtn(false);

		if (xml.@label != "-No objects-") {
			fileManagerForViewer3D.setDownloadBtn(true);
		}
	}
	if (remoteFilePath.indexOf("../../AVContent/Upload/Common") != -1) {
		if (tag != "root" && !isFolderSelected) {
			fileManagerForViewer3D.setDownloadBtn(true);
		} else {
			fileManagerForViewer3D.setDownloadBtn(false);
		}
		fileManagerForViewer3D.setUploadBtn(false);
		fileManagerForViewer3D.setCreateBtn(false);
		fileManagerForViewer3D.setDeleteBtn(false);
	}
}

/**
 *
 * @private
 * Invoked when user delete an object from server
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 */

private function onDleteHandler(event:ContentOperationEvent):void {
	if (remoteFileName == "") {
		alert=MessageBox.show("No file selected for deletion", "INFO", MessageBox.MB_OK, fileManagerForViewer3D, null, null, MessageBox.IC_INFO);
		return;
	}
	remoteFilePath=remoteFilePath.replace("./../../../../", "../../");
	var exclusionMsg:String=fileManagerForViewer3D.checkExclusionMessage(remoteFilePath, remoteFileName, isFolderSelected);
	if (exclusionMsg != "") {
		alert=MessageBox.show(exclusionMsg, "INFO", MessageBox.MB_OK, fileManagerForViewer3D, null, null, MessageBox.IC_INFO);
	} else {
		
		if(fileManagerForViewer3D.downloadBtn.enabled==true)
		alert=MessageBox.show("Do You want to Delete This file", "Confirm File Deletion", MessageBox.MB_YESNO, fileManagerForViewer3D, deleteConfirmation, null, MessageBox.IC_DELETE);
		else
			alert=MessageBox.show("Do You want to Delete This folder and all its contents", "Confirm File Deletion", MessageBox.MB_YESNO, fileManagerForViewer3D, deleteConfirmation, null, MessageBox.IC_DELETE);	
	}
}

/**
 *
 * @private
 * For Confirming object deletion
 *
 * @param event of type MessageBoxEvent
 * @return void
 *
 */
private function deleteConfirmation(event:MessageBoxEvent):void {
	if (event.type == "messageBoxYES") {
		contentService.deleteFile(remoteFilePath, successfullDeletion, deletionFaultHandler);
	}
}

/**
 *
 * @private
 * Invoked after user deleted an object from server
 *
 * @param event of type Object
 * @return void
 *
 */

private function successfullDeletion(event:Object):void {
	fileManagerForViewer3D.loadFileList();
}

/**
 *
 * @private
 * Invoked when an error occur in object delection
 *
 * @param obj of type Object
 * @return void
 *
 */
private function deletionFaultHandler(obj:Object):void {

}

/**
 *
 * @private
 * Invoked from "Upload" button click
 *
 * to filter the files for uploading
 *
 * event of type ContentOpertaionEvent
 * @return void
 *
 */
private function onUploadHandler(event:ContentOperationEvent):void 
{
	remoteFileName=event.fileReference.name
	applicationType::DesktopMobile{
		fileReference=event.fileReference as File;
	}
	//Fix for issue #19269
	var folderPath:String=remoteFilePath + "/_3d___" + remoteFileName;
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
 */
private function uploadComplete(event:Event):void 
{

	//Fix for issue #19269
	applicationType::DesktopMobile{
		/*if (event.currentTarget.extension == "dae") 
		{
			
			var fileServerPath:String;
			var finalPath:String;
			fileServerPath=remoteFilePath + "/_3d___" + remoteFileName + "/" + remoteFileName;
			fileServerPath=fileServerPath.substr(5, fileServerPath.length);
			contentService.textureUpload(fileServerPath, onTextureUploadComplete, onFault);
		} 
		else 
		{*/
			onUploadComplete(remoteFileName);
		//}
	}
	applicationType::web{
		if (event.currentTarget.type== ".dae") 
		{
			var fileServerPath:String;
			var finalPath:String;
			fileServerPath=remoteFilePath + "/_3d___" + remoteFileName + "/" + remoteFileName;
			fileServerPath=fileServerPath.substr(5, fileServerPath.length);
			contentService.textureUpload(fileServerPath, onTextureUploadComplete, onFault);
		} 
		else 
		{
			onUploadComplete(remoteFileName);
		}
	}
}

/**
 *
 * @private
 * Invoked when an eror occur at the time of uploading
 *
 * @param event of type Event
 * @return void
 *
 */
private function onFault(event:Event):void {

}

/**
 *
 * @private
 * Invoked when user upload an object to server
 *
 * Checking the object is already uploaded or not
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 */
private function onCheckFileExistanceHandler(event:ContentOperationEvent):void {
	var folderPath:String=remoteFilePath + "/_3d___" + remoteFileName;
	contentService.checkFileExistance(folderPath, checkFileExistanceResultHandler, onFault);
}

/**
 *
 * @private
 * Invoked from "onCheckFileExistanceHandler"
 *
 *
 * @param data of type String
 * @return void
 *
 */

private function checkFileExistanceResultHandler(data:String):void {
	fileManagerForViewer3D.fileExistanceMessage(data);
}

/**
 *
 * @private
 * Invoked when user click on create new folder button
 *
 * Creating the new folder in server.
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 */
private function onCreateFolderHandler(event:ContentOperationEvent):void {
	var folderPath:String=remoteFilePath + "/" + event.folderName;
	contentService.createFolder(folderPath, succesFolderCreation, onFault);
}

/**
 *
 * @private
 * Invoked from "onCreateFolderHandler" function
 *
 *
 * @param msg of type Object
 * @return void
 *
 */

private function succesFolderCreation(msg:Object):void {
	fileManagerForViewer3D.successNewFolder();
}

/**
 *
 * @private
 * Invoked after object uploading complete
 *
 * Request for object downloading.
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 */

private function onDownloadHandler(event:ContentOperationEvent):void 
{
	closeFileList();
	applicationType::DesktopWeb{
		viewer3DSWC.normalDownload=true;
	//	uploadComplete=false;
		viewer3DSWC.nextOrPrevious=false;
		if(viewer3DSWC.flare3DEngineInstance)
		{
			if(viewer3DSWC.flare3DEngineInstance.sceneObject.children.length!=0)
			{	
				viewer3DSWC.storeObjectDetails();
			}
		}
		viewer3DSWC.lblPageNo.text="Page" + (viewer3DSWC.objectDetails.length + 1);
		
		
		//viewer3DSWC.fluidSimulation=viewer3DSWC.remoteFilePath.substr(viewer3DSWC.remoteFilePath.lastIndexOf("/")+1,viewer3DSWC.remoteFilePath.length);
		viewer3DSWC.fluidSimulation=getDownloadableRemotePath(remoteFilePath).substr(getDownloadableRemotePath(remoteFilePath).lastIndexOf("/")+1,getDownloadableRemotePath(remoteFilePath).length);
		if(viewer3DSWC.fluidSimulation !="_3d___Fluid_simulation.f3d")
		{
			if(!viewer3DSWC.loadIcon.visible)
			{
				viewer3DSWC.loadIcon.visible=true;
				viewer3DSWC.loadingLabel.visible=true;
			}
			loadFileToCache(getDownloadableRemotePath(remoteFilePath));
		}
		else
		{
			if(!viewer3DSWC.waterDemo)
			{
				viewer3DSWC.Waterdemo();
			}
		}
	}
	applicationType::mobile{
		viewer3DSWC.normalDownload=true;
		//	uploadComplete=false;
		if(viewer3DSWC.flare3DEngineInstance)
		{
			if(viewer3DSWC.flare3DEngineInstance.sceneObject.children.length!=0)
			{	
				viewer3DSWC.storeObjectDetails();
			}
		}
		//viewer3DSWC.fluidSimulation=viewer3DSWC.remoteFilePath.substr(viewer3DSWC.remoteFilePath.lastIndexOf("/")+1,viewer3DSWC.remoteFilePath.length);
		if(!viewer3DSWC.loadIcon.visible)
		{
			viewer3DSWC.loadIcon.visible=true;
			viewer3DSWC.loadingLabel.visible=true;
		}
		loadFileToCache(getDownloadableRemotePath(remoteFilePath));
	}
}

/**
 *
 * @private
 * Invoked when user open upload window
 *
 * Filter the object files for uploading
 *
 * @param event of type ContentOpertaionEvent
 * @return void
 *
 */

private function onPreinitilizeUpload(event:ContentOperationEvent):void {
	var fileFileter:FileFilter=new FileFilter("3D Objects(.f3d .dae)", "*.f3d;*.dae");
	fileManagerForViewer3D.setUploadData(fileFileter);
}

/**
 *
 * @public
 * Invoked when user request to download object
 *
 * Get the local path for downloading
 *
 * @param remotePath of type String
 * @return String
 *
 */
public function getDownloadableRemotePath(remotePath:String):String {
	var downloadable:String="";
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
 * Invoked when user complete the collada object uploading
 *
 * Start the texture uploading
 *
 *  @param result of type Object
 * @return void
 *
 */

private function onTextureUploadComplete(result:Object):void {
	applicationType::DesktopWeb{
		textureNameArray=findingTextureName(result.message.body.toString());
		if (textureNameArray.length == 0) {
			fileManagerForViewer3D.successUpload();
		} else {
			for (i=0; i < textureNameArray.length; i++) {
				applicationType::desktop{
					var textureFullPath:String=fileReference.nativePath;
					texturePath=textureNameArray[i];
					textureFullPath=textureFullPath.substr(0, textureFullPath.lastIndexOf("\\"));
					arrayToPHP[i]=textureName;
					uploadCount++;
					var fileRefForUploadTexture:File=new File();
					if (texturePath.indexOf("file:\\") > -1){
						texturePath=texturePath.substr(texturePath.indexOf("\\") + 3, texturePath.length);
						fileRefForUploadTexture.nativePath=texturePath;
					} else if (texturePath.indexOf(":") > 0){
						fileRefForUploadTexture.nativePath=texturePath;
					} else{
						textureFullPath=textureFullPath + "/" + texturePath;
						fileRefForUploadTexture.nativePath=textureFullPath;
					}
					if (texturePath != ""){
						contentService.uploadFile(texturePath, fileRefForUploadTexture as FileReference, textureUploadComplete, textureUploadError);
					}
				}
			}
		}
	}
}

/**
 *
 * @private
 * Invoked when user start the texture uploading
 *
 * Finding the texture name
 *
 * @param colladaContent of type String
 * @return Array
 *
 */

private function findingTextureName(colladaContent:String):Array {
	applicationType::DesktopWeb{
		/*Regular expression variable used to remove the schema from the xml file*/
		var xmlnsPattern:RegExp;
		/*A string variable for storing the new xml file in for of string*/
		var namespaceRemovedXML:String;
		/*An XML Object for storing the new xml file after updating the texture name*/
		var xmlNew:XML=new XML();
		var originalTexture:String;
		xmlnsPattern=new RegExp("xmlns[^\"]*\"[^\"]*\"", "gi");
		namespaceRemovedXML=colladaContent.replace(xmlnsPattern, "");
		xmlNew=new XML(namespaceRemovedXML);
		for (i=0; i < xmlNew.library_images.image.length(); i++) {
			textureNameArray[i]=xmlNew.library_images.image[i].init_from;
		}
	}
	return textureNameArray;
}

/**
 *
 * @private
 * Invoked when there is any issue in texture uploading
 *
 *
 * @param event of type IOErrorEvent
 * @return void
 *
 */

private function textureUploadError(event:IOErrorEvent):void 
{
	applicationType::DesktopWeb{
		if (uploadCount == textureNameArray.length && !boolTextureUploadError) {
			var fileName:String=texturePath + "/_3d___" + remoteFilename + "/" + remoteFilename;
			contentService.updateCollada(fileName, null, onUpdateColladaResultHandler, onFault);
			boolTextureUploadError=true;
		}
	}
}

/**
 *
 * @private
 * Invoked when the texture uploading complete
 *
 *
 * @param event of type Event
 * @return void
 *
 */

private function textureUploadComplete(event:Event):void 
{
	applicationType::DesktopWeb{
		if (uploadCount == textureNameArray.length && !boolTextureUploadError && !updated) {
			var fileName:String=texturePath + "/_3d___" + remoteFilename + "/" + remoteFilename;
			contentService.updateCollada(fileName, arrayToPHP, onUpdateColladaResultHandler, onFault);
			boolTextureUploadError=true;
		}
	}
}

/**
 *
 * @private
 * Invoked when the collada object uploading completed
 *
 *
 * @param obj of type Object
 * @return void
 *
 */

private function onUpdateColladaResultHandler(obj:Object):void 
{
	//onUploadComplete(obj as Event);
}

/**
 *
 * @private
 * Invoked when the click on My3Dlibrary button
 *
 * It show the loaded objects
 *
 *
 * @return void
 *
 */
private function showLoadedFiles():void {
	applicationType::DesktopWeb{
		if (viewer3DSWC.scrollComponents.objectLayer.height > 0) {
			viewer3DSWC.scrollComponents.objectLayer.openItems=[];
			viewer3DSWC.scrollComponents.objectLayer.visible=false;
		}
		if (viewer3DSWC.scrollComponents.loadedList.height > 0) {
			viewer3DSWC.scrollComponents.loadedList.horizontalScrollPolicy="off";
			viewer3DSWC.scrollComponents.loadedListClose.play();
			if (viewer3DSWC.flare3DEngineInstance) {
				viewer3DSWC.scrollComponents.objectLayer.visible=true;
			}
		} else {
			viewer3DSWC.scrollComponents.loadedList.horizontalScrollPolicy="auto";
			viewer3DSWC.scrollComponents.loadedList.visible=true;
			viewer3DSWC.scrollComponents.loadedListOpen.play();
		}
	}
}

/**
 *
 * @private
 * Invoked when upload complete event occur
 *
 * It call the object downloading function
 *
 * @param uploadCompletedEvent of type Object
 * @return void
 *
 */
private function onUploadComplete(remoteFilename:String,uploadCompletedEvent:Object=null):void
{

	if (Log.isInfo())
		viewer3DSWC.logger.info("Upload completed in 3DViewer");
	var lastSlashIdx:int;
	applicationType::DesktopWeb{
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) 
		{
			closeFileList();
			//remoteFilename=remoteFilename;
			viewer3DSWC.remoteFilePath=remoteFilePath + "/" + remoteFilename;
			lastSlashIdx=viewer3DSWC.remoteFilePath.lastIndexOf("/");
			if (lastSlashIdx != 0) 
			{
				viewer3DSWC.remoteFilePath=viewer3DSWC.remoteFilePath.substr(0, lastSlashIdx + 1) + FOLDER_PREFIX + viewer3DSWC.remoteFilePath.substr(lastSlashIdx + 1, viewer3DSWC.remoteFilePath.length);
			}
			viewer3DSWC.normalDownload=true;
			isUploadComplete=true;
			viewer3DSWC.nextOrPrevious=false;
			if (viewer3DSWC.flare3DEngineInstance) {
				if (viewer3DSWC.flare3DEngineInstance.sceneObject.children.length != 0) 
				{
					viewer3DSWC.storeObjectDetails();
				}
			}
			viewer3DSWC.lblPageNo.text="Page" + (viewer3DSWC.objectDetails.length + 1);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObject("currentcanvas", (viewer3DSWC.objectDetails.length + 1));
			viewer3DSWC.scrollComponents.objectLayer.visible=false;
			if (!viewer3DSWC.loadIcon.visible) 
			{
				viewer3DSWC.loadIcon.visible=true;
				viewer3DSWC.loadingLabel.visible=true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObject("loadicon", "true");
			}
			//viewer3DSWC.remoteFilePath=remoteFilePath + "/" + remoteFilename;
			remoteFilePath=remoteFilePath.replace("../../","/");
			viewer3DSWC.remoteFilePath=remoteFilePath+ "/_3d___"+remoteFilename;;
			loadFileToCache(viewer3DSWC.remoteFilePath);
			threeDSharingUploadEventLog(viewer3DSWC.remoteFilePath, null, null);
		}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) 
		{
			closeFileList();
			//remoteFilename=remoteFilename;
			viewer3DSWC.remoteFilePath=remoteFilePath + "/" + remoteFilename;
			lastSlashIdx=viewer3DSWC.remoteFilePath.lastIndexOf("/");
			if (lastSlashIdx != 0) 
			{
				viewer3DSWC.remoteFilePath=viewer3DSWC.remoteFilePath.substr(0, lastSlashIdx + 1) + FOLDER_PREFIX + viewer3DSWC.remoteFilePath.substr(lastSlashIdx + 1, viewer3DSWC.remoteFilePath.length);
			}
			viewer3DSWC.normalDownload=true;
			isUploadComplete=true;
			if (viewer3DSWC.flare3DEngineInstance) {
				if (viewer3DSWC.flare3DEngineInstance.sceneObject.children.length != 0) 
				{
					viewer3DSWC.storeObjectDetails();
				}
			}
			FlexGlobals.topLevelApplication.viewer3DComp.setSharedObject("currentcanvas", (viewer3DSWC.objectDetails.length + 1));
			if (!viewer3DSWC.loadIcon.visible) 
			{
				viewer3DSWC.loadIcon.visible=true;
				viewer3DSWC.loadingLabel.visible=true;
				FlexGlobals.topLevelApplication.viewer3DComp.setSharedObject("loadicon", "true");
			}
			//viewer3DSWC.remoteFilePath=remoteFilePath + "/" + remoteFilename;
			remoteFilePath=remoteFilePath.replace("../../","/");
			viewer3DSWC.remoteFilePath=remoteFilePath+ "/_3d___"+remoteFilename;;
			loadFileToCache(viewer3DSWC.remoteFilePath);
			threeDSharingUploadEventLog(viewer3DSWC.remoteFilePath, null, null);
		}
	}
}

/**
 *
 * @private
 * Audits the "3DSharingUpload" action, when the presenter is uploading the 3D Model
 *
 * @param url of the 3D Model
 * @param animation - Whether the file has animations
 * @param size - Size of the file
 * @return void
 *
 */
private function threeDSharingUploadEventLog(url:String, animations:String, size:String):void
{
	applicationType::DesktopWeb{
		AuditContext.userAction.createAction(AuditConstants.threeDSharingLoad, url, animations, size);
	}
}

/**
 *
 * @private
 * Invoked when download Request Event occur
 *
 * It call the object downloading function
 *
 * @param downloadRequestedEvent of type DownloadRequestedEvent
 * @return void
 *
 */
private function onDownloadRequest(downloadRequestedEvent:DownloadRequestedEvent):void 
{
	if (Log.isInfo())
		viewer3DSWC.logger.info("Downloading object from file manager");
	viewer3DSWC.remoteFilePath=downloadRequestedEvent.remotePath;
	closeFileList();
	viewer3DSWC.normalDownload=true;
	isUploadComplete=false;
	applicationType::DesktopWeb{
		viewer3DSWC.nextOrPrevious=false;
	}
	if (viewer3DSWC.flare3DEngineInstance) {
		if (viewer3DSWC.flare3DEngineInstance.sceneObject.children.length != 0) {
			viewer3DSWC.storeObjectDetails();
		}
	}
	applicationType::DesktopWeb{
		viewer3DSWC.lblPageNo.text="Page" + (viewer3DSWC.objectDetails.length + 1);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObject("currentcanvas", (viewer3DSWC.objectDetails.length + 1));
	
		viewer3DSWC.scrollComponents.objectLayer.visible=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObject("loadicon", "true");
		viewer3DSWC.fluidSimulation=viewer3DSWC.remoteFilePath.substr(viewer3DSWC.remoteFilePath.lastIndexOf("/")+1,viewer3DSWC.remoteFilePath.length);
		
		if(viewer3DSWC.fluidSimulation !="_3d___Fluid_simulation.f3d")
		{
			if (!viewer3DSWC.loadIcon.visible) 
			{
				viewer3DSWC.loadIcon.visible=true;
				viewer3DSWC.loadingLabel.visible=true;
			}
		loadFileToCache(viewer3DSWC.remoteFilePath);
		}
		else
		{
			viewer3DSWC.Waterdemo();
		}
	}
	applicationType::mobile{
		FlexGlobals.topLevelApplication.viewer3DComp.setSharedObject("currentcanvas", (viewer3DSWC.objectDetails.length + 1));
		
		FlexGlobals.topLevelApplication.viewer3DComp.setSharedObject("loadicon", "true");
		if (!viewer3DSWC.loadIcon.visible) 
		{
			viewer3DSWC.loadIcon.visible=true;
			viewer3DSWC.loadingLabel.visible=true;
		}
		loadFileToCache(viewer3DSWC.remoteFilePath);
	}
}

/**
 *
 * @public
 * Invoked when upload complete or download request handler function
 *
 * It download the object.
 *
 * @param filePath of type String
 * @return void
 *
 */
public function loadFileToCache(filePath:String):void 
{
	if (Log.isInfo())
		viewer3DSWC.logger.info("Load file to cache called and path to load Object" + filePath);
	applicationType::DesktopWeb{
		if(viewer3DSWC.fluidSimulation !="_3d___Fluid_simulation.f3d")
		{
			if(!viewer3DSWC.loadIcon.visible &&viewer3DSWC.userRole!="PRESENTER")
			{
				viewer3DSWC.loadIcon.visible=true;
				viewer3DSWC.loadingLabel.visible=true;
			}
		}
		fileDownloaderObj.usingModule=FileManager.MODULE_3D_SHARING;
		viewer3DSWC.disableButtons();
	}
	applicationType::mobile{
		if(!viewer3DSWC.loadIcon.visible &&viewer3DSWC.userRole!="PRESENTER")
		{
			viewer3DSWC.loadIcon.visible=true;
			viewer3DSWC.loadingLabel.visible=true;
		}
		fileDownloaderObj.usingModule=MobileFileManager.MODULE_3D_SHARING;
	}
	viewer3DSWC.remoteFilePath=filePath;
	fileDownloaderObj.download("http://" + ClassroomContext.CONTENT_VIEWER3D + ":" + viewer3DSWC.portViewer3D + "/AVScript/Upload/DownloadFilelist.php?directory=" + filePath);
}

/**
 *
 * @private
 * Invoked when close the filemanger window
 *
 *
 * @param event of type CloseFileComponentEvent
 * @return void
 *
 */
private function onCloseFileComponentEvent(event:CloseFileComponentEvent):void {
	if (event.componentName == CloseFileComponentEvent.FILE_MANAGER) {
		closeFileList();
	}
}

/**
 *
 * @public
 * Invoked when the user click on the remove button in the file list panel
 *
 * It will remove all pop up windows from the application
 *
 * @return void
 *
 */
public function onCloseViewer3DComponentEvent():void {
	applicationType::DesktopWeb{
		var childList:IChildList;
		fileManagerForViewer3D=null;
		if (!isPopOut) {
			childList=FlexGlobals.topLevelApplication.systemManager.popUpChildren;
		} else if (isPopOut) {
			applicationType::desktop{
				childList=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.systemManager.popUpChildren;
			}
		}
		for (var i:int=childList.numChildren - 1; i > 0; i--) {
			var child:IFlexDisplayObject=childList.getChildAt(i) as IFlexDisplayObject;
			PopUpManager.removePopUp(child);
		}
	}
}

/**
 *
 * @public
 * Invoked when the user upload or download object or close the filemanager window
 *
 * @return void
 *
 */
public function closeFileList():void {
	applicationType::DesktopWeb{
		onCloseViewer3DComponentEvent();
	}
	applicationType::mobile{
		if (fileManagerForViewer3D){
			fileManagerForViewer3D.close();
		}
	}
}
applicationType::mobile{
	/**
	 * @private
	 *
	 * To disable fileManager button
	 *
	 * @param event of Event
	 * @return void
	 */
	private function modifyCalloutVisibility(event:Event):void{
		btnListingServerFiles.enabled=true;
	}
	/**
	 * @public
	 *
	 * Update the layout based on the user type
	 *
	 * @param isPresenter holds the value of whether user is presenter or not
	 * @return void
	 */
	private function updateControls(userRole:String):void{
		if (userRole == Constants.VIEWER_ROLE){
			btnListingServerFiles.includeInLayout=false;
			btnListingServerFiles.visible=false;
			btnDelete.includeInLayout=false;
			btnDelete.visible=false;
			closeFileList()
		}else{
			btnListingServerFiles.includeInLayout=true;
			btnListingServerFiles.visible=true;
			btnDelete.includeInLayout=true;
			btnDelete.visible=true;
			closeFileList()
		}
	}
}