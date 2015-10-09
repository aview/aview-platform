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
 * File			: FileManagerAS.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *
 * The Filemanger component is a custom component for managing the file operations. 
 * This component will take over all the file operation like deletion,upload, etc.
 * This Component fired some  custom events for file managing.This is the source file
 * for FileManger.mxml
 *
 * 
 */

import edu.amrita.aview.common.components.fileManager.ExcludedFileOperation;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.ImageButton;
	import edu.amrita.aview.common.components.fileManager.FolderCreation;
	import edu.amrita.aview.common.components.fileManager.Upload;
	import edu.amrita.aview.common.components.fileManager.XMLLoadedTree;
	import mx.controls.Tree;
}
import edu.amrita.aview.common.components.messageBox.MessageBox;
import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.common.components.fileManager.events.DragFinish;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.FileFilter;


import mx.controls.ProgressBar;
import mx.logging.ILogger;
import mx.events.ListEvent;
import mx.events.MoveEvent;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;
import mx.rpc.events.ResultEvent;
import mx.collections.XMLListCollection;
import spark.components.Image;
applicationType::mobile{
	import edu.amrita.aview.common.components.fileManager.MobileFileManager;
	import mx.rpc.events.FaultEvent;
	import mx.collections.ArrayList;
	import spark.components.Button;
	import edu.amrita.aview.common.components.fileManager.MobileFolderCreation;
	import flash.media.CameraRoll;
}

/**
 * Path+Name of the selected file or folder
 */
private var remoteFilePath:String=""; 
/**
 * Name of the selected file or folder
 */
private var remoteFileName:String=""; 
/**
 * Name of the selected file or folder
 */
private var remoteFolderPath:String=""; 
/**
 * Object for Message box
 */
private var alert:MessageBox;
/**
 * Indicating this variable for File extension
 */
private var fileExtension:String="";
/**
 * Indicating this constant variable for to refer a text which is 'files'
 */
public const xmlFile:String="files"
/**
 * Indicating this constant variable for to refer a text which is 'folder'
 */
public const xmlFolder:String="folder";
/**
 * Indicating this static  constant variable for to refer a text which is 'Document Sharing'.
 */
public static const MODULE_DOCUMENT_SHARING:String="Document Sharing";
/**
 * Indicating this static  constant variable for to refer a text which is 'Video Sharing'.
 */
public static const MODULE_VIDEO_SHARING:String="Video Sharing";
/**
 * Indicating this static  constant variable for to refer a text which is '2D Sharing'.
 */
public static const MODULE_2D_SHARING:String="2D Sharing";
/**
 * Indicating this static  constant variable for to refer a text which is '3D Sharing'.
 */
public static const MODULE_3D_SHARING:String="3D Sharing";
/**
 * Collection of institutes 
 */
[Bindable]
public var institutes:Array=new Array();
/**
 * Collection of courses
 */
[Bindable]
public var courses:Array=new Array();
/**
 * Collection of classes
 */
[Bindable]
public var classes:Array=new Array();
applicationType::DesktopWeb{
	/**
	 * This icon represents for institutes
	 */
	[Bindable]
	[Embed("assets/images/institute.png")]
	public var institutesIcon:Class;
	/**
	 * This icon represents for course
	 */
	[Bindable]
	[Embed("assets/images/course.png")]
	public var coursesIcon:Class;
	
	/**
	 * This icon represents for classes
	 */
	[Bindable]
	[Embed("assets/images/class.png")]
	public var classesIcon:Class;
	/**
	 * This icon represents for files
	 */
	[Bindable]
	[Embed("assets/images/file.png")]
	public var fileIcon:Class;
	/**
	 * This icon represents for folders
	 */
	[Bindable]
	[Embed("assets/images/folder.png")]
	public var folderIcon:Class;
	/**
	 * This icon represents for No documents message
	 */
	[Bindable]
	[Embed("assets/images/No Documents.png")]
	public var noDocumentIcon:Class;
	/**
	 * This icon represents for copy button
	 */
	[Bindable]
	[Embed("assets/images/copy doc.png")]
	public var copydoc:Class;
}
/**
 * Object of Loger class
 */
//Logging class
public var log:ILogger=Log.getLogger("aview.components.filemanagement.FileManagerAS");
/**
 * Information about which module have been used .
 */
public var usingModule:String="";
/**
 * Indicating the root folder of module.Each module have separate root folder
 */
public var rootFolder:String="";
/**
 * The default folder path 
 */
public var defaultFolderPath:String="";
/**
 * Wamp Server IP address 
 */
public var serverIPAddress:String="";
/**
 * to check whether the user selection is folder or not
 * deafult false means the selection is  not in folder
 */
public var isFolderSelected:Boolean=false;
/**
 * Object of FolderCreation class
 */
applicationType::DesktopWeb{
	private var folderCreation:FolderCreation=null;
}
applicationType::mobile{
	private var folderCreation:MobileFolderCreation=null;
}
/**
 * For storing the user's role 
 */
public var userRole:String;
/**
 * Object of Upload class
 */
applicationType::DesktopWeb{
	private var upload:Upload=null;
}
/**
 *  For storing the open nodes as object
 */
private var openNodes:Object=null;
/**
 * For checking exclusion message in a ceratin path
 */
public var exclusions:ExcludedFileOperation=new ExcludedFileOperation();
/**
 * For Collecting the information of institues ,courses and classes
 */
private var pathArr:Array=null;
/**
 * This variable stands for store the  id of institute
 */
private var instituteId:int;
/**
 * * This variable stands for store the  id of course
 */
private var courseId:int;
/**
 * * This variable stands for store the  id of class
 */
private var classId:int;
/**
 * Tooltip text for upload button
 */
[Bindable]
private var uploadTooltip:String;
/**
 * The url of copied file.
 */
[Bindable]
public var sourceURL:String="";
/**
 * The url ,which  is where the file copied to
 */
[Bindable]
public var destURL:String="";
/**
 * The original file name
 */
[Bindable]
public var orgFileName:String="";
/**
 * Type of files
 */
[Bindable]
public var fileType:String="";
/**
 * Indicating this constant variable for to refer a text which is 'Error'
 */
private const ERROR:String="Error";
/**
 * This is the path of common file area
 */
private var centralDocPath:String="";
/**
 * File type ,which is user selected from list
 */
private var type:String="";
/**
 * Tooltip text for close button
 */
applicationType::mobile{
	/**
	 * Check whether selected file/folder is in common library or presenter library
	 */
	private var isCommonLibrary:Boolean=false;
	/**
	 * Holds supported files in an array
	 */
	[Bindable]
	public var filetypeSupported:Array;
	/**
	 * Holds list of files/folder in the format of XML for presenter library
	 */
	[Bindable]
	private var documentList:XMLListCollection;
	/**
	 * Holds list of files for presenter library
	 */
	private var documentListData:ArrayList=new ArrayList();
	/**
	 * Holds list of files for common library
	 */
	private var fileListName:ArrayList=new ArrayList();
	/**
	 * Holds list of institute files in the format of XML for common library
	 */
	[Bindable]
	private var InstituteListName:XMLListCollection;
	/**
	 * To show dummy XML while loading remote files for document sharing
	 */
	public var dummyXMLForDocument:XML=<dirs><files label="Document list is loading, Please wait..." type="initial" /></dirs>;
	/**
	 * To show dummy XML while loading remote files for threeD sharing
	 */
	public var dummyXMLFor3D:XML=<dirs><files label="3DObject list is loading, Please wait..." /></dirs>;
	/**
	 * Holds list of course files in the format of XML for common library
	 */
	[Bindable]
	private var courseListName:XMLListCollection;
	/**
	 * Holds list of class files in the format of XML for common library
	 */
	private var classListName:XMLListCollection;
	/**
	 * Holds target file data in XML
	 */
	private var targetFile:XML;
	/**
	 * CameraRoll object to upload image files
	 */
	private var fileReference:CameraRoll;
	/**
	 * Icon for download to directory button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/downloadTopc.png")]
	public var downloadDiscEnabled:Class;
	/**
	 * Icon for download to directory button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/disabledownloadTopc.png")]
	public var downloadDiscDisabled:Class;
	/**
	 * Icon for common upload button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/upload.png")]
	public var commonUploadEnabled:Class;
	/**
	 * Icon for common upload button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/disableupload.png")]
	public var commonUploadDisabled:Class;
	/**
	 * Icon for common delete button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/delete.png")]
	public var commonDeleteEnabled:Class;
	/**
	 * Icon for common delete button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/disabledelete.png")]
	public var commonDeleteDisabled:Class;
	/**
	 * Icon for common folder creation button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/folder-new.png")]
	public var commonCreationEnabled:Class;
	/**
	 * Icon for common folder creation button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/disablefolder-new.png")]
	public var commonCreationDisabled:Class;
	/**
	 * Icon for common download button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/download.png")]
	public var commonDownloadEnabled:Class;
	/** 
	 * Icon for common download button
	 */
	[Bindable]
	[Embed(source="assets/mobileAssets/disabledownload.png")]
	public var commonDownloadDisabled:Class;
}
applicationType::DesktopWeb{
	[Bindable]
	public var closeBtntip:String="Close My Documents list";
	[Embed(source="assets/images/upload.png")]
	private var fileManageUpload:Class;
	/**
	 * Icon class for upload disable state
	 */
	[Embed(source="assets/images/disableupload.png")]
	private var fileUploadDisable:Class;
	/**
	 * Icon class for download enable state
	 */
	[Embed(source="assets/images/download.png")]
	private var fileManageDwnload:Class;
	/**
	 * Icon class for download disable state
	 */
	[Embed(source="assets/images/disabledownload.png")]
	private var fileDwnloadDisable:Class;
	/**
	 * Icon class for folder creation enable state
	 */
	[Embed(source="assets/images/folder-new.png")]
	private var filecreateBtn:Class;
	/**
	 * Icon class for folder creation disable state
	 */
	[Embed(source="assets/images/disablefolder-new.png")]
	private var createBtnDisable:Class;
	/**
	 * Icon class for folder/file delete enable state
	 */
	[Embed(source="assets/images/delete.png")]
	private var filedeleteBtn:Class;
	/**
	 *  Icon class for folder/file delete disable state
	 */
	[Embed(source="assets/images/disabledelete.png")]
	private var deleteBtnDisable:Class;
	/**
	 *  Icon class for download to disc button's enable state
	 */
	[Embed(source="assets/images/downloadTopc.png")]
	private var dwnloadDiscBtn:Class;
	/**
	 * Icon class for download to disc button's disable state
	 */
	[Embed(source="assets/images/disabledownloadTopc.png")]
	private var dwnloadDiscBtnDisable:Class;
	/**
	 * Icon class for close button
	 */
	[Bindable]
	[Embed(source="assets/images/Medium_close.png")]
	public var CloseIcon:Class;
	/**
	 * Icon class for close button while on getting the mouse focus 
	 */
	[Bindable]
	[Embed(source="assets/images/Medium_close_over.png")]
	public var mouseOverCloseIcon:Class;
}
/**
 * Close buuton image class
 */
private var _closer:Image=new Image();
/**
 * The url of thumbnail files
 */
private var thumbPath:String;
/**
 * Immage icon for close button
 */
applicationType::DesktopWeb{
	[Bindable]
	public var closePng:Class=CloseIcon;
}

/**
 * An array of special charactor for checking in the file names contain any spoecial charctor or not
 */
// AKCR: please change this from array to map, refer to the function that is using this array
public static var spclCharArray:Array=[" ", "~", "!", "@", "#", "$", "%", "^", "&", ",", "*", "(", ")", "'", "+"];
////////////////////////////////////////////////////
//Issue #204 ---START
/**
 * dummy xml for showing the message 'Document list is loading...Please wait...'
 * while file list is loading
 */
public var dummyXML:XML=<dirs><files label="Your file list is loading, Please wait..." type="initial" /></dirs>;
/**
 * To check whether the operation held on personal File area or Not
 * Default false means its in personal area
 */
private var OperationFromCommon:Boolean=false;
/**
 * @public
 * Initilize the filemanger component 
 * 
 */
public function onInitilize():void
{
	applicationType::DesktopWeb{
		if (isSharedLibraryVisible)
		{
			if (!commonTree.hasEventListener(DragFinish.DRAG_FINSISHED))
			{
				commonTree.addEventListener(DragFinish.DRAG_FINSISHED, handleDragFinish);
			}
			closeIconHandler(this.width);
			
		}
		else
		{
			commonArea.includeInLayout=false;
			commonArea.visible=false;
			cpyCan.includeInLayout=false;
			cpyCan.visible=false;
			closeIconHandler(320);
		}
	}
	applicationType::mobile{
		isSharedLibraryVisible=true;
	}
	setUploadBtnToolTip(true, uploadBtn);
	setDownloadBtnToolTip(false, downloadBtn);
	setCreateBtnToolTip(true, createBtn);
	setDeleteBtnToolTip(true, deleteBtn);
	loadFileList();
}

/**
 * @public
 * Setting the download button icon here
 * @param enabled of Type Boolean
 * 
 */
public function setDownloadDiscBtn(enabled:Boolean):void
{
	setDownloadDiscBtnToolTip(enabled, downloadDiscBtn);
	downloadDiscBtn.enabled=enabled;
	// AKCR: use conditional operator
	if (enabled){
		applicationType::DesktopWeb{
			downloadDiscBtn.setStyle("icon", dwnloadDiscBtn);
		}
		applicationType::mobile{
			downloadDiscBtn.setStyle("icon", downloadDiscEnabled);
		}
	} else {
		applicationType::DesktopWeb{
			downloadDiscBtn.setStyle("icon", dwnloadDiscBtnDisable);
		}
		applicationType::mobile{
			downloadDiscBtn.setStyle("icon", downloadDiscDisabled);
		}
	}
	downloadDiscBtn.validateNow();
}

/**
 * @private
 * SHandling the keyboard events here
 * @param event of type KeyboardEvent
 * 
 */
applicationType::DesktopWeb{
	private function keyboaredEventHandeler(event:KeyboardEvent):void
	{
		if (event.charCode == 13)
		{
			expandOrLoad(event);
			
		}
	}
}

/**
 * @public
 * Setting the download button's icon  of common area here
 * @param enabled of type Boolean
 * 
 */
public function setCommonDownloadBtn(enabled:Boolean):void
{
	setDownloadBtnToolTip(enabled, commonDownloadBtn);
	commonDownloadBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			commonDownloadBtn.setStyle("icon", fileManageDwnload);
		}
		applicationType::mobile{
			commonDownloadBtn.setStyle("icon", commonDownloadEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			commonDownloadBtn.setStyle("icon", fileDwnloadDisable);
		}
		applicationType::mobile{
			commonDownloadBtn.setStyle("icon", commonDownloadDisabled);
		}
	}
	commonDownloadBtn.validateNow();
}

/**
 * @public
 * Setting the download button icon for common Area
 * @param enabled of type Boolean
 * 
 */
public function setCommonUploadBtn(enabled:Boolean):void
{
	setUploadBtnToolTip(enabled, commonUploadBtn);
	commonUploadBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			commonUploadBtn.setStyle("icon", fileManageUpload);
		}
		applicationType::mobile{
			commonUploadBtn.setStyle("icon", commonUploadEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			commonUploadBtn.setStyle("icon", fileUploadDisable);
		}
		applicationType::mobile{
			commonUploadBtn.setStyle("icon", commonUploadDisabled);
		}
	}
	commonUploadBtn.validateNow();
}

/**
 * @public
 * Setting the create button icon for common
 * @param enabled of type Boolean
 * 
 */
public function setCommonCreateBtn(enabled:Boolean):void
{
	setCreateBtnToolTip(enabled, commonCreateBtn);
	commonCreateBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			commonCreateBtn.setStyle("icon", filecreateBtn);
		}
		applicationType::mobile{
			commonCreateBtn.setStyle("icon", commonCreationEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			commonCreateBtn.setStyle("icon", createBtnDisable);
		}
		applicationType::mobile{
			commonCreateBtn.setStyle("icon", commonCreationDisabled);
		}
	}
	commonCreateBtn.validateNow();
}

/**
 * @public
 * Setting the delete button icon for common
 * @param enabled of type Boolean
 * 
 */
public function setCommonDeleteBtn(enabled:Boolean):void
{
	setDeleteBtnToolTip(enabled, commonDeleteBtn);
	commonDeleteBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			commonDeleteBtn.setStyle("icon", filedeleteBtn);
		}
		applicationType::mobile{
			commonDeleteBtn.setStyle("icon", commonDeleteEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			commonDeleteBtn.setStyle("icon", deleteBtnDisable);
		}
		applicationType::mobile{
			commonDeleteBtn.setStyle("icon", commonDeleteDisabled);
		}
	}
	commonDeleteBtn.validateNow();
}


/**
 * @public
 * Setting the download button icon
 * @param enabled of type Boolean
 * 
 */
public function setDownloadBtn(enabled:Boolean):void
{
	setDownloadBtnToolTip(enabled, downloadBtn);
	downloadBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			downloadBtn.setStyle("icon", fileManageDwnload);
		}
		applicationType::mobile{
			downloadBtn.setStyle("icon", commonDownloadEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			downloadBtn.setStyle("icon", fileDwnloadDisable);
		}
		applicationType::mobile{
			downloadBtn.setStyle("icon", commonDownloadDisabled);
		}
	}
	downloadBtn.validateNow();
}

/**
 * @public
 * Setting the Upload button icon
 * 
 */
public function setUploadBtn(enabled:Boolean):void
{
	setUploadBtnToolTip(enabled, uploadBtn);
	uploadBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			uploadBtn.setStyle("icon", fileManageUpload);
		}
		applicationType::mobile{
			uploadBtn.setStyle("icon", commonUploadEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			uploadBtn.setStyle("icon", fileUploadDisable);
		}
		applicationType::mobile{
			uploadBtn.setStyle("icon", commonUploadDisabled);
		}
	}
	uploadBtn.validateNow();
}

/**
 * @public
 * Setting the create button icon
 * @param enabled of type Boolean
 * 
 */
public function setCreateBtn(enabled:Boolean):void
{
	setCreateBtnToolTip(enabled, createBtn);
	createBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			createBtn.setStyle("icon", filecreateBtn);
		}
		applicationType::mobile{
			createBtn.setStyle("icon", commonCreationEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			createBtn.setStyle("icon", createBtnDisable);
		}
		applicationType::mobile{
			createBtn.setStyle("icon", commonCreationDisabled);
		}
	}
	createBtn.validateNow();
}

/**
 *@public 
 *  Setting the delete button icon
 * @param enabled of type Boolean
 * 
 */
public function setDeleteBtn(enabled:Boolean):void
{
	setDeleteBtnToolTip(enabled, deleteBtn);
	deleteBtn.enabled=enabled;
	// AKCR: please use conditional operator
	if (enabled)
	{
		applicationType::DesktopWeb{
			deleteBtn.setStyle("icon", filedeleteBtn);
		}
		applicationType::mobile{
			deleteBtn.setStyle("icon", commonDeleteEnabled);
		}
	}
	else
	{
		applicationType::DesktopWeb{
			deleteBtn.setStyle("icon", deleteBtnDisable);
		}
		applicationType::mobile{
			deleteBtn.setStyle("icon", commonDeleteDisabled);
		}
	}
	deleteBtn.validateNow();
}

/**
 * @public
 * Setting the tooltip for upload  button
 * @param enabled of type Boolean
 * @param btn of type ImageButton
 * 
 */
applicationType::DesktopWeb{
	public function setUploadBtnToolTip(enabled:Boolean, btn:ImageButton):void
	{
		// AKCR: please use conditional operator
		if (enabled)
		{
			btn.toolTip="Upload new file";
		}
		else
		{
			btn.toolTip="Uploading is Not Allowed";
		}
	}
	/**
	 * @public
	 * Setting the tooltip for create  button
	 * @param enabled of type Boolean
	 * @param btn of type ImageButton
	 * 
	 */
	public function setCreateBtnToolTip(enabled:Boolean, btn:ImageButton):void
	{
		// AKCR: please use conditional operator
		if (enabled)
		{
			btn.toolTip="Create new remote folder";
		}
		else
		{
			btn.toolTip="Folder creation is Not Allowed";
		}
	}

	/**
	 * @public 
	 * Setting the tooltip for common download button
	 * @param enabled of type Boolean
	 * @param btn of type ImageButton
	 * 
	 */
	public function setDownloadDiscBtnToolTip(enabled:Boolean, btn:ImageButton):void
	{
		// AKCR: please use conditional operator
		if (enabled)
		{
			btn.toolTip="Download this file to your Local Disc";
		}
		else
		{
			btn.toolTip="No Permission to Download this file to your Local Disc";
		}
	}
	/**
	 *@public 
	 * Setting the tooltip for download button
	 * @param enabled of type Boolean
	 * @param btn of type ImageButton
	 * 
	 */
	public function setDownloadBtnToolTip(enabled:Boolean, btn:ImageButton):void
	{
		// AKCR: please use conditional operator
		if (enabled)
		{
			btn.toolTip="Download and open remote file";
		}
		else
		{
			btn.toolTip="Downloading and opening is Not Allowed";
		}
	}

	/**
	 * @public 
	 * Setting the tooltip for delete button
	 * @param enabled of type Boolean
	 * @param btn of type ImageButton
	 * 
	 */
	public function setDeleteBtnToolTip(enabled:Boolean, btn:ImageButton):void
	{
		// AKCR: please use conditional operator
		if (enabled)
		{
			btn.toolTip="Delete remote folder/file";
		}
		else
		{
			btn.toolTip="Deletion is Not Allowed";
		}
	}
}
/**
 * @public
 * Setting the tooltip for close button
 * @return String
 * 
 */
public function toolTipChange():String
{
	return "Close My file List"

}
/**
 * @public  
 * Handling the file copying from Personal area to Common area
 * @param docPath of type String
 * @param centralDocPath of type String
 * 
 */
private function handleCopyFile(docPath:String, centralDocPath:String):void
{
	var pathMsg:String=verifyPaths(docPath, centralDocPath);
	if (pathMsg == "ok")
	{
		sourceURL="../../" + docPath
		applicationType::DesktopWeb{
			openNodes=commonTree.openItems;
		}
		//RGCR: Why are we replacing like this.
		// AKCR: this logic is duplicated in several other places. Need to centralize all instances
		centralDocPath=centralDocPath.replace("./../../../../", "../../");
		var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CHECKEXISTANCE)
		this.dispatchEvent(event);
	}
	else
	{
		MessageBox.show(pathMsg, "Information", MessageBox.MB_OK, this);
	}
}


/**
 *@public 
 * Handling copying through button
 * 
 * 
 */
public function moveByBtn():void
{
	var myDocPath:String="";
	applicationType::DesktopWeb{
		if (fileList.selectedItem != null && commonTree.selectedItem != null)
		{
			myDocPath=fileList.selectedItem.@path[0];
			type=commonTree.selectedItem.name();
			centralDocPath=commonTree.selectedItem.@path[0];
			handleCopyFile(myDocPath, centralDocPath);
		}
		else if (fileList.selectedItem == null && commonTree.selectedItem != null)
		{
			MessageBox.show("Please select the source file", "Information", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO)
		}
		else if (fileList.selectedItem != null && commonTree.selectedItem == null)
		{
			MessageBox.show("Please select the destination location", "Information", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO)
		}
		else
		{
			MessageBox.show("Please select the correct source and destinations", "Information", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		}
	}
	
	// AKCR: is the following IF condition needed?
	if (Log.isDebug()) log.debug(myDocPath + "--" + centralDocPath);
}

/**
 * @private
 * show a message showing the file copying process
 * @param event of DragFinish
 * 
 */
private function handleDragFinish(event:DragFinish):void
{
	
	var myDocPath:String="";
	myDocPath=fileList.selectedItem.@path[0];
	centralDocPath=event.dropPath;
	
	var d:Number=centralDocPath.search(".swf");
	var f:Number=centralDocPath.search("_sfp__");
	if (d != -1 || f != -1)
	{
		var i:int=centralDocPath.lastIndexOf("/");
		centralDocPath=centralDocPath.slice(0, i);
	}
	handleCopyFile(myDocPath, centralDocPath);
}

/**
 * @public 
 * Replacing the special charactor from filename
 * @param fileFolder of type String
 * @param parent of type Sprite
 * @return string
 * 
 */
public static function replaceSpecialChars(fileFolder:String, parent:Sprite):String
{
	// AKCR: instead of arrays, can you use a HashMap? This will avoid the inner for loop
	var special:Boolean=false;
	for (var a:int=0; a < fileFolder.length; a++)
	{
		for (var b:int=0; b < spclCharArray.length; b++)
		{
			if (fileFolder.charAt(a) == spclCharArray[b])
			{
				fileFolder=fileFolder.replace(fileFolder.charAt(a), "_");
				special=true;
			}
		}
	}
	if (special)
	{
		MessageBox.show("Your file name has been changed to '" + fileFolder + " ' due to some special characters found in the file name", "Information", MessageBox.MB_OK, parent, null, null, MessageBox.IC_INFO);
	}
	return fileFolder;
}

//RGCR: What is the use of this method..
/**
 * @public  
 * Handling the close button's position and icon here 
 * @param width of type Number
 * 
 */
public function closeIconHandler(width:Number):void
{
	applicationType::DesktopWeb{
		this.addElement(_closer);
		_closer.right=5;
		_closer.top=-25;
		//_closer.y = 8;	
		_closer.useHandCursor=true;
		_closer.buttonMode=true;
		_closer.toolTip=toolTipChange();
		_closer.addEventListener(MouseEvent.MOUSE_OUT, closer_mouseOutHandler);
		_closer.addEventListener(MouseEvent.MOUSE_OVER, closer_mouseOverHandler);
		_closer.addEventListener(MouseEvent.CLICK, closeFileList);
		_closer.source=closePng;
		_closer.useHandCursor=false;
	}
}

/**
 * @public 
 * This is the handler for tree's changes
 * @param event of type ListEvent
 * @return void
 */
applicationType::DesktopWeb{
	private function changeHandler(event:ListEvent):void
	{
		var targetTree:Tree=event.target as Tree;
		var item:XML=XML(targetTree.selectedItem);
	}
}

/**
 * @public 
 * Exclude operation check for folder deletion
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFolderDeletion(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER, ExcludedFileOperation.COMPARE_METHOD_FULL, customErrorMessage);
}

/**
 * @public 
 * Exclude operation check for folder deletion
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFolderDeletionStartingWith(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER, ExcludedFileOperation.COMPARE_METHOD_STARTS_WITH, customErrorMessage);
}

/**
 * @public 
 * Exclude operation check for folder creation
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFolderCreation(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_CREATE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER, ExcludedFileOperation.COMPARE_METHOD_FULL, customErrorMessage);
}

/**
 * @public 
 * Exclude operation check for folder creation
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFolderCreationStartingWith(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_CREATE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER, ExcludedFileOperation.COMPARE_METHOD_STARTS_WITH, customErrorMessage);
}

/**
 * @public 
 * Exclude operation check for file deletion
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFileDeletion(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FILE, ExcludedFileOperation.COMPARE_METHOD_FULL, customErrorMessage);
}

/**
 * @public 
 * Exclude operation check for file deletion
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFileDeletionStartingWith(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FILE, ExcludedFileOperation.COMPARE_METHOD_STARTS_WITH, customErrorMessage);
}

/**
 * @public  
 * Exclude operation check for file creation
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFileCreation(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_CREATE, ExcludedFileOperation.COMPARE_CONTENT_FILE, ExcludedFileOperation.COMPARE_METHOD_FULL, customErrorMessage);
}

/**
 * @public 
 * Exclude operation check for file creation
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFileCreationStartingWith(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_CREATE, ExcludedFileOperation.COMPARE_CONTENT_FILE, ExcludedFileOperation.COMPARE_METHOD_STARTS_WITH, customErrorMessage);
}

/**
 * @public 
 * Exclude operation checking in file Path for deletion
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFilePathDeletion(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FILE_PATH, ExcludedFileOperation.COMPARE_METHOD_FULL, customErrorMessage);
}

/**
 * @public 
 *  Exclude operation checking in file Path Prefix for deletion
 * @param filePattern of type String
 * @param customErrorMessage of type String
 * 
 */
public function excludeFolderPathDeletionPrefixOf(filePattern:String, customErrorMessage:String):void
{
	addExcludedFileOperation(filePattern, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER_PATH, ExcludedFileOperation.COMPARE_METHOD_PREFIX, customErrorMessage);
}

/**
 * @public
 *  Exclude operation checking in file operation
 * @param filePattern of type String
 * @param operation of type String
 * @param fileType of type String
 * @param comparisonType of type 
 * @param args
 * 
 */
public function addExcludedFileOperation(filePattern:String, operation:String, fileType:String, comparisonType:String, ... args):void
{
	var customErrorMessage:String=null;
	if (args.length > 0)
	{
		customErrorMessage=args[0];
	}
	exclusions.addExcludedFileOperation(filePattern, operation, fileType, comparisonType, customErrorMessage);
}
private function isFolder(xml:XML):Boolean
{
	if(xml.name()==xmlFolder)
		return true;
	else
		return false;
}
/**
 * function for getting current selected file/folder name and path.
 */
/**
 * @private 
 * This will invoked while the user selected an item at tree list
 * @param event of type Event
 * 
 */
private function selection(event:Event):void
{	
	var xmlList:XML=XML(event.currentTarget.selectedItem);
	isFolderSelected=isFolder(xmlList);
	var selectionEvent:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.SELECTION);
	selectionEvent.selectedItem=XML(event.currentTarget.selectedItem);
	selectionEvent.selectedArea="PersonalArea";
	this.dispatchEvent(selectionEvent);
}

/**
 * @private 
 * This will invoked while the user slected an item at tree list in common area
 * @param event of type Event
 * 
 */
private function selectionInCommon(event:Event):void
{
	var selectionEvent:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.SELECTION);
	selectionEvent.selectedItem=XML(event.currentTarget.selectedItem);
	selectionEvent.selectedArea="SharedArea";
	this.dispatchEvent(selectionEvent);
}

/**
 * @private 
 * For getting the full folder path of loaded document
 * @param filePath of type String
 * @return String
 * 
 */
private function getFolderPath(filePath:String):String
{
	var folderPath:String="";
	// AKCR: please change the "/" to a varibale :PATH_DELIMITER (to achieve poratbility)
	var lastIdx:int=filePath.lastIndexOf("/", filePath.length);
	if (lastIdx != -1)
	{
		folderPath=filePath.substr(0, lastIdx);
	}
	return folderPath;

}
applicationType::DesktopWeb{
	/**
	 * @private 
	 *  Here the data will reflected while user have made any changes in 
	 * file lists from server
	 * @param event of ListEvent
	 * 
	 */
	private function treeChanged(event:ListEvent):void
	{
		var targetTree:Tree=event.target as Tree;
		var item:XML=XML(targetTree.selectedItem);
	}



	/**
	 * @private 
	 * This function for expand a nod if user select a folder other wise
	 * it will be download to aview
	 * @param event of type Event
	 * 
	 */
	private function expandOrLoad(event:Event):void
	{
		var s:XMLLoadedTree=event.currentTarget as XMLLoadedTree;
		if (!isFolderSelected)
		{
			requestDownload();
		}
		else
		{
			expand(s);
		}
	}
	
	/**
	 * @private 
	 * This function for expanding the folder node
	 * @param s of type XMLLoadedTree
	 * 
	 */
	private function expand(s:XMLLoadedTree):void
	{
		if (!s.isItemOpen(s.selectedItem))
		{
			s.expandItem(s.selectedItem, true);
		}
		else
		{
			s.expandItem(s.selectedItem, false);
		}
	}
}

/**
 * @private 
 * For local downloading
 * 
 */
private function downloadToLocalDisc():void
{
	//this.dispatchEvent(new DownloadRequestedEvent(remoteFileName,remoteFilePath,"ToLocal"));						
}

/**
 *@private 
 *This will called for file downloading to application
 *
 */
private function requestDownload():void
{
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.DOWLOAD);
	this.dispatchEvent(event);
}

/**
 * @private 
 * for clearing the tooltip when the selection of files and folders changes
 * @param event of type ListEvent
 * 
 */
applicationType::DesktopWeb{
	private function toolTipOut(event:ListEvent):void
	{
		fileList.toolTip="";
	
	}
}

/**
 * @private 
 * For getting the server url path of current selected files
 * @return String
 * 
 */
private function getRemoteFolderPath():String
{
	if (remoteFilePath != "")
	{
		return remoteFilePath;
	}
	else
	{
		return defaultFolderPath;
	}
}

/**
 *@private
 * Function for showing the upload panel
 * 
 *
 */
private function showUpload():void
{
	applicationType::DesktopWeb{
		upload=new Upload();
	}
	if (!this.hasEventListener(MoveEvent.MOVE))
		this.addEventListener(MoveEvent.MOVE, onMove);
	applicationType::mobile{
		currentParentFolder=getRemoteFolderPath();
		initializeUpload();
	}
	applicationType::DesktopWeb{
		this.dispatchEvent(new ContentOperationEvent(ContentOperationEvent.PREINITILIZEUPLOAD));
		upload.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
		upload.addEventListener(ContentOperationEvent.UPLOAD, onUploadInitilize)
		upload.addEventListener(ContentOperationEvent.CHECKEXISTANCE, onCheckFileExistance)
		PopUpManager.addPopUp(upload, this, true, PopUpManagerChildList.POPUP);
		PopUpManager.centerPopUp(upload);
		upload.isPopUp=false;
	}

}

/**
 * @public
 * Here we can set all the necessary  data for uploading process
 * @param fileFileter of type FileFilter
 * 
 */
public function setUploadData(fileFileter:FileFilter):void
{
	applicationType::DesktopWeb{
		upload.currentParentFolder=getRemoteFolderPath();
		upload.serverIPAddress=serverIPAddress;
		upload.txtFilter=fileFileter;
	}
}

/**
 *@private  
 * Initilize the upload process
 *@param ev of type ContentOpertaionEvent
 *
 */
private function onUploadInitilize(ev:ContentOperationEvent):void
{
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.UPLOAD)
	event.fileReference=ev.fileReference;
	this.dispatchEvent(event);
}

/**
 * @private 
 * For checking before upload ,if the file already existing in server or not 
 * @param ev of type ContentOpertaionEvent
 * 
 */
private function onCheckFileExistance(ev:ContentOperationEvent):void
{
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CHECKEXISTANCE)
	this.dispatchEvent(event);
}

/**
 * @public  
 * 
 * @param data of type String
 * 
 */
public function fileExistanceMessage(data:String):void
{
	applicationType::DesktopWeb{
		if (upload)
			upload.fileExistanceMessage(data)
		else
			copyFileToSharedLibrary(data);
	}

}

/**
 *@public
 *
 * 
 * 
 */
public function successUpload():void
{
	applicationType::DesktopWeb{
		PopUpManager.removePopUp(upload);
	}
}

/**
 * @public  
 * @param event of type ResultEvent
 * @return void
 */
private function documentConversionCompleted(event:ResultEvent):void
{
	// AKCR: what is dile?
	if (Log.isDebug()) log.debug("upload dile count....");
}


/**
 *@private 
 * 
 * @param area of type String
 * 
 */
applicationType::DesktopWeb{
	private function openFolderCreation(area:String):void
	{
		// AKCR: please use logical operator
		if (area == "Common")
		{
			OperationFromCommon=true;
		}
		else
		{
			OperationFromCommon=false;
		}
		if (!this.hasEventListener(MoveEvent.MOVE))
			this.addEventListener(MoveEvent.MOVE, onMove);
		folderCreation=new FolderCreation();
		folderCreation.currentParentFolder=getRemoteFolderPath();
		folderCreation.exclusions=exclusions;
		folderCreation.serverIPAddress=serverIPAddress;
		folderCreation.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
		folderCreation.addEventListener(ContentOperationEvent.CREATFOLDER, onFolderCreate)
		PopUpManager.addPopUp(folderCreation, this, true, PopUpManagerChildList.POPUP);
		PopUpManager.centerPopUp(folderCreation);
		folderCreation.isPopUp=false;
	}
	/**
	 * @public
	 * Function for confirming the file deletion.
	 * 
	 * @param area of type String
	 * 
	 */
	private function deleteFile(area:String):void
	{
		var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.DELETE)
		this.dispatchEvent(event);
	}
}
applicationType::mobile{
	private function openFolderCreation(event:MouseEvent):void
	{
		// AKCR: please use logical operator
		if (event.currentTarget.id  == "Common")
		{
			OperationFromCommon=true;
		}
		else if (event.currentTarget.id == "createBtn")
		{
			OperationFromCommon=false;
		}
		if (!this.hasEventListener(MoveEvent.MOVE))
			this.addEventListener(MoveEvent.MOVE, onMove);
		folderCreation=new MobileFolderCreation();
		folderCreation.currentParentFolder=getRemoteFolderPath();
		folderCreation.exclusions=exclusions;
		folderCreation.serverIPAddress=serverIPAddress;
		folderCreation.addEventListener("onCloseFileComponentEvent", onCloseFileComponentEvent);
		folderCreation.addEventListener(ContentOperationEvent.CREATFOLDER, onFolderCreate)
		folderCreation.open(event.target.valueOf());
		folderCreation.isPopUp=false;
		folderCreation.x=FlexGlobals.topLevelApplication.width / 2 - (folderCreation.width / 2);
		folderCreation.y=FlexGlobals.topLevelApplication.height / 2 - (folderCreation.height / 2);
		
	}
	private function deleteFile(event:MouseEvent):void
	{
		var evt:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.DELETE)
		this.dispatchEvent(evt);
	}
}

/**
 *@private 
 * 
 *@param ev of type ContentOpertaionEvent
 *@return void
 */
private function onFolderCreate(ev:ContentOperationEvent):void
{
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CREATFOLDER)
	event.folderName=replaceSpecialChars(ev.folderName, this);
	this.dispatchEvent(event);

}

/**
 *@public
 * 
 */
public function successNewFolder():void
{
	PopUpManager.removePopUp(folderCreation);
	loadFileList();
}

/**
 *@private 
 * @param event of type MoveEvent
 * 
 */
private function onMove(event:MoveEvent):void
{
	applicationType::DesktopWeb{
		if (upload)
		{
			upload.move((this.parent.width / 2 - (upload.width / 2)), (this.parent.height / 2 - (upload.height / 2)));
		}
	}
	applicationType::mobile{
		if (folderCreation)
			folderCreation.move((this.parent.width / 2 - (folderCreation.width / 2)), (this.parent.height / 2 - (folderCreation.height / 2)));
	}
}

/**
 *@private 
 * @param event of type CloseFileComponentEvent
 * 
 */
private function onCloseFileComponentEvent(event:CloseFileComponentEvent):void
{
	// AKCR: please use upload operator
	if (CloseFileComponentEvent.UPLOAD == event.componentName)
	{
		applicationType::DesktopWeb{
			PopUpManager.removePopUp(upload);
		}
	}
	else if (CloseFileComponentEvent.FOLDER_CREATION == event.componentName)
	{
		PopUpManager.removePopUp(folderCreation);
	}
}


/**
 * @public 
 * To check whether the filpath have any exclusion for file operation
 * @param filePath of type String
 * @param fileName of type String
 * @param isFolder of type Boolean
 * @return String
 * 
 */
public function checkExclusionMessage(filePath:String, fileName:String, isFolder:Boolean):String
{
	var exclusionMessage:String="";
	if (isFolder)
	{
		
		exclusionMessage=exclusions.isFileExcluded(fileName, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER);
		if (exclusionMessage != "You cannot delete the root folder!")
		{
			exclusionMessage=exclusions.isFileExcluded(filePath..replace("../..", ""), ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FOLDER_PATH);
			
		}
		
	}
	else
	{
		exclusionMessage=exclusions.isFileExcluded(fileName, ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FILE);
		if (exclusionMessage != "No documents to delete!")
		{
			exclusionMessage=exclusions.isFileExcluded(filePath..replace("../..", ""), ExcludedFileOperation.OPERATION_DELETE, ExcludedFileOperation.COMPARE_CONTENT_FILE_PATH);
			
		}
	}
	return exclusionMessage;

}

/**
 * function for closing the file panel when user click close button 
 * @public 
 * @param event of type MouseEvent
 * 
 */
public function closeFileList(event:MouseEvent):void
{
	_closer.toolTip="";
	this.dispatchEvent(new CloseFileComponentEvent(CloseFileComponentEvent.FILE_MANAGER));
}

public var isSharedLibraryVisible:Boolean=false;

/**
 *@public
 * Function to load file list.
 *
 */
public function loadFileList():void
{
		var url:String;
		treeXmlListDp=dummyXML.children();
		var event:ContentOperationEvent;
		//RGCR: We should move the button setup code out of this method. This method should not have any thing to do with button setup.
		if (userRole == Constants.PRESENTER_ROLE)
		{
			if (!OperationFromCommon)
				fileList.selectedItem="";
			remoteFileName="";
			remoteFilePath=remoteFolderPath;
			setDownloadBtn(false);
			setUploadBtn(true);
			setCreateBtn(true);
			setDeleteBtn(true);
			event=new ContentOperationEvent(ContentOperationEvent.FILELIST)
			event.rootFolder=rootFolder;
			this.dispatchEvent(event);
			if (isSharedLibraryVisible)
			{
				setCommonDownloadBtn(false);
				setCommonCreateBtn(false);
				setCommonUploadBtn(false);
				setCommonDeleteBtn(false);
				setDownloadDiscBtn(false);
				centralRepXMLList=dummyXML.children();
				event=new ContentOperationEvent(ContentOperationEvent.SHAREDFILELIST);
				this.dispatchEvent(event);
			}
			applicationType::mobile{
				if (usingModule == MobileFileManager.MODULE_3D_SHARING)
				{
					commonArea.includeInLayout=false;
					commonArea.visible=false;
					personalArea.percentWidth=100;
					uploadBtn.visible=false;
					createBtn.visible=false;
					deleteBtn.visible=false;
					documentMoveGroup.includeInLayout=false;
					documentMoveGroup.visible=false;
				}
			}
		}
}

/**
 * @public
 * @param obj of type Object
 *  
 */

public function setFileList(obj:Object):void
{
	var myXML:XML=XML(obj);
	//treeXmlListDp=myXML.children();
	applicationType::DesktopWeb{
		treeXmlListDp=sortXMLByAttribute(myXML.children(),Array.NUMERIC);
	}
	// AKCR: please use AND (&&) instead of nested IF
	if (myXML.root[0])
	{
		if (defaultFolderPath == "")
		{
			defaultFolderPath=myXML.root[0].@path;
		}
	}
	applicationType::mobile{
		treeXmlListDp=sortXMLByAttribute(myXML.children(),Array.NUMERIC);
		documentList=new XMLListCollection(myXML.children());
		documentListData.source=null;
	}

}

/**
 * @public
 * This function for sorting the file list as alphabetical order 
 * @param xml of type XMLList
 * @param options of type Object default=null
 * @return XMLList
 * 
 */
public static function sortXMLByAttribute(xml:XMLList, options:Object = null):XMLList
{
	
	/**store in array to sort on */
	var xmlArray:Array = new Array();
	
	/**Temporary object to store data to be sorted.*/
	var object:Object;
	
	/**create a new XMLList with sorted XML */
	var sortedXmlList:XMLList = new XMLList();	
		for (var i:int = 0; i < xml.length(); i++){
			object = {
				data	: xml[i],
				order 	: xml[i]
			};
			xmlArray.push(object);
		}		
	
	/**sort the array */
	xmlArray.sortOn('order',options);	
	
	for each(var xmlObject:Object in xmlArray ){
		sortedXmlList += xmlObject.data;
	}
	
	return sortedXmlList.copy();
}


/**
 *@private 
 * This is the fault handler for file listing
 * @param obj of the type Object
 * 
 */
private function fileListfaultHandler(obj:Object):void
{
	dummyXML=<dirs><files label="File Listing is failed  due to network issue.Please Try Again..." type="fault"/></dirs>;
	treeXmlListDp=dummyXML.children();
}

/**
 * @public 
 * Here we can set the common shared file list.
 * @param obj
 * 
 */
public function setSharedFileList(obj:Object):void
{
	var myXML:XML=XML(obj);
	if (Log.isDebug()) log.debug("Data loaded.");
	applicationType::DesktopWeb{
		centralRepXMLList=sortXMLByAttribute(myXML.children(),Array.NUMERIC);
		commonTree.doubleClickEnabled=true;
	}
	applicationType::mobile{
		centralRepXMLList=sortXMLByAttribute(myXML.children(),Array.NUMERIC);
		commonFileList.doubleClickEnabled=true;
		InstituteListName=new XMLListCollection(centralRepXMLList.folder);
		fileListName.source=null;
		this.currentState="Institute";
	}
	if (openNodes != null)
	{
		/**Get the XML list with node details of folder that should be reinstated after copying */
		var xList:XMLList=centralRepXMLList..folder.(hasOwnProperty("@id") && ((@id == instituteId && @type == 'institutes') || (@id == courseId && @type == 'courses') || (@id == classId && @type == 'classes')));
		/**Reinstate the folder to which the file was copied/moved */
		applicationType::DesktopWeb{
			commonTree.openItems=xList;
		}
		
	}

}

/**
 * @public
 *Function used to delete an uploaded file or user created folder from the server
 * 
 * 
 */
public function del_file():void
{
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.DELETE)
	this.dispatchEvent(event);
}


/**
 * @private 
 * Initilize the file copying process
 * @param msg of the type String
 * 
 */
private function copyFileToSharedLibrary(msg:String):void
{
	if (msg.indexOf(ERROR) == -1)
	{
		confirmCopyFiletoCommonLibrary(sourceURL, centralDocPath);
	}
	else
	{
		MessageBox.show("Are you sure you want to overwrite this file ?", "Warning", MessageBox.MB_YESNO, this, confirmOverwrite, null, MessageBox.IC_INFO);
	}

}

/**
 * @private 
 * Confirm the copying the file,which is existing  already in server
 * @param event of the type MessageBoxEvent
 * 
 */
private function confirmOverwrite(event:MessageBoxEvent):void
{
	if (event.type == "messageBoxYES")
	{
		confirmCopyFiletoCommonLibrary(sourceURL, centralDocPath);
	}
}

/**
 * @public 
 * Here we are veryfy the path of copying file's source and destination path are valid
 * @param src of type String
 * @param dest of type String
 * @return String
 * 
 */
public function verifyPaths(src:String, dest:String):String
{
	var status:String="ok";
	var arrLen:int;
	var destArray:Array;
	var srcArray:Array;
	var srcArrLen:int;
	var destArrLen:int;
	var srcFileExt:String;
	
	if (src != null && dest != null)
	{
		srcArray=src.split(".");
		srcArrLen=srcArray.length;
		srcFileExt=srcArray[srcArrLen - 1];
		destArray=dest.split("/");
		
		// needs to be changes
		destArrLen=destArray.length;
		
		//RGCR: Where is 13 coming from?
		if (destArrLen <= 13 || type == "files")
		{
			status="Please select the correct  destination folder";
		}
		//RGCR: Below check is already implemented in handleDragFinish method
		// AKCR: please use static constants for the hard-coded strings
		if (srcFileExt != "swf" && (src.indexOf("_sfp__") < 0) && type != "files")
		{
			status="Please select a file from the 'My Documents'";
		}
		//RGCR: Why are we repeating the checks
		if (destArrLen <= 13 && srcFileExt != "swf" && (src.indexOf("_sfp__") < 0) && type != "files")
		{
			status="Please select the correct source file and destination folder";
		}
		
	}
	else
	{
		status="Please select the correct source file and destination folder";
	}
	
	return status;
}

//RGCR: Should be in Document module
//RGCR: Are we copying only the Original documents
//RGCR: We are calling Common librayr some places, shared library some places. We should stick to one name only
/**
 * @public 
 * Here we initilize the process of file copying from personal folder ro sahred folder
 * @param src of type String
 * @param dest of type String
 * 
 */
public function confirmCopyFiletoCommonLibrary(src:String, dest:String):void
{
	var index:Number=dest.search("_sfp__");
	if (index != -1)
	{
		destURL=dest.slice(0, index);
	}
	else
	{
		destURL=dest;
	}
	pathArr=dest.split("/");
	
	//RGCR: Where are these variables used..
	//RGCR: Big potential bug to use the global variables
	instituteId=pathArr[9];
	courseId=pathArr[11];
	classId=pathArr[13];
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.COPY)
	event.sourcePath=src;
	event.destinationPath=dest;
	this.dispatchEvent(event);
	//RGCR: Progress bar code belongs to some other method

}

/**
 *@public 
 * This is the fault handler for file listing
 *@param null
 * 
 * 
 */
public function showErrorInFileList():void
{
	dummyXML=<dirs><files label="File Listing is failed  due to network issue.Please Try Again..." type="fault"/></dirs>;
	treeXmlListDp=dummyXML.children();
}

/**
 *@public 
 * Initilize the progress bar 
 *
 *
 */
public function showCopyProgressing():void
{
	progressBar=new ProgressBar();
	progressBar.height=20;
	progressBar.horizontalCenter=0;
	progressBar.verticalCenter=0
	progressBar.indeterminate=true;
	progressBar.labelPlacement="center";
	progressBar.setStyle("barColor", 0xFF0000);
	this.addElement(progressBar);
	progressBar.label="Copying.....";
}

/**
 * @public 
 * This is the file copying reslut handler
 * @param obj of type Object
 *
 */
public function showCopyFileResult(obj:Object):void
{
	var myXML:XML=XML(obj)
	//RGCR: What does status 1 mean?
	if (myXML.root[0].@status == "1")
	{
		//RGCR: Why are we calling init here..should we be calling loadFileList only? Should we try and avoid it if possible?
		loadFileList()
		progressBar.label=myXML.root[0].@message;
		progressBar.indeterminate=false;
		
	}
	else
	{
		progressBar.label=myXML.root[0].@message;
		progressBar.indeterminate=false;
		return;
	}

}
/**
 * This progress bar shown the progress of file copying
 */
private var progressBar:ProgressBar;

/**
 * @private
 * This function returns a date string which can be appended to HTTPService urls to prevent from caching
 * and make the urls unique every time a request is sent to the server .
 * @return String
 * 
 */
private function getCacheClearDate():String
{
	var appendCacheClear:Date=new Date();
	return appendCacheClear.toString();
}

/**
 * @private 
 * Icon change for close button
 * @param event of type MouseEvent
 * 
 */
private function closer_mouseOverHandler(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		_closer.source=mouseOverCloseIcon;
	}
}

/**
 * @private
 * Icon change for close button
 * @param event of type MouseEvent
 * 
 */
private function closer_mouseOutHandler(event:MouseEvent):void
{
	applicationType::DesktopWeb{
		_closer.source=CloseIcon;
	}
}

/**
 *@private 
 * Icon setting for root elements in file list
 * @param item of type Object
 * @return Class
 */
private function tree_iconFunc(item:Object):Class
{
	var iconClass:Class;
	applicationType::DesktopWeb{
		var nodeType:String=XML(item).@type;
		switch (nodeType)
		{
			case "institutes":
				iconClass=institutesIcon;
				break;
			case "courses":
				iconClass=coursesIcon;
				break;
			case "classes":
				iconClass=classesIcon;
				break;
			case "file":
				iconClass=fileIcon;
				break;
			case "No Documents":
				iconClass=noDocumentIcon;
				break;
			case "initial":
				iconClass=noDocumentIcon;
				break;
			case "fault":
				iconClass=noDocumentIcon;
				break;
			default:
				iconClass=folderIcon;
			
		}
	}
	return iconClass;
}
applicationType::mobile{
	/**
	 * @private
	 * 
	 * Function for Navigating backward from current XMLFilePath.
	 * fileXml contains the entire xmlfilepath,values in documentListData is compared with fileXml.
	 * Parent of the selected xml file is given as Dataprovider for fileList.
	 * Last index of the documentListData can be removed for every backward naviagtion.
	 * 
	 * @param event of mouse event
	 * @return void
	 */
	private function backWardNavigate(event:Event):void
	{
		var selectedItem:XML;
		if (usingModule == MobileFileManager.MODULE_DOCUMENT_SHARING)
		{
			var fileXml:XML=XML(treeXmlListDp);
			selectedItem=fileXml;
		}
		else if (usingModule == MobileFileManager.MODULE_3D_SHARING)
		{
			for (var k:int=0; k < 2; k++)
			{
				var fileXml:XML=XML(treeXmlListDp[k]);
				var data:String=documentListData.source[documentListData.length - 1].data;
				for each (var xmlList:XML in fileXml..folder)
				{
					if (xmlList.@path == data)
					{
						var item:XML=xmlList.parent();
						selectedItem=fileXml;
						break;
					}
				}
			}
		}
		backwardNavigation(selectedItem);
	}
	/**
	 * @private
	 * 
	 * To navigate to previous folder path
	 * 
	 * @param selectd folder/file
	 * @return void
	 */
	private function backwardNavigation(selectedItem:XML):void
	{
		if ((documentListData.length - 1).toString() != "0")
		{
			for (var j:int=documentListData.length - 1; j > -1; j--)
			{
				var data:String=documentListData.source[j].data;
				for each (var xmlList:XML in selectedItem..folder)
				{
					if (xmlList.@path == data)
					{
						var item:XML=xmlList.parent();
						break;
					}
				}
				documentListData.removeItem(documentListData.source[j]);
				break;
			}
			var fileListProvider:XMLListCollection=new XMLListCollection(item.children());
			fileList.dataProvider=fileListProvider;
		}
		else
		{
			fileList.dataProvider=documentList;
			btnNavigateBack.visible=false;
			documentListData.source=null;
		}
	}
	/**
	 * @private
	 * 
	 * Result handler for fileList service, to get presenter library folder path
	 * 
	 * @param event holds the values of remote files
	 * @return void
	 */
	private function fileListResultHandler(event:ResultEvent):void
	{
		var myXML:XML=XML(event.result);
		treeXmlListDp=myXML.children();
		documentList=new XMLListCollection(myXML.children());
		documentListData.source=null;
	}
	/**
	 * @private
	 * 
	 * Result handler for deleteService to refresh the file list
	 * 
	 * @param event of ResultEvent
	 * @return void
	 */
	private function refresh(event:ResultEvent):void
	{
		remoteFilePath="";
		loadFileList();
	}
	/**
	 * @private
	 * 
	 * Result handler for copyFile service to refresh the central library file list
	 * 
	 * @param event holds the values of remote files
	 * @return void
	 */
	private function copyFileServiceResultHandler(event:ResultEvent):void
	{
		var myXML:XML=XML(event.result)
		if (myXML.root[0].@status == "1")
		{
			onInitilize();
//			init();
		}
		else
		{
			event.preventDefault();
			return;
		}
	}
	/**
	 * @private
	 * 
	 * Result handler for centralRep service to get central library folder path
	 * 
	 * @param event holds the values of remote files
	 * @return void
	 */
	private function centralRepHTTPServiceResultHandler(event:ResultEvent):void
	{
		var myXML:XML=XML(event.result);
		trace("Data loaded.");
		centralRepXMLList=myXML.children();
		InstituteListName=new XMLListCollection(centralRepXMLList.folder);
		fileListName.source=null;
		this.currentState="Institute";
	}
	/**
	 * @private
	 * 
	 *  Result handler for checkFileExists service to move files to central library
	 * 
	 * @param event holds the value of whether file is exist or not
	 * @return void
	 */
	private function checkFileExistResultHandler(event:ResultEvent):void
	{
		var result:String=String(event.result);
		if (result.indexOf(ERROR) == -1)
		{
			moveToCentralLibrary(sourceURL, centralDocPath);
		}
		else
		{
			MessageBox.show("Are you sure you want to overwrite this file ?", "Warning", MessageBox.MB_YESNO, this, confirmOverwriteToLibrary, confirmOverwriteToLibrary, MessageBox.IC_ALERT);
		}
	}
	/**
	 * @private
	 * 
	 * Fault handler for checkFileExists service
	 * 
	 * @param event of FaultEvent
	 * @return void
	 */
	private function checkFileExistFaultHandler(event:FaultEvent):void
	{
		trace(event.type.toString());
	}
	/**
	 * @public
	 * 
	 * To move files to central library
	 * 
	 * @param src holds source filename
	 * @param dest holds destination folder path
	 * @return void
	 */
	public function moveToCentralLibrary(src:String, dest:String):void
	{
		var d:int=src.lastIndexOf("@@-OriginalDocs-@@");
		sourceURL="../" + src.slice(0, d);
		var c:Number=dest.search("_sfp__");
		if (c != -1)
		{
			destURL=dest.slice(0, c);
		}
		else
		{
			destURL=dest;
		}
		pathArr=dest.split("/");
		instituteId=pathArr[9];
		courseId=pathArr[11];
		classId=pathArr[13];
		copyFileService.url=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/CentralRep/scripts/copyFile.php?date=" + getCacheClearDate());
		copyFileService.send();
		MessageBox.show("File Copied to CommonLibrary is Completed", "INFO", MessageBox.MB_OK, this, fileCopyCompleted, null, MessageBox.IC_INFO);
	}
	/**
	 * @private
	 * 
	 * Confirmation for overwrite the file
	 * 
	 * @param event of MessageBoxEvent
	 * @return void
	 */
	private function confirmOverwriteToLibrary(event:MessageBoxEvent):void
	{
		if (event.type.toString() == MessageBoxEvent.MESSAGEBOX_YES)
		{
			moveToCentralLibrary(sourceURL, centralDocPath);
		}
		else
		{
			btnCopyFile.enabled=true;
		}
	}
	/**
	 * @private
	 * 
	 * Confirmation for moving file to central library
	 * 
	 * @param event of MessageBoxEvent
	 * @return void
	 */
	private function fileCopyCompleted(event:MessageBoxEvent):void
	{
		if (event.type.toString() == MessageBoxEvent.MESSAGEBOX_OK)
		{
			btnCopyFile.enabled=true;
		}
	}
	/**
	 * @private
	 * 
	 * Set upload button tool tip
	 * 
	 * @param enabled holds true or false
	 * @param btn holds instance of button
	 * @return void
	 */
	private function setUploadBtnToolTip(enabled:Boolean, btn:Button):void
	{
		if (enabled)
		{
			if (usingModule == MODULE_DOCUMENT_SHARING)
			{
				btn.toolTip="Upload new document";
			}
		}
		else
		{
			btn.toolTip="Uploading is Not Allowed";
		}
	}
	/**
	 * @private
	 * 
	 * Set download button tool tip
	 * 
	 * @param enabled holds true or false
	 * @param btn holds instance of button
	 * @return void
	 */
	private function setDownloadBtnToolTip(enabled:Boolean, btn:Button):void
	{
		if (enabled)
		{
			if (usingModule == MODULE_DOCUMENT_SHARING)
			{
				btn.toolTip="Download and open remote document";
			}
		}
		else
		{
			btn.toolTip="Downloading and opening is Not Allowed";
		}
	}
	/**
	 * @private
	 * 
	 * Set folder creation button tool tip
	 * 
	 * @param enabled holds true or false
	 * @param btn holds instance of button
	 * @return void
	 */
	private function setCreateBtnToolTip(enabled:Boolean, btn:Button):void
	{
		if (enabled)
		{
			btn.toolTip="Create new remote folder";
		}
		else
		{
			btn.toolTip="Folder creation is Not Allowed";
		}
	}
	/**
	 * @private
	 * 
	 * Set delete button tool tip
	 * 
	 * @param enabled holds true or false
	 * @param btn holds instance of button
	 * @return void
	 */
	private function setDeleteBtnToolTip(enabled:Boolean, btn:Button):void
	{
		if (enabled)
		{
			if (usingModule == MODULE_DOCUMENT_SHARING)
			{
				btn.toolTip="Delete remote folder/document";
			}
		}
		else
		{
			btn.toolTip="Deletion is Not Allowed";
		}
	}
	/**
	 * @private
	 * 
	 * Function for displaying files in library.
	 * set listProvider as a Dataprovider for fileList.
	 * 
	 * @param event holds the values of the current xmlFilePath.
	 * @return void
	 */
	private function documentFileList(event:Event):void
	{
		btnNavigateBack.visible=true;
		var xml:XML=XML(event.currentTarget.selectedItems);
		if (xml.name() == "folder" || xml.name() == "root")
		{
			var listProvider:XMLListCollection=new XMLListCollection(xml.children());
			fileList.dataProvider=listProvider;
			var obj:Object={data: xml.@path};
			documentListData.addItem(obj);
		}
	}
	/**
	 * @private
	 * 
	 * Function for switching states from Institute to Course State.
	 * set courseListName as a Dataprovider for commonFileList in CourseState.
	 * 
	 * @param event holds the values of the current xmlFilePath.
	 * @return void
	 */
	private function instituteFileList(event:Event):void
	{
		this.currentState="Course";
		var institutefileindex:int=event.target.selectedIndex;
		courseListName=new XMLListCollection(centralRepXMLList.folder[institutefileindex].folder);
		commonFileList.dataProvider=courseListName;
		if (courseListName.children() != null)
		{
			commonFileList.addEventListener(Event.CHANGE, courseFileList);
		}
	}
	/**
	 * @private
	 * 
	 * Function for navigating forward in CommonLibrary filepath and setting current selected values as Dataprovider for commonFileList.
	 * current filepath can be stored in fileListName arraylist.
	 * 
	 * @param event holds the values of the current xmlFilePath.
	 * @return void
	 */
	private function courseFileList(event:Event):void
	{
		var xml:XML=XML(event.currentTarget.selectedItems);
		targetFile=xml;
		if (xml.name() == "folder")
		{
			classListName=new XMLListCollection(xml.children());
			commonFileList.dataProvider=classListName;
			var obj:Object={data: xml.@path};
			fileListName.addItem(obj);
			if (xml.children() != null)
			{
				commonFileList.addEventListener(Event.CHANGE, courseFileList);
			}
		}
		else
		{
			commonFileList.addEventListener(MouseEvent.CLICK, commonFileListClickHandler);
		}
	}
	/**
	 * @private
	 * 
	 * Function for Loading files in SWFLoader.
	 * After loading files,removes MouseClick Event.
	 * 
	 * @param event of mouse event
	 * @return void
	 */
	private function commonFileListClickHandler(event:MouseEvent):void
	{
		commonFileList.removeEventListener(MouseEvent.CLICK, commonFileListClickHandler);
	}
	/**
	 * @private
	 * 
	 * Function for Navigating backward from  current XMLFilePath.
	 * centralXml contains the entire xmlfilepath,values in fileListName is compared with centralxml.
	 * Parent of the selected xml file is given as Dataprovider for commonFileList.
	 * Last index of the fileListName can be removed for every backward naviagtion.
	 * 
	 * @param event of mouse event
	 * @return void
	 */
	private function commonBackWardNavigate(event:Event):void
	{
		targetFile=null;
		var centralXml:XML=XML(centralRepXMLList);
		if (fileListName.length.toString() != "0")
		{
			for (var i:int=fileListName.length - 1; i > -1; i--)
			{
				var data:String=fileListName.source[i].data;
				for each (var xmlList:XML in centralXml..folder)
				{
					if (xmlList.@path == data)
					{
						var item:XML=xmlList.parent();
						break;
					}
				}
				fileListName.removeItem(fileListName.source[i]);
				break;
			}
			var fileListProvider:XMLListCollection=new XMLListCollection(item.children());
			commonFileList.dataProvider=fileListProvider;
			//If user navigates to course selection
			if (fileListProvider[0].@type == "courses")
			{
				setCommonUploadBtn(false);
				setCommonCreateBtn(false);
				setCommonDeleteBtn(false);
				setCommonDownloadBtn(false);
			}
			else if (fileListProvider[0].@type == "institutes")
			{
				btnPrevious.visible=false;
			}
		}
		else
		{
			//If user navigates to Institute selection
			this.currentState="Institute";
			setCommonUploadBtn(false);
			setCommonCreateBtn(false);
			setCommonDeleteBtn(false);
			setCommonDownloadBtn(false);
			btnPrevious.visible=false;
		}
		//If user has selected file, disable the downloadDIsc button.
		if (!isFolderSelected)
		{
			setDownloadDiscBtn(false);
		}
	}
	/**
	 * @private
	 * 
	 * Set downloadToDirectory button tool tip
	 * 
	 * @param enabled holds true or false
	 * @param btn holds instance of button
	 * @return void
	 */
	private function setDownloadDiscBtnToolTip(enabled:Boolean, btn:Button):void
	{
		if (enabled)
		{
			btn.toolTip="Download the document to your Local Disc";
		}
		else
		{
			btn.toolTip="No Permission to Download the document to your Local Disc";
		}
	}
}