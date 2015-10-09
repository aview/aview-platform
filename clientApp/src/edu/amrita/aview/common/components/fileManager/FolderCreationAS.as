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
 * File			: FolderCreationAS.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 * The FolderCreation component is a custom component for Folder create functionality. 
 * This component will take all the initiative for  folder creation.
 * This Component fired some  custom events for folder creation.This is the source file
 * for FolderCreation.mxml
 *
 */
applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.fileManager.FileManager;
}
import edu.amrita.aview.common.components.messageBox.MessageBox;
import mx.utils.StringUtil;
import mx.core.FlexGlobals;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import edu.amrita.aview.common.components.fileManager.ExcludedFileOperation;
import edu.amrita.aview.common.components.fileManager.events.FolderCreationSuccess;
import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;


/**
 * Indicating the Selected file's parent folder                                                                                                                                                                                                                                                                                                                                                                             
 */
public var currentParentFolder:String="";
/**
 * Stands for checking the Exclusions
 */
public var exclusions:ExcludedFileOperation;
/**
 * Contant for Error messages
 */
private const ERROR:String="Error";
/**
 * Indicating the IP address of server which has been connecting 
 */
public var serverIPAddress:String="";

/**
 * @private
 *
 * function for creating new folder
 * we can creating folder inside a folder
 * folder name duplication is also checked here
 * 
 */
private function createFolder():void
{
	/////////////////////////////////////
	/**Checks for null string */						
	fName.text=StringUtil.trim(fName.text);
	if (fName.text == "")
	{
		return;
	}
	else if (fName.text.charAt(0) == "." || fName.text.charAt(fName.text.length - 1) == ".") //Folder name can't start or end with a .
	{
		MessageBox.show("Folder name should not start or end with a dot(.)", "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		return;
	}
	/**Check for Exclusions */
	var exclusionMessage:String=exclusions.isFileExcluded(fName.text, ExcludedFileOperation.OPERATION_CREATE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER);
	
	if (exclusionMessage != "")
	{
		MessageBox.show(exclusionMessage, "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
	}
	else
	{
		applicationType::DesktopWeb{			
			//createRemoteFolder(currentParentFolder + "/" + FileManager.replaceSpecialChars(fName.text, this));
			createRemoteFolder(FileManager.replaceSpecialChars(fName.text, this));
			
		}
		applicationType::mobile{
			createRemoteFolder(currentParentFolder + "/" + MobileFileManager.replaceSpecialChars(fName.text, this));
		}
	}
}

/**
 *
 * @private
 *
 * this function invokes when user clicks on cancel button on the new folder panel
 * for closing the new folder panel
 * 
 */

private function folderCancel():void
{
	this.dispatchEvent(new CloseFileComponentEvent(CloseFileComponentEvent.FOLDER_CREATION));
}

/**
 * @private 
 * The creation process will handled here
 * Content service dispatched here.
 * @param folderName of type String
 * 
 */
private function createRemoteFolder(folderName:String):void
{
	folderName=folderName.replace("./../../../../", "../../");
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CREATFOLDER)
	event.folderName=folderName;
	this.dispatchEvent(event);
}
applicationType::mobile{
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
			MessageBox.show("This folder name already exists.!\nPlease provide another name.", "WARNING", MessageBox.MB_OK, this, null, null, MessageBox.IC_ALERT);
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
		MessageBox.show("Application Error (Error Number: S/DS/0001-" + event.fault.errorID + ")\nPlease contact A-VIEW Administrator.", "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_ALERT);
	}
}

