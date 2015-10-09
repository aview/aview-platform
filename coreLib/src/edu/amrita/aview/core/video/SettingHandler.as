// ActionScript file
import edu.amrita.aview.core.entry.AVCEnvironment;
import edu.amrita.aview.core.entry.ClassroomComponent;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.vo.ClassServerVO;
import edu.amrita.aview.core.shared.audit.AuditContext;
import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
import edu.amrita.aview.core.shared.components.userList.mainHandler;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.video.AVParameters;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Camera;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.mxml.HTTPService;
import mx.states.SetStyle;
import mx.utils.StringUtil;

import spark.components.DropDownList;

/**Platform specific imports*/
applicationType::desktop{
	import flash.filesystem.File;
	//Fix for issue #19640
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
}
/** Variable declarations */
[Bindable]
private var toolTipLnk:String;

[Bindable]
private var publishingBWArr:ArrayCollection;

private var isAudioOnlyOptionSelected:Boolean=false;
private var band_Quality:int=0;
public var isDriverListPopulated:Boolean=false;
private var isDriverRefreshPressed:Boolean=false;

[Bindable]
public var previousWidth:int=0;
[Bindable]
public var currentX:int=0;
[Bindable]
public var currentY:int=0;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.Setting");
[Bindable]
private var arrVideoDriver:ArrayCollection=new ArrayCollection();
[Bindable]
private var arrAudioDriver:ArrayCollection=new ArrayCollection();
private var arrBandWidth:ArrayCollection=new ArrayCollection();
//Fix for issue #19667
[Bindable] 
public var prefsXML:XML; // The XML data
var prevFmleVal:Boolean;
//Fix for issue #19640
applicationType::desktop{
	//for device details	
	private var prefsFile:File; // The preferences prefsFile
	private var stream:FileStream;
}

applicationType::web{
	//To store users video details to Local Shared Object
	private var userDetailsSharedObject:SharedObject;
	//Fix for issue #19667
	//For device details
	private var getDeviceDetails:HTTPService;
	//Fix for issue #19931
	private var isShowAdavancedSettings:Boolean = false;
}

//public var obj_multiCombo:MultiSelectComboBox;

/**
 * The function for closing the pop up window of custom component Setting.mxml, when cancel button is applied.
 *
 *
 * @return void.
 * @see null.
 */
public function onCancel():void{
	
	if (Log.isDebug()) log.debug("onCancel");
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isSettingPopedUp=false;
	// Function for removing the pop-up window 
	PopUpManager.removePopUp(this);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings=false;
	
	//START----------------------------------------
	//Check if displayed in multiple mode UI.
	//If yes, then enable the Settings(btnSetting) button in multiple mode.
	//else displayed in consolidated mode
	//If yes, then enable the Settings(btnSetting) button in consolidated mode.
	//END------------------------------------------
	if ((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton.running) || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnStart.enabled=true;
	}
	
}
//PNCR: maintain consistency with other funciton names "removePopUp"
private function removePopup():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isSettingPopedUp=false;
	// Function for removing the pop-up window.
	PopUpManager.removePopUp(this);
}

public function onStart():void{
	if(isBandwidthValueValid())
	if (onSave(true)){
		/*if (ClassroomContext.aviewClass.classType == "Meeting"){
			chkrecordsession.enabled=false;
			chkrecordsession.selected=false;
		}*/
		applicationType::desktop{
			if (ClassroomContext.isModerator && chkrecordsession.selected == true){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recordButtonBlinkedOnce=true;
				lectureTopicValue.text=StringUtil.trim(lectureTopicValue.text);
				txtkeywords.text=StringUtil.trim(txtkeywords.text);
				if (lectureTopicValue.text != "" && txtkeywords.text != ""){
					var videoServersData:ArrayCollection=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData
					if ((videoServersData[0].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || videoServersData[0].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN || videoServersData[videoServersData.length - 1].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || videoServersData[videoServersData.length - 1].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN) && ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264){
						Alert.show("Recording is not possible as RED5 server & High definition codec is used for the class.", "RECORDING");
						
					}
					else{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.automaticRecording=true;
					}
				}
				else
				{				
					//Fix for Bug#15244
					if(txtkeywords.text == "")
					{
						Alert.show("Please enter Keyword ", "Information", 0, this);
					}
					else
					{
						Alert.show("Please fill the key word field for recording. Leading and trailing spaces are not valid . ", "INFO", 0, this);
					}
					
					return;
				}
			}
		}
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings == false)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callVideo()
		removePopup();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings=false;
	}
}

public function onReStart():void{
	applicationType::desktop{
		if (ClassroomContext.isModerator && chkrecordsession.selected == true){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recordButtonBlinkedOnce=true;
			lectureTopicValue.text=StringUtil.trim(lectureTopicValue.text);
			txtkeywords.text=StringUtil.trim(txtkeywords.text);
			if (lectureTopicValue.text != "" && txtkeywords.text != ""){
				var videoServersData:ArrayCollection=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData
				if ((videoServersData[0].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || videoServersData[0].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN || videoServersData[videoServersData.length - 1].serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || videoServersData[videoServersData.length - 1].serverCategory == Constants.SERVER_CATEGORY_RED5_LIN) && ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264){
					Alert.show("Recording is not possible as RED5 server & High definition codec is used for the class.", "RECORDING");
					
				}
				else{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.automaticRecording=true;
				}
			}
			else
			{				
				//Fix for Bug#15244
				if(txtkeywords.text == "")
				{
					Alert.show("Please enter Keyword ", "Information", 0, this);
				}
				else
				{
					Alert.show("Please fill the key word field for recording. Leading and trailing spaces are not valid . ", "INFO", 0, this);
				}
				
				return;
			}
		}
	}
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings){
		MessageBox.show("This may take few seconds to apply your new Settings.Do you want to Continue?", "Info", MessageBox.MB_YESNO, this, continueVideoPublishing, stopVideoSettings);
	}
	//commented to fix bug#17487
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings=false;
}

public function continueVideoPublishing(event:Event=null):void{
	onStart();
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.callContinueRestart();
}

public function  stopVideoSettings(event:Event=null):void{
	onSave(true);
	//removePopup();
	//commented to fix bug#17487
}

public function validate():Boolean{
	var deviceDriverCheck:Boolean=true;
	if (!isAudioOnlyOptionSelected){
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver == "" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver == ""){
			if (Log.isDebug()) log.debug("No Camera\Audio Devices Detected");
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver == ""){
				Alert.show("No Camera\Audio Devices Detected!\nPlease check your Camera\Audio Devices", "   Hardware Error", Alert.OK, this);
				deviceDriverCheck=false;
			}
		}
		else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver == ""){
			if (Log.isDebug()) log.debug("No Camera Devices Detected");
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver == ""){
				Alert.show("No Camera Detected!\nPlease plugin a Camera & refresh the Application", "    Camera Error", Alert.OK, this);
				deviceDriverCheck=false;
			}
		}
		else if (micSelect.selectedIndex == -1 || camSelect.selectedIndex == -1){
			Alert.show("Please select a valid Audio/Video driver!!!", "Selection Error", Alert.OK, this);
			deviceDriverCheck=false;
		}
	}
	else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver == ""){
		if (Log.isDebug()) log.debug("No Audio Devices Detected");
		Alert.show("No Audio Devices Detected!\nPlease check your audio devices", "   Audio Device Error", Alert.OK, this);
		deviceDriverCheck=false;
	}
	return deviceDriverCheck;
}

/**
 * The function for closing the pop up window of custom component Setting.mxml when OK button is applied.
 * Also,sets the audio and video driver names (selected by the user from a list of options available) to the variables in main.mxml.
 *
 *
 * @return void
 * @see removeme().
 */
public function onSave(calledFromOnStart:Boolean=false):Boolean{
	//START----------------------------------------
	//Check if array videodriver(array contains the names of video drivers installed in the system) is null and 
	//          array audiodriver(array contains the names of audio drivers installed in the system) is null.
	//If yes, then show the alert that no camera and audio devices detected.
	//else if check array videodriver(array contains the names of video drivers installed in the system) is null or 
	//          array audiodriver(array contains the names of audio drivers installed in the system) is null.
	//If yes, then check which driver is missing.
	//else if check the combobox of camera or combobox of microphone is null
	//If yes, then show an appropriate alert.
	//else, assign the selected value from micSelect(combobox of microphone) to audioDeviceDrive(string variable) in Video_ScriptCode.as
	//		assign the selected value from camSelect(combobox of camera) to videoDeviceDrive(string variable) in Video_ScriptCode.as
	//		assign the selected value from bandwidthSelect(combobox of bandwidth range) to selectedKbps(string variable) in Video_ScriptCode.as
	//END------------------------------------------
	
	var deviceDriverCheck:Boolean=validate();
	if(isBandwidthValueValid())
	{
		if (deviceDriverCheck){
			if (isAudioOnlyOptionSelected){
				ClassroomContext.isAudioOnlyMode=true;
				ClassroomContext.STREAMING_OPTION=rbAudioOnly.label.toString();
			}
			else{
				ClassroomContext.isAudioOnlyMode=false;
				ClassroomContext.STREAMING_OPTION=rbAudioVideo.label.toString();
			}
			if(calledFromOnStart == true){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setStreamingStatus();
			}
			//Fix for issue #17085
			applicationType::DesktopMobile{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive=micSelect.selectedItem.toString();
			}
			applicationType::web{
				if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
					for(var i:int=0; i<FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver.length; i++)
					{
						if(micSelect.selectedIndex == i)
						{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive =FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver[i];
						}
					}
				}
				else
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive=micSelect.selectedItem.toString();
				}
			}
			if (!isAudioOnlyOptionSelected){
				//Fix for issue #17085
				applicationType::DesktopMobile{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive=camSelect.selectedItem.toString();
				}
				applicationType::web{
					if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
						for(var i:int=0; i<FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver.length; i++)
						{
							if(camSelect.selectedIndex == i)
							{
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver[i];
							}
						}
					}
					else
					{
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive=camSelect.selectedItem.toString();
					}
				}
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps=bandwidthSelect.textInput.text;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType = cmbVideoDeviceType.selectedItem.index.toString();
			//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE = chkboxUseFMLE.selected;
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings && !isAudioOnlyOptionSelected)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE = rbVideoModeQuality.selected;
			if(ClassroomContext.aviewClass.isMultiBitrate != "Y" && !ClassroomContext.isAudioOnlyMode)
			{
				//PNCR: added video only mode condition checking. the below combo boxes will not be available for video only mode
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraResolution = cmbResolution.selectedItem.value.toString();
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraVideoQuality = cmbQuality.selectedItem.index;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.FPS = cmbFPS.selectedItem.value.toString();
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.keyFrames=cmbKeyframe.selectedItem.value.toString();
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.h264Profile = cmbH264Profile.selectedItem.value.toString();
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.h264ProfileValue = cmbH264ProfilerValues.selectedItem.value.toString();
				}
			//if(chkAdvncedSetting.selected)
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAdvancedSettingsChecked = true;
			//else
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAdvancedSettingsChecked = false;
	
			//START----------------------------------------
			//Check if displayed in multiple mode UI.
			//If yes, then enable the Settings(btnSetting) button in multiple mode and notify the user.
			//else displayed in consolidated mode
			//If yes, then enable the Settings(btnSetting) button in consolidated mode and notify the user.
			//END------------------------------------------
			
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE){ //ClassroomContext.userVO.role == Constants.STUDENT_TYPE
				if (Log.isDebug()) log.debug("VIEWER_ROLE");
				ClassroomContext.publisherVideoQuality=parseInt(bandwidthSelect.textInput.text);
				if (ClassroomContext.aviewClass.isMultiBitrate == "Y"){
					bitRateQualitySelection();
					ClassroomContext.subscriber_bandwidthQualityIndex=band_Quality;
					if (ClassroomContext.subscriber_bandwidthQualityIndex != ClassroomContext.subscriber_prev_bandwidthQualityIndex){
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selection_change();
					}
				}
			}
			else if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE && ClassroomContext.aviewClass.isMultiBitrate != "Y"){
				ClassroomContext.publisherVideoQuality=parseInt(bandwidthSelect.textInput.text);
			}
			if (ClassroomContext.publisherVideoQuality != -1){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setPublishingBandwidth();
			}
			saveSettingsToFile();
			/* Issue No:517 is fixed */
			if (!calledFromOnStart){
				Alert.show("Your settings are saved", "Settings", 0, this); //SVRS-Issue no 49
			}
		}
		if ((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton.running) || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnStart.enabled=true;
		}
		// The following 2 LOC saves the record settings
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords=StringUtil.trim(txtkeywords.text);
		
		if (!calledFromOnStart){
			removePopup();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings=false;
		}
	}
	return deviceDriverCheck;
}

private function saveSettingsToFile():void
{
	if(Log.isDebug()) log.debug("savingDriverSelected");
	try
	{
		var isFMLEVal:Boolean=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE;
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings && isAudioOnlyOptionSelected)
			isFMLEVal=false;
		var _string:String="<user>\n<username></username>\n<password>\n</password>" +
			"<audioDriver>\n"+micSelect.selectedItem.toString()+"</audioDriver>\n" +
			"<videoDriver>\n"+camSelect.selectedItem.toString()+"</videoDriver>\n" +
			"<bandwidth>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps+"</bandwidth>\n" +
			"<videoDeviceType>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType +"</videoDeviceType>\n" +
			"<isAdvancedChecked>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAdvancedSettingsChecked+"</isAdvancedChecked>\n" +
			"<camResolution>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraResolution+"</camResolution>\n" +
			"<videoQuality>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraVideoQuality+"</videoQuality>\n" +
			"<fps>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.FPS+"</fps>\n" +
			"<h264Profile>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.h264Profile+"</h264Profile>\n" +
			"<h264ProfileValue>\n"+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.h264ProfileValue+"</h264ProfileValue>\n" +
			"<keyFrames>\n" + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.keyFrames + "</keyFrames>\n"+
			"<useFMLE>\n" + isFMLEVal + "</useFMLE>\n";
		
		if(chkrecordsession != null)
		{
			_string += "<isRecording>\n"+chkrecordsession.selected.toString()+"</isRecording>\n";
		}
		
		_string += "</user>";
		applicationType::desktop{
			var path:String="file:///" + File.applicationStorageDirectory.nativePath.toString()+ "\\UserDetails.xml";
		}
		if(Log.isDebug()) log.debug("saveSettingsToFile -  Values - "+_string);
		
		
		//_file_det=File.applicationDirectory;	
		//_file_det=_file_det.resolvePath("app:///config/UserDetails.xml");	
		//For Web: File and FileStream are not available
		applicationType::desktop{
			var _file_det:File=new File(path);
			var _fileStream_det:FileStream=new FileStream();
			_fileStream_det.addEventListener(Event.CLOSE, completeHandler1);
			_fileStream_det.addEventListener(IOErrorEvent.IO_ERROR, errorHandler1);
			_fileStream_det.openAsync(_file_det, FileMode.WRITE);
			_fileStream_det.writeUTFBytes(_string);
			_fileStream_det.close();
		}
		applicationType::web{
			userDetailsSharedObject = SharedObject.getLocal("UserDetails_"+ClassroomContext.userVO.userName,"/"); 
			userDetailsSharedObject.data.value= _string;
			userDetailsSharedObject.flush();
		}
	}
	catch(er:Error)
	{
		if(Log.isError()) log.error("Error in saveSettingsToFile method :"+ er.getStackTrace());
	}
}


private function completeHandler1(eve:Event):void{
	if (Log.isDebug()) log.debug("completeHandler1");
}

private function errorHandler1(eve:Event):void{
	if(Log.isDebug()) log.debug("errorHandler "+eve.toString());
}
private var xmlData:XML;
private var driverHttpService:HTTPService;
private var audioDriverName:String="";
private var videoDriverName:String="";

public function prePopulateSettings():void{
	if (Log.isDebug()) log.debug("prePopulateDrivers");
	audioDriverName="";
	videoDriverName="";
	try{
		driverHttpService=new HTTPService();
		driverHttpService.addEventListener(ResultEvent.RESULT, loadSettingsHandler);
		driverHttpService.addEventListener(FaultEvent.FAULT, faultHandler);
		//File is not available for web
		applicationType::desktop{
			driverHttpService.url=File.applicationStorageDirectory.nativePath + "\\UserDetails.xml";
		}
		//Fix for issue #19709
		applicationType::web{
			driverHttpService.url="config/UserDetails.xml";
		}
		driverHttpService.resultFormat="e4x"
		driverHttpService.send();
	}
	catch (er:Error){
		if(Log.isError()) log.error("Error in prePopulateSettings method :"+ er.getStackTrace());
	}
}

private function searchingPreviousChosenDriver():void{
	if (Log.isDebug()) log.debug("searchingPreviousChosenDriver");
	var isVideoDriverFound:Boolean=false;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive != ""){
		for (var i:int=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver.length; i++){
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver[i]){
				isVideoDriverFound=true;
				break;
			}
		}
	}
	if (isVideoDriverFound == true){
		camSelect.selectedItem=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive;
	}
	else{
		//Fix for issue #17085
		applicationType::DesktopMobile{
			camSelect.selectedIndex=0;
		}
		applicationType::web{
			if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive != ""){
					camSelect.selectedItem=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive;
				}
				else
				{
					camSelect.selectedIndex=0;
				}
			}
			else
			{
				camSelect.selectedIndex=0;
			}
		}
	}
	
	//Pre select the previously chosen audio driver
	var isAudioDriverFound:Boolean=false;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive != ""){
		for (var j:int=0; j < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver.length; j++){
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver[j]){
				isAudioDriverFound=true;
				break;
			}
		}
	}
	
	if (isAudioDriverFound == true){
		micSelect.selectedItem=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive;
	}
	else{
		//Fix for issue #17085
		applicationType::DesktopMobile{
			micSelect.selectedIndex=0;
		}
		applicationType::web{
			if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive != ""){
					micSelect.selectedItem=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive;
				}
				else
				{
					micSelect.selectedIndex=0;
				}
			}
			else
			{
				micSelect.selectedIndex=0;
			}		
		}
	}
}

applicationType::web{
	private function loadPreviousDetails():void
	{
		userDetailsSharedObject = SharedObject.getLocal("UserDetails_"+ClassroomContext.userVO.userName ,"/");
		var values:String = userDetailsSharedObject.data.value;
		//Convert string to xml 
		xmlData = XML(values);
		//Fix for issue #19709
		if(Log.isDebug()) log.debug("loadSettingsHandler audioDriverName - "+audioDriverName+" videoDriverName - "+videoDriverName+
			" videoDeviceType -"+xmlData.videoDeviceType+" bandwidth - "+xmlData.bandwidth+" isAdvancedCheckboxChecked - "+xmlData.isAdvancedChecked+
			" camera Resolution - "+xmlData.camResolution+" videoQuality - "+xmlData.videoQuality+" fps - "+xmlData.fps +
			" h264Profile - "+xmlData.h264Profile+" h264ProfileValue - "+xmlData.h264ProfileValue+ " keyFrames - " + xmlData.keyFrames);
		audioDriverName=xmlData.audioDriver.toString();
		videoDriverName=xmlData.videoDriver.toString();
		//if(xmlData.useFMLE.toString()=="true" && ClassroomContext.aviewClass.isMultiBitrate != "Y" && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.VIEWER_ROLE || ClassroomContext.userVO.role != Constants.STUDENT_TYPE))
		/*if(xmlData.useFMLE.toString()=="true" && ClassroomContext.aviewClass.isMultiBitrate != "Y" && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE ))
		{
			//chkboxUseFMLE.selected=true;
			rbVideoModeQuality.selected=true;
		}
		else 
		{
			//chkboxUseFMLE.selected=false;
			rbVideoModeDelay.selected=true;
		}*/
		rbVideoModeDelay.selected=true; //FMLE works only for desktop versions
		
		if (chkrecordsession != null && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recordIcon == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.startRecordIcon){
			//chkrecordsession.selected=(xmlData.isRecording == "true") ? true : false;
		}
		else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recordIcon == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopRecordIcon){
			chkrecordsession.selected=true;
		}
		isDriverListPopulated=true;
		if (audioDriverName != ""){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive=audioDriverName;
		}
		if (videoDriverName != ""){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive=videoDriverName;
		}
		
		for(var i:int = 0; i< Constants.cameraDeviceType.length; i++)
		{
			if(Constants.cameraDeviceType[i].index == xmlData.videoDeviceType.toString())
			{
				cmbVideoDeviceType.selectedIndex = i;
				break;
			}
		}
		//Fix for issue #19709
		if(xmlData.videoDeviceType.toString() != ""){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=xmlData.videoDeviceType.toString();
		}
		setCamResolutionDataProvider();
		var isSavedBandwidthAvailable:Boolean=false;
		//for(var i:int = 0; i< publishingBWArr.length; i++)
		for(var i:int = 0; i< bandwidthSelect.dataProvider.length; i++)
		{
			//if(publishingBWArr[i].index.toString() == xmlData.bandwidth.toString())
			if(bandwidthSelect.dataProvider[i].index.toString() == xmlData.bandwidth.toString())
			{
				isSavedBandwidthAvailable=true;
				bandwidthSelect.selectedIndex = i;
				break;
			}
		}
		if(!isSavedBandwidthAvailable)
		{
			if(parseInt(xmlData.bandwidth.toString())>= ClassroomContext.aviewClass.minPublishingBandwidthKbps && parseInt(xmlData.bandwidth.toString())<= ClassroomContext.aviewClass.maxPublishingBandwidthKbps)
			{
				isSavedBandwidthAvailable=true;
				bandwidthSelect.textInput.text=xmlData.bandwidth.toString();
			}
			else
			{
				if(parseInt(xmlData.bandwidth.toString()).toString()=="NaN")
					bandwidthSelect.textInput.text=ClassroomContext.aviewClass.minPublishingBandwidthKbps.toString();
			}
		}
		if(xmlData.isAdvancedChecked.toString() == "true")
		{
			//chkAdvncedSetting.selected = true;
			toggleAdvancedSettingComponents(true);
		}
		if(isSavedBandwidthAvailable)
		{
			setXMLData(arResolution, xmlData.camResolution.toString(), cmbResolution);
		}
		/*for (var i:int=0; i < Constants.videoQuality.length; i++)
		{
			if (Constants.videoQuality[i].index == xmlData.videoQuality)
			{
				cmbQuality.selectedIndex=i;
				break;
			}
		}*/
		//setXMLData(Constants.AR_FPS_VALUES, xmlData.fps, cmbFPS);
		//setXMLData(Constants.AR_KEY_FRAME_VALUES, xmlData.keyFrames, cmbKeyframe);
		//setXMLData(Constants.h264Profiles, xmlData.h264Profile.toString(), cmbH264Profile);
		//setXMLData(Constants.AR_H264_PROFILER_VALUES, xmlData.h264ProfileValue, cmbH264ProfilerValues);
		//Fix for issue #19709
		searchingPreviousChosenDriver();
		if(arrVideoDriver.length <= 0)
		{
			//chkAdvncedSetting.enabled=false;
			toggleAdvancedSettingComponents(false);
		}
		else
		{
			//chkAdvncedSetting.enabled=true;
			//if (chkAdvncedSetting.selected)
			toggleAdvancedSettingComponents(true);
		}
	}
}

private function faultHandler(event:FaultEvent):void{
	//init();
	if (Log.isError()) log.error("faultHandler:"+AbstractHelper.getStaticFaultMessage(event));
	isDriverListPopulated=true;
	searchingPreviousChosenDriver();
}

private function loadSettingsHandler(event:ResultEvent):void{
	//Fix for issue #19709
	applicationType::desktop{
	if(Log.isDebug()) log.debug("loadSettingsHandler ");
	xmlData=event.result as XML;
	if(Log.isDebug()) log.debug("loadSettingsHandler audioDriverName - "+audioDriverName+" videoDriverName - "+videoDriverName+
		" videoDeviceType -"+xmlData.videoDeviceType+" bandwidth - "+xmlData.bandwidth+" isAdvancedCheckboxChecked - "+xmlData.isAdvancedChecked+
		" camera Resolution - "+xmlData.camResolution+" videoQuality - "+xmlData.videoQuality+" fps - "+xmlData.fps +
		" h264Profile - "+xmlData.h264Profile+" h264ProfileValue - "+xmlData.h264ProfileValue+ " keyFrames - " + xmlData.keyFrames);
	audioDriverName=xmlData.audioDriver.toString();
	videoDriverName=xmlData.videoDriver.toString();
	if(xmlData.useFMLE.toString()=="true" && (ClassroomContext.aviewClass.audioVideoInteractionMode=='Minimal' || (ClassroomContext.aviewClass.audioVideoInteractionMode=='Full' && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings)) && ClassroomContext.aviewClass.isMultiBitrate != "Y" && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE || ClassroomContext.isModerator))
	{
		//chkboxUseFMLE.selected=true;
		rbVideoModeQuality.selected= true;
		lblSettings.enabled=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE=true;
	}
	else if(xmlData.useFMLE.toString()=="false") 
	{
		//chkboxUseFMLE.selected=false;
		rbVideoModeDelay.selected=true;
		if (rbgAudioOption.selection == rbAudioOnly)
			lblSettings.enabled=false;
		else
			lblSettings.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE=false;
	}
	if(xmlData.fps>=5 && xmlData.fps<=30)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.FPS=xmlData.fps;
	
	if(xmlData.keyFrames>=1 && xmlData.keyFrames<=30)
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.keyFrames=xmlData.keyFrames;

	if (chkrecordsession != null && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recordIcon == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.startRecordIcon){
		//chkrecordsession.selected=(xmlData.isRecording == "true") ? true : false;
	}
	else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.recordIcon == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.stopRecordIcon){
		chkrecordsession.selected=true;
	}
	
	isDriverListPopulated=true;
	if (audioDriverName != ""){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audioDeviceDrive=audioDriverName;
	}
	if (videoDriverName != ""){
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoDeviceDrive=videoDriverName;
	}
	
	for(var i:int = 0; i< Constants.cameraDeviceType.length; i++)
	{
		if(Constants.cameraDeviceType[i].index == xmlData.videoDeviceType.toString())
		{
			cmbVideoDeviceType.selectedIndex = i;
			break;
		}
	}
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=xmlData.videoDeviceType.toString();
	setCamResolutionDataProvider();
	var isSavedBandwidthAvailable:Boolean=false;
	//for(var i:int = 0; i< publishingBWArr.length; i++)
	for(var i:int = 0; i< bandwidthSelect.dataProvider.length; i++)
	{
		//if(publishingBWArr[i].index.toString() == xmlData.bandwidth.toString())
		if(bandwidthSelect.dataProvider[i].index.toString() == xmlData.bandwidth.toString())
		{
			isSavedBandwidthAvailable=true;
			bandwidthSelect.selectedIndex = i;
			break;
		}
	}
	if(!isSavedBandwidthAvailable)
	{
		if(parseInt(xmlData.bandwidth.toString())>= ClassroomContext.aviewClass.minPublishingBandwidthKbps && parseInt(xmlData.bandwidth.toString())<= ClassroomContext.aviewClass.maxPublishingBandwidthKbps)
		{
			isSavedBandwidthAvailable=true;
			bandwidthSelect.textInput.text=xmlData.bandwidth.toString();
		}
		else
		{
			if(parseInt(xmlData.bandwidth.toString()).toString()=="NaN")
				bandwidthSelect.textInput.text=ClassroomContext.aviewClass.minPublishingBandwidthKbps.toString();
		}
	}
	if(xmlData.isAdvancedChecked.toString() == "true")
	{
		//chkAdvncedSetting.selected = true;
		toggleAdvancedSettingComponents(true);
	}
	if(isSavedBandwidthAvailable)
	{
		setXMLData(arResolution, xmlData.camResolution.toString(), cmbResolution);
	}
	/*for(var i:int = 0; i< Constants.videoQuality.length; i++)
	{
		if(Constants.videoQuality[i].index == xmlData.videoQuality)
		{
			cmbQuality.selectedIndex = i;
			break;
		}
	}*/
	setXMLData(Constants.AR_FPS_VALUES, xmlData.fps, cmbFPS);
	setXMLData(Constants.AR_KEY_FRAME_VALUES, xmlData.keyFrames, cmbKeyframe);
	//setXMLData(Constants.h264Profiles, xmlData.h264Profile.toString(), cmbH264Profile);
	//setXMLData(Constants.AR_H264_PROFILER_VALUES, xmlData.h264ProfileValue, cmbH264ProfilerValues);
	searchingPreviousChosenDriver();
	if(arrVideoDriver.length <= 0)
	{
		//chkAdvncedSetting.enabled=false;
		toggleAdvancedSettingComponents(false);
	}
	else
	{
		//chkAdvncedSetting.enabled=true;
		//if (chkAdvncedSetting.selected)
			toggleAdvancedSettingComponents(true);
	}
	}
	//Fix for issue #19709
	applicationType::web{
		loadPreviousDetails();
	}
}

private function setXMLData(arData:ArrayCollection, value:String, comboBox:DropDownList):void
{
	for(var i:int = 0; i< arData.length; i++)
	{
		if(arData[i].value == value)
		{
			comboBox.selectedIndex = i;
			break;
		}
	}
}


//Bug fix for #7451 start
private function setPublishingBandwidth():void{
	publishingBWArr=new ArrayCollection();
	var startIndex:int=0;
	var endIndex:int=Constants.availableVideoPublishingBandwidths.length - 1;
	var i:int=0;
	var obj:Object;
	//Removed min and max bandwidth check for teacher users. i.e. a teacher can publish at any bitrate from 28Kbps to 8505Kbps.
	if( ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
	{
		//Limited SORENSON & Vp6 codec to 1Mbps
		if (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON || ClassroomContext.aviewClass.videoCodec == Constants.CODEC_VP6)
		{
			ClassroomContext.aviewClass.maxPublishingBandwidthKbps=1024;
			
			for (i=0; i < Constants.availableVideoPublishingBandwidths.lengt; i++)
			{
				if (ClassroomContext.aviewClass.maxPublishingBandwidthKbps == Constants.availableVideoPublishingBandwidths[i].index)
				{
					endIndex=i;
					break;
				}
			}
		}
		for( i=0; i <= endIndex; i++)
		{
			obj=new Object();
			obj.value=Constants.availableVideoPublishingBandwidths[i].value;
			obj.index=Constants.availableVideoPublishingBandwidths[i].index;
			publishingBWArr.addItem(obj);
		}
	}
	else
	{
		for (i=0; i < Constants.availableVideoPublishingBandwidths.length; i++){
			if (ClassroomContext.aviewClass.minPublishingBandwidthKbps == Constants.availableVideoPublishingBandwidths[i].index){
				startIndex=i;
				break;
			}
		}
		//Limited SORENSON & Vp6 codec to 1Mbps
		if ((ClassroomContext.aviewClass.videoCodec == Constants.CODEC_SORENSON || ClassroomContext.aviewClass.videoCodec == Constants.CODEC_VP6) && ClassroomContext.aviewClass.maxPublishingBandwidthKbps > 1024){
			ClassroomContext.aviewClass.maxPublishingBandwidthKbps=1024;
		}
		for (; i < Constants.availableVideoPublishingBandwidths.length; i++){
			if (ClassroomContext.aviewClass.maxPublishingBandwidthKbps == Constants.availableVideoPublishingBandwidths[i].index){
				endIndex=i;
				break;
			}
		}		
		for (i=startIndex; i <= endIndex; i++){
			obj=new Object();
			obj.value=Constants.availableVideoPublishingBandwidths[i].value;
			obj.index=Constants.availableVideoPublishingBandwidths[i].index;
			publishingBWArr.addItem(obj);
			
		}
	}
}

//Bug fix for #7451 end

/**
 * The function for listing the audio and video drivers connected to the system in combobox.
 *
 *
 * @return void
 * @see null
 */
public function init():void{
	if(!isDriverRefreshPressed && (ClassroomContext.aviewClass.isMultiBitrate == "Y" || ClassroomContext.aviewClass.videoCodec==Constants.CODEC_VP6))
	{
		//Fix for issue #18710
		applicationType::desktop{
			cnvAdvancedSettings.visible=false;
			cnvAdvancedSettings.includeInLayout=false;
			//Fix for issue #18669
			this.width=	this.width-100;
		}
		//Fix for issue #19416
		applicationType::web{
			this.width=436;
		}
	}
	else{
		//Fix for issue #19401
		applicationType::web{
			//Fix for issue #19931
			if(isShowAdavancedSettings == false){
				this.width=368;
			}
		}
	}
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.timerEnableStartButton.running)
		btnStart.enabled=false;
	/*if(!isDriverRefreshPressed)
	{
		//setXMLData(Constants.AR_FPS_VALUES, "15", cmbFPS);
		//setXMLData(Constants.AR_KEY_FRAME_VALUES, "15", cmbKeyframe);
		//setXMLData(Constants.AR_H264_PROFILER_VALUES, "3", cmbH264ProfilerValues);
	}*/
	if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings){
		//btnViewDesktop0.visible=false;
		btnViewDesktop0.enabled=false;
		btnPreTesting.enabled=false;
		btnStart.visible=false;
		btnStart.includeInLayout=false;
		btnReStart.visible=true;
		btnReStart.includeInLayout=true;
		//if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
		//chkboxUseFMLE.enabled=false;
		hboxVideoModeContainer.enabled=false;
	}
	if(ClassroomContext.aviewClass.audioVideoInteractionMode=='Minimal' && ClassroomContext.aviewClass.isMultiBitrate == "N" && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classEntryCheck) && (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings) &&  ClassroomContext.isModerator)
	{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classEntryCheck=false;
		rbVideoModeQuality.selected=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE=true;
	}
	else if(ClassroomContext.aviewClass.audioVideoInteractionMode=='Full' && ClassroomContext.aviewClass.isMultiBitrate == "N" && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classEntryCheck) && (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings) && ClassroomContext.isModerator)
	{
		rbVideoModeDelay.selected=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classEntryCheck=false;
	}
	//Bug fix for #7451 start
	setPublishingBandwidth();
	toggleAdvancedSettingComponents(false);
	//Bug fix for #7451 end
	if (Log.isDebug()) log.debug("init");
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isSettingPopedUp=true;
	if(!isDriverRefreshPressed)
		prePopulateSettings();
	var i:int;
	var k:int;
	try{
		for (i=0; i < ClassroomContext.aviewClass.classServers.length; i++){
			var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClass.classServers.getItemAt(i));
			if (classServer.serverTypeName == Constants.FMS_PRESENTER || classServer.serverTypeName == Constants.MEETING_FMS_PRESENTER){
				if (ClassroomContext.aviewClass.videoCodec == Constants.CODEC_H264 && (classServer.server.serverCategory == Constants.SERVER_CATEGORY_RED5_WIN || classServer.server.serverCategory == Constants.SERVER_CATEGORY_RED5_LIN)){
					chkrecordsession.selected=false;
					chkrecordsession.enabled=false;
					recordsettingscan.enabled=false;
					break;
				}
			}
		}
		if (ClassroomContext.aviewClass.videoCodec == "VP6" || ClassroomContext.aviewClass.isMultiBitrate == "Y"){
			rbgAudioOption.enabled=false;
		}
		rbgAudioOption.selectedValue=ClassroomContext.STREAMING_OPTION;
		streamingOptionChange();
		arrVideoDriver.removeAll();
		//Fix for issue #17085
		applicationType::DesktopMobile{
			for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver.length; i++){
				arrVideoDriver.addItem(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver[i]);
			}
		}
		applicationType::web{
			if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
				for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver.length; i++){
					arrVideoDriver.addItem("Camera " + (i+1));
				}
			}
			else
			{
				for (i=0; i < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver.length; i++){
					arrVideoDriver.addItem(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver[i]);
				}
			}
		}
		arrAudioDriver.removeAll();
		//Fix for issue #17085
		applicationType::DesktopMobile{
			for (var j:int=0; j < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver.length; j++){
				arrAudioDriver.addItem(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver[j]);
			}
		}
		applicationType::web{
			if(FlexGlobals.topLevelApplication.mainApp.browserName == "Chrome"){
				for (var j:int=0; j < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver.length; j++){
					arrAudioDriver.addItem("Audio driver " + (j+1));
				}
			}
			else
			{
				for (var j:int=0; j < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver.length; j++){
					arrAudioDriver.addItem(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.audiodriver[j]);
				}
			}
		}
		for (k=0; k < FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.arrBW.length; k++){
			arrBandWidth.addItem(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.arrBW[k]);
		}
		camSelect.dataProvider=arrVideoDriver;
		camSelect.selectedIndex=0;
		micSelect.dataProvider=arrAudioDriver;
		micSelect.selectedIndex=0;
		//bandwidthSelect.dataProvider=arrBandWidth; //Bug #19725
		//bandwidthSelect.labelField="value";
		
		//START----------------------------------------
		//Check if displayed in multiple mode UI.
		//If yes, then disable the Settings(btnSetting) button in multiple mode.
		//else displayed in consolidated mode
		//If yes, then disable the Settings(btnSetting) button in consolidated mode.
		//END------------------------------------------
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnStart.enabled=false;
		
		//Preselect the previously chosen bandwidth
		//Initialze this pre selection from database
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps == ""){
			if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE || ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE){
				if (ClassroomContext.aviewClass.isMultiBitrate != "Y"){
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps=ClassroomContext.aviewClass.presenterPublishingBwsKbps;
				}
			}
		}
		//bandwidthSelect.selectedIndex=0;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps != ""){
			for (k=0; k < publishingBWArr.length; k++){
				if (publishingBWArr[k].index == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps){
					//bandwidthSelect.selectedIndex=k;
					bandwidthSelect.textInput.text=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedPublishingBWKbps;
					break;
				}
			}
		}
		if (ClassroomContext.aviewClass.classType == "Meeting")
		{
			setModeratorSettingForMeeting();
		}
		else
		{
			if (ClassroomContext.userVO.role == Constants.TEACHER_TYPE || ClassroomContext.userVO.role == Constants.ADMIN_TYPE || ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE){
				if (ClassroomContext.isModerator){
					if (Log.isDebug()) log.debug("init ClassroomContext.isModerator");
					// For record settings
					lblCourse.text=ClassroomContext.course.courseName;
//					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedLectureName == ""){
//						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedLectureName=ClassroomContext.lecture.lectureName;
//					}
					lectureTopicValue.text=ClassroomContext.lecture.displayName;
				
					if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords == "")
					{
						//Commenting code to fix Bug#15244
						//Fix for Bug# 14074
						/*if(ClassroomContext.lecture.keywords == "")
						{
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords=ClassroomContext.lecture.displayName;
						}
						else
						{*/
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords=ClassroomContext.lecture.keywords;
							if(!chkrecordsession.selected || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords!="")
								txtkeywords.enabled = false;
						/*}*/
					}
					else
						txtkeywords.enabled = false;
					txtkeywords.text=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords;
					if (ClassroomContext.aviewClass.isMultiBitrate != "Y"){
						recordChoiceMultiQuality.visible=false;
						recordChoiceMultiQuality.visible=false;
						recordChoiceMultiQuality.includeInLayout=false;
					}
					else{
						//								this.height+=5; 
						rb_RecordLowQuality.label="Low";
						rb_RecordMedQuality.label="Medium";
						rb_RecordHighQuality.label="High";
					}
				
					if (!ClassroomContext.record_selectionCheck){
						chkrecordsession.selected=false;
						disableVideoQuality();
					}
				}
				else{
					if (Log.isDebug()) log.debug("init else ClassroomContext.isModerator");
					mainvbox.removeChild(recordsettingscan);
					//							hBoxStreamingOption.top=70;
					//							mainvbox.top=15;
					//							this.width=390;
					//							this.height=275; 
				}
				if (ClassroomContext.aviewClass.isMultiBitrate == "Y"){
					lbl_vidQuality.visible=false;
					bandwidthSelect.visible=false;
					lbl_vidQuality.includeInLayout=false;
					bandwidthSelect.includeInLayout=false;
					
					rb_louQuality.label="Low";
					rb_medQuality.label="Medium";
					rb_highQuality.label="High";
					
				}
				if(ClassroomContext.aviewClass.isMultiBitrate != "Y" || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userRole  == Constants.PRESENTER_ROLE && ClassroomContext.aviewClass.isMultiBitrate == "Y") || (ClassroomContext.currentPresenterName!="" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.currentPresenterName).userType  == Constants.STUDENT_TYPE && ClassroomContext.aviewClass.isMultiBitrate == "Y"))
					mainvbox.removeChild(stdVideoSettings);
				lbl_userSettings.text="Teacher Video Settings (Sending)";
				
				}
			else if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE){
				if (Log.isDebug()) log.debug("init Constants.STUDENT_TYPE");
				mainvbox.removeChild(recordsettingscan);
			
				lbl_userSettings.text="Student Video Settings (Sending)";
				//if(ClassroomContext.aviewClass.isMultiBitrate != "Y" || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSOStatus(ClassroomContext.userVO.userName).userRole  == Constants.PRESENTER_ROLE && ClassroomContext.aviewClass.isMultiBitrate == "Y") || (ClassroomContext.currentPresenterName!="" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSOStatus(ClassroomContext.currentPresenterName).userType  == Constants.STUDENT_TYPE && ClassroomContext.aviewClass.isMultiBitrate == "Y")){
				if(ClassroomContext.aviewClass.isMultiBitrate != "Y" || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userRole  == Constants.PRESENTER_ROLE && ClassroomContext.aviewClass.isMultiBitrate == "Y") || (ClassroomContext.currentPresenterName!="" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.currentPresenterName).userType  == Constants.STUDENT_TYPE && ClassroomContext.aviewClass.isMultiBitrate == "Y"))
				{	
					mainvbox.removeChild(stdVideoSettings);
				//							hBoxStreamingOption.top=70;
				//							mainvbox.top=15;
				//							this.width=390;
				//							this.height=275; 
				}
				else{
					if(ClassroomContext.aviewClass.allowDynamicSwitching != "Y"){
					lbl_bandSelection.visible=false;
					rb_manual.visible=false;
					rb_automatic.visible=false;
					//								canvas_Quality.y= lbl_teacherSettings.y+30;
					//								this.height=410;
					}
					rb_louQuality.label="Low";
					rb_medQuality.label="Medium";
					rb_highQuality.label="High";
				} 
			}
			rbg_dynmcSelection.selectedValue=ClassroomContext.subscriber_bandwidthSelection;
			rbg_bandQuality.selectedValue=ClassroomContext.subscriber_bandwidthQualityName;
			bitRateModeSelection(); 
			if ((Capabilities.os.toLowerCase().indexOf("mac") > -1 || AVCEnvironment.runTime == AVCEnvironment.BROWSER) && ClassroomContext.aviewClass.videoCodec == "VP6"){
				//hBoxStreamingOption.enabled=false;
				selectcamcanvas.enabled=false;
				recordsettingscan.enabled=false;
				stdVideoSettings.enabled=false;
				btnRefreshDriver.enabled=false;
				btnStart.enabled=false;
				btnSave.enabled=false;
			}
		}
	}
	catch (e:Error) {
		if(Log.isError()) log.error("Error in init method"+e.getStackTrace());
	}
	if(!isDriverRefreshPressed)
	{
		setCamResolutionDataProvider();
	}
	isDriverRefreshPressed=false;
}
private var arResolution:ArrayCollection;
private var togglecheck:Boolean= false;

private function toggleCheckFmle(bool:Boolean):void
{
	if(rbVideoModeQuality.selected==true)
	{
		if(togglecheck== false)
		  Alert.show("Recommended for presentation-only sessions (Higher Video Quality) May introduce a small delay, Do you want to continue ?", "Confirmation", Alert.YES | Alert.NO, null, function(event:CloseEvent):void {FMLEConfirmation(event)}, null, 1);
	}
	else if(rbVideoModeDelay.selected==true)
	{
		      lblSettings.enabled=true;
		      togglecheck=false;
	}
	
}

private function FMLEConfirmation(event:CloseEvent):void
	
{
	if (event.detail == Alert.YES) 
	{
		lblSettings.enabled=false;
		setCamResolutionValue();
		if(this.width==598)
			showHideSettings();
		togglecheck=true;
	}
	else
	{
		rbVideoModeDelay.selected=true;
		lblSettings.enabled=true;
		changeSelection('videoMode');
		togglecheck=false;
	}
}
private function videoDeviceTypeChangeHandler():void
{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=cmbVideoDeviceType.selectedItem.index;
	setCamResolutionDataProvider();
}
private function setCamResolutionDataProvider():void
{
	cmbResolution.dataProvider = null;
	cmbResolution.dataProvider=Constants.videoResolutions;
	arResolution=Constants.videoResolutions;
	/*if(cmbVideoDeviceType.selectedIndex == 0)
	{
		cmbResolution.dataProvider = Constants.webCamVideoResolution;
		cmbResolution.selectedIndex=0;
		arResolution = Constants.webCamVideoResolution;
	}
	else if(cmbVideoDeviceType.selectedIndex == 1)
	{
		cmbResolution.dataProvider = Constants.hdWebCamVideoResolution;
		cmbResolution.selectedIndex=0;
		arResolution = Constants.hdWebCamVideoResolution;
	}
	else if(cmbVideoDeviceType.selectedIndex == 2)
	{
		cmbResolution.dataProvider = Constants.easyCapVideoResolution;
		cmbResolution.selectedIndex=0;
		arResolution = Constants.easyCapVideoResolution;
	}
	else if(cmbVideoDeviceType.selectedIndex == 3)
	{
		cmbResolution.dataProvider = Constants.blackMagicVideoResolution;
		cmbResolution.selectedIndex=0;
		arResolution = Constants.blackMagicVideoResolution;
	}*/
	setCamResolutionValue();
}
private function setModeratorSettingForMeeting():void
{
	if (ClassroomContext.isModerator)
	{
		if (Log.isDebug())
			log.debug("init ClassroomContext.isModerator");
		// For record settings
		lblCourse.text=ClassroomContext.course.courseName;
		//					if(FlexGlobals.topLevelApplication.mainContainerComp.classroomComp.savedLectureName == "")
		//					{
		//						FlexGlobals.topLevelApplication.mainContainerComp.classroomComp.savedLectureName=ClassroomContext.lecture.lectureName;
		//					}
		lectureTopicValue.text=ClassroomContext.lecture.displayName;
		
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords == "")
		{
			//Commenting code to fix Bug#15244
			//Fix for Bug# 14074
			/*if(ClassroomContext.lecture.keywords =="")
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords=ClassroomContext.lecture.displayName;
			}
			else
			{*/
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords=ClassroomContext.lecture.keywords;
			/*}*/
		}
		txtkeywords.text=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.savedKeywords;
		if (ClassroomContext.aviewClass.isMultiBitrate != "Y")
		{
			recordChoiceMultiQuality.visible=false;
			recordChoiceMultiQuality.visible=false;
			recordChoiceMultiQuality.includeInLayout=false;
		}
		else
		{
			
			rb_RecordLowQuality.label="Low Quality" + " (" + getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[0].bandWidth) + ")";
			rb_RecordMedQuality.label="Medium Quality" + " (" + getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[1].bandWidth) + ")";
			rb_RecordHighQuality.label="High Quality" + " (" + getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[2].bandWidth) + ")";
		}
		
		if (!ClassroomContext.record_selectionCheck)
		{
			chkrecordsession.selected=false;
			disableVideoQuality();
		}
	}
	else
	{
		if (Log.isDebug())
			log.debug("init else ClassroomContext.isModerator");
		mainvbox.removeChild(recordsettingscan);
		
	}
	if(ClassroomContext.aviewClass.isMultiBitrate != "Y" || (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.userVO.userName).userRole  == Constants.PRESENTER_ROLE && ClassroomContext.aviewClass.isMultiBitrate == "Y") || (ClassroomContext.currentPresenterName!="" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.getUserSO(ClassroomContext.currentPresenterName).userType  == Constants.STUDENT_TYPE && ClassroomContext.aviewClass.isMultiBitrate == "Y"))
		mainvbox.removeChild(stdVideoSettings);
	lbl_userSettings.text="Teacher Video Settings (Sending)";
}

private function getBandwidthLabel(bandwidth:Number):String{
	var label:String="";
	if (bandwidth >= 1024){
		label=(bandwidth / 1024) + "Mbps";
	}
	else{
		label=bandwidth + "Kbps";
	}
	return label;
}

private function bitRateModeSelection():void{
	if(rbg_dynmcSelection.selectedValue.toString()=="Manual"){
	ClassroomContext.subscriber_bandwidthSelection="Manual";
	canvas_Quality.visible=true;
	canvas_Quality.includeInLayout=true;
	}
	else if(rbg_dynmcSelection.selectedValue.toString()=="Automatic"){
	ClassroomContext.subscriber_bandwidthSelection="Automatic";
	canvas_Quality.visible=false;
	canvas_Quality.includeInLayout=false;
	} 
}

private function bitRateQualitySelection():void{
	if(rbg_bandQuality.selectedValue.toString()==rb_louQuality.label){//"Low Quality"+" ("+FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.streamRate[0].toString()+"Kbps)"){
	ClassroomContext.subscriber_bandwidthQualityName=rb_louQuality.label;
	band_Quality=0;
	}
	else if(rbg_bandQuality.selectedValue.toString()==rb_medQuality.label){
	ClassroomContext.subscriber_bandwidthQualityName=rb_medQuality.label;
	band_Quality=1;
	}
	else if(rbg_bandQuality.selectedValue.toString()==rb_highQuality.label){
	ClassroomContext.subscriber_bandwidthQualityName=rb_highQuality.label;
	band_Quality=2;
	}
	if(Log.isDebug()) log.debug("bitRateQualitySelection ClassroomContext.subscriber_bandwidthQualityName "+ClassroomContext.subscriber_bandwidthQualityName+" band_Quality "+band_Quality.toString());
}

public function disableVideoQuality():void{
	
	
	if (ClassroomContext.lecture.recordedContentUrl != null && ClassroomContext.lecture.recordedContentUrl != "" || 
		ClassroomContext.lecture.recordedVideoFilePath != null && ClassroomContext.lecture.recordedVideoFilePath != "" || 
		ClassroomContext.lecture.recordedPresenterVideoUrl != null && ClassroomContext.lecture.recordedPresenterVideoUrl != "" || 
		ClassroomContext.lecture.recordedViewerVideoUrl != null && ClassroomContext.lecture.recordedViewerVideoUrl != ""){
		
		lectureTopicValue.enabled=false;
		txtkeywords.text=ClassroomContext.lecture.keywords;
		txtkeywords.enabled=false;
		ClassroomContext.record_selectionCheck=false;
	}
	else if (chkrecordsession.selected){
		ClassroomContext.record_selectionCheck=true;
		lectureTopicValue.enabled=true;
		txtkeywords.enabled=true;
	}
	else if (!chkrecordsession.selected){
		ClassroomContext.record_selectionCheck=false;
		lectureTopicValue.enabled=false;
		txtkeywords.enabled=false;
	}
	
}

private function refreshList():void{
	isDriverRefreshPressed=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.refreshDriverList();
	init();
}

private function streamingOptionChange():void{
	if (rbgAudioOption.selection == rbAudioOnly){
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE)
			prevFmleVal=true;
		bandwidthSelect.enabled=false;
		camSelect.enabled=false;
		isAudioOnlyOptionSelected=true;
		//VideoDeviceType.enabled = false;
		//chkAdvncedSetting.enabled = false;
		toggleAdvancedSettingComponents(false);
		//chkboxUseFMLE.enabled=false;
		hboxVideoModeContainer.enabled=false;
		lblSettings.enabled=false;
		/*if(chkboxUseFMLE.selected)
			chkboxUseFMLE.selected=false;*/
		if(rbVideoModeQuality.selected)
		{
			rbVideoModeDelay.selected=true;
			togglecheck=false;
			changeSelection('videoMode')
		}
	}
	else{
		bandwidthSelect.enabled=true;
		isAudioOnlyOptionSelected=false;
		camSelect.enabled=true;
		lblSettings.enabled=true;
		if((Capabilities.os.toLowerCase().indexOf("win") > -1) && ClassroomContext.aviewClass.isMultiBitrate != "Y" && ClassroomContext.aviewClass.classType!="Meeting" && (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE))
		{
			//chkboxUseFMLE.enabled=true;
			if(!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isLocalAudioVideoSettings)
				hboxVideoModeContainer.enabled=true;
			if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE || prevFmleVal )
			{
				//chkboxUseFMLE.selected=true;
				rbVideoModeQuality.selected=true;
				lblSettings.enabled=false;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isFMLE=true;
			}
		}
		//VideoDeviceType.enabled = true;
		//chkAdvncedSetting.enabled = true;
		if(arrVideoDriver.length > 0)
			//chkAdvncedSetting.enabled=true;
		if ( arrVideoDriver.length > 0)
			toggleAdvancedSettingComponents(true);
	}
}


public function initurl():void{
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.showBandwidthWindow();
	/*if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.bugreportFormSpeedTestEnable == true){
		tooltipFetcher.send();
	}
	else{
		Alert.show("Please enter a classroom to enable this link.", "Bug Report Form");
	}*/
}

/* This function is to load the speed test web page when the user click the link to test connection speed  */
public function getSpeedTestURLResultHandler(event:ResultEvent):void{
	if(Log.isInfo()) log.info(event.result.tool.Link);
	
	//If single server is used for both content and streaming, then web server would be listening on 80, otherwise on 8080
	var contentServerPort:Number=(ClassroomContext.CONTENT_DOCUMENT == ClassroomContext.VIDEO_RECORD_SERVER) ? Constants.CONTENT_SERVER_PORT : Constants.CONTENT_SERVER_PORT_FIREWALL;
	
	toolTipLnk=encodeURI("http://" + ClassroomContext.VIDEO_RECORD_SERVER + ":" + contentServerPort + event.result.tool.Link);
	navigateToURL(new URLRequest(toolTipLnk), "_self");
}

public function getSpeedTestURLFaultHandler(event:FaultEvent):void{
	if(Log.isError()) log.error("video::SettingHandler::getSpeedTestURLFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
}

private function toggleAdvancedSettingComponents(bool:Boolean):void
{
	//cmbResolution.enabled =bool;
	//cmbFPS.enabled =bool;
	//cmbQuality.enabled =bool;
	//cmbKeyframe.enabled=bool;
	/*if(ClassroomContext.aviewClass.videoCodec==Constants.CODEC_H264)
	{
		//.enabled =bool;
		//cmbH264ProfilerValues.enabled =bool;
	}
	else if(ClassroomContext.aviewClass.videoCodec!=Constants.CODEC_H264)
	{
		//cmbH264Profile.enabled = false;
		//cmbH264ProfilerValues.enabled = false;
	}*/
}


protected function advancedSettingsClickHandler(event:MouseEvent = null):void
{
	// TODO Auto-generated method stub
	/*if(chkAdvncedSetting.selected)
	{
		cnvAdvancedSettings.setStyle('backgroundColor', '#C3D5E8');
		toggleAdvancedSettingComponents(true);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAdvancedSettingsChecked = true;
	}
	else
	{
		cnvAdvancedSettings.setStyle('backgroundColor', '#d2d4d4');
		toggleAdvancedSettingComponents(false);
		setCamResolutionValue();
		setXMLData(Constants.AR_FPS_VALUES, "15", cmbFPS);
		setXMLData(Constants.AR_KEY_FRAME_VALUES, "15", cmbKeyframe);
		setXMLData(Constants.AR_H264_PROFILER_VALUES, "3", cmbH264ProfilerValues);
		cmbQuality.selectedIndex = 0;
		cmbH264Profile.selectedIndex = 0;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isAdvancedSettingsChecked = false;
	}
	*/
}
private var resolutionValue:String;
private var arResolutionValues:Array;
private function isBandwidthValueValid():Boolean
{
	var isValidBandwidthEntered:Boolean=true;
	if(ClassroomContext.aviewClass.isMultiBitrate != "Y")
	{
		//Removed min and max bandwidth check for teacher users. i.e. a teacher can publish at any bitrate from 28Kbps to 8505Kbps.
		if(ClassroomContext.userVO.role == Constants.TEACHER_TYPE)
		{
			if(parseInt(bandwidthSelect.textInput.text).toString()=="NaN" || parseInt(bandwidthSelect.textInput.text)<1)
			{
				isValidBandwidthEntered=false;
				Alert.show("Please enter a valid video bandwidth value. ", "INFO", 0, this);
			}
		}
		else
		{
			if(parseInt(bandwidthSelect.textInput.text).toString()=="NaN" || parseInt(bandwidthSelect.textInput.text)<1)
			{
				isValidBandwidthEntered=false;
				Alert.show("Please enter a valid video bandwidth value. ", "INFO", 0, this);
			}
			else if(parseInt(bandwidthSelect.textInput.text)>ClassroomContext.aviewClass.maxPublishingBandwidthKbps)
			{
				isValidBandwidthEntered=false;
				Alert.show("Value entered should not be greater than "+ClassroomContext.aviewClass.maxPublishingBandwidthKbps+". ", "INFO", 0, this);
			}
		}
	}
	return isValidBandwidthEntered;
}
private function setCamResolutionValue():void
{
	//bandwidthSelectFocusOutHandler();
	if (ClassroomContext.aviewClass.videoCodec != Constants.CODEC_VP6 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videodriver.length > 0)
	{
		var selectedCamera:Camera=Camera.getCamera(this.camSelect.selectedIndex.toString());
		if(selectedCamera!=null)
		{
				var factor1:int=Math.floor(selectedCamera.width/16);
				var factor2:int=Math.floor(selectedCamera.height/9);
		}	
		var is4By3:Boolean = false;
		if(ClassroomContext.aviewClass.videoCodec!=Constants.CODEC_VP6 &&( factor1>0 && factor1>=(factor2-2) && factor1<(factor2+2)))
		{
			is4By3=false;
		}
		else if(ClassroomContext.aviewClass.videoCodec==Constants.CODEC_VP6)
		{
			is4By3 =true;
		}
		
		//bwKbps:int,cameraType:String,isAdobeCodec:Boolean,is4By3:Boolean
		var enteredBandwidthValue:String;
		if(bandwidthSelect.selectedIndex<0)
			enteredBandwidthValue=bandwidthSelect.textInput.text; 
		else
			enteredBandwidthValue=bandwidthSelect.selectedItem.index.toString();
		//if(chkboxUseFMLE.selected==true)
		if(rbVideoModeQuality.selected==true)
			arResolutionValues = AVParameters.getPublishingParams(parseInt(enteredBandwidthValue), Constants.CAM_TYPE_FMLE, (ClassroomContext.aviewClass.videoCodec==Constants.CODEC_VP6)? false:true, is4By3);
		else
			arResolutionValues = AVParameters.getPublishingParams(parseInt(enteredBandwidthValue), FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType , (ClassroomContext.aviewClass.videoCodec==Constants.CODEC_VP6)? false:true, is4By3);
			//arResolutionValues = AVParameters.getPublishingParams(parseInt(enteredBandwidthValue), Constants.CAM_TYPE_WEBCAM , (ClassroomContext.aviewClass.videoCodec==Constants.CODEC_VP6)? false:true, is4By3);
		if(arResolution!=null)
		{
			applicationType::desktop{
				var tempValue:String=arResolutionValues[2] + " x " + arResolutionValues[3];	
			}
			//Fix for issue #19667
			applicationType::web{
				if(arResolutionValues !=null){
					var tempValue:String=arResolutionValues[2] + " x " + arResolutionValues[3];
				}
			}
			for (var i:int=0; i < arResolution.length; i++)
			{
				if (arResolution[i].value == tempValue)
				{
					cmbResolution.selectedIndex=i;
					break;
				}
			}
		}
	}
	
}

private function showHideSettings():void
{
	currentX = this.x;
	currentY = this.y;
	
	if(ClassroomContext.aviewClass.videoCodec == 'VP6' || ClassroomContext.aviewClass.isMultiBitrate == 'Y')
	{
		if(this.width==436)
		{
			showAdvance.play();
			hideAdvance.stop();
			//lblSettings.text="Advanced Settings <<";
		}
		else
		{
			previousWidth=436;
			hideAdvance.play();
			showAdvance.stop();
			//lblSettings.text="Advanced Settings >>";
		}
	}
	else
	{
	
		if(this.width==368)
		{
			showAdvance.play();
			hideAdvance.stop();
			//lblSettings.text="Advanced Settings <<";
			//Fix for issue #19931
			applicationType::web{
				isShowAdavancedSettings = true;
			}
		}
		else
		{
			
			previousWidth=368;
			hideAdvance.play();
			showAdvance.stop();
			//lblSettings.text="Advanced Settings >>";
			//Fix for issue #19931
			applicationType::web{
				isShowAdavancedSettings = false;
			}
		}
	}
}

private function settingsResizeHandler():void
{
	this.x=(FlexGlobals.topLevelApplication.stage.stageWidth -this.width)/2;
}


public function changeSelection(value:String):void
{
	if (value == "AudioVideo")
	{
		if (rbAudioOnly.selected == true)
		{
			rbAudioOnly.setStyle("color", "#026293");
			rbAudioVideo.setStyle("color", "#3e3e3e");
			audioOnlyContainer.setStyle("backgroundColor", '#FFFFFF');
			audioVideoContainer.setStyle("backgroundColor", '#F0F0F0');
			
		}
		else
		{
			rbAudioVideo.setStyle("color", "#026293");
			rbAudioOnly.setStyle("color", "#3e3e3e");
			audioVideoContainer.setStyle("backgroundColor", '#FFFFFF');
			audioOnlyContainer.setStyle("backgroundColor", '#F0F0F0');
		}
	}
	else if (value == 'recordQuality')
	{
		if (rb_RecordLowQuality.selected == true)
		{
			rb_RecordLowQuality.setStyle("color", "#026293");
			rb_RecordHighQuality.setStyle("color", "#3e3e3e");
			rb_RecordMedQuality.setStyle("color", "#3e3e3e");
			lowQualityRecordContainer.setStyle("backgroundColor", '#FFFFFF');
			mediumQualityRecordContainer.setStyle("backgroundColor", '#F0F0F0');
			highQualityRecordContainer.setStyle("backgroundColor", '#F0F0F0');
			
		}
		else if (rb_RecordMedQuality.selected == true)
		{
			rb_RecordLowQuality.setStyle("color", "#3e3e3e");
			rb_RecordHighQuality.setStyle("color", "#3e3e3e");
			rb_RecordMedQuality.setStyle("color", "#026293");
			lowQualityRecordContainer.setStyle("backgroundColor", '#F0F0F0');
			mediumQualityRecordContainer.setStyle("backgroundColor", '#FFFFFF');
			highQualityRecordContainer.setStyle("backgroundColor", '#F0F0F0');
		}
		else
		{
			rb_RecordLowQuality.setStyle("color", "#3e3e3e");
			rb_RecordHighQuality.setStyle("color", "#026293");
			rb_RecordMedQuality.setStyle("color", "#3e3e3e");
			lowQualityRecordContainer.setStyle("backgroundColor", '#F0F0F0');
			mediumQualityRecordContainer.setStyle("backgroundColor", '#F0F0F0');
			highQualityRecordContainer.setStyle("backgroundColor", '#FFFFFF');
		}
	}
	else if (value == "videoMode")
	{
		if (rbVideoModeDelay.selected == true)
		{
			rbVideoModeDelay.setStyle("color", "#026293");
			rbVideoModeQuality.setStyle("color", "#3e3e3e");
			videoModeDelayContainer.setStyle("backgroundColor", '#FFFFFF');
			VideoModeQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			
		}
		else
		{
			rbVideoModeQuality.setStyle("color", "#026293");
			rbVideoModeDelay.setStyle("color", "#3e3e3e");
			VideoModeQualityContainer.setStyle("backgroundColor", '#FFFFFF');
			videoModeDelayContainer.setStyle("backgroundColor", '#F0F0F0');
		}
	}
	else
		
	{
		if (rb_louQuality.selected == true)
		{
			rb_louQuality.setStyle("color", "#026293");
			rb_highQuality.setStyle("color", "#3e3e3e");
			rb_medQuality.setStyle("color", "#3e3e3e");
			lowQualityContainer.setStyle("backgroundColor", '#FFFFFF');
			mediumQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			highQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			
		}
		else if (rb_medQuality.selected == true)
		{
			rb_louQuality.setStyle("color", "#3e3e3e");
			rb_highQuality.setStyle("color", "#3e3e3e");
			rb_medQuality.setStyle("color", "#026293");
			lowQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			mediumQualityContainer.setStyle("backgroundColor", '#FFFFFF');
			highQualityContainer.setStyle("backgroundColor", '#F0F0F0');
		}
		else
		{
			rb_louQuality.setStyle("color", "#3e3e3e");
			rb_highQuality.setStyle("color", "#026293");
			rb_medQuality.setStyle("color", "#3e3e3e");
			lowQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			mediumQualityContainer.setStyle("backgroundColor", '#F0F0F0');
			highQualityContainer.setStyle("backgroundColor", '#FFFFFF');
		}
	}
}

public function camSelectChangeHandler():void
{
	//Fix for issue #19640
	applicationType::desktop{
		var appDir:String = File.applicationDirectory.nativePath;
		prefsFile = new File("file:///" + File.applicationDirectory.nativePath.toString()+ "\\config\\DeviceDetails.xml");
		stream = new FileStream();
		stream.open(prefsFile,FileMode.READ);
		prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable)); 
		stream.close();
		
		//cmbVideoDeviceType.selectedItem=(prefsXML.device.(@name.toString().toLowerCase() ==cmbdevice.selectedItem.label.toString().toLowerCase()).@type.toString());
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType = (prefsXML.device.(@name.toString().toLowerCase() ==camSelect.selectedItem.toString().toLowerCase()).@type.toString());
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=="")
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=Constants.CAM_TYPE_WEBCAM;
		}
		//cmbVideoDeviceType.selectedItem=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType;
		for(var i:int = 0; i< Constants.cameraDeviceType.length; i++)
		{
			if(Constants.cameraDeviceType[i].index == FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType)
			{
				cmbVideoDeviceType.selectedIndex = i;
				break;
			}
		}
		setCamResolutionDataProvider();	
		//setCamResolutionValue();
	}
	//Fix for issue #19667
	applicationType::web{
		getDeviceDetails=new HTTPService();
		getDeviceDetails.url = "config/DeviceDetails.xml";
		getDeviceDetails.send();
		getDeviceDetails.resultFormat="e4x";
		getDeviceDetails.addEventListener(ResultEvent.RESULT, deviceDetailsResultHandler);
		getDeviceDetails.addEventListener(FaultEvent.FAULT,deviceDetailsFaultHandler);
	}
}
//Fix for issue #19667
applicationType::web{
	private function deviceDetailsResultHandler(event:ResultEvent):void{
		prefsXML=event.result as XML;
		//Fix for issue #17085
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType = (prefsXML.device.(@name.toString().toLowerCase() ==camSelect.selectedItem.toString().toLowerCase()).@type.toString());
		if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=="")
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.cameraDeviceType=Constants.CAM_TYPE_WEBCAM;
		}
		setCamResolutionValue();
	}
	
	private function deviceDetailsFaultHandler(event:FaultEvent):void{
		trace(event.fault.toString());
	}
}
/*protected function rb_louQuality_mouseOverHandler(event:MouseEvent):void
{
	//Alert.show("quality:"+getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[0].bandWidth));
	rb_louQuality.toolTip="Low:"+getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[0].bandWidth);
}
protected function rb_medQuality_mouseOverHandler(event:MouseEvent):void
{
	rb_medQuality.toolTip="Medium:"+getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[1].bandWidth);
}
protected function rb_highQuality_mouseOverHandler(event:MouseEvent):void
{
	rb_highQuality.toolTip="High:"+getBandwidthLabel(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[2].bandWidth);
}*/