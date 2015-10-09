// ActionScript file
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.lms.LocalPlayback;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.mxml.HTTPService;
import mx.utils.ObjectProxy;

import spark.components.TitleWindow;

private var _selectedFilePath:String="";
public var localPlayBack:LocalPlayback=null;
private var folderNames:ArrayCollection=null;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.lms.BrowseLocalFilePathHandler.as");

public function get selectedFilePath():String{
	return _selectedFilePath;
}

protected function btnBrowse_clickHandler(event:MouseEvent):void{
	applicationType::desktop{
		/*File and FileStream not available for web.*/
		var file:File=new File();
		if (lstBrowseFolders.selectedItem != null)
			file=new File(lstBrowseFolders.selectedItem.path);
		file.browseForDirectory("");
		file.addEventListener(Event.SELECT, onSelectFolderLocation);
	}
}

private function onSelectFolderLocation(event:Event):void{
	applicationType::desktop{
		/* File and FileStream not available for web.*/
		var selectedFolder:File=event.target as File;
		txtFilePath.text=selectedFolder.nativePath;
		_selectedFilePath=txtFilePath.text;
		if (_selectedFilePath.substr(-1) != "\\")
			_selectedFilePath+="\\";
		localPlayBack.selectedFolder=_selectedFilePath;
		localPlayBack.addEventListener(LocalPlayback.DOWNLOAD, onDownloadComplete);
		if (btnPlay.visible)
			btnPlay.enabled=true;
		if (btnDownload.visible){
			btnDownload.enabled=true;
			localPlayBack.addFolderToXML(selectedFolder.name, selectedFolder.nativePath);
		}
	}
}

private function folderOverwriteHandler(event:MessageBoxEvent):void{
	localPlayBack.downloadZipFiles();
	pgbDownload.visible=true;
}

private function folderNoOverwriteHandler(event:MessageBoxEvent):void{
	txtFilePath.text="";
	_selectedFilePath="";
	localPlayBack.selectedFolder=_selectedFilePath;
	btnPlay.enabled=false;
	btnPlay.enabled=false;
}

private function onDownloadComplete(event:Event):void{
	lblQuestion.visible=true;
	btnDownload.includeInLayout=false;
	btnPlay.visible=true;
	btnPlay.enabled=true;
	pgbDownload.label="Download Complete";
	pgbDownload.visible=false;
	txtFilePath.text=_selectedFilePath + localPlayBack.lectureName;
	_selectedFilePath=txtFilePath.text;
	localPlayBack.selectedFolder=txtFilePath.text;
}

public function enablelblInfo(isEnable:Boolean):void{
	lblInfo.visible=isEnable;
	btnPlay.visible=isEnable;
	btnDownload.visible=!isEnable;
}


protected function btnPlay_clickHandler(event:MouseEvent):void{
	localPlayBack.selectedFolder=_selectedFilePath;
	btnPlay.enabled=false;
	localPlayBack.unzipFiles();
	txtFilePath.text="";
}

protected function btnDownload_clickHandler(event:MouseEvent):void{
	btnDownload.enabled=false;
	applicationType::desktop{
		/*File and FileStream not available for web.*/
		if (new File(_selectedFilePath + localPlayBack.lectureName).exists)
			MessageBox.show("A folder with the name of the selected Lecture already exists in the selected folder." + "\n Do you want to Overwrite it?", "Confirmation", MessageBox.MB_YESNO, null, folderOverwriteHandler, folderNoOverwriteHandler);
		else{
			localPlayBack.downloadZipFiles();
			pgbDownload.visible=true;
		}
	}
	applicationType::web{
		localPlayBack.downloadZipFiles();
		pgbDownload.visible=true;
	}
	txtFilePath.text="";
}

protected function btnCancel_clickHandler(event:MouseEvent):void{
	if (this.owner is TitleWindow)
		(this.owner as TitleWindow).dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
	localPlayBack.stopDownLoading();
}

private function getFolderList():void{
	var folderService:HTTPService=new HTTPService();
	folderService.url="config/folderlist.xml";
	folderService.addEventListener(ResultEvent.RESULT, onLoadComplete);
	folderService.addEventListener(FaultEvent.FAULT, onFaultService);
	folderService.send();
}

private function onLoadComplete(event:ResultEvent):void{
	folderNames=new ArrayCollection();
	var obj:Object;
	if (event.result.folders.folder is ObjectProxy){
		if (event.result.folders.folder.name != null){
			obj=new Object();
			obj.name=event.result.folders.folder.name;
			obj.path=event.result.folders.folder.path;
			folderNames.addItem(obj);
		}
		else{
			applicationType::desktop{
				//File and FileStream not available for web.				
				for (var index:int=0; index < File.getRootDirectories().length; index++){
					obj=new Object();
					obj.name=File.getRootDirectories()[index].name;
					obj.path=File.getRootDirectories()[index].nativePath;
					folderNames.addItem(obj);
				}
			}
		}
	}
	else if (event.result.folders.folder is ArrayCollection){
		for (var index1:int=0; index1 < event.result.folders.folder.length; index1++){
			obj=new Object();
			obj.name=event.result.folders.folder[index1].name;
			obj.path=event.result.folders.folder[index1].path;
			folderNames.addItem(obj);
		}
	}
	lstBrowseFolders.dataProvider=folderNames;
}

private function onFaultService(event:FaultEvent):void{
	if(Log.isError()) log.error("lms::BrowseLocalFilePathHandler::onFaultService:" + AbstractHelper.getStaticFaultMessage(event));
	MessageBox.show("Failed to List Folders", "Error");
}

protected function skinnablecontainer1_creationCompleteHandler(event:FlexEvent):void{
	getFolderList();
}
