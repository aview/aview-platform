import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.LectureHelper;
import edu.amrita.aview.core.gclm.helper.StaticDataHelper;
import edu.amrita.aview.core.gclm.vo.LectureVO;
import edu.amrita.aview.core.lms.BrowseLocalFilePath;
import edu.amrita.aview.core.lms.LMSadvanceSearch;
import edu.amrita.aview.core.lms.LocalPlayback;
import edu.amrita.aview.core.playback.AviewPlayer;
import edu.amrita.aview.core.playback.editing.scripts.CloseFileHandler;
import edu.amrita.aview.core.playback.oldPlayback.Aview_Playback;
import edu.amrita.aview.core.shared.audit.AuditConstants;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.AViewDateUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.Capabilities;

import mx.collections.*;
import mx.controls.*;
import mx.core.FlexGlobals;
import mx.events.*;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.*;
import mx.rpc.http.HTTPService;

import spark.components.Button;
import spark.components.TitleWindow;
import spark.components.gridClasses.GridColumn;

/**Platform specific imports*/
applicationType::desktop
{
	import flash.data.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filesystem.*;
	
	import edu.amrita.aview.core.playback.editing.VideoEditing;
	import edu.amrita.aview.core.playback.oldPlayback.Aview_PlaybackDesktop;
	import edu.amrita.aview.core.playback.AviewPlayerDesktop;
}
/** Variable declaration */
[Bindable]
private var recordedLectures:ArrayCollection=new ArrayCollection;

/* *** Swati start *** */
[Bindable]
public var registeredClasses:ArrayCollection=new ArrayCollection;
// v.e changes

[Bindable]
public var editingActiveflag:int=0;

[Bindable]
[Embed(source="assets/images/Search.png")]
public var SearchIcon:Class;

[Bindable]
[Embed(source="assets/images/Refresh.png")]
public var RefreshIcon:Class;

public var isEnableButtonPlay:Boolean=true;
public var isEnableButtonCut:Boolean=true;

private var advanceSearch_Window:LMSadvanceSearch;

//Advanced search window field values
private var date:String=null;
private var lectureKeyWord:String=null;
private var topic:String=null;
public var isLocalPlay:Boolean=false;
private var browseDirectoryControl:BrowseLocalFilePath;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.lms.LMSAs.as");

/**Platform specific variables*/
//Handling Old libraries.
applicationType::web{
	public var design_LMS:Aview_Playback;
	public var player:AviewPlayer;
}

applicationType::desktop{
	public var player:AviewPlayerDesktop;
	public var design_LMS:Aview_PlaybackDesktop;
	public var videoEditor:VideoEditing;
}

private function initApp():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.isPlayback=false;
	callSearchLayout();
	//Fix for issue #17072: Made invisible the video editing button. Since we were not used video editing for web version
	applicationType::web{
		btnCut.visible =false;
		btnCut.includeInLayout = false;
	}
}

private function callSearchLayout():void{
	/* *** Swati start *** */
	lblClass.visible=true;
	cmbClass.visible=true;
	/* *** Swati end *** */
	getRegisteredClasses();
}


private function faultHandler(event:FaultEvent):void{
	if(Log.isError()) log.error("lms::LMSAs::faultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	Alert.show("Fault string: " + event.fault.faultString, "Server Error");
}

private function checkForModerator():void{
	if (recordedLecturesDataGrid.selectedItem != null && cmbClass.selectedItem.isModerator == "Y" && playBackActiveflag == 0 && editingActiveflag == 0){
		btnCut.enabled = true;
	}
	else{
		btnCut.enabled = false;
	}
}

/* Issue NO 445 is fixed */
[Bindable]
public var playBackActiveflag:int=0;
private var advancedsearchflag:int=0;

private var localPlayback:LocalPlayback=null;

private function playVideo(e:Event):void{
	if ((isLocalPlay && e == null) || (e.target.hasOwnProperty("id") && e.target.id == "btnplayVideo") || e.target.hasOwnProperty("columnIndex") || (!e.target.hasOwnProperty("columnIndex") && !e.target.hasOwnProperty("id"))){
		//Alert.show("dataprovider::"+searchResult.toString());
		if (!btnplayVideo.enabled){
			return;
		}
		/*Issue No:500 is fixed  */
		if (cmbClass.selectedIndex == -1 && advancedsearchflag == 0){
			Alert.show("Please select any Course", "Alert", 0, this);
		}
		else{
			if (recordedLecturesDataGrid.selectedItem == null)
				Alert.show("Please select any file from the list", "Alert", 0, this);
			else if (playBackActiveflag == 0 && recordedLecturesDataGrid.selectedItem != null){
				//isLocalPlay=true;
				//	btnCut.enabled = false;
				btnplayVideo.enabled=false;
//				Fix for Bug#15476
//				btnLocalPlayback.enabled=false;
				applicationType::web{
					player=new AviewPlayer();
				}
				applicationType::desktop{
					player=new AviewPlayerDesktop();
					player.open();
					player.maximize();
				}
				
				player.width=Capabilities.screenResolutionX - 50;
				player.height=Capabilities.screenResolutionY - 100;
				if (isLocalPlay == true){
					applicationType::desktop{
						//File method not available for web.
						var selectedFolder:File=new File(localPlayback.selectedFolder);
						var parentFolder:String=selectedFolder.parent.nativePath;
						if (parentFolder.substr(-1) != "\\")
							parentFolder+="\\";
						var localFolderPath:String=localPlayback.selectedFolder;
						//player.aviewPlayerComp.setValues(parentFolder, parentFolder, localFolderPath + "/", parentFolder, selectedFolder.name + "/", selectedFolder.name, parentFolder, isLocalPlay);
					}
				}
				//{					
				//	player.aviewPlayerComp.setValues(dg.selectedItem.recorded_presenter_video_url,dg.selectedItem.recorded_viewer_video_url,
				//	dg.selectedItem.recorded_video_file_path,dg.selectedItem.recorded_content_url,dg.selectedItem.recorded_content_file_path,dg.selectedItem.lecture_topic,
				//	"rtmp://192.168.0.155/vod",isLocalPlay); // Need to change after desktop recording code gets committed
				//}
				else{
					var lecture:LectureVO=recordedLecturesDataGrid.selectedItem as LectureVO;
					var playerComp:Object = null;
					applicationType::web{
						playerComp = player.playerComp;
						//Fix for issue #17071
						player.width=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Library_canvas.width - 10;
						player.height=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Library_canvas.height - 20;
					}
					applicationType::desktop{
						playerComp = player.aviewPlayerComp.playerComp;
					}
					playerComp.setValues(lecture.recordedPresenterVideoUrl, lecture.recordedViewerVideoUrl, lecture.recordedVideoFilePath, lecture.recordedContentUrl, lecture.recordedContentFilePath, lecture.displayName);
				}
				player.x=5;
				player.y=5;
				playBackActiveflag=1;
				playbackStartEventLog(recordedLecturesDataGrid.selectedItem.lectureId);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.isPlayback=true;
				applicationType::desktop{
					//activate() method not available for web.
					player.activate();
				}
				//Fix for issue #17071
				applicationType::web{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Library_canvas.removeAllChildren();
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.Library_canvas.addChild(player);
				}
			}
		}
	}
}

/**
 *
 * @private
 * Audits the "PlaybackStart" action, when the user is starts playing back a lecture/session
 *
 * @param lectureId - Id of the lecture/session
 * @return void
 *
 */
private function playbackStartEventLog(lectureId:String):void
{
	AuditContext.userAction.createAction(AuditConstants.playbackStart, lectureId, null, null);
}

protected function btnDownload_clickHandler(event:MouseEvent):void
{
	if (recordedLecturesDataGrid.selectedIndex == -1)
		MessageBox.show("Please Select a lecture to download", "Warning", MessageBox.MB_OK);
	else if (browseDirectoryControl == null)
		zipDownload();
}

private function enablePlayVideo(e:Event):void{
	if (e.target.hasOwnProperty("columnIndex")){
		if (playBackActiveflag == 0 && editingActiveflag == 0){
			btnplayVideo.enabled=true;
//			Fix for Bug#15476
//			btnLocalPlayback.enabled=true;
		}
		checkForModerator();
		isLocalPlay=false;
	}
}
private function getRegisteredClasses():void{
	var classReg:ClassRegistrationHelper = new ClassRegistrationHelper();
	classReg.getAllRegisteredAndOpenClassesForUser(ClassroomContext.userVO.userId,getAllRegisteredAndOpenClassesForUserResultHandler);
}

public function getActiveCoursesResultHandler(result:ArrayCollection):void{
	registeredClasses.removeAll();
	registeredClasses=result;
}

private function backupAdvancedSearchOptions():void{
	date=advanceSearch_Window.datef.text;
	lectureKeyWord=advanceSearch_Window.keyWord.text;
	topic=advanceSearch_Window.txtTopic.text;
	this.cmbClass.selectedIndex=advanceSearch_Window.cmbClass.selectedIndex;
}

private function initAdvancedSearchOptions():void{
	//Fix for Bug#15198
	advanceSearch_Window.date="";
	advanceSearch_Window.lectureKeyWord=null;
	advanceSearch_Window.topic=null;
	advanceSearch_Window.classSelectedIndex=this.cmbClass.selectedIndex;
}

private function resetAdvancedSearchOptions():void{
	date=null;
	lectureKeyWord=null;
	topic=null;
}


private function getAdvancedSearchOption():void{
	btnAdvancedSearch.enabled=false;
	advanceSearch_Window=new LMSadvanceSearch();
	PopUpManager.addPopUp(advanceSearch_Window, this, true, null);
	advanceSearch_Window.cmbClass.dataProvider=registeredClasses;
	advanceSearch_Window.search.addEventListener(MouseEvent.CLICK, callAdvanceSearch);
	advanceSearch_Window.addEventListener(FlexEvent.REMOVE, onAdvancedSearchClose);
	initAdvancedSearchOptions();
	PopUpManager.centerPopUp(advanceSearch_Window);
}

private function onAdvancedSearchClose(event:FlexEvent):void{
	btnAdvancedSearch.enabled=true;
}

private function callAdvanceSearch(eve:MouseEvent):void{
	btnAdvancedSearch.enabled=true;
	backupAdvancedSearchOptions();
	PopUpManager.removePopUp(advanceSearch_Window);
	var searchDate:Date = new Date();
	//Fix for Bug#15205:Start
	if(advanceSearch_Window.datef.text != null)
	{
		searchDate = DateField.stringToDate(advanceSearch_Window.datef.text,"DD/MM/YYYY");
	}
	else
	{
		searchDate = null;
	}
	
	(new LectureHelper()).searchRecordedLectures(cmbClass.selectedItem.aviewClass.classId,advanceSearch_Window.txtTopic.text,
		advanceSearch_Window.keyWord.text,searchDate,getRecordedLecturesResultHandler);
	//Fix for Bug#15205:End
}

private function formatDate(item:Object, data:Object):String
{
	var sDate:String=AViewDateUtil.formatDateTime(item.startDate,item.startTime);
	return sDate;
}

private function searchLecture():void{
	if(Log.isDebug()) log.debug("Selected Item: " + cmbClass.selectedItem);
	if(Log.isDebug()) log.debug("Selected Item Index: " + cmbClass.selectedIndex);
	
	(new LectureHelper()).getRecordedLectures(cmbClass.selectedItem.aviewClass.classId,getRecordedLecturesResultHandler)
	resetAdvancedSearchOptions();
}

public function getRecordedLecturesResultHandler(lectures:ArrayCollection):void{
	recordedLectures.removeAll();
	recordedLectures = lectures;
	if (recordedLectures.length <= 0){
		MessageBox.show("Sorry no recorded files in this course. Please select any other course", "INFO", MessageBox.MB_OK, this, null, null, MessageBox.IC_INFO);
	}
	else{
		btnLibRefresh.enabled=true;
	}
}

public function getAllRegisteredAndOpenClassesForUserResultHandler(classes:ArrayCollection):void
{
	registeredClasses.removeAll() ;
	registeredClasses=classes;
}

private function formatStartDate(item:Object, column:GridColumn):String{
	return sparkDateFormatter.format(item.lecture.startDate);
}

private function lib_Refresh():void{
	searchLecture();
}

/**
 * This method is called from playbackWindowCloseHandler() in PlaybackCode.as
 * This activates data grid once the playback window is closed.
 *
 * @return void
 * */
public function killPlayback():void{
	//mainLMSCanvas.enabled=true;
	if (isEnableButtonPlay){
		btnplayVideo.enabled=true;
//		Fix for Bug#15476
//		btnLocalPlayback.enabled=true;
		playBackActiveflag=0;
	}
	checkForModerator();
	player=null;
	isEnableButtonPlay=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.isPlayback=false;
	if (!isLocalPlay)
		playbackEndEventLog(recordedLecturesDataGrid.selectedItem.lectureId);

}

/**
 *
 * @private
 * Audits the "PlaybackEnd" action, when the user is ends playing back a lecture/session
 *
 * @param lectureId - Id of the lecture/session
 * @return void
 *
 */
private function playbackEndEventLog(lectureId:String):void
{
	AuditContext.userAction.createAction(AuditConstants.playbackEnd, lectureId, null, null);
}

private function date_sortCompareFunc(itemA:Object, itemB:Object):int{
	return AViewDateUtil.date_sortCompareFunc(itemA.startDate, itemB.startDate);
}

/**
 * This function is called when user clicks on "Edit Video" button
 * This disables datagrid and opens the edit window.
 *
 * @return void
 * */
private function cutRecordedDetails():void{
	if (cmbClass.selectedIndex == -1 && advancedsearchflag == 0)
		Alert.show("Please select any Course", "Alert", 0, this);
	else{
		if (recordedLecturesDataGrid.selectedItem == null)
			Alert.show("Please select any file from the list", "Alert", 0, this);
		else if (editingActiveflag == 0 && recordedLecturesDataGrid.selectedItem != null){
			//	btnCut.enabled = false;
			btnplayVideo.enabled=false;
			selPresenterURL=recordedLecturesDataGrid.selectedItem.recordedPresenterVideoUrl.toString();
			selViewerURL=recordedLecturesDataGrid.selectedItem.recordedViewerVideoUrl.toString();
			selVideoFilePath=recordedLecturesDataGrid.selectedItem.recordedVideoFilePath.toString();
			selContentURL=recordedLecturesDataGrid.selectedItem.recordedContentUrl.toString();
			selContentFilePath=recordedLecturesDataGrid.selectedItem.recordedContentFilePath.toString();
			selLectureTopic=recordedLecturesDataGrid.selectedItem.displayName.toString();
			
			editingActiveflag=1;
			applicationType::desktop{
				videoEditor=new VideoEditing();
				videoEditor.open();
				videoEditor.width=1200;
				videoEditor.height=690;
				videoEditor.addEventListener(CloseFileHandler.CLOSED_VIDEO_EDITING, reloadingVideoEditing);
				videoEditor.aviewPlayer.editingActive=true;
				videoEditor.aviewPlayer.setValues(selPresenterURL,selViewerURL,selVideoFilePath,selContentURL,selContentFilePath,selLectureTopic);
				editingStartEventLog(recordedLecturesDataGrid.selectedItem.lectureId);
			}
		}
		
	}
}

/**
 *
 * @private
 * Audits the "EditingStart" action, when the moderator starts editing of a lecture
 *
 * @param lectureId - Id of the lecture/session
 * @return void
 *
 */
private function editingStartEventLog(lectureId:String):void
{
	AuditContext.userAction.createAction(AuditConstants.editingStart, lectureId, null, null);
}

private var selPresenterURL:String;
private var selViewerURL:String;
private var selVideoFilePath:String;
private var selContentURL:String;
private var selContentFilePath:String;
private var selLectureTopic:String;

private function reloadingVideoEditing(eve:CloseFileHandler):void{
	setTimeout(onLoadVideoEditing, 500);
}

private function onLoadVideoEditing():void
{
	isEnableButtonCut=false;
	isEnableButtonPlay=false
	applicationType::desktop{
		videoEditor=new VideoEditing();
		videoEditor.open();
		videoEditor.width=1200;
		videoEditor.height=690;
		videoEditor.addEventListener(CloseFileHandler.CLOSED_VIDEO_EDITING, reloadingVideoEditing);
		videoEditor.aviewPlayer.editingActive=true;
		videoEditor.aviewPlayer.setValues(selPresenterURL, selViewerURL, selVideoFilePath, selContentURL, selContentFilePath, selLectureTopic);
		editingActiveflag=1;
		btnplayVideo.enabled=false;
	}
}
/**
 * This method is called from onFileError() and onCuttingWindowCloseEvent() in AviewEditing.as
 * This activates data grid once the cutting window is closed.
 *
 * @return void
 * */
public function killEditing():void{
	if (isEnableButtonCut)
		editingActiveflag=0;
			//	btnCut.enabled = true;
	isEnableButtonCut=true;
	editingEndEventLog(recordedLecturesDataGrid.selectedItem.lectureId);
	//mainLMSCanvas.enabled=true;
}

/**
 *
 * @private
 * Audits the "EditingEnd" action, when the moderator closes editing window of a lecture
 *
 * @param lectureId - Id of the lecture/session
 * @return void
 *
 */
private function editingEndEventLog(lectureId:String):void
{
	AuditContext.userAction.createAction(AuditConstants.editingEnd, lectureId, null, null);
}

private var zipFileService:HTTPService=new HTTPService();
private var zipVideoService:HTTPService=new HTTPService();
private var presenterVideoURL:String=null;
private var viewerVideoURL:String=null;


private var isContentFilesDownloaded:Boolean=false;
private var isVideoFilesDownloaded:Boolean=false;

private const ALLVIDEOS:String="AllVIDEOS";
private const ALLFILES:String="ALLFILES";
private const PRESENTERVIDEO:String="PRESENTERVIDEO";

private function zipDownload():void{
	localPlayback=new LocalPlayback();
	var selectedLecture:LectureVO=recordedLecturesDataGrid.selectedItem as LectureVO;
	localPlayback.setPathVariables(selectedLecture.recordedPresenterVideoUrl, selectedLecture.recordedViewerVideoUrl, selectedLecture.recordedVideoFilePath, selectedLecture.recordedContentUrl, selectedLecture.recordedContentFilePath, selectedLecture.displayName, selectedLecture.recordedDesktopVideoUrl);
	showBrowseDirectoryControl(false);
	localPlayback.addEventListener(LocalPlayback.DOWNLOADFAILED, downloadErrorHandler);
	localPlayback.addEventListener(LocalPlayback.PLAYFAILED, playErrorHandler);
}

private function showBrowseDirectoryControl(isPlayback:Boolean):void{
	browseDirectoryControl=new BrowseLocalFilePath();
	var popupFolderLocation:TitleWindow=new TitleWindow();
	var btnSelect:spark.components.Button=new spark.components.Button();
	popupFolderLocation.addElement(browseDirectoryControl);
	browseDirectoryControl.enablelblInfo(isPlayback);
	browseDirectoryControl.localPlayBack=this.localPlayback;
	popupFolderLocation.width=500;
	popupFolderLocation.height=280;
	if (isPlayback) popupFolderLocation.title="Select Folder to Play the Lecture";
	else popupFolderLocation.title="Select Folder to Download Lecture";
	popupFolderLocation.addEventListener(Event.CLOSE, onClosepopupFolderLocation);
	localPlayback.addEventListener(LocalPlayback.PLAY, PlayLectureHandler);
	//localPlayback.addEventListener(LocalPlayback.DOWNLOAD,DownloadCompleteHandler);
	PopUpManager.addPopUp(popupFolderLocation, this, true);
	PopUpManager.centerPopUp(popupFolderLocation);

}

private function onClosepopupFolderLocation(event:Event):void{
	PopUpManager.removePopUp(event.target as TitleWindow);
	browseDirectoryControl=null;
}

private function downloadErrorHandler(event:Event):void{
	if (browseDirectoryControl != null){
		PopUpManager.removePopUp(browseDirectoryControl.owner as TitleWindow);
		browseDirectoryControl=null;
	}
}

private function playErrorHandler(event:Event):void{
	if (browseDirectoryControl != null)	{
		PopUpManager.removePopUp(browseDirectoryControl.owner as TitleWindow);
		browseDirectoryControl=null;
		if (player != null)	{
			applicationType::desktop{
				//close() method not available for web.
				player.close();
			}
		}
	}
}

private function PlayLectureHandler(event:Event):void{
	if (browseDirectoryControl != null)	{
		PopUpManager.removePopUp(browseDirectoryControl.owner as TitleWindow);
		browseDirectoryControl=null;
	}
	
	isLocalPlay=true;
	playVideo(null);


}

/**
 *
 * @param oldLocation
 * @param newLocation
 * @param topic
 *
 */
private function moveRecordedLecturesToSelectedLocation(oldLocation:String, newLocation:String, topic:String):void
{
	//Reads xml files with recording data from default direcory and stores the content to bytesFile2
	applicationType::desktop{
		//File and File related methods not available for web.
		var file1:File=File.applicationStorageDirectory.resolvePath(oldLocation + "/" + topic + ".zip");
		var filestream:FileStream=new FileStream();
		filestream.open(file1, FileMode.READ);
		var bytesFile1:ByteArray=new ByteArray();
		filestream.readBytes(bytesFile1);
		filestream.close();
		
		//Reads video files from default direcory and stores the content to bytesFile2
		var file2:File=File.applicationStorageDirectory.resolvePath(oldLocation + "/" + topic + "_videos.zip");
		filestream.open(file2, FileMode.READ);
		var bytesFile2:ByteArray=new ByteArray();
		filestream.readBytes(bytesFile2);
		filestream.close();
		
		//writing the xmldata for recorded lectures to local file
		filestream.open(new File(newLocation + "/" + topic + "/" + topic + ".zip"), FileMode.WRITE);
		filestream.writeBytes(bytesFile1);
		filestream.close();
		
		//writing the video files for recorded lectures to local file
		filestream.open(new File(newLocation + "/" + topic + "/" + topic + "_videos.zip"), FileMode.WRITE);
		filestream.writeBytes(bytesFile2);
		filestream.close();
	}
	
	MessageBox.show("Lectures are saved to the Selected Folder.", "Information", MessageBox.MB_OK);
}

import flash.utils.ByteArray;

import spark.components.Label;
import flash.utils.Endian;
import flash.utils.CompressionAlgorithm;
import flash.utils.setTimeout;
import mx.utils.object_proxy;

private function playLocally():void{
	localPlayback=new LocalPlayback();
	
	var lecture:LectureVO=recordedLecturesDataGrid.selectedItem as LectureVO;
	localPlayback.setPathVariables(lecture.recordedPresenterVideoUrl, lecture.recordedViewerVideoUrl, lecture.recordedVideoFilePath, lecture.recordedContentUrl, lecture.recordedContentFilePath, lecture.displayName, lecture.recordedDesktopVideoUrl);
	localPlayback.addEventListener(LocalPlayback.PLAYFAILED, playErrorHandler);
	showBrowseDirectoryControl(true);
}

// ActionScript file
