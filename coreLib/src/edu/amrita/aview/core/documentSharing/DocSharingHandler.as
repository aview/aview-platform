// ActionScript file
import edu.amrita.aview.core.documentSharing.DocComponent;
import edu.amrita.aview.core.entry.ClassroomContext;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;

/**Platform specific imports*/
applicationType::desktop
{
	import mx.events.AIREvent;
}

public var docComp:DocComponent;
public var loginname:String;
public var presenterName:String;
public var fmsip:String;
public var minimizeFlag:int=0;

/**
 * For Error log
 */
private var log:ILogger=Log.getLogger("aview.modules.documentSharing.DocSharingHandler.as");

/**
 * Initializing values to the parameters of DocComponent
 */
private function init():void{
	//initializing values to the parameters of DocComponent
	//docComp = new DocComponent;
	//setting component width as 100%
	applicationType::desktop{
		docComp.documentSharingMW.title="Document Sharing (A-VIEW - " + ClassroomContext.aviewClass.className + ")";
	}
	docComp.percentWidth=100;
	//setting component height as 100%
	docComp.percentHeight=100;
	//user's login name(userName) as teacher or student or admin
	docComp.userName=loginname;
	//IP address for connecting to the Wamp Server(ipAddress)
	docComp.ipAddress=ClassroomContext.CONTENT_DOCUMENT;
	//DocComponent object(docComp) is selected as child of DocSharing(doc)
	doc.addElement(docComp);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.popOutBtn.setStyle("icon", docComp.popinIcon);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.popOutBtn.toolTip="Pop-in";
	/*FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.popOutBtn_student.setStyle("icon", docComp.popinIcon);
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.popOutBtn_student.toolTip="Pop-in";*/
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.isPopOut=true;
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.popOutBtn.visible=true;
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.docComp.popOutBtn_student.visible=true;
	//this.focusManager.setFocus(docComp.teacherRefreshBtn);
}

/**
 * function for closing the connections when the application is closed
 */
//this is called when user closes document sharing window in multiple mode
public function close_doc():void{
	trace("close docc")
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.selectedModulle=99;
	//calling close_doc() function in DocComponent.mxml
	if (docComp)
		
		docComp.close_doc();
	applicationType::desktop{
		if (!docComp.documentSharingMW.closed)
			docComp.popOutDocWindow();
		else{
			docComp.isPopOut=true;
			docComp.popOutDocWindow();
		}
	}
	if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.flag_openwin_doc == 1)	{
		//this MAY not be using
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.open_winDoc.label="v";
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.opencurrentinWindow("Conso_Doc");
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.flag_openwin_doc=0;
		if (FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.openall_flag_doc == 1){
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.flag_openwin_doc=1;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.openall_flag_doc=0;
				//docComp.setsizep2f();  
		}
	}
}

/**
 * DocComponent width and height are setting when resizing the application window
 */
private function onResize():void{
	//////////////////////////////////////////////////////////////////////////////// 
	//calling when window is resizing in multiple mode
	//DocComponent width and height are setting by decrement 2 from DocSharing window width
	//this is for avoiding scrolls
	//if window is minimized, then minimizeFlag is set to 1;
	//START-----------------------------------------
	try{
		docComp.width=doc.width - 5;
		docComp.height=doc.height - 5;
	}
	catch (err:Error){
		if(Log.isError()) log.error("Error in onResize method:"+ err.getStackTrace());
	}
	if (this.width == 160)
		minimizeFlag=1;
	//END-------------------------------------------
}

applicationType::desktop{
	public function documentMWwindowActivateHandler(event:AIREvent):void{
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.multipleWindowActivateHandler("documentMW");
	}
}
