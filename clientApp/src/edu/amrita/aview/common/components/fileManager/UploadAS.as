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
 * File			: UploadAS.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 * The Upload component is a custom component for file uploading functionality. 
 * This component will take all the initiative for file uploading process.
 * This Component fired some  custom events for upload progressing.This is the source file
 * for Upload.mxml
 *
 *
 */
//VGCR:-Variable Description
//VGCR:-Function Description 
import context.ContextManager;

import edu.amrita.aview.common.components.fileManager.FileManager;
import edu.amrita.aview.common.components.fileManager.events.CloseFileComponentEvent;
import edu.amrita.aview.common.components.fileManager.events.ContentOperationEvent;
import edu.amrita.aview.common.components.fileManager.events.UploadCompletedEvent;
applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.messageBox.MessageBox;
	import edu.amrita.aview.common.components.messageBox.events.MessageBoxEvent;
}
applicationType::mobile{
	import edu.amrita.aview.core.shared.components.mobileComponents.messageBox.MobileMessageBox;
	import edu.amrita.aview.core.shared.components.mobileComponents.messageBox.events.MessageBoxEvent;
}
import edu.amrita.aview.common.service.content.ContentService;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.twoDSharing.V2DEvent;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Button;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 * 
 */
public var isofflineUpload:Boolean=false;
/**
 * 
 */
public var currentParentFolder:String="";
/**
 * 
 */
public var serverIPAddress:String="";
/**
 * 
 */
public var usingModule:String="";
/**
 * 
 */
[Embed(source="assets/images/Medium_close.png")]
[Bindable]
public var closePng:Class;
/**
 * 
 */
private var textureNameArray:Array=new Array();
/**
 * 
 */
private var arrayToPHP:Array=new Array();
/**
 * 
 */
private var uploadPath2D:String;
/**
 * 
 */
private var newPath:String;
/**
 * the current file which is uploading
 * @default null
 */
[Bindable]
private var uploadFile:String="";

/**
 * For changing the interface depends on module name
 */
[Bindable]
private var objectUpload:Boolean;
[Bindable]
private var object2DUpload:Boolean;
/**For changing the interface depends on module name*/
[Bindable]
private var documetUpload:Boolean;
/**For setting the label depends on the module selection */
[Bindable]
private var labelText:String;
/**Setting the upload button text depends on the module name*/
[Bindable]
private var uploadButtonText:String;
/**
 * 
 */
private var uploadClose:Button=new Button();
/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.components.filemanagement.UploadAS");
/**
 */
private var fileExtention:String="";
/**A String variable for storing xml as string*/
private var texturePath:String;
/**
 * 
 */
private var textureName:String;
/**
 * 
 */
private var fileName:String="";

/**Platform specific imports and variables*/
applicationType::desktop
{
	import flash.filesystem.File;
	
	private var sourceFile:File;
	private var newFile:File;
	private var fileReference:File;
	private var fileRefForUploadTexture:File;
}
applicationType::web
{
	/**File is not available for web. So we changed File to FileReference*/
	private var fileReference:FileReference;
	private var fileRefForUploadTexture:FileReference;
}

/**
import edu.amrita.aview.threedsharing.Viewer3DComponent;
 * function for starting upload file process
 */
////////////////////////////
// Changed method name from startUpload to initializeUpload
// Issue #127 ---START
[Bindable]
public var txtFilter:FileFilter;

/**
 * @private
 * 
 * @return void
 */
private function initializeUpload():void
{
	applicationType::web
	{
		/**File is not available for web. So we changed File to FileReference */
		fileReference=new FileReference();
	}
	applicationType::desktop
	{
		fileReference=new File();
	}
	fileReference.browse([txtFilter]);
	fileReference.addEventListener(Event.CANCEL, cancelHandler);
	fileReference.addEventListener(Event.SELECT, selectHandler);
	fileReference.addEventListener(Event.OPEN, openHandler);
	//--END----------------------------------------------------------------------------------
}

/**
 * Icon for cancel icon
 */
[Bindable]
[Embed(source="assets/images/cancel.png")]
public var cancel1:Class;
[Bindable]
public var cancelicon:Class;
/**
 * 
 */
private var packageName:String="";
/**
 * 
 */
private var i:int;
/**
 * 
 */
private var uploadCount:int=0;
/**
 * 
 */
private var booltextureUploadError:Boolean=false;
/**
 * 
 */
private var updated:Boolean=false;

/**
 * @private
 *
 * function for closing the upload panel
 * 
 */
private function closeUpload():void
{
	//RTCR: Should remove the below check if the commented code is not needed.
	if (fileReference)
	{
		//fileReference.removeEventListener(Event.CANCEL,cancelHandler);
		//fileReference.removeEventListener(Event.SELECT, selectHandler);
		//fileReference.removeEventListener(Event.OPEN, openHandler);
		//fileReference.removeEventListener(Event.COMPLETE, completeHandler);
		//fileReference=null;
	}
	this.dispatchEvent(new CloseFileComponentEvent(CloseFileComponentEvent.UPLOAD));
}

/**
 * function for starting upload file process
 */
////////////////////////////
// Changed method name from startUpload to initializeUpload
// Issue #127 ---START


/////////////////////////////////
// Added the following method and moved some lines of code from selectHandler()
// Issue #127 ---START
/**
 *@private
 *
 *
 * 
 */
private function startUpload():void
{
	if (uploadFileName.text == "")
	{
		applicationType::DesktopWeb{
			MessageBox.show("Please choose a file to upload", "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		}
		applicationType::mobile{
			MobileMessageBox.show("Please choose a file to upload", "INFO", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_INFO);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////
	//TEACHER_UPLOAD_NEW_DOC #3.1
	//If size of the user selected file is equal to zero, 
	//then alert will show with description and
	//then apply the upload panel closing effect 
	//the TextInupt for displaying the selected file name(UploadFileName) is set to null
	//visibility of upload panel is set to false
	//Upload button visibility is to set true
	//WARNING: Upload panel may be still in memory
	//--START--------------------------------------------------------------------------------	
	else if (fileReference != null && fileReference.size == 0)
	{
		applicationType::DesktopWeb{
			MessageBox.show("Your file cannot be uploaded because its size is zero bytes!", "WARNING", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		}
		applicationType::mobile{
			MobileMessageBox.show("Your file cannot be uploaded because its size is zero bytes!", "WARNING", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_INFO);
		}
		closeUpload();
	}
	else if (fileReference != null && fileReference.size > 41943040)
	{
		applicationType::DesktopWeb{
			MessageBox.show("File more than 40MB in size cannot be uploaded!", "WARNING", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
		}
		applicationType::mobile{
			MobileMessageBox.show("files more than 40MB in size cannot be uploaded!", "WARNING", MobileMessageBox.MB_OK, this, null, null, MobileMessageBox.IC_INFO);
		}
	}
	else
	{
		var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CHECKEXISTANCE, true, false)
		this.dispatchEvent(event);
	}
	//--END----------------------------------------------------------------------------
}

// Issue #127 ---END

/**
 * @private 
 * @param event of type Event
 * 
 */
private function cancelHandler(event:Event):void
{
	applicationType::desktop
	{
		if (tempNativepath != "")
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
	//RTCR: See whether we can merge the following blocks minimizing redundant code. 
	applicationType::web
	{
		//Added this check to avoid the issue with '.type' return null value in Mac os.
		if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
		{
			/**Store uploaded file name */
			var uploadedFileName:String=event.target.name;
			/**Get fileExtension from file name*/
			fileExtention=uploadedFileName.substring(uploadedFileName.lastIndexOf("."), uploadedFileName.length);
		}
		else //For all other OSs
		{
			//'.type' returns file extension with dot (.) infront of extension (Eg:.jpg)
			fileExtention=event.target.type;
			isConversionComplete=false;
		}
		//'.' is removed from after '*' in following code.
		if (txtFilter.extension.indexOf("*" + fileExtention.toLowerCase()) == -1)
		{
			MessageBox.show("Selected file " + event.target.name + " is not of a valid file type", "WARNING", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
			resetUploadFileDetails();
		}
		else
		{
			uploadFile=FileManager.replaceSpecialChars(event.target.name, this);
			setUploadFileDetails();
		}
	}
	applicationType::desktop
	{
		fileExtention=event.target.extension;
		isConversionComplete=false;
		if (txtFilter.extension.indexOf("*." + fileExtention.toLowerCase()) == -1)
		{
			MessageBox.show("Selected file " + event.target.name + " is not of a valid file type", "WARNING", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
			resetUploadFileDetails();
		}
		else
		{
			uploadFile=FileManager.replaceSpecialChars(event.target.name, this);
			setUploadFileDetails();
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
private function resetUploadFileDetails():void
{
	uploadFile="";
	fileName=uploadFile;
	tempNativepath="";
}
//RTCR: Need to change the function name
/**
 *@private 
 *
 *
 */
private function setUploadFileDetails():void
{
	fileExtention=fileExtention.toLowerCase();
	uploadFile=uploadFile.substring(0, (uploadFile.lastIndexOf(".") + 1)) + fileExtention;
	fileName=uploadFile;
}
/**
 * @private
 * @param resultEvent of type ResultEvent
 * loading the xmlfile
 * 
 */
private function loadXmlFileResultHandler(resultEvent:ResultEvent):void
{
	textureNameArray=findingTextureName(resultEvent.message.body.toString());
	if (textureNameArray.length == 0)
	{
		this.dispatchEvent(new UploadCompletedEvent(uploadFile, fileExtention, currentParentFolder + "/" + uploadFile, animated));
	}
	else
	{
		applicationType::desktop
		{
			for (i=0; i < textureNameArray.length; i++)
			{
				var textureFullPath:String=fileReference.nativePath;
				texturePath=textureNameArray[i];
				textureFullPath=textureFullPath.substr(0, textureFullPath.lastIndexOf("\\"));
				arrayToPHP[i]=textureName;
				uploadCount++;
				fileRefForUploadTexture=new File()
				fileRefForUploadTexture.addEventListener(Event.COMPLETE, textureUploadComplete);
				fileRefForUploadTexture.addEventListener(IOErrorEvent.IO_ERROR, textureUploadError);
				if (texturePath.indexOf("file:\\") > -1)
				{
					texturePath=texturePath.substr(texturePath.indexOf("\\") + 3, texturePath.length);
					fileRefForUploadTexture.nativePath=texturePath;
				}
				else if (texturePath.indexOf(":") > 0)
				{
					fileRefForUploadTexture.nativePath=texturePath;
				}
				else
				{
					textureFullPath=textureFullPath + "/" + texturePath;
					fileRefForUploadTexture.nativePath=textureFullPath;
				}
				if (texturePath != "")
				{
					var request:URLRequest=new URLRequest();
					// AKCR: how do we build the URL for SSL i.e https:// ?
					// AKCR: please move such hard-coded strings to constants file
					request.url=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/upload.php?folderName=" + currentParentFolder + "&module=" + usingModule + "&folder=" + uploadFile);
					fileRefForUploadTexture.upload(request);
				}
			}
		}
	}
}

/**
 * @private 
 * @param event of type IOErrorEvent
 * 
 */
private function textureUploadError(event:IOErrorEvent):void
{
	fileReference.removeEventListener(IOErrorEvent.IO_ERROR, textureUploadError);
	/*if (uploadCount == textureNameArray.length && !booltextureUploadError)
	{
		// AKCR: please move such hard-coded strings to constants file
		// AKCR: the logic to build the upload path should not be in this function. 
		// AKCR: the code should be something like:
		// AKCR:  var params = "&content=nil"
		// AKCR:  foo.url = FileService.getUploadPath() + PATH_SEPARATER + filename + params 
		xmlUpdatingService.url=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/updateCollada.php?fileName=" + currentParentFolder + "/_3d___" + uploadFile + "/" + fileName + "&content=nil");
		xmlUpdatingService.send();
		booltextureUploadError=true;
	}*/
	
	var deletedae:HTTPService=new HTTPService();	
	deletedae.url=encodeURI("http://" + serverIPAddress+":"+ClassroomContext.portWAMP + "/AVScript/Upload/deleteDirectory.php?filePath="+currentParentFolder+"/_3d___"+uploadFile);
	deletedae.send();
	
	MessageBox.show("Uploading failed, Object texture file is missing");
	FlexGlobals.topLevelApplication.mainContainerComp.classroomComp.viewer3DComp.onCloseViewer3DComponentEvent();
}

/**
 * @private 
 * @param event of type Event
 * 
 */
private function textureUploadComplete(event:Event):void
{
	fileRefForUploadTexture.removeEventListener(Event.COMPLETE, textureUploadComplete);
	if (uploadCount == textureNameArray.length && !booltextureUploadError && !updated)
	{
		// AKCR: please refer to comments from the previous function on building this URL.
		xmlUpdatingService.url=encodeURI("http://" + serverIPAddress + ":" + ClassroomContext.portWAMP + "/AVScript/Upload/updateCollada.php?fileName=" + currentParentFolder + "/_3d___" + uploadFile + "/" + fileName + "&content=" + arrayToPHP);
		xmlUpdatingService.send();
		updated=true;
	}
}

/**
 * @private 
 * @param event of type Event
 * 
 */
private function colladaUpdateCompleted(event:Event):void
{
	this.dispatchEvent(new UploadCompletedEvent(uploadFile, fileExtention, currentParentFolder + "/" + uploadFile, animated));
}

/**
 * @private 
 * @param colladaContent of type String
 * @return Array
 */
private function findingTextureName(colladaContent:String):Array
{
	/**Regular expression variable used to remove the schema from the xml file*/
	var xmlnsPattern:RegExp;
	/**A string variable for storing the new xml file in for of string*/
	var namespaceRemovedXML:String;
	/**An XML Object for storing the new xml file after updating the texture name*/
	var xmlNew:XML=new XML();
	var originalTexture:String;
	xmlnsPattern=new RegExp("xmlns[^\"]*\"[^\"]*\"", "gi");
	namespaceRemovedXML=colladaContent.replace(xmlnsPattern, "");
	xmlNew=new XML(namespaceRemovedXML);
	for (i=0; i < xmlNew.library_images.image.length(); i++)
	{
		textureNameArray[i]=xmlNew.library_images.image[i].init_from;
	}
	return textureNameArray;
}

/**
 * @private
 * @param event of type Event
 * open event handler, it shows the uploading progress message
 * 
 */
private function openHandler(event:Event):void
{
	/////////////////////////////////////////////////////
	//TEACHER_UPLOAD_NEW_DOC #9
	//showing uploading progress message
	//rotating icon is visible
	//close button on the upload panel(uploadClose) is disabled
	//--START-------------------------------------------
	
	message.text="Please wait while your file is getting uploaded...";
	progressIcon.visible=true;
	cancelicon=cancel1;
	uploadClose.enabled=false;
	//--END---------------------------------------------
}
/**
 * 
 */
private var uploadingFileQueue:ArrayCollection;
/**
 * 
 */
private var checkFileExistsCount:Number=0;
/**
 * This boolean indicate for whether the conversion is completed or not
 */
private var isConversionComplete:Boolean=false;
/**
 *  function for completing the upload file process
 */
private var uploadFileCount:Number=0;
/**
 * 
 */
private var tempTimer:Timer;

/**
 * @private 
 * @param event of type Event
 * 
 */
private function completeHandler(event:Event):void
{
	var dataSource:String;
	/**Browse button is enabled*/
	/**remove the event listener for select,open and complete events */
	fileReference.addEventListener(Event.CANCEL, cancelHandler);
	fileReference.removeEventListener(Event.SELECT, selectHandler);
	fileReference.removeEventListener(Event.OPEN, openHandler);
	fileReference.removeEventListener(Event.COMPLETE, completeHandler);
	downloadNotifier();
}

/**
 * @private 
 * @param ev of type TimerEvent
 * 
 */
private function tempList(ev:TimerEvent):void
{
	message.text="";
	upload.enabled=true;
	this.dispatchEvent(new UploadCompletedEvent(uploadFile, fileExtention, currentParentFolder + "/" + uploadFile, animated));
	tempTimer.stop();
	tempTimer.removeEventListener(TimerEvent.TIMER, tempList);

}

/**
 * 
 */
private const ERROR:String="Error";
/**
 * 
 */
private var contentService:ContentService=new ContentService();
/**
 *@private 
 * @param filePath of type String
 * 
 */
private function checkFileExistance(filePath:String):void
{
	filePath=filePath.replace("./../../../../", "../../");
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.CHECKEXISTANCE)
	this.dispatchEvent(event);

}

/**
 * @public 
 * @param data of type String
 * 
 */
public function fileExistanceMessage(data:String):void
{
	if (data.indexOf(ERROR) == -1)
	{
		confirmUpload();
	}
	else
	{
		
		MessageBox.show("Are you sure you want to overwrite this file ?", "Warning", MessageBox.MB_YESNO, this, confirmOverwrite, null, MessageBox.IC_INFO);
		
	}
}

/**
 * @private 
 * @param event of type KeyboardEvent
 * 
 */
private function keyboaredEventHandeler(event:KeyboardEvent):void
{
	if (event.charCode == 13)
	{
		if (event.currentTarget.label == "Browse" && event.currentTarget.enabled)
		{
			initializeUpload()
			return;
		}
		if (event.currentTarget.label == uploadButtonText && event.currentTarget.enabled)
		{
			startUpload();
			return;
		}
		if (event.currentTarget.label == "Close" && event.currentTarget.enabled)
		{
			closeUpload();
			return;
		}
		
	}
}

/**
 * @private
 * 
 * 
 */
private function downloadNotifier():void
{
	message.text="";
	upload.enabled=true;

}

/**
 * @private 
 * @param event of type MessageBoxEvent
 * 
 * 
 */
private function confirmOverwrite(event:MessageBoxEvent):void
{
	if (event.type == "messageBoxYES")
	{
		confirmUpload();
	}
}

/**
 * function used for uploading a file after the confirmation
 * Here we checking the spaces between folder names
 */
private var uploadUrl:String;
/**
 * 
 */
private var animated:Boolean=false;

/**
 *@public
 *
 *
 * 
 */
public function confirmUpload():void
{
	var event:ContentOperationEvent=new ContentOperationEvent(ContentOperationEvent.UPLOAD, true, false)
	event.fileReference=fileReference;
	this.dispatchEvent(event);
	startUploadBtn.enabled=false;
	upload.enabled=false;
}

/**
 *@private 
 * @param e of type V2DEvent
 * This function is used to handle 2D Viewer supported and unsupported
 * file upload
 * 
 */
private function viewer2dUploadHelper(e:V2DEvent):void
{
	
	ContextManager.viewer2DComp.uploadHelper2D.removeEventListener(V2DEvent.SUPPORTED_FILE, viewer2dUploadHelper)
	if (e.data == "true")
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
	//TEACHER_REMOTE_FILE_FOLDER_LIST #3.2
	/**showing error message if folderPath.php is not executed */
	if (Log.isError()) log.error(event.fault.toString());
	MessageBox.show("Application Error (Error Number: S/UL/0001-" + event.fault.errorID + ")\nPlease contact A-VIEW Administrator.", "ERROR", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
}

/**
 * @protected 
 * 
 * 
 */
//PNCR: function name lowerCamelCase
//PNCR: function description
protected function panel1_creationCompleteHandler():void
{
	closeIconHandler();
	uploadFileName.setFocus();
}

/**
 *@protected
 * 
 * 
 */
protected function uploadFileName_creationCompleteHandler():void
{
	uploadFileName.setFocus();
}

/**
 * @public
 * 
 * 
 */
public function closeIconHandler():void
{
	this.addElement(uploadClose);
	uploadClose.width=18;
	uploadClose.height=18;
	uploadClose.right=7;
	uploadClose.top=-25;
	
	uploadClose.toolTip="Close";
	uploadClose.addEventListener(MouseEvent.CLICK, closeFileList);
	uploadClose.setStyle('icon', closePng);
	uploadClose.useHandCursor=false;
}

/**
 * @private 
 * @param ev of type MouseEvent
 * 
 */
private function closeFileList(ev:MouseEvent):void
{
	closeUpload();

}