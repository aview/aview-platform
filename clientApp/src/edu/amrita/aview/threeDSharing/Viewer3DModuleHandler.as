
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
 * File			: Viewer3DModuleHandler.as
 * Module		: 3DViewer
 * Developer(s)	: Jayakrishnan R, Arun V
 * Reviewer(s)	: Pradeesh,Remya T
 *
 * Viewer3DModuleHandler.as file used to add popout functionality to Viewer3DModule.mxml for 3DViewer.
 *
 */

import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.threeDSharing.Viewer3DComponent;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;

/**
 *  For accessing the shared object and viewer3D library variables
 */
public var viewer3DComp:Viewer3DComponent;
/**
 * For setting the shared object based on user role
 */
public var userRole:String;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.threeDSharing.Viewer3DModuleHandler.as");

/**
 * Platform specific variables
 * */
applicationType::desktop {
	/* There is no AIREvent for web application.*/
	import mx.events.AIREvent;
}

/**
 *
 * @private
 * Invoked when user click on 3Dviewer pop-up button.
 *
 * @return void
 *
 */
private function init():void {
	applicationType::desktop {
		//title property is not available for canvas.
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.title="3D Viewer (A-VIEW - " + ClassroomContext.aviewClass.className + ")";
	}
	viewer3DComp.percentWidth=100;
	viewer3DComp.percentHeight=100;
	viewer3DComp.contentIPAddress=ClassroomContext.CONTENT_VIEWER3D;
	viewer3DCanvas.addChild(viewer3DComp);
	viewer3DComp.viewer3DSWC.backGround.x=viewer3DCanvas.x + 2;
	viewer3DComp.viewer3DSWC.backGround.y=viewer3DCanvas.y + 40;
	viewer3DComp.viewer3DSWC.backGround.width=viewer3DCanvas.width - 10;
	viewer3DComp.viewer3DSWC.backGround.height=viewer3DCanvas.height - 60;
	viewer3DComp.viewer3DSWC.leftCanvas.visible=false;
	viewer3DComp.viewer3DSWC.rightCanvas.visible=false;
	if (viewer3DComp.viewer3DSWC.loadIcon.visible) {
		viewer3DComp.viewer3DSWC.loadIcon.visible=false;
		viewer3DComp.viewer3DSWC.loadingLabel.visible=false;
	}
	applicationType::desktop {
		//activate() method is not available for canvas
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.activate();
	}
	viewer3DComp.viewer3DSWC.addComponent();
}

/**
 *
 * @public
 * Invoked when window get Activate
 *
 * @param event of Type AIREvent
 * @return void
 *
 */
applicationType::desktop {
	//There is no AIREvent for web application. 
	public function multippleWwindowActivateHandler(event:AIREvent):void {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multipleWindowActivateHandler("3dMW");
	}
}

/**
 *
 * @public
 * Invoked when resize the 3Dviewer window
 *
 *
 * @return void
 *
 */

public function onReSize():void {
	if (!FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isPopOut) {
		return;
	}
	// Rev 4326 SRS
	viewer3DComp.viewer3DSWC.lblObjectVisibility.x=viewer3DCanvas.width - 550;
	viewer3DComp.viewer3DSWC.lblPageNo.x=viewer3DComp.viewer3DSWC.brdrCont3DLoader.x + viewer3DCanvas.width - 60;
	viewer3DComp.viewer3DSWC.lblPageNo.y=viewer3DComp.viewer3DSWC.brdrCont3DLoader.y + 2;

	viewer3DComp.viewer3DSWC.imgInfo.x=viewer3DCanvas.width - 200;
	viewer3DComp.viewer3DSWC.imgInfo.y=viewer3DCanvas.height - 70;
	applicationType::desktop{
		viewer3DComp.viewer3DSWC.borderLine.x=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.viewer3DCanvas.x + 300;
	}
	viewer3DComp.viewer3DSWC.borderLine.width=viewer3DCanvas.width - 10;
	viewer3DComp.viewer3DSWC.borderLine.height=viewer3DCanvas.height - 60;
	if (viewer3DComp.viewer3DSWC.contextViewer3DMenuList) {
		viewer3DComp.viewer3DSWC.hideContextMenuList();
	}
	if (viewer3DComp.viewer3DSWC.scrollComponents) {
		viewer3DComp.viewer3DSWC.scrollComponents.objectLayer.width=viewer3DComp.viewer3DSWC.borderLine.x - 140;
	}
	viewer3DComp.viewer3DSWC.lblObjectName.width=viewer3DComp.viewer3DSWC.borderLine.x - 140;
	viewer3DComp.viewer3DSWC.imgInfo.width=200;
	viewer3DComp.viewer3DSWC.imgInfo.x=viewer3DCanvas.width - 100;
	viewer3DComp.viewer3DSWC.imgInfo.y=viewer3DCanvas.height - 70;
	if (viewer3DComp.viewer3DSWC.flare3DEngineInstance) {
		try {
			viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenHeight=viewer3DCanvas.height - 30;
			viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenWidth=viewer3DCanvas.width - 5;
			viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenAspectRatio=(viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenWidth / viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenHeight);
			viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectAspectRatio=(viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectHeight / viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectWidth);
			if (viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectAspectRatio <= viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenAspectRatio) {
				// The scaled size is based on the height
				viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledHeight=viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenHeight;
				viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth=(viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenHeight * viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectAspectRatio);
			} else {
				// The scaled size is based on the width
				viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth=viewer3DComp.viewer3DSWC.flare3DEngineInstance.screenWidth;
				viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledHeight=(viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth / viewer3DComp.viewer3DSWC.flare3DEngineInstance.objectAspectRatio);
			}
			viewer3DComp.viewer3DSWC.flare3DEngineInstance.sceneObject.setViewport(viewer3DCanvas.x + (viewer3DCanvas.width - viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2, viewer3DCanvas.y + 29, viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth, viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledHeight);
			viewer3DComp.viewer3DSWC.borderLine.x=viewer3DCanvas.x + (viewer3DCanvas.width - viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2 - 2;
			viewer3DComp.viewer3DSWC.borderLine.width=viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth + 2;
			viewer3DComp.viewer3DSWC.borderLine.height=viewer3DCanvas.height - 40;
			if (viewer3DComp.viewer3DSWC.scrollComponents && userRole == "PRESENTER") {
				viewer3DComp.viewer3DSWC.scrollComponents.objectLayer.width=viewer3DCanvas.x + (viewer3DCanvas.width - viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2 - 5;
			}
			viewer3DComp.viewer3DSWC.lblObjectName.width=viewer3DCanvas.x + (viewer3DCanvas.width - viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2 - 20;
			viewer3DComp.viewer3DSWC.imgInfo.x=viewer3DComp.viewer3DSWC.borderLine.x + viewer3DComp.viewer3DSWC.borderLine.width;
			applicationType::desktop{
				viewer3DComp.viewer3DSWC.imgInfo.width=(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.viewer3DCanvas.width - viewer3DComp.viewer3DSWC.flare3DEngineInstance.scaledWidth) / 2 - 20;
			}
		} 
		catch (error:Error) {
			if(Log.isError()) log.error("Error in onReSize method:"+ error.getStackTrace());

		}
	}
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.memoryState) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.memoryState.x=viewer3DComp.viewer3DSWC.borderLine.x + viewer3DComp.viewer3DSWC.borderLine.width - 75;
	}
	viewer3DComp.viewer3DSWC.lblObjectVisibility.x=(viewer3DComp.viewer3DSWC.borderLine.x + viewer3DComp.viewer3DSWC.borderLine.width) / 2;
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.x=(viewer3DCanvas.width / 2) - (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.width / 2);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.y=(viewer3DCanvas.height / 2) - (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D.height / 2);
	}
}


/**
 *
 * @public
 * Invoked when window close event occur
 *
 * remove the objects form the scene
 *
 *
 * @return void
 *
 */
public function closeViewer3D():void {
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModulle=99;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.ViewerIcon3D=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.Viewer3D_unclicked;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3D_count=0;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.setSharedObject("newlogin", "true");
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.objectLoaded=false;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.animationEnabled=false;
	if (viewer3DComp.viewer3DSWC.flare3DEngineInstance) {
		viewer3DComp.viewer3DSWC.spvObjectLoader.removeChild(viewer3DComp.viewer3DSWC.flare3DEngineInstance);
		viewer3DComp.viewer3DSWC.flare3DEngineInstance.sceneObject.removeChild(viewer3DComp.viewer3DSWC.flare3DEngineInstance.defaultPivot);
		viewer3DComp.viewer3DSWC.flare3DEngineInstance.defaultPivot.dispose();
		viewer3DComp.viewer3DSWC.flare3DEngineInstance.sceneObject.dispose();
		viewer3DComp.viewer3DSWC.flare3DEngineInstance=null;
	}
	if (userRole == "PRESENTER" && FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.fileManagerForViewer3D=null;
	}
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.isPopOut) {
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.popOut3DWindow();
	}

	applicationType::desktop {
		//close() method does not support in web application.
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DModule.close();
	}
}
