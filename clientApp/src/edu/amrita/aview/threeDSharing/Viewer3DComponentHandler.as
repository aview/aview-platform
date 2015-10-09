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
 * File			: Viewer3DComponentHandler.as
 * Module		: 3DViewer
 * Developer(s)	: Jayakrishnan R, Arun V
 * Reviewer(s)	: Pradeesh,Remya T
 *
 * For 3DViewer Shared object connection and synchandler functions.
 *
 */


import com.amrita.edu.collaboration.CollaborationObject;

import context.ContextManager;

applicationType::DesktopWeb{
	import edu.amrita.aview.common.components.fileManager.FileManager;
}
applicationType::mobile{
	import edu.amrita.aview.common.components.fileManager.MobileFileManager;
}
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;

import flash.events.MouseEvent;
import flash.utils.setTimeout;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;

import spark.components.Label;
import spark.events.IndexChangeEvent;

applicationType::DesktopWeb{
	[Bindable]
	[Embed(source="assets/images/view-fullscreen1.png")]
	public var popoutIcon:Class;
	[Bindable]
	[Embed(source="assets/images/windows_nofullscreen.png")]
	public var popinIcon:Class;
}
public var presenterViewer3D:String;

/**
 * Flag to check the module is pop-out or not
 */
public var isPopOut:Boolean=false;

/**
 * Flag for checking the pop-out button clicked or not
 */
public var isPopBtnClicked:Boolean=false;

/**
 * Object of CollaborationObject
 */
public var viewerSharedObject:CollaborationObject=null;
/**
 * For displaying a text message when the module is disabled
 */
private var messageLabel:Label=new Label();

/**
 * Integer object mainly used in 'for' loops
 */
private var i:int;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.threeDSharing.Viewer3DComponentHandler.as");

/**
 *
 * @private
 *
 * @return void
 *
 */

private function init():void {
	if (!ClassroomContext.IS_3D_ENABLED) {
		messageLabel.text=Constants.MODULE_DISABLE_MSG;
		this.addElement(messageLabel);
		messageLabel.percentWidth=100;
		messageLabel.height=50;
		messageLabel.setStyle("textAlign", "center");
		messageLabel.setStyle("fontSize", "30");
		messageLabel.horizontalCenter=0;
		messageLabel.verticalCenter=0;
	}
	presenterViewer3D=ClassroomContext.currentPresenterName;
	applicationType::DesktopWeb{
		viewer3DSWC.userRole=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole;
		fileDownloaderObj.usingModule=FileManager.MODULE_3D_SHARING;
	}
	applicationType::mobile{
		connectSharedObjects();
		if(FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole == Constants.PRESENTER_ROLE){
			isPresenterRole = true;
		}
		viewer3DSWC.setupGUI(isPresenterRole);
		viewer3DSWC.userRole=FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole;
		fileDownloaderObj.usingModule=MobileFileManager.MODULE_3D_SHARING;
	}
	//Bug fix 5209 start
	if (this.stage) {
		this.stage.frameRate=24;
	}
	// Rev 4326 SRS
	applicationType::desktop{
		viewer3DSWC.popOutBtn.visible=true;
		viewer3DSWC.popOutBtn.setStyle("icon", popoutIcon);
	}
	// Rev 4326 SRS
	//Bug fix 5209 end
}

/**
 *
 * @public
 * Invoked from connectModulesCollabObjects() function in users.as
 *
 * It connect the 3D shared obejct.
 *
 * @return void
 *
 */
public function connectSharedObjects():void {
	viewerSharedObject=ClassroomContext.collaborationService.connectCollaborationObject("threeD_so");
	viewerSharedObject.setOnChange(usersSyncHandler);
}

/**
 *
 * @protected
 * Invoked from viewer3DSWC initialize
 *
 * It assign server ip and port numbers to the variables
 *
 * @param event of type FlexEvent
 * @return void
 *
 */
protected function viewer3DSWC_initializeHandler(event:FlexEvent):void {
	applicationType::DesktopWeb{
		viewer3DSWC.btnListingServerFiles.addEventListener(MouseEvent.CLICK, listRemoteFiles);
	}
	applicationType::mobile{
		groupThreeDHolder.addElement(viewer3DSWC);
		if(FlexGlobals.topLevelApplication.screenTypes ==  Constants.SCREENTYPE_ALLINONE){
			viewer3DSWC.width = (FlexGlobals.topLevelApplication.width/100)*70;
			viewer3DSWC.height = (FlexGlobals.topLevelApplication.height - FlexGlobals.topLevelApplication.actionBar.height);
		}else{
			viewer3DSWC.width = (FlexGlobals.topLevelApplication.width/100)*90;
			viewer3DSWC.height = (FlexGlobals.topLevelApplication.height - (FlexGlobals.topLevelApplication.collaborationBtnsHeight+FlexGlobals.topLevelApplication.actionBar.height));
		}
	}
	viewer3DSWC.contentViewer3D=ClassroomContext.CONTENT_VIEWER3D;
	viewer3DSWC.fmsViewer3D=ClassroomContext.FMS_USER;
	viewer3DSWC.portViewer3D=ClassroomContext.portWAMP;
	viewer3DSWC.viewer3DSWCComp=viewer3DSWC;
	viewer3DSWC.is3dModuleEnabled=ClassroomContext.IS_3D_ENABLED;
	applicationType::DesktopWeb{
		viewer3DSWC.ipAddressWaterdemo=ClassroomContext.ipAddress;
		viewer3DSWC.usernameWaterdemo=ClassroomContext.userVO.userName;
	}
	//Fix for issues #16721 and #16894
	applicationType::web{
		viewer3DSWC.platform ="web";
	}
	applicationType::desktop{
		viewer3DSWC.platform ="desktop";
	}
	applicationType::mobile{
		init();
	}
}

/**
 * @public
 * This function is used to enable 3Dscene
 * @return void.
 */
public function enable3DScene():void {
	if (viewer3DSWC) {
		if (viewer3DSWC.flare3DEngineInstance) {
			viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
		}
	}
}

/**
 * @public
 * This function is used to remove the 3D scene
 * @return void.
 */
public function disable3DScene():void {
	if (viewer3DSWC) {
		if (viewer3DSWC.flare3DEngineInstance) {
			viewer3DSWC.flare3DEngineInstance.sceneObject.visible=false;
		}
	}
}

/**
 * @public
 * The function is called when button 3DViewer is clicked in consolidated mode.
 * @return void
 */
public function click_Conso_3DViewer():void // Rev 4326 SRS
{
	applicationType::DesktopWeb{
		
		if((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"] == 6 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModulle == 6) || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isQuizPollingMod  )
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.onChangeModule();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isQuizPollingMod = false;
		} 
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModulle=2;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectModuleByUser) {
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setActiveWindowInSO(2);
		}
		FlexGlobals.topLevelApplication.stage.frameRate=24;
		
		
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("remove");
		//if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoWallLayout != Constants.SIMPLE_LAYOUT) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnShowViewersWall.enabled=true;
		//}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Doc.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Whiteboard.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_LiveQuiz.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.evaluationFlag=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_PollingQuiz.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.pollingFlag=false;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_2DViewer.enabled=true;
		//ContextManager.viewer2DModule.loadedListVisiblityChange();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_vidsharing.enabled=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex=2;
		
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isPopOut) // Rev 4326 SRS
		{
			
			
			applicationType::DesktopWeb {
				//Enable Deskop sharing button
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.btnDesktopSharing.enabled=true;
			}
			
			if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.contains(this)) //viewer3DComp
			{
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.addElement(this); //viewer3DComp
			}
			if (!viewer3DSWC.flare3DEngineInstance) {
				if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == Constants.PRESENTER_ROLE) {
					viewer3DSWC.addComponent();
				} else if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != Constants.PRESENTER_ROLE && !viewer3DSWC.lateUser) {
					viewer3DSWC.addComponent();
				}
			} else {
				viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=true;
			if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.netStatusmsg && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.alertServerSwitching == null) {
				Alert.show("Your connection to server is lost. Please wait till it reconnects automatically.", "MESSAGE");
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.netStatusmsg=true;
			}
		}
		applicationType::desktop {
			if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isUnInterruptedDesktopsharingON()) {
				FlexGlobals.topLevelApplication.activate();
			}
			// Rev 4326 SRS
			if (isPopOut) {	
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.activate();
			} else {
				FlexGlobals.topLevelApplication.activate();
				//Fix for issue #18757
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopViewer.desktopSharingWindow){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopViewer.desktopSharingWindow.alwaysInFront = true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.desktopViewer.desktopSharingWindow.open(true);
				}
				
			}
		}
		// Rev 4326 SRS
		if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isViewer3DInitialized && !isPopOut) // Rev 4326 SRS
		{
			init_viewer3D();
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.contextMenuList) {
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.hideContextMenuList();
		}
	}
}

/**
 * @public
 * The function is used to add the 3DViewer component.
 * @return void
 */
//PNCR: move the initialization and removal to 3d module
public function init_viewer3D():void {
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.addChild(this);
	contentIPAddress=ClassroomContext.CONTENT_VIEWER3D;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DInitial=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initviewer3D_flag=1;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.isViewer3DInitialized=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=false;
}

/**
 * @public
 * The function is for removing viewer3DComp component.
 * @return void
 */
public function removeViewer3DComp():void {
	applicationType::DesktopWeb{
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded && viewer3DSWC) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initviewer3D_flag=0;
		viewer3DSWC.removeComponent();
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=false;
	}
	}
	applicationType::mobile{
		if (FlexGlobals.topLevelApplication.viewer3DLoaded && viewer3DSWC) {
			viewer3DSWC.removeComponent();
			FlexGlobals.topLevelApplication.viewer3DLoaded=false;
			is3DActionBtnsEnable = false;
		}
	}
}

/**
 * @public
 * The function is used to remove the 3DViewer component.
 * It will remove the 3DViewer elements
 * @return void
 */
public function remove_3DViewer():void {
	//Bug Fix #3673
	/* if(remove3D)
	{
	if(viewer3DBox.contains(viewer3DComp))
	{
	viewer3DBox.removeChild(viewer3DComp);
	}
	} */
	if (viewer3DSWC.flare3DEngineInstance) {
		viewer3DSWC.flare3DEngineInstance.sceneObject.visible=false;
	}
}

/**
 * @public
 * The function is used to set the size of 3DViewer component
 * when the component is resized in cosolidated mode.
 * @return void
 */
public function on3DViewerResize():void {
	applicationType::DesktopWeb{
		if (!viewer3DSWC) {
			return;
		}
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex != 2) {
			if (viewer3DSWC.flare3DEngineInstance) {
				viewer3DSWC.flare3DEngineInstance.sceneObject.visible=false;
			}
			return;
		}
		viewer3DSWC.imgInfo.x=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - 100;
		viewer3DSWC.imgInfo.y=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.height - 70;
		if (viewer3DSWC.flare3DEngineInstance && !viewer3DSWC.loadIcon.visible) {
			try {
				viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
				viewer3DSWC.flare3DEngineInstance.screenHeight=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.height - 40;
				viewer3DSWC.flare3DEngineInstance.screenWidth=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - 5;
				viewer3DSWC.flare3DEngineInstance.screenAspectRatio=(viewer3DSWC.flare3DEngineInstance.screenWidth / viewer3DSWC.flare3DEngineInstance.screenHeight);
				viewer3DSWC.flare3DEngineInstance.objectAspectRatio=(viewer3DSWC.flare3DEngineInstance.objectHeight / viewer3DSWC.flare3DEngineInstance.objectWidth);
				if (viewer3DSWC.flare3DEngineInstance.objectAspectRatio <= viewer3DSWC.flare3DEngineInstance.screenAspectRatio) {
					// The scaled size is based on the height
					viewer3DSWC.flare3DEngineInstance.scaledHeight=viewer3DSWC.flare3DEngineInstance.screenHeight;
					viewer3DSWC.flare3DEngineInstance.scaledWidth=(viewer3DSWC.flare3DEngineInstance.screenHeight * viewer3DSWC.flare3DEngineInstance.objectAspectRatio);
				} else {
					// The scaled size is based on the width
					//viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth = viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenWidth;
					//viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledHeight = (viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth / viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectAspectRatio);
				}
				if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isPopOut) {
					//Fix for issues #19175,#18456 and #18390
					applicationType::web{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.isFullScreen){
							viewer3DSWC.flare3DEngineInstance.sceneObject.setViewport((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.x + (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2) ,FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.y, viewer3DSWC.flare3DEngineInstance.scaledWidth + 100, viewer3DSWC.flare3DEngineInstance.scaledHeight+300);
						}
						else{
							viewer3DSWC.flare3DEngineInstance.sceneObject.setViewport((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.x + (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2) + 10, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.y + 185, viewer3DSWC.flare3DEngineInstance.scaledWidth, viewer3DSWC.flare3DEngineInstance.scaledHeight);
						}
					}
					applicationType::desktop{
						viewer3DSWC.flare3DEngineInstance.sceneObject.setViewport((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.x + (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2) + 10, FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.canvas3.y + 185, viewer3DSWC.flare3DEngineInstance.scaledWidth, viewer3DSWC.flare3DEngineInstance.scaledHeight);
					}
					viewer3DSWC.leftCanvas.width=(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2;
					viewer3DSWC.rightCanvas.x=viewer3DSWC.leftCanvas.x + viewer3DSWC.leftCanvas.width + viewer3DSWC.flare3DEngineInstance.scaledWidth;
					viewer3DSWC.rightCanvas.width=((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2) - 7;
					viewer3DSWC.borderLine.x=viewer3DSWC.leftCanvas.x + viewer3DSWC.leftCanvas.width;
					viewer3DSWC.borderLine.width=viewer3DSWC.flare3DEngineInstance.scaledWidth;
					if (viewer3DSWC.scrollComponents && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole == "PRESENTER") {
						viewer3DSWC.scrollComponents.objectLayer.width=viewer3DSWC.leftCanvas.width;
					}
					viewer3DSWC.lblObjectName.width=viewer3DSWC.leftCanvas.width - 15;
					viewer3DSWC.imgInfo.x=viewer3DSWC.borderLine.x + viewer3DSWC.borderLine.width + 2 //viewer3DComp.viewer3DSWC.leftCanvas.x+viewer3DComp.viewer3DSWC.leftCanvas.width+viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth+5;
					viewer3DSWC.imgInfo.width=(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2 - 20;
				}
			} catch (error:Error) {
				if(Log.isError()) log.error("Error in on3DViewerResize method:"+ error.getStackTrace());
	
			}
		}
		viewer3DSWC.lblPageNo.x=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.width - 60;
		viewer3DSWC.lblObjectVisibility.x=(viewer3DSWC.borderLine.x + viewer3DSWC.borderLine.width) / 2;
		if (viewer3DSWC.memoryState) {
			viewer3DSWC.memoryState.x=viewer3DSWC.borderLine.x + viewer3DSWC.borderLine.width - 75;
		}
		applicationType::web {
			// Fix for issue #8032
			if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D){
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.move((FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.parent.width / 2 - (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.width / 2)), (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.parent.height / 2 - (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.height / 2)));
			}
		}
	}
}



/**
 * @public
 * Invoked when click on popOutBtn
 * pop-out the 3Dviewer window
 * @return void
 *
 */
public function popOut3DWindow():void {
	
	applicationType::desktop{
		isPopBtnClicked=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=true;
		if (!isPopOut) {
			isPopOut=true;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=false;
			if (viewer3DSWC.userRole != "PRESENTER") {
				if (viewer3DSWC.flare3DEngineInstance) {
					viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.flare3DEngineInstance);
					viewer3DSWC.flare3DEngineInstance.sceneObject.removeChild(viewer3DSWC.flare3DEngineInstance.defaultPivot);
					viewer3DSWC.flare3DEngineInstance.defaultPivot.dispose();
					viewer3DSWC.flare3DEngineInstance.sceneObject.dispose();
					viewer3DSWC.flare3DEngineInstance=null;
				}
				viewer3DSWC.viewer3DSWCComp.objectLoaded=false;
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multiple_3DViewer();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.onReSize();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.maximize();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.setMessageForFullScreenForMXMLComponents(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox, Constants.FULLSCREEN_MSG);
	
			if (viewer3DSWC.viewer3DSWCComp.scrollComponents) {
				viewer3DSWC.viewer3DSWCComp.scrollComponents.loadedList.x=viewer3DSWC.viewer3DSWCComp.brdrCont3DLoader.x;
				viewer3DSWC.viewer3DSWCComp.scrollComponents.loadedList.y=viewer3DSWC.viewer3DSWCComp.brdrCont3DLoader.y - 35;
			}
			viewer3DSWC.viewer3DSWCComp.lblPageNo.x=viewer3DSWC.brdrCont3DLoader.x + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.viewer3DCanvas.width - 60;
			viewer3DSWC.popOutBtn.setStyle("icon", popinIcon);
			viewer3DSWC.popOutBtn.toolTip="3D: Exit full screen";
		} else {
			isPopOut=false;
			if (viewer3DSWC.userRole != "PRESENTER") {
				viewer3DSWC.viewer3DSWCComp.objectLoaded=false;
			}
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.viewer3DCanvas.removeElement(this);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.close();
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.unSetMessageForFullScreenForMXMLComponents(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox);
			removeViewer3DComp();
			setTimeout(click_Conso_3DViewer, 0.5);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.resizeFunction();
			viewer3DSWC.viewer3DSWCComp.scrollComponents.loadedList.x=viewer3DSWC.viewer3DSWCComp.brdrCont3DLoader.x;
			viewer3DSWC.viewer3DSWCComp.scrollComponents.loadedList.y=viewer3DSWC.viewer3DSWCComp.brdrCont3DLoader.y - 35;
			viewer3DSWC.popOutBtn.setStyle("icon", popoutIcon);
			viewer3DSWC.popOutBtn.toolTip="3D: Full screen";
		}
	}
}

/**
 *
 * @public
 * Invoked from mouse move function when change the rotation or position of the object
 *
 * Store the position and rotation values to the shared object
 *
 * @param positionArray of type Array
 * @param rotationArray of type Array
 * @return void
 *
 */
public function shareMouseMove(positionArray:Array, rotationArray:Array):void {
	viewerSharedObject.setValue("position", positionArray);
	viewerSharedObject.setValue("rotation", rotationArray);
}

/**
 *
 * @public
 * Invoked when need to set the shared object values
 *
 * Store the property name and corresponding string value to the shared object
 *
 * @param property of type String
 * @param value of type String
 * @return void
 *
 */
public function setSharedObject(property:String, value:String):void 
{
	viewerSharedObject.lock();
	viewerSharedObject.setValue(property, value);
	viewerSharedObject.unlock();
}


public function setSharedObjectArray(property:String, value:Array):void 
{
	viewerSharedObject.lock();
	viewerSharedObject.setValue(property, value);
	viewerSharedObject.unlock();
}

public function setSharedObjectNumber(property:String, value:Number):void 
{
	trace("setting shared object,.."+value);
	viewerSharedObject.lock();
	viewerSharedObject.setValue(property, value);
	viewerSharedObject.unlock();
}
/**
 *
 * @public
 * Invoked when need to set the object details in shared object
 *
 * Store the property name and objectdetails(object partname,rotation and position values)
 *
 * @param property of type String
 * @param value of type String
 * @return void
 *
 */
public function setObjectdetails(property:String, value:Array):void 
{
	viewerSharedObject.setValue(property, value);
}

/**
 *
 * @public
 * Invoked when need to set the object name
 *
 * Clear all property values
 * Store currently loaded object name in shared obejct property "objectname".
 *
 * @param objectname of type String
 * @return void
 *
 */
public function shareObjectName(objectname:String):void {
	viewerSharedObject.lock();
	viewerSharedObject.setValue("clearserver", null);
	viewerSharedObject.setValue("objectname", objectname);
	viewerSharedObject.unlock();
}

/**
 *
 * @public
 * Invoked when need to set object position
 *
 * Store the object position.
 *
 * @param position of type Array
 * @return void
 *
 */
public function shareObjectPosition(position:Array):void {
	viewerSharedObject.setValue("position", position);
}

/**
 *
 * @public
 * Invoked when need to set object rotation
 *
 * Store the object position.
 *
 * @param rotation of type Array
 * @return void
 *
 */
public function shareObjectRotation(rotation:Array):void
{
	viewerSharedObject.setValue("rotation", rotation);
}

/**
 *
 * @public
 * Invoked when need to clear all shared object property
 *
 * @param propertyname of type String
 * @param value of type String
 * @return void
 *
 */
public function clearServer(propertyname:String, value:String):void 
{
	if (viewerSharedObject != null) {
		viewerSharedObject.removeAllValues();
		viewerSharedObject.setValue(propertyname, value);
	}
}

/**
 *
 * @public
 * This function is invoked whenever sharedobject updation happens
 *
 * It synchronize the users
 *
 *
 * @param SycEvent of type Object
 * @param name of type String
 *
 */
public function usersSyncHandler(SycEvent:Object, name:String):void 
{
	if (!viewer3DSWC.is3dModuleEnabled)
		return;
	if (viewerSharedObject.syncEventCount > 0 && viewer3DSWC.userRole != "PRESENTER" && !viewer3DSWC.login)
	{
		setSharedObject("newlogin", "true");
		shareObjectName(null);
		setSharedObject("newuser", "true");
		viewer3DSWC.newUser=true;
		viewer3DSWC.login=true;
		if(viewerSharedObject != null)
		{ 
			applicationType::DesktopWeb{
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"]==2 && viewerSharedObject.getData()["waterDemo"]=="true" && !viewer3DSWC.waterDemoEnabled)
				{
					//Waterdemo();
					if(!viewer3DSWC.waterDemo)
					{ 
						viewer3DSWC.waterDemoEnabled=true;
						setTimeout(viewer3DSWC.Waterdemo,4000);
					}
				}
			}
		}
	}
	//........................
	/*if(SyEvent.changeList[0].code!="clear")
	{*/
	if(viewerSharedObject!=null)
	{
		applicationType::DesktopWeb{
			if(viewer3DSWC.waterDemo)
			{
				
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["username"]!=viewer3DSWC.waterDemo.userName)
				{
					trace("same username...");
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["awayimage"]!=null)
					{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["awayimage"]=="true" && !viewer3DSWC.waterDemo.logoShowing)
						{
							viewer3DSWC.waterDemo.logoShowing=true;
							viewer3DSWC.waterDemo._showingLiquidImage=true;
							//viewer3DSWC.waterDemo._imageBrush.fromSprite(new ImageClip() as Sprite);
							viewer3DSWC.waterDemo._fluidDisturb.disturbBitmapMemory(0.5, 0.5, -10, viewer3DSWC.waterDemo._imageBrush.bitmapData, -1, 0.01);
						}
						else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["awayimage"]=="false")
						{
							viewer3DSWC.waterDemo.logoShowing=false;
							viewer3DSWC.waterDemo._showingLiquidImage=false;
							viewer3DSWC.waterDemo._fluidDisturb.releaseMemoryDisturbances();
						}
						else
						{
							
						}
					}
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]!=null)
					{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]=="WaterDemo_Brush3_9")
						{
							viewer3DSWC.waterDemo._activeMouseBrushClip=viewer3DSWC.waterDemo.brushClip3
							viewer3DSWC.waterDemo._mouseBrush.fromSprite(viewer3DSWC.waterDemo._activeMouseBrushClip, 2);
						}
						else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]=="WaterDemo_Brush1_7")
						{
							viewer3DSWC.waterDemo._activeMouseBrushClip=viewer3DSWC.waterDemo.brushClip1
							viewer3DSWC.waterDemo._mouseBrush.fromSprite(viewer3DSWC.waterDemo._activeMouseBrushClip, 2);
						}
						else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]=="WaterDemo_Brush2_8")
						{
							viewer3DSWC.waterDemo._activeMouseBrushClip=viewer3DSWC.waterDemo.brushClip2
							viewer3DSWC.waterDemo._mouseBrush.fromSprite(viewer3DSWC.waterDemo._activeMouseBrushClip, 2);
						}
						else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]=="WaterDemo_Brush4_10")
						{
							viewer3DSWC.waterDemo._activeMouseBrushClip=viewer3DSWC.waterDemo.brushClip4
							viewer3DSWC.waterDemo._mouseBrush.fromSprite(viewer3DSWC.waterDemo._activeMouseBrushClip, 2);
						}
						else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]=="WaterDemo_Brush5_11")
						{
							viewer3DSWC.waterDemo._activeMouseBrushClip=viewer3DSWC.waterDemo.brushClip5
							viewer3DSWC.waterDemo._mouseBrush.fromSprite(viewer3DSWC.waterDemo._activeMouseBrushClip, 2);
						}
						else if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["brushtype"]=="WaterDemo_Brush6_12")
						{
							viewer3DSWC.waterDemo._activeMouseBrushClip=viewer3DSWC.waterDemo.brushClip6
							viewer3DSWC.waterDemo._mouseBrush.fromSprite(viewer3DSWC.waterDemo._activeMouseBrushClip, 2);
						}
						else
						{
							
						}
					}
					if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["rain"]!=null)
					{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["rain"]=="true")
						{
							viewer3DSWC.waterDemo._dropTmr.start();
						}
						else
						{
							viewer3DSWC.waterDemo._dropTmr.stop();
						}
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["raindelay"]!=null)
						{
							viewer3DSWC.waterDemo._dropTmr.delay =parseInt(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["raindelay"]);
						}
					}
					if (parseInt(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["mouselife"])==0)
					{
						var ex:Number=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["eventx"]);
						var ey:Number=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["eventy"]);
						viewer3DSWC.waterDemo._fluidDisturb.disturbBitmapInstant(ex, ey, -viewer3DSWC.waterDemo.mouseBrushStrength, viewer3DSWC.waterDemo._mouseBrush.bitmapData);
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObjectNumber("mouselife",1);
						trace("syn eventx............."+ex+"..eventy.."+ey);
					}
					else if (parseInt(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["mouselife"])==2)
					{
						ex=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["eventx"]);
						ey=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["eventy"]);
						var BrushLife:Number=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["mousebrushlife"]);
						viewer3DSWC.waterDemo._fluidDisturb.disturbBitmapMemory(ex, ey,-5*viewer3DSWC.waterDemo.mouseBrushStrength,viewer3DSWC.waterDemo._mouseBrush.bitmapData,BrushLife,0.2);
						FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObjectNumber("mouselife",1);
					}
					else 
					{
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["elevation"]!=null && (parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["elevation"])!=viewer3DSWC.waterDemo._cameraController._sOCameraController.elevation))
						{
							viewer3DSWC.waterDemo._cameraController._sOCameraController.elevation=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["elevation"]);
						}
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["azimuth"]!=null && (parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["azimuth"])!=viewer3DSWC.waterDemo._cameraController._sOCameraController.azimuth))
						{
							viewer3DSWC.waterDemo._cameraController._sOCameraController.azimuth=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["azimuth"]);
						}
						if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["radius"]!=null && (parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["radius"])!=viewer3DSWC.waterDemo._cameraController._sOCameraController.radius))
						{
							viewer3DSWC.waterDemo._cameraController._sOCameraController.radius=parseFloat(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewerSharedObject.getData()["radius"]);
						}
					}
						}	
					//}
					
				}
			}
	}
	
	//..........................
	
	if (viewer3DSWC.userRole == "PRESENTER" && viewerSharedObject.getData()["newuser"] == "true") 
	{
		if (viewer3DSWC.objectDetails != null) {
			applicationType::DesktopWeb{
				if (viewer3DSWC.objectDetails.length != 0 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex == 2 && viewer3DSWC.flare3DEngineInstance != null || viewer3DSWC.objectDetails.length != 0 && isPopOut && viewer3DSWC.flare3DEngineInstance) {
					if (viewer3DSWC.flare3DEngineInstance.defaultPivot && !isPopOut || FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3D_count != 0 && viewer3DSWC.flare3DEngineInstance.defaultPivot) {
						//Position
						viewer3DSWC.currentPosition=viewer3DSWC.flare3DEngineInstance.defaultPivot.getPosition();
						//Rotation	
						viewer3DSWC.currentRotation=viewer3DSWC.flare3DEngineInstance.defaultPivot.getRotation();
						viewer3DSWC.positionArray=new Array(viewer3DSWC.currentPosition.x, viewer3DSWC.currentPosition.y, viewer3DSWC.currentPosition.z);
						viewer3DSWC.rotationArray=new Array(viewer3DSWC.currentRotation.x, viewer3DSWC.currentRotation.y, viewer3DSWC.currentRotation.z);
						if (viewer3DSWC.reloadObject) {
							for (i=0; i < viewer3DSWC.objectPartDetails.length; i++) {
								if (viewer3DSWC.lastLoadedPage == viewer3DSWC.objectPartDetails[i].canvasNumber) {
									viewer3DSWC.partOfObject=viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewer3DSWC.objectPartDetails[i].meshName);
									if (viewer3DSWC.partOfObject) 
									{
										viewer3DSWC.objectPartDetails[i]={canvasNumber: viewer3DSWC.objectPartDetails[i].canvasNumber, meshName: viewer3DSWC.partOfObject.name, vectorX: viewer3DSWC.partOfObject.getPosition().x, vectorY: viewer3DSWC.partOfObject.getPosition().y, vectorZ: viewer3DSWC.partOfObject.getPosition().z, rotateX: viewer3DSWC.partOfObject.getRotation().x, rotateY: viewer3DSWC.partOfObject.getRotation().y, rotateZ: viewer3DSWC.partOfObject.getRotation().z, updated: true, visible: viewer3DSWC.objectPartDetails[i].visible};
									}
								}
							}
						}
						setSharedObject("mousewheel", viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom.toString());
						//M1 load 2 objects & u1 log out, m1 delete one object & u1 login. m1 load another object
						//In this case issue happens to solve that issue this code is moved to here(Bug fix #7375)
						if (viewer3DSWC.flare3DEngineInstance.defaultPivot) {
							viewer3DSWC.flare3DEngineInstance.isObjectAnimated=viewer3DSWC.flare3DEngineInstance.isAnimated(viewer3DSWC.flare3DEngineInstance.defaultPivot);
						}
					}
					setObjectdetails("objectpartdetails", viewer3DSWC.objectPartDetails);
					//Setting Shared object values
					setSharedObject("newuser", "false");
					if ((viewer3DSWC.currentPage - 1) != -1) {
						shareObjectName(viewer3DSWC.objectDetails[viewer3DSWC.currentPage - 1].packageName);
					}
					shareObjectPosition(viewer3DSWC.positionArray);
					shareObjectRotation(viewer3DSWC.rotationArray);
					setObjectdetails("objectdetails", viewer3DSWC.objectDetails);
					setSharedObject("currentpage", "" + viewer3DSWC.currentPageNumber);
					setSharedObject("totalcanvas", "" + viewer3DSWC.objectDetails.length);
					if (viewer3DSWC.mousePointerIcon == viewer3DSWC.hidePointer) {
						setSharedObject("showpointer", "true");
						setSharedObject("pointerX", "" + viewer3DSWC.pointElepse.x);
						setSharedObject("pointerY", "" + viewer3DSWC.pointElepse.y);
						setSharedObject("width", "" + viewer3DSWC.borderLine.width);
						setSharedObject("height", "" + viewer3DSWC.borderLine.height);
					} else {
						setSharedObject("showpointer", "false");
					}
				}
			}
			applicationType::mobile{
				if (viewer3DSWC.objectDetails.length != 0 && viewer3DSWC.flare3DEngineInstance != null || viewer3DSWC.objectDetails.length != 0 && isPopOut && viewer3DSWC.flare3DEngineInstance) {
					if (viewer3DSWC.flare3DEngineInstance.defaultPivot && viewer3DSWC.flare3DEngineInstance.defaultPivot) {
						//Position
						viewer3DSWC.currentPosition=viewer3DSWC.flare3DEngineInstance.defaultPivot.getPosition();
						//Rotation	
						viewer3DSWC.currentRotation=viewer3DSWC.flare3DEngineInstance.defaultPivot.getRotation();
						viewer3DSWC.positionArray=new Array(viewer3DSWC.currentPosition.x, viewer3DSWC.currentPosition.y, viewer3DSWC.currentPosition.z);
						viewer3DSWC.rotationArray=new Array(viewer3DSWC.currentRotation.x, viewer3DSWC.currentRotation.y, viewer3DSWC.currentRotation.z);
						if (viewer3DSWC.reloadObject) {
							for (i=0; i < viewer3DSWC.objectPartDetails.length; i++) {
								if (viewer3DSWC.lastLoadedPage == viewer3DSWC.objectPartDetails[i].canvasNumber) {
									viewer3DSWC.partOfObject=viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewer3DSWC.objectPartDetails[i].meshName);
									if (viewer3DSWC.partOfObject) 
									{
										viewer3DSWC.objectPartDetails[i]={canvasNumber: viewer3DSWC.objectPartDetails[i].canvasNumber, meshName: viewer3DSWC.partOfObject.name, vectorX: viewer3DSWC.partOfObject.getPosition().x, vectorY: viewer3DSWC.partOfObject.getPosition().y, vectorZ: viewer3DSWC.partOfObject.getPosition().z, rotateX: viewer3DSWC.partOfObject.getRotation().x, rotateY: viewer3DSWC.partOfObject.getRotation().y, rotateZ: viewer3DSWC.partOfObject.getRotation().z, updated: true, visible: viewer3DSWC.objectPartDetails[i].visible};
									}
								}
							}
						}
						setSharedObject("mousewheel", viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom.toString());
						//M1 load 2 objects & u1 log out, m1 delete one object & u1 login. m1 load another object
						//In this case issue happens to solve that issue this code is moved to here(Bug fix #7375)
						if (viewer3DSWC.flare3DEngineInstance.defaultPivot) {
							viewer3DSWC.flare3DEngineInstance.isObjectAnimated=viewer3DSWC.flare3DEngineInstance.isAnimated(viewer3DSWC.flare3DEngineInstance.defaultPivot);
						}
					}
					setObjectdetails("objectpartdetails", viewer3DSWC.objectPartDetails);
					//Setting Shared object values
					setSharedObject("newuser", "false");
					if ((viewer3DSWC.currentPage - 1) != -1) {
						shareObjectName(viewer3DSWC.objectDetails[viewer3DSWC.currentPage - 1].packageName);
					}
					shareObjectPosition(viewer3DSWC.positionArray);
					shareObjectRotation(viewer3DSWC.rotationArray);
					setObjectdetails("objectdetails", viewer3DSWC.objectDetails);
					setSharedObject("currentpage", "" + viewer3DSWC.currentPageNumber);
					setSharedObject("totalcanvas", "" + viewer3DSWC.objectDetails.length);
					if (viewer3DSWC.mousePointerIcon == viewer3DSWC.hidePointer) {
						setSharedObject("showpointer", "true");
						setSharedObject("pointerX", "" + viewer3DSWC.pointElepse.x);
						setSharedObject("pointerY", "" + viewer3DSWC.pointElepse.y);
						setSharedObject("width", "" + viewer3DSWC.borderLine.width);
						setSharedObject("height", "" + viewer3DSWC.borderLine.height);
					} else {
						setSharedObject("showpointer", "false");
					}
				}
			}
		}
	}
	applicationType::DesktopWeb{
		if (viewerSharedObject.syncEventCount > 0 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomContextObj.userRole != "PRESENTER") {
			if (viewerSharedObject != null) 
			{
				
				if(viewerSharedObject.getData()["waterDemo"]=="true" && !viewer3DSWC.waterDemoEnabled)
				{
					viewer3DSWC.waterDemoEnabled=true;
					setTimeout(viewer3DSWC.Waterdemo,1000);
					//Waterdemo();
				}
				else if(viewerSharedObject.getData()["deleteWaterDemo"]=="true" && viewer3DSWC.waterDemoEnabled)
				{
					if(viewer3DSWC.waterDemo)
					{
						viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.waterDemo);
						viewer3DSWC.waterDemo.removeWaterDemo();
						//removeEventLisner();
						viewer3DSWC.waterDemo=null;
					}
					
				}
			
				
				
				
				
				
				
				
				if (viewerSharedObject.getData()["clearserver"] == "true") 
				{
					if (Log.isInfo())
						viewer3DSWC.logger.info("Presenter log off clearing student node details 3DViewer");
					viewer3DSWC.objectLoaded=false;
					viewer3DSWC.lblObjectVisibility.visible=false;
					if (viewer3DSWC.flare3DEngineInstance != null)
					{
						viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.flare3DEngineInstance);
						if (viewer3DSWC.flare3DEngineInstance.loadingObject) 
						{
							viewer3DSWC.flare3DEngineInstance.sceneObject.removeChild(viewer3DSWC.flare3DEngineInstance.loadingObject);
						}
						if (viewer3DSWC.flare3DEngineInstance.defaultPivot)
							viewer3DSWC.flare3DEngineInstance.defaultPivot.dispose();
						if (viewer3DSWC.pointElepse.visible == true) 
						{
							viewer3DSWC.partNameLabel.visible=false;
						}
						//Clearing object details from memory
						viewer3DSWC.flare3DEngineInstance.sceneObject.dispose();
						viewer3DSWC.flare3DEngineInstance=null;
					}
					viewer3DSWC.currentPage=0;
					viewer3DSWC.totalPageNumber=0;
					viewer3DSWC.currentPageNumber=0;
					viewer3DSWC.lblPageNo.text="Page1";
					viewer3DSWC.borderLine.visible=false;
					viewer3DSWC.imgInfo.visible=false;
					viewer3DSWC.lblObjectName.text="";
					viewer3DSWC.backGround.visible=true;
					viewer3DSWC.disableButtons();
					viewer3DSWC.objectDetails=new Array();
					viewer3DSWC.objectPartDetails=new Array();
					if (viewer3DSWC.scrollComponents)
					{
						viewer3DSWC.scrollComponents.loadedListDataProvider=new Array();
					}
					if (viewer3DSWC.memoryState) 
					{
						viewer3DSWC.memoryState.destroy();
						if (viewer3DSWC.spvObjectLoader.contains(viewer3DSWC.memoryState)) 
						{
							viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.memoryState);
							viewer3DSWC.viewer3DContextMenuArray=new Array(viewer3DSWC.showMemory);
							viewer3DSWC.hideContextMenuList();
						}
					}
					this.contextMenu=null;
				} else 
				{
					if (!isPopOut && viewer3DSWC.newUser == true && viewer3DSWC.objectDeleted == false && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"] != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex) {
						if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex == 2) {
							if (viewer3DSWC.flare3DEngineInstance) 
							{
								viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
							}
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Whiteboard.enabled=true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Doc.enabled=true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_vidsharing.enabled=true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=false;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_2DViewer.enabled=true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=true;
							FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("remove");
						}
					} else {
						//Delete object
						if (viewer3DSWC.objectDeleted == false && viewerSharedObject.getData()["delete"] == "true" && viewer3DSWC.flare3DEngineInstance != null) {
							if (viewer3DSWC.flare3DEngineInstance.defaultPivot != null) 
							{
								if (Log.isInfo())
									viewer3DSWC.logger.info("Deleting object at student node in 3DViewer");
								viewer3DSWC.backGround.visible=true;
								viewer3DSWC.lblObjectVisibility.visible=false;
								if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex != 2) 
								{
									viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex=2;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Whiteboard.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Doc.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_vidsharing.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=false;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_2DViewer.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("remove");
								}
								viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.flare3DEngineInstance);
								viewer3DSWC.partNameLabel.text="";
								if (viewerSharedObject.getData()["showpointer"] == "false" && viewer3DSWC.pointElepse.visible == true) {
									viewer3DSWC.partNameLabel.visible=false;
								}
								viewer3DSWC.flare3DEngineInstance.sceneObject.removeChild(viewer3DSWC.flare3DEngineInstance.loadingObject);
								viewer3DSWC.flare3DEngineInstance.loadingObject.dispose();
								viewer3DSWC.objectDeleted=true;
								viewer3DSWC.objectLoaded=false;
								viewer3DSWC.animationEnabled=false;
								viewer3DSWC.objectPartDetails=viewerSharedObject.getData()["objectpartdetails"];
								viewer3DSWC.currentPage=parseInt(viewerSharedObject.getData()["currentcanvas"]);
								//Clearing object details from memory
								if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.visible) {
									viewer3DSWC.flare3DEngineInstance.sceneObject.dispose();
								}
								viewer3DSWC.flare3DEngineInstance=null;
								viewer3DSWC.disableButtons();
								viewer3DSWC.lblObjectName.text="";
								viewer3DSWC.objectDetails=viewerSharedObject.getData()["objectdetails"];
								viewer3DSWC.borderLine.visible=false;
								viewer3DSWC.imgInfo.visible=false;
								viewer3DSWC.leftCanvas.visible=false;
								viewer3DSWC.rightCanvas.visible=false;
								this.contextMenu=null;
								if (viewer3DSWC.memoryState) 
								{
									viewer3DSWC.memoryState.destroy();
									if (viewer3DSWC.spvObjectLoader.contains(viewer3DSWC.memoryState)) {
										viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.memoryState);
										viewer3DSWC.viewer3DContextMenuArray=new Array(viewer3DSWC.showMemory);
										viewer3DSWC.hideContextMenuList();
									}
								}
								viewer3DSWC.lblPageNo.text="Page" + (viewer3DSWC.objectDetails.length + 1);
							}
						}
						if (viewerSharedObject.getData()["loadicon"] == "true" && !viewer3DSWC.loadIcon.visible && !viewer3DSWC.flare3DEngineInstance &&!viewer3DSWC.waterDemo) {
							if (Log.isInfo())
								viewer3DSWC.logger.info("Load icon visibility enabling in 3DViewer");
							viewer3DSWC.loadIcon.visible=true;
							viewer3DSWC.loadingLabel.visible=true;
						}
						//Load new object
						if (viewer3DSWC.objectLoaded == false && viewerSharedObject.getData()["objectname"] != null && !viewer3DSWC.flare3DEngineInstance && viewerSharedObject.getData()["currentcanvas"] != null) {
							viewer3DSWC.backGround.visible=true;
							viewer3DSWC.objectDetails=viewerSharedObject.getData()["objectdetails"];
							if (isPopOut && viewerSharedObject.getData()["newlogin"] == "false" || isPopOut && viewer3DSWC.newUser || !isPopOut && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"] == 2) {
								if (!isPopOut) {
									if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp) {
										if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initviewer3D_flag == 0 && !isPopOut || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.contains(this) && !isPopOut) {
											//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.addElement(this);
										}
									}
								}
								if (!isPopOut && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex != 2) {
									if (viewer3DSWC.flare3DEngineInstance) {
										viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
									}
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex=2;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Whiteboard.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Doc.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_vidsharing.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=false;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_2DViewer.enabled=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=true;
									FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("remove");
								}
								viewer3DSWC.objectDeleted=false;
								viewer3DSWC.objectPartDetails=viewerSharedObject.getData()["objectpartdetails"];
								if (viewer3DSWC.newUser == true) {
									viewer3DSWC.newUser=false;
								}
								viewer3DSWC.currentPage=parseInt(viewerSharedObject.getData()["currentcanvas"]);
								viewer3DSWC.objectAnimation=false;
								viewer3DSWC.animationEnabled=false;
								viewer3DSWC.lastLoadedPage=viewer3DSWC.currentPage;
								if (viewer3DSWC.objectDetails) {
									if (viewer3DSWC.currentPage - 1 != -1) {
										try {
											loadFileToCache(viewer3DSWC.objectDetails[viewer3DSWC.currentPage - 1].packageName);
											viewer3DSWC.lblPageNo.text="Page" + viewer3DSWC.currentPage;
											viewer3DSWC.objectLoaded=true;
											if (Log.isInfo())
												viewer3DSWC.logger.info("loading object going to start at student node in 3DViewer and path" + viewer3DSWC.objectDetails[viewer3DSWC.currentPage - 1].packageName);
										} 
										catch (error:Error) {
											if(Log.isError()) log.error("Error in usersSyncHandler method:"+ error.getStackTrace());
	
										}
									}
								}
								viewer3DSWC.enableButtons();
							}
						}
	
						if (viewerSharedObject.getData()["showpointer"] == "true" && viewer3DSWC.flare3DEngineInstance) {
							if (viewerSharedObject.getData()["showpointervisible"] == "true" && viewer3DSWC.flare3DEngineInstance.defaultPivot) {
								viewer3DSWC.pointElepse.visible=true;
								if (viewer3DSWC.pointElepse.x != parseFloat(viewerSharedObject.getData()["pointerX"]) || viewer3DSWC.pointElepse.y != parseFloat(viewerSharedObject.getData()["pointerY"])) {
									if (this.stage) {
										if (this.stage.frameRate == 7) {
											this.stage.frameRate=24;
										}
									}
									viewer3DSWC.borderScaleX=viewer3DSWC.borderLine.width / parseFloat(viewerSharedObject.getData()["width"]);
									viewer3DSWC.borderScaleY=viewer3DSWC.borderLine.height / parseFloat(viewerSharedObject.getData()["height"]);
									viewer3DSWC.pointElepse.x=viewer3DSWC.borderScaleX * parseFloat(viewerSharedObject.getData()["pointerX"]) - 5;
									viewer3DSWC.pointElepse.y=viewer3DSWC.borderScaleY * parseFloat(viewerSharedObject.getData()["pointerY"]) - 2;
									if (viewerSharedObject.getData()["partname"] != null) {
										viewer3DSWC.partNameLabel.visible=true;
										viewer3DSWC.partNameLabel.text=viewerSharedObject.getData()["partname"];
										viewer3DSWC.partNameLabel.x=viewer3DSWC.pointElepse.x + 10;
										viewer3DSWC.partNameLabel.y=viewer3DSWC.pointElepse.y + 25;
									} else {
										viewer3DSWC.partNameLabel.visible=false;
									}
								}
							} else {
								viewer3DSWC.pointElepse.visible=false;
							}
						} else if (viewerSharedObject.getData()["showpointer"] == "false" && viewer3DSWC.pointElepse.visible == true) {
							viewer3DSWC.pointElepse.visible=false;
							viewer3DSWC.partNameLabel.visible=false;
							viewer3DSWC.partNameLabel.text="";
						}
						//Zoom or rotate or drag object
						if (viewer3DSWC.flare3DEngineInstance != null && viewer3DSWC.flare3DEngineInstance.defaultPivot != null) {
							if (this.stage) {
								if (this.stage.frameRate == 7) {
									this.stage.frameRate=24;
								}
							}
							if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex != 2 && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModule_so.getData()["val"] == 2 && !isPopOut) {
								viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.tab2.selectedIndex=2;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Whiteboard.enabled=true;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_Doc.enabled=true;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_vidsharing.enabled=true;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_3DViewer.enabled=false;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.Conso_2DViewer.enabled=true;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DLoaded=true;
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.addRemoveDocComp("remove");
							}
							if (!isPopOut && !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.contains(this)) {
								FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.addElement(this);
							}
							if (viewerSharedObject.getData()["selectedpivot"] != null && viewerSharedObject.getData()["partselection"] == "true" && viewerSharedObject.getData()["newlogin"] == "false") {
								viewer3DSWC.partSelected=true;
								if (viewer3DSWC.lastPivot.name != viewerSharedObject.getData()["selectedpivot"]) {
									viewer3DSWC.resetScene();
									viewer3DSWC.lastPivot=viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewerSharedObject.getData()["selectedpivot"]);
								}
								viewer3DSWC.partSeperationDisabled=false;
							}
							if (viewer3DSWC.partSeparted) {
								viewer3DSWC.resetScene();
							}
							if (viewerSharedObject.getData()["selectedpivot"] != null && viewerSharedObject.getData()["partselection"] == "true") {
								viewer3DSWC.partSelected=true;
								//Bug fix #7372 start
								viewer3DSWC.partSeparted=true;
								//Bug fix #7372 end
								viewer3DSWC.partSeperationDisabled=false;
							}
							//Getting my values
							viewer3DSWC.currentPosition=viewer3DSWC.flare3DEngineInstance.loadingObject.getPosition();
							viewer3DSWC.currentRotation=viewer3DSWC.flare3DEngineInstance.loadingObject.getRotation();
							viewer3DSWC.zoomPresenterValue=viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom;
							viewer3DSWC.mouseWheel=viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom;
							viewer3DSWC.positionArray=viewerSharedObject.getData()["position"];
							viewer3DSWC.rotationArray=viewerSharedObject.getData()["rotation"];
							viewer3DSWC.objectPartDetails=viewerSharedObject.getData()["objectpartdetails"];
							if (viewer3DSWC.layerChanged != viewerSharedObject.getData()["layer"] && viewer3DSWC.objectPartDetails != null) 
							{
								viewer3DSWC.fullObjectVisible=false;
								for (i=0; i < viewer3DSWC.objectPartDetails.length; i++) {
									if (viewer3DSWC.currentPage == viewer3DSWC.objectPartDetails[i].canvasNumber) {
										if (!viewer3DSWC.objectPartDetails[i].visible && viewer3DSWC.objectPartDetails[i].meshName != null) 
										{
											viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewer3DSWC.objectPartDetails[i].meshName).visible=false;
										} 
										else if(viewer3DSWC.objectPartDetails[i].meshName != null) 
										{
											viewer3DSWC.fullObjectVisible=true;
											viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewer3DSWC.objectPartDetails[i].meshName).visible=true;
										}
									}
								}
								if (viewer3DSWC.fullObjectVisible) 
								{
									viewer3DSWC.lblObjectVisibility.visible=false;
								} 
								else 
								{
									viewer3DSWC.lblObjectVisibility.visible=true;
									viewer3DSWC.flare3DEngineInstance.loadingObject.visible=false;
									viewer3DSWC.partNameLabel.text="";
								}
								viewer3DSWC.layerChanged=viewerSharedObject.getData()["layer"];
							}
							if (parseInt(viewerSharedObject.getData()["currentcanvas"]) != viewer3DSWC.currentPage && viewerSharedObject.getData()["currentcanvas"] != null) {
								viewer3DSWC.currentPage=parseInt(viewerSharedObject.getData()["currentcanvas"]);
								viewer3DSWC.lastLoadedPage=viewer3DSWC.currentPage;
								viewer3DSWC.objectDetails=viewerSharedObject.getData()["objectdetails"];
							}
							//Mouse Wheel Zoom
							if (viewer3DSWC.mouseWheel != parseFloat(viewerSharedObject.getData()["mousewheel"]) && viewerSharedObject.getData()["mousewheel"] != null) {
								viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom=parseFloat(viewerSharedObject.getData()["mousewheel"]);
								viewer3DSWC.mouseWheel=parseFloat(viewerSharedObject.getData()["mousewheel"]);
							}
	
							if (viewerSharedObject.getData()["partselection"] == "false" && !viewer3DSWC.partSeperationDisabled) {
								//Bug #3993 start
								viewer3DSWC.resetScene();
								//Bug #3993 end
								viewer3DSWC.selectedPivot=viewer3DSWC.flare3DEngineInstance.defaultPivot;
								viewer3DSWC.lastPivot=viewer3DSWC.flare3DEngineInstance.defaultPivot;
								viewer3DSWC.rotationArray=null;
								viewer3DSWC.positionArray=null;
								viewer3DSWC.partSelected=false;
								viewer3DSWC.partSeperationDisabled=true;
							}
							if (viewer3DSWC.rotationArray != null && viewer3DSWC.positionArray != null && viewerSharedObject.getData()["newlogin"] == "false") {
								//Rotate object
								if (viewer3DSWC.currentRotation.x != viewer3DSWC.rotationArray[0] || viewer3DSWC.currentRotation.y != viewer3DSWC.rotationArray[1] || viewer3DSWC.currentRotation.z != viewer3DSWC.rotationArray[2]) {
									viewer3DSWC.lastPivot.setPosition(viewer3DSWC.positionArray[0], viewer3DSWC.positionArray[1], viewer3DSWC.positionArray[2]);
									viewer3DSWC.lastPivot.setRotation(viewer3DSWC.rotationArray[0], viewer3DSWC.rotationArray[1], viewer3DSWC.rotationArray[2]);
									viewer3DSWC.currentRotation=viewer3DSWC.selectedPivot.getRotation();
									viewer3DSWC.currentPosition=viewer3DSWC.selectedPivot.getPosition();
								}
							}
							if (viewer3DSWC.positionArray != null && viewer3DSWC.rotationArray != null && viewerSharedObject.getData()["newlogin"] == "false") {
								//Drag object
								if (viewer3DSWC.currentPosition.x != viewer3DSWC.positionArray[0] || viewer3DSWC.currentPosition.y != viewer3DSWC.positionArray[1] || viewer3DSWC.currentPosition.z != viewer3DSWC.positionArray[2]) {
									viewer3DSWC.lastPivot.setPosition(viewer3DSWC.positionArray[0], viewer3DSWC.positionArray[1], viewer3DSWC.positionArray[2]);
									viewer3DSWC.lastPivot.setRotation(viewer3DSWC.rotationArray[0], viewer3DSWC.rotationArray[1], viewer3DSWC.rotationArray[2]);
									viewer3DSWC.currentPosition=viewer3DSWC.selectedPivot.getPosition();
									viewer3DSWC.currentRotation=viewer3DSWC.selectedPivot.getRotation();
								}
							}
							//Animation control
							if (viewerSharedObject.getData()["animation"] == "true" && !viewer3DSWC.animationEnabled) {
								if (this.stage) {
									this.stage.frameRate=24;
								}
								viewer3DSWC.playReset=true;
								viewer3DSWC.resetScene();
								viewer3DSWC.flare3DEngineInstance.loadingObject.play();
								viewer3DSWC.animationEnabled=true;
							}
							if (viewerSharedObject.getData()["animation"] == "false" && viewer3DSWC.animationEnabled) {
								viewer3DSWC.flare3DEngineInstance.loadingObject.stop();
								viewer3DSWC.animationEnabled=false;
							}
						}
					}
				}
			}
		}
	}
	applicationType::mobile{
		if (viewerSharedObject.syncEventCount > 0 && FlexGlobals.topLevelApplication.mainApp.classroomContextObj.userRole != "PRESENTER") {
			if (viewerSharedObject != null) 
			{
				if (viewerSharedObject.getData()["clearserver"] == "true") 
				{
					if (Log.isInfo())
						viewer3DSWC.logger.info("Presenter log off clearing student node details 3DViewer");
					viewer3DSWC.objectLoaded=false;
					viewer3DSWC.lblObjectVisibility.visible=false;
					if (viewer3DSWC.flare3DEngineInstance != null)
					{
						viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.flare3DEngineInstance);
						if (viewer3DSWC.flare3DEngineInstance.loadingObject) 
						{
							viewer3DSWC.flare3DEngineInstance.sceneObject.removeChild(viewer3DSWC.flare3DEngineInstance.loadingObject);
						}
						if (viewer3DSWC.flare3DEngineInstance.defaultPivot)
							viewer3DSWC.flare3DEngineInstance.defaultPivot.dispose();
						if (viewer3DSWC.pointElepse.visible == true) 
						{
							viewer3DSWC.partNameLabel.visible=false;
						}
						//Clearing object details from memory
						viewer3DSWC.flare3DEngineInstance.sceneObject.dispose();
						viewer3DSWC.flare3DEngineInstance=null;
					}
					viewer3DSWC.currentPage=0;
					viewer3DSWC.totalPageNumber=0;
					viewer3DSWC.currentPageNumber=0;
					///viewer3DSWC.lblPageNo.text="Page1";
					viewer3DSWC.borderLine.visible=false;
					///viewer3DSWC.imgInfo.visible=false;
					viewer3DSWC.lblObjectName.text="";
					///viewer3DSWC.backGround.visible=true;
					///viewer3DSWC.disableButtons();
					viewer3DSWC.objectDetails=new Array();
					viewer3DSWC.objectPartDetails=new Array();
					this.contextMenu=null;
				} else 
				{
					if (viewer3DSWC.newUser == true && viewer3DSWC.objectDeleted == false && FlexGlobals.topLevelApplication.selectedModuleSO.getData()["val"] != FlexGlobals.topLevelApplication.selectedModuleIndex) {
						if (FlexGlobals.topLevelApplication.selectedModuleIndex == 2) {
							if (viewer3DSWC.flare3DEngineInstance) 
							{
								viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
							}
							FlexGlobals.topLevelApplication.viewer3DLoaded=true;
						}
					} else {
						//Delete object
						if (viewer3DSWC.objectDeleted == false && viewerSharedObject.getData()["delete"] == "true" && viewer3DSWC.flare3DEngineInstance != null) {
							if (viewer3DSWC.flare3DEngineInstance.defaultPivot != null) 
							{
								if (Log.isInfo())
									viewer3DSWC.logger.info("Deleting object at student node in 3DViewer");
								viewer3DSWC.lblObjectVisibility.visible=false;
								if (FlexGlobals.topLevelApplication.selectedModuleIndex != 2) 
								{
									viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
									FlexGlobals.topLevelApplication.viewer3DLoaded=true;
								}
								viewer3DSWC.spvObjectLoader.removeChild(viewer3DSWC.flare3DEngineInstance);
								viewer3DSWC.partNameLabel.text="";
								if (viewerSharedObject.getData()["showpointer"] == "false" && viewer3DSWC.pointElepse.visible == true) {
									viewer3DSWC.partNameLabel.visible=false;
								}
								viewer3DSWC.flare3DEngineInstance.sceneObject.removeChild(viewer3DSWC.flare3DEngineInstance.loadingObject);
								viewer3DSWC.flare3DEngineInstance.loadingObject.dispose();
								viewer3DSWC.objectDeleted=true;
								viewer3DSWC.objectLoaded=false;
								viewer3DSWC.animationEnabled=false;
								viewer3DSWC.objectPartDetails=viewerSharedObject.getData()["objectpartdetails"];
								viewer3DSWC.currentPage=parseInt(viewerSharedObject.getData()["currentcanvas"]);
								//Clearing object details from memory
								if (FlexGlobals.topLevelApplication.mainApp) {
									viewer3DSWC.flare3DEngineInstance.sceneObject.dispose();
								}
								viewer3DSWC.flare3DEngineInstance=null;
								viewer3DSWC.lblObjectName.text="";
								viewer3DSWC.objectDetails=viewerSharedObject.getData()["objectdetails"];
								viewer3DSWC.borderLine.visible=false;
								FlexGlobals.topLevelApplication.viewer3D.setStyle("backgroundAlpha","1");
								is3DActionBtnsEnable = false;
							}
						}
						if (viewerSharedObject.getData()["loadicon"] == "true" && !viewer3DSWC.loadIcon.visible && !viewer3DSWC.flare3DEngineInstance) {
							if (Log.isInfo())
								viewer3DSWC.logger.info("Load icon visibility enabling in 3DViewer");
							viewer3DSWC.loadIcon.visible=true;
							viewer3DSWC.loadingLabel.visible=true;
						}
						//Load new object
						if (viewer3DSWC.objectLoaded == false && viewerSharedObject.getData()["objectname"] != null && !viewer3DSWC.flare3DEngineInstance && viewerSharedObject.getData()["currentcanvas"] != null) {
							///viewer3DSWC.backGround.visible=true;
							viewer3DSWC.objectDetails=viewerSharedObject.getData()["objectdetails"];
							if (isPopOut && viewerSharedObject.getData()["newlogin"] == "false" || isPopOut && viewer3DSWC.newUser || !isPopOut && FlexGlobals.topLevelApplication.mainApp && FlexGlobals.topLevelApplication.selectedModuleSO.getData()["val"] == 2) {
								if (!isPopOut) {
									if (FlexGlobals.topLevelApplication.mainApp) {
										/*if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.initviewer3D_flag == 0 && !isPopOut || !FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.contains(this) && !isPopOut) {
											FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.classroomComponentSgl.viewer3DBox.addElement(this);
										}*/
									}
								}
								if (!isPopOut && FlexGlobals.topLevelApplication.selectedModuleIndex != 2) {
									if (viewer3DSWC.flare3DEngineInstance) {
										viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
										FlexGlobals.topLevelApplication.viewer3DLoaded=true;
									}
									FlexGlobals.topLevelApplication.selectedModuleIndex=2;
									FlexGlobals.topLevelApplication.viewer3DLoaded=true;
								}
								viewer3DSWC.objectDeleted=false;
								viewer3DSWC.objectPartDetails=viewerSharedObject.getData()["objectpartdetails"];
								if (viewer3DSWC.newUser == true) {
									viewer3DSWC.newUser=false;
								}
								viewer3DSWC.currentPage=parseInt(viewerSharedObject.getData()["currentcanvas"]);
								viewer3DSWC.objectAnimation=false;
								viewer3DSWC.animationEnabled=false;
								viewer3DSWC.lastLoadedPage=viewer3DSWC.currentPage;
								if (viewer3DSWC.objectDetails) {
									if (viewer3DSWC.currentPage - 1 != -1) {
										try {
											loadFileToCache(viewer3DSWC.objectDetails[viewer3DSWC.currentPage - 1].packageName);
											///viewer3DSWC.lblPageNo.text="Page" + viewer3DSWC.currentPage;
											viewer3DSWC.objectLoaded=true;
											if (Log.isInfo())
												viewer3DSWC.logger.info("loading object going to start at student node in 3DViewer and path" + viewer3DSWC.objectDetails[viewer3DSWC.currentPage - 1].packageName);
										} 
										catch (error:Error) {
											if(Log.isError()) log.error("Error in usersSyncHandler method:"+ error.getStackTrace());
											
										}
									}
								}
								is3DActionBtnsEnable = true;
								///viewer3DSWC.enableButtons();
							}
						}
						
						if (viewerSharedObject.getData()["showpointer"] == "true" && viewer3DSWC.flare3DEngineInstance) {
							if (viewerSharedObject.getData()["showpointervisible"] == "true" && viewer3DSWC.flare3DEngineInstance.defaultPivot) {
								viewer3DSWC.pointElepse.visible=true;
								if (viewer3DSWC.pointElepse.x != parseFloat(viewerSharedObject.getData()["pointerX"]) || viewer3DSWC.pointElepse.y != parseFloat(viewerSharedObject.getData()["pointerY"])) {
									if (this.stage) {
										if (this.stage.frameRate == 7) {
											this.stage.frameRate=24;
										}
									}
									viewer3DSWC.borderScaleX=viewer3DSWC.borderLine.width / parseFloat(viewerSharedObject.getData()["width"]);
									viewer3DSWC.borderScaleY=viewer3DSWC.borderLine.height / parseFloat(viewerSharedObject.getData()["height"]);
									viewer3DSWC.pointElepse.x=viewer3DSWC.borderScaleX * parseFloat(viewerSharedObject.getData()["pointerX"]) - 5;
									viewer3DSWC.pointElepse.y=viewer3DSWC.borderScaleY * parseFloat(viewerSharedObject.getData()["pointerY"]) - 2;
									if (viewerSharedObject.getData()["partname"] != null) {
										viewer3DSWC.partNameLabel.visible=true;
										viewer3DSWC.partNameLabel.text=viewerSharedObject.getData()["partname"];
										viewer3DSWC.partNameLabel.x=viewer3DSWC.pointElepse.x + 10;
										viewer3DSWC.partNameLabel.y=viewer3DSWC.pointElepse.y + 25;
									} else {
										viewer3DSWC.partNameLabel.visible=false;
									}
								}
							} else {
								viewer3DSWC.pointElepse.visible=false;
							}
						} else if (viewerSharedObject.getData()["showpointer"] == "false" && viewer3DSWC.pointElepse.visible == true) {
							viewer3DSWC.pointElepse.visible=false;
							viewer3DSWC.partNameLabel.visible=false;
							viewer3DSWC.partNameLabel.text="";
						}
						//Zoom or rotate or drag object
						if (viewer3DSWC.flare3DEngineInstance != null && viewer3DSWC.flare3DEngineInstance.defaultPivot != null) {
							if (this.stage) {
								if (this.stage.frameRate == 7) {
									this.stage.frameRate=24;
								}
							}
							if (FlexGlobals.topLevelApplication.selectedModuleIndex != 2 && FlexGlobals.topLevelApplication.selectedModuleSO.getData()["val"] == 2 && !isPopOut) {
								viewer3DSWC.flare3DEngineInstance.sceneObject.visible=true;
								FlexGlobals.topLevelApplication.selectedModuleIndex=2;
								if(FlexGlobals.topLevelApplication.screenTypes == Constants.SCREENTYPE_INDIVIDUAL){
									FlexGlobals.topLevelApplication.colbTools.tabs.selectedIndex = 4;
									FlexGlobals.topLevelApplication.colbTools.tabs.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
								}
							}
							if (!isPopOut && !FlexGlobals.topLevelApplication.viewer3D.contains(this)) {
								FlexGlobals.topLevelApplication.viewer3D.addElement(this);
							}
							if (viewerSharedObject.getData()["selectedpivot"] != null && viewerSharedObject.getData()["partselection"] == "true" && viewerSharedObject.getData()["newlogin"] == "false") {
								viewer3DSWC.partSelected=true;
								if (viewer3DSWC.lastPivot.name != viewerSharedObject.getData()["selectedpivot"]) {
									viewer3DSWC.resetScene();
									viewer3DSWC.lastPivot=viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewerSharedObject.getData()["selectedpivot"]);
								}
								viewer3DSWC.partSeperationDisabled=false;
							}
							if (viewer3DSWC.partSeparted) {
								viewer3DSWC.resetScene();
							}
							if (viewerSharedObject.getData()["selectedpivot"] != null && viewerSharedObject.getData()["partselection"] == "true") {
								viewer3DSWC.partSelected=true;
								//Bug fix #7372 start
								viewer3DSWC.partSeparted=true;
								//Bug fix #7372 end
								viewer3DSWC.partSeperationDisabled=false;
							}
							//Getting my values
							viewer3DSWC.currentPosition=viewer3DSWC.flare3DEngineInstance.loadingObject.getPosition();
							viewer3DSWC.currentRotation=viewer3DSWC.flare3DEngineInstance.loadingObject.getRotation();
							viewer3DSWC.zoomPresenterValue=viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom;
							viewer3DSWC.mouseWheel=viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom;
							viewer3DSWC.positionArray=viewerSharedObject.getData()["position"];
							viewer3DSWC.rotationArray=viewerSharedObject.getData()["rotation"];
							viewer3DSWC.objectPartDetails=viewerSharedObject.getData()["objectpartdetails"];
							if (viewer3DSWC.layerChanged != viewerSharedObject.getData()["layer"] && viewer3DSWC.objectPartDetails != null) 
							{
								viewer3DSWC.fullObjectVisible=false;
								for (i=0; i < viewer3DSWC.objectPartDetails.length; i++) {
									if (viewer3DSWC.currentPage == viewer3DSWC.objectPartDetails[i].canvasNumber) {
										if (!viewer3DSWC.objectPartDetails[i].visible && viewer3DSWC.objectPartDetails[i].meshName != null) 
										{
											viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewer3DSWC.objectPartDetails[i].meshName).visible=false;
										} 
										else if(viewer3DSWC.objectPartDetails[i].meshName != null) 
										{
											viewer3DSWC.fullObjectVisible=true;
											viewer3DSWC.flare3DEngineInstance.sceneObject.getChildByName(viewer3DSWC.objectPartDetails[i].meshName).visible=true;
										}
									}
								}
								if (viewer3DSWC.fullObjectVisible) 
								{
									viewer3DSWC.lblObjectVisibility.visible=false;
								} 
								else 
								{
									viewer3DSWC.lblObjectVisibility.visible=true;
									viewer3DSWC.flare3DEngineInstance.loadingObject.visible=false;
									viewer3DSWC.partNameLabel.text="";
								}
								viewer3DSWC.layerChanged=viewerSharedObject.getData()["layer"];
							}
							if (parseInt(viewerSharedObject.getData()["currentcanvas"]) != viewer3DSWC.currentPage && viewerSharedObject.getData()["currentcanvas"] != null) {
								viewer3DSWC.currentPage=parseInt(viewerSharedObject.getData()["currentcanvas"]);
								viewer3DSWC.lastLoadedPage=viewer3DSWC.currentPage;
								viewer3DSWC.objectDetails=viewerSharedObject.getData()["objectdetails"];
							}
							//Mouse Wheel Zoom
							if (viewer3DSWC.mouseWheel != parseFloat(viewerSharedObject.getData()["mousewheel"]) && viewerSharedObject.getData()["mousewheel"] != null) {
								viewer3DSWC.flare3DEngineInstance.sceneObject.camera.zoom=parseFloat(viewerSharedObject.getData()["mousewheel"]);
								viewer3DSWC.mouseWheel=parseFloat(viewerSharedObject.getData()["mousewheel"]);
							}
							
							if (viewerSharedObject.getData()["partselection"] == "false" && !viewer3DSWC.partSeperationDisabled) {
								//Bug #3993 start
								viewer3DSWC.resetScene();
								//Bug #3993 end
								viewer3DSWC.selectedPivot=viewer3DSWC.flare3DEngineInstance.defaultPivot;
								viewer3DSWC.lastPivot=viewer3DSWC.flare3DEngineInstance.defaultPivot;
								viewer3DSWC.rotationArray=null;
								viewer3DSWC.positionArray=null;
								viewer3DSWC.partSelected=false;
								viewer3DSWC.partSeperationDisabled=true;
							}
							if (viewer3DSWC.rotationArray != null && viewer3DSWC.positionArray != null && viewerSharedObject.getData()["newlogin"] == "false") {
								//Rotate object
								if (viewer3DSWC.currentRotation.x != viewer3DSWC.rotationArray[0] || viewer3DSWC.currentRotation.y != viewer3DSWC.rotationArray[1] || viewer3DSWC.currentRotation.z != viewer3DSWC.rotationArray[2]) {
									viewer3DSWC.lastPivot.setPosition(viewer3DSWC.positionArray[0], viewer3DSWC.positionArray[1], viewer3DSWC.positionArray[2]);
									viewer3DSWC.lastPivot.setRotation(viewer3DSWC.rotationArray[0], viewer3DSWC.rotationArray[1], viewer3DSWC.rotationArray[2]);
									viewer3DSWC.currentRotation=viewer3DSWC.selectedPivot.getRotation();
									viewer3DSWC.currentPosition=viewer3DSWC.selectedPivot.getPosition();
								}
							}
							if (viewer3DSWC.positionArray != null && viewer3DSWC.rotationArray != null && viewerSharedObject.getData()["newlogin"] == "false") {
								//Drag object
								if (viewer3DSWC.currentPosition.x != viewer3DSWC.positionArray[0] || viewer3DSWC.currentPosition.y != viewer3DSWC.positionArray[1] || viewer3DSWC.currentPosition.z != viewer3DSWC.positionArray[2]) {
									viewer3DSWC.lastPivot.setPosition(viewer3DSWC.positionArray[0], viewer3DSWC.positionArray[1], viewer3DSWC.positionArray[2]);
									viewer3DSWC.lastPivot.setRotation(viewer3DSWC.rotationArray[0], viewer3DSWC.rotationArray[1], viewer3DSWC.rotationArray[2]);
									viewer3DSWC.currentPosition=viewer3DSWC.selectedPivot.getPosition();
									viewer3DSWC.currentRotation=viewer3DSWC.selectedPivot.getRotation();
								}
							}
							//Animation control
							if (viewerSharedObject.getData()["animation"] == "true" && !viewer3DSWC.animationEnabled) {
								if (this.stage) {
									this.stage.frameRate=24;
								}
								viewer3DSWC.playReset=true;
								viewer3DSWC.resetScene();
								viewer3DSWC.flare3DEngineInstance.loadingObject.play();
								viewer3DSWC.animationEnabled=true;
							}
							if (viewerSharedObject.getData()["animation"] == "false" && viewer3DSWC.animationEnabled) {
								viewer3DSWC.flare3DEngineInstance.loadingObject.stop();
								viewer3DSWC.animationEnabled=false;
							}
						}
					}
				}
			}
		}
	}
}
// Rev 4326 SRS
