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
 * File			: MobileFileManagerAS.as
 * Module		: FileManager
 * Developer(s)	: Salil George, Ganesan A
 * Reviewer(s)	: Pradeesh
 *
 */

/**
 * Importing various components
 */
import components.filemanagement.asfiles.CloseFileComponentEvent;
import components.filemanagement.asfiles.ExcludedFileOperation;
import components.filemanagement.asfiles.FolderCreationSuccess;

import edu.amrita.aview.core.shared.components.mobileComponents.messageBox.MobileMessageBox;

import flash.events.SoftKeyboardEvent;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

/**
 *  Used to check whether folder is exist
 */
private const ERROR:String="Error";
/**
 * Holds remote root folder path
 */
public var currentParentFolder:String="";
/**
 * Holds inastance of ExcludedFileOperation
 */
public var exclusions:ExcludedFileOperation;
/**
 * Holds remote server IP
 */
public var serverIPAddress:String="";
/**
 * Holds module name
 */
public var usingModule:String;

/**
 * @private
 * 
 * To create new folder
 * we can creating folder inside a folder
 * folder name duplication is also checked here
 * 
 * @param null
 * @return void
 */
private function createFolder():void
{
	serverIPAddress=ClassroomContext.CONTENT_DOCUMENT;
	//Checks for null string
	txtFolderName.text=StringUtil.trim(txtFolderName.text);
	if (txtFolderName.text == "")
	{
		return;
	}
	else if (txtFolderName.text.charAt(0) == "." || txtFolderName.text.charAt(txtFolderName.text.length - 1) == ".") //Folder name can't start or end with a .
	{
		MobileMessageBox.show("Folder name should not start or end with a dot(.)", "INFO", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_INFO);
		return;
	}
	//Check for Exclusions
	var exclusionMessage:String=exclusions.isFileExcluded(txtFolderName.text, ExcludedFileOperation.OPERATION_CREATE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER);

	if (exclusionMessage != "")
	{
		MobileMessageBox.show(exclusionMessage, "INFO", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_INFO);
	}
	//Temporary Commented
	else
	{
		createRemoteFolder(currentParentFolder + "/" + components.filemanagement.MobileFileManager.replaceSpecialChars(txtFolderName.text, "Folder", this));
	}
}

/**
 * @private
 * 
 * To close the new folder component
 * 
 * @param null
 * @return void
 */

private function folderCancel():void
{
	this.dispatchEvent(new CloseFileComponentEvent(CloseFileComponentEvent.FOLDER_CREATION));
}

/**
 * @private
 * 
 * To invoke fodler creation service
 * 
 * @param folderName holds value of folder name to create
 * @return void
 */
private function createRemoteFolder(folderName:String):void
{
	folderName=folderName.replace("./../../../../", "../../");
	createFolderService.url="http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/createDirectory.php?folderName=" + folderName;
	createFolderService.send();
}

/**
 * @private
 * 
 * Result handler for folder craetion service, to check file existance and create folder
 * 
 * @param event holds value of whether folder is exist or not
 * @return void
 */
private function createFolderResultHandler(event:ResultEvent):void
{
	var result:String=String(event.result);
	if (result.indexOf(ERROR) != -1)
	{
		MobileMessageBox.show("This folder name already exists.!\nPlease provide another name.", "WARNING", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_ALERT);
	}
	else
	{
		this.dispatchEvent(new FolderCreationSuccess());
	}
}

/**
 * @private
 * 
 * Fault handler for folder craetion
 * 
 * @param event holds fault message
 * @return void
 */
private function faultHandler(event:FaultEvent):void
{
	//TEACHER_REMOTE_FILE_FOLDER_LIST #3.2
	//showing error message if folderPath.php is not executed 
	trace(event.fault.toString());
	MobileMessageBox.show("Application Error (Error Number: S/DS/0001-" + event.fault.errorID + ")\nPlease contact A-VIEW Administrator.", "INFO", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_ALERT);
}
